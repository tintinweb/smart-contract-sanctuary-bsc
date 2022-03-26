/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)
pragma solidity  >=0.4.22 <0.9.0;
interface IERC20UNISWAP {
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
interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}
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
interface IPancakeCallee {
    function pancakeCall(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract SandyLoan is IUniswapV2Callee,IPancakeCallee {
    address private immutable  WETH;
    address private immutable UNISWAP_FACTORY;
    address private UNISWAP_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;//0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private TokenBorrow;
    address private immutable Cowner;


    event log(string message,  uint val);
    event swaps(string message, address[] path);

    constructor (address WETH_,address UNISWAP_FACTORY_) {
        WETH = WETH_;
        UNISWAP_FACTORY = UNISWAP_FACTORY_;
        Cowner = msg.sender;
    }
    function getTokenPair(address _tokenBorrow) external view returns(address) {
        return IUniswapV2Factory(UNISWAP_FACTORY).getPair(_tokenBorrow,WETH);
    }
    function setTokenBorrow(address _tokenBorrow) external returns(address){
        TokenBorrow = _tokenBorrow;
        return TokenBorrow;
    }
    function initFlashloan(address _tokenBorrow, uint amount,address[] calldata path1,address[] calldata path2,uint tokenToBorrow,uint lowestLimit) external{
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(_tokenBorrow,WETH);
        require(pair!= address(0),'Pair donot exist');
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = 0;
        uint amount1Out = 0;
        if (tokenToBorrow == 0) {
            amount0Out = _tokenBorrow == token0 ? 0:amount; //: 0;
            amount1Out = _tokenBorrow == token1 ? 0:amount; //: 0;
        } else {
            amount0Out = _tokenBorrow == token0 ? amount : 0;
            amount1Out = _tokenBorrow == token1 ? amount : 0;            
        }


        uint tokenRecieved = IERC20UNISWAP(WETH).balanceOf(address(this));
        emit log("Token initial Amount",tokenRecieved);

        bytes memory data = abi.encode(_tokenBorrow,amount,path1,path2,lowestLimit);
        
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out,address(this),data);
    }
    function uniswapV2Call(address _sender,uint _amount0,uint _amount1, bytes calldata _data) external override {
        
        
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(token0,token1);
        uint tokenRecieved;
        require (msg.sender == pair,'Msg not sent from pair');
        require(_sender == address(this),'Not sendrt');

        //data sent through abi encode now decodes
        (address _tokenBorrow, uint amount,address[] memory path1,address[] memory path2,uint _lowestLimit) = abi.decode(_data,(address, uint,address[],address[],uint));
        //
        emit swaps("Path one",path1);
        emit swaps("Path two",path2);
        //Swap token
        uint ethRecieved = IERC20UNISWAP(path1[0]).balanceOf(address(this));
        emit log("Token Borrowed Amount",ethRecieved);
        uint amountT  = _amount0;
        uint amountT1 = _amount1;

       // address[] memory path = new address[](2);
       // path[0] = amountT == 0 ? token1 : token0;
       // path[1] = amountT == 0 ? token0 : token1;
 
        IERC20UNISWAP(path1[0]).approve(UNISWAP_ROUTER, amountT);
        emit log("Token ETH Allowance",IERC20UNISWAP(path1[0]).allowance(address(this),UNISWAP_ROUTER));

        uint  deadline = block.timestamp + 1800;
        IPancakeRouter02(UNISWAP_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountT,0,path1,address(this),deadline);

        //Swap to Eth
        if (path2[0] == WETH) {
            TokenBorrow = path2[1];
            tokenRecieved = IERC20UNISWAP(TokenBorrow).balanceOf(address(this));
            IERC20UNISWAP(path2[1]).approve(UNISWAP_ROUTER, tokenRecieved);
        }else if (path2[1] == WETH) {
            TokenBorrow = path2[0];
            tokenRecieved = IERC20UNISWAP(TokenBorrow).balanceOf(address(this));
            IERC20UNISWAP(path2[0]).approve(UNISWAP_ROUTER, tokenRecieved);
            
        }

        
        emit log("Token Recieved 4rmSwap Amount",tokenRecieved);

       emit log("Token Allowance",IERC20UNISWAP(TokenBorrow).allowance(address(this),UNISWAP_ROUTER));
        
        uint256 counter = 0;
        while(gasleft() > _lowestLimit) counter++;
        emit log("Gas Waste",counter);
        //path[0] = TokenBorrow;
        //path[1] = WETH;
       IPancakeRouter02(UNISWAP_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenRecieved, 0, path2, address(this), deadline);
       address pair_ = pair;
        uint ethSwapBack = IERC20UNISWAP(path2[path2.length-1]).balanceOf(address(this));
        emit log("Token SwapBack Amount",ethSwapBack);
        //fee for transaction
        uint fee = ((amount *3)/997) +1;
        uint rePay = amount + fee;
        
        // log emit
        emit log("amount",amount);
        emit log("amount0",amountT);
        emit log("amount1",amountT1);
        emit log("Fee",fee);
        emit log("Repay Amount",rePay);

        //IERC20(_tokenBorrow).transfer(pair,rePay);
        IERC20UNISWAP(WETH).transfer(pair_,rePay);
    }
    function pancakeCall(address _sender,uint _amount0,uint _amount1, bytes calldata _data) external override {
        
        
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(token0,token1);
        uint tokenRecieved;
        require (msg.sender == pair,'Msg not sent from pair');
        require(_sender == address(this),'Not sendrt');

        //data sent through abi encode now decodes
        (address _tokenBorrow, uint amount,address[] memory path1,address[] memory path2,uint _lowestLimit) = abi.decode(_data,(address, uint,address[],address[],uint));
        //
        emit swaps("Path one",path1);
        emit swaps("Path two",path2);
        //Swap token
        uint ethRecieved = IERC20UNISWAP(path1[0]).balanceOf(address(this));
        emit log("Token Borrowed Amount",ethRecieved);
        uint amountT  = _amount0;
        uint amountT1 = _amount1;

       // address[] memory path = new address[](2);
       // path[0] = amountT == 0 ? token1 : token0;
       // path[1] = amountT == 0 ? token0 : token1;
 
        IERC20UNISWAP(path1[0]).approve(UNISWAP_ROUTER, amountT);
        emit log("Token ETH Allowance",IERC20UNISWAP(path1[0]).allowance(address(this),UNISWAP_ROUTER));

        uint  deadline = block.timestamp + 1800;
        IPancakeRouter02(UNISWAP_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountT,0,path1,address(this),deadline);

        //Swap to Eth
        if (path2[0] == WETH) {
            TokenBorrow = path2[1];
            tokenRecieved = IERC20UNISWAP(TokenBorrow).balanceOf(address(this));
            IERC20UNISWAP(path2[1]).approve(UNISWAP_ROUTER, tokenRecieved);
        }else if (path2[1] == WETH) {
            TokenBorrow = path2[0];
            tokenRecieved = IERC20UNISWAP(TokenBorrow).balanceOf(address(this));
            IERC20UNISWAP(path2[0]).approve(UNISWAP_ROUTER, tokenRecieved);
            
        }

        
        emit log("Token Recieved 4rmSwap Amount",tokenRecieved);

       emit log("Token Allowance",IERC20UNISWAP(TokenBorrow).allowance(address(this),UNISWAP_ROUTER));
        
        uint256 counter = 0;
        while(gasleft() > _lowestLimit) counter++;
        emit log("Gas Waste",counter);
        //path[0] = TokenBorrow;
        //path[1] = WETH;
       IPancakeRouter02(UNISWAP_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenRecieved, 0, path2, address(this), deadline);
       address pair_ = pair;
        uint ethSwapBack = IERC20UNISWAP(path2[path2.length-1]).balanceOf(address(this));
        emit log("Token SwapBack Amount",ethSwapBack);
        //fee for transaction
        uint fee = ((amount *3)/997) +1;
        uint rePay = amount + fee;
        
        // log emit
        emit log("amount",amount);
        emit log("amount0",amountT);
        emit log("amount1",amountT1);
        emit log("Fee",fee);
        emit log("Repay Amount",rePay);

        //IERC20(_tokenBorrow).transfer(pair,rePay);
        IERC20UNISWAP(WETH).transfer(pair_,rePay);
    }
    function withdrawals() external virtual returns(bool) {
        require(Cowner == msg.sender);
        uint balanceEth = IERC20UNISWAP(WETH).balanceOf(address(this));
        IERC20UNISWAP(WETH).transfer(Cowner,balanceEth);
    }
}