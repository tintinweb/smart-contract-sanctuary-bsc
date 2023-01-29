/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

/**
 * ->> KISSAN CHARITY <--
 * website: https://kissantoken.io
 * KSN Contract: 0xC8A11F433512C16ED895245F34BCC2ca44eb06bd

*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
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

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract KISSAN_CHARITY is ReentrancyGuard, Ownable {

    event Stake(
        uint256 _order_id,
        address indexed _creator,
        address indexed _beneficiary,
        uint256 indexed _amount,
        uint256 _lockedUntil,
        uint256 _timestamp
    );

    event Unstake(
        uint256 _order_id,
        address indexed _beneficiary,
        address indexed _caller
    );

    event lockAdminAdd(address indexed _account);

    struct TimeLock {
        uint256 order_id;
        address creator;
        address beneficiary;
        uint256 amount;
        uint256 totalLockedAmount;
        uint256 lockedUntil;
        uint256 timestamp;
    }

    IERC20 public token;

    mapping(uint256 => TimeLock) public stakeToTime;
    address return_stake = address(0x5cb8f3Ec9Bef355C38fF631864d89d1788610311);

    constructor(IERC20 _token) {
        token = _token;
    }

    function stake(address _beneficiary, uint256 _amount, uint256 _order_id) public nonReentrant {
        require(_order_id > 0, "Order Required for Lock Transaction!");
        require(_beneficiary != address(0), "You cannot lock up tokens for the zero address!");
        require(_amount > 0, "Lock up amount of zero tokens is invalid!");
        require(stakeToTime[_order_id].amount == 0, "Tokens have already been locked up for the given order id!");
        require(token.allowance(msg.sender, address(this)) >= _amount, "The contract does not have enough of an allowance to escrow!");
        uint256 lockForTime = uint256(block.timestamp) + 2630000;

        stakeToTime[_order_id] = TimeLock({
            order_id : _order_id,
            creator : msg.sender,
            beneficiary : _beneficiary,
            amount : _amount,
            totalLockedAmount : _amount,
            lockedUntil : lockForTime,
            timestamp : block.timestamp
            
        });

        bool transferSuccess = token.transferFrom(msg.sender, address(this), _amount);
        require(transferSuccess, "Failed to escrow tokens into the contract");

        emit Stake(_order_id, msg.sender, _beneficiary, _amount, lockForTime, block.timestamp);
    }

    

    function unstake(uint256 _order_id) public nonReentrant {
        require(_order_id > 0, "Order Required for Rewert Transaction!");
        TimeLock storage lockup = stakeToTime[_order_id];
        require(lockup.beneficiary == msg.sender, "Invaild Wallet Address, You can't withdraw another wallet balance!");
        require(lockup.amount > 0, "There are no tokens locked up for this address");
        require(block.timestamp >= lockup.lockedUntil, "Tokens are still locked up");
        uint256 lockForTime = uint256(block.timestamp) + 2630000;
        uint256 transferAmount = (lockup.totalLockedAmount*1/100);
        lockup.amount = (lockup.amount-transferAmount);
        lockup.lockedUntil = lockForTime;

        bool transferSuccess = token.transfer(return_stake, transferAmount);
        require(transferSuccess, "Failed to send tokens to the beneficiary");
        emit Unstake(_order_id,return_stake, msg.sender);
    }
    

}