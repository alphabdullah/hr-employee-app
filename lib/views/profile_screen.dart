import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../resources/app_colors.dart';
import '../resources/components/primary_button.dart';
import '../resources/components/skills_selector.dart';
import '../utils/screen_unit_util.dart';
import '../utils/toast_message.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';

/// Profile Screen View following MVVM pattern
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    // Load both profile data and skills
    vm.loadProfile().then((_) {
      final p = vm.profile;
      _nameController.text = p.name;
      _emailController.text = p.email;
      _phoneController.text = p.phoneNumber;
      _addressController.text = p.residentialAddress;
    });
    // Load skills from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadSkills();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.profile.name.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(20),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.loadProfile(forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: ScreenUnitUtil.getSpacing(24),
                right: ScreenUnitUtil.getSpacing(24),
                top: ScreenUnitUtil.getSpacing(24),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatar(),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    _buildNameField(vm),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildEmailField(vm),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildPhoneField(vm),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildAddressField(vm),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    _buildSkillsSection(vm),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    if (vm.errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
                        margin: EdgeInsets.only(bottom: ScreenUnitUtil.getSpacing(16)),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: ScreenUnitUtil.getFontSize(20),
                            ),
                            SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                            Expanded(
                              child: Text(
                                vm.errorMessage!,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: ScreenUnitUtil.getFontSize(14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    PrimaryButton(
                      text: 'Save Profile',
                      isLoading: vm.isLoading,
                      onPressed: () => _handleSave(vm),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    OutlinedButton.icon(
                      onPressed: () {
                        AppRouter.pushNamed(context, RouteNames.editProfile);
                      },
                      icon: Icon(Icons.edit_outlined),
                      label: Text('Edit Registration Details'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUnitUtil.getSpacing(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        final profileImageUrl = vm.profile.profileImageUrl;
        final selectedImageFile = vm.selectedImageFile;
        
        // Determine which image to show: selected file, profile URL, or default icon
        Widget avatarWidget;
        if (selectedImageFile != null && selectedImageFile.existsSync()) {
          // Show selected image file
          avatarWidget = ClipOval(
            child: Image.file(
              selectedImageFile,
              width: ScreenUnitUtil.getWidth(80),
              height: ScreenUnitUtil.getWidth(80),
              fit: BoxFit.cover,
            ),
          );
        } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          // Show profile image URL (if it's a network URL)
          // Handle both full URLs and relative paths
          String imageUrl = profileImageUrl;
          if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
            // If it's a relative path, prepend base URL
            imageUrl = 'https://hr.aibitsoft.cloud$imageUrl';
          }
          
          avatarWidget = ClipOval(
            child: Image.network(
              imageUrl,
              width: ScreenUnitUtil.getWidth(80),
              height: ScreenUnitUtil.getWidth(80),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: ScreenUnitUtil.getWidth(40),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: ScreenUnitUtil.getFontSize(40),
                    color: AppColors.secondary,
                  ),
                );
              },
            ),
          );
        } else {
          // Default icon when no profile image
          avatarWidget = CircleAvatar(
            radius: ScreenUnitUtil.getWidth(40),
            backgroundColor: AppColors.secondary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: ScreenUnitUtil.getFontSize(40),
              color: AppColors.secondary,
            ),
          );
        }

        return Center(
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(context, vm),
            child: Stack(
              children: [
                avatarWidget,
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImagePickerDialog(BuildContext context, ProfileViewModel vm) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.secondary,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: ScreenUnitUtil.getFontSize(16),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(context, vm, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera,
                  color: AppColors.secondary,
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: ScreenUnitUtil.getFontSize(16),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(context, vm, ImageSource.camera);
                },
              ),
              if (vm.profile.profileImageUrl != null || vm.selectedImageFile != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(16),
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    vm.removeProfileImage();
                    ToastMessage.showInfo('Profile photo removed', context);
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                title: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: ScreenUnitUtil.getFontSize(16),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ProfileViewModel vm, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        vm.updateProfileImage(imageFile);
        ToastMessage.showSuccess('Profile photo updated', context);
      }
    } catch (e) {
      if (context.mounted) {
        ToastMessage.showError(
          'Failed to pick image: ${e.toString()}',
          context,
        );
      }
    }
  }

  Widget _buildNameField(ProfileViewModel vm) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(
          Icons.person_outline,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: vm.updateName,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(ProfileViewModel vm) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      keyboardType: TextInputType.emailAddress,
      onChanged: vm.updateEmail,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(ProfileViewModel vm) {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(
          Icons.phone_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      keyboardType: TextInputType.phone,
      onChanged: vm.updatePhoneNumber,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your phone number';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField(ProfileViewModel vm) {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Residential Address',
        hintText: 'Enter your residential address',
        prefixIcon: Icon(
          Icons.home_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      maxLines: 2,
      onChanged: vm.updateResidentialAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your residential address';
        }
        return null;
      },
    );
  }

  Widget _buildSkillsSection(ProfileViewModel vm) {
    return SkillsSelector(
      selectedSkills: vm.profile.skills,
      availableSkills: vm.availableSkills,
      isLoadingSkills: vm.isLoadingSkills,
      onAddSkill: (skill) => vm.addSkill(skill),
      onRemoveSkill: (skill) => vm.removeSkill(skill),
      isRequired: false,
      dropdownKeyPrefix: 'profile_skill_dropdown',
    );
  }

  Future<void> _handleSave(ProfileViewModel vm) async {
    if (_formKey.currentState!.validate()) {
      final success = await vm.saveProfile();
      if (success && mounted) {
        ToastMessage.showSuccess('Profile updated successfully', context);
      } else if (!success && mounted && vm.errorMessage != null) {
        ToastMessage.showError(vm.errorMessage!, context);
      }
    }
  }
}

