import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../utils/screen_unit_util.dart';

/// Reusable Skills Selector Widget
/// Used in Sign Up and Profile screens
class SkillsSelector extends StatelessWidget {
  final List<String> selectedSkills;
  final List<String> availableSkills;
  final bool isLoadingSkills;
  final Function(String) onAddSkill;
  final Function(String) onRemoveSkill;
  final bool isRequired;
  final String? Function(List<String>)? validator;
  final String dropdownKeyPrefix;

  const SkillsSelector({
    super.key,
    required this.selectedSkills,
    required this.availableSkills,
    required this.isLoadingSkills,
    required this.onAddSkill,
    required this.onRemoveSkill,
    this.isRequired = false,
    this.validator,
    this.dropdownKeyPrefix = 'skill_dropdown',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isRequired ? 'Skills *' : 'Skills',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(16),
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(width: ScreenUnitUtil.getSpacing(8)),
            Text(
              '(${selectedSkills.length}/8)',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(14),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(12)),
        
        // Selected Skills Chips
        if (selectedSkills.isNotEmpty)
          Wrap(
            spacing: ScreenUnitUtil.getSpacing(8),
            runSpacing: ScreenUnitUtil.getSpacing(8),
            children: selectedSkills.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: () {
                  onRemoveSkill(skill);
                },
                deleteIcon: Icon(
                  Icons.close,
                  size: ScreenUnitUtil.getFontSize(18),
                ),
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                deleteIconColor: AppColors.secondary,
                labelStyle: TextStyle(
                  color: AppColors.secondary,
                  fontSize: ScreenUnitUtil.getFontSize(14),
                ),
              );
            }).toList(),
          ),
        
        SizedBox(height: ScreenUnitUtil.getSpacing(12)),
        
        // Skill Dropdown - Only show if there are available skills to select and limit not reached
        if (selectedSkills.length < 8 && 
            availableSkills.any((skill) => !selectedSkills.contains(skill)))
          isLoadingSkills
              ? Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUnitUtil.getSpacing(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: ScreenUnitUtil.getFontSize(20),
                        height: ScreenUnitUtil.getFontSize(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUnitUtil.getSpacing(12)),
                      Text(
                        'Loading skills...',
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(14),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : availableSkills.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ScreenUnitUtil.getSpacing(8),
                        ),
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
                              'Unable to load skills. Please try again later.',
                              style: TextStyle(
                                fontSize: ScreenUnitUtil.getFontSize(14),
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      // Use key that changes when skills are added to force rebuild
                      key: ValueKey('${dropdownKeyPrefix}_${selectedSkills.length}'),
                      decoration: InputDecoration(
                        labelText: 'Add Skill',
                        hintText: 'Select a skill to add',
                        prefixIcon: Icon(
                          Icons.add_circle_outline,
                          size: ScreenUnitUtil.getFontSize(20),
                        ),
                      ),
                      items: availableSkills
                          .where((skill) => !selectedSkills.contains(skill))
                          .map((skill) {
                        return DropdownMenuItem<String>(
                          value: skill,
                          child: Text(skill),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onAddSkill(value);
                        }
                      },
                      validator: validator != null
                          ? (_) => validator!(selectedSkills)
                          : null,
                    ),
        
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          isRequired
              ? 'Select at least 1 skill and maximum 8 skills'
              : 'Maximum 8 skills allowed',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(12),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
