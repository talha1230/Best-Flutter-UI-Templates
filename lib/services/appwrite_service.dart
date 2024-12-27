import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client();
  static late final Account account;
  static late final Databases databases;
  static late final Storage storage;
  static late final Realtime realtime;

  // Update these with your Appwrite details
  static const String databaseId = "your_database_id";
  static const String userCollectionId = "users";
  static const String workoutCollectionId = "workouts";
  static const String mealsCollectionId = "meals";

  static void initialize() {
    client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('676e44ed001c5c1424fc'); // Your project ID

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }
}
