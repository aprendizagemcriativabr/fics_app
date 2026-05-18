import 'package:flutter/material.dart';
import '../viewmodels/pessoa_view_model.dart';
import '../utility/color.dart';

class FiltroModal extends StatefulWidget {
  final FiltroStatus statusInicial;
  final bool ordemAzInicial;

  const FiltroModal({
    super.key,
    required this.statusInicial,
    required this.ordemAzInicial,
  });

  @override
  State<FiltroModal> createState() => _FiltroModalState();
}

class _FiltroModalState extends State<FiltroModal> {
  late FiltroStatus statusSelecionado;
  late bool ordemAz;

  @override
  void initState() {
    super.initState();
    statusSelecionado = widget.statusInicial;
    ordemAz = widget.ordemAzInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "STATUS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          /// NOVO RadioGroup
          RadioGroup<FiltroStatus>(
            groupValue: statusSelecionado,
            onChanged: (FiltroStatus? value) {
              setState(() {
                statusSelecionado = value!;
              });
            },
            child: Column(
              children: [
                _buildRadio("TODOS", FiltroStatus.todos),
                _buildRadio("PENDENTES", FiltroStatus.pendentes),
                _buildRadio("VALIDADOS", FiltroStatus.validados),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "ORDENAR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                ordemAz = !ordemAz;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Text(
                ordemAz ? "A → Z" : "Z → A",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: _buildButton(
                  "LIMPAR\nFILTROS",
                  () {
                    Navigator.pop(context, {
                      'status': FiltroStatus.todos,
                      'ordem': true,
                    });
                  },
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  "APLICAR",
                  () {
                    Navigator.pop(context, {
                      'status': statusSelecionado,
                      'ordem': ordemAz,
                    });
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(String label, FiltroStatus value) {
    return RadioListTile<FiltroStatus>(
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      value: value,
      activeColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildButton(
    String label,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? AppColors.secondaryYellow : Colors.grey.shade200,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
