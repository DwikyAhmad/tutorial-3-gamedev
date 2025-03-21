# Dwiky Ahmad Megananta - 2206829206

### Implementasi Tutorial 5

Untuk mengerjakan tutorial 5 ini, saya untuk tutorialnya saya mengganti node sprite menjadi yang animated lalu menambahkan masing-masing animasi menggunakan spritesheet dari karakter yang digunakan pada tutorial 3 sebelumnya dan memberikan script play berdasarkan statenya, lalu pada tugas mandiri tutorial 5 ini, saya membuat objek baru menggunakan assets yang berbeda (https://aamatniekss.itch.io/fantasy-knight-free-pixelart-animated-character), lalu saya gunakan juga Audio pada scene node char tersebut untuk SFX dan BGM, lalu untuk interaksi dengan objek lainnya saya membuat sebuah objek dummy baru rigidbody yang akan menerima pergeseran apabila dia di dalam area main char dan main char tersebut sedang menyerang, untuk masuk ke area penyerangan dan bisa dideteksi saya menggunakan area2D, jika area2D mendeteksi dummy character dan kita memencet spasi, maka dummy character tersebut akan bergeser dan menjalankan sfx.

Referensi Implementasi Crouch dan Change Sprite: https://youtu.be/Hpbn-w7H2V4?si=ozGmLMAE5B97WlRR

## Latihan Mandiri: Eksplorasi Mekanika Pergerakan

### 1. Double Jump

Untuk menerapkan double jump kita perlu menyimpan 1 variable sebagai state yaitu can_double_jump, ketika user menekan up dan player sedang di floor, maka can_double_jump akan di set true dan velocity di set dengan jump_speed, ketika sedang tidak di floor dan can_double_jump true, maka user saat menekan tombol up lagi player akan di set velocity dengan double jump speed yang lebih besar dari jump_speed, can_double_jump akan di set false dan bisa true kembali ketika player menyentuh floor.

### 2. Dashing

Untuk melakukan implementasi dash diperlukan 5 variable yaitu is_dashing, dash_timer, last_press_time, double_tap_threshold, dan last_press_direction, ketika double tap dan belum dash maka akan dicek direction jalan player dan apabila durasi antar double tap masih dibawah threshold akan dibuat is_dashing menjadi true dan dibuat timer dash sehingga player memiliki velocity x yang lebih cepat untuk periode waktu yang singkat.

### 3. Crouching

Untuk melakukan implementasi crouching diperlukan resource 2 CollisionShape yang berbeda, untuk standing dan crouching, by default player akan menggunakan standing CollisionShape, dan ketika variable is_crouching di set true ketika ditekan down, maka CollisionShape akan diubah menjadi resource untuk ukuran crouch yang positionnya diatur sedemikian rupa dan spritenya di scale mengecil ke bawah, lalu ketika down di release, state default akan dikembalikan seperti semula.

### 4. Polishing tampilan sprite karakter

Untuk menambahkan polishing sprite karakter, maka akan diload untuk masing-masing assets ketika berjalan, melompat, dash, dan idle. Ketika salah satu state selain idle true maka sprite texture player akan diganti menjadi sprite sesuai masing-masing yang ada di assets, assets akan di flip ketika walk berdasarkan last_press_direction, ketika character diam sprite texture akan diubah menjadi idle.