import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'shell_event.dart';
part 'shell_state.dart';

class ShellBloc extends Bloc<ShellEvent, ShellState> {
  ShellBloc() : super(ShellInitial()) {
    on<ShellEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
