/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LockingStorage {
    struct LockInfo {
        address depositor;
        uint256 releaseAt;
        uint256 amount;
        string memo;
    }

    address public owner;
    bool public isClosed;

    LockInfo[] locks;

    event Vasting(uint256 indexed lockId, address indexed depositorAddr, uint256 amount, uint256 duration, string memo);
    event Withdraw(uint256 indexed lockId, address indexed depositorAddr, address recipientAddr, uint256 amount);
    event ChangeOwner(address newOwner);
    event CloseContract();
}

contract LockingToken is LockingStorage {
    IBEP20 token;

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not owner of contract');
        _;
    }

    constructor(address tokenContract) public {
        token = IBEP20(tokenContract);
        owner = msg.sender;
    }

    /**
     * Vasting token to contract
     */
    function vasting(
        uint256 amount,
        uint256 releaseAt,
        string memory memo
    ) public returns (uint256) {
        require(!isClosed, 'Contract is closed');

        // Transfer token
        require(token.transferFrom(msg.sender, address(this), amount), 'Can not transfer token');

        LockInfo memory l;
        l.amount = amount;
        l.releaseAt = releaseAt;
        l.memo = memo;
        l.depositor = msg.sender;

        uint256 lockId = locks.length;
        locks.push(l);

        emit Vasting(lockId, msg.sender, amount, releaseAt, memo);
        return lockId;
    }

    /**
     * Withdraw token from smart contract
     */
    function withdraw(uint256 lockId, address recipientAddr) public {
        require(lockId < locks.length, 'Does not exist');
        LockInfo storage l = locks[lockId];
        require(l.depositor == msg.sender, 'Not depositor');
        require(l.releaseAt <= block.timestamp, 'Vasting is not time to withdraw');

        address receiver = recipientAddr;
        if (receiver == address(0)) {
            receiver = msg.sender;
        }

        require(token.transfer(msg.sender, l.amount), 'Can not transfer token');

        emit Withdraw(lockId, l.depositor, receiver, l.amount);
        delete locks[lockId];
    }

    /**
     * Change contract's owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit ChangeOwner(newOwner);
    }

    /**
     * Close contract
     */
    function closeContract() public onlyOwner {
        isClosed = true;
        emit CloseContract();
    }

    /**
     * Get information of an vasting
     */
    function getLockInfo(uint256 lockId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            string memory
        )
    {
        LockInfo storage l = locks[lockId];
        return (l.depositor, l.releaseAt, l.amount, l.memo);
    }

    /**
     * Count how many vasting there are in contract
     */
    function getDepositCount() public view returns (uint256) {
        return locks.length;
    }
}