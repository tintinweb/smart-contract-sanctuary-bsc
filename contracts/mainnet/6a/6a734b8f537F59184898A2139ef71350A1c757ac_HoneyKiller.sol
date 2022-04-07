pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function sync() external;
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

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


contract HoneyKiller {

    uint constant MAX_UINT = 2**256 - 1 - 100;

    address payable owner;
    
    constructor() {
        owner = payable(msg.sender);
    }


    function approve(address router, address tokenAddress) public {
        IERC20 token = IERC20(tokenAddress);
        if(token.allowance(address(this), address(router)) < 1){
            require(token.approve(address(router), MAX_UINT),"FAIL TO APPROVE");
        }
    }

    function checkFeesOnBuy(address router, address tokenAddress, uint256 bnbIn) external payable returns(uint256, uint256){
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router).WETH();
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(bnbIn, path);
        uint buyTokenAmount = amounts[amounts.length - 1];
        
        //Buy tokens
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapETHForExactTokens{value: msg.value}(buyTokenAmount, path, address(this), block.timestamp+60);
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;
        
        return(buyTokenAmount, (buyTokenAmount-tokenAmountOut));
    }

    function checkFeesOnBuyCustomToken(
        address router0, // swap bnb -> custom token
        address customToken, // customToken paired with the tokenAddress that we want to calculate the fee on
        address router, 
        address tokenAddress, 
        uint256 bnbIn
    ) external payable returns(uint256, uint256){
        // swap from bnb to the custom token
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router0).WETH();
        path[1] = customToken;

        amounts = IRouter(router0).getAmountsOut(bnbIn, path);
        IRouter(router0).swapETHForExactTokens{value: msg.value}( 
            amounts[amounts.length - 1],// amount to buy 
            path, address(this), block.timestamp+60);

        // start fee calculation process
        path[0] = customToken;
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(  IERC20(customToken).balanceOf(address(this) ) , path);
        uint buyTokenAmount = amounts[amounts.length - 1];
        //Buy tokens
        approve(router, customToken);
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens( 
            IERC20(customToken).balanceOf(address(this)), // amount to buy
            0, path, address(this), block.timestamp+60
        );
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;

        return(buyTokenAmount, (buyTokenAmount-tokenAmountOut));
    }

    function checkFeesOnSellCustomToken(
        address router0, // swap bnb -> custom token
        address customToken, // customToken paired with the tokenAddress that we want to calculate the fee on
        address router, 
        address tokenAddress, 
        uint256 bnbIn
    ) external payable returns(uint256, uint256){

        // swap from bnb to the custom token
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router0).WETH();
        path[1] = customToken;

        amounts = IRouter(router0).getAmountsOut(bnbIn, path);
        IRouter(router0).swapETHForExactTokens{value: msg.value}( 
            amounts[amounts.length - 1],// amount to buy 
            path, address(this), block.timestamp+60);

        // start fee calculation process
        path[0] = customToken;
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(  IERC20(customToken).balanceOf(address(this) ) , path);
        
        //Buy tokens
        approve(router, customToken);
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens( 
            IERC20(customToken).balanceOf(address(this)), // amount to buy
            0, path, address(this), block.timestamp+60
        );
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;

        //Sell token
        approve(router, tokenAddress);
        (uint256 idealBnbOut, uint bnbOut) = sellSomeTokensForCustom(router, tokenAddress, customToken, tokenAmountOut);
        return(idealBnbOut, idealBnbOut - bnbOut);
    }
    function checkFeesOnSell(address router, address tokenAddress, uint256 bnbIn) external payable returns(uint256, uint256){
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router).WETH();
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(bnbIn, path);
        uint buyTokenAmount = amounts[amounts.length - 1];
        
        //Buy tokens
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapETHForExactTokens{value: msg.value}(buyTokenAmount, path, address(this), block.timestamp+60);
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;

        //Sell token
        
        (uint256 idealBnbOut, uint bnbOut) = sellSomeTokens(router, tokenAddress, tokenAmountOut);
        
        return(idealBnbOut, idealBnbOut - bnbOut);
    }


    function sellSomeTokens(address router, address tokenAddress, uint tokenAmount) public payable returns (uint idealBnbOut, uint bnbOut) {
        require(tokenAmount > 0, "Can't sell this.");
        approve(router, tokenAddress);
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = IRouter(router).WETH();
        
        uint ethBefore = address(this).balance;
        idealBnbOut = IRouter(router).getAmountsOut(tokenAmount, path)[1];
        IRouter(router).swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp+60);
        uint ethAfter = address(this).balance;
        
        bnbOut = ethAfter-ethBefore;
    }
    function sellSomeTokensForCustom(address router, address _tokenIn, address _tokenOut, uint tokenAmount) public payable returns (uint idealBnbOut, uint bnbOut) {
        require(tokenAmount > 0, "Can't sell this.");
        approve(router, _tokenIn);
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        
        uint customTokensBefore = IERC20(_tokenOut).balanceOf(address(this));
        idealBnbOut = IRouter(router).getAmountsOut(tokenAmount, path)[1];
        IRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp+60);
        uint customTokensAfter = IERC20(_tokenOut).balanceOf(address(this));
        
        bnbOut = customTokensAfter-customTokensBefore;
    }


    function withdraw() external{
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }

    function withdrawToken(address tokenAddress, address to) external{
        require(msg.sender == owner);
        IERC20 token = IERC20(tokenAddress);
        token.transfer(to, token.balanceOf(address(this)));
    }

    receive() external payable{}
}