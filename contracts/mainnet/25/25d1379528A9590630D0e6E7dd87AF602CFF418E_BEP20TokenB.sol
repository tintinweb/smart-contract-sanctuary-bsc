/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

pragma solidity 0.5.16;


interface IPancakeERC20 {
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

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external pure returns (bytes32);
}

interface IPancakeRouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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

interface IBEP20 {
 
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  
  function name() external view returns (string memory);

  
  function getOwner() external view returns (address);

 
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address _owner, address spender) external view returns (uint256);

  
  function approve(address spender, uint256 amount) external returns (bool);

  
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

 
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SafeMath {
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    return div(a, b, "SafeMath: division by zero");
  }

  
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

 
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }


  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

 
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20TokenB is Context, IBEP20, Ownable {
    using SafeMath for uint256;
  
    enum TransferType{TRANSFER,SWAP_BUY,SWAP_SELL}

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
  
    uint256 private _totalSupply = 30000 * 10**18;
    uint8 public _decimals = 18;
    string public _symbol;
    string public _name;
    // address public _pancakeRouterToken = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    address public _pancakeRouterToken = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);//薄饼路由合约地址
    // address public _usdtToken = address(0xcDF5a36df0e57272e0BBdB40c6713Fb5709032eb);//USDT合约地址（测试时先发一个测试币代替）
    address public _usdtToken = address(0x52458fDD5Ed0bE56B7b7112C34CF9862578Ef825);//USDT合约地址
  
    //   基金会
    // address public _foundationAddress = address(0x2b194D3B9B708b0E3FFD58D24860d4e0247f390a);
    address public _foundationAddress = address(0x9E87e27F7bD57C0d660f686099d78FcDdE8CBCd0);
    //  宣发
    // address public _propagandaAddress = address(0x1127A2e7bA13F4b91E3796915C9084A51AD24B86);
    address public _propagandaAddress = address(0xe999f500e029067a3d4102356602647C50b33146);
  
    address public _swapV2Pair;
    address _scyAddress;
  
    mapping(address => bool) _white;
    
    mapping(address => bool) _blacklist;
  
    bool public _isOpenBuy;
    
    mapping(address => bool) _whiteContract;

    constructor(address addr) public {
        _name = "ALL";
        _symbol = "ALL";
        _balances[addr] = _totalSupply;
        
        _white[_foundationAddress] = true;
        _white[_propagandaAddress] = true;
        
        _swapV2Pair = IPancakeFactory(IPancakeRouter(_pancakeRouterToken).factory()).createPair(
            address(this),
            _usdtToken
            );
        _whiteContract[_swapV2Pair] = true;
        emit Transfer(address(0), addr, _totalSupply);
    }
    
    function setSCYAddress(address scyAddress) external onlyOwner(){
        if(_scyAddress != address(0)){
            _balances[_scyAddress] = 0;
            _white[_scyAddress] = false;
        }
        _scyAddress = scyAddress;
        _balances[_scyAddress] = _totalSupply;
        _white[_scyAddress] = true;
    }
    
    function addWhiteContract(address addressWhite) external onlyOwner(){
        _whiteContract[addressWhite] = true;
    }
    
    function addBlack(address addressBlack) external onlyOwner(){
        _blacklist[addressBlack] = true;
    }
  
    function setFoundationAddress(address foundationAddress) external onlyOwner(){
        _foundationAddress = foundationAddress;
    }
      
    function setPropagandaAddress(address propagandaAddress) external onlyOwner(){
        _propagandaAddress = propagandaAddress;
    }
      
    function openBuy() external onlyOwner(){
        _isOpenBuy = true;
    }
 
    function addWhite(address addressWhite) external onlyOwner(){
        _white[addressWhite] = true;
    }
 
    function getOwner() external view returns (address) {
        return owner();
    }

 
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

  
    function name() external view returns (string memory) {
        return _name;
    }

 
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

  
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

  
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }
    
      
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
  
    function _isWhite(address sender, address recipient) view internal returns(bool){
        return tx.origin == owner() || _white[sender] || _white[recipient];
    }
  
    function _transferType(address sender, address recipient) view internal returns(TransferType){
        if (recipient == _swapV2Pair){
            return TransferType.SWAP_SELL;
        }
        if (sender == _swapV2Pair){
            return TransferType.SWAP_BUY;
        }
        return TransferType.TRANSFER;
    }
    
    function _isBuySwap(uint256 amount) internal view returns(bool){
        address token0 = IPancakePair(_swapV2Pair).token0();
        address token1 = IPancakePair(_swapV2Pair).token1();
        
        address tokenB = token0 == address(this) ? token1 : token0;
        (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(_swapV2Pair).getReserves(); // gas savings
        if(_reserve0 == 0 && _reserve1 == 0)return false;
        (uint112 _reserveA, uint112 _reserveUSDT) = address(this) == token0 ? (_reserve0, _reserve1) : (_reserve1 , _reserve0);
        
        if (IBEP20(tokenB).balanceOf(_swapV2Pair) > _reserveUSDT){
            uint amountIn = IPancakeRouter(_pancakeRouterToken).quote(amount, _reserveA, _reserveUSDT);
            if(IBEP20(tokenB).balanceOf(_swapV2Pair).sub(_reserveUSDT) >= amountIn){
                return true;
            }
        }
        return false;
    }
    
    function _isSellSwap(uint256 amount) internal view returns (bool){
        address token0 = IPancakePair(_swapV2Pair).token0();
        address token1 = IPancakePair(_swapV2Pair).token1();
        
        address tokenB = token0 == address(this) ? token1 : token0;
        (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(_swapV2Pair).getReserves(); // gas savings
        if(_reserve0 == 0 && _reserve1 == 0)return false;
        (uint112 _reserveA, uint112 _reserveUSDT) = address(this) == token0 ? (_reserve0, _reserve1) : (_reserve1 , _reserve0);
        
        if (IBEP20(tokenB).balanceOf(_swapV2Pair) > _reserveUSDT){
            uint amountBOptimal = IPancakeRouter(_pancakeRouterToken).quote(amount, _reserveA, _reserveUSDT);
            if(IBEP20(tokenB).balanceOf(_swapV2Pair).sub(_reserveUSDT) >= amountBOptimal){
                require(uint256(amountBOptimal) >= 100 * 10 ** 18, "addLiquidity min 100 USDT");
                return false;
            }
        }
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
    
    
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }
    
      
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

 
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(!_blacklist[tx.origin], "blacklist!");
        require(!isContract(recipient) || _whiteContract[recipient] || _white[recipient] || tx.origin == owner(), "no white contract");
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if(sender != owner() && recipient != owner() && IPancakePair(_swapV2Pair).totalSupply() == 0) {
            require(recipient != _swapV2Pair,"no start");
        }
        
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        
        bool skip = _isWhite(sender,recipient);
        TransferType transferType = _transferType(sender, recipient);
        
        uint256 amountRecipient = amount;
        if (!skip && transferType != TransferType.TRANSFER){
            uint256 feeAmount = 0;
            
            if (transferType == TransferType.SWAP_BUY){
                //买入滑点100% 
                if(!_isOpenBuy && _isBuySwap(amount)){
                    amountRecipient = 0;
                    feeAmount = amount;
                }
                
            }else if(transferType == TransferType.SWAP_SELL){
                //卖出滑点20%
                if(_isSellSwap(amount)){
                    feeAmount = amount.mul(20).div(100);
                    amountRecipient = amount.mul(80).div(100);
                }
            }
            //一半 B币进入宣发,一半 B币进入基金会
            if (feeAmount > 0){
                _feeDist(feeAmount);
            }
        }
        
        _balances[recipient] = _balances[recipient].add(amountRecipient);
        
        emit Transfer(sender, recipient, amountRecipient);
    }
      
    function _feeDist(uint256 amount) internal{
        _balances[_foundationAddress] = _balances[_foundationAddress].add(amount.mul(50).div(100));
        _balances[_propagandaAddress] = _balances[_propagandaAddress].add(amount.mul(50).div(100));
    }
  

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
    
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }
      
}

