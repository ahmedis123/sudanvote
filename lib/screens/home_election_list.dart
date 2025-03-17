import 'dart:convert'; // لتحويل البيانات بين JSON والنصوص

import 'package:flutter/material.dart'; // لعناصر واجهة المستخدم في Flutter
import 'package:http/http.dart' as http; // لإرسال طلبات HTTP إلى الخادم

import '../env.dart'; // استيراد ملف البيئة الذي يحتوي على عنوان URL

class ElectionsScreen extends StatefulWidget {
  const ElectionsScreen({super.key});

  @override
  _ElectionsScreenState createState() => _ElectionsScreenState();
}

class _ElectionsScreenState extends State<ElectionsScreen> {
  late Future<List<Map<String, dynamic>>> elections;

  @override
  void initState() {
    super.initState();
    elections = fetchElections(); // جلب الانتخابات عند تحميل الشاشة
  }

  // جلب قائمة الانتخابات مع التحقق من الاتصال بالإنترنت
  Future<List<Map<String, dynamic>>> fetchElections() async {
    try {
      final response = await http.get(Uri.parse('$url/elections'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('فشل في تحميل الانتخابات');
      }
    } catch (e) {
      // في حالة وجود خطأ في الاتصال بالإنترنت
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
  }

  // تنسيق التاريخ بشكل يدوي
  String formatDate(String dateStr) {
    List<String> dates = dateStr.split(' - ');
    DateTime startDate = DateTime.parse(dates[0]);
    DateTime endDate = DateTime.parse(dates[1]);

    return '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} إلى ${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الانتخابات'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', ModalRoute.withName('/login'));
            },
          ),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            // عرض قائمة الانتخابات
            future: elections,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                String errorMessage = snapshot.error.toString();
                if (errorMessage.contains('لا يوجد اتصال بالإنترنت')) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.wifi_off, size: 40, color: Colors.red),
                        SizedBox(height: 10),
                        Text('لا يوجد اتصال بالإنترنت',
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
              } else if (snapshot.hasData) {
                final electionsList = snapshot.data!;
                return ListView.builder(
                  itemCount: electionsList.length,
                  itemBuilder: (context, index) {
                    final election = electionsList[index];
                    String formattedDate = formatDate(election['ElectionDate']);

                    DateTimeRange electioDateTimeRange = DateTimeRange(
                      start: DateTime.parse(formattedDate.split(' إلى ')[0]),
                      end: DateTime.parse(formattedDate.split(' إلى ')[1]),
                    );

                    if (election['ElectionStatus'] == "مفتوحة" &&
                        electioDateTimeRange.start.isBefore(DateTime.now())) {
                      return InkWell(
                        onTap: () {
                          Edata.electionId = election['ElectionID']!;
                          Edata.electionDate = electioDateTimeRange;
                          Navigator.pushNamed(context, '/home');
                        },
                        child: _buildElectionCard(
                          type: election['ElectionType'],
                          date: formattedDate,
                          status: election['ElectionStatus'],
                        ),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  title: const Text("تنبيه"),
                                  content: const Text(
                                      "هذه الانتخابات مغلقة في الوقت الحالي أو لم تبدأ بعد"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("حسنًا"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: _buildElectionCard(
                          type: election['ElectionType'],
                          date: formattedDate,
                          status: election['ElectionStatus'],
                        ),
                      );
                    }
                  },
                );
              } else {
                return const Center(child: Text('لا توجد انتخابات متاحة.'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildElectionCard(
      {required String type, required String status, required String date}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.how_to_vote,
              size: 40,
              color: Colors.teal,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "حالة الانتخابات : $status",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "فترة الانتخابات : $date",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
