import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
          title: const Center(
            child: Text('Profil'),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .background, // bottomsheet color
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      enableDrag: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) => const MenuItems());
                },
                icon: const Icon(Icons.menu)),
          ]),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.all(25),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      user!['username'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user['email'],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
    );
  }
}
