# Template Laporan Bug Bounty — STANDAR USER (diadopsi 2026-11-19)

Ini template baku untuk SEMUA laporan bug bounty (XE Network, Immunefi, HackerOne,
Bugcrowd, program mana pun). Ikuti urutan bagiannya persis. Panduan penulisan rinci
ada di SKILL.md bb-report; template ini yang menentukan struktur.

## Gerbang sebelum menulis (WAJIB, berurutan)

1. **Cek scope** — aset & kelas bug harus di dalam scope program. Di luar scope = berhenti.
2. **Cek duplikat** — cari laporan existing (desk publik, disclosed reports, issue tracker)
   untuk root cause yang sama. Duplikat = berhenti, atau catat sebagai kandidat kontestasi
   hanya bila buktinya benar-benar beda.
3. **Satu laporan = satu bug** — satu root cause per laporan. Temuan kedua = laporan terpisah.
4. **JANGAN SUBMIT** sebelum OK eksplisit dari user di chat. Simpan sebagai draft.

## Struktur laporan

### 1. Judul spesifik
Format: `<Bug> di <lokasi/komponen> menyebabkan <dampak>`
Judul harus memuat bug + lokasi + dampak dalam satu baris. Bukan "Bug kritis" atau
"Masalah keamanan". Contoh pola: "lease_renew double-credit di consensus handler
memungkinkan saldo digandakan tanpa pembayaran kedua".

### 2. Ringkasan
2–4 kalimat non-teknis: apa bug-nya, di mana, kenapa penting. Triager harus paham
tanpa membaca sisanya.

### 3. Severity
Severity jujur sesuai CVSS (jangan dinaikkan — kredibilitas adalah taruhannya):
skor + vektor CVSS, tier program yang diklaim, dan satu kalimat justifikasi.

### 4. Langkah Reproduksi
Langkah bernomor, bisa diikuti orang asing dari nol sampai bug terjadi:
prasyarat/akun → perintah persis (curl/kode) → hasil yang teramati di tiap langkah.
Sertakan request/response persis, bukan parafrase.

### 5. PoC
Bukti yang jalan: script/transaksi/log/output. PoC dibuktikan TANPA merusak —
berhenti begitu bukti cukup; jangan eksploitasi lebih jauh dari yang perlu
untuk membuktikan dampak.

### 6. Dampak
Konsekuensi bisnis/teknis konkret: apa yang bisa dilakukan penyerang, skala
(berapa user/dana/data), prasyarat serangan. Bukan sekadar "data terekspos".

### 7. Rekomendasi
Perbaikan konkret dan bisa ditindaklanjuti: cek/validasi apa, di komponen mana,
pola aman yang disarankan.

### 8. Lingkungan
Target & versi/commit, chain/network, akun/peran yang dipakai, tool & versi,
tanggal pengujian, alamat/ID pengujian yang relevan.

## Aturan tetap
- Bukti diredaksi seperlunya (kredensial pihak lain tidak pernah masuk laporan).
- Jawab pertanyaan triage cepat dan sopan; satu klarifikasi per balasan.
- Draft disimpan dulu; submit hanya setelah user bilang OK untuk laporan itu.
