# 🥤 Système d'En-cas Intelligents

## Vue d'ensemble

Le système de génération de programmes hebdomadaires a été amélioré pour inclure automatiquement des **encas (snacks)** selon le profil utilisateur. Cette fonctionnalité répond aux besoins spécifiques des sportifs et des personnes qui veulent prendre du poids.

## 🎯 Objectif

- **Sportifs** : Fournir l'énergie supplémentaire nécessaire entre les repas
- **Prise de poids** : Augmenter l'apport calorique quotidien de manière équilibrée
- **Personnalisation** : Adapter les repas selon le niveau d'activité et les objectifs

## 🔧 Fonctionnement Technique

### Critères d'attribution des encas

Un utilisateur reçoit automatiquement des encas si :

1. **Niveau d'activité élevé** :
   - `ActivityLevel.veryActive` (Très actif)
   - `ActivityLevel.extremelyActive` (Extrêmement actif)

2. **Objectif de prise de poids** :
   - `WeightGoal.gain` avec objectif de +0.25 à +1 kg/semaine

3. **Activités sportives intenses** :
   - Sports avec intensité `SportIntensity.high` ou `SportIntensity.extreme`
   - Ou plus de 10 séances sportives par semaine

### Logique d'implémentation

#### 1. Génération GPT (`_generateGPTMeals`)
```dart
// Déterminer quels repas sont nécessaires selon le profil utilisateur
final requiredMeals = _determineRequiredMeals(userProfile, consumedMealTypes, consumedToday);
```

#### 2. Génération hebdomadaire (`_generateWeeklyMealsWithDates`)
```dart
// Déterminer quels repas sont nécessaires selon le profil utilisateur pour ce jour
final requiredMeals = _determineRequiredMealsForDay(userProfile, consumedMealTypes);
```

#### 3. Fonctions de détermination des repas

##### `_userNeedsSnacks(UserProfile userProfile)`
- Analyse si l'utilisateur a besoin d'encas
- Retourne `true` si critères remplis

##### `_isExtremelyActive(UserProfile userProfile)`
- Détermine si l'utilisateur est extrêmement actif
- Considère activité + sports + fréquence

##### `_determineRequiredMeals(UserProfile userProfile, List<String> consumedMealTypes, Map<String, dynamic> consumedToday)`
- Fonction principale pour génération GPT
- Inclut toujours encas pour profils éligibles

##### `_determineRequiredMealsForDay(UserProfile userProfile, List<String> consumedMealTypes)`
- Version adaptée pour génération hebdomadaire
- Logique similaire mais optimisée pour usage quotidien

## 🍎 Variétés d'encas disponibles

Le système propose **5 variations d'encas** adaptées au niveau de cuisine et aux préférences :

### Encas sains (indulgence < 0.5)
1. **Yaourt grec aux fruits** - Débutant : 2 min, Intermédiaire : Smoothie aux baies
2. **Pomme au fromage blanc** - Chia pudding aux fruits
3. **Mix de noix et fruits secs** - Avocat sur toast complet
4. **Banane au beurre d'arachide** - Salade de fruits frais
5. **Compote de pommes maison** - Overnight oats aux graines

### Encas gourmands (indulgence > 0.5)
1. **Carré de chocolat** - Tiramisu minute
2. **Pain d'épices** - Crème brûlée express
3. **Barre chocolatée** - Macarons maison
4. **Cookies aux pépites** - Tarte au citron meringuée
5. **Muffin aux myrtilles** - Éclair au chocolat

## 📊 Répartition calorique

### Avec encas (profils éligibles)
- **Petit-déjeuner** : 25% des calories
- **Déjeuner** : 30% des calories
- **Collation** : 20% des calories
- **Dîner** : 25% des calories

### Sans encas (profils standard)
- **Petit-déjeuner** : 25% des calories
- **Déjeuner** : 40% des calories
- **Dîner** : 35% des calories

## 🎮 Exemples d'utilisation

### Profil 1 : Sportif très actif
```dart
UserProfile(
  activityLevel: ActivityLevel.veryActive,
  weightGoal: WeightGoal.maintain,
  sportActivities: [/* sports quotidiens */]
)
// Résultat : 4 repas/jour (PDJ + Déjeuner + Collation + Dîner)
```

### Profil 2 : Prise de poids modérée
```dart
UserProfile(
  activityLevel: ActivityLevel.moderatelyActive,
  weightGoal: WeightGoal.gain,
  weightGoalKgPerWeek: 0.5
)
// Résultat : 4 repas/jour avec encas énergétiques
```

### Profil 3 : Utilisateur sédentaire
```dart
UserProfile(
  activityLevel: ActivityLevel.sedentary,
  weightGoal: WeightGoal.maintain
)
// Résultat : 3 repas/jour (encas seulement si pas encore consommé)
```

## 🔄 Compatibilité

### Générations compatibles
- ✅ **Génération GPT** : Intègre automatiquement les encas
- ✅ **Génération hebdomadaire** : Inclut encas selon profil
- ✅ **Génération quotidienne simulée** : Toujours 4 repas

### Données utilisateur utilisées
- Niveau d'activité (`ActivityLevel`)
- Objectif poids (`WeightGoal`)
- Activités sportives (`UserSportActivity[]`)
- Niveau de cuisine (`CookingLevel`)
- Préférences d'indulgence (`_indulgenceLevel`)

## 🧪 Tests et validation

### Tests unitaires
- ✅ Utilisateur sédentaire : Pas d'encas automatique
- ✅ Utilisateur très actif : Encas automatique
- ✅ Utilisateur prise de poids : Encas automatique
- ✅ Utilisateur sports intenses : Encas automatique

### Critères de succès
- Les sportifs reçoivent des encas énergétiques adaptés
- Les personnes en prise de poids ont un apport calorique équilibré
- Les utilisateurs sédentaires gardent la flexibilité
- Tous les niveaux de cuisine sont pris en compte

## 🚀 Avantages

### Pour les utilisateurs
- **Énergie optimisée** pour l'activité physique
- **Apport calorique adapté** aux objectifs
- **Variété alimentaire** accrue
- **Sensation de satiété** améliorée

### Pour l'application
- **Personnalisation intelligente** des repas
- **Adaptation automatique** aux profils
- **Équilibre nutritionnel** maintenu
- **Expérience utilisateur** enrichie

## 🔮 Évolutions futures

### Améliorations possibles
- **Encas personnalisés** selon allergies/restrictions
- **Horaires d'encas** adaptés aux rythmes
- **Quantités variables** selon l'appétit
- **Suivi de consommation** des encas

### Intégrations
- **Avec le système sportif** : Encas adaptés aux séances
- **Avec les objectifs nutritionnels** : Ajustements précis
- **Avec les préférences culturelles** : Encas régionaux

---

## 📝 Notes techniques

- Le système fonctionne en temps réel selon le profil utilisateur
- Les encas sont générés avec la même IA que les repas principaux
- La répartition calorique est automatiquement ajustée
- Compatible avec tous les niveaux de cuisine existants

**Date d'implémentation** : Décembre 2024
**Version** : 1.0
**Statut** : ✅ Opérationnel
