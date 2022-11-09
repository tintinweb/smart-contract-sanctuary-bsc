/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

pragma solidity ^0.8.0;
contract Revert1{
    function f() public {
        revert("revert1");
    }
}

contract Revert2{
    function f() public{
        revert("revert2");
    }
}

contract TestRevert {
Revert1 r1;
Revert2 r2;
constructor() public{
    r1=new Revert1();
    r2=new Revert2();
}

function f() public{
    address(r1).call{value: 0}(msg.data);
    address(r2).call{value: 0}(msg.data);
}

function test() public payable{
    address(msg.sender).call{value: msg.value}(msg.data);
}

function test1() public payable{
    address(msg.sender).call{value: msg.value}(msg.data);
    revert("revert3");
}

function test2(address  to) public payable{
    to.call{value: msg.value}(msg.data);
}

function test3(address  to) public payable{
    to.call{value: msg.value}(msg.data);
    revert("revert3");
}

}