/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

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

pragma solidity >=0.6.2;

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

pragma solidity >=0.6.2;

/*
interface IUniswapV2Router02 is IUniswapV2Router01 {
    
}
*/

pragma solidity ^0.7.1;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract TokenSwap {

  address public UNISWAP_FACTORY_ADDRESS;
  address public UNISWAP_ROUTER_ADDRESS;
  address public WETH;
  address public baseTokenAddress;
  address public receiverAddress;
  
  address public owner;

  IUniswapV2Router02 uniswapRouter;
  IERC20 baseToken; //BUSD
  IERC20 wethToken;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  constructor(uint256 _chainId) {
    owner = msg.sender;
    receiverAddress = 0xBd1d184bD749c163C24D6ae5133C6b81Da26d638; // ETH

    if (_chainId == 56){
        //PancakeSwap - BSC - Mainnet
        UNISWAP_FACTORY_ADDRESS = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB
        baseTokenAddress = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    }else if (_chainId == 97){
        //PancakeSwap - BSC - Testnet
        UNISWAP_FACTORY_ADDRESS = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
        UNISWAP_ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB
        baseTokenAddress = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
    }

    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    baseToken = IERC20(baseTokenAddress);
    wethToken = IERC20(WETH);

  }

  function swapNativeCoinWithBaseToken() public payable returns(bool){ // SWAP BNB with BUSD
    address _tokenOut = baseTokenAddress; 
    
    wethToken.deposit{value:msg.value}();
    wethToken.approve(UNISWAP_ROUTER_ADDRESS,wethToken.balanceOf(address(this)));
    
    uint deadline = block.timestamp + 15;
    uniswapRouter.swapExactTokensForTokens(wethToken.balanceOf(address(this)), 0, getPathForTokenToToken(WETH,_tokenOut), receiverAddress, deadline);

    return true;
  }

  function getPrice(address _tokenAddress1, address _tokenAddress2, uint256 _amount) public view returns(uint256) {
    address pairAddress = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS).getPair(_tokenAddress1, _tokenAddress2);
   
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

    IERC20 token1 = IERC20(pair.token1());
    (uint Res0, uint Res1,) = pair.getReserves();

    // decimals
    uint res0 = Res0*(10**token1.decimals());
    return((_amount*res0)/Res1); // return amount of token0 needed to buy token1
  }

  function getPathForETHtoToken(address _token) public view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = _token;
    
    return path;
  }

  function getPathForTokenToToken(address _tokenIn, address _tokenOut) public view returns (address[] memory) {
    address[] memory path = new address[](3);
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }
    return path;
  }

  function setReceiverAddress(address _newReceiverAddress) public onlyOwner{
    receiverAddress = _newReceiverAddress;
  }

  function withdrawETH() external onlyOwner {
      (bool success, ) = msg.sender.call{value: address(this).balance}("");
      require(success, "Transfer failed.");
  }

  function withdrawTokens(address _tokenAddress) external onlyOwner {
      IERC20 token =  IERC20(_tokenAddress);
      bool success = token.transfer(msg.sender, token.balanceOf(address(this)));
      require(success, "Token Transfer failed.");
  }

  function transferOwnership(address _newOwner) public onlyOwner{
    owner = _newOwner;
  }

  // important to receive ETH
  receive() payable external {
    
  }
}