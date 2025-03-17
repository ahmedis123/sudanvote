import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/models/candidate.dart';
import '/widgetes/build_text_field.dart';
import '../env.dart';

class CandidateScreen extends StatefulWidget {
  const CandidateScreen({super.key, this.candidate, required this.isFroEdite});
  final bool isFroEdite;
  final Candidate? candidate;

  @override
  _CandidateScreenState createState() => _CandidateScreenState();
}

class _CandidateScreenState extends State<CandidateScreen> {
  // المتغيرات لتخزين الإدخال
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _partyNameController = TextEditingController();
  late TextEditingController _biographyController = TextEditingController();
  late TextEditingController _nationalIDController = TextEditingController();
  late TextEditingController _candidateProgramController =
      TextEditingController();
  String? _selectedElection;
  late Future<List<Map<String, dynamic>>> elections;
  var sizedBox = const SizedBox(height: 20);
  final _nameFocusNode = FocusNode();
  final _partyNameFocusNode = FocusNode();
  final _biographyFocusNode = FocusNode();
  final _nationalFocusNode = FocusNode();
  final _electionsFocusNode = FocusNode();
  bool _isLoading = false; // لإظهار مؤشر التحميل أثناء تسجيل البينات
  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.candidate?.candidateName ?? '');
    _partyNameController =
        TextEditingController(text: widget.candidate?.partyName ?? '');
    _biographyController =
        TextEditingController(text: widget.candidate?.biography ?? '');
    _nationalIDController =
        TextEditingController(text: widget.candidate?.nationalID ?? '');
    _candidateProgramController =
        TextEditingController(text: widget.candidate?.candidateProgram ?? '');
    elections = fetchElections();
    if (widget.candidate != null) {
      _selectedElection = widget.candidate?.electionID.toString() ??
          ''; // جلب الانتخابات عند تحميل الشاشة
    }
  }

  @override
  void dispose() {
    // التخلص من الموارد لتجنب التسريبات
    _candidateProgramController.dispose();
    _nameController.dispose();
    _nationalIDController.dispose();
    _biographyController.dispose();
    _partyNameController.dispose();
    _electionsFocusNode.dispose();
    _nameFocusNode.dispose();
    _nationalFocusNode.dispose();
    _biographyFocusNode.dispose();
    _partyNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> addCandidate(String name, String partyName, String biography,
      String nationalID, String candidateProgram, String electionID) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final http.Response response;
      final data = {
        'CandidateName': name,
        'PartyName': partyName,
        'Biography': biography,
        'NationalID': nationalID,
        'CandidateProgram': candidateProgram,
        'ElectionID': electionID
      };
      if (widget.isFroEdite == false) {
        response = await http.post(
          Uri.parse('$url/candidates'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        setState(() {
          _isLoading = false; // إخفاء مؤشر التحميل
        });
      } else {
        response = await http.put(
          Uri.parse('$url/candidates/${widget.candidate!.candidateID}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        setState(() {
          _isLoading = false; // إخفاء مؤشر التحميل
        });
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("تم تسجيل البيانات بنجاح!"),
              backgroundColor: Colors.teal),
        );
        Edata.initTabController = 0;
        // العودة إلى الصفحة السابقة بعد النجاح
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', ModalRoute.withName('/'));
      } else {
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('خطأ'),
              content: Text('خطأ: ${response.statusCode}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('موافق'),
                ),
              ],
            ),
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل عند حدوث خطأ
      });
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('خطأ'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('موافق'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchElections() async {
    final response = await http.get(Uri.parse('$url/elections'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load elections');
    }
  }

  // دالة لتقديم البيانات
  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final partyName = _partyNameController.text.trim();
      final biography = _biographyController.text.trim();
      final nationalID = _nationalIDController.text.trim();
      final candidateProgram = _candidateProgramController.text.trim();
      final electionId = _selectedElection;
      // هنا يمكن إضافة عملية التسجيل في قاعدة البيانات

      await addCandidate(name, partyName, biography, nationalID,
          candidateProgram, electionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تسجيل المرشحين"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // حقل الاسم
                  buildTextField(
                    label: ' الاسم الكامل',
                    controller: _nameController,
                    context: context,
                    cruntFocusNode: _nameFocusNode,
                    nextFocusNode: _partyNameFocusNode,
                  ),

                  // حقل الحزب

                  buildTextField(
                      label: 'اسم الحزب',
                      controller: _partyNameController,
                      cruntFocusNode: _partyNameFocusNode,
                      nextFocusNode: _electionsFocusNode,
                      context: context),
                  sizedBox,
                  // قائمة منسدلة لانتخاب واحد
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: elections,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('خطاء : ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final electionsList = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          focusNode: _electionsFocusNode,
                          value: _selectedElection,
                          decoration: const InputDecoration(
                            labelText: 'اختر انتخابات',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedElection = newValue;
                            });
                          },
                          items: electionsList
                              .map<DropdownMenuItem<String>>((election) {
                            return DropdownMenuItem<String>(
                              value: election['ElectionID'].toString(),
                              child: Text(election['ElectionID'].toString()),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'الرجاء اختيار انتخابات';
                            }
                            return null;
                          },
                        );
                      } else {
                        return const Center(
                            child: Text('لا يوجد انتخابات في الوقت الحالي'));
                      }
                    },
                  ),

                  sizedBox,
                  // حقل الرقم الوطني
                  TextFormField(
                    controller: _nationalIDController,
                    focusNode: _nationalFocusNode,
                    decoration: const InputDecoration(
                      labelText: " الرقم الوطني  ",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال الرقم الوطني الكامل";
                      } else if (!RegExp(r'\d').hasMatch(value)) {
                        return "الرقم الوطني يجب أن يحتوي على أرقام فقط";
                      } else if (!(value.length == 11)) {
                        return "الرقم الوطني يجب أن يتكون من 11 خانة ";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_biographyFocusNode);
                    },
                  ),
                  sizedBox,

                  // حقل السيرة الذاتية

                  buildTextField(
                      label: ' السيرة الذاتية',
                      controller: _biographyController,
                      cruntFocusNode: _biographyFocusNode,
                      maxLin: 10,
                      minLin: 3),

                  // حقل البرنامج الانتخابي

                  buildTextField(
                      label: ' البرنامج الانتخابي',
                      controller: _candidateProgramController,
                      maxLin: 10,
                      minLin: 3),
                  sizedBox, sizedBox,
                  // زر التسجيل
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text(
                            'حفظ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
