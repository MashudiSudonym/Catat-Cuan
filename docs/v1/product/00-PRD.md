# PRD – Aplikasi Pencatatan Pemasukan & Pengeluaran Pribadi

## 0. The WHY – Alasan Bisnis/Pribadi

Aku ingin punya **kendali** yang lebih sadar atas keuangan pribadiku, bukan sekadar tahu saldo akhir. Saat ini uang sering terasa “bocor” tanpa jelas ke mana, dan sulit mengingat pola pengeluaran per bulan.

Dengan aplikasi ini, dalam 1 bulan pertama penggunaan aku ingin:
- Mencatat sebanyak mungkin transaksi (pada prinsipnya unlimited).
- Mengetahui rata-rata pengeluaran per kategori dan kategori apa yang paling tinggi.
- Mendapat saran praktis untuk:
  - Menghemat pengeluaran (terutama di kategori boros).
  - Mengoptimalkan keseimbangan pemasukan vs pengeluaran.

v1 secara eksplisit hanya fokus ke keuangan pribadi, bukan keuangan bisnis.

---

## 1. Target Pengguna (The WHO)

### 1.1 Persona Utama

**Persona: “Developer dengan income campuran”**

- Latar belakang:
  - Software developer (mobile / fullstack).
  - Punya sumber pemasukan campuran: gaji, freelance, mungkin side-business.
- Perilaku keuangan:
  - Sering melakukan transaksi campur: cash, e-wallet, kartu, transfer.
  - Ingin mencatat sebanyak-banyaknya transaksi (tidak ingin ada batasan jumlah).
  - Sering menerima struk dalam dua bentuk:
    - Struk fisik kertas.
    - Screenshot / bukti transfer / invoice digital sederhana.
- Masalah utama:
  - Susah mengingat ke mana uang banyak terpakai setiap bulan.
  - Mencatat manual terasa ribet, apalagi dari struk.
  - Sulit mendapat insight: “Aku boros di mana?” dan “Apa yang bisa dikurangi?”

### 1.2 Use Case Utama

- Mencatat pengeluaran sehari-hari (makan, transport, langganan, dll) tanpa batas jumlah.
- Mencatat semua pemasukan (gaji, freelance, dll).
- Memfoto struk kertas atau memilih screenshot, lalu otomatis mengisi nominal total.
- Melihat ringkasan tiap bulan:
  - Total pemasukan, total pengeluaran, saldo.
  - Kategori pengeluaran terbesar dan rata-rata pengeluaran per kategori.
- Mendapat rekomendasi sederhana:
  - “Kategori X terlalu besar dibanding pemasukan.”
  - “Jika kamu mengurangi Y% di kategori Z, efeknya ke saldo per bulan sekian.”

---

## 2. Tujuan & Keberhasilan (The WHY → terukur)

### 2.1 Tujuan v1 (1 bulan pertama)

- Aku bisa:
  - Mencatat mayoritas transaksi pribadi harianku (target: minimal 80% transaksi tercatat).
  - Melihat dengan jelas kategori apa yang paling banyak menghabiskan uang per bulan.
  - Mendapat rekomendasi sederhana untuk menghemat atau menyeimbangkan cashflow.

### 2.2 Metrics (untuk evaluasi diri)

- Coverage transaksi:
  - ≥ 80% transaksi pribadiku tercatat dalam app (estimasi self-report).
- Engagement:
  - Minimal 20 hari dalam 1 bulan aku membuka app untuk mencatat/mengecek.
- Insight:
  - Aku bisa menjawab: “Kategori pengeluaran terbesar bulan ini apa dan berapa rata-ratanya?” hanya dengan melihat satu layar ringkasan.
- Rekomendasi:
  - App memberi minimal 1–3 rekomendasi penghematan yang terasa masuk akal (tidak terlalu generik).

---

## 3. Lingkup Produk v1 (The WHAT – non-teknis)

### 3.1 In Scope v1

Dari sudut pandang pengguna, v1 harus memungkinkan:

1. **Pencatatan transaksi tanpa batas jumlah**  
   Aku bisa menambah transaksi pemasukan dan pengeluaran sesering apapun tanpa limit tampak.

2. **Input manual yang cepat**  
   Bisa tambah pengeluaran/pemasukan dengan beberapa field inti:
   - Nominal.
   - Tipe (pemasukan / pengeluaran).
   - Tanggal & waktu.
   - Kategori.
   - Catatan (opsional).

3. **Input via struk (foto & screenshot)**  
   - Aku bisa:
     - Foto struk kertas.
     - Pilih gambar/screenshot dari galeri.
   - App mencoba membaca struk dan mengisi otomatis nilai total pengeluaran (aku masih bisa mengedit).

