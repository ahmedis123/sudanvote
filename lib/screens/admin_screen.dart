import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/widgetes/build_text_field.dart';
import '../env.dart';
import '../models/admin.dart';

class AdminScreen extends StatefulWidget {
  final Admin? admin;
  final bool isFroEdite;
  const AdminScreen({super.key, this.admin, required this.isFroEdite});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // المتغيرات لتخزين الإدخال
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  String? privilege;
//  المتغيرات للانتقال textfeild التالي
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _privilegeFocusNode = FocusNode();
  bool _isLoading = false; // لإظهار مؤشر التحميل أثناء تسجيل البينات
  var items = [
    'ادارة المرشحين',
    'ادارة الانتخابات',
    'ادارة مدراء النظام',
    'كامل الصلاحيات',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.admin?.name ?? '');
    _emailController = TextEditingController(text: widget.admin?.email ?? '');
    _passwordController =
        TextEditingController(text: widget.admin?.password ?? '');
    privilege = widget.admin?.privilege ?? 'ادارة المرشحين';
  }

  @override
  void dispose() {
    // التخلص من الموارد لتجنب التسريبات
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _privilegeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  var sizedBox = const SizedBox(height: 20);

  Future<void> addAdmin(
      String voterName,
      String email,
      String password,
      String privilege,
      ) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final http.Response response;
      final data = {
        'AdminName': voterName,
        'Email': email,
        'Password': password,
        'Privileges': privilege,
      };
      if (widget.isFroEdite == false) {
        response = await http.post(
          Uri.parse('$url/admin'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        setState(() {
          _isLoading = false; // إخفاء مؤشر التحميل
        });
      } else {
        response = await http.put(
          Uri.parse('$url/admin/${widget.admin!.adminID}'),
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
        Edata.initTabController = 2;
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
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      // هنا يمكن إضافة عملية التسجيل في قاعدة البيانات
      await addAdmin(name, email, password, privilege!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل مدير'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
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
                      label: "الاسم كامل",
                      controller: _nameController,
                      cruntFocusNode: _nameFocusNode,
                      nextFocusNode: _emailFocusNode,
                      context: context),

                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: const InputDecoration(
                      labelText: "البريد الإلكتروني",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال البريد الإلكتروني";
                      } else if (!RegExp(r'\w+@\w+\.\w+', caseSensitive: false)
                          .hasMatch(value)) {
                        return "البريد الإلكتروني غير صالح";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  sizedBox,

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: const InputDecoration(
                      labelText: "كلمة المرور",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال كلمة المرور";
                      } else if (value.length < 8) {
                        return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_privilegeFocusNode);
                    },
                  ),
                  sizedBox,

                  // حقل الصلاحيات
                  DropdownButtonFormField<String>(
                    value: privilege,
                    focusNode: _privilegeFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء اختيار الصلاحيات";
                      }
                      return null;
                    },
                    items: items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'الصلاحيات',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        privilege = newValue!;
                      });
                    },
                  ),

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
