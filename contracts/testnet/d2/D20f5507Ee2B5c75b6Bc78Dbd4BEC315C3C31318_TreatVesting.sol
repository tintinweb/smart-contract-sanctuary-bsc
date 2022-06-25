// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./utils/ITreatVesting.sol";
import "./utils/ITreatLiquidity.sol";


contract TreatVesting is Ownable, ITreatVesting, ReentrancyGuard{
    event Staked(address account, address stakingContract, uint256 amount);
    event Withdrawn(address account, address stakingContract, uint256 amount);
    event Burned(address account, address stakingContract, uint256 amount);
    event Transfer(address account, uint256 vestingAmount);
    event Receive(address account, uint256 vestingAmount);
    event VestingSettingsUpdated(uint256 vestingPercentage, uint256 vestingLockAfterPurchase);

    struct VestingData {
        uint256 time;
        uint256 lastUpdateTime;
        uint256 amount;
    }

    address public immutable treatToken;
    uint256 public vestingPercentage;
    uint256 public vestingLockAfterPurchase;

    //account => staking contract (address(0) for wallet vesting) => VestingData
    mapping(address => mapping(address => VestingData)) public tokenVesting;

    modifier onlyTreatToken() {
        require(msg.sender == treatToken, "Not allowed");
        _;
    }

    /*
     * @title Constructor
     * @param Treat token address
     * @param Default vesting lock time
     * @param Transaction percent that locks into vesting
     */
    constructor(
        address _treatToken,
        uint256 _vestingLockAfterPurchase,
        uint256 _vestingPercentage
    ){
        require(_vestingLockAfterPurchase > 0, "vestingLockAfterPurchase = 0");
        require(_treatToken != address(0), "invalid treatToken");
        treatToken = _treatToken;
        vestingLockAfterPurchase = _vestingLockAfterPurchase;
        vestingPercentage = _vestingPercentage;
    }

    /*
     * @title Function for managing staking of vested tokens
     * @param User account address
     * @param Staking contract address
     * @param Percentage of vested tokens to move
     * @param Is user staking? true = staling, false = withdrawing
     * @dev Only for calling by Treat Token
     */
    function registerStake(
        address account,
        address stakingContract,
        uint256 percentage,
        bool isStaking
    ) external nonReentrant onlyTreatToken {
        vestingUpdate(account, 0, address(0), false);
        vestingUpdate(account, 0, stakingContract, true);

        //STAKING
        if(isStaking && tokenVesting[account][address(0)].amount > 0) {
            if(percentage > 0) {
                //gas savings
                uint256 walletVestingTime = tokenVesting[account][address(0)].time;
                uint256 stakeVestingTime = tokenVesting[account][stakingContract].time;

                if(walletVestingTime == 0) return;

                //calculating amount
                uint256 toReduce = tokenVesting[account][address(0)].amount
                * percentage / 10000;

                //calculating time
                if(stakeVestingTime == 0){
                    tokenVesting[account][stakingContract].time = tokenVesting[account][address(0)].time;
                } else {
                    uint256 walletTimeTillEnd = walletVestingTime - block.timestamp;
                    uint256 stakedTimeTillEnd = stakeVestingTime - block.timestamp;
                    uint256 stakedAmount = tokenVesting[account][stakingContract].amount;
                    tokenVesting[account][stakingContract].time = block.timestamp +
                    (walletTimeTillEnd * toReduce + stakedTimeTillEnd * stakedAmount)
                    / (toReduce + stakedAmount);
                }

                tokenVesting[account][address(0)].amount -= toReduce;
                tokenVesting[account][stakingContract].amount += toReduce;
                tokenVesting[account][stakingContract].lastUpdateTime = block.timestamp;
                emit Staked(account, stakingContract, toReduce);
            }
        }
        //WITHDRAWING
        if(!isStaking && tokenVesting[account][stakingContract].amount > 0)  {
            percentage = ITreatLiquidity(stakingContract)
                .withdrawnPercent(account);

            if(percentage > 0) {
                if(tokenVesting[account][stakingContract].time == 0) return;
                //calculating amount
                uint256 toReduce = tokenVesting[account][stakingContract].amount
                * percentage / 10000;

                tokenVesting[account][stakingContract].amount -= toReduce;
                tokenVesting[account][address(0)].amount += toReduce;
                tokenVesting[account][address(0)].lastUpdateTime = block.timestamp;
                emit Withdrawn(account, stakingContract, toReduce);
            }
        }
    }

    /*
     * @title Function for managing vested tokens on transfer
     * @param User account address
     * @param Token balance of user
     * @param Amount of tokens being transferred
     * @return Returns amount that should be sent
     * @return Returns amount that should be recovered
     * @dev Only for calling by Treat Token
     */
    function registerTransfer(
        address account,
        uint256 balance,
        uint256 transferAmount
    ) external onlyTreatToken returns(uint256 willSend, uint256 toRecover) {
        vestingUpdate(account, 0, address(0), false);

        VestingData storage vestingStorage = tokenVesting[account][address(0)];
        toRecover = transferAmount * vestingStorage.amount
            / balance;
        willSend = transferAmount - toRecover;
        vestingStorage.amount -= toRecover;
        emit Transfer(account, toRecover);
    }

    /*
     * @title Updates personal vesting data
     * @param Recipient of the tokens
     * @param Amount to receive
     * @param Address of staking contract (only for liquidity transfer)
     * @param Is this liquidity transfer?
     * @dev Only for calling by Treat Token
     */
    function vestingUpdate(
        address _recipient,
        uint256 _amount,
        address _stakingContract,
        bool _liquidity
    ) public onlyTreatToken {
        VestingData storage vestingStorage;
        uint256 _vestingLockAfterPurchase = vestingLockAfterPurchase;

        if (_liquidity) {
            vestingStorage = tokenVesting[_recipient][_stakingContract];
        } else {
            vestingStorage = tokenVesting[_recipient][address(0)];
        }
        if (vestingStorage.time == 0) {
            if (_amount > 0) {
                vestingStorage.time = block.timestamp + _vestingLockAfterPurchase;
                vestingStorage.lastUpdateTime = block.timestamp;
                vestingStorage.amount = _amount * vestingPercentage / 10000;
                emit Receive(_recipient, _amount * vestingPercentage / 10000);
            }
        }
        // If wallet has prior transactions
        else {
            uint256 vestingEndTime = vestingStorage.time;
            if(vestingEndTime > vestingStorage.lastUpdateTime + _vestingLockAfterPurchase) {
                vestingEndTime = vestingStorage.lastUpdateTime + _vestingLockAfterPurchase;
            }
            // Calculate how much time is left to vest tokens
            uint256 coolDownRemaining = 0;
            uint256 sinceLastUpdate = block.timestamp - vestingStorage.lastUpdateTime;
            if (vestingEndTime > block.timestamp) {
                coolDownRemaining = vestingEndTime - block.timestamp;
            }
            // If vesting time is over
            if (
                coolDownRemaining == 0
            ) {
                if (_liquidity) {
                    delete tokenVesting[_recipient][_stakingContract];
                } else {
                    delete tokenVesting[_recipient][address(0)];
                }
            }
            // If there is vesting calculate remaining tokens that need vesting.
            else {
                if (coolDownRemaining > _vestingLockAfterPurchase)
                    coolDownRemaining = _vestingLockAfterPurchase;

                uint256 vestedPercentage = sinceLastUpdate * 10000
                    / (sinceLastUpdate + coolDownRemaining);

                vestingStorage.amount = vestingStorage.amount
                    * (10000 - vestedPercentage) / 10000;
            }

            // Taking the vesting percent.
            _amount = _amount * vestingPercentage / 10000;
            if (vestingStorage.amount != 0 || _amount != 0) {
                uint256 DaysLocked = (_amount * _vestingLockAfterPurchase
                    + vestingStorage.amount * coolDownRemaining)
                    / (_amount + vestingStorage.amount);

                vestingStorage.time = block.timestamp + DaysLocked;
                vestingStorage.amount = vestingStorage.amount + _amount;
                vestingStorage.lastUpdateTime = block.timestamp;
                if (_amount > 0) {
                    emit Receive(_recipient, _amount);
                }
            }
        }
    }

    /*
     * @title Returns locked vesting tokens and time till full unlock
     * @param Recipient address
     * @param Staking contract address (address(0) for viewing wallet vesting info)
     * @return How many vested tokens are still locked?
     * @return How much to wait until full unlock?
     */
    function viewNotVestedTokens(address recipient, address stakingContract)
        external
        view
        returns (uint256 locked, uint256 coolDownRemaining)
    {
        VestingData memory vestingData = tokenVesting[recipient][stakingContract];
        coolDownRemaining = 0;

        if (vestingData.amount == 0) {
            locked = 0;
        } else {
            uint256 _vestingLockAfterPurchase = vestingLockAfterPurchase;
            uint256 vestingEndTime = vestingData.time;
            if(vestingEndTime > vestingData.lastUpdateTime + _vestingLockAfterPurchase) {
                vestingEndTime = vestingData.lastUpdateTime + _vestingLockAfterPurchase;
            }

            if (vestingEndTime > block.timestamp) {
                coolDownRemaining = vestingEndTime - block.timestamp;
            }

            if (coolDownRemaining == 0) {
                locked = 0;
            } else {
                uint256 sinceLastUpdate = block.timestamp - vestingData.lastUpdateTime;
                uint256 vestedPercentage = sinceLastUpdate * 10000
                / (sinceLastUpdate + coolDownRemaining);

                locked = vestingData.amount
                * (10000 - vestedPercentage) / 10000;
            }
        }
    }

    /*
     * @title Burns specific amount of staked vesting tokens
     * @param User account address
     * @param Percent of tokens to burn
     * @dev The caller must be staking contract
     */
    function burnStakeVesting(
        address account,
        uint256 percentage
    ) external {
        uint256 amountToBurn = percentage
            * tokenVesting[account][msg.sender].amount / 10000;
        tokenVesting[account][msg.sender].amount -= amountToBurn;
        emit Burned(account, msg.sender, amountToBurn);
    }

    /*
     * @title Set vesting settings
     * @param Locked percent of incoming tokens (in basis points)
     * @param Default lock value for tokens
     * @dev The caller must have the Owner role
     */
    function setVestingSettings(
        uint256 _vestingPercentage,
        uint256 _vestingLockAfterPurchase
    ) external onlyOwner {
        require(
            _vestingPercentage < 10000 && _vestingLockAfterPurchase > 0,
            "Invalid values"
        );
        vestingPercentage = _vestingPercentage;
        vestingLockAfterPurchase = _vestingLockAfterPurchase;
        emit VestingSettingsUpdated(_vestingPercentage, _vestingLockAfterPurchase);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITreatVesting {
    function registerStake(
        address account,
        address stakingContract,
        uint256 percentage,
        bool isStaking
    ) external;

    function registerTransfer(
        address account,
        uint256 balance,
        uint256 transferAmount
    ) external returns(uint256 willSend, uint256 toRecover);

    function vestingUpdate(
        address _recipient,
        uint256 _amount,
        address _stakingContract,
        bool _liquidity
    ) external;

    function burnStakeVesting(
        address account,
        uint256 percentage
    ) external;

    function viewNotVestedTokens(
        address recipient,
        address stakingContract
    ) external returns(uint256 locked, uint256 coolDownRemaining);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITreatLiquidity {
    function withdrawnPercent(address) external returns(uint256);
}

// SPDX-License-Identifier: MIT

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