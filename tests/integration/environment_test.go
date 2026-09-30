package integration

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type aksSecurityProperties struct {
	AzureRBAC            bool `json:"azureRbac"`
	LocalAccountDisabled bool `json:"localAccountDisabled"`
	PrivateCluster       bool `json:"privateCluster"`
}

type virtualNetworkProperties struct {
	AddressSpace []string `json:"addressSpace"`
	Location     string   `json:"location"`
}

func TestTestEnvironmentAzureBehavior(t *testing.T) {
	t.Parallel()

	suffix := os.Getenv("TERRATEST_SUFFIX")
	if suffix == "" {
		suffix = strings.ToLower(strings.ReplaceAll(random.UniqueId(), "-", ""))
	}

	project := "aksit"
	environment := "r" + suffix
	location := "westeurope"
	resourceGroupName := fmt.Sprintf("rg-%s-%s-weu", project, environment)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../environments/test",
		Vars: map[string]interface{}{
			"project":                project,
			"environment":            environment,
			"location":               location,
			"admin_group_object_ids": []string{},
			"alert_email_receivers":  []map[string]interface{}{},
		},
		BackendConfig: map[string]interface{}{
			"key": "integration/" + suffix + "/platform-aks.tfstate",
		},
		EnvVars: map[string]string{
			"ARM_USE_OIDC":    "true",
			"ARM_USE_AZUREAD": "true",
		},
		Lock:               true,
		LockTimeout:        "10m",
		TimeBetweenRetries: 10 * time.Second,
		MaxRetries:         3,
	}
	terraformOptions = terraform.WithDefaultRetryableErrors(t, terraformOptions)

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be configured for integration tests")

	assert.True(t, azure.ResourceGroupExists(t, resourceGroupName, subscriptionID))

	clusterName := terraform.OutputRequired(t, terraformOptions, "aks_cluster_name")
	vnetID := terraform.OutputRequired(t, terraformOptions, "vnet_id")

	var aksProperties aksSecurityProperties
	runAzureJSON(t, "aks", &aksProperties,
		"aks", "show",
		"--resource-group", resourceGroupName,
		"--name", clusterName,
		"--query", "{azureRbac: aadProfile.enableAzureRbac, localAccountDisabled: disableLocalAccounts, privateCluster: apiServerAccessProfile.enablePrivateCluster}",
	)

	assert.True(t, aksProperties.AzureRBAC, "Azure RBAC must be enabled on the deployed AKS cluster")
	assert.True(t, aksProperties.LocalAccountDisabled, "The AKS local account must be disabled")
	assert.False(t, aksProperties.PrivateCluster, "The test environment intentionally uses a public AKS cluster")

	var virtualNetwork virtualNetworkProperties
	runAzureJSON(t, "virtual network", &virtualNetwork,
		"network", "vnet", "show",
		"--ids", vnetID,
		"--query", "{addressSpace: addressSpace.addressPrefixes, location: location}",
	)

	assert.Equal(t, location, virtualNetwork.Location)
	assert.Contains(t, virtualNetwork.AddressSpace, "10.101.0.0/16")
}

func runAzureJSON(t *testing.T, resourceName string, target interface{}, args ...string) {
	output := shell.RunCommandAndGetStdOut(t, shell.Command{
		Command: "az",
		Args:    args,
	})
	require.NoError(t, json.Unmarshal([]byte(output), target), "Unable to decode Azure CLI response for %s", resourceName)
}
