/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

//unique comment to change bytecode 25895radsadsewb354g

pragma solidity 0.8.13;
pragma abicoder v2;

abstract contract Context { 
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    constructor () {
      address msgSender = msg.sender;
      _owner = msgSender;
    }

    modifier onlyOwner() {
      require(_owner == _msgSender(), "Owner access only");
      _;
    }
}

//v2 interfaces

interface IUniswapV2Callee {
  function uniswapV2Call(
    address sender,
    uint amount0,
    uint amount1,
    bytes calldata data
  ) external;
}

interface IUniswapV2Router {
  function getAmountsOut(uint amountIn, address[] memory path)
    external
    view
    returns (uint[] memory amounts);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  )
    external
    returns (
      uint amountA,
      uint amountB,
      uint liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);

  function WETH() external pure returns (address);
  function factory() external pure returns (address);
}

interface IUniswapV2Pair {
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

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}


//misc interfaces

interface ApprovalInterface {
    function approve(address spender, uint256 value) external returns (bool);
}

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract ArbSwapper is Context, Ownable, IUniswapV2Callee {

    event Log(string msg);

    struct ArbInfo {
        address buyDEXRouterAddress;
        address sellDEXRouterAddress;
        address tokenToArb;
        uint amountToArb;
        address originalSearcher;

    }

    function estimateProfitability(address buyDEXRouterAddress, address sellDEXRouterAddress, address tokenToArb, uint buyAmountETH) public view returns (uint totalProfit) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        address dexWETH = buyDEXRouter.WETH();

        address[] memory buyPath = new address[](2);
        buyPath[0] = dexWETH;
        buyPath[1] = tokenToArb;

        uint buyTokenOutput = buyDEXRouter.getAmountsOut(buyAmountETH, buyPath)[1];

        address[] memory sellPath = new address[](2);
        sellPath[0] = tokenToArb;
        sellPath[1] = dexWETH;

        uint sellOutput = sellDEXRouter.getAmountsOut(buyTokenOutput, sellPath)[1];


        return sellOutput;
    }

    function isDoubleDEXPaired(address tokenToCheck, address buyDEXRouterAddress, address sellDEXRouterAddress) public view returns (bool) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        IUniswapV2Factory buyDEXFactory = IUniswapV2Factory(buyDEXRouter.factory());
        IUniswapV2Factory sellDEXFactory = IUniswapV2Factory(sellDEXRouter.factory());

        address dexWETH = buyDEXRouter.WETH();

        address buyTokenPair = buyDEXFactory.getPair(dexWETH, tokenToCheck);
        address sellTokenPair = sellDEXFactory.getPair(dexWETH, tokenToCheck);

        return (buyTokenPair != address(0) && sellTokenPair != address(0)) ? true : false;

    }

    function printCrypto(address buyDEXRouterAddress, address sellDEXRouterAddress, address tokenToArb, uint amountToArb) public payable onlyOwner {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        address dexWETH = buyDEXRouter.WETH();

        tokenToArb = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

        address uniswapPair = IUniswapV2Factory(buyDEXRouter.factory()).getPair(tokenToArb, dexWETH);

        require(uniswapPair != address(0), "Invalid pair");

        address token0 = IUniswapV2Pair(uniswapPair).token0();
        address token1 = IUniswapV2Pair(uniswapPair).token1();

        uint amount0Out = dexWETH == token0 ? amountToArb : 0;
        uint amount1Out = dexWETH == token1 ? amountToArb : 0;

        ArbInfo memory arbInfo = ArbInfo(buyDEXRouterAddress, sellDEXRouterAddress, tokenToArb, amountToArb, msg.sender);

        bytes memory data = abi.encode(arbInfo);

        emit Log("before swap");

        IUniswapV2Pair(uniswapPair).swap(amount0Out, amount1Out, address(this), data);

        emit Log("after swap");
  }

  function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external override {

        emit Log("in swap function");
        (ArbInfo memory arbInfo) = abi.decode(_data, (ArbInfo));
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(arbInfo.buyDEXRouterAddress);
        //IUniswapV2Router sellDEXRouter = IUniswapV2Router(arbInfo.sellDEXRouterAddress);
        address uniswapPair = IUniswapV2Factory(buyDEXRouter.factory()).getPair(IUniswapV2Pair(msg.sender).token0(), IUniswapV2Pair(msg.sender).token1());

        require(msg.sender == uniswapPair, "Invalid pair");
        require(_sender == address(this), "!sender");

        uint flashswapFee = ((arbInfo.amountToArb * 3) / 997) + 1;

        uint amountToRepay = arbInfo.amountToArb + flashswapFee;


        emit Log("before payback");
        IERC20(buyDEXRouter.WETH()).transfer(uniswapPair, amountToRepay);
        emit Log("after payback");
        //payable(address(arbInfo.originalSearcher)).transfer(address(this).balance);
  }

  /*

          ERC20 tokenContract = ERC20(arbInfo.tokenToArb);
        address[] memory buyPath = getPathFromETHToToken(buyDEXRouter.WETH(), arbInfo.tokenToArb);
        buyDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: arbInfo.amountToArb}(0, buyPath, address(this), deadline);

        ApprovalInterface tokenApproval = ApprovalInterface(arbInfo.tokenToArb);
        tokenApproval.approve(arbInfo.sellDEXRouterAddress, (2**256 - 1));

        uint tokenAmount = tokenContract.balanceOf(address(this));

        address[] memory sellPath = getPathFromTokenToETH(buyDEXRouter.WETH(), arbInfo.tokenToArb);
        sellDEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, sellPath, address(this), deadline);

    */

  function getPathFromETHToToken(address wethAddress, address tokenToArb) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = wethAddress;
    path[1] = tokenToArb;
    
    return path;
  }

  function getPathFromTokenToETH(address wethAddress, address tokenToArb) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = tokenToArb;
    path[1] = wethAddress;
    
    return path;
  }

  function killContract() public onlyOwner {
      address payable caller = payable(msg.sender);
      selfdestruct(caller);
  }

  receive() payable external {}
}