import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/models/user_model.dart';
import 'package:guares/Auth/services/firebase_storage.dart';
import 'package:guares/Auth/user_Bloc/user_bloc.dart';
import 'package:guares/Auth/user_Bloc/user_event.dart';
import 'package:guares/Utils/dialog_helper.dart';
import 'package:guares/views/main_navigation_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guares/Auth/services/firestore_service.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/views/Authentication_Module/verify_email_view.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final FirestoreService _firestoreService = FirestoreService();

  final FirebaseStorageService _storageService = FirebaseStorageService();

  final TextEditingController _aboutController = TextEditingController();
  String selectedGender = "male";
  String selectedGoal = "Build Better Habits";
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _userNameController = TextEditingController();

  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  Timer? _debounce;

  final _formKey = GlobalKey<FormState>();

  Future<void> _checkUsername() async {
    final username = _userNameController.text.trim();

    if (username.length < 3) {
      setState(() {
        _isUsernameAvailable = null;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    final available = await _firestoreService.isUsernameAvailable(username);

    setState(() {
      _isCheckingUsername = false;
      _isUsernameAvailable = available;
    });
  }

  @override
  void initState() {
    super.initState();

    _userNameController.addListener(() {
      setState(() {});

      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(const Duration(milliseconds: 500), () {
        _checkUsername();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fullNameController.dispose();
    _userNameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _completeProfile() async {
    // Validate all fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Username must be available
    if (_isUsernameAvailable != true) {
      DialogHelper.showError(
        context,
        title: "Username Unavailable",
        message: "Please choose another username.",
      );
      return;
    }

    DialogHelper.showLoading(
      context,
      title: "Creating Your Profile",
      message: "Please wait while we prepare your Guares account...",
    );

    try {
      // Current Firebase user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      // Upload image (if selected)
      String imageUrl = "";

      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadProfileImage(_selectedImage!);
      }

      // Create UserModel
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        fullName: _fullNameController.text.trim(),
        username: _userNameController.text.trim(),
        bio: _aboutController.text.trim(),
        gender: selectedGender,
        goal: selectedGoal,
        profileImage: imageUrl,
        profileCompleted: true,
        streak: 0,
        xp: 0,
        level: 1,
        coins: 0,
        totalHabits: 0,
        createdAt: Timestamp.now(),
      );

      // Save in Firestore
      await _firestoreService.createUser(userModel);

      if (!mounted) return;

      DialogHelper.hideLoading(context);

      context.read<UserBloc>().add(LoadUserRequested());

      DialogHelper.showSuccess(
        context,
        title: "Welcome to Guares!",
        message: "Your profile has been created successfully.",
        buttonText: "Start My Journey",
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationView()),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      DialogHelper.hideLoading(context);

      DialogHelper.showError(
        context,
        title: "Something Went Wrong",
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerifyEmailView(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 5),

                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.primary),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 45),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "FINAL STEP",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Make it ",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 25,
                              ),
                            ),
                            TextSpan(
                              text: "yours",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: AppColors.card,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: _selectedImage == null
                                  ? const Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 35,
                                      color: AppColors.iconSecondary,
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Add Photo",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Full Name",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your full name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Abdul Rauf",
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: .45),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Username",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _userNameController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter username";
                    }

                    if (value.trim().length < 3) {
                      return "Username must be at least 3 characters";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "abdulrauf",
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: .45),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _isCheckingUsername
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            _isUsernameAvailable == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _isUsernameAvailable == true
                                ? AppColors.primary
                                : Colors.red,
                          ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                if (_userNameController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _isCheckingUsername
                          ? "Checking username..."
                          : _userNameController.text.length < 3
                          ? "Username must be at least 3 characters."
                          : _isUsernameAvailable == true
                          ? "Username is available."
                          : "Username is already taken.",
                      style: TextStyle(
                        color: _isCheckingUsername
                            ? Colors.orange
                            : _isUsernameAvailable == true
                            ? AppColors.primary
                            : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                TextField(
                  controller: _aboutController,
                  maxLines: 5,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Tell us about yourself...",
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Gender",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                RadioListTile<String>(
                  title: const Text(
                    "Male",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: "male",
                  groupValue: selectedGender,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text(
                    "Female",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: "female",
                  groupValue: selectedGender,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text(
                    "Prefer not to say",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: "prefer_not_to_say",
                  groupValue: selectedGender,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  "Primary Goal",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedGoal,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Build Better Habits",
                      child: Text("Build Better Habits"),
                    ),
                    DropdownMenuItem(
                      value: "Fitness & Health",
                      child: Text("Fitness & Health"),
                    ),
                    DropdownMenuItem(
                      value: "Study Consistently",
                      child: Text("Study Consistently"),
                    ),
                    DropdownMenuItem(
                      value: "Increase Productivity",
                      child: Text("Increase Productivity"),
                    ),
                    DropdownMenuItem(
                      value: "Improve Sleep",
                      child: Text("Improve Sleep"),
                    ),
                    DropdownMenuItem(value: "Others", child: Text("Others")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGoal = value!;
                    });
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.buttonPrimaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
