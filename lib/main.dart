import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For progress indicators and other Material widgets
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Calorie Tracker',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeGreen,
        scaffoldBackgroundColor: CupertinoColors.lightBackgroundGray,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: 'Helvetica', color: CupertinoColors.black),
        ),
      ),
      home: CalorieTrackerHome(),
    );
  }
}

class CalorieTrackerHome extends StatefulWidget {
  @override
  _CalorieTrackerHomeState createState() => _CalorieTrackerHomeState();
}

class _CalorieTrackerHomeState extends State<CalorieTrackerHome> {
  int _selectedIndex = 1; // Start with Diary screen (index 1)

  final List<Widget> _screens = [
    HomeScreen(), // Index 0
    DiaryScreen(), // Index 1
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Diary',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: CupertinoColors.activeGreen,
        activeColor: CupertinoColors.white,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => _screens[_selectedIndex],
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // HomeScreen state variables (simplified for now)
  double totalCalories = 0;
  double calorieGoal = 2000;
  final TextEditingController _controller = TextEditingController();

  Future<void> addFood(String query) async {
    final apiKey = 'YOUR_USDA_API_KEY'; // Replace with your key
    final url = 'https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      final food = data['foods'][0];
      final calories = food['foodNutrients'].firstWhere((n) => n['nutrientName'] == 'Energy')['value'].toDouble();
      setState(() {
        totalCalories += calories;
      });
    } catch (e) {
      print('Error fetching food: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Calorie Tracker', style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.activeGreen,
      ),
      child: Center(
        child: Text('Home Screen Placeholder'),
      ),
    );
  }
}

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int _selectedDayIndex = 0; // Current day index
  final List<DateTime> _days = List.generate(7, (index) => DateTime.now().subtract(Duration(days: index)));
  final Map<String, List<Map<String, dynamic>>> _mealLog = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };
  int _selectedMealIndex = 0; // Track selected meal (0: Breakfast, 1: Lunch, 2: Dinner, 3: Snacks)
  final TextEditingController _foodController = TextEditingController();
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Fetch food data from USDA API
  Future<void> addFood(String query) async {
    final apiKey = 'av75jC4qNdVa0BwXiEG7TW3hK2wXz7q4lSeeBDLq'; // Replace with your key
    final url = 'https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      final food = data['foods'][0];
      final calories = food['foodNutrients'].firstWhere((n) => n['nutrientName'] == 'Energy')['value'].toDouble();
      final foodItem = {'name': food['description'], 'calories': calories};

      setState(() {
        _mealLog[_mealTypes[_selectedMealIndex]]!.add(foodItem);
      });
    } catch (e) {
      print('Error fetching food: $e');
    }
  }

  // Navigate to previous/next day
  void _changeDay(int delta) {
    setState(() {
      _selectedDayIndex = (_selectedDayIndex + delta).clamp(0, _days.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Diary', style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.left_chevron, color: CupertinoColors.white),
          onPressed: () => _changeDay(1), // Swipe right (next day)
        ),
        trailing: CupertinoButton(
          child: Icon(CupertinoIcons.right_chevron, color: CupertinoColors.white),
          onPressed: () => _changeDay(-1), // Swipe left (previous day)
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Day Selector
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '${_days[_selectedDayIndex].day}/${_days[_selectedDayIndex].month}/${_days[_selectedDayIndex].year}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black),
              ),
            ),
            // Meal Tabs
            CupertinoSegmentedControl<int>(
              children: {
                0: Text('Breakfast'),
                1: Text('Lunch'),
                2: Text('Dinner'),
                3: Text('Snacks'),
              },
              onValueChanged: (int value) {
                setState(() {
                  _selectedMealIndex = value;
                });
              },
              groupValue: _selectedMealIndex,
              selectedColor: CupertinoColors.activeGreen,
              unselectedColor: CupertinoColors.white,
              borderColor: CupertinoColors.activeGreen,
            ),
            // Meal List
            Expanded(
              child: ListView.builder(
                itemCount: _mealLog[_mealTypes[_selectedMealIndex]]!.length,
                itemBuilder: (context, index) {
                  final food = _mealLog[_mealTypes[_selectedMealIndex]]![index];
                  return ListTile(
                    title: Text(food['name'], style: TextStyle(color: CupertinoColors.black)),
                    trailing: Text('${food['calories'].toInt()} kcal', style: TextStyle(color: CupertinoColors.darkBackgroundGray)),
                  );
                },
              ),
            ),
            // Add Food Section
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _foodController,
                      placeholder: 'Search food (e.g., apple)',
                      padding: EdgeInsets.all(10),
                      style: TextStyle(color: CupertinoColors.black), // Ensure text is visible
                      placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  SizedBox(width: 10),
                  CupertinoButton(
                    color: CupertinoColors.activeGreen,
                    child: Text('Add', style: TextStyle(color: CupertinoColors.white)),
                    onPressed: () {
                      if (_foodController.text.isNotEmpty) {
                        addFood(_foodController.text);
                        _foodController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}