import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/views/Home_Module/Profile/Bloc/profile_bloc.dart';
import 'package:guares/views/Home_Module/Profile/Bloc/profile_event.dart';
import 'package:guares/views/Home_Module/Profile/Bloc/profile_state.dart';

class EditProfileView extends StatefulWidget {
  final String name;
  final String username;
  final String bio;
  final String profileImageUrl;

  const EditProfileView({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImageUrl,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name);
    _usernameController = TextEditingController(text: widget.username);
    _bioController = TextEditingController(text: widget.bio);
    _imageController = TextEditingController(text: widget.profileImageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<ProfileBloc>().add(
      UpdateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        profileImageUrl: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            Navigator.of(context).pop();
          }

          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixText: '@',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Profile Image URL',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final isUpdating = state is ProfileUpdating;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : _save,
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
