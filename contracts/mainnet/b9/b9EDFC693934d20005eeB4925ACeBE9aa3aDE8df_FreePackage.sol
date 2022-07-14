// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./String.sol";
import "./Util.sol";

import "./Shop.sol";
import "./Member.sol";
import "./ERC721Enumerable.sol";
import './SafeMath.sol';

abstract contract FreeNft{
    function mintByPackage(address to, uint packageId,uint256 rare) external virtual returns (uint tokenId);
}
contract FreePackage is Member, ERC721Enumerable {
    using String for string;
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant NFT_SIGN_BIT = 1 << 255;
    uint private totalAccount;
    
    struct ShopInfo {
        uint256 id;
        bool enabled;
    }

    FreeNft private characterNft;
    

    mapping(uint256 => uint256) public packageRareMapping;

    
    mapping(address => ShopInfo) public shopInfos;
    
    uint256 public shopCount;
    
    function setCharacterNftAddress(address _characterNft) external CheckPermit("Config") {
        characterNft = FreeNft(_characterNft);
    }

    

    constructor(string memory name, string memory symbol, address _characterNft) ERC721(name, symbol) {
        characterNft = FreeNft(_characterNft);
        totalAccount = 0;
    }

    event Mint(
        address to,
        uint256 packageId,
        uint256 quantity,
        uint256 packageNumber,
        uint256 packageRare,
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
        uint256 quantity,
        uint256 packageRare
    ) external returns (uint[] memory totalTokenIds){
        require(shopInfos[msg.sender].enabled, "shop not enabled");
        uint256 shopId = shopInfos[msg.sender].id;
        uint thisId = 1;
        totalTokenIds = new uint[](quantity);
        for (uint i = 0; i < quantity; i++) {
            uint256 packageId = NFT_SIGN_BIT |
            (uint256(uint32(shopId)) << 224) |
            (uint256(uint64(totalAccount)) << 160) |
            (uint256(uint16(quantity)) << 144) |
            (uint256(uint40(shopCount)) << 104) |
            (block.timestamp << 64) |
            (uint64(thisId + totalSupply()));
            thisId++;
            totalTokenIds[i] = packageId;
            
            _mintOld(to, packageId);
            totalAccount = totalAccount.add(1);
            packageRareMapping[packageId] = packageRare;
            emit Mint(to, packageId, quantity,totalAccount, packageRare, 1);
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

        
        characterNft.mintByPackage(_owners[packageId],packageId,packageRareMapping[packageId]);
        
        _burnOld(packageId);

        
        delete packageRareMapping[packageId];
    }
}