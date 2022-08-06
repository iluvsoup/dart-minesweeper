# Command-line minesweeper tool I made in Dart

## Requirements:
Dart

## Getting started
Install required packages with
```bash
dart pub get
```

## Compile with
```bash
dart compile jit-snapshot bin/minesweeper.dart -o dist/minesweeper.jit
```
or
```bash
dart compile aot-snapshot bin/minesweeper.dart -o dist/minesweeper.aot
```

## Run with
```bash
dart run
```
or
```bash
dart run dist/minesweeper.jit
```
or
```bash
dartaotruntime dist/minesweeper.aot
```

This might not work on windows, I can't say for sure because I don't use windows