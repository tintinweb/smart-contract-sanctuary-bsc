// SPDX-License-Identifier: MIT

//                 .................
//             ...::^~~!!777777!!~~^::...
//          ...:~!777777777777777???77!~:...
//       ...:^!7777777777G&&P7777777777?77~:...
//      ..:[email protected]@@@?777777777777?7~:..
//    ...^[email protected]@@@?77777777777777?7^...            :777777777!~.      :!777:          ^777!.    ~777^         :777!.                                       ~777!:        :!777^
//   ...~!!!!!!!!!B&@@@@@@@@@@@@&&B57777777777?!...           [email protected]@@@@@@@@@@@&Y.   [email protected]@@@#         :&@@@@P   [email protected]@@@@Y       [email protected]@@@@5                                      [email protected]@@@@@?       [email protected]@@@&.
//  ...~!!!!!!!!!7&@@@@@@@@@@@@@@@@@@57777777777!...          [email protected]@@@@@@@@@@@@@#.  [email protected]@@@#         :&@@@@P   [email protected]@@@@@P     [email protected]@@@@@#.                                     [email protected]@@@@@@G.     [email protected]@@@&.
// ...^[email protected]@@@Y7777777777~...         [email protected]@@@B. [email protected]@@@@?  [email protected]@@@#         :&@@@@P  .&@@@@@@@G.  [email protected]@@@@@@@^      .^!77!~:          .^!77!~:     [email protected]@@@@@@@&!    [email protected]@@@&.
// ..:~~~~~~~~!!!!~~~~~~~~~~!!!!!!&@@@G!7777777777:..         [email protected]@@@B.  [email protected]@@@@~  [email protected]@@@#         :&@@@@P  [email protected]@@@@@@@@#^[email protected]@@@@@@@@?   .Y&@@@@@@@@@B!    :5&@@@@@@@@&G~  [email protected]@@@@@@@@@5.  [email protected]@@@&.
// ..^~~~~~~~~~~~~?5PPPPPPPPPPPPG&@@@@?!7777777777^..         [email protected]@@@@@@@@@@@@@P   [email protected]@@@#         :&@@@@P  [email protected]@@@@&@@@@@@@@@@&@@@@G  [email protected]@@@@@@@@@@@@@#: [email protected]@@@@@@@@@@@@@[email protected]@@@@[email protected]@@@@#^ [email protected]@@@&.
// ..^[email protected]@@@@@@@@@@@@@@@@@@?!!!777777777~..         [email protected]@@@@@@@@@@@@@@B^ [email protected]@@@#         :&@@@@P  [email protected]@@@#~#@@@@@@@&[email protected]@@@&:[email protected]@@@@P:. .!&@@@@#[email protected]@@@@Y:...7&@@@@[email protected]@@@@?^#@@@@@[email protected]@@@&.
// ..:[email protected]@@@&7!!!!!!77777^..         [email protected]@@@&[email protected]@@@@&[email protected]@@@&.        :&@@@@P :&@@@@P [email protected]@@@@&^ [email protected]@@@@[email protected]@@@B      ^@@@@@&@@@@P      [email protected]@@@@[email protected]@@@@? [email protected]@@@@&@@@@&.
// ..:^^^~~~~~~~~~~^^^^~~~~~~~~~~!&@@@P~!!!!!!!!!7:..         [email protected]@@@B      [email protected]@@@@[email protected]@@@@!        [email protected]@@@@? [email protected]@@@@?  [email protected]@@#:  [email protected]@@@@[email protected]@@@B      ^@@@@@@@@@@5      [email protected]@@@@[email protected]@@@@?   !&@@@@@@@@&.
// ...^^^^^^^~~~~~^[email protected]@@@Y~!!!!!!!!7~...         [email protected]@@@B:...:!#@@@@@7:&@@@@&J.    :[email protected]@@@@#. [email protected]@@@@^    J#P.   .&@@@@[email protected]@@@@Y.   ^#@@@@&[email protected]@@@@?.   ~&@@@@[email protected]@@@@?    [email protected]@@@@@@&.
//  ...^^^^^^^^^^[email protected]@@@@@@@@@@@@@@@@@P~!!!!!!!!!~...          [email protected]@@@@@@@@@@@@@@@P  ^&@@@@@@&&&@@@@@@@#: .&@@@@#.            [email protected]@@@@[email protected]@@@@@&&&@@@@@&^[email protected]@@@@@&&@@@@@@#:[email protected]@@@@?      [email protected]@@@@@&.
//   ...^^^^^^^^^[email protected]@@@@@@@@@@@@@&#P7~~~!!!!!!!~...           [email protected]@@@@@@@@@@@@&G^     7#@@@@@@@@@@@@B7   [email protected]@@@@5             [email protected]@@@@? ^P&@@@@@@@@@#?.   [email protected]@@@@@@@@@#7  [email protected]@@@@7       :[email protected]@@@&.
//    ...:^^^^^^^^^[email protected]@@@7!!!~~~~~~~~~~!!!^...            :!!!!!!!!!!!^:          .^7JYYYYJ7^.      ^!!!~.              ^!!!~.    :!?JYJ?~.        .^7JJJJ7~.     ^!!!~          ^!!!:
//     ....:^^^^^^^^^^^^[email protected]@@@!^~~~~~~~~~~~~~^:...
//       ....::^^^^^^^^^^P&&5^^^~~~~~~~~~~^:...
//         ....:::^^^^^^^:^^^^^^^^~~~~^^:...
//            .....:::::^^^^^^^^^^::::....
//                 ..................

