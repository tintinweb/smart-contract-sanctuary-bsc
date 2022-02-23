/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

contract LockingStorage {
    struct LockInfo {
        address depositor;
        address tokenAddr;
        uint256 lockingDuration;
        uint256 depositAt;
        uint256 amount;
        string memo;
    }

    address public owner;
    bool public isClosed;

    LockInfo[] deposits;

    event Vasting(
        uint256 indexed lockId,
        address indexed tokenAddr,
        address indexed depositorAddr,
        uint256 amount,
        uint256 duration,
        string memo
    );
    event Withdraw(
        uint256 indexed lockId,
        address indexed tokenAddr,
        address indexed depositorAddr,
        address recipientAddr,
        uint256 amount
    );
    event ChangeOwner(address newOwner);
    event CloseContract();
}

contract Locking is LockingStorage {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner of contract");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
     * Vasting token to contract
     */
    function vasting(
        address tokenAddr,
        uint256 amount,
        uint256 lockingDuration,
        string memory memo
    ) public returns (uint256) {
        require(!isClosed, "Contract is closed");

        // Transfer token
        bool transferred = _executeTransferFrom(
            tokenAddr,
            msg.sender,
            address(this),
            amount
        );
        require(transferred, "Can not transfer token");

        LockInfo memory d;
        d.tokenAddr = tokenAddr;
        d.amount = amount;
        d.lockingDuration = lockingDuration;
        d.memo = memo;
        d.depositor = msg.sender;
        d.depositAt = block.timestamp;

        uint256 lockId = deposits.length;
        deposits.push(d);
        emit Vasting(
            lockId,
            tokenAddr,
            msg.sender,
            amount,
            lockingDuration,
            memo
        );
        return lockId;
    }

    /**
     * Withdraw token from smart contract
     */
    function withdraw(uint256 lockId, address recipientAddr) public {
        require(lockId < deposits.length, "Does not exist");
        LockInfo storage d = deposits[lockId];
        require(d.depositor == msg.sender, "Not depositor");
        require(
            d.depositAt + d.lockingDuration <= block.timestamp,
            "Vasting is not time to withdraw"
        );

        address receiver = recipientAddr;
        if (receiver == address(0)) {
            receiver = msg.sender;
        }

        bool transferred = _executeTransfer(d.tokenAddr, receiver, d.amount);
        require(transferred, "Can not transfer token");

        emit Withdraw(lockId, d.tokenAddr, d.depositor, receiver, d.amount);
        delete deposits[lockId];
    }

    function _executeTransferFrom(
        address tokenAddr,
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        bytes memory payload = abi.encodeWithSignature(
            "transferFrom(address,address,uint256)",
            from,
            to,
            amount
        );
        (bool success, ) = tokenAddr.call(payload);
        return success;
    }

    function _executeTransfer(
        address tokenAddr,
        address to,
        uint256 amount
    ) internal returns (bool) {
        bytes memory payload = abi.encodeWithSignature(
            "transfer(address,uint256)",
            to,
            amount
        );
        (bool success, ) = tokenAddr.call(payload);
        return success;
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
            address,
            uint256,
            uint256,
            uint256,
            string memory
        )
    {
        LockInfo storage d = deposits[lockId];
        return (
            d.depositor,
            d.tokenAddr,
            d.lockingDuration,
            d.depositAt,
            d.amount,
            d.memo
        );
    }

    /**
     * Count how many vasting there are in contract
     */
    function getDepositCount() public view returns (uint256) {
        return deposits.length;
    }
}