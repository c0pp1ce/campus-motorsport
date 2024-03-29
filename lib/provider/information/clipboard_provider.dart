import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_clipboards.dart';

class ClipboardProvider extends BaseProvider {
  ClipboardProvider() {
    getAll();
  }

  List<Clipboard>? _clipboards;
  bool _alreadyRequestedUpdate = false;

  Future<void> getAll() async {
    _clipboards = await CrudClipboards().getAll();
    notify();
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    final crud = CrudClipboards();
    final success = await crud.update(id, data);
    if (success && _clipboards != null) {
      final Clipboard? clipboard = await crud.getOne(id);
      if (clipboard != null) {
        final int i = _clipboards!.indexWhere(
          (element) => element.id == clipboard.id,
        );
        if (i >= 0) {
          _clipboards![i] = clipboard;
        }
      }
    }
    notify();
    return success;
  }

  Future<bool> create(Clipboard clipboard) async {
    final crud = CrudClipboards();
    final success = await crud.create(clipboard);
    if (success) {
      _clipboards = await crud.getAll();
    }
    notify();
    return success;
  }

  Future<bool> delete(String id) async {
    final success = await CrudClipboards().delete(id);
    if (success && _clipboards != null) {
      _clipboards!.removeWhere((element) => element.id == id);
    }
    notify();
    return success;
  }

  List<Clipboard> get clipboards {
    if (_clipboards == null && !_alreadyRequestedUpdate) {
      _alreadyRequestedUpdate = true;
      CrudClipboards().getAll().then((value) => notify());
      return [];
    }
    return _clipboards ?? [];
  }
}
