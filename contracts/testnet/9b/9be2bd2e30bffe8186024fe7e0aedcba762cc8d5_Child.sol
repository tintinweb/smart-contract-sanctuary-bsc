contract Child {
  string public constant NAME = "Elon";
}

contract Mommy {
  event NewChild(address son);

  function bringNewLife() external {
    Child child = new Child();
    emit NewChild(address(child));
  }
}