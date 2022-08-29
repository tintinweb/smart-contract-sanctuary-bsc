/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol






/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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


interface IHeroNft{
    function getAttrByTokenId(uint tokenId) external view returns (Attr memory attr);
    function mint(address recipient, Attr memory attr) external returns(uint256);
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
    function withdraw(uint tokenAddrId,address to,uint num) external;
    function getUserPackage(uint key) external view returns(UserPackage memory);
    function delUserPackage(uint key) external;
    function transferNft(address to,uint tokenId) external;
    function deposit(address userAddr,uint coin,uint stone,uint rune)external;
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
        function getHeroConfig(uint index) view external returns(Attr memory);
        function getEquipConfig(uint index) view external returns(Attr memory);
        function getConfig() view external returns (Config memory);
        function getRateConfig() view external returns (RateConfig memory);
    }




contract Business is Ownable {
    
    address public heroNft = 0xE6a7D7d7C4753b3714546A6364139aB39A7eb2e5;
    address IrandomAddr = 0xAE4476F8e055A428fda2f3d812f371Acd90143cB;
    address feeAddr = 0xC431F66fBd5db78B3bD3F04A948F6603814Bf34D;
    address storageAddr = 0xAe3913Fc8733a5a5dc43Cc62e8c46dC7ee57018a;
    address configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;
  
    constructor () {
        
    }
    

    function newaccount(address refer) external{
        Config memory config = IConfig(configAddr).getConfig();
        require(msg.sender != refer,"Sorry,you can not refer your self!");
        User memory userRes = IStorage(storageAddr).getUser(msg.sender);
        require(userRes.regTime == 0,"You have registered!");
        if (refer!=address(0)){
            userRes = IStorage(storageAddr).getUser(refer);
            require(userRes.regTime > 0,"refer not  registered!");
        }
        uint userTalnet = config.defaultTalent;
        uint randomTalent = IRandom(IrandomAddr).getRandom(msg.sender,20);
        if(randomTalent%2!=0){
            userTalnet -= randomTalent;
        }
        else{
            userTalnet += randomTalent;
        }
        
        User memory user = User(0,0,0,msg.sender,refer,200,userTalnet,block.timestamp,0);
        IStorage(storageAddr).setUser(msg.sender,user);
    }

    function deposit(uint coin,uint stone,uint rune) external{
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.regTime > 0,"address not  registered!");
        IStorage(storageAddr).deposit(msg.sender,coin,stone,rune);

        

    }

    function withdraw(uint[] memory tokenNums) external {
        Config memory config = IConfig(configAddr).getConfig();
        require(tokenNums.length ==3 ,"length is error");
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        uint fee = config.fee;
        //ssc
        if (tokenNums[0] > 0){
            require(user.coin >=tokenNums[0]," you dont have engough coin");
            IStorage(storageAddr).withdraw(1,feeAddr,tokenNums[0]*fee/100);
            IStorage(storageAddr).withdraw(1,msg.sender,tokenNums[0] - tokenNums[0]*fee/100 );
            user.coin -= tokenNums[0];
        }
        //sss
        if (tokenNums[1] > 0){
            require(user.stone >=tokenNums[1]," you dont have engough stone");
            IStorage(storageAddr).withdraw(2,feeAddr,tokenNums[1]*fee/100);
            IStorage(storageAddr).withdraw(2,msg.sender,tokenNums[1] - tokenNums[1]*fee/100);
            user.stone -= tokenNums[1];
        }
        //ssr
        if (tokenNums[2] > 0){
            require(user.rune >=tokenNums[2]," you dont have engough rune");
            IStorage(storageAddr).withdraw(3,feeAddr,tokenNums[2]*fee/100);
            IStorage(storageAddr).withdraw(3,msg.sender,tokenNums[2] - tokenNums[2]*fee/100);
            user.rune -= tokenNums[2];
        }
         IStorage(storageAddr).setUser(msg.sender,user);

    }

    function mintnft(uint types) external{
        Config memory config = IConfig(configAddr).getConfig();
        User memory user = IStorage(storageAddr).getUser(msg.sender);
        require(user.regTime > 0,"address not registered!");
        require(types == 0 || types ==1,"Unknow type!");
        RateConfig memory current_rate_config = IConfig(configAddr).getRateConfig();
        if (types ==0){
            require(user.coin >= config.mint_hero_coin,"Sorry, you dont have engough coin to mint hero nft!");
            require(user.rune >= config.mint_hero_rune,"Sorry, you dont have engough rune to mint hero nft!");
            uint heroIndex =  IRandom(IrandomAddr).getRandom(msg.sender,config.hero_num);
            uint heroRarity = getheror(msg.sender,current_rate_config);
            IStorage(storageAddr).withdraw(1,feeAddr,config.mint_hero_coin/2);
            IStorage(storageAddr).withdraw(3,feeAddr,config.mint_hero_rune/2);
            IStorage(storageAddr).withdraw(1,address(0xdead),config.mint_hero_coin/2);
            IStorage(storageAddr).withdraw(3,address(0xdead),config.mint_hero_rune/2);
            user.coin -= config.mint_hero_coin;
            user.rune -= config.mint_hero_rune;
            minthero(msg.sender,heroRarity,heroIndex,config.threhold);
        } else if  (types ==1){
            require(user.coin >= config.mint_equip_coin,"Sorry, you dont have engough coin to mint equip nft!");
            require(user.stone >= config.mint_equip_stone,"Sorry, you dont have engough rune to mint equip nft!");
            uint heroIndex =  IRandom(IrandomAddr).getRandom(msg.sender,config.equip_num);
            uint heroRarity = getequipr(msg.sender,current_rate_config);
            IStorage(storageAddr).withdraw(1,feeAddr,config.mint_equip_coin/2);
            IStorage(storageAddr).withdraw(2,feeAddr,config.mint_equip_stone/2);
            IStorage(storageAddr).withdraw(1,address(0xdead),config.mint_equip_coin/2);
            IStorage(storageAddr).withdraw(2,address(0xdead),config.mint_equip_stone/2);
            user.coin -= config.mint_equip_coin;
            user.stone -= config.mint_equip_stone;
            mintequip(msg.sender,heroRarity,heroIndex,config.threhold);
        }
         IStorage(storageAddr).setUser(msg.sender,user);
        
    }

    function getheror(address addr,RateConfig memory current_rate_config) internal returns (uint){
        
        uint rand = IRandom(IrandomAddr).getRandom(addr,99999);
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

    function getequipr(address addr,RateConfig memory current_rate_config) internal returns (uint){
        uint rand = IRandom(IrandomAddr).getRandom(addr,99999);
        if(rand>=1 && 
            rand<=current_rate_config.elr){
            return 5;
        }
        else if (rand>current_rate_config.elr && 
            rand<=current_rate_config.elr+current_rate_config.essr){
            return 4;
        }
        else if (rand>current_rate_config.elr+current_rate_config.essr && 
            rand<=current_rate_config.elr+current_rate_config.essr+current_rate_config.esr){
            return 3;
        }
        else if(rand>current_rate_config.elr+current_rate_config.essr+current_rate_config.esr &&
        rand<=current_rate_config.elr+current_rate_config.essr+current_rate_config.esr+current_rate_config.er){
            return 2;
        }
        return 1;
    }

    function minthero(address addr,uint rarity,uint heroindex,uint threhold) internal returns(uint){
        uint newIndex = heroindex*5 + (rarity - 1);
        Attr memory hero = IConfig(configAddr).getHeroConfig(newIndex);
     
        uint tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.hp = tmpRand%2==0?hero.hp+hero.hp*tmpRand/(threhold*4):hero.hp-hero.hp*tmpRand/(threhold*4);
        tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.atk = tmpRand%2==0?hero.atk+hero.atk*tmpRand/(threhold*3):hero.atk-hero.atk*tmpRand/(threhold*3);
        tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.def = tmpRand%2==0?hero.def+hero.def*tmpRand/(threhold*3):hero.def-hero.def*tmpRand/(threhold*3);
        tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.dgr= tmpRand%2==0?hero.dgr+hero.dgr*tmpRand/(threhold*2):hero.dgr-hero.dgr*tmpRand/(threhold*2);
        tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.cri = tmpRand%2==0?hero.cri+hero.cri*tmpRand/(threhold*2):hero.cri-hero.cri*tmpRand/(threhold*2);
        tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
        hero.ass = tmpRand%2==0?hero.ass+hero.ass*tmpRand/(threhold*2):hero.ass-hero.ass*tmpRand/(threhold*2);
        uint tokenId = IHeroNft(heroNft).mint(addr,hero);
        return tokenId;
    }

    function mintequip(address addr,uint rarity,uint equipindex,uint threhold) internal returns(uint){
        uint newIndex = equipindex*5 + (rarity - 1);
        Attr memory equip =  IConfig(configAddr).getEquipConfig(newIndex);
        uint tmpRand = 0;
         if(equipindex==0 || equipindex==6 || equipindex==12 || equipindex==18)
        {
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.atk=tmpRand%2==0?equip.atk + equip.atk*tmpRand/(threhold*3):equip.atk-equip.atk*tmpRand/(threhold*3);
        }
        else if(equipindex==1|| equipindex==7 || equipindex==13 || equipindex==19){
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.cri=tmpRand%2==0?equip.cri + equip.cri*tmpRand/(threhold*2):equip.cri-equip.cri*tmpRand/(threhold*2);
        }
        else if(equipindex==2|| equipindex==8 || equipindex==14 || equipindex==20){
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.ass=tmpRand%2==0?equip.ass + equip.ass*tmpRand/(threhold*2):equip.ass-equip.ass*tmpRand/(threhold*2);
        }
        else if(equipindex==3|| equipindex==9 || equipindex==15 || equipindex==21){
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.def=tmpRand%2==0?equip.def + equip.def*tmpRand/(threhold*3):equip.def-equip.def*tmpRand/(threhold*3);
        }
        else if(equipindex==4|| equipindex==10 || equipindex==16 || equipindex==22){
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.dgr=tmpRand%2==0?equip.dgr + equip.dgr*tmpRand/(threhold*2):equip.dgr-equip.dgr*tmpRand/(threhold*2);
        }
        else if(equipindex==5|| equipindex==11 || equipindex==17 || equipindex==23){
            tmpRand = IRandom(IrandomAddr).getRandom(addr,threhold);
            equip.hp=tmpRand%2==0?equip.hp + equip.hp*tmpRand/(threhold*4):equip.hp-equip.hp*tmpRand/(threhold*4);
        }
        else{
            require(false,"unknown equipment to mint");
        }
        uint tokenId = IHeroNft(heroNft).mint(addr,equip);
        return tokenId;

    }

    function makeReqId(address addr,uint tokenId) internal pure returns (uint) {
        uint seed = uint(keccak256(abi.encode(addr, tokenId)));
        return seed;  
    }

    function opencardpack(uint assetid) external{
        UserPackage memory up = IStorage(storageAddr).getUserPackage(makeReqId(msg.sender,assetid));
        require(up.tokenId >0,"package not have asset");
        Attr memory attr = IHeroNft(heroNft).getAttrByTokenId(assetid);
        require((attr.packageType == 1) ||(attr.packageType == 2),"this asset not package");
        Config memory config = IConfig(configAddr).getConfig();
        RateConfig memory current_rate_config = IConfig(configAddr).getRateConfig();
        uint heroIndex =  IRandom(IrandomAddr).getRandom(msg.sender,config.hero_num);
        uint heroRarity = getheror(msg.sender,current_rate_config);
        if (attr.packageType ==1){
            minthero(msg.sender,heroRarity,heroIndex,config.threhold);
        } else if (attr.packageType ==2) {
            mintequip(msg.sender,heroRarity,heroIndex,config.threhold);
        }
        IStorage(storageAddr).delUserPackage(assetid);
        IStorage(storageAddr).transferNft(address(0xdead),assetid);
    }
    
}