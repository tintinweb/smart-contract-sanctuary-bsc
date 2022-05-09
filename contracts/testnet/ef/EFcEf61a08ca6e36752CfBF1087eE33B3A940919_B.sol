/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

pragma solidity 0.6.0;

interface C {
    function dotest() external;
}

contract B {
  address public adr1;
  address public adr2;
  uint public num1;
  uint public num2;
  uint public num3;
   
  function setAdr (uint n, address _target) public {
    if (n == 1)
      adr1 = _target;
    else
      adr2 = _target;
  }

  function func1() internal {
    num3 = 213;
  }

  function func2() external {
    num2 = 222;
    func1();
  }

  function func3() public {
    num1 = 231;
    func1();
  }

  function func4() public {
    num1 = 241;
  }

  function func5() public {
    C(adr2).dotest();
  }
  
  function callbackfunc() public {
    num2 = 252;
  }

  function reset() public{
    num1 = 0;
    num2 = 0;
    num3 = 0;
  }
}