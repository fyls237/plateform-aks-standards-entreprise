# Guide de Contribution

Tout d'abord, merci de prendre le temps de contribuer à ce projet ! Ce document établit les lignes directrices pour contribuer au dépôt **plateform-aks-standards-entreprise**.

Ces directives sont conçues pour faciliter le processus de contribution, assurer la qualité du code Terraform et maintenir une infrastructure en tant que code (IaC) robuste et sécurisée.

## Table des Matières

1. [Pré-requis](#pré-requis)
2. [Processus de Développement](#processus-de-développement)
3. [Stratégie de Branche (Branching Strategy)](#stratégie-de-branche)
4. [Standards de Code (Terraform)](#standards-de-code-terraform)
5. [Conventions de Commit](#conventions-de-commit)
6. [Processus de Pull Request (PR)](#processus-de-pull-request)
7. [Sécurité et Conformité](#sécurité-et-conformité)

---

## Pré-requis

Pour contribuer à ce projet, vous devez installer les outils suivants sur votre poste de travail :

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (respecter la version minimale définie dans les fichiers `versions.tf`)
- [Azure CLI (az)](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Git](https://git-scm.com/downloads)
- [Make](https://www.gnu.org/software/make/) (utilisé pour l'orchestration des scripts de validation)
- [pre-commit](https://pre-commit.com/) (pour l'exécution des hooks locaux)
- [terraform-docs](https://terraform-docs.io/) (pour la génération automatique de la documentation)
- [tflint](https://github.com/terraform-linters/tflint) (pour l'analyse statique)
- [tfsec](https://github.com/aquasecurity/tfsec) ou [Trivy](https://trivy.dev/) (pour la sécurité du code)

### Initialisation de l'environnement local

1. Clonez le dépôt :
   ```bash
   git clone <URL_DU_REPO>
   cd plateform-aks-standards-entreprise
   ```

2. Installez les hooks pre-commit (fortement recommandé) :
   ```bash
   pre-commit install
   ```
   Cela garantira que votre code est formaté et vérifié avant chaque commit.

---

## Processus de Développement

Avant de soumettre des modifications, assurez-vous que votre code passe les validations locales.

Vous pouvez utiliser le `Makefile` ou les scripts du dossier `scripts/` pour valider votre code. Par exemple :
```bash
# Vérifier le formatage et valider les modules (ex: ./scripts/validate-all.sh)
./scripts/validate-all.sh
```

---

## Stratégie de Branche

Nous suivons une approche basée sur **GitHub Flow** / **Trunk-Based Development** adaptée pour l'infrastructure :

- `main` (ou `master`) : Branche principale. Elle doit toujours être dans un état déployable et stable. Le code sur cette branche représente l'infrastructure en production.
- **Branches de fonctionnalités / correctifs** : Créez une branche à partir de `main` pour vos développements.
  - Convention de nommage : `<type>/<issue-id-ou-description-courte>`
  - Types : `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`
  - Exemple : `feat/add-aks-private-cluster` ou `fix/update-node-pool-tags`

---

## Standards de Code (Terraform)

- **Formatage** : Le code doit toujours être formaté avec `terraform fmt`.
- **Validation** : Le code doit passer `terraform validate`.
- **Variables** : Toutes les variables doivent avoir une `description` et, si possible, un `type` strict et des blocs de `validation`.
- **Outputs** : Les outputs doivent être clairement documentés.
- **Documentation** : Utilisez `terraform-docs` pour maintenir les fichiers `README.md` des modules à jour. Les hooks pre-commit s'en chargeront automatiquement si configurés.
- **Chemins et Noms** : Privilégiez le snake_case pour les noms de ressources, de variables et de fichiers Terraform (ex: `resource_group_name`).

---

## Conventions de Commit

Nous utilisons les [Conventional Commits](https://www.conventionalcommits.org/fr/v1.0.0/) pour générer automatiquement le CHANGELOG et gérer les versions sémantiques (SemVer).

**Format du commit :**
```
<type>[scope optionnel]: <description courte>

[corps optionnel]

[pied de page optionnel]
```

**Types autorisés :**
- `feat` : Ajout d'une nouvelle fonctionnalité (ex: nouveau module Terraform).
- `fix` : Correction d'un bug (ex: correction d'une politique IAM).
- `docs` : Modification de la documentation uniquement.
- `style` : Changements qui n'affectent pas le sens du code (espaces, formatage, etc.).
- `refactor` : Modification du code qui ne corrige ni un bug ni n'ajoute une fonctionnalité.
- `test` : Ajout ou modification de tests.
- `chore` : Mise à jour des tâches de build, gestion des paquets, etc.

**Exemple :**
`feat(aks): ajout du support pour Azure CNI Overlay`

---

## Processus de Pull Request

1. Poussez votre branche sur le dépôt distant.
2. Ouvrez une Pull Request (PR) ciblant la branche `main`.
3. **Titre de la PR** : Doit suivre la convention des commits (ex: `feat: add integration with Azure Key Vault`).
4. **Description** : Remplissez le modèle de PR (s'il existe). Décrivez clairement le problème résolu et la solution apportée.
5. **CI/CD** : Assurez-vous que tous les pipelines GitHub Actions (ou Azure DevOps) passent avec succès (tests tfsec, tflint, formatage, plan Terraform).
6. **Revue de code** : Au moins une approbation (Approve) de la part d'un mainteneur ou d'un autre ingénieur plateforme est requise avant le merge.
7. **Merge** : Privilégiez le `Squash and Merge` pour garder un historique Git propre sur la branche `main`.

---

## Sécurité et Conformité

Le code d'infrastructure doit respecter les standards de sécurité de l'entreprise :

- **Pas de secrets en clair** : N'ajoutez jamais de mots de passe, tokens ou clés dans le code. Utilisez Azure Key Vault et des références (Data Sources).
- **Moindre Privilège** : Les attributions de rôles (RBAC) doivent être strictes et limiter l'accès au minimum nécessaire.
- **Ressources Privées** : Dans la mesure du possible, évitez d'exposer les ressources sur des adresses IP publiques sans justification.
- **Analyse statique** : Le code est scanné avec `tfsec` et/ou `checkov`. Les alertes bloquantes dans la CI devront être corrigées avant que la PR puisse être fusionnée.

Merci encore pour votre contribution à l'amélioration de la plateforme !
