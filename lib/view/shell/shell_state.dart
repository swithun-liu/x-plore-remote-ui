part of 'shell_bloc.dart';

@immutable
abstract class ShellState {}

class ShellInitial extends ShellState {}

class ShellNormal extends ShellState { }