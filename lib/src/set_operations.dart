
part of intervals;

class _InverseIntervalSet<T extends Comparable> extends IntervalSet<T> {

  @override
  IntervalSet<T> inverse;

  _InverseIntervalSet(this.inverse);

  @override
  Interval<T> firstIntervalEndingAfter(T value, {bool strict: false}) {
    var upper = inverse.firstIntervalStartingAfter(value, strict: strict);
    var lower = inverse.lastIntervalStartingBefore(upper?.lower ?? value, strict: upper!=null);
    return new Interval(
      upper: upper?.lower, upperClosed: !(upper?.lowerClosed ?? false)&&upper!=null,
      lower: lower?.upper, lowerClosed: !(lower?.upperClosed ?? false)&&lower!=null
    );
  }

  @override
  Interval<T> lastIntervalStartingBefore(T value, {bool strict: false}) {
    var lower = inverse.lastIntervalEndingBefore(value, strict: strict);
    var upper = inverse.firstIntervalEndingAfter(lower?.upper ?? value, strict: lower!=null);
    return new Interval(
        upper: upper?.lower, upperClosed: !(upper?.lowerClosed ?? false)&&upper!=null,
        lower: lower?.upper, lowerClosed: !(lower?.upperClosed ?? false)&&lower!=null
    );
  }

  @override
  int get hashCode => inverse.hashCode^(#_InverseIntervalSet).hashCode;

  @override
  bool operator==(other) => other is _InverseIntervalSet && inverse==other.inverse;

  @override
  Interval<T> get bounds => new Interval.all();

}

class _IntersectionIntervalSet<T extends Comparable> extends IntervalSet<T> {

  final List<IntervalSet<T>> _children;

  _IntersectionIntervalSet(this._children);

  @override
  String toString() => _children.join("∩");

  @override
  Interval<T> firstIntervalEndingAfter(T value, {bool strict: false}) {
    var intervals = _children.map((i)=>i.firstIntervalEndingAfter(value, strict: strict));
    if (intervals.any((v)=>v==null)) return null;
    var lower = intervals.reduce(lowerOrdering.max);
    var upper = intervals.reduce(upperOrdering.min);
    if (lower.isAfter(upper)) return firstIntervalEndingAfter(lower.lower, strict: false);
    return new Interval(
      lower: lower.lower, lowerClosed: lower.lowerClosed,
      upper: upper.upper, upperClosed: upper.upperClosed
    );
  }

  @override
  Interval<T> lastIntervalStartingBefore(T value, {bool strict: false}) {
    var intervals = _children.map((i)=>i.lastIntervalStartingBefore(value, strict: strict));
    if (intervals.any((v)=>v==null)) return null;
    var lower = intervals.reduce(lowerOrdering.max);
    var upper = intervals.reduce(upperOrdering.min);
    if (lower.isAfter(upper)) return lastIntervalStartingBefore(upper.upper, strict: false);
    return new Interval(
        lower: lower.lower, lowerClosed: lower.lowerClosed,
        upper: upper.upper, upperClosed: upper.upperClosed
    );
  }

  @override
  Interval<T> get bounds =>
      new Interval.intersectAll(_children.map((i)=>i.bounds));


  @override
  int get hashCode =>
      _children.map((v)=>v.hashCode).reduce((a,b)=>a^b)^(#_IntersectionIntervalSet).hashCode;

  @override
  bool operator==(other) => other is _IntersectionIntervalSet &&
      new IterableEquality().equals(_children, other._children);

}

class _UnionIntervalSet<T extends Comparable> extends IntervalSet<T> {

  final List<IntervalSet<T>> _children;

  _UnionIntervalSet(this._children);

  @override
  String toString() => _children.join("∪");

  Interval<T> _firstEndingAfter(T value, bool strict) {
    var ii = _children
        .map((c)=>c.firstIntervalEndingAfter(value, strict: strict))
        .where((a)=>a!=null)
        .toList()..sort(lowerOrdering.comparator);
    if (ii.isEmpty) return null;
    return ii.reduce((a,b)=>a.connectedTo(b) ? a.enclose(b) : a);
  }

  Interval<T> _lastStartingBeofre(T value, bool strict) {
    var ii = _children
        .map((c)=>c.lastIntervalStartingBefore(value, strict: strict))
        .where((a)=>a!=null)
        .toList()..sort(upperOrdering.comparator);
    if (ii.isEmpty) return null;
    return ii.reversed.reduce((a,b)=>a.connectedTo(b) ? a.enclose(b) : a);
  }

  Interval<T> _grow(Interval<T> i) {
    if (i==null) return null;
    var j;
    while ((j = _firstEndingAfter(i.upper, true))?.connectedTo(i)==true) {
      i = i.enclose(j);
    }
    while ((j = _lastStartingBeofre(i.lower, true))?.connectedTo(i)==true) {
      i = i.enclose(j);
    }
    return i;
  }

  @override
  Interval<T> firstIntervalEndingAfter(T value, {bool strict: false}) {
    return _grow(_firstEndingAfter(value, strict));
  }



  @override
  Interval<T> lastIntervalStartingBefore(T value, {bool strict: false}) {
    return _grow(_lastStartingBeofre(value, strict));
  }

  @override
  int get hashCode => _children.map((v)=>v.hashCode).reduce((a,b)=>a^b)^(#_UnionIntervalSet).hashCode;

  @override
  bool operator==(other) => other is _UnionIntervalSet &&
      new IterableEquality().equals(_children, other._children);

  @override
  Interval<T> get bounds =>
      new Interval.encloseAll(_children.map((i)=>i.bounds));

}
