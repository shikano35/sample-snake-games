import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

enum Direction { up, down, left, right }

class _SnakeGamePageState extends State<SnakeGamePage> {
  int noOfRow = 38, noOfColumn = 21;
  List<int> borderList = [];
  List<int> snakePosition = [];
  int snakeHeade = 0;
  int score = 0;
  late int foodPosition;
  late FocusNode focusNode;
  late Direction direction;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    startGame();
  }

  void despose() {
    focusNode.dispose();
    super.initState();
  }

  void startGame() {
    setState(() {
      score = 0;
      makeBorder();
      generateFood();
      direction = Direction.right;
      snakePosition = [50, 49, 48];
      snakeHeade = snakePosition.first;
    });

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      updateSnake();
      if (checkCollision()) {
        timer.cancel();
        showDialogBox();
      }
    });
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(
            "You Final Score is $score",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  bool checkCollision() {
    if (borderList.contains(snakeHeade)) {
      return true;
    }
    if (snakePosition.sublist(1).contains(snakeHeade)) {
      return true;
    }
    return false;
  }

  void generateFood() {
    foodPosition = Random().nextInt(noOfRow * noOfColumn);
    if (borderList.contains(foodPosition) ||
        snakePosition.contains(foodPosition)) {
      generateFood();
    }
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snakePosition.insert(0, snakeHeade - noOfColumn);
          break;
        case Direction.down:
          snakePosition.insert(0, snakeHeade + noOfColumn);
          break;
        case Direction.right:
          snakePosition.insert(0, snakeHeade + 1);
          break;
        case Direction.left:
          snakePosition.insert(0, snakeHeade - 1);
          break;
      }
    });

    if (snakeHeade == foodPosition) {
      score++;
      generateFood();
    } else {
      snakePosition.removeLast();
    }
    snakeHeade = snakePosition.first;
  }

  void handledKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (direction != Direction.down) direction = Direction.up;
          break;
        case LogicalKeyboardKey.arrowDown:
          if (direction != Direction.up) direction = Direction.down;
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (direction != Direction.right) direction = Direction.left;
          break;
        case LogicalKeyboardKey.arrowRight:
          if (direction != Direction.left) direction = Direction.right;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: KeyboardListener(
          focusNode: focusNode,
          onKeyEvent: (KeyEvent event) {
            handledKey(event);
          },
          autofocus: true,
          child: Column(
            children: [
              Text(
                "Score:$score",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Expanded(child: groundForSnake()),
            ],
          ),
        ),
      ),
    );
  }

  Widget groundForSnake() {
    return GridView.builder(
      itemCount: noOfRow * noOfColumn,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: noOfColumn,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: boxFillColor(index),
          margin: EdgeInsets.only(right: 1, bottom: 1),
        );
      },
    );
  }

  Color boxFillColor(int index) {
    if (borderList.contains(index)) {
      return Colors.blue;
    } else {
      if (snakePosition.contains(index)) {
        if (snakeHeade == index) {
          return Colors.green;
        } else {
          return Colors.black45;
        }
      } else {
        if (index == foodPosition) {
          return Colors.green;
        }
      }
    }
    return Colors.white60;
  }

  void makeBorder() {
    borderList.clear();
    for (int i = 0; i < noOfColumn; i++) {
      borderList.add(i);
    }
    for (int i = 0; i < noOfRow * noOfColumn; i += noOfColumn) {
      borderList.add(i);
    }
    for (int i = noOfColumn - 1; i < noOfRow * noOfColumn; i += noOfColumn) {
      borderList.add(i);
    }
    for (
      int i = (noOfRow * noOfColumn) - noOfColumn;
      i < noOfRow * noOfColumn;
      i++
    ) {
      borderList.add(i);
    }
  }
}
