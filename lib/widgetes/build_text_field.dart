import 'package:flutter/material.dart';

Widget buildTextField(
    {required String label,
    context,
    required TextEditingController controller,
    FocusNode? cruntFocusNode,
    FocusNode? nextFocusNode,
    int maxLin = 1,
    int minLin = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: TextFormField(
      controller: controller,
      focusNode: cruntFocusNode,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(nextFocusNode);
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLin,
      minLines: minLin,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "الرجاء إدخال $label";
        }
        return null;
      },
    ),
  );
}
