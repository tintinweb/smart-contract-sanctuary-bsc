// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.1;

import "../ERC20.sol";
import "../SafeMath.sol";
import "../Ownable.sol";

contract airdropCBL is Ownable{

    using SafeMath for uint256;
    ERC20 public airdropToken;
    struct airdrop{
        uint256 amount;
        uint256 lockedUntil;
    }

    mapping (address => airdrop) internal userBalance;

    constructor(address token) {
        airdropToken = ERC20(token);
    }

    function assignAirdrop(address to, uint256 amount, uint256 lockTime) public onlyOwner {
        airdropToken.transferFrom(owner(), address(this), amount);
        userBalance[to] = airdrop(amount, block.timestamp + lockTime);
    }

    function getAirdrop(address user) public view returns (uint256, uint256){
        return (userBalance[user].amount, userBalance[user].lockedUntil);
    }

    function claimAirdrop() public {
        (uint256 amount, uint256 locked) = getAirdrop(msg.sender);
        require(amount > 0 && locked < block.timestamp, "airdrop is not claimable");
        userBalance[msg.sender] = airdrop(0, 0);
        airdropToken.transfer(msg.sender, amount);
    }
}