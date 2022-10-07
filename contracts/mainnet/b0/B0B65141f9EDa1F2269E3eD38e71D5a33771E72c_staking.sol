pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";


contract staking is DataPlayer {
    // uint256 private constant  ONE_Month = 180*24*60*60;
    uint256 private constant  ONE_Month = 10;
    using SafeMath for uint;

    constructor()
    public {
        _owner = msg.sender; 
        _startTime = block.timestamp;
    }



   function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
 
    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        require(element != 0, "0"); 
        array[0] = element;
        return array;
    }

    function Mining(uint256 amount ) public payable   {
 

        NFT.safeBatchTransferFrom(msg.sender,address(Z_address),_asSingletonArray(1),_asSingletonArray(amount),"0x00");

 
        registry(msg.sender );
        uint256 id = _playerAddrMap[msg.sender];
        uint256  Daynumber = getdayNum( block.timestamp); 

        uint256 endTime =Daynumber.add(180) ;
 
 
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
                _playerMap[id].list[index].settlementTime = Daynumber;
                _playerMap[id].list[index].amount = amount;
                 _playerMap[id].list[index].staticBalance = amount;
                 _playerMap[id].list[index].endTime = endTime;
            }else{
                InvestInfo memory info = InvestInfo(id, amount, Daynumber, amount, endTime);
                _playerMap[id].list.push(info);
            }


            netAlltotle = netAlltotle.add(amount);
            everydaytotle [Daynumber] = netAlltotle;

    }
 


 



    
 
    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); // 用户不存在
        _; 
    }

    function registry(address playerAddr ) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
 
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].addr = playerAddr;
 
           
        }

        
    }


  
    

    function Validate() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo[] memory investList = _playerMap[id].list;
        uint256 staticaAmount = 0;

        uint256  Daynumber = getdayNum( block.timestamp); 


        for (uint256 i = 0; i < investList.length; i++) {
                if(Daynumber>investList[i].settlementTime ){
                uint256 yield = getInvestInfo(Daynumber,id,i);
                staticaAmount =  staticaAmount.add(yield);
            }
        }
 
        _playerMap[id].MiningIncome =  _playerMap[id].MiningIncome.add(staticaAmount);
        _AMAIns.mint(staticaAmount);
  
    }
 
    function Withdrawal() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require( _playerMap[id].MiningIncome > 0, "0"); 
        _AMAIns.transfer(msg.sender,_playerMap[id].MiningIncome);
        _playerMap[id].MiningIncome =  0;

    }
 
         
 
 
    function getInvestInfo(uint256  Daynumber,uint256  id ,uint256  index  ) internal   returns(uint256)  {


        InvestInfo  memory investList = _playerMap[id].list[index];
            uint256 investAmt = investList.amount;
            uint256 yield = 0;
            uint256 daytotle = 0;
            uint256 DaynumberLS = Daynumber;

            if(Daynumber >  investList.endTime){
                DaynumberLS =  investList.endTime;
            }

        for (uint256 i = investList.settlementTime; i < DaynumberLS; i++) {

            uint256 today = getReduceCycle(Daynumber);


            if(everydaytotle[i] == 0)
            {
                everydaytotle[i] = daytotle;
            }
            else
            {
                daytotle = everydaytotle[i];
            }

            
         


           yield =yield.add(investAmt.mul(today).div(daytotle));    
 
        }

            everydaytotle[Daynumber] = daytotle;
           if(Daynumber >= investList.endTime){
                    delete _playerMap[id].list[index];
            }else{
                _playerMap[id].list[index].settlementTime = Daynumber;

            }
        return yield;
        
    } 

  



    
    function getReduceCycle(uint256  Daynumber  ) public pure returns(uint256)  {
    
        uint256  cycle = Daynumber.div(30); 
        uint256  produce = AMA_Convert(53933); 


        for (uint256 i = 1; i <= cycle; i++) {
            produce = produce.mul(98382).div(100000);

        }
        return produce;
        
   
      }
 
 
         
 










 




  























   
}