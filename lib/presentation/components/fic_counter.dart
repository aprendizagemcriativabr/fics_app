import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/color.dart';

class FicCounter extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const FicCounter({super.key, required this.value, required this.onChanged});

  @override
  State<FicCounter> createState() => _FicCounterState();
}

class _FicCounterState extends State<FicCounter> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FicCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Value changed from outside (+/- buttons or parent): sync the text,
    // unless it already represents that value (e.g. user is mid-typing).
    if (oldWidget.value != widget.value) {
      final typed = int.tryParse(_controller.text) ?? 0;
      if (typed != widget.value) {
        final text = _focusNode.hasFocus
            ? widget.value.toString()
            : _format(widget.value);
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _format(int value) => value.toString().padLeft(2, '0');

  void _handleFocusChange() {
    final text = _focusNode.hasFocus
        ? widget.value.toString()
        : _format(widget.value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _selectAll() {
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  void _handleTextChanged(String text) {
    // Empty field counts as 0.
    final parsed = int.tryParse(text) ?? 0;
    if (parsed != widget.value) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final isDecrementDisabled = widget.value <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepButton(
          icon: Icons.remove,
          onTap:
              isDecrementDisabled ? null : () => widget.onChanged(widget.value - 1),
          isDisabled: isDecrementDisabled,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 112,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              cursorColor: AppColors.text,   
              cursorWidth: 2.5,
              enableSuggestions: false, 
              autocorrect: false,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.disabledButton,
                    width: 2,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.button, width: 2),
                ),
              ),
              onChanged: _handleTextChanged,
              onSubmitted: (_) => _focusNode.unfocus(),
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
        ),
        _buildStepButton(
          icon: Icons.add,
          onTap: () => widget.onChanged(widget.value + 1),
          isDisabled: false,
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.disabledButton : AppColors.button,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColors.disabledButtonText : AppColors.white,
          size: 30,
        ),
      ),
    );
  }
}