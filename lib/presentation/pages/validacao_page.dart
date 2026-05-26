import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';
import 'package:fics_app_new/presentation/utility/color.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_counter.dart';

class ValidacaoPage extends StatefulWidget {
  final Pessoa pessoa;

  const ValidacaoPage({
    super.key,
    required this.pessoa,
  });

  @override
  State<ValidacaoPage> createState() => _ValidacaoPageState();
}

class _ValidacaoPageState extends State<ValidacaoPage> {
  late int qtd;

  @override
  void initState() {
    qtd = widget.pessoa.acompanhantes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PessoaViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: const FicAppBar(
        title: "Confirmação de\nAcompanhantes",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOPO FIXO
              Text(
                "NOME DO RESPONSÁVEL",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.pessoa.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              /// CONTEÚDO CENTRAL
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "QUANTIDADE DE\nACOMPANHANTES",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FicCounter(
                        value: qtd,
                        onChanged: (newValue) {
                          if (newValue >= 0) {
                            setState(() {
                              qtd = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// BOTÃO NO FINAL
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FicButton(
                  label: "Confirmar Check-in",
                  isLoading: vm.isLoading,
                  onPressed: () async {
                    await vm.atualizarQtd(
                      widget.pessoa.nome,
                      qtd,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
