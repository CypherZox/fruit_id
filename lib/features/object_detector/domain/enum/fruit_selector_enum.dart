enum FruitSelectorEnum {
  apple,
  banana,
  grape,
  lemon,
  orange,
}

extension FruitSelectorExtention on FruitSelectorEnum {
  String get title {
    switch (this) {
      case FruitSelectorEnum.apple:
        return 'Apple';
      case FruitSelectorEnum.grape:
        return 'Grape';
      case FruitSelectorEnum.banana:
        return 'Banana';
      case FruitSelectorEnum.lemon:
        return 'Lemon';
      case FruitSelectorEnum.orange:
        return 'Orange';
    }
  }

  String get icon {
    switch (this) {
      case FruitSelectorEnum.apple:
        return 'assets/images/apple.svg';
      case FruitSelectorEnum.grape:
        return 'assets/images/grapes.svg';
      case FruitSelectorEnum.orange:
        return 'assets/images/orange.svg';
      case FruitSelectorEnum.lemon:
        return 'assets/images/lemon.svg';
      case FruitSelectorEnum.banana:
        return 'assets/images/banana.svg';
    }
  }
}
