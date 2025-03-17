import 'dart:convert'; // لتحويل البيانات بين JSON والنصوص

import 'package:flutter/material.dart'; // لعناصر واجهة المستخدم في Flutter
import 'package:http/http.dart' as http; // لإرسال طلبات HTTP إلى الخادم

import '/models/candidate.dart'; // استيراد نموذج بيانات المرشح
import '../env.dart'; // استيراد ملف البيئة الذي يحتوي على عنوان URL

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  VotingScreenState createState() => VotingScreenState();
}

class VotingScreenState extends State<VotingScreen> {
  late Future<List<Candidate>> candidateFuture; // Future لتخزين قائمة المرشحين
  int? selectedCandidate; // الفهرس المحدد للمرشح
  int? selectedIdCandidate; // معرف المرشح المحدد
  String? voteSuccessMessage; // رسالة نجاح التصويت
  bool isLoading = false; // حالة التحميل أثناء إرسال التصويت

  @override
  void initState() {
    super.initState();
    candidateFuture = fetchCandidates(); // جلب قائمة المرشحين عند بدء التشغيل
  }

  // دالة لجلب قائمة المرشحين من الخادم
  Future<List<Candidate>> fetchCandidates() async {
    try {
      final response = await http
          .get(Uri.parse('$url/candidates/election/${Edata.electionId}'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body); // تحويل JSON إلى قائمة
        return data
            .map((json) => Candidate.fromJson(json))
            .toList(); // تحويل البيانات إلى كائنات Candidate
      } else {
        throw Exception(
            'فشل تحميل البيانات: ${response.statusCode}'); // خطأ في حالة فشل الطلب
      }
    } catch (e) {
      throw Exception(
          'حدث خطأ أثناء تحميل البيانات: $e'); // خطأ في حالة وجود استثناء
    }
  }

  // دالة لإرسال التصويت إلى الخادم
  Future<void> submitVote(
      int voterId, int electionId, int candidateId, String date) async {
    setState(() {
      isLoading = true; // بدء التحميل
    });

    try {
      final response = await http.post(
        Uri.parse('$url/castVote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'voter_id': voterId,
          'election_id': electionId,
          'candidate_id': candidateId,
          'date': date,
        }),
      );

      if (!mounted) return; // التأكد من أن الواجهة لا تزال نشطة

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String message = responseData.containsKey('message')
          ? responseData['message']
          : (response.statusCode == 200
              ? 'تم التصويت بنجاح'
              : 'حدث خطأ أثناء التصويت');

      setState(() {
        voteSuccessMessage = message; // تعيين رسالة النجاح أو الخطأ
        isLoading = false; // إنهاء التحميل
      });

      // عرض رسالة للمستخدم باستخدام SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                response.statusCode == 200 ? Colors.teal : Colors.red,
            content: Text(message),
            duration: const Duration(seconds: 3), // تحديد مدة عرض الرسالة
          ),
        );
      }

      // الانتقال إلى الشاشة الرئيسية بعد التصويت بنجاح
      if (response.statusCode == 200 && mounted) {
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false; // إنهاء التحميل في حالة الخطأ
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("حدث خطأ أثناء إرسال التصويت!"),
          ),
        );
      }
    }
  }

  // دالة لعرض مربع حوار تأكيد التصويت
  void _submitVote() {
    if (selectedCandidate != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl, // دعم اللغة العربية
            child: AlertDialog(
              title: const Text("تأكيد التصويت"),
              content: const Text("هل تريد التصويت لصالح هذا المرشح؟"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // إغلاق مربع الحوار
                  },
                  child: const Text("إلغاء"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // إغلاق مربع الحوار
                    await submitVote(
                      Edata.voter_id,
                      Edata.electionId,
                      selectedIdCandidate!,
                      DateTime.now().toString(),
                    );
                    if (mounted) {
                      Edata.isVoted = 1; // تحديث حالة التصويت
                      Edata.isInElection.add(Edata.electionId
                          .toString()); // إضافة الانتخابات إلى القائمة
                    }
                  },
                  child: const Text("تأكيد"),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // عرض رسالة خطأ إذا لم يتم اختيار مرشح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("يرجى اختيار مرشح قبل التصويت!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: const Text("شاشة التصويت"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // العودة إلى الشاشة السابقة
            },
          ),
          backgroundColor: Colors.teal,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (voteSuccessMessage != null) // عرض رسالة نجاح التصويت
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        voteSuccessMessage!,
                        style:
                            const TextStyle(color: Colors.green, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Text(
                    "اختر المرشح الذي ترغب في التصويت له:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Candidate>>(
                      future: candidateFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // عرض مؤشر تحميل
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'حدث خطأ: ${snapshot.error}')); // عرض رسالة خطأ
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text(
                                  'لا توجد بيانات في الوقت الحالي')); // عرض رسالة عدم وجود بيانات
                        } else {
                          List<Candidate> candidateData = snapshot.data!;
                          return ListView.builder(
                            itemCount: candidateData.length,
                            itemBuilder: (context, index) {
                              return Card(
                                key: ValueKey(candidateData[index]
                                    .candidateID), // إضافة key فريد
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title:
                                      Text(candidateData[index].candidateName),
                                  subtitle:
                                      Text(candidateData[index].partyName),
                                  trailing: Radio<int>(
                                    value: index,
                                    groupValue: selectedCandidate,
                                    onChanged: (value) {
                                      if (mounted) {
                                        setState(() {
                                          selectedCandidate =
                                              value; // تحديث المرشح المحدد
                                          selectedIdCandidate = candidateData[
                                                  index]
                                              .candidateID; // تحديث معرف المرشح
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : _submitVote, // تعطيل الزر أثناء التحميل
                    icon: const Icon(Icons.how_to_vote, color: Colors.white),
                    label: const Text("تصويت"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading) // عرض مؤشر تحميل أثناء إرسال التصويت
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
