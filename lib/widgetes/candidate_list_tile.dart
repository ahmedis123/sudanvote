import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/screens/candidate_screen.dart';
import '../env.dart';
import '../models/candidate.dart';

// شاشة المرشحين
class CandidatesListTile extends StatefulWidget {
  const CandidatesListTile({super.key, required this.candidate});

  final Candidate candidate;

  @override
  State<CandidatesListTile> createState() => _CandidatesListTileState();
}

class _CandidatesListTileState extends State<CandidatesListTile> {
  bool _isLoading = false;
  Future<void> deleteData() async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final response = await http.delete(
          Uri.parse('$url/candidates/${widget.candidate.candidateID}'),
          headers: {
            'Content-Type': 'application/json', // إذا كان لديك توكن
          });
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("تم حذف البينات بنجاح."),
              backgroundColor: Colors.teal),
        );
        // العودة إلى الصفحة السابقة بعد النجاح
        Edata.initTabController = 0;
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', ModalRoute.withName('/'));
      } else {
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('خطأ'),
              content: Text("فشل في الحذف: ${response.reasonPhrase}"),
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
            content: Text("خطأ أثناء الحذف: $e"),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ListTile(
        isThreeLine: true,
        leading: const Icon(
          Icons.person,
          size: 40,
          color: Colors.teal,
        ),
        title: Text(widget.candidate.candidateName),
        subtitle: Text('الرقم الوطني ${widget.candidate.nationalID}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // منطق التعديل
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CandidateScreen(
                    isFroEdite: true,
                    candidate: widget.candidate,
                  ),
                ));
              },
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // منطق الحذف
                      // تأكيد الحذف

                      showDialog(
                        context: context,
                        builder: (context) {
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              title: const Text("تأكيد الحذف"),
                              content:
                                  const Text("هل أنت متأكد من حذف هذا المرشح؟"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("إلغاء"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await deleteData();
                                  },
                                  child: const Text("حذف"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
