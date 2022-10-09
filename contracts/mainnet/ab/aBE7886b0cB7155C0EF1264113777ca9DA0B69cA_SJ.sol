pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
import "./DataPlayer.sol";
contract SJ is DataPlayer  {
    
    using SafeMath for uint256;
 
    uint256 NFTID = 0;

    
 
    constructor()
    public {
        _startTime = block.timestamp;//参与时间
        _owner = msg.sender; 
        Uaddress = msg.sender; 
        allNetworkCalculatingPower = 500000000000000000000000;
        // allNetworkCalculatingPowerDT = 500000000000000000000000;

    }
  

    function levelUP(uint256 IDD) public returns(uint256,uint256){

        uint256 livel = 0;
        uint256 totle = 0;
        uint256 lilv = 0;//利率
        (,totle) = range(IDD);
        if(totle > 10000000000000000000000 && totle<50000000000000000000000){
            livel = 1;
            lilv = 5;
        }
        else  if(totle > 50000000000000000000000 && totle<150000000000000000000000){
            livel = 2;
            lilv = 8;
        }
        else  if(totle > 150000000000000000000000 && totle<500000000000000000000000){
            livel = 3;
            lilv = 12;

        }
        else if(totle > 500000000000000000000000 && totle<1000000000000000000000000){
            livel = 4;
            lilv = 15;

        }
        else if(totle > 1000000000000000000000000 ){
            livel = 5;
            lilv = 18;

        }
        if(_SEOSPlayerMap[IDD].level < livel){
            _SEOSPlayerMap[IDD].level = livel;
        }
        return (livel,lilv);
    }

// 极差
    // function range(uint256[] memory   _IDlist) public  view returns(uint256,uint256){
        
    function range(uint256 IDD) public  view returns(uint256,uint256){
        uint256[]  memory   _IDlist =_SEOSPlayerMap[IDD].IDlist;
        uint256 max;
        uint256 MAXID = 0;
        uint256 totle;
        if(_IDlist.length>0){
             MAXID = _IDlist[0];
    	    for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].teamTotalDeposit;
    		    if (dynamic > max) {
    			    max = dynamic;
                    MAXID = _IDlist[i];
    		    }	
            }
            for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].teamTotalDeposit;
    		    if (MAXID !=  _IDlist[i]) {
    			    totle = totle.add(dynamic);
    		    }	
            }
        }
        return (max,totle);
    }

// 普通玩家数据
    function SEOSPlayeRegistry(address playerAddr, address superior) external  {

     

        
        uint256 id = _SEOSAddrMap[playerAddr];
        if(id == 0){
        _SEOSPlayerCount++;
        _SEOSAddrMap[playerAddr] = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
        id = _SEOSAddrMap[superior];
        if(id > 0 &&superior != playerAddr){
            _SEOSPlayerMap[_SEOSPlayerCount].superior = superior;
            _SEOSPlayerMap[id].IDlist.push(_SEOSPlayerCount);

        }
        }
     }
    function Noderegistry(address playerAddr) internal    {
        uint256 id = _SEOSAddrMap[playerAddr];
        if(id == 0 ){
            this.SEOSPlayeRegistry(playerAddr,  playerAddr); 
            id = _SEOSPlayerCount; 
        }

// 创世节点数据
        require(_NodePlayerCount < 19, "NodeSoldOut");       
        _NodePlayerCount++;       
        _SEOSPlayerMap[id].GenesisNode.id = _NodePlayerCount; //节点编号
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;//参与时间
        _SEOSPlayerMap[id].GenesisNode.LockUp = ERC20_Convert(50000000);//锁仓
        // uint256  eosprice =  Spire_Price(_EOSAddr, _EOSLPAddr);
        // _SEOSPlayerMap[id].integral = nodePrice.mul(10).mul(eosprice).div(10000000);//积分
        _SEOSPlayerMap[id].integral =_SEOSPlayerMap[id].integral.add(nodePrice.mul(10));//积分
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(3);
    }


     function SupernodeRegistry(address playerAddr, address superior) internal {
        uint256 id = _SEOSAddrMap[playerAddr];
        require(_SupernodeCount < 5000, "SupernodeOut");
         if(id == 0){
             this.SEOSPlayeRegistry(playerAddr,  superior); 
            id = _SEOSPlayerCount;
        }

// 超级节点数据
        _SupernodeCount++;
        _SEOSPlayerMap[id].Supernode.id = _SupernodeCount; //节点编号
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;//参与时间
        _SEOSPlayerMap[id].Supernode.LockUp = ERC20_Convert(20000);//锁仓
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);

    }

  function setSupernodePrice(  uint256 NewSupernodePrice) public onlyOwner {
   
        SupernodePrice = NewSupernodePrice;
    }

 
