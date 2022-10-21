// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

interface Token {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    

}

// pragma solidity >=0.5.0;
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

// pragma solidity >=0.6.2;
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

contract TrainerNFT is ERC721Enumerable, Ownable {
  uint256 public mintPrice = 75;

  address public tokenAddress = 0x64Ea6c203187E5a702fb7B453f8eEB558B5CC48B;
  address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  
  string _baseTokenURI;

  bool public isActive = true;

  uint256 public maximumMintSupply = 10000;
  Token token;

  IUniswapV2Router02 public uniswapV2Router;

  event AssetMinted(uint256 tokenId, address sender);
  event SaleActivation(bool isActive);

  constructor() ERC721("Royale Trainer", "RTNER") {
    token = Token(tokenAddress);
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
    uniswapV2Router = _uniswapV2Router;
  }

  modifier saleIsOpen {
    require(totalSupply() <= maximumMintSupply, "Sale has ended.");
    _;
  }

  function setDexRouter(address dexRouter) external onlyOwner {
    _routerAddress = dexRouter;
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dexRouter);
    uniswapV2Router = _uniswapV2Router;
  }

  function setBusdAddress(address _busdAddress) public onlyOwner {
    busdAddress = _busdAddress;
  }

  function setActive(bool val) public onlyOwner {
    isActive = val;
    emit SaleActivation(val);
  }

  function setMaxMintSupply(uint256 maxMintSupply) external  onlyOwner {
    maximumMintSupply = maxMintSupply;
  }

  function setPrice(uint256 _price) public onlyOwner {
    mintPrice = _price;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function getPrice() external view returns (uint256) {
    return mintPrice;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function mint(address _to, uint256 _count, uint256 price) public saleIsOpen {
    if (msg.sender != owner()) {
      require(isActive, "Sale is not active currently.");
    }

    require(totalSupply() + _count <= maximumMintSupply, "Total supply exceeded.");
    require(totalSupply() <= maximumMintSupply, "Total supply spent.");

    require(price >= _count * getNFTPriceByBCOMP(), "Insuffient BCOMP amount sent.");

    token.transferFrom(msg.sender, address(this), price);
      
    for (uint256 i = 0; i < _count; i++) {
      emit AssetMinted(totalSupply(), _to);
      _safeMint(_to, totalSupply());
    }
  }

  function batchReserveToMultipleAddresses(uint256 _count, address[] calldata addresses) external onlyOwner {
    uint256 supply = totalSupply();

    require(supply + _count <= maximumMintSupply, "Total supply exceeded.");
    require(supply <= maximumMintSupply, "Total supply spent.");

    for (uint256 i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "Can't add a null address");

      for(uint256 j = 0; j < _count; j++) {
        emit AssetMinted(totalSupply(), addresses[i]);
        _safeMint(addresses[i], totalSupply());
      }
    }
  }

  function setTokenAddress(address _tokenAddress) public onlyOwner {
    tokenAddress = _tokenAddress;
    token = Token(_tokenAddress);
  }

  function walletOfOwner(address _owner) external view returns(uint256[] memory) {
    uint tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);

    for(uint i = 0; i < tokenCount; i++){
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokensId;
  }

  function withdraw(uint256 _amount) external onlyOwner {
    require(_amount <= token.balanceOf(address(this)), "Not enough balance!");
    token.transfer(_msgSender(), _amount);
  }

  function withdraw(uint256 _amount, address _tokenAddress) external onlyOwner {
    require(_amount <= token.balanceOf(address(this)), "Not enough balance!");
    Token(_tokenAddress).transfer(_msgSender(), _amount);
  }

  function getAmountsOut(uint256 amount, address tokenIn, address tokenOut) public view returns (uint256){
    address[] memory path = new address[](2);
    path[0] = tokenIn;
    path[1] = tokenOut;

    return uniswapV2Router.getAmountsOut(amount, path)[1];
  }

  function getTokenPerBUSD(uint256 _amount) public view returns(uint256) {
    return getAmountsOut(_amount * 10 ** 18, busdAddress, tokenAddress);
  }

  function getNFTPriceByBCOMP() public view returns(uint256) {
    return getTokenPerBUSD(mintPrice);
  }

  receive() external payable {}

}