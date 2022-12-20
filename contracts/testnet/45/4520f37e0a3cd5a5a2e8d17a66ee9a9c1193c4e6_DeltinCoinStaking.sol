/**
 *Submitted for verification at BscScan.com on 2022-12-20
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

contract DeltinCoinStaking{
    BEP20 public DELT = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);
    address signer;
    
    event Stake(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
   
    modifier signature(){
        require(msg.sender == signer,"Invalid signer.");
        _;
    }
    
    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    function getContractInfo() view public returns(uint256 contractBalance){
        return contractBalance = DELT.balanceOf(address(this));
    }

    constructor() public {
        signer = msg.sender;
    }

    function stake(uint256 amount) public security{
        DELT.transferFrom(msg.sender,address(this),amount);
        emit Stake(msg.sender, amount);
    }

    function stakeDistribution(address _address, uint _amount) external signature security{
        DELT.transfer(_address,_amount);
        emit StakeDistribution(_address,_amount);
    }

}