## **Aplikasi Catatan Tanaman**

Aplikasi ini menerapkan fitur berikut:

1. **Firebase Authentication**
    - Digunakan untuk autentikasi pengguna, termasuk **register** dan **login**.
    - Jika pengguna sudah login atau logout, mereka diarahkan ke halaman **Home**.

2. **State Management Provider**
    - Mengelola status autentikasi pengguna (logged in atau logged out).
    - Memastikan data dan status di aplikasi tetap konsisten.

3. **Firebase Realtime Database**
    - Digunakan untuk menyimpan dan mengambil data tanaman dalam bentuk **object**.
    - Data yang disimpan mencakup informasi seperti:
        - Nama Tanaman
        - Jenis Tanaman
        - Tanggal Penanaman
        - Kebutuhan Cahaya
        - Catatan Khusus
        - URL Gambar
        - Informasi `createdBy` berdasarkan username pengguna.

4. **Menampilkan Tampilan List**
    - Data tanaman dari Firebase ditampilkan dalam bentuk **ListView**.
    - Fitur tambahan:
        - **Search**: Filter daftar tanaman berdasarkan nama.
        - **Favorite**: Menandai tanaman sebagai favorit atau menghapus status favorit.

---

**Teknologi yang Digunakan**:

- **Flutter**: Framework untuk pembuatan UI.
- **Firebase**: Authentication & Realtime Database.
- **Supabase**: Storage.
- **Provider**: State Management.

---

