class Event{
  final String managerId;
  final String name;
  final String description;
  final String latitude;
  final String longitude;
  final String placeName;
  final String eventType;
  final String date;
  final int maxPartecipants;

  Event(this.managerId, this.name, this.description, this.latitude, this.longitude, this.placeName,this.eventType,this.date, this.maxPartecipants);
}