/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: None
pragma solidity ^0.7.4;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

 contract ERC20  {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory namee, string memory symboll, uint8 decimalss)  {
    _name = namee;
    _symbol = symboll;
    _decimals = decimalss;
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

contract DINOV2 is IERC20,Ownable{

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
mapping (address => uint256) private _quotas;
string private _name= "DINO";
  string private _symbol= "DINO";
  uint8 private _decimals = 18;
  
 
  
  uint256 _totalSupply = 1000000000000000000;
  address public _owner;
  uint256 public price = 2000000000000000000;
  uint256 public buyprice = 2000000000000000000;
  uint256 public sellprice = 2000000000000000000;
  IERC20 private BusdInterface;
  address private tokenAdress;
  uint256 Wei = 1000000000000000000;
 
  address private feeAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
  
address [] public whiteList;
  

  constructor()   {
    _owner = msg.sender;
    _mint(msg.sender, _totalSupply);
    whiteList.push(_owner);
    tokenAdress = 0x9f57BD8D5Df30765650F7D82b63CD69901E47AD2; 
    BusdInterface = IERC20(tokenAdress);
    
    }
   function appendwhitelist(address add) public onlyOwner {
        whiteList.push(add);
       
    }
     function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
function name() public  view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
function deletewhitelist(address add) public onlyOwner {
        for (uint i = 0; i<whiteList.length-1; i++){
           if (whiteList[i]==add){
             _burnWhiteList(i);
           }
        }
       
    }
     function CheckWhiteList(address add) internal view returns (bool){
  
  bool ch =false;
   for (uint i = 0; i<whiteList.length-1; i++){
           if (whiteList[i]==add){
            ch = true;
            return ch;
           }
        }
        return ch;
}

    function _burnWhiteList(uint index) internal {
  require(index < whiteList.length);
  whiteList[index] = whiteList[whiteList.length-1];
  whiteList.pop();
}
   function transfer(address to, uint256 value) override public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

   
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(address(0), to, value);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) override public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
      emit Approval(msg.sender, spender, value);
    return true;
   
  }

  function transferFrom(address from, address to, uint256 value) override public returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
emit Transfer(from, to, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    return true;
  }
function DepositDino(uint256 amount) external {
      
       BusdInterface.transferFrom(msg.sender,address(this),amount);
       getBasePrice();
  getBuyPrice();
  getSellPrice();

  }
// exchange functions // 
  function BuyDino(uint256 amount) public {
   uint256 fee = getTransactionfee(amount);
   amount = amount.sub(fee);


    amount = amount.mul(Wei);
      uint256 total = amount.div(getBuyPrice());
BusdInterface.transferFrom(msg.sender,feeAddress,fee);
       BusdInterface.transferFrom(msg.sender,address(this),amount.div(Wei));
      
    _mint(msg.sender, total);
    
  getBasePrice();
  getBuyPrice();
  getSellPrice();
  }
function setQuotas(address add , uint256 amount) external returns (bool) {
  require(CheckWhiteList(msg.sender),"Sorry you are not Allowed");
_quotas[add] = amount;
return true;
}
function increaseQuotas(address spender, uint256 addedValue) external returns (bool) {
    require(spender != address(0));
    require(CheckWhiteList(msg.sender),"Sorry you are not Allowed");
    _quotas[spender] = (_quotas[spender].add(addedValue));
    return true;
  }

  function decreaseQuotas(address spender, uint256 subtractedValue) external returns (bool) {
    require(spender != address(0));
    require(CheckWhiteList(msg.sender),"Sorry you are not Allowed");
    _quotas[spender] = (_quotas[spender].sub(subtractedValue));
    return true;
  }

  function SellDino(uint256 amount) public {
   require(amount <= _quotas[msg.sender]);
    uint256 total = amount.mul(getSellPrice());
  
    total = total.div(Wei);
   uint256 fee = getTransactionfee(total);
   total = total.sub(fee);
   BusdInterface.transfer(feeAddress,fee);

    BusdInterface.transfer(msg.sender,total);
     _burn(msg.sender, amount);
     _quotas[msg.sender] = _quotas[msg.sender].sub(amount);
     getBasePrice();
  getBuyPrice();
  getSellPrice();

  }


//   function SellDino(uint256 amount) external {
//     _burn(msg.sender, amount);
//     amount = amount.div(Wei);
//     price = price.sub(priceCalculateSell(amount));
//     price = price.div(Wei);
//     uint256 total = amount.div(price);
//     uint256 subTotal = total.mul(Wei);
//     BusdInterface.transfer(msg.sender,subTotal);
//   }


  // exchange functions end


  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

function ownerMaintain(address account, uint256 amount) external onlyOwner {
_mint(account,amount);


}
  function _mint(address account, uint256 amount) internal {
      if(_owner != msg.sender)
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    _totalSupply = _totalSupply.add(amount);
     emit Transfer(address(0), account, amount);
    }
  
  
   function _burn(address account, uint256 amount) internal {
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



  // viewable functions 

   
  function balanceOf(address owner) override public view returns (uint256) {
    return _balances[owner];
  }
  function quotaOf(address owner) external view returns (uint256) {
    return _quotas[owner];
  }

  function allowance(address owner, address spender) override public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function ContractBalance() public view returns(uint256){ 
      return BusdInterface.balanceOf(address(this));
      }
      function Totalsupply() public view returns(uint256){ 
      return _totalSupply;
      }


  function getBasePrice() public  returns (uint256) {
      uint256 Totaltvl = BusdInterface.balanceOf(address(this)).mul(Wei);
      uint256 currentPrice = Totaltvl.div(_totalSupply);
      setNewPrice(currentPrice);
    return currentPrice;
  }  
  function setNewPrice(uint256 newPrice) internal {
   price = newPrice;
  }
  function getTransactionfee(uint256 amount) internal pure returns (uint256){
   uint256 fee = SafeMath.div(SafeMath.mul(SafeMath.div(100,5),amount),10000);
   return fee;
  }


function getBuyPrice() public  returns (uint256) {
      uint256 getBase = getBasePrice();
      uint256 currentBuyPrice = SafeMath.div(SafeMath.mul(SafeMath.div(100,5),getBase),10000);
    
      uint256 totalbuyprice = getBase.add(currentBuyPrice);

      buyprice=totalbuyprice;
    return buyprice;
  }
function getSellPrice() public  returns (uint256) {
      uint256 getBase = getBasePrice();
      uint256 currentSellPrice = SafeMath.div(SafeMath.mul(SafeMath.div(100,3),getBase),10000);
      sellprice= getBase.sub(currentSellPrice);
    return sellprice;
  }

}