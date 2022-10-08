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

contract LandNFT is ERC721Enumerable, Ownable {

  uint256 public smallLandMintPrice = 400.0;

  function setSmallLandMintPrice(uint256 _smallLandMintPrice) public onlyOwner {
    smallLandMintPrice = _smallLandMintPrice;
  }

  uint256 public mediumLandMintPrice = 550.0;

  function setMediumLandMintPrice(uint256 _mediumLandMintPrice) public onlyOwner {
    mediumLandMintPrice = _mediumLandMintPrice;
  }
  
  uint256 public largeLandMintPrice = 750.0;

  function setLargeLandMintPrice(uint256 _largeLandMintPrice) public onlyOwner {
    largeLandMintPrice = _largeLandMintPrice;
  }

  uint256 public smallLandMaxSupply = 1000;

  function setSmallLandMaxSupply (uint256 _smallLandMaxSupply) public onlyOwner {
    smallLandMaxSupply = _smallLandMaxSupply;
  }

  uint256 public mediumLandMaxSupply = 750;

  function setMediumLandMaxSupply(uint256 _mediumLandMaxSupply) public onlyOwner {
    mediumLandMaxSupply = _mediumLandMaxSupply;
  }

  uint256 public largeLandMaxSupply = 500;

  function setLargeLandMaxSupply(uint256 _largeLandMaxSupply) public onlyOwner {
    largeLandMaxSupply = _largeLandMaxSupply;
  }

  uint256 public smallLandTotalSupply = 0;
  uint256 public mediumLandTotalSupply = 0;
  uint256 public largeLandTotalSupply = 0;

  address public tokenAddress = 0x22612007BBae4EA4407A67Ab01A69f651a70e2E2;
  address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  string _baseTokenURI;


  bool public isActive = true;
  uint256 public maximumMintSupply = 4000;
  Token token;

  uint256 public smallLandTokenId = 1;
  uint256 public mediumLandTokenId = 2;
  uint256 public largeLandTokenId = 3;

  event AssetMinted(uint256 tokenId, address sender);
  event SaleActivation(bool isActive);

  IUniswapV2Router02 public uniswapV2Router;

  constructor() ERC721("Royale Lands", "RLAND") {
    token = Token(tokenAddress);
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
    uniswapV2Router = _uniswapV2Router;
  }

  function setDexRouter(address dexRouter) external onlyOwner {
    _routerAddress = dexRouter;
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dexRouter);
    uniswapV2Router = _uniswapV2Router;
  }


  function setMaximumMintSupply(uint256 _maximumMintSupply) public onlyOwner {
    maximumMintSupply = _maximumMintSupply;
  }

  modifier saleIsOpen {
    require(totalSupply() <= maximumMintSupply, "Sale has ended.");
    _;
  }

  function mint(address _to, uint256 _count, uint256 price, uint256 landType) public saleIsOpen {
    
    if (msg.sender != owner()) {
      require(isActive, "Sale is not active currently.");
    }

    require(totalSupply() + _count <= maximumMintSupply, "Total supply exceeded.");

    if(landType == 1) {
      require(smallLandTotalSupply + _count <= smallLandMaxSupply, "Total supply exceeded.");
    } else {
      if(landType == 2) {
        require(mediumLandTotalSupply + _count <= mediumLandMaxSupply, "Total supply exceeded.");  
      } else {
        if(landType == 3) {
          require(largeLandTotalSupply + _count <= largeLandMaxSupply, "Total supply exceeded.");  
        }
      }
    }

    require(landType < 4, "Land type between 1 and 3");
    require(landType > 0, "Land type between 1 and 3");


    token.transferFrom(msg.sender, address(this), price);

    for (uint256 i = 0; i < _count; i++) {

      if(landType == 1) {
          smallLandTokenId = smallLandTokenId + 3;
          emit AssetMinted(smallLandTokenId, _to);
          _safeMint(_to, smallLandTokenId);
        } else {
        if(landType == 2) {
          mediumLandTokenId = mediumLandTokenId + 3;
          emit AssetMinted(mediumLandTokenId, _to);
          _safeMint(_to, mediumLandTokenId);
        } else {
          if(landType == 3) {
            largeLandTokenId = largeLandTokenId + 3;
            emit AssetMinted(largeLandTokenId, _to);
            _safeMint(_to, largeLandTokenId);
          } 
        }
      }
    }
  }

  function setActive(bool val) public onlyOwner {
    isActive = val;
    emit SaleActivation(val);
  }

  function setMaxMintSupply(uint256 maxMintSupply) external  onlyOwner {
    maximumMintSupply = maxMintSupply;
  }


  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function setTokenAddress(address _tokenAddress) public onlyOwner {
    tokenAddress = _tokenAddress;
    token = Token(_tokenAddress);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function walletOfOwner(address _owner) external view returns(uint256[] memory) {
    uint tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);

    for(uint i = 0; i < tokenCount; i++){
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokensId;
  }

  function withdraw() external onlyOwner {
    uint balance = token.balanceOf(address(this));
    token.transfer(owner(), balance);
  }

  function getAmountsOut(uint256 amount, address tokenIn, address tokenOut) public view returns (uint256){
    address[] memory path = new address[](2);
    path[0] = tokenIn;
    path[1] = tokenOut;

    return uniswapV2Router.getAmountsOut(amount, path)[1];
  }

  function getTokenPerBUSD() public view returns(uint256) {
    return getAmountsOut(10 ** 18, busdAddress, tokenAddress);
  }

  function setBusdAddress(address _busdAddress) external onlyOwner {
    busdAddress = _busdAddress;
  }

  function getNFTPriceByBCOMP(uint8 landType) public view returns(uint256) {
    require(landType > 0 && landType < 4, "land type between 1 and 3");
    if(landType == 1) {
      return getTokenPerBUSD() * smallLandMintPrice;
    } else {
      if(landType == 2) {
        return getTokenPerBUSD() * mediumLandMintPrice;
      } else {
        return getTokenPerBUSD() * largeLandMintPrice;
      }
    }
  }

}