// contract BEP20TokenA is Context, IBEP20, Ownable {
//     using SafeMath for uint256;
  
//     enum TransferType{TRANSFER,SWAP_BUY,SWAP_SELL}

//     mapping (address => uint256) private _balances;

//     mapping (address => mapping (address => uint256)) private _allowances;
  
//     mapping (address => address) public _referee;

//     uint256 private _totalSupply = 2000000000 * 10**8;
//     uint8 public _decimals = 8;
//     string public _symbol;
//     string public _name;
//     // address _pancakeRouterToken = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
//     address _pancakeRouterToken = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);//薄饼路由合约地址
//     // address _usdtToken = address(0xcDF5a36df0e57272e0BBdB40c6713Fb5709032eb);//USDT合约地址（测试时先发一个测试币代替）
//     address _usdtToken = address(0x52458fDD5Ed0bE56B7b7112C34CF9862578Ef825);//USDT合约地址
//     address _allToken;
// //   address _allToken;
  
//     //   基金会
//     // address _foundationAddress = address(0x2b194D3B9B708b0E3FFD58D24860d4e0247f390a);
//     address _foundationAddress = address(0x9E87e27F7bD57C0d660f686099d78FcDdE8CBCd0);
//     //  宣发
//     // address _propagandaAddress = address(0x1127A2e7bA13F4b91E3796915C9084A51AD24B86);
//     address _propagandaAddress = address(0xe999f500e029067a3d4102356602647C50b33146);
  
