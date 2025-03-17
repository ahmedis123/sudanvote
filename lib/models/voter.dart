class Voter {
  final int nationalID;
  final String voterID, voterName, state, gender, email, password;
  final DateTime dateOfBirth;
  final bool hasVoted;

  Voter(
      {required this.voterID,
      required this.nationalID,
      required this.voterName,
      required this.state,
      required this.hasVoted,
      required this.email,
      required this.dateOfBirth,
      required this.gender,
      required this.password});
}
