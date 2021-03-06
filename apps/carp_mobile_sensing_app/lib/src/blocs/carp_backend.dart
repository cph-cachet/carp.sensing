part of mobile_sensing_app;

class CarpBackend {
  static const String PROD_URI = "https://cans.cachet.dk:443";
  static const String STAGING_URI = "https://cans.cachet.dk:443/stage";
  // static const String TEST_URI = "https://cans.cachet.dk:443/test"; // The testing server
  // static const String DEV_URI = "https://cans.cachet.dk:443/dev"; // The development server
  static const String CLIENT_ID = "carp";
  static const String CLIENT_SECRET = "carp";

  CarpApp _app;

  /// The signed in user
  CarpUser get user => CarpService().currentUser;
  String get username => CarpService().currentUser.username;

  static CarpBackend _instance = CarpBackend._();
  CarpBackend._() : super();

  factory CarpBackend() => _instance;

  String get uri => (bloc.deploymentMode == DeploymentMode.CARP_PRODUCTION)
      ? PROD_URI
      : STAGING_URI;

  String get name => (bloc.deploymentMode == DeploymentMode.CARP_PRODUCTION)
      ? "CANS Production @ DTU"
      : "CANS Staging @ DTU";

  CarpApp get app => _app;

  Future initialize() async {
    _app = CarpApp(
      name: name,
      uri: Uri.parse(uri),
      oauth: OAuthEndPoint(clientID: CLIENT_ID, clientSecret: CLIENT_SECRET),
    );

    // configure and authenticate
    CarpService().configure(app);
    // await CarpService().authenticate(username: username, password: password);

    info('$runtimeType initialized');
  }

  /// Authenticate the user using the username / password dialogue.
  Future<void> authenticate(BuildContext context) async {
    info('Authenticating user...');
    await CarpService().authenticateWithDialog(context);
    info('User authenticated - user: $user');

    // configure the participation service in order to get the invitations
    CarpParticipationService().configureFrom(CarpService());
  }

  /// Get the study invitation.
  Future<void> getStudyInvitation(BuildContext context) async {
    ActiveParticipationInvitation _invitation =
        await CarpParticipationService().getStudyInvitation(context);
    debug('CARP Study Invitation: $_invitation');

    bloc.studyDeploymentId = _invitation?.studyDeploymentId;
    info('Deployment ID: ${bloc.studyDeploymentId}');
  }
}
