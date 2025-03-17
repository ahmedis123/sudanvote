import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env.dart'; //  يحتوي على متغير 'url'.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _nationalIDController = TextEditingController();
  bool _isLoading = false; // لإظهار مؤشر التحميل أثناء تسجيل الدخول
  bool _obscurePassword = true;
  var sizedBox = const SizedBox(height: 20);
  final _passwordFocusNode = FocusNode();
  final _nationalIDFocusNode = FocusNode();

  @override
  void dispose() {
    // التخلص من الموارد لتجنب التسريبات
    _passwordController.dispose();
    _nationalIDController.dispose();
    _passwordFocusNode.dispose();
    _nationalIDFocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> loginVoter(
      String nationalId, String password) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final response = await http.post(
        Uri.parse('$url/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'national_id': nationalId, 'password': password}),
      );
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': jsonDecode(response.body)['message'] ?? 'حدث خطأ غير معروف'
        };
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل عند حدوث خطأ
      });
      return {'error': 'فشل الاتصال بالخادم: $e'};
    }
  }

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final response = await http.post(
        Uri.parse('$url/login_admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email, 'password': password}),
      );
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': jsonDecode(response.body)['message'] ?? 'حدث خطأ غير معروف'
        };
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل عند حدوث خطأ
      });
      return {'error': 'فشل الاتصال بالخادم: $e'};
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final userInput = _nationalIDController.text.trim().toLowerCase();
      final password = _passwordController.text;

      Map<String, dynamic> result;

      // تحقق إذا كان الإدخال رقمًا (National ID للناخب) أو اسمًا (Admin username)
      if (RegExp(r'\d').hasMatch(userInput)) {
        // الرقم الوطني (ناخب)
        result = await loginVoter(userInput, password);
      } else {
        // اسم المستخدم (أدمن)
        result = await loginAdmin(userInput, password);
      }

      // معالجة الاستجابة
      if (result.containsKey('voter_id')) {
        Edata.voter_id = result['voter_id'];
        Edata.isVoted = result['HasVoted'];
        Edata.isInElection = result['election_id'];
        // تسجيل الدخول كناخب
        Navigator.pushReplacementNamed(context, '/election');
      } else if (result.containsKey('Privileges')) {
        Edata.Privileges = result['Privileges'];
        // تسجيل الدخول كأدمن
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (result.containsKey('error')) {
        // عرض رسالة خطأ

        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('خطأ'),
              content: Text(result['error']),
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
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الصندوق
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Icon(
                    Icons.how_to_vote,
                    size: 110,
                    color: Colors.teal,
                  ),
                ),
                // نص العنوان
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '  ليس لديك حساب؟  ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          ' إنشاء حساب',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // الحقول
                Container(
                  padding: const EdgeInsets.all(60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nationalIDController,
                          focusNode: _nationalIDFocusNode,
                          decoration: const InputDecoration(
                            labelText: " الرقم الوطني  ",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال الرقم الوطني ";
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                        sizedBox,
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            labelText: "كلمة المرور",
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال كلمة المرور";
                            } else if (value.length < 8) {
                              return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // زر تسجيل الدخول
                sizedBox,
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          'تسجيل دخول',
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
    );
  }
}
