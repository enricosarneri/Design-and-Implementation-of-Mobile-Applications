import 'package:event_handler/screens/authenticate/sign_in.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Tutorial extends StatefulWidget {
  Tutorial({Key? key, required this.authServices}) : super(key: key);

  final AuthService authServices;

  //bool isManger = true;
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return WideLayout(
              authServices: widget.authServices,
            );
          } else {
            return NarrowLayout(
              authServices: widget.authServices,
            );
          }
        },
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final AuthService? authServices;
  @override
  NarrowLayout({Key? key, this.authServices}) : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.transparent,
            size: 1,
          ),
          onPressed: () => {},
        ),
        title: const Text(
          'Tutorial',
          style: TextStyle(color: Color(0xFF121B22)),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFF121B22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 80, 10, 12),
          child: IntroductionScreen(
              controlsPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              animationDuration: 1000,
              globalBackgroundColor: Color(0xFF121B22),
              pages: [
                PageViewModel(
                  title: 'Welcome to Book a Place!',
                  body:
                      'Find the event that suits you best or create the perfect one for your public!',
                  footer: SizedBox(
                    height: 45,
                    width: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 8),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignIn(
                                    authServices: widget.authServices!,
                                  )),
                        );
                      },
                      child: const Text("Let's Go!",
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  image: Center(
                    child: Image.asset(
                      'assets/bap.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                  decoration: const PageDecoration(
                    bodyTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                    titleTextStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                PageViewModel(
                    title: 'Join the Events!',
                    body:
                        'Choose the events on the map and ask to partecipate!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text(
                          "Why to Wait!",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    image: Center(
                      child: Image.asset(
                        'assets/NIST_EAB_Story.png',
                        height: 300,
                        width: 300,
                      ),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                PageViewModel(
                    title: 'Get your Qr Code!',
                    body:
                        'Get your own Qr Code and show it at the entrance to make sure to access!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text("Let's Start!",
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    image: Center(
                      child: Image.asset('assets/qr.png'),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                PageViewModel(
                    title: 'Create your Event!',
                    body:
                        'Create a Public or Private event and keep partecipants entertained!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text("Can't Wait!",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                      ),
                    ),
                    image: Center(
                      child: Image.asset('assets/470326.png'),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
              ],
              dotsDecorator: const DotsDecorator(
                size: Size(10, 10),
                color: Color(0xFF8596a0),
                activeSize: Size.square(20),
                activeColor: Colors.white,
              ),
              showDoneButton: true,
              done: const Text(
                'Done',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              showSkipButton: true,
              skip: const Text(
                'Skip',
                style: TextStyle(fontSize: 20),
              ),
              skipColor: Colors.white,
              showNextButton: true,
              next: const Icon(
                Icons.arrow_forward,
                size: 25,
              ),
              nextColor: Colors.white,
              onDone: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignIn(
                            authServices: widget.authServices!,
                          )),
                );
              },
              curve: Curves.easeInOutBack),
        ),
      ),
    );
  }
}

class WideLayout extends StatefulWidget {
  final AuthService? authServices;
  @override
  WideLayout({Key? key, this.authServices}) : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.transparent,
            size: 1,
          ),
          onPressed: () => {},
        ),
        title: const Text(
          'Tutorial',
          style: TextStyle(color: Color(0xFF121B22)),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFF121B22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(300, 80, 300, 12),
          child: IntroductionScreen(
              controlsPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              animationDuration: 1000,
              globalBackgroundColor: Color(0xFF121B22),
              pages: [
                PageViewModel(
                  title: 'Welcome to Book a Place!',
                  body:
                      'Find the event that suits you best or create the perfect one for your public!',
                  footer: SizedBox(
                    height: 45,
                    width: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 8),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignIn(
                                    authServices: widget.authServices!,
                                  )),
                        );
                      },
                      child: const Text("Let's Go!",
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  image: Center(
                    child: Image.asset(
                      'assets/bap.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                  decoration: const PageDecoration(
                    bodyTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                    titleTextStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                PageViewModel(
                    title: 'Join the Events!',
                    body:
                        'Choose the events on the map and ask to partecipate!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text(
                          "Why to Wait!",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    image: Center(
                      child: Image.asset(
                        'assets/NIST_EAB_Story.png',
                        height: 300,
                        width: 300,
                      ),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                PageViewModel(
                    title: 'Get your Qr Code!',
                    body:
                        'Get your own Qr Code and show it at the entrance to make sure to access!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text("Let's Start!",
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    image: Center(
                      child: Image.asset('assets/qr.png'),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                PageViewModel(
                    title: 'Create your Event!',
                    body:
                        'Create a Public or Private event and keep partecipants entertained!',
                    footer: SizedBox(
                      height: 45,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignIn(
                                      authServices: widget.authServices!,
                                    )),
                          );
                        },
                        child: const Text("Can't Wait!",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                      ),
                    ),
                    image: Center(
                      child: Image.asset('assets/470326.png'),
                    ),
                    decoration: const PageDecoration(
                        bodyTextStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        titleTextStyle: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
              ],
              dotsDecorator: const DotsDecorator(
                spacing: EdgeInsets.symmetric(horizontal: 20),
                size: Size(10, 10),
                color: Color(0xFF8596a0),
                activeSize: Size.square(20),
                activeColor: Colors.white,
              ),
              showDoneButton: true,
              done: const Text(
                'Done',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              showSkipButton: true,
              skip: const Text(
                'Skip',
                style: TextStyle(fontSize: 20),
              ),
              skipColor: Colors.white,
              showNextButton: true,
              next: const Icon(
                Icons.arrow_forward,
                size: 25,
              ),
              nextColor: Colors.white,
              onDone: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignIn(
                            authServices: widget.authServices!,
                          )),
                );
              },
              curve: Curves.easeInOutBack),
        ),
      ),
    );
  }
}
