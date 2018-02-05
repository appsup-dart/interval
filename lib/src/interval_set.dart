part of intervals;


/// A set of none connected intervals.
abstract class IntervalSet<T extends Comparable> {

  IntervalSet();

  /// The individual intervals in this set
  List<Interval<T>> get intervals;

  /// The minimal set of intervals which [encloses] each interval in [intervals].
  ///
  /// If [intervals] is empty, the returned interval set is empty, i.e. contains
  /// no values.
  factory IntervalSet.unionAll(Iterable<Interval<T>> intervals) {
    var r = <Interval<T>>[];
    for (var i in intervals.toList()..sort(_lowerComparator)) {
      if (r.isEmpty||!r.last.connectedTo(i)) {
        r.add(i);
      } else {
        r[r.length-1] = new Interval.encloseAll([r.last,i]);
      }
    }
    return new MultiInterval._(r);
  }

  /// Whether `this` contains [test].
  bool contains(T test) => intervals.any((i)=>i.contains(test));

  /// Whether the intersection of `this` and [other] is not empty.
  bool intersects(IntervalSet<T> other) =>
      intervals.any((i)=>other.intervals.any((j)=>i.intersects(j)));

  /// Returns the intersection of `this` interval set with [other].
  ///
  /// If the intervals do not intersect, `null` is returned.
  IntervalSet<T> intersect(IntervalSet<T> other) {
    return new IntervalSet.unionAll((() sync* {
      for (var a in intervals) {
        for (var b in other.intervals) {
          yield a.intersect(b);
        }
      }
    })().where((v)=>v!=null));
  }

  /// Returns the union of `this` interval set with [other].
  IntervalSet<T> union(IntervalSet<T> other) =>
      new IntervalSet.unionAll(<Interval<T>>[]..addAll(intervals)..addAll(other.intervals));

  /// Returns the set difference of `this` with [other].
  IntervalSet<T> diff(IntervalSet<T> other) {

    var i = 0, j= 0;

    var out = <Interval<T>>[];

    var a = i<this.intervals.length ? this.intervals[i] : null;
    while (i<this.intervals.length) {
      var b = j<other.intervals.length ? other.intervals[j] : null;

      if (b==null||a.isBefore(b)) {
        out.add(a);
        i++;
        a = i<this.intervals.length ? this.intervals[i] : null;
      } else if (b.isBefore(a)) {
        j++;
      } else {
        if (_lowerComparator(a,b)>=0) {
          if (_upperComparator(a,b)>0) {
            a = new Interval(
                lower: b.upper,
                lowerClosed: !b.upperClosed,
                upper: a.upper,
                upperClosed: a.upperClosed
            );
          } else {
            i++;
            a = i<this.intervals.length ? this.intervals[i] : null;
          }
        } else {
          out.add(new Interval(
              lower: a.lower, lowerClosed: a.lowerClosed,
              upper: b.lower, upperClosed: !b.lowerClosed
          ));

          if (_upperComparator(a,b)>0) {
            a = new Interval(
                lower: b.upper, lowerClosed: !b.upperClosed,
                upper: a.upper, upperClosed: a.upperClosed
            );
          } else {
            i++;
            a = i<this.intervals.length ? this.intervals[i] : null;
          }
        }
      }

    }

    return new IntervalSet.unionAll(out);

  }

  @override
  int get hashCode => intervals.map((v)=>v.hashCode).reduce((a,b)=>a^b);

  @override
  bool operator==(other) => other is IntervalSet &&
      new IterableEquality().equals(intervals, other.intervals);

  @override
  String toString() => intervals.join("U");

}


int _lowerComparator<T extends Comparable>(Interval<T> a, Interval<T> b) {
  if (!a.lowerBounded) return -1;
  if (!b.lowerBounded) return 1;
  var cmp = Comparable.compare(a.lower, b.lower);
  if (cmp!=0) return cmp;
  if (a.lowerClosed&&!b.lowerClosed) return -1;
  if (b.lowerClosed&&!a.lowerClosed) return 1;
  return 0;
}

int _upperComparator<T extends Comparable>(Interval<T> a, Interval<T> b) {
  if (!a.upperBounded) return 1;
  if (!b.upperBounded) return -1;
  var cmp = Comparable.compare(a.upper, b.upper);
  if (cmp!=0) return cmp;
  if (a.upperClosed&&!b.upperClosed) return -1;
  if (b.upperClosed&&!a.upperClosed) return 1;
  return 0;
}

class MultiInterval<T extends Comparable> extends IntervalSet<T> {

  @override
  final List<Interval<T>> intervals;

  MultiInterval._(this.intervals);

}