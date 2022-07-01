/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

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
  event Gift(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Context {
  constructor ()  { }
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }
  function _msgData() internal view returns (bytes memory) {
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
  constructor ()  {
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

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
   
  }
}

contract RozmaBitNetwork is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint128 private _fee_burn;
  uint128 private _min_trans;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  bool private _isPassed=true;
  bool private _isMin=true;
  bool private fee_asBurn=true; 
  constructor()  {
    _name = "RozmaBit";
    _symbol = "RB";
    _decimals = 9;
    _totalSupply = 100000000000 ; //10**11 100 000 000 000 
    _balances[msg.sender] = _totalSupply;
    _min_trans =1500;
    _fee_burn =2;
    emit Transfer(address(0), address(this), _totalSupply);
  }

  function getOwner() override external view returns (address) {
    return owner(); 
  }

  function decimals() override external view returns (uint8) {
    return _decimals;
  }

  function symbol() override external view returns (string memory) {
    return _symbol;
  }

  function name() override external view returns (string memory) {
    return _name;
  }

  function totalSupply() override external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) override external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) override external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
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
  function update_fees(uint128 burn,uint128 mintrans) public onlyOwner returns (bool) {
    _fee_burn = burn;//def => 5
    _min_trans = mintrans;//def =>320
    return true;
  }
  function change_state_transfer(bool _st) public onlyOwner returns (bool) {
      _isPassed=_st;
      return true;
  }

    function _transfer(address sender, address recipient, uint256 amount) internal {
   
      require(_isPassed, "Transactions are currently blocked");
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
       //require(_balances[sender] >= amount, " Inventory is not enough");
       if(_isMin){
        require(_min_trans < amount, "Inventory is not enough");
       }
       if(fee_asBurn){
         fee_balancer(sender);
          amount = amount - _fee_burn;
       }
    
      
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function fee_balancer(address sender) internal  returns(bool){
    
      _balances[sender] = _balances[sender].sub(_fee_burn, "BEP20: burn amount exceeds balance");
      _totalSupply = _totalSupply.sub(_fee_burn);
      return true;
    }

    function _mint(address account, uint256 amount) internal {
      require(account != address(0), "BEP20: mint to the zero address");

      _totalSupply = _totalSupply.add(amount);
      _balances[account] = _balances[account].add(amount);
      emit Transfer(address(30), account, amount);
    }

    function _burn(address account, uint256 amount) public onlyOwner {
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
    function transferOwnership(address newOwner) public onlyOwner {
     
       _transfer(owner(),newOwner,_balances[owner()]);  
       _transferOwnership(newOwner);
    //
   
  }
}


contract RozmaBitNetworks is RozmaBitNetwork {
    using SafeMath for uint;


    address payable reff; // adresse 
    address  _owner;
    uint public saleStart = block.timestamp;  // 
    uint public tokenPrice = 1600000000000; // 10000; // 1  = 0.0001 BNB 0.000000125
    uint public mull;
    uint public RaisedAmount; // Montant de la 
    uint public Raisedtoken; // Montant de la 
    uint128  mod;
    uint64 public minInvestment =  3300000000000000; // 0,033 BNB
    uint64 public minInvestment_first_invest =  2200000000000000; // 0,0066 BNB
    uint32 max = 1400;
    uint16 min = 1000;
    address[] private first_invest_whitelist;



 
    enum State {beforeStart, running, afterEnd, halted} // Etat de l'ICO (avant le début, en cours, terminé, interrompu (ça va reprendre))
    State public icoState;
    
    

    constructor() 
    {
     
        icoState = State.beforeStart;
        mull=1;
        mod=100000000000;
        _owner = msg.sender;
   
    
    }
  
   

    event Invest(address investor, uint value, uint token);

    // Interruption de l'ICO.
    function halted() public onlyOwner {
        icoState = State.halted;
    }

    function lift() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
       
    }
    // Redemarrage de l'ICO
    function unhalted() public onlyOwner {
        icoState = State.running;
    }
    function first_invest_whitelists() public view returns(address[] memory) {
       return first_invest_whitelist;
    }
    function changeprice(uint _price) public onlyOwner {
      tokenPrice = _price;
    } 
    
    
    
    function changemul(uint _mull) public onlyOwner {
      mull = _mull;
    }

    function getCurrentState() public view returns (State) {
        if(icoState == State.halted){
            return State.halted;
        } else if (block.timestamp >= saleStart) {
            return State.running;
        } else {
            return State.beforeStart;
        }
    }

    function getbalance_value() public view returns(uint){
     return address(this).balance;
    }

    function Invest_first() payable public returns (bool) {
 

        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment_first_invest, 'Value is less than minimum');

  
        RaisedAmount = RaisedAmount.add(msg.value);

    
        uint rand_number =random();
        // rand_number = rand_number+get_balance_doge();
        _balances[msg.sender] = _balances[msg.sender].add( rand_number);
        _balances[owner()] = _balances[owner()].sub( rand_number);
         emit Transfer(owner(), msg.sender,   rand_number);
      
         emit Invest(msg.sender, msg.value, 0);

 
         first_invest_whitelist.push(msg.sender);
         return true;
    }

  

    function buy() payable public returns (bool) {
    
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment, 'Value is less than minimum');
      
        uint tokenAmount = msg.value.div(tokenPrice);

           uint tokens = tokenAmount.div(mull);
  
        RaisedAmount = RaisedAmount.add(msg.value);

        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        _balances[owner()] = _balances[owner()].sub(tokens);
        emit Transfer(owner(), msg.sender, tokens);
        
   
        emit Transfer(owner(), msg.sender, tokens);
        emit Invest(msg.sender, msg.value, 0);
    
    
        return true;
    }
     
    

///**********************************************************************************************/Refrral

    function random() public view returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % max;
    randomnumber = randomnumber + min;
    return randomnumber;
}
///**********************************************************************************************
    receive() payable external {
     Invest_first();
    }
}