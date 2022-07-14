// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./String.sol";
import "./Util.sol";

import "./Shop.sol";
import "./Member.sol";
import "./ERC721Enumerable.sol";
import './SafeMath.sol';

abstract contract CharacterAndEquipmentNft{
    function mintByPackage(address to, uint packageId) external virtual  returns (uint tokenId);
}

contract Package is Member, ERC721Enumerable {
    using String for string;
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant NFT_SIGN_BIT = 1 << 255;
    uint private totalAccount;
    
    struct ShopInfo {
        uint256 id;
        bool enabled;
    }

    CharacterAndEquipmentNft private characterNft;
    CharacterAndEquipmentNft private equipmentNft;
   
    struct PackageInfo {
        uint256 blockNumber;
        Shop shop;
        uint buyCont;
        uint nftType;
        uint price;
        CharacterAndEquipmentNft ntfAddress;
    }

    
    mapping(uint256 => PackageInfo) public packageInfos;

    
    mapping(address => ShopInfo) public shopInfos;
    
    uint256 public shopCount;
    
    function setCharacterNftAddress(address _characterNft) external CheckPermit("Config") {
        characterNft = CharacterAndEquipmentNft(_characterNft);
    }

    function setEquipmentNftAddress(address _equipmentNft) external CheckPermit("Config") {
        equipmentNft = CharacterAndEquipmentNft(_equipmentNft);
    }

    constructor(string memory name, string memory symbol, address _characterNft, address _equipmentNft) ERC721(name, symbol) {
        characterNft = CharacterAndEquipmentNft(_characterNft);
        equipmentNft = CharacterAndEquipmentNft(_equipmentNft);
        totalAccount = 0;
    }

    event Mint(
        address to,
        uint256 packageId,
        uint256 shop,
        uint256 amount,
        uint256 nftType,
        uint256 quantity,
        uint256 packageNumber,
        uint256 logeType
    );

    
    function setShop(address addr, bool enable) external CheckPermit("Config") {
        
        ShopInfo storage si = shopInfos[addr];
        
        if (si.id == 0) {
            si.id = ++shopCount;
        }
        
        si.enabled = enable;
    }

    
    function mint(
        address to, 
        uint256 tokenAmount,
        uint256 quantity, 
        uint256 padding,
        uint256 nftType, 
        uint256 payAmount
    ) external returns (uint[] memory totalTokenIds){
        require(shopInfos[msg.sender].enabled, "shop not enabled");
        uint256 shopId = shopInfos[msg.sender].id;
        uint thisId = 1;
        totalTokenIds = new uint[](quantity);
        for (uint i = 0; i < quantity; i++) {
            uint256 packageId = NFT_SIGN_BIT |
            (uint256(uint32(shopId)) << 224) |
            (uint256(uint64(tokenAmount)) << 160) |
            (uint256(uint16(quantity)) << 144) |
            (uint256(uint40(padding)) << 104) |
            (block.timestamp << 64) |
            (uint64(thisId + totalSupply()));
            thisId++;
            totalTokenIds[i] = packageId;
            packageInfos[packageId].blockNumber = block.number + 1;
            packageInfos[packageId].shop = Shop(msg.sender);
            packageInfos[packageId].buyCont = 1;
            packageInfos[packageId].nftType = nftType;
            packageInfos[packageId].price = payAmount.div(quantity);
            if (nftType == 1) {
                packageInfos[packageId].ntfAddress = characterNft;
            } else {
                packageInfos[packageId].ntfAddress = equipmentNft;
            }
            _mintOld(to, packageId);
            totalAccount = totalAccount.add(1);
            emit Mint(to, packageId, shopId, payAmount, nftType, quantity, totalAccount, 1);
        }

    }

    
    function getAccountAllTokens(address account) external view returns (uint256[] memory){
        uint256 balance_ = balanceOf(account);
        uint256[] memory ids = new uint256[](balance_);
        if (balance_ > 0) {
            for (uint256 i = 0; i < balance_; i++) {
                ids[i] = tokenOfOwnerByIndex(account, i);
            }
        }
        return ids;
    }


    function open(uint256 packageId) external {

        require(msg.sender == _owners[packageId], "you not own this package");

        
        packageInfos[packageId].ntfAddress.mintByPackage(_owners[packageId],packageId);
        
        _burnOld(packageId);

        
        delete packageInfos[packageId];
    }

}