import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/env.dart';
import '/models/admin.dart';
import '/models/candidate.dart';
import '/models/election.dart';
import '/screens/candidate_screen.dart';
import '/screens/election_screen.dart';
import '/widgetes/admin_list_tile.dart';
import '/widgetes/candidate_list_tile.dart';
import '/widgetes/elction_list_tile.dart';
import 'admin_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Candidate> candidateData;
  late List<Tab> selectedTap;
  late int selectedPrivilege = 1;

  @override
  void initState() {
    super.initState();
    checkPrivilege();
    _tabController = TabController(
        length: selectedPrivilege,
        vsync: this,
        initialIndex: Edata.initTabController);
  }

  checkPrivilege() {
    if (Edata.Privileges == 'ادارة المرشحين') {
      selectedPrivilege = 1;
      selectedTap = [const Tab(text: "المرشحون")];
      return [const CandidatesTab()];
    } else if (Edata.Privileges == 'ادارة الانتخابات') {
      selectedPrivilege = 1;
      selectedTap = [const Tab(text: "الانتخابات")];
      return [const ElectionsTab()];
    } else if (Edata.Privileges == 'ادارة مدراء النظام') {
      selectedPrivilege = 1;
      selectedTap = [const Tab(text: "مديرو النظام")];
      return [const AdminsTab()];
    } else if (Edata.Privileges == 'كامل الصلاحيات') {
      selectedPrivilege = 3;
      selectedTap = [
        const Tab(text: "المرشحون"),
        const Tab(text: "الانتخابات"),
        const Tab(text: "مديرو النظام")
      ];
      return [
        const CandidatesTab(),
        const ElectionsTab(),
        const AdminsTab(),
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', ModalRoute.withName('/login'));
            },
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
          title: const Text("لوحة التحكم"),
          bottom: TabBar(
            controller: _tabController,
            tabs: selectedTap,
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: TabBarView(
            controller: _tabController,
            children: checkPrivilege(),
          ),
        ),
      ),
    );
  }
}

// شاشة المرشحين
class CandidatesTab extends StatefulWidget {
  const CandidatesTab({super.key});

  @override
  State<CandidatesTab> createState() => _CandidatesTabState();
}

class _CandidatesTabState extends State<CandidatesTab> {
  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

//جلب بينات المرشح
  Future<List<Candidate>> fetchCandidates() async {
    final response =
        await http.get(Uri.parse('$url/candidates')); // استبدل بالرابط الخاص بك

    if (response.statusCode == 200) {
      // فك البيانات وتحويلها إلى قائمة كائنات Candidate
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Candidate.fromJson(json)).toList();
    } else {
      throw Exception('فشل تحميل البيانات');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        RefreshIndicator(
          onRefresh: fetchCandidates,
          child: FutureBuilder<List<Candidate>>(
              future: fetchCandidates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطاء : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('لا توجد بينات في الوقت الحالي'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length, // عدد العناصر
                    itemBuilder: (context, index) {
                      return CandidatesListTile(
                        candidate: snapshot.data![index],
                      );
                    },
                  );
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0, right: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CandidateScreen(
                        isFroEdite: false,
                      )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text(
              'اضافة',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// شاشة الانتخابات
class ElectionsTab extends StatefulWidget {
  const ElectionsTab({super.key});

  @override
  State<ElectionsTab> createState() => _ElectionsTabState();
}

class _ElectionsTabState extends State<ElectionsTab> {
  @override
  void initState() {
    super.initState();
    fetchElection();
  }

//جلب بينات الانتحابات
  Future<List<Election>> fetchElection() async {
    final response =
        await http.get(Uri.parse('$url/elections')); // استبدل بالرابط الخاص بك

    if (response.statusCode == 200) {
      // فك البيانات وتحويلها إلى قائمة كائنات Candidate
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Election.formJson(json)).toList();
    } else {
      throw Exception('فشل تحميل البيانات');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        RefreshIndicator(
          onRefresh: fetchElection,
          child: FutureBuilder<List<Election>>(
              future: fetchElection(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطاء : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('لا توجد بينات في الوقت الحالي'));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data!.length, // عدد العناصر
                      itemBuilder: (context, index) {
                        return ElectionsListTile(
                          election: snapshot.data![index],
                        );
                      });
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0, right: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ElectionScreen(
                        isFroEdite: false,
                      )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text(
              'اضافة',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// شاشة مديري النظام
class AdminsTab extends StatefulWidget {
  const AdminsTab({super.key});

  @override
  State<AdminsTab> createState() => _AdminsTabState();
}

class _AdminsTabState extends State<AdminsTab> {
  @override
  void initState() {
    super.initState();
    fetchAdmin();
  }

//جلب بينات مدير النظام
  Future<List<Admin>> fetchAdmin() async {
    final response =
        await http.get(Uri.parse('$url/admin')); // استبدل بالرابط الخاص بك

    if (response.statusCode == 200) {
      // فك البيانات وتحويلها إلى قائمة كائنات Admin
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Admin.fromJson(json)).toList();
    } else {
      throw Exception('فشل تحميل البيانات');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        RefreshIndicator(
          onRefresh: fetchAdmin,
          child: FutureBuilder<List<Admin>>(
              future: fetchAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطاء : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('لا توجد بينات في الوقت الحالي'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length, // عدد العناصر
                    itemBuilder: (context, index) {
                      return AdminsListTile(admin: snapshot.data![index]);
                    },
                  );
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0, right: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdminScreen(
                        isFroEdite: false,
                      )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text(
              'اضافة',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
