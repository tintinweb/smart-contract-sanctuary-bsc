/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.5.11;

contract Contr {
    mapping(address => uint) balances;

    function invest() external payable {
        if(msg.value < 0.00000000000000002 ether) {
            revert();
        }
        balances[msg.sender] +=msg.value;
    }
    function balanceOf() external view returns(uint) {
        return address(this).balance;
    } 
    address payable[] recipients;
    function sendEther(address payable recipient ) external {
        recipient.transfer(1 ether);

        address a;
        a = recipient;



        msg.sender.transfer(100);

        recipient.transfer(1 ether);
    }

}