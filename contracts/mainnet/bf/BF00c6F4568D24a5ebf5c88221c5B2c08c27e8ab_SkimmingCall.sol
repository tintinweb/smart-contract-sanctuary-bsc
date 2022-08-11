// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../strategies/IBonfireStrategicCalls.sol";
import "../swap/IBonfireFactory.sol";
import "../swap/IBonfirePair.sol";
import "../swap/IBonfireRouterPaths.sol";
import "../token/IBonfireTokenTracker.sol";

contract SkimmingCall is IBonfireStrategicCalls, Ownable {
    address public override token;
    address public constant tracker = address(0xBF0089F09D4D90BB51b098F09e05eb40C641627a);
    address public constant paths = address(0xBF00dee4A780037E64909D7D82f7dB3F5beabB95);
    address[] public pools;

    event Skim(uint256 totalAmountOut, address to);

    event PoolUpdate(address indexed pool, bool enabled);

    constructor(
        address gainToken,
        address admin
    ) Ownable() {
        transferOwnership(admin);
        token = gainToken;
    }

    function sortPools() external {
        pools = _sortPools(pools);
    }

    function skimOnly(address to) external {
        for (uint256 i = 0; i < pools.length; i++) {
            IBonfirePair(pools[i]).skim(to);
        }
    }

    function execute(uint256 threshold, address to)
        external
        override
        returns (uint256 amountOut)
    {
        for (uint256 i = 0; i < pools.length; i++) {
            amountOut += _skim(pools[i], to, threshold);
        }
        emit Skim(amountOut, to);
    }

    function quote() external view override returns (uint256 amountOut) {
        for (uint256 i = 0; i < pools.length; i++) {
            (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pools[i])
                .getReserves();
            (reserveA, reserveB) = IBonfirePair(pools[i]).token1() == token
                ? (reserveA, reserveB)
                : (reserveB, reserveA);
            amountOut += IERC20(token).balanceOf(pools[i]) - reserveB;
        }
    }

    function addPool(address pool) external {
        address factory = IBonfirePair(pool).factory();
        address otherToken = IBonfirePair(pool).token0();
        if (otherToken == token) {
            otherToken = IBonfirePair(pool).token1();
        } else {
            require(
                IBonfirePair(pool).token1() == token,
                "SkimmingCall, bad pool"
            );
        }
        SkimmingCall(this).addPoolViaFactory(otherToken, factory);
    }

    function addPoolViaFactory(address otherToken, address uniswapFactory)
        external
    {
        bool included = false;
        address[] memory factories = IBonfireRouterPaths(paths)
            .getUniswapFactories();
        for (uint256 i = 0; i < factories.length; i++) {
            if (factories[i] == uniswapFactory) {
                included = true;
                break;
            }
        }
        require(included, "SkimmingCall: factory not allowed");
        address pool = IBonfireFactory(uniswapFactory).getPair(
            otherToken,
            token
        );
        require(pool != address(0), "SkimmingCall: pool not found");
        included = false;
        for (uint256 i = 0; i < pools.length; i++) {
            if (pools[i] == pool) {
                included = true;
                break;
            }
        }
        require(!included, "SkimmingCall: pool already present");
        pools.push(pool);
        SkimmingCall(this).sortPools();
        emit PoolUpdate(pool, true);
    }

    function removePool(address pool) external {
        address factory = IBonfirePair(pool).factory();
        address[] memory factories = IBonfireRouterPaths(paths)
            .getUniswapFactories();
        uint256 i;
        for (i = 0; i < factories.length; i++) {
            if (factories[i] == factory) {
                break;
            }
        }
        require(i < factories.length, "SkimmingCall: pool not found");
        pools[i] = pools[pools.length - 1];
        pools.pop();
        emit PoolUpdate(pool, false);
    }

    function _sortPools(address[] memory tokenPools)
        internal
        view
        returns (address[] memory _pools)
    {
        if (tokenPools.length <= 1) return tokenPools;
        _pools = new address[](tokenPools.length);
        uint256[] memory balances = new uint256[](tokenPools.length);
        _pools[0] = tokenPools[0];
        balances[0] = IERC20(token).balanceOf(_pools[0]);
        for (uint256 i = 1; i < _pools.length; i++) {
            address pool = tokenPools[i];
            uint256 balance = IERC20(token).balanceOf(pool);
            uint256 index;
            for (index = i; index > 0; index--) {
                if (balances[index - 1] > balance) {
                    balances[index] = balances[index - 1];
                    _pools[index] = _pools[index - 1];
                } else {
                    break;
                }
            }
            _pools[index] = pool;
            balances[index] = balance;
        }
        return _pools;
    }

    function _skim(
        address pool,
        address to,
        uint256 threshold
    ) internal returns (uint256) {
        (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pool)
            .getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token1() == token
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 balance = IERC20(token).balanceOf(pool);
        uint256 amount = ((balance - reserveB) *
            IBonfireRouterPaths(paths).factoryRemainder(
                IBonfirePair(pool).factory()
            )) /
            IBonfireRouterPaths(paths).factoryDenominator(
                IBonfirePair(pool).factory()
            );
        if (amount < threshold) return 0;
        if (amount > reserveB) {
            IBonfirePair(pool).skim(to);
            return amount;
        }
        amount = IBonfireRouterPaths(paths).reflectionAdjustment(
            token,
            pool,
            amount,
            balance - amount
        );
        if (IBonfirePair(pool).token1() == token) {
            IBonfirePair(pool).swap(uint256(0), amount, to, new bytes(0));
        } else {
            IBonfirePair(pool).swap(amount, uint256(0), to, new bytes(0));
        }
        return amount;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IBonfireStrategicCalls {
    function token() external view returns (address token);

    function quote() external view returns (uint256 expectedGains);

    function execute(uint256 threshold, address to)
        external
        returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

interface IBonfireFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

interface IBonfirePair {
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blickTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IBonfireRouterPaths {
    event ChangeFactory(
        address indexed uniswapFactory,
        uint256 fee,
        uint256 denominator,
        string description,
        bool enabled
    );

    event ChangeIntermediateToken(
        address indexed intermediateToken,
        bool enabled
    );

    function wrapper() external returns (address);

    function tracker() external returns (address);

    function getBestPathAugmented(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescriptions
        );

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut);

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath
        );

    function factoryFee(address factory) external view returns (uint256 p);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 p);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 p);

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view returns (uint256 amountOut);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) external pure returns (uint256 amountOut);

    function getAmountOutFromPool(
        uint256 amountIn,
        address tokenB,
        address pool
    )
        external
        view
        returns (
            uint256 amountOut,
            uint256 reserveB,
            uint256 projectedBalanceB
        );

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 reserve
    ) external view returns (uint256);

    function getUniswapFactories()
        external
        returns (address[] memory factories);

    function getIntermediateTokens() external returns (address[] memory tokens);

    function defaultProxy(address) external returns (address);

    function getDefaultProxy(address) external returns (address);

    function getAlternateProxy(address) external returns (address);

    function tokenFactory() external returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IBonfireTokenTracker {
    function getObserver(address token) external view returns (address o);

    function getTotalTaxP(address token) external view returns (uint256 p);

    function getReflectionTaxP(address token) external view returns (uint256 p);

    function getTaxQ(address token) external view returns (uint256 q);

    function reflectingSupply(address token, uint256 transferAmount)
        external
        view
        returns (uint256 amount);

    function includedSupply(address token)
        external
        view
        returns (uint256 amount);

    function excludedSupply(address token)
        external
        view
        returns (uint256 amount);

    function getDescription(address token)
        external
        view
        returns (string memory);

    function storeTokenReference(address token, uint256 chainid) external;

    function tokenid(address token, uint256 chainid)
        external
        pure
        returns (uint256);

    function getURI(uint256 _tokenid) external view returns (string memory);

    function getImageURI(address token) external view returns (string memory);

    function getName(address token) external view returns (string memory);

    function getSwapAndLiquifyAt(address token)
        external
        view
        returns (uint256 value, address pool);

    function triggerSwapAndLiquifyIfPending(address token)
        external
        returns (bool triggered);

    function getProperties(address token)
        external
        view
        returns (string memory properties);

    function registerToken(address proxy) external;

    function registeredTokens(uint256 index)
        external
        view
        returns (uint256 tokenid);

    function registeredProxyTokens(uint256 sourceTokenid, uint256 index)
        external
        view
        returns (address);
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