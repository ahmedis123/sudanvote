import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/env.dart';
import '/models/election.dart';

class ElectionScreen extends StatefulWidget {
  const ElectionScreen({super.key, this.election, required this.isFroEdite});
  final bool isFroEdite;
  final Election? election;

  @override
  _ElectionScreenState createState() => _ElectionScreenState();
}

class _ElectionScreenState extends State<ElectionScreen> {
  // المتغيرات لتخزين الإدخال
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _elctionDateController = TextEditingController();
  String? elctionType;
  String? elctionStatus;
  bool _isLoading = false; // لإظهار مؤشر التحميل أثناء تسجيل البينات
  DateTimeRange? elctionDates;

  var sizedBox = const SizedBox(height: 20);

  @override
  void initState() {
    super.initState();
    if (widget.election != null) {
      var temp =
          '${widget.election?.elctionDate.toString().split(' ')[0]} الى ${widget.election?.elctionDate.toString().split(' ')[3]}';
      _elctionDateController = TextEditingController(text: temp);
      elctionDates = widget.election?.elctionDate;
      elctionType = widget.election?.elctionType;
      elctionStatus = widget.election?.elctionStatus;
    }
  }

  @override
  void dispose() {
    // التخلص من الموارد لتجنب التسريبات
    _elctionDateController.dispose();
    super.dispose();
  }

  Future<void> addElection(
    String elctionType,
    String elctionStatus,
    String elctionDate,
  ) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final http.Response response;
      final data = {
        'ElectionType': elctionType,
        'ElectionStatus': elctionStatus,
        'ElectionDate': elctionDate,
      };
      if (widget.isFroEdite == false) {
        response = await http.post(
          Uri.parse('$url/elections'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        setState(() {
          _isLoading = false; // إخفاء مؤشر التحميل
        });
      } else {
        response = await http.put(
          Uri.parse('$url/elections/${widget.election!.elctionID}'),
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
        Edata.initTabController = 1;
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

  // دالة لتقديم البيانات
  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      // هنا يمكن إضافة عملية التسجيل في قاعدة البيانات
      await addElection(
          elctionType!,
          elctionStatus!,
          elctionDates == null
              ? elctionDates.toString()
              : elctionDates.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("تسجيل الانتخابات")),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // حقل نوع الانتخابات
                  const SizedBox(
                    height: 40,
                  ),
                  DropdownButtonFormField<String>(
                    value: elctionType,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال نوع الانتخابات";
                      }
                      return null;
                    },
                    items: [
                      "انتخابات رئاسية",
                      "انتخابات برلمانية",
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "نوع الانتخابات",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        elctionType = newValue;
                      });
                    },
                  ),
                  sizedBox,
                  // حقل حالة الانتخابات
                  DropdownButtonFormField<String>(
                    value: elctionStatus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال حالة الانتخابات";
                      }
                      return null;
                    },
                    items: ["مغلقة", "مفتوحة"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "حالة الانتخابات",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        elctionStatus = newValue;
                      });
                    },
                  ),
                  sizedBox,
                  // حقل تاريخ الانتخابات

                  TextFormField(
                    controller: _elctionDateController,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الانتخابات',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      elctionDates = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate:
                            DateTime.now().add(const Duration(days: 1380)),
                      );
                      _elctionDateController.text =
                          '${elctionDates.toString().split(' ')[0]} الى ${elctionDates.toString().split(' ')[3]}';
                      setState(() {
                        elctionDates = elctionDates;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال تاريخ الانتخابات";
                      }
                      return null;
                    },
                  ),
                  sizedBox,
                  sizedBox,
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
