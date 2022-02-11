/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity 0.4.26;
// pragma solidity 0.5.16;


interface Prosus_AMM_interfaz {
    function buy(address _playerAddress) payable external returns(uint256);
    function sell(uint256 _amountOfTokens) external;
    function reinvest() external;
    function withdraw() external;
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function balanceOf(address _customerAddress) view external returns(uint256);
    function myDividends(bool _includeReferralBonus) external view returns(uint256);
    function totalSupply() external view returns (uint256);
//  function decimals() external view returns (uint8);
//  function symbol() external view returns (string memory);
//  function name() external view returns (string memory);
//  function approve(address spender, uint256 amount) external returns (bool);
}
interface BEP20_interfaz {
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Prosus_Hold_deploy {
    event HoldCreado(address indexed owner, address indexed ProsusHold);
    
    mapping (address => address) public ProsusHolder;
    
    function esBuenInversionista() public view returns (bool) {return ProsusHolder[msg.sender] != address(0);}
    
    function miHold() external view returns (address) {  
        require(esBuenInversionista(), "Todavía no eres un buen inversionista!");
        return ProsusHolder[msg.sender];
    }
    
    function create(uint256 _unlockAfterNDays) public {
        require(!esBuenInversionista(), "Ahora eres un buen inversionista!");
        require(_unlockAfterNDays >= 0); //YKB
        
        address owner = msg.sender;
        ProsusHolder[owner] = new Hold(owner, _unlockAfterNDays);
        emit HoldCreado(owner, ProsusHolder[owner]);
    }
}

contract Hold {
    Prosus_AMM_interfaz constant Prosus_AMM_instancia = Prosus_AMM_interfaz(0x0435e7936af50CF2fbb8048e29BD8C3A9a750Df1);
//    BEP20_interfaz constant BEP20_contrato = BEP20_interfaz(msg.sender);

    address public developer = 0x92E378cC7867f71220A60De15545b02B1AeEd3D1; // www.prosuscorp.com

    address public owner;
    uint256 public creationDate;
    uint256 public unlockAfterNDays;
    
    modifier timeLocked() {
        require(now >= creationDate + unlockAfterNDays * 1 days);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _owner, uint256 _unlockAfterNDays) public {
        owner = _owner;
        unlockAfterNDays =_unlockAfterNDays;
        creationDate = now;
    }
    
    function() public payable {}
    
    function isLocked() public view returns(bool) {return now < creationDate + unlockAfterNDays * 1 days;}
    function lockedUntil() external view returns(uint256) {return creationDate + unlockAfterNDays * 1 days;}
    
    function extendLock(uint256 _howManyDays) external onlyOwner {
        uint256 newLockTime = unlockAfterNDays + _howManyDays;
        require(newLockTime > unlockAfterNDays);
        unlockAfterNDays = newLockTime;
    }
    
    function withdraw() external onlyOwner {owner.transfer(address(this).balance);}
    function reinvest() external onlyOwner {Prosus_AMM_instancia.reinvest();}
    function transfer(address _toAddress, uint256 _amountOfTokens) external timeLocked onlyOwner returns(bool) {return Prosus_AMM_instancia.transfer(_toAddress, _amountOfTokens);}
    
    function buy() external payable onlyOwner {Prosus_AMM_instancia.buy.value(msg.value)(developer);}
    function buyWithBalance() external onlyOwner {Prosus_AMM_instancia.buy.value(address(this).balance)(developer);}

//    function balanceOf() external view returns(uint256) {return Prosus_AMM_instancia.balanceOf(address(this));}
    function dividendsOf() external view returns(uint256) {return Prosus_AMM_instancia.myDividends(true);}
    
    function withdrawDividends() external onlyOwner {
        Prosus_AMM_instancia.withdraw();
        owner.transfer(address(this).balance);
    }
    
    function sell(uint256 _amount) external timeLocked onlyOwner {
        Prosus_AMM_instancia.sell(_amount);
        owner.transfer(address(this).balance);
    }


  function name() external view returns (string memory) {
    return "Prosus dev02d";
  }
  function symbol() external view returns (string memory) {
    return "dev02d";
  }
  function decimals() external view returns (uint8) {
    return 12;
  }
  function totalSupply() external view returns (uint256) {
    return Prosus_AMM_instancia.totalSupply();
  }
  // function mint(uint256 amount) public onlyOwner returns (bool) {
// //    _mint(_msgSender(), amount);
    // return true;
  // }  
  function balanceOf() external view returns(uint256) {
    return Prosus_AMM_instancia.balanceOf(address(this));
//return 77000000000000;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
//  mapping (address => mapping (address => uint256)) private _allowances;
  function _approve(address creador, address spender, uint256 amount) internal {
    require(creador != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

//    _allowances[owner][spender] = amount;
//    emit Approval(creador, spender, amount);
  }
  
}