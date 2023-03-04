// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ScaleVesting is Ownable {
    struct LinearVestingSchedule {
        uint256 initialUnlockTime;
        uint256 fullUnlockTime;
        uint256 releaseEpochs;
    }

    struct UserVesting {
        uint256 allocationLeft;
        uint256 allocationUsed;
        uint256 lastReleaseEpoch;
        bool claimedBackHeart;
    }

    IERC20 public heartToken;
    IERC20 public launchToken;
    address public withdrawalWallet;
    address public hostWallet;
    bool withdrawn;

    uint256 public saleStartTime;
    uint256 public saleEndTime;
    mapping(address => UserVesting)public userVestings;

    LinearVestingSchedule public saleSchedule;

    uint256 constant precision = 10 ** 18;
    uint256 public heartToSaleTokenConversionRate;
    uint256 public tokenReleasePerEpoch;
    uint256 public heartSoftLimit;
    uint256 public totalHeartRaised;

    constructor(address _launchToken, address _withdrawalWallet, address _hostWallet, address _heartToken) {
        launchToken = IERC20(_launchToken);
        // heartToken = IERC20(0x8FAc8031e079F409135766C7d5De29cf22EF897C);
        heartToken = IERC20(_heartToken);
        withdrawalWallet = _withdrawalWallet;
        hostWallet = _hostWallet;
    }

    function buySale(uint256 _heartAmount)external {
        require(block.timestamp >= saleStartTime && block.timestamp<saleEndTime, "Sale is closed"
        );
        require(
            _heartAmount <= userVestings[msg.sender].allocationLeft, "Not enough allocation"
        );

        heartToken.transferFrom(msg.sender, address(this), _heartAmount);
    unchecked {
        userVestings[msg.sender].allocationLeft -= _heartAmount;
        userVestings[msg.sender].allocationUsed += _heartAmount;
        totalHeartRaised += _heartAmount;
    }
    }

    function releaseVestedTokens() external {

        (uint256 tokensToClaim, uint256 currentEpoch) = tokensClaimableNow(msg.sender);

        require(tokensToClaim > 0, "Nothing to claim");

        userVestings[msg.sender].lastReleaseEpoch = currentEpoch;

        launchToken.transfer(msg.sender, tokensToClaim);
    }

    function claimExcessHeart() external {
        require(
            block.timestamp >= saleEndTime, "No withdrawal before sale end");
        require(heartSoftLimit < totalHeartRaised, "Not overallocated");
        require(!userVestings[msg.sender].claimedBackHeart, "Already claimed");
        uint256 excessHeart = excessHeartToClaim(msg.sender);
        require(excessHeart > 0, "Nothing to claim");
        userVestings[msg.sender].claimedBackHeart = true;
        heartToken.transfer(msg.sender, excessHeart);
    }

    function excessHeartToClaim(address user) public view returns(uint256 excessHeart) {
        if (userVestings[user].claimedBackHeart || heartSoftLimit > totalHeartRaised){ return 0; }
        excessHeart = (userVestings[msg.sender].allocationUsed * (totalHeartRaised - heartSoftLimit)) / totalHeartRaised;
    }

    function allocationUsed(address user)external view returns(uint256) {
        return userVestings[user].allocationUsed;
    }

    function allocationLeft(address user)external view returns(uint256) {
        return userVestings[user].allocationLeft;
    }

    function tokensClaimableNow(address user)public view returns(uint256 tokensToClaim, uint256 thisEpoch) {
        if (userVestings[user].allocationUsed == 0)
            return(0, 0);

        uint256 lastReleaseEpoch = userVestings[user].lastReleaseEpoch;
        thisEpoch = currentReleaseEpoch();

        if (lastReleaseEpoch >= thisEpoch)
            return(0, thisEpoch);

        uint256 heartDeposited = userVestings[user].allocationUsed * currentHeartRatio() / precision;
        uint256 epochsToClaim;
    unchecked {
        epochsToClaim = thisEpoch - lastReleaseEpoch;
        tokensToClaim += tokenReleasePerEpoch * epochsToClaim * heartDeposited / precision;
    }
    }

    function totalTokensToReceive(address user)public view returns(uint256 totalTokens) {
    unchecked {
        totalTokens = (userVestings[user].allocationUsed * heartToSaleTokenConversionRate * currentHeartRatio()) / precision / precision;
    }
    }

    function currentHeartRatio()public view returns(uint256 heartRatio) {
    unchecked {
        heartRatio = (precision * heartSoftLimit) / totalHeartRaised;
    }
        if (heartRatio > precision)
            return precision;

    }

    function currentReleaseEpoch() public view returns(uint256 epoch) {
        uint256 initialUnlockTime = saleSchedule.initialUnlockTime;
        if (block.timestamp < initialUnlockTime || initialUnlockTime == 0) {
            return 0;
        }
        uint256 epochs = saleSchedule.releaseEpochs;
        if (block.timestamp > saleSchedule.fullUnlockTime) {
            return epochs;
        }
        uint256 timeBetweenEpochs;
        if (epochs == 1 || saleSchedule.fullUnlockTime == initialUnlockTime) {
            return block.timestamp - initialUnlockTime;
        }
    unchecked {
        timeBetweenEpochs = (saleSchedule.fullUnlockTime - initialUnlockTime) / (epochs - 1);
    }
        uint256 epochTime = initialUnlockTime;
        for (uint i; i <= epochs;) {
            if (epochTime > block.timestamp)
                return i;

        unchecked {
            epochTime += timeBetweenEpochs;
            ++i;
        }
        }
    }

    function timeToNextEpoch()public view returns(uint256) {
        uint256 initialUnlockTime = saleSchedule.initialUnlockTime;
        if (initialUnlockTime == 0)
            return 0;

        uint256 timestamp = block.timestamp;
        if (timestamp > saleSchedule.fullUnlockTime)
            return 0;


        uint256 epochs = saleSchedule.releaseEpochs;
        if (epochs == 1 || saleSchedule.fullUnlockTime == initialUnlockTime) {
            return timestamp - initialUnlockTime;
        }
        uint256 timeBetweenEpochs;
    unchecked {
        timeBetweenEpochs = (saleSchedule.fullUnlockTime - initialUnlockTime) / (epochs - 1);
    }
        uint256 epochTime = initialUnlockTime;
        for (uint i; i <= epochs;) {
            if (epochTime > timestamp)
                return epochTime - timestamp;

        unchecked {
            epochTime += timeBetweenEpochs;
            ++i;
        }
        }
        return 0;
    }

    function addToAllowlist(address[] calldata _users, uint256[] calldata _amounts)external onlyOwner {
        require(saleStartTime == 0 || block.timestamp < saleStartTime, "No changes after sale start");
        for (uint i; i < _users.length;) {
        unchecked {
            userVestings[_users[i]].allocationLeft += _amounts[i];
            ++i;
        }
        }
    }

    function setSaleParameters(uint256 _saleStartTime, uint256 _saleEndTime, uint256 _initialUnlockTime, uint256 _fullUnlockTime, uint256 _releaseEpochs, uint256 _tokenSaleAmount, uint256 _heartSoftLimit)external onlyOwner {
        require(_tokenSaleAmount < 2 ** 224, "Token sell amount overflow");
        require(_heartSoftLimit < 2 ** 224, "Heart soft limit overflow");
        require(saleStartTime == 0 || block.timestamp < saleStartTime, "No changes after sale start");
        require(_saleStartTime < _saleEndTime, "No negative duration sales");
        require(_saleEndTime <= _initialUnlockTime, "Can't start vesting before sale end");
        require(_initialUnlockTime <= _fullUnlockTime, "Can't end vesting that soon");
        require(_releaseEpochs > 0, "At least 1 epoch");
        if (_initialUnlockTime == _fullUnlockTime){
            require(_releaseEpochs == 1, "For matching times, just 1 epoch");
        }
        if (_releaseEpochs == 1){
            require(_initialUnlockTime == _fullUnlockTime, "For one epoch unlock times are equal");
        }

        launchToken.transferFrom(msg.sender, address(this), _tokenSaleAmount);

        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
        heartSoftLimit = _heartSoftLimit;
    unchecked {
        heartToSaleTokenConversionRate = (precision * _tokenSaleAmount) / _heartSoftLimit;
        tokenReleasePerEpoch = heartToSaleTokenConversionRate / _releaseEpochs;
    }

        saleSchedule = LinearVestingSchedule({initialUnlockTime: _initialUnlockTime, fullUnlockTime: _fullUnlockTime, releaseEpochs: _releaseEpochs});
    }

    function withdraw()external onlyOwner {
        require(block.timestamp >= saleEndTime, "No withdrawal before sale end");
        require(!withdrawn, "Already withdrawn");
        withdrawn = true;
        if (heartSoftLimit > totalHeartRaised) { // not all launch tokens sold, some must be returned
            uint256 launchTokensToReturn;
        unchecked {
            launchTokensToReturn = ((heartSoftLimit - totalHeartRaised) * heartToSaleTokenConversionRate) / precision;
        }
            launchToken.transfer(withdrawalWallet, launchTokensToReturn);
            uint256 heartBalance = heartToken.balanceOf(address(this));
            uint256 feeTaken;
        unchecked {
            feeTaken = (heartBalance * 2) / 100; // 2% fee taken
        }
            heartToken.transfer(hostWallet, feeTaken);
            heartToken.transfer(withdrawalWallet, heartToken.balanceOf(address(this)));
        } else { // only `heartSoftLimit` needs to be withdrawn
            uint256 feeTaken;
        unchecked {
            feeTaken = (heartSoftLimit * 2) / 100; // 2% fee taken
        }
            heartToken.transfer(hostWallet, feeTaken);
            heartToken.transfer(withdrawalWallet, heartSoftLimit - feeTaken);
        }
    }

    function emergencyWithdraw()external onlyOwner {
        require(block.timestamp < saleStartTime, "Sale has started");
        launchToken.transfer(withdrawalWallet, launchToken.balanceOf(address(this)));
        saleSchedule = LinearVestingSchedule({initialUnlockTime: 0, fullUnlockTime: 0, releaseEpochs: 0});
    }
}