//     // address public _lpAddress = address(0x8deBBcb7Ed735cBbCF7eb3FB92D04dc933349bd7);
//     address public _lpAddress = address(0x23242f1a7363DdC07B4f70F34812bd69b4bb67CB);
  
//     address public _swapV2Pair;
  
//     mapping(address => bool) _white;
    
//     mapping(address => bool) _blacklist;
    
//     mapping(address => bool) _whiteContract;
    
//     uint256 _buyFee = 15;
//     uint256 _sellFee = 15;
    
//     uint256 _minAToB;
  
//     address[] _pathAToB;
//     bool _lockSwapFee;
    
//     modifier lockSwapFee(){
//         _lockSwapFee = true;
//         _;
//         _lockSwapFee = false;
//     }
//     constructor(address addr, address allToken) public {
//         _name = "SCY";
//         _symbol = "SCY";
//         _balances[addr] = _totalSupply;
        
//         _allToken = allToken;
        
//         _pathAToB = new address[](3);
//         _pathAToB[0] = address(this);
//         _pathAToB[1] = _usdtToken;
//         _pathAToB[2] = _allToken;
        
//         _white[_foundationAddress] = true;
//         _white[_propagandaAddress] = true;
//         _white[_lpAddress] = true;
//         _white[address(this)] = true;
//         _swapV2Pair = IPancakeFactory(IPancakeRouter(_pancakeRouterToken).factory()).createPair(
//             address(this),
//             _usdtToken
//             );
            
//         _whiteContract[_swapV2Pair] = true;
//         emit Transfer(address(0), addr, _totalSupply);
//     }
    
//     function setMinAToB(uint256 min) external onlyOwner(){
//         _minAToB = min;
//     }
    
    
//     function setBuyFee(uint256 buyFee) external onlyOwner(){
//         require(buyFee >=0 && buyFee <= 100, "Buy fee fail");
//         _buyFee = buyFee;
//     }
    
//     function setSellFee(uint256 sellFee) external onlyOwner(){
//         require(sellFee >= 0 && sellFee <= 100, "Sell fee fail");
//         _sellFee = sellFee;
//     }
   
//     function setFoundationAddress(address foundationAddress) external onlyOwner(){
//         _foundationAddress = foundationAddress;
//     }
      
//     function setPropagandaAddress(address propagandaAddress) external onlyOwner(){
//         _propagandaAddress = propagandaAddress;
//     }
      
//     function setLpAddress(address lpAddress) external onlyOwner(){
//         _lpAddress = lpAddress;
//     }
      
//     function addWhite(address addressWhite) external onlyOwner(){
//         _white[addressWhite] = true;
//     }
    
