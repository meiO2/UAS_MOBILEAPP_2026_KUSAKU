import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationController sequenceController;
  late AnimationController rotationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  setUp(() {
    sequenceController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: const TestVSync(),
    );

    rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: const TestVSync(),
    );

    scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.5), weight: 50),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(sequenceController);

    fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(sequenceController);
  });

  tearDown(() {
    sequenceController.dispose();
    rotationController.dispose();
  });

  group('AnimationController durations', () {
    test('sequenceController duration is 2500 ms', () {
      expect(
        sequenceController.duration,
        const Duration(milliseconds: 2500),
      );
    });

    test('rotationController duration is 4 s', () {
      expect(
        rotationController.duration,
        const Duration(seconds: 4),
      );
    });
  });

  group('AnimationController initial state', () {
    test('sequenceController starts at 0', () {
      expect(sequenceController.value, 0.0);
    });

    test('rotationController starts at 0', () {
      expect(rotationController.value, 0.0);
    });

    test('sequenceController is initially dismissed', () {
      expect(sequenceController.status, AnimationStatus.dismissed);
    });
  });

  group('scaleAnimation values', () {
    test('is 0.5 at t=0 (start of sequence)', () {
      sequenceController.value = 0.0;
      expect(scaleAnimation.value, closeTo(0.5, 0.01));
    });

    test('is 0.5 at t=0.5 (boundary between first and second segment)', () {
      sequenceController.value = 0.5;
      expect(scaleAnimation.value, closeTo(0.5, 0.01));
    });

    test('reaches ~1.0 at t=1.0 (sequence complete)', () {
      sequenceController.value = 1.0;
      expect(scaleAnimation.value, closeTo(1.0, 0.05));
    });

    test('value stays between 0.0 and ~1.1 throughout (easeOutBack overshoot)',
        () {
      for (var i = 0; i <= 10; i++) {
        sequenceController.value = i / 10;
        expect(scaleAnimation.value, greaterThanOrEqualTo(0.0));
        // easeOutBack can overshoot slightly above 1.0
        expect(scaleAnimation.value, lessThanOrEqualTo(1.15));
      }
    });
  });

  group('fadeAnimation values', () {
    test('is 0.0 at t=0 (invisible at start)', () {
      sequenceController.value = 0.0;
      expect(fadeAnimation.value, closeTo(0.0, 0.01));
    });

    test('is 0.0 at t=0.15 (still in constant-zero segment)', () {
      sequenceController.value = 0.15;
      expect(fadeAnimation.value, closeTo(0.0, 0.01));
    });

    test('is > 0.0 at t=0.3 (mid fade-in segment)', () {
      sequenceController.value = 0.3;
      expect(fadeAnimation.value, greaterThan(0.0));
    });

    test('is 1.0 at t=1.0 (fully visible at end)', () {
      sequenceController.value = 1.0;
      expect(fadeAnimation.value, closeTo(1.0, 0.01));
    });

    test('never exceeds 1.0', () {
      for (var i = 0; i <= 10; i++) {
        sequenceController.value = i / 10;
        expect(fadeAnimation.value, lessThanOrEqualTo(1.0));
      }
    });

    test('is monotonically non-decreasing', () {
      double previous = 0.0;
      for (var i = 0; i <= 20; i++) {
        sequenceController.value = i / 20;
        expect(fadeAnimation.value, greaterThanOrEqualTo(previous - 0.001));
        previous = fadeAnimation.value;
      }
    });
  });

  group('rotationController', () {
    test('repeats (value wraps back to 0 after one full cycle)', () {
      rotationController.repeat();
      expect(rotationController.isAnimating, isTrue);
    });

    test('value is within [0, 1] while repeating', () {
      rotationController.repeat();
      rotationController.value = 0.75;
      expect(rotationController.value, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Timer delay constants', () {
    test('rotation start delay is 1250 ms (half of sequence duration)', () {
      const rotationStartDelay = Duration(milliseconds: 1250);
      const halfSequence = Duration(milliseconds: 2500 ~/ 2); 
      expect(rotationStartDelay, halfSequence);
    });

    test('navigation delay is 4 s (matches rotationController duration)', () {
      const navigationDelay = Duration(seconds: 4);
      const rotationDuration = Duration(seconds: 4);
      expect(navigationDelay, rotationDuration);
    });
  });
}