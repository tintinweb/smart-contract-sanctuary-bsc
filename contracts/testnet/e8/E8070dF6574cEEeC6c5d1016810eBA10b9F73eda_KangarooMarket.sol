// SPDX-License-Identifier: MIT
/*
https://integroo.group
*/
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/IPancakeRouter02.sol";
import "./lib/IPancakeFactory.sol";
import "./lib/IPancakePair.sol";
import "./KangarooMatrix.sol";

contract KangarooMarket is Ownable {
    uint256 public creatorPercent;
    uint256 public creatorReferrerPercent;
    uint256 public buyerReferrerPercent;

    IERC20 public immutable marketToken;
    IPancakePair public immutable pancakePair;
    KangarooMatrix public immutable matrix;
    address public immutable distribution;

    struct Course {
        uint32 courseId;
        uint32 creatorId;
        uint32 price;
    }

    enum Receiver {
        CREATOR,
        CREATOR_REFERRER,
        BUYER_REFERRER
    }

    event MissedReceive(uint32 userId);
    event Dividends(Receiver receiver, uint32 userId, uint256 amount);
    event Purchase(uint32 courseId, uint32 creatorId, uint32 price, uint32 buyerId, uint256 amount);
    event PercentsChanged(uint256 creatorPercent, uint256 creatorReferrerPercent, uint256 buyerReferrerPercent);

    constructor(
        address _pancakeRouter,
        address _matrix,
        address _distribution,
        address _rooToken,
        address _usdtToken
    ) {
        marketToken = IERC20(_rooToken);
        pancakePair = IPancakePair(
            IPancakeFactory(IPancakeRouter02(_pancakeRouter).factory()).getPair(_usdtToken, _rooToken)
        );
        distribution = _distribution;
        matrix = KangarooMatrix(_matrix);

        creatorPercent = 7000;
        creatorReferrerPercent = 500;
        buyerReferrerPercent = 200;
    }

    function setMarketPercents(
        uint256 _creatorPercent,
        uint256 _creatorReferrerPercent,
        uint256 _buyerReferrerPercent
    ) external onlyOwner {
        require(_creatorPercent + _creatorReferrerPercent + _buyerReferrerPercent <= 10000, "Bad percents!");

        creatorPercent = _creatorPercent;
        creatorReferrerPercent = _creatorReferrerPercent;
        buyerReferrerPercent = _buyerReferrerPercent;

        emit PercentsChanged(_creatorPercent, _creatorReferrerPercent, _buyerReferrerPercent);
    }

    function buyCourses(Course[] calldata _courses) external {
        for (uint8 i = 0; i < _courses.length; i++) {
            buyCourse(_courses[i]);
        }
    }

    function buyCourse(Course calldata _course) public {
        require(_course.price > 0, "The price must be greater than 0!");

        uint256 amount = (uint256(_course.price) * getMarketTokenRate()) / 100;
        require(marketToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance!");

        uint32 buyerId = matrix.AddressToId(msg.sender);
        require(buyerId != 0, "The buyer doesn't exists!");

        (uint32 creatorReferrerId, , , , , address creator, ,) = matrix.users(_course.creatorId);
        require(creator != address(0), "The creator doesn't exists!");

        marketToken.transferFrom(msg.sender, address(this), amount);

        uint256 creatorAmount = (amount * creatorPercent) / 10000;
        uint256 creatorReferrerAmount = (amount * creatorReferrerPercent) / 10000;
        uint256 buyerReferrerAmount = (amount * buyerReferrerPercent) / 10000;
        uint256 distributionAmount = amount - (creatorAmount + creatorReferrerAmount + buyerReferrerAmount);

        if (creatorAmount > 0) {
            marketToken.transfer(creator, creatorAmount);
            emit Dividends(Receiver.CREATOR, _course.creatorId, creatorAmount);
        }

        if (creatorReferrerAmount > 0) {
            creatorReferrerId = _getActiveReferrerId(creatorReferrerId);
            (, , , , , address creatorReferrer, ,) = matrix.users(creatorReferrerId);

            marketToken.transfer(creatorReferrer, creatorReferrerAmount);
            emit Dividends(Receiver.CREATOR_REFERRER, creatorReferrerId, creatorReferrerAmount);
        }

        if (buyerReferrerAmount > 0) {
            (uint32 buyerReferrerId, , , , , , ,) = matrix.users(buyerId);
            buyerReferrerId = _getActiveReferrerId(buyerReferrerId);
            (, , , , , address buyerReferrer, ,) = matrix.users(buyerReferrerId);

            marketToken.transfer(buyerReferrer, buyerReferrerAmount);
            emit Dividends(Receiver.BUYER_REFERRER, buyerReferrerId, buyerReferrerAmount);
        }

        if (distributionAmount > 0) {
            marketToken.transfer(distribution, distributionAmount);
        }

        emit Purchase(_course.courseId, _course.creatorId, _course.price, buyerId, amount);
    }

    function getMarketTokenRate() public view returns (uint256) {
        (uint112 reserves0, uint112 reserves1,) = pancakePair.getReserves();
        (uint112 reserveIn, uint112 reserveOut) = pancakePair.token0() == address(marketToken)
        ? (reserves0, reserves1)
        : (reserves1, reserves0);

        require(reserveIn > 0 && reserveOut > 1e18, "Insufficient liquidity!");

        uint256 numerator = uint256(1e18) * 10000 * reserveIn;
        uint256 denominator = (uint256(reserveOut) - 1e18) * 9975;

        return numerator / denominator + 1;
    }

    function _getActiveReferrerId(uint32 _referrerId) private returns (uint32) {
        while (true) {
            if (matrix.isActive(_referrerId)) return _referrerId;

            emit MissedReceive(_referrerId);
            (_referrerId,,,,,,,) = matrix.users(_referrerId);
        }

        return 0;
    }
}

// SPDX-License-Identifier: MIT
/*
https://integroo.group/
*/
pragma solidity ^0.8.0;

contract KangarooMatrix {
    struct User {
        uint32 referrerID;
        uint32 partnersCount;
        uint8 activeX3Levels;
        uint8 activeX6Levels;
        uint8 maxAvailableLevel;
        address userAddress;
        uint256 lastActivity;
        bool refBlocked;
    }

    mapping(uint32 => User) public users;
    mapping(address => uint32) public AddressToId;

    function isActive(uint32 _userID) public view returns (bool) {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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