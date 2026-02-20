import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/extras/appSize.dart';
import 'package:getaqi/models/userModel.dart';
import 'package:getaqi/providers/userListProvides/userListProviders.dart';

class BuildCard extends ConsumerWidget {
  final User user;
  final WidgetRef ref;
  final BuildContext context;
  BuildCard(this.user, this.ref, this.context);


  @override
  Widget build(BuildContext context,ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      margin: EdgeInsets.all(AppSize.screenNormalMarginSize),
      child: ListTile(
        onLongPress: () {
          ref.read(usersProvider.notifier).deleteUser(user);
        },
        key: ValueKey(user.id),
        leading: Container(
          child: IconButton(
            onPressed: () {
              ref
                  .read(usersProvider.notifier)
                  .updateUser(user.copyWith(isLiked: !user.isLiked));
            },
            icon: Icon(
              Icons.heart_broken,
              color: user.isLiked ? Colors.red : Colors.grey,
            ),
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                final nameController = TextEditingController(text: user.name);

                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // important for center dialog
                      children: [
                        Text(
                          "Update User",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(

                            hintText: "Enter name",
                            fillColor: Colors.white,
                            labelText: "Name",
                            border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(usersProvider.notifier)
                                    .updateUser(
                                  user.copyWith(name: nameController.text),
                                );
                                Navigator.pop(context);
                              },
                              child: Text("Update"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },

          icon: Icon(Icons.edit, size: 15,color: Colors.white,),
        ),
        title: Text("User ${user.name},",style: TextStyle(color: Colors.white),),
      ),
    );
  }
}