pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";


contract ARRpledge is DataPlayer {
    uint256 private constant  ONE_Month = 30*24*60*60;
    // uint256 private constant  ONE_Month = 30 ;
          using SafeMath for uint;

    constructor()
  public {
      
        _owner = msg.sender; 
        // _startTime = block.timestamp;
    }

        // struct InvestInfo {
        //     uint256 id; 
        //     uint256 TokenId; 
        //     uint256 amount; 
        //     uint256 startTime; 
        //     uint256 endTime;
        // }
     function investment(  uint256 MineModel) public payable   {
         registry(msg.sender);
        MinerSelection(MineModel) ;
        // uint256 id = _playerAddrMap[msg.sender];
        // uint256 endTime = block.timestamp.add(ONE_Month);
        // InvestInfo[] memory investList = _playerMap[id].first_Mining_machine.sow;
  
        // uint256 index = 10000;
        // for (uint256 i = 0; i < investList.length; i++) {
        //     if (investList[i].id == 0){
        //             index = i;
        //             break;
        //     }
        // }
            // if (index != 10000){
            //     _playerMap[id].first_Mining_machine.sow[index].id = id;
            //     _playerMap[id].first_Mining_machine.sow[index].amount = amount;
            //     _playerMap[id].first_Mining_machine.sow[index].startTime = block.timestamp;
            //     _playerMap[id].first_Mining_machine.sow[index].endTime = endTime;
            // }else{
            //     InvestInfo memory info = InvestInfo(id, amount, block.timestamp,  endTime);
            //     _playerMap[id].list.push(info);
            // }


                    // _eptIns.transferFrom(msg.sender, address(this), amount);

    }
  
    function MinerSelection(uint256 MineModel) private    {

        uint256 Tokenid = 0;

        if(MineModel< 3){
            Tokenid = 1;
            
        }else if(MineModel > 4){
            Tokenid = 3;

        }else{
             Tokenid = 2;
        }

        uint256 endTime = block.timestamp.add(ONE_Month);
        uint256 id = _playerAddrMap[msg.sender];
        uint256 amount = 10000000000000000000000000000000000000000000000000000000000000000;
        uint256 Mininglimit = _userMininglimit[msg.sender][MineModel];
        Mininglimit = Mininglimit.add(1);
        
        InvestInfo[] memory investList =   _userMining[msg.sender][MineModel];

        if(MineModel == 1){
        require(Mininglimit <= 10, "limit 10"); // 用户不存在
        
           amount = 100000000000000000;
        }
        else if(MineModel == 2){
                    require(Mininglimit <= 8, "limit 8"); // 用户不存在

        //   investList = _playerMap[id].first_Mining_machine.watering;
           amount = 300000000000000000;

        }
        else if(MineModel == 3){
        // investList = _playerMap[id].first_Mining_machine.applyFertilizer;
           amount = 5000000000000000000000;
        require(Mininglimit <= 5, "limit 5"); // 用户不存在

        }
        else if(MineModel == 4){
            // investList = _playerMap[id].first_Mining_machine.Harvest;
           amount = 10000000000000000000000;

        }

        else if(MineModel == 5){
            //  investList = _playerMap[id].Second_Mining_machine.miniature;
           amount = 2000000000000000000;
        require(Mininglimit <= 10, "limit 10"); // 用户不存在

        }
        else if(MineModel == 6){
        //    investList = _playerMap[id].Second_Mining_machine.Smalltype;
           amount = 30000000000000000000;
                    require(Mininglimit <= 8, "limit 8"); // 用户不存在

        }
        else if(MineModel == 7){
    //    investList = _playerMap[id].Second_Mining_machine.medium_sized;
           amount = 100000000000000000000;
        require(Mininglimit <= 6, "limit 6"); // 用户不存在

        }
        else if(MineModel == 8){
        //    investList = _playerMap[id].Second_Mining_machine.large;
           amount = 300000000000000000000;
        require(Mininglimit <= 3, "limit 3"); // 用户不存在

        }
        else if(MineModel == 9){
            // investList = _playerMap[id].Second_Mining_machine.giant;
           amount = 500000000000000000000;
        require(Mininglimit <= 2, "limit 2"); // 用户不存在

        }
        else if(MineModel == 10){
        //   investList = _playerMap[id].Second_Mining_machine.super_sized;
           amount = 1000000000000000000000;

        }
        else if(MineModel == 11){
        //  investList = _playerMap[id].Second_Mining_machine.cloud;
           amount = 3000000000000000000000;

        }else {
            require(false, "MineModel fil"); // 用户不存在

        }



            uint256 index = 10000;
        for (uint256 i = 0; i < investList.length; i++) {
            if (investList[i].id == 0){
                    index = i;
                    break;
            }
        }
            if (index != 10000){
                _userMining[msg.sender][MineModel][index].id = id;
                _userMining[msg.sender][MineModel][index].amount = amount;
                _userMining[msg.sender][MineModel][index].startTime = block.timestamp;
                _userMining[msg.sender][MineModel][index].endTime = endTime;

 
 



            }else{



                InvestInfo memory info = InvestInfo(id, Tokenid,amount, block.timestamp,  endTime);

                _userMining[msg.sender][MineModel].push(info);

    //     if(MineModel == 1){

    //      _playerMap[id].first_Mining_machine.sow.push(info);

    //       }
    //     else if(MineModel == 2){
    //        _playerMap[id].first_Mining_machine.watering.push(info);

    //     }
    //     else if(MineModel == 3){
    //        _playerMap[id].first_Mining_machine.applyFertilizer.push(info);

    //     }
    //     else if(MineModel == 4){
    //        _playerMap[id].first_Mining_machine.Harvest.push(info);

    //     }

    //     else if(MineModel == 5){
    //          investList = _playerMap[id].Second_Mining_machine.miniature;
 
    //     }
    //     else if(MineModel == 6){
    //        investList = _playerMap[id].Second_Mining_machine.Smalltype;
 
    //     }
    //     else if(MineModel == 7){
    //    investList = _playerMap[id].Second_Mining_machine.medium_sized;
 
    //     }
    //     else if(MineModel == 8){
    //        investList = _playerMap[id].Second_Mining_machine.large;
 
    //     }
    //     else if(MineModel == 9){
    //         investList = _playerMap[id].Second_Mining_machine.giant;
 
    //     }
    //     else if(MineModel == 10){
    //       investList = _playerMap[id].Second_Mining_machine.super_sized;
     

    //     }
    //     else if(MineModel == 11){
    //      investList = _playerMap[id].Second_Mining_machine.cloud;
 
    //     }
            }

        
        // if(MineModel< 3){
        //  _eptIns.transferFrom(msg.sender, address(this), amount);

        // }else if(MineModel > 4){
        //   _arrIns.transferFrom(msg.sender, address(this), amount);

        // }else{
        //     _ETIns.transferFrom(msg.sender, address(this), amount);

        //  }

        _userMininglimit[msg.sender][MineModel] = Mininglimit;
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
             
        }

        
    }

 

    function settleStatic(uint256 MineModel) public  isRealPlayer   {
 

        InvestInfo[] memory investList =   _userMining[msg.sender][MineModel];

         uint256 staticaAmount = 0;
           for (uint256 i = 0; i < investList.length; i++) {
            if(block.timestamp>investList[i].endTime){
                staticaAmount =  staticaAmount.add(investList[i].amount);
                 delete _userMining[msg.sender][MineModel][i];
            _userMininglimit[msg.sender][MineModel] = _userMininglimit[msg.sender][MineModel].sub(1);

             }
        }
        require(staticaAmount > 0  , " this field" ); 
        if(staticaAmount > 0){
 



        // if(MineModel< 3){
        //  _eptIns.transferFrom(msg.sender, address(this), staticaAmount);

        // }else if(MineModel > 4){
        //   _arrIns.transferFrom(msg.sender, address(this), staticaAmount);

        // }else{
        //     _ETIns.transferFrom(msg.sender, address(this), staticaAmount);

        //  }

 




        }
 
    }
 

 
 
     function settleStatic(uint256 MineModel,address userAddress  ) public    view  returns(uint256) {
          uint256 staticaAmount = 0;

        uint256 id = _playerAddrMap[msg.sender];


        if(id > 0){
            InvestInfo[] memory investList =   _userMining[userAddress][MineModel];

           for (uint256 i = 0; i < investList.length; i++) {
            if(block.timestamp>investList[i].endTime){
                staticaAmount =  staticaAmount.add(investList[i].amount);
              }
        }
        }
 
       
         
         return staticaAmount ;
  
    }
 

   

     function WithdrawalAirdropARR() public {
         uint256 airARRdrop =_playerARR[msg.sender];
          if(airARRdrop > 0){
            _arrIns.transfer(msg.sender, airARRdrop);
            _playerARR[msg.sender] = 0;
        }
    }

    function WithdrawalAirdropEPT() public  {
         uint256 Airdrop = _playerEPT[msg.sender];
          if(Airdrop > 0){
            _eptIns.transfer(msg.sender, Airdrop);
            _playerEPT[msg.sender] = 0;
        }
    }
 

    function WithdrawalAirdropATT() public  {
         uint256 Airdrop = _playerATT[msg.sender];
          if(Airdrop > 0){
            _ATTIns.transfer(msg.sender, Airdrop);
            _playerATT[msg.sender] = 0;
        }
    }



    function AirdropERC(address[] calldata Addrs,uint256[] calldata Num,uint256 ERC ) public onlyOwner {
        for (uint256 i=0; i<Addrs.length; i++) {
            address add = Addrs[i];
            uint256 amount = eptConvert(Num[i]);

            if(ERC ==1){
                _playerEPT[add] = _playerEPT[add].add(amount)  ;
            }
            if(ERC ==2){
                _playerARR[add] =  _playerARR[add].add(amount);
            }
            if(ERC ==3){
                _playerATT[add] =  _playerATT[add].add(amount);
            }

         }
    }

// 提取
    function extract( uint256 typeERC20,uint256 amount  ) public   {
    }

// 充值
    function Recharge( uint256 typeERC20,uint256 amount  ) public   {
        if(typeERC20 == 1){
            _eptIns.transferFrom(msg.sender, address(this), amount);
        } else
        if(typeERC20 == 2){
            _arrIns.transferFrom(msg.sender, address(this), amount);
        }else
        if(typeERC20 == 3){
            _ATTIns.transferFrom(msg.sender, address(this), amount);
        }else{
            require(false , " type field" ); 
        }
    }

  
// 兑换
    function exchange( uint256 typeERC20,uint256 amount  ) public   {
    }

    function settlementIndex(uint256 MineModel,uint256 index ) public  isRealPlayer   {
 
        InvestInfo[] memory investList =   _userMining[msg.sender][MineModel];
        uint256 staticaAmount = 0;
        require(block.timestamp>investList[index].endTime  , " time field" ); 
        staticaAmount =  staticaAmount.add(investList[index].amount);
        delete _userMining[msg.sender][MineModel][index];
        require(staticaAmount > 0  , " this field" ); 

        if(staticaAmount > 0){
 



        // if(MineModel< 3){
        //  _eptIns.transferFrom(msg.sender, address(this), staticaAmount);

        // }else if(MineModel > 4){
        //   _arrIns.transferFrom(msg.sender, address(this), staticaAmount);

        // }else{
        //     _ETIns.transferFrom(msg.sender, address(this), staticaAmount);

        //  }

 




        }
 
    }









   
}