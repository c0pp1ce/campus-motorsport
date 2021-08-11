import 'package:cloud_functions/cloud_functions.dart';

// Wrapper methods for easy access to firebase cloud functions

/// Tries to add the accepted-Role to the specified user (as custom claim).
/// This function needs to be called after a user has been accepted as well as
/// verified his email.
Future<void> addAcceptedRole(String email) async {
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  try {
    final HttpsCallable callable = functions.httpsCallable('addAcceptedRole');
    await callable.call({'email': email});
  } on Exception catch (e) {
    print(e.toString());
  }
}

/// Tries to retrieve/update the training grounds images.
Future<void> getTrainingGroundsOverview() async {
  final FirebaseFunctions functions = FirebaseFunctions.instance;
  try {
    final HttpsCallable callable =
        functions.httpsCallable('getTrainingGroundsOverviews');
    await callable.call();
  } on Exception catch (e) {
    print(e.toString());
  }
}
