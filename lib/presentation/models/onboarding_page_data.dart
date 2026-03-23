import 'package:flutter/material.dart';

/// Data model for onboarding page content
/// Following SRP: Only holds onboarding page data
class OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData primaryIcon;
  final IconData? secondaryIcon;
  final Color iconColor;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.primaryIcon,
    this.secondaryIcon,
    required this.iconColor,
  });
}

/// List of onboarding pages with Indonesian content
/// Following the PRD key selling points
const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Catat Semua Transaksi',
    subtitle:
        'Pencatatan tanpa batas untuk setiap pemasukan dan pengeluaran Anda. Kendali penuh atas keuangan pribadi.',
    primaryIcon: Icons.receipt_long,
    secondaryIcon: Icons.add_circle,
    iconColor: Color(0xFFFF8A00), // Primary orange
  ),
  OnboardingPageData(
    title: 'Scan Struk Instan',
    subtitle:
        'Foto atau pilih struk dari galeri, aplikasi otomatis mengisi nominal. Input transaksi jadi lebih cepat.',
    primaryIcon: Icons.document_scanner,
    secondaryIcon: Icons.camera_alt,
    iconColor: Color(0xFFE53935), // Expense red
  ),
  OnboardingPageData(
    title: 'Insight Cerdas',
    subtitle:
        'Dapatkan ringkasan bulanan dan rekomendasi praktis untuk menghemat pengeluaran Anda.',
    primaryIcon: Icons.insights,
    secondaryIcon: Icons.lightbulb,
    iconColor: Color(0xFF43A047), // Income green
  ),
];
