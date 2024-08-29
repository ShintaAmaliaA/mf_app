import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String _email = "Sedang memuat...";
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _email = _user!.email ?? "Email tidak ditemukan";
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Color.fromARGB(
            255, 218, 207, 203), // Menggunakan warna pilihan Anda
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8),
              const CircleAvatar(
                backgroundColor: Color.fromARGB(
                    255, 218, 207, 203), // Warna background yang diinginkan
                backgroundImage: AssetImage('assets/img/logo.png'),
                radius: 25,
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(height: 8),
                        Text(
                          _email,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.logout,
                    color: Colors.black), // Warna ikon logout
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.black), // Warna teks logout
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF997950), // Warna background tombol
                ),
              ),
              SizedBox(height: 30),
              ListTile(
                leading: Icon(Icons.info, color: Color(0xFF997950)),
                title: Text('Tentang Aplikasi'),
                onTap: () {
                  // Navigasi ke halaman Tentang Aplikasi atau tampilkan informasi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Tentang Aplikasi'),
                      content: Text(
                          'Aplikasi ini dirancang untuk membantu mengelola dana masjid dengan transparansi dan efisiensi. Aplikasi ini memungkinkan pengurus masjid untuk melacak pemasukan dan pengeluaran, memastikan transparansi keuangan, dan pengelolaan sumber daya masjid yang tepat.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.policy, color: Color(0xFF997950)),
                title: Text('Kebijakan dan Layanan Aplikasi'),
                onTap: () {
                  // Navigasi ke halaman Kebijakan dan Layanan Aplikasi atau tampilkan informasi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Kebijakan dan Layanan Aplikasi'),
                      content: Text(
                          'Aplikasi ini mematuhi kebijakan privasi yang ketat untuk melindungi data pengguna. Semua catatan keuangan disimpan dengan aman dan hanya dapat diakses oleh personel yang berwenang. Aplikasi ini menyediakan layanan seperti pelacakan transaksi secara real-time, manajemen anggaran, dan pelaporan keuangan. Pembaruan rutin disediakan untuk meningkatkan fungsionalitas dan keamanan.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: Color(0xFF997950)),
                title: Text('Versi Aplikasi 1.0.0'),
                onTap: () {
                  // Tampilkan dialog atau toast dengan informasi versi aplikasi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Versi Aplikasi'),
                      content: Text(
                          'Anda saat ini menggunakan versi 1.0.0 dari aplikasi ini.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
