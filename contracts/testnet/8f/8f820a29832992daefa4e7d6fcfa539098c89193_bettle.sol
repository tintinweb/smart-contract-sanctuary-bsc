/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

struct Config{
        uint defaultTalent;
        uint mint_hero_coin;
        uint mint_hero_rune;
        uint mint_equip_coin;
        uint mint_equip_stone;
        uint hero_num;
        uint equip_num;
        uint threhold;
        uint fee;
        uint recover;   
        uint up_hero;	
        uint up_equip;  
        uint up_exp;    
        uint maxenergy; 
    }


    struct Attr{
        uint types; //1.hero 2.equip 3.package 4.tool
        string name;
        string img;
        uint rarity;
        uint lv;
        uint exp;
        uint hp;
        uint atk;
        uint def;
        uint dgr;
        uint cri;
        uint ass;
        uint toolType; //1 human 2.god
        uint position;
        uint packageType; // 1.hero 2.equip
        uint heroIndex;
        uint heroType; // 1.human 2.god
    }

    struct UserHero{
        uint tokenId;
        uint wear_1;
        uint wear_2;
        uint wear_3;
        uint wear_4;
        uint wear_5;
        uint wear_6;
        uint stakeTime;
        Attr attr;
        uint pvpTime;
        uint pveTime;
    }
    struct UserEquip{
        uint tokenId;
        uint isUsed;
        uint stakeTime;
        uint lockTime;
        Attr attr;
    }

    struct EvolConfig {
        string name;	
        uint types; //1.human 2.god	
        uint numhuman;	
        uint numgod;	
        uint uprate;
    }
    struct UserTool{
        uint tokenId;
        Attr attr;
    }
     struct EnhanceConfig {
        uint coin;
        uint stone;
        uint rune;
    }
    struct HeroevolConfig{
        string name;
        string url;
    }

    struct User{
        uint256 coin;
        uint256 stone;
        uint256 rune;
        address userAddr;
        address referAddr;
        uint energy;
        uint talent;
        uint regTime;
        uint CurrentStage;
    }
struct PVPCost {
        uint level;
        uint coin;	
        uint stone;
        uint rune;
    }
    struct PVPRateConfig{
        uint baseRate;
        uint decreaseRate;	
        uint randRate;
    }

    struct PowerConfig{
        uint    hp;
        uint    atk;	
        uint    def;
        uint    dgr;
        uint    cri;
        uint    ass;
    }

    struct PVPReward {
        uint level;
        uint coin;
        uint stone;	
        uint rune;
    }
    struct PvEConfig {
        uint    stage;	
        uint    level;	
        uint    hp;
        uint    atk;	
        uint    def;
        uint    dgr;
        uint    cri;
        uint    ass;
        uint    degree;
    }
    struct PVEReward {
        uint stage;
        uint coin;
        uint stone;	
        uint rune;
    }
    interface IStorage{
        function setUserHero(address userAddr,uint tokenId,UserHero memory userHero) external;
    
        function setUserTool(uint key,UserTool memory userTool) external;
        function getUserHero(uint key) external view returns(UserHero memory);
        function getUserEquip(uint key) external view returns(UserEquip memory);
        function getUserTool(uint key) external view returns(UserTool memory);
        function pay(address userAddr,uint coin,uint stone,uint rune) external;
        function getUserToolList(address userAddr) external view returns (uint[] memory);
        function delUserTool(address userAddr,uint tokenId) external;
        function transferNft(address to,uint tokenId) external;
        function getUser(address addr) external view returns(User memory);
        function getAllHeros() external view returns(uint[] memory);
        function isContains(uint value) external view returns (bool);
        function getDurability(uint equipId) external view returns(uint);
        function setDurability(uint equipId,uint dur) external;
        function getFindAddr(uint tokenId) external view returns(address);
        function getPVPRewardList(uint level) view external returns (PVPReward memory);
        function setUser(address addr,User memory user) external;
    }
    interface IConfig{
        function getEvolConfig(uint index) view external returns(EvolConfig memory);
        function getEvolCostHuman(uint index) view external returns(EnhanceConfig memory);
        function getEvolCostGod(uint index) view external returns(EnhanceConfig memory);
        function getHeroevolConfig(uint index) view external returns(HeroevolConfig memory);
        function getPvpCost(uint level) view external returns (PVPCost memory);
        function getPVPRateConfig()view external returns(PVPRateConfig memory);
        function getPowerConfig()view external returns(PowerConfig memory);
        function getPvEConfigList(uint stage)view external returns(PvEConfig memory);
        function getPVERewardList(uint stage) view external returns (PVEReward memory);
        function getConfig() view external returns (Config memory);
        function getRecoverConfig() external view returns (EnhanceConfig memory);
        function getRepairConfig() external view returns (EnhanceConfig memory);

    }
    interface IHeroNft{
        function setAttr(uint tokenId, Attr memory attr) external;
        function getAttrByTokenId(uint tokenId) external view returns (Attr memory attr);

    }
    


