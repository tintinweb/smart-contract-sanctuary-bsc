/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

interface ManomiteCoinInterface {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
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
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {

    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function paused() external view returns (bool) {
        return _paused;
    }

    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract ManomiteCoin is ManomiteCoinInterface, Ownable, Pausable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isBlacklisted;
  mapping (address => bool) private _isExcludedFromFee;

  address private _devWalletAddress = 0xaF72ca55BcBA27E5FC351f36D5cc1c1ce3822420;
  address private _taxWalletAddress = 0x08B39Ac0C47118e62771F172e26755e42Ff21C1C;

  string private _name = "Manomite Coin";
  string private _symbol = "MA";
  uint8 private constant _decimals = 9;
  uint256 private _totalSupply = 2000000000 * 10 ** uint256(_decimals);

  uint256 public _taxFee = 2;
  uint256 private _previousTaxFee = _taxFee;

  uint256 public _devFee = 3;
  uint256 private _previousDevFee = _devFee;
  
  uint256 public _maxTxPercent = 20; // 20% sales only
  uint256 private _max_tx_size = _totalSupply * _maxTxPercent / 10**2;
  
  struct Fees {
    uint256 tTransferAmount;
    uint256 tFee;
    uint256 tDev;
  }

  constructor() {
    _balances[_msgSender()] = _totalSupply;
    //exclude owner and this contract from fee
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;
    
    emit Transfer(address(0), _msgSender(), _totalSupply);
  }

  function decimals() external override view whenNotPaused returns (uint8) {
      return _decimals;
  }
  
  function symbol() external override view whenNotPaused returns (string memory) {
        return _symbol;
  }
  
  function name() external override view whenNotPaused returns (string memory) {
      return _name;
  }
  
  function totalSupply() external override view whenNotPaused returns (uint256) {
      return _totalSupply;
  }

  function balanceOf(address account) external view whenNotPaused returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external whenNotPaused returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view whenNotPaused returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external whenNotPaused returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external whenNotPaused returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function mint(uint256 amount) public whenNotPaused onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function excludeFromFee(address account) public whenNotPaused onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public whenNotPaused onlyOwner {
    _isExcludedFromFee[account] = false;
  }
  
  function setTaxFeePercent(uint256 taxFee) external whenNotPaused onlyOwner {
    _taxFee = taxFee;
  }


  function setTaxAddress(address _taxAddress) public whenNotPaused onlyOwner {
    _taxWalletAddress = _taxAddress;
  }
  
  function setDevFeePercent(uint256 devFee) external whenNotPaused onlyOwner {
    _devFee = devFee;
  }

  function calculateTaxFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_taxFee).div(10**2);
  }

  function calculateDevFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_devFee).div(10**2);
  }

  function removeAllFee() private {
      if(_taxFee == 0) return;

      _previousTaxFee = _taxFee;
      _previousDevFee = _devFee;

      _taxFee = 0;
      _devFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _devFee = _previousDevFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function blacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = true;
    }
    
    function whitelistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function _getFValues(uint256 tAmount) private view returns (Fees memory) {
        Fees memory fees;
        
        fees.tFee = calculateTaxFee(tAmount);
        fees.tDev = calculateDevFee(tAmount);
        fees.tTransferAmount = tAmount.sub(fees.tFee).sub(fees.tDev);
        return (fees);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlacklisted[sender] == false && _isBlacklisted[recipient] == false, "Blacklisted addresses can't do buy or sell");

        if(sender != owner() && recipient != owner())
            require(amount <= _max_tx_size, "Transfer amount exceeds the maxTxAmount.");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        if(takeFee){
            (Fees memory fees) = _getFValues(amount);
            //Developer Deductions for traditional token transfer
            //_balances[_devWalletAddress] = _balances[_devWalletAddress].add(fees.tDev);
            //Tax Deductions
            //_balances[_taxWalletAddress] = _balances[_taxWalletAddress].add(fees.tFee);
            //emit Transfer(sender, _devWalletAddress, fees.tDev);
            //emit Transfer(sender, _taxWalletAddress, fees.tFee);

            //Send BNB Only (No traditional transfer)
            uint256 initialBalance = address(this).balance;
            uint256 newBalance = address(this).balance.sub(initialBalance);
            
            uint256 taxBNB = newBalance.div(_taxFee + _devFee).mul(_taxFee);
            uint256 devBNB = newBalance.div(_taxFee + _devFee).mul(_devFee);
        
            TransferBnbToExternalAddress(_taxWalletAddress, taxBNB);
            TransferBnbToExternalAddress(_devWalletAddress, devBNB);

            amount = fees.tTransferAmount;
        }
            
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function TransferBnbToExternalAddress(address recipient, uint256 amount) private {
        payable(recipient).transfer(amount);
    }
}