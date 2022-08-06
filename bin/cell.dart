// I really don't need a class for this but I was too
// lazy to change it back

class Cell {
  final int x;
  final int y;

  String type;

  bool hasMined;
  bool isFlagged;

  // default values
  Cell({
    this.x = 0,
    this.y = 0,
    this.type = 'empty',
    this.hasMined = false,
    this.isFlagged = false,
  });
}
