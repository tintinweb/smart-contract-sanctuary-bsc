pragma solidity 0.8.10; 

contract Box{
    uint public num;

    function initialize(uint _val) external {
        num = _val;
    }

    function addOne() external {
        num = num + 1;
    }

    function addTwo() external {
        num = num + 2;
    }
 
}