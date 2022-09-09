/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        _setOwner(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
    
   

    struct UpCost {
        uint lv;
        uint exp;
        uint coin;
        uint stone;
        uint rune;
        uint br;
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
    

    struct PVPReward {
        uint level;
        uint coin;
        uint stone;	
        uint rune;
    }
    
    struct PVEReward {
        uint stage;
        uint coin;
        uint stone;	
        uint rune;
    }
    

    struct PVPCost {
        uint level;
        uint coin;	
        uint stone;
        uint rune;
    }

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
    struct RateConfig{
        uint hn;
        uint hr;
        uint hsr;
        uint hssr;
        uint hlr;
        uint en;
        uint er;
        uint esr;
        uint essr;
        uint elr;

    }
    
    struct UpdateConfig {
        uint    hp;
        uint    atk;	
        uint    def;
        uint    dgr;
        uint    cri;
        uint    ass;
    }
    

    struct EnhanceConfig {
        uint coin;
        uint stone;
        uint rune;
    }
    

    struct EvolConfig {
        string name;	
        uint types; //1.god 2.human	
        uint numhuman;	
        uint numgod;	
        uint uprate;
    }

    

    struct HeroevolConfig{
        string name;
        string url;
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

    struct UserPackage{
        uint tokenId;
        Attr attr;
    }
    struct UserTool{
        uint tokenId;
        Attr attr;
    }


interface IConfig{
    function getPvEConfigList(uint stage)view external returns(PvEConfig memory);
    function getPowerConfig()view external returns(PowerConfig memory);
    function getPVPRateConfig()view external returns(PVPRateConfig memory);
    function getHeroevolConfig(uint index) view external returns(HeroevolConfig memory);
    function getEvolCostHuman(uint index) view external returns(EnhanceConfig memory);
    function getEvolCostGod(uint index) view external returns(EnhanceConfig memory);
    function getEvolConfig(uint index) view external returns(EvolConfig memory);
    function getEnhanceConfig()view external returns (EnhanceConfig memory);
    function getUpdateConfig() view external returns (UpdateConfig memory);
    function getHeroConfig(uint index) view external returns(Attr memory);
    function getEquipConfig(uint index) view external returns(Attr memory);
    function getConfig() view external returns (Config memory);
    function getRateConfig() view external returns (RateConfig memory);
    function getUpHeroCost(uint level) view external returns (UpCost memory);
    function getUpEquipCost(uint level) view external returns (UpCost memory);
    function getPvpCost(uint level) view external returns (PVPCost memory);
    function getPVPRewardList(uint level) view external returns (PVPReward memory);
    function getPVERewardList(uint stage) view external returns (PVEReward memory);
    function getRecoverConfig() external view returns (EnhanceConfig memory);
    function getRepairConfig() external view returns (EnhanceConfig memory);
}
interface IStorage{
    function getAllHeros() external view returns(uint[] memory);
    function getUser(address addr) external view returns(User memory);
    function getDurability(uint equipId) external view returns(uint);

}
interface IBusiness{
    function newaccount(address refer) external;
    function deposit(uint coin,uint stone,uint rune) external;
    function mintnft(uint types) external returns(uint,Attr memory);
    function opencardpack(uint assetid) external returns(uint,Attr memory);
    function withdraw(uint coin,uint stone,uint rune) external;
}
interface IBusinessStake{
    function stake(uint types,uint[] memory assetids) external;
    function unStake(uint assetid,uint types) external;
    function unwear(uint hero,uint equip) external;
    function wearequip(uint hero,uint equip) external;
    function upgradehero(uint assetid) external;
    function upgradeequip(uint assetid) external;
}
interface IBusinessBattle{
    
    function pvpbattle(uint from ,uint to) external returns(uint,uint);
    function pvebattle(uint self,uint stage)external returns(uint,EnhanceConfig memory);

}

interface IBusinessRecover{
    function recover(uint energy) external;
    function repair(uint assetid,uint durability) external;
    function enhance(uint mainasset,uint[] memory subcard) external;
    function evolution(uint mainasset) external;
}
interface IERC20{
        function approve(address spender, uint256 amount) external returns (bool);
    }



contract interfaceServer  is Ownable {
    // address public configAddr = 0x1e5Ef41a5bE5D81b922c777fe6d7eDA4691304D5;
    // address public storageAddr = 0xddE61Ac0F6F9a6271785f300F43e156733888fAB;
    // address public businessAddr = 0xc09A5E28c90ACDE1272E66749281226B72192BF6;
    // address public businessStakeAddr = 0x6db1c7F0cB56B371A5AC3f985055Ac6BacD4e8AE;
    // address public businessBattleAddr = 0x99e9673A4d4E830bD5B29313B1670c7BB57Ad0b2;
    // address public businessRecoverAddr = 0x37069971138ab0Ed5A8d9b52DEc4a1E9A2456F77;
    address public configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
    address public storageAddr = 0x4dA9276f1194a6Ab7484E00CbAAccb199333FD59;
    address public businessAddr = 0xbeAdd7e0aF4c8D6F71E9065cb9585D88948d6f29;
    address public businessStakeAddr = 0xE304ab9C7d14Ac35e52Ade66a8613c4C8367B348;
    address public businessBattleAddr = 0x51687B213CC0C04e29e206479dBBb88f0971f3a6;
    address public businessRecoverAddr = 0x71e7D1B69B0896d02540dCf4Cc8060fc354DC062;

    event battleEvent(uint256 isWin,uint256 coin,uint256 stone,uint256 rune);
    event mintEvent(uint256 tokenId,uint256 types,string name,uint256 hp,uint256 atk,uint256 def,uint256 dgr,uint256 cri,uint256 ass,uint rarity,uint lv);

    function setconfigAddr(address addr) external onlyOwner{
        configAddr = addr;
    }
    function setstorageAddr(address addr) external onlyOwner{
        storageAddr = addr;
    }
    function setbusinessAddr(address addr) external onlyOwner{
        businessAddr = addr;
    }
    function setbusinessStakeAddr(address addr) external onlyOwner{
        businessStakeAddr = addr;
    }
    function setbusinessBattleAddr(address addr) external onlyOwner{
        businessBattleAddr = addr;
    }
    function setbusinessRecoverAddr(address addr) external onlyOwner{
        businessRecoverAddr = addr;
    }

    function getPvEConfigList(uint stage)view external returns(PvEConfig memory){
        return IConfig(configAddr).getPvEConfigList(stage);
    }
    function getPowerConfig()view external returns(PowerConfig memory){
        return IConfig(configAddr).getPowerConfig();
    }
    function getPVPRateConfig()view external returns(PVPRateConfig memory){
         return IConfig(configAddr).getPVPRateConfig();
    }
    function getHeroevolConfig(uint index) view external returns(HeroevolConfig memory){
        return IConfig(configAddr).getHeroevolConfig(index);
    }
    function getEvolCostHuman(uint index) view external returns(EnhanceConfig memory){
        return IConfig(configAddr).getEvolCostHuman(index);
    }
    function getEvolCostGod(uint index) view external returns(EnhanceConfig memory){
        return IConfig(configAddr).getEvolCostGod(index);
    }
    function getEvolConfig(uint index) view external returns(EvolConfig memory){
        return IConfig(configAddr).getEvolConfig(index);
    }
    function getEnhanceConfig()view external returns (EnhanceConfig memory){
        return IConfig(configAddr).getEnhanceConfig();
    }
    function getUpdateConfig() view external returns (UpdateConfig memory){
        return IConfig(configAddr).getUpdateConfig();
    }
    function getHeroConfig(uint index) view external returns(Attr memory){
        return IConfig(configAddr).getHeroConfig(index);
    }
    function getEquipConfig(uint index) view external returns(Attr memory){
        return IConfig(configAddr).getEquipConfig(index);
    }
    function getConfig() view external returns (Config memory){
        return IConfig(configAddr).getConfig();
    }
    function getRateConfig() view external returns (RateConfig memory){
        return IConfig(configAddr).getRateConfig();
    }
    function getUpHeroCost(uint level) view external returns (UpCost memory){
        return IConfig(configAddr).getUpHeroCost(level);
    }
    function getUpEquipCost(uint level) view external returns (UpCost memory){
        return IConfig(configAddr).getUpEquipCost(level);
    }
    function getPvpCost(uint level) view external returns (PVPCost memory){
        return IConfig(configAddr).getPvpCost(level);
    }
    function getPVPRewardList(uint level) view external returns (PVPReward memory){
        return IConfig(configAddr).getPVPRewardList(level);
    }
    function getPVERewardList(uint stage) view external returns (PVEReward memory){
        return IConfig(configAddr).getPVERewardList(stage);
    }
    function getRecoverConfig() external view returns (EnhanceConfig memory){
        return IConfig(configAddr).getRecoverConfig();
    }
    function getRepairConfig() external view returns (EnhanceConfig memory){
        return IConfig(configAddr).getRepairConfig();
    }

    function getAllHeros() external view returns(uint[] memory){
        return IStorage(storageAddr).getAllHeros();
    }
    function getUser(address addr) external view returns(User memory){
        return IStorage(storageAddr).getUser(addr);
    }

    function getDurability(uint equipId) external view returns(uint){
        return IStorage(storageAddr).getDurability(equipId);
    }
  
    function newaccount(address refer) external{
        IBusiness(businessAddr).newaccount(refer);
    }
    function deposit(uint coin,uint stone,uint rune) external{
        IBusiness(businessAddr).deposit(coin,stone,rune);
    }
    function withdraw(uint coin,uint stone,uint rune) external{
         IBusiness(businessAddr).withdraw(coin,stone,rune);
    }
    function mintnft(uint types) external{
       
        (uint tokenId,Attr memory attr) = IBusiness(businessAddr).mintnft(types);
        emit mintEvent(tokenId,attr.types,attr.name,attr.hp,attr.atk,attr.def,attr.dgr,attr.cri,attr.ass,attr.rarity,attr.lv);

    }
    function opencardpack(uint assetid) external{
        (uint tokenId,Attr memory attr) = IBusiness(businessAddr).opencardpack(assetid);
        emit mintEvent(tokenId,attr.types,attr.name,attr.hp,attr.atk,attr.def,attr.dgr,attr.cri,attr.ass,attr.rarity,attr.lv);
    }

    function stake(uint types,uint[] memory assetids) external{
        IBusinessStake(businessStakeAddr).stake(types,assetids);
    }
    function unStake(uint assetid,uint types) external{
        IBusinessStake(businessStakeAddr).unStake(assetid,types);
    }
    function unwear(uint hero,uint equip) external{
        IBusinessStake(businessStakeAddr).unwear(hero,equip);
    }
    function wearequip(uint hero,uint equip) external{
        IBusinessStake(businessStakeAddr).wearequip(hero,equip);   
    }
    function upgradehero(uint assetid) external{
        IBusinessStake(businessStakeAddr).upgradehero(assetid); 
    }
    function upgradeequip(uint assetid) external{
        IBusinessStake(businessStakeAddr).upgradeequip(assetid); 
    }


    function pvpbattle(uint from ,uint to) external{
        (uint isWin,uint coin) = IBusinessBattle(businessBattleAddr).pvpbattle(from,to);
        emit battleEvent(isWin,coin,0,0);
       
        
    }
    function pvebattle(uint self,uint stage)external{
        (uint isWin,EnhanceConfig memory ec) = IBusinessBattle(businessBattleAddr).pvebattle(self,stage);
        emit battleEvent(isWin,ec.coin,ec.stone,ec.rune);
    
    }

    function recover(uint energy) external{
        IBusinessRecover(businessRecoverAddr).recover(energy);
    }
    function repair(uint assetid,uint durability) external{
        IBusinessRecover(businessRecoverAddr).repair(assetid,durability);
    }
    function enhance(uint mainasset,uint[] memory subcard) external{
        IBusinessRecover(businessRecoverAddr).enhance(mainasset,subcard);
    }
    function evolution(uint mainasset) external{
        IBusinessRecover(businessRecoverAddr).evolution(mainasset);
    }
    
    
}