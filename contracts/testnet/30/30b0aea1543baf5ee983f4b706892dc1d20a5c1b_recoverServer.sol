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

     struct UserEquip{
        uint tokenId;
        uint isUsed;
        uint stakeTime;
        uint lockTime;
        Attr attr;
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
    struct EnhanceConfig {
        uint coin;
        uint stone;
        uint rune;
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
    interface IStorage{
        function getUser(address addr) external view returns(User memory);
        function getUserEquip(uint key) external view returns(UserEquip memory);
        function setUser(address addr,User memory user) external;
        function getDurability(uint equipId) external view returns(uint);
        function setDurability(uint equipId,uint dur) external;
        function getUserHero(uint key) external view returns(UserHero memory);
        function pay(address userAddr,uint coin,uint stone,uint rune) external;
        function transferNft(address to,uint tokenId) external;
        function setUserHero(address userAddr,uint tokenId,UserHero memory userHero) external;

    }
    interface IConfig{
        function getConfig() view external returns (Config memory);
        function getRecoverConfig() external view returns (EnhanceConfig memory);
        function getRepairConfig() external view returns (EnhanceConfig memory);
        function getEnhanceConfig() view external returns (EnhanceConfig memory);
    }
    interface IHeroNft{
        function setAttr(uint tokenId, Attr memory attr) external;
        function getAttrByTokenId(uint tokenId) external view returns (Attr memory attr);
        

    }

contract recoverServer {

    address storageAddr = 0xAe3913Fc8733a5a5dc43Cc62e8c46dC7ee57018a;
    address configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
    address public heroNft = 0xE6a7D7d7C4753b3714546A6364139aB39A7eb2e5;

    function makeReqId(address addr,uint tokenId) internal pure returns (uint) {
        uint seed = uint(keccak256(abi.encode(addr, tokenId)));
        return seed;  
    }

    function recover(uint energy) external{
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.regTime > 0,"address not  registered!");
        Config memory  config =  IConfig(configAddr).getConfig();
        require(user.energy < config.maxenergy,"you have full energy,you do not need recover");
        uint newenergy = energy + user.energy;
        if (newenergy >= config.maxenergy) newenergy >= config.maxenergy;
        EnhanceConfig memory rc = IConfig(configAddr).getRecoverConfig();
        require(user.coin >= rc.coin*energy,"you do not have enough coin to recover");
        require(user.stone >= rc.stone*energy,"you do not have enough stone to recover");
        require(user.rune >= rc.rune*energy,"you do not have enough rune to recover");
        user.coin -= rc.coin*energy;
        user.stone -= rc.stone*energy;
        user.rune -= rc.rune*energy;
        user.energy = newenergy;
        IStorage(storageAddr).setUser(msg.sender,user);
    }

    function repair(uint assetid,uint durability) external{
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.regTime > 0,"address not  registered!");
        UserEquip memory userEquip = IStorage(storageAddr).getUserEquip(makeReqId(msg.sender,assetid));
        require(userEquip.tokenId >0,"assetid not exist");
        EnhanceConfig memory rc = IConfig(configAddr).getRepairConfig();

        require(user.coin >= rc.coin*durability,"you do not have enough coin to recover");
        require(user.stone >= rc.stone*durability,"you do not have enough stone to recover");
        require(user.rune >= rc.rune*durability,"you do not have enough rune to recover");
        user.coin -= rc.coin*durability;
        user.stone -= rc.stone*durability;
        user.rune -= rc.rune*durability;
        IStorage(storageAddr).setUser(msg.sender,user);
        uint dur = IStorage(storageAddr).getDurability(assetid);
        Config memory  config =  IConfig(configAddr).getConfig();
        require( dur< config.maxenergy,"you have full energy,you do not need recover");
        uint newdur = dur + durability;
        if (newdur >= config.maxenergy) newdur >= config.maxenergy;
        IStorage(storageAddr).setDurability(assetid,newdur);

    }

    function searchhero() external view {

    }

    function enhance(uint mainasset,uint[] memory subcard) external{
        require(subcard.length >0,"need hero cards to enhance");
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,mainasset));
        require(userHero.tokenId >0," you please stake nft");
        EnhanceConfig memory ec =  IConfig(configAddr).getEnhanceConfig();
        IStorage(storageAddr).pay(msg.sender,ec.coin,ec.stone,ec.rune);
        Attr memory attr = userHero.attr;
        uint  hp;uint  atk;uint  def;uint  cri;uint  dgr;uint ass;
        for (uint i=0;i<subcard.length;i++){
            UserHero memory userHero1 = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,subcard[i]));
            require(userHero1.tokenId >0,"this hero is not you");
            require((userHero1.wear_1==0) &&(userHero1.wear_2==0)&&(userHero1.wear_3==0)&&(userHero1.wear_4==0)&&(userHero1.wear_5==0)&&(userHero1.wear_6==0),"please unequip your equipment first");
            hp += userHero1.attr.hp*3*userHero1.attr.rarity/100>0?userHero1.attr.hp*3*userHero1.attr.rarity/100:1;
            atk += userHero1.attr.atk*3*userHero1.attr.rarity/100>0?userHero1.attr.atk*3*userHero1.attr.rarity/100:1;
            def += userHero1.attr.def*3*userHero1.attr.rarity/100>0?userHero1.attr.def*3*userHero1.attr.rarity/100:1;
            dgr += userHero1.attr.dgr*3*userHero1.attr.rarity/100>0?userHero1.attr.dgr*3*userHero1.attr.rarity/100:1;
            cri += userHero1.attr.cri*3*userHero1.attr.rarity/100>0?userHero1.attr.cri*3*userHero1.attr.rarity/100:1;
            ass += userHero1.attr.ass*3*userHero1.attr.rarity/100>0?userHero1.attr.ass*3*userHero1.attr.rarity/100:1;
            IStorage(storageAddr).transferNft(address(0xdead),subcard[i]);
        }
        attr.hp += hp;
        attr.atk += atk;
        attr.def += def;
        attr.cri += cri;
        attr.dgr += dgr;
        attr.ass += ass;
        userHero.attr = attr;
        IStorage(storageAddr).setUserHero(msg.sender,mainasset,userHero);
        IHeroNft(heroNft).setAttr(mainasset,attr);

    }



}