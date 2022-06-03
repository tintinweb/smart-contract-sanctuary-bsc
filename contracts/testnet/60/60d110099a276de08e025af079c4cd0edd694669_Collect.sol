/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity 0.7.6;

contract Collect {
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    function deposit() external payable {
        require(msg.value == 0.1 ether, "please send two ether");
    }
    
    function withdraw() external {
        require(msg.sender == owner, "No");
        msg.sender.transfer(address(this).balance);
    }
    
    // this is observable without help from the contract, could be left out or included as a courtesy
    
    function balance() external view returns(uint balanceEth) {
        balanceEth = address(this).balance;
    }
}