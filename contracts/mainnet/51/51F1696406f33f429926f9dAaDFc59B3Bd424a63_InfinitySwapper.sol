/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IPhoenix {
    function mintWithNative(address recipient, uint256 minOut) external payable;
    function sell(uint256 amount) external;
}

interface IPair {
    function getReserves() external view returns (uint112, uint112, uint32);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract InfinitySwapper is Ownable {

    // Infinity Token
    address public immutable token;

    // router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Phoenix+
    address public constant phoenix = 0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9;

    // BUSD
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Phoenix+ - Infinity Pair
    address public immutable pair;

    // path
    address[] buyPath;
    address[] sellPath;
    address[] busdToBNB;

    constructor(address _token, address _pair) {

        token = _token;
        pair = _pair;

        buyPath = new address[](2);
        buyPath[0] = phoenix;
        buyPath[1] = _token;

        sellPath = new address[](2);
        sellPath[0] = _token;
        sellPath[1] = phoenix;

        busdToBNB = new address[](2);
        busdToBNB[0] = BUSD;
        busdToBNB[1] = router.WETH();
    }

    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function sell(address recipient) external {

        // approve and sell infinity
        IERC20(token).approve(address(router), type(uint256).max);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(token).balanceOf(address(this)), 0, sellPath, address(this), block.timestamp + 100
        );

        // sell phoenix
        IPhoenix(phoenix).sell(IERC20(phoenix).balanceOf(address(this)));

        // approve and sell BUSD
        IERC20(BUSD).approve(address(router), type(uint256).max);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            IERC20(BUSD).balanceOf(address(this)), 0, busdToBNB, recipient, block.timestamp + 100
        );
    }

    function buy(address recipient, uint minOut) external payable {
        _buyToken(recipient, msg.value, minOut);
    }

    function buy(address recipient) external payable {
        _buyToken(recipient, msg.value, 0);
    }

    function buy() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    receive() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    function _buyToken(address recipient, uint value, uint minOut) internal {
        require(
            value > 0,
            'Zero Value'
        );
        require(
            recipient != address(0),
            'Recipient Cannot Be Zero'
        );

        // mint Phoenix+ to the LP
        IPhoenix(phoenix).mintWithNative{value: value}(pair, minOut);

        // handle swap logic
        (address input, address output) = (phoenix, token);
        (address token0,) = sortTokens(input, output);
        uint amountInput;
        uint amountOutput;
        { // scope to avoid stack too deep errors
        (uint reserve0, uint reserve1,) = IPair(pair).getReserves();
        (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        amountInput = IERC20(input).balanceOf(pair) - reserveInput;
        amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
        }
        
        // format amounts
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));

        // make the swap
        IPair(pair).swap(amount0Out, amount1Out, recipient, new bytes(0));
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
      require(amountIn > 0, 'DappdLibrary: INSUFFICIENT_INPUT_AMOUNT');
      require(reserveIn > 0 && reserveOut > 0, 'DappdLibrary: INSUFFICIENT_LIQUIDITY');
      uint amountInWithFee = amountIn * 9970;
      uint numerator = amountInWithFee * reserveOut;
      uint denominator = reserveIn * 10000 + amountInWithFee;
      amountOut = numerator / denominator;
  }

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
      require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
      (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      require(token0 != address(0), 'DappdLibrary: ZERO_ADDRESS');
  }
}