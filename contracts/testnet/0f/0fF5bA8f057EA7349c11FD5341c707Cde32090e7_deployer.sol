//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./bnbOnlyLaunch.sol";

contract deployer is Ownable {
    using SafeMath for uint256;

    struct pools {
        address _owner;
        uint256 _createdTime;
    }

    mapping(address => pools) public launchpads;

    uint256 public feeAmount = 1 * 10**17;

    uint256 public bnbFeePercentage = 100;

    uint256 public insuranceFundPercentage = 25;

    event nePoolCreated(address _poolAddress, address _owner);

    constructor() {}

    receive() external payable {}

    function createNewPool(
        uint256[5] memory _poolDetails,
        bool isWhitelisted,
        uint256 publicStartTime,
        address mainToken
    ) public payable returns (address) {
        require(
            msg.value >= feeAmount,
            "Please submit the asking price in order to complete the pool creating"
        );
        payable(address(this)).transfer(feeAmount);

        LaunchpadOnlyBnb newPool;

        newPool = new LaunchpadOnlyBnb(
            msg.sender,
            owner(),
            _poolDetails,
            insuranceFundPercentage,
            bnbFeePercentage,
            isWhitelisted,
            publicStartTime,
            mainToken
        );

        launchpads[address(newPool)]._owner = msg.sender;
        launchpads[address(newPool)]._createdTime = block.timestamp;

        emit nePoolCreated(address(newPool), msg.sender);

        return address(newPool);
    }

    function withdrawBnb() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB);
    }

    function withdrawBep20Tokens(address _token, uint256 percentage)
        public
        onlyOwner
    {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        require(tokenBalance > 0, "No enough tokens in the pool");

        uint256 tokensToTransfer = tokenBalance.mul(percentage).div(100);

        IERC20(_token).transfer(msg.sender, tokensToTransfer);
    }

    function changeFeeAmount(uint256 _feeAmount) public onlyOwner {
        feeAmount = _feeAmount;
    }

    function changeFeePercentages(uint256 _bnbFee, uint256 _insuranceFee)
        public
        onlyOwner
    {
        bnbFeePercentage = _bnbFee;
        insuranceFundPercentage = _insuranceFee;
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LaunchpadOnlyBnb is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct Share {
        uint256 bnbAmount;
        uint256 enrolledAt;
        bool isClaimed;
    }

    IERC20 public tokenAddress;
    IERC20 public mainToken;

    bool public isTokenAddressSet;

    uint256 public tokenPerBnb;

    bool public createdWithToken = false;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public poolCreatedAt;
    uint256 public hardCap;
    uint256 public minimumParticipate;
    uint256 public maximumParticipate;
    uint256 public filledBNB;
    uint256 public remainingBNB;

    uint256 public investorCount;

    address public poolOwner;
    address public poolAdmin;

    uint256 public insuranceFundPercentage;
    uint256 public insuranceFundAmount;

    uint256 public finalizedAt;

    mapping(address => Share) public shares;

    // whitelist Details
    bool public isWhitelisted;
    uint256 public goPublicTime;

    mapping(address => bool) public isWhiteListed;

    address[] public whitelistedUsers;

    /*
    pool status

    0 pending
    1 live
    2 sales ended
    3 canceled
    4 finalized
    **/

    uint256 public poolStatus;

    uint256 private bnbFee;

    event newParticipate(address investor, uint256 bnbAmount);

    event tokensClaim(address investor, uint256 tokensAmount);
    event leavePool(address investor, uint256 bnbAmount);

    // reward related events

    event rewardClaimed(address investor, uint256 amount);

    receive() external payable {}

    constructor(
        address _owner,
        address _admin,
        uint256[5] memory _poolDetails,
        uint256 _insuranceFundPercentage,
        uint256 _bnbFee,
        bool _isWhitelisted,
        uint256 _publicStartTime,
        address _mainToken
    ) {
        mainToken = IERC20(_mainToken);

        startTime = _poolDetails[0];
        endTime = _poolDetails[1];
        hardCap = _poolDetails[2];
        remainingBNB = _poolDetails[2];
        minimumParticipate = _poolDetails[3];
        maximumParticipate = _poolDetails[4];

        bnbFee = _bnbFee;

        poolOwner = _owner;
        poolAdmin = _admin;

        // set whitelist
        isWhitelisted = _isWhitelisted;
        goPublicTime = _publicStartTime;

        insuranceFundPercentage = _insuranceFundPercentage;

        poolStatus = 0;
        poolCreatedAt = block.timestamp;
    }

    function participateToSale(uint256 value) public nonReentrant {
        syncPool();

        require(poolStatus == 1, "Pool not in live");
        if (isWhitelisted) {
            require(
                goPublicTime <= block.timestamp || isWhiteListed[msg.sender],
                "You are not a whitelisted user"
            );
        }
        require(
            shares[msg.sender].bnbAmount.add(value) <= maximumParticipate,
            "You already Reached max participate amount"
        );
        require(
            value >= minimumParticipate &&
                value <= maximumParticipate &&
                value <= remainingBNB,
            "Your Amount is not in minimum and maximum range"
        );

        mainToken.transferFrom(msg.sender, address(this), value);

        filledBNB = filledBNB.add(value);
        remainingBNB = hardCap.sub(filledBNB);

        shares[msg.sender].bnbAmount = shares[msg.sender].bnbAmount.add(value);
        shares[msg.sender].enrolledAt = block.timestamp;
        shares[msg.sender].isClaimed = false;

        investorCount = investorCount.add(1);

        syncPool();

        emit newParticipate(msg.sender, value);
    }

    function claimBnb() public nonReentrant {
        syncPool();
        require(poolStatus == 1 || poolStatus == 3, "Pool not in live");
        require(
            shares[msg.sender].bnbAmount > 0,
            "You do not have bnb in the pool"
        );
        mainToken.transfer(msg.sender, shares[msg.sender].bnbAmount);

        filledBNB = filledBNB.sub(shares[msg.sender].bnbAmount);
        remainingBNB = hardCap.sub(filledBNB);

        emit leavePool(msg.sender, shares[msg.sender].bnbAmount);

        shares[msg.sender].bnbAmount = 0;
        shares[msg.sender].enrolledAt = 0;
        shares[msg.sender].isClaimed = false;

        investorCount = investorCount.sub(1);

        syncPool();
    }

    function claimTokens() public nonReentrant {
        syncPool();
        require(isTokenAddressSet, "No tokens set to this pool");
        require(poolStatus == 4, "Pool not finalized yet");
        require(
            shares[msg.sender].bnbAmount > 0,
            "You do not have bnb in the pool"
        );

        require(
            !shares[msg.sender].isClaimed,
            "You already Claimed your tokens"
        );

        uint256 tokensToUser = tokenPerBnb
            .mul(shares[msg.sender].bnbAmount)
            .div(10**18);

        require(
            tokensToUser <= tokenAddress.balanceOf(address(this)),
            "No enough tokens in the pool"
        );

        tokenAddress.transfer(msg.sender, tokensToUser);

        shares[msg.sender].isClaimed = true;

        emit tokensClaim(msg.sender, tokensToUser);
    }

    function cancelPool() public onlyOwner {
        require(poolStatus != 4, "You can not cancel pool after finalize");
        require(msg.sender == poolAdmin, "Only Pool admin can cancel the pool");

        poolStatus = 3;

        uint256 tokenBalance = tokenAddress.balanceOf(address(this));

        tokenAddress.transfer(poolOwner, tokenBalance);
    }

    function syncPool() public {
        if (poolStatus == 0 && startTime <= block.timestamp) {
            poolStatus = 1;
        }
        if (filledBNB >= hardCap) {
            poolStatus = 2;
        } else if (endTime <= block.timestamp) {
            poolStatus = 2;
        }
    }

    function finalizePool() external nonReentrant {
        require(
            msg.sender == poolOwner,
            "Only pool owner can finalize the pool"
        );
        syncPool();

        require(poolStatus == 2, "You can not finalize the pool at this stage");

        // calculate bnb fee for launch pad

        filledBNB = address(this).balance;

        uint256 bnbFeeForLaunchPad = filledBNB.mul(bnbFee).div(10000);
        uint256 bnbForOwner = filledBNB.sub(bnbFeeForLaunchPad);
        insuranceFundAmount = bnbForOwner.mul(insuranceFundPercentage).div(100);

        mainToken.transfer(address(owner()), bnbFeeForLaunchPad);

        mainToken.transfer(poolOwner, bnbForOwner.sub(insuranceFundAmount));

        finalizedAt = block.timestamp;

        poolStatus = 4;
    }

    function setTokenAddress(address _token, uint256 _tokensPerBnb) public {
        require(
            msg.sender == poolOwner,
            "Only pool owner can finalize the pool"
        );

        tokenAddress = IERC20(_token);
        isTokenAddressSet = true;
        tokenPerBnb = _tokensPerBnb;

        uint256 tokensToDistribute = _tokensPerBnb.mul(filledBNB).div(10**18);

        tokenAddress.transferFrom(
            msg.sender,
            address(this),
            tokensToDistribute
        );
    }

    function releaseInsuranceFund() public {
        require(msg.sender == poolAdmin, "Only Pool admin can release funds");

        payable(poolOwner).transfer(insuranceFundAmount);
    }

    function takeInsuranceFund() public {
        require(msg.sender == poolAdmin, "Only Pool admin can release funds");

        payable(msg.sender).transfer(insuranceFundAmount);
    }

    function whiteListUsers(address[] memory _wallets) public {
        require(msg.sender == poolOwner, "Only pool owner can whitelist users");

        require(
            _wallets.length <= 15,
            "you can white list maximum 15 wallets at a time"
        );

        for (uint256 i = 0; i < _wallets.length; i++) {
            isWhiteListed[_wallets[i]] = true;
            whitelistedUsers.push(_wallets[i]);
        }
    }

    function getWhiteListedUsers() public view returns (address[] memory) {
        return whitelistedUsers;
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
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