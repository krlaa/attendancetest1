const KEY = "cop49O04ttendance7est";

String encryptStringWithXORtoHex(input, key) {
  var c = '';
  while (key.length < input.length) {
    key += key;
  }
  for (var i = 0; i < input.length; i++) {
    var value1 = input[i].codeUnitAt(0);
    var value2 = key[i].codeUnitAt(0);

    var xorValue = value1 ^ value2;
    // print(xorValue);
    var xorValueAsHexString = xorValue.toRadixString(16);

    if (xorValueAsHexString.length < 2) {
      xorValueAsHexString = "0" + xorValueAsHexString;
    }

    c += xorValueAsHexString;
  }
  return c;
}

String decryptStringWithXORFromHex(String input, String key) {
  var c = [];
  while (key.length < input.length / 2) {
    key += key;
  }

  for (int i = 0; i < input.length; i += 2) {
    String hexValueString = input.substring(i, i + 2);
    int value1 = int.parse(hexValueString, radix: 16);
    int value2 = key.codeUnitAt((i / 2).round());

    int xorValue = value1 ^ value2;
    c.add(String.fromCharCode(xorValue));
  }
  return c.join();
}

