import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/primary_button.dart';
import '../resources/components/skills_selector.dart';
import '../routes/app_router.dart';
import '../utils/toast_message.dart';

/// SignUp Screen View following MVVM pattern
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Load skills from API when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpViewModel>().loadSkills();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUnitUtil is initialized
    ScreenUnitUtil.init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<SignUpViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUnitUtil.getSpacing(24),
                vertical: ScreenUnitUtil.getSpacing(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Text
                    _buildWelcomeText(),
                    SizedBox(height: ScreenUnitUtil.getSpacing(32)),
                    
                    // Full Name Field
                    _buildFullNameField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Email Field
                    _buildEmailField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Phone Number Field
                    _buildPhoneField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Residential Address Field
                    _buildAddressField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Skills Section
                    _buildSkillsSection(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Password Field
                    _buildPasswordField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Confirm Password Field
                    _buildConfirmPasswordField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    
                    // Error Message
                    if (viewModel.errorMessage != null)
                      _buildErrorMessage(viewModel.errorMessage!),
                    
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    
                    // Sign Up Button
                    _buildSignUpButton(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    
                    // Login Link
                    _buildLoginLink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Us',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(32),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          'Create your account to get started',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Full Name *',
        hintText: 'Enter your full name',
        prefixIcon: Icon(
          Icons.person_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updateFullName(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        if (value.length < 2) {
          return 'Full name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updateEmail(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(
          Icons.phone_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updatePhoneNumber(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        if (!RegExp(r'^\d{7,15}$').hasMatch(cleaned)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: _addressController,
      keyboardType: TextInputType.streetAddress,
      textInputAction: TextInputAction.next,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Residential Address *',
        hintText: 'Enter your complete residential address',
        prefixIcon: Icon(
          Icons.home_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
        alignLabelWithHint: true,
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updateResidentialAddress(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your residential address';
        }
        if (value.length < 10) {
          return 'Please enter a complete address';
        }
        return null;
      },
    );
  }

  Widget _buildSkillsSection(SignUpViewModel viewModel) {
    return SkillsSelector(
      selectedSkills: viewModel.signUpModel.skills,
      availableSkills: viewModel.availableSkills,
      isLoadingSkills: viewModel.isLoadingSkills,
      onAddSkill: (skill) => viewModel.addSkill(skill),
      onRemoveSkill: (skill) => viewModel.removeSkill(skill),
      isRequired: true,
      validator: (skills) {
        if (skills.isEmpty) {
          return 'Please select at least one skill';
        }
        return null;
      },
      dropdownKeyPrefix: 'signup_skill_dropdown',
    );
  }

  Widget _buildPasswordField(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              size: ScreenUnitUtil.getFontSize(20),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: ScreenUnitUtil.getFontSize(20),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
          onChanged: (value) {
            viewModel.updatePassword(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            
            if (value.length > 8) {
              return 'Password must be maximum 8 characters';
            }
            
            // Check for uppercase letter
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Must contain at least 1 uppercase letter';
            }
            
            // Check for lowercase letter
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Must contain at least 1 lowercase letter';
            }
            
            // Check for numeric digit
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Must contain at least 1 numeric digit';
            }
            
            // Check for special character (@$!%*?&#)
            if (!RegExp(r'[@$!%*?&#]').hasMatch(value)) {
              return 'Must contain at least 1 special character (@!%*?&#)';
            }
            
            return null;
          },
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          'Password must contain: 1 uppercase, 1 lowercase, 1 number, 1 special character (@!%*?&#) (max 8 chars)',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(12),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirm Password *',
        hintText: 'Re-enter your password',
        prefixIcon: Icon(
          Icons.lock_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: ScreenUnitUtil.getFontSize(20),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updateConfirmPassword(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _handleSignUp(viewModel);
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
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
              message,
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(14),
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(SignUpViewModel viewModel) {
    return PrimaryButton(
      text: 'Create Account',
      isLoading: viewModel.isLoading,
      onPressed: () => _handleSignUp(viewModel),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(14),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            AppRouter.pop(context);
          },
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp(SignUpViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.signUp();
      if (success && mounted) {
        // Navigate back to login screen
        Navigator.of(context).pop(true); // Pass true as result to indicate success
        ToastMessage.showSuccess('Account created successfully! Please login.', context);
      } else if (mounted && viewModel.errorMessage != null) {
        // Error message is already displayed in the UI via Consumer
        // Optionally show toast for API errors
        ToastMessage.showError(viewModel.errorMessage!, context);
      }
    }
  }
}

