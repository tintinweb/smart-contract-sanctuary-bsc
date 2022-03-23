// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ILiquidityPoolBroker.sol";

/// @title Static APY LTT Farming
/// @author Vladyslav Dalechyn <[email protected]>
/// @notice Farm with fixed reward amount and fixed APY in LTT
contract LiquidityPoolBroker is ILiquidityPoolBroker, Ownable {

    /// @inheritdoc ILiquidityPoolBrokerImmutables
    IUniswapV2Router02 public immutable override router;
    /// @inheritdoc ILiquidityPoolBrokerImmutables
    address public immutable override ltt;
    /// @inheritdoc ILiquidityPoolBrokerImmutables
    address public immutable override busd;

    constructor(
        address _router,
        address _busd,
        address _ltt
    ) Ownable() {
        router = IUniswapV2Router02(_router);
        ltt = _ltt;
        busd = _busd;

        // Approve BUSD and LTT for liquidity
        IERC20(_busd).approve(_router, 2**256 - 1);
        IERC20(_ltt).approve(_router, 2**256 - 1);
    }

    /// @inheritdoc ILiquidityPoolBrokerActions
    function provideETHLiquidity(
        uint amountInLTT,
        uint amountInBUSD,
        uint amountLTTDesired,
        uint amountBUSDDesired,
        uint amountLTTMin,
        uint amountBUSDMin,
        address[] memory pathLTT,
        address[] memory pathBUSD,
        address to,
        uint deadline
    ) external override payable {
        require(
            pathBUSD[pathBUSD.length - 1] == busd,
            "PathBUSD route end must be BUSD"
        );
        require(
            pathLTT[pathLTT.length - 1] == ltt,
            "PathLTT route end must be LTT");
        require(
            pathBUSD[0] == pathLTT[0],
            "First token in routes must be the same");

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountInBUSD
        }(amountBUSDMin, pathBUSD, address(this), deadline);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountInLTT
        }(amountLTTMin, pathLTT, address(this), deadline);

        router.addLiquidity(
            ltt,
            busd,
            amountLTTDesired,
            amountBUSDDesired,
            amountLTTMin,
            amountBUSDMin,
            to,
            deadline
        );
    }

    /// @inheritdoc ILiquidityPoolBrokerActions
    function provideTokensLiquidity(
        uint amount,
        uint amountInLTT,
        uint amountInBUSD,
        uint amountLTTDesired,
        uint amountBUSDDesired,
        uint amountLTTMin,
        uint amountBUSDMin,
        address[] memory pathLTT,
        address[] memory pathBUSD,
        address to,
        uint deadline
    ) external override {
        require(
            pathBUSD[pathBUSD.length - 1] == busd || (pathBUSD.length == 0 && pathLTT.length != 0),
            "PathBUSD route end must be BUSD or empty"
        );
        require(
            pathLTT[pathLTT.length - 1] == ltt || (pathLTT.length == 0 && pathBUSD.length != 0),
            "PathLTT route end must be LTT or empty");
        require(
            pathLTT.length == 0 ||
            pathBUSD.length == 0 ||
            pathBUSD[0] == pathLTT[0],
            "First token in routes must be the same");

        // Approve Token for swaps
        IERC20(pathBUSD[0]).approve(address(router), amount);
        require(
            IERC20(pathBUSD[0]).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // If we provide BUSD this swap is not needed
        if (pathBUSD.length != 0)
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountInBUSD,
                amountBUSDMin,
                pathBUSD,
                address(this),
                deadline
            );

        // If we provide LTT this swap is not needed
        if (pathLTT.length != 0)
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountInLTT,
                amountLTTMin,
                pathLTT,
                address(this),
                deadline
            );

        router.addLiquidity(
            ltt,
            busd,
            amountLTTDesired,
            amountBUSDDesired,
            amountLTTMin,
            amountBUSDMin,
            to,
            deadline
        );
    }

    /// @inheritdoc ILiquidityPoolBrokerOwnerActions
    function transferLTT(address to, uint amount) external override onlyOwner {
        require(IERC20(ltt).transfer(to, amount), "Transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Permissioned LP broker actions
/// @notice Contains LP broker methods that may only be called by the factory owner
interface ILiquidityPoolBrokerOwnerActions {
    /// @notice Transfer LTT's in case of migration
    /// @param to Address to transfer
    /// @param amount Amount to transfer
    function transferLTT(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/// @title LP Broker state that never changes
/// @notice These parameters are fixed for a broker forever, i.e., the methods will always return the same values
interface ILiquidityPoolBrokerImmutables {
    /// @notice Address of PancakeSwap router
    /// @return Address of PancakeSwap router
    function router() external view returns (IUniswapV2Router02);

    /// @notice Address of LTT
    /// @return Address of LTT
    function ltt() external view returns (address);

    /// @notice Address of BUSD
    /// @return Address of BUSD
    function busd() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Permissionless broker actions
/// @notice Contains farm methods that can be called by anyone
interface ILiquidityPoolBrokerActions {
    /// @notice Provides BUSD/LTT liquidity in any token
    /// @param amount Amount of tokens to be processed
    /// @param amountInBUSD Amount of tokens to swap to BUSD
    /// @param amountInLTT Amount of tokens to swap to LTT
    /// @param amountBUSDDesired Desired amount of BUSD tokens to provide liquidity
    /// @param amountLTTDesired Desired amount of LTT tokens to provide liquidity
    /// @param amountBUSDMin Minimum amount of BUSD tokens to swap/lp providing
    /// @param amountLTTMin Minimum amount of LTT tokens to swap/lp providing
    /// @param pathBUSD Route path Token->...->BUSD
    /// @param pathLTT Route path Token->...->LTT
    /// @param to Recipient of LP tokens
    /// @param deadline Deadline when contract must revert
    function provideTokensLiquidity(
        uint amount,
        uint amountInBUSD,
        uint amountInLTT,
        uint amountBUSDDesired,
        uint amountLTTDesired,
        uint amountBUSDMin,
        uint amountLTTMin,
        address[] memory pathBUSD,
        address[] memory pathLTT,
        address to,
        uint deadline
    ) external;

    /// @notice Provides BUSD/LTT liquidity in ETH
    /// @param amountInBUSD Amount of ETH to swap to BUSD
    /// @param amountInLTT Amount of ETH to swap to LTT
    /// @param amountBUSDDesired Desired amount of BUSD tokens to provide liquidity
    /// @param amountLTTDesired Desired amount of LTT tokens to provide liquidity
    /// @param amountBUSDMin Minimum amount of BUSD tokens to swap/lp providing
    /// @param amountLTTMin Minimum amount of LTT tokens to swap/lp providing
    /// @param pathBUSD Route path ETH->...->BUSD
    /// @param pathLTT Route path ETH->...->LTT
    /// @param to Recipient of LP tokens
    /// @param deadline Deadline when contract must revert
    function provideETHLiquidity(
        uint amountInBUSD,
        uint amountInLTT,
        uint amountBUSDDesired,
        uint amountLTTDesired,
        uint amountBUSDMin,
        uint amountLTTMin,
        address[] memory pathBUSD,
        address[] memory pathLTT,
        address to,
        uint deadline
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./lp/ILiquidityPoolBrokerActions.sol";
import "./lp/ILiquidityPoolBrokerImmutables.sol";
import "./lp/ILiquidityPoolBrokerOwnerActions.sol";

/// @title The interface for LP Broker
/// @dev The broker interface is broken up into many smaller pieces
interface ILiquidityPoolBroker is
    ILiquidityPoolBrokerImmutables,
    ILiquidityPoolBrokerActions,
    ILiquidityPoolBrokerOwnerActions
{}

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}