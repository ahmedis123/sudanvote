class Result {
  final int resultID, countVotes, candidateID, elctionID;
  final String resultDate;

  Result(
      {required this.resultID,
      required this.countVotes,
      required this.candidateID,
      required this.elctionID,
      required this.resultDate});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        resultID: json['ResultID'],
        countVotes: json['CountVotes'],
        candidateID: json['CandidateID'],
        elctionID: json['ElectionID'],
        resultDate: json['ResultDate']);
  }
}
