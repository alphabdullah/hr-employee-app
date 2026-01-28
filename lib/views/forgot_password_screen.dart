import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/primary_button.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../utils/toast_message.dart';

/// Forgot Password Screen View following MVVM pattern
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUnitUtil is initialized
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<ForgotPasswordViewModel>(
          builder: (context, viewModel, child) {
            // Show success screen if email is sent
            if (viewModel.isEmailSent) {
              return _buildSuccessScreen();
            }

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
                    // Header Section
                    _buildHeaderSection(),
                    SizedBox(height: ScreenUnitUtil.getSpacing(40)),
                    
                    // Email Field
                    _buildEmailField(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    
                    // Error Message
                    if (viewModel.errorMessage != null)
                      _buildErrorMessage(viewModel.errorMessage!),
                    
                    SizedBox(height: ScreenUnitUtil.getSpacing(32)),
                    
                    // Submit Button
                    _buildSubmitButton(viewModel),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    
                    // Back to Login Link
                    _buildBackToLoginLink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ScreenUnitUtil.getWidth(80),
          height: ScreenUnitUtil.getWidth(80),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_outlined,
            size: ScreenUnitUtil.getFontSize(40),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(24)),
        Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(32),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          'No worries! Enter your email address and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ForgotPasswordViewModel viewModel) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
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
      onFieldSubmitted: (_) {
        _handleSubmit(viewModel);
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

  Widget _buildSubmitButton(ForgotPasswordViewModel viewModel) {
    return PrimaryButton(
      text: 'Send Reset Link',
      isLoading: viewModel.isLoading,
      onPressed: () => _handleSubmit(viewModel),
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
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

  Widget _buildSuccessScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(24),
        vertical: ScreenUnitUtil.getSpacing(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success Icon
          Container(
            width: ScreenUnitUtil.getWidth(120),
            height: ScreenUnitUtil.getWidth(120),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: ScreenUnitUtil.getFontSize(60),
              color: AppColors.success,
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(32)),
          
          // Success Title
          Text(
            'Check Your Email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(28),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
          
          // Success Message
          Text(
            'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(40)),
          
          // Back to Login Button
          PrimaryButton(
            text: 'Back to Login',
            onPressed: () {
              AppRouter.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(ForgotPasswordViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.sendPasswordResetEmail();
      if (success && mounted) {
        ToastMessage.showSuccess(
          'Password reset link sent to your email!',
          context,
        );
      } else if (!success && mounted && viewModel.errorMessage != null) {
        ToastMessage.showError(viewModel.errorMessage!, context);
      }
    }
  }
}

