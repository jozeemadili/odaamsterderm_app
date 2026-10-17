/// This MUST be the same Web OAuth client ID as the Laravel backend's
/// GOOGLE_CLIENT_ID — Google issues the ID token with that as its audience
/// only when serverClientId is set to it, and the backend's /auth/google
/// rejects anything else. Override with
/// --dart-define=GOOGLE_SERVER_CLIENT_ID=... if the backend's client ever
/// changes.
const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '201989877749-s6kaif6n2vlfps0gnhkqkpd0ru7ju3ed.apps.googleusercontent.com',
);
