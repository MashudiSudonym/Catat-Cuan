import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// User tracking level based on transaction recording habits
enum UserTrackingLevel {
  /// No transactions yet
  pemula,

  /// Last transaction within 24 hours - Very Active
  sultanKeuangan,

  /// Last transaction within 3 days - Active
  stokisKeuangan,

  /// Last transaction within 7 days - Regular
  pencatatRajin,

  /// Last transaction within 14 days - Fair
  mulaiPeduli,

  /// Last transaction within 30 days - Inactive
  perluSemangat,

  /// Last transaction more than 30 days - Very Inactive
  janganMenyerah,
}

/// User tracking category with title and motivational quote
class UserTrackingCategory {
  final String title;
  final String quote;
  final String emoji;
  final ColorType colorType;

  const UserTrackingCategory({
    required this.title,
    required this.quote,
    required this.emoji,
    required this.colorType,
  });
}

/// Color type for tracking level badges
enum ColorType {
  /// Gold/Yellow for excellent
  gold,

  /// Green for good
  green,

  /// Blue for normal
  blue,

  /// Orange for warning
  orange,

  /// Red for alert
  red,

  /// Grey for neutral
  grey,
}

/// Service for determining user tracking level and generating motivational quotes
class UserTrackingLevelService {
  const UserTrackingLevelService();

  /// Calculate user tracking level based on transactions
  UserTrackingLevel calculateLevel(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return UserTrackingLevel.pemula;
    }

    // Get the most recent transaction
    final sortedTransactions = transactions.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final lastTransaction = sortedTransactions.first;
    final now = DateTime.now();
    final difference = now.difference(lastTransaction.dateTime);

    // Determine level based on time difference
    if (difference.inHours < 24) {
      return UserTrackingLevel.sultanKeuangan;
    } else if (difference.inDays < 3) {
      return UserTrackingLevel.stokisKeuangan;
    } else if (difference.inDays < 7) {
      return UserTrackingLevel.pencatatRajin;
    } else if (difference.inDays < 14) {
      return UserTrackingLevel.mulaiPeduli;
    } else if (difference.inDays < 30) {
      return UserTrackingLevel.perluSemangat;
    } else {
      return UserTrackingLevel.janganMenyerah;
    }
  }

  /// Get tracking category info for a given level
  UserTrackingCategory getCategoryInfo(UserTrackingLevel level) {
    switch (level) {
      case UserTrackingLevel.pemula:
        return const UserTrackingCategory(
          title: 'Calon Sultan',
          quote: 'Siap memulai perjalanan keuangan yang hebat 💪',
          emoji: '🌱',
          colorType: ColorType.grey,
        );

      case UserTrackingLevel.sultanKeuangan:
        return const UserTrackingCategory(
          title: 'Sultan Keuangan',
          quote: 'Disiplin tingkat dewa! Keuangan terkontrol penuh 👑',
          emoji: '🏆',
          colorType: ColorType.gold,
        );

      case UserTrackingLevel.stokisKeuangan:
        return const UserTrackingCategory(
          title: 'Stokis Keuangan',
          quote: 'Konsisten catat keuangan, mantap terus! 💰',
          emoji: '📈',
          colorType: ColorType.green,
        );

      case UserTrackingLevel.pencatatRajin:
        return const UserTrackingCategory(
          title: 'Pencatat Rajin',
          quote: 'Bagus! Terus jaga konsistensinya 🎯',
          emoji: '✨',
          colorType: ColorType.blue,
        );

      case UserTrackingLevel.mulaiPeduli:
        return const UserTrackingCategory(
          title: 'Mulai Peduli',
          quote: 'Hebat! Semangat catat keuangannya 💪',
          emoji: '🌟',
          colorType: ColorType.blue,
        );

      case UserTrackingLevel.perluSemangat:
        return const UserTrackingCategory(
          title: 'Perlu Semangat',
          quote: 'Ayo mulai catat lagi! Kamu pasti bisa 🔥',
          emoji: '⚡',
          colorType: ColorType.orange,
        );

      case UserTrackingLevel.janganMenyerah:
        return const UserTrackingCategory(
          title: 'Jangan Menyerah',
          quote: 'Kembali ke jalur yang benar, semangat! 💫',
          emoji: '🚀',
          colorType: ColorType.red,
        );
    }
  }

  /// Get tracking category info directly from transactions
  UserTrackingCategory getCategoryFromTransactions(List<TransactionEntity> transactions) {
    final level = calculateLevel(transactions);
    return getCategoryInfo(level);
  }

  /// Get tracking level description
  String getLevelDescription(UserTrackingLevel level) {
    switch (level) {
      case UserTrackingLevel.pemula:
        return 'Belum ada catatan transaksi';
      case UserTrackingLevel.sultanKeuangan:
        return 'Aktif mencatat (dalam 24 jam terakhir)';
      case UserTrackingLevel.stokisKeuangan:
        return 'Aktif mencatat (dalam 3 hari terakhir)';
      case UserTrackingLevel.pencatatRajin:
        return 'Cukup aktif (dalam 7 hari terakhir)';
      case UserTrackingLevel.mulaiPeduli:
        return 'Mulai aktif (dalam 14 hari terakhir)';
      case UserTrackingLevel.perluSemangat:
        return 'Kurang aktif (dalam 30 hari terakhir)';
      case UserTrackingLevel.janganMenyerah:
        return 'Sudah lama tidak mencatat';
    }
  }

  /// Get color for a color type
  static String getColorHex(ColorType colorType) {
    switch (colorType) {
      case ColorType.gold:
        return '#FFD700'; // Gold
      case ColorType.green:
        return '#4CAF50'; // Green
      case ColorType.blue:
        return '#2196F3'; // Blue
      case ColorType.orange:
        return '#FF9800'; // Orange
      case ColorType.red:
        return '#F44336'; // Red
      case ColorType.grey:
        return '#9E9E9E'; // Grey
    }
  }
}

/// Extension to get Color from ColorType
extension ColorTypeExtension on ColorType {
  Color toColor() {
    switch (this) {
      case ColorType.gold:
        return const Color(0xFFFFD700);
      case ColorType.green:
        return const Color(0xFF4CAF50);
      case ColorType.blue:
        return const Color(0xFF2196F3);
      case ColorType.orange:
        return const Color(0xFFFF9800);
      case ColorType.red:
        return const Color(0xFFF44336);
      case ColorType.grey:
        return const Color(0xFF9E9E9E);
    }
  }
}
