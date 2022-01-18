import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer_bloc/ticker.dart';
import 'dart:async';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<TimerPaused>(_onTimerPaused);
    on<TimerResumed>(_onTimerResumed);
    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgess(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    event.duration > 0
        ? emit(TimerRunInProgess(event.duration))
        : emit(TimerRunComplete());
  }

  void _onTimerPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgess) {
      emit(TimerRunPause(state.duration));
      _tickerSubscription?.pause();
    }
  }

  void _onTimerResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      emit(TimerRunInProgess(state.duration));
      _tickerSubscription?.resume();
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    emit(TimerInitial(_duration));
    _tickerSubscription?.cancel();
  }
}
