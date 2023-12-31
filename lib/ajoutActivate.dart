import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// Import TensorFlow Lite or an alternative library for image processing, if available for web

class AddActivity extends StatefulWidget {
  const AddActivity({Key? key}) : super(key: key);

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController lieuController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nbrPersonnesController = TextEditingController();
  bool isAddingActivity = false;
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activity'),
        backgroundColor: const Color.fromARGB(255, 174, 175, 177),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(titreController, 'Titre'),
              _buildTextField(lieuController, 'Lieu'),
              _buildTextField(categorieController, 'Categorie'),
              _buildTextField(prixController, 'Prix', isNumber: true),
              _buildTextField(nbrPersonnesController, 'Number of People', isNumber: true),
              const SizedBox(height: 16.0),
              _buildImagePickerButton(),
              const SizedBox(height: 16.0),
              _buildAddActivityButton(),
              if (isAddingActivity) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool readOnly = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      readOnly: readOnly,
    );
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton(
      onPressed: isAddingActivity ? null : _pickImage,
      child: const Text('Pick Image'),
    );
  }

  Widget _buildAddActivityButton() {
    return ElevatedButton(
      onPressed: isAddingActivity ? null : addActivity,
      child: const Text('Add Activity'),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageBytes;
        // Call function to identify the image
        // You may need to implement or integrate a web-compatible image recognition library
      });
    }
  }

  void addActivity() async {
    if (_imageData == null) {
      // Show an error message if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.'))
      );
      return;
    }

    setState(() => isAddingActivity = true);

    FirebaseFirestore.instance.collection('Activity').add({
      'titre': titreController.text,
      'lieu': lieuController.text,
      'categorie': categorieController.text,
      'prix': prixController.text,
      'nbrPersonnes': int.tryParse(nbrPersonnesController.text) ?? 0,
      'img': base64Encode(_imageData!),
    }).then((value) {
      // Clear fields and reset state
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity added successfully!'))
      );
    }).catchError((error) {
      print(error);
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding activity. Please try again.'))
      );
    }).whenComplete(() => setState(() => isAddingActivity = false));
  }

  void _clearForm() {
    titreController.clear();
    lieuController.clear();
    categorieController.clear();
    prixController.clear();
    nbrPersonnesController.clear();
    _imageData = null;
  }
}
