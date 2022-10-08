/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

interface IRandom{
    function getRandom(address addr,uint max) external returns(uint);
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
interface IStorage{
    function getUser(address addr) external view returns(User memory);
    function setUser(address addr,User memory user) external;
    function transferNft(address to,uint tokenId) external;
    function deposit(address userAddr,uint coin,uint stone,uint rune)external;

    function mint(address recipient,Attr memory attr) external returns (uint);
    function getAttrByTokenId(uint tokenId) external view returns (Attr memory);

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
    
    interface IConfig{
        function getHeroConfig(uint index) view external returns(Attr memory);
        function getConfig() view external returns (Config memory);
        function getRateConfig() view external returns (RateConfig memory);
    }




contract IDO  is Ownable{

    // address public IrandomAddr = 0xC55CA5A14db1dd276b4b811AEFE56D9f8215e99B;
    // address public feeAddr = 0xC431F66fBd5db78B3bD3F04A948F6603814Bf34D;
    // address public storageAddr = 0xddE61Ac0F6F9a6271785f300F43e156733888fAB;
    // address public configAddr = 0x1e5Ef41a5bE5D81b922c777fe6d7eDA4691304D5;

    address public IrandomAddr = 0xAE4476F8e055A428fda2f3d812f371Acd90143cB;
    address public storageAddr = 0x4dA9276f1194a6Ab7484E00CbAAccb199333FD59;
    address public configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
    address public usdtAddr = 0x07a6406AAa0A3a07404e3c66880776d8Ef49245C;



    event newaccountEvent(address sender,User user);
    event depositEvent(address sender,uint coin,uint stone,uint rune);
    event inviteEvent(address sender,address refer);
  
    //event mintnftEvent(address sender,uint types,uint coin,uint stone,uint rune,uint tokenId);
    event referNftEvent(address sender,address refer,uint rewardNum,uint num);
    uint private useed = 1;

    uint public endTime = 1664971200;
    uint public idoSupply = 9999;
    uint public useIdo = 0;
    uint public price = 30e18;
     uint totalTimes = 10;
    uint intervalTime = 60;
    uint inviteNum = 2;
    uint public gameStartTime = 0;
    uint public  status = 1;  //1 not start 2.start 3.end
    uint inviteReward = 7000e18;
    struct UserClaim{
        uint total;
        uint claimTimes;
        
    }
    mapping (address=>UserClaim) userClaim;
     mapping (address=>uint) userIdoNum;
    mapping (address=>uint) referIdoNum; //ido 
   





    constructor () {
        // gameStartTime = block.timestamp;
        // userClaim[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = UserClaim(5000,0);
    }


    function setInviteReward (uint num) external onlyOwner{
        inviteReward = num;
    }

    function setSatus(uint s) external onlyOwner{
        status = s;
    }

    function setEndTime(uint idoEndTime,uint totalNum,uint gameTime) external onlyOwner{
        if (idoEndTime!=0){
            endTime = idoEndTime;
        }
        if (totalNum!=0){
            idoSupply = totalNum;
        }
        if (gameTime!=0){
            gameStartTime = gameTime;
        }
       
       
    }


    function claim() external{
        require(status==3,"ido not over");
        (uint waitCoin,) = getClaimInternal();
        require(waitCoin>0,"no coin to withdraw");
        UserClaim storage uc = userClaim[tx.origin];
        uc.claimTimes += waitCoin*totalTimes/uc.total;
        require(uc.claimTimes<=totalTimes,"you have claim over");
        deposit(waitCoin,0,0);
        
        
        
    }
    
    function getClaim()external view returns(uint,uint){
        return getClaimInternal();
    }

    function getClaimInternal() internal view returns(uint,uint){
        uint waitCoin;
        uint lockCoin;
        uint times;
        if ((block.timestamp < gameStartTime) || (gameStartTime == 0)){
            return (0,userClaim[tx.origin].total);
        }
        if ((gameStartTime+totalTimes*intervalTime) < block.timestamp){
            waitCoin = userClaim[tx.origin].total * (totalTimes-userClaim[tx.origin].claimTimes) /totalTimes;
            lockCoin = 0;
            times = totalTimes + 1;

        } else {
            times = totalTimes - (gameStartTime+totalTimes*intervalTime - block.timestamp)/intervalTime - 1;
            waitCoin = userClaim[tx.origin].total *(times - userClaim[tx.origin].claimTimes)/totalTimes;
            lockCoin = (totalTimes - times) *userClaim[tx.origin].total / totalTimes;
        }
        
        return (waitCoin,lockCoin);
    }

    function getIdo()external view returns(uint ,uint ,uint ,uint){
        return (endTime,idoSupply,useIdo,price);
    }

    

    function withdraw(address tokenAddr,address to,uint num) external onlyOwner{
        IERC20(tokenAddr).transfer(to,num);
    }




    function newaccount(address refer) external{
        Config memory config = IConfig(configAddr).getConfig();
        require(tx.origin != refer,"Sorry,you can not refer your self!");
        User memory userRes = IStorage(storageAddr).getUser(tx.origin);
        require(userRes.regTime == 0,"You have registered!");
        if (refer!=address(0)){
            userRes = IStorage(storageAddr).getUser(refer);
            require(userRes.regTime > 0,"refer not  registered!");
        }
        uint userTalnet = config.defaultTalent;
        uint randomTalent = IRandom(IrandomAddr).getRandom(tx.origin,20);
        if(randomTalent%2!=0){
            userTalnet -= randomTalent;
        }
        else{
            userTalnet += randomTalent;
        }

        User memory user = User(0,0,0,tx.origin,refer,200,userTalnet,block.timestamp,0);
        IStorage(storageAddr).setUser(tx.origin,user);
        emit newaccountEvent(tx.origin,user);
    }


    function invite(address refer)external{

        require(refer !=address(0),"refer address is null");
        require(refer !=tx.origin,"you can't invite youself");
        User memory user = IStorage(storageAddr).getUser(tx.origin);
        require(user.referAddr == address(0),"this user have refer");
        user.referAddr = refer;
        emit inviteEvent(tx.origin,refer);
        IStorage(storageAddr).setUser(tx.origin,user);
    }

    function deposit(uint coin,uint stone,uint rune) internal{
        User memory user = IStorage(storageAddr).getUser(tx.origin);
        user.coin += coin;
        user.stone += stone;
        user.rune += rune;
        IStorage(storageAddr).setUser(tx.origin,user);
        emit depositEvent(tx.origin,coin,stone,rune);
    }

  

    function randomz(uint seed,uint max) internal returns(uint){

        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty,useed, block.timestamp, seed)));
        random = random % max;
        useed ++;
        return random;
    }

    function ido(uint num) external returns(uint[] memory,Attr[] memory){
        if (status == 1){
            require(false,"ido is not start");
        }
        require(status == 2,"ido is over");
        //require(num + useIdo <= idoSupply,"supply is Insufficient");
       
        require((num >0) &&(num<6),"num is between 1 and 5");
        Config memory config = IConfig(configAddr).getConfig();
        User memory user = IStorage(storageAddr).getUser(tx.origin);
        require(user.regTime > 0,"address not registered!");
       
        RateConfig memory current_rate_config = IConfig(configAddr).getRateConfig();
        uint prand = IRandom(IrandomAddr).getRandom(tx.origin,1e9)+1e9;
        uint tokenId;
        Attr memory attr;
        Attr[] memory attrs = new Attr[](num);
        uint[] memory tokenIds = new uint[](num);

        uint heroIndex;
        uint heroRarity;
        //uint coinNum;
        for (uint i=0;i<num;i++){
            heroIndex =  randomz(prand,config.hero_num);
            heroRarity = getheror(current_rate_config,prand);
            (tokenId,attr) = minthero(tx.origin,heroRarity,heroIndex,config.threhold,prand);
            
            attrs[i] = attr;
            tokenIds[i] = tokenId;
    
        }
        inviteBus(user.referAddr,num);
        
         return (tokenIds,attrs);
    }

   

    function inviteBus(address refer,uint num) internal {
        
        UserClaim storage uc =  userClaim[tx.origin];
        
        if  (refer != address(0)){
            referIdoNum[refer]++;
            if (referIdoNum[refer]%inviteNum ==0){
               uc.total += inviteReward;
                
            }
        }
        emit referNftEvent(tx.origin,refer,inviteReward,num);
        userIdoNum[tx.origin] +=num;
        useIdo+=num;

        IERC20(usdtAddr).transferFrom(tx.origin,address(this),num*price);

        
       
    }

    function getheror(RateConfig memory current_rate_config,uint prand) internal  returns (uint){

        uint rand = randomz(prand,99999);
        if(rand>=1 &&
            rand<=current_rate_config.hlr){
            return 5;
        }
        else if (rand>current_rate_config.hlr &&
            rand<=current_rate_config.hlr+current_rate_config.hssr){
            return 4;
        }
        else if (rand>current_rate_config.hlr+current_rate_config.hssr &&
            rand<=current_rate_config.hlr+current_rate_config.hssr+current_rate_config.hsr){
            return 3;
        }
        else if(rand>current_rate_config.hlr+current_rate_config.hssr+current_rate_config.hsr &&
        rand<=current_rate_config.hlr+current_rate_config.hssr+current_rate_config.hsr+current_rate_config.hr){
            return 2;
        }
        return 1;
    }

    

    function minthero(address addr,uint rarity,uint heroindex,uint threhold,uint prand) internal returns(uint,Attr memory){
        uint newIndex = heroindex*5 + (rarity - 1);
        Attr memory hero = IConfig(configAddr).getHeroConfig(newIndex);
        uint tmpRand = randomz(prand,threhold);
        hero.hp = tmpRand%2==0?hero.hp+hero.hp*tmpRand/(threhold*4):hero.hp-hero.hp*tmpRand/(threhold*4);
        tmpRand = randomz(prand,threhold);
        hero.atk = tmpRand%2==0?hero.atk+hero.atk*tmpRand/(threhold*3):hero.atk-hero.atk*tmpRand/(threhold*3);
        tmpRand = randomz(prand,threhold);
        hero.def = tmpRand%2==0?hero.def+hero.def*tmpRand/(threhold*3):hero.def-hero.def*tmpRand/(threhold*3);
       tmpRand = randomz(prand,threhold);
        hero.dgr= tmpRand%2==0?hero.dgr+hero.dgr*tmpRand/(threhold*2):hero.dgr-hero.dgr*tmpRand/(threhold*2);
        tmpRand = randomz(prand,threhold);
        hero.cri = tmpRand%2==0?hero.cri+hero.cri*tmpRand/(threhold*2):hero.cri-hero.cri*tmpRand/(threhold*2);
        tmpRand = randomz(prand,threhold);
        hero.ass = tmpRand%2==0?hero.ass+hero.ass*tmpRand/(threhold*2):hero.ass-hero.ass*tmpRand/(threhold*2);
        hero.lv = 1;
        uint tokenId = IStorage(storageAddr).mint(addr,hero);
        return (tokenId,hero);
    }

   

    function makeReqId(address addr,uint tokenId) internal  pure returns (uint) {
        uint seed = uint(keccak256(abi.encode(addr, tokenId)));
        return seed;
    }


 

}