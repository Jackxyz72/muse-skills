# Xingchi — Pendamping AI (Companion) buat Muse / Codex

Paket ini yang dipakai @Jackxyz72 buat memasang **Xingchi** sebagai "otak kedua" (pendamping / second opinion) di sebelah agent utama: agent utama tetap yang memutuskan dan mengeksekusi, Xingchi dipanggil untuk pendapat kedua soal coding dan saat agent utama buntu.

Xingchi (xingchiapi.com) adalah **relay API gratis dari komunitas linux.do** yang menyediakan akses OpenAI-compatible ke model-model GPT (`gpt-6.1-sol`, `gpt-6-astra`, tergantung grup key kamu).

---

## Mulai dari sini — daftar + klaim kredit gratis

API key dibuat di web Xingchi, tapi saldonya diklaim lewat bot Telegram. Urutannya:

1. **Buka bot lewat link undangan ini:** https://t.me/xingchi66bot?start=inv_6805282234 — pencet **Start**, lalu tombol pertama / `/invite` buat menerima **kode redeem** (promo kredit gratis, s.d. $1.000).
2. **Daftar akun** di https://xingchiapi.com/register — cukup email + password, tanpa kartu / nomor HP.
3. **Redeem kodenya** di dashboard web (menu Redeem) — saldo masuk ke akun kamu.
4. **Buat API key** di dashboard (menu API Keys → Create API Key) dan simpan — key inilah yang dipasang ke connector / Codex di langkah instal bawah.

---

## Yang dibutuhkan buat instal

| # | Kebutuhan | Keterangan |
|---|---|---|
| 1 | **Akun Xingchi + API key sendiri** | Ikuti langkah "Mulai dari sini" di atas: klaim kode redeem lewat bot undangan, daftar di xingchiapi.com, redeem, lalu buat API key di dashboard. **Key TIDAK disediakan di repo ini** — tiap orang wajib pakai key-nya sendiri. Grup key menentukan model yang bisa dijangkau. |
| 2 | **Python 3** | Buat jalanin helper `bin/xingchi.py` / `bin/xingchi_standalone.py`. Tanpa library tambahan (cuma stdlib). |
| 3a | **Muse** (jalur connector) | Buat jalur resmi di repo ini: Muse dengan dukungan custom connector + Secure Vault, supaya key tersimpan aman dan tidak pernah tertulis di file/chat. |
| 3b | **ATAU Codex CLI** (jalur pendamping coding) | Jalur yang terbukti jalan buat second opinion coding. Butuh Node.js / Codex CLI terpasang (`codex` di PATH). |
| 4 | **Koneksi internet ke `api.xingchiapi.com`** | Cuma host itu yang diakses paket ini. |

Tidak butuh: kartu kredit, server sendiri, database, atau token bot apa pun.

---

## Cara instal — Jalur A: Connector Muse (buat tanya-jawab / chat)

1. Salin folder ini ke tempat connector Muse kamu:
   ```bash
   mkdir -p ~/workspace/custom-connectors
   cp -r custom.xingchi ~/workspace/custom-connectors/
   ```
2. Daftarkan key kamu lewat alur API access Muse (Secure Vault) dengan detail ini — jangan pernah tempel key di chat atau tulis di file:
   ```json
   { "provider": "xingchi", "auth_scheme": "api_key", "placement": "bearer_header", "api_hosts": ["api.xingchiapi.com"] }
   ```
3. Tes koneksi (read-only, tidak memotong kredit):
   ```bash
   python3 ~/workspace/custom-connectors/custom.xingchi/bin/xingchi.py models
   ```
   Berhasil = keluar daftar model, mis. `gpt-6-astra`, `gpt-6.1-sol`.
4. Chat:
   ```bash
   python3 ~/workspace/custom-connectors/custom.xingchi/bin/xingchi.py chat gpt-6.1-sol "halo, kamu siapa?"
   ```

Di luar Muse, pakai `bin/xingchi_standalone.py` — key dibaca dari env `XINGCHI_API_KEY`.

## Cara instal — Jalur B: Codex CLI (pendamping coding, jalur terbukti)

Panggilan script langsung kadang ditolak relay (`403 client_not_allowed` — relay hanya menerima client pemrograman bernama). Jalur yang stabil adalah lewat Codex CLI:

1. Pasang Codex CLI sampai perintah `codex` jalan.
2. Salin `codex/config.example.toml` ke `~/.codex/config.toml` (isinya: provider `xingchi`, base_url `https://api.xingchiapi.com/v1`, `wire_api = "responses"`, model `gpt-6.1-sol`). Key **tidak** ditulis di config — config cuma menyebut nama env var `XINGCHI_KEY`.
3. Jalanin sekali-tembak, key diteruskan lewat env saat launch saja, dan stdin **wajib** dari `/dev/null` (kalau tidak, Codex menunggu stdin selamanya):
   ```bash
   XINGCHI_KEY="key-kamu" codex exec --skip-git-repo-check "tulis fungsi ..." < /dev/null
   ```

---

## Isi paket

- `CONNECTOR.md` — dokumen connector Muse (aturan pakai, limit, error handling)
- `connector.yaml` — deskriptor connector
- `bin/xingchi.py` — helper versi Muse (key disuntik lewat koneksi aman Muse)
- `bin/xingchi_standalone.py` — helper versi umum (key dari env `XINGCHI_API_KEY`)
- `codex/config.example.toml` — contoh config Codex CLI buat provider Xingchi

## Peringatan (baca sebelum pakai)

- **Jangan pernah kirim data sensitif** ke relay ini: kredensial, data wallet, data pribadi, isi akun. Semua prompt melewati server pihak ketiga, dan rute GPT-nya kebanyakan reverse-proxy web — bukan API resmi.
- **Prompt membengkak**: relay membungkus request dengan prompt sesi tersembunyi (±4.000 token per panggilan), jadi kredit terkuras lebih cepat dari perkiraan.
- **Layanan bisa mati / rate-limit kapan saja** — anggap sekali pakai, jangan top-up, jangan jadikan satu-satunya andalan.
- Perlakukan outputnya sebagai **pendapat kedua**, bukan kebenaran: agent utama tetap yang menilai dan mengeksekusi.
