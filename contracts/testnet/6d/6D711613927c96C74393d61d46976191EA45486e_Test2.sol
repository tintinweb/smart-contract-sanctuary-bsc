/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

pragma solidity 0.6.12;
contract Test2{
    constructor() public {}
    function test1() public payable  returns(bool){
        require(1==2,"#1");
    }
    function rescuebnb()public returns(bool){
        msg.sender.transfer(address(this).balance);
        return true;
    }
}