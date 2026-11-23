---
name: cloud-compute
description: Use GitHub Codespaces (primary) or Google Colab as extra cloud compute when the agent's own VM is too small for a heavy job (self-play testing, rendering, batch jobs). Proven browser-only workflow: private repo → codespace created FROM the repo → nohup background jobs → report results.
---

# Cloud Compute — Codespaces / Colab sebagai VM tambahan

VM bawaan agent kecil (1,5 shared CPU / 6 GB RAM) dan **tidak bisa di-upgrade** — tidak ada setting/paket yang mengubahnya. Untuk kerjaan berat, pindahkan beban ke komputer cloud lewat browser. Jalur yang TERBUKTI jalan (2026-11-24, pertandingan self-play catur 100 game): **GitHub Codespaces free tier** — 2-core, 8 GB RAM, 32 GB disk, tanpa kartu, siap ±1 menit, kuota gratis ±120 core-jam/bulan.

## Kapan pakai

- Job CPU/RAM-berat yang di VM sendiri lambat atau tidak muat: self-play/testing engine, render batch, kompilasi besar, simulasi panjang.
- BUKAN untuk mengganti VM utama — codespace hanya buruh tambahan untuk satu job.

## Alur Codespaces (ikuti persis — urutan penting)

1. **Login GitHub** lewat browser pakai login tersimpan (Secure Vault) bila ada.
2. **File harus masuk repo dulu.** Upload langsung ke VS Code web TIDAK jalan (File System Access API — file dilaporkan "attached" tapi tidak pernah sampai ke workspace). Buat repo **PRIVATE** baru lewat halaman web GitHub dan upload file lewat web (Add file → Upload files).
3. **Buat codespace BARU langsung DARI repo itu** (halaman repo → Code → Codespaces → Create). File otomatis ter-clone. JANGAN clone repo lain dari codespace template kosong: token bawaan codespace hanya berhak atas repo asalnya (clone repo lain = 403).
4. **Idle timeout**: Settings GitHub → Codespaces → set default idle timeout ke maksimum **240 menit**. Catatan: setting ini berlaku sebagai default codespace baru; codespace yang sudah jalan mengikuti nilai saat dibuat — jadi set SEBELUM membuat codespace untuk job panjang.
5. **Verifikasi** di terminal codespace: `ls -la` (semua file ada, ukuran masuk akal) + compile-check sesuai bahasa (mis. `python3 -m py_compile *.py && echo COMPILE_OK`).
6. **Jalankan job di background**: `nohup <perintah> > <log>.log 2>&1 &` supaya tetap jalan saat tab ditutup. Pantau berkala lewat log/file hasil; laporkan progres nyata (berapa selesai, skor/status), bukan janji.
7. **Selesai**: ambil hasil akhirnya, laporkan, lalu **hapus codespace yang tidak dipakai** (hemat kuota) dan codespace lama yang tergantikan. Repo privat sementara: sepakati penghapusannya dengan user setelah pekerjaan benar-benar selesai — jangan hapus sepihak di tengah jalan.

## Alternatif: Google Colab

- Notebook di Drive user, runtime T4 GPU gratis — cocok untuk training/inferensi GPU (mis. NNUE).
- Kelemahan terbukti (2026-11-23): alokasi GPU free tier bisa macet lama ("Mengalokasikan runtime" ±9 menit tanpa hasil) saat kapasitas penuh; coba lagi di jam sepi (pagi). CPU fallback tetap lebih besar dari VM agent.
- Login Google bisa memakai login tersimpan di Secure Vault.

## Aturan keras

- Repo untuk pekerjaan user selalu **PRIVATE**. Jangan pernah publikasikan repo kerja tanpa perintah eksplisit user.
- **Jangan pernah** menaruh private key, seed phrase, password, atau API key di repo/codespace/notebook.
- Jangan libatkan user untuk hal yang bisa diselesaikan sendiri (mis. kode device-flow `gh auth` yang macet — tinggalkan kedaluwarsa, pakai jalur codespace-dari-repo).
- Laporkan spesifikasi apa adanya dari bukti (label mesin, `nproc`, RAM terlihat), jangan mengarang angka.