// 2022 BUMooN.io - Locker Contracts
// https://bumoon.io
// BUMooN Locker Contracts

// To conduct a support act for good projects we implement a commercial locker contract whose free for everyone with at least one year's commitment.
// Method
// 1. trust
// 2. short
// 3. vesting

pragma solidity ^0.8.14;

import "../dependencies/Ownable.sol";

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract BooLocker is Ownable {
    event TrustLock(uint256 amount, address from, address tokenAddress);
    event ShortLock(uint256 amount, address from, address tokenAddress);
    event ReleaseLock(uint256 amount, address to, address tokenAddress);
    event ForceRelease(uint256 amount, address to, address tokenAddress);
    event ClaimTGE(uint256 amount, address tokenAddress);
    event ClaimVesting(uint256 amount, address tokenAddress);

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Only EOA");
        _;
    }

    uint256 public totalLocked;
    uint256 public shortFee = 0.5 ether;
    uint256 public penaltyFee = 1 ether;

    struct LockInfo {
        address owner;
        address tokenAddress;
        uint256 releaseDate;
        uint256 lockDate;
        uint256 amount;
        uint8 method;
    }

    struct LockVestingInfo {
        address owner;
        address tokenAddress;
        uint256 lockDate;
        uint256 amount;
        uint256 dynamicAmount;
        uint256 initDate;
        uint24 dayCliff;
        uint16 totalStep;
        uint16 currentStep;
        uint8 percentCliff;
        uint8 percentTGE;
        uint8 method;
    }

    struct AccountInfo {
        uint256 lockedCount;
        uint256 lockedVestingCount;
        mapping(uint256 => LockInfo) lockinfo;
        mapping(uint256 => LockVestingInfo) lockvestinginfo;
    }

    mapping(address => AccountInfo) public locker;

    //----STATEFUL

    //---LOCKING---
    function trustLock(
        uint256 unlockDate,
        address tokenAddress,
        uint256 amount
    ) external onlyEOA {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(unlockDate > block.timestamp, "Invalid date");
        require(allowance >= amount, "please adjust allowances");
        require(unlockDate >= block.timestamp + 365 days, "invalid date");
        require(
            balance >= amount && balance > 0 && amount > 0,
            "invalid amount"
        );
        AccountInfo storage AInfo = locker[msg.sender];
        AInfo.lockedCount++;
        AInfo.lockinfo[AInfo.lockedCount] = LockInfo({
            owner: msg.sender,
            tokenAddress: tokenAddress,
            releaseDate: unlockDate,
            lockDate: block.timestamp,
            amount: amount,
            method: 1
        });
        totalLocked++;
        tokens.transferFrom(msg.sender, address(this), amount);
        emit TrustLock(amount, msg.sender, tokenAddress);
    }

    function vestingLock(
        address tokenAddress,
        uint256 amount,
        uint256 init_date,
        uint8 percentTGE,
        uint8 percentCliff,
        uint16 dayCliff
    ) public onlyEOA {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(init_date > block.timestamp, "Invalid date");
        require(allowance >= amount, "please adjust allowances");
        require(
            balance >= amount && balance > 0 && amount > 0 && dayCliff > 0,
            "invalid amount / vlaue"
        );
        require(
            percentTGE > 0 && percentTGE < 100,
            "invalid tge percentage, use trustlock instead"
        );
        require(
            percentCliff > 0 && percentCliff < 100,
            "invalid tge percentage, use trustlock instead"
        );

        //-----------------------
        AccountInfo storage AInfo = locker[msg.sender];
        AInfo.lockedVestingCount++;

        AInfo.lockvestinginfo[AInfo.lockedVestingCount] = LockVestingInfo({
            owner: msg.sender,
            tokenAddress: tokenAddress,
            lockDate: block.timestamp,
            amount: amount,
            dynamicAmount: amount,
            initDate: init_date,
            totalStep: ((100 - percentTGE) % percentCliff) == 0
                ? (((100 - percentTGE) / percentCliff) + 1)
                : (((100 - percentTGE) / percentCliff) + 2),
            currentStep: 0,
            percentCliff: percentCliff,
            percentTGE: percentTGE,
            dayCliff: dayCliff * 1 days,
            method: 3
        });
        totalLocked++;
        tokens.transferFrom(msg.sender, address(this), amount);
    }

    function shortLock(
        uint256 unlockDate,
        address tokenAddress,
        uint256 amount
    ) external payable onlyEOA {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(
            balance >= amount && balance > 0 && amount > 0,
            "invalid amount"
        );
        require(allowance >= amount, "please adjust allowances");
        require(msg.value * 1 ether >= shortFee, "invalid payable amount");
        require(unlockDate > block.timestamp, "Invalid date");
        AccountInfo storage AInfo = locker[msg.sender];
        AInfo.lockedCount++;
        AInfo.lockinfo[AInfo.lockedCount] = LockInfo({
            owner: msg.sender,
            tokenAddress: tokenAddress,
            releaseDate: unlockDate,
            lockDate: block.timestamp,
            amount: amount,
            method: 2
        });
        totalLocked++;
        tokens.transferFrom(msg.sender, address(this), amount);
        emit ShortLock(amount, msg.sender, tokenAddress);
    }

    //---RELEASE---
    function releaseLock(uint256 lockId) external onlyEOA {
        LockInfo storage LInfo = locker[msg.sender].lockinfo[lockId];
        (uint256 balance, , ERC20 tokens) = _tokenProxy(
            LInfo.tokenAddress,
            address(this)
        );

        require(LInfo.releaseDate >= block.timestamp, "Not unlocked yet");
        require(msg.sender == LInfo.owner, "invalid owner");
        require(balance > 0 && LInfo.amount > 0, "invalid balance");
        LInfo.amount = 0;
        totalLocked--;
        tokens.transfer(msg.sender, LInfo.amount);
        emit ReleaseLock(LInfo.amount, msg.sender, LInfo.tokenAddress);
    }

    function forceRelease(uint256 lockId) external payable onlyEOA {
        require(msg.value * 1 ether >= penaltyFee, "invalid payable amount");
        LockInfo storage LInfo = locker[msg.sender].lockinfo[lockId];
        (uint256 balance, , ERC20 tokens) = _tokenProxy(
            LInfo.tokenAddress,
            address(this)
        );
        require(balance > 0 && LInfo.amount > 0, "invalid balance");
        require(msg.sender == LInfo.owner, "invalid owner");
        LInfo.amount = 0;
        totalLocked--;
        tokens.transfer(msg.sender, LInfo.amount);
        emit ForceRelease(LInfo.amount, msg.sender, LInfo.tokenAddress);
    }

    function releaseVesting(uint256 lockId) external onlyEOA {
        LockVestingInfo storage LVInfo = locker[msg.sender].lockvestinginfo[
            lockId
        ];
        (uint256 balance, , ERC20 tokens) = _tokenProxy(
            LVInfo.tokenAddress,
            address(this)
        );
        require(msg.sender == LVInfo.owner, "invalid owner");
        require(balance > 0 && LVInfo.amount > 0, "invalid balance");
        require(LVInfo.dynamicAmount > 0, "vesting finished");
        if (LVInfo.currentStep == 0) {
            //RELEASE TGE
            require(LVInfo.initDate >= block.timestamp, "invalid TGE Date");
            uint256 rAmount = ((LVInfo.amount * LVInfo.percentTGE) * 100) /
                10000;
            LVInfo.dynamicAmount -= rAmount;
            LVInfo.currentStep++;
            tokens.transfer(msg.sender, rAmount);
            emit ClaimTGE(LVInfo.amount, LVInfo.tokenAddress);
        } else if (LVInfo.currentStep == LVInfo.totalStep - 1) {
            //FINAL RELEASE
            require(
                LVInfo.initDate + (LVInfo.dayCliff * LVInfo.currentStep) >=
                    block.timestamp,
                "invalid cliff date"
            );
            LVInfo.currentStep++;
            uint256 rAmount = LVInfo.dynamicAmount;
            LVInfo.dynamicAmount = 0;
            tokens.transfer(msg.sender, rAmount);
            emit ReleaseLock(rAmount, msg.sender, LVInfo.tokenAddress);
        } else {
            //RELEASE CYCLE
            require(
                LVInfo.initDate + (LVInfo.dayCliff * LVInfo.currentStep) >=
                    block.timestamp,
                "invalid cliff date"
            );
            LVInfo.currentStep++;
            uint256 rAmount = ((LVInfo.amount * LVInfo.percentCliff) * 100) /
                10000;
            LVInfo.dynamicAmount -= rAmount;
            tokens.transfer(msg.sender, rAmount);
            emit ClaimVesting(rAmount, LVInfo.tokenAddress);
        }
    }

    //----VIEW
    function _tokenProxy(address tokenAddress, address owner)
        private
        view
        returns (
            uint256 balance,
            uint256 allowance,
            ERC20 token
        )
    {
        ERC20 tokens = ERC20(tokenAddress);
        uint256 balances = tokens.balanceOf(msg.sender);
        uint256 allowances = tokens.allowance(owner, address(this));
        return (balances, allowances, tokens);
    }

    function viewLockCount(address addr)
        public
        view
        returns (uint256 lockedCount, uint256 lockedVestingCount)
    {
        AccountInfo storage AInfo = locker[addr];
        return (AInfo.lockedCount, AInfo.lockedVestingCount);
    }

    function viewLockVestingByID(uint256 id, address addr)
        public
        view
        returns (LockVestingInfo memory LVInfo)
    {
        AccountInfo storage AInfo = locker[addr];
        LockVestingInfo storage LVInfos = AInfo.lockvestinginfo[id];

        return (LVInfos);
    }

    function viewLockByID(uint256 id, address addr)
        public
        view
        returns (LockInfo memory LInfo)
    {
        AccountInfo storage AInfo = locker[addr];
        LockInfo storage LInfos = AInfo.lockinfo[id];

        return (LInfos);
    }

    //----ALIGNMENT
    function setFee(uint256 shortValue, uint256 penaltyValue) public onlyOwner {
        shortFee = shortValue;
        penaltyFee = penaltyValue;
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}