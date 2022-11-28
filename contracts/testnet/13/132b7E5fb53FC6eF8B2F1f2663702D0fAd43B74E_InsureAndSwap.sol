/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor()  {
        owner = msg.sender;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract InsureAndSwap is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    // insure&swap part
    address public taker = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    address public adminer = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    uint256 public lastDtime = 0;
    uint256 public timeLimit = 1800;
    uint256 public amountDlimit = 10000e18;
    address public swapToken  = 0x96F15F089d30Cf4cF8C9d0EeB2Bf40C3cD2476b9;
    address public usdt = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;
    bool public isSwapEnable = true;

    // center part
    mapping(address => uint) public nonces;
    mapping(uint256 => uint256) public orderIds;

    address public signAddr = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    address public token0  = usdt;
    address public token1  = swapToken;
    address public token2  = swapToken;
    address public fuelToAddr = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;



    // price part 
    bool public priceChanging = false;
    uint256 public priceIncreaseAmount = 1000; // 0.1 price
    uint256 public buyAmount = 0; // all get money
    uint256 public buyPriceChangeAmount = 1000e18; // 1000USDT
    uint256 public swapPrice = 50000;
    uint256 public basicPrice = 10000;
    uint256 public swapTokenLeftToChange = 1e8;

    // pancake part
    address public pancakeRouter  = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public uniswapV2Pair;
    IUniswapV2Router02 public  uniswapV2Router;

    modifier onlyTaker(){
        require(msg.sender == taker, "Taker: caller is not the taker");
        _;
    }

    modifier onlyAdminer(){
        require(msg.sender == adminer, "Taker: caller is not the adminer");
        _;
    }

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pancakeRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .getPair(swapToken, address(usdt));
        uniswapV2Router = _uniswapV2Router;
    }


    function swap(uint256 amount) public {
        uint256 usdtAmount = (amount.mul(swapPrice)).div(basicPrice);
        uint256 decimalFix;
        if (IERC20(usdt).decimals() >= IERC20(swapToken).decimals()) {
            decimalFix = IERC20(usdt).decimals() - IERC20(swapToken).decimals();
        }
        else {
            decimalFix = IERC20(swapToken).decimals() - IERC20(usdt).decimals();
        }
        usdtAmount = usdtAmount.mul(10**decimalFix);

        safeTransferFrom(usdt, msg.sender, address(this),usdtAmount); 
        safeTransfer(swapToken, msg.sender, amount);
        priceSyncPancake();
    }

    function priceSyncPancake() internal {
        require(priceChanging == false,'price changing!');
        priceChanging = true;
        if(IERC20(swapToken).balanceOf(address(this)) <= swapTokenLeftToChange){
            uint256 pancakePrice = getPancakePrice();
            if (pancakePrice > swapPrice){
                swapPrice = pancakePrice;
            }
        }
        priceChanging = false;
    }

    function distribution (address accountAddress, address _token,uint256 amount) public onlyTaker{
        require(IERC20(_token).balanceOf(address(this)) > amount, 'over amount'); 
        require(amount<= amountDlimit,'over amount limit');
        require(block.timestamp.sub(lastDtime) >= timeLimit,'too frequency');
        safeTransfer(_token, accountAddress, amount); 
        lastDtime = block.timestamp;
    }



    function setNewTaker (address addr) public onlyAdminer{
        require(addr != address(0),"zero addr!");
        taker = addr;
    }

    function setNewAmountDlimit (uint256 num) public onlyAdminer{
        require(num > 0,"zero num!");
        amountDlimit = num;
    }

    function setNewTimelimit (uint256 num) public onlyAdminer{
        require(num > 0,"zero num!");
        timeLimit = num;
    }


    function updateSwapToken(address addr) public onlyAdminer {
        require(addr != address(0),'Zero addr!');
        swapToken = addr;
    }

     function updatePrice(uint256 price) public onlyAdminer {
        swapPrice = price;
    }

     function updatePriceIncreaseAmount(uint256 amount) public onlyAdminer {
        priceIncreaseAmount = amount;
    }

    function swapSwitch () public onlyAdminer{
        if (isSwapEnable == true){
            isSwapEnable = false;
        }else{
            isSwapEnable = true;
        }
    }


    // center part

    function permitBuy(address msgSender,address contractAddr,string memory funcName, uint256 _orderId,uint256 _amount0,uint256 _amount1,uint256 _amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_orderId,_amount0,_amount1,_amount2,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddr, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _orderId,uint256 amount0 ,uint256 amount1,uint256 amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[_orderId] == 0, "buy orderId has been used!");
        orderIds[_orderId] = 1;
        permitBuy(msg.sender,address(this),"buy",_orderId,amount0,amount1,amount2,deadline, v, r, s); 
        if (amount0 > 0){
            safeTransferFrom(token0, msg.sender, address(this),amount0);
            buyAmount = buyAmount.add(amount0);
            priceBuyIncrease();
        }
        if (amount1 > 0){
            safeTransferFrom(token1, msg.sender, address(this),amount1); 
        }
        if (amount2 > 0){
            safeTransferFrom(token2, msg.sender, fuelToAddr,amount2); 
        }

    }

    function priceBuyIncrease () internal {
        require(priceChanging == false,'price changing!');
        priceChanging = true;
        if(buyAmount >= buyPriceChangeAmount){
            uint256 priceIncreaseRate = buyAmount/buyPriceChangeAmount;
            swapPrice = swapPrice.add(priceIncreaseAmount.mul(priceIncreaseRate));
            buyAmount = buyAmount.sub(buyPriceChangeAmount.mul(priceIncreaseRate));
        }
        priceChanging = false;
    }

    function updateSignAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        signAddr = addr;
    }

    function updateToken0(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token0 = addr;
    }

    function updateToken1(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token1 = addr;
    }

    function updateToken2(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token2 = addr;
    }

    function updateBuyPriceChangeAmount(uint256 amount) public onlyOwner{
        buyPriceChangeAmount = amount;
    }

    function getPancakePrice() public view returns (uint256){
       if (IERC20(swapToken).balanceOf(uniswapV2Pair) <= 0 || IERC20(usdt).balanceOf(uniswapV2Pair) <=0){
           return 0;
       } 
       return  (IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 8).div(IERC20(swapToken).balanceOf(uniswapV2Pair))).div(10 ** 14);
    }

    





 



}