// 创世节点领取代币  每月 每个节点均分26000枚/节点
    function GenesisNodeStatic() external  isNodePlayer  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 difTime = block.timestamp.sub(_SEOSPlayerMap[id].GenesisNode.investTime); 
        uint256 dif  = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;
        uint256  amount = ERC20_Convert(dif.mul(26000));
        if(_SEOSPlayerMap[id].GenesisNode.LockUp > amount){
            _SEOSPlayerMap[id].GenesisNode.LockUp = _SEOSPlayerMap[id].GenesisNode.LockUp.sub(amount);
        }else{
            amount = _SEOSPlayerMap[id].GenesisNode.LockUp;
            _SEOSPlayerMap[id].GenesisNode.LockUp = 0;
        }
        _SEOSAddr.transfer(msg.sender, amount);
    }

// 超级节点 领取代币每月 每个节点均分1000枚/节点
    function SupernodesettleStatic() external   isSuperNodePlayer  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 difTime = block.timestamp.sub(_SEOSPlayerMap[id].Supernode.investTime); 
        uint256 dif  = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;
        uint256  amount = ERC20_Convert(dif.mul(1000));
        if(_SEOSPlayerMap[id].Supernode.LockUp > amount){
            _SEOSPlayerMap[id].Supernode.LockUp = _SEOSPlayerMap[id].Supernode.LockUp.sub(amount);
        }else{
            amount = _SEOSPlayerMap[id].Supernode.LockUp;
            _SEOSPlayerMap[id].Supernode.LockUp = 0;
        }
        _SEOSAddr.transfer(msg.sender, amount);
    }

// 积分转让
    function integral(address Destination,uint256 integralamount) external      {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 DestinationID = _SEOSAddrMap[Destination];
        require(_SEOSPlayerMap[id].integral >= integralamount, "Insufficient");
        if(DestinationID == 0)
        {
             this.SEOSPlayeRegistry(Destination,Destination);
        }
        DestinationID = _SEOSAddrMap[Destination];
        _SEOSPlayerMap[DestinationID].integral = _SEOSPlayerMap[DestinationID].integral.add(integralamount);
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.sub(integralamount);
    }
 
 


        function getEOSmun(uint256 GbonusNum,bool isjf)public view returns(uint256 GbonusNumT){

            if(isjf){
                uint256 SEOSprice = Spire_Price(_SEOSAddr, _SEOSLPAddr);
                  GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);
            }else{
                uint256 EOSprice =  Spire_Price(_EOSAddr, _EOSLPAddr);
                  GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);

            }
        }


