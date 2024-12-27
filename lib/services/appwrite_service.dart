import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client();
  static late final Account account;
  static late final Databases databases;
  static late final Storage storage;
  static late final Realtime realtime;

  // Update these with your Appwrite details
  static const String databaseId = "676e4e2d001f67247820"; // Update this
  static const String userCollectionId = "676e61ed00335448c959"; // Update this
  static const String workoutCollectionId = "676e628c00139ebb5f8c"; // Update this
  static const String mealsCollectionId = "676e631d002e71aba841"; // Update this

  static void initialize() {
    client
      .setEndpoint('https://cloud.appwrite.io/v1')  // Verify this endpoint
      .setProject('676e44ed001c5c1424fc')  // Verify this is your project ID
      .setSelfSigned(status: true); // Add this for development

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }
}
