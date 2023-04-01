// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: BUSL-1.1
// 2023 Rectngl - Locker Contracts
// https://rectngl.com

// To conduct a support act for good projects we implement a commercial locker contract whose free for everyone with at least one year's commitment.
// Method
// 1. trust
// 2. short
// 3. vesting

// Business Source License 1.1
// License text copyright © 2023 Rectngl Ltd, All Rights Reserved. "Business Source License" is a trademark of Rectngl Ltd.

// Terms

// The Licensor hereby grants you the right to copy, modify, create derivative works, redistribute, and make non-production use of the Licensed Work. The Licensor may make an Additional Use Grant, above, permitting limited production use.
// Effective on the Change Date, or the fourth anniversary of the first publicly available distribution of a specific version of the Licensed Work under this License, whichever comes first, the Licensor hereby grants you rights under the terms of the Change License, and the rights granted in the paragraph above terminate.
// If your use of the Licensed Work does not comply with the requirements currently in effect as described in this License, you must purchase a commercial license from the Licensor, its affiliated entities, or authorized resellers, or you must refrain from using the Licensed Work.
// All copies of the original and modified Licensed Work, and derivative works of the Licensed Work, are subject to this License. This License applies separately for each version of the Licensed Work and the Change Date may vary for each version of the Licensed Work released by Licensor.
// You must conspicuously display this License on each original or modified copy of the Licensed Work. If you receive the Licensed Work in original or modified form from a third party, the terms and conditions set forth in this License apply to your use of that work.
// Any use of the Licensed Work in violation of this License will automatically terminate your rights under this License for the current and all other versions of the Licensed Work.
// This License does not grant you any right in any trademark or logo of Licensor or its affiliates (provided that you may use a trademark or logo of Licensor as expressly required by this License).
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED WORK IS PROVIDED ON AN "AS IS" BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract RectLocker is Ownable {
    event TrustLock(uint256 amount, address from, address tokenAddress);
    event ShortLock(uint256 amount, address from, address tokenAddress);
    event ReleaseLock(uint256 amount, address to, address tokenAddress);
    event ClaimTGE(uint256 amount, address tokenAddress);
    event ClaimVesting(uint256 amount, address tokenAddress);
    event ExtendLock(uint256 newUnlockDate, address from, address tokenAddress);

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Only EOA");
        _;
    }

    uint256 public totalLocked;
    uint256 public vestingFee = 0.5 ether;
    uint256 public shortFee = 1 ether;

    struct LockInfo {
        address owner;
        address tokenAddress;
        uint256 releaseDate;
        uint256 lockDate;
        uint256 amount;
        uint8 method;
        bool isLpToken;
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
        bool isLpToken;
    }

    struct AccountInfo {
        uint256 lockedCount;
        uint256 lockedVestingCount;
        mapping(uint256 => LockInfo) lockinfo;
        mapping(uint256 => LockVestingInfo) lockvestinginfo;
    }

    mapping(address => AccountInfo) public locker;

    constructor(uint256 _shortFee, uint256 _vestingFee) {
        shortFee = _shortFee;
        vestingFee = _vestingFee;
    }

    //----STATEFUL

    //---LOCKING---
    function lock(
        uint256 unlockDate,
        address tokenAddress,
        uint256 amount
    ) external payable onlyEOA {
        if (unlockDate >= block.timestamp + 365 days) {
            trustLock(unlockDate, tokenAddress, amount);
        } else {
            shortLock(unlockDate, tokenAddress, amount);
        }
    }

    function trustLock(
        uint256 unlockDate,
        address tokenAddress,
        uint256 amount
    ) internal {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(unlockDate >= block.timestamp, "Invalid date");
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
            method: 1,
            isLpToken: checkIsLpToken(tokenAddress)
        });
        totalLocked++;
        require(
            tokens.transferFrom(msg.sender, address(this), amount),
            "tx failed"
        );
        emit TrustLock(amount, msg.sender, tokenAddress);
    }

    function shortLock(
        uint256 unlockDate,
        address tokenAddress,
        uint256 amount
    ) internal {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(
            balance >= amount && balance > 0 && amount > 0,
            "invalid amount"
        );
        require(allowance >= amount, "please adjust allowances");
        require(msg.value >= shortFee, "invalid payable amount");
        require(unlockDate >= block.timestamp, "Invalid date");
        AccountInfo storage AInfo = locker[msg.sender];
        AInfo.lockedCount++;
        AInfo.lockinfo[AInfo.lockedCount] = LockInfo({
            owner: msg.sender,
            tokenAddress: tokenAddress,
            releaseDate: unlockDate,
            lockDate: block.timestamp,
            amount: amount,
            method: 2,
            isLpToken: checkIsLpToken(tokenAddress)
        });
        totalLocked++;
        require(
            tokens.transferFrom(msg.sender, address(this), amount),
            "tx failed"
        );
        emit ShortLock(amount, msg.sender, tokenAddress);
    }

    function vestingLock(
        address tokenAddress,
        uint256 amount,
        uint256 init_date,
        uint8 percentTGE,
        uint8 percentCliff,
        uint16 dayCliff
    ) public payable onlyEOA {
        (uint256 balance, uint256 allowance, ERC20 tokens) = _tokenProxy(
            tokenAddress,
            msg.sender
        );
        require(init_date >= block.timestamp, "Invalid date");
        require(allowance >= amount, "please adjust allowances");
        require(msg.value >= vestingFee, "invalid payable amount");
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
            method: 3,
            isLpToken: checkIsLpToken(tokenAddress)
        });
        totalLocked++;
        require(
            tokens.transferFrom(msg.sender, address(this), amount),
            "tx failed"
        );
    }

    function checkIsLpToken(address token) private view returns (bool) {
        address possibleFactoryAddress;
        try IUniswapV2Pair(token).factory() returns (address factory) {
            possibleFactoryAddress = factory;
        } catch {
            return false;
        }

        if (
            possibleFactoryAddress != address(0) &&
            _isValidLpToken(token, possibleFactoryAddress)
        ) return true;
        else return false;
    }

    function _isValidLpToken(address token, address factory)
        private
        view
        returns (bool)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(token);
        address factoryPair = IUniswapV2Factory(factory).getPair(
            pair.token0(),
            pair.token1()
        );
        return factoryPair == token;
    }

    //---EXTEND---
    function extendLock(uint256 lockId, uint256 newUnlockDate)
        external
        payable
        onlyEOA
    {
        require(msg.value >= (shortFee * 80) / 100, "invalid payable amount");
        LockInfo storage LInfo = locker[msg.sender].lockinfo[lockId];
        require(msg.sender == LInfo.owner, "invalid owner");
        require(LInfo.amount > 0, "this lock id is already unlocked");
        require(newUnlockDate > LInfo.releaseDate, "invalid new unlock date");

        LInfo.releaseDate = newUnlockDate;
        emit ExtendLock(newUnlockDate, msg.sender, LInfo.tokenAddress);
    }

    //---RELEASE---
    function releaseLock(uint256 lockId) external onlyEOA {
        LockInfo storage LInfo = locker[msg.sender].lockinfo[lockId];
        (uint256 balance, , ERC20 tokens) = _tokenProxy(
            LInfo.tokenAddress,
            address(this)
        );

        require(block.timestamp >= LInfo.releaseDate, "Not unlocked yet");
        require(msg.sender == LInfo.owner, "invalid owner");
        require(balance > 0 && LInfo.amount > 0, "invalid balance");
        uint256 txAmount = LInfo.amount;
        LInfo.amount = 0;
        totalLocked--;
        require(
            tokens.transfer(msg.sender, txAmount),
            "tx failed / non standard token"
        );
        emit ReleaseLock(txAmount, msg.sender, LInfo.tokenAddress);
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
            require(block.timestamp >= LVInfo.initDate, "invalid TGE Date");
            uint256 rAmount = ((LVInfo.amount * LVInfo.percentTGE) * 100) /
                10000;
            LVInfo.dynamicAmount -= rAmount;
            LVInfo.currentStep++;
            require(
                tokens.transfer(msg.sender, rAmount),
                "tx failed / non standard token"
            );
            emit ClaimTGE(rAmount, LVInfo.tokenAddress);
        } else if (LVInfo.currentStep == LVInfo.totalStep - 1) {
            //FINAL RELEASE
            require(
                block.timestamp >=
                    LVInfo.initDate + (LVInfo.dayCliff * LVInfo.currentStep),
                "invalid cliff date"
            );
            LVInfo.currentStep++;
            uint256 rAmount = LVInfo.dynamicAmount;
            LVInfo.dynamicAmount = 0;
            LVInfo.amount = 0;
            totalLocked--;
            require(
                tokens.transfer(msg.sender, rAmount),
                "tx failed / non standard token"
            );
            emit ReleaseLock(rAmount, msg.sender, LVInfo.tokenAddress);
        } else {
            //RELEASE CYCLE
            require(
                block.timestamp >=
                    LVInfo.initDate + (LVInfo.dayCliff * LVInfo.currentStep),
                "invalid cliff date"
            );
            LVInfo.currentStep++;
            uint256 rAmount = ((LVInfo.amount * LVInfo.percentCliff) * 100) /
                10000;
            LVInfo.dynamicAmount -= rAmount;
            require(
                tokens.transfer(msg.sender, rAmount),
                "tx failed / non standard token"
            );
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
        uint256 balances = tokens.balanceOf(owner);
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
    function setFee(uint256 shortValue, uint256 vestingValue) public onlyOwner {
        shortFee = shortValue;
        vestingFee = vestingValue;
    }

    function withdrawFee() external onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}