/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    mapping (address => bool) private _authorized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _authorized[_msgSender()] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuthorized() {
        require(_authorized[_msgSender()] == true, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function setAuthorized(address account, bool isAuthorized) public onlyOwner {
        _authorized[account] = isAuthorized;
    }
}

contract LostMetasAntiBot is Ownable {
    uint256 private timeAntiBot = 120;
    uint256 private launchTime;

    function setBotSettingTime(uint256 _val) external onlyAuthorized {
        require(launchTime == 0 && _val <= 300, "Already launched or max 5 minuts.");
        timeAntiBot = _val;
    }

    function setLaunchTime(uint256 _launchTime) external onlyAuthorized {
        require(launchTime == 0, "Already launched.");
        launchTime = _launchTime;
    }

    function checkAntiBotStatus() external view onlyAuthorized returns (bool, bool) {
        require(launchTime != 0, "Not launched yet.");
        bool isBot = block.timestamp <= launchTime + timeAntiBot;
        bool isBlacklist = !isBot && block.timestamp <= launchTime + timeAntiBot + 5;
        return (isBot, isBlacklist);
    }

}