/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

pragma solidity ^0.5.16;
//این توکن با قابلیت تنظیم فی تراکنش توسط مالک در هرزمان  .  و تعین مقدار نگهداری هر کیف پول از این توکن
interface IBEP20 {
 
  function totalSupply() external view returns (uint256);

  
  function decimals() external view returns (uint8);

  
   
  function symbol() external view returns (string memory);

  
  function name() external view returns (string memory);

  
  function getOwner() external view returns (address);

  
  function balanceOf(address account) external view returns (uint256);

  
  // * @dev Moves `amount` tokens from the caller's account to `recipient`.
  // *
   
   //
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address _owner, address spender) external view returns (uint256);

  
  function approve(address spender, uint256 amount) external returns (bool);

  
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

 
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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

  
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
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
contract blacklists is Ownable{
mapping(address=>bool) isBlacklisted;

    function blackList(address _user) public onlyOwner {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
        // emit events as well
    }
    
    function removeFromBlacklist(address _user) public onlyOwner {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
        // emit events as well
    }
    
    function transferr(address _to , uint256 _value) public {
        require(!isBlacklisted[_to], "Recipient is backlisted");
        // remaining transfer logic
    }
}
contract BEP20Token is Context, IBEP20, Ownable ,blacklists {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  address marketing = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
  uint256 Fee;
  mapping (address => mapping (address => uint256)) private _allowances;
   uint256 maxWallet ;
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
    

  constructor() public {
       //  maxWallet = _amount;
    _name = "test";
    _symbol = "tfst";
    _decimals = 18;
    _totalSupply = 10000000 * 10 ** 18 ;
    _balances[msg.sender] = _totalSupply;
    
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  
  function getOwner() external view returns (address) {
    return owner();
  }

  
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  
  function name() external view returns (string memory) {
    return _name;
  }

  
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  

   function setMaxwallet(uint MaxWallet)public onlyOwner{
        maxWallet  = MaxWallet;
   }
   function setFee(uint fee)public onlyOwner{
        Fee = fee;
   }

  function transfer(address recipient, uint256 _amount) external returns (bool) {
       
    _transfer(_msgSender(), recipient, _amount);
    return true;
  }

  
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }


  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

 
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
       
    _balances[sender] -=amount;
    _balances[marketing] +=Fee;
    uint256 pureAmount = (amount - Fee);
    _balances[recipient] = _balances[recipient]+pureAmount;
    emit Transfer(sender, recipient, pureAmount);
    emit Transfer(sender,marketing,Fee);
  }


  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

 
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}