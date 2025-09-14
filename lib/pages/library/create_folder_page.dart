import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/models/idea_folder.dart';
import 'package:tech_knowl_edge_connect/components/folder_textfield.dart';
import 'package:tech_knowl_edge_connect/components/submit_button.dart';

class CreateFolderPage extends StatefulWidget {
  final void Function(IdeaFolder folder) onCreate;
  const CreateFolderPage({Key? key, required this.onCreate}) : super(key: key);

  @override
  State<CreateFolderPage> createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPublic = true;

  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuen Ordner erstellen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FolderTextField(
                controller: _nameController,
                hintText: 'Titel',
                validator: (value) => value == null || value.isEmpty
                    ? 'Bitte Titel des Ordners eingeben'
                    : null,
              ),
              const SizedBox(height: 30),
              FolderTextField(
                controller: _descController,
                hintText: 'Beschreibung',
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Text('Öffentlich'),
                  const Spacer(),
                  Switch(
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                  ),
                ],
              ),
              const Spacer(),
              SubmitButton(
                text: 'Erstellen',
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    final now = DateTime.now();
                    final folder = IdeaFolder(
                      id: now.millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      description: _descController.text,
                      ideaPostIds: [],
                      timestamp: Timestamp.fromDate(now),
                      userId: userId!,
                      isPublic: _isPublic,
                    );
                    widget.onCreate(folder);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
