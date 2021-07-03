class Anotacao {
  int id;
  String titulo;
  String descricao;
  String data;

  Anotacao(
    this.id,
    this.titulo,
    this.descricao,
    this.data,
  );

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data,
    };

    if (this.id != 0) {
      map["id"] = this.id;
    }

    return map;
  }
}
