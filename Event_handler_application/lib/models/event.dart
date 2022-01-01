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
  final String eventId;
  List<String> partecipantList=[];
  List<String> applicantsList=[];
  List<String> qrCodeList=[];

  get getQrCodeList => qrCodeList;

  get getEventId => eventId;


  get getManagerId => managerId;


  get getName => name;


  get getDescription => description;


  get getLatitude => latitude;


  get getLongitude => longitude;


  get getPlaceName => placeName;


  get getEventType => eventType;


  get getDate => date;


  get getMaxPartecipants => maxPartecipants;


  get getPartecipantList => partecipantList;


  get getApplicantList => applicantsList;

 

  Event(this.managerId, this.name, this.description, this.latitude, this.longitude, this.placeName,this.eventType,this.date, this.maxPartecipants, this.eventId);
}