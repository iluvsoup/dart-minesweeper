import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:console/console.dart';
import 'cell.dart';

// mining:
// mine until a cell has at least one neighbor

bool gameInProgress = false;

int gridSizeX = 5;
int gridSizeY = 5;

double bombChance = 0.15; // 15% chance of any cell being a bomb

int cursorPosX = 0;
int cursorPosY = 0;

var cells = generateCells();

final numberColors = [
  Color.BLUE, // 1
  Color.LIME, // 2
  Color.RED, // 3
  Color.MAGENTA, // 4
  Color.GOLD, // 5
  Color.LIGHT_CYAN, // 6
  Color.LIGHT_MAGENTA, // 7
  Color.LIGHT_GRAY, // 8
];

final stopwatch = Stopwatch();
Timer? drawEvent;

const controls = [
  'up',
  'down',
  'left',
  'right',
  'w',
  'a',
  's',
  'd',
  'f',
  ' ',
  '', // escape
];

void main() {
  Console.init();
  Keyboard.init();

  Keyboard.echoUnhandledKeys = false;
  Console.hideCursor();

  Keyboard.bindKeys(controls).listen((key) {
    handleInput(key);
  });

  draw();
}

void startGame() {
  gameInProgress = true;

  stopwatch.start();

  drawEvent = Timer.periodic(
    Duration(seconds: 1),
    (timer) {
      draw();
    },
  );
}

Map<int, Map<int, Cell>> generateCells() {
  Map<int, Map<int, Cell>> cells = {};

  for (var y = 0; y < gridSizeY; y++) {
    cells[y] = {};
    for (var x = 0; x < gridSizeX; x++) {
      double random = Random().nextDouble();
      cells[y]![x] = Cell(
        x: x,
        y: y,
        type: random >= bombChance ? 'empty' : 'bomb',
      );
    }
  }

  return cells;
}

void clear() {
  if (Platform.isWindows) {
    stdout.write(
      Process.runSync("cls", [], runInShell: true).stdout,
    );
  } else {
    stdout.write(
      Process.runSync("clear", [], runInShell: true).stdout,
    );
  }
}

void draw() {
  clear();
  var pen = TextPen();

  for (var y = 0; y < gridSizeY; y++) {
    for (var x = 0; x < gridSizeX; x++) {
      var cell = cells[y]![x];
      String text;

      if (cell!.hasMined) {
        if (cell.type == 'empty') {
          int bombs = getNumberOfSurroundingBombs(cell);

          if (bombs == 0) {
            pen.setColor(Color.GRAY);
            text = ' ';
          } else {
            pen.setColor(numberColors[bombs - 1]);
            text = bombs.toString();
          }
        } else {
          pen.setColor(Color.DARK_RED);
          text = 'X';
        }
      } else {
        if (cell.isFlagged) {
          pen.setColor(Color.WHITE);
          text = '?';
        } else {
          pen.setColor(Color.GREEN);
          text = '·';
        }
      }

      if (cursorPosX == x && cursorPosY == y) {
        pen.text('[$text]');
      } else {
        pen.text(' $text ');
      }
    }

    pen.print();
    pen.reset();
  }

  print('X: $cursorPosX, Y: $cursorPosY');
  print('${(stopwatch.elapsedMilliseconds / 1000).floor()}s');
}

int getNumberOfSurroundingBombs(Cell cell) {
  int count = 0;

  var neighbors = getNeighbors(cell);
  for (var neighbor in neighbors) {
    if (neighbor.type == 'bomb') {
      count++;
    }
  }

  return count;
}

List<Cell> getNeighbors(Cell cell) {
  List<Cell> neighbors = [];

  for (int y = cell.y - 1; y <= cell.y + 1; y++) {
    if (y < 0 || y > gridSizeY - 1) continue;
    for (int x = cell.x - 1; x <= cell.x + 1; x++) {
      if (x < 0 || x > gridSizeX - 1) continue;
      if (x == cell.x && y == cell.y) continue;

      var neighbor = cells[y]![x];
      neighbors.add(neighbor!);
    }
  }

  return neighbors;
}

void checkForVictory() {
  for (int y = 0; y < gridSizeY; y++) {
    for (int x = 0; x < gridSizeX; x++) {
      var cell = cells[y]![x]!;
      if (cell.type != 'bomb' && cell.hasMined == false) {
        return;
      }
    }
  }

  victory();
}

void mine(Cell cell) {
  if (cell.hasMined) return;

  cell.hasMined = true;
  cell.isFlagged = false;

  checkForVictory();

  var neighbors = getNeighbors(cell);

  if (getNumberOfSurroundingBombs(cell) > 0) return;

  for (var neighbor in neighbors) {
    // if (neighbor.x == fromCell.x && neighbor.y == fromCell.y) continue;
    if (neighbor.type == 'bomb') continue;

    mine(neighbor);
  }
}

void gameOver() {
  stopwatch.stop();
  drawEvent!.cancel();

  for (int y = 0; y < gridSizeY; y++) {
    for (int x = 0; x < gridSizeX; x++) {
      var cell = cells[x]![y];
      if (cell!.type == 'bomb') {
        cell.hasMined = true;
      }
    }
  }

  draw();

  Console.showCursor();
  print('Game over!');

  exit(0);
}

void victory() {
  stopwatch.stop();
  drawEvent!.cancel();

  draw();

  Console.showCursor();
  print('You win!');

  exit(0);
}

void handleInput(String key) {
  if (key == 'w' || key == 'up') cursorPosY--;
  if (key == 'a' || key == 'left') cursorPosX--;
  if (key == 's' || key == 'down') cursorPosY++;
  if (key == 'd' || key == 'right') cursorPosX++;

  if (key == 'f') {
    var cell = cells[cursorPosY]![cursorPosX];
    cell!.isFlagged = !cell.isFlagged;
  }

  if (key == ' ') {
    var cell = cells[cursorPosY]![cursorPosX];

    if (cell!.isFlagged) return;

    if (cell.type == 'bomb') {
      if (gameInProgress) {
        gameOver();
      } else {
        cell.type = 'empty';
        startGame();
        mine(cell);
      }
    } else {
      if (!gameInProgress) {
        startGame();
      }
      mine(cell);
    }
  }

  if (key == '') {
    stopwatch.stop();
    if (drawEvent != null) {
      drawEvent!.cancel();
    }

    clear();
    Console.showCursor();
    exit(0);
  }

  cursorPosX = cursorPosX % gridSizeX;
  cursorPosY = cursorPosY % gridSizeY;

  draw();
}
