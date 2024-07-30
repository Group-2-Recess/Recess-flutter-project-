import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/reminder.dart';
import 'set_reminder.dart';
import 'patient_list.dart';

class MedicationDetailPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final String patientId;
  final Medication? medication;

  MedicationDetailPage({
    Key? key,
    required this.userId,
    required this.caregiverId,
    required this.patientId,
    this.medication,
  }) : super(key: key);

  @override
  _MedicationDetailPageState createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _diagnosisController;
  late TextEditingController _prescriptionController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _instructionsController;
  List<Reminder> _reminders = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotificationPlugin();
    _initializeFormControllers();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _diagnosisController.text = widget.medication!.diagnosis;
      _prescriptionController.text = widget.medication!.prescription;
      _dosageController.text = widget.medication!.dosage;
      _frequencyController.text = widget.medication!.frequency;
      _instructionsController.text = widget.medication!.instructions;
      _reminders = widget.medication!.reminders;
    }
  }

  void _initializeFormControllers() {
    _nameController = TextEditingController();
    _diagnosisController = TextEditingController();
    _prescriptionController = TextEditingController();
    _dosageController = TextEditingController();
    _frequencyController = TextEditingController();
    _instructionsController = TextEditingController();
  }

  Future<void> _initializeNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _scheduleNotification(
      Reminder reminder, String patientName, String patientAddress) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            importance: Importance.high, playSound: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Medication Reminder for $patientName',
      'It\'s time for $patientName to take their medication: ${reminder.medicationName}. Address: $patientAddress',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _navigateToSetReminderPage() async {
    // Fetch patient data from Firestore
    final patient = await _firestoreService.getPatient(
        widget.caregiverId, widget.patientId);
    final patientName = patient?.name ?? "Unknown";
    final patientAddress = patient?.address ??
        "No address provided"; // Replace with actual address field

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderPage(
          userId: widget.userId,
          caregiverId: widget.caregiverId,
          patientId: widget.patientId,
          medicationName: _nameController.text,
        ),
      ),
    ).then((reminder) {
      if (reminder != null && reminder is Reminder) {
        setState(() {
          _reminders.add(reminder);
          _scheduleNotification(reminder, patientName, patientAddress);
        });
      }
    });
  }

  void _addAnotherMedication() {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget.medication?.id ?? '',
        name: _nameController.text,
        diagnosis: _diagnosisController.text,
        prescription: _prescriptionController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        instructions: _instructionsController.text,
        alarms: [], // Initialize with an empty list if needed
        reminders: _reminders,
        verificationStatus: widget.medication?.verificationStatus ?? false,
        verificationDate: widget.medication?.verificationDate ?? DateTime.now(),
      );

      _saveMedication(medication);
      _resetForm();
    }
  }

  Future<void> _saveMedication(Medication medication) async {
    try {
      final newMedId = await _firestoreService.addMedication(
        widget.caregiverId,
        widget.patientId,
        medication,
      );

      medication.id = newMedId;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication saved successfully.'),
        ),
      );
    } catch (e) {
      print('Error saving medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving medication.'),
        ),
      );
    }
  }

  void _resetForm() {
    _nameController.clear();
    _diagnosisController.clear();
    _prescriptionController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _instructionsController.clear();
    _reminders.clear();
  }

  Future<void> _saveMedications() async {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget.medication?.id ?? '',
        name: _nameController.text,
        diagnosis: _diagnosisController.text,
        prescription: _prescriptionController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        instructions: _instructionsController.text,
        alarms: [], // Initialize with an empty list if needed
        reminders: _reminders,
        verificationStatus: widget.medication?.verificationStatus ?? false,
        verificationDate: widget.medication?.verificationDate ?? DateTime.now(),
      );

      await _saveMedication(medication);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PatientListPage(
            userId: widget.userId,
            caregiverId: widget.caregiverId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Medication Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Medication Name'),
              _buildTextField(_diagnosisController, 'Diagnosis'),
              _buildTextField(_prescriptionController, 'Prescription'),
              _buildTextField(_dosageController, 'Dosage'),
              _buildTextField(_frequencyController, 'Frequency'),
              _buildTextField(_instructionsController, 'Instructions'),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildElevatedButton(
                      'Set Reminders',
                      Colors.green[700]!,
                      _navigateToSetReminderPage,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildElevatedButton(
                      'Add Another Medication',
                      Colors.green[800]!,
                      _addAnotherMedication,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildElevatedButton(
                'Save Medication',
                Colors.green[900]!,
                _saveMedications,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.green[700]),
          border: OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildElevatedButton(
      String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: color,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.0),
      ),
    );
  }
}
