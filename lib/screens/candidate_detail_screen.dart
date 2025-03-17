import 'package:flutter/material.dart'; // استيراد مكتبة Flutter الأساسية
import '/models/candidate.dart'; // استيراد نموذج بيانات المرشح

import '../env.dart'; // استيراد ملف البيئة الذي يحتوي على متغيرات التطبيق

class CandidateDetailsScreen extends StatelessWidget {
  const CandidateDetailsScreen({
    required this.index, // الفهرس الخاص بالمرشح في القائمة
    required this.candidate, // بيانات المرشح
    super.key, // مفتاح الويدجت (Widget Key)
  });

  final int index; // الفهرس الخاص بالمرشح
  final Candidate candidate; // بيانات المرشح
  final sizeBox = const SizedBox(height: 16); // مسافة عمودية ثابتة

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تحديد اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تفاصيل المرشح"), // عنوان الشاشة
          backgroundColor: Colors.teal, // لون خلفية AppBar
          centerTitle: true, // توسيط العنوان
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0), // إضافة هامش داخلي
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // محاذاة العناصر إلى اليسار
            children: [
              // صورة المرشح (رمزية)
              Center(
                child: CircleAvatar(
                  radius: 50, // نصف قطر الصورة
                  backgroundColor: Colors.teal.shade700, // لون خلفية الصورة
                  child: const Icon(
                    Icons.person, // أيقونة شخص
                    size: 50, // حجم الأيقونة
                    color: Colors.white, // لون الأيقونة
                  ),
                ),
              ),
              const SizedBox(height: 30), // مسافة عمودية

              // عرض تفاصيل المرشح باستخدام وظيفة مساعدة
              _buildDetailText("اسم المرشح:", candidate.candidateName, true),
              sizeBox, // مسافة عمودية
              _buildDetailText("الحزب:", candidate.partyName),
              sizeBox, // مسافة عمودية
              _buildDetailText("السيرة الذاتية:", candidate.biography, true),
              sizeBox, // مسافة عمودية
              _buildDetailText(
                  "البرنامج الانتخابي:", candidate.candidateProgram, true),
              const Spacer(), // توسيع المساحة المتبقية

              // زر التصويت
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _handleVote(context), // التعامل مع الضغط على الزر
                  icon: const Icon(Icons.how_to_vote,
                      color: Colors.white), // أيقونة التصويت
                  label: const Text("تصويت"), // نص الزر
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40), // هامش الزر
                    backgroundColor: Colors.teal, // لون خلفية الزر
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // شكل الزوايا
                    ),
                    elevation: 5, // ارتفاع الزر
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// وظيفة مساعدة لإنشاء نصوص المعلومات بتنسيق ثابت
  Widget _buildDetailText(String title, String content, [bool isBold = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // محاذاة النص إلى اليسار
      children: [
        Text(
          title, // عنوان الحقل
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold), // تنسيق العنوان
        ),
        const SizedBox(height: 5), // مسافة عمودية صغيرة
        Text(
          content, // محتوى الحقل
          style: TextStyle(
            fontSize: 16, // حجم الخط
            fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal, // تحديد سماكة الخط
            color: Colors.black87, // لون النص
          ),
        ),
      ],
    );
  }

  /// وظيفة التعامل مع زر التصويت
  void _handleVote(BuildContext context) {
    // التحقق مما إذا كان الناخب قد صوت بالفعل أو انتهت الانتخابات
    if ((Edata.isInElection
            .toString()
            .contains(Edata.electionId.toString())) ||
        !Edata.electionDate.end.isAfter(DateTime.now())) {
      // عرض مربع حوار تنبيه
      showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl, // تحديد اتجاه النص
            child: AlertDialog(
              title: const Text("تنبيه"), // عنوان مربع الحوار
              content: const Text(
                  "لقد صوت الناخب بالفعل أو انتهت الانتخابات."), // محتوى مربع الحوار
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // إغلاق مربع الحوار
                  child: const Text("حسناً"), // نص الزر
                ),
              ],
            ),
          );
        },
      );
    } else {
      // الانتقال إلى شاشة التصويت
      Navigator.pushNamed(context, '/vote');
    }
  }
}
