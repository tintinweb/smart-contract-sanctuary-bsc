// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "./IStableTokenConverter.sol";

contract StableTokenConverter is IStableTokenConverter {
    /**
     * @dev ERC20 token address used for conversion.
     */
    address public stableTokenAddress;

    /**
     * @dev ERC20 token address used for conversion.
     */
    address public swapTokenAddress;

    /**
     * @dev Wrapped BNB token address to be used as intermediary token pair for swap.
     * @dev Example: swap token -> wBNB token -> stable token.
     */
    address public wBNBAddress;

    /**
     * @dev Emitted each time `convertToStable` was called.
     */
    event AmountConvertedToStableCoin(
        address indexed _beneficiary,
        uint256 indexed _amountIn,
        uint256 indexed _amountOut
    );

    /**
     * @dev Emitted each time `convertToStable` was called.
     */
    event AmountConvertedBackFromStableCoin(
        address indexed _beneficiary,
        uint256 indexed _amountIn,
        uint256 indexed _amountOut
    );

    /**
     * @dev Router used to communicate with the Uniswap implementation. Used for the `swapExactTokensForTokens` function.
     */
    IUniswapV2Router01 public router;

    /**
     * @param _stableTokenAddress  First ERC20 token address used for conversion.
     * @param _swapTokenAddress  Second ERC20 token address used for conversion.
     * @param _uniswapV2RouterAddress Router used to communicate with the Uniswap implementation. Used for the `swapExactTokensForTokens` function.
     * @param _wBNBAddress Wrapped BNB token address to be used as intermediary token pair for swap. 
     */
    constructor(
        address _stableTokenAddress,
        address _swapTokenAddress,
        address _uniswapV2RouterAddress,
        address _wBNBAddress
    ) {
        stableTokenAddress = _stableTokenAddress;
        swapTokenAddress = _swapTokenAddress;
        router = IUniswapV2Router01(_uniswapV2RouterAddress);
        wBNBAddress = _wBNBAddress;
    }

    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of swap token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of swap tokens in @param _amountOut amount of stable tokens.
     * @dev The stable tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertToStable(uint256 _amountIn, address _to)
        external
        override
        returns (uint256 _amountOut)
    {
        _amountOut = swap(swapTokenAddress, stableTokenAddress, _amountIn, _to);
        emit AmountConvertedToStableCoin(_to, _amountIn, _amountOut);
    }

    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of stable token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of stable tokens in @param _amountOut amount of swap tokens.
     * @dev The swap tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertBackFromStable(uint256 _amountIn, address _to)
        external
        override
        returns (uint256 _amountOut)
    {
        _amountOut = swap(stableTokenAddress, swapTokenAddress, _amountIn, _to);
        emit AmountConvertedBackFromStableCoin(_to, _amountIn, _amountOut);
    }

    /**
     * @dev Swaps the @param _amountIn amount of token identified by it's @param _tokenInAddress address  via the `router`.
     * @dev Leverages the `getAmountOutMin` internal function.
     * @dev This function will assume the caller will first want to go through the wBRB token.
     * @dev Because the function uses the ERC30's `transferFrom` function, the caller must perform 
     * an `ERC20` approve on the `_tokenInAddress` for a minimum of `_amountIn`.
     */
    function swap(
        address _tokenInAddress,
        address _tokenOutAddress,
        uint256 _amountIn,
        address _to
    ) internal returns (uint256 _amountOut) {
        IERC20(_tokenInAddress).transferFrom(
            msg.sender,
            address(this),
            _amountIn
        );
        IERC20(_tokenInAddress).approve(address(router), _amountIn);
        address[] memory path = new address[](3);
        path[0] = _tokenInAddress;
        path[1] = wBNBAddress;
        path[2] = _tokenOutAddress;
        return
            router.swapExactTokensForTokens(
                _amountIn,
                getAmountOutMin(_tokenInAddress, _tokenOutAddress, _amountIn),
                path,
                _to,
                block.timestamp
            )[path.length - 1];
    }

    /**
     * @dev This function will return the minimum amount for a swap. This forwards to the router's `getAmountsOut` function.
     * @dev This function will assume the caller will first want to go through the wBRB token.
     */
    function getAmountOutMin(
        address _tokenInAddress,
        address _tokenOutAddress,
        uint256 _amountIn
    ) internal view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = _tokenInAddress;
        path[1] = wBNBAddress;
        path[2] = _tokenOutAddress;
        uint256[] memory amountOutMins = router.getAmountsOut(_amountIn, path);
        return amountOutMins[path.length - 1];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStableTokenConverter {
    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of swap token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of swap tokens in @param _amountOut amount of stable tokens.
     * @dev The stable tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertToStable(uint256 _amountIn, address _to)
        external
        returns (uint256 _amountOut);

    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of stable token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of stable tokens in @param _amountOut amount of swap tokens.
     * @dev The swap tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertBackFromStable(uint256 _amountIn, address _to)
        external
        returns (uint256 _amountOut);
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