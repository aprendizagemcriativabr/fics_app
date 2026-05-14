import 'package:fics_app_new/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DATA
import 'data/datasources/pessoa_datasource.dart';
import 'data/repositories/pessoa_repository_impl.dart';

// DOMAIN
import 'domain/usecases/get_pessoas.dart';
import 'domain/usecases/atualizar_acompanhantes.dart';
import 'domain/usecases/importar_pessoas.dart';
import 'domain/usecases/add_pessoa.dart';

// PRESENTATION
import 'presentation/viewmodels/pessoa_view_model.dart';

// COLORS
import 'package:fics_app_new/presentation/utility/color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dataSource = PessoaDataSource();
  final repository = PessoaRepositoryImpl(dataSource);

  final getPessoas = GetPessoas(repository);
  final atualizar = AtualizarAcompanhantes(repository);
  final importar = ImportarPessoas(repository);
  final addPessoa = AddPessoa(repository);

  runApp(MyApp(
    getPessoas: getPessoas,
    atualizar: atualizar,
    importar: importar,
    addPessoa: addPessoa,
  ));
}

class MyApp extends StatelessWidget {
  final GetPessoas getPessoas;
  final AtualizarAcompanhantes atualizar;
  final ImportarPessoas importar;
  final AddPessoa addPessoa;

  const MyApp({
    super.key,
    required this.getPessoas,
    required this.atualizar,
    required this.importar,
    required this.addPessoa,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              PessoaViewModel(getPessoas, atualizar, importar, addPessoa)..carregar(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FIC App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryYellow,
            primary:
                AppColors.primaryYellow, 
          ),
          scaffoldBackgroundColor: AppColors.primaryYellow,
          appBarTheme: const AppBarTheme(
            surfaceTintColor:
                Colors.transparent, // Remove o escurecimento na rolagem
            backgroundColor: AppColors.primaryYellow,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
