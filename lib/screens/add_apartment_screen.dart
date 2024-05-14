import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_textfield.dart';
import '../widgets/custom_bar.dart';
import '../config.dart';

class AddApartmentScreen extends StatefulWidget {
  @override
  _AddApartmentScreenState createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  List<XFile> _images = [];

  void _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    final Map<String, String> formData = {
      'name': _nameController.text,
      'location': _locationController.text,
      'price': (_priceController.text.isEmpty) ? '0.0' : _priceController.text,
      'beds': (_bedsController.text.isEmpty) ? '0' : _bedsController.text,
      'space': (_spaceController.text.isEmpty) ? '0' : _spaceController.text,
      'phoneNumber': _phoneNumberController.text,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$BASE_URL/api/apartments/add'),
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields.addAll(formData);

    for (var image in _images) {
      final contentType = lookupMimeType(image.path);
      if (contentType != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else {
        print('Error: Unable to determine content type for ${image.path}');
      }
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Apartment added successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  Navigator.pop(context,
                      true); // Close this screen and return true as a result// Go back to the previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Apartment Addition Error'),
            content: Text('Failed to add apartment. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error submitting form: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to add apartment. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: Expanded(
        child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               CustomAppBar(title: 'Add Apartment'),
              RoundedTextField(
                hintText: 'Name',
                icon: Icons.home,
                isPassword: false,
                controller: _nameController,
              ),
              RoundedTextField(
                hintText: 'Location',
                icon: Icons.location_on,
                isPassword: false,
                controller: _locationController,
              ),
              RoundedTextField(
                hintText: 'Price',
                icon: Icons.attach_money,
                isPassword: false,
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              RoundedTextField(
                hintText: 'Beds',
                icon: Icons.king_bed,
                isPassword: false,
                controller: _bedsController,
                keyboardType: TextInputType.number,
              ),
              RoundedTextField(
                hintText: 'Space',
                icon: Icons.aspect_ratio,
                isPassword: false,
                controller: _spaceController,
                keyboardType: TextInputType.number,
              ),
              RoundedTextField(
                hintText: 'Phone Number',
                icon: Icons.phone,
                isPassword: false,
                controller: _phoneNumberController,
              ),
              SizedBox(height: 20.0),
              Text(
                'Upload Images:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _addImage,
                    icon: Icon(Icons.add),
                    label: Text('Add Image'),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _images.length,
                          (index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_images[index].path),
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 12.0,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              RoundedButton(
                text: 'Submit',
                icon: Icons.check,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    )
    )
    );
  }
}
