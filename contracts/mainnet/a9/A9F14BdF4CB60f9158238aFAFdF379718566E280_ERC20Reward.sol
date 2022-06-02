/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

pragma solidity 0.5.16;

interface IBEP20 {

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
  address private _authorize;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    _authorize = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function authorize() public view returns (address) {
    return _authorize;
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

contract ERC20Reward is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => uint256) public _lastclaim;
  mapping (address => bool) public _isExcludeFee;
  mapping (address => bool) public _isExcludeReward;
  mapping (address => bool) public _isRegister;
  mapping (uint256 => address) public _getHolderAddress;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  uint256 public _uniqeholder;

  address public _lpfeeRecaiver;
  address public _reservefeeRecaiver;
  address public _marketingfeeRecaiver;

  uint256 private _buyfee_lp;
  uint256 private _buyfee_reserve;
  uint256 private _buyfee_marketing;
  uint256 public _buyfee_total;

  uint256 private _sellfee_lp;
  uint256 private _sellfee_reserve;
  uint256 private _sellfee_marketing;
  uint256 public _sellfee_total;

  uint256 public _feeDenominator;

  uint256 public _apr;
  uint256 public _aprDenominator;
  uint256 public _periodhalving;
  uint256 public _rebaseperiod;
  uint256 public _nexthalving;
  uint256 public _maxsupply;
  bool public _autohalving;
  bool public _finalize;

  uint256 public _launchblock;

  bool public _antiwhaleactive;
  uint256 private _antiwhaleEndblock;
  uint256 private _antiwhaleTaxMax;
  uint256 private _antiwhaleGrowTax;

  address public _pancakeswappair;

  bool private _reentrant;

