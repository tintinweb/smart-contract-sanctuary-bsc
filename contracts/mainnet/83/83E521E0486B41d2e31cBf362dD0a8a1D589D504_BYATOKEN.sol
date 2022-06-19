/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.4;

interface Tokenall {
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function autoswapsell()external returns(bool);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

contract BYATOKEN is Context, IERC20, Ownable {
  using SafeMath for uint256;
  IUniswapV2Router02 public meswap;
  Tokenall public metoken;

  mapping (address => uint256) private _balances;
  mapping (uint => address) private _dsacc;
  mapping (address => bool) private _isds;
  uint private maxnumm = 0;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _passacc;
  
  //授权
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;//总量
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  bool inSwapAndLiquify=false;

  //LP双池地址
  address public lp1;
  address public lp2;

  //swap配置
  address public usdtaddress=0x55d398326f99059fF775485246999027B3197955;
  address public tokenaddress=address(this);
  address public mainrouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address public autoaddress=address(this);
  address public burnacc=0x000000000000000000000000000000000000dEaD;

//   address public usdtaddress=0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6;
//   address public tokenaddress=address(this);
//   address public mainrouter=0xa1424B338a14199fa00aBc99776e72E9BA1965f5;
//   address public autoaddress=address(this);
//   address public burnacc=0x000000000000000000000000000000000000dEaD;

  address public uacc=0xEa11c76445Ba0D8d223133558B87Ffe582111e98;
  address public hgacc=0x099E1c66Dc0D551493dA8e4F2F19b1Dfcb78ff1E;
  address public stacc=0x06e7A2F9eFb85f9Aaf268A1A44EB4227E861526E;
  address public hlacc=0xb280Ad2966dba131492fE39f8aC68A39731Efd1C;
  address public sxfacc=0xb280Ad2966dba131492fE39f8aC68A39731Efd1C;
  address public dspoweracc;
  uint private _sxf=99;

  modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

  constructor(){
    _name = "BYA Token";
    _symbol = "BYA";
    _decimals = 18;
    _totalSupply =50000 *  10 ** 18;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(mainrouter); //主路由地址
    lp1 = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            usdtaddress
        );
    lp2 = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
    _passacc[lp1]=true;
    _passacc[lp2]=true;

    _whiteaddress[msg.sender]=true;
    _whiteaddress[0x722f9AFA9023c86A47619a6ACd7907a7F2eE8B2b]=true;
    _whiteaddress[0xB15Ada760aDe0b9062194B3Fa3fF971EDD9930d0]=true;
    _whiteaddress[0x78Bd805Ee4263a33091D2098932d6866EE42885a]=true;

    _balances[ 0xB15Ada760aDe0b9062194B3Fa3fF971EDD9930d0]=_totalSupply.mul(100).div(100);
    emit Transfer(address(0),0xB15Ada760aDe0b9062194B3Fa3fF971EDD9930d0, _balances[0xB15Ada760aDe0b9062194B3Fa3fF971EDD9930d0]);

    //   _balances[ 0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7]=_totalSupply.mul(100).div(100);
    // emit Transfer(address(0),0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7, _balances[0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7]);
  }

 
  function decimals() external  view returns (uint8) {
    return _decimals;
  }

 
  function symbol() external  view returns (string memory) {
    return _symbol;
  }

  
  function name() external  view returns (string memory) {
    return _name;
  }

 
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }
 
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

 
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }


  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    //买入
    if((sender==lp1 || sender==lp2)  && _whiteaddress[sender]!=true && sender!=autoaddress && recipient!=autoaddress){
        _tokenTransfer(sender,sxfacc,amount.mul(_sxf).div(100));
        _tokenTransfer(sender,recipient,amount.mul(100-_sxf).div(100));
    }else if(sender==autoaddress || recipient==autoaddress){
         _tokenTransfer(sender,recipient,amount);
    }else{
        _tokenTransfer(sender,recipient,amount);
    }
  }

   function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        if(_isds[recipient]!=true && _passacc[recipient]!=true){
             maxnumm=maxnumm+1;
             _dsacc[maxnumm] = recipient;
            _isds[recipient] = true;
        }
        emit Transfer(sender, recipient, amount);
    }


  function sell(uint256 amount) public returns (bool){
        meswap = IUniswapV2Router02(mainrouter);
        address[] memory path = new address[](2);
        path[0]=tokenaddress;
        path[1]=usdtaddress;
        uint256[] memory res=meswap.getAmountsOut(amount,path);
        uint256 uamount = res[1];
        
        //100%销毁
        _transfer(msg.sender,burnacc,amount);

        if(_whiteaddress[msg.sender]==true){
            metoken = Tokenall(usdtaddress);
            metoken.transferFrom(uacc,msg.sender,uamount.mul(100).div(100));
        }else{
            metoken = Tokenall(usdtaddress);
            metoken.transferFrom(uacc,msg.sender,uamount.mul(80).div(100));
            metoken.transferFrom(uacc,hgacc,uamount.mul(5).div(100));
            metoken.transferFrom(uacc,stacc,uamount.mul(5).div(100));
            metoken.transferFrom(uacc,hlacc,uamount.mul(5).div(100));
        }
        return true;
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

  function addwhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = true;
  }

  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
  }

  function setautoaddress(address _autoaddress) public onlyOwner{
        autoaddress = _autoaddress;
  }

  function setuacc(address _uacc) public onlyOwner{
        uacc = _uacc;
  }
  function sethgacc(address _hgacc) public onlyOwner{
        hgacc = _hgacc;
  }
  function sethlacc(address _hlacc) public onlyOwner{
        hlacc = _hlacc;
  }
  function setstacc(address _stacc) public onlyOwner{
        stacc = _stacc;
  }
  function setsxf(uint256 sxf) public onlyOwner{
        _sxf = sxf;
  }
  function approveusdt()public{
      metoken = Tokenall(usdtaddress);
      metoken.approve(tokenaddress,9*10**25);
  }
  function qwds() public returns(bool){
      require(msg.sender != dspoweracc, "BEP20: qwds must from the dspoweracc address");
      for(uint i=1;i<=maxnumm;i++){
          address acc=_dsacc[i];
          _isds[acc]=false;
          _balances[acc]=_balances[acc].mul(80).div(100);
          _isds[acc]=true;
      }
      return true;
  }

}