import 'package:flutter/foundation.dart'; // Ditambah untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kehadiran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? urlGuru;
  String? urlSubjek;
  String? urlMasa;

  @override
  void initState() {
    super.initState();
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('guru')) {
      urlGuru = uri.queryParameters['guru'];
      urlSubjek = uri.queryParameters['subjek'];
      urlMasa = uri.queryParameters['masa'];
      _selectedIndex = 1; 
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _selectedIndex == 0 
        ? const TeacherForm() 
        : StudentForm(initialGuru: urlGuru, initialSubjek: urlSubjek, initialMasa: urlMasa);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Kehadiran Sekolah'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: content,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Guru'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Murid'),
        ],
      ),
    );
  }
}

class TeacherForm extends StatefulWidget {
  const TeacherForm({super.key});

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  String? selectedTeacher;
  String? selectedSubject;
  TimeOfDay selectedTime = TimeOfDay.now();

  final List<String> teachers = [
    'EN. ZAKARIA BIN MOHAMED', 'EN.AL-AIMAN BIN DOLLAH @ ABDUL AZIZ', 'EN. AHMAD SHARQAWI BIN ISMAIL',
    'UST. MUHAMMAD SYAHRAN BIN IBRAHIM', 'EN. AHAMAD TAMIZEE BIN SUHAIMI', 'EN.NIK FATHUDDIN AFIQ BIN NIK MOHD DIN',
    'EN.MOHAMAD RASHDAN', 'EN.SAYUNI BIN MD. NOR', 'EN. FIKRI BIN IBRAHIM', 'PN. ROHANA BINTI JUSOH',
    'PN. RUZIHAN BINTI AB RAZAK', 'PN. NORASIKIN BINTI ABDUL RAHMAN',
  ];

  final List<String> subjects = [
    'Bahasa Melayu', 'Bahasa Inggeris', 'Matematik', 'Sains', 'Pendidikan Islam', 'Pendidikan Jasmani',
    'Pendidikan Kesihatan', 'Pendidikan Seni Visual', 'Pendidikan Muzik', 'Reka Bentuk dan Teknologi',
    'Teknologi Maklumat dan Komunikasi', 'Sejarah', 'Bahasa Arab',
  ];

  void _generateAndShareLink() {
    if (selectedTeacher == null || selectedSubject == null) return;
    final String timeStr = selectedTime.format(context);
    String baseUrl = Uri.base.origin;
    if (baseUrl == "null" || baseUrl.isEmpty || !baseUrl.startsWith("http")) {
      baseUrl = "https://e-hadir-b42ba.web.app";
    }

    final String generatedLink = "$baseUrl/?guru=${Uri.encodeComponent(selectedTeacher!)}&subjek=${Uri.encodeComponent(selectedSubject!)}&masa=${Uri.encodeComponent(timeStr)}";
    
    final String fullMessage = """
*KEHADIRAN MURID*
Guru: $selectedTeacher
Subjek: $selectedSubject
Masa: $timeStr

Sila klik link di bawah untuk tanda hadir:
$generatedLink
""";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Kehadiran Dijana'),
        content: SelectableText(fullMessage),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullMessage));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesej disalin!')));
            },
            child: const Text('SALIN & KONGSI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Kawalan Guru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 25),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Pilih Nama Guru', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            items: teachers.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => selectedTeacher = v),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Pilih Subjek', border: OutlineInputBorder(), prefixIcon: Icon(Icons.book)),
            items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => selectedSubject = v),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _generateAndShareLink,
              icon: const Icon(Icons.share),
              label: const Text('Jana Link Kehadiran'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const Text('Analisis Kehadiran Semasa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          if (selectedTeacher != null && selectedSubject != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kehadiran')
                  .where('guru', isEqualTo: selectedTeacher)
                  .where('subjek', isEqualTo: selectedSubject)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data?.docs ?? [];
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                      child: Column(
                        children: [
                          const Text('Jumlah Murid Hadir', style: TextStyle(fontSize: 14)),
                          Text('${docs.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(backgroundImage: data['photo'] != null ? NetworkImage(data['photo']) : null, child: data['photo'] == null ? const Icon(Icons.person) : null),
                            title: Text(data['nama'] ?? 'Murid'),
                            subtitle: Text(data['email'] ?? ""),
                            trailing: Text(data['tarikh'] != null ? (data['tarikh'] as Timestamp).toDate().toString().substring(11, 16) : '-'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            )
          else
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Sila pilih guru dan subjek di atas.', style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }
}

class StudentForm extends StatefulWidget {
  final String? initialGuru;
  final String? initialSubjek;
  final String? initialMasa;
  const StudentForm({super.key, this.initialGuru, this.initialSubjek, this.initialMasa});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  bool _isLoading = false;
  User? _currentUser;

  // Web Client ID dari fail google-services.json anda
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '244181607041-8qcslq6uku2eo62a73at4106upaqe45o.apps.googleusercontent.com',
  );

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat Log Masuk: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('kehadiran').add({
        'email': _currentUser!.email,
        'nama': _currentUser!.displayName,
        'photo': _currentUser!.photoURL,
        'guru': widget.initialGuru ?? 'Umum',
        'subjek': widget.initialSubjek ?? 'Umum',
        'masa': widget.initialMasa ?? 'N/A',
        'tarikh': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Text('Terima kasih!\nKehadiran anda telah berjaya direkodkan.', textAlign: TextAlign.center),
          actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP')))],
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ralat: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (widget.initialGuru != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SESI KEHADIRAN AKTIF", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Divider(),
                  Text("GURU: ${widget.initialGuru}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("SUBJEK: ${widget.initialSubjek}"),
                  Text("MASA: ${widget.initialMasa}"),
                ],
              ),
            ),

          if (_currentUser == null)
            Column(
              children: [
                const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                const Text('Sila pilih akaun Google untuk mendaftar kehadiran', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Pilih Akaun Google'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.shade100), borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(_currentUser!.photoURL ?? "")),
                    title: Text(_currentUser!.displayName ?? ""),
                    subtitle: Text(_currentUser!.email ?? ""),
                    trailing: TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Tukar')),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAttendance,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SAHKAN KEHADIRAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
