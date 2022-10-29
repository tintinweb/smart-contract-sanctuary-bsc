/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    
    function calculateFeesBeforeSend(
        address sender,
        address recipient,
        uint256 amount
    ) external view returns (uint256, uint256);
    
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract Faucet {
    

    address public immutable token = address(0x49C9AB88196A41ab971C66fA585c05220A247374); 
    mapping(address => uint256) public nextClaim;
    
    function getCurrentFaucetReward() public view returns (uint256){
        return (IERC20(token).balanceOf(address(this)) /100000);
    }
    
    function getNextClaimTime(address claimer) public view returns (uint256) {
        return nextClaim[claimer] > 0 ? nextClaim[claimer] : block.timestamp;
    }

    constructor() {
    }
    
    function getFaucetTokens() external {
        uint256 timeNow = block.timestamp;
        require(timeNow >= getNextClaimTime(msg.sender), "getFaucetTokens:: Wallet may only claim once every 24 hours.");
        // set in advance to prevent reentrancy
        nextClaim[msg.sender] = timeNow + (1 hours);
        uint256 transferToAmount = getCurrentFaucetReward(); // .001% of tokens on the contract get transferred
        require(IERC20(token).transfer(address(msg.sender), transferToAmount), "Error in withdrawing tokens");
    }
}