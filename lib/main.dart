import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Destroyer";
  int happinessLevel = 50;
  int hungerLevel = 50;

  final TextEditingController _nameController = TextEditingController();

  Timer? _hungerTimer;
  Timer? _winTimer;

  int _happySeconds = 0;
  bool _gameOver = false;
  bool _hasWon = false;

  // Activity Selection
  final List<String> _activities = ["Play", "Run", "Sleep"];
  String _selectedActivity = "Play";

  @override
  void initState() {
    super.initState();

    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_gameOver || _hasWon) return;
      _updateHunger();
    });

    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_gameOver || _hasWon) return;

      if (happinessLevel > 80) {
        _happySeconds++;
        if (_happySeconds >= 180) {
          _triggerWin();
        }
      } else {
        _happySeconds = 0;
      }
    });
  }

  Color _moodColor(double happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _moodText() {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  void _setPetName() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() {
      petName = newName;
    });

    _nameController.clear();
  }

  void _doActivity() {
    if (_gameOver || _hasWon) return;

    setState(() {
      if (_selectedActivity == "Play") {
        happinessLevel += 10;
        hungerLevel += 5;
      } else if (_selectedActivity == "Run") {
        happinessLevel += 15;
        hungerLevel += 10;
      } else if (_selectedActivity == "Sleep") {
        happinessLevel += 5;
        hungerLevel += 2;
      }

      if (happinessLevel > 100) happinessLevel = 100;
      if (happinessLevel < 0) happinessLevel = 0;

      if (hungerLevel > 100) hungerLevel = 100;
      if (hungerLevel < 0) hungerLevel = 0;
    });

    if (_selectedActivity != "Play") {
      _checkLoss();
    } else {
      // keep original behavior consistent: use existing hunger update
      _checkLoss();
    }
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
    });

    _updateHappiness();
    _checkLoss();
  }

  void _updateHappiness() {
    setState(() {
      if (hungerLevel < 30) {
        happinessLevel -= 20;
      } else {
        happinessLevel += 10;
      }

      if (happinessLevel < 0) happinessLevel = 0;
      if (happinessLevel > 100) happinessLevel = 100;
    });
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;

      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
        if (happinessLevel < 0) happinessLevel = 0;
      }
    });

    _checkLoss();
  }

  void _checkLoss() {
    if (hungerLevel >= 100 && happinessLevel <= 10 && !_gameOver && !_hasWon) {
      _gameOver = true;
      _showDialog("Game Over", "$petName has lost the game.");
      setState(() {});
    }
  }

  void _triggerWin() {
    if (_hasWon || _gameOver) return;

    _hasWon = true;
    _showDialog("You Win", "You kept happiness above 80 for 3 minutes.");
    setState(() {});
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      petName = "Destroyer";
      happinessLevel = 50;
      hungerLevel = 50;
      _happySeconds = 0;
      _gameOver = false;
      _hasWon = false;
      _selectedActivity = "Play";
      _nameController.clear();
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
        actions: [
          TextButton(
            onPressed: _resetGame,
            child: Text(
              "Reset",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter pet name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _setPetName(),
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: disabled ? null : _setPetName,
              child: Text('Set Name'),
            ),

            SizedBox(height: 16.0),

            // Activity Selection Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: DropdownButtonFormField<String>(
                value: _selectedActivity,
                decoration: InputDecoration(
                  labelText: 'Select activity',
                  border: OutlineInputBorder(),
                ),
                items: _activities
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: disabled
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedActivity = value;
                        });
                      },
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: disabled ? null : _doActivity,
              child: Text('Do Activity'),
            ),

            SizedBox(height: 20.0),

            ColorFiltered(
              colorFilter: ColorFilter.mode(
                _moodColor(happinessLevel.toDouble()),
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/pet_image.png',
                width: 160,
                height: 160,
              ),
            ),

            SizedBox(height: 16.0),

            Text(
              'Mood: ${_moodText()}',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16.0),
            Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 32.0),

            ElevatedButton(
              onPressed: disabled ? null : _feedPet,
              child: Text('Feed Your Pet'),
            ),

            SizedBox(height: 16.0),

            Text(
              'Win timer: ${(_happySeconds / 60).toStringAsFixed(2)} minutes above 80',
            ),
          ],
        ),
      ),
    );
  }
}
