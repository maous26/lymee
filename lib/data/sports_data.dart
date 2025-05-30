// Sports and activities data for nutrition app
import 'package:lym_nutrition/domain/entities/user_profile.dart';

class SportData {
  final String name;
  final String category;
  final SportIntensity recommendedIntensity;
  final String icon; // Emoji or icon name
  final List<String> alternativeNames;

  const SportData({
    required this.name,
    required this.category,
    required this.recommendedIntensity,
    required this.icon,
    this.alternativeNames = const [],
  });
}

class SportsDatabase {
  static const List<SportData> sports = [
    // Cardio / Course à pied
    SportData(
      name: 'Course à pied',
      category: 'Cardio',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃',
      alternativeNames: ['Running', 'Jogging', 'Course'],
    ),
    SportData(
      name: 'Jogging',
      category: 'Cardio',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏃‍♀️',
      alternativeNames: ['Course lente', 'Footing'],
    ),
    SportData(
      name: 'Sprint',
      category: 'Cardio',
      recommendedIntensity: SportIntensity.extreme,
      icon: '💨',
      alternativeNames: ['Course rapide', 'Vitesse'],
    ),
    SportData(
      name: 'Marathon',
      category: 'Cardio',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♂️',
      alternativeNames: ['Course longue distance', 'Endurance'],
    ),

    // Natation
    SportData(
      name: 'Natation',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏊',
      alternativeNames: ['Nage', 'Swimming'],
    ),
    SportData(
      name: 'Natation compétition',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.high,
      icon: '🏊‍♀️',
      alternativeNames: ['Nage intensive'],
    ),
    SportData(
      name: 'Aqua-fitness',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🌊',
      alternativeNames: ['Aquagym', 'Fitness aquatique'],
    ),
    SportData(
      name: 'Water-polo',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.high,
      icon: '🤽',
      alternativeNames: ['Polo aquatique'],
    ),
    SportData(
      name: 'Plongée',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.low,
      icon: '🤿',
      alternativeNames: ['Diving', 'Plongée sous-marine'],
    ),

    // Cyclisme
    SportData(
      name: 'Vélo',
      category: 'Cyclisme',
      recommendedIntensity: SportIntensity.medium,
      icon: '🚴',
      alternativeNames: ['Cyclisme', 'Bicyclette'],
    ),
    SportData(
      name: 'VTT',
      category: 'Cyclisme',
      recommendedIntensity: SportIntensity.high,
      icon: '🚵',
      alternativeNames: ['Vélo tout terrain', 'Mountain bike'],
    ),
    SportData(
      name: 'Vélo d\'appartement',
      category: 'Cyclisme',
      recommendedIntensity: SportIntensity.medium,
      icon: '🚴‍♀️',
      alternativeNames: ['Spinning', 'Bike indoor'],
    ),
    SportData(
      name: 'BMX',
      category: 'Cyclisme',
      recommendedIntensity: SportIntensity.high,
      icon: '🚲',
      alternativeNames: ['Bicross'],
    ),

    // Musculation & Fitness
    SportData(
      name: 'Musculation',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.high,
      icon: '🏋️',
      alternativeNames: ['Bodybuilding', 'Renforcement musculaire'],
    ),
    SportData(
      name: 'CrossFit',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏋️‍♀️',
      alternativeNames: ['Cross training'],
    ),
    SportData(
      name: 'Fitness',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.medium,
      icon: '💪',
      alternativeNames: ['Cardio-training', 'Remise en forme'],
    ),
    SportData(
      name: 'HIIT',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.extreme,
      icon: '⚡',
      alternativeNames: ['High Intensity Interval Training', 'Fractionné'],
    ),
    SportData(
      name: 'Pilates',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.low,
      icon: '🧘‍♀️',
      alternativeNames: ['Méthode Pilates'],
    ),
    SportData(
      name: 'Yoga',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.low,
      icon: '🧘',
      alternativeNames: ['Yoga doux', 'Hatha yoga'],
    ),
    SportData(
      name: 'Yoga dynamique',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.medium,
      icon: '🧘‍♂️',
      alternativeNames: ['Vinyasa', 'Power yoga', 'Ashtanga'],
    ),
    SportData(
      name: 'Stretching',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.low,
      icon: '🤸',
      alternativeNames: ['Étirements', 'Assouplissement'],
    ),
    SportData(
      name: 'Calisthenics',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.high,
      icon: '🤸‍♂️',
      alternativeNames: ['Street workout', 'Musculation au poids du corps'],
    ),

    // Sports de combat
    SportData(
      name: 'Boxe',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🥊',
      alternativeNames: ['Boxe anglaise'],
    ),
    SportData(
      name: 'Kickboxing',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🦵',
      alternativeNames: ['Savate'],
    ),
    SportData(
      name: 'MMA',
      category: 'Combat',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🤼',
      alternativeNames: ['Arts martiaux mixtes', 'Free fight'],
    ),
    SportData(
      name: 'Karaté',
      category: 'Combat',
      recommendedIntensity: SportIntensity.medium,
      icon: '🥋',
      alternativeNames: ['Karate-do'],
    ),
    SportData(
      name: 'Judo',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🥋',
      alternativeNames: ['Art martial japonais'],
    ),
    SportData(
      name: 'Taekwondo',
      category: 'Combat',
      recommendedIntensity: SportIntensity.medium,
      icon: '🦵',
      alternativeNames: ['Taekwon-do'],
    ),
    SportData(
      name: 'Aïkido',
      category: 'Combat',
      recommendedIntensity: SportIntensity.low,
      icon: '🥋',
      alternativeNames: ['Art martial défensif'],
    ),
    SportData(
      name: 'Escrime',
      category: 'Combat',
      recommendedIntensity: SportIntensity.medium,
      icon: '🤺',
      alternativeNames: ['Épée', 'Fleuret', 'Sabre'],
    ),

    // Sports collectifs
    SportData(
      name: 'Football',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '⚽',
      alternativeNames: ['Soccer'],
    ),
    SportData(
      name: 'Basketball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '🏀',
      alternativeNames: ['Basket-ball', 'Basket'],
    ),
    SportData(
      name: 'Volleyball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏐',
      alternativeNames: ['Volley-ball', 'Volley'],
    ),
    SportData(
      name: 'Handball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '🤾',
      alternativeNames: ['Hand-ball', 'Hand'],
    ),
    SportData(
      name: 'Rugby',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏉',
      alternativeNames: ['Rugby à 15', 'Rugby à 13'],
    ),
    SportData(
      name: 'Hockey sur glace',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '🏒',
      alternativeNames: ['Hockey'],
    ),
    SportData(
      name: 'Baseball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.medium,
      icon: '⚾',
      alternativeNames: ['Base-ball'],
    ),
    SportData(
      name: 'American Football',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏈',
      alternativeNames: ['Football américain'],
    ),

    // Sports de raquette
    SportData(
      name: 'Tennis',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.high,
      icon: '🎾',
      alternativeNames: ['Tennis de court'],
    ),
    SportData(
      name: 'Tennis de table',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏓',
      alternativeNames: ['Ping-pong'],
    ),
    SportData(
      name: 'Badminton',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.high,
      icon: '🏸',
      alternativeNames: ['Bad'],
    ),
    SportData(
      name: 'Squash',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.high,
      icon: '🎾',
      alternativeNames: ['Squash-ball'],
    ),
    SportData(
      name: 'Padel',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.medium,
      icon: '🎾',
      alternativeNames: ['Paddle tennis'],
    ),

    // Sports d'hiver
    SportData(
      name: 'Ski alpin',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.high,
      icon: '⛷️',
      alternativeNames: ['Ski de piste'],
    ),
    SportData(
      name: 'Ski de fond',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.high,
      icon: '🎿',
      alternativeNames: ['Ski nordique', 'Ski de randonnée'],
    ),
    SportData(
      name: 'Snowboard',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.high,
      icon: '🏂',
      alternativeNames: ['Surf des neiges'],
    ),
    SportData(
      name: 'Patinage artistique',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.medium,
      icon: '⛸️',
      alternativeNames: ['Patinage sur glace'],
    ),
    SportData(
      name: 'Hockey sur glace',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.high,
      icon: '🏒',
      alternativeNames: ['Hockey'],
    ),

    // Sports de précision
    SportData(
      name: 'Golf',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '⛳',
      alternativeNames: ['Golf 18 trous'],
    ),
    SportData(
      name: 'Tir à l\'arc',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '🏹',
      alternativeNames: ['Archerie'],
    ),
    SportData(
      name: 'Fléchettes',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '🎯',
      alternativeNames: ['Darts'],
    ),
    SportData(
      name: 'Billard',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '🎱',
      alternativeNames: ['Pool', 'Snooker'],
    ),

    // Sports nautiques
    SportData(
      name: 'Surf',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.high,
      icon: '🏄',
      alternativeNames: ['Surf des vagues'],
    ),
    SportData(
      name: 'Windsurf',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏄‍♀️',
      alternativeNames: ['Planche à voile'],
    ),
    SportData(
      name: 'Kitesurf',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.high,
      icon: '🪁',
      alternativeNames: ['Kite', 'Cerf-volant tracteur'],
    ),
    SportData(
      name: 'Voile',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.medium,
      icon: '⛵',
      alternativeNames: ['Bateau à voile', 'Dériveur'],
    ),
    SportData(
      name: 'Aviron',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.high,
      icon: '🚣',
      alternativeNames: ['Rame', 'Rowing'],
    ),
    SportData(
      name: 'Canoë-kayak',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.medium,
      icon: '🛶',
      alternativeNames: ['Canoë', 'Kayak', 'Pagaie'],
    ),
    SportData(
      name: 'Stand-up paddle',
      category: 'Sports nautiques',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏄‍♂️',
      alternativeNames: ['SUP', 'Paddle'],
    ),

    // Sports aériens
    SportData(
      name: 'Parapente',
      category: 'Sports aériens',
      recommendedIntensity: SportIntensity.low,
      icon: '🪂',
      alternativeNames: ['Vol libre'],
    ),
    SportData(
      name: 'Deltaplane',
      category: 'Sports aériens',
      recommendedIntensity: SportIntensity.low,
      icon: '🛩️',
      alternativeNames: ['Aile delta'],
    ),
    SportData(
      name: 'Parachutisme',
      category: 'Sports aériens',
      recommendedIntensity: SportIntensity.medium,
      icon: '🪂',
      alternativeNames: ['Saut en parachute'],
    ),

    // Sports de montagne
    SportData(
      name: 'Escalade',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.high,
      icon: '🧗',
      alternativeNames: ['Climbing', 'Grimpe'],
    ),
    SportData(
      name: 'Alpinisme',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏔️',
      alternativeNames: ['Haute montagne'],
    ),
    SportData(
      name: 'Randonnée',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.medium,
      icon: '🥾',
      alternativeNames: ['Trekking', 'Marche en montagne'],
    ),
    SportData(
      name: 'Trail',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♀️',
      alternativeNames: ['Course nature', 'Ultra-trail'],
    ),
    SportData(
      name: 'Via ferrata',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.medium,
      icon: '🧗‍♀️',
      alternativeNames: ['Chemin de fer'],
    ),

    // Sports équestres
    SportData(
      name: 'Équitation',
      category: 'Équestre',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏇',
      alternativeNames: ['Cheval', 'Hippisme'],
    ),
    SportData(
      name: 'Dressage',
      category: 'Équestre',
      recommendedIntensity: SportIntensity.low,
      icon: '🐎',
      alternativeNames: ['Dressage équestre'],
    ),
    SportData(
      name: 'Saut d\'obstacles',
      category: 'Équestre',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏇',
      alternativeNames: ['CSO', 'Jumping'],
    ),

    // Activités de loisir
    SportData(
      name: 'Marche',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.low,
      icon: '🚶',
      alternativeNames: ['Marche à pied', 'Promenade'],
    ),
    SportData(
      name: 'Marche rapide',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.medium,
      icon: '🚶‍♀️',
      alternativeNames: ['Power walking', 'Marche sportive'],
    ),
    SportData(
      name: 'Danse',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.medium,
      icon: '💃',
      alternativeNames: ['Dance', 'Danse classique'],
    ),
    SportData(
      name: 'Danse intensive',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.high,
      icon: '🕺',
      alternativeNames: ['Danse contemporaine', 'Hip-hop', 'Breakdance'],
    ),
    SportData(
      name: 'Zumba',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.medium,
      icon: '💃',
      alternativeNames: ['Fitness danse'],
    ),
    SportData(
      name: 'Bowling',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.low,
      icon: '🎳',
      alternativeNames: ['Quilles'],
    ),
    SportData(
      name: 'Skateboard',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.medium,
      icon: '🛹',
      alternativeNames: ['Skate', 'Planche à roulettes'],
    ),
    SportData(
      name: 'Roller',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.medium,
      icon: '🛼',
      alternativeNames: ['Patin à roulettes', 'Rollerblading'],
    ),
    SportData(
      name: 'Trottinette',
      category: 'Loisir',
      recommendedIntensity: SportIntensity.low,
      icon: '🛴',
      alternativeNames: ['Scooter', 'Patinette'],
    ),

    // Sports mécaniques
    SportData(
      name: 'Karting',
      category: 'Mécanique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏎️',
      alternativeNames: ['Kart'],
    ),
    SportData(
      name: 'Moto',
      category: 'Mécanique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏍️',
      alternativeNames: ['Motocross', 'Enduro'],
    ),

    // Autres sports
    SportData(
      name: 'Gymnastique',
      category: 'Gymnastique',
      recommendedIntensity: SportIntensity.high,
      icon: '🤸‍♀️',
      alternativeNames: ['Gym artistique'],
    ),
    SportData(
      name: 'Gymnastique rythmique',
      category: 'Gymnastique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🤸',
      alternativeNames: ['GR', 'Gym rythmique'],
    ),
    SportData(
      name: 'Trampoline',
      category: 'Gymnastique',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♂️',
      alternativeNames: ['Saut sur trampoline'],
    ),
    SportData(
      name: 'Athlétisme',
      category: 'Athlétisme',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♀️',
      alternativeNames: ['Course', 'Saut', 'Lancer'],
    ),
    SportData(
      name: 'Triathlon',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏊‍♂️',
      alternativeNames: ['Triath', 'Iron man'],
    ),
    SportData(
      name: 'Décathlon',
      category: 'Athlétisme',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏃',
      alternativeNames: ['Épreuves combinées'],
    ),

    // Sports de raquette additionnels
    SportData(
      name: 'Racquetball',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.high,
      icon: '🎾',
      alternativeNames: ['Racquet ball'],
    ),
    SportData(
      name: 'Beach tennis',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏐',
      alternativeNames: ['Tennis de plage'],
    ),

    // Sports de combat asiatiques
    SportData(
      name: 'Kung Fu',
      category: 'Combat',
      recommendedIntensity: SportIntensity.medium,
      icon: '🥋',
      alternativeNames: ['Wushu', 'Arts martiaux chinois'],
    ),
    SportData(
      name: 'Jiu-jitsu brésilien',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🤼‍♂️',
      alternativeNames: ['BJJ', 'Gracie Jiu-jitsu'],
    ),
    SportData(
      name: 'Muay Thai',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🥊',
      alternativeNames: ['Boxe thaï', 'Thai boxing'],
    ),
    SportData(
      name: 'Capoeira',
      category: 'Combat',
      recommendedIntensity: SportIntensity.medium,
      icon: '🤸‍♂️',
      alternativeNames: ['Art martial brésilien'],
    ),
    SportData(
      name: 'Krav Maga',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🥋',
      alternativeNames: ['Self-défense'],
    ),

    // Sports urbains
    SportData(
      name: 'Parkour',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♂️',
      alternativeNames: ['Freerunning', 'Art du déplacement'],
    ),
    SportData(
      name: 'Street workout',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.high,
      icon: '🤸‍♂️',
      alternativeNames: ['Calisthenics urbain'],
    ),
    SportData(
      name: 'BMX freestyle',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.high,
      icon: '🚲',
      alternativeNames: ['BMX acrobatique'],
    ),
    SportData(
      name: 'Longboard',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.medium,
      icon: '🛹',
      alternativeNames: ['Long skate'],
    ),

    // Sports d'eau froide
    SportData(
      name: 'Nage en eau libre',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.high,
      icon: '🏊‍♀️',
      alternativeNames: ['Open water swimming'],
    ),
    SportData(
      name: 'Triathlon Ironman',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏊‍♂️',
      alternativeNames: ['Iron man', 'Triath longue distance'],
    ),
    SportData(
      name: 'Aquathlon',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.high,
      icon: '🏊',
      alternativeNames: ['Course-natation'],
    ),

    // Sports de force
    SportData(
      name: 'Powerlifting',
      category: 'Force',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏋️‍♂️',
      alternativeNames: ['Force athlétique'],
    ),
    SportData(
      name: 'Haltérophilie',
      category: 'Force',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏋️‍♀️',
      alternativeNames: ['Weightlifting'],
    ),
    SportData(
      name: 'Strongman',
      category: 'Force',
      recommendedIntensity: SportIntensity.extreme,
      icon: '💪',
      alternativeNames: ['Homme fort'],
    ),
    SportData(
      name: 'Kettlebell',
      category: 'Force',
      recommendedIntensity: SportIntensity.high,
      icon: '🏋️',
      alternativeNames: ['Girya'],
    ),

    // Sports émergents
    SportData(
      name: 'Pickleball',
      category: 'Raquette',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏓',
      alternativeNames: ['Pickle ball'],
    ),
    SportData(
      name: 'Spikeball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '🏐',
      alternativeNames: ['Roundnet'],
    ),
    SportData(
      name: 'Ultimate Frisbee',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.high,
      icon: '🥏',
      alternativeNames: ['Ultimate', 'Frisbee'],
    ),
    SportData(
      name: 'Tchoukball',
      category: 'Sports collectifs',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏐',
      alternativeNames: ['Tchouk'],
    ),

    // Sports d'hiver additionnels
    SportData(
      name: 'Biathlon',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🎿',
      alternativeNames: ['Ski-tir'],
    ),
    SportData(
      name: 'Ski de randonnée',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.high,
      icon: '🎿',
      alternativeNames: ['Ski touring', 'Rando ski'],
    ),
    SportData(
      name: 'Raquettes à neige',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.medium,
      icon: '❄️',
      alternativeNames: ['Snowshoeing'],
    ),
    SportData(
      name: 'Luge',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.low,
      icon: '🛷',
      alternativeNames: ['Sledding'],
    ),
    SportData(
      name: 'Curling',
      category: 'Sports d\'hiver',
      recommendedIntensity: SportIntensity.low,
      icon: '🥌',
      alternativeNames: ['Pierre sur glace'],
    ),

    // Sports de plage
    SportData(
      name: 'Beach volley',
      category: 'Plage',
      recommendedIntensity: SportIntensity.high,
      icon: '🏐',
      alternativeNames: ['Volleyball de plage'],
    ),
    SportData(
      name: 'Beach soccer',
      category: 'Plage',
      recommendedIntensity: SportIntensity.high,
      icon: '⚽',
      alternativeNames: ['Football de plage'],
    ),
    SportData(
      name: 'Beach handball',
      category: 'Plage',
      recommendedIntensity: SportIntensity.high,
      icon: '🤾‍♀️',
      alternativeNames: ['Handball de plage'],
    ),
    SportData(
      name: 'Sandboarding',
      category: 'Plage',
      recommendedIntensity: SportIntensity.medium,
      icon: '🏂',
      alternativeNames: ['Surf des sables'],
    ),

    // Sports avec animaux
    SportData(
      name: 'Course de chiens de traîneaux',
      category: 'Animaux',
      recommendedIntensity: SportIntensity.medium,
      icon: '🐕',
      alternativeNames: ['Mushing', 'Attelage'],
    ),
    SportData(
      name: 'Polo',
      category: 'Équestre',
      recommendedIntensity: SportIntensity.high,
      icon: '🏇',
      alternativeNames: ['Polo équestre'],
    ),

    // Sports de tir
    SportData(
      name: 'Tir sportif',
      category: 'Tir',
      recommendedIntensity: SportIntensity.low,
      icon: '🎯',
      alternativeNames: ['Tir à la cible'],
    ),
    SportData(
      name: 'Tir à la carabine',
      category: 'Tir',
      recommendedIntensity: SportIntensity.low,
      icon: '🔫',
      alternativeNames: ['Carabine'],
    ),
    SportData(
      name: 'Ball-trap',
      category: 'Tir',
      recommendedIntensity: SportIntensity.low,
      icon: '🎯',
      alternativeNames: ['Tir aux pigeons d\'argile'],
    ),

    // Sports de précision additionnels
    SportData(
      name: 'Pétanque',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '⚪',
      alternativeNames: ['Boules', 'Jeu de boules'],
    ),
    SportData(
      name: 'Bowling sur gazon',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '🟢',
      alternativeNames: ['Lawn bowling'],
    ),
    SportData(
      name: 'Croquet',
      category: 'Précision',
      recommendedIntensity: SportIntensity.low,
      icon: '🔨',
      alternativeNames: ['Jeu de croquet'],
    ),

    // Sports de roue
    SportData(
      name: 'Roller derby',
      category: 'Roue',
      recommendedIntensity: SportIntensity.high,
      icon: '🛼',
      alternativeNames: ['Derby roller'],
    ),
    SportData(
      name: 'Skateboard vert',
      category: 'Roue',
      recommendedIntensity: SportIntensity.high,
      icon: '🛹',
      alternativeNames: ['Vert skating', 'Bowl'],
    ),
    SportData(
      name: 'Trottinette freestyle',
      category: 'Roue',
      recommendedIntensity: SportIntensity.high,
      icon: '🛴',
      alternativeNames: ['Scooter freestyle'],
    ),

    // Sports d'endurance spécialisés
    SportData(
      name: 'Ultramarathon',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏃‍♂️',
      alternativeNames: ['Ultra running', 'Course ultra'],
    ),
    SportData(
      name: 'Course d\'orientation',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.medium,
      icon: '🧭',
      alternativeNames: ['Orientation', 'CO'],
    ),
    SportData(
      name: 'Raid multisport',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.extreme,
      icon: '🏃‍♀️',
      alternativeNames: ['Adventure racing'],
    ),
    SportData(
      name: 'Duathlon',
      category: 'Endurance',
      recommendedIntensity: SportIntensity.high,
      icon: '🚴‍♂️',
      alternativeNames: ['Course-vélo-course'],
    ),

    // Sports adaptés/paralympiques
    SportData(
      name: 'Basket fauteuil',
      category: 'Adapté',
      recommendedIntensity: SportIntensity.high,
      icon: '♿',
      alternativeNames: ['Basketball en fauteuil roulant'],
    ),
    SportData(
      name: 'Tennis fauteuil',
      category: 'Adapté',
      recommendedIntensity: SportIntensity.high,
      icon: '♿',
      alternativeNames: ['Tennis en fauteuil roulant'],
    ),
    SportData(
      name: 'Cécifoot',
      category: 'Adapté',
      recommendedIntensity: SportIntensity.high,
      icon: '⚽',
      alternativeNames: ['Football pour aveugles'],
    ),

    // Sports traditionnels
    SportData(
      name: 'Lutte',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🤼',
      alternativeNames: ['Wrestling', 'Lutte libre'],
    ),
    SportData(
      name: 'Sumo',
      category: 'Combat',
      recommendedIntensity: SportIntensity.high,
      icon: '🤼‍♂️',
      alternativeNames: ['Lutte sumo'],
    ),

    // Sports aquatiques spécialisés
    SportData(
      name: 'Nage synchronisée',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.high,
      icon: '🏊‍♀️',
      alternativeNames: ['Natation artistique'],
    ),
    SportData(
      name: 'Plongeon',
      category: 'Aquatique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🤸‍♂️',
      alternativeNames: ['Diving', 'Plongeon de haut vol'],
    ),

    // Sports de sable
    SportData(
      name: 'Course sur sable',
      category: 'Plage',
      recommendedIntensity: SportIntensity.high,
      icon: '🏃‍♀️',
      alternativeNames: ['Beach running'],
    ),

    // Sports électroniques physiques
    SportData(
      name: 'Laser tag',
      category: 'Électronique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🔫',
      alternativeNames: ['Laser game'],
    ),
    SportData(
      name: 'Paintball',
      category: 'Électronique',
      recommendedIntensity: SportIntensity.medium,
      icon: '🎯',
      alternativeNames: ['Paint ball'],
    ),

    // Sports de fitness spécialisés
    SportData(
      name: 'TRX',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.high,
      icon: '⚖️',
      alternativeNames: ['Suspension training'],
    ),
    SportData(
      name: 'Bootcamp',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.extreme,
      icon: '💪',
      alternativeNames: ['Boot camp fitness'],
    ),
    SportData(
      name: 'Circuit training',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.high,
      icon: '🔄',
      alternativeNames: ['Entraînement en circuit'],
    ),
    SportData(
      name: 'Tabata',
      category: 'Fitness',
      recommendedIntensity: SportIntensity.extreme,
      icon: '⏱️',
      alternativeNames: ['Protocole Tabata'],
    ),

    // Nouveaux sports olympiques
    SportData(
      name: 'Skateboard street',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.high,
      icon: '🛹',
      alternativeNames: ['Street skating'],
    ),
    SportData(
      name: 'Skateboard park',
      category: 'Urbain',
      recommendedIntensity: SportIntensity.high,
      icon: '🛹',
      alternativeNames: ['Park skating'],
    ),
    SportData(
      name: 'Escalade sportive',
      category: 'Montagne',
      recommendedIntensity: SportIntensity.high,
      icon: '🧗‍♀️',
      alternativeNames: ['Sport climbing'],
    ),
  ];

  static List<String> getAllCategories() {
    return sports.map((sport) => sport.category).toSet().toList()..sort();
  }

  static List<SportData> getSportsByCategory(String category) {
    return sports.where((sport) => sport.category == category).toList();
  }

  static List<SportData> searchSports(String query) {
    if (query.isEmpty) return sports;
    
    final lowercaseQuery = query.toLowerCase();
    return sports.where((sport) {
      return sport.name.toLowerCase().contains(lowercaseQuery) ||
             sport.category.toLowerCase().contains(lowercaseQuery) ||
             sport.alternativeNames.any((name) => 
                name.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static SportData? getSportByName(String name) {
    try {
      return sports.firstWhere(
        (sport) => sport.name.toLowerCase() == name.toLowerCase() ||
                   sport.alternativeNames.any((altName) => 
                      altName.toLowerCase() == name.toLowerCase())
      );
    } catch (e) {
      return null;
    }
  }
}
