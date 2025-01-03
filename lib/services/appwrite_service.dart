import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  static Client client = Client();
  static late Account account;
  static late Databases databases;
  static late final Storage storage;
  static late final Realtime realtime;

  // Use environment variables
  static String get projectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  static String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
  static String get userCollectionId =>
      dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? '';
  static String get workoutCollectionId =>
      dotenv.env['APPWRITE_WORKOUT_COLLECTION_ID'] ?? '';
  static String get mealsCollectionId =>
      dotenv.env['APPWRITE_MEALS_COLLECTION_ID'] ?? '';

  static void initialize() async {
    // Ensure .env is loaded
    await dotenv.load();

    client
        .setEndpoint(
            dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1')
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
