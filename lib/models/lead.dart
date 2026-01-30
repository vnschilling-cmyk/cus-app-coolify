class Lead {
  final String id;
  final String name;
  final String company;
  final String? country;
  final String clientType;
  final String? waterloopAdvantages;
  final String? waterloopConcerns;
  final String? regulationHandling;
  final String? regulationPositiveFeedback;
  final String? regulationCriticismWishes;
  final String? coolingTechFeedback;
  final String? coolingTechAdvantages;
  final String? coolingTechFollowup;
  final String? energyEfficiencyPriority;
  final String? energyEfficiencyComment;
  final String? projectChance;
  final String? followUp;
  final String? eventId;
  final int? year;
  final String? responsible;

  Lead({
    required this.id,
    required this.name,
    required this.company,
    this.country,
    required this.clientType,
    this.waterloopAdvantages,
    this.waterloopConcerns,
    this.regulationHandling,
    this.regulationPositiveFeedback,
    this.regulationCriticismWishes,
    this.coolingTechFeedback,
    this.coolingTechAdvantages,
    this.coolingTechFollowup,
    this.energyEfficiencyPriority,
    this.energyEfficiencyComment,
    this.projectChance,
    this.followUp,
    this.eventId,
    this.year,
    this.responsible,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      company: json['company'],
      country: json['country'],
      clientType: json['client_type'],
      waterloopAdvantages: json['waterloop_advantages'],
      waterloopConcerns: json['waterloop_concerns'],
      regulationHandling: json['regulation_handling'],
      regulationPositiveFeedback: json['regulation_positive_feedback'],
      regulationCriticismWishes: json['regulation_criticism_wishes'],
      coolingTechFeedback: json['cooling_tech_feedback'],
      coolingTechAdvantages: json['cooling_tech_advantages'],
      coolingTechFollowup: json['cooling_tech_followup'],
      energyEfficiencyPriority: json['energy_efficiency_priority'],
      energyEfficiencyComment: json['energy_efficiency_comment'],
      projectChance: json['project_chance'],
      followUp: json['follow_up'],
      eventId: json['event_id'],
      year: json['year'],
      responsible: json['responsible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'country': country,
      'client_type': clientType,
      'waterloop_advantages': waterloopAdvantages,
      'waterloop_concerns': waterloopConcerns,
      'regulation_handling': regulationHandling,
      'regulation_positive_feedback': regulationPositiveFeedback,
      'regulation_criticism_wishes': regulationCriticismWishes,
      'cooling_tech_feedback': coolingTechFeedback,
      'cooling_tech_advantages': coolingTechAdvantages,
      'cooling_tech_followup': coolingTechFollowup,
      'energy_efficiency_priority': energyEfficiencyPriority,
      'energy_efficiency_comment': energyEfficiencyComment,
      'project_chance': projectChance,
      'follow_up': followUp,
      'event_id': eventId,
      'year': year,
      'responsible': responsible,
    };
  }
}
