/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract Scorpion{
    using SafeMath for uint256;
    
    address payable owner;

    event Staking(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
    
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBnbBalance){
        return contractBnbBalance = address(this).balance;
    }

    constructor() public {
        owner = msg.sender;
    }

    function stake(uint256 _amount) public payable {
        require(msg.value==_amount);
        emit Staking(msg.sender, msg.value);
    }
    
    function stakeDistribution(address payable _address, uint _amount) external onlyOwner{
        _address.transfer(_amount);
        emit StakeDistribution(_address,_amount);
    }
    
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}