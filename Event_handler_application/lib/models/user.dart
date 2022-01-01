class AppUser {
  final String uid;
  final String email;
   String name='';
   String surname='';
   String password='';
   bool isOwner=false;
  
  get getUid => uid;


  get getEmail => email;


  get getName => name;


  get getSurname => surname;


  get getPassword => password;


  get getIsOwner => isOwner;

  //const AppUser (this.uid, this.email, this.name, this.surname, this.password,this.isOwner );
  AppUser (this.uid, this.email);
  AppUser.fromAppUser(this.uid, this.email, this.name, this.surname, this.password, this.isOwner);
}