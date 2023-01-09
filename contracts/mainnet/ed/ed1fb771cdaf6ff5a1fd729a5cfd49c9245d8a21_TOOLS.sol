/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface STAKING {
  function getFee() external view returns (uint);
}

interface IUniswapV2Router {

  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
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


  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}


contract TOOLS {

  modifier onlyOwner() {
        require(_isOwner[msg.sender], "Ownable: caller is not the owner");
        _;
    }

    address private UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private STAKING_ADDRESS = 0x97330cACB18042CDF9eF133a0B460265A512Bf8E;
    address private VAULT_ADDRESS = 0x66aa88C3eEE056F7a51995074D1A493fc332e2E3;
    mapping (address => bool) private _isOwner;

    constructor () {
      _isOwner[msg.sender] = true;
    }
   
   
   function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
    uint FEE = STAKING(STAKING_ADDRESS).getFee();
    payable(address(VAULT_ADDRESS)).transfer(FEE);
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address[] memory path;
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

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    
    function swapTokensForETH(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
    uint FEE = STAKING(STAKING_ADDRESS).getFee();
    payable(address(VAULT_ADDRESS)).transfer(FEE);
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address[] memory path;
    path = new address[](2);
    path[0] = _tokenIn;
    path[1] = _tokenOut;
    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForETH(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    function swapETHForTokens(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
    uint FEE = STAKING(STAKING_ADDRESS).getFee();
    payable(address(VAULT_ADDRESS)).transfer(FEE);
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address[] memory path;
    path = new address[](2);
    path[0] = _tokenIn;
    path[1] = _tokenOut;
    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactETHForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    function swapWithFees(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
      

    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address[] memory path;
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

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    
     function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {
        address[] memory path;
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
        
        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  

    function changeNativeTokenAddress(address addr) external onlyOwner {
      WETH = addr;
    }
    function changeStakingAddress(address addr) external onlyOwner {
      STAKING_ADDRESS = addr;
    }
    function changeVaultAddress(address addr) external onlyOwner {
      VAULT_ADDRESS = addr;
    }
    function changeRouterAddress(address addr) external onlyOwner {
      UNISWAP_V2_ROUTER = addr;
    }

    receive() external payable {}

}