// 社区奖励
    function levelgod(address superior,uint256 GbonusNum,uint256 Algebra,uint256 pj,bool isjf) internal  {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
            if(id > 0 ){
                uint256 livel = 0;
                uint256 lilv = 0;
                (livel,lilv) = levelUP(id);
                address sjid =  _SEOSPlayerMap[id].superior;
                uint256 SJlivel = 0;
                uint256 SJlilv = 0;
                (SJlivel,SJlilv) = levelUP(_SEOSAddrMap[sjid]);
 
                uint256  GbonusNumT = getEOSmun(GbonusNum,isjf);
        

                if(pj == 2){
                     if(isjf){
                    // JFFH[id].communitySEOSQuantity  = JFFH[id].communitySEOSQuantity.add(GbonusNum.mul(lilv).div(1000));

                    // uint256  GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);
 
                    _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNumT.mul(lilv).div(1000));

                    detailedMap[id].AdministrationSEOS  = detailedMap[id].AdministrationSEOS.add(GbonusNumT.mul(lilv).div(1000));

                    }else{
                        // uint256  GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);
                        _SEOSPlayerMap[id].EOSQuantity  = _SEOSPlayerMap[id].EOSQuantity.add(GbonusNumT.mul(lilv).div(1000));
                        detailedMap[id].AdministrationEOS  = detailedMap[id].AdministrationEOS.add(GbonusNumT.mul(lilv).div(1000));

                    }
                 }else if(pj == 1){


                    if(isjf){
                        // uint256  GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);
                        _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNumT.mul(lilv).div(100));
                        detailedMap[id].AdministrationSEOS  = detailedMap[id].AdministrationSEOS.add(GbonusNumT.mul(lilv).div(100));


                    }else{
                        // uint256  GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);
                        _SEOSPlayerMap[id].EOSQuantity  = _SEOSPlayerMap[id].EOSQuantity.add(GbonusNumT.mul(lilv).div(100));
                        detailedMap[id].AdministrationEOS  = detailedMap[id].AdministrationEOS.add(GbonusNumT.mul(lilv).div(100));

                    }

                 }
                if(livel == SJlilv){
                    pj = 2;
                }else if(livel > SJlilv){
                    pj = 3;
                }else{
                    pj = 1;
                }
                levelgod(sjid, GbonusNum, Algebra.sub(1),pj,isjf);
            }
        }
    }
    function jsplayerI(address senderaa) internal      {
        uint256 id = _SEOSAddrMap[senderaa];
        require(id > 0, "nothisuser");
      
        uint256 Daynumber =  getdayNum(block.timestamp);
        uint256 daytotle = 0;
        uint256 dayDTtotle = 0;
        uint256 Static = _SEOSPlayerMap[id].EOSmining.OutGold;
        uint256 dynamic = _SEOSPlayerMap[id].EOSmining.dynamic;
        uint256 Quantity = 0;
        uint256 DTQuantity = 0;
        require(Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime, "time");

        if(Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime){

            for (uint256 m = _SEOSPlayerMap[id].EOSmining.LastSettlementTime; m < Daynumber; m++) {
                if(everydaytotle[m] == 0)
                {
                    everydaytotle[m] = daytotle;
                }
                else
                {
                    daytotle = everydaytotle[m];
                }

                if(everydayDTtotle[m] == 0)
                {
                    everydayDTtotle[m] = dayDTtotle;
                }
                else
                {
                    dayDTtotle = everydayDTtotle[m];
                }
                if(everydayTotalOutput[m] == 0)
                {
                    everydayTotalOutput[m] = CurrentOutput;
                }
                uint256 todayOutput = everydayTotalOutput[m];
                Quantity =Quantity.add(Static.mul(todayOutput.mul(7).div(10)).div(daytotle).mul(7).div(10));
                uint256 dongtaishouyi = 0;
                if (dayDTtotle > 0){
                    dongtaishouyi = dynamic.mul(todayOutput.mul(3).div(10)).div(dayDTtotle).mul(3).div(10);
                    DTQuantity =DTQuantity.add(dongtaishouyi);
                }




            }
     
            everydaytotle[Daynumber] = allNetworkCalculatingPower;
            everydayDTtotle[Daynumber] = allNetworkCalculatingPowerDT;

            uint256 SEOSPrice  =   Spire_Price(_SEOSAddr, _SEOSLPAddr);
              Quantity = Quantity.mul(10000000).div(SEOSPrice);
              DTQuantity = DTQuantity.mul(10000000).div(SEOSPrice);

            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(Quantity);
            // 更新静态数据
            detailedMap[id].miningStatic = detailedMap[id].miningStatic.add(Quantity);

            // grantProfit(_SEOSPlayerMap[id].superior,DTQuantity.div(20),2);
    // 更新动态数据
            detailedMap[id].Dynamic = detailedMap[id].Dynamic.add(DTQuantity);
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(DTQuantity);
            _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
        }
    }
 
 
// 挖矿结算收益
    function jsplayer() public payable    {
         jsplayerI( msg.sender);
        
    }
 

    // 领取分享奖励、
    function sharebonus() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].USDT_T_Quantity >  0){
            _USDTAddr.transfer(msg.sender, _SEOSPlayerMap[id].USDT_T_Quantity);
            _SEOSPlayerMap[id].USDT_T_Quantity = 0;
        }
    }

