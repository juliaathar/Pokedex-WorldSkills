import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png',
                width: 300,
                height: 300,
                semanticLabel:
                'Logo do aplicativo. Está escrito "Pokémon" em cor amarela com uma borda azul'),
            SizedBox(
              height: 100,
            ),
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Procurar pokémon',
                  style: TextStyle(color: Color.fromRGBO(156, 5, 0, 1)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PokeSearch()));
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(247, 247, 247, 1)),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(247, 247, 247, 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Lista de pokémons',
                  style: TextStyle(color: Color.fromRGBO(156, 5, 0, 1)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PokeList()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PokeSearch extends StatelessWidget {
  final TextEditingController _pokemonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Encontre seu pokémon aqui!',
          style: TextStyle(color: Color.fromRGBO(247, 247, 247, 1)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png',
                width: 300,
                height: 300,
                semanticLabel:
                'Logo do aplicativo. Está escrito "Pokémon" em cor amarela com uma borda azul'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _pokemonController,
                decoration: InputDecoration(
                  hintText: 'Digite o nome do pokémon',
                  labelText: 'Nome do Pokémon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                        width: 2, color: Color.fromRGBO(156, 5, 0, 1)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Pesquisar pokémon',
                  style: TextStyle(color: Color.fromRGBO(247, 247, 247, 1)),
                ),
              ),
              onPressed: () async {
                String pokemonName = _pokemonController.text.toLowerCase();

                if (pokemonName.isNotEmpty) {
                  try {
                    Map<String, dynamic> pokemonData =
                    await fetchPokemon(pokemonName);
                    String imageUrl = pokemonData['sprites']['front_default'];
                    showPokemonDialog(context, pokemonData, imageUrl);
                  } catch (e) {
                    showErrorDialog(context, 'Pokémon não encontrado.');
                  }
                } else {
                  showErrorDialog(context, 'O campo não pode estar vazio.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PokeList extends StatefulWidget {
  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  List<String> pokemonList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllPokemon();
  }

  Future<void> fetchAllPokemon() async {
    try {
      final response =
      await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/'));

      if (response.statusCode == 200) {
        final List<dynamic> pokemonDataList =
        json.decode(response.body)['results'];
        setState(() {
          pokemonList =
              pokemonDataList.map((pokemon) => pokemon['name'].toString()).toList();
          isLoading = false;
        });
      } else {
        showErrorDialog(context, 'Falha ao carregar a lista de Pokémon.');
      }
    } catch (e) {
      showErrorDialog(
          context, 'Erro inesperado ao carregar a lista de Pokémon.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Nossos pokémons',
          style: TextStyle(color: Color.fromRGBO(247, 247, 247, 1)),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pokemonList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(pokemonList[index]),
              onTap: () async {
                String pokemonName = pokemonList[index].toLowerCase();

                try {
                  Map<String, dynamic> pokemonData =
                  await fetchPokemon(pokemonName);
                  String imageUrl =
                  pokemonData['sprites']['front_default'];
                  showPokemonDialog(context, pokemonData, imageUrl);
                } catch (e) {
                  showErrorDialog(
                      context, 'Falha ao carregar dados do Pokémon.');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// Métodos pra buscar pokémons na API

Future<Map<String, dynamic>> fetchPokemon(String pokemonName) async {
  final response =
  await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Falha ao carregar dados do Pokémon');
  }
}

void showPokemonDialog(
    BuildContext context, Map<String, dynamic> pokemonData, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Detalhes do ${pokemonData['name']}'),
        content: Column(
          children: [
            SizedBox(height: 60),
            Image.network(imageUrl, width: 120, height: 120),
            SizedBox(height: 60),
            Text('Nome: ${pokemonData['name']}'),
            Text('Tipo: ${pokemonData['types'][0]['type']['name']}'),
            Text(
                'Habilidades: ${pokemonData['abilities'].map((ability) => ability['ability']['name']).join(', ')}'),
            Text('Altura: ${pokemonData['height']}'),
            Text('Peso: ${pokemonData['weight']}'),
            Text('Stats:'),
            Column(
              children: pokemonData['stats'].map<Widget>((stat) {
                return Text('${stat['stat']['name']}: ${stat['base_stat']}');
              }).toList(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fechar'),
          ),
        ],
      );
    },
  );
}

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Erro'),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fechar'),
          ),
        ],
      );
    },
  );
}
