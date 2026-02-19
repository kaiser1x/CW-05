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
  int energyLevel = 80;

  final TextEditingController _nameController = TextEditingController();

  Timer? _hungerTimer;
  Timer? _winTimer;

  int _happySeconds = 0;
  bool _gameOver = false;
  bool _hasWon = false;

  final List<String> _activities = ["Play", "Run", "Sleep"];
  String _selectedActivity = "Play";

  @override
  void initState() {
    super.initState();

    // Auto-hunger: increases hunger every 30 seconds
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_gameOver || _hasWon) return;
      _increaseHunger(5);
    });

    // Win condition: happiness > 80 for 3 minutes (180 seconds)
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

  int _clamp(int v) {
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  void _setPetName() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() {
      petName = newName;
    });

    _nameController.clear();
  }

  // Core hunger functions (clearer than mixing meanings in one method)
  void _increaseHunger(int amount) {
    setState(() {
      hungerLevel = _clamp(hungerLevel + amount);

      // If hunger maxes out, happiness takes a hit
      if (hungerLevel == 100) {
        happinessLevel = _clamp(happinessLevel - 20);
      }
    });

    _checkLoss();
  }

  void _decreaseHunger(int amount) {
    setState(() {
      hungerLevel = _clamp(hungerLevel - amount);
    });
  }

  void _updateHappinessFromHunger() {
    setState(() {
      // Hungry pet is less happy, well-fed pet is happier
      if (hungerLevel >= 70) {
        happinessLevel = _clamp(happinessLevel - 10);
      } else if (hungerLevel <= 30) {
        happinessLevel = _clamp(happinessLevel + 10);
      }
    });
  }

  void _doActivity() {
    if (_gameOver || _hasWon) return;

    if (_selectedActivity == "Play") {
      setState(() {
        happinessLevel = _clamp(happinessLevel + 10);
        energyLevel = _clamp(energyLevel - 5);
      });
      _increaseHunger(5);
    } else if (_selectedActivity == "Run") {
      setState(() {
        happinessLevel = _clamp(happinessLevel + 15);
        energyLevel = _clamp(energyLevel - 15);
      });
      _increaseHunger(10);
    } else if (_selectedActivity == "Sleep") {
      setState(() {
        energyLevel = _clamp(energyLevel + 20);
        happinessLevel = _clamp(happinessLevel + 5);
      });
      // Sleeping makes the pet slightly hungrier over time, but less than running
      _increaseHunger(2);
    }

    _updateHappinessFromHunger();
    _checkLoss();
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    // Feeding reduces hunger and restores a bit of energy
    _decreaseHunger(10);

    setState(() {
      energyLevel = _clamp(energyLevel + 5);
    });

    _updateHappinessFromHunger();
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
      energyLevel = 80;
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
            SizedBox(height: 16.0),
            Text('Energy Level: $energyLevel',
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
