/**
 *Submitted for verification at BscScan.com on 2022-09-01
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
    function getUserHero(uint key) external view returns(UserHero memory);
    function getUserEquip(uint key) external view returns(UserEquip memory);
    function getUserPackage(uint key) external view returns(UserPackage memory);
    function getUserTool(uint key) external view returns(UserTool memory);
    function getUserHeroList(address userAddr) external view returns (uint[] memory);
    function getUserEquipList(address userAddr) external view returns (uint[] memory);
    function getUserPackageList(address userAddr) external view returns (uint[] memory);
    function getUserToolList(address userAddr) external view returns (uint[] memory);
}
interface IBusiness{
    function newaccount(address refer) external;
    function deposit(uint coin,uint stone,uint rune) external;
    function mintnft(uint types) external;
    function opencardpack(uint assetid) external;
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
    function evolution(uint mainasset) external;
    function pvpbattle(uint from ,uint to) external;
    function pvebattle(uint self,uint stage)external;

}

interface IBusinessRecover{
    function recover(uint energy) external;
    function repair(uint assetid,uint durability) external;
    function enhance(uint mainasset,uint[] memory subcard) external;
    function approve() external;
}



contract interfaceServer  is Ownable {
    address public configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
    address public storageAddr = 0xAe3913Fc8733a5a5dc43Cc62e8c46dC7ee57018a;
    address public businessAddr = 0xCE52251359d2dA932C2100FeE0a9EF7ADcB41F98;
    address public businessStakeAddr = 0x7b415e91b66482892D24CF4e214F8E552ACb4845;
    address public businessBattleAddr = 0x0f26127843e63Ec3A6990037A70AEb05b6561732;
    address public businessRecoverAddr = 0x8dd6cbCe6eb417eFeEa201C899cD9fea4563Cd43;



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
    function getUserHero(uint key) external view returns(UserHero memory){
        return IStorage(storageAddr).getUserHero(key);
    }
    function getUserEquip(uint key) external view returns(UserEquip memory){
        return IStorage(storageAddr).getUserEquip(key);
    }
    function getUserPackage(uint key) external view returns(UserPackage memory){
        return IStorage(storageAddr).getUserPackage(key);
    }
    function getUserTool(uint key) external view returns(UserTool memory){
        return IStorage(storageAddr).getUserTool(key);
    }
    function getUserHeroList(address userAddr) external view returns (uint[] memory){
        return IStorage(storageAddr).getUserHeroList(userAddr);
    }

    function getUserEquipList(address userAddr) external view returns (uint[] memory){
         return IStorage(storageAddr).getUserEquipList(userAddr);
    }
    function getUserPackageList(address userAddr) external view returns (uint[] memory){
        return IStorage(storageAddr).getUserPackageList(userAddr);
    }
    function getUserToolList(address userAddr) external view returns (uint[] memory){
        return IStorage(storageAddr).getUserToolList(userAddr);
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
        IBusiness(businessAddr).mintnft(types);
    }
    function opencardpack(uint assetid) external{
        IBusiness(businessAddr).opencardpack(assetid);
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

    function evolution(uint mainasset) external{
        IBusinessBattle(businessBattleAddr).evolution(mainasset);
    }
    function pvpbattle(uint from ,uint to) external{
        IBusinessBattle(businessBattleAddr).pvpbattle(from,to);
    }
    function pvebattle(uint self,uint stage)external{
        IBusinessBattle(businessBattleAddr).pvebattle(self,stage);
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
    function approve() external{
        IBusinessRecover(businessRecoverAddr).approve();
    }
    
}