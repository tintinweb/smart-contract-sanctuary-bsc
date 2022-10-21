/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

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

// 
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


contract DexStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    IBEP20 public USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public BTD = IBEP20(0xA43Ee56694713ea064C3a42E2EE94C19A8F61DE9);
    
    uint256 public INTEREST_RATE_PACKAGE_1 = 15;
    uint256 public INTEREST_RATE_PACKAGE_2 = 20;
    uint256 public INTEREST_RATE_PACKAGE_3 = 25;
    uint256 public BONUS_BTD = 90;
    uint256 public BONUS_USDT = 10;

    uint256 public BONUS_F1_PACKAGE_1 = 18;
    uint256 public BONUS_F2_PACKAGE_1 = 12;
    uint256 public BONUS_F3_PACKAGE_1 = 8;

    uint256 public BONUS_F1_PACKAGE_2 = 20;
    uint256 public BONUS_F2_PACKAGE_2 = 15;
    uint256 public BONUS_F3_PACKAGE_2 = 10;

    uint256 public BONUS_F1_PACKAGE_3 = 25;
    uint256 public BONUS_F2_PACKAGE_3 = 20;
    uint256 public BONUS_F3_PACKAGE_3 = 15;

    uint256 public CLAIM_FEE = 2;

    uint256 public WITHDRAW_PERIOD_1 = 180 days;
    uint256 public WITHDRAW_PERIOD_2 = 365 days;
    uint256 public WITHDRAW_PERIOD_3 = 730 days;

    uint256 public BTD_PRICE = 172;
    uint256 public BTD_PRICE_DECIMAL = 1000000;

    struct UserInfo {
        uint256 package;
        uint256 stakingAmount;
        uint256 bonusDebt;
        uint256 depositAt;
    }

    mapping(address => UserInfo) public userInfo;

    event RescueFundsUSDT(address indexed owner, address _to);
    event RescueFundsBTD(address indexed owner, address _to);
    event SetUSDTToken(address indexed owner, address _to);
    event SetBTDToken(address indexed owner, address _to);
    event SetInterestRatePackage(address indexed owner, uint256 _interestRatePackage1, uint256 _interestRatePackage2, uint256 _interestRatePackage3);
    event SetBonus(address indexed owner, uint256 _bonusBTD, uint256 _bonusUSDT);
    event SetFBonus(address indexed owner, uint256 _f1BonusPackage1, uint256 _f2BonusPackage1, uint256 _f3BonusPackage1, uint256 _f1BonusPackage2, uint256 _f2BonusPackage2, uint256 _f3BonusPackage2, uint256 _f1BonusPackage3, uint256 _f2BonusPackage3, uint256 _f3BonusPackage3);
    event SetClaimFee(address indexed owner, uint256 _claimFee);
    event SetWithdrawPeriod(address indexed owner, uint256 _withdrawPeriod1, uint256 _withdrawPeriod2, uint256 _withdrawPeriod3);
    event SetBTDPrice(address indexed owner, uint256 _btdPrice, uint256 _btdPriceDecimal);
    event Stake(address indexed owner, uint256 _package, uint256 _amount, address _f1, address _f2, address _f3);
    event Withdraw(address indexed owner, uint256 _amount);
    event Claim(address indexed owner);
    event AddUserInfo(address indexed owner, address _account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt);
    event UpdateUserInfo(address indexed owner, address _account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt);
    event RemoveUserInfo(address indexed owner, address _account);

    /* --VIEWS-- */

    function balanceUSDT() public view returns(uint256) {
        return USDT.balanceOf(address(this));
    }

    function balanceBTD() public view returns(uint256) {
        return BTD.balanceOf(address(this));
    }

    function balanceBTDOfUser(address account) public view returns(uint256) {
        return BTD.balanceOf(account);
    }

    function calculateBonus(address account) public view returns(uint256) {
        UserInfo storage user = userInfo[account];
        if(user.stakingAmount > 0) {
            uint256 dayBonus = 0;
            uint256 timestampBonus = block.timestamp.sub(user.depositAt);
            
            if(timestampBonus > 86400) {
                uint256 modBonus = timestampBonus.mod(86400);
                uint256 modBonusTimeStamp = timestampBonus.sub(modBonus);
                dayBonus = modBonusTimeStamp.div(86400);
            } else {
                return 0;
            }

            if(user.package == 1) {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_1).div(100).div(30).mul(dayBonus).sub(user.bonusDebt);
            } else if (user.package == 2) {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_2).div(100).div(30).mul(dayBonus).sub(user.bonusDebt);
            } else {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_3).div(100).div(30).mul(dayBonus).sub(user.bonusDebt);
            }
        } else {
            return 0;
        }
    }

    function checkWithdraw(address account) public view returns(bool) {
        UserInfo storage user = userInfo[account];
        if(user.package == 1) {
            if(user.depositAt.add(WITHDRAW_PERIOD_1) > block.timestamp) {
                return false;
            }
        } else if (user.package == 2) {
            if(user.depositAt.add(WITHDRAW_PERIOD_2) > block.timestamp) {
                return false;
            }
        } else {
            if(user.depositAt.add(WITHDRAW_PERIOD_3) > block.timestamp) {
                return false;
            }
        }
        return true;
    }

    /* --OWNER-- */

    function addUserInfo(address account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt) external onlyOwner {
        userInfo[account].package = _package;
        userInfo[account].stakingAmount = _stakingAmount;
        userInfo[account].bonusDebt = _bonusDebt;
        userInfo[account].depositAt = _depositAt;

        emit AddUserInfo(msg.sender, account, _package, _stakingAmount, _bonusDebt, _depositAt);
    }

    function updateUserInfo(address account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt) external onlyOwner {
        userInfo[account].package = _package;
        userInfo[account].stakingAmount = _stakingAmount;
        userInfo[account].bonusDebt = _bonusDebt;
        userInfo[account].depositAt = _depositAt;

        emit UpdateUserInfo(msg.sender, account, _package, _stakingAmount, _bonusDebt, _depositAt);
    }

    function removeUserInfo(address account) external onlyOwner {
        delete userInfo[account];

        emit RemoveUserInfo(msg.sender, account);
    }

    function rescueFundsUSDT(address to) external onlyOwner {
        uint256 bal = balanceUSDT();
        require(bal > 0, 'dont have a USDT');
        USDT.transfer(to, bal);

        emit RescueFundsUSDT(msg.sender, to);
    }

    function rescueFundsBTD(address to) external onlyOwner {
        uint256 bal = balanceBTD();
        require(bal > 0, 'dont have a BTD');
        BTD.transfer(to, bal);

        emit RescueFundsBTD(msg.sender, to);
    }

    function setUSDTToken(address _usdt) external onlyOwner {
        USDT = IBEP20(_usdt);

        emit SetUSDTToken(msg.sender, _usdt);
    }

    function setBTDToken(address _btd) external onlyOwner {
        BTD = IBEP20(_btd);

        emit SetBTDToken(msg.sender, _btd);
    }

    function setInterestRatePackage(uint256 _interestRatePackage1, uint256 _interestRatePackage2, uint256 _interestRatePackage3) external onlyOwner {
        INTEREST_RATE_PACKAGE_1 = _interestRatePackage1;
        INTEREST_RATE_PACKAGE_2 = _interestRatePackage2;
        INTEREST_RATE_PACKAGE_3 = _interestRatePackage3;

        emit SetInterestRatePackage(msg.sender, _interestRatePackage1, _interestRatePackage2, _interestRatePackage3);
    }

    function setBonus(uint256 _bonusBTD, uint256 _bonusUSDT) external onlyOwner {
        BONUS_BTD = _bonusBTD;
        BONUS_USDT = _bonusUSDT;

        emit SetBonus(msg.sender, _bonusBTD, _bonusUSDT);
    }

    function setFBonus(uint256 _f1BonusPackage1, uint256 _f2BonusPackage1, uint256 _f3BonusPackage1, uint256 _f1BonusPackage2, uint256 _f2BonusPackage2, uint256 _f3BonusPackage2, uint256 _f1BonusPackage3, uint256 _f2BonusPackage3, uint256 _f3BonusPackage3) external onlyOwner {
        BONUS_F1_PACKAGE_1 = _f1BonusPackage1;
        BONUS_F2_PACKAGE_1 = _f2BonusPackage1;
        BONUS_F3_PACKAGE_1 = _f3BonusPackage1;
        
        BONUS_F1_PACKAGE_2 = _f1BonusPackage2;
        BONUS_F2_PACKAGE_2 = _f2BonusPackage2;
        BONUS_F3_PACKAGE_2 = _f3BonusPackage2;

        BONUS_F1_PACKAGE_3 = _f1BonusPackage3;
        BONUS_F2_PACKAGE_3 = _f2BonusPackage3;
        BONUS_F3_PACKAGE_3 = _f3BonusPackage3;

        emit SetFBonus(msg.sender, _f1BonusPackage1, _f2BonusPackage1, _f3BonusPackage1, _f1BonusPackage2, _f2BonusPackage2, _f3BonusPackage2, _f1BonusPackage3, _f2BonusPackage3, _f3BonusPackage3);
    }

    function setClaimFee(uint256 _claimFee) external onlyOwner {
        CLAIM_FEE = _claimFee;

        emit SetClaimFee(msg.sender, _claimFee);
    }

    function setWithdrawPeriod(uint256 _withdrawPeriod1, uint256 _withdrawPeriod2, uint256 _withdrawPeriod3) external onlyOwner {
        WITHDRAW_PERIOD_1 = _withdrawPeriod1;
        WITHDRAW_PERIOD_2 = _withdrawPeriod2;
        WITHDRAW_PERIOD_3 = _withdrawPeriod3;

        emit SetWithdrawPeriod(msg.sender, _withdrawPeriod1, _withdrawPeriod2, _withdrawPeriod3);
    }

    function setBTDPrice(uint256 _btdPrice, uint256 _btdPriceDecimal) external onlyOwner {
        BTD_PRICE = _btdPrice;
        BTD_PRICE_DECIMAL = _btdPriceDecimal;

        emit SetBTDPrice(msg.sender, _btdPrice, _btdPriceDecimal);
    }

    /* --EXTERNAL-- */

    function stake(uint256 package, uint256 amount, address f1, address f2, address f3) public {
        _stake(msg.sender, package, amount, f1, f2, f3);
    }

    function withdraw(uint256 amount) public {
        _withdraw(msg.sender, amount);
    }

    function claim() public {
        _claim(msg.sender);
    }

    /* --INTERNAL-- */

    function _stake(address account, uint256 package, uint256 amount, address f1, address f2, address f3) private {
        require(amount > 0, "amount must greater than zero");
        require(account != address(0), "account must not zero address");
        require(balanceBTDOfUser(account) >= amount, "balance BTD is not enough");
        UserInfo storage user = userInfo[account];
        if(user.stakingAmount > 0) {
            require(package == user.package, "user already staked on other package");
        }
        BTD.transferFrom(account, address(this), amount);
        user.stakingAmount = user.stakingAmount.add(amount);
        user.depositAt = block.timestamp;
        user.bonusDebt = 0;
        uint256 BONUS_F1 = BONUS_F1_PACKAGE_1;
        uint256 BONUS_F2 = BONUS_F2_PACKAGE_1;
        uint256 BONUS_F3 = BONUS_F3_PACKAGE_1;

        if(package == 2) {
            BONUS_F1 = BONUS_F1_PACKAGE_2;
            BONUS_F2 = BONUS_F2_PACKAGE_2;
            BONUS_F3 = BONUS_F3_PACKAGE_2;
        } else if (package == 3) {
            BONUS_F1 = BONUS_F1_PACKAGE_3;
            BONUS_F2 = BONUS_F2_PACKAGE_3;
            BONUS_F3 = BONUS_F3_PACKAGE_3;
        }

        if(f1 != address(0) && account != f1 && userInfo[f1].stakingAmount > 0){
            uint256 f1BonusAmount = amount.mul(BONUS_F1).div(100);
            BTD.transfer(f1, f1BonusAmount);
        }
        if(f2 != address(0) && account != f2 && f2 != f1 && userInfo[f2].stakingAmount > 0) {
            uint256 f2BonusAmount = amount.mul(BONUS_F2).div(100);
            BTD.transfer(f2, f2BonusAmount);
        }
        if(f3 != address(0) && account != f3 && f3 != f2 && f3 != f1 && userInfo[f3].stakingAmount > 0) {
            uint256 f3BonusAmount = amount.mul(BONUS_F3).div(100);
            BTD.transfer(f3, f3BonusAmount);
        }

        emit Stake(account, package, amount, f1, f2, f3);
    }

    function _withdraw(address account, uint256 amount) private nonReentrant {
        UserInfo storage user = userInfo[account];
        require(userInfo[msg.sender].stakingAmount >= amount, "sender dont have a enough fund");
        require(amount > 0, "amount must greater than zero");
        require(account != address(0), "account must not zero address");

        if(user.package == 1) {
            require(user.depositAt.add(WITHDRAW_PERIOD_1) <= block.timestamp, "your account was locked");
        } else if (user.package == 2) {
            require(user.depositAt.add(WITHDRAW_PERIOD_2) <= block.timestamp, "your account was locked");
        } else {
            require(user.depositAt.add(WITHDRAW_PERIOD_3) <= block.timestamp, "your account was locked");
        }        
        
        uint256 balBTD = balanceBTD();
        require(balBTD >= amount, "smartcontract is not enough BTD");
        BTD.transfer(account, amount);
        user.stakingAmount = user.stakingAmount.sub(amount);
        user.depositAt = block.timestamp;
        user.bonusDebt = 0;
        emit Withdraw(account, amount);
    }

    function _claim(address account) private nonReentrant {
        require(userInfo[msg.sender].stakingAmount > 0, "user is not staking");
        uint256 bonus = calculateBonus(account);
        require(bonus > 0, "bonus must be greater than zero");
        uint256 bonusReturn = bonus.sub(bonus.mul(CLAIM_FEE).div(100));
        BTD.transfer(account, bonusReturn.mul(BONUS_BTD).div(100));
        USDT.transfer(account, bonusReturn.mul(BONUS_USDT).div(100).mul(BTD_PRICE).div(BTD_PRICE_DECIMAL));
        userInfo[account].bonusDebt = userInfo[account].bonusDebt.add(bonus);
        emit Claim(account);
    }
}