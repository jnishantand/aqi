import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:getaqi/Services/aqi_log_service.dart';
import 'package:getaqi/extras/appColors.dart';
import 'package:getaqi/extras/appPath.dart';
import 'package:getaqi/features/sensor_read/sensorController.dart';
import 'package:getaqi/l10n/app_localizations.dart';
import 'package:getaqi/providers/aqiProvides/aqiProviders.dart';
import 'package:getaqi/providers/providers.dart';
import 'package:getaqi/ui/news/news.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AI Suggestion Provider with DeepSeek API (FREE)
final aiSuggestionProvider = FutureProvider.autoDispose.family<String, Map<String, dynamic>>((
  ref,
  params,
) async {
  final city = params['city'];
  final aqi = params['aqi'];
  final level = params['level'];

  // SECURE: Load from environment variables
  final apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
    return ' API key not configured. Please add DEEPSEEK_API_KEY to .env file';
  }

  try {
    final response = await http.post(
      Uri.parse('https://api.deepseek.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
      body: json.encode({
        'model': 'deepseek-chat',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a health and environmental expert. Provide concise, actionable AQI-based health recommendations. Format as 3-4 bullet points without markdown.',
          },
          {
            'role': 'user',
            'content':
                'The Air Quality Index in $city is $aqi which is "$level" level. Provide specific health recommendations for this air quality level. Be practical and helpful.',
          },
        ],
        'max_tokens': 150,
        'temperature': 0.7,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'];
      }
      return 'No suggestions available.';
    } else if (response.statusCode == 401) {
      return 'Invalid API key. Please check your DeepSeek API key.';
    } else if (response.statusCode == 429) {
      return 'Rate limit reached. Free tier allows ~100 requests per hour.';
    } else {
      return 'Unable to fetch AI suggestions (Error: ${response.statusCode}).';
    }
  } catch (e) {
    return 'Connection error. Please check your internet.';
  }
});

