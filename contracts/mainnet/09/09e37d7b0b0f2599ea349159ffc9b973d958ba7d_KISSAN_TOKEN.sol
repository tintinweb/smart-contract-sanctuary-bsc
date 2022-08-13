/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/


/**
 * Developed by Sunil Kumar 
 * ->> KISSAN TOKEN LOCKUP STAKING <--
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


contract KISSAN_TOKEN is ReentrancyGuard, Ownable {


    event Lockup(
        address indexed _creator,
        address indexed _beneficiary,
        uint256 indexed _amount,
        uint256 _lockedUntil,
        uint256 _timestamp
    );

    event LockupReverted(
        address indexed _creator,
        address indexed _beneficiary,
        uint256 indexed _amount,
        uint256 _timestamp
    );

    event Withdraw(
        address indexed _beneficiary,
        address indexed _caller
    );

    event lockAdminAdd(address indexed _account);

    struct TimeLock {
        address creator;
        uint256 amount;
        uint256 lockedUntil;
        uint256 timestamp;
    }

    IERC20 public token;

    mapping(address => TimeLock) public beneficiaryToTimeLock;
    mapping(address => bool) public lockAdmin;

    modifier onlyLockAdmin(address _account) {
        require(lockAdmin[_account] == true);
        _;
    }

    constructor(IERC20 _token) {
        token = _token;
        setLockAdmin(msg.sender);
    }

    function setLockAdmin(address _account) public onlyOwner {
        lockAdmin[_account] = true;
        emit lockAdminAdd(_account);
    }

    function unsetLockAdmin(address _account) public onlyOwner {
        lockAdmin[_account] = false;
        emit lockAdminAdd(_account);
    }

    function lock(address _beneficiary, uint256 _amount, uint256 _lockedUntil) public nonReentrant onlyLockAdmin(msg.sender) {
        require(_beneficiary != address(0), "You cannot lock up tokens for the zero address");
        require(_amount > 0, "Lock up amount of zero tokens is invalid");
        require(beneficiaryToTimeLock[_beneficiary].amount == 0, "Tokens have already been locked up for the given address");
        require(token.allowance(msg.sender, address(this)) >= _amount, "The contract does not have enough of an allowance to escrow");

        beneficiaryToTimeLock[_beneficiary] = TimeLock({
            creator : msg.sender,
            amount : _amount,
            lockedUntil : _lockedUntil,
            timestamp : block.timestamp
            
        });

        bool transferSuccess = token.transferFrom(msg.sender, address(this), _amount);
        require(transferSuccess, "Failed to escrow tokens into the contract");

        emit Lockup(msg.sender, _beneficiary, _amount, _lockedUntil, block.timestamp);
    }

    function revertLock(address _beneficiary) public nonReentrant onlyLockAdmin(msg.sender) {
        TimeLock storage lockup = beneficiaryToTimeLock[_beneficiary];
        require(lockup.creator == msg.sender, "Cannot revert a lock unless you are the creator");
        require(lockup.amount > 0, "There are no tokens left to revert lock up for this address");

        uint256 transferAmount = lockup.amount;
        lockup.amount = 0;

        bool transferSuccess = token.transfer(lockup.creator, transferAmount);
        require(transferSuccess, "Failed to send tokens back to lock creator");

        emit LockupReverted(msg.sender, _beneficiary, transferAmount, block.timestamp);
    }

    function withdraw() public nonReentrant {
        TimeLock storage lockup = beneficiaryToTimeLock[msg.sender];
        require(lockup.amount > 0, "There are no tokens locked up for this address");
        require(block.timestamp >= lockup.lockedUntil, "Tokens are still locked up");

        uint256 transferAmount = lockup.amount;
        lockup.amount = 0;

        bool transferSuccess = token.transfer(msg.sender, transferAmount);
        require(transferSuccess, "Failed to send tokens to the beneficiary");
        emit Withdraw(msg.sender, msg.sender);
    }
    

}