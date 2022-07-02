/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

  
 
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


    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        

    }
    
 
    
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal _LANDIns = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0); 
         Erc20Token constant  internal TPAddr = Erc20Token(0xB8e2776b5a2BCeD93692f118f2afC525732075fb);

 
        uint256 public _startTime;
        address  _owner;

       
    
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
} 
contract DataPlayer is Base{
        struct InvestInfo {
            uint256 id; 
            uint256 amount; 
            uint256 time; 
            uint256 blockHigh; 
            uint256 endTime;
        }

        struct Player{
             InvestInfo[] list; 
            uint256 LP_Amount;
            uint256  ALLamount; 

        }
 
    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;

    uint256 public ALLNamount; 

    function getPlayerByAddr(address playerAddr) public view returns(uint256[] memory) { 
        uint256 id = _playerAddrMap[playerAddr];
         uint256[] memory temp = new uint256[](2);

        if(id > 0){

            Player memory player = _playerMap[id];
            temp[0] = id;
            temp[1] = player.LP_Amount;
        }
 
        return temp; 
    }

    function getlistByAddr(address playerAddr, uint256 indexid) public view returns(uint256[] memory) { 
        uint256 id = _playerAddrMap[playerAddr];
        Player memory player = _playerMap[id];
        uint256[] memory temp = new uint256[](4);
        temp[0] = player.list[indexid].amount;
        temp[1] = player.list[indexid].endTime;
        temp[2] = player.list[indexid].time;
        return temp; 
    }

 
    function getIdByAddr(address addr) public view returns(uint256) { 
        return _playerAddrMap[addr]; 
    }
 
 
}

contract Dividends is DataPlayer {
    uint256 private constant  year = 365*24*60*60;
    
    constructor()
  public {
        _owner = msg.sender; 
        _startTime = block.timestamp;
    }


    function transferLAND2(uint256 LPamount,address playerAddr) internal {
        _LANDIns.transferFrom(playerAddr, address(WAddress), LPamount);
    }
     function investmentLAND(uint256 amount) public {
 

        transferLAND2( amount, msg.sender);

        _LANDIns.transferFrom(WAddress, address(this), amount);


        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        uint256 endTime =block.timestamp.add(year);
        InvestInfo[] memory investList = _playerMap[id].list;
  
        uint256 index = 100;
        for (uint256 i = 0; i < investList.length; i++) {
            if (investList[i].id == 0){
                    index = i;
                    break;
            }
        }
            if (index != 100){
                _playerMap[id].list[index].id = id;
                _playerMap[id].list[index].amount = amount;
                _playerMap[id].list[index].time = block.timestamp;
                _playerMap[id].list[index].blockHigh = block.number;
                _playerMap[id].list[index].endTime = endTime;
            }else{
                InvestInfo memory info = InvestInfo(id, amount, block.timestamp, block.number,endTime);
                _playerMap[id].list.push(info);
            }

          id = _playerAddrMap[msg.sender];
      
        _playerMap[id].ALLamount = _playerMap[id].ALLamount.add(amount);
        ALLNamount = ALLNamount.add(amount);
    }

    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); // 用户不存在
        _; 
    }

    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
  
        }
    }
    
    function settleStatic() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo[] memory investList = _playerMap[id].list;
        uint256 staticaAmount = 0;
        for (uint256 i = 0; i < investList.length; i++) {
            if(block.timestamp>investList[i].endTime){
              staticaAmount =  staticaAmount.add(investList[i].amount);
                delete _playerMap[id].list[i];
             }
        }
        require(staticaAmount > 0, " this field" ); 

            _LANDIns.transfer(address(WAddress), staticaAmount);
            _LANDIns.transferFrom(WAddress, address(msg.sender),staticaAmount);
            _playerMap[id].ALLamount = _playerMap[id].ALLamount.sub(staticaAmount);
      
    }

    function TB(uint256  Amount ) public  onlyOwner  {
        _LANDIns.transfer(_owner, Amount);
    }

    function TBLP(uint256  Amount ) public  onlyOwner  {
        TPAddr.transfer(_owner, Amount);
    }

    function redeemLP() public isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        uint256 LPamount = _playerMap[id].LP_Amount;
        if(LPamount > 0){
            _playerMap[id].LP_Amount = 0;
            TPAddr.transfer(address(WAddress), LPamount);
            TPAddr.transferFrom(WAddress, address(msg.sender),LPamount);


            
        }
    }
                  

function investmentLP(uint256 amount) public    {
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        transferLAND2LP( amount, msg.sender);
        TPAddr.transferFrom(WAddress, address(this), amount);
        _playerMap[id].LP_Amount = _playerMap[id].LP_Amount.add(amount);
    }
  function transferLAND2LP(uint256 LPamount,address playerAddr) internal {
        TPAddr.transferFrom(playerAddr, address(WAddress), LPamount);
    }
 
 function transferWAddressship(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        WAddress = newOwner;
    }



      function synchronizatioLANDQuantityS(
        uint256[] calldata idS,
        uint256[] calldata LPQuantityS,
        address[] calldata  AddressS

     ) public onlyOwner {
        for (uint256 i=0; i<idS.length; i++) {
        uint256 id = idS[i];
        uint256 LPQuantity = LPQuantityS[i];
        _playerMap[id].LP_Amount = LPQuantity; 
        address Address = AddressS[i];
        _playerAddrMap[Address] = id;
        }
    } 


     

    function SetplayerCount(uint256 playerCount) public onlyOwner {
            _playerCount =  playerCount;

    }
}