//import 'package:flutter/material.dart';

import 'board_state.dart';

class WinChecker {
  static bool ended(List<Log> spotList) {
    if (spotList.length != 4) return false;

    int ab = _dist(spotList[0], spotList[1]);
    int ac = _dist(spotList[0], spotList[2]);
    int ad = _dist(spotList[0], spotList[3]);
    int bc = _dist(spotList[1], spotList[2]);
    int bd = _dist(spotList[1], spotList[3]);
    int cd = _dist(spotList[2], spotList[3]);

    int abcd = ab * cd;
    int acbd = ac * bd;
    int adbc = ad * bc;

    // debugPrint("ABCD is ${ABCD}");
    // debugPrint("ACBD is ${ACBD}");
    // debugPrint("ADBC is ${ADBC}");
  
    if (abcd > acbd && acbd > adbc) {
      // ABCD max
      return ptolemy(abcd, acbd, adbc);
    } else if (acbd > abcd && acbd > adbc) {
      // ACBD max
      return ptolemy(acbd, abcd, adbc);
    } else {
      // ADBC max
      return ptolemy(adbc, abcd, acbd);
    }
  }

  static int _dist(Log a, Log b) {
    return (a.row - b.row) * (a.row - b.row) +
        (a.col - b.col) * (a.col - b.col);
  }

  static bool ptolemy(int x, int y, int z) {
    // x is biggest
    return (x - y - z) * (x - y - z) == 4 * y * z;
  }

  // static CircleData calcCenter(List<Log> spotList) {
  //   double x, y, r;

    



  //   return CircleData(x, y, r);
  // }
}

class CircleData {
  final double x;
  final double y;
  final double r;
  CircleData(this.x, this.y, this.r);
}
