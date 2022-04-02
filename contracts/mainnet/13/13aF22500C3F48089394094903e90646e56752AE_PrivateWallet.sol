/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: contracts/8_PrivateWallet.sol



pragma solidity 0.8.11;




contract PrivateWallet is Ownable, ReentrancyGuard {
    struct User {
        uint256 balance;
        uint256 amountClaimVesting;
        bool isClaimTGE;
    }
    uint256 public _firstLockingTime;
    uint256 public _tge;
    uint256 public _totalVestingPeriod;
    uint256 public _vestingPeriod;
    uint256 public _totalBalances;
    uint256 public _cost;
    uint256 public _minW1;
    uint256 public _maxW1;
    uint256 public _minW2;
    uint256 public _maxW2;
    uint256 public _tgeTime;

    bool public _soldOut;

    address public _token;
    address public _exchangeToken;

    address[] public whiteList1;
    address[] public whiteList2;
    address[] private _userKeys;

    event Register(address indexed buyer, uint256 amount);
    event ClaimWDA(address indexed buyer, uint256 amount);
    event SoldOut(bool soldout);
    mapping(address => User) public users;

    constructor(address token_, address exchangeToken_) {
        _token = token_;
        _exchangeToken = exchangeToken_;
    }

    function initialize(
        uint256 firstLockingTime_,
        uint256 tge_,
        uint256 vestingPeriod_,
        uint256 totalVestingPeriod_,
        uint256 totalBalances_,
        uint256 cost_
    ) external onlyOwner {
        _firstLockingTime = firstLockingTime_;
        _tge = tge_;
        _vestingPeriod = vestingPeriod_;
        _totalVestingPeriod = totalVestingPeriod_;
        _totalBalances = totalBalances_;
        _cost = cost_;
        delete whiteList1;
        delete whiteList2;
        for(uint256 i = 0; i < _userKeys.length; i++){
            delete users[_userKeys[i]];
        }
        _soldOut = false;
    }

    function setMinMax(
        uint256 minW1_,
        uint256 maxW1_,
        uint256 minW2_,
        uint256 maxW2_
    ) external onlyOwner {
        _minW1 = minW1_;
        _maxW1 = maxW1_;
        _minW2 = minW2_;
        _maxW2 = maxW2_;
    }

    function buy(uint256 amount) external  nonReentrant {
        require(_maxW1 != 0 && _maxW2 != 0, "PRIVATE:Not initial");
        require(
            getTotalBoughtWDA() + amount <= _totalBalances,
            "PRIVATE:Higer than total"
        );
        require(
            isWhiteList1(msg.sender) || isWhiteList2(msg.sender),
            "PRIVATE:Address not whitelist"
        );
        if (!isExistAddress(msg.sender)) {
            users[msg.sender] = User(0, 0, false);
            _userKeys.push(msg.sender);
        }

        User storage user = users[msg.sender];
        require(user.isClaimTGE == false, "PRIVATE: Already claim TGE");

        if (isWhiteList1(msg.sender)) {
            require(amount >= _minW1, "PRIVATE:Less than _minW1");
            require(
                user.balance + amount <= _maxW1,
                "PRIVATE:More than maxium"
            );
        } else if (isWhiteList2(msg.sender)) {
            require(amount >= _minW2, "PRIVATE:Less than _minW2");
            require(
                user.balance + amount <= _maxW2,
                "PRIVATE:More than maxium"
            );
        }
        user.balance += amount;
        if (getTotalBoughtWDA() == _totalBalances) {
            _soldOut = true;
            emit SoldOut(_soldOut);
        }
        uint256 totalBusd = (amount / 1 ether) * _cost;
        uint256 allowance = IERC20(_exchangeToken).allowance(
            msg.sender,
            address(this)
        );
        require(totalBusd <= allowance, "PRIVATE:Insufficent allowance");
        IERC20(_exchangeToken).transferFrom(
            msg.sender,
            address(this),
            totalBusd
        );
        emit Register(msg.sender, amount);
    }

    function setTgeTime(uint256 tgeTime_) external onlyOwner {
       _tgeTime = tgeTime_;
        _firstLockingTime = _firstLockingTime + _tgeTime;
    }

    function vesting() external nonReentrant onlyTgeStart {
        User storage user = users[msg.sender];
        uint256 amount = getUnlocked(msg.sender);
        require(amount > 0, "PRIVATE: Unlock token is 0");
        if(user.isClaimTGE == false){
            user.amountClaimVesting = user.amountClaimVesting + amount - user.balance * _tge / 100;
            user.isClaimTGE = true;
        } else {
            user.amountClaimVesting += amount;
        }
        _claimToken(amount);
    }

    function nextTimeClaim() external view returns(uint256){
        uint256 times = 0;
        if (_tgeTime == 0 ){
            return 0;
        }
        if(0 < _tgeTime && _tgeTime >= block.timestamp){
            return _tgeTime;
        } else if(block.timestamp > _firstLockingTime) {
            times = (block.timestamp - _firstLockingTime) / _vestingPeriod;
        }
        return _firstLockingTime + times*_vestingPeriod;
    }

    function _claimToken(uint256 amount) internal {
        uint256 walletBalances = IERC20(_token).balanceOf(address(this));
        require(amount <= walletBalances, "PRIVATE:Insufficent token");
        IERC20(_token).transfer(msg.sender, amount);
        emit ClaimWDA(msg.sender, amount);
    }

    function getUnlocked(address account) public view returns (uint256) {
        User storage user = users[account];
        if(_tgeTime == 0 || block.timestamp <= _tgeTime){
            return 0;
        }
        uint256 amountUnlock = 0;
        uint256 times = 0;
        if(block.timestamp > _firstLockingTime){
            times = (block.timestamp - _firstLockingTime) / _vestingPeriod;
            times = times + 1;
        }
        uint256 unlockedTokenPerTime = ((user.balance * (100 - _tge)) / 100) /
            _totalVestingPeriod;
        uint256 totalUnlockedToken = (times * unlockedTokenPerTime);
        if (totalUnlockedToken >= ((user.balance * (100 - _tge)) / 100)) {
            amountUnlock = (user.balance * (100 - _tge)) / 100 - user.amountClaimVesting;
        } else {
            amountUnlock = totalUnlockedToken - user.amountClaimVesting;
        }
        if(user.isClaimTGE == false){
            amountUnlock = amountUnlock + user.balance * _tge / 100;
        }
        return amountUnlock;
    }

    function getRelease(address account) public view returns(uint256){
        if(users[account].isClaimTGE){
            return users[account].amountClaimVesting + users[account].balance * _tge / 100;
        }
        return 0;
    }

    function setWhiteList1(address[] calldata users_) external onlyOwner {
        delete whiteList1;
        whiteList1 = users_;
    }

    function isWhiteList1(address account) public view returns (bool) {
        for (uint256 i = 0; i < whiteList1.length; i++) {
            if (whiteList1[i] == account) {
                return true;
            }
        }
        return false;
    }

    function setWhiteList2(address[] calldata users_) external onlyOwner {
        delete whiteList2;
        whiteList2 = users_;
    }

    function isWhiteList2(address account) public view returns (bool) {
        for (uint256 i = 0; i < whiteList2.length; i++) {
            if (whiteList2[i] == account) {
                return true;
            }
        }
        return false;
    }

    function setUserBalance(address account, uint256 amount)
        external
        onlyOwner
    {
        require(!isExistAddress(account), "PRIVATE:Already exist");
        users[account] = User(0, 0, false);
        _userKeys.push(account);
        User storage user = users[account];
        user.balance += amount;
        if(getTotalBoughtWDA() == _totalBalances){
            _soldOut = true;
        }
        emit SoldOut(_soldOut);
    }

    function withdrawBusd() external onlyOwner {
        uint256 amountBusd = IERC20(_exchangeToken).balanceOf(address(this));
        IERC20(_exchangeToken).transfer(owner(), amountBusd);
    }

    function getWDABalance(address account) public view returns (uint256) {
        for (uint256 i = 0; i < _userKeys.length; i++) {
            if (_userKeys[i] == account) {
                return users[_userKeys[i]].balance;
            }
        }
        return 0;
    }

    function getTotalBoughtWDA() public view returns (uint256) {
        uint256 totalBought = 0;
        for (uint256 i = 0; i < _userKeys.length; i++) {
            totalBought += users[_userKeys[i]].balance;
        }
        return totalBought;
    }

    function getTotalUnboughtWDA() public view returns (uint256) {
        return _totalBalances - getTotalBoughtWDA();
    }

    function isExistAddress(address account) public view returns (bool) {
        for (uint256 i = 0; i < _userKeys.length; i++) {
            if (_userKeys[i] == account) {
                return true;
            }
        }
        return false;
    }

    modifier onlyTgeStart() {
        require(_tgeTime > 0, "SEED: TGE not start");
        _;
    }
}