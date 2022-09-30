import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_timer/sp_provider.dart';

final timerProvider = StateNotifierProvider.autoDispose<TimerViewModel, String>((ref) {
  return TimerViewModel();
});

const _initialDuration = 60;

class TimerViewModel extends StateNotifier<String> {
  StreamSubscription<int>? _countDownSubscription;
  final String _key = "time_key";

  TimerViewModel() : super("01:00");

  void start() async {
    _countDownSubscription?.cancel();
    // const duration = 60;
    final duration = await _getTimeDuration();

    _countDownSubscription = _countDown(ticks: duration).listen((duration) {
      state = _durationString(duration);
    });

    _countDownSubscription?.onDone(() async {
      setTimeDone();
    });

    state = _durationString(duration);
  }

  void setTimeDone() async {
    final pref = await SharedPreferencesProvider.getInstance();
    await pref.remove(_key);
  }

  Stream<int> _countDown({required int ticks}) {
    return Stream.periodic(
      const Duration(seconds: 1),
          (x) => ticks - x - 1,
    ).take(ticks);
  }

  String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, "0");
    final seconds = (duration % 60).floor().toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  Future<int> _getTimeDuration() async {
    final lastRemainTime = await _getLastRemainTime();
    if (lastRemainTime == _initialDuration) {
      await _setCurrentTimestamp();
      return lastRemainTime;
    } else {
      final isFromBegin = lastRemainTime == 0;
      if (isFromBegin) {
        await _setCurrentTimestamp();
        return _initialDuration;
      } else {
        return lastRemainTime;
      }
    }
  }

  Future<int> _getLastRemainTime() async {
    final pref = await SharedPreferencesProvider.getInstance();
    final lastCurrentTimeStamp = pref.getInt(_key);
    var remainTime = _initialDuration;
    if (lastCurrentTimeStamp == null) {
      return remainTime;
    } else {
      remainTime = _initialDuration -
          ((DateTime.now().millisecondsSinceEpoch - lastCurrentTimeStamp) / 1000).floor();
      final currentRemainTime = max(0, remainTime);
      return currentRemainTime;
    }
  }

  Future<bool> _setCurrentTimestamp() async {
    final pref = await SharedPreferencesProvider.getInstance();
    return pref.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    super.dispose();
    _countDownSubscription?.cancel();
  }
}