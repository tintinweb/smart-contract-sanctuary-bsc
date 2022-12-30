/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

pragma solidity ^0.4.0;

contract SalesContract {
    address public owner;
    bool public sold = false;
    string public salesDescription = 'Targetas antiradiacion happhuman';
    uint price = 2 ether;
    
    function SalesContract() payable {
        owner = msg.sender;
    }
    
    function buy() payable {
        if(msg.value >= price) {
            owner.transfer(this.balance);
            owner = msg.sender;
            sold = true;
        } else {
            revert();
        }
    }
}