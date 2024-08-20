import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_menu.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  late String _height;
  late String _age;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _name = data['name'] ?? '';
        _height = data['height'] ?? '';
        _age = data['age'] ?? '';
        _nameController.text = _name;
        _heightController.text = _height;
        _ageController.text = _age;
      });
    }
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'name': _nameController.text,
      'height': _heightController.text,
      'age': _ageController.text,
    });
    setState(() {
      _name = _nameController.text;
      _height = _heightController.text;
      _age = _ageController.text;
      _isEditing = false;
    });
  }

  Future<void> _deleteProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).delete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginMenu(title: 'Login')),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _updateProfile,
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteProfile, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileField('Name', _nameController),
              const SizedBox(height: 16.0),
              _buildProfileField('Height', _heightController),
              const SizedBox(height: 16.0),
              _buildProfileField('Age', _ageController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
