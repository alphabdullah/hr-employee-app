import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/components/primary_button.dart';
import '../../routes/route_names.dart';

/// Terms & Conditions Screen - Second Agreement Screen
class TermsConditionsScreen extends StatefulWidget {
  final bool isEditMode;
  
  const TermsConditionsScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
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
                    _buildSection(
                      '1. DEFINITIONS',
                      [
                        '1.1 In these Terms and Conditions the Following Apply:',
                        '"The Assignment" means the period during which the Employee is supplied to render services to the Client',
                        '"The Client" means the person, firm or corporate body requiring the services of the employee together with any subsidiary or associated company as defined by the Companies Act 1985',
                        '"The Employer" means Premier Support Solutions Ltd, or whose registered offices are based at 42-44 Regal Court, High Street, Slough SL1 1EL. Whether with any subsidiary or associated company as defined by the Companies Act 1985',
                        '"Relevant Period" means the longer period of either 14 weeks from the first day on which the employee worked for the Client or 8 weeks from the day the Employee was last supplied by the Employer to the Client',
                        '"The Employee" means the person named above',
                        '1.2 Unless context otherwise requires, reference to the singular includes the plural and reference to the masculine includes the feminine and view versa',
                        '1.3 The headings contained in these Terms & Conditions are for convenience only and do not affect their interpretation.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '2. THE CONTRACT',
                      [
                        '2.1 In terms of the Employment Act 1966 (The Act) this document gives details of your terms and conditions of employment with the employer, as at the date of the first assignment. No employment with a previous employer count as part of your period of continuous employment with the employer.',
                        '2.2 These Terms & Conditions govern all Assignments undertaken by the employee.',
                        '2.3 The employer reserves the absolute right to vary or change any of these Terms & Conditions of employment',
                        '2.4 The Employee will be given not less than one month\'s notice of any significant changes, which may be given by way of an individual or general notice. The Employee will be deemed to have accepter those changes at the expiry of the notice period. If the Employee objects to the changes, then they must notify the Employer accordingly in writing before the expiry of the notice period however the Employers right to vary or change these Terms & Conditions remains absolute.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '3. ASSIGNMENTS',
                      [
                        '3.1 The Employer will endeavour to obtain suitable assignments for the Employee. The Employee acknowledges that the nature of flexible work means that there may be periods when no suitable work is available and agrees: that the suitability of the work to be offered shall be determined solely by the Employer, that you may be transferred to a new assignment at any time, without restriction to location or Client, as directed by the Employer. The Employer agrees that the Employer or the Client may terminate an Assignment at any time without prior notice or liability. Termination of an Assignment is not Termination of your Employment.',
                        '3.2 At the same time as an Assignment is offered to the Employee the Employee shall inform the Employee of the identity of the Client, and if applicable the nature of their business, The date the Assignment is to commence and the duration or likely duration of the Assignment; the type of work, location and hours during which the Employee would be required to work; the remuneration that will be paid and any expenses payable by or to the Employee; and any risks to health & safety known to the Client in relation to the Assignment and the steps the Client considers necessary or which are required by law to work in the Assignment.',
                        '3.3 Where such information is not given in paper form or by electronic means it shall be confirmed by such means by the end of the third business say (excluding Saturday, Sunday and any public or bank holiday) following where:',
                        '3.3.1 The Employee is being offered an Assignment in the same position as one in which the Employee had previously been supplied within the last 5business days and such information has already been given to the Employee; or',
                        '3.3.2 Where, subject to clause 3.5 the Assignment is intended to last for 5 consecutive days or less and such information has previously been given to the Employee before and remains unchanged.',
                        '3.4 Where an Assignment is for five consecutive working days or less and the provisions of clause 3.3.2 are met, the Employer need only provide the Employee with written confirmation of the Identity of the Client and the likely duration of the Assignment. If the Assignment extends beyond the intended five consecutive workings day period the Employer shall provide such information as set out in clause 3.3 to the Employee in paper or electronic form within 8 days of the start of the Assignment',
                        '3.5 For the purpose of calculating the average number of weekly hours worked by the Employee on an Assignment, the Start date for the relevant averaging period under the Working Time Regulations shall be the date on which the Employee commences the first Assignment.',
                        '3.6 If, before the first Assignment, during the course of the Assignment or within the Relevant Period the Client wishes to employ the Employee direct or through another Employer, The Employee acknowledges that the Employer will be entitled either to charge the Client a fee or agree to an extension of the hiring period with the Client at the end of which the Employee may be engaged directly with the Client or through another Employer without further charge to the Client. In addition, the Employer will be entitled to charge a fee to the Client if the Client introduces the Employee to a third party who subsequently engages the Employee within the Relevant Period.',
                        'Regal Court, 42-44 High Street, Slough, SL1 1EL Mobile: 07809439408',
                        '3.7 It is a condition of your employment that you undertake Assignments when required by the Employer if without good cause, you decline or refuse to work on any particular Assignments then the same shall be regarded as gross misconduct entitling the Employer to terminate your employment.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '4 REMUNERATIONS',
                      [
                        '4.1 The Employer shall pay to the Employee remuneration calculated at no less than the statutory minimum hourly rate for all hours worked. The actual rate will be notified on a per Assignment basis, for each hour worked during an Assignment (to the nearest quarter of an hour) is to be paid weekly in arrears, subject to deductions in respect of PAYE, and Class 1 National Insurance Contributions and any other deductions which the Employer may be required by law to make. For the purpose of the Employment Rights Act 1966 sections 13-27, the Employee agrees that the Employer may deduct from their remuneration any sums due from the Employee to the Employer including without limitations any overpayments, holiday pay, loans or advance made to you by the Employer.',
                        '4.2 Subject to any statutory entitlement under the relevant legislation, The Employee is not entitled to receive payments from the Employer or Clients for the time not spent on Assignment, whether in respect of holidays, illness or absence for any other reason unless otherwise agreed.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '5 STATUTORY LEAVE',
                      [
                        '5.1 Entitlement to payment for leave accrues in proportion to the amount of time worked continuously by the Employee on Assignment during the leave year. The amount of payment which the Employee will receive in respect of periods of annual leave taken during the course of an Assignment, will be calculated in accordance with and paid in proportion to the number of hours that the Employee has worked on his Assignment. Payments for annual leave will be calculated on the basis of rates paid during a client\'s normal working hours i.e. those that do not attract overtime rates of pay.',
                        '5.2 Where the Employee wishes to take any paid leave to which they are entitled, they should notify the Employer in writing of the dates of their intended absence. The amount of notice, which the Employee is required to give, should be at least twice the length of the period of leave they wish to take. Unless the Employer informs the Employee in writing that it is not possible for them to take leave on the specified dates the Employee shall be entitled to take up their notified leave entitlement. Annual leave requests may be refused during periods of high demands.',
                        '5.3 For the purposes of calculating entitlement to paid annual leave pursuant to the Working Time Regulations1998, the leave year commences on first January.',
                        '5.4 Under the Working Time (Amendment) Regulations 2007, the Employee is entitled to twenty-eight days paid leave per leave year. All entitlement leave must be taken during the course of the leave year in which it accrues and none may be carried forward to the next year.',
                        '5.5 In the case of any assignment, The Employee is entitled request lease at the rate of one-twelfth of their total holiday entitlement in each month of their leave year.',
                        '5.6 The Employer may at his discretion request the Employee upon giving one weeks\' notice to take a public holiday as part of their annual leave entitlement.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '6 SICKNESS ABSENCE',
                      [
                        '6.1 The Employee may be eligible for Statutory Sick Pay provided that they meet the relevant statutory criteria.',
                        '6.2 For the purposes of the Statutory Sick Pay Scheme there is one Qualifying day per week during the course of an Assignment and that qualifying day shall be a Wednesday of every week.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '7 TIME SHEETS',
                      [
                        '7.1 At the end of each week of an Assignment (or at the end of the Assignment where it is for a period of less than one week) the Employee shall deliver to the Employer their time sheet duly completed to indicate the number of hours worked by them during the preceding week (or such lesser period) and signed by an authorised representative of the Client',
                        '7.2 Subject to clause 7.3 The Employer shall pay the Employee for all hours worked regardless of whether the Employer has received payment form the client for those hours.',
                        '7.3 Where the Employee fails to submit a properly authenticated timesheet the Employer shall in a timely fashion conduct further investigations into the hours claimed by the Employee and the reasons that the Client has refused to sign a timesheet in respect of those hours. This may delay any payment due to the Employee. The Employer shall make no payment to the Employee for hours not worked.',
                        '7.4 For the avoidance of doubt and for the purposes of the Working Time Regulations, the Employees working time shall only consist of those periods during which they are carrying out their activities or duties for the Client as part of the Assignment. Time spent travelling to the Clients premises, lunch breaks, and other rest breaks shall not count as part of the Employers working time for these purposes.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '8 CONDUCTS OF ASSIGNMENTS',
                      [
                        '8.1 The Employee will be assigned from time to time to carry work out under the direction of the Employer\'s Clients and will during every Assignment and afterwards, where appropriate;',
                        '(a) Co-operate with Clients reasonable instructions and accept the direction, supervision and control of any responsible person at the Clients organization',
                        '(b) Observe any relevant rules and regulations of the Clients establishment (including normal hours of work) to which attention has been drawn or which the Employee might reasonably be expected to ascertain;',
                        '(c) Take all reasonable steps to safeguard their own health& Safety and the safety of any other person who may be present or affected by their actions on the Assignment and comply with the health & safety policies and procedures of the Client;',
                        '(d) Not engage in any conduct detrimental to the interests of the Client',
                        'Regal Court, 42-44 High Street, Slough, SL1 1EL Mobile: 07809439408',
                        '(e) Not at any time divulge to any person, nor use for their own or any other persons benefit any confidential information relating to the Client\'s or the Employers Employees, business affairs, transactions or finances. These restrictions apply to both while the Employee is employed by the Employer and after the Employment is terminated. The restrictions will cease to apply to any information which becomes generally available to the public other than through a failure by the Employee to observe these restrictions',
                        '8.2 If the Employee is unable for any reason to attend work during or before the Assignment, they should inform the Employer and/or the Client by no later than 4 hours prior to the start time of the Assignment or shift to enable alternative arrangements to be made.',
                        '8.3 If, either before or during the course of an Assignment, the Employee becomes aware of any reason why they may not be suitable for an Assignment, they shall notify the Employer without delay.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '9 PLACE OF WORK',
                      [
                        '9.1 You will not be regarded as having a normal place of work and you will be required to work at any of the Client\'s premises as the Employer may require from time to time. The Employer may change your place of work by giving you such notice as is reasonably practical in the circumstances.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '10 AGE DISCRIMINATION',
                      [
                        '10.1 The Employer is committed to implementing the provisions of the Employment Equality (age) Regulations 2006 and it does not have a policy of normal automatic retirement age of 65. In the event that you are in the Employ of the Employer on or beyond your 65th birthday and you are served with a Notice of intention to terminate your employment by the reason of retirement then you still have the right to continue working beyond the then stated intended time of retirement age and the Employer will consider that request. Any such requests must be made in writing and in accordance with the Employment Equality (age) Regulations 2006 and the Employers policies and procedures.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '11 DATA PROTECTION',
                      [
                        '11.1 By signing these Terms & Conditions, The Employee acknowledges and agrees that the Employer is permitted to hold personal information about you as part of its personnel and other business records and that the Employer may use such information in the course of the Employers business.',
                        '11.2 The Employee agrees that the Employer may disclose information about them to third parties if the Employer considers to do so, and is required for the proper conduct of the Employer\'s business or that of any associated company. Clause 11 applies to information held, used or disclosed in any medium.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '12 PREVIOUS CONTRACTS',
                      [
                        '12.1 Any contract of employment was previously issued to you by the Employer will cease to have any effect on the date upon which you commence work under this contract. This contract will supersede any previous contract, whether "of employment" or "for services"',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '13 TERMINATION',
                      [
                        '13.1 If you wish to terminate your employment you must give the Employer one weeks\' notice in writing.',
                        '13.2 The Employer must give you the following periods of prior written notice to terminate your employment:',
                        '(a) Immediate notice if you have been continuously employed for less than 4 weeks',
                        '(b) Two weeks\' notice if you have been continuously employed for more than 4 weeks but less than two years.',
                        '(c) Three weeks\' notice if you have been continuously employed for more than 2 years but less than three years. With an additional weeks\' notice for every year of continues employment thereafter up to a maximum of 13 weeks for 12 or more years of continuous employment whichever is greater.',
                        '13.3 There is no guarantee that work will be available during any notice period',
                        '13.4 The company reserves the right to terminate your employment without notice in the event of gross misconduct',
                        '13.5 When you are not on an Assignment you are obliged to contact the Employer at regular intervals to confirm your availability to undertake further Assignments. If you do terminate your employment in accordance with clause 13.1 above, then in the event you fail to contact the Employer for any continuous period of four weeks following the end of your last Assignment, you expressly agree that you will be deemed to have given notice of termination of your employment with immediate effect and the Employer reserves the right to forward the Employee\'s P45 to their last known address.',
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    _buildSection(
                      '14 LAW',
                      [
                        '15 These terms are governed by the law of England and Wales and are subject to the Exclusive jurisdiction of the courts of England and Wales.',
                      ],
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
                              'I have read and agree to the Terms & Conditions',
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

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: ScreenUnitUtil.getSpacing(8)),
          child: Text(
            item,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        )),
      ],
    );
  }

  void _handleContinue() {
    if (!_hasAgreed) return;
    
    final viewModel = context.read<SignUpViewModel>();
    viewModel.setTermsConditionsAgreed(true);
    
    Navigator.pushReplacementNamed(
      context,
      RouteNames.signUpStep4,
      arguments: {'isEditMode': widget.isEditMode},
    );
  }
}
