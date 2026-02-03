import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../routes/route_names.dart';

/// Declaration Screen - First Agreement Screen
class DeclarationScreen extends StatefulWidget {
  final bool isEditMode;
  
  const DeclarationScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<DeclarationScreen> createState() => _DeclarationScreenState();
}

class _DeclarationScreenState extends State<DeclarationScreen> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Declaration',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUnitUtil.getSpacing(24),
                  vertical: ScreenUnitUtil.getSpacing(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DECLARATION',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(24),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    Text(
                      'I declare that the information given in this application form is true and complete. I understand that if I have given any misleading information on this form or made any omissions, this will be sufficient grounds for terminating my employment. The information provided by you on this form as an applicant will be stored either on paper records or a computer system in accordance with the Data Protection Act 2018 and will be processed solely in connection with recruitment.',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildDeclarationItem(
                      '1. I state that I have chosen to waive the EEC working time directive for a maximum of 48 hours per week and recognize that I am responsible for my own health and wellbeing if I work excess hours.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '2. I agree to the company policy in regards to a £100 penalty being imposed on me if I do not attend a shift designated to me or I provide less than12hrs notice of my absence prior to a shift without a valid reason.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '3. I agree to wear the full uniform and obey the company\'s health and safety policy, particularly in regards to uniform and safety wear. If I am found not obeying the policy I can be fined a penalty.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '4. If I am using the company\'s provided transport, I agree to be collected from my designated pickup point and I will arrive at this pickup point on time.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '5. I agree that I will not possess, use, transport, smoke, trade, or deal with any illegal or abstained substances and drugs including alcohol during my working hours with the company. I will also not arrive on a working shift under the influence of such. If found to be undertaking any of the above it will be considered as gross misconduct.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '6. I agree to at all working times within the company to be in a smart and clean kept appearance.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDeclarationItem(
                      '7. High levels of personal hygiene will be maintained. Hair will be tidy and well groomed; if a necessity my hair will be tied or restrained. Jewellery items, including earrings, necklaces, nose piercings and studs will be discreet and not impose on my personal health and safety.',
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    
                    // Agreement Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _hasAgreed,
                          onChanged: (value) {
                            setState(() {
                              _hasAgreed = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: ScreenUnitUtil.getSpacing(12)),
                            child: Text(
                              'I have read and agree to the above declaration',
                              style: TextStyle(
                                fontSize: ScreenUnitUtil.getFontSize(14),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  ],
                ),
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Back'),
                    ),
                  ),
                  SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Continue',
                      onPressed: _hasAgreed ? () => _handleContinue() : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclarationItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ScreenUnitUtil.getFontSize(14),
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  void _handleContinue() {
    if (!_hasAgreed) return;
    
    final viewModel = context.read<SignUpViewModel>();
    viewModel.setDeclarationAgreed(true);
    
    Navigator.pushNamed(
      context,
      RouteNames.termsConditions,
      arguments: {'isEditMode': widget.isEditMode},
    );
  }
}
