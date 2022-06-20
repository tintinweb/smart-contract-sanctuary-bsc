/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity 0.8.6;



contract MockTarget {
    
    uint public x;
    address public addr;
    uint public y;


    function setX(uint newX) public {
        x = newX;
    }

    function setY(uint newY) public {
        y = newY;
    }


    receive() external payable {}
}