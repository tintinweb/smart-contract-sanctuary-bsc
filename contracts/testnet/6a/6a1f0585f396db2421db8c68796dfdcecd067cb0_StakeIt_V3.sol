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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Initialize} from "./config/initialize.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract StakeIt_V3 is Initialize {
    function initialize(
        address signer,
        address stc_addr,
        address[] memory tokenAddress, // 0 - BUSD, 1 - Voucher
        bool[] memory isAffRewardEnabled,
        address _operatorAddress,
        address ownerAddress,
        uint256 _deployTime
    ) public IsInitialized {
        assembly {
            sstore(signerAddress.slot, signer)
            sstore(STC_Addr.slot, stc_addr)
            sstore(operatorAddress.slot, _operatorAddress)
        }
        BUSD = IERC20(tokenAddress[0]);
        VoucherAddr = IERC20(tokenAddress[1]);
        currentTokenPoolID = 2;
        initPackages();
        initPools(tokenAddress, isAffRewardEnabled);
        lastRewardPerShareUpdate = _deployTime;
        initLevelRewards();
        initLevelsRefferalCount();
        initAdminActiveInAllPacks();
        _transferOwnership(ownerAddress);
        isInitialized = 1;
    }

    function addAffsAndDepositToken(
        userDetails storage userdetails,
        uint tokenPoolID,
        Pools memory PoolInfo
    ) private {
        uint price = PoolInfo.price;

        if (PoolInfo.isAffiliateRewardEnabled) {
            addAffiliateRewardAmountToTheReffs(
                PoolInfo.tokenAddress,
                tokenPoolID,
                userdetails,
                price
            );
        }
        require(
            IERC20(PoolInfo.tokenAddress).transferFrom(
                msg.sender,
                address(this),
                price
            ),
            "Tx f"
        );
    }

    function buyPackage(
        Pack pack,
        uint256 tokenPoolID,
        uint256 packIdToRedeem
    ) public ensurePackageStatus(pack) whenNotPaused {
        require(pack <= Pack(2), "Invalid pack!");
        require(tokenPoolID <= currentTokenPoolID, "Invalid pool ID");
        Pools memory PoolInfo = poolInfo[tokenPoolID][pack];
        require(PoolInfo.tokenAddress != address(0), "Pool not exist!");

        userDetails storage userdetails = UserDetails[msg.sender];

        address reffererAddress = userdetails.reffererAddr;
        require(reffererAddress != address(0), "0 ref");

        userDetails storage userReffererDetails = UserDetails[reffererAddress];

        require(userReffererDetails.uplineLength != 0, "Invalid upline!");

        if (packIdToRedeem != 0)
            require(
                userdetails
                .packages[packIdToRedeem][pack]
                    .isUserAlreadyBoughtThisPackToRedeem[packIdToRedeem][pack],
                "User not found in this id!"
            );
        else {
            packIdToRedeem = ++userdetails.userPackId[pack];
            userdetails.packages[packIdToRedeem][pack].userPackId++;
        }

        addAffsAndDepositToken(userdetails, tokenPoolID, PoolInfo);

        userdetails.packages[packIdToRedeem][pack].userPackActivedIds[
            packIdToRedeem
        ][pack] = true;
        userdetails
        .packages[packIdToRedeem][pack].packageBoughtTime = userdetails
        .packages[packIdToRedeem][pack].lastRewardClaimedTime = block.timestamp;
        userdetails
        .packages[packIdToRedeem][pack].isUserAlreadyBoughtThisPackToRedeem[
                packIdToRedeem
            ][pack] = true;

        if (userdetails.level == 0) userdetails.level = 1;
        if (!userdetails.packages[packIdToRedeem][pack].isActive)
            userdetails.packages[packIdToRedeem][pack].isActive = true;

        emit packageBought(
            msg.sender,
            pack,
            PoolInfo.price,
            userdetails.userPackId[pack],
            tokenPoolID
        );
    }

    function buyLevel(
        Pack pack,
        address reffererAddress,
        uint tokenPoolID,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) ensurePackageStatus(pack) whenNotPaused {
        require(pack <= Pack(2), "Invalid pack!");
        require(tokenPoolID <= currentTokenPoolID, "Invalid pool ID");
        Pools memory PoolInfo = poolInfo[tokenPoolID][pack];
        require(PoolInfo.tokenAddress != address(0), "Pool not exist!");
        require(
            validateBuyLevelHash(
                reffererAddress,
                msg.sender,
                tokenPoolID,
                pack,
                expiry,
                v,
                r,
                s
            ),
            "Invalid sig"
        );
        reffererAddress = reffererAddress == address(0)
            ? owner()
            : reffererAddress;
        userDetails storage userRefferralDetails = UserDetails[msg.sender];
        userDetails storage userReffererDetails = UserDetails[reffererAddress];
        require(
            userRefferralDetails.reffererAddr == address(0),
            "User already reffered!"
        );
        require(userRefferralDetails.level == 0, "User exist!");
        require(
            reffererAddress == owner() ||
                checkRefBoughtAnyPack(reffererAddress),
            "Refferer not active in any pack yet!"
        );

        userReffererDetails.directRefferals.push(msg.sender);

        if (reffererAddress != owner())
            userRefferralDetails.uplineLength =
                userReffererDetails.uplineLength +
                1;
        else userRefferralDetails.uplineLength = 1;

        uint256 userPackId = invokeUserDetails(reffererAddress, pack);

        userReffererDetails.reffererAddedLevel[msg.sender] = userReffererDetails
            .level;
        userReffererDetails.levelRefferredUsers[userReffererDetails.level].push(
                msg.sender
            );

        if (
            reffererAddress != owner() &&
            userReffererDetails.directRefferals.length ==
            levels[userReffererDetails.level]
        ) {
            userReffererDetails.level <= 11
                ? userReffererDetails.level++
                : userReffererDetails.level;
        }

        addAffsAndDepositToken(userRefferralDetails, tokenPoolID, PoolInfo);

        setHashCompleted(
            prepareBuyLevelHash(
                reffererAddress,
                msg.sender,
                tokenPoolID,
                pack,
                expiry
            ),
            true
        );
        emit LevelBought(
            reffererAddress,
            msg.sender,
            pack,
            userPackId,
            tokenPoolID
        );
    }

    function invokeUserDetails(
        address reffererAddress,
        Pack pack
    ) private returns (uint256 userPackId) {
        userDetails storage userRefferralDetails = UserDetails[msg.sender];

        userRefferralDetails.level = 1;
        userRefferralDetails.reffererAddr = reffererAddress;
        userPackId = ++userRefferralDetails.userPackId[pack];
        userRefferralDetails
        .packages[userPackId][pack].packageBoughtTime = block.timestamp;
        userRefferralDetails.packages[userPackId][pack].isActive = true;
        userRefferralDetails
        .packages[userPackId][pack].isUserAlreadyBoughtThisPackToRedeem[
                userPackId
            ][pack] = true;
        userRefferralDetails.packages[userPackId][pack].userPackActivedIds[
            userPackId
        ][pack] = true;
    }

    function stake(
        Pack pack,
        uint256 userPackId,
        uint256 stcAmountToStake,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) {
        require(stcAmountToStake > 0, "Invalid STC amount");
        require(
            validateHash(msg.sender, stcAmountToStake, pack, expiry, v, r, s),
            "Invalid signature"
        );
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages storage package = packages[pack];
        require(userdetails.reffererAddr != address(0), "zero ref!");
        require(
            userdetails.packages[userPackId][pack].userPackActivedIds[
                userPackId
            ][pack],
            "User not active in the packId!"
        );
        require(
            userdetails.packages[userPackId][pack].isActive,
            "User not found in this packID and pack! stake"
        );
        require(
            (userdetails.packages[userPackId][pack].packageBoughtTime +
                package.lifeSpan) > block.timestamp,
            "User pack expired, claim capital!"
        );
        require(stcAmountToStake >= package.minStakeAmount, "min!");

        require(
            userdetails.packages[userPackId][pack].stakedAmount +
                stcAmountToStake <=
                package.maxStakeAmount,
            "Exceeds max stake amount!"
        );

        userdetails.packages[userPackId][pack].unClaimedAmt += pendingReward(
            pack,
            userPackId,
            msg.sender
        );
        userdetails.packages[userPackId][pack].stakedTime = block.timestamp;
        userdetails.packages[userPackId][pack].stakedAmount += stcAmountToStake;
        userdetails.packages[userPackId][pack].rewardDept = (rewardPerShare *
            userdetails.packages[userPackId][pack].stakedAmount);
        totalStakedAmount += stcAmountToStake;
        package.poolSTCamount += stcAmountToStake;
        require(
            STC_Addr.transferFrom(msg.sender, address(this), stcAmountToStake),
            "Tx failed!"
        );

        setHashCompleted(
            prepareHash(msg.sender, stcAmountToStake, pack, expiry),
            true
        );
        emit Staked(pack, msg.sender, stcAmountToStake);
    }

    function claimRewardAmount(
        Pack pack,
        uint256 userPackId,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) isDisabled {
        require(pack <= Pack(2), "Invalid pack!");
        require(
            validateClaimHash(pack, msg.sender, expiry, v, r, s),
            "Invalid sig"
        );
        userDetails storage userdetails = UserDetails[msg.sender];
        require(
            userdetails.packages[userPackId][pack].userPackActivedIds[
                userPackId
            ][pack],
            "User not active in the packId!"
        );
        require(
            userdetails.packages[userPackId][pack].isActive,
            "User not found"
        );
        require(
            userdetails.packages[userPackId][pack].stakedAmount > 0,
            "User not staked yet!"
        );
        userdetails.packages[userPackId][pack].lastRewardClaimedTime = block
            .timestamp;
        uint256 rewardAmount = _pendingReward(pack, userPackId, msg.sender);
        rewardAmount += userdetails.packages[userPackId][pack].unClaimedAmt;
        userdetails.packages[userPackId][pack].unClaimedAmt = 0;
        userdetails
        .packages[userPackId][pack].totalRewardClaimed += rewardAmount;
        userdetails.packages[userPackId][pack].rewardDept = (rewardPerShare *
            userdetails.packages[userPackId][pack].stakedAmount);
        require(rewardAmount > 0, "No reward to claim!");
        require(STC_Addr.transfer(msg.sender, rewardAmount), "Tx failed!");
        setHashCompleted(prepareClaimHash(pack, msg.sender, expiry), true);
        emit ClaimedRewardAmount(pack, msg.sender, rewardAmount);
    }

    function pendingReward(
        Pack pack,
        uint256 userPackId,
        address userAddress
    ) public view returns (uint256) {
        return (_pendingReward(pack, userPackId, userAddress) +
            UserDetails[userAddress].packages[userPackId][pack].unClaimedAmt);
    }

    function _pendingReward(
        Pack pack,
        uint256 userPackId,
        address userAddress
    ) private view returns (uint256) {
        if (
            UserDetails[userAddress].packages[userPackId][pack].stakedAmount ==
            0
        ) {
            return 0;
        }

        return
            ((rewardPerShare *
                UserDetails[userAddress]
                .packages[userPackId][pack].stakedAmount) -
                UserDetails[userAddress]
                .packages[userPackId][pack].rewardDept) / 1e18;
    }

    function addAffiliateRewardAmountToTheReffs(
        address tokenAddress,
        uint tokenPoolID,
        userDetails storage userRefferralDetails,
        uint price
    ) private {
        address[] memory reffererAddresses = new address[](14);
        reffererAddresses[0] = address(0);
        uint256 level = 1;
        reffererAddresses[1] = userRefferralDetails.reffererAddr;
        for (uint8 i = 1; i <= userRefferralDetails.uplineLength; i++) {
            userDetails storage userRefferralDetailsForAddingR = UserDetails[
                reffererAddresses[i]
            ];
            if (level == 1) {
                uint256 rewardAmount = calculateAffiliateRewardAmount(
                    price,
                    level
                );

                if (isPackNotExpired(reffererAddresses[i]))
                    userRefferralDetailsForAddingR
                        .affiliateLevelRefferredUserReward[tokenAddress][
                            tokenPoolID
                        ][level] += rewardAmount;

                reffererAddresses[i + 1] = userRefferralDetailsForAddingR
                    .reffererAddr;

                level++;
            } else {
                if (level + 1 > 13) {
                    break;
                }

                uint256 rewardAmount = calculateAffiliateRewardAmount(
                    price,
                    level
                );

                if (isPackNotExpired(reffererAddresses[i]))
                    userRefferralDetailsForAddingR
                        .affiliateLevelRefferredUserReward[tokenAddress][
                            tokenPoolID
                        ][level] += rewardAmount;

                reffererAddresses[i + 1] = userRefferralDetailsForAddingR
                    .reffererAddr;
                level <= 12 ? level++ : level;
            }
        }
    }

    function claimAffiliateReward(
        uint tokenPoolID,
        uint256 level,
        Pack pack
    ) public isDisabled {
        require(level != 0 && level <= 12, "Invalid level!");
        Pools memory PoolInfo = poolInfo[tokenPoolID][pack];
        require(
            tokenPoolID <= currentTokenPoolID &&
                PoolInfo.tokenAddress != address(0),
            "Invalid poolID!"
        );
        userDetails storage userdetails = UserDetails[msg.sender];
        address tokenAddress = PoolInfo.tokenAddress;
        uint256 afReward = userdetails.affiliateLevelRefferredUserReward[
            tokenAddress
        ][tokenPoolID][level];
        require(
            PoolInfo.isAffiliateRewardEnabled || afReward > 0,
            "poolID reward claiming is disabled!"
        );

        require(userdetails.level >= level, "User not yet reached the level!");

        require(afReward > 0, "No rewards in this level!");
        userdetails.affiliateLevelRefferredUserReward[tokenAddress][
            tokenPoolID
        ][level] = 0;
        require(
            IERC20(tokenAddress).transfer(msg.sender, afReward),
            "Tx failed!"
        );
        emit ClaimedAffiliate(
            msg.sender,
            tokenAddress,
            tokenPoolID,
            afReward,
            level
        );
    }

    function claimCapital(Pack pack, uint256 userPackId) public {
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages storage package = packages[pack];
        require(
            userdetails.packages[userPackId][pack].isActive,
            "User not found in this packID and pack! stake"
        );
        require(
            block.timestamp >
                userdetails.packages[userPackId][pack].packageBoughtTime +
                    package.lifeSpan,
            "Pack not yet expired!"
        );
        require(
            pendingReward(pack, userPackId, msg.sender) == 0,
            "Claim the pending rewards before capital!"
        );
        uint256 stkAmnt = userdetails.packages[userPackId][pack].stakedAmount;
        userdetails.packages[userPackId][pack].stakedAmount = 0;
        userdetails.packages[userPackId][pack].userPackActivedIds[userPackId][
                pack
            ] = false;
        userdetails.packages[userPackId][pack].isActive = false;
        userdetails.packages[userPackId][pack].packageBoughtTime = 0;
        package.poolSTCamount -= stkAmnt;
        totalStakedAmount -= stkAmnt;
        require(STC_Addr.transfer(msg.sender, stkAmnt), "Tx failed!");
        emit ClaimedCapital(msg.sender, pack, stkAmnt);
    }

    //let stc = 1
    // let busdPerStc = 2
    // undefined
    // let ratio = stc / busdPerStc
    // undefined
    // let busdPrice = ratio * 20
    // undefined
    // busdPrice
    // 10

    function swapBusdToStc(
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(busdAmount > 0 && busdPrice > 0, "0 busd");
        require(
            validateSwapHash(
                msg.sender,
                busdAmount,
                busdPrice,
                expiry,
                v,
                r,
                s
            ),
            "Invalid sig"
        );
        require(
            BUSD.transferFrom(msg.sender, address(this), busdAmount),
            "Tx_failed"
        );
        uint256 stcAmount = (busdAmount * busdPrice) / 1e18;
        require(STC_Addr.transfer(msg.sender, stcAmount), "Tx_2 failed");
        emit SwapBusdToStc(msg.sender, busdAmount, busdPrice);
    }

    function calculateAffiliateRewardAmount(
        uint256 priceForTokenPack,
        uint256 level
    ) public view returns (uint256 rewardAmount) {
        rewardAmount = ((priceForTokenPack * rewards[level]) / diviser);
    }

    function viewRefAddedLevel(
        address userAddress,
        address refAddr
    ) public view returns (uint256) {
        userDetails storage userdetails = UserDetails[userAddress];
        return userdetails.reffererAddedLevel[refAddr];
    }

    function viewUserLevelDetails(
        address userAddress,
        uint tokenPoolID,
        uint256 level,
        Pack pack
    )
        public
        view
        returns (
            uint256 affiliateRewardForTheLevel,
            address[] memory levelRefferedUsers
        )
    {
        require(level <= 12, "Invalid level");
        Pools memory PoolInfo = poolInfo[tokenPoolID][pack];
        userDetails storage userdetails = UserDetails[userAddress];
        affiliateRewardForTheLevel = userdetails
            .affiliateLevelRefferredUserReward[PoolInfo.tokenAddress][
                tokenPoolID
            ][level];
        levelRefferedUsers = userdetails.levelRefferredUsers[level];
    }

    function viewUserPackDetailsByPackId(
        address userAddress,
        Pack pack,
        uint256 userPackId
    )
        public
        view
        returns (
            uint256 stakedAmount,
            uint256 rewardDept,
            uint256 unClaimedAmt,
            uint256 totalRewardsClaimed,
            uint256 packageBoughtTime,
            uint256 stakedTime,
            bool userPackActivedIds,
            bool isUserAlreadyBoughtThisPackToRedeem,
            bool isActive
        )
    {
        userDetails storage userdetails = UserDetails[userAddress];
        stakedAmount = userdetails.packages[userPackId][pack].stakedAmount;
        rewardDept = userdetails.packages[userPackId][pack].rewardDept;
        unClaimedAmt = userdetails.packages[userPackId][pack].unClaimedAmt;
        totalRewardsClaimed = userdetails
        .packages[userPackId][pack].totalRewardClaimed;
        packageBoughtTime = userdetails
        .packages[userPackId][pack].packageBoughtTime;
        stakedTime = userdetails.packages[userPackId][pack].stakedTime;
        userPackActivedIds = userdetails
        .packages[userPackId][pack].userPackActivedIds[userPackId][pack];
        isUserAlreadyBoughtThisPackToRedeem = userdetails
        .packages[userPackId][pack].isUserAlreadyBoughtThisPackToRedeem[
                userPackId
            ][pack];
        isActive = userdetails.packages[userPackId][pack].isActive;
    }

    function viewUserDetails(
        address userAddress
    )
        public
        view
        returns (
            address reffererAddress,
            uint256 uplineLength,
            uint256 level,
            address[] memory directRefs
        )
    {
        userDetails storage userdetails = UserDetails[userAddress];
        reffererAddress = userdetails.reffererAddr;
        uplineLength = userdetails.uplineLength;
        level = userdetails.level;
        directRefs = userdetails.directRefferals;
    }

    function viewUserAffiliateRewardForLevelsForPack(
        uint tokenPoolID,
        address userAddress,
        Pack pack
    ) public view returns (uint256[13] memory level) {
        level[0] = 0;
        require(tokenPoolID <= currentTokenPoolID, "Invalid poolID!");
        userDetails storage userdetails = UserDetails[userAddress];
        Pools memory PoolInfo = poolInfo[tokenPoolID][pack];
        for (uint8 j = 1; j <= 12; j++) {
            uint affReward = userdetails.affiliateLevelRefferredUserReward[
                PoolInfo.tokenAddress
            ][tokenPoolID][j];
            level[j] = affReward;
        }
    }

    function viewUserPackCurrentId(
        address userAddress,
        Pack pack
    ) public view returns (uint256) {
        return UserDetails[userAddress].userPackId[pack];
    }

    function viewUserActivePack(
        address userAddress,
        Pack pack
    ) public view returns (uint8) {
        if (UserDetails[userAddress].packages[1][pack].isActive) {
            return uint8(pack);
        } else {
            for (uint8 i = 0; i <= 2; i++) {
                if (UserDetails[userAddress].packages[i][Pack(i)].isActive) {
                    return i;
                }
            }
        }
        return 3;
    }

    function checkRefBoughtAnyPack(
        address userAddress
    ) public view returns (bool) {
        uint256 length;
        uint8 pack;
        for (uint8 i; i <= 2; i++) {
            length = UserDetails[userAddress].userPackId[Pack(i)];
            if (length > 0) {
                pack = i;
                break;
            }
        }
        if (length == 0) return false;

        for (uint256 j = 1; j <= length; j++) {
            if (
                UserDetails[userAddress].packages[j][Pack(pack)].isActive &&
                (UserDetails[userAddress]
                .packages[j][Pack(pack)].packageBoughtTime +
                    packages[Pack(pack)].lifeSpan) >
                block.timestamp
            ) {
                return true;
            }
        }
        return false;
    }

    function viewUserPackDetails(
        address userAddress,
        Pack pack
    )
        public
        view
        returns (
            string[] memory expired,
            bool[] memory isActive,
            uint256[] memory ids
        )
    {
        uint256 userPackLength = UserDetails[userAddress].userPackId[pack];
        expired = new string[](userPackLength);
        isActive = new bool[](userPackLength);
        ids = new uint256[](userPackLength);
        for (uint256 i = 1; i <= userPackLength; i++) {
            // if (i == 0) i = 1;
            if (
                UserDetails[userAddress].packages[i][pack].isActive &&
                (UserDetails[userAddress].packages[i][pack].packageBoughtTime +
                    packages[pack].lifeSpan) >
                block.timestamp
            ) {
                expired[i - 1] = "Not expired";
                isActive[i - 1] = true;
                ids[i - 1] = i;
            } else {
                expired[i - 1] = "Expired";
                isActive[i - 1] = false;
                ids[i - 1] = i;
            }
        }
    }

    function viewUserActivePacks(
        address userAddress
    ) public view returns (uint8[3] memory packs, bool[3] memory isActive) {
        for (uint8 i = 0; i <= 2; i++) {
            if (UserDetails[userAddress].packages[i][Pack(i)].isActive) {
                packs[i] = i;
                isActive[i] = true;
            } else {
                packs[i] = 3;
                isActive[i] = false;
            }
        }
    }

    function isPackNotExpired(address userAddress) public view returns (bool) {
        if (userAddress == owner()) return true;
        uint256 length;
        uint8 pack;
        for (uint8 i; i <= 2; i++) {
            length = UserDetails[userAddress].userPackId[Pack(i)];
            if (length > 0) {
                pack = i;
                for (uint256 j = 1; j <= length; j++) {
                    if (
                        (UserDetails[userAddress]
                        .packages[j][Pack(pack)].packageBoughtTime +
                            packages[Pack(pack)].lifeSpan) > block.timestamp
                    ) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function validateHash(
        address to,
        uint256 stcAmountToStake,
        Pack pack,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool result) {
        bytes32 hash = prepareHash(to, stcAmountToStake, pack, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareHash(
        address to,
        uint256 stcAmountToStake,
        Pack pack,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(to, stcAmountToStake, pack, blockExpiry)
            );
    }

    function validateBuyLevelHash(
        address refferAddr,
        address referrerdAddr,
        uint tokenPoolID,
        Pack pack,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareBuyLevelHash(
            refferAddr,
            referrerdAddr,
            tokenPoolID,
            pack,
            expiry
        );
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address referrerAddr = ecrecover(fullMessage, v, r, s);
        result = referrerAddr == referrerdAddr;
    }

    function validateClaimHash(
        Pack pack,
        address to,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareClaimHash(pack, to, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareBuyLevelHash(
        address refferrer,
        address referringAddr,
        uint tokenPoolID,
        Pack pack,
        uint256 expiry
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    refferrer,
                    referringAddr,
                    tokenPoolID,
                    pack,
                    expiry
                )
            );
    }

    function prepareClaimHash(
        Pack pack,
        address to,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(pack, to, blockExpiry));
    }

    function validateSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareSwapHash(to, busdAmount, busdPrice, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(to, busdAmount, busdPrice, blockExpiry));
    }

    function setHashCompleted(bytes32 hash, bool status) private {
        hashStatus[hash] = status;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function update() public onlyOwner {
        diviser = 100e18;
        maxMintStcPerDay = 41e18;
        updateRewardPershareLimit = 1e18;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {MiddleWares} from "../middlewares/MiddleWares.sol";

contract AdminFunctions is MiddleWares {
    function setRewardClaiming(bool isOpen) public onlyOwner {
        //Eg := True = enable, False = Disable
        rewardClaiming = isOpen;
        emit RewardClaiming(isOpen);
    }

    function setPackageStatus(Pack pack, bool status) public onlyOwner {
        //Eg := True = enable, False = Disable
        packageStatus[pack] = status;
        emit SetPackageStatus(pack, status);
    }

    function updateRewardPerShare() public onlyOperator {
        rewardPerShare += (maxMintStcPerDay * 1e18) / totalStakedAmount;
        lastRewardPerShareUpdate = block.timestamp;
    }

    function updateReward(
        uint256 level,
        uint256 rewardPercent
    ) public onlyOwner {
        require(level != 0 && level <= 12, "Invalid level!");
        rewards[level] = rewardPercent;
        emit RewardUpdated(level, rewardPercent);
    }

    function updateLevelReferals(
        uint256 level,
        uint256 refCount
    ) public onlyOwner {
        require(level != 0 && level <= 12, "Invalid level");
        levels[level] = refCount;
        emit LevelRefCountUpdated(level, refCount);
    }

    function updateToken(address tokenAddress, uint256 flag) public onlyOwner {
        require(tokenAddress != address(0) && flag != 0, "0");
        if (flag == 1) {
            BUSD = IERC20(tokenAddress);
        } else if (flag == 2) {
            STC_Addr = IERC20(tokenAddress);
        } else {
            revert("Invalid flag");
        }
    }

    function updatePackage(
        Pack pack,
        uint256 span,
        uint256 minStakeAmount,
        uint256 maxStakeAmount,
        uint256 poolStcAmount
    ) public onlyOwner {
        require(span != 0 && maxStakeAmount != 0, "0 pack");
        require(pack <= Pack.GROWTH, "Invalid pack");
        packages[pack] = Packages({
            lifeSpan: span,
            minStakeAmount: minStakeAmount,
            maxStakeAmount: maxStakeAmount,
            poolSTCamount: poolStcAmount
        });
        emit updatedPackage(pack, span, maxStakeAmount);
    }

    function updateMaxMintStcPerDay(
        uint256 maxMintStcPerDay_
    ) public onlyOwner {
        require(maxMintStcPerDay_ != 0, "Invalid maxMintStcPerDay_");
        maxMintStcPerDay = maxMintStcPerDay_;
    }

    function updateSigner(address signer) public onlyOwner {
        require(signer != address(0), "Signer: wut?");
        signerAddress = signer;
    }

    function updateOperator(address opAddr) public onlyOwner {
        require(opAddr != address(0), "Operator: How?");
        operatorAddress = opAddr;
    }

    function updateMaxStakeAmount(
        uint256 _maxStakeAmount,
        Pack pack
    ) public onlyOwner {
        require(pack <= Pack(2), "Invalid pack");
        require(_maxStakeAmount != 0, "0 max!");
        Packages storage package = packages[pack];
        package.maxStakeAmount = _maxStakeAmount;
        emit UpdatedMaxStakeAmount(_maxStakeAmount, pack);
    }

    function updateMinStakeAmount(
        uint256 _minStakeAmount,
        Pack pack
    ) public onlyOwner {
        require(_minStakeAmount != 0, "0 min!");
        Packages storage package = packages[pack];
        package.minStakeAmount = _minStakeAmount;
        emit UpdateMinStakeAmount(_minStakeAmount, pack);
    }

    function updateAdminPacks(
        Pack pack,
        uint256 uplineLength,
        uint256 level,
        address refAddr
    ) public onlyOwner {
        require(pack <= Pack(2), "Invalid pack!");
        userDetails storage userdetails = UserDetails[msg.sender];
        userdetails.uplineLength = uplineLength;
        userdetails.level = level;
        userdetails.reffererAddr = refAddr;
    }

    function updateTokenPoolDetails(
        address _tokenAddr,
        uint poolID,
        uint price,
        bool _isAffiliateRewardEnabled,
        Pack pack
    ) public onlyOwner {
        require(poolID <= currentTokenPoolID, "Pool not exist!");
        Pools memory PoolInfo = poolInfo[poolID][pack];
        PoolInfo.tokenAddress = _tokenAddr;
        PoolInfo.isAffiliateRewardEnabled = _isAffiliateRewardEnabled;
        PoolInfo.price = price;
        emit SetTokenPoolStatus(
            _tokenAddr,
            poolID,
            pack,
            price,
            _isAffiliateRewardEnabled
        );
    }

    function addTokensToPool(
        address _tokenAddress,
        bool _isAffiliateRewardEnabled,
        uint price,
        Pack pack
    ) public onlyOwner {
        uint cpi = ++currentTokenPoolID;
        Pools storage PoolInfo = poolInfo[cpi][pack];
        PoolInfo.tokenAddress = _tokenAddress;
        PoolInfo.isAffiliateRewardEnabled = _isAffiliateRewardEnabled;
        PoolInfo.price = price;
        tokenPoolID[_tokenAddress] = cpi;
        emit AddedTokenToPool(
            _tokenAddress,
            cpi,
            price,
            _isAffiliateRewardEnabled
        );
    }

    function addUser(
        address refAddress,
        address userAddress,
        Pack pack
    ) public onlyOwner returns (uint256 userPackId) {
        require(
            userAddress != address(0) && refAddress != address(0),
            "0 Addr!"
        );
        userDetails storage user_details = UserDetails[userAddress];

        user_details.level = 1;
        user_details.uplineLength = 1;
        user_details.reffererAddr = refAddress;
        userPackId = ++user_details.userPackId[pack];
        user_details.packages[userPackId][pack].packageBoughtTime = block
            .timestamp;
        user_details.packages[userPackId][pack].isActive = true;
        user_details
        .packages[userPackId][pack].isUserAlreadyBoughtThisPackToRedeem[
                userPackId
            ][pack] = true;
        user_details.packages[userPackId][pack].userPackActivedIds[userPackId][
                pack
            ] = true;
        emit AddUser(refAddress, userAddress, pack);
    }

    function withdraw(
        address tokenAddress,
        address _toUser,
        uint256 amount
    ) public onlyOwner returns (bool status) {
        require(_toUser != address(0), "0");
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "!");
            require(payable(_toUser).send(amount), "f");
            return true;
        } else {
            require(IERC20(tokenAddress).balanceOf(address(this)) >= amount);
            IERC20(tokenAddress).transfer(_toUser, amount);
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/security/Pausable.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";

contract StateVariables is Ownable, Pausable {
    address public signerAddress;
    address public operatorAddress;

    IERC20 public STC_Addr;
    IERC20 public BUSD;
    IERC20 public VoucherAddr;

    uint8 public isInitialized;
    uint256 public currentTokenPoolID;
    uint256 public diviser;
    uint256 public maxMintStcPerDay = 41e18;
    uint256 public updateRewardPershareLimit = 1 days;
    uint256 public lastRewardPerShareUpdate;
    uint256 public totalStakedAmount;
    uint256 public rewardPerShare;

    bool public rewardClaiming;
    // Eg := currentPoolID -> Pack ===> poolInfo
    mapping(uint => mapping(Pack => Pools)) public poolInfo;
    mapping(Pack => bool) public packageStatus;
    mapping(Pack => Packages) public packages;
    mapping(address => userDetails) public UserDetails;
    mapping(uint256 => uint256) public rewards; //EG := LEVEL => REWARD
    mapping(uint256 => uint256) public levels;
    mapping(bytes32 => bool) public hashStatus;
    mapping(address => uint256) public tokenPoolID;

    enum Pack {
        TRIAL,
        STARTER,
        GROWTH
    }

    struct Pools {
        address tokenAddress;
        uint price;
        bool isAffiliateRewardEnabled;
    }

    struct Packages {
        uint256 lifeSpan;
        uint256 minStakeAmount;
        uint256 maxStakeAmount;
        uint256 poolSTCamount;
    }

    struct userDetails {
        address reffererAddr;
        address[] directRefferals;
        uint256 uplineLength;
        uint256 level;
        //Eg := tokenAddress -> tokenPoolID -> userLevel ===> rewardAmount
        mapping(address => mapping(uint => mapping(uint => uint))) affiliateLevelRefferredUserReward;
        mapping(uint256 => address[]) levelRefferredUsers;
        mapping(address => uint256) reffererAddedLevel;
        mapping(Pack => uint256) userPackId;
        mapping(uint256 => mapping(Pack => UserPack)) packages;
    }

    struct UserPack {
        uint256 stakedAmount;
        uint256 unClaimedAmt;
        uint256 rewardDept;
        uint256 totalRewardClaimed;
        uint256 packageBoughtTime;
        uint256 stakedTime;
        uint256 lastRewardClaimedTime;
        uint256 userPackId;
        // bool userPackActivedIds;
        mapping(uint256 => mapping(Pack => bool)) userPackActivedIds;
        mapping(uint256 => mapping(Pack => bool)) isUserAlreadyBoughtThisPackToRedeem;
        bool isActive;
    }

    event packageBought(
        address indexed userAddr,
        Pack indexed pack,
        uint256 busdAmount,
        uint256 indexed userPackId,
        uint256 tokenPoolID
    );
    event LevelBought(
        address indexed reffererAddr,
        address indexed refferingAddr,
        Pack indexed pack,
        uint256 userPackId,
        uint256 tokenPoolID
    );
    event ClaimedAffiliate(
        address indexed userAddress,
        address indexed tokenAddress,
        uint256 tokenPoolID,
        uint256 claimedRewardAmount,
        uint256 level
    );
    event Staked(
        Pack indexed pack,
        address indexed userAddress,
        uint256 stcAmountToStake
    );
    event ClaimedRewardAmount(
        Pack indexed pack,
        address indexed userAddress,
        uint256 indexed rewardAmount
    );
    event updatedPackage(
        Pack indexed pack,
        uint256 span,
        uint256 maxStakeAmount
    );
    event SwapBusdToStc(address addr, uint256 busdAmount, uint256 busdPrice);
    event ClaimedCapital(
        address indexed user,
        Pack indexed pack,
        uint256 amount
    );
    event RewardUpdated(uint256 indexed level, uint256 percentage);
    event LevelRefCountUpdated(uint256 indexed level, uint256 refCounts);
    event RewardClaiming(bool indexed isOpen);
    event SetPackageStatus(Pack indexed pack, bool indexed status);
    event UpdatedMaxStakeAmount(uint256 _maxStakeAmount, Pack pack);
    event UpdateMinStakeAmount(uint256 _minStakeAmount, Pack pack);
    event SetTokenPoolStatus(
        address indexed tokenAddress,
        uint poolID,
        Pack pack,
        uint price,
        bool isAffiliateRewardEnabled
    );
    event AddedTokenToPool(
        address indexed tokenAddresses,
        uint indexed cpi,
        uint price,
        bool isRewardEnabledForAffiliateReward
    );
    event AddUser(
        address indexed refAddr,
        address indexed userAddr,
        Pack indexed pack
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {AdminFunctions} from "../admin/AdminFunctions.sol";

contract Initialize is AdminFunctions {
    function initPools(
        address[] memory tokenAddress,
        bool[] memory isAffiliateRewardEnabled
    ) internal IsInitialized {
        uint packagePrice = 100e18;
        for (uint8 i = 0; i < tokenAddress.length; i++) {
            uint packID = i == 0 ? 1 : 2;
            for (uint8 j = 0; j < 3; j++) {
                if (j > 0) (packagePrice = packagePrice * 5);
                poolInfo[packID][Pack(j)].tokenAddress = tokenAddress[i];
                poolInfo[packID][Pack(j)].price = packagePrice;
                poolInfo[packID][Pack(j)]
                    .isAffiliateRewardEnabled = isAffiliateRewardEnabled[i];
                if (j == 2) {
                    packagePrice = 100e18;
                }
            }
        }
    }

    function initPackages() internal IsInitialized {
        uint256 span = 60 days;
        uint256 maxStakeAmount = 200e18;
        for (uint8 i = 0; i < 3; i++) {
            packages[Pack(i)] = Packages({
                lifeSpan: span,
                minStakeAmount: 0,
                maxStakeAmount: maxStakeAmount,
                poolSTCamount: 0
            });
            i == 0 ? span += 305 days : 0;
            i == 0 || i > 0
                ? (
                    i == 1
                        ? (maxStakeAmount = 5000e18)
                        : (maxStakeAmount = 1000e18)
                )
                : maxStakeAmount;
        }
    }

    function initAdminActiveInAllPacks() internal IsInitialized {
        userDetails storage userdetails = UserDetails[msg.sender];
        userdetails.uplineLength = 1;
        userdetails.level = 12;
        userdetails.reffererAddr = msg.sender;
        for (uint256 i = 0; i <= 2; i++) {
            if (i <= 2) {
                userdetails.packages[i][Pack(i)].isActive = true;
            }
        }
    }

    function initLevelRewards() internal IsInitialized {
        // downline
        rewards[1] = 20e18;
        rewards[2] = 10e18;
        rewards[3] = 5e18;
        rewards[4] = 4e18;
        rewards[5] = 4e18;
        rewards[6] = 4e18;
        rewards[7] = 4e18;
        rewards[8] = 4e18;
        rewards[9] = 2.5e18;
        rewards[10] = 2.5e18;
        rewards[11] = 2.5e18;
        rewards[12] = 2.5e18;
    }

    function initLevelsRefferalCount() internal IsInitialized {
        levels[1] = 3;
        levels[2] = 5;
        levels[3] = 7;
        levels[4] = 9;
        levels[5] = 11;
        levels[6] = 13;
        levels[7] = 15;
        levels[8] = 17;
        levels[9] = 19;
        levels[10] = 21;
        levels[11] = 23;
        levels[12] = 24;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {StateVariables} from "../config/StateVariables.sol";

contract MiddleWares is StateVariables {
    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Operator: wut?");
        _;
    }

    modifier IsInitialized() {
        require(isInitialized == 0, "Already initialized!");
        _;
    }

    modifier isDisabled() {
        require(!rewardClaiming, "disabled!");
        _;
    }

    modifier ensure(uint256 expiry) {
        require(expiry > block.timestamp, "Expired!");
        _;
    }

    modifier ensurePackageStatus(Pack pack) {
        require(!packageStatus[pack], "This pack is disabled!");
        _;
    }
}