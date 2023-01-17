/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

/** 
 *  SourceUnit: /home/dos/dev/softblock/MintyMarket_Contracts/contracts/Lock.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// ////import "hardhat/console.sol";

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract Lock {
    error NotOwnerError();
    
    uint public unlockTime;
    address public owner;
    bool private lock;
    IPancakeERC20 public LP;
    uint256 public LP_Total;

    constructor (address _token) {
        owner = msg.sender;
        LP = IPancakeERC20(_token);
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
        revert NotOwnerError();
        }
        _;
    }

    function setUnlockTime(uint256 _unlockTime) external onlyOwner {
        require(block.timestamp < _unlockTime, "Unlock time should be in the future");
        require(lock == false, "The tokens are locked");
        lock = true;
        unlockTime = _unlockTime;
    }

    function getUnlockTime() public view returns (uint256) {
        return unlockTime;
    }

    function getLpTotal() external view returns (uint256) {
        return LP_Total;        
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0, "amount = 0");
        require(_amount <= LP_Total, "The amount is greater than what is in the users account");
        require(block.timestamp >= unlockTime, "The tokens are still locked");
        lock = false;
        LP_Total -= _amount;
        LP.transfer(msg.sender, _amount);
    }

    function deposit(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount = 0");
        LP_Total += _amount;
        LP.transferFrom(msg.sender, address(this), _amount);
    }
}