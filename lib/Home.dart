import 'package:anotacoes/helper/AnotacaoHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'model/Anotacao.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  var _db = AnotacaoHelper();

  List<Anotacao>? _anotacoes = <Anotacao>[];

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";

    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      _tituloController.text = anotacao.titulo.toString();
      _descricaoController.text = anotacao.descricao.toString();
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${textoSalvarAtualizar} anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Título",
                    hintText: "Digite o título",
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    hintText: "Digite a descrição",
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  setState(() {
                    _recuperarAnotacoes();
                  });

                  Navigator.pop(context);
                },
                child: Text("${textoSalvarAtualizar}"),
              ),
            ],
          );
        });
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) //Salvar
    {
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else //Atualizando
    {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int qtdAtualizado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    setState(() {
      _recuperarAnotacoes();
    });
  }

  _recuperarAnotacoes() async {
    //_anotacoes!.clear();

    List anotacoesRecuperada = await _db.recuperarAnotacoes();

    List<Anotacao>? listaTemporaria = <Anotacao>[];

    for (var item in anotacoesRecuperada) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    _anotacoes = listaTemporaria;
    listaTemporaria = null;

    print("Lista anotacoes: " + anotacoesRecuperada.toString());
  }

  _formatarData(String? data) {
    initializeDateFormatting("pt_BR");
    //var formatador = DateFormat("d/MM/y H:m:s");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data.toString());
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    setState(() {
      _recuperarAnotacoes();
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    _recuperarAnotacoes();
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _anotacoes!.length,
            itemBuilder: (context, index) {
              final anotacao = _anotacoes![index];

              return Card(
                child: ListTile(
                  title: Text(anotacao.titulo.toString()),
                  subtitle: Text(
                      "${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _exibirTelaCadastro(anotacao: anotacao);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _removerAnotacao(anotacao.id!);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
