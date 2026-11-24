import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latihan Firebase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData ? const ProfilePage() : const AuthPage();
        },
      ),
    );
  }
}

const _gradient = LinearGradient(
  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

String _pesanError(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau password salah.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar.';
    case 'weak-password':
      return 'Password minimal 6 karakter.';
    case 'operation-not-allowed':
      return 'Email/Password belum di-enable di Firebase Console.';
    case 'network-request-failed':
      return 'Koneksi internet bermasalah.';
    default:
      return 'Terjadi kesalahan: $code';
  }
}

// ================= LOGIN / DAFTAR =================
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _hide = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _pesanError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.lock_outline, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLogin ? 'Selamat Datang' : 'Buat Akun Baru',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLogin
                              ? 'Login untuk melanjutkan'
                              : 'Isi data di bawah untuk mendaftar',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Email tidak valid'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _hide,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hide
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() => _hide = !_hide),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Minimal 6 karakter'
                              : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_isLogin ? 'Login' : 'Daftar'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                          }),
                          child: Text(
                            _isLogin
                                ? 'Belum punya akun? Daftar'
                                : 'Sudah punya akun? Login',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= PROFILE =================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nama = TextEditingController();
  final _foto = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nama.text = user?.displayName ?? '';
    _foto.text = user?.photoURL ?? '';
  }

  Future<void> _simpan() async {
    final foto = _foto.text.trim();
    if (foto.isNotEmpty && !foto.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL foto harus diawali https:// (direct link imgbb)'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.updateDisplayName(_nama.text.trim());
      if (foto.isNotEmpty) await user.updatePhotoURL(foto);
      await user.reload();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_pesanError(e.code))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _info(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final adaNama = user.displayName?.isNotEmpty ?? false;
    final nama = adaNama ? user.displayName! : 'Belum ada nama';
    final inisial = adaNama
        ? user.displayName![0].toUpperCase()
        : (user.email ?? '?')[0].toUpperCase();
    final adaFoto = user.photoURL != null && user.photoURL!.isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 32),
              decoration: const BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: adaFoto
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: adaFoto
                        ? null
                        : Text(
                            inisial,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _info(Icons.email_outlined, 'Email', user.email ?? '-'),
                      _info(Icons.fingerprint, 'UID', user.uid),
                      _info(
                        Icons.calendar_today_outlined,
                        'Tanggal daftar',
                        '${user.metadata.creationTime ?? '-'}',
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nama,
                        decoration: const InputDecoration(
                          labelText: 'Nama tampilan',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _foto,
                        decoration: const InputDecoration(
                          labelText: 'URL foto (direct link imgbb)',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _loading ? null : _simpan,
                          child: Text(
                            _loading ? 'Menyimpan...' : 'Simpan profil',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
