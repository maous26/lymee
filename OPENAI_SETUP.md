# Configuration OpenAI pour Génération IA de Séances

## 🚀 Setup Rapide

1. **Créer un fichier `.env`** dans le dossier racine du projet
2. **Ajouter votre clé OpenAI:**

```env
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
OPENAI_MODEL=gpt-4o-mini
```

## 📋 Comment obtenir une clé OpenAI

1. Aller sur [platform.openai.com](https://platform.openai.com)
2. Se connecter/créer un compte
3. Aller dans **API Keys** 
4. Créer une nouvelle clé
5. Copier la clé dans votre fichier `.env`

## ⚡ Avantages OpenAI vs Simulation

**Avec OpenAI:**
- Séances détaillées et professionnelles
- Exercices précis avec séries/répétitions
- Instructions étape par étape
- Conseils de sécurité personnalisés
- Estimation calories précise

**Sans OpenAI (simulation):**
- Séances basiques génériques
- Format minimal
- Pas de personnalisation

## 🎯 Test

Une fois configuré, cliquez sur **"Générer une séance"** dans le Journal et vous devriez voir une séance riche et détaillée au lieu du format basique actuel.

## 💰 Coût

GPT-4o-mini coûte environ 0.15$ par million de tokens, soit ~0.001$ par séance générée.
