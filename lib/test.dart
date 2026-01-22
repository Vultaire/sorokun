import 'dart:math';

List<List<int>> generateOutput(List<int> input) {
  List<List<int>> output = [];
  List<int>? previousList;
  Random random = Random();

  for (int length in input) {
    List<int> currentList = [];

    // Generate the last digit first (cannot be 0)
    if (length > 0) {
      List<int> availableForLast = List.generate(10, (index) => index);
      availableForLast.remove(0); // Last digit cannot be 0

      // Remove the value at the last index from previous list if it exists
      if (previousList != null && length - 1 < previousList.length) {
        availableForLast.remove(previousList[length - 1]);
      }

      if (availableForLast.isNotEmpty) {
        int lastDigit =
            availableForLast[random.nextInt(availableForLast.length)];
        currentList.add(lastDigit);
      }
    }

    // Generate the rest of the digits
    for (int i = 0; i < length - 1; i++) {
      List<int> available = List.generate(10, (index) => index);

      // Remove the value at this index from the previous list if it exists
      if (previousList != null && i < previousList.length) {
        available.remove(previousList[i]);
      }

      // Remove already used values in current list
      for (int used in currentList) {
        available.remove(used);
      }

      // Pick a random available value
      if (available.isNotEmpty) {
        int randomIndex = random.nextInt(available.length);
        currentList.add(available[randomIndex]);
      }
    }

    // Move the first element (which was the last digit) to the end
    if (currentList.isNotEmpty) {
      int lastDigit = currentList.removeAt(0);
      currentList.add(lastDigit);
    }

    output.add(currentList);
    previousList = currentList;
  }

  return output;
}

// Example usage:
void main() {
  List<int> input = [10, 8, 6, 8, 10, 5, 9, 6, 5, 10];
  List<List<int>> result = generateOutput(input);

  for (var list in result) {
    print(list);
  }
}
