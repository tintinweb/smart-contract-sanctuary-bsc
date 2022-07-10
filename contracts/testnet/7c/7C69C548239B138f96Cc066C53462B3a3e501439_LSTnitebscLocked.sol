/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Context{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
} 

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract LSTnitebscLocked is Ownable {
    uint public startTime;
    uint public lockperiodindays;
    uint public lockedamount;
    uint public endTime;
    IERC20 public basetoken = IERC20(0x71764ab6b32DB707b42Fd9878b5b9c22d3324b0e);

    constructor(uint _lockdays){
        startTime = block.timestamp;
        lockperiodindays = _lockdays;
        endTime = startTime + (lockperiodindays * 1 days);
    }

    function WithdrawLST(uint256 _amount) public onlyOwner {
        require(block.timestamp > endTime,"Locking Period");
        payable(msg.sender).transfer(_amount);
    }
}