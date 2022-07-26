/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

contract PetroCanadsStaking{
    using SafeMath for uint256;
    BEP20 public token = BEP20(0x37af59151Bd431C90D4510E0926651A27281A912);
    address payable owner;
    
    
    event Register(address depositor, uint256 amount);
    event Stake(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
    event DepositDistribution(address receiver, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBnbBalance, uint256 contractTokenBalance){
        return (
            contractBnbBalance = address(this).balance,
            contractTokenBalance = token.balanceOf(address(this))
        );
    }

    constructor() public {
        owner = msg.sender;
    }

    function register() payable public {
        emit Register(msg.sender, msg.value);
    }
    
    function stake(uint256 amount) public {
        token.transferFrom(msg.sender,address(this),amount);
        emit Stake(msg.sender, amount);
    }

    function stakeDistribution(address _address, uint _amount) external onlyOwner{
        token.transfer(_address,_amount);
        emit StakeDistribution(_address,_amount);
    }
    
    function depositDistribution(address payable _address, uint _amount) external onlyOwner{
        _address.transfer(_amount);
        emit DepositDistribution(_address,_amount);
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