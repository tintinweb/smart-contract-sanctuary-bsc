/**
 *Submitted for verification at BscScan.com on 2022-07-16
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

contract LSTbscLocked is Ownable {
    uint public startTime;
    uint public lockperiodindays;
    uint public lockedamount;
    uint public endTime;
    IERC20 public basetoken = IERC20(0x019992270e95b800671d3bc1d763E07e489687B2);

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