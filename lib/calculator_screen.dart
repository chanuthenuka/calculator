// Chanuth Enuka - IM/2021/033
import 'package:calculator/button_calues.dart'; //import for button values
import 'package:calculator/history_screen.dart';//import for the history screen
import 'package:flutter/material.dart'; //import for UI
import 'dart:math'; // import for maths opertaions(power)

//widget for the calculator screen.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
  // links calculator screen widget to its state class
}

String operand1 = ""; // stores the first operand (. 0-9 )
String operator = ""; // stores rge selected operator (+ - / * )
String operand2 = ""; // stores the second operand (. 0-9 )
bool isResultDisplayed = false; //tracks if result is displayed or not

class _CalculatorScreenState extends State<CalculatorScreen> {

  List<String> history = [];

  @override
  Widget build(BuildContext context) { //Defines the UI layout for the calculator screen
    final screenSize=MediaQuery.of(context).size; // Retrieves the screen dimensions for responsive design
    
    return Scaffold( //provides the structure for the screen
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        actions: [
          IconButton( //history button
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(history: history), // navigates to history screen
                ),
              );
            },
          ),
        ],
      ),
      
      body:SafeArea( //to ensure UI elements do not overlap with system
        bottom: false,
        child: Column(
          children: [
        // output
        Expanded( //makes tvertical spacehe output section fill available 
          child: SingleChildScrollView( // enables scrolling to stop the overflow of the output
          reverse: true,
            child: Container( //holds and output text
              alignment: Alignment.bottomRight, // have the output in the bottom right
              padding: const EdgeInsets.all(16),
              child: Text(
                "$operand1$operator$operand2".isEmpty
                ? "0"
                : "$operand1$operator$operand2", // displays the number or if nothing 0
                style: const TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end, //aligns the text to the bottom right
              ),
            ),
          ),
        ),
        
        //buttons section
        Wrap( //displays buttons in grid format
          children: Btn.buttonValues.map // map each button value to a sized box
          (
            (value) => SizedBox(
              width: screenSize.width/4, //one button width=screenSize/4
              height: screenSize.width/5, //one button height=width/5
              child: buildButton(value),),
            )
            .toList(),
        )
        
        ],),
      )
    );
  }

  Widget buildButton(value){ //constructs individual buttons
    return Padding( 
      padding: const EdgeInsets.all(3.0), //adds space between buttons
      child: Material( //provides styling
        color: getBtnColor(value),//button colours are added
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(200), //circular buttons
          ),
        child: InkWell( //to add tap feedback
          onTap: () => onBtnTap(value), //handle button taps
          child: Center(
            child: Text(value, 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 24,
            ),
            ),
            ),
        ),
      ),
    );
  }

  // handle button taps
  void onBtnTap(String value){ 
    if(value==Btn.del){
      delete(); // delete last digit in the screen
      return;
    }

    if(value == Btn.clr){
      clearAll(); //clear all in
      return;
    }

    if(value == Btn.per){
      convertToPercentage(); //convert ot percentage
      return;
    }

    if (value == Btn.equal) {
      calculate(); //performs calculation
      return;
    }
    handleInput(value); //handles input
  }

  void handleInput(String value) {
    if (isResultDisplayed) {
      if (int.tryParse(value) != null || value == Btn.dot) {
        clearAll(); // If a number or dot is clicked after a result, clear the screen and start a new calculation
      }
      isResultDisplayed = false;
    }

    appendValue(value);
  }


   
  void calculate() { //do calculations based on operands and operator
  if (operand1.isEmpty || operator.isEmpty || operand2.isEmpty) return;

  double oper1 = double.parse(operand1);
  double oper2 = double.parse(operand2);
  String resultMessage;

  if (operator == Btn.divide) {
    if (oper1 == 0 && oper2 == 0) {      
      resultMessage = "Indeterminate";// Handle 0/0 case
    } else if (oper2 == 0) {      
      resultMessage = "Undefined";// Handle division by zero for other numbers
    } else {      
      double result = oper1 / oper2;// Perform division
      resultMessage = formatResult(result);
    }
  } else {
    double result = 0.0;
    switch (operator) {
      case Btn.add:
        result = oper1 + oper2; //addition
        break;
      case Btn.subtract:
        result = oper1 - oper2; //subtraction
        break;
      case Btn.multiply:
        result = oper1 * oper2; //multiply
        break;
      case Btn.caret:
        result = pow(oper1, oper2).toDouble(); //power
        break;
      default:
        return;
    }
    resultMessage = formatResult(result);
  }

  setState(() {
    history.insert(0, "$operand1 $operator $operand2 = $resultMessage"); //adds to history
    operand1 = resultMessage;
    operator = "";
    operand2 = "";
    isResultDisplayed = true;
  });
}


  // Helper function to format the result
  String formatResult(double result) {
  String resultStr = result.toStringAsFixed(10); // Start with 10 decimal places

  TextStyle textStyle = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
  );

  double availableWidth = MediaQuery.of(context).size.width - 32; // Account for padding

  TextPainter textPainter = TextPainter(
  text: TextSpan(text: resultStr, style: textStyle),
  textDirection: TextDirection.ltr, // Specify left-to-right or right-to-left direction.
);

textPainter.layout(); // Perform layout to calculate size.

while (textPainter.width > availableWidth && resultStr.contains('.')) {
  resultStr = resultStr.substring(0, resultStr.length - 1); // Trim the string.
  textPainter.text = TextSpan(text: resultStr, style: textStyle); // Update text.
  textPainter.layout(); // Re-layout the text.
}


  // Trim trailing zeros and the dot if not necessary
  if (resultStr.contains('.')) {
    resultStr = resultStr.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  return resultStr;
}


  void convertToPercentage() {
  if (operand1.isNotEmpty && operator.isNotEmpty && operand2.isNotEmpty) {
    calculate(); // Perform calculation before conversion.
  }

  if (operator.isNotEmpty) {
    return; // Conversion not allowed if operator exists after calculate().
  }

  final number = double.parse(operand1);
  final percentageResult = number / 100;

  setState(() {
    // Add the conversion operation to the history.
    history.insert(0, "$operand1% = $percentageResult");
    
    // Update operands for displaying the result.
    operand1 = "$percentageResult"; 
    operator = "";
    operand2 = "";
    isResultDisplayed = true;
  });
}


  void clearAll(){ //clear all inputs
    setState(() {
      operand1 ="";
      operator ="";
      operand2 ="";
    });
  }

  void delete() {//delete last character
    if (operand2.isNotEmpty){
      operand2 =operand2.substring(0, operand2.length - 1);
    }else if(operator.isNotEmpty){
      operator = "";
    }else if(operand1.isNotEmpty){
      operand1 =operand1.substring(0, operand1.length - 1);
    }

    setState(() {});
  }

  void appendValue(String value) {
    // Prevent further operations if the result is "Indeterminate" or "Undefined"
    if (operand1 == "Indeterminate" || operand1 == "Undefined") {
      clearAll(); // Clear all inputs to reset the calculator
      return;
    }

    // Handle operator input (`+`, `-`, `*`, `/`, `^`)
  if (value != Btn.dot && int.tryParse(value) == null) {
    if (operator.isNotEmpty && operand2.isNotEmpty) {
      // Perform the calculation if both operands and operator exist
      calculate();
    }

    // After calculation or if operator was empty, set new operator
    operator = value;
    isResultDisplayed = false;
    setState(() {});
    return;
  }

    if (value != Btn.dot && int.tryParse(value) == null) {
      // If operator is pressed, calculate before assigning it to operator
      if (operator.isNotEmpty && operand2.isNotEmpty) {
        calculate();
      }
      operator = value;
    } else if (operand1.isEmpty || operator.isEmpty) {
      // After calculation, if operand1 is empty or operator is empty, reset operand1
      if (operand1 == "" && operand2 == "") {
        operand1 = value;  // Start a new calculation from operand1 with the number clicked
      } else {
        // Append number to operand1, ensuring no multiple dots in operand1
        if (value == Btn.dot && operand1.contains(Btn.dot)) return;
        if (value == Btn.dot && (operand1.isEmpty || operand1 == Btn.dot)) {
          value = "0.";
        }
        operand1 += value;
      }
    } else if (operand2.isEmpty || operator.isNotEmpty) {
      // Append numbers to operand2
      if (value == Btn.dot && operand2.contains(Btn.dot)) return;
      if (value == Btn.dot && (operand2.isEmpty || operand2 == Btn.dot)) {
        value = "0.";
      }
      operand2 += value;
    }

    setState(() {});
  }

  //button colours
  Color getBtnColor(value){
    return [Btn.del, Btn.clr].contains(value)
        ?Color.fromARGB(229, 57, 53, 1)
        : [
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.equal,
            Btn.caret,
          ].contains(value)
            ?const Color.fromARGB(67, 160, 71, 1)
            :const Color.fromARGB(58, 58, 58, 1);
  }

}