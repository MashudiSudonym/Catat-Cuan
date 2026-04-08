# SPEC v2 – Dark Mode

## Daftar Persyaratan Teknis (REQ-THM)

### REQ-THM-001: Theme System Architecture
Sistem menyediakan arsitektur tema yang mendukung light dan dark mode.

#### AC-THM-001.1: Theme Mode Options
- [ ] Tiga opsi tema:
  - Light (tema terang)
  - Dark (tema gelap)
  - System Default (mengikuti pengaturan device)

#### AC-THM-001.2: Theme Persistence
- [ ] Pilihan tema disimpan di local storage
- [ ] Tema tetap konsisten setelah app restart
- [ ] Default: System Default

#### AC-THM-001.3: Runtime Theme Switch
- [ ] Tema dapat diubah kapan saja dari Settings
- [ ] Perubahan tema instan tanpa restart app
- [ ] Smooth transition animation (opsional)

---

### REQ-THM-002: Color Scheme Definitions
Sistem mendefinisikan color scheme untuk light dan dark mode.

#### AC-THM-002.1: Light Theme Colors
- [ ] Primary: #4CAF50 (Green)
- [ ] Background: #FFFFFF
- [ ] Surface: #F5F5F5
- [ ] Card: #FFFFFF
- [ ] Text Primary: #212121
- [ ] Text Secondary: #757575
- [ ] Error: #F44336
- [ ] Success: #4CAF50
- [ ] Warning: #FF9800

#### AC-THM-002.2: Dark Theme Colors
- [ ] Primary: #81C784 (Light Green - untuk contrast)
- [ ] Background: #121212 (Material Design dark)
- [ ] Surface (elevation 1): #1E1E1E
- [ ] Surface (elevation 2): #2C2C2C
- [ ] Card: #1E1E1E
- [ ] Text Primary: #FFFFFF
- [ ] Text Secondary: #B0B0B0
- [ ] Error: #EF5350
- [ ] Success: #81C784
- [ ] Warning: #FFB74D

#### AC-THM-002.3: Glassmorphism Adaptation
- [ ] Light mode: glass dengan white tint + opacity
- [ ] Dark mode: glass dengan dark tint + opacity
- [ ] Blur effect tetap berfungsi di dark mode
- [ ] Border colors adjusted untuk visibility

---

### REQ-THM-003: Component Adaptations
Semua komponen UI harus mendukung dark mode.

#### AC-THM-003.1: Base Components
- [ ] AppContainer mendukung theme-aware colors
- [ ] AppGlassContainer dengan dark mode variants
- [ ] AppCard dengan theme-aware background
- [ ] AppButton dengan theme-aware styling
- [ ] AppTextField dengan theme-aware input decoration

#### AC-THM-003.2: Navigation Components
- [ ] BottomNavigationBar dengan dark mode styling
- [ ] AppBar dengan theme-aware background
- [ ] Drawer dengan dark mode styling

#### AC-THM-003.3: Data Display Components
- [ ] Charts dengan theme-aware colors
- [ ] Lists dengan theme-aware dividers
- [ ] Cards dengan theme-aware shadows/borders

#### AC-THM-003.4: Feedback Components
- [ ] Snackbar dengan theme-aware styling
- [ ] Dialog dengan dark mode styling
- [ ] BottomSheet dengan dark mode styling

---

### REQ-THM-004: Theme Settings UI
Sistem menyediakan UI untuk mengatur tema.

#### AC-THM-004.1: Theme Toggle in Settings
- [ ] Settings screen memiliki section "Tampilan"
- [ ] Opsi tema dengan radio buttons atau segmented control
- [ ] Preview thumbnail untuk setiap opsi (opsional)

#### AC-THM-004.2: Theme Preview
- [ ] Saat memilih tema, preview perubahan langsung terlihat
- [ ] Tidak perlu save, perubahan langsung aktif

#### AC-THM-004.3: Quick Theme Toggle
- [ ] Opsional: Quick toggle di AppBar atau profile menu
- [ ] Toggle cycle: Light → Dark → System → Light

