import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/ui/auth/login.dart';
import 'package:sanpo/ui/dog/dog_show.dart';
import 'package:sanpo/ui/schedule/schedule_index.dart';
import 'package:sanpo/ui/schedule/schedule_show.dart';
import 'package:sanpo/ui/user/profile_edit.dart';
import 'package:sanpo/ui/user/user.dart';

import 'firebase_options.dart';
import 'tabs_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    useEffect(() {
      if (authState.asData?.value != null) {
        final user = authState.asData!.value;
        if (user != null) {
          firestoreService.getUser(user.uid).then((userModel) {
            if (userModel != null && userModel.dogs.isNotEmpty) {
              final dogId = userModel.dogs[0];
              firestoreService.getDogById(dogId).then((dog) {
                if (dog != null) {
                  ref.read(selectedDogProvider.notifier).state = dog;
                }
              });
            }
          });
        }
      }
      return null;
    }, [authState]);
    return MaterialApp(
      title: 'Firebase Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
      },
      navigatorObservers: <NavigatorObserver>[observer],
      home: authState.when(
        data: (user) => user != null
            ? HomePage(
                analytics: analytics,
                observer: observer,
              )
            : const LoginPage(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.analytics,
    required this.observer,
  });

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<PreferredSizeWidget> _appBars = [
    HomeAppBar(),
    DogAppBar(),
    UserAppBar(),
  ];
  final List<Widget> _pages = [
    ScheduleIndexPage(),
    DogDetailPage(),
    UserDetailPage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBars[_selectedIndex],
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<TabsPage>(
              settings: const RouteSettings(name: TabsPage.routeName),
              builder: (BuildContext context) {
                return TabsPage(widget.observer);
              },
            ),
          );
        },
        child: const Icon(Icons.tab),
        heroTag: 'dog_index_fab',
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });
  void showBottomSheetDemo(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 700,
          width: MediaQuery.sizeOf(context).width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '犬：',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '日にち：',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ユーザー：',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      '検索',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.abc,
            size: 48,
          ),
          Text(
            'home',
            style: TextStyle(fontSize: 24),
          ),
          InkWell(
            onTap: () {
              showBottomSheetDemo(context);
            },
            child: Icon(
              Icons.search,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class DateAndWeather extends StatelessWidget {
  const DateAndWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).primaryColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '5月14日',
            style: TextStyle(fontSize: 32),
          ),
          Row(
            children: [
              Column(
                children: [
                  Text('6'),
                  Icon(
                    Icons.sunny,
                    size: 48,
                  ),
                ],
              ),
              SizedBox(
                width: 24,
              ),
              Column(
                children: [
                  Text('12'),
                  Icon(
                    Icons.sunny,
                    size: 48,
                  ),
                ],
              ),
              SizedBox(
                width: 24,
              ),
              Column(
                children: [
                  Text('18'),
                  Icon(
                    Icons.sunny,
                    size: 48,
                  ),
                ],
              ),
              SizedBox(
                width: 24,
              ),
              Column(
                children: [
                  Text('24'),
                  Icon(
                    Icons.sunny,
                    size: 48,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
