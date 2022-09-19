/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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

contract StackingFuture{
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);
    address aggregator;

    event Staking(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
    
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized owner.");
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
        return contractBalance = busd.balanceOf(address(this));
    }

    constructor() public {
        aggregator = msg.sender;
    }

    function stake(uint256 _busd) public security {
        busd.transferFrom(msg.sender,address(this),_busd);
        emit Staking(msg.sender, _busd);
    }
    
    function stakeDistribution(address payable _staker, uint _busd) external security onlyAggregator{
        busd.transfer(_staker,_busd);
        emit StakeDistribution(_staker,_busd);
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