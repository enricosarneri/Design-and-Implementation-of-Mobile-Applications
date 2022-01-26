class Event {
  final String managerId;
  final String name;
  final String urlImage;
  final String description;
  final double latitude;
  final double longitude;
  final String placeName;
  final String typeOfPlace;
  final String eventType;
  final String dateBegin;
  final String dateEnd;
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
  get getUrlImage => urlImage;
  get getDescription => description;

  get getLatitude => latitude;

  get getLongitude => longitude;

  get getPlaceName => placeName;

  get getTypeOfPlace => typeOfPlace;

  get getEventType => eventType;

  get getDateBegin => dateBegin;

  get getDateEnd => dateEnd;

  get getMaxPartecipants => maxPartecipants;

  get getPrice => price;

  get getPartecipantList => partecipants;

  get getApplicantList => applicants;

  Event(
      this.managerId,
      this.name,
      this.urlImage,
      this.description,
      this.latitude,
      this.longitude,
      this.placeName,
      this.typeOfPlace,
      this.eventType,
      this.dateBegin,
      this.dateEnd,
      this.maxPartecipants,
      this.price,
      this.eventId,
      this.partecipants,
      this.applicants,
      this.qrCodes,
      this.firstFreeQrCode);
}
