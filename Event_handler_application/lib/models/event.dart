class Event{
  final String managerId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String placeName;
  final String eventType;
  final String date;
  final int maxPartecipants;

  get getManagerId => this.managerId;


  get getName => this.name;


  get getDescription => this.description;


  get getLatitude => this.latitude;


  get getLongitude => this.longitude;


  get getPlaceName => this.placeName;


  get getEventType => this.eventType;


  get getDate => this.date;


  get getMaxPartecipants => this.maxPartecipants;

  Event(this.managerId, this.name, this.description, this.latitude, this.longitude, this.placeName,this.eventType,this.date, this.maxPartecipants);
}