/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

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
    function renounceOwnership(bool renounce) public virtual onlyOwner {
        if (renounce)
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

interface IExosToken is IERC20 {
    function mint(address account, uint256 amount) external;
}

interface IExosPresale {
    function getContribution(address account) external view returns (uint256);
}

contract ExosVesting is Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 MAX_INT = 2**256 - 1;
    uint256 pctgNormalizer = 10 ** 12;

    uint256 public startTime;

    //Information associated with a presale contract
    struct PresaleInfo {
        address contractAddress;
        uint256 cliffTime;
        uint256 initialUnlockPctg;
        uint256 vestingMonths;
        uint256 monthlyVestingPctg;
        uint256 pricePerToken;
        uint256 totalClaimed;
        uint256 lastClaimDate;
        uint256 soldTokens;
        uint256 maxTokensPerUser;
        bool enabled;
    }

    PresaleInfo private presaleInfo;

    address private tokenAddress = address(0x16b8dBa442cc9fAa40d0Dd53f698087546CCF096);
    
    mapping (address => bool) private blacklist;

    struct WalletInfo {
        uint256 totalClaimed;
        uint256 lastClaimDate;
    }
    mapping(address => WalletInfo) private walletInfos;


    constructor(address exos) {
        // Initially, vesting is closed
        startTime = MAX_INT;

        tokenAddress = exos;
    }


    /////////////////////
    // OWNER FUNCTIONS //
    /////////////////////

    function setStartTime(uint256 value) external onlyOwner {    
        startTime = value;
    }

    function setTokenAddress(address newAddress) external onlyOwner {
        require(tokenAddress != newAddress, "Vesting: token already has that address.");
        tokenAddress = newAddress;
    }

    function setBlacklisted(address account, bool value) external onlyOwner {
        blacklist[account] = value;
    }

    function setPresaleInfo(
        address contractAddress,
        uint256 cliffTime,
        uint256 initialUnlockPctg,
        uint256 vestingMonths,
        uint256 pricePerToken,
        uint256 totalClaimed,
        uint256 lastClaimDate,
        uint256 soldTokens,
        uint256 maxTokensPerUser,
        bool enabled) external onlyOwner {
        
        presaleInfo.contractAddress = contractAddress;
        presaleInfo.cliffTime = cliffTime;
        presaleInfo.initialUnlockPctg = initialUnlockPctg.mul(pctgNormalizer);
        presaleInfo.vestingMonths = vestingMonths;
        presaleInfo.monthlyVestingPctg = (100 - initialUnlockPctg).mul(pctgNormalizer).div(vestingMonths);
        presaleInfo.pricePerToken = pricePerToken;
        presaleInfo.totalClaimed = totalClaimed;
        presaleInfo.lastClaimDate = lastClaimDate;
        presaleInfo.soldTokens = soldTokens;
        presaleInfo.maxTokensPerUser = maxTokensPerUser;
        presaleInfo.enabled = enabled;
    }

    function getPresaleInfo() external view onlyOwner
        returns (
            address contractAddress,
            uint256 cliffTime,
            uint256 initialUnlockPctg,
            uint256 vestingMonths,
            uint256 monthlyVestingPctg,
            uint256 pricePerToken,
            uint256 totalClaimed,
            uint256 lastClaimDate,
            uint256 soldTokens,
            uint256 maxTokensPerUser,
            bool enabled) {
        
        contractAddress = presaleInfo.contractAddress;
        cliffTime = presaleInfo.cliffTime;
        initialUnlockPctg = presaleInfo.initialUnlockPctg.div(pctgNormalizer);
        vestingMonths = presaleInfo.vestingMonths;
        monthlyVestingPctg = presaleInfo.monthlyVestingPctg.div(pctgNormalizer);
        pricePerToken = presaleInfo.pricePerToken;
        totalClaimed = presaleInfo.totalClaimed;
        lastClaimDate = presaleInfo.lastClaimDate;
        soldTokens = presaleInfo.soldTokens;
        maxTokensPerUser = presaleInfo.maxTokensPerUser;
        enabled = presaleInfo.enabled;
    }

    function setPresaleEnabledStatus(bool value) external onlyOwner {
        presaleInfo.enabled = value;
    }

    ///////////////////////////
    // END - OWNER FUNCTIONS //
    ///////////////////////////


    //////////////////////
    // PUBLIC FUNCTIONS //
    //////////////////////

    function claimTokens() public {
        address sender = msg.sender;

        require(!blacklist[sender], "Wallet is blacklisted");
        require(block.timestamp > startTime, "Tokens are not yet claimable");
        require(presaleInfo.enabled, "Not enabled");

        uint256 claimableTokens = getClaimableTokens(sender);

        if (claimableTokens > 0) {
            // Update wallet info
            walletInfos[sender].totalClaimed = walletInfos[sender].totalClaimed.add(claimableTokens);
            walletInfos[sender].lastClaimDate = block.timestamp;

            // Update presale info
            presaleInfo.totalClaimed = presaleInfo.totalClaimed.add(claimableTokens);
            presaleInfo.lastClaimDate = block.timestamp;

            // Mint the tokens
            IExosToken(tokenAddress).mint(sender, claimableTokens);
        }
    }

    function getWalletInfo() public view returns (uint256 purchasedTokens, uint256 claimableTokens, uint256 totalClaimed, uint256 lastClaimDate, bool isBlacklisted) {
        address sender = msg.sender;

        purchasedTokens = getPurchasedTokens(sender);
        claimableTokens = getClaimableTokens(sender);
        totalClaimed = walletInfos[sender].totalClaimed;
        lastClaimDate = walletInfos[sender].lastClaimDate;
        isBlacklisted = blacklist[sender];
    }

    ////////////////////////////
    // END - PUBLIC FUNCTIONS //
    ////////////////////////////


    ///////////////////////
    // PRIVATE FUNCTIONS //
    ///////////////////////

    function getClaimableTokens(address account) private view returns (uint256) {
        uint256 mintableTokens = 0;
        uint256 claimableTokens = 0;

        if (presaleInfo.enabled) {
            uint256 purchasedTokens = getPurchasedTokens(account);
            if (purchasedTokens > 0) {
                uint256 vestedPctg = getVestedPercentage();
                if (vestedPctg > 0) {
                    mintableTokens = purchasedTokens.mul(vestedPctg).div(100 * pctgNormalizer);
                }
            }
        }

        claimableTokens = mintableTokens.sub(walletInfos[account].totalClaimed);

        require (presaleInfo.totalClaimed.add(claimableTokens) <= presaleInfo.soldTokens, "Cannot mint this amount");
        require (walletInfos[account].totalClaimed.add(claimableTokens) <= presaleInfo.maxTokensPerUser, "Cannot mint this amount");

        return claimableTokens;
    }

    function getPurchasedTokens(address account) private view returns (uint256) {
        uint256 purchasedTokens = 0;

        uint256 presaleContribution = IExosPresale(presaleInfo.contractAddress).getContribution(account);
        if (presaleContribution > 0) {
            purchasedTokens = (presaleContribution.mul(10**18)).div(presaleInfo.pricePerToken);
        }

        return purchasedTokens;
    }
       
    function getVestedPercentage() private view returns (uint256) {
        uint256 vestedPercentage = 0;

        if (block.timestamp > startTime + presaleInfo.cliffTime) {
            vestedPercentage += presaleInfo.initialUnlockPctg;
            uint256 timeVested = block.timestamp - (startTime + presaleInfo.cliffTime);
            uint256 monthsVested = timeVested.div(30 days);
            if (monthsVested > presaleInfo.vestingMonths) {
                monthsVested = presaleInfo.vestingMonths;
            }
            vestedPercentage += monthsVested.mul(presaleInfo.monthlyVestingPctg);
        }

        return vestedPercentage;
    }

    /////////////////////////////
    // END - PRIVATE FUNCTIONS //
    /////////////////////////////
}