pragma solidity ^0.8.0;

import "./a.sol";

contract b is a{
    function doCall(uint256 p) public view returns (uint256){
       uint256 t=test(p); 
       return t;
    }

    function do2() public{
        uint256 t=test(100);
    }
}