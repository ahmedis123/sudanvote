class Candidate {
  final int candidateID, electionID;
  final String candidateName,
      nationalID,
      partyName,
      biography,
      candidateProgram;

  Candidate(
      {required this.candidateID,
      required this.candidateName,
      required this.nationalID,
      required this.partyName,
      required this.biography,
      required this.electionID,
      required this.candidateProgram});

  // دالة لتحويل البيانات من JSON إلى كائن Candidate
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
        candidateName: json['CandidateName'],
        partyName: json['PartyName'],
        candidateProgram: json['CandidateProgram'],
        candidateID: json['CandidateID'],
        nationalID: json['NationalID'],
        biography: json['Biography'],
        electionID: json['ElectionID']);
  }
}
