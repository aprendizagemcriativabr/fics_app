import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> compartilharArquivoLocal({
    required String caminhoArquivoOriginal,
  }) async {
    final arquivoOriginal = File(caminhoArquivoOriginal);

    if (!await arquivoOriginal.exists()) {
      throw Exception(
        "O arquivo físico não foi localizado. Gere ou baixe o documento novamente.",
      );
    }

    final dirTemporario = await getTemporaryDirectory();
    final nomeArquivo = caminhoArquivoOriginal.split(Platform.pathSeparator).last;
    final caminhoTemporario = '${dirTemporario.path}/$nomeArquivo';
    final arquivoTemporario = File(caminhoTemporario);

    await arquivoOriginal.copy(caminhoTemporario);

    await Share.shareXFiles([
      XFile(arquivoTemporario.path),
    ]);
  }
}