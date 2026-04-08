# SPEC v2 – Google Drive Backup & Restore

## Daftar Persyaratan Teknis (REQ-BKP)

### REQ-BKP-001: Autentikasi Google Account
Sistem menyediakan mekanisme autentikasi ke Google Account untuk akses Google Drive.

#### AC-BKP-001.1: OAuth 2.0 Flow
- [ ] Sistem menggunakan Google Sign-In untuk autentikasi
- [ ] Scope yang diminta: `drive.appdata` (app-specific folder only)
- [ ] Tidak meminta akses ke file pribadi pengguna
- [ ] Token disimpan securely menggunakan `flutter_secure_storage`

#### AC-BKP-001.2: First-time Authentication
- [ ] Saat pertama kali menggunakan fitur backup, tampilkan OAuth consent screen
- [ ] Jelaskan data apa saja yang akan diakses (app data only)
- [ ] User dapat membatalkan proses autentikasi

#### AC-BKP-001.3: Re-authentication
- [ ] Jika token expired, sistem otomatis refresh token
- [ ] Jika refresh gagal, user diminta login ulang
- [ ] Session tetap valid selama user tidak revoke access

---

### REQ-BKP-002: Backup Data ke Google Drive
Sistem menyediakan fungsi untuk membackup semua data lokal ke Google Drive.

#### AC-BKP-002.1: Data yang Di-backup
- [ ] Semua transaksi (tabel transactions)
- [ ] Semua kategori (tabel categories)
- [ ] Settings aplikasi (theme, currency, dll)
- [ ] Metadata backup (timestamp, device info, version)

#### AC-BKP-002.2: Format Backup
- [ ] Data disimpan dalam format JSON atau SQLite file
- [ ] Nama file: `catat_cuan_backup_YYYYMMDD_HHMMSS.json`
- [ ] File disimpan di folder app-specific (`drive.appdata`)

#### AC-BKP-002.3: Proses Backup
- [ ] Tombol "Backup ke Google Drive" di Settings screen
- [ ] Progress indicator selama proses backup
- [ ] Estimasi waktu/waktu tersisa ditampilkan
- [ ] User dapat membatalkan proses backup yang sedang berjalan

#### AC-BKP-002.4: Backup Success
- [ ] Tampilkan pesan sukses dengan timestamp backup
- [ ] Update "Last backup" info di Settings
- [ ] Tampilkan ukuran file backup

#### AC-BKP-002.5: Backup Error Handling
- [ ] Handle network error dengan pesan jelas
- [ ] Handle quota exceeded dengan pesan informatif
- [ ] Handle authentication error dengan opsi re-login
- [ ] Log error untuk debugging (tidak ditampilkan ke user)

---

### REQ-BKP-003: Restore Data dari Google Drive
Sistem menyediakan fungsi untuk restore data dari backup Google Drive.

#### AC-BKP-003.1: List Available Backups
- [ ] Tampilkan daftar backup yang tersedia di Google Drive
- [ ] Setiap item menampilkan: tanggal backup, ukuran file, device asal
- [ ] Backup diurutkan dari terbaru ke terlama

#### AC-BKP-003.2: Preview sebelum Restore
- [ ] Sebelum restore, tampilkan preview data:
  - Jumlah transaksi
  - Rentang tanggal transaksi
  - Jumlah kategori
- [ ] Tampilkan warning bahwa data lokal akan diganti

#### AC-BKP-003.3: Conflict Handling
- [ ] Jika ada data lokal, tampilkan opsi:
  - Replace all (semua data lokal diganti)
  - Cancel (batalkan restore)
- [ ] Tampilkan jumlah data lokal yang akan dihapus

#### AC-BKP-003.4: Proses Restore
- [ ] Progress indicator selama proses restore
- [ ] Validasi integritas data setelah restore
- [ ] Restart aplikasi setelah restore berhasil (opsional)

#### AC-BKP-003.5: Restore Error Handling
- [ ] Handle corrupted backup file
- [ ] Handle incompatible version (backup dari versi lebih baru)
- [ ] Handle network error
- [ ] Jika restore gagal, data lokal tetap utuh

---

### REQ-BKP-004: Manajemen Backup
Sistem menyediakan fitur manajemen backup.

