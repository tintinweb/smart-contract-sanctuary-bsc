/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

/**
 
 * ->> STAKE CRYPTO SMART-CONTRACT DECENTERLIZED <--
 * website: https://stakecrypto.us/


 * Developed by STAKE Crypto  (stakecrypto)

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


contract STAKE_CRYPTO_CONTRACT is ReentrancyGuard, Ownable {

    event Lockup(
        uint256 _order_id,
        address indexed _creator,
        address indexed _beneficiary,
        uint256 indexed _amount,
        uint256 _lockedUntil,
        uint256 _timestamp
    );

    event LockupReverted(
        uint256 _order_id,
        address indexed _creator,
        address indexed _beneficiary,
        uint256 indexed _amount,
        uint256 _timestamp
    );

    event Withdraw(
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
        uint256 lockedUntil;
        uint256 timestamp;
    }

    IERC20 public token;

    mapping(uint256 => TimeLock) public beneficiaryToTimeLock;
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

    function lock(address _beneficiary, uint256 _amount, uint256 _lockedUntil, uint256 _order_id) public nonReentrant onlyLockAdmin(msg.sender) {
        require(_order_id > 0, "Order Required for Lock Transaction!");
        require(_beneficiary != address(0), "You cannot lock up tokens for the zero address!");
        require(_amount > 0, "Lock up amount of zero tokens is invalid!");
        require(beneficiaryToTimeLock[_order_id].amount == 0, "Tokens have already been locked up for the given order id!");
        require(token.allowance(msg.sender, address(this)) >= _amount, "The contract does not have enough of an allowance to escrow!");

        beneficiaryToTimeLock[_order_id] = TimeLock({
            order_id : _order_id,
            creator : msg.sender,
            beneficiary : _beneficiary,
            amount : _amount,
            lockedUntil : _lockedUntil,
            timestamp : block.timestamp
            
        });

        bool transferSuccess = token.transferFrom(msg.sender, address(this), _amount);
        require(transferSuccess, "Failed to escrow tokens into the contract");

        emit Lockup(_order_id, msg.sender, _beneficiary, _amount, _lockedUntil, block.timestamp);
    }

    function revertLock(address _beneficiary, uint256 _order_id) public nonReentrant onlyLockAdmin(msg.sender) {
        require(_order_id > 0, "Order Required for Rewert Transaction!");
        TimeLock storage lockup = beneficiaryToTimeLock[_order_id];
        require(lockup.creator == msg.sender, "Cannot revert a lock unless you are the creator");
        require(lockup.beneficiary == _beneficiary, "Invaild Locker Address!");
        require(lockup.amount > 0, "There are no tokens left to revert lock up for this address");
        uint256 transferAmount = lockup.amount;
        lockup.amount = 0;

        bool transferSuccess = token.transfer(lockup.creator, transferAmount);
        require(transferSuccess, "Failed to send tokens back to lock creator");

        emit LockupReverted(_order_id,msg.sender, _beneficiary, transferAmount, block.timestamp);
    }

    function withdraw(uint256 _order_id) public nonReentrant {
        require(_order_id > 0, "Order Required for Rewert Transaction!");
        TimeLock storage lockup = beneficiaryToTimeLock[_order_id];
        require(lockup.beneficiary == msg.sender, "Invaild Wallet Address, You can't withdraw another wallet balance!");
        require(lockup.amount > 0, "There are no tokens locked up for this address");
        require(block.timestamp >= lockup.lockedUntil, "Tokens are still locked up");
        uint256 transferAmount = lockup.amount;
        lockup.amount = 0;
        bool transferSuccess = token.transfer(msg.sender, transferAmount);
        require(transferSuccess, "Failed to send tokens to the beneficiary");
        emit Withdraw(_order_id,msg.sender, msg.sender);
    }
    

}