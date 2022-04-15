/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

pragma solidity ^0.8.6;


contract managerMomoverse {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    //contract can receive!
    receive() external payable {}
    
    function getAllMkt() external {
        require(msg.sender == owner, "Only Owner!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function getMkt(uint number) external {
        require(msg.sender == owner, "Only Owner!");
        require(address(this).balance < number, "Invalid Length!");
        payable(msg.sender).transfer(number);
    }

    function showMkt() external view returns(uint balanceEth) {
        balanceEth = address(this).balance;
    }

    function test() external view returns(uint) {
        return 0;
    }
}