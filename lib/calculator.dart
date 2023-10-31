import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String output = '';

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  List<String> calculationHistory = [];

  void addToHistory(String input, String output) {
    calculationHistory.add('$input = $output');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        actions: [
          IconButton(
              onPressed: onHistoryPressed,
              icon: const Icon(Icons.history_rounded)),
        ],
      ),
      body: Column(
        children: <Widget>[
          /// Input Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                input,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ),

          /// Output Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                output,
                style: const TextStyle(
                    fontSize: 36.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          /// Keyboard Layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("("),
              buildButton(")"),
              buildButton("%"),
              buildButton("C"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("7"),
              buildButton("8"),
              buildButton("9"),
              buildButton("÷"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("4"),
              buildButton("5"),
              buildButton("6"),
              buildButton("×"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("1"),
              buildButton("2"),
              buildButton("3"),
              buildButton("-"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("0"),
              buildButton("."),
              buildButton("="),
              buildButton("+"),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        onButtonPressed(buttonText);
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }

  // Define a function to handle button clicks
  void onButtonPressed(String value) {
    if (value == '=') {
      // Calculate and update the result
      final result = calculate(input);
      return setState(() {
        output = result;
      });
    }

    if (value == 'C') {
      // Clear the input and output
      return setState(() {
        input = '';
        output = '';
      });
    }

    if (canAppendValue(input, value)) {
      // Append the value to the input
      return setState(() {
        input += value;
      });
    }
  }

  // TODO: Show Popup dialog displaying calculation history so that when user
  // clicks a line, replace current input and output with input and output from
  // that line
  // See Google Calculator for reference: https://i.imgur.com/iwKp1JS.gif

  void onHistoryPressed() async {
    final historyList = await loadCalculationHistory();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calculation History'),
          content: SingleChildScrollView(
            child: Column(
              children: historyList.map((calculation) {
                return ListTile(
                  title: Text(calculation),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // TODO: Load last run history from file
  // Note: Everytime user pressed "=" to get math result, calculation input and
  // output should be persisted to disk for retrieving later.
  //
  // Reference: https://docs.flutter.dev/cookbook/persistence/key-value
  Future<List<String>> loadCalculationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('calculationHistory') ?? [];

    return historyList;
  }

  String inputH = '';
  String outputH = '';

  void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    // obtain shared preferences

// set value
    // await prefs.setString('input', input);
    //await prefs.setString('output', output);

// Try reading data from the counter key. If it doesn't exist, return 0.
    prefs.setString('input', input);

    prefs.setString('output', output);
    inputH = (prefs.getString('input') ?? '');
    outputH = (prefs.getString('output') ?? '');

    final historyList = prefs.getStringList('calculationHistory') ?? [];
    //final calculation = calculationHistory;
    final calculation = '$inputH = $outputH';
    //historyList.add(calculation);
    historyList.add(calculation);

    await prefs.setStringList('calculationHistory', calculationHistory);
  }
}

// TODO: Return true when next value or operation can be added to current input
// Example:
//  ----------------
//  currentInput: 5
//  nextValue: ÷
//  Output: true
//  ----------------
//  currentInput: 5÷
//  nextValue: /
//  Output: false (Invalid operation: 5÷/)
bool canAppendValue(String currentInput, String nextValue) {
  List<String> reg = ["×", "÷"];
  List<String> regPlus = ["+", "-"];
  if (currentInput.length >= 1) {
    if (reg.any((value) =>
                currentInput[currentInput.length - 1].contains(value)) ==
            true &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else if (currentInput == '' &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else if (regPlus.any((value) =>
                currentInput[currentInput.length - 1].contains(value)) ==
            true &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else if (regPlus.any((value) => currentInput[0].contains(value)) ==
            true &&
        regPlus.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else
      return true;
  } else if (currentInput.length == 0) {
    if (reg.any((value) => currentInput.contains(value)) == true &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else if (currentInput == '' &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else if (regPlus.any((value) => currentInput.contains(value)) == true &&
        reg.any((value) => nextValue.contains(value)) == true) {
      return false;
    } else
      return true;
  }

  return true;
}

String calculateIfBracket(String input) {
  int start = input.indexOf("(") + 1;
  int end = input.indexOf(")", start);
  String result = input.substring(start, end);
  return result;
}

int check(String test) {
  List<String> reg = ["+", "-", "×", "÷"];

  for (int i = 0; i < test.length; i++) {
    if (reg.any((value) => test[i].contains(value)) == true &&
        reg.any((value) => test[i + 1].contains(value)) == true) {
      return i;
    }
    if (reg.any((value) => test[0].contains(value)) == true) {
      return 0;
    }
    if (reg.any((value) => test[test.length - 1].contains(value)) == true) {
      return test.length;
    }
  }
  return -1;
}

String checkBracket(String input) {
  late String inputNew = input;
  double resultBracker = 0;
  List<String> reg = ["+", "-", "×", "÷"];
  List<String> opeMulDiv = ["+", "-", "×", "÷"];
  int start = 0;
  int end = 0;

  if (inputNew.contains('(') == true) {
    String res = calculateIfBracket(inputNew);

    for (int i = 0; i < res.length; i++) {
      if (i > 0) {
        if (res[i] == '-' &&
            reg.any((value) => res[i - 1].contains(value)) == false &&
            res[i + 1] != '-') {
          res = res.substring(0, i) + '+' + res.substring(i);
        }
        if (res[i] == '-' &&
            reg.any((value) => res[i - 1].contains(value)) == false &&
            res[i + 1] == '-') {
          res = res.substring(0, i) + '+' + res.substring(i + 1);
        }
        if (opeMulDiv.any((value) => res[i].contains(value)) == true &&
            res[i + 1] == '+') {
          res = res.substring(0, i) +
              res.substring(i, i + 1) +
              res.substring(i + 2);
        }
      }
    }

    List<String> operator = res.split(RegExp(r'[-.\d]'))
      ..removeWhere((element) => element.isEmpty);

    RegExp numberRegex = RegExp(r'-?\d+(\.\d+)?');

    Iterable<Match> matches = numberRegex.allMatches(res);
    List<double> number =
        matches.map((match) => double.parse(match.group(0)!)).toList();

    List<String> numberStr =
        List.generate(number.length, (i) => number[i].toString());
    List<String> calculation = [];

    int maxLength =
        numberStr.length > operator.length ? numberStr.length : operator.length;
    for (int i = 0; i < maxLength; i++) {
      if (i < numberStr.length) {
        calculation.add(numberStr[i]);
      }
      if (i < operator.length) {
        if (operator[i] == '÷') {
          calculation.add('/');
          continue;
        }
        if (operator[i] == '×') {
          calculation.add('*');
        } else {
          calculation.add(operator[i]);
        }
      }
    }

// clean "*" and "/" first
    while (calculation.contains("*") || calculation.contains("/")) {
      final pos = calculation.indexWhere((e) => e == "*" || e == "/");
      double leftOp = double.parse((calculation[pos - 1]));
      double rightOp = double.parse(calculation[pos + 1]);
      switch (calculation[pos]) {
        case "*":
          resultBracker = leftOp * rightOp;
          break;
        case "/":
          resultBracker = leftOp / rightOp;
          break;
      }
      calculation.removeAt(pos);
      calculation.removeAt(pos);
      calculation[pos - 1] = resultBracker.toString();
    }

// Then After calculated "*" and "/" perform calculate on "+" and "-"
    while (calculation.length > 1) {
      final pos = calculation.indexWhere((e) => e == "-" || e == "+");
      double leftOp = double.parse((calculation[pos - 1]));
      double rightOp = double.parse(calculation[pos + 1]);
      switch (calculation[pos]) {
        case "-":
          resultBracker = leftOp - rightOp;
          break;
        case "+":
          resultBracker = leftOp + rightOp;
          break;
      }
      calculation.removeAt(pos);
      calculation.removeAt(pos);
      calculation[pos - 1] = resultBracker.toString();
    }
    for (int i = 0; i < input.length; i++) {
      if (input[i].contains('(')) {
        start = i;
      }
      if (input[i].contains(')')) {
        end = i;
      }
    }

    if (start == 0 && end == input.length - 1) {
      return resultBracker.toString();
    }

    String test = input.replaceAll(RegExp(r'\([^)]*\)'), '');
    int index = check(test);
    if (index == 0) {
      inputNew = resultBracker.toString() + test;
    } else if (index == test.length) {
      inputNew = test + resultBracker.toString();
    } else if (index == -1) {
      inputNew = test;
    } else {
      inputNew = test.substring(0, index + 1) +
          resultBracker.toString() +
          test.substring(index + 1);
    }
  }
  return inputNew;
}

// TODO: Return calculation result given the input operations
// Example:
//  Input: 5.6×-9.21+12÷-0.521
//  Output: -75.576
String calculate(String input) {
  final containsBrackets = input.contains('('); // true
  double result = 0;
  double resultBracker = 0;
  late String inputNew = input;
  List<String> reg = ["+", "-", "×", "÷"];
  List<String> opeMulDiv = ["+", "-", "×", "÷"];

  if (inputNew.contains('(') == true) {
    inputNew = checkBracket(inputNew);
  }

  for (int i = 0; i < inputNew.length; i++) {
    if (i > 0) {
      if (inputNew[i] == '-' &&
          reg.any((value) => inputNew[i - 1].contains(value)) == false &&
          inputNew[i + 1] != '-') {
        inputNew = inputNew.substring(0, i) + '+' + inputNew.substring(i);
      }
      if (inputNew[i] == '-' &&
          reg.any((value) => inputNew[i - 1].contains(value)) == false &&
          inputNew[i + 1] == '-') {
        inputNew = inputNew.substring(0, i) + '+' + inputNew.substring(i + 1);
      }
      if (opeMulDiv.any((value) => inputNew[i].contains(value)) == true &&
          inputNew[i + 1] == '+') {
        inputNew = inputNew.substring(0, i) +
            inputNew.substring(i, i + 1) +
            inputNew.substring(i + 2);
      }
    }
  }

  List<String> calculation = [];

  List<String> operator = inputNew
      .split(RegExp(r'[-.\d]'))
      .where((element) => element.isNotEmpty)
      .toList();

  RegExp numberRegex = RegExp(r'-?\d+(\.\d+)?');

  Iterable<Match> matches = numberRegex.allMatches(inputNew);
  List<double> number =
      matches.map((match) => double.parse(match.group(0)!)).toList();

  List<String> numberStr =
      List.generate(number.length, (i) => number[i].toString());

  int maxLength =
      numberStr.length > operator.length ? numberStr.length : operator.length;
  for (int i = 0; i < maxLength; i++) {
    if (i < numberStr.length) {
      calculation.add(numberStr[i]);
    }
    if (i < operator.length) {
      if (operator[i] == '÷') {
        calculation.add('/');
        continue;
      }
      if (operator[i] == '×') {
        calculation.add('*');
      } else {
        calculation.add(operator[i]);
      }
    }
  }

  List<String> opMulDiv = ["×", "÷"];

  print("calc $calculation");

// clean "*" and "/" first
  while (calculation.contains("*") || calculation.contains("/")) {
    final pos = calculation.indexWhere((e) => e == "*" || e == "/");
    double leftOp = double.parse((calculation[pos - 1]));
    double rightOp = double.parse(calculation[pos + 1]);
    switch (calculation[pos]) {
      case "*":
        result = leftOp * rightOp;
        break;
      case "/":
        result = leftOp / rightOp;
        break;
    }
    calculation.removeAt(pos);
    calculation.removeAt(pos);
    calculation[pos - 1] = result.toString();
  }

// Then After calculated "*" and "/" perform calculate on "+" and "-"
  while (calculation.length > 1) {
    final pos = calculation.indexWhere((e) => e == "-" || e == "+");
    double leftOp = double.parse((calculation[pos - 1]));
    double rightOp = double.parse(calculation[pos + 1]);
    switch (calculation[pos]) {
      case "-":
        result = leftOp - rightOp;
        break;
      case "+":
        result = leftOp + rightOp;
        break;
    }
    calculation.removeAt(pos);
    calculation.removeAt(pos);
    calculation[pos - 1] = result.toString();
  }
  while (calculation.length == 1) return calculation[0];

  return result.toString();
}
