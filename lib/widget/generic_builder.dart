import 'package:flutter/material.dart';

class GenericBuilder<T> extends StatefulWidget {
  const GenericBuilder({super.key, required this.future, this.initialData, required this.builder});

  final Future<T>? future;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;
  static bool debugRethrowError = false;

  @override
  State<GenericBuilder<T>> createState() => _GenericBuilderState<T>();
}

class _GenericBuilderState<T> extends State<GenericBuilder<T>> {
  Object? _activeCallbackIdentity;
  late AsyncSnapshot<T> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.initialData == null ? AsyncSnapshot<T>.nothing() : AsyncSnapshot<T>.withData(ConnectionState.none, widget.initialData as T);
    _subscribe();
  }

  @override
  void didUpdateWidget(GenericBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future == widget.future) return;
    if (_activeCallbackIdentity != null) {
      _unsubscribe();
      _snapshot = _snapshot.inState(ConnectionState.none);
    }
    _subscribe();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _snapshot);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.future == null) return;
    final Object callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;
    widget.future!.then<void>((T data) {
      if (_activeCallbackIdentity == callbackIdentity) {
        setState(() => _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data));
      }
    }, onError: (Object error, StackTrace stackTrace) {
      if (_activeCallbackIdentity == callbackIdentity) {
        setState(() => _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, error, stackTrace));
      }
      assert(() {
        if (GenericBuilder.debugRethrowError) {
          Future<Object>.error(error, stackTrace);
        }
        return true;
      }());
    });
    if (_snapshot.connectionState != ConnectionState.done) {
      _snapshot = _snapshot.inState(ConnectionState.waiting);
    }
  }

  void _unsubscribe() => _activeCallbackIdentity = null;
}
