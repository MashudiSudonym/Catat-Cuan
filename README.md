<div align="center">

  ![Catat Cuan Logo](assets/icons/app_icon.png)

  # Catat Cuan 📱💰

  **Aplikasi Pencatatan Keuangan Pribadi dengan AI Smart Scan**

  [![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
  [![Riverpod](https://img.shields.io/badge/Riverpod-3.3.1-0A8FFF?logo=flutter)](https://riverpod.dev)
  [![AI/ML](https://img.shields.io/badge/AI%2FML-Google%20ML%20Kit-F59E0B?logo=tensorflow)](https://developers.google.com/ml-kit)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey)](https://flutter.dev/multi-platform)
  [![SOLID](https://img.shields.io/badge/SOLID-100%25%20SRP-brightgreen.svg)](docs/guides/SOLID.md)
  [![Tests](https://img.shields.io/badge/Tests-791%2F791%20Passing-success.svg)](https://github.com/MashudiSudonym/Catat-Cuan)
  [![Version](https://img.shields.io/badge/Version-1.5.0-blue.svg)](https://github.com/MashudiSudonym/Catat-Cuan/releases)

  [Bahasa Indonesia](#indonesia) | [English](#english)

</div>

---

<a id="indonesia"></a>

## Indonesia

### 🌟 Mengapa Catat Cuan?

**"Uang sering terasa bocor tanpa jelas ke mana?"**

Catat Cuan hadir untuk memberikan **kendali sadar** atas keuangan pribadimu. Bukan sekadar mengetahui saldo akhir, tapi memahami **pola pengeluaran** dan mendapatkan **insight nyata** untuk mengoptimalkan keuanganmu.

---

### ✨ Fitur Utama

#### 🤖 **AI Smart Scan - Pindai Struk dengan Kecerdasan Buatan!**
> "Dari buka kamera sampai nominal terisi ≤ 30 detik - Powered by On-Device AI"

- **Neural Network Text Recognition** - Google ML Kit untuk membaca struk dengan akurasi tinggi
- **Smart Amount Detection** - AI mengenali pola "Total", "Jumlah", "Grand Total"
- **Multi-Format Support** - Mengenali format mata uang Indonesia (Rp 50.000, 50.000, dll)
- **100% On-Device** - Privasi terjaga, data tidak dikirim ke server
- **Merchant Recognition** (v1.4) - Kenali 50+ merchant Indonesia otomatis
- **Category Prediction** (v1.4) - Prediksi kategori berdasarkan merchant

#### 💸 **Pencatatan Transaksi Tanpa Batas**
- **Unlimited transactions** - catat sebanyak apapun
- **Input manual cepat** - selesai dalam ≤ 20 detik
- **Kategorisasi fleksibel** - atur kategori sesuai kebutuhanmu

#### 📊 **Dashboard & Insight Bulanan**
- **Ringkasan bulanan**: Total pemasukan, pengeluaran, dan saldo
- **Top kategori** dengan persentase & visualisasi chart
- **AI-Powered Recommendations** - Insight personal dari pola pengeluaranmu

#### 🏷️ **Manajemen Kategori Penuh**
- **Kategori default** siap pakai
- **Custom kategori** dengan warna & icon
- **Drag & drop reorder** - atur urutan sesuai preferensi

#### 🎨 **Desain Glassmorphism Modern**
- **UI frosted glass** dengan tema orange
- **Responsive design** - mobile, tablet, desktop
- **Smooth animations** - pengalaman premium

#### 📱 **Home Screen Widgets** (v1.3)
- **Widget Android/iOS** - Ringkasan pengeluaran di home screen
- **Quick Add** - Tap widget untuk langsung tambah transaksi
- **Auto Update** - Widget update otomatis setelah transaksi baru

---

### 🚀 Teknologi

| Komponen | Teknologi | Versi |
|----------|-----------|-------|
| **Framework** | Flutter | 3.5+ |
| **Bahasa** | Dart | 3.5+ |
| **State Management** | Riverpod | 3.3.1 |
| **Database** | SQLite | SchemaManager v2 |
| **🤖 AI/ML** | Google ML Kit | 0.15.1 (On-Device) |

**Arsitektur**: Clean Architecture dengan 100% SRP Compliance

---

### 📦 Quick Start

```bash
# Clone repository
git clone https://github.com/MashudiSudonym/Catat-Cuan.git
cd Catat-Cuan

# Install dependencies
flutter pub get

# Generate code (Riverpod/Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# Run application
flutter run
```

---

### 🧪 Kualitas Terjamin

- **Tests**: 791/791 passing ✅
- **SRP Compliance**: 100% (16/16 violations addressed)
- **Analyzer Errors**: 0 ✅

---

### 📚 Dokumentasi

**⭐ Mulai di sini:** [AI_ASSISTANT_GUIDE.md](./docs/AI_ASSISTANT_GUIDE.md)

#### Panduan Teknis (English)
- [ARCHITECTURE.md](./docs/guides/ARCHITECTURE.md) - Clean Architecture dengan contoh nyata
- [RIVERPOD_GUIDE.md](./docs/guides/RIVERPOD_GUIDE.md) - Riverpod 3.3.1 patterns
- [CODING_STANDARDS.md](./docs/guides/CODING_STANDARDS.md) - File naming & conventions
- [SOLID.md](./docs/guides/SOLID.md) - SOLID principles dengan contoh codebase

#### Status Proyek
- [PROJECT_STATUS.md](./docs/project/PROJECT_STATUS.md) - Status proyek lengkap (EN/ID)
- [IMPLEMENTATION_STATUS.md](./docs/v1/product/IMPLEMENTATION_STATUS.md) - Status implementasi fitur

---

### 🎯 Roadmap

#### v1.2.2 ✅
- [x] Pencatatan transaksi manual
- [x] 🤖 AI Smart Scan dengan Google ML Kit
- [x] Dashboard ringkasan bulanan
- [x] AI Analytics & recommendations
- [x] Manajemen kategori lengkap
- [x] Glassmorphism design system
- [x] Export/Import CSV
- [x] Multi-select delete
- [x] Onboarding system
- [x] Currency settings (IDR/USD)
- [x] GoRouter navigation
- [x] Dark mode / Theme switching
- [x] Pagination (infinite scroll)
- [x] Full-text search

#### v1.3 ✅ (Home Screen Widgets)
- [x] Widget home screen (Android/iOS)
- [x] Widget deep linking (tap widget → buka form tambah transaksi)
- [x] Widget data update otomatis setelah transaksi baru

#### v1.4 ✅ (Enhanced AI Model)
- [x] ML Kit Latin script configuration untuk teks Indonesia
- [x] Ekstraksi nama merchant dari 50+ retailer Indonesia
- [x] Prediksi kategori berdasarkan merchant yang dikenali
- [x] UI display nama merchant di hasil scan

#### v1.5 ✅ (Documentation & Code Standards)
- [x] English-only code comments standard
- [x] Documentation synchronization across all files
- [x] Version synchronization (1.2.2 → 1.5.0)

#### v2.0 (Mendatang)
- [ ] 💬 AI Chatbot assistant
- [ ] Cloud sync & backup
- [ ] Budgeting per kategori
- [ ] Multi-currency dengan AI prediction

---

### 🤝 Kontribusi

Kontribusi sangat welcome!

1. Fork repository
2. Buat branch fitur
3. Commit perubahan
4. Push & buat Pull Request

---

### 📝 Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

---

### 📧 Kontak

- **Project**: [Catat Cuan](https://github.com/MashudiSudonym/Catat-Cuan)
- **Issues**: [GitHub Issues](https://github.com/MashudiSudonym/Catat-Cuan/issues)

---

### 🙏 Terima Kasih

**"Catat setiap rupiah, pahami setiap keputusan, capai setiap tujuan."** 💰✨

---

<a id="english"></a>

## English

### 🌟 Why Catat Cuan?

**"Money often feels like it's leaking without knowing where?"**

Catat Cuan gives you **conscious control** over your personal finances. Understand **spending patterns** and get **real insights** to optimize your finances.

---

### ✨ Key Features

- **🤖 AI Smart Scan** - Scan receipts with Google ML Kit (on-device, private)
- **🏪 Merchant Recognition** - Auto-recognize 50+ Indonesian retailers (v1.4)
- **📊 Monthly Dashboard** - AI-powered insights & recommendations
- **💸 Unlimited Transactions** - Record as much as you want
- **🏷️ Category Management** - Full CRUD with drag-drop reorder
- **🎨 Glassmorphism Design** - Modern, responsive UI
- **📱 Home Screen Widgets** - Quick expense tracking from home screen (v1.3)

---

### 🚀 Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.5+ |
| Language | Dart | 3.5+ |
| State Management | Riverpod | 3.3.1 |
| Navigation | GoRouter | 17.1.0 |
| Database | SQLite | SchemaManager v2 |
| AI/ML | Google ML Kit | 0.15.1 |

**Architecture**: Clean Architecture with 100% SRP compliance

---

### 📚 Documentation

**⭐ [AI_ASSISTANT_GUIDE.md](./docs/AI_ASSISTANT_GUIDE.md)** - Critical rules & quick reference

**Technical Guides:**
- [ARCHITECTURE.md](./docs/guides/ARCHITECTURE.md)
- [RIVERPOD_GUIDE.md](./docs/guides/RIVERPOD_GUIDE.md)
- [CODING_STANDARDS.md](./docs/guides/CODING_STANDARDS.md)
- [SOLID.md](./docs/guides/SOLID.md)

**Project Status:**
- [PROJECT_STATUS.md](./docs/project/PROJECT_STATUS.md)
- [IMPLEMENTATION_STATUS.md](./docs/v1/product/IMPLEMENTATION_STATUS.md)

---

### 🤝 Contributing

Contributions welcome! Please follow [CODING_STANDARDS.md](./docs/guides/CODING_STANDARDS.md) and SOLID principles.

---

**Built with ❤️ using Flutter**

<div align="center">
  <sub>Production Ready | 100% SRP Compliance | 791/791 Tests Passing</sub>
</div>
