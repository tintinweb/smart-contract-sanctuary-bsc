/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

pragma solidity 0.6.0;

contract A {
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
  
  function test(uint n) public {
    if (n == 1)
        address(adr1).delegatecall(abi.encodeWithSignature("func1()"));
    else if (n == 2)
        address(adr1).delegatecall(abi.encodeWithSignature("func2()"));
    else if (n == 3)
        address(adr1).delegatecall(abi.encodeWithSignature("func3()"));
    else if (n == 4)
        address(adr1).delegatecall(abi.encodeWithSignature("func4()"));
    else if (n == 5)
        address(adr1).delegatecall(abi.encodeWithSignature("func5()"));  
  }

  function reset() public{
    num1 = 0;
    num2 = 0;
    num3 = 0;
  }

  fallback() external {
      num1 = 100;
  }
}