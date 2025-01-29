import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({Key? key}) : super(key: key);

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String input = '';
  String result = '0';
  final TextEditingController _controller = TextEditingController();

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
        _controller.clear();
      } else if (value == '=') {
        result = _calculateResult(input);
      } else {
        input += value;
        _controller.text = input;
        _controller.selection = TextSelection.collapsed(offset: input.length);
      }
    });
  }

  String _calculateResult(String expression) {
    try {
      String sanitizedExpression = expression.replaceAll('x', '*').replaceAll('÷', '/');
            if (sanitizedExpression.contains('%')) {
        final regex = RegExp(r'(\d+)%');
        sanitizedExpression = sanitizedExpression.replaceAllMapped(regex, (match) {
          final value = int.parse(match.group(1)!);
          return (value / 100).toString();
        });
      }

      final expressionParsed = Expression.parse(sanitizedExpression);
      final evaluator = ExpressionEvaluator();
      final evalResult = evaluator.eval(expressionParsed, {});
      if (evalResult is double) {
        if (evalResult == evalResult.toInt()) {
          return evalResult.toInt().toString();
        }
        return evalResult.toStringAsFixed(2);
      } else {
        return evalResult.toString();
      }
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildButtonGrid(),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    const buttons = [
      '7', '8', '9', '÷',
      '4', '5', '6', 'x',
      '1', '2', '3', '-',
      'C', '0', '=', '+',
      '%', // Added percentage button
    ];

    return Expanded(
      flex: 2,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: buttons.length,
        itemBuilder: (context, index) {
          final button = buttons[index];
          return _buildButton(button);
        },
      ),
    );
  }

  Widget _buildButton(String label) {
    return GestureDetector(
      onTap: () => buttonPressed(label),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _isOperator(label) ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              color: _isOperator(label) ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool _isOperator(String label) {
    return ['+', '-', 'x', '÷', '=', '%'].contains(label);
  }
}
