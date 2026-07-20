import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<GoogleSignInAuthentication?> signIn() async {
    final GoogleSignInAccount? account =
        await _googleSignIn.signIn();

    if (account == null) {
      return null;
    }

    final auth = await account.authentication;

    return auth;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}