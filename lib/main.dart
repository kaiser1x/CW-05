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

  @override
  void initState() {
    super.initState();

    // Auto-Hunger Timer
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateHunger();
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

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
    } else {
      happinessLevel += 10;
    }
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;

      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
      }
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
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
              onPressed: _setPetName,
              child: Text('Set Name'),
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
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
          ],
        ),
      ),
    );
  }
}
