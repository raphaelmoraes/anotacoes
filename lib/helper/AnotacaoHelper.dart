import 'package:anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static final String nomeTabela = "Anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        "CREATE TABLE anotacao (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoBD = await getDatabasesPath();
    final localBancoDados = join(caminhoBD, "anotacoes.db");

    var db = await openDatabase(
      localBancoDados,
      version: 1,
      onCreate: _onCreate,
    );

    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;

    int id = await bancoDados.insert(
      nomeTabela,
      anotacao.toMap(),
    );

    return id;
  }
}
