class Vote {
  final int voteID, elctionID, candidateID, voterID;
  final String elctionDate;

  Vote(
      {required this.voteID,
      required this.elctionID,
      required this.voterID,
      required this.candidateID,
      required this.elctionDate});
}
