import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/unificar_planilhas.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_feedback.dart';
import '../viewmodels/unificar_planilhas_view_model.dart';
import '../../data/services/import_service.dart';
import '../utility/color.dart';
import 'dart:io';

class UnificarDadosPage extends StatelessWidget {
  const UnificarDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UnificarDadosViewModel(
        unificarPlanilhas: UnificarPlanilhas(
          ImportService(),
        ),
      ),
      child: Consumer<UnificarDadosViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.primaryYellow,
            appBar: const FicAppBar(
              title: "Unificar planilhas",
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "SELECIONE AS PLANILHAS PARA JUNTAR",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOTÃO DE ADICIONAR (Sempre disponível para clicar quantas vezes quiser)
                    ElevatedButton.icon(
                      onPressed: vm.isProcessing ? null : vm.pickMultipleFiles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryYellow,
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_to_photos),
                      label: const Text("Escolher Planilhas"),
                    ),

                    const SizedBox(height: 20),

                    // LISTA DE ARQUIVOS JÁ SELECIONADOS
                    Expanded(
                      child: vm.selectedFiles.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhum arquivo selecionado",
                                style: TextStyle(color: AppColors.text, fontStyle: FontStyle.italic),
                              ),
                            )
                          : ListView.separated(
                              itemCount: vm.selectedFiles.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final arquivo = vm.selectedFiles[index];
                                final nomeArquivo = arquivo.path.split(Platform.pathSeparator).last;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description, color: AppColors.text),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          nomeArquivo,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => vm.removerArquivo(arquivo),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    // BOTÃO DE EXECUTAR NO FINAL
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 16),
                      child: FicButton(
                        label: "UNIFICAR E EXPORTAR",
                        isLoading: vm.isProcessing,
                        onPressed: vm.canSubmit
                            ? () {
                                vm.executarUnificacaoEExportar(
                                  onSuccess: () {
                                    FicFeedback.show(
                                      context,
                                      message: "Planilha unificada e salva com sucesso!",
                                      type: FeedbackType.success,
                                    );
                                  },
                                  onError: (msg) {
                                    FicFeedback.show(
                                      context,
                                      message: "Erro ao processar: $msg",
                                      type: FeedbackType.error,
                                    );
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}