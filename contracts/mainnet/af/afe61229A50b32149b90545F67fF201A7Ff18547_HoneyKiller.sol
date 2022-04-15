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
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) external pure returns (uint amountOut);
    function getAmountsOut( uint amountIn, address[] memory path, address pairAdd, uint fee) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function swapTokens(
        uint amountIn,
        uint amountOutMin,
        
        address[] calldata path,
        address pair,

        address to,
        uint fee
    ) external;
    function swapETHForTokens(
        uint amountOutMin,

        address[] calldata path, // [wbnb, token]
        address pair,

        address to,
        uint fee
    ) external payable;
    function swapTokensForETH(
        uint amountIn,
        uint amountOutMin,
        
        address[] calldata path, // [token, wbnb]
        address pair,

        address to,
        uint fee
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

    uint constant MAX_UINT = type(uint256).max;
    address payable owner;
    address router;
    constructor( address _router ) {
        owner = payable(msg.sender);
        router = _router;
    }

    function approve(address spender, address tokenAddress) public {
        IERC20 token = IERC20(tokenAddress);
        if(token.allowance(address(this), address(spender)) < 1){
            require(token.approve(address(spender), MAX_UINT),"FAIL TO APPROVE");
        }
    }

    function checkFeesOnBuy(
        address tokenAddress, 
        address pairAdd,
        uint fee,
        uint256 bnbIn
    ) external payable returns(uint256, uint256){
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router).WETH();
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(bnbIn, path, pairAdd, fee);
        uint buyTokenAmount = amounts[amounts.length - 1];
        
        //Buy tokens
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapETHForTokens{value: msg.value}(0, path, pairAdd, address(this), fee);
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;
        
        return(buyTokenAmount, (buyTokenAmount-tokenAmountOut));
    }

    function checkFeesOnBuyCustomToken(
        address customToken, // customToken paired with the tokenAddress that we want to calculate the fee on
        address pairAdd1,
        uint fee1,
        address tokenAddress, 
        address pairAdd2,
        uint fee2,
        uint256 bnbIn
    ) external payable returns(uint256, uint256){
        // swap from bnb to the custom token
        address[] memory path = new address[](2);
        uint[] memory amounts;
        path[0] = IRouter(router).WETH();
        path[1] = customToken;

        amounts = IRouter(router).getAmountsOut(bnbIn, path, pairAdd1, fee1);
        IRouter(router).swapETHForTokens{value: msg.value}(0, path, pairAdd1, address(this), fee1);

        // start fee calculation process
        path[0] = customToken;
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        amounts = IRouter(router).getAmountsOut(IERC20(customToken).balanceOf(address(this) ) , path, pairAdd2, fee2);
        uint buyTokenAmount = amounts[amounts.length - 1];
        //Buy tokens
        approve(router, customToken);
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapTokens(IERC20(customToken).balanceOf(address(this)), 0, path, pairAdd2, address(this),fee2);
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;

        return(buyTokenAmount, (buyTokenAmount-tokenAmountOut));
    }

    function checkFeesOnSellCustomToken(
        address customToken, // customToken paired with the tokenAddress that we want to calculate the fee on
        address pairAdd1,
        uint fee1,
        address tokenAddress, 
        address pairAdd2,
        uint fee2
    ) external payable returns(uint256, uint256){
        // swap from bnb to the custom token
        address[] memory path = new address[](2);
        path[0] = IRouter(router).WETH();
        path[1] = customToken;

        IRouter(router).swapETHForTokens{value: msg.value}(0, path, pairAdd1, address(this), fee1);

        // start fee calculation process
        path[0] = customToken;
        path[1] = tokenAddress;
        
        //Buy tokens
        approve(router, customToken);
        uint scrapTokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        IRouter(router).swapTokens(IERC20(customToken).balanceOf(address(this)), 0, path, pairAdd2, address(this),fee2);
        uint tokenAmountOut = IERC20(tokenAddress).balanceOf(address(this)) - scrapTokenBalance;

        //Sell token
        approve(router, tokenAddress);
        (uint256 idealBnbOut, uint bnbOut) = sellSomeTokensForCustom(tokenAddress, customToken, pairAdd2, fee2, tokenAmountOut);
        return(idealBnbOut, idealBnbOut - bnbOut);
    }
    function sellSomeTokensForCustom(address _tokenIn, address _tokenOut, address pairAdd, uint fee, uint tokenAmount) public payable returns (uint idealBnbOut, uint bnbOut) {
        require(tokenAmount > 0, "Can't sell this.");
        approve(router, _tokenIn);
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        
        uint customTokensBefore = IERC20(_tokenOut).balanceOf(address(this));
        idealBnbOut = IRouter(router).getAmountsOut(tokenAmount, path, pairAdd, fee)[1];
        IRouter(router).swapTokens(tokenAmount, 0, path, pairAdd, address(this), fee);
        uint customTokensAfter = IERC20(_tokenOut).balanceOf(address(this));
        
        bnbOut = customTokensAfter-customTokensBefore;
    }

    function checkFeesOnSell(
        address tokenAddress, 
        address pairAdd1,
        uint fee1
    ) external payable returns(uint256, uint256){
        address[] memory path = new address[](2);
        path[0] = IRouter(router).WETH();
        path[1] = tokenAddress;
        IERC20 token = IERC20(tokenAddress);

        //Buy tokens
        uint scrapTokenBalance = token.balanceOf(address(this));
        IRouter(router).swapETHForTokens{value: msg.value}(0, path, pairAdd1, address(this), fee1);
        uint tokenAmountOut = token.balanceOf(address(this)) - scrapTokenBalance;

        //Sell token
        
        (uint256 idealBnbOut, uint bnbOut) = sellSomeTokens(tokenAddress, pairAdd1, fee1, tokenAmountOut);
        
        return(idealBnbOut, idealBnbOut - bnbOut);
    }


    function sellSomeTokens(address tokenAddress, address pairAddress, uint fee, uint tokenAmount) public payable returns (uint idealBnbOut, uint bnbOut) {
        require(tokenAmount > 0, "Can't sell this.");
        approve(router, tokenAddress);
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = IRouter(router).WETH();
        
        uint ethBefore = address(this).balance;
        idealBnbOut = IRouter(router).getAmountsOut(tokenAmount, path, pairAddress, fee)[1];
        IRouter(router).swapTokensForETH(tokenAmount, 0, path, pairAddress, address(this), fee);
        uint ethAfter = address(this).balance;
        
        bnbOut = ethAfter-ethBefore;
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