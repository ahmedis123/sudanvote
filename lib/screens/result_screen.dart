import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env.dart';

// نموذج البيانات للنتائج
class Result {
  final int candidateId;
  final String candidateName;
  final String partyName;
  final int countVotes;

  Result({
    required this.candidateId,
    required this.candidateName,
    required this.partyName,
    required this.countVotes,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      candidateId: json['CandidateID'],
      candidateName: json['CandidateName'],
      partyName: json['PartyName'],
      countVotes: json['CountVotes'],
    );
  }
}

void main() {
  runApp(const ElectionResultsApp());
}

class ElectionResultsApp extends StatelessWidget {
  const ElectionResultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Election Results',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResultsScreen(),
    );
  }
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // رابط API

  // دالة لجلب البيانات من API
  Future<List<Result>> fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse('$url/election_results/${Edata.electionId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Result.fromJson(json)).toList();
      } else {
        _showMessage(' خطأ في الخادم: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      _showMessage(' تعذر جلب البيانات. تحقق من اتصال الإنترنت.');
      return [];
    }
  }

// دالة لعرض رسالة للمستخدم
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // حساب إجمالي الأصوات
  int getTotalVotes(List<Result> results) {
    return results.fold(0, (sum, result) => sum + result.countVotes);
  }

  // تحديد الفائزين في حالة التعادل
  List<Result> getTopResults(List<Result> results) {
    int maxVotes = results.fold(
        0, (max, result) => result.countVotes > max ? result.countVotes : max);
    return results.where((result) => result.countVotes == maxVotes).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder<List<Result>>(
            future: fetchResults(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('لا توجد نتائج متاحة حالياً.'));
              }

              final results = snapshot.data!;
              final totalVotes = getTotalVotes(results);

              // تحديد الفائزين
              final topCandidates = getTopResults(results);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عرض رسالة الفائز فقط بعد انتهاء الانتخابات
                  if (!Edata.electionDate.end.isAfter(DateTime.now()))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        topCandidates.isEmpty
                            ? 'لا يوجد فائز'
                            : 'الفائز: ${topCandidates.map((candidate) => candidate.candidateName).join(", ")}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final percentage =
                            (result.countVotes / totalVotes) * 100;

                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color:
                              result.countVotes == topCandidates[0].countVotes
                                  ? Colors.green[100]
                                  : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: result.countVotes ==
                                      topCandidates[0].countVotes
                                  ? Colors.green
                                  : Colors.blue,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              result.candidateName,
                              style: TextStyle(
                                fontWeight: result.countVotes ==
                                        topCandidates[0].countVotes
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'الأصوات: ${result.countVotes} (${percentage.toStringAsFixed(1)}%)',
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                color: result.countVotes ==
                                        topCandidates[0].countVotes
                                    ? Colors.green
                                    : Colors.blue,
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'إجمالي الأصوات: $totalVotes\nعدد المرشحين: ${results.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