---

### REQ-THM-005: System Theme Following
Sistem mengikuti pengaturan tema device.

#### AC-THM-005.1: Platform Brightness Detection
- [ ] Detect platform brightness change (light ↔ dark)
- [ ] Update app theme secara real-time
- [ ] Works on Android, iOS, macOS, Windows, Linux

#### AC-THM-005.2: System Theme Change Response
- [ ] Listen ke `MediaQuery.platformBrightness`
- [ ] Theme change tanpa restart app
- [ ] Smooth transition saat system theme berubah

---

### REQ-THM-006: Accessibility
Dark mode harus memenuhi standar accessibility.

#### AC-THM-006.1: Contrast Ratio
- [ ] Text contrast ratio ≥4.5:1 untuk normal text
- [ ] Text contrast ratio ≥3:1 untuk large text
- [ ] Icon contrast ratio ≥3:1

#### AC-THM-006.2: Color Independence
- [ ] Informasi tidak hanya conveyed by color
- [ ] Gunakan icon, text, atau pattern sebagai tambahan
- [ ] Color blind friendly palette

---

## Non-Functional Requirements (NFR)

### NFR-THM-001: Performance
- [ ] Theme switch ≤100ms
- [ ] No flicker saat theme change
- [ ] No frame drop saat transition

### NFR-THM-002: Consistency
- [ ] 100% UI components mendukung dark mode
- [ ] Warna konsisten di seluruh app
- [ ] No hardcoded colors

### NFR-THM-003: User Experience
- [ ] Instant visual feedback saat theme change
- [ ] Tema persisten across sessions
- [ ] Intuitive theme selection

### NFR-THM-004: Maintainability
- [ ] Theme colors terpusat di satu file
- [ ] Easy to add new theme variants
- [ ] No duplicate color definitions

---

## Verifikasi Checklist

**Total Requirements**: 6 (REQ-THM-001 hingga REQ-THM-006)
**Total NFR**: 4 (NFR-THM-001 hingga NFR-THM-004)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-THM-001 | Theme System Architecture | ⏳ | Code review | - |
| REQ-THM-002 | Color Scheme Definitions | ⏳ | Design review | - |
| REQ-THM-003 | Component Adaptations | ⏳ | Manual testing | - |
| REQ-THM-004 | Theme Settings UI | ⏳ | Manual testing | - |
| REQ-THM-005 | System Theme Following | ⏳ | Manual testing | - |
| REQ-THM-006 | Accessibility | ⏳ | Accessibility test | - |
| NFR-THM-001 | Performance | ⏳ | Performance test | - |
| NFR-THM-002 | Consistency | ⏳ | Code review | - |
| NFR-THM-003 | User Experience | ⏳ | Usability test | - |
| NFR-THM-004 | Maintainability | ⏳ | Code review | - |

### Ringkasan Implementasi

- **Total Requirements**: 6
- **Fully Implemented (✅)**: 0 (0%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (⏳)**: 6 (100%)

### File Implementasi yang Direncanakan

- **Theme Provider**: `lib/presentation/providers/theme/theme_provider.dart`
- **App Theme**: `lib/presentation/theme/app_theme.dart`
- **Color Scheme**: `lib/presentation/theme/app_colors.dart`
- **Theme Extensions**: `lib/presentation/theme/theme_extensions.dart`
- **Settings Update**: `lib/presentation/screens/settings_screen.dart`

### Implementation Approach

1. **Create ThemeProvider** dengan Riverpod
2. **Define AppTheme** class dengan light/dark themes
3. **Update AppColors** untuk support dark mode
4. **Refactor existing components** untuk theme-aware
5. **Add theme settings** di SettingsScreen
6. **Test all screens** di dark mode

### Color Tokens

```dart
// Light Theme
class LightColors {
  static const primary = Color(0xFF4CAF50);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

// Dark Theme
class DarkColors {
  static const primary = Color(0xFF81C784);
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
}
```

---

**Status**: 📝 Draft - Ready for Implementation
**Created**: 8 April 2026
