/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
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


    }

    interface Erc20Token { 
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
    
    contract Base {
        using SafeMath for uint;
        Erc20Token public LAND2   = Erc20Token(0xe9Db7b620a5b8b41445A81b882d44B561c30C6De);
 
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
    uint256 public oneDay = 86400; 
    struct Player{
        uint256 id; 
        address selfAddress; 
        uint256 LANDQuantity; 
        uint256 investAmtLAND; 
        uint256 investtDayNum; 
        uint256 settlementDayNum; 
        uint256 superior; 
        address superiorAddress;
    }
    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); // 用户不存在
        _; 
    }
 
    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    mapping(uint256 => uint256) public everydaytotle; 
    mapping(uint256 => uint256) public everydayBDtotle; 
     uint256 public AllNetworkComputing;

     uint256 public quota; 
 
    function getIdByAddr(address addr) public view returns(uint256) {
        return _playerAddrMap[addr]; 
    }

      function getPlayerByAddr(address addr) public view returns(uint256) {
        return _playerAddrMap[addr]; 
    }

     function getdayNum(uint256 time) public view returns(uint256) {
        return (time.sub(_startTime)).div(oneDay);
    }


    function getPlayerByaddress(address addr) public view returns(uint256[] memory,address,address) { 
        uint256 id = _playerAddrMap[addr];
        Player memory player = _playerMap[id];
        uint256[] memory temp = new uint256[](6);
        temp[0] = player.id;
        temp[1] = player.LANDQuantity;
        temp[2] = player.investAmtLAND;
        temp[3] = player.investtDayNum;
        temp[4] = player.settlementDayNum;
        temp[5] = player.superior;
        return (temp,addr,player.superiorAddress); 
    }
}
 
 contract LANDpledge is DataPlayer {
     constructor()
   public {
        _owner = msg.sender; 
        _startTime = block.timestamp;
    }
   
 
    function WithdrawalLAND() public payable isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require(  id > 0, "1");
        if(_playerMap[id].LANDQuantity > 0){
            LAND2.transfer(msg.sender, _playerMap[id].LANDQuantity);
            LANDdividend( id,_playerMap[id].LANDQuantity,  1);
            _playerMap[id].LANDQuantity = 0;
        }
    }



  function LANDdividend(uint256 id, uint256 Quantity, uint256 round) internal {
        if(round <= 13){
          
            uint256 superiorid = _playerMap[id].superior;
            if(superiorid > 0){
                uint256 dividend = Quantity;
                if(round == 1){
                    dividend = Quantity.mul(100).div(1000);
                }else if(round == 2){
                    dividend = Quantity.mul(80).div(1000);
                }else if(round == 3){
                    dividend = Quantity.mul(50).div(1000);
                }else if(round == 4){
                    dividend = Quantity.mul(30).div(1000);
                }else if(round == 5){
                    dividend = Quantity.mul(20).div(1000);
                }else if(round == 6){
                    dividend = Quantity.mul(20).div(1000);
                }else if(round == 7){
                    dividend = Quantity.mul(20).div(1000);
                }else if(round == 8){
                    dividend = Quantity.mul(10).div(1000);
                }else if(round == 9){
                    dividend = Quantity.mul(10).div(1000);
                }else if(round == 10){
                    dividend = Quantity.mul(10).div(1000);
                }else{
                    dividend = Quantity.mul(5).div(1000);
                }
                LAND2.transfer(_playerMap[id].superiorAddress, dividend);
                if(_playerMap[superiorid].superior > 0){
                    LANDdividend(_playerMap[id].superior,Quantity,round.add(1));
                }
            }
        }
    }
 
    function ReleasePledge() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].investAmtLAND > 0, "<0");
        uint256 Daynumber =  getdayNum(block.timestamp);
        require(Daynumber.sub(_playerMap[id].investtDayNum) >= 120, "<120");
        if(_playerMap[id].settlementDayNum != Daynumber){
            js(msg.sender,Daynumber);
        }
        LAND2.transfer(msg.sender, _playerMap[id].investAmtLAND);
        everydaytotle[Daynumber] = everydaytotle[Daynumber].sub(_playerMap[id].investAmtLAND);
        AllNetworkComputing = AllNetworkComputing.sub(_playerMap[id].investAmtLAND);
        _playerMap[id].investAmtLAND = 0;
    }
  
    function investment(uint256 LPamount,address playerAddr) public   {
        uint256 superiorId = _playerAddrMap[playerAddr];
        AllNetworkComputing = AllNetworkComputing.add(LPamount);
        uint256 Daynumber =  getdayNum(block.timestamp);
        LAND2.transferFrom(msg.sender, address(this), LPamount);
        registry(msg.sender,LPamount,Daynumber); 
        uint256 id = _playerAddrMap[msg.sender];

          if(superiorId > 0  ){
        bool  PD = JudgeSuperior(superiorId ,id);
        if(PD){
            _playerMap[id].superior = superiorId;
            _playerMap[id].superiorAddress = playerAddr;
        }
        }
        everydaytotle[Daynumber] = AllNetworkComputing;
    }

    function registry(address playerAddr,uint256 InvestmentQuantity,uint256 Daynumber) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount;
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].selfAddress = playerAddr; 
            _playerMap[_playerCount].LANDQuantity = 0;
            _playerMap[_playerCount].settlementDayNum = Daynumber;
            _playerMap[_playerCount].investAmtLAND = InvestmentQuantity.mul(95).div(100);
            _playerMap[_playerCount].investtDayNum = Daynumber;
        }else{
            if(_playerMap[id].settlementDayNum != Daynumber&&_playerMap[id].investAmtLAND > 0 ){
                js(playerAddr,Daynumber);
            }
            _playerMap[id].investAmtLAND = _playerMap[id].investAmtLAND.add(InvestmentQuantity.mul(95).div(100));
            _playerMap[id].settlementDayNum = Daynumber;
            _playerMap[id].investtDayNum = Daynumber;
        }
    }

   function js(address playerAddr,uint256 Daynumber) internal{
        uint256 daytotle = 0;
        uint256 id = _playerAddrMap[playerAddr];
        uint256 investAmtLAND = _playerMap[id].investAmtLAND;
        uint256 LANDQuantity = 0;
        for (uint256 m = _playerMap[id].settlementDayNum; m < Daynumber; m++) {
            if(everydaytotle[m] == 0)
            {
                everydaytotle[m] = daytotle;
            }
            else
            {
                daytotle = everydaytotle[m];
            }
            LANDQuantity =LANDQuantity.add(investAmtLAND.mul(quota).div(daytotle));
        }
        if(everydaytotle[Daynumber] == 0){
            everydaytotle[Daynumber] = daytotle;
        }
        _playerMap[id].LANDQuantity = _playerMap[id].LANDQuantity.add(LANDQuantity);
        _playerMap[id].settlementDayNum = Daynumber;
     }


// 用户结算
    function playerSettlement() public  isRealPlayer  {
        uint256 Daynumber =  getdayNum(block.timestamp);

        uint256 id = _playerAddrMap[msg.sender];

        js(  msg.sender,  Daynumber);

        _playerMap[id].settlementDayNum = Daynumber;
     
    }

    function JudgeSuperior(uint256 superior, uint256  id) internal  returns(bool ) {
        if(superior > 0  ){
            if (superior == id){
                return false;
            }else{
                JudgeSuperior(_playerMap[superior].superior,id);
            }
        }
         
        return true;
       
    }

    function TB(uint256 LAND2amount) public onlyOwner   {
        LAND2.transfer(msg.sender,LAND2amount);
    }

    function setquota(uint256 LAND2amount) public onlyOwner   {
        quota = LAND2amount; 
    }

   
}