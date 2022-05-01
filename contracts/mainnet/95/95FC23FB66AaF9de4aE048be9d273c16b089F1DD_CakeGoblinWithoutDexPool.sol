// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./abstract/AGoblinWithoutDexPool.sol";
import "./interface/Pancake/IPancakeRouter02.sol";
import "./interface/Pancake/IMasterChef.sol";
import "./utils/SafeToken.sol";
import "./utils/Math.sol";


contract CakeGoblinWithoutDexPool is AGoblinWithoutDexPool {
    /// @notice Libraries
    using SafeToken for address;
    using SafeMath for uint256;

    constructor(
        address _operator,              // Bank
        address _farm,                  // Farm
        uint256 _poolId,                // Farm pool id
        address _router,
        address _cake,
        address _token0,
        address _token1,
        address _liqStrategy
    ) public AGoblinWithoutDexPool(_operator, _farm, _poolId, 
                _router, _cake, _token0, _token1, _liqStrategy) {}

    /* ==================================== Internal ==================================== */

    function _WBNB(address _router) internal view override returns (address) {
        return IPancakeRouter02(_router).WETH();
    }

    /**
     * @dev Return maximum output given the input amount and the status of Uniswap reserves.
     * @param aIn The amount of asset to market sell.
     * @param rIn the amount of asset in reserve for input.
     * @param rOut The amount of asset in reserve for output.
     */
    function _getMktSellAmount(uint256 aIn, uint256 rIn, uint256 rOut) internal pure override returns (uint256) {
        if (aIn == 0) return 0;
        require(rIn > 0 && rOut > 0, "bad reserve values");
        uint256 aInWithFee = aIn.mul(9975);
        uint256 numerator = aInWithFee.mul(rOut);
        uint256 denominator = rIn.mul(10000).add(aInWithFee);
        return numerator.div(denominator);
    }

    /**
     * @dev Return minmum input given the output amount and the status of Uniswap reserves.
     * @param aOut The output amount of asset after market sell.
     * @param rIn the amount of asset in reserve for input.
     * @param rOut The amount of asset in reserve for output.
     */
    function _getMktSellInAmount(uint256 aOut, uint256 rIn, uint256 rOut) internal pure override returns (uint256) {
        if (aOut == 0) return 0;
        require(rIn > 0, "Get sell in amount, rIn must > 0");
        require(rOut > aOut, "Get sell in amount, rOut must > aOut");
        uint256 numerator = rIn.mul(aOut).mul(10000);
        uint256 denominator = rOut.sub(aOut).mul(9975);
        return numerator.div(denominator);
    }

    /**
     * @dev Swap A to B with the input debts ratio
     * @notice na/da should lager than nb/db
     *
     * @param ra Reserved token A in LP pair.
     * @param rb Reserved token B in LP pair.
     * @param da Debts of token A.
     * @param db Debts of token B.
     * @param na Current available balance of token A.
     * @param nb Current available balance of token B.
     *
     * @return uint256 How many A should be swaped to B.
     */
    function _swapAToBWithDebtsRatio(
        uint256 ra,
        uint256 rb,
        uint256 da,
        uint256 db,
        uint256 na,
        uint256 nb
    ) internal pure override returns (uint256) {
        // This can also help to make sure db != 0
        require(na.mul(db) > nb.mul(da), "na/da should lager than nb/db");

        if (da == 0) {
            return na;
        }

        uint256 part1 = na.sub(nb.mul(da).div(db));
        uint256 part2 = ra.mul(10000).div(9975);
        uint256 part3 = da.mul(rb).div(db);

        uint256 b = part2.add(part3).sub(part1);
        uint256 nc = part1.mul(part2);

        // (-b + math.sqrt(b * b + 4 * nc)) / 2
        // Note that nc = - c
        return Math.sqrt(b.mul(b).add(nc.mul(4))).sub(b).div(2);
    }

}

// SPDX-License-Identifier: MIT
// Goblin without dex farm pool
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./../interface/IRouter.sol";
import "./../interface/IFactory.sol";
import "./../interface/IPair.sol";

