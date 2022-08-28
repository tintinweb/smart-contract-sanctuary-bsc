/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract rorConfig is Ownable {

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

    

    mapping(uint=>Attr) heroList;
    mapping(uint=>Attr) equipList;
    mapping(uint=>UpCost) upHeroCostList;
    mapping(uint=>UpCost) upEquipCostList;

    mapping(uint=>PvEConfig) PvEConfigList;
    mapping(uint=>PVPReward) PVPRewardList;
    mapping(uint=>PVEReward) PVERewardList;
    mapping(uint=>PVPCost) PVPCostList;

    mapping (uint=>HeroevolConfig) heroevolConfig;
    mapping(uint=>EvolConfig) evolConfig;

    mapping (uint=>EnhanceConfig) evolCostHuman;
    mapping (uint=>EnhanceConfig) evolCostGod;


    Config config;
    RateConfig rateConfig;
    EnhanceConfig enhanceConfig;
    EnhanceConfig repairConfig;
    EnhanceConfig recoverConfig;
    UpdateConfig updateConfig;
    PVPRateConfig pvpRateConfig;
    PowerConfig powerConfig;

    constructor () {
        config = Config(100,1500e18,1500e18,2000e18,2000e18,12,12,20,5,10,130,150,134,200);
        rateConfig = RateConfig(78858,19890,1200,50,2,78858,19890,1200,50,2);
        updateConfig = UpdateConfig(1250,1325,1325,1200,1200,1200);
        enhanceConfig = EnhanceConfig(200e18,200e18,200e18);
        repairConfig = EnhanceConfig(1e18,4e18,0);
        recoverConfig = EnhanceConfig(1e18,0,3e18);
        pvpRateConfig = PVPRateConfig(25,20,5);
        powerConfig = PowerConfig(2,10,10,100,100,100);
    }

    function getPvEConfigList(uint stage)view external returns(PvEConfig memory){
        return PvEConfigList[stage];
    } 

    function getPowerConfig()view external returns(PowerConfig memory){
        return powerConfig;
    }
    function getPVPRateConfig()view external returns(PVPRateConfig memory){
        return pvpRateConfig;
    }
    function getHeroevolConfig(uint index) view external returns(HeroevolConfig memory){
        return heroevolConfig[index];
    }
    function getEvolCostHuman(uint index) view external returns(EnhanceConfig memory){
        return evolCostHuman[index];
    }
    function getEvolCostGod(uint index) view external returns(EnhanceConfig memory){
        return evolCostGod[index];
    }

    function getEvolConfig(uint index) view external returns(EvolConfig memory){
        return evolConfig[index];
    }

    function getEnhanceConfig()view external returns (EnhanceConfig memory){
        return enhanceConfig;
    }

    function getUpdateConfig() view external returns (UpdateConfig memory){
        return updateConfig;
    }
    
    function getHeroConfig(uint index) view external returns(Attr memory){
        return heroList[index];
    }

    function getEquipConfig(uint index) view external returns(Attr memory){
        return equipList[index];
    }
    function getConfig() view external returns (Config memory){
        return config;
    }
    function getRateConfig() view external returns (RateConfig memory){
        return rateConfig;
    }

    function getUpHeroCost(uint level) view external returns (UpCost memory){
        return upHeroCostList[level];
    }
    function getUpEquipCost(uint level) view external returns (UpCost memory){
        return upEquipCostList[level];
    }
    function getPvpCost(uint level) view external returns (PVPCost memory){
        return PVPCostList[level];
    }
    function getPVPRewardList(uint level) view external returns (PVPReward memory){
        return PVPRewardList[level];
    }

    function getPVERewardList(uint stage) view external returns (PVEReward memory){
        return PVERewardList[stage];
    }
    function getRecoverConfig() external view returns (EnhanceConfig memory){
        return recoverConfig;
    }

    function getRepairConfig() external view returns (EnhanceConfig memory){
        return repairConfig;
    }

    

   

    
    function setConfig(Config memory cfg) external onlyOwner {
        config = cfg;
    }
    function setRateConfig(RateConfig memory cfg) external onlyOwner {
        rateConfig = cfg;
    }
    function setUpdateConfig(UpdateConfig memory cfg) external onlyOwner {
        updateConfig = cfg;
    }
    function setEnhanceConfig(EnhanceConfig memory cfg) external onlyOwner {
        enhanceConfig = cfg;
    }
    function setRepairConfig(EnhanceConfig memory cfg) external onlyOwner {
        repairConfig = cfg;
    }
    function setRecoverConfig(EnhanceConfig memory cfg) external onlyOwner {
        recoverConfig = cfg;
    }

    function setPvpRateConfig(PVPRateConfig memory cfg) external onlyOwner{
        pvpRateConfig = cfg;
    }
    function setPowerConfig(PowerConfig memory cfg) external onlyOwner{
        powerConfig = cfg;
    }


    function setHeroConfig(Attr[] memory hero)external onlyOwner{
        for (uint i=0;i<hero.length;i++) {
            heroList[i] = hero[i];
        }
        
    }
    function setEquipConfig(Attr[] memory equip)external onlyOwner {
        for (uint i=0;i<equip.length;i++) {
            equipList[i] = equip[i];
        }
    }
    function setUpHeroCostList(UpCost[] memory uc)external onlyOwner{
        for (uint i=0;i<uc.length;i++) {
            upHeroCostList[uc[i].lv] = uc[i];
        }
    }
    function setUpEquipCostList(UpCost[] memory uc)external onlyOwner{
        for (uint i=0;i<uc.length;i++) {
            upEquipCostList[uc[i].lv] = uc[i];
        }
    }

    function setPvEConfigList(PvEConfig[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            PvEConfigList[i+1] = pc[i];
        }
    }

    function setPVPRewardList(PVPReward[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            PVPRewardList[i+1] = pc[i];
        }
    }
    function setPVERewardList(PVEReward[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            PVERewardList[i+1] = pc[i];
        }
    }
    function setPVPCostList(PVPCost[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            PVPCostList[i+1] = pc[i];
        }
    }
    function setHeroevolConfig(HeroevolConfig[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            heroevolConfig[i] = pc[i];
        }
    }
    function setEvolConfig(EvolConfig[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            evolConfig[i] = pc[i];
        }
    }

    function setEvolCostHuman(EnhanceConfig[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            evolCostHuman[i+1] = pc[i];
        }
    }

    function setEvolCostGod(EnhanceConfig[] memory pc) external onlyOwner{
        for (uint i=0;i<pc.length;i++) {
            evolCostGod[i+1] = pc[i];
        }
    }
}