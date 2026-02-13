class ApiConfig {
  // Use 10.0.2.2 to point to your computer's localhost from the Android emulator.
  // Or use your local IP 10.41.1.43 if you prefer.
  static const String baseUrl = 'https://5171-103-95-7-6.ngrok-free.app/api';

  static const String deteksiJerawat = '$baseUrl/deteksi_jerawat';
  static const String deteksiKeriput = '$baseUrl/deteksi_keriput';
  static const String deteksiKemerahan = '$baseUrl/deteksi_kemerahan';
  static const String deteksiBintikHitam = '$baseUrl/deteksi_bintik_hitam';
}
