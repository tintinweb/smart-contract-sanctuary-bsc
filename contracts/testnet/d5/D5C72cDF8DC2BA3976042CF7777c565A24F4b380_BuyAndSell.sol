/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



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



// pragma solidity >=0.6.2;

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


interface IERC20 {

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



contract BuyAndSell {
    
    address owner;

    constructor() public {
        owner = msg.sender;
    }
    

    // IUniswapV2Router02 public immutable uniswapV2Router;
    
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);

    IUniswapV2Router01 _uniswapV1Router = IUniswapV2Router01(routerAddress);

    address WBNB = _uniswapV2Router.WETH();
    address factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;

    function changeFactory(address factoryAddress) public {
        require(owner == msg.sender);
        factory = factoryAddress;
    }

    function getAccountBalance(address tokenContract, address whoamI) public view returns (uint256) {
        uint256 balance = IERC20(tokenContract).balanceOf(whoamI);
        return balance;
    }
    function sortTokens(address tokenB) internal view returns (address token0, address token1) {
        require(WBNB != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = WBNB < tokenB ? (WBNB, tokenB) : (tokenB, WBNB);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function getWETH() public view returns (address){
        return WBNB;
    }

    function getPair(address tokenContract) public view returns (address) {
        address Token0;
        address Token1;
        (Token0, Token1) = sortTokens(tokenContract);
        address pair = address(uint160(uint(keccak256(abi.encodePacked(
        hex'ff',
        factory,
        keccak256(abi.encodePacked(Token0,Token1)),
        hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074'
        )))));
        return pair;
    }

    uint256 Fee = 10;

    function setFee(uint256 cFee) public {
        require(msg.sender == owner);
        Fee = cFee;
    }

    function setRouterAddress(address router) public {
        require(msg.sender == owner);
        routerAddress = router;
    }

    function recoveryBNB() public {
        require(owner == address(this) || owner == msg.sender);
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable { }

    function simulate(address tokenContract) public payable {

        require(msg.value > 0);
        // address tokenContract;
        uint256 approveAmount = 115792089237316195423570985008687907853269984665640564039457;

        IERC20(tokenContract).approve(address(_uniswapV2Router), approveAmount);

        address pair = getPair(tokenContract);

        uint256 pairAmount = getAccountBalance(tokenContract,pair);

        uint256 BuyToken = pairAmount * 5 / 100;

        address[] memory path2 = new address[](2);
        path2[0] = WBNB;
        path2[1] = tokenContract;

        _uniswapV1Router.swapETHForExactTokens {value: msg.value}(
            BuyToken,
            path2,
            address(this),
            block.timestamp
        );

        uint256 pairAmountAfterBuy = getAccountBalance(tokenContract,pair); 
        
        uint256 userBalance = getAccountBalance(tokenContract,address(this));

        require(userBalance >= BuyToken * (100 - Fee) / 100, "B");
        // make the swap
        address[] memory path = new address[](2);
        path[0] = tokenContract;
        path[1] = WBNB;

        // uint256 tokenAmount = getAccountBalance(tokenContract,whoamI);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            userBalance,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        
        uint256 pairAmount2 = getAccountBalance(tokenContract,pair);
        require(pairAmount2 - pairAmountAfterBuy >= userBalance * (100 - Fee) / 100, "S");
    }
}