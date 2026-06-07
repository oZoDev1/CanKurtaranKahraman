import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_kids.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6, // Modül 4 PNG görselleri için versiyon artırıldı
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Her güncellemede tabloları sıfırdan oluştur
    await db.execute('DROP TABLE IF EXISTS ordering_items');
    await db.execute('DROP TABLE IF EXISTS options');
    await db.execute('DROP TABLE IF EXISTS questions');
    await db.execute('DROP TABLE IF EXISTS quiz_groups');
    await _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    const boolNullType = 'BOOLEAN';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE questions (
        id $idType,
        type $textType,
        question_text $textType,
        correct_answer_bool $boolNullType,
        explanation $textNullType,
        quiz_group_id $integerType,
        order_in_quiz $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE options (
        id $idType,
        question_id $integerType,
        option_text $textType,
        is_correct $boolType,
        image_path $textNullType
      )
    ''');

    await db.execute('''
      CREATE TABLE ordering_items (
        id $idType,
        question_id $integerType,
        item_text $textType,
        drag_image_path $textNullType,
        drop_image_path $textNullType,
        correct_order $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_groups (
        id $idType,
        title $textType,
        description $textType,
        total_questions $integerType
      )
    ''');

    await SeedData.insertInitialData(db);
  }
}
