
library interval.test;

import 'package:intervals/intervals.dart';
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
          var interval = new Interval<Comparable>.span([]);
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
          var interval = new Interval<Comparable>.encloseAll([]);
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
          expect(new Interval.encloseAll([
            new Interval.closed(16,17),
            new Interval.closedOpen(17,18)
          ]), new Interval.closedOpen(16, 18));
        });

      });

      group('intersectAll', () {

        test('should return ( -∞ .. +∞ ) if iterable is empty', () {
          var interval = new Interval<Comparable>.intersectAll([]);
          expect(interval, new Interval.all());
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

    group('isBefore', () {
      test('should be true/false when properly ordered', () {
        expect(new Interval.atMost(4).isBefore(new Interval.atLeast(5)),isTrue);
        expect(new Interval.atLeast(5).isAfter(new Interval.atMost(4)),isTrue);
        expect(new Interval.atMost(4).isAfter(new Interval.atLeast(5)),isFalse);
        expect(new Interval.atLeast(5).isBefore(new Interval.atMost(4)),isFalse);
      });
      test('should be false when overlapping', () {
        expect(new Interval.atMost(5).isBefore(new Interval.atLeast(4)),isFalse);
        expect(new Interval.atLeast(4).isAfter(new Interval.atMost(5)),isFalse);
      });
      test('should be false if not bounded', () {
        expect(new Interval.atLeast(5).isBefore(new Interval.span([10,20])),isFalse);
        expect(new Interval.span([10,20]).isBefore(new Interval.atMost(100)),isFalse);
      });
      test('should be true/false when touching', () {
        expect(new Interval.closed(0, 4).isBefore(new Interval.closed(4, 5)),isFalse);
        expect(new Interval.closed(0, 4).isBefore(new Interval.open(4, 5)),isTrue);
        expect(new Interval.open(0, 4).isBefore(new Interval.closed(4, 5)),isTrue);
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

  group('IntervalSet', () {

    var a = new IntervalSet.unionAll([
      new Interval.closed(3,6),
      new Interval.closed(10,13),
      new Interval.closed(15,16),
      new Interval.closedOpen(17,18),
      new Interval.closed(19,24),
      new Interval.closed(26,27),
      new Interval.closed(28,29)
    ]);

    var b = new IntervalSet.unionAll([
      new Interval.closed(0,4),
      new Interval.openClosed(5,8),
      new Interval.closedOpen(11,12),
      new Interval.closed(14,15),
      new Interval.closedOpen(16, 17),
      new Interval.closed(20,21),
      new Interval.closed(22,23),
      new Interval.closed(25,30)
    ]);

    group('MaterializedIntervalSet', () {

      test('firstIntervalEndingAfter',() {
        expect(a.firstIntervalEndingAfter(2),new Interval.closed(3,6));
        expect(a.firstIntervalEndingAfter(3),new Interval.closed(3,6));
        expect(a.firstIntervalEndingAfter(6),new Interval.closed(3,6));
        expect(a.firstIntervalEndingAfter(6, strict: true),new Interval.closed(10,13));
        expect(a.firstIntervalEndingAfter(18),new Interval.closed(19,24));
        expect(a.firstIntervalEndingAfter(30),null);
      });

      test('firstIntervalStartingAfter', () {
        expect(a.firstIntervalStartingAfter(2),new Interval.closed(3,6));
        expect(a.firstIntervalStartingAfter(3),new Interval.closed(10,13));
        expect(b.firstIntervalStartingAfter(5),new Interval.openClosed(5,8));
        expect(b.firstIntervalStartingAfter(5, strict: true),new Interval.closedOpen(11,12));
        expect(b.firstIntervalStartingAfter(25),null);
      });

      test('lastIntervalStartingBefore',() {
        expect(a.lastIntervalStartingBefore(3, strict: true),null);
        expect(a.lastIntervalStartingBefore(3),new Interval.closed(3,6));
        expect(a.lastIntervalStartingBefore(6),new Interval.closed(3,6));
        expect(a.lastIntervalStartingBefore(10),new Interval.closed(10,13));
        expect(a.lastIntervalStartingBefore(19),new Interval.closed(19,24));
      });

      test('lastIntervalEndingBefore', () {
        expect(a.lastIntervalEndingBefore(6),null);
        expect(a.lastIntervalEndingBefore(14),new Interval.closed(10,13));
        expect(b.lastIntervalEndingBefore(12),new Interval.closedOpen(11,12));
        expect(b.lastIntervalEndingBefore(12, strict: true),new Interval.openClosed(5,8));
      });

      test('contains', () {
        expect(a.contains(0),isFalse);
        expect(a.contains(3),isTrue);
        expect(a.contains(8),isFalse);
        expect(a.contains(11),isTrue);
        expect(a.contains(14),isFalse);
        expect(a.contains(18),isFalse);
      });

    });

    group('_InverseIntervalSet', () {
      var i = a.inverse;
      var j = b.inverse;

      test('firstIntervalEndingAfter',() {
        expect(i.firstIntervalEndingAfter(2),new Interval.atMost(3).interior);
        expect(i.firstIntervalEndingAfter(3),new Interval.open(6,10));
        expect(j.firstIntervalEndingAfter(5),new Interval.openClosed(4,5));
        expect(j.firstIntervalEndingAfter(5, strict: true),new Interval.open(8,11));
        expect(i.firstIntervalEndingAfter(3),new Interval.open(6,10));
        expect(new IntervalSet.unionAll([
          new Interval.singleton(9)
          ]).inverse.firstIntervalEndingAfter(9), new Interval.atLeast(9).interior);
      });

      test('firstIntervalStartingAfter', () {
        expect(i.firstIntervalStartingAfter(2),new Interval.open(6,10));
        expect(i.firstIntervalStartingAfter(6),new Interval.open(6,10));
        expect(i.firstIntervalStartingAfter(6, strict: true),new Interval.open(13,15));
        expect(i.firstIntervalStartingAfter(29),new Interval.atLeast(29).interior);
      });

      test('lastIntervalStartingBefore',() {
        expect(i.lastIntervalStartingBefore(3),new Interval.atMost(3).interior);
        expect(i.lastIntervalStartingBefore(6),new Interval.atMost(3).interior);
        expect(i.lastIntervalStartingBefore(10),new Interval.open(6,10));
        expect(new IntervalSet.unionAll([
          new Interval.singleton(9)
        ]).inverse.lastIntervalStartingBefore(9), new Interval.atMost(9).interior);
      });

      test('lastIntervalEndingBefore', () {
        expect(i.lastIntervalEndingBefore(2),null);
        expect(i.lastIntervalEndingBefore(3),new Interval.atMost(3).interior);
        expect(i.lastIntervalEndingBefore(3, strict: true),null);
        expect(i.lastIntervalEndingBefore(6),new Interval.atMost(3).interior);
        expect(i.lastIntervalEndingBefore(13),new Interval.open(6,10));
      });

    });

    group('_IntersectionIntervalSet', () {

      var d = a.intersect(b);

      test('intervalsOverlapping', () {
        expect(d.intervalsOverlapping(), [
          new Interval.closed(3,4),
          new Interval.openClosed(5,6),
          new Interval.closedOpen(11,12),
          new Interval.singleton(15),
          new Interval.singleton(16),
          new Interval.closed(20,21),
          new Interval.closed(22,23),
          new Interval.closed(26,27),
          new Interval.closed(28,29)
        ]);
      });

      test('firstIntervalEndingAfter',() {
        expect(d.firstIntervalEndingAfter(2), new Interval.closed(3,4));
        expect(d.firstIntervalEndingAfter(4), new Interval.closed(3,4));
        expect(d.firstIntervalEndingAfter(4, strict: true), new Interval.openClosed(5,6));
        expect(d.firstIntervalEndingAfter(12), new Interval.singleton(15));
        expect(d.firstIntervalEndingAfter(15), new Interval.singleton(15));
        expect(d.firstIntervalEndingAfter(30), null);
      });

      test('lastIntervalStartingBefore', () {
        expect(d.lastIntervalStartingBefore(2), null);
        expect(d.lastIntervalStartingBefore(3), new Interval.closed(3,4));
        expect(d.lastIntervalStartingBefore(3, strict: true), null);
        expect(d.lastIntervalStartingBefore(5), new Interval.closed(3,4));
      });
    });

    group('_UnionIntervalSet', () {
      var u = a.union(b);

      test('intervalsOverlapping', () {
        expect(u.intervalsOverlapping(), [
        new Interval.closed(0,8),
        new Interval.closed(10,13),
        new Interval.closedOpen(14,18),
        new Interval.closed(19,24),
        new Interval.closed(25,30)
        ]);
      });

      test('firstIntervalEndingAfter',() {
        expect(u.firstIntervalEndingAfter(2), new Interval.closed(0,8));
        expect(u.firstIntervalEndingAfter(8), new Interval.closed(0,8));
        expect(u.firstIntervalEndingAfter(8, strict: true), new Interval.closed(10,13));
        expect(u.firstIntervalEndingAfter(17), new Interval.closedOpen(14,18));
        expect(u.firstIntervalEndingAfter(18), new Interval.closed(19,24));
        expect(u.firstIntervalEndingAfter(30), new Interval.closed(25,30));
        expect(u.firstIntervalEndingAfter(30, strict: true), null);
      });

      test('lastIntervalStartingBefore', () {
        expect(u.lastIntervalStartingBefore(0), new Interval.closed(0,8));
        expect(u.lastIntervalStartingBefore(0, strict: true), null);
        expect(u.lastIntervalStartingBefore(10), new Interval.closed(10,13));
        expect(u.lastIntervalStartingBefore(10, strict: true), new Interval.closed(0,8));
        expect(u.lastIntervalStartingBefore(31), new Interval.closed(25,30));
      });

    });

    group('diff', () {

      var d = a.diff(b);


      test('intervalsOverlapping', () {
        expect(d.intervalsOverlapping(), [
          new Interval.openClosed(4,5),
          new Interval.closedOpen(10,11),
          new Interval.closed(12,13),
          new Interval.open(15,16),
          new Interval.closedOpen(17,18),
          new Interval.closedOpen(19,20),
          new Interval.open(21,22),
          new Interval.openClosed(23,24),
        ]);
        expect(d.intervalsOverlapping(new Interval.closed(0,4)), [
        ]);
        expect(d.intervalsOverlapping(new Interval.closed(5,12)), [
          new Interval.openClosed(4,5),
          new Interval.closedOpen(10,11),
          new Interval.closed(12,13),
        ]);

      });

    });

  });
}
