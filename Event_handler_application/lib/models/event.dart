class Event {
  final String managerId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String placeName;
  final String typeOfPlace;
  final String eventType;
  final String date;
  final int maxPartecipants;

  final double price;
  final String eventId;
  int firstFreeQrCode;
  List<String> partecipants = [];
  List<String> applicants = [];
  List<String> qrCodes = [];

  get getQrCodeList => qrCodes;

  get getEventId => eventId;

  get getManagerId => managerId;

  get getName => name;

  get getDescription => description;

  get getLatitude => latitude;

  get getLongitude => longitude;

  get getPlaceName => placeName;

  get getTypeOfPlace => typeOfPlace;

  get getEventType => eventType;

  get getDate => date;

  get getMaxPartecipants => maxPartecipants;

  get getPrice => price;

  get getPartecipantList => partecipants;

  get getApplicantList => applicants;

  Event(
      this.managerId,
      this.name,
      this.description,
      this.latitude,
      this.longitude,
      this.placeName,
      this.typeOfPlace,
      this.eventType,
      this.date,
      this.maxPartecipants,
      this.price,
      this.eventId,
      this.partecipants,
      this.applicants,
      this.qrCodes,
      this.firstFreeQrCode);
}
