// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BUSDVYNCSTAKE {
    using SafeMath for uint256;

    uint256 public apr = 2;
    uint256 public compoundRate= 180;

    struct userInfoData {
        uint256 amount;
        uint256 balance;
        uint256 lastClaimedReward;
        uint256 lastClaimTimestamp;
        bool isStaker;
        uint256 totalClaimedReward;
        uint256 autoClaimWithStake;
    }

    IERC20 public vync = IERC20(0x15b3aC7c92a12231Dbcd95bb7bF117B26804e010);
    IERC20 public busd = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    IUniswapV2Router02 public router =
        IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    IUniswapV2Factory public factory =
        IUniswapV2Factory(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc);

    uint256 public constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    mapping(address => userInfoData) public userInfo;

    uint256 public totalSupply;

    event rewardSent(address indexed user, uint256 rewards);

    function approve() public {
        vync.approve(address(router), MAX_INT);
        busd.approve(address(router), MAX_INT);
        getSwappingPair().approve(address(router), MAX_INT);
    }

    function setApr(uint256 _apr) public {
        apr = _apr;
    }

    function setCompoundRate(uint256 _compoundRate) public{
        compoundRate= _compoundRate;
    }

    function stake(uint256 amount) external {

        busd.transferFrom(msg.sender, address(this), amount);

        // if(userInfo[msg.sender].isStaker == true && pendingReward(msg.sender)> 0){
        //     //uint256 busdOut= swapVyncToBusd(pendingReward(msg.sender));
        //     uint busdOut= pendingReward(msg.sender); // only for testing
        //     amount= amount+busdOut;
        //     userInfo[msg.sender].totalClaimedReward= userInfo[msg.sender].totalClaimedReward+pendingReward(msg.sender);
        //     userInfo[msg.sender].lastClaimedReward= pendingReward(msg.sender);
        // }

        if(userInfo[msg.sender].isStaker == true && pendingReward(msg.sender)> 0){
            uint256 _pendingReward= pendingReward(msg.sender);
            userInfo[msg.sender].balance= userInfo[msg.sender].balance+ _pendingReward;
            userInfo[msg.sender].totalClaimedReward= userInfo[msg.sender].totalClaimedReward+ _pendingReward;
            userInfo[msg.sender].autoClaimWithStake= userInfo[msg.sender].autoClaimWithStake + _pendingReward;

        }

        (, uint256 res1, ) = getSwappingPair().getReserves();
        uint256 amountToSwap = calculateSwapInAmount(res1, amount);

        uint256 vyncOut = swapBusdToVync(amountToSwap);
        uint256 amountLeft = amount.sub(amountToSwap);

        (, uint256 busdAdded, uint256 liquidityAmount) = router.addLiquidity(
            address(vync),
            address(busd),
            vyncOut,
            amountLeft,
            0,
            0,
            address(this),
            block.timestamp
        );

        //update state
        userInfo[msg.sender].amount = userInfo[msg.sender].amount.add(
            liquidityAmount
        );
        totalSupply = totalSupply.add(liquidityAmount);
        userInfo[msg.sender].balance = userInfo[msg.sender].balance + (busdAdded + amountToSwap);
        userInfo[msg.sender].lastClaimTimestamp = block.timestamp;
        userInfo[msg.sender].isStaker= true;

        // trasnfer back amount left
        if (amount > busdAdded + amountToSwap) {
            busd.transfer(msg.sender, amount - (busdAdded + amountToSwap));
        }
    }

    function unStake(uint256 amount) external {
        uint256 lpAmountNeeded;
        if (amount >= balanceOf(msg.sender)) {
            // withdraw all
            lpAmountNeeded = userInfo[msg.sender].amount;
        } else {
            //calculate LP needed that corresponding with amount
            lpAmountNeeded = getLPTokenByAmount1(amount);
            if (lpAmountNeeded >= userInfo[msg.sender].amount) {
                // if >= current lp, use all lp
                lpAmountNeeded = userInfo[msg.sender].amount;
            }
        }

        require(
            userInfo[msg.sender].amount >= lpAmountNeeded,
            "withdraw: not good"
        );
        //remove liquidity
        (uint256 amountVync, uint256 amountBusd) = removeLiquidity(
            lpAmountNeeded
        );
        
        uint256 _amount= swapVyncToBusd(amountVync).add(amountBusd);

        busd.transfer( msg.sender,_amount);

        // update state

        uint256 percentOfunstake= (_amount*100)/userInfo[msg.sender].balance;
        userInfo[msg.sender].totalClaimedReward= userInfo[msg.sender].totalClaimedReward - (userInfo[msg.sender].totalClaimedReward*percentOfunstake)/100;

        userInfo[msg.sender].amount = userInfo[msg.sender].amount.sub(
            lpAmountNeeded
        );
        userInfo[msg.sender].balance = userInfo[msg.sender].balance.sub(_amount);

        if(userInfo[msg.sender].amount == 0){
            userInfo[msg.sender].balance=0;
            userInfo[msg.sender].isStaker= false;
        }
        totalSupply = totalSupply.sub(lpAmountNeeded);
    }

    function pendingReward(address user)
        public
        view
        returns (uint256 totalReward)
    {
        if(userInfo[msg.sender].isStaker == true){
        uint256 compoundTime= block.timestamp - userInfo[user].lastClaimTimestamp;
        uint256 loopRound = compoundTime/compoundRate;
        uint256 reward = 0;
        uint256 balance = userInfo[user].balance;
        totalReward=0;

        for (uint256 i = 1; i <= loopRound; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(apr)).div(100);
            totalReward = totalReward.add(reward);
            balance = amount;
        }
        if(totalReward!=0){
        totalReward= totalReward-userInfo[user].totalClaimedReward+userInfo[msg.sender].autoClaimWithStake;
        }
        if(totalReward==0){
            totalReward=0;
        }
        }
    }

    function rewardCalculation(address user) internal {
        uint256 compoundTime= block.timestamp- userInfo[user].lastClaimTimestamp;
        uint256 loopRound = compoundTime/compoundRate;
        uint256 reward;
        uint256 totalReward;
        uint256 balance = userInfo[user].balance;

        for (uint256 i = 1; i <= loopRound; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(apr)).div(100);
            totalReward = totalReward.add(reward);
            balance = amount;
        }

        
        userInfo[user].lastClaimedReward= totalReward- userInfo[user].totalClaimedReward;
        userInfo[user].totalClaimedReward = userInfo[user].totalClaimedReward + userInfo[user].lastClaimedReward;
        
    }

    function claim() public {
        require(userInfo[msg.sender].isStaker == true,"user not staked");

        uint256 compoundTime= block.timestamp - userInfo[msg.sender].lastClaimTimestamp;
        require(compoundTime >= compoundRate,"wait for next compound"); //86400

        rewardCalculation(msg.sender);
        uint256 reward = userInfo[msg.sender].lastClaimedReward+userInfo[msg.sender].autoClaimWithStake;
        require(vync.balanceOf(address(this)) >= reward,"reward token not available into contract");
        vync.transfer(msg.sender, reward);
        emit rewardSent(msg.sender, reward);
        userInfo[msg.sender].autoClaimWithStake=0;
        userInfo[msg.sender].lastClaimTimestamp= block.timestamp;
    }

    function getSwappingPair() internal view returns (IUniswapV2Pair) {
        return IUniswapV2Pair(factory.getPair(address(vync), address(busd)));
    }

    // following: https://blog.alphafinance.io/onesideduniswap/ zzb 
    // applying f = 0.25% in PancakeSwap
    // we got these numbers

    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
        internal
        pure
        returns (uint256) 
    {
        return
            sqrt(
                reserveIn.mul(userIn.mul(399000000) + reserveIn.mul(399000625))
            ).sub(reserveIn.mul(19975)) / 19950;
    }

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
        // else z = 0
    }

    function swapBusdToVync(uint256 amountToSwap)
        internal
        returns (uint256 amountOut)
    {
        uint256 vyncBalanceBefore = vync.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            getBusdVyncRoute(),
            address(this),
            block.timestamp
        );
        amountOut = vync.balanceOf(address(this)).sub(vyncBalanceBefore);
    }

    function swapVyncToBusd(uint256 amountToSwap)
        internal
        returns (uint256 amountOut)
    {
        uint256 busdBalanceBefore = busd.balanceOf(address(this)); // remove for testing
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            getVyncBusdRoute(),
            address(this),
            block.timestamp
        );
        amountOut = busd.balanceOf(address(this)).sub(busdBalanceBefore);
    }

    function getBusdVyncRoute() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(busd);
        paths[1] = address(vync);
    }

    function getVyncBusdRoute() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(vync);
        paths[1] = address(busd);
    }

    function getReserveInAmount1ByLP(uint256 lp)
        public
        view
        returns (uint256 amount)
    {
        IUniswapV2Pair pair = getSwappingPair();
        uint256 balance0 = vync.balanceOf(address(pair));
        uint256 balance1 = busd.balanceOf(address(pair));
        uint256 _totalSupply = pair.totalSupply();
        uint256 amount0 = lp.mul(balance0) / _totalSupply;
        uint256 amount1 = lp.mul(balance1) / _totalSupply;
        // convert amount0 -> amount1
        amount = amount1.add(amount0.mul(balance1).div(balance0));
    }

    function balanceOf(address user) public view returns (uint256) {
        return getReserveInAmount1ByLP(userInfo[user].amount);
    }

    function getLPTokenByAmount1(uint256 amount)
        internal
        view
        returns (uint256 lpNeeded)
    {
        (, uint256 res1, ) = getSwappingPair().getReserves();
        lpNeeded = amount.mul(getSwappingPair().totalSupply()).div(res1).div(2);
    }

    function removeLiquidity(uint256 lpAmount)
        internal
        returns (uint256 amountVync, uint256 amountBusd)
    {
        uint256 vyncBalanceBefore = vync.balanceOf(address(this));
        (, amountBusd) = router.removeLiquidity(
            address(vync),
            address(busd),
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        amountVync = vync.balanceOf(address(this)).sub(vyncBalanceBefore);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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