/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
/*

 /$$   /$$ /$$$$$$$$       /$$$$$$$$ /$$
| $$  / $$|_____ $$/      | $$_____/|__/
|  $$/ $$/     /$$/       | $$       /$$ /$$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$
 \  $$$$/     /$$/        | $$$$$   | $$| $$__  $$ |____  $$| $$__  $$ /$$_____/ /$$__  $$
  >$$  $$    /$$/         | $$__/   | $$| $$  \ $$  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$
 /$$/\  $$  /$$/          | $$      | $$| $$  | $$ /$$__  $$| $$  | $$| $$      | $$_____/
| $$  \ $$ /$$/           | $$      | $$| $$  | $$|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$
|__/  |__/|__/            |__/      |__/|__/  |__/ \_______/|__/  |__/ \_______/ \_______/

Contract: A time lock contract for initial liquidity for X7 Tokens.

This contract will be deployed in place of the "Liquidity Hub" in the X7 ecosystem until token trading is live.
It provides a means for accumulating native token reserves for initial liquidity while providing transparency and safety.
When reserves have reached an acceptable level, the destination will be set to a launch contract which will support airdrop, spot price cash out and launch activities.

This contract will NOT be renounced.

The following are the only functions that can be called on the contract that affect the contract:

    function setUnlockTime(uint256 newTime) external onlyOwner {
        require(newTime > unlockTime, "Cannot decrease time lock");
        unlockTime = newTime;
    }

    function setDestination(address destination_) external onlyOwner {
        require(destination != destination_ && !destinationFrozen);
        destination = destination_;
    }

    function freezeDestination() external onlyOwner {
        require(!destinationFrozen);
        destinationFrozen = true;
    }

*/

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract X7RInitialLiquidityTimeLock is Ownable {

    uint256 public unlockTime;
    address public destination;
    bool public destinationFrozen = false;

    address public token;

    constructor (uint256 unlockTime_, address token_) Ownable(msg.sender) {
        if (unlockTime_ == 0) {
            // Default 30 day lock time
            unlockTime = block.timestamp + (60 * 60 * 24 * 30);
        }
        token = token_;
    }

    receive() external payable {
        if (destination != address(0) && block.timestamp > unlockTime) {
            (bool ok,) = destination.call{value: msg.value}("");
            require(ok);
        }
    }

    function setUnlockTime(uint256 newTime) external onlyOwner {
        require(newTime > unlockTime, "Cannot decrease time lock");
        unlockTime = newTime;
    }

    function setDestination(address destination_) external onlyOwner {
        require(destination != destination_ && !destinationFrozen);
        destination = destination_;
    }

    function freezeDestination() external onlyOwner {
        require(!destinationFrozen);
        destinationFrozen = true;
    }

    function sendToDestination() external {
        require(destination != address(0) && block.timestamp > unlockTime);
        (bool ok,) = destination.call{value: address(this).balance}("");
        require(ok);

        IERC20 token_ = IERC20(token);
        uint256 balance = token_.balanceOf(address(this));
        if (balance > 0) {
            token_.transfer(destination, balance);
        }
    }
}