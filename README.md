# Muse Skills Collection — by @Jackxyz72

Koleksi **529 skill** untuk AI agent (Muse / agent yang kompatibel dengan format `SKILL.md`), dikumpulkan dan dipakai sehari-hari oleh @Jackxyz72 — untuk make.fun bounties, bug bounty, BSC / Binance Agentic Wallet mint & claim, game dev, chess, riset, dan banyak lagi.

Setiap skill ada di folder `skills/<nama-skill>/` dengan file utama `SKILL.md`.

👉 Daftar lengkap: [SKILLS_INDEX.md](SKILLS_INDEX.md)

## Connector pendamping

- **[Xingchi](connectors/custom.xingchi/)** — connector + panduan instal buat memasang Xingchi (relay API gratis komunitas linux.do, model `gpt-6.1-sol` / `gpt-6-astra`) sebagai pendamping / otak kedua Muse, termasuk jalur Codex CLI yang terbukti jalan. Syarat utamanya: akun Xingchi + API key sendiri (key tidak disediakan di repo ini).

## Cara pasang

### Pasang semua
```bash
git clone https://github.com/Jackxyz72/muse-skills.git
mkdir -p ~/workspace/custom-skills
cp -r muse-skills/skills/* ~/workspace/custom-skills/
```

### Pasang satu skill saja
```bash
git clone https://github.com/Jackxyz72/muse-skills.git
cp -r muse-skills/skills/<nama-skill> ~/workspace/custom-skills/
```
Contoh:
```bash
cp -r muse-skills/skills/mode-galak ~/workspace/custom-skills/
cp -r muse-skills/skills/bsc-contract-audit ~/workspace/custom-skills/
```

Setelah disalin, restart / mulai sesi baru di agent kamu supaya skill-nya terdeteksi.

## Catatan penting

- **File rahasia sengaja TIDAK di-upload**: file `.env` (mis. RPC endpoint fastmint) dibuang dari repo ini. Kalau sebuah skill butuh `.env` / API key, isi pakai endpoint dan key kamu sendiri.
- Koleksi ini adalah **kumpulan (library)** — sebagian skill ditulis sendiri / untuk workflow pemilik repo, sebagian lagi berasal dari repo open-source lain yang sudah publik (lisensi masing-masing skill tetap berlaku, file `LICENSE` di dalam folder skill dipertahankan apa adanya). Terima kasih untuk semua author aslinya.
- Skill yang berisi script (`.js`, `.py`, `.sh`) — **baca dulu script-nya sebelum menjalankan**, jangan langsung eksekusi buta.
- Tidak ada jaminan skill cocok untuk semua workflow; pakai atas risiko sendiri.

## Isi kategori besar

- **make.fun & kontes**: `makefun-playbook`, `mode-galak`, `makefun_image_contest`, `makefun_submission_quota`, `chess-engine`, skill game-dev & Three.js
- **Bug bounty & security**: `bug-bounty`, `bb-*`, `bounty-hunter`, `bsc-contract-audit`, `launch-curve-audit`, audit & fuzzing
- **BSC / Agentic Wallet**: `binance-agentic-wallet`, `bsc-free-mint-watch`, `fastmint-fcfs`, `fcfs_cron_arming`, `on-chain-safety-rails`, `airdrop-agent`
- **Umum**: riset, dokumen, desain, writing, dan lainnya — lihat indeks lengkap.
