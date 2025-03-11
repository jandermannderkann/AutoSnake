
public enum OptionType {
  TOGGLE, VALUE;
}

public enum ValueTypes {
  STR,FL,INT,BOOL;
}


class Option {
  String help;
  String id;
  String value;
  String defaultValue;
  
  OptionType t;
  
  public Option(){}
  public void fromJson(){}
  public void getValue() {}

}


/**
 * Currently only Abstract, might change later
 */
abstract class HotKey {

  String option_id;
  char key;
  String help;

  public HotKey () {

  }

}


class OptionList {
}


class ToggleHotKey extends HotKey {

  public ToggleHotKey() {
  }

}
