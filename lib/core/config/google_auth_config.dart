/// This MUST be the same Web OAuth client ID as the Laravel backend's
/// GOOGLE_CLIENT_ID — Google issues the ID token with that as its audience
/// only when serverClientId is set to it, and the backend's /auth/google
/// rejects anything else. Override with
/// --dart-define=GOOGLE_SERVER_CLIENT_ID=... if the backend's client ever
/// changes.
const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '380293121851-sbt8d8k41j45dmkgt12vdcd91tjsg9u5.apps.googleusercontent.com',
);
