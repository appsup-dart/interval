part of intervals;

abstract class MaterializedIntervalSet<T extends Comparable> extends IntervalSet<T> {

  /// The individual intervals in this set
  List<Interval<T>> get intervals;

  @override
  int get hashCode => intervals.map((v)=>v.hashCode).reduce((a,b)=>a^b);

  @override
  bool operator==(other) => other is MaterializedIntervalSet &&
      new IterableEquality().equals(intervals, other.intervals);

  @override
  String toString() => intervals.join("∪");

  @override
  Interval<T> firstIntervalEndingAfter(T value, {bool strict: false}) =>
      intervals.firstWhere((i) {
        if (!i.upperBounded) return true;
        var cmp = Comparable.compare(i.upper, value);
        return cmp>0||(cmp==0&&!strict&&i.upperClosed);
      }, orElse: ()=>null);

  @override
  Interval<T> lastIntervalStartingBefore(T value, {bool strict: false}) =>
      intervals.lastWhere((i) {
        if (!i.lowerBounded) return true;
        var cmp = Comparable.compare(i.lower, value);
        return cmp<0||(cmp==0&&!strict&&i.lowerClosed);
      }, orElse: ()=>null);


  @override
  Interval<T> get bounds => new Interval.encloseAll(intervals);

}

class MultiInterval<T extends Comparable> extends MaterializedIntervalSet<T> {

  @override
  final List<Interval<T>> intervals;

  MultiInterval._(this.intervals);


}