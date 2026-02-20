import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/models/userModel.dart';
import 'package:getaqi/providers/userListProvides/userListProviders.dart';
import 'package:getaqi/ui/users/user_card.dart';

class UsersList extends ConsumerStatefulWidget {
  const UsersList({super.key});

  @override
  ConsumerState<UsersList> createState() => _UsersListState();
}

class _UsersListState extends ConsumerState<UsersList>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(usersProvider);
    final isActionLoading = ref.watch(userActionLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.add, color: Colors.black),
          onPressed: () => addUser(context),
        ),
      ),
      body: SafeArea(child: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content
          userAsync.when(
            data: (users) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];

                  return AnimatedSlide(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    offset: const Offset(0, 0),
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      opacity: 1,
                      child: glassCard(
                        child: BuildCard(user, ref, context),
                      ),
                    ),
                  );
                },
              );
            },
            error: (e, st) =>
                Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white))),
            loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
          ),

          // Loading Overlay (Futuristic)
          if (isActionLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),)
    );
  }

  // Glass Effect Card
  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Futuristic Add User Dialog
  void addUser(BuildContext context) {
    final nameController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add User",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Material(
          child: Center(
            child: glassCard(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Enter name",
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyanAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        final users =
                        await ref.read(userServiceProvider).getUsers();

                        ref.read(usersProvider.notifier).addUser(
                          User(
                            id: users.length + 1,
                            name: nameController.text,
                            isLiked: false,
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Add User"),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
    );
  }
}