#### AC-BKP-004.1: Backup Info di Settings
- [ ] Tampilkan "Last backup: [date/time]"
- [ ] Tampilkan "Backup size: [size]"
- [ ] Tampilkan "Google account: [email]"

#### AC-BKP-004.2: Delete Old Backups
- [ ] Opsi untuk menghapus backup lama dari Google Drive
- [ ] Konfirmasi sebelum menghapus
- [ ] Maksimal menyimpan 5 backup terakhir (auto-cleanup)

#### AC-BKP-004.3: Auto-backup Reminder (Optional)
- [ ] Notifikasi jika tidak ada backup dalam 7 hari
- [ ] User dapat disable reminder di settings

---

## Non-Functional Requirements (NFR)

### NFR-BKP-001: Performa Backup
- [ ] Backup 1000 transaksi dalam ≤30 detik
- [ ] Progress update setiap 10% progress
- [ ] UI tetap responsif selama backup

### NFR-BKP-002: Performa Restore
- [ ] Restore 1000 transaksi dalam ≤60 detik
- [ ] Progress update setiap 10% progress
- [ ] Aplikasi dapat digunakan setelah restore selesai

### NFR-BKP-003: Keamanan
- [ ] Token OAuth disimpan dengan enkripsi
- [ ] Data di Google Drive dienkripsi (optional untuk v2)
- [ ] Tidak ada sensitive data di logs

### NFR-BKP-004: Reliability
- [ ] Backup success rate ≥95%
- [ ] Restore success rate ≥95%
- [ ] Data integrity setelah restore = 100%

### NFR-BKP-005: User Experience
- [ ] Satu tap untuk backup
- [ ] Max 3 tap untuk restore (select → preview → confirm)
- [ ] Error messages dalam Bahasa Indonesia

---

## Verifikasi Checklist

**Total Requirements**: 4 (REQ-BKP-001 hingga REQ-BKP-004)
**Total NFR**: 5 (NFR-BKP-001 hingga NFR-BKP-005)

### Status Implementasi

| ID | Deskripsi | Status | Metode Verifikasi | Terakhir Diverifikasi |
|----|-----------|--------|-------------------|---------------------|
| REQ-BKP-001 | Autentikasi Google Account | ⏳ | Manual testing | - |
| REQ-BKP-002 | Backup Data ke Google Drive | ⏳ | Integration test | - |
| REQ-BKP-003 | Restore Data dari Google Drive | ⏳ | Integration test | - |
| REQ-BKP-004 | Manajemen Backup | ⏳ | Manual testing | - |
| NFR-BKP-001 | Performa Backup | ⏳ | Performance test | - |
| NFR-BKP-002 | Performa Restore | ⏳ | Performance test | - |
| NFR-BKP-003 | Keamanan | ⏳ | Security review | - |
| NFR-BKP-004 | Reliability | ⏳ | Stress test | - |
| NFR-BKP-005 | User Experience | ⏳ | Usability test | - |

### Ringkasan Implementasi

- **Total Requirements**: 4
- **Fully Implemented (✅)**: 0 (0%)
- **Partially Implemented (⚠️)**: 0 (0%)
- **Not Implemented (⏳)**: 4 (100%)

### File Implementasi yang Direncanakan

- **Repository Interface**: `lib/domain/repositories/backup/backup_repository.dart`
- **Repository Impl**: `lib/data/repositories/backup/backup_repository_impl.dart`
- **Service**: `lib/data/services/google_drive_service.dart`
- **Provider**: `lib/presentation/providers/backup/backup_provider.dart`
- **Screen**: `lib/presentation/screens/backup_screen.dart`

### Dependencies

| Package | Versi | Tujuan |
|---------|-------|--------|
| google_sign_in | ^6.2.1 | OAuth authentication |
| googleapis | ^13.0.0 | Google Drive API |
| extension_google_sign_in_as_googleapis_auth | ^2.0.12 | Auth adapter |
| flutter_secure_storage | ^9.0.0 | Secure token storage |
| path_provider | ^2.1.1 | Local file paths |

---

**Status**: 📝 Draft - Ready for Implementation
**Created**: 8 April 2026
