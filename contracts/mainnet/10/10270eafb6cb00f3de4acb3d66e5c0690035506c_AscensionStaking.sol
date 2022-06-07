/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: staking.sol


pragma solidity ^0.8.0;




contract AscensionStaking is Ownable, Pausable {
    // Address of the token for the staking.
    IERC20 public acceptedToken;

    // Struc with user details.
    struct _user {
        uint256 balance;
        uint256 timeStarted;
        uint256 timeFinish;
    }

    // APY for each class.
    uint256 public level0APY = 3000;
    uint256 public level1APY = 5000;
    uint256 public vipLevelAPY = 10000;

    // Min - Max for each Level
    uint256 public level0Min = 50000000 * 10**9;
    uint256 public level0Max = 500000000 * 10**9;
    uint256 public level1Min = 50000000 * 10**9;
    uint256 public level1Max = 500000000 * 10**9;
    uint256 public levelVipMin = 1000000000 * 10**9;
    uint256 public levelVipMax = 2500000000 * 10**9;

    // Mapping for user details of  each class.
    mapping(address => bool) public isLevel0;
    mapping(address => _user) public level0Balance;
    mapping(address => bool) public isLevel1;
    mapping(address => _user) public level1Balance;
    mapping(address => bool) public isVip;
    mapping(address => _user) public vipBalance;

    // Events.
    event deposit(
        address user,
        uint8 class,
        uint256 amount,
        uint256 timeStart,
        uint256 timeEnd
    );
    event withdraw(
        address user,
        uint8 class,
        bool onTime,
        uint256 amount,
        uint256 earnings
    );

    // Set the token to be staked.
    constructor(address _token) {
        acceptedToken = IERC20(_token);
    }

    // Pause and Unpause the contract
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Change APY for all categories.
     */

    function setNewAPY(
        uint256 _level0APY,
        uint256 _level1APY,
        uint256 _vipLevelAPY
    ) external onlyOwner {
        level0APY = _level0APY;
        level1APY = _level1APY;
        vipLevelAPY = _vipLevelAPY;
    }

    /**
     * @dev Change max and min values for all categories.
     */

    function setNewMaxMin(
        uint256 _level0Min,
        uint256 _level0Max,
        uint256 _level1Min,
        uint256 _level1Max,
        uint256 _levelVipMin,
        uint256 _levelVipMax
    ) external onlyOwner {
        level0Min = _level0Min;
        level0Max = _level0Max;
        level1Min = _level1Min;
        level1Max = _level1Max;
        levelVipMin = _levelVipMin;
        levelVipMax = _levelVipMax;
    }

    /**
     * @dev Join to a staking class.
     *
     * Requirements:
     *
     * - User has not enter the staking class previously.
     */
    function enterLevel0(uint256 _amount) public whenNotPaused {
        require(
            _amount <= level0Max && _amount >= level0Min,
            "Amount needs to be more than min and less than max"
        );
        address _msgSender = msg.sender;
        require(!isLevel0[_msgSender], "You're already in this Stake level");

        acceptedToken.transferFrom(_msgSender, address(this), _amount);

        isLevel0[_msgSender] = true;
        level0Balance[_msgSender] = _user({
            balance: _amount,
            timeStarted: block.timestamp,
            timeFinish: block.timestamp + 30 days
        });

        emit deposit(
            _msgSender,
            0,
            _amount,
            block.timestamp,
            block.timestamp + 30 days
        );
    }

    /**
     * @dev Join to a staking class.
     *
     * Requirements:
     *
     * - User has not enter the staking class previously.
     */
    function enterLevel1(uint256 _amount) public whenNotPaused {
        require(
            _amount <= level1Max && _amount >= level1Min,
            "Amount needs to be more than min and less than max"
        );
        address _msgSender = msg.sender;
        require(!isLevel1[_msgSender], "You're already in this Stake level");

        acceptedToken.transferFrom(_msgSender, address(this), _amount);

        isLevel1[_msgSender] = true;
        level1Balance[_msgSender] = _user({
            balance: _amount,
            timeStarted: block.timestamp,
            timeFinish: block.timestamp + 90 days
        });

        emit deposit(
            _msgSender,
            1,
            _amount,
            block.timestamp,
            block.timestamp + 90 days
        );
    }

    /**
     * @dev Join to a staking class.
     *
     * Requirements:
     *
     * - _amount must be greather than enter fee.
     * - User has not enter the staking class previously.
     */
    function enterVip(uint256 _amount) public whenNotPaused {
        require(
            _amount <= levelVipMax && _amount >= levelVipMin,
            "Amount needs to be more than min and less than max"
        );
        address _msgSender = msg.sender;
        require(!isVip[_msgSender], "You're already in the Vip Stake");

        acceptedToken.transferFrom(_msgSender, address(this), _amount);

        isVip[_msgSender] = true;
        vipBalance[_msgSender] = _user({
            balance: _amount,
            timeStarted: block.timestamp,
            timeFinish: block.timestamp + 180 days
        });

        emit deposit(
            _msgSender,
            2,
            _amount,
            block.timestamp,
            block.timestamp + 180 days
        );
    }

    /**
     * @dev Checks if the staking has reached the timeFinish limit.
     *
     * classes :0 - level 0, 1 - level 1, 2 - Vip
     */
    function isOnTime(address user, uint8 class) public view returns (bool) {
        uint256 releaseTime;
        if (class == 0) {
            releaseTime = level0Balance[user].timeFinish;
        } else if (class == 1) {
            releaseTime = level1Balance[user].timeFinish;
        } else if (class == 2) {
            releaseTime = vipBalance[user].timeFinish;
        } else {
            return false;
        }
        return block.timestamp >= releaseTime;
    }

    /**
     * @dev Get interest earned during the staking time.
     *
     * classes : 0 - level 0, 1 - level 1, 2 - Vip
     */
    function getInterest(
        address user,
        uint8 class,
        uint256 balance
    ) public view returns (uint256) {
        if (class == 0) {
            uint256 _timeStarted = level0Balance[user].timeStarted;

            return calculateInterest(balance, _timeStarted, level0APY);
        } else if (class == 1) {
            uint256 _timeStarted = level1Balance[user].timeStarted;

            return calculateInterest(balance, _timeStarted, level1APY);
        } else if (class == 2) {
            uint256 _timeStarted = vipBalance[user].timeStarted;

            return calculateInterest(balance, _timeStarted, vipLevelAPY);
        } else {
            return 0;
        }
    }

    function calculateInterest(
        uint256 _balance,
        uint256 _timeStarted,
        uint256 _APY
    ) internal view returns (uint256) {
        uint256 timeStaked = block.timestamp - _timeStarted;

        uint256 interestPerSecond = ((_balance * _APY) / 10000) / 365 days;
        uint256 interestsEarned = timeStaked * interestPerSecond;

        return interestsEarned;
    }

    /**
     * @dev Withdraw from a staking class.
     *
     * Requirements:
     *
     * - Msg.sender should have an active deposit in the class.
     */
    function withdrawLevel0(uint256 _amount) public {
        address _msgSender = msg.sender;
        require(isLevel0[_msgSender], "User is not on Level 0");

        uint256 balance = level0Balance[_msgSender].balance;
        require(balance >= _amount, "Not enough balance to withdraw");

        bool _isOnTime = isOnTime(_msgSender, 0);
        uint256 earnings = getInterest(_msgSender, 0, _amount);

        if (_amount == balance) {
            delete level0Balance[_msgSender];
            isLevel0[_msgSender] = false;
        } else {
            level0Balance[_msgSender].balance -= _amount;
        }

        if (_isOnTime) {
            acceptedToken.transfer(_msgSender, _amount + earnings);
        } else {
            earnings = 0;
            acceptedToken.transfer(_msgSender, _amount);
        }

        emit withdraw(_msgSender, 0, _isOnTime, _amount, earnings);
    }

    /**
     * @dev Withdraw from a staking class.
     *
     * Requirements:
     *
     * - Msg.sender should have an active deposit in the class.
     */
    function withdrawLevel1(uint256 _amount) public {
        address _msgSender = msg.sender;
        require(isLevel1[_msgSender], "User is not on Level 1");

        uint256 balance = level1Balance[_msgSender].balance;
        require(balance >= _amount, "Not enough balance to withdraw");

        bool _isOnTime = isOnTime(_msgSender, 1);
        uint256 earnings = getInterest(_msgSender, 1, _amount);

        if (_amount == balance) {
            delete level1Balance[_msgSender];
            isLevel1[_msgSender] = false;
        } else {
            level1Balance[_msgSender].balance -= _amount;
        }

        if (_isOnTime) {
            acceptedToken.transfer(_msgSender, _amount + earnings);
        } else {
            earnings = 0;
            acceptedToken.transfer(_msgSender, _amount);
        }

        emit withdraw(_msgSender, 1, _isOnTime, _amount, earnings);
    }

    /**
     * @dev Withdraw from a staking class.
     *
     * Requirements:
     *
     * - Msg.sender should have an active deposit in the class.
     */
    function withdrawVip(uint256 _amount) public {
        address _msgSender = msg.sender;
        require(isVip[_msgSender], "User is not Vip");

        uint256 balance = vipBalance[_msgSender].balance;
        require(balance >= _amount, "Not enough balance to withdraw");

        bool _isOnTime = isOnTime(_msgSender, 2);
        uint256 earnings = getInterest(_msgSender, 2, _amount);

        if (_amount == balance) {
            delete vipBalance[_msgSender];
            isVip[_msgSender] = false;
        } else {
            vipBalance[_msgSender].balance -= _amount;
        }

        if (_isOnTime) {
            acceptedToken.transfer(_msgSender, _amount + earnings);
        } else {
            earnings = 0;
            acceptedToken.transfer(_msgSender, _amount);
        }

        emit withdraw(_msgSender, 2, _isOnTime, _amount, earnings);
    }

    function withdrawTokens(address _token) external onlyOwner {
        uint256 balance =  IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(
            msg.sender,
            balance
        );
    }
}