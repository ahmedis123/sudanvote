import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/widgetes/build_text_field.dart';
import '../env.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // المتغيرات لتخزين الإدخال
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIDController = TextEditingController();
  final _birthDayController = TextEditingController();
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _isLoading = false; // لإظهار مؤشر التحميل أثناء تسجيل الدخول
  String? gender; // القيم الافتراضية لحقل الجنس
  String? states; // القيم الافتراضية لحقل الولايات
  String? selectedCountryCode = '+249'; // رمز الدولة الافتراضي
  final List<String> countryCodes = [
    '+249', // السودان
    '+20', // مصر
    '+966', // السعودية
    '+971', // الإمارات
    '+974', // قطر
    '+965', // الكويت
    '+973', // البحرين
    '+968', // عمان
    '+962', // الأردن
    '+961', // لبنان
    '+963', // سوريا
    '+964', // العراق
    '+967', // اليمن
    '+213', // الجزائر
    '+212', // المغرب
    '+216', // تونس
    '+218', // ليبيا
    '+1', // الولايات المتحدة
    '+44', // المملكة المتحدة
    '+91', // الهند
    '+90', // تركيا
    '+86', // الصين
    '+81', // اليابان
    '+49', // ألمانيا
    '+33', // فرنسا
    '+61', // أستراليا
  ];

  final _nameNode = FocusNode();
  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();
  final _confirmPasswordNode = FocusNode();
  final _phoneNode = FocusNode();
  final _nationalIDNode = FocusNode();
  final _stateFocusNode = FocusNode();
  var sizedBox = const SizedBox(height: 20);

  Future<http.Response> addVoter(
    String nationalID,
    String voterName,
    String state,
    String email,
    bool hasVoted,
    DateTime dateOfBirth,
    String gender,
    String password,
    String phone,
  ) async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final data = {
        'NationalID': nationalID,
        'VoterName': voterName,
        'State': state,
        'Email': email,
        'HasVoted': hasVoted,
        'DateOfBirth': dateOfBirth.toIso8601String(),
        'Gender': gender,
        'Password': password,
        'Phone': phone,
      };

      final response = await http.post(
        Uri.parse('$url/voters'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });

      return response;
    } on Exception catch (e) {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل عند حدوث خطأ
      });
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }

  @override
  void dispose() {
    // التخلص من الموارد لتجنب التسريبات
    _passwordController.dispose();
    _nationalIDController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthDayController.dispose();
    _stateFocusNode.dispose();
    _nationalIDNode.dispose();
    _phoneNode.dispose();
    _confirmPasswordNode.dispose();
    _passwordNode.dispose();
    _emailNode.dispose();
    _nameNode.dispose();
    super.dispose();
  }

  // دالة لتقديم البيانات
  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();
      final phone = '$selectedCountryCode  ${_phoneController.text.trim()}';
      final nationalID = _nationalIDController.text.trim();
      final birthDay = _birthDayController.text.trim();
      const hasVoted = false; // القيم الافتراضية لحالة الناخب
      final selectedState = states;
      final selectedGender = gender;
      // إضافة البيانات إلى API
      try {
        // إضافة بيانات المستخدم إلى مجموعة
        final response = await addVoter(
            nationalID,
            name,
            selectedState!,
            email,
            hasVoted,
            DateTime.parse(birthDay),
            selectedGender!,
            password,
            phone);
        if (response.statusCode == 201) {
          // إظهار رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("تم تسجيل البيانات بنجاح!"),
                backgroundColor: Colors.teal),
          );
          // العودة إلى الصفحة السابقة بعد النجاح
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("الرقم الوطني او رقم الهاتف مسجلين بالفعل"),
              backgroundColor: Colors.red));
        }
      } catch (e) {
        // في حال حدوث خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تسجيل البيانات"),
          centerTitle: true,
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
                  // حقل الاسم
                  buildTextField(
                    label: ' الاسم الكامل',
                    controller: _nameController,
                    context: context,
                    cruntFocusNode: _nameNode,
                    nextFocusNode: _emailNode,
                  ),

                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "البريد الإلكتروني",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    focusNode: _emailNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordNode);
                    },
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
                  ),
                  sizedBox,

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
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
                    focusNode: _passwordNode,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordNode);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال كلمة المرور";
                      } else if (value.length < 8) {
                        return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                      }
                      return null;
                    },
                  ),
                  sizedBox,
                  // حقل تاكيد كلمة المرور
                  TextFormField(
                    controller: _confirmPasswordController,
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
                      labelText: "تاكيد كلمة المرور",
                      border: const OutlineInputBorder(),
                    ),
                    focusNode: _confirmPasswordNode,
                    keyboardType: TextInputType.visiblePassword,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneNode);
                    },
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال كلمة المرور";
                      } else if (value != _passwordController.text) {
                        return "الرجاء اعادة كتابة كلمة الرور بشكل صحيح";
                      }
                      return null;
                    },
                  ),
                  sizedBox,

                  // حقل رقم الهاتف
                  Row(
                    children: [
                      // قائمة اختيار رمز الدولة
                      DropdownButton<String>(
                        value: selectedCountryCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        items: countryCodes
                            .map<DropdownMenuItem<String>>((String code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: "رقم الهاتف",
                            border: OutlineInputBorder(),
                          ),
                          focusNode: _phoneNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_nationalIDNode);
                          },
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال رقم الهاتف";
                            } else if (!RegExp(r'\d').hasMatch(value)) {
                              return "رقم الهاتف يجب أن يحتوي على أرقام فقط";
                            } else if (!(value.length > 7)) {
                              return "رقم الهاتف يجب أن يتكون من 8 خانة ";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  sizedBox,

                  // حقل الرقم الوطني
                  TextFormField(
                    controller: _nationalIDController,
                    decoration: const InputDecoration(
                      labelText: " الرقم الوطني  ",
                      border: OutlineInputBorder(),
                    ),
                    focusNode: _nationalIDNode,
                    keyboardType: TextInputType.number,
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
                      FocusScope.of(context).requestFocus(_stateFocusNode);
                    },
                  ),
                  sizedBox,
                  // حقل الولاية
                  DropdownButtonFormField<String>(
                    value: states,
                    focusNode: _stateFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال الولاية";
                      }
                      return null;
                    },
                    items: [
                      "ولاية الخرطوم",
                      "ولاية الجزيرة",
                      "ولاية القضارف",
                      "ولاية النيل الازرق",
                      "ولاية البحر الاحمر",
                      "الولاية الشمالية",
                      "ولاية كسلا",
                      "ولاية سنار",
                      "ولاية جنوب كردفان",
                      "ولاية شمال كردفان",
                      "ولاية غرب كردفان",
                      " ولاية النيل الابيض",
                      "ولاية جنوب دارفور",
                      "ولاية شمال دارفور",
                      "ولاية غرب دارفور",
                      "ولاية وسط دارفور",
                      "ولاية شرق دارفور",
                      "ولاية نهر النيل"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "الولاية",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        states = newValue;
                      });
                    },
                  ),
                  sizedBox,
                  // حقل الجنس
                  DropdownButtonFormField<String>(
                    value: gender,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال الجنس";
                      }
                      return null;
                    },
                    items: ["ذكر", "أنثى"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "الجنس",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue;
                      });
                    },
                  ),
                  sizedBox,
                  // حقل تاريخ الميلاد
                  TextFormField(
                    controller: _birthDayController,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      _selectedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate:
                            DateTime.now().subtract(const Duration(days: 6210)),
                        initialDate:
                            DateTime.now().subtract(const Duration(days: 6210)),
                      );
                      _birthDayController.text =
                          _selectedDate.toString().split(' ')[0];
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال تاريخ الميلاد";
                      }
                      return null;
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
                            'تسجيل ',
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