// Continuous monitoring provider
final monitoredCitiesProvider = StateProvider<List<String>>((ref) => []);
final monitoringIntervalProvider = StateProvider<int>((ref) => 300);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String city = '';
  Timer? _monitoringTimer;
  final Map<String, String> _citySuggestions = {};

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        ref.read(monitoredCitiesProvider.notifier).state = [
          ...ref.read(monitoredCitiesProvider),
        ];
      }
    });
  }

  String _getAqiLevel(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  String _getAqiDescription(double aqi) {
    if (aqi <= 50) return 'Air quality is satisfactory';
    if (aqi <= 100) return 'Air quality is acceptable';
    if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects';
    }
    if (aqi <= 200) return 'Everyone may begin to experience health effects';
    if (aqi <= 300) {
      return 'Health alert: everyone may experience more serious health effects';
    }
    return 'Health warning of emergency conditions';
  }

  Future<void> _fetchAISuggestion(String cityName, double aqi) async {
    final level = _getAqiLevel(aqi);
    final params = {
      'city': cityName,
      'aqi': aqi.toStringAsFixed(0),
      'level': level,
    };

    try {
      final suggestion = await ref.read(aiSuggestionProvider(params).future);
      setState(() {
        _citySuggestions[cityName] = suggestion;
      });
    } catch (e) {
      print('Error fetching AI suggestion: $e');
      setState(() {
        _citySuggestions[cityName] =
            'Failed to load suggestions. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dashboard,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Consumer(
          builder: (c, r, _) {
            final mode = r.watch(themeProvider);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mode == ThemeMode.dark
                        ? Colors.black
                        : AppColors.primaryColor,
                    mode == ThemeMode.dark
                        ? Colors.black
                        : AppColors.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(monitoredCitiesProvider.notifier).state = [
                ...ref.read(monitoredCitiesProvider),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
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
            _sectionTitle("Monitored Cities"),
            const SizedBox(height: 10),
            _monitoredCitiesList(),
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

  Widget _buildDrawer() {
    return Consumer(
      builder: (c, r, _) {
        final themeMode = r.watch(themeProvider);
        final userState = r.watch(authStateProvider);

        final user = userState.value;

        return Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeMode == ThemeMode.dark
                      ? Colors.black
                      : AppColors.primaryColor.withOpacity(0.95),
                  themeMode == ThemeMode.dark
                      ? Colors.black
                      : AppColors.secondaryColor.withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Drawer Header with User Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user == null ? 'Guest User' : user.email.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),
                        if (user == null)
                          Text(
                            'Sign in to access more features',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),

                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (user == null) {
                              context.push(AppPath.login);
                            } else {
                              await FirebaseAuth.instance.signOut();
                            }
                          },
                          child: Text(
                            user == null ? 'Login' : "Logout",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white30, thickness: 1),

                  // Drawer Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          icon: Icons.dashboard,
                          title: AppLocalizations.of(context)!.dashboard,
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to dashboard if needed
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.location_city,
                          title: AppLocalizations.of(context)!.monitoredCities,
                          onTap: () {
                            Navigator.pop(context);
                            // Scroll to monitored cities section
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.location_city,
                          title: "Image Process",
                          onTap: () {
                            Navigator.pop(context);
                            // Scroll to monitored cities section
                            context.push(AppPath.imageProcess);
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.article,
                          title: AppLocalizations.of(context)!.aqiNews,
                          onTap: () {
                            Navigator.pop(context);

                            context.push(AppPath.news);
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.psychology,
                          title: AppLocalizations.of(
                            context,
                          )!.aiRecommendations,
                          onTap: () {
                            Navigator.pop(context);
                            // Show AI recommendations
                          },
                        ),

                        const Divider(color: Colors.white30, thickness: 1),

                        _buildDrawerItem(
                          icon: Icons.person,
                          title: AppLocalizations.of(context)!.profile,
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppPath.profile);
                          },
                        ),

                        const Divider(color: Colors.white30, thickness: 1),

                        _buildDrawerItem(
                          icon: Icons.settings,
                          title: AppLocalizations.of(context)!.settings,
                          onTap: () {
                            context.push(AppPath.setting);
                            Navigator.pop(context);
                            // Navigate to settings
                          },
                        ),

                        _buildDrawerItem(
                          icon: Icons.help,
                          title: AppLocalizations.of(context)!.helpSupport,
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to help
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.money,
                          title: "Tax 80g calculator",
                          onTap: () {
                            context.push(AppPath.tax80GScreen);
                            Navigator.pop(context);
                            // Navigate to help
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.description,
                          title: "AQI Logs",
                          onTap: () {
                            context.push(AppPath.logScreen);
                            Navigator.pop(context);
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.description,
                          title: "Sensor Data",
                          onTap: () {
                            context.push(AppPath.sensorScreen);
                            Navigator.pop(context);
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.info,
                          title: AppLocalizations.of(context)!.about,
                          onTap: () {
                            Navigator.pop(context);
                            // Show about dialog
                          },
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2024 AQI Checker',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  dynamic _openSetting() async {
    final channel = MethodChannel("open_settings");
    final bool isWifi = await channel.invokeMethod("openNetworkSettings");
    if (isWifi) {
      print("----->on");
    } else {
      print("----->offf");
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primaryColor : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _searchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final newCity = _controller.text.trim();
                if (newCity.isNotEmpty) {
                  setState(() {
                    city = newCity;
                  });

                  final aqiData = await ref.read(aqiProvider(newCity).future);

                  final aqi = aqiData.aqi.toDouble();
                  final level = _getAqiLevel(aqi);

                  await LogService.writeLog(
                    city: newCity,
                    aqi: aqi,
                    level: level,
                  );

                  ref.invalidate(aqiReadprovider);

                  _controller.clear();
                  FocusScope.of(context).unfocus();
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Monitor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainAqiCard() {
    if (city.isEmpty) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'Search a city to see AQI',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Get AI-powered health recommendations',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final aqiAsync = ref.watch(aqiProvider(city));

    return aqiAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                Text(
                  'Error loading AQI for $city',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Please check city name and try again',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) {
        final aqi = data.aqi.toDouble();
        final level = _getAqiLevel(aqi);
        final description = _getAqiDescription(aqi);
        final color = _getAqiColor(aqi);

        // // Fetch AI suggestion if AQI is above moderate
        if (aqi > 100 && !_citySuggestions.containsKey(city)) {
          _fetchAISuggestion(city, aqi);
        }

        return Column(
          children: [
            Card(
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
                    colors: [color.withOpacity(0.9), color],
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
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      aqi.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (aqi > 100) ...[
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // AI Suggestions Card
            if (aqi > 100 && _citySuggestions.containsKey(city))
              _aiSuggestionsCard(city),
          ],
        );
      },
    );
  }

  Widget _aiSuggestionsCard(String cityName) {
    final suggestion = _citySuggestions[cityName] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'AI Health Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(suggestion, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 8),
            const Divider(),
            const Text(
              'Powered by DeepSeek AI',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monitoredCitiesList() {
    final cities = ref.watch(monitoredCitiesProvider);

    if (cities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.location_city_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 10),
                const Text(
                  'No cities being monitored',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  'Add cities to monitor their AQI',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return _monitoredCityCard(cities[index]);
      },
    );
  }

  Widget _monitoredCityCard(String cityName) {
    final aqiAsync = ref.watch(aqiProvider(cityName));
    return aqiAsync.when(
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(cityName),
          subtitle: const Text('Loading AQI...'),
        ),
      ),
      error: (e, _) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: Text(cityName),
          subtitle: const Text('Error loading data'),
        ),
      ),
      data: (data) {
        final aqi = data.aqi.toDouble();
        final level = _getAqiLevel(aqi);
        final color = _getAqiColor(aqi);

        // Trigger AI suggestion if AQI is high
        if (aqi > 100 && !_citySuggestions.containsKey(cityName)) {
          _fetchAISuggestion(cityName, aqi);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  aqi.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(cityName),
            subtitle: Text('AQI: ${aqi.toStringAsFixed(0)} - $level'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aqi > 100)
                  IconButton(
                    icon: Icon(Icons.psychology, color: Colors.blue[700]),
                    onPressed: () {
                      _showAiSuggestionDialog(cityName, aqi);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    ref.read(monitoredCitiesProvider.notifier).state = ref
                        .read(monitoredCitiesProvider)
                        .where((c) => c != cityName)
                        .toList();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAiSuggestionDialog(String cityName, double aqi) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(child: Text('AI Suggestions for $cityName')),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _citySuggestions.containsKey(cityName)
                ? SingleChildScrollView(
                    child: Text(
                      _citySuggestions[cityName]!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Fetching AI suggestions...'),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  final sensorStreamProvider = StreamProvider.autoDispose<double>((ref) {
    return SensorServiceController.sensorStream();
  });

  Widget _cityGrid() {
    final cities = ["Delhi", "Mumbai", "Bhopal", "Pune"];
    final sensorAsync = ref.watch(sensorStreamProvider);

    return sensorAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Sensor error"),
      data: (rotationValue) {
        final angle = rotationValue * 0.05; // reduce intensity

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return Transform.rotate(
              angle: angle,
              child: GetCity(
                city: cities[index],
                onAddToMonitor: () {
                  if (!ref
                      .read(monitoredCitiesProvider)
                      .contains(cities[index])) {
                    ref.read(monitoredCitiesProvider.notifier).state = [
                      ...ref.read(monitoredCitiesProvider),
                      cities[index],
                    ];
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (title == "Monitored Cities")
          Chip(
            label: Text('${ref.watch(monitoredCitiesProvider).length}'),
            backgroundColor: Colors.blue[50],
          ),
      ],
    );
  }
}

class GetCity extends ConsumerWidget {
  final String city;
  final VoidCallback? onAddToMonitor;

  const GetCity({super.key, required this.city, this.onAddToMonitor});

  Color _getAqiColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aqiAsync = ref.watch(aqiProvider(city));
    return aqiAsync.when(
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Icon(Icons.error, color: Colors.red)),
      ),
      data: (data) {
        final aqi = data.aqi.toDouble();

        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getAqiColor(aqi).withOpacity(0.9),
                    _getAqiColor(aqi),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aqi.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getAqiLevel(aqi),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  if (aqi > 100)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.white.withOpacity(0.9),
                ),
                iconSize: 20,
                onPressed: onAddToMonitor,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getAqiLevel(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy';
    if (aqi <= 200) return 'Very Unhealthy';
    if (aqi <= 300) return 'Hazardous';
    return 'Severe';
  }
}
