
library interval.test;

import 'package:interval/interval.dart';
import 'package:test/test.dart';

main() {
  group('Interval', () {

    group('constructors', () {

      test('should throw when upper less than lower', () {
        var throwsArgumentError = throwsA(new isInstanceOf<ArgumentError>());
        expect(() => new Interval(lower: 1, lowerClosed: true, upper: 0,
            upperClosed: true), throwsArgumentError);
        expect(() => new Interval.open(1, 0), throwsArgumentError);
        expect(() => new Interval.closed(1, 0), throwsArgumentError);
        expect(() => new Interval.openClosed(1, 0), throwsArgumentError);
        expect(() => new Interval.closedOpen(1, 0), throwsArgumentError);
      });

      test('should throw when open and lower equals upper', () {
        var throwsArgumentError = throwsA(new isInstanceOf<ArgumentError>());
        expect(() => new Interval(upper: 0, upperClosed: false, lower: 0,
            lowerClosed: false), throwsArgumentError);
        expect(() => new Interval.open(0, 0), throwsArgumentError);
      });

      test('should throw on null when corresponding bound is closed', () {
        var throwsArgumentError = throwsA(new isInstanceOf<ArgumentError>());
        expect(() => new Interval.closed(null, 0), throwsArgumentError);
        expect(() => new Interval.closed(0, null), throwsArgumentError);
        expect(() => new Interval.openClosed(0, null), throwsArgumentError);
        expect(() => new Interval.closedOpen(null, 0), throwsArgumentError);
        expect(() => new Interval.atMost(null), throwsArgumentError);
        expect(() => new Interval.atLeast(null), throwsArgumentError);
        expect(() => new Interval.singleton(null), throwsArgumentError);
      });

      group('span', () {

        test('should contain all values if iterable is empty', () {
          var interval = new Interval.span([]);
          expect(interval.lower, null);
          expect(interval.upper, null);
          expect(interval.lowerClosed, isFalse);
          expect(interval.upperClosed, isFalse);
        });

        test('should find lower and upper', () {
          var interval = new Interval.span([2,5,1,4]);
          expect(interval.lower, 1);
          expect(interval.upper, 5);
          expect(interval.lowerClosed, isTrue);
          expect(interval.upperClosed, isTrue);
        });

        test('should be singleton if single element', () {
          var interval = new Interval.span([2]);
          expect(interval.lower, 2);
          expect(interval.upper, 2);
          expect(interval.lowerClosed, isTrue);
          expect(interval.upperClosed, isTrue);
        });

      });

      group('encloseAll', () {

        test('should contain all values if iterable is empty', () {
          var interval = new Interval.encloseAll([]);
          expect(interval.lower, null);
          expect(interval.upper, null);
        });

        test('should have null bounds when any input interval does', () {
          var interval = new Interval.encloseAll([
              new Interval.atMost(0),
              new Interval.atLeast(1)]);
          expect(interval.lower, null);
          expect(interval.upper, null);
        });

        test('should have bounds matching extreme input interval bounds', () {
          var interval = new Interval.encloseAll([
              new Interval.closed(0, 3),
              new Interval.closed(-1, 0),
              new Interval.closed(8, 10),
              new Interval.closed(5, 7)]);
          expect(interval.lower, -1);
          expect(interval.upper, 10);
        });

        test('should have closed bound when any corresponding extreme input '
            'interval bound does', () {
          var interval = new Interval.encloseAll([
              new Interval.closedOpen(0, 1),
              new Interval.openClosed(0, 1)]);
          expect(interval.lowerClosed, isTrue);
          expect(interval.upperClosed, isTrue);
        });

        test('should have open bound when all extreme input interval bounds '
            'do', () {
          var interval = new Interval.encloseAll([
              new Interval.open(0, 1),
              new Interval.open(0, 1)]);
          expect(interval.lowerClosed, isFalse);
          expect(interval.upperClosed, isFalse);
        });

      });

      group('intersectAll', () {

        test('should return null if iterable is empty', () {
          var interval = new Interval.intersectAll([]);
          expect(interval, null);
        });

        test('should return null when input interval do not overlap', () {
          var interval = new Interval.intersectAll([
            new Interval.atMost(0),
            new Interval.atLeast(1)]);
          expect(interval, null);
        });

        test('should have bounds matching extreme input interval bounds', () {
          var interval = new Interval.intersectAll([
            new Interval.closed(0, 3),
            new Interval.closed(-1, 1),
            new Interval.closed(-8, 10),
            new Interval.closed(-5, 7)]);
          expect(interval.lower, 0);
          expect(interval.upper, 1);
        });

        test('should have open bound when any corresponding extreme input '
            'interval bound does', () {
          var interval = new Interval.intersectAll([
            new Interval.closedOpen(0, 1),
            new Interval.openClosed(0, 1)]);
          expect(interval.lowerClosed, isFalse);
          expect(interval.upperClosed, isFalse);
        });

        test('should have closed bound when all extreme input interval bounds '
            'do', () {
          var interval = new Interval.intersectAll([
            new Interval.closed(0, 1),
            new Interval.closed(0, 1)]);
          expect(interval.lowerClosed, isTrue);
          expect(interval.upperClosed, isTrue);
        });

      });

    });

    group('contains', () {

      test('should be true for values between lower and upper', () {
        expect(new Interval.closed(0, 2).contains(1), isTrue);
      });

      test('should be false for values below lower', () {
        expect(new Interval.closed(0, 2).contains(-1), isFalse);
      });

      test('should be false for values above upper', () {
        expect(new Interval.closed(0, 2).contains(3), isFalse);
      });

      test('should be false for lower when lowerClosed is false', () {
        expect(new Interval.open(0, 2).contains(0), isFalse);
      });

      test('should be true for lower when lowerClosed is true', () {
        expect(new Interval.closed(0, 2).contains(0), isTrue);
      });

      test('should be false for upper when upperClosed is false', () {
        expect(new Interval.open(0, 2).contains(2), isFalse);
      });

      test('should be true for upper when upperClosed is true', () {
        expect(new Interval.closed(0, 2).contains(2), isTrue);
      });

      test('should be true for greater than lower when upper is null', () {
        expect(new Interval.atLeast(0).contains(100), isTrue);
      });

      test('should be true for less than upper when lower is null', () {
        expect(new Interval.atMost(0).contains(-100), isTrue);
      });

      test('should be false for bounds when equal and not both closed', () {
        expect(new Interval.openClosed(0, 0).contains(0), isFalse);
        expect(new Interval.closedOpen(0, 0).contains(0), isFalse);
      });

    });

    group('isEmpty', () {

      test('should be true when bounds equal and not both closed', () {
        expect(new Interval.openClosed(0, 0).isEmpty, isTrue);
        expect(new Interval.closedOpen(0, 0).isEmpty, isTrue);
      });

      test('should be false when bounds equal and closed', () {
        expect(new Interval.closed(0, 0).isEmpty, isFalse);
      });

      test('should be false when lower less than upper', () {
        expect(new Interval.closed(0, 1).isEmpty, isFalse);
      });

    });

    group('isSingleton', () {

      test('should be true when bounds equal and both closed', () {
        expect(new Interval.closed(0, 0).isSingleton, isTrue);
      });

      test('should be false when empty', () {
        expect(new Interval.openClosed(0, 0).isSingleton, isFalse);
        expect(new Interval.closedOpen(0, 0).isSingleton, isFalse);
      });

      test('should be false when lower less than upper', () {
        expect(new Interval.closed(0, 1).isSingleton, isFalse);
      });

    });

    group('bounded', () {

      test('should be true only when lower bounded and upper bounded', () {
        expect(new Interval.closedOpen(0, 1).bounded, isTrue);
        expect(new Interval.atLeast(0).bounded, isFalse);
        expect(new Interval.atMost(0).bounded, isFalse);
      });

    });

    group('lowerBounded', () {

      test('should be true only when lower bounded', () {
        expect(new Interval.atLeast(0).lowerBounded, isTrue);
        expect(new Interval.atMost(0).lowerBounded, isFalse);
      });

    });

    group('upperBounded', () {

      test('should be true only when upper bounded', () {
        expect(new Interval.atMost(0).upperBounded, isTrue);
        expect(new Interval.atLeast(0).upperBounded, isFalse);
      });

    });

    group('isOpen', () {

      test('should be true only when both bounds open', () {
        expect(new Interval.open(0, 1).isOpen, isTrue);
        expect(new Interval.closedOpen(0, 1).isOpen, isFalse);
        expect(new Interval.openClosed(0, 1).isOpen, isFalse);
        expect(new Interval.closed(0, 1).isOpen, isFalse);
      });

    });

    group('isClosed', () {

      test('should be true only when both bounds closed', () {
        expect(new Interval.closed(0, 1).isClosed, isTrue);
        expect(new Interval.closedOpen(0, 1).isClosed, isFalse);
        expect(new Interval.openClosed(0, 1).isClosed, isFalse);
        expect(new Interval.open(0, 1).isClosed, isFalse);
      });

    });

    group('isClosedOpen', () {

      test('should be true only when lower closed and upper open', () {
        expect(new Interval.closedOpen(0, 1).isClosedOpen, isTrue);
        expect(new Interval.open(0, 1).isClosedOpen, isFalse);
        expect(new Interval.closed(0, 1).isClosedOpen, isFalse);
        expect(new Interval.openClosed(0, 1).isClosedOpen, isFalse);
      });

    });

    group('isOpenClosed', () {

      test('should be true only when lower open and upper closed', () {
        expect(new Interval.openClosed(0, 1).isOpenClosed, isTrue);
        expect(new Interval.open(0, 1).isOpenClosed, isFalse);
        expect(new Interval.closed(0, 1).isOpenClosed, isFalse);
        expect(new Interval.closedOpen(0, 1).isOpenClosed, isFalse);
      });

    });

    group('interior', () {

      test('should return input when input already open', () {
        var open = new Interval.open(0, 1);
        expect(open.interior, same(open));
      });

      test('should return open version of non-open input', () {
        var interior = new Interval.closed(0, 1).interior;
        expect(interior.lower, 0);
        expect(interior.upper, 1);
        expect(interior.lowerClosed, isFalse);
        expect(interior.upperClosed, isFalse);
      });

    });

    group('closure', () {

      test('should return input when input already open', () {
        var closed = new Interval.closed(0, 1);
        expect(closed.closure, same(closed));
      });

      test('should return closed version of non-closed input', () {
        var closure = new Interval.closed(0, 1).closure;
        expect(closure.lower, 0);
        expect(closure.upper, 1);
        expect(closure.lowerClosed, isTrue);
        expect(closure.upperClosed, isTrue);
      });

    });

    group('encloses', () {

      test('should be true when both bounds outside input bounds', () {
        expect(new Interval.closed(0, 3)
            .encloses(new Interval.closed(1, 2)), isTrue);
        expect(new Interval.atLeast(0)
            .encloses(new Interval.closed(1, 2)), isTrue);
        expect(new Interval.atMost(3)
            .encloses(new Interval.closed(1, 2)), isTrue);
      });

      test('should be false when either bound not outside input bound', () {
        expect(new Interval.closed(0, 2)
            .encloses(new Interval.closed(1, 3)), isFalse);
        expect(new Interval.closed(1, 3)
            .encloses(new Interval.closed(0, 2)), isFalse);
        expect(new Interval.closed(0, 2)
            .encloses(new Interval.atLeast(1)), isFalse);
        expect(new Interval.closed(0, 2)
            .encloses(new Interval.atMost(1)), isFalse);
      });

      test('should be true when bound closed and input has same bound', () {
        expect(new Interval.closedOpen(0, 2)
            .encloses(new Interval.closed(0, 1)), isTrue);
        expect(new Interval.openClosed(0, 2)
            .encloses(new Interval.closed(1, 2)), isTrue);
      });

      test('should be false when bound open and input has same bound but '
           'closed', () {
        expect(new Interval.openClosed(0, 2)
            .encloses(new Interval.closed(0, 1)), isFalse);
        expect(new Interval.closedOpen(0, 2)
            .encloses(new Interval.closed(1, 2)), isFalse);
      });

    });

    group('connectedTo', () {

      expectConnected(Interval interval1, Interval interval2, matcher) {
        expect(interval1.connectedTo(interval2), matcher);
        expect(interval2.connectedTo(interval1), matcher);
      }

      test('should be true when intervals properly intersect', () {
        expectConnected(new Interval.open(0, 1), new Interval.open(0, 1),
            isTrue);
        expectConnected(new Interval.closed(1, 3), new Interval.closed(0, 2),
            isTrue);
        expectConnected(new Interval.atLeast(1), new Interval.atLeast(2),
            isTrue);
        expectConnected(new Interval.atLeast(1), new Interval.atLeast(2),
            isTrue);
        expectConnected(new Interval.atMost(2), new Interval.atMost(1),
            isTrue);
      });

      test('should be true when intervals adjacent and at least one bound '
           'closed', () {
        expectConnected(new Interval.closed(0, 1), new Interval.closed(1, 2),
            isTrue);
        expectConnected(new Interval.open(0, 1), new Interval.closed(1, 2),
            isTrue);
        expectConnected(new Interval.closed(0, 1), new Interval.open(1, 2),
            isTrue);
        expectConnected(new Interval.atMost(1), new Interval.greaterThan(1),
            isTrue);
      });

      test('should be false when interval closures do not intersect', () {
        expectConnected(new Interval.closed(0, 1), new Interval.closed(2, 3),
            isFalse);
        expectConnected(new Interval.closed(2, 3), new Interval.closed(0, 1),
            isFalse);
        expectConnected(new Interval.atMost(0), new Interval.atLeast(1),
            isFalse);
      });

      test('should be false when intervals adjacent and both bounds open', () {
        expectConnected(new Interval.open(0, 1), new Interval.greaterThan(1),
            isFalse);
        expectConnected(new Interval.greaterThan(1), new Interval.lessThan(1),
            isFalse);
      });

    });

    test('should be equal iff lower, upper, lowerClosed, and upperClosed are '
         'all equal', () {
      var it = new Interval.closed(0, 1);
      expect(it, new Interval.closed(0, 1));
      expect(it, isNot(equals(new Interval.closed(0, 2))));
      expect(it, isNot(equals(new Interval.closed(1, 1))));
      expect(it, isNot(equals(new Interval.openClosed(0, 1))));
      expect(it, isNot(equals(new Interval.closedOpen(0, 1))));
    });

    test('hashCode should be equal if lower, upper, lowerClosed, and '
         'upperClosed are all equal', () {
      var it = new Interval.closed(0, 1);
      expect(it.hashCode, new Interval.closed(0, 1).hashCode);
    });

    test('toString should depict the interval', () {
      expect(new Interval.closedOpen(0, 1).toString(), '[0..1)');
      expect(new Interval.openClosed(0, 1).toString(), '(0..1]');
      expect(new Interval.atLeast(0).toString(), '[0..+∞)');
      expect(new Interval.atMost(0).toString(), '(-∞..0]');
    });

  });

}