import "./../interface/IFarm.sol";
import "./../interface/IGoblin.sol";
import "./../interface/IStrategy.sol";

import "./../utils/SafeToken.sol";
import "./../utils/Math.sol";

abstract contract AGoblinWithoutDexPool is Ownable, ReentrancyGuard, IGoblin {
    /// @notice Libraries
    using SafeToken for address;
    using SafeMath for uint256;

    /// @notice Events
    event AddPosition(uint256 indexed id, uint256 lpAmount);
    event RemovePosition(uint256 indexed id, uint256 lpAmount);
    event Liquidate(uint256 indexed id, address lpTokenAddress, uint256 lpAmount,
        address[2] debtToken, uint256[2] liqAmount);

    /// @notice Immutable variables
    IFarm public farm;
    uint256 public poolId;

    address dexPool;
    uint256 dexPoolId;

    IPair public lpToken;
    address public dexToken;
    address public wBNB;
    address public token0;      // lpToken.token0(), Won't be 0
    address public token1;      // lpToken.token1(), Won't be 0
    address public operator;    // Bank

    /// @notice Mutable state variables
    uint256 private globalLp;
    mapping(address => uint256) private userLp;
    mapping(uint256 => uint256) public override posLPAmount;

    // Principal of each tokens in each pos. Same order with borrow tokens
    mapping(uint256 => uint256[2]) public principal;
    mapping(address => bool) public strategiesOk;
    IStrategy public liqStrategy;

    /// @notice temp params
    struct TempParams {
        uint256 beforeLPPosAmount;
        uint256 afterLPAmount;
        uint256 deltaAmount;
    }

    constructor(
        address _operator,              // Bank
        address _farm,                  // Farm
        uint256 _poolId,                // Farm pool id
        address _router,
        address _dexToken,
        address _token0,
        address _token1,
        address _liqStrategy
    ) public {
        operator = _operator;
        farm = IFarm(_farm);
        poolId  = _poolId;

        // DexToken related params.
        dexToken = _dexToken;
        IFactory factory = IFactory(IRouter(_router).factory());

        wBNB = _WBNB(_router);
        _token0 = _token0 == address(0) ? wBNB : _token0;
        _token1 = _token1 == address(0) ? wBNB : _token1;

        lpToken = IPair(factory.getPair(_token0, _token1));
        require(address(lpToken) != address(0), 'Pair not exit');
        // May switch the order of tokens
        token0 = lpToken.token0();
        token1 = lpToken.token1();

        liqStrategy = IStrategy(_liqStrategy);
        strategiesOk[_liqStrategy] = true;

    }

    /// @dev Require that the caller must be the operator (the bank).
    modifier onlyOperator() {
        require(msg.sender == operator, "not operator");
        _;
    }

    /* ==================================== Read ==================================== */

    /// @dev Keep interface same with AGoblin
    function globalInfo() external view returns (        
        uint256 totalLp,
        uint256 totalDexToken,      // Don't need
        uint256 accDexTokenPerLp,   // Don't need
        uint256 lastUpdateTime      // Don't need
    ) {
        totalLp = globalLp;
        totalDexToken = 0;
        accDexTokenPerLp = 0;
        lastUpdateTime = 0;
    }

    /// @dev Keep interface same with AGoblin
    function userInfo(address user) external view returns (
        uint256 totalLp,
        uint256 earnedDexTokenStored,   // Don't need
        uint256 accDexTokenPerLpStored, // Don't need
        uint256 lastUpdateTime          // Don't need
    ) {
        totalLp = userLp[user];
        earnedDexTokenStored = 0;
        accDexTokenPerLpStored = 0;
        lastUpdateTime = 0;
    }
    /**
     * @dev Return the amount of each borrow token can be withdrawn with the given borrow amount rate.
     * @param id The position ID to perform health check.
     * @param borrowTokens Address of two tokens this position had debts.
     * @param debts Debts of two tokens.
     */
    function health(
        uint256 id,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts
    ) external view override returns (uint256[2] memory) {

        require(borrowTokens[0] == token0 ||
                borrowTokens[0] == token1 ||
                borrowTokens[0] == address(0), "borrowTokens[0] not token0 and token1");

        require(borrowTokens[1] == token0 ||
                borrowTokens[1] == token1 ||
                borrowTokens[1] == address(0), "borrowTokens[1] not token0 and token1");

        // 1. Get the position's LP balance and LP total supply.
        uint256 lpBalance = posLPAmount[id];
        uint256 lpSupply = lpToken.totalSupply();
        // Ignore pending mintFee as it is insignificant

        // 2. Get the pool's total supply of token0 and token1.
        (uint256 ra, uint256 rb,) = lpToken.getReserves();

        if (borrowTokens[0] == token1 ||
            (borrowTokens[0] == address(0) && token1 == wBNB))
        {
            // If reverse
            (ra, rb) = (rb, ra);
        }
        // 3. Convert the position's LP tokens to the underlying assets.
        uint256 na = lpBalance.mul(ra).div(lpSupply);
        uint256 nb = lpBalance.mul(rb).div(lpSupply);
        ra = ra.sub(na);
        rb = rb.sub(nb);

        // 4. Get the amount after swaped
        uint256 da = debts[0];
        uint256 db = debts[1];

        // na/da > nb/db, swap A to B
        if (na.mul(db) > nb.mul(da).add(1e25)) {
            uint256 amount = _swapAToBWithDebtsRatio(ra, rb, da, db, na, nb);
            amount = amount > na ? na : amount;
            na = na.sub(amount);
            nb = nb.add(_getMktSellAmount(amount, ra, rb));
        }

        // na/da < nb/db, swap B to A
        else if (na.mul(db).add(1e25) < nb.mul(da)) {
            uint256 amount = _swapAToBWithDebtsRatio(rb, ra, db, da, nb, na);
            amount = amount > nb ? nb : amount;
            na = na.add(_getMktSellAmount(amount, rb, ra));
            nb = nb.sub(amount);
        }

        // 5. Return the amount after swaping according to the debts ratio
        return [na, nb];
    }

    /**
     * @dev Return the left rate of the principal. need to divide to 10000, 100 means 1%
     * @param id The position ID to perform loss rate check.
     * @param borrowTokens Address of two tokens this position had debt.
     * @param debts Debts of two tokens.
     */
    function newHealth(
        uint256 id,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts
    ) external view override returns (uint256) {

        require(borrowTokens[0] == token0 ||
                borrowTokens[0] == token1 ||
                borrowTokens[0] == address(0), "borrowTokens[0] not token0 and token1");

        require(borrowTokens[1] == token0 ||
                borrowTokens[1] == token1 ||
                borrowTokens[1] == address(0), "borrowTokens[1] not token0 and token1");

        uint256[2] storage N = principal[id];

        if (N[0] > 0 || N[1] > 0) {
            // Get the position's LP balance and LP total supply.
            uint256 lpBalance = posLPAmount[id];
            uint256 lpSupply = lpToken.totalSupply();
            // Ignore pending mintFee as it is insignificant

            // 2. Get the pool's total supply of token0 and token1.
            (uint256 ra, uint256 rb,) = lpToken.getReserves();

            if (borrowTokens[0] == token1 ||
                (borrowTokens[0] == address(0) && token1 == wBNB))
            {
                // If reverse
                (ra, rb) = (rb, ra);
            }
            // 3. Convert the position's LP tokens to the underlying assets.
            uint256 na = lpBalance.mul(ra).div(lpSupply);
            uint256 nb = lpBalance.mul(rb).div(lpSupply);
            ra = ra.sub(na);
            rb = rb.sub(nb);

            // 4. Get the health
            if (N[0] > 0) {
                // token 0 is the standard coin.
                uint256 leftA = _repayDeptsAndSwapLeftToA(ra, rb, debts[0], debts[1], na, nb);
                return leftA.mul(10000).div(N[0]);
            } else {
                // token 1 is the standard coin.
                uint256 leftB = _repayDeptsAndSwapLeftToA(rb, ra, debts[1], debts[0], nb, na);
                return leftB.mul(10000).div(N[1]);
            }
        } else {
            // No principal, treat it as no loss.
            return uint256(10000);
        }
    }

    /// @return Earned DEMA amount.
    function userAmount(address account) public view override returns (uint256, uint256) {

        return (0, // Dex token earned amount
                farm.stakeEarnedPerPool(poolId, account));
    }

    /* ==================================== Write ==================================== */

    /// @dev Send DEMA rewards to user.
    function getAllRewards(address account) external override nonReentrant {
        farm.getStakeRewardsPerPool(poolId, account);
    }


    /**
     * @dev Work on the given position. Must be called by the operator.
     * @param id The position ID to work on.
     * @param account The original user that is interacting with the operator.
     * @param borrowTokens Address of two tokens user borrow from bank.
     * @param borrowAmount The amount of two borrow tokens.
     * @param debts The user's debts amount of two tokens.
     * @param data The encoded data, consisting of strategy address and bytes to strategy.
     */
    function work(
        uint256 id,
        address account,
        address[2] calldata borrowTokens,
        uint256[2] calldata borrowAmount,
        uint256[2] calldata debts,
        bytes calldata data
    )
        external
        payable
        override
        onlyOperator
        nonReentrant
    {
        require(borrowTokens[0] != borrowTokens[1]);
        require(borrowTokens[0] == token0 || borrowTokens[0] == token1 || borrowTokens[0] == address(0), "borrowTokens not token0 and token1");
        require(borrowTokens[1] == token0 || borrowTokens[1] == token1 || borrowTokens[1] == address(0), "borrowTokens not token0 and token1");

        TempParams memory temp;     // Just in case stack too deep.
        // 1. Convert this position back to LP tokens.
        temp.beforeLPPosAmount = posLPAmount[id];
        _removePosition(id, account);

        // 2. Perform the worker strategy; sending LP tokens + borrowTokens; expecting LP tokens.
        (address strategy, bytes memory ext) = abi.decode(data, (address, bytes));
        require(strategiesOk[strategy], "unapproved work strategy");

        if (temp.beforeLPPosAmount > 0) {
            lpToken.transfer(strategy, temp.beforeLPPosAmount);
        }

        for (uint256 i = 0; i < 2; ++i) {
            // transfer the borrow token.
            if (borrowAmount[i] > 0 && borrowTokens[i] != address(0)) {
                borrowTokens[i].safeTransferFrom(msg.sender, address(this), borrowAmount[i]);

                borrowTokens[i].safeApprove(address(strategy), 0);
                borrowTokens[i].safeApprove(address(strategy), uint256(-1));
            }
        }

        // -------------------------- execute --------------------------
        // strategy will send back all token and LP.
        uint256[2] memory deltaN = IStrategy(strategy).execute{value: msg.value}(
            account, borrowTokens, borrowAmount, debts, ext);

        _addPosition(id, account);

        // Handle stake reward.
        temp.afterLPAmount = posLPAmount[id];

        // 4. Update stored info after withdraw or deposit.

        // If withdraw some LP.
        if (temp.beforeLPPosAmount > temp.afterLPAmount) {
            temp.deltaAmount = temp.beforeLPPosAmount.sub(temp.afterLPAmount);
            farm.withdraw(poolId, account, temp.deltaAmount);

            (/* token0 */, /* token1 */, uint256 rate, uint256 whichWantBack) =
                abi.decode(ext, (address, address, uint256, uint256));

            // If it is repay, don't update principle.
            if (whichWantBack < 3) {
                _updatePrinciple(id, true, borrowTokens, deltaN, rate);
            }
        }
        // If depoist some LP.
        else if (temp.beforeLPPosAmount < temp.afterLPAmount) {
            temp.deltaAmount = temp.afterLPAmount.sub(temp.beforeLPPosAmount);
            farm.stake(poolId, account, temp.deltaAmount);
            _updatePrinciple(id, false, borrowTokens, deltaN, temp.deltaAmount);
        }

        // 5. Send tokens back.
        for (uint256 i = 0; i < 2; ++i) {
            if (borrowTokens[i] == address(0)) {
                uint256 borrowTokenAmount = address(this).balance;
                if (borrowTokenAmount > 0) {
                    SafeToken.safeTransferETH(msg.sender, borrowTokenAmount);
                }
            } else {
                uint256 borrowTokenAmount = borrowTokens[i].myBalance();
                if(borrowTokenAmount > 0) {
                    SafeToken.safeTransfer(borrowTokens[i], msg.sender, borrowTokenAmount);
                }
            }
        }
    }

    /**
     * @dev Liquidate the given position by converting it to debtToken and return back to caller.
     * @param id The position ID to perform liquidation.
     * @param account The address than this position belong to.
     * @param borrowTokens Two tokens address user borrow from bank.
     * @param debts Two tokens debts.
     */
    function liquidate(
        uint256 id,
        address account,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts
    )
        external
        override
        onlyOperator
        nonReentrant
    {
        require(borrowTokens[0] == token0 ||
                borrowTokens[0] == token1 ||
                borrowTokens[0] == address(0), "borrowTokens[0] not token0 and token1");

        require(borrowTokens[1] == token0 ||
                borrowTokens[1] == token1 ||
                borrowTokens[1] == address(0), "borrowTokens[1] not token0 and token1");


        // 1. Convert the position back to LP tokens and use liquidate strategy.
        farm.withdraw(poolId, account, posLPAmount[id]);
        uint256 lpTokenAmount = posLPAmount[id];
        _removePosition(id, account);
        lpToken.transfer(address(liqStrategy), lpTokenAmount);

        // address token0, address token1, uint256 rate, uint256 whichWantBack
        liqStrategy.execute(address(this), borrowTokens, uint256[2]([uint256(0), uint256(0)]), debts, abi.encode(
            lpToken.token0(), lpToken.token1(), 10000, 2));



        // 2. transfer borrowTokens and user want back to bank.
        uint256[2] memory tokensLiquidate;
        for (uint256 i = 0; i < 2; ++i) {
            if (borrowTokens[i] == address(0)) {
                tokensLiquidate[i] = address(this).balance;
                if (tokensLiquidate[i] > 0) {
                    SafeToken.safeTransferETH(msg.sender, tokensLiquidate[i]);
                }
            } else {
                tokensLiquidate[i] = borrowTokens[i].myBalance();
                if (tokensLiquidate[i] > 0) {
                    borrowTokens[i].safeTransfer(msg.sender, tokensLiquidate[i]);
                }
            }

            // Clear principal
            principal[id][i] = 0;
        }

        emit Liquidate(id, address(lpToken), lpTokenAmount, borrowTokens, tokensLiquidate);
    }

    /* ==================================== Internal ==================================== */

    // ------------------ The following are virtual function ------------------

    function _WBNB(address _router) internal view virtual returns (address);


    /**
     * @dev Return maximum output given the input amount and the status of Uniswap reserves.
     * @param aIn The amount of asset to market sell.
     * @param rIn the amount of asset in reserve for input.
     * @param rOut The amount of asset in reserve for output.
     */
    function _getMktSellAmount(uint256 aIn, uint256 rIn, uint256 rOut) internal pure virtual returns (uint256);

    /**
     * @dev Return minmum input given the output amount and the status of Uniswap reserves.
     * @param aOut The output amount of asset after market sell.
     * @param rIn the amount of asset in reserve for input.
     * @param rOut The amount of asset in reserve for output.
     */
    function _getMktSellInAmount(uint256 aOut, uint256 rIn, uint256 rOut) internal pure virtual returns (uint256);

    /**
     * @dev Swap A to B with the input debts ratio
     * @notice na/da should lager than nb/db
     *
     * @param ra Reserved token A in LP pair.
     * @param rb Reserved token B in LP pair.
     * @param da Debts of token A.
     * @param db Debts of token B.
     * @param na Current available balance of token A.
     * @param nb Current available balance of token B.
     *
     * @return uint256 How many A should be swaped to B.
     */
    function _swapAToBWithDebtsRatio(
        uint256 ra,
        uint256 rb,
        uint256 da,
        uint256 db,
        uint256 na,
        uint256 nb
    ) internal pure virtual returns (uint256);

    // ------------------------------------------------------------------------

    function _updatePrinciple(
        uint256 id,
        bool isWithdraw,
        address[2] calldata borrowTokens,
        uint256[2] memory deltaN,       // Only used for deposit
        uint256 rateOrDepositAmount     // When withdraw, it is withdraw rate
                                        // When deposit, It is deposited lp amount
    ) 
        internal 
    {
        // Update principal.
        uint256[2] storage N = principal[id];
        (uint256 ra, uint256 rb,) = lpToken.getReserves();

        if (borrowTokens[0] == token1 || (borrowTokens[0] == address(0) && token1 == wBNB)) {
            // If reverse
            (ra, rb) = (rb, ra);
        }

        // If withdraw some LP.
        if (isWithdraw) {

            if (deltaN[0] > 0 || deltaN[1] > 0) {
                // Decrease some principal.
                if (N[0] > 0) {
                    if (rateOrDepositAmount < 10000) {
                        N[0] = N[0].mul(10000 - rateOrDepositAmount).div(10000);
                    } else {
                        N[0] = 1;   // Never return to 0
                    }
                } else {
                    // N[1] >= 0
                    if (rateOrDepositAmount < 10000) {
                        N[1] = N[1].mul(10000 - rateOrDepositAmount).div(10000);
                    } else {
                        N[1] = 1;   // Never return to 0
                    }
                }
            }
        }

        // If depoist some LP.
        else {
            uint256 lpSupply = lpToken.totalSupply();
            uint256 na = rateOrDepositAmount.mul(ra).div(lpSupply);
            uint256 nb = rateOrDepositAmount.mul(rb).div(lpSupply);
            ra = ra.sub(na);
            rb = rb.sub(nb);

            if (N[0] == 0 && N[1] == 0) {
                // First time open the position, get the principal.
                // if deltaN[0] / deltaN[1] > ra / rb, that means token0 is worth more than token1.
                if (deltaN[0].mul(rb) > deltaN[1].mul(ra)) {
                    uint256 incN0 = _getMktSellAmount(deltaN[1], rb, ra);
                    N[0] = deltaN[0].add(incN0);
                } else {
                    uint256 incN1 = _getMktSellAmount(deltaN[0], ra, rb);
                    N[1] = deltaN[1].add(incN1);
                }
            } else {
                // Not the first time.
                if (deltaN[0] > 0 || deltaN[1] > 0){
                    // Increase some principal.
                    if (N[0] > 0) {
                        uint256 incN0 = _getMktSellAmount(deltaN[1], rb, ra);
                        N[0] = N[0].add(deltaN[0]).add(incN0);
                    } else {
                        // N[1] > 0
                        uint256 incN1 = _getMktSellAmount(deltaN[0], ra, rb);
                        N[1] = N[1].add(deltaN[1]).add(incN1);
                    }
                }
            }
        }
    }

    /**
     * @dev Return equivalent output given the input amount and the status of Uniswap reserves.
     * @param aIn The amount of asset to market sell.
     * @param rIn the amount of asset in reserve for input.
     * @param rOut The amount of asset in reserve for output.
     */
    function _getEqAmount(uint256 aIn, uint256 rIn, uint256 rOut) internal pure returns (uint256) {
        require(rIn > 0 && rOut > 0, "bad reserve values");
        return aIn.mul(rOut).div(rIn);
    }

    /// @dev Internal function to stake all outstanding LP tokens to the given position ID.
    function _addPosition(uint256 id, address account) internal {
        uint256 lpBalance = lpToken.balanceOf(address(this));
        if (lpBalance > globalLp) {
            lpBalance = lpBalance - globalLp;
            posLPAmount[id] = posLPAmount[id].add(lpBalance);
            globalLp = globalLp.add(lpBalance);
            userLp[account] = userLp[account].add(lpBalance);
            emit AddPosition(id, lpBalance);
        }
    }

    /// @dev Internal function to remove shares of the ID and convert to outstanding LP tokens.
    function _removePosition(uint256 id, address account) internal {
        uint256 lpAmount = posLPAmount[id];
        if (lpAmount > 0) {
            globalLp = globalLp.sub(lpAmount);
            userLp[account] = userLp[account].sub(lpAmount);
            posLPAmount[id] = 0;
            emit RemovePosition(id, lpAmount);
        }
    }

    /// @dev Return the left amount of A after repay all debts
    function _repayDeptsAndSwapLeftToA(
        uint256 ra,
        uint256 rb,
        uint256 da,
        uint256 db,
        uint256 na,
        uint256 nb
    ) internal pure returns(uint256) {

        if (nb > db) {
            // Swap B to A
            uint256 incA = _getMktSellAmount(nb-db, rb, ra);
            if (na.add(incA) > da) {
                na = na.add(incA).sub(da);
            } else {
                // The left amount is not enough to repay debts.
                na = 0;
            }

        // nb <= db, swap A to B
        } else {
            if (db-nb > rb) {
                // There are not enough token B in DEX, no left A.
                na = 0;
            }
            else {
                uint256 decA = _getMktSellInAmount(db-nb, ra, rb);
                if (na > da.add(decA)) {
                    na = na.sub(decA).sub(da);
                } else {
                    // The left amount is not enough to repay debts.
                    na = 0;
                }
            }
        }
        return na;
    }

    /* ==================================== Only owner ==================================== */

    /**
     * @dev Recover ERC20 tokens that were accidentally sent to this smart contract.
     * @param token The token contract. Can be anything. This contract should not hold ERC20 tokens.
     * @param to The address to send the tokens to.
     * @param value The number of tokens to transfer to `to`.
     */
    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {
        require(token != address(lpToken), "Cannot recover lp token");
        if (token == address(0)) {
            SafeToken.safeTransferETH(to, value);
        } else {
            SafeToken.safeTransfer(token, to, value);
        }
    }

    /**
     * @dev Set the given strategies' approval status.
     * @param strategies The strategy addresses.
     * @param isOk Whether to approve or unapprove the given strategies.
     */
    function setStrategyOk(address[] calldata strategies, bool isOk) external onlyOwner {
        uint256 len = strategies.length;
        for (uint256 idx = 0; idx < len; idx++) {
            strategiesOk[strategies[idx]] = isOk;
        }
    }

    /**
     * @dev Update critical strategy smart contracts. EMERGENCY ONLY. Bad strategies can steal funds.
     * @param _liqStrategy The new liquidate strategy contract.
     */
    function setCriticalStrategies(IStrategy _liqStrategy) external onlyOwner {
        liqStrategy = _liqStrategy;
    }

    receive() external payable {}

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

// Inheritance
interface IFarm {

    /* ==================================== Read ==================================== */
    
    /* ----------------- Pool Info ----------------- */

    function lastTimeRewardApplicable(uint256 poolId) external view returns (uint256);

    function rewardPerToken(uint256 poolId) external view returns (uint256);

    function getRewardForDuration(uint256 poolId) external view returns (uint256);

    /* ----------------- User Staked Info ----------------- */

    // Rewards amount for user in one pool.
    function stakeEarnedPerPool(uint256 poolId, address account) external view returns (uint256);

    /* ----------------- User Bonus Info  ----------------- */

    // Rewards amount for bonus in one pool.
    function bonusEarnedPerPool(uint256 poolId, address account) external view returns (uint256);

    // Rewards amount for bonus in all pools.
    function bonusEarned(address account) external view returns (uint256);

    /* ----------------- Inviter Bonus Info  ----------------- */

    // Rewards amount for inviter bonus in one pool.
    function inviterBonusEarnedPerPool(uint256 poolId, address account) external view returns (uint256);

    // Rewards amount for inviter bonus in all pools.
    function inviterBonusEarned(address account) external view returns (uint256);


    /* ==================================== Write ==================================== */

   
    /* ----------------- For Staked ----------------- */

    // Send rewards from the target pool directly to users' account
    function getStakeRewardsPerPool(uint256 poolId, address account) external;

    /* ----------------- For Bonus ----------------- */

    function getBonusRewardsPerPool(uint256 poolId, address account) external;

    function getBonusRewards(address account) external;

    /* ----------------- For Inviter Bonus ----------------- */

    function getInviterBonusRewardsPerPool(uint256 poolId, address account) external;

    function getInviterRewards(address account) external;


    /* ==================================== Only operator ==================================== */

    // Inviter is address(0), when there is no inviter.
    function stake(uint256 poolId, address account, uint256 amount) external;

    // Must indicate the inviter once the user have has one. 
    function withdraw(uint256 poolId, address account, uint256 amount) external;   
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;


interface IGoblin {
    /* ==================================== Read ==================================== */

    /// @return Earned MDX and DEMA amount.
    function userAmount(address account) external view returns (uint256, uint256);

    /// @dev Get the lp amount at given posId.
    function posLPAmount(uint256 posId) external view returns (uint256);

    /**
     * @dev Return the amount of each borrow token can be withdrawn with the given borrow amount rate.
     * @param id The position ID to perform health check.
     * @param borrowTokens Address of two tokens this position had debt.
     * @param debts Debts of two tokens.
     */
    function health(
        uint256 id,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts
    ) external view returns (uint256[2] memory);

    /**
     * @dev Return the left rate of the principal. need to divide to 10000, 100 means 1%
     * @param id The position ID to perform loss rate check.
     * @param borrowTokens Address of two tokens this position had debt.
     * @param debts Debts of two tokens.
     */
    function newHealth(
        uint256 id,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts
    ) external view returns (uint256);

    /* ==================================== Write ==================================== */

    /// @dev Send all mdx rewards earned in this goblin to account.
    function getAllRewards(address account) external;

    /**
     * @dev Work on the given position. Must be called by the operator.
     * @param id The position ID to work on.
     * @param user The original user that is interacting with the operator.
     * @param borrowTokens Address of two tokens user borrow from bank.
     * @param borrowAmounts The amount of two borrow tokens.
     * @param debts The user's debt amount of two tokens.
     * @param data The encoded data, consisting of strategy address and bytes to strategy.
     */
    function work(
        uint256 id,
        address user,
        address[2] calldata borrowTokens,
        uint256[2] calldata borrowAmounts,
        uint256[2] calldata debts,
        bytes calldata data
    ) external payable;

    /**
     * @dev Liquidate the given position by converting it to debtToken and return back to caller.
     * @param id The position ID to perform liquidation.
     * @param user The address than this position belong to.
     * @param borrowTokens Two tokens address user borrow from bank.
     * @param debts Two tokens debts.
     */
    function liquidate(
        uint256 id,
        address user,
        address[2] calldata borrowTokens,
        uint256[2] calldata debts) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

interface IPair {

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

interface IRouter {
    function factory() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IStrategy {

    /// @dev Execute worker strategy. Take LP tokens + debt token. Return LP tokens or debt token.
    /// @param user The original user that is interacting with the operator.
    /// @param borrowTokens Two borrow token address.
    /// @param borrows The amount of each borrow token.
    /// @param debts The user's total debt of each borrow token, for better decision making context.
    /// @param data Extra calldata information passed along to this strategy.
    /// @return Principal changed amount change of each token, increase or decrease.
    /// return token and amount need transfer back.
    function execute(
        address user,
        address[2] calldata borrowTokens,
        uint256[2] calldata borrows,
        uint256[2] calldata debts,
        bytes calldata data) external payable returns (uint256[2] memory);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IMasterChef {
    function syrup() view external returns(address);
    
    function cakePerBlock() view external returns(uint);
    function totalAllocPoint() view external returns(uint);

    function poolInfo(uint _pid) view external returns(address lpToken, uint allocPoint, uint lastRewardBlock, uint accCakePerShare);
    function userInfo(uint _pid, address _account) view external returns(uint amount, uint rewardDebt);
    function poolLength() view external returns(uint);
    
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function emergencyWithdraw(uint256 _pid) external;

    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (BNBtps://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}