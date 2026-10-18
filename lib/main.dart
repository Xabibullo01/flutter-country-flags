import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: "API Darsimiz!",
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        setState(() {
          countries = jsonDecode(response.body);
          filteredCountries = countries;
        });
      } else {
        throw Exception("Ma'lumotlarni olishda xatolik yuz berdi: ${response.statusCode}");
      }
    } catch (error) {
      print("Xatolik yuz berdi: $error");
    }
  }

  void filterCountries(String query) {
    List<dynamic> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = countries.where((country) {
        final countryName = country['name']['common'].toString().toLowerCase();
        return countryName.contains(query.toLowerCase());
      }).toList();
    } else {
      filteredList = countries;
    }
    setState(() {
      filteredCountries = filteredList;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Davlat Bayroqlari"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterCountries(value);
              },
              decoration: InputDecoration(
                labelText: 'Qidiruv',
                hintText: 'Davlat nomini kiriting',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                return ListTile(
                  leading: Image.network(country['flags']['png']),
                  title: Text(country['name']['common']),
                  subtitle: Text(country['name']['official']),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(country['name']['common']),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rasm:"),
                              Image.network(country['flags']['png']),
                              SizedBox(height: 8),
                              Text("Rasmiy nomi: ${country['name']['official']}"),
                              Text("Iso kodi: ${country['cca2']}"),
                              Text("Paytdagi ismi: ${country['demonyms']['eng']['official']}"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Yopish'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
