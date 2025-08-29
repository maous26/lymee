# 🎤 Guide Speech-to-Text avec API Google

## 🔧 Configuration des clés API

### 1. Créer le fichier `.env`
```bash
# Copier ENV_EXAMPLE.txt vers .env
cp ENV_EXAMPLE.txt .env
```

### 2. Configurer les clés dans `.env`
```env
# OpenAI API Key - Obligatoire
OPENAI_API_KEY=sk-proj-...

# Google API Key - Pour Speech-to-Text avancé
GOOGLE_API_KEY=AIza...
```

### 📍 Obtenir la clé Google API

1. **Aller sur [Google Cloud Console](https://console.cloud.google.com/)**
2. **Créer/sélectionner un projet**
3. **Activer l'API Speech-to-Text:**
   - APIs & Services → Library
   - Rechercher "Cloud Speech-to-Text API"
   - Cliquer "Enable"
4. **Créer une clé API:**
   - APIs & Services → Credentials
   - Create Credentials → API Key
   - Copier la clé générée

## 🧪 Test dans l'application

### Interface de test intégrée

1. **Ouvrir l'app** → Journal → "Créer une recette"
2. **Aller à l'étape "Description vocale"**
3. **Choisir le service:**
   - 📱 **Natif** : Services iOS/Android natifs
   - ☁️ **Google** : API Google Cloud Speech
4. **Tester l'API Google:**
   - Cliquer l'icône 🔬 (Science)
   - Vérifier le message de succès/erreur

### Services disponibles

#### 📱 Service Natif (speech_to_text)
- ✅ **Gratuit** et intégré
- ✅ **Reconnaissance française** correcte
- ✅ **Pas de clé API** nécessaire
- ⚠️ **Qualité** variable selon device

#### ☁️ Service Google Cloud
- ✅ **Précision élevée** et contexte culinaire
- ✅ **Ponctuation automatique**
- ✅ **Modèles optimisés** (latest_long)
- 💰 **Payant** après quota gratuit
- 🔑 **Clé API** obligatoire

## 🎯 Test de reconnaissance vocale

### Phrases de test recommandées :

```
"Pour cette recette de pâtes carbonara, j'ai besoin de 300 grammes de spaghettis, 150 grammes de lardons, 3 œufs entiers, 100 grammes de parmesan râpé, du poivre noir et un peu de sel. Je fais d'abord cuire les pâtes dans l'eau bouillante salée pendant 8 minutes, puis je fais revenir les lardons dans une poêle jusqu'à ce qu'ils soient dorés."
```

### Critères d'évaluation :
- ✅ **Nombres** (300 grammes, 8 minutes)
- ✅ **Ingrédients** (spaghettis, parmesan)
- ✅ **Actions** (cuire, revenir, faire)
- ✅ **Ponctuation** (virgules, points)

## 🔧 Dépannage

### Erreur "Clé API manquante"
```
Solution: Vérifier que GOOGLE_API_KEY est bien dans .env
```

### Erreur "Service non disponible"
```
Solution: Vérifier les permissions microphone
- iOS: NSMicrophoneUsageDescription
- Android: RECORD_AUDIO
```

### Erreur CocoaPods macOS
```
Solution: Vérifier macOS deployment target ≥ 11.0
- Podfile: platform :osx, '11.0'
- AppInfo.xcconfig: MACOSX_DEPLOYMENT_TARGET = 11.0
```

## 💡 Performance et coûts

### Google Speech API - Tarification
- **Gratuit** : 60 minutes/mois
- **Standard** : $0.006 par tranche de 15 secondes
- **Enhanced** : $0.009 par tranche de 15 secondes

### Recommandations
1. **Développement** : Utiliser service natif
2. **Production** : Tester les deux et choisir selon qualité
3. **Hybride** : Fallback natif si quota Google épuisé

## 🎉 Résultats attendus

Avec une configuration correcte, vous devriez voir :
- ✅ **Bouton test Google** → "API Google configurée avec succès"
- ✅ **Recognition temps réel** avec le service sélectionné
- ✅ **Transcription précise** des termes culinaires
- ✅ **Basculement automatique** vers natif si Google indisponible
