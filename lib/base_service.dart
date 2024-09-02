import 'package:get_it/get_it.dart';
import 'package:money_manager/database/db_helper.dart';
import 'package:money_manager/route/record_manage_provider.dart';

final sl = GetIt.instance;
setup() async {
  sl.registerSingletonAsync<DbHelper>(() async {
    DbHelper dbProvider = DbHelper();
    await dbProvider.initDB();
    return dbProvider;
  });
  sl.registerLazySingleton(() => RecordManageProvider());
  await sl.allReady();
  return sl;
}
