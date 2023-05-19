import 'package:flutter/material.dart';
import 'package:common_circle/src/game/board_state.dart';
import 'package:provider/provider.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  //Turn turn =
  Text toText(BoardState boardState) {
    String str;
    if (boardState.gameEnded) {
      str = "${boardState.turn} wins";
      if (boardState.spottingSuccess) {
        str += " by spotting cocyclic points!!";
      }
      else {
        str += "!! (Opponent failed)";
      }
    }
    else {
      str = "${boardState.turn}'s Turn";
      if (boardState.spotCocyclicPointsMode) {
        str += " spotting Cocyclic Points!";
      }
    }
    return Text(str, textScaleFactor: 1.5, softWrap: true,);
  }

  @override
  Widget build(BuildContext context) {
    final boardState = Provider.of<BoardState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              height: 70,
              child: toText(boardState),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: boardState.boardSize * boardState.boardSize,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardState.boardSize,
              ),
              itemBuilder: (context, index) {
                final int row = index ~/ boardState.boardSize;
                final int col = index % boardState.boardSize;
                //final int cellState = boardState.at(row, col);

                return GestureDetector(
                  onTap: () {
                    boardState.makeMove(row, col);
                  },
                  child: CustomContainer(
                      cellState: boardState.at(row, col), child: Container()),
                );
              },
            ),
            Container(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: () {
                    boardState.spotCocyclicPoints();
                  },
                  child: const Icon(Icons.search),
                ),
                const SizedBox(
                  width: 16,
                ),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () {
                    if (boardState.gameEnded) {
                      boardState.restart();
                    } else {
                      boardState.undo();
                    }
                  },
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomContainer extends StatefulWidget {
  final Widget child;
  final CellState cellState;

  const CustomContainer({super.key, required this.child, required this.cellState});

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomContainerPainter(cellState: widget.cellState),
      child: Container(
        child: widget.child,
      ),
    );
  }
}

class _CustomContainerPainter extends CustomPainter {
  final CellState cellState;
  _CustomContainerPainter({required this.cellState});

  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double horizontalLineY = height / 2;
    final double verticalLineX = width / 2;
    final double radius = size.width / 3;

    canvas.drawLine(
        Offset(0, horizontalLineY), Offset(width, horizontalLineY), _paint);
    canvas.drawLine(
        Offset(verticalLineX, 0), Offset(verticalLineX, height), _paint);

    switch (cellState) {
      case CellState.red:
        canvas.drawCircle(Offset(verticalLineX, horizontalLineY), radius,
            Paint()..color = Colors.red);
        break;
      case CellState.blue:
        canvas.drawCircle(Offset(verticalLineX, horizontalLineY), radius,
            Paint()..color = Colors.blue);
        break;
      case CellState.placed:
        canvas.drawCircle(Offset(verticalLineX, horizontalLineY), radius,
            Paint()..color = Colors.grey);
      case CellState.selected:
        canvas.drawCircle(Offset(verticalLineX, horizontalLineY), radius,
            Paint()..color = Colors.purple);
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