// 推荐奖励
    function grantProfit(address superior,uint256 GbonusNum,uint256 Algebra,bool isjf) internal  {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
                uint256  GbonusNumT = getEOSmun(GbonusNum,isjf);



            if(id > 0 ){
                if(Algebra == 2){
                if(isjf){
                    // JFFH[id].TSEOSQuantity  = JFFH[id].TSEOSQuantity.add(GbonusNum);
                //   uint256  GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);

                _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNumT);
                detailedMap[id].shareSEOS = detailedMap[id].shareSEOS.add(GbonusNumT);


                }else{
                    // _SEOSPlayerMap[id].TSEOSQuantity  = _SEOSPlayerMap[id].TSEOSQuantity.add(GbonusNum);
                    //   uint256  GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);

                    _SEOSPlayerMap[id].EOSQuantity  = _SEOSPlayerMap[id].EOSQuantity.add(GbonusNumT);
                detailedMap[id].shareEOS = detailedMap[id].shareEOS.add(GbonusNumT);

                }
                }else{
                    if(isjf){

                        // uint256  GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);
                        _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNumT.mul(2).div(5));
                        detailedMap[id].shareSEOS = detailedMap[id].shareSEOS.add(GbonusNumT.mul(2).div(5));
                    }else{
                        // uint256  GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);

                        _SEOSPlayerMap[id].EOSQuantity  = _SEOSPlayerMap[id].EOSQuantity.add(GbonusNumT.mul(2).div(5));
                        detailedMap[id].shareSEOS  = detailedMap[id].shareSEOS.add(GbonusNumT.mul(2).div(5));
                    }

                }

                address sjid =  _SEOSPlayerMap[id].superior;
                grantProfit(sjid, GbonusNum, Algebra.sub(1),isjf);
            }
        }
    }
   
 


 

// 提取产出 
    function updateTX(uint256 id, uint256 OutGold,uint256 Quantity,bool EOSOrSeos) external canCall {
        require(id > 0, "isplayer");  
        uint256 Daynumber =  getdayNum(block.timestamp);


        uint256 produce =  _SEOSPlayerMap[id].EOSmining.OutGold.sub(OutGold) ;

        allNetworkCalculatingPower = allNetworkCalculatingPower.sub(produce);
        everydaytotle[Daynumber] = allNetworkCalculatingPower;

    if(EOSOrSeos){
        _SEOSPlayerMap[id].EOSQuantity  = _SEOSPlayerMap[id].EOSQuantity.sub(Quantity);
    }else{
        _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.sub(Quantity);
    }

        _SEOSPlayerMap[id].EOSmining.OutGold  = OutGold;
    }



 

     function updateBQ(address recommend,address  playAddress,uint256 USDT_T_Quantity) external canCall    {
        uint256 id = _SEOSAddrMap[recommend];
        uint256 IDOT  = _SEOSPlayerMap[id].PlayerIDO.IDORecommend;
        if(IDOT > 100){
            IDOT = 0;
        }
        uint256 max = 100;

        uint256 Tid = _SEOSAddrMap[_SEOSPlayerMap[_SEOSAddrMap[playAddress]].superior];
        if(IDOT >0){
        if(Tid > 0){
        uint256 SuperPrice = SupernodePrice.div(100).mul(max.sub(IDOT));

            if(_SEOSPlayerMap[Tid].GenesisNode.id > 0)
            {
                USDT_T_Quantity = SuperPrice.mul(20).div(100);
                _SEOSPlayerMap[Tid].USDT_T_Quantity =_SEOSPlayerMap[Tid].USDT_T_Quantity.add(USDT_T_Quantity);

            }else{
                if(_SEOSPlayerMap[Tid].Supernode.id > 0){
                    USDT_T_Quantity = SuperPrice.mul(15).div(100);
                    _SEOSPlayerMap[Tid].USDT_T_Quantity =_SEOSPlayerMap[Tid].USDT_T_Quantity.add(USDT_T_Quantity);

                }
            }
      
         }else if(id > 0 && USDT_T_Quantity > 0&& playAddress !=  recommend){
            _SEOSPlayerMap[id].USDT_T_Quantity =_SEOSPlayerMap[id].USDT_T_Quantity.add(USDT_T_Quantity);
        }
        }
        SupernodeRegistry(playAddress,recommend);
    }
  