contract bettle {
    address storageAddr = 0xAe3913Fc8733a5a5dc43Cc62e8c46dC7ee57018a;
    address configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
    address public NftAddr = 0xE6a7D7d7C4753b3714546A6364139aB39A7eb2e5;
    


    struct BattleAttr{
        uint hp;
        uint atk;
        uint def;
        uint dgr;
        uint cri;
        uint ass;
        uint lv;
    }
    constructor () {
        
    }
    
    function makeReqId(address addr,uint tokenId) internal pure returns (uint) {
        uint seed = uint(keccak256(abi.encode(addr, tokenId)));
        return seed;  
    }

    function evolution(uint mainasset) external{
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,mainasset));
        require(userHero.tokenId >0,"you do not own this hero nft");
        Attr memory attr = userHero.attr;
        EvolConfig memory evolConfig = IConfig(configAddr).getEvolConfig(attr.heroIndex);
        uint[] memory ownerTools =  IStorage(storageAddr).getUserToolList(msg.sender);
        uint need = 0;
        uint owner = 0;
        EnhanceConfig memory enhanceConfig;
        if (attr.heroType ==1){
            enhanceConfig = IConfig(configAddr).getEvolCostHuman(attr.lv);
            need = evolConfig.numhuman;
        } else {
            enhanceConfig = IConfig(configAddr).getEvolCostGod(attr.lv);
            need = evolConfig.numgod;
        }
        //pay
        IStorage(storageAddr).pay(msg.sender,enhanceConfig.coin,enhanceConfig.stone,enhanceConfig.rune);
        UserTool memory userTool;
        for (uint i=0;i<ownerTools.length;i++){
            userTool = IStorage(storageAddr).getUserTool(makeReqId(msg.sender,ownerTools[i]));
            require(userTool.tokenId>0,"you do not own this nft");
            if (userTool.attr.toolType == userHero.attr.heroType) {
                IStorage(storageAddr).delUserTool(msg.sender,ownerTools[i]);
                IStorage(storageAddr).transferNft(address(0xdead),ownerTools[i]);
                owner++;
            }
        }
        require((need == owner)&&(owner >0)," evol card Insufficient num");
        uint index = (attr.heroIndex -1)*5 + attr.rarity - 1;
        HeroevolConfig memory heroevolConfig = IConfig(configAddr).getHeroevolConfig(index);
        attr.name = heroevolConfig.name;
        attr.img = heroevolConfig.url;
        attr.hp = attr.hp + evolConfig.uprate /100;
        attr.atk = attr.atk + evolConfig.uprate /100;
        attr.def = attr.def + evolConfig.uprate /100;
        attr.dgr = attr.dgr + evolConfig.uprate /100;
        attr.cri = attr.cri + evolConfig.uprate /100;
        attr.ass = attr.ass + evolConfig.uprate /100;
        userHero.attr = attr;
        IStorage(storageAddr).setUserHero(msg.sender,mainasset,userHero);
        IHeroNft(NftAddr).setAttr(mainasset,attr);
    }

    function pvpbattle(uint from ,uint to) external{
        require(from != to,"can not battle to self");
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,from));
        require(userHero.tokenId >0,"you do not own this hero nft");
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.energy >=10,"you do not have enough energy");
        require(IStorage(storageAddr).isContains(to),"not exist hero");
        require(userHero.pvpTime < block.timestamp,"your asset is still on cooldown,please wait");
        
        address toAddr = IStorage(storageAddr).getFindAddr(to);
        require(toAddr !=address(0),"to address is null");

        PVPCost memory pvpCost = IConfig(configAddr).getPvpCost(userHero.attr.lv); 
        require(user.coin >=pvpCost.coin,"you do not have enough coin" );
        require(user.stone >=pvpCost.stone,"you do not have enough stone" );
        require(user.rune >=pvpCost.rune,"you do not have enough rune" );

        UserHero memory toHero =  IStorage(storageAddr).getUserHero(makeReqId(toAddr,to));
        Attr memory fromCalcpower = calcpower(userHero,msg.sender);
        Attr memory toCalcpower = calcpower(toHero,toAddr);
        uint target_kill_time =  killtimes(fromCalcpower,toCalcpower.hp,user.talent);
        uint self_kill_time =  killtimes(toCalcpower,fromCalcpower.hp,100);
        
        //IConfig(configAddr).getPVPRewardList(toCalcpower.lv);
        uint new_reward_coin = getReward(fromCalcpower,toCalcpower,target_kill_time,self_kill_time);
        
        uint isWin = 0;
        if(self_kill_time>target_kill_time){
            user.coin += new_reward_coin;
            user.coin -= pvpCost.coin;
            user.stone -= pvpCost.stone;
            user.rune -= pvpCost.rune;
            user.energy -= 3;
            isWin=1;
        }else{
            new_reward_coin = new_reward_coin / 10;
            user.coin += new_reward_coin;
            user.coin -= pvpCost.coin;
            user.stone -= pvpCost.stone;
            user.rune -= pvpCost.rune;
            user.energy -= 3;
            isWin=0;
        }
        userHero.pvpTime = block.timestamp + 6 * 60 *60;
        IStorage(storageAddr).setUser(msg.sender,user);
        IStorage(storageAddr).setUserHero(msg.sender,userHero.tokenId,userHero);

    }

    function getReward(Attr memory fromCalcpower, Attr memory toCalcpower,uint target_kill_time,uint self_kill_time) view internal returns(uint){
        uint targetpower = genpower(toCalcpower);
        PVPRateConfig memory rc = IConfig(configAddr).getPVPRateConfig();
        targetpower *=rc.baseRate;
        uint creaseRate = fromCalcpower.lv > toCalcpower.lv?(fromCalcpower.lv-toCalcpower.lv)*rc.decreaseRate:(toCalcpower.lv-fromCalcpower.lv)*rc.decreaseRate;
        if (creaseRate >=100) creaseRate = 99;
        if (toCalcpower.lv > fromCalcpower.lv){
            creaseRate += 100;
        } else {
            creaseRate -= 100;
        }
        //IConfig(configAddr).getPVPRewardList(toCalcpower.lv);
        uint new_reward_coin = targetpower*creaseRate/100;
        if(self_kill_time<=target_kill_time){
            targetpower = genpower(fromCalcpower);
            new_reward_coin = targetpower;
        }
        return new_reward_coin * 1e18;
    }

    function calcpower(UserHero memory userHero,address addr) internal  returns(Attr memory){
        Attr memory attr = userHero.attr;
        UserEquip memory userEquip;
        
        if (userHero.wear_1 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_1));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_1,5);
        }
        if (userHero.wear_2 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_2));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_2,5);
        }
        if (userHero.wear_3 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_3));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_3,5);
        }
        if (userHero.wear_4 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_4));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_4,5);
        }
        if (userHero.wear_5 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_5));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_5,5);
        }
        if (userHero.wear_6 >0){
           userEquip = IStorage(storageAddr).getUserEquip(makeReqId(addr,userHero.wear_6));
           attr.hp += userEquip.attr.hp;attr.atk += userEquip.attr.atk;attr.def += userEquip.attr.def;
           attr.dgr += userEquip.attr.dgr;attr.cri += userEquip.attr.cri;attr.ass += userEquip.attr.ass;
           subdurability(userHero.wear_6,5);
        }
        return attr;
    }

    function subdurability(uint assetid,uint durability) internal{
        uint dur = IStorage(storageAddr).getDurability(assetid);
        require((dur-1) >= durability,"no enough durability");
        IStorage(storageAddr).setDurability(assetid,dur - durability);
    }


    function killtimes(Attr memory attr,uint tHp,uint talnet) pure internal returns(uint){
        attr.atk = attr.atk*1e5;
        attr.def = attr.def*1e5;
        attr.dgr = attr.dgr*1e5;
        attr.cri = attr.cri*1e5;
        attr.ass = attr.ass*1e5;
        attr.lv = attr.lv*1e5;
        tHp = tHp*1e5;
        talnet = talnet *1e5;
        
        uint point1 = attr.lv*attr.atk*attr.cri/1000;
        uint point2 = attr.atk*attr.ass/1000;
        uint tDgr = attr.dgr;
        if (tDgr > 1000e5) tDgr = 1000e5;
        uint point3 = attr.atk - attr.atk * tDgr/1000;
        uint point4 = attr.atk*attr.atk/attr.def;
        uint point5 = point1+point2 + point3 +point4;
        return tHp/point5*talnet/100;
    }
    function genpower(Attr memory attr) internal view returns(uint){
        PowerConfig memory pc = IConfig(configAddr).getPowerConfig();
        return attr.hp * pc.hp + attr.atk*pc.atk + attr.def*pc.atk + attr.cri*pc.cri +attr.dgr*pc.dgr +attr.ass * pc.ass;
    }

    function pvebattle(uint self,uint stage)external{
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,self));
        require(userHero.tokenId >0,"you do not own this hero nft");
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.energy >=10,"you do not have enough energy");
        require(stage>0 && stage<=20,"error stage index");
        require((user.CurrentStage +1)>=stage,"you can not battle with this stage");
        require(block.timestamp>userHero.pveTime,"your asset is still on cooldown,please wait");
        PvEConfig memory pc = IConfig(configAddr).getPvEConfigList(stage);
        
        Attr memory stageAttr = Attr(0,"","",0,pc.level,0,
            pc.hp*pc.degree,
            pc.atk*pc.degree,
            pc.def*pc.degree,
            pc.dgr*pc.degree,
            pc.cri*pc.degree,
            pc.ass*pc.degree,0,0,0,0,0);
        Attr memory userCalcpower = calcpower(userHero,msg.sender);
        require(userCalcpower.hp<1000000,"error attribute,please wait a moment and try again");
        require(userCalcpower.atk<100000,"error attribute,please wait a moment and try again");
        require(userCalcpower.def<100000,"error attribute,please wait a moment and try again");
        require(userCalcpower.dgr<5000,"error attribute,please wait a moment and try again");
        require(userCalcpower.cri<5000,"error attribute,please wait a moment and try again");
        require(userCalcpower.ass<5000,"error attribute,please wait a moment and try again");
        uint target_kill_time =  killtimes(userCalcpower,stageAttr.hp,100);
        uint self_kill_time =  killtimes(stageAttr,userCalcpower.hp,user.talent);
        PVEReward memory pveReward = IConfig(configAddr).getPVERewardList(stage);
        
       
        uint exp = getExp(userCalcpower,stageAttr,target_kill_time,self_kill_time,stage);
        
        if(self_kill_time>target_kill_time){
            if (userHero.attr.heroType == 2){
                user.coin += pveReward.coin;
                user.rune += pveReward.rune;
            } else {
                user.coin = pveReward.coin;
                user.stone = pveReward.stone;
            }
            user.CurrentStage = stage>user.CurrentStage?user.CurrentStage+1:user.CurrentStage;
        } else {
            if (userHero.attr.heroType ==2){
                user.coin += pveReward.coin/10;
                user.rune += pveReward.rune/10;
            } else {
                 user.coin = pveReward.coin/10;
                user.stone = pveReward.stone/10;
            }
            
        }
        
        user.energy -= userHero.attr.lv;
        IStorage(storageAddr).setUser(msg.sender,user);
        userHero.pveTime = 4*60*60;
        userHero.attr.exp += exp;
        IStorage(storageAddr).setUserHero(msg.sender,userHero.tokenId,userHero);
    
    }

    function getExp(Attr memory userCalcpower,Attr memory stageAttr,uint self_kill_time,uint target_kill_time,uint stage ) view internal returns(uint){
        uint new_level = 1;
        if(userCalcpower.lv>stageAttr.lv) new_level=userCalcpower.lv-stageAttr.lv;
        if(new_level>3)new_level=3;
        uint  tmp_reward = (self_kill_time-target_kill_time)*new_level;
        if(tmp_reward<=0)tmp_reward=1;
        Config memory config = IConfig(configAddr).getConfig();
        uint exp = stage*tmp_reward*config.up_exp/100;
        return exp;
    }

    

    
    



}