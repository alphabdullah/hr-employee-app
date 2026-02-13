import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodels/signup_viewmodel.dart';
import '../../models/register_flow_models.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../resources/components/step_indicator.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';
import '../../services/auth_service.dart';

/// Step 6: Custom Fields Screen
class SignUpStep6Screen extends StatefulWidget {
  final bool isEditMode;

  const SignUpStep6Screen({super.key, this.isEditMode = false});

  @override
  State<SignUpStep6Screen> createState() => _SignUpStep6ScreenState();
}

class _SignUpStep6ScreenState extends State<SignUpStep6Screen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controllers =
      {}; // Field ID -> Controller
  final Map<int, dynamic> _fieldValues = {}; // Field ID -> Value
  final Map<int, File?> _documentFiles = {}; // Field ID -> File

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<SignUpViewModel>();
      viewModel.goToStep(6);
      viewModel.setEditMode(widget.isEditMode);

       // Ensure profile data (including profile_extra) is loaded so existing values
       // can be shown in the Additional Information screen.
       await viewModel.loadProfileData();

      // If custom fields are already loaded, use them; otherwise fetch
      if (viewModel.customFields.isNotEmpty) {
        debugPrint(
          'Step 6: Using existing custom fields (${viewModel.customFields.length})',
        );
        _initializeFields(viewModel);
      } else {
        debugPrint('Step 6: Fetching custom fields...');
        // Fetch custom fields
        viewModel.fetchCustomFields().then((_) {
          if (mounted) {
            debugPrint(
              'Step 6: Custom fields fetched, count: ${viewModel.customFields.length}',
            );
            _initializeFields(viewModel);
          }
        });
      }
    });
  }

  void _initializeFields(SignUpViewModel viewModel) {
    // Create controllers for each custom field
    // Only supports 'text' and 'document' types
    for (var field in viewModel.customFields) {
      if (field.type.toLowerCase() == 'document') {
        // For document type, initialize file as null
        _documentFiles[field.id] = null;
      } else {
        // For text type (or any other type defaults to text)
        _controllers[field.id] = TextEditingController();

        // Load existing value if in edit mode
        if (widget.isEditMode) {
          final existingValue = viewModel.step5Model.getFieldValue(field.id);
          if (existingValue != null) {
            _controllers[field.id]!.text = existingValue.toString();
            _fieldValues[field.id] = existingValue;
          }
        }
      }
    }
    setState(() {});
  }

  Widget _buildField(CustomFieldModel field, SignUpViewModel viewModel) {
    switch (field.type.toLowerCase()) {
      case 'text':
      case 'textarea':
        return _buildTextField(field, viewModel);
      case 'document':
        return _buildDocumentField(field, viewModel);
      default:
        // Default to text field for any unknown types
        return _buildTextField(field, viewModel);
    }
  }

  Widget _buildTextField(CustomFieldModel field, SignUpViewModel viewModel) {
    final controller = _controllers[field.id] ?? TextEditingController();
    if (!_controllers.containsKey(field.id)) {
      _controllers[field.id] = controller;
    }

    return TextFormField(
      controller: controller,
      maxLines: field.type.toLowerCase() == 'textarea' ? 4 : 1,
      maxLength: field.maxLength,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: ScreenUnitUtil.getFontSize(12),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (field.isRequired && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required';
        }
        if (field.maxLength != null &&
            value != null &&
            value.length > field.maxLength!) {
          return 'Maximum ${field.maxLength} characters allowed';
        }
        return null;
      },
      onChanged: (value) {
        _fieldValues[field.id] = value;
        viewModel.updateStep5Field(field.id, value);
      },
    );
  }

  Widget _buildDocumentField(CustomFieldModel field, SignUpViewModel viewModel) {
    final file = _documentFiles[field.id];
    final maxSizeMb = field.maxFileSizeMb ?? 20;
    final remoteUrl = viewModel.getDocumentUrl(field.id);
    final previewWidget = _buildDocumentPreview(file, remoteUrl);

    return FormField<File>(
      initialValue: file,
      validator: (val) {
        final hasRemoteFile = remoteUrl != null && remoteUrl.isNotEmpty;
        if (field.isRequired && val == null && !hasRemoteFile) {
          return '${field.label} is required';
        }
        if (val != null) {
          final fileSizeMb = val.lengthSync() / (1024 * 1024);
          if (fileSizeMb > maxSizeMb) {
            return 'File size must be less than ${maxSizeMb}MB';
          }
        }
        return null;
      },
      builder: (formFieldState) {
        final displayName = file?.path.split('/').last ??
            viewModel.step5Model.getFieldValue(field.id)?.toString() ??
            'Uploaded file';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label + (field.isRequired ? ' *' : ''),
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(16),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(8)),
            if (previewWidget != null) ...[
              previewWidget,
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
            ],
            if (file != null || (remoteUrl != null && remoteUrl.isNotEmpty))
              Container(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(
                    ScreenUnitUtil.getSpacing(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _documentFiles[field.id] = null;
                        _fieldValues[field.id] = null;
                        viewModel.updateStep5Field(
                          field.id,
                          null,
                        );
                        viewModel.clearDocumentUrl(field.id);
                        formFieldState.didChange(null);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  try {
                    // Show options: Camera or Gallery
                    final source = await showDialog<ImageSource>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Select Source'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Camera'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.camera),
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Gallery'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (source != null) {
                      final pickedFile = await picker.pickImage(source: source);
                      if (pickedFile != null) {
                        final file = File(pickedFile.path);
                        final fileSizeMb = file.lengthSync() / (1024 * 1024);

                        if (fileSizeMb > maxSizeMb) {
                          if (mounted) {
                            ToastMessage.showError(
                              'File size must be less than ${maxSizeMb}MB',
                              context,
                            );
                          }
                          return;
                        }

                        _documentFiles[field.id] = file;
                        _fieldValues[field.id] =
                            file.path; // Store file path temporarily
                        viewModel.clearDocumentUrl(field.id);
                        viewModel.updateStep5Field(
                          field.id,
                          file.path,
                        );
                        formFieldState.didChange(file);
                        setState(() {});
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ToastMessage.showError(
                        'Failed to pick image: ${e.toString()}',
                        context,
                      );
                    }
                  }
                },
                icon: Icon(Icons.upload_file),
                label: Text('Upload ${field.label}'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUnitUtil.getSpacing(16),
                    vertical: ScreenUnitUtil.getSpacing(12),
                  ),
                ),
              ),
            SizedBox(height: ScreenUnitUtil.getSpacing(4)),
            Text(
              'Maximum file size: ${maxSizeMb}MB',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(12),
                color: Colors.grey.shade600,
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: EdgeInsets.only(top: ScreenUnitUtil.getSpacing(4)),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: ScreenUnitUtil.getFontSize(12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget? _buildDocumentPreview(File? file, String? remoteUrl) {
    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
        child: Image.file(
          file,
          width: double.infinity,
          height: ScreenUnitUtil.getSpacing(150),
          fit: BoxFit.cover,
        ),
      );
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
        child: Image.network(
          remoteUrl,
          width: double.infinity,
          height: ScreenUnitUtil.getSpacing(150),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: ScreenUnitUtil.getSpacing(150),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: ScreenUnitUtil.getSpacing(150),
              color: Colors.grey.shade100,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: ScreenUnitUtil.getFontSize(32),
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Additional Information',
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
            // Debug logging
            debugPrint(
              'Step 6 Screen - isLoadingCustomFields: ${viewModel.isLoadingCustomFields}',
            );
            debugPrint(
              'Step 6 Screen - hasCustomFields: ${viewModel.hasCustomFields}',
            );
            debugPrint(
              'Step 6 Screen - customFields.length: ${viewModel.customFields.length}',
            );

            // Show loading while fetching custom fields
            if (viewModel.isLoadingCustomFields) {
              return Center(child: CircularProgressIndicator());
            }

            // If no custom fields, show message with debug info
            if (viewModel.customFields.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 64, color: Colors.grey),
                      SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                      Text(
                        'No additional information required',
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                      Text(
                        'hasCustomFields: ${viewModel.hasCustomFields}',
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(12),
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'customFields count: ${viewModel.customFields.length}',
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Indicator
                    StepIndicator(
                      currentStep: 6,
                      totalSteps: viewModel.hasCustomFields ? 6 : 5,
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                    // Custom Fields
                    ...viewModel.customFields.map((field) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: ScreenUnitUtil.getSpacing(16),
                        ),
                        child: _buildField(field, viewModel),
                      );
                    }).toList(),

                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                    // Submit Button
                    PrimaryButton(
                      text: widget.isEditMode
                          ? 'Update'
                          : 'Complete Registration',
                      isLoading: viewModel.isStepLoading,
                      onPressed: () => _handleSubmit(viewModel),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit(SignUpViewModel viewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Prepare files for upload - use field IDs as keys
    final filesToUpload = <int, File>{};
    for (var field in viewModel.customFields) {
      if (field.type.toLowerCase() == 'document') {
        final file = _documentFiles[field.id];
        if (file != null) {
          filesToUpload[field.id] = file;
        }
      }
    }

    final success = await viewModel.submitStep5(files: filesToUpload);
    if (success && mounted) {
      if (widget.isEditMode) {
        // In edit mode, go back to profile edit screen
        Navigator.pop(context, true);
        ToastMessage.showSuccess(
          'Custom fields updated successfully!',
          context,
        );
      } else {
        // Registration complete - clear all auth data and providers
        await AuthService.logout();
        viewModel.reset();

        // Navigate to login screen and clear navigation stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
        ToastMessage.showSuccess(
          'Registration completed successfully! Please login to continue.',
          context,
        );
      }
    } else if (mounted && viewModel.errorMessage != null) {
      ToastMessage.showError(viewModel.errorMessage!, context);
    }
  }
}
