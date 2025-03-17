import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/models/admin.dart';
import '/screens/admin_screen.dart';
import '../env.dart';

class AdminsListTile extends StatefulWidget {
  const AdminsListTile({super.key, required this.admin});
  final Admin admin;

  @override
  State<AdminsListTile> createState() => _AdminsListTileState();
}

class _AdminsListTileState extends State<AdminsListTile> {
  bool _isLoading = false;
  Future<void> deleteData() async {
    try {
      setState(() {
        _isLoading = true; // إظهار مؤشر التحميل
      });
      final response = await http
          .delete(Uri.parse('$url/admin/${widget.admin.adminID}'), headers: {
        'Content-Type': 'application/json',
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
        Edata.initTabController = 2;
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
      padding: const EdgeInsets.only(top: 20),
      child: ListTile(
        leading: const Icon(
          Icons.admin_panel_settings,
          size: 40,
          color: Colors.teal,
        ),
        title: Text(widget.admin.name),
        subtitle: Text(widget.admin.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // منطق التعديل
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AdminScreen(
                    admin: widget.admin,
                    isFroEdite: true,
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              title: const Text("تأكيد الحذف"),
                              content:
                                  const Text("هل أنت متأكد من حذف هذا المدير؟"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
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
