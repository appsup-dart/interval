part of intervals;


/// A set of none connected intervals.
abstract class IntervalSet<T extends Comparable> {

  IntervalSet();

  /// The minimal set of intervals which [encloses] each interval in [intervals].
  ///
  /// If [intervals] is empty, the returned interval set is empty, i.e. contains
  /// no values.
  factory IntervalSet.unionAll(Iterable<Interval<T>> intervals) {
    var r = <Interval<T>>[];
    for (var i in intervals.toList()..sort(lowerOrdering.comparator)) {
      if (r.isEmpty||!r.last.connectedTo(i)) {
        r.add(i);
      } else {
        r[r.length-1] = new Interval.encloseAll([r.last,i]);
      }
    }
    return new MultiInterval._(r);
  }

  /// Returns the first interval that ends after [value]
  Interval<T> firstIntervalEndingAfter(T value, {bool strict: false});

  /// Returns the last interval that starts before [value]
  Interval<T> lastIntervalStartingBefore(T value, {bool strict: false});

  /// Returns the first interval that starts after [value]
  Interval<T> firstIntervalStartingAfter(T value, {bool strict: false}) {
    var v = firstIntervalEndingAfter(value);
    if (v==null) return null;
    var cmp = v.lower==null ? -1 : Comparable.compare(v.lower, value);
    if (cmp>0||(cmp==0&&!v.lowerClosed&&!strict)) return v;
    if (!v.upperBounded) return null;
    return firstIntervalEndingAfter(v.upper, strict: true);
  }

  /// Returns the last interval that ends before [value]
  Interval<T> lastIntervalEndingBefore(T value, {bool strict: false}) {
    var v = lastIntervalStartingBefore(value);
    if (v==null) return null;
    var cmp = Comparable.compare(v.upper, value);
    if (cmp<0||(cmp==0&&!v.upperClosed&&!strict)) return v;
    if (!v.lowerBounded) return null;
    return lastIntervalStartingBefore(v.lower, strict: true);
  }

  /// Whether `this` contains [test].
  bool contains(T test) => firstIntervalEndingAfter(test)?.contains(test) ?? false;

  /// Returns the intersection of `this` interval set with [other].
  IntervalSet<T> intersect(IntervalSet<T> other) =>
      new _IntersectionIntervalSet([this,other]); // TODO simplify

  /// Returns the union of `this` interval set with [other].
  IntervalSet<T> union(IntervalSet<T> other) =>
      new _UnionIntervalSet([this,other]); // TODO simplify

  /// Returns the set difference of `this` with [other].
  IntervalSet<T> diff(IntervalSet<T> other) =>
      intersect(other.inverse);

  /// Returns the inverse set of `this`, i.e. the set that contains all values
  /// that are not contained in `this` and contains none of the values contained
  /// in `this`.
  IntervalSet<T> get inverse => new _InverseIntervalSet(this);
  
  /// Returns an interval that contains at least every value in this set. 
  /// 
  /// An implementing class should try to return the minimal enclosing interval,
  /// but can also return a larger interval.
  Interval<T> get bounds;

  /// Returns all the intervals contained in this set overlapping the given
  /// bounds.
  ///
  /// When the bounds argument is omitted, all the intervals contained in this
  /// set are returned.
  Iterable<Interval<T>> intervalsOverlapping([Interval<T> bounds]) sync* {
    bounds ??= this.bounds;
    var next = bounds.lower;
    var strict = !bounds.lowerClosed;
    Interval<T> i;
    while ((i = firstIntervalEndingAfter(next, strict: strict))!=null
        &&i.intersects(bounds)) {
      yield i;
      next = i.upper;
      strict = true;
    }
  }

}


