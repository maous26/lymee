#!/bin/bash

# Création du projet Flutter
flutter create --org com.lym --project-name lym_nutrition .

# Création de la structure de dossiers
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/themes
mkdir -p lib/domain/entities
mkdir -p lib/domain/usecases
mkdir -p lib/domain/repositories
mkdir -p lib/data/models
mkdir -p lib/data/datasources/local
mkdir -p lib/data/datasources/remote
mkdir -p lib/data/repositories
mkdir -p lib/core/util
mkdir -p lib/core/error
mkdir -p lib/core/network
mkdir -p assets/data
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

# Ajout des dépendances essentielles
flutter pub add provider
flutter pub add flutter_bloc
flutter pub add equatable
flutter pub add dartz
flutter pub add get_it
flutter pub add http
flutter pub add path_provider
flutter pub add sqflite
flutter pub add shared_preferences
flutter pub add cached_network_image
flutter pub add lottie
flutter pub add flutter_svg
flutter pub add intl
flutter pub add json_annotation
flutter pub add json_serializable --dev
flutter pub add build_runner --dev

# Copie de la base CIQUAL dans les assets
echo "Placez votre fichier common_ciqual.json dans le dossier assets/data/"

# Message de fin
echo "Structure initiale du projet créée avec succès!"
