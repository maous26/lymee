// lib/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    required bool isEmailVerified,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) : super(
          id: id,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          isEmailVerified: isEmailVerified,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