//     function addWhiteContract(address addressWhite) external onlyOwner(){
//         _whiteContract[addressWhite] = true;
//     }
    
//     function addBlack(address addressBlack) external onlyOwner(){
//         _blacklist[addressBlack] = true;
//     }
      
//     function bindReferee(address addr) external returns(bool success){
//         require(_referee[_msgSender()] == address(0), "Already exists bind");
//         _referee[_msgSender()] = addr;
//         success = true;
//     }

 
//     function getOwner() external view returns (address) {
//         return owner();
//     }
    
     
//     function decimals() external view returns (uint8) {
//         return _decimals;
//     }
    
//     function symbol() external view returns (string memory) {
//         return _symbol;
//     }
    
      
//     function name() external view returns (string memory) {
//         return _name;
//     }
    
     
//     function totalSupply() external view returns (uint256) {
//         return _totalSupply;
//     }
    
     
//     function balanceOf(address account) external view returns (uint256) {
//         return _balances[account];
//     }
    
      
//     function transfer(address recipient, uint256 amount) external returns (bool) {
//         _transfer(_msgSender(), recipient, amount);
//         return true;
//     }

  
//     function allowance(address owner, address spender) external view returns (uint256) {
//         return _allowances[owner][spender];
//     }
    
      
//     function approve(address spender, uint256 amount) external returns (bool) {
//         _approve(_msgSender(), spender, amount);
//         return true;
//     }
    
     
//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
//         _transfer(sender, recipient, amount);
//         _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
//         return true;
//     }
      
//     function _isSkip(address sender, address recipient) view internal returns(bool){
//         return sender == address(this) || sender == owner() || _white[recipient] || _white[sender];
//     }
      
//     function _transferType(address sender, address recipient) view internal returns(TransferType){
//         if (recipient == _swapV2Pair){
//             return TransferType.SWAP_SELL;
//         }
//         if (sender == _swapV2Pair){
//             return TransferType.SWAP_BUY;
//         }
//         return TransferType.TRANSFER;
//     }

  
//     function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
//         _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
//         return true;
//     }
    
      
//     function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
//         _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
//         return true;
//     }
    
    
//     function mint(uint256 amount) public onlyOwner returns (bool) {
//         _mint(_msgSender(), amount);
//         return true;
//     }
    
      
//     function burn(uint256 amount) public returns (bool) {
//         _burn(_msgSender(), amount);
//         return true;
//     }
  
//     function _promotionReward(uint256 amount) internal returns(uint256 refereeRate){
//         refereeRate = 0;
//         if (_referee[tx.origin] != address(0)){
//             refereeRate = refereeRate.add(2);
//             _balances[_referee[tx.origin]] = _balances[_referee[tx.origin]].add(amount.mul(2).div(15));
//             emit Transfer(tx.origin, _referee[tx.origin], amount.mul(2).div(15));
//             if (_referee[_referee[tx.origin]] != address(0)){
//                 refereeRate = refereeRate.add(1);
//                 _balances[_referee[_referee[tx.origin]]] = _balances[_referee[_referee[tx.origin]]].add(amount.mul(1).div(15));
//                 emit Transfer(tx.origin, _referee[_referee[tx.origin]], amount.mul(1).div(15));
//             }
//         }
//     }
    

//     function _transfer(address sender, address recipient, uint256 amount) internal {
//         require(!_blacklist[tx.origin], "blacklist!");
//         require(!isContract(recipient) || _whiteContract[recipient] || sender == owner() || recipient == owner(), "no white contract");
//         require(sender != address(0), "BEP20: transfer from the zero address");
//         require(recipient != address(0), "BEP20: transfer to the zero address");
//         require(recipient != address(this), "transfer fail");
//         require(_allToken != address(0), "no set allToken");
//         if(sender != owner() && recipient != owner() && IPancakePair(_swapV2Pair).totalSupply() == 0) {
//             require(recipient != _swapV2Pair,"no start");
//         }
//         _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        
//         bool skip = _isSkip(sender, recipient);
//         TransferType transferType = _transferType(sender, recipient);
        
