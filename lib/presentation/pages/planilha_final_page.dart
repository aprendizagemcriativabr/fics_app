import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/unificar_planilhas.dart';
import '../../data/services/import_service.dart';
import '../../data/services/share_service.dart'; 
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_feedback.dart';
import '../viewmodels/unificar_planilhas_view_model.dart';
import '../utility/color.dart';

class UnificarDadosPage extends StatelessWidget {
  const UnificarDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UnificarDadosViewModel(
        unificarPlanilhas: UnificarPlanilhas(
          ImportService(),
        ),
        shareService: ShareService(), 
      ),
      child: Consumer<UnificarDadosViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.primaryYellow,
            appBar: FicAppBar(
              title: "Unificar planilhas",
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.text,
                  ),
                  onPressed: vm.isProcessing 
                      ? null 
                      : () {
                          vm.compartilharPlanilha(
                            onAvisoGerarPrimeiro: () {
                              FicFeedback.show(
                                context,
                                message: "Gere e exporte a planilha unificada primeiro.",
                                type: FeedbackType.error,
                              );
                            },
                            onError: (mensagemErro) {
                              FicFeedback.show(
                                context,
                                message: "Erro ao compartilhar: $mensagemErro",
                                type: FeedbackType.error,
                              );
                            },
                          );
                        },
                ),
              ],
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

                    Expanded(
                      child: _buildListaArquivos(context, vm),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 16),
                      child: FicButton(
                        label: "UNIFICAR E EXPORTAR",
                        isLoading: vm.isProcessing,
                        onPressed: vm.canSubmit
                            ? () {
                                if (vm.selectedFiles.length < 2) {
                                  FicFeedback.show(
                                    context,
                                    message: "Selecione ao menos duas planilhas para poder unificar os dados.",
                                    type: FeedbackType.error,
                                  );
                                  return;
                                }

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
                                      message: msg,
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

  Widget _buildListaArquivos(BuildContext context, UnificarDadosViewModel vm) {
    if (vm.selectedFiles.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum arquivo selecionado",
          style: TextStyle(color: AppColors.text, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: [
        if (vm.selectedFiles.length == 1)
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            key: ValueKey('aviso_um_arquivo'),
            child: Text(
              "⚠️ Selecione mais 1 planilha para poder unificar.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text, 
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: vm.selectedFiles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final arquivo = vm.selectedFiles[index];
              final nomeArquivo = arquivo.path.split(Platform.pathSeparator).last;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(128),
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
      ],
    );
  }
}