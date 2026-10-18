import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// restcountries.com v3.1 eskirgan, v5 esa API kalit talab qiladi.
// Shuning uchun kalitsiz ochiq manbalardan foydalanamiz.
const countriesUrl =
    'https://raw.githubusercontent.com/mledoze/countries/master/countries.json';

String flagUrl(String cca2) =>
    'https://flagcdn.com/w320/${cca2.toLowerCase()}.png';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Davlat Bayroqlari',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class Country {
  final String name;
  final String officialName;
  final String cca2;
  final String? demonym;

  Country({
    required this.name,
    required this.officialName,
    required this.cca2,
    this.demonym,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']?['common'] ?? '',
      officialName: json['name']?['official'] ?? '',
      cca2: json['cca2'] ?? '',
      demonym: json['demonyms']?['eng']?['m'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Country> countries = [];
  List<Country> filteredCountries = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse(countriesUrl));
      if (response.statusCode != 200) {
        throw Exception('Server javobi: ${response.statusCode}');
      }
      final List<dynamic> data = jsonDecode(response.body);
      final list = data
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .where((c) => c.name.isNotEmpty && c.cca2.isNotEmpty)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        countries = list;
        isLoading = false;
      });
      filterCountries(searchController.text);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Ma'lumotlarni yuklab bo'lmadi. Internetni tekshiring.";
      });
    }
  }

  void filterCountries(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      filteredCountries = q.isEmpty
          ? countries
          : countries.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  Widget flagImage(String cca2, {double? width}) {
    return Image.network(
      flagUrl(cca2),
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.flag_outlined, color: Colors.grey),
    );
  }

  void showCountryDialog(Country country) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(country.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                flagImage(country.cca2),
                const SizedBox(height: 8),
                Text("Rasmiy nomi: ${country.officialName}"),
                Text("ISO kodi: ${country.cca2}"),
                Text("Aholisi qanday ataladi: ${country.demonym ?? "Noma'lum"}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Yopish'),
            ),
          ],
        );
      },
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: fetchCountries,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }
    if (filteredCountries.isEmpty) {
      return const Center(child: Text('Hech narsa topilmadi'));
    }
    return ListView.builder(
      itemCount: filteredCountries.length,
      itemBuilder: (context, index) {
        final country = filteredCountries[index];
        return ListTile(
          leading: SizedBox(width: 56, child: flagImage(country.cca2, width: 56)),
          title: Text(country.name),
          subtitle: Text(country.officialName),
          onTap: () => showCountryDialog(country),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Davlat Bayroqlari"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterCountries,
              decoration: const InputDecoration(
                labelText: 'Qidiruv',
                hintText: 'Davlat nomini kiriting',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: buildBody()),
        ],
      ),
    );
  }
}
