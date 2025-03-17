import 'dart:async'; // لإضافة Timer للبحث مع تأخير (debounce)
import 'dart:convert';
import 'dart:io'; // استخدام مكتبة dart:io لفحص الاتصال

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/models/candidate.dart';
import '/screens/candidate_detail_screen.dart';
import '/screens/result_screen.dart';
import '../env.dart';

// شاشة عرض رئيسية تحتوي على قائمة من المرشحين والبحث بينهم
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<Candidate> filter = [],
      candidateData = []; // قائمة لتخزين بيانات المرشحين بعد الفلترة
  late TabController _tabController; // تحكم في التبديل بين التبويبات
  bool isLoading = true; // حالة التحميل
  bool isError = false; // حالة الخطأ
  late TextEditingController searchController; // تحكم في حقل البحث
  String? lastQuery; // نص آخر عملية بحث
  late Timer _debounce; // مؤقت لتأخير تنفيذ البحث (debounce)

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(); // تهيئة تحكم البحث
    _tabController =
        TabController(length: 2, vsync: this); // تهيئة التحكم في التبويبات
    _debounce = Timer(const Duration(seconds: 0), () {}); // تهيئة المؤقت
    fetchCandidates(); // جلب بيانات المرشحين عند بدء الشاشة
  }

  // فحص الاتصال بالإنترنت عبر التحقق من إمكانية الوصول إلى "google.com"
  Future<bool> _isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false; // إرجاع false إذا لم يكن هناك اتصال بالإنترنت
    }
  }

  // جلب بيانات المرشحين من الخادم
  Future<void> fetchCandidates() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    bool connected = await _isConnected(); // التحقق من الاتصال بالإنترنت
    if (!connected) {
      // إذا لم يكن هناك اتصال، يتم مسح بيانات المرشحين وعرض رسالة
      setState(() {
        isLoading = false;
        isError = true;
        candidateData = [];
        filter = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال وإعادة المحاولة.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // جلب بيانات المرشحين من الخادم باستخدام HTTP GET
      final response = await http
          .get(Uri.parse('$url/candidates/election/${Edata.electionId}'));

      if (response.statusCode == 200) {
        // فك البيانات وتحويلها إلى كائنات Candidate
        List<dynamic> data = json.decode(response.body);
        setState(() {
          candidateData = data.map((json) => Candidate.fromJson(json)).toList();
          filter = candidateData;
          isLoading = false;
        });
      } else {
        // في حال فشل جلب البيانات من الخادم
        throw Exception(
            'فشل تحميل البيانات. رمز الاستجابة: ${response.statusCode}');
      }
    } catch (e) {
      // في حال حدوث أي خطأ أثناء الاتصال بالخادم
      setState(() {
        isLoading = false;
        isError = true;
        candidateData = []; // مسح بيانات المرشحين في حال حدوث خطأ
        filter = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'حدث خطأ في الاتصال بالخادم. تأكد من الاتصال بالإنترنت وأعد المحاولة.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة للبحث مع تأخير (debounce) لتقليل الضغط على الخادم أثناء الكتابة
  void filters(String query) {
    if (lastQuery != query) {
      setState(() {
        lastQuery = query; // تحديث النص الذي أدخله المستخدم
      });

      // إلغاء المؤقت السابق إذا كان نشطًا
      if (_debounce.isActive) _debounce.cancel();

      // تهيئة المؤقت مع مدة تأخير قبل تنفيذ الفلترة
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          // فلترة المرشحين بناءً على النص المدخل في حقل البحث
          filter = candidateData
              .where((c) =>
                  c.candidateName.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      });
    }
  }

  @override
  void dispose() {
    // إلغاء المؤقت عند مغادرة الشاشة
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تحديد اتجاه النص من اليمين لليسار
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          centerTitle: true,
          title: const Text("الشاشة الرئيسية"), // عنوان الشاشة
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // العودة إلى الشاشة السابقة
            },
          ),
          bottom: TabBar(
            controller: _tabController, // تحكم التبديل بين التبويبات
            tabs: const [
              Tab(text: "قائمة المرشحين"),
              Tab(text: "النتائج"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // حقل البحث عن المرشحين
                  TextField(
                    controller: searchController,
                    onChanged: (query) {
                      filters(query); // استدعاء دالة الفلترة
                    },
                    decoration: InputDecoration(
                      hintText: "البحث عن مرشح...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // عرض مؤشر التحميل أثناء تحميل البيانات
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                  // عرض رسالة في حال حدوث خطأ أو عدم وجود بيانات
                  if (isError && !isLoading)
                    const Center(
                      child: Text(
                        'لا توجد بيانات لعرضها.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  // عرض قائمة المرشحين
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchCandidates, // سحب لتحديث البيانات
                      child: ListView.builder(
                        itemCount: filter.length, // عدد المرشحين المعروضين
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // عند النقر على المرشح، يتم الانتقال إلى تفاصيله
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CandidateDetailsScreen(
                                      index: index, candidate: filter[index]),
                                ),
                              );
                            },
                            child: _buildCandidateCard(
                              name: filter[index].candidateName,
                              party: "حزب ${filter[index].partyName}",
                              program:
                                  "البرنامج الانتخابي  \n ${filter[index].candidateProgram}",
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const ResultsScreen(), // شاشة النتائج
          ],
        ),
      ),
    );
  }

  // بناء واجهة بطاقة المرشح
  Widget _buildCandidateCard(
      {required String name, required String party, required String program}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // أيقونة المرشح
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            // تفاصيل المرشح
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    party,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program,
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
