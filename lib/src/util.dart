
library intervals.util;

import 'package:intervals/intervals.dart';

class Order<T> {
  final int Function(T,T) comparator;

  const Order(this.comparator);

  S min<S extends T>(S a, S b) => comparator(a,b)<=0 ? a : b;
  S max<S extends T>(S a, S b) => comparator(a,b)>=0 ? a : b;

}

const lowerOrdering = const Order<Interval>(_lowerComparator);
const upperOrdering = const Order<Interval>(_upperComparator);

T minOfComparables<T extends Comparable>(T a, T b) => Comparable.compare(a, b)<0 ? a : b;
T maxOfComparables<T extends Comparable>(T a, T b) => Comparable.compare(a, b)<0 ? b : a;

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
  if (a.upperClosed&&!b.upperClosed) return 1;
  if (b.upperClosed&&!a.upperClosed) return -1;
  return 0;
}