// 领取分红
    function EOSbonus() public  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256  GenesisNodebonus = bonusNum.div(10).div(19);
        uint256  Supernodebonus = bonusNum.mul(45).div(100).div(5000);
        SEOSPlayer memory  play  = _SEOSPlayerMap[id];
        if(play.GenesisNode.id > 0){
            if( bonusTime != play.GenesisNode.bonusTime)
            {
                _EOSAddr.transfer(msg.sender, GenesisNodebonus);
                _SEOSPlayerMap[id].GenesisNode.bonusTime = bonusTime;
            }
        }
        if(play.Supernode.id > 0)
        {
            if( bonusTime != play.Supernode.bonusTime){
                _EOSAddr.transfer(msg.sender, Supernodebonus);
                _SEOSPlayerMap[id].Supernode.bonusTime = bonusTime;
            }
        }
    }

    // 领取IDO 锁仓的额度
    function IODLocklq() public  {
        require(block.timestamp > _IDOUnlockTime, "timeisout");
        uint256 id = _SEOSAddrMap[msg.sender];
        if(id > 0){
            _SEOSAddr.transfer(msg.sender,  _SEOSPlayerMap[id].PlayerIDO.LockWarehouse);
        }
    }
 
// // 铸造NFT
    function NFTcasting() public isPlayer   returns(uint256)  {
        require(block.timestamp > NFTcastingTime, "NFT casting time out");
        uint256 id = _SEOSAddrMap[msg.sender];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        NFTID = NFTID.add(1);
        EOSSNFT.mint(msg.sender, NFTID);
        require(player.NFTmintnumber != 0, "NFT casting is fil"); 
        player.NFTmintnumber = player.NFTmintnumber.sub(1); 
        return NFTID;
    }

    modifier canCall() {//konwnsec//修饰器，检测调用者为合约地址
        address diviAddr = address(this);
        require(msg.sender == _OPAddress || msg.sender == diviAddr, "Permission denied");
        _; 
    }

    function setOPAddress(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        _OPAddress = newaddress;
    }






