pragma solidity ^0.8.9;

contract Decemal {
    function caculation(uint number) public view returns (uint){
        return number/1e18;
    }
}