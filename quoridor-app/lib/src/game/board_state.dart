import 'package:flutter/material.dart';
import 'package:common_circle/src/game/win_check.dart';

class BoardState with ChangeNotifier {
  Turn _turn = Turn.red;
  late int _boardSize;
  late List<List<CellState>> _boardState;
  List<Log> _history = [];
  bool _spotCocyclicPointsMode = false;
  List<Log> _spotList = [];
  bool _gameEnded = false;
  bool _spottingSuccess = false;
  bool hintMode = false;

  BoardState(int boardSize) {
    _boardSize = boardSize;
    _boardState = List.generate(
        _boardSize, (_) => List.generate(_boardSize, (_) => CellState.empty));
  }

  int get boardSize => _boardSize;

  Turn get turn => _turn;

  bool get spotCocyclicPointsMode => _spotCocyclicPointsMode;

  bool get gameEnded => _gameEnded;

  bool get spottingSuccess => _spottingSuccess;

  CellState at(int row, int col) => _boardState[row][col];

  void makeMove(int row, int col) {
    if (_spotCocyclicPointsMode) {
      _spotMove(row, col);
    } else {
      _placeMove(row, col);
    }
    notifyListeners();
  }

  void _spotMove(int row, int col) {
    CellState cellState = at(row, col);
    if (cellState == CellState.empty) {
      return;
    } else if (cellState == CellState.selected) {
      for (Log log in _spotList) {
        if (log.cellState == CellState.placed &&
            log.row == row &&
            log.col == col) {
          _boardState[row][col] = log.cellState;
          _spotList.remove(log);
          break;
        }
      }
    } else if (_spotList.length < 4) {
      _boardState[row][col] = CellState.selected;
      _spotList.add(Log(cellState, row, col));
    }
    return;
  }

  void _placeMove(int row, int col) {
    if (at(row, col) != CellState.empty) return;

    if (_history.isNotEmpty) {
      _boardState[_history.last.row][_history.last.col] = CellState.placed;
    }
    _boardState[row][col] = _turn.toCellState();
    _history.add(Log(_turn.toCellState(), row, col));
    _nextTurn();
  }

  void undo() {
    if (_spotCocyclicPointsMode) return;
    if (_history.isNotEmpty) {
      _boardState[_history.last.row][_history.last.col] = CellState.empty;
      _history.removeLast();

      if (_history.isNotEmpty) {
        _boardState[_history.last.row][_history.last.col] = _turn.toCellState();
      }
      _nextTurn();
      notifyListeners();
    }
  }

  void _nextTurn() {
    _turn = _turn.next();
  }

  void spotCocyclicPoints() {
    if (_history.length < 4) {
      return;
    }
    if (!_spotCocyclicPointsMode) {
      _spotCocyclicPointsMode = true;
      _spotList = [_history.last];
      _boardState[_history.last.row][_history.last.col] = CellState.selected;
    } else {
      if (_spotList.length < 4) {
        _spotCocyclicPointsMode = false;
        for (Log log in _spotList) {
          _boardState[log.row][log.col] = log.cellState;
        }
        _spotList = [];
      } else {
        _gameEnded = true;
        if (!WinChecker.ended(_spotList)) {
          // spot failed, so opponent wins
          _nextTurn();
          _spottingSuccess = false;
        } else {
          _spottingSuccess = true;
        }
        _spotList = [];
      }
    }
    notifyListeners();
  }

  void restart() {
    _boardState = List.generate(
        _boardSize, (_) => List.generate(_boardSize, (_) => CellState.empty));
    _turn = Turn.red;
    _history = [];
    _spotCocyclicPointsMode = false;
    _spotList = [];
    _gameEnded = false;
    notifyListeners();
  }
}

enum Turn {
  red,
  blue;

  Turn next() {
    return this == red ? blue : red;
  }

  CellState toCellState() {
    return this == red ? CellState.red : CellState.blue;
  }

  @override
  String toString() => this == red ? "RED" : "BLUE";
}

enum CellState {
  empty,
  placed,
  selected,
  red,
  blue;
}

class Log {
  final CellState cellState;
  final int row;
  final int col;
  Log(this.cellState, this.row, this.col);
}