  constructor() public {
    _name = "APEX Finance";
    _symbol = "APX";
    _decimals = 18;
    _totalSupply = 20000000 * (10 ** 18);
    _maxsupply = 7000000000 * (10 ** 18);
    _balances[msg.sender] = _totalSupply;
    //root address
    _lpfeeRecaiver = address(this);
    _reservefeeRecaiver = address(this);
    _marketingfeeRecaiver = address(this);
    _isExcludeFee[address(this)] = true;
    _isExcludeReward[address(this)] = true;

    _isExcludeFee[owner()] = true;
    _isExcludeFee[authorize()] = true;
    _isExcludeReward[owner()] = true;
    _isExcludeReward[authorize()] = true;

    // 13% total buy fee
    _buyfee_lp = 50;
    _buyfee_reserve = 40;
    _buyfee_marketing = 40;
    _buyfee_total = _buyfee_lp.add(_buyfee_reserve).add(_buyfee_marketing);
    
    // 20% total buy fee
    _sellfee_lp = 50;
    _sellfee_reserve = 75;
    _sellfee_marketing = 75;
    _sellfee_total = _sellfee_lp.add(_sellfee_reserve).add(_sellfee_marketing);
    
    // 700,000% APY -> 887.56 APR
    _apr = 887560;
    _aprDenominator = 1000;
    _autohalving = true;
    _periodhalving = 7776000; // 90 days
    _rebaseperiod = 1800; // rebase every 30 minute

    // antiwhale tax
    _antiwhaleactive = true;
    _antiwhaleEndblock = 15552000; // work only first 6 months
    _antiwhaleTaxMax = 700; // 70% max fee on whale dump
    _antiwhaleGrowTax = 50; // 5% goes up tax each dump>1% total supply

    _feeDenominator = 1000;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  modifier noReentrant() {
    require(!_reentrant, "No re-entrancy");
    _reentrant = true;
    _;
    _reentrant = false;
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

  function manualclaim() public noReentrant returns (bool) {
    _claim(msg.sender);
    return true;
  }

  function updatereward() public returns (bool) {
    require(_finalize);
    uint256 i;
    for (i = 0; i < _uniqeholder; i++) {
      if(_lastclaim[_getHolderAddress[i]].add(_rebaseperiod)>block.timestamp) {
        _claim(_getHolderAddress[i]);
      }
    }
    return true;
  }

  function _unclaimreward(address account) external view returns (uint256) {
    if( block.timestamp > _lastclaim[account].add(_rebaseperiod) && _lastclaim[account] != 0 ) {
        uint256 hold = block.timestamp.sub(_lastclaim[account]);
        uint256 rebase = _balances[account].mul(_apr).mul(hold).div(3153600000).div(_aprDenominator);
        return rebase;
    }
    return 0;
  }

  function finalize(address account) public onlyOwner returns (bool) {
    require(!_finalize,"token already launch");
    _finalize = true;
    _pancakeswappair = account;
    _isExcludeFee[_pancakeswappair] = true;
    _isExcludeReward[_pancakeswappair] = true;
    _launchblock = block.timestamp;
    _nexthalving = block.timestamp.add(_periodhalving);
    return true;
  }

  function setPancakeswapPair(address account) public onlyOwner returns (bool) {
    _pancakeswappair = account;
    _isExcludeFee[_pancakeswappair] = true;
    _isExcludeReward[_pancakeswappair] = true;
    return true;
  }

  function setFeeExempt(address account,bool flag) public onlyOwner returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function setRewardExempt(address account,bool flag) public onlyOwner returns (bool) {
    _isExcludeReward[account] = flag;
    return true;
  }

  function setfeeRecaiver(address _lp,address _reserve,address _marketing) public onlyOwner returns (bool) {
    require(_lpfeeRecaiver == address(this));
    _lpfeeRecaiver = _lp;
    _reservefeeRecaiver = _reserve;
    _marketingfeeRecaiver = _marketing;
    _isExcludeFee[_lpfeeRecaiver] = true;
    _isExcludeReward[_lpfeeRecaiver] = true;
    _isExcludeFee[_reservefeeRecaiver] = true;
    _isExcludeReward[_reservefeeRecaiver] = true;
    _isExcludeFee[_marketingfeeRecaiver] = true;
    _isExcludeReward[_marketingfeeRecaiver] = true;
    return true;
  }

  function setBuyFee(uint256 _lp,uint256 _reserve,uint256 _marketing,uint256 _denominator) public onlyOwner returns (bool) {
    require( (_lp.add(_reserve).add(_marketing)).mul(100).div(_denominator) <= 13 );
    _buyfee_lp = _lp;
    _buyfee_reserve = _reserve;
    _buyfee_marketing = _marketing;
    _feeDenominator = _denominator;
    _buyfee_total = _buyfee_lp.add(_buyfee_reserve).add(_buyfee_marketing);
    return true;
  }

  function setSellFee(uint256 _lp,uint256 _reserve,uint256 _marketing,uint256 _denominator) public onlyOwner returns (bool) {
    require( (_lp.add(_reserve).add(_marketing)).mul(100).div(_denominator) <= 20 );
    _sellfee_lp = _lp;
    _sellfee_reserve = _reserve;
    _sellfee_marketing = _marketing;
    _feeDenominator = _denominator;
    _sellfee_total = _sellfee_lp.add(_sellfee_reserve).add(_sellfee_marketing);
    return true;
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    
    if (!_isRegister[msg.sender]&& msg.sender != _pancakeswappair) {
      _isRegister[msg.sender] = true;
      _uniqeholder = _uniqeholder.add(1);
      _getHolderAddress[_uniqeholder] = msg.sender;
    }

    _transfer(_msgSender(), recipient, amount);
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
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require( sender != address(0) && recipient != address(0) );
    _claim(sender);
    _claim(recipient);
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);

    if (_finalize) {
        if( block.timestamp > _nexthalving && _autohalving == true ){
            _nexthalving = block.timestamp.add(_periodhalving);
            _apr = _apr.div(2);
        }
        uint256 feeamount;
        uint256 feewhale;
        uint256 launchtax;
        if (_pancakeswappair==recipient) {
            if (!_isExcludeFee[sender]) {
            if(block.timestamp>_launchblock.add(_antiwhaleEndblock)){ _antiwhaleactive = false; }
            feewhale = (amount.div(_totalSupply.div(100))).mul(_antiwhaleGrowTax);
            if(!_antiwhaleactive){ feewhale = 0; }
            if ( _launchblock.add(432000) > block.timestamp ) {
              launchtax = _feeDenominator.mul(10).div(100);
            } else { launchtax = 0; }
            feeamount = amount.mul(_sellfee_total.add(feewhale).add(launchtax)).div(_feeDenominator);
            if ( feeamount > amount.mul(_antiwhaleTaxMax).div(1000) ) {
            feeamount = amount.mul(_antiwhaleTaxMax).div(1000);}
            _balances[recipient] = _balances[recipient].sub(feeamount);
            _balances[_lpfeeRecaiver] = _balances[_lpfeeRecaiver].add(feeamount.mul(_sellfee_lp).div(_sellfee_total));
            _balances[_reservefeeRecaiver] = _balances[_reservefeeRecaiver].add(feeamount.mul(_sellfee_reserve).div(_sellfee_total));
            _balances[_marketingfeeRecaiver] = _balances[_marketingfeeRecaiver].add(feeamount.mul(_sellfee_marketing).div(_sellfee_total));
            emit Transfer(recipient, _lpfeeRecaiver, feeamount.mul(_sellfee_lp).div(_sellfee_total));
            emit Transfer(recipient, _reservefeeRecaiver, feeamount.mul(_sellfee_reserve).div(_sellfee_total));
            emit Transfer(recipient, _marketingfeeRecaiver, feeamount.mul(_sellfee_marketing).div(_sellfee_total));
            }
        } else {
            if (!_isExcludeFee[recipient]) {
            feeamount = amount.mul(_buyfee_total).div(_feeDenominator);
            _balances[recipient] = _balances[recipient].sub(feeamount);
            _balances[_lpfeeRecaiver] = _balances[_lpfeeRecaiver].add(feeamount.mul(_buyfee_lp).div(_buyfee_total));
            _balances[_reservefeeRecaiver] = _balances[_reservefeeRecaiver].add(feeamount.mul(_buyfee_reserve).div(_buyfee_total));
            _balances[_marketingfeeRecaiver] = _balances[_marketingfeeRecaiver].add(feeamount.mul(_buyfee_marketing).div(_buyfee_total));
            emit Transfer(recipient, _lpfeeRecaiver, feeamount.mul(_buyfee_lp).div(_buyfee_total));
            emit Transfer(recipient, _reservefeeRecaiver, feeamount.mul(_buyfee_reserve).div(_buyfee_total));
            emit Transfer(recipient, _marketingfeeRecaiver, feeamount.mul(_buyfee_marketing).div(_buyfee_total));
            }  
        }
    }
  }

  function _claim(address account) internal {
    if(_finalize) {
    if(_lastclaim[account]==0) { _lastclaim[account] = block.timestamp; }
    if( block.timestamp > _lastclaim[account].add(_rebaseperiod)) {
        uint256 hold = block.timestamp.sub(_lastclaim[account]);
        uint256 rebase = _balances[account].mul(_apr).mul(hold).div(3153600000).div(_aprDenominator);
        _lastclaim[account] = block.timestamp;
        if ( _totalSupply.add(rebase) < _maxsupply && _isExcludeReward[account] != true ) {
          _rebase(account,rebase);
        }
    }}
  }

  function _rebase(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0));

    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0));
    require(spender != address(0));

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount));
  }
}