/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.0;

//CONTEXT
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

//REENTRANCY GUARD
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


abstract contract ExtraModifiers {
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function _isContract(address addr) internal view returns (bool)
    {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}


abstract contract EtherTransfer {
    function _safeTransferBNB(address to, uint256 value) internal
    {
        (bool success,) = to.call{gas : 23000, value : value}("");
        require(success, "Transfer Failed");
    }
}
//OWNABLE
abstract contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function OwnershipRenounce() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function OwnershipTransfer(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FunPonzi is Ownable, ReentrancyGuard, ExtraModifiers, EtherTransfer {
    event RewardRateUpdated(uint rewardRate);

    struct User {
        address payable investorAddress;
        uint investmentAmount;
    }

    User[] public users;

    uint  public currentlyInvesting = 0;
    uint public totalUsers = 0;
    address payable public dev;

    uint public rewardRate = 133;

    

    constructor() {
        dev = payable(msg.sender);
    }


    function Invest() external payable {
        users.push(User(payable(msg.sender), msg.value));
        totalUsers += 1;
        dev.transfer(msg.value / 10);

        while (address(this).balance > users[currentlyInvesting].investmentAmount * rewardRate / 100) {
            users[currentlyInvesting].investorAddress.transfer(users[currentlyInvesting].investmentAmount * rewardRate/ 100);
        }
    }


    function SetRewardRate(uint256 newRewardRate) external onlyOwner
    {
        rewardRate = newRewardRate;
        emit RewardRateUpdated(rewardRate);
    }

    


}