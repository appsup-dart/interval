# intervals 

[![Build Status](https://travis-ci.org/appsup-dart/interval.svg?branch=master)](https://travis-ci.org/appsup-dart/interval)


Provides the `Interval` and `IntervalSet` class, a (resp. piecewise) contiguous set of values.

If an Interval contains two values, it also contains all values between
them.  It may have an upper and lower bound, and those bounds may be
open or closed.

An IntervalSet represents the union of zero or more non connected intervals.


*Note: this package is a fork and extension of the [`interval`](https://github.com/seaneagan/interval) 
package created by Sean Eagan*

## Usage

```dart
import 'package:intervals/intervals.dart';

void isActive(DateTime date1, DateTime date2) {
    // Date intervals
    var activeDates = new Interval<DateTime>.closed(date1, date2);
    if(activeDates.contains(new DateTime.now())) {
      print('Item is active!');
    }  
}

// View selection model
var slider = new Slider(interval: new Interval.closed(0, 100));

// Validation
class Rating {
  final int value;

  Rating(this.value) {
    if(!new Interval.closed(1, 5).contains(value)) {
      throw new ArgumentError('ratings must be between 1 and 5');
    }
  }
}

// IntervalSet
var a = new Interval.closed(0,1)
    .union(new Interval.closed(2,5))
    .diff(new Interval.closed(3,4));
```