4. **Ringkasan bulanan**  
   Menampilkan:
   - Total pemasukan.
   - Total pengeluaran.
   - Saldo (pemasukan – pengeluaran).
   - Kategori pengeluaran terbesar (misalnya top 3) dan rata-rata pengeluaran per kategori.

5. **Insight & saran sederhana**  
   App menampilkan insight dasar seperti:
   - “Kategori X menyumbang Y% dari total pengeluaranmu bulan ini.”
   - “Jika pengeluaran di kategori X dikurangi sekian, saldo bulananmu akan naik sekitar sekian.”  
   Saran difokuskan ke *penghematan praktis* dan *awareness*, bukan financial planning kompleks.

6. **List transaksi & edit**  
   - Aku bisa melihat daftar transaksi per hari/per kategori.
   - Aku bisa mengedit atau menghapus transaksi jika salah input.

### 3.2 Out of Scope v1 (sengaja ditunda)

- Keuangan bisnis (rekening usaha, laporan keuangan bisnis, dsb).
- Multi user atau sharing akun.
- Multi device sync / cloud backup.
- Integrasi otomatis dengan bank, e-wallet, atau kartu kredit.
- Fitur budgeting lengkap (set budget per kategori + alert).
- Ekspor ke Excel/CSV.
- Fitur laporan pajak.
- Multi currency.

---

## 4. User Story Tingkat Produk

1. Sebagai pengguna, aku ingin mencatat pengeluaran dan pemasukan setiap kali ada transaksi, agar aku tidak bergantung pada ingatan.
2. Sebagai pengguna, aku ingin mencatat transaksi sebanyak apapun tanpa batasan, agar histori keuangan pribadiku utuh.
3. Sebagai pengguna, aku ingin memfoto struk kertas atau memilih screenshot, lalu aplikasi mengisi otomatis nilai total pengeluaran, agar input terasa jauh lebih cepat.
4. Sebagai pengguna, aku ingin melihat kategori pengeluaran terbesar dan rata-rata pengeluaran per kategori tiap bulan, agar aku tahu di mana aku paling boros.
5. Sebagai pengguna, aku ingin mendapatkan saran praktis berdasarkan dataku (bukan tips generik), agar aku punya ide konkret untuk menghemat atau menyeimbangkan pemasukan vs pengeluaran.
6. Sebagai pengguna, aku ingin bisa mengedit dan menghapus transaksi yang salah, agar dataku tetap akurat.

---

## 5. Pengalaman Pengguna yang Diinginkan (UX)

- Aplikasi harus terasa:
  - Ringan, cepat, dan tidak “menghakimi”.
  - Minimalis: 2–3 layar utama yang sering dipakai.
- Input transaksi ideal:
  - Manual: selesai dalam ≤ 20 detik.
  - Via struk: dari buka kamera/pilih screenshot sampai nominal terisi ≤ 30 detik (termasuk waktu berpikirku).
- Fokus UX:
  - Meminimalkan friction input (sedikit tap, default value yang smart).
  - Memaksimalkan kejelasan insight (ringkasan dan saran yang mudah dimengerti dalam sekali lihat).

---

## 6. Risiko & Asumsi

### Asumsi

- Aku cukup termotivasi untuk:
  - Buka app hampir tiap hari.
  - Memfoto struk atau menyimpan screenshot saat transaksi penting.
- Struk (fisik dan screenshot) umumnya:
  - Mengandung teks angka yang dapat dibaca OCR.
  - Memiliki satu atau beberapa baris yang jelas menunjukkan “Total”.

### Risiko

- Jika input (terutama via struk) terasa lambat atau sering salah, aku bisa berhenti menggunakan app.
- Insight dan saran yang terlalu generik atau “ceramah” bisa membuatku tidak tertarik membaca, sehingga fitur rekomendasi tidak dipakai.
- Jika scope diam-diam melebar ke hal-hal seperti bisnis, pajak, atau budgeting canggih terlalu cepat, v1 bisa tidak pernah selesai.

---

## 7. Catatan Teknis High-Level

Bagian ini hanya untuk menjaga alignment dengan tujuan, detail implementasi akan ada di dokumen teknis terpisah.

- Platform awal:
  - Mobile, fokus Android.
- Framework:
  - Flutter (menyesuaikan skill pengembang).
- OCR:
  - Menggunakan Google ML Kit – Text Recognition v2, mode on-device, untuk membaca teks di struk (fisik dan screenshot).
- Penyimpanan data:
  - Disimpan lokal di device (misalnya SQLite / local DB lain yang cocok dengan Flutter).
- Insight & saran:
  - Berdasarkan agregasi data transaksi per kategori dan per bulan, dengan logika sederhana di sisi app.
