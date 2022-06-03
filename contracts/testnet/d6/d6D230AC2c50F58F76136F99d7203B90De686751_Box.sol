pragma solidity 0.8.14;

contract Box {
    uint public val; 

    function initialize(uint _val) external {
        val = _val;
    }
}