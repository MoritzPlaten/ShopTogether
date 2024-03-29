import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/functions/services/firestore/MyFirestoreService.dart';
import 'package:shopping_app/objects/users/MyUsers.dart';

/**
 * this shows the name of the user. When you click on it you navigate to the account settings
 * */
class MyUserCard extends StatelessWidget {
  const MyUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUuid = user?.uid ?? '';

    return StreamBuilder<MyUser>(
      stream: MyFirestoreService.userService.getUserAsStream(userUuid),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data!;
        final displayName = "${userData.prename} ${userData.surname}";

        return _buildUserCard(context, displayName);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, String displayName) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 10),
          ),
        ),
        child: Card(
          color: Theme.of(context).cardTheme.color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Accounteinstellungen",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: Theme.of(context).iconTheme.size,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}