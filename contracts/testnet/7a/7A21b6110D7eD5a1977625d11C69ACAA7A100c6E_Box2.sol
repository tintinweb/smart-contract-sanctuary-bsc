pragma solidity 0.8.10; 

contract Box2{
    uint public num;

    function addOne() external {
        num = num - 1;
    }

    function addTwo() external {
        num = num - 2;
    }
 
    function setOne() external {
        num = 1;
    }

}