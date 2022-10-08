/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
        require(c >= a, "SafeMath: addition overflow");

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
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
        return div(a, b, "SafeMath: division by zero");
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
}

interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


interface IConsumptionNFT {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function mint(uint256 id, address to, uint32 amount) external;
    function burn(address who, uint32 amount) external;
}
 

contract Consumption is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    int constant OFFSET19700101 = 2440588; 

    // IERC20 public token = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public token = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    IConsumptionNFT nft = IConsumptionNFT(0x0f37FD1bD23adaBB5aA6370E94c9e904D41b8838);

    uint private start;
    uint private end;
    uint private index;
    address private market;
    address private feeMarket;

    mapping (address => UserInfo) private userInfo;

    struct UserInfo {
        uint payAmount;
        bool lotterying;
        bool lottery;
    }

    event Purchase(address indexed user, uint indexed pay, uint amount);
    event Lotterying(address indexed user);
    event Claim(address indexed user, bool indexed lottery);
    event Burn(address indexed user, uint amount);

    constructor(address newMarket, address newFeeMarket, uint newStart, uint newEnd) {
        market = newMarket;
        feeMarket = newFeeMarket;
        start = newStart;
        end = newEnd;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // function purchase(uint pay) external {
    //     require(block.timestamp >= start, "Not start");
    //     require(block.timestamp <= end, "Has end");
    //     require(pay == 100 * 10 ** 18 ||
    //         pay == 5000 * 10 ** 18 ||
    //         pay == 10000 * 10 ** 18, "Error pay amount");

    //     UserInfo storage user = userInfo[msg.sender];
    //     user.payAmount += pay;

    //     (, , , uint mp100, uint mp5000, uint mp10000) = getConsumptionInfo();
    //     if (pay == 100 * 10 ** 18) {
    //         nft.mint(0, msg.sender, uint32(mp100));
    //         user.nftAmount += mp100;

    //         if (!user.lotterying && !user.lottery) {
    //             user.lotterying = true;
    //             emit Lotterying(msg.sender);
    //         }
    //     } else if (pay == 5000 * 10 ** 18) {
    //         nft.mint(0, msg.sender, uint32(mp5000));
    //         user.nftAmount += mp5000;
    //     } else {
    //         nft.mint(0, msg.sender, uint32(mp10000));
    //         user.nftAmount += mp10000;
    //     } 

    //     if (pay == 100 * 10 ** 18) index++;
    //     else index = 0;

    //     token.safeTransferFrom(msg.sender, market, pay.mul(17).div(20));
    //     token.safeTransferFrom(msg.sender, feeMarket, pay.mul(3).div(20));

    //     emit Purchase(msg.sender, pay);
    // }

    function purchase(uint pay) external {
        require(block.timestamp >= start, "Not start");
        require(block.timestamp <= end, "Has end");
        require(pay == 1 * 10 ** 16 ||
            pay == 50 * 10 ** 17 ||
            pay == 1 * 10 ** 18, "Error pay amount");

        UserInfo storage user = userInfo[msg.sender];
        user.payAmount += pay;

        (, , , uint mp100, uint mp5000, uint mp10000) = getConsumptionInfo();
        uint amount;
        if (pay == 1 * 10 ** 16) {
            amount = mp100;
            nft.mint(0, msg.sender, uint32(mp100));

            if (!user.lotterying && !user.lottery) {
                user.lotterying = true;
                emit Lotterying(msg.sender);
            }
        } else if (pay == 50 * 10 ** 17) {
            amount = mp5000;
            nft.mint(0, msg.sender, uint32(mp5000));
        } else {
            amount = mp10000;
            nft.mint(0, msg.sender, uint32(mp10000));
        } 

        if (pay == 1 * 10 ** 16) index++;
        else index = 0;

        token.safeTransferFrom(msg.sender, market, pay.mul(17).div(20));
        token.safeTransferFrom(msg.sender, feeMarket, pay.mul(3).div(20));

        emit Purchase(msg.sender, pay, amount);
    }

    function claim() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.lotterying && !user.lottery, "Insufficient permissions");

        user.lotterying = false;
        user.lottery = true;

        // if (index % 100 == 0) {
        //     index = 0;
        //     emit Claim(msg.sender, true);
        // } else {
        //     emit Claim(msg.sender, false);
        // }

        if (index % 3 == 0) {
            index = 0;
            emit Claim(msg.sender, true);
        } else {
            emit Claim(msg.sender, false);
        }
    }

    function burn(uint amount) external {
        require(nft.balanceOf(msg.sender, 0) >= amount, "Insufficient amount");

        nft.burn(msg.sender, uint32(amount));

        emit Burn(msg.sender, amount);
    }

    function setMarket(address newMarket) external onlyOwner {
        market = newMarket;
    }

    function setFeeMarket(address newFeeMarket) external onlyOwner {
        feeMarket = newFeeMarket;
    }

    function setStart(uint newStart) external onlyOwner {
        start = newStart;
    }

    function setEnd(uint newEnd) external onlyOwner {
        end = newEnd;
    }

    function getUserInfo(address user) public view returns (UserInfo memory) {
        return userInfo[user];
    }

    function getConsumptionInfo() public view returns (uint, uint, uint, uint, uint, uint) {
        uint subdays = _subDays(start, block.timestamp);
        if (subdays > 30) subdays = 30;

        uint maxPurchase100 = 50 - subdays;
        uint maxPurchase5000 = 2500 - subdays * 30;
        uint maxPurchase10000 = 5000 - subdays * 60;

        return (start, end, _subDays(start, block.timestamp) + 1, maxPurchase100, maxPurchase5000, maxPurchase10000);
    }

    
    function _subDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint day) {
        (uint yf, uint mf, uint df) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint yt, uint mt, uint dt) = _daysToDate(toTimestamp / SECONDS_PER_DAY);

        uint fdays = _daysFromDate(yf, mf, df);
        uint tdays = _daysFromDate(yt, mt, dt);

        return tdays - fdays; 
    }

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);
 
        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;
 
        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);
 
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;
 
        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

}