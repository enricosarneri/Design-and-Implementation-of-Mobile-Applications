class AppUser {
  final String uid;
  final String email;
   String name='';
   String surname='';
   String password='';
   bool isOwner=false;
  
  get getUid => this.uid;


  get getEmail => this.email;


  get getName => this.name;


  get getSurname => this.surname;


  get getPassword => this.password;


  get getIsOwner => this.isOwner;

  //const AppUser (this.uid, this.email, this.name, this.surname, this.password,this.isOwner );
  AppUser (this.uid, this.email);
  AppUser.fromAppUser(this.uid, this.email, this.name, this.surname, this.password, this.isOwner);
}