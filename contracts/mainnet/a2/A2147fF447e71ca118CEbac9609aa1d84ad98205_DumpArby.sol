/**
 *Submitted for verification at BscScan.com on 2022-07-27
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

interface IDUMP {
    function sell(uint256 tokenAmount) external returns (address, uint256);
}

contract DumpArby {

    // token info    
    IUniswapV2Router02 private constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant DUMP = 0x6b8a384DDe6FC779342Fbb2E4a8EcF73eD18D151;
    address public ARBY = 0x17d85bE5fb4EF2b34f8d2d5F30ae3635F066fA2E;
    
    // paths
    address[] private buyPath;
    
    // cost to run cycle + incentive
    uint256 public gasCost = 30 * 10**14;

    // creator address
    address public creator;
    address public profitReceiver = 0x13DDe481A8b2F5D9c43ED566d852612CcCB1AbeC;
    address public dumpReceiver = 0xc5D5c35E65ce327D15b4923cE01dB3FF4c5a1350;
    uint256 private profitShare;

    bool split;

    modifier onlyOwner() {
        require(msg.sender == creator, 'OC');
        _;
    }
    
    constructor(uint pShare) {
        buyPath = new address[](2);
        buyPath[0] = router.WETH();
        buyPath[1] = DUMP;
        creator = msg.sender;
        profitShare = pShare;
    }

    function setSplit() external onlyOwner {
        split = true;
    }

    function setArby(address ARBY_) external onlyOwner {
        ARBY = ARBY_;
    }

    function setGasCost(uint nG) external onlyOwner {
        gasCost = nG;
    }

    function setProfitShare(uint nPS) external onlyOwner {
        profitShare = nPS;
    }

    function setProfitReceiver(address pR) external onlyOwner {
        profitReceiver = pR;
    }

    function setDumpReceiver(address dR) external onlyOwner {
        dumpReceiver = dR;
    }

    function setCreator(address creator_) external onlyOwner {
        creator = creator_;
    }

    function withdraw(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'Zero Tokens');
        IERC20(token).transfer(msg.sender, bal);
    }
    
    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value:address(this).balance}("");
        require(s, 'Failure on BNB Withdrawal');
    }




    function buyCycle() external payable {
        // buy dump
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0,
            buyPath,
            address(this),
            block.timestamp + 30
        );
        
        // sell dump
        (address token,) = IDUMP(DUMP).sell(IERC20(DUMP).balanceOf(address(this)));

        // sell stable
        _tokenToBNB(token, IERC20(token).balanceOf(address(this)));

        _split();
    }
    
    function sellCycle() external payable {

        // buy dump
        (bool s,) = payable(DUMP).call{value: msg.value}("");
        require(s, 'FDP');

        // sell dump
        _tokenToBNB(DUMP, IERC20(DUMP).balanceOf(address(this)));

        _split();
    }
    



    function _split() internal {
        if (split) {
            (bool s0,) = payable(ARBY).call{value: msg.value + gasCost}("");
            require(s0, 'Non Profitable');

            (bool s1,) = payable(profitReceiver).call{value: ( address(this).balance * profitShare ) / 100}("");
            require(s1, 'Non Profitablee');

            (bool s2,) = payable(dumpReceiver).call{value: address(this).balance}("");
            require(s2, 'Non Profitableee');
        } else {
            (bool s0,) = payable(msg.sender).call{value: address(this).balance}("");
            require(s0);
        }
    }

    function _tokenToBNB(address token, uint amount) internal {

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();

        IERC20(token).approve(address(router), amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp + 30
        );
    }
    
    receive() external payable {}
    
}