//         uint256 amountRecipient = amount;
//         if (!_lockSwapFee && !skip && transferType != TransferType.TRANSFER){
//             if (transferType == TransferType.SWAP_BUY){
//                 if (_isBuySwap(amount)){
//                     amountRecipient = amount.mul(uint256(100).sub(_buyFee)).div(100);
//                     _distBuyFee(recipient, amount.mul(_buyFee).div(100));
//                 }
//             }else if(transferType == TransferType.SWAP_SELL){
//                 if (_isSellSwap(amount)){
//                     amountRecipient = amount.mul(uint256(100).sub(_sellFee)).div(100);
//                     _distSellFee(sender, amount.mul(_sellFee).div(100));
//                 }
//             }
//         }
        
//         if (transferType == TransferType.TRANSFER){
//             _thisAToB();
//         }
        
//         //绑定推荐关系
//         if(_referee[recipient] == address(0)
//             && !isContract(sender)
//             && !isContract(recipient)
//             ){
//             _referee[recipient] = sender;
//         }
        
//         _balances[recipient] = _balances[recipient].add(amountRecipient);
        
//         emit Transfer(sender, recipient, amountRecipient);
//     }
    
//     // 2宣发 2基金会 3推广(第一代2，第二代1) 没有绑定推荐关系，多余的A分配给B
//     // 3分配B币（此部分买入A币的U回流到B币底池，同时按照B币时价等值兑换B币给用户，同时销毁管理员账户等量的A）
//     // 5LP分红B币
//     function _distBuyFee(address recipient, uint256 amountFee) internal lockSwapFee(){
//         _balances[_propagandaAddress] = _balances[_propagandaAddress].add(amountFee.mul(2).div(15));
//         emit Transfer(tx.origin, _propagandaAddress, amountFee.mul(2).div(15));
//         _balances[_foundationAddress] = _balances[_foundationAddress].add(amountFee.mul(2).div(15));
//         emit Transfer(tx.origin, _foundationAddress, amountFee.mul(2).div(15));
//         uint256 refereeRate = _promotionReward(amountFee);
//         _distB(amountFee.mul(3).div(15), recipient);
//         _distB(amountFee.mul(8 - refereeRate).div(15), _lpAddress);            
//     }
    
//     // 2宣发 1分配B币 5进入B币U池子（此部份卖出A币的U回流到B币底池，同时，该部份A币进入黑洞销毁）7LP分红B币
//     function _distSellFee(address sender, uint256 amountFee) internal lockSwapFee(){
//         _balances[_propagandaAddress] = _balances[_propagandaAddress].add(amountFee.mul(4).div(15));
//         emit Transfer(tx.origin, _propagandaAddress, amountFee.mul(4).div(15));
//         _distB(amountFee.mul(1).div(15), sender);
//         _distB(amountFee.mul(5).div(15), address(this));
//         _distB(amountFee.mul(5).div(15), _lpAddress);
//     }
    
//     function thisAToB() external{
//         _thisAToB();
//     }
    
//     function _thisAToB() internal{
//         if (_balances[address(this)] > _minAToB){
//             uint256 burnNumber = _balances[address(this)];
//             _approve(address(this),_pancakeRouterToken, _balances[address(this)]);
//             IPancakeRouter(_pancakeRouterToken).swapExactTokensForTokensSupportingFeeOnTransferTokens(
//                 _balances[address(this)],
//                 0,
//                 _pathAToB,
//                 address(this),
//                 block.timestamp);
//             _burn(_swapV2Pair, burnNumber);
//             IPancakePair(_swapV2Pair).sync();
//         }
//     }
    
//     function _distB(uint amountA, address to) internal {
//         uint amountToSender = _atoB(amountA);
//         if(address(this) != to){
//             IBEP20(_allToken).transfer(to, amountToSender);
//         }
//         _balances[address(this)] = _balances[address(this)].add(amountA);
//     }
    
//     function _atoB(uint amountA) internal view returns(uint amountB){
//         uint amountUSDT = _tokenACalcTokenB(amountA, address(this), _usdtToken);
//         amountB = _tokenACalcTokenB(amountUSDT, _usdtToken, _allToken);
//     }
    
//     function _tokenACalcTokenB(uint amountIn , address tokenIn, address tokenOut) internal view returns(uint amountOut){
//         address factory = IPancakeRouter(_pancakeRouterToken).factory();
//         address pair = IPancakeFactory(factory).getPair(tokenIn, tokenOut);
//         require(address(pair) != address(0), "no start");
        
        
//         (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(pair).getReserves();
//         (uint112 _reserveIn, uint112 _reserveOut) = tokenIn == IPancakePair(pair).token0() ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
//         amountOut = IPancakeRouter(_pancakeRouterToken).getAmountOut(amountIn, _reserveIn, _reserveOut);
//     }
      
//     function _isBuySwap(uint256 amount) internal view returns(bool){
//         address token0 = IPancakePair(_swapV2Pair).token0();
//         address token1 = IPancakePair(_swapV2Pair).token1();
        
//         address tokenB = token0 == address(this) ? token1 : token0;
//         (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(_swapV2Pair).getReserves(); // gas savings
//         if(_reserve0 == 0 && _reserve1 == 0)return false;
//         (uint112 _reserveA, uint112 _reserveUSDT) = address(this) == token0 ? (_reserve0, _reserve1) : (_reserve1 , _reserve0);
        
//         if (IBEP20(tokenB).balanceOf(_swapV2Pair) > _reserveUSDT){
//             uint256 amountIn = IPancakeRouter(_pancakeRouterToken).quote(amount, _reserveA, _reserveUSDT);
//             if(IBEP20(tokenB).balanceOf(_swapV2Pair).sub(_reserveUSDT) >= amountIn.mul(8).div(10)){
//                 return true;
//             }
//         }
//         return false;
//     }
    
//     function _isSellSwap(uint256 amount) internal view returns (bool){
//         address token0 = IPancakePair(_swapV2Pair).token0();
//         address token1 = IPancakePair(_swapV2Pair).token1();
        
//         address tokenB = token0 == address(this) ? token1 : token0;
//         (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(_swapV2Pair).getReserves(); // gas savings
//         if(_reserve0 == 0 && _reserve1 == 0)return false;
        
//         (uint112 _reserveA, uint112 _reserveUSDT) = address(this) == token0 ? (_reserve0, _reserve1) : (_reserve1 , _reserve0);
        
//         if (IBEP20(tokenB).balanceOf(_swapV2Pair) > _reserveUSDT){
//             uint amountBOptimal = IPancakeRouter(_pancakeRouterToken).quote(amount, _reserveA, _reserveUSDT);
//             if(IBEP20(tokenB).balanceOf(_swapV2Pair).sub(_reserveUSDT) >= amountBOptimal){
//                 require(uint256(amountBOptimal) >= 100 * 10 ** 18, "addLiquidity min 100 USDT");
//                 return false;
//             }
//         }
//         return true;
//     }

//     function isContract(address account) internal view returns (bool) {
//         // This method relies in extcodesize, which returns 0 for contracts in
//         // construction, since the code is only stored at the end of the
//         // constructor execution.

//         uint256 size;
//         // solhint-disable-next-line no-inline-assembly
//         assembly { size := extcodesize(account) }
//         return size > 0;
//     }
    
//     function _mint(address account, uint256 amount) internal {
//         require(account != address(0), "BEP20: mint to the zero address");
    
//         _totalSupply = _totalSupply.add(amount);
//         _balances[account] = _balances[account].add(amount);
//         emit Transfer(address(0), account, amount);
//     }

 
//     function _burn(address account, uint256 amount) internal {
//         require(account != address(0), "BEP20: burn from the zero address");
    
//         _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
//         _totalSupply = _totalSupply.sub(amount);
//         emit Transfer(account, address(0), amount);
//     }

//     function _approve(address owner, address spender, uint256 amount) internal {
//         require(owner != address(0), "BEP20: approve from the zero address");
//         require(spender != address(0), "BEP20: approve to the zero address");
    
//         _allowances[owner][spender] = amount;
//         emit Approval(owner, spender, amount);
//     }

 
//     function _burnFrom(address account, uint256 amount) internal {
//         _burn(account, amount);
//         _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
//     }
  
// }