// 挖矿投资
    function updatePmining(uint256 USDT_Num,uint256 id,uint256 paytype,uint256 JF,address SEOSPlayerAddress,address Destination) external  canCall   {

        if(id == 0)
        {
            this.SEOSPlayeRegistry(SEOSPlayerAddress,Destination);
        }


        id   = _SEOSAddrMap[SEOSPlayerAddress];

       
        uint256 Daynumber =  getdayNum(block.timestamp);
        if(Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime&&_SEOSPlayerMap[id].EOSmining.OutGold  > 0){
            jsplayerI(SEOSPlayerAddress); 
        }

         _SEOSPlayerMap[id].EOSmining.CalculatingPower = _SEOSPlayerMap[id].EOSmining.CalculatingPower.add(USDT_Num);
// 总产出
        uint256  OutGold = _SEOSPlayerMap[id].EOSmining.OutGold.add(USDT_Num.mul(3));

        allNetworkCalculatingPower = allNetworkCalculatingPower.add(USDT_Num.mul(3));
        allNetworkCalculatingPowerDT = allNetworkCalculatingPower.add(USDT_Num.mul(2));
// 给上级加算力
        // uint256 SJID = _SEOSAddrMap[Destination];

    
            grantProfitsl(SEOSPlayerAddress,USDT_Num,6);
            addteamTotalDeposit(Destination,USDT_Num,15);
          
// 更新当日代币产出
        // uint256 Daynumber =  getdayNum(block.timestamp);
        getCapacity();
        everydayTotalOutput[Daynumber] = CurrentOutput;
        _SEOSPlayerMap[id].EOSmining.LastSettlementTime =  Daynumber;
        everydaytotle[Daynumber] = allNetworkCalculatingPower;
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.sub(JF);

        if(paytype == 3){
            _SEOSPlayerMap[id].SEOSQuantity = 0;
            grantProfit(_SEOSPlayerMap[id].superior,USDT_Num.div(2),2,true);
            levelgod(_SEOSPlayerMap[id].addr,USDT_Num.div(2),15,3,true);
        } 
        
        
        if(Destination != SEOSPlayerAddress&&_SEOSAddrMap[Destination] > 0){
         if(paytype == 2)
        {
            uint256 shiji =   USDT_Num.div(10).mul(4).sub(JF);
            grantProfit(_SEOSPlayerMap[id].superior,shiji.div(20),2,false);
            levelgod(_SEOSPlayerMap[id].addr,USDT_Num.div(10).mul(4),15,3,false);
        }else if(paytype == 1){

            uint256 shiji =  USDT_Num.div(2).sub(JF);
            grantProfit(_SEOSPlayerMap[id].superior,shiji.div(20),2,false);
            levelgod(_SEOSPlayerMap[id].addr,USDT_Num.div(2),15,3,false);
        }
        }
        _SEOSPlayerMap[id].EOSmining.OutGold = OutGold;
    }

    function updatepIDO(address Destination,address SEOSPlayerAddress,uint256 USDT_T_Quantity) external     canCall   {
        require(block.timestamp > IDOtimeLimitS, "time start");
        require(block.timestamp < IDOtimeLimitE, "time end");
        uint256 id = _SEOSAddrMap[SEOSPlayerAddress];
        uint256 SJID = _SEOSAddrMap[Destination];
        require(_SEOSPlayerMap[id].PlayerIDO.IDO, "is IDO"); 

        require(10000 >= _IDOCount, "IDO");
         if(SJID != 0)
        {
            _SEOSPlayerMap[SJID].PlayerIDO.IDORecommend=  _SEOSPlayerMap[SJID].PlayerIDO.IDORecommend.add(1);
            _SEOSPlayerMap[SJID].USDT_T_Quantity =_SEOSPlayerMap[SJID].USDT_T_Quantity.add(USDT_T_Quantity);
        }
        if(id == 0)
        {
            this.SEOSPlayeRegistry(SEOSPlayerAddress,Destination);
        }
        id = _SEOSAddrMap[SEOSPlayerAddress];

        _SEOSPlayerMap[id].PlayerIDO.IDO = true;
        _SEOSPlayerMap[id].PlayerIDO.LockWarehouse = 500000000000000000000;
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);
        _IDOCount = _IDOCount.add(1);
    }
 



 function updatepbecomeNode(address  playAddress ) external     canCall   {
 
        uint256 senderid = _SEOSAddrMap[playAddress];
        require(_SEOSPlayerMap[senderid].GenesisNode.id == 0, "is GenesisNode"); 
         Noderegistry(playAddress);
    }
//  成为超级节点  购买超级节点
  function updatepbecomeSupernode(address recommend,address  playAddress,uint256 USDT_T_Quantity) external canCall {
 

      
        uint256 id = _SEOSAddrMap[recommend];
        
        uint256 Tid = _SEOSAddrMap[_SEOSPlayerMap[_SEOSAddrMap[playAddress]].superior];
        if(Tid > 0){
            if(_SEOSPlayerMap[Tid].GenesisNode.id > 0)
            {
                USDT_T_Quantity = SupernodePrice.mul(20).div(100);
                _SEOSPlayerMap[Tid].USDT_T_Quantity =_SEOSPlayerMap[Tid].USDT_T_Quantity.add(USDT_T_Quantity);

            }else{
                if(_SEOSPlayerMap[Tid].Supernode.id > 0){
                    USDT_T_Quantity = SupernodePrice.mul(15).div(100);
                    _SEOSPlayerMap[Tid].USDT_T_Quantity =_SEOSPlayerMap[Tid].USDT_T_Quantity.add(USDT_T_Quantity);

                }
            }
      
         }else if(id > 0 && USDT_T_Quantity > 0 && playAddress !=  recommend){
            _SEOSPlayerMap[id].USDT_T_Quantity =_SEOSPlayerMap[id].USDT_T_Quantity.add(USDT_T_Quantity);
        }
        uint256 senderid = _SEOSAddrMap[playAddress];
        require(_SEOSPlayerMap[senderid].Supernode.id == 0, "is Supernode"); 
        SupernodeRegistry(playAddress,recommend);
    }


}