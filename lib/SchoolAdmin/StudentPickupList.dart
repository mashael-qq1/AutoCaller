import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'NavBarAdmin.dart';
class StudentPickupList extends StatefulWidget {
  const StudentPickupList({Key? key}) : super(key: key);
  @override
  State<StudentPickupList> createState() => _StudentPickupListState();
}

class _StudentPickupListState extends State<StudentPickupList> {
  String? schoolLogo;
  String? selectedSchoolId;
  String? selectedSchoolName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int waitingCount = 0;
  int lateCount = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = true;
//======= TTS =======//
  FlutterTts flutterTts = FlutterTts(); // Initialize the FlutterTts

  List<dynamic> _voices = [];
  String? _selectedVoice;
  String _selectedLocale = 'en-GB'; // Default Arabic locale

  @override
  void initState() {
    super.initState();
    _setAwaitOptions(); // Optional: Configure TTS engine to wait for

    _setInitialLocale(_selectedLocale); // Set initial Arabic locale
    _getVoices(); // Get available voices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

//======= TTS =======//
  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _setInitialLocale(String locale) async {
    try {
      await flutterTts.setLanguage(locale);
      debugPrint('🔵 TTS: Locale set to $locale');
    } catch (e) {
      debugPrint('❌ TTS: Error setting locale: $e');
    }
  }

  Future<void> _getVoices() async {
    try {
      _voices = await flutterTts.getVoices as List<dynamic>;
      debugPrint('🔵 TTS: Available voices: $_voices');
      setState(() {
        for (var voice in _voices) {
          if (voice['locale'].toString().startsWith('ar')) {
            debugPrint('🔊 Arabic Voice Found: ${voice['name']}');
          }
        }

        if (_selectedVoice == null && _voices.isNotEmpty) {
//If no arabic voice is found, set to the first available

          _selectedVoice = _voices[0]['name'];
          _setVoice(_selectedVoice!);
        }
      });
    } catch (e) {
      debugPrint('❌ TTS: Error getting voices: $e');
    }
  }

  Future<void> _setVoice(String voice) async {
    try {
      await flutterTts.setVoice({'name': voice, 'locale': _selectedLocale});
      debugPrint('🔵 TTS: Voice set to $voice');
    } catch (e) {
      debugPrint('❌ TTS: Error setting voice: $e');
    }
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS: Error speaking: $e');
    }
  }
//===================//

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!_isAutoScrolling || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll < maxScroll) {
        _scrollController.animateTo(
          currentScroll + 50, // 👈 smaller scroll step
          duration: const Duration(seconds: 2), // 👈 slower animation
          curve: Curves.linear, // 👈 smoother, steady scroll
        );
      } else {
        // Return to the top smoothly
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      _startAutoScroll(); // Recursive call
    });
  }

  @override
  void dispose() {
    _isAutoScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSchoolData(String schoolId) async {
    debugPrint('🔵 StudentPickupList: Loading data for school: $schoolId');
    try {
      final schoolDoc =
          await _firestore.collection('School').doc(schoolId).get();
      if (schoolDoc.exists) {
        final data = schoolDoc.data();
        setState(() {
          schoolLogo = data?['logo'];
          selectedSchoolName = data?['name'];
          debugPrint(
              '🔵 StudentPickupList: School data loaded - Name: $selectedSchoolName, Logo: $schoolLogo');
        });
      }
    } catch (e) {
      debugPrint('❌ StudentPickupList: Error loading school data: $e');
    }
  }

  Stream<List<DocumentSnapshot>> getStudentsStream() {
    if (selectedSchoolId == null) return Stream.value([]);

    debugPrint('\n🔍 DEBUG: Student Query Information:');
    debugPrint('----------------------------------------');
    debugPrint('🏫 Selected School ID: $selectedSchoolId');

    return _firestore.collection('Student').snapshots().map((snapshot) {
      debugPrint('\n📊 Query Results:');
      debugPrint('----------------------------------------');
      debugPrint('📝 Total students in collection: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('\n👤 Student Details:');
        debugPrint('   ID: ${doc.id}');
        debugPrint('   Name: ${data['Sname']}');
        debugPrint('   School ID: ${data['schoolID']}');
        debugPrint('   Ready for Pickup: ${data['readyForPickup']}');
        debugPrint('   Dismissal Status: ${data['dismissalStatus']}');
        debugPrint('   Grade Level: ${data['gradeLevel']}');
      }

      final schoolStudents = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final studentSchoolRef = data['schoolID'] as DocumentReference?;
        final matchesSchool = studentSchoolRef?.id == selectedSchoolId;

        debugPrint('\n🏫 School Check for ${data['Sname']}:');
        debugPrint('   Student\'s School ID: ${studentSchoolRef?.id}');
        debugPrint('   Looking for School ID: $selectedSchoolId');
        debugPrint('   Matches School: $matchesSchool');
        return matchesSchool;
      }).toList();

      debugPrint('\n📊 School Filter Results:');
      debugPrint('----------------------------------------');
      debugPrint('Students matching school: ${schoolStudents.length}');

      waitingCount = 0;
      lateCount = 0;

      final filteredStudents = schoolStudents.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final dismissalStatus = data['dismissalStatus'] as String? ?? '';
        final isWaitingOrLate = dismissalStatus.toLowerCase() == 'waiting' ||
            dismissalStatus.toLowerCase() == 'late';

        final readyForPickup = data['readyForPickup'] as bool? ?? false;
        final isAbsent = data['absent'] as bool? ?? false;

        final shouldInclude = readyForPickup && !isAbsent && isWaitingOrLate;

        if (shouldInclude) {
          if (dismissalStatus.toLowerCase() == 'waiting') waitingCount++;
          if (dismissalStatus.toLowerCase() == 'late') lateCount++;
        }

        debugPrint('\n👤 Student Filter Details for ${data['Sname']}:');
        debugPrint('   Ready for Pickup: $readyForPickup');
        debugPrint('   Absent: $isAbsent');
        debugPrint('   Dismissal Status: $dismissalStatus');
        debugPrint('   Should Include: $shouldInclude');

        return shouldInclude;
      }).toList();

      debugPrint('\n📈 Final Results:');
      debugPrint('----------------------------------------');
      debugPrint(
          'Total students after all filtering: ${filteredStudents.length}');
      debugPrint('Waiting count: $waitingCount');
      debugPrint('Late count: $lateCount');

      // 🔊 Speak all names in order
      List<String> studentNames = filteredStudents.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['Sname']?.toString() ?? '';
      }).toList();

      _speakStudentListLoop(studentNames); // 🔁 Repeat TTS names

      return filteredStudents;
    });
  }

  Stream<DateTime> _timeStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield DateTime.now();
    }
  }

  Widget _buildSchoolSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/autoCallerLogoWithoutName.png',
            width: 140,
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to the Student Pickup Screen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please select a school to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('School').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Text('Error loading schools');
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const CircularProgressIndicator();

                  final schools = snapshot.data?.docs ?? [];
                  if (schools.isEmpty) return const Text('No schools found');

                  return DropdownButton<String>(
                    value: selectedSchoolId,
                    isExpanded: true,
                    hint: const Text('Choose from available schools'),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: schools.map((school) {
                      final data = school.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: school.id,
                        child: Text(data['name'] ?? 'Unnamed School'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSchoolId = newValue;
                        if (newValue != null) {
                          _loadSchoolData(newValue);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _startAutoScroll();
                          });
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'autocaller@zohomail.sa',
                query: Uri.encodeFull(
                    'subject=Support Request&body=Hello AutoCaller Support,'),
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                debugPrint('❌ Could not launch email client');
              }
            },
            icon: const Icon(Icons.support_agent, color: Color(0xFF2196F3)),
            label: const Text(
              'Need Help? Contact Support',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  int _currentStudentIndex = 0;
  bool _isSpeaking = false;

  void _speakStudentListLoop(List<String> names) async {
    if (_isSpeaking || names.isEmpty) return;
    _isSpeaking = true;

    while (mounted) {
      final nameToSpeak = names[_currentStudentIndex];
      await flutterTts.speak(nameToSpeak);
      await Future.delayed(const Duration(seconds: 3)); // pause between names

      _currentStudentIndex++;
      if (_currentStudentIndex >= names.length) {
        _currentStudentIndex = 0; // start over
      }
    }

    _isSpeaking = false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 StudentPickupList: Building UI...');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (selectedSchoolId == null)
            _buildSchoolSelector()
          else
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // School Logo
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey[100],
                        ),
                        child: schoolLogo != null
                            ? Image.network(
                                schoolLogo!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      '❌ Error loading school logo: $error');
                                  return const Icon(Icons.school,
                                      color: Colors.grey);
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.school, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // School Name and System
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSchoolName ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Student Pickup System',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Time
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 4),
                          StreamBuilder<DateTime>(
                            stream: _timeStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Text('--:--');
                              return Text(
                                DateFormat('hh:mm a').format(snapshot.data!),
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),
                      // Pickup Zone Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on,
                                color: Colors.blue, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Pickup Zone Active',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (selectedSchoolId != null) ...[
            // Status Counts
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Student List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(
                    icon: Icons.access_time,
                    label: 'Waiting',
                    count: '($waitingCount)',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    icon: Icons.warning,
                    label: 'Late',
                    count: '($lateCount)',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            // Student List
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: getStudentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint(
                        '❌ StudentPickupList: StreamBuilder error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    debugPrint(
                        '🔵 StudentPickupList: StreamBuilder waiting for data...');
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data ?? [];
                  debugPrint(
                      '🔵 StudentPickupList: Building list with ${students.length} students');

                  if (students.isEmpty) {
                    return const Center(
                        child: Text('No students available for pickup'));
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          220, // Adjusts number of columns based on screen width
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7, // Less height = more compact cards
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student =
                          students[index].data() as Map<String, dynamic>;
                      final dismissalStatus =
                          student['dismissalStatus'] as String;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 4),
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: student['photoUrl'] != null &&
                                        student['photoUrl']
                                            .toString()
                                            .isNotEmpty
                                    ? NetworkImage(student['photoUrl'])
                                    : null,
                                child: student['photoUrl'] == null ||
                                        student['photoUrl'].toString().isEmpty
                                    ? Text(
                                        student['Sname'][0],
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.black54),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                student['Sname'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Grade ${student['gradeLevel']}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const Spacer(), // 👈 Pushes the status label down
                              _buildStatusLabel(dismissalStatus),
                              const SizedBox(
                                  height:
                                      23), // 👈 pushes the statuss slightly upward
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            const Expanded(child: SizedBox()), // keep layout clean
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    IconData icon;
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'waiting':
        icon = Icons.access_time;
        color = Colors.orange;
        label = 'Waiting';
        break;
      case 'late':
        icon = Icons.warning;
        color = Colors.red;
        label = 'Late';
        break;
      default:
        icon = Icons.access_time;
        color = Colors.orange;
        label = 'Waiting';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
