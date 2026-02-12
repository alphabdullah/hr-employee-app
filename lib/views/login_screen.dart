import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/primary_button.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../utils/toast_message.dart';

/// Login Screen View following MVVM pattern
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUnitUtil is initialized
    ScreenUnitUtil.init(context);
    
    return Scaffold(
      body: SafeArea(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUnitUtil.getSpacing(24),
                vertical: ScreenUnitUtil.getSpacing(32),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/App Title Section
                    SizedBox(height: ScreenUnitUtil.getHeight(60)),
                    _buildLogoSection(),
                    SizedBox(height: ScreenUnitUtil.getHeight(80)),
                    
                    // Welcome Text
                    _buildWelcomeText(),
                    SizedBox(height: ScreenUnitUtil.getHeight(40)),
                    
                    // Email Field
                    _buildEmailField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(20)),
                    
                    // Password Field
                    _buildPasswordField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    
                    // Forgot Password
                    _buildForgotPassword(),
                    SizedBox(height: ScreenUnitUtil.getSpacing(32)),
                    
                    // Error Message
                    if (viewModel.errorMessage != null)
                      _buildErrorMessage(viewModel.errorMessage!),
                    
                    // Login Button
                    _buildLoginButton(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    
                    // Sign Up Link
                    _buildSignUpLink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: ScreenUnitUtil.getWidth(120),
          height: ScreenUnitUtil.getWidth(120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Padding(
            padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
            child: Image.asset(
              'assets/icon/icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(16)),
        Text(
          'TempSpot',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(28),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(32),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(LoginViewModel viewModel) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          size: ScreenUnitUtil.getFontSize(20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenUnitUtil.getSpacing(16),
          vertical: ScreenUnitUtil.getSpacing(16),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updateEmail(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenUnitUtil.getSpacing(16),
          vertical: ScreenUnitUtil.getSpacing(16),
        ),
      ),
      style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(16)),
      onChanged: (value) {
        viewModel.updatePassword(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _handleLogin(viewModel);
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child:         TextButton(
          onPressed: () {
            AppRouter.pushNamed(context, RouteNames.forgotPassword);
          },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(14),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
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

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return PrimaryButton(
      text: 'Login',
      isLoading: viewModel.isLoading,
      onPressed: () => _handleLogin(viewModel),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(14),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () async{
            // Navigate to signup and wait for result
            final result = await AppRouter.pushNamed(context, RouteNames.signUp);
            // If signup was successful, show success message
            if (result == true && mounted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  ToastMessage.showSuccess('Account created successfully! Please login.', context);
                }
              });
            }
          },
          child: Text(
            'Sign Up',
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

  Future<void> _handleLogin(LoginViewModel viewModel) async {
    // Validate form before attempting login
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.login();
      if (success && mounted) {
        // Show success message
        // Wait a bit for toast to show, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Ensure custom fields are loaded so all step indicators know about Step 6
          try {
            final signUpViewModel =
                Provider.of<SignUpViewModel>(context, listen: false);
            await signUpViewModel.fetchCustomFields();
          } catch (_) {
            // Ignore errors here; registration flow should still work without custom fields
          }

          // Check registration progress and navigate accordingly
          final registrationProgress = viewModel.registrationProgress;
          final nextStep = registrationProgress?.nextStep;
          
          if (nextStep != null) {
            // User needs to complete registration steps
            String route;
            switch (nextStep) {
              case 2:
                route = RouteNames.signUpStep2;
                break;
              case 3:
                route = RouteNames.signUpStep3;
                break;
              case 4:
                // If nextStep is 4, user needs to complete declarations first
                route = RouteNames.declaration;
                break;
              case 5:
                // Step 5: HMRC/Tax details (P46)
                route = RouteNames.signUpStep5;
                break;
              default:
                route = RouteNames.signUpStep1;
            }
            // Navigate to the required step and remove login from stack
            // Pass isEditMode: false since user is completing registration
            Navigator.of(context).pushNamedAndRemoveUntil(
              route,
              (route) => false,
              arguments: {'isEditMode': false},
            );
            ToastMessage.showSuccess('Login successful! Please complete your registration.', context);
          } else {
            // All steps complete - check if user status is pending
            final userData = viewModel.userData;
            final userStatus = userData?['status'] as String?;
            
            if (userStatus == 'pending') {
              AppRouter.pushNamedAndRemoveUntil(context, RouteNames.pendingDashboard);
              ToastMessage.showSuccess('Login successful! Continue completing your steps.', context);
            } else {
              AppRouter.pushNamedAndRemoveUntil(context, RouteNames.home);
              ToastMessage.showSuccess('Login successful!', context);
            }
          }
        }
      } else if (mounted && viewModel.errorMessage != null) {
        // Error message is already displayed in the UI via Consumer
        // Optionally show toast for API errors
        ToastMessage.showError(viewModel.errorMessage!, context);
      }
    }
  }
}

