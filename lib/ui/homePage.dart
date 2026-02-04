import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/providers/aqiProvides/aqiProviders.dart';
import 'package:getaqi/ui/news/news.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String city = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AQI Checker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchCard(),
            const SizedBox(height: 20),
            _mainAqiCard(),
            const SizedBox(height: 30),
            _sectionTitle("Live Cities"),
            const SizedBox(height: 10),
            _cityGrid(),
            const SizedBox(height: 30),
            _sectionTitle("AQI News"),
            const SizedBox(height: 10),
            const AqiNewsWidget(),
          ],
        ),
      ),
    );
  }

  // ---------------- SEARCH ----------------
  Widget _searchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  city = _controller.text.trim();
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MAIN AQI ----------------
  Widget _mainAqiCard() {
    if (city.isEmpty) {
      return const Center(
        child: Text('Search a city to see AQI'),
      );
    }

    final aqiAsync = ref.watch(aqiProvider(city));

    return aqiAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  data.city,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.aqi.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Air Quality Index',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- CITY GRID ----------------
  Widget _cityGrid() {
    final cities = ["Delhi", "Mumbai", "Bhopal", "Pune"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return GetCity(city: cities[index]);
      },
    );
  }

  // ---------------- TITLE ----------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ================= CITY CARD =================

class GetCity extends ConsumerWidget {
  final String city;

  const GetCity({super.key, required this.city});

  Color getAqiColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 200) return Colors.orange;
    if (aqi <= 300) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aqiAsync = ref.watch(aqiProvider(city));

    return aqiAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Error')),
      data: (data) {
        final aqi = data.aqi.toDouble();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                getAqiColor(aqi).withOpacity(0.85),
                getAqiColor(aqi),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                city,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                aqi.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
