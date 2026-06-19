import 'package:fics_app_new/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// DATA
import 'data/datasources/pessoa_datasource.dart';
import 'data/repositories/pessoa_repository_impl.dart';
import 'data/models/pessoa_model.dart';
import 'data/mappers/pessoa_model_mapper.dart';
import 'data/services/share_service.dart';

// DOMAIN
import 'domain/usecases/get_pessoas.dart';
import 'domain/usecases/atualizar_acompanhantes.dart';
import 'domain/usecases/importar_pessoas.dart';
import 'domain/usecases/add_pessoa.dart';
import 'domain/usecases/deletar_pessoas.dart';

// PRESENTATION
import 'presentation/viewmodels/pessoa_view_model.dart';
import 'presentation/viewmodels/planilha_view_model.dart';

// COLORS
import 'package:fics_app_new/presentation/utility/color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// HIVE
  await Hive.initFlutter();

  Hive.registerAdapter(PessoaModelAdapter());

  await Hive.openBox<PessoaModel>('pessoas');

  /// DATASOURCE
  final dataSource = PessoaDataSource();

  /// MAPPER
  final mapper = PessoaModelMapper();

  /// REPOSITORY
  final repository = PessoaRepositoryImpl(
    datasource: dataSource,
    mapper: mapper,
  );

  /// SERVICES
  final shareService = ShareService();

  /// USECASES
  final getPessoas = GetPessoas(repository);

  final atualizar = AtualizarAcompanhantes(repository);

  final importar = ImportarPessoas(repository);

  final addPessoa = AddPessoa(repository);

  final deletarTodasPessoasUseCase = DeletarTodasPessoasUseCase(repository);

  runApp(
    MyApp(
      getPessoas: getPessoas,
      atualizar: atualizar,
      importar: importar,
      addPessoa: addPessoa,
      deletarTodasPessoasUseCase: deletarTodasPessoasUseCase,
      shareService: shareService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetPessoas getPessoas;
  final AtualizarAcompanhantes atualizar;
  final ImportarPessoas importar;
  final AddPessoa addPessoa;
  final DeletarTodasPessoasUseCase deletarTodasPessoasUseCase;
  final ShareService shareService;

  const MyApp({
    super.key,
    required this.getPessoas,
    required this.atualizar,
    required this.importar,
    required this.addPessoa,
    required this.deletarTodasPessoasUseCase,
    required this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// PESSOAS
        ChangeNotifierProvider(
          create: (_) => PessoaViewModel(
            getPessoas,
            atualizar,
            importar,
            addPessoa,
            deletarTodasPessoasUseCase,
          )..carregar(),
        ),

        /// PLANILHA
        ChangeNotifierProvider(
          create: (_) => PlanilhaViewModel(
            getPessoas,
            shareService,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FIC App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryYellow,
            primary: AppColors.primaryYellow,
          ),
          scaffoldBackgroundColor: AppColors.primaryYellow,
          appBarTheme: const AppBarTheme(
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.primaryYellow,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
