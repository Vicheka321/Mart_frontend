import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<GoogleSignInAuthentication?> signIn() async {
    await _googleSignIn.signOut();

    final account = await _googleSignIn.signIn();

    if (account == null) return null;

    final auth = await account.authentication;

    return auth;
  }
}