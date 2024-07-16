import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14.0),
          titleLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.pink[50],
          labelStyle: TextStyle(fontFamily: 'Roboto', color: Colors.pink[700]),
          prefixIconColor: Colors.pink[700],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[500], // Updated to backgroundColor
            foregroundColor: Colors.white, // Updated to foregroundColor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink[400],
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: UserDetailsForm(),
    );
  }
}

class UserDetailsForm extends StatefulWidget {
  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  String _illness = '';
  String _medication = '';
  String _prescription = '';
  String _reminder = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MEDICATION FORM',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center align the title
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.pink[100]!,
              Colors.pink[200]!,
              Colors.pink[300]!,
              Colors.pink[400]!,
              Colors.pink[500]!,
            ],
            center: Alignment(0.0, 0.0),
            radius: 1.5,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink[300]!,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Illness',
                            prefixIcon: Icon(FontAwesomeIcons.virus),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your illness';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _illness = value!;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Medication',
                            prefixIcon: Icon(FontAwesomeIcons.capsules),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your medication';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _medication = value!;
                          },
                        ),
                        SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrescriptionDetailsPage(),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Prescription/Medicine(s)',
                                prefixIcon: Icon(FontAwesomeIcons.pills),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your prescription/medicine(s)';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _prescription = value!;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReminderPage(),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Reminder',
                                prefixIcon: Icon(FontAwesomeIcons.bell),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a reminder for taking medication';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _reminder = value!;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              // Process the input data
                              print('Illness: $_illness');
                              print('Medication: $_medication');
                              print('Prescription: $_prescription');
                              print('Reminder: $_reminder');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.pink[500], // Updated to backgroundColor
                            foregroundColor:
                                Colors.white, // Updated to foregroundColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            textStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrescriptionDetailsPage extends StatefulWidget {
  @override
  _PrescriptionDetailsPageState createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  String _prescriptionDetails = '';
  bool _beforeBreakfast = false;
  bool _afterBreakfast = false;
  bool _beforeLunch = false;
  bool _afterLunch = false;
  bool _evening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prescription Details',
                  prefixIcon: Icon(FontAwesomeIcons.pills),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter prescription details';
                  }
                  return null;
                },
                onSaved: (value) {
                  _prescriptionDetails = value!;
                },
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text('Before breakfast'),
                value: _beforeBreakfast,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeBreakfast = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('After breakfast'),
                value: _afterBreakfast,
                onChanged: (bool? value) {
                  setState(() {
                    _afterBreakfast = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Before lunch'),
                value: _beforeLunch,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeLunch = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('After lunch'),
                value: _afterLunch,
                onChanged: (bool? value) {
                  setState(() {
                    _afterLunch = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Evening'),
                value: _evening,
                onChanged: (bool? value) {
                  setState(() {
                    _evening = value!;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process the input data
                    print('Prescription Details: $_prescriptionDetails');
                    print('Before Breakfast: $_beforeBreakfast');
                    print('After Breakfast: $_afterBreakfast');
                    print('Before Lunch: $_beforeLunch');
                    print('After Lunch: $_afterLunch');
                    print('Evening: $_evening');

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[500],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final Map<DateTime, List<String>> _medications = {};
  final Map<DateTime, String> _dosageDetails = {};
  DateTime _selectedDay = DateTime.now();
  final _dosageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder Page'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.bell),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification Icon Pressed')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: CalendarFormat.week, // Display only one week
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.pink[800]),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.pink[500],
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(color: Colors.pink[800]),
              ),
              onFormatChanged: (format) {
                // Do nothing to keep the calendar in week format
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Dosage Details for ${_selectedDay.toString().split(' ')[0]}:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Enter Dosage Details',
                prefixIcon: Icon(FontAwesomeIcons.pills),
              ),
              onChanged: (value) {
                setState(() {
                  _dosageDetails[_selectedDay] = value;
                });
              },
            ),
            SizedBox(height: 8.0),
            Text(
              'Medications for ${_selectedDay.toString().split(' ')[0]}:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView(
                children: _medications[_selectedDay] != null
                    ? _medications[_selectedDay]!
                        .map((med) => ListTile(
                              leading: Icon(FontAwesomeIcons.pills),
                              title: Text(med),
                            ))
                        .toList()
                    : [ListTile(title: Text('No medicines for this day'))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
