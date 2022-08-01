/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external returns(uint256);
    function mint(address account, uint amount)external;
    function approve(address spender, uint amount) external returns (bool);
}
interface IPancakeFactory {
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

interface IPancakePair {
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
contract MINE {
    uint8  private _decimals;
    address public DEX=0x6e0c46Ec78525c4b238929265DfB61769823Fb20;
    address public Miner;
    address public pir;
    address public pinksale;
    mapping(address =>uint)public v1;
    mapping(address =>uint)public v2;
    mapping(address =>uint)public v3;
    mapping(address =>uint)public v1time;
    mapping(address =>uint)public v2time;
    mapping(address =>uint)public v3time;
    mapping(address =>uint)public v1Value;
    mapping(address =>uint)public v2Value;
    mapping(address =>uint)public v3Value;
    uint256 sumPower;
    constructor () public {
    }
    receive() external payable{
  }
  function buyMinerA()public{
      require(v1[msg.sender]==0);
      ERC20(DEX).transferFrom(msg.sender,address(this),10000 ether);
      v1[msg.sender]=10000 ether;
      v1time[msg.sender]=block.timestamp;
      v1Value[msg.sender]=0.000002318 ether;
      sumPower+=10000 ether;
      _swap(10000 ether);
  }
  function buyMinerB()public{
      require(v2[msg.sender]==0);
      ERC20(DEX).transferFrom(msg.sender,address(this),50000 ether);
      v2[msg.sender]=50000 ether;
      v2time[msg.sender]=block.timestamp;
      v2Value[msg.sender]=0.00001818 ether;
      sumPower+=50000 ether;
      _swap(50000 ether);
  }
  function buyMinerC()public{
      require(v3[msg.sender]==0);
      ERC20(DEX).transferFrom(msg.sender,address(this),100000 ether);
      v3[msg.sender]=100000 ether;
      v3time[msg.sender]=block.timestamp;
      v3Value[msg.sender]=0.00003939 ether;
      sumPower+=100000 ether;
      _swap(100000 ether);
  }
  function profitA()public{
    require(block.timestamp > v1time[msg.sender]);
    require(v1[msg.sender] >= 10000 ether);
    uint256 _time=block.timestamp-v1time[msg.sender];
    uint256 bnb=v1Value[msg.sender] *_time;
    if(address(this).balance >= bnb){
        msg.sender.transfer(bnb);
        v1time[msg.sender]=block.timestamp;
        v1Value[msg.sender]=v1Value[msg.sender]*99/100;
    }else{
        v1time[msg.sender]=block.timestamp;
    }
  }
  function profitB()public{
    require(block.timestamp > v2time[msg.sender]);
    require(v2[msg.sender] >= 50000 ether);
    uint256 _time=block.timestamp-v2time[msg.sender];
    uint256 bnb=v2Value[msg.sender] *_time;
    if(address(this).balance >= bnb){
        msg.sender.transfer(bnb);
        v2time[msg.sender]=block.timestamp;
        v2Value[msg.sender]=v2Value[msg.sender]*99/100;
    }else{
        v2time[msg.sender]=block.timestamp;
    }
  }
  function profitC()public{
    require(block.timestamp > v3time[msg.sender]);
    require(v3[msg.sender] >= 100000 ether);
    uint256 _time=block.timestamp-v3time[msg.sender];
    uint256 bnb=v3Value[msg.sender] *_time;
    if(address(this).balance >= bnb){
        msg.sender.transfer(bnb);
        v3time[msg.sender]=block.timestamp;
        v3Value[msg.sender]=v3Value[msg.sender]*99/100;
    }else{
        v3time[msg.sender]=block.timestamp;
    }
  }
  function getUserA(address addr)public view returns(uint256){
      uint256 t;
      uint256 V;
      if(block.timestamp > v1time[addr]){
          t=block.timestamp - v1time[addr];
          V=v1Value[addr]*t;
          if(address(this).balance >= V){
          return V;
          }else{
          return 0;
         }
      }else{
          return 0;
      }
  }
  function getUserB(address addr)public view returns(uint256){
      uint256 t;
      uint256 V;
      if(block.timestamp > v2time[addr]){
          t=block.timestamp - v2time[addr];
          V=v2Value[addr]*t;
          if(address(this).balance >= V){
          return V;
          }else{
          return 0;
         }
      }else{
          return 0;
      }
  }
  function getUserC(address addr)public view returns(uint256){
      uint256 t;
      uint256 V;
      if(block.timestamp > v3time[addr]){
          t=block.timestamp - v3time[addr];
          V=v3Value[addr]*t;
          if(address(this).balance >= V){
          return V;
          }else{
          return 0;
         }
      }else{
          return 0;
      }
  }
  function setMinr(address addr)public{
        ERC20(DEX).approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 2 ** 256 - 1);
    }
  function _swap(uint value)public{
        swapTokensForEth(0x10ED43C718714eb63d5aA57B78B54704E256024E,DEX,address(this),value);
    }
    function swapTokensForEth(
        address routerAddress,
        address ceotoken,
        address miner,
        uint256 tokenAmount
    ) public {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = ceotoken;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        // make the swap
        IPancakeRouter02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            miner,
            block.timestamp
        );
    }
}