import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authenticate {
  FirebaseAuth _auth;

  Authenticate(this._auth);

  // Getting stream of UserCredential.user
  Stream<User?> get authStateChanges => _auth.idTokenChanges();

  //Register with email & password
  Future<String> regWithEmail(String email, String password) async {
    // it will either return a string(uid) or error
    // errors: Null User on user==null else FirebaseAuth error
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        return user.uid;
      } else {
        return Future.error("Null User");
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString()); // print error message
      return Future.error(e.toString());
    }
  }

  //Login with email Password
  Future<String> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        return user.uid;
      } else {
        return Future.error("Null User");
      }
    } catch (e) {
      print(e.toString());
      return Future.error(e.toString());
    }
  }

  //Register with Google Account
  Future<String> regWithGoogle() async {
    // it will return either a string(uid) or error
    // errors: Null User(user==null), User Already Exist(if already in db)
    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    String email = account!.email;
    var signMethods = await _auth.fetchSignInMethodsForEmail(email);
    if (signMethods.isNotEmpty || signMethods.length > 0) {
      await GoogleSignIn().disconnect();
      return Future.error('User Already Exist');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final socialCredential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);
    try {
      UserCredential credential =
          await _auth.signInWithCredential(socialCredential);
      User? user = credential.user;
      if (user != null) {
        return user.uid;
      } else {
        return Future.error("Null User");
      }
    } catch (e) {
      await GoogleSignIn().disconnect();
      print(e.toString());
      return Future.error(e.toString());
    }
  }

  //Login with Google Account
  Future<String> signWithGoogle() async {
    // it will return either a string(uid) or error
    // errors: Null User(user==null), User Not Registered(if not in db)
    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    String email = account!.email;
    var signMethods = await _auth.fetchSignInMethodsForEmail(email);
    if (signMethods.isEmpty || signMethods.length == 0) {
      await GoogleSignIn().disconnect();
      return Future.error('User Not Registered');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final socialCredential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);
    try {
      UserCredential credential =
          await _auth.signInWithCredential(socialCredential);
      User? user = credential.user;
      if (user != null) {
        return user.uid;
      } else {
        return Future.error("Null User");
      }
    } catch (e) {
      await GoogleSignIn().disconnect();
      print(e.toString());
      return Future.error(e.toString());
    }
  }

  //getter
  String getUid() {
    User? user = _auth.currentUser;
    if (user == null) {
      throw ('User is Null');
    }
    return user.uid;
  }

  //signOut

  Future<void> signOut() async {
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print(e);
    }
    await _auth.signOut();
  }
}
