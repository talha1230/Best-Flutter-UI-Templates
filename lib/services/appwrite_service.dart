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
  static const String mealsCollectionId = 'meals';  // This should be different from workoutCollectionId

  static void initialize() {
    client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }

  // Alternative verification method using getDocument
  static Future<bool> verifyConnection() async {
    try {
      // Try to get a document from the users collection
      await databases.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: 'test',
      );
      print('Successfully connected to Appwrite');
      return true;
    } catch (e) {
      // It's okay if we get a 404 error (document not found)
      // We just want to verify the connection works
      if (e is AppwriteException && e.code != 404) {
        print('Error connecting to Appwrite: $e');
        return false;
      }
      print('Successfully connected to Appwrite');
      return true;
    }
  }
}
