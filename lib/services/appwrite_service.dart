import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static Client client = Client();
  static late Account account;
  static late Databases databases;
  static late final Storage storage;
  static late final Realtime realtime;

  // Update these constants with the exact IDs from your Appwrite console
  static const String projectId = '676e44ed001c5c1424fc';
  static const String databaseId = '676e4e2d001f67247820';
  static const String userCollectionId = 'user_profiles';  // Update this
  static const String workoutCollectionId = '676e628c00139ebb5f8c';
  static const String mealsCollectionId = 'meals';  // Verify this matches exactly what you created

  static void initialize() {
    client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }
}
