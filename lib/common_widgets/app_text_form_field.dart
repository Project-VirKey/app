import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    Key? key,
    required this.labelText,
    this.onFieldSubmitted,
    required this.onSaved,
    required this.validator,
    required this.textInputAction,
    required this.focusNode,
    this.nextFieldFocusNode,
  }) : super(key: key);

  final String labelText;
  final dynamic onFieldSubmitted;
  final Function(String?) onSaved;
  final Function(String?) validator;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final FocusNode? nextFieldFocusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        FocusScope.of(context).requestFocus(focusNode),
      },
      child: TextFormField(
        focusNode: focusNode,
        validator: (value) {
          return validator(value);
        },
        onSaved: (value) {
          onSaved(value);
        },
        onFieldSubmitted: (value) {
          // if true -> there is a following field
          if (textInputAction == TextInputAction.next) {
            // set the focus to the following field through the passed focus node
            FocusScope.of(context).requestFocus(nextFieldFocusNode);
          }
        },
        textInputAction: textInputAction,
        maxLines: 1,
        minLines: 1,
        style: const TextStyle(
            letterSpacing: 3, fontSize: 16, fontWeight: AppFonts.weightLight),
        decoration: InputDecoration(
          isDense: true,
          labelText: labelText,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
