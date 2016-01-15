library rx.operators.pluck;

import 'package:rxdart/src/observable/stream.dart';

class PluckObservable<T, S> extends StreamObservable<T> {

  StreamController<S> controller;

  PluckObservable(Stream<T> stream, List<dynamic> sequence, {bool throwOnNull: false}) {
    StreamSubscription<T> subscription;

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            dynamic curVal = value;

            sequence.forEach((dynamic part) {
              try {
                curVal = curVal[part];
              } catch (error) {
                controller.addError(error, error.stackTrace);
              }
            });

            if (throwOnNull && curVal == null) {
              final PluckError error = new PluckError();

              controller.addError(error, error.stackTrace);
            } else {
              try {
                controller.add(curVal);
              } catch (error) {
                controller.addError(error, error.stackTrace);
              }
            }
          },
              onError: controller.addError,
              onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}

class PluckError extends Error {

  final String message;

  PluckError() : message = 'Value was resolved as null from the pluck sequence';

  String toString() => message;

}