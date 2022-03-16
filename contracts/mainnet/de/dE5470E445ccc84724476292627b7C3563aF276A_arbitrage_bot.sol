/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-04
*/

/**
 *Submitted for verification at Etherscan.io on 2022-02-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;


interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transfer(address dst, uint wad) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function decimals() external view returns (uint8 decimals);
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





// Start

contract arbitrage_bot {

    mapping(address => bool) isOwner;
    mapping(address => bool) isGelato;
    mapping(address => bool) sniped;
    address uniswapV2Pair; //address of the pool
    address public router1 = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //pancakeswap
    address public router2 = 0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7; //apeswap
    address public WETH_address = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public pokeMe = 0x527a819db1eb0e34426297b03bae11F2f8B3A19E;
    address reciever;
    address player1;
    address player2;
    address player3;
    address player4;

    //uint threshold;  // 10000 = 100% , 100 = 1% , 1 = 0.01%

    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router1);
    IUniswapV2Router02 apeswapV2Router = IUniswapV2Router02(router2);

    constructor() {
        isOwner[msg.sender] = true;
        isGelato[pokeMe] = true;
    }

    modifier owner {
        require(isOwner[msg.sender] == true); _;
    }

    modifier gelato {
        require(isGelato[msg.sender] == true);_;
    }
    
    function getPair() public view returns(address) {
        return uniswapV2Pair;
    }
    
    function getWETH() public view returns(address) {
        return WETH_address;
    }

    //Swap functions (uniswap)
    
    function uniswap_swapETHforTokens(address token, uint amount_eth) public{
        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = WETH_address;                     //Token address
        path[1] = token;                    //WETH address
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount_eth}(0,path,to,block.timestamp);
    }

    function uniswap_swapTokensforETH(address token, uint amount_token) public{
        ERC20 TOKEN = ERC20(token);
        TOKEN.approve(router1,amount_token);

        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH_address;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount_token,0,path,to,block.timestamp);
    }

    function uniswap_swapTokensForTokens(address tokenIn, address tokenOut, uint amount_tokenIn) public{
        ERC20 TOKEN = ERC20(tokenIn);
        TOKEN.approve(router1,amount_tokenIn);
        TOKEN.approve(msg.sender,amount_tokenIn);

        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount_tokenIn,0,path,to,block.timestamp);
    }

    function uniswap_getAmountsOut(address token, address pairedToken, uint amountIn) public view returns (uint[] memory amounts){ //Returns ETH value of input token amount
        address[] memory path = new address[](2);
        path[0] = token;                            //Token address
        path[1] = pairedToken;                      //WETH address
        amounts = uniswapV2Router.getAmountsOut(amountIn,path);

        return amounts;
    }

    //Swap functions (apeswap)
    
    function apeswap_swapETHforTokens(address token, uint amount_eth) public{
        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = WETH_address;                     //Token address
        path[1] = token;                    //WETH address
        apeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount_eth}(0,path,to,block.timestamp);
    }

    function apeswap_swapTokensforETH(address token, uint amount_token) public{
        ERC20 TOKEN = ERC20(token);
        TOKEN.approve(router2,amount_token);

        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH_address;
        apeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount_token,0,path,to,block.timestamp);
    }

    function apeswap_swapTokensForTokens(address tokenIn, address tokenOut, uint amount_tokenIn) public{
        ERC20 TOKEN = ERC20(tokenIn);
        TOKEN.approve(router2,amount_tokenIn);
        TOKEN.approve(msg.sender,amount_tokenIn);

        address to = address(this);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        apeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount_tokenIn,0,path,to,block.timestamp);
    }

    function apeswap_getAmountsOut(address token, address pairedToken, uint amountIn) public view returns (uint[] memory amounts){ //Returns ETH value of input token amount
        address[] memory path = new address[](2);
        path[0] = token;                            //Token address
        path[1] = pairedToken;                      //WETH address
        amounts = apeswapV2Router.getAmountsOut(amountIn,path);

        return amounts;
    }

    //Arbitrage functions

    function buyApeSellUni(address token, address pairedToken_uni, uint amount_eth) public{
        ERC20 TOKEN = ERC20(token);
        ERC20 PTOKEN_uni = ERC20(pairedToken_uni);

        apeswap_swapETHforTokens(token, amount_eth); //swap ETH for TXL (ape)
        uint amount_token = TOKEN.balanceOf(address(this));
        uniswap_swapTokensForTokens(token, pairedToken_uni, amount_token); //swap TXL for bUSD (uni)
        uint amount_ptoken = PTOKEN_uni.balanceOf(address(this));
        uniswap_swapTokensforETH(pairedToken_uni, amount_ptoken); //swap bUSD for ETH (uni)
    }

    function buyUniSellApe(address token, address pairedToken_uni, uint amount_eth) public{
        ERC20 TOKEN = ERC20(token);
        ERC20 PTOKEN_uni = ERC20(pairedToken_uni);

        uniswap_swapETHforTokens(pairedToken_uni, amount_eth); //swap ETH for bUSD (uni)
        uint amount_ptoken = PTOKEN_uni.balanceOf(address(this));
        uniswap_swapTokensForTokens(pairedToken_uni, token, amount_ptoken); //swap bUSD for TXL (uni)
        uint amount_token = TOKEN.balanceOf(address(this));
        apeswap_swapTokensforETH(token, amount_token); //swap TXL for ETH (ape)
    }

    function test1(address token, address pairedToken_uni) public{
        ERC20 TOKEN = ERC20(token);
        ERC20 PTOKEN_uni = ERC20(pairedToken_uni);

        uint amount_ptoken = PTOKEN_uni.balanceOf(address(this));
        uniswap_swapTokensForTokens(pairedToken_uni, token, amount_ptoken); //swap bUSD for TXL (uni)
        uint amount_token = TOKEN.balanceOf(address(this));
        apeswap_swapTokensforETH(token, amount_token); //swap TXL for ETH (ape)
    }

    function arbitrage(address token, address pairedToken_uni, address pairedToken_ape, uint amount, uint threshold) public owner{

        //get output value of the amounts
        uint AmntsOut_uni = uniswap_getAmountsOut(token, pairedToken_uni, amount)[1]; //out amount (pair1) of x tokens
        uint AmntsOut_ape = apeswap_getAmountsOut(token, pairedToken_ape, amount)[1]; //out amount (pair2) of x tokens
        
        //get eth value of the amounts
        uint ethAmntsOut_uni;
        uint ethAmntsOut_ape;
        if(pairedToken_uni != WETH_address){
        ethAmntsOut_uni = uniswap_getAmountsOut(pairedToken_uni, WETH_address, AmntsOut_uni)[1];  //eth value of x tokens (pair1)
        }else{
        ethAmntsOut_uni = AmntsOut_uni; 
        }
        if(pairedToken_ape != WETH_address){
        ethAmntsOut_ape = uniswap_getAmountsOut(pairedToken_ape, WETH_address, AmntsOut_ape)[1];  //eth value of x tokens (pair2)
        }else{
        ethAmntsOut_ape = AmntsOut_ape;
        }

        uint AmntsDiff;
        uint AmntsDiff_perc;
        if(ethAmntsOut_uni > ethAmntsOut_ape){
        AmntsDiff = ethAmntsOut_uni - ethAmntsOut_ape;
        AmntsDiff_perc = AmntsDiff * 10000 / ethAmntsOut_ape; 
            if(AmntsDiff_perc > threshold){
                buyApeSellUni(token, pairedToken_uni, amount);
            }else{
                revert();
            }
        }else if(ethAmntsOut_ape > ethAmntsOut_uni){
        AmntsDiff = ethAmntsOut_ape - ethAmntsOut_uni;
        AmntsDiff_perc = AmntsDiff * 10000 / ethAmntsOut_uni;
            if(AmntsDiff_perc > threshold){
                buyUniSellApe(token, pairedToken_uni, amount);
            }else{
                revert();
            }
        }

    }



    //Other

    function withdrawTokens(address token) public owner{
        ERC20 TOKEN = ERC20(token);
        uint contractBalance = TOKEN.balanceOf(address(this));
        TOKEN.approve(address(this),contractBalance);
        TOKEN.approve(msg.sender,contractBalance);
        TOKEN.transferFrom(address(this), msg.sender, contractBalance);
    }

    function addOwner(address user) public owner{
        isOwner[user] = true;
    }

    function randomNumber(uint min, uint max) internal view returns(uint){
        uint num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % max;
        return num + min;
    }


    //Native ETH/BNB functions
    

    function claim() public owner{
        uint contractBalance = address(this).balance;
        payable(msg.sender).transfer(contractBalance);
    }

    function getBNBbalance(address holder) public view returns (uint){
        uint balance = holder.balance;
        return balance;
    }
    

    receive() external payable {}
    fallback() external payable {}

}