//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./priceCalculate.sol";

contract Referral is Ownable {
    using SafeMath for uint256;

    IERC20 public tokenAddress;
    IERC20 public rewardToken;

    mapping(address => address) public referees;

    struct Rewards {
        uint256 totalRewards;
        uint256 claimedRewards;
        uint256 lastClaimedTime;
        uint256 lastClaimedAmount;
        address lastRewardFrom;
        uint256 lastRewardAmount;
        uint256 referralCount;
        uint256 totalTrades;
    }

    struct RefereeRewards {
        uint256 totalRewards;
        uint256 claimedRewards;
        uint256 lastClaimedTime;
        uint256 lastClaimedAmount;
    }

    mapping(address => Rewards) public rewards;
    mapping(address => RefereeRewards) public refereeRewards;

    mapping(address => address[]) public referrals;

    PriceCalculator private priceCalculator;

    uint256 public referrerLevel1Fee;
    uint256 public referrerLevel2Fee;
    uint256 public referrerLevel3Fee;

    // total comiision earned

    uint256 public totalCommissionEarned;
    // total active
    uint256 public totalReferrals;
    // total trade
    uint256 public totalTrades;

    uint256 public topReferBonus;

    uint256 public refereeFee;

    uint256 public referrerClaimThreshold = 50 * 10**18;
    uint256 public refereeClaimThreshold = 50 * 10**18;

    modifier onlyToken() {
        require(msg.sender == address(tokenAddress));
        _;
    }

    constructor(
        uint256 _referrer1Fee,
        uint256 _referrer2Fee,
        uint256 _referrer3Fee,
        uint256 _refereeFee,
        address _tokenAddress
    ) {
        referrerLevel1Fee = _referrer1Fee;
        referrerLevel2Fee = _referrer2Fee;
        referrerLevel3Fee = _referrer3Fee;
        refereeFee = _refereeFee;

        tokenAddress = IERC20(_tokenAddress);

        rewardToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        priceCalculator = new PriceCalculator();
    }

    receive() external payable {}

    function setReferees(address _referee) public {
        require(
            _referee != msg.sender,
            "you can not add yourself as a referrer"
        );
        require(
            referees[msg.sender] == address(0),
            "you already have a referral"
        );
        referees[msg.sender] = _referee;
        referrals[_referee].push(msg.sender);
        rewards[_referee].referralCount++;
        totalReferrals++;
    }

    function setReferValue(uint256 amount, address _referee) public onlyToken {
        address refer1 = referees[_referee];
        // calculate tokens amount in usd
        uint256 userTokenValue = priceCalculator.getLatestPrice(
            address(tokenAddress),
            amount
        );
        totalTrades = totalTrades.add(userTokenValue);

        if (refer1 != address(0)) {
            // calculate reward percentage
            uint256 level1Fee = userTokenValue.mul(referrerLevel1Fee).div(
                10000
            );

            if (level1Fee > topReferBonus) {
                topReferBonus = level1Fee;
            }

            totalCommissionEarned = totalCommissionEarned.add(level1Fee);

            rewards[refer1].totalTrades = userTokenValue.add(
                rewards[refer1].totalTrades
            );

            rewards[refer1].totalRewards = level1Fee.add(
                rewards[refer1].totalRewards
            );

            // set last reward amount
            rewards[refer1].lastRewardAmount = level1Fee;
            // set last reward from
            rewards[refer1].lastRewardFrom = _referee;

            // check level 2
            address refer2 = referees[refer1];
            if (refer2 != address(0)) {
                // calculate reward percentage
                uint256 level2Fee = userTokenValue.mul(referrerLevel2Fee).div(
                    10000
                );

                totalCommissionEarned = totalCommissionEarned.add(level2Fee);

                rewards[refer2].totalRewards = level2Fee.add(
                    rewards[refer2].totalRewards
                );
                rewards[refer2].totalTrades = userTokenValue.add(
                    rewards[refer1].totalTrades
                );
                // set last reward amount
                rewards[refer2].lastRewardAmount = level2Fee;
                // set last reward from
                rewards[refer2].lastRewardFrom = _referee;

                // check level 3
                address refer3 = referees[refer2];
                if (refer3 != address(0)) {
                    // calculate reward percentage
                    uint256 level3Fee = userTokenValue
                        .mul(referrerLevel3Fee)
                        .div(10000);

                    rewards[refer3].totalTrades = userTokenValue.add(
                        rewards[refer1].totalTrades
                    );
                    totalCommissionEarned = totalCommissionEarned.add(
                        level3Fee
                    );
                    rewards[refer3].totalRewards = level3Fee.add(
                        rewards[refer3].totalRewards
                    );

                    // set last reward amount
                    rewards[refer3].lastRewardAmount = level3Fee;
                    // set last reward from
                    rewards[refer3].lastRewardFrom = _referee;
                }
            }

            // calculate referee rewards percentage
            uint256 _refereeFee = userTokenValue.mul(refereeFee).div(10000);

            totalCommissionEarned = totalCommissionEarned.add(_refereeFee);
            // set rewards to referee
            refereeRewards[_referee].totalRewards = _refereeFee.add(
                refereeRewards[_referee].totalRewards
            );
        }
    }

    // claim referrer rewards

    function claimReferrerRewards() public {
        // calculate claimable rewards

        uint256 claimableRewards = rewards[msg.sender].totalRewards.sub(
            rewards[msg.sender].claimedRewards
        );

        require(
            claimableRewards >= referrerClaimThreshold,
            "You have not reached to minimum threshold"
        );

        rewards[msg.sender].lastClaimedTime = block.timestamp;
        rewards[msg.sender].lastClaimedAmount = claimableRewards;
        rewards[msg.sender].claimedRewards = claimableRewards.add(
            rewards[msg.sender].claimedRewards
        );

        require(
            rewardToken.balanceOf(address(this)) >= claimableRewards,
            "Pool doesn't have enough reward tokens"
        );

        rewardToken.transfer(msg.sender, claimableRewards);
    }

    //claim referee rewards
    function claimRefereeRewards() public {
        // calculate claimable rewards

        uint256 claimableRewards = refereeRewards[msg.sender].totalRewards.sub(
            refereeRewards[msg.sender].claimedRewards
        );

        require(
            claimableRewards >= refereeClaimThreshold,
            "You have not reached to minimum threshold"
        );

        refereeRewards[msg.sender].lastClaimedTime = block.timestamp;
        refereeRewards[msg.sender].lastClaimedAmount = claimableRewards;
        refereeRewards[msg.sender].claimedRewards = claimableRewards.add(
            refereeRewards[msg.sender].claimedRewards
        );

        require(
            rewardToken.balanceOf(address(this)) >= claimableRewards,
            "Pool doesn't have enough reward tokens"
        );

        rewardToken.transfer(msg.sender, claimableRewards);
    }

    // set claim threshold
    function setClaimThreshold(uint256 _referee, uint256 _referrer)
        public
        onlyOwner
    {
        referrerClaimThreshold = _referrer * 10**18;
        refereeClaimThreshold = _referee * 10**18;
    }

    // set referrer level percentages
    function setLevelPercentages(
        uint256 _level1,
        uint256 _level2,
        uint256 _level3,
        uint256 _referee
    ) public onlyOwner {
        referrerLevel1Fee = _level1;
        referrerLevel2Fee = _level2;
        referrerLevel3Fee = _level3;

        refereeFee = _referee;
    }

    function myReferrals(address _wallet)
        public
        view
        returns (address[] memory)
    {
        return referrals[_wallet];
    }
}

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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PriceCalculator {
    using SafeMath for uint256;

    IUniswapV2Router02 public router;

    address bnb;

    // address usdt;

    constructor() {
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        bnb = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        // usdt = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    }

    function getLatestPrice(address _tokenAddress, uint256 _tokenAmount)
        public
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = bnb;

        // get token price in bnb
        uint256[] memory amounts = router.getAmountsOut(_tokenAmount, path);

        return amounts[1];
    }

    // function getBnbPrice(uint256 _amount) internal returns (uint256) {
    //     address[] memory path = new address[](2);
    //     path[0] = bnb;
    //     path[1] = usdt;

    //     uint256[] memory amounts = router.getAmountsOut(_amount, path);

    //     return amounts[1];
    // }
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