/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;


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

    struct UserPackage{
        uint tokenId;
        Attr attr;
    }
    struct UserTool{
        uint tokenId;
        Attr attr;
    }
    struct UpCost {
        uint exp;
        uint coin;
        uint stone;
        uint rune;
        uint br;
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
    interface IStorage{
        function setUserHero(address userAddr,uint tokenId,UserHero memory userHero) external;
        function setUserEquip(address userAddr,uint tokenId,UserEquip memory userEquip) external; 
        function setUserPackage(address userAddr,uint tokenId,UserPackage memory userPackage) external;
        function setUserTool(address userAddr,uint tokenId,UserTool memory userTool) external;
        function getUserHero(uint key) external view returns(UserHero memory);
        function getUserEquip(uint key) external view returns(UserEquip memory);
        function delUserHero(uint key) external;
        function delUserEquip(uint key) external;
        function transferNft(address to,uint tokenId) external;
        function pay(address userAddr,uint coin,uint stone,uint rune) external;
        function getDurability(uint equipId) external view returns(uint);
        function setDurability(uint equipId,uint dur) external;
    }
    interface IHeroNft{
        function setAttr(uint tokenId, Attr memory attr) external;
        function getAttrByTokenId(uint tokenId) external view returns (Attr memory attr);

    }
    interface IConfig{
        function getUpHeroCost(uint level) view external returns (UpCost memory);
        function getUpEquipCost(uint level) view external returns (UpCost memory);
        function getUpdateConfig() view external returns (UpdateConfig memory);
        function getEnhanceConfig() view external returns (EnhanceConfig memory);
    }



contract stakeServer {
    address public heroNft = 0xE6a7D7d7C4753b3714546A6364139aB39A7eb2e5;
    address storageAddr = 0xAe3913Fc8733a5a5dc43Cc62e8c46dC7ee57018a;
     address configAddr = 0xAE258a843A6998EdDdb76F8E4c953eAE016D7776;


    constructor () {
        
    }
    
    function makeReqId(address addr,uint tokenId) internal pure returns (uint) {
        uint seed = uint(keccak256(abi.encode(addr, tokenId)));
        return seed;  
    }
    // 1.hero 2.equip 3.package 4.tool
    function stake(uint types,uint[] memory assetids) external{
        require(types>0 && types <5,"unkown type");
        require(assetids.length >0," assetids length is 0");
        Attr memory attr;
        uint key;
        if (types == 1){
            for (uint i=0;i<assetids.length;i++){
                key = makeReqId(msg.sender,assetids[i]);
                attr = IHeroNft(heroNft).getAttrByTokenId(assetids[i]);
                require(attr.types == 1,"this nft not hero");
                IERC721(heroNft).transferFrom(msg.sender,storageAddr,assetids[i]);
                IStorage(storageAddr).setUserHero(msg.sender,assetids[i],UserHero(assetids[i],0,0,0,0,0,0,block.timestamp,attr,0,0));
                
            }   
        } else if (types == 2){
            for (uint i=0;i<assetids.length;i++){
                key = makeReqId(msg.sender,assetids[i]);
                attr = IHeroNft(heroNft).getAttrByTokenId(assetids[i]);
                require(attr.types == 2,"this nft not equip");
                IERC721(heroNft).transferFrom(msg.sender,storageAddr,assetids[i]);
                uint dur = IStorage(storageAddr).getDurability(assetids[i]);
                if (dur==0){
                    IStorage(storageAddr).setDurability(assetids[i],200);
                }
                IStorage(storageAddr).setUserEquip(msg.sender,assetids[i],UserEquip(assetids[i],0,block.timestamp,block.timestamp+ 6*60*60,attr));
            }
        } else if (types == 3){
            for (uint i=0;i<assetids.length;i++){
                key = makeReqId(msg.sender,assetids[i]);
                attr = IHeroNft(heroNft).getAttrByTokenId(assetids[i]);
                require(attr.types == 3,"this nft not package");
                IERC721(heroNft).transferFrom(msg.sender,storageAddr,assetids[i]);
                IStorage(storageAddr).setUserPackage(msg.sender,assetids[i],UserPackage(assetids[i],attr));
            }
        } else {
            for (uint i=0;i<assetids.length;i++){
                key = makeReqId(msg.sender,assetids[i]);
                attr = IHeroNft(heroNft).getAttrByTokenId(assetids[i]);
                require(attr.types == 4,"this nft not tool");
                IERC721(heroNft).transferFrom(msg.sender,storageAddr,assetids[i]);
                IStorage(storageAddr).setUserTool(msg.sender,assetids[i],UserTool(assetids[i],attr));
            }
        }

    }

    function unStake(uint assetid,uint types) external{
        require(types>0 && types <=2,"error type");
        if (types == 1){
            uint key = makeReqId(msg.sender,assetid);
            UserHero memory userHero = IStorage(storageAddr).getUserHero(key);
            require(userHero.tokenId >0,"you do not own this hero nft");
            require((block.timestamp - 24*60*60)>userHero.stakeTime,"your asset is still on cooldown,please wait");
            require(userHero.wear_1==0,"sorry,you have to unequip all equipment first");
            require(userHero.wear_2==0,"sorry,you have to unequip all equipment first");
            require(userHero.wear_3==0,"sorry,you have to unequip all equipment first");
            require(userHero.wear_4==0,"sorry,you have to unequip all equipment first");
            require(userHero.wear_5==0,"sorry,you have to unequip all equipment first");
            require(userHero.wear_6==0,"sorry,you have to unequip all equipment first");
            IStorage(storageAddr).transferNft(msg.sender,assetid);
            IStorage(storageAddr).delUserHero(key);
        } else if (types ==2){
            uint key = makeReqId(msg.sender,assetid);
            UserEquip memory userEquip = IStorage(storageAddr).getUserEquip(key);
            require(userEquip.tokenId >0,"you do not own this equip nft");
            require((block.timestamp - 24*60*60)>userEquip.stakeTime,"your asset is still on cooldown,please wait");
            require(userEquip.isUsed > 0,"please unequip your equipemnt first");
            require(block.timestamp >userEquip.lockTime,"your equipment was equipped before and once on locked,please wait max 6 hour to unequip");
            IStorage(storageAddr).transferNft(msg.sender,assetid);
            IStorage(storageAddr).delUserEquip(key);
        }
    }

    function unwear(uint hero,uint equip) external{
        
        
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,hero));
        require(userHero.tokenId >0," you please stake nft");
        UserEquip memory userEquip = IStorage(storageAddr).getUserEquip(makeReqId(msg.sender,equip));
        require(userEquip.tokenId >0," you please stake nft");
        require(userEquip.lockTime > block.timestamp,"your equipment was equipped before and once on locked,please wait max 6 hour to unequip");
        if (userEquip.attr.position == 1) {
            require(userHero.wear_1 == equip,"you not wear this equip");
            userHero.wear_1 =0;
        } else if (userEquip.attr.position == 2) {
            require(userHero.wear_2 ==equip,"you not wear this equip");
            userHero.wear_2 =0;
        } else if (userEquip.attr.position ==3) {
            require(userHero.wear_3 ==equip,"you not wear this equip");
            userHero.wear_3 =0;
        }else if (userEquip.attr.position == 4) {
            require(userHero.wear_4 ==equip,"you not wear this equip");
            userHero.wear_4 =0;
        }else if (userEquip.attr.position == 5) {
            require(userHero.wear_5 ==equip,"you not wear this equip");
            userHero.wear_5 =0;
        }else if (userEquip.attr.position == 6) {
            require(userHero.wear_6 ==equip,"you not wear this equip");
            userHero.wear_6 =0;
        } else {
            require(false,"error equip position");
        }
        userEquip.isUsed = 0;
        IStorage(storageAddr).setUserEquip(msg.sender,equip,userEquip);
        IStorage(storageAddr).setUserHero(msg.sender,hero,userHero);
    }

    function wearequip(uint hero,uint equip) external{
        
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,hero));
        require(userHero.tokenId >0," you please stake nft");
        UserEquip memory userEquip = IStorage(storageAddr).getUserEquip(makeReqId(msg.sender,equip));
        require(userEquip.tokenId >0," you please stake nft");
        require(userEquip.isUsed != hero,"you have wear this equip");
        require(userEquip.isUsed ==0," this equip is used by other hero!");
        if (userEquip.attr.position == 1) {
            require(userHero.wear_1 == 0,"you have equiped equipment on this position 1");
            userHero.wear_1 =equip;
        } else if (userEquip.attr.position == 2) {
            require(userHero.wear_2 ==0,"you have equiped equipment on this position 2");
            userHero.wear_2 =equip;
        } else if (userEquip.attr.position ==3) {
            require(userHero.wear_3 ==0,"you have equiped equipment on this position 3");
            userHero.wear_3 =equip;
        }else if (userEquip.attr.position == 4) {
            require(userHero.wear_4 ==0,"you have equiped equipment on this position 4");
            userHero.wear_4 =equip;
        }else if (userEquip.attr.position == 5) {
            require(userHero.wear_5 ==0,"you have equiped equipment on this position 5");
            userHero.wear_5 =equip;
        }else if (userEquip.attr.position == 6) {
            require(userHero.wear_6 ==0,"you have equiped equipment on this position 6");
            userHero.wear_6 =equip;
        } else {
            require(false,"error equip position");
        }
        userEquip.isUsed = hero;
        userEquip.lockTime = 6*60 *60;
        IStorage(storageAddr).setUserEquip(msg.sender,equip,userEquip);
        IStorage(storageAddr).setUserHero(msg.sender,hero,userHero); 
    }

    function upgradehero(uint assetid) external{
        UserHero memory userHero = IStorage(storageAddr).getUserHero(makeReqId(msg.sender,assetid));
        require(userHero.tokenId >0," you please stake nft");
        uint level = userHero.attr.lv;
        uint exp = userHero.attr.exp;
        UpCost memory upCost = IConfig(configAddr).getUpHeroCost(level + 1);
        require(upCost.exp >0,"not have the level config");
        require(exp >= upCost.exp,"your experience is not enough");
        IStorage(storageAddr).pay(msg.sender,upCost.coin,upCost.stone,upCost.rune);
        UpdateConfig memory upCfg = IConfig(configAddr).getUpdateConfig();
        Attr memory attr = userHero.attr;
        attr.hp = upCfg.hp * attr.hp /1000;
        attr.atk = upCfg.atk * attr.atk /1000;
        attr.def = upCfg.def * attr.def /1000;
        attr.cri = upCfg.cri * attr.cri /1000;
        attr.dgr = upCfg.dgr * attr.dgr /1000;
        attr.ass = upCfg.ass * attr.ass /1000;
        attr.lv = attr.lv +1;
        attr.exp = attr.exp - upCost.exp;
        userHero.attr = attr;
        IStorage(storageAddr).setUserHero(msg.sender,assetid,userHero);
        IHeroNft(heroNft).setAttr(assetid,attr);
    }

    function upgradeequip(uint assetid) external{
        UserEquip memory userEquip = IStorage(storageAddr).getUserEquip(makeReqId(msg.sender,assetid));
        require(userEquip.tokenId >0," you please stake nft");
        uint level = userEquip.attr.lv;
        UpCost memory upCost = IConfig(configAddr).getUpEquipCost(level + 1);
        require(upCost.exp >0,"not have the level config");
        IStorage(storageAddr).pay(msg.sender,upCost.coin,upCost.stone,upCost.rune);
        UpdateConfig memory upCfg = IConfig(configAddr).getUpdateConfig();
        Attr memory attr = userEquip.attr;
        attr.hp = upCfg.hp * attr.hp /1000;
        attr.atk = upCfg.atk * attr.atk /1000;
        attr.def = upCfg.def * attr.def /1000;
        attr.cri = upCfg.cri * attr.cri /1000;
        attr.dgr = upCfg.dgr * attr.dgr /1000;
        attr.ass = upCfg.ass * attr.ass /1000;
        attr.lv = attr.lv +1;
        userEquip.attr = attr;
        IStorage(storageAddr).setUserEquip(msg.sender,assetid,userEquip);
        IHeroNft(heroNft).setAttr(assetid,attr);
    }
    
}