class TutorialFaq {
  final String question;
  final String answer;
  final String? relatedFlowId;

  TutorialFaq({
    required this.question,
    required this.answer,
    this.relatedFlowId,
  });

  factory TutorialFaq.fromMap(Map<String, dynamic> map) {
    return TutorialFaq(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      relatedFlowId: map['related_flow_id'],
    );
  }
}