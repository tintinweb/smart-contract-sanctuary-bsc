//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IGEMUNIItem.sol";
import "./interfaces/IGENIPass.sol";
import "./interfaces/IGEMUNIMarketplace.sol";
import "./interfaces/IGENIPassSale.sol";
import "./interfaces/IGENI.sol";
import "./utils/PermissionGroupUpgradeable.sol";

contract GEMUNIMarketplace is IGEMUNIMarketplace, PermissionGroupUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IGENI;

    IGEMUNIItem public gemuniItem;
    IGENIPass public geniPass;
    IGENI public geni;
    IGENIPassSale public geniPassSale;

    address public treasury;
    uint public feeRate;
    uint constant decimalRate = 10000;
    address public mysteryBox;

    mapping(address => mapping(uint => mapping(address => OfferInfo))) public offerInfos;
    mapping(address => mapping(uint => SaleInfo)) public saleInfos;

    function _initialize (
        IGENI _geni,
        IGENIPass _geniPass,
        address _treasury,
        IGEMUNIItem _gemuniItem,
        uint _feeRate,
        IGENIPassSale _geniPassSale    
    ) external initializer
    {
        __operatable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        geni = _geni; 
        geniPass = _geniPass; 
        treasury = _treasury;
        gemuniItem = _gemuniItem;
        feeRate = _feeRate;
        geniPassSale = _geniPassSale;
    }
    
    /**
     * @dev Owner set new geniItem contract
     * @param _gemuniItem new address
     */
    function setGemUniItem(IGEMUNIItem _gemuniItem) external onlyOwner {
        require(address(_gemuniItem) != address(0), "GEMUNIMarketplace: new address must be different address(0)");
        gemuniItem = _gemuniItem;
        emit SetGemUniItem(address(_gemuniItem));
    }   

    function setGeniAddress(IGENI _geni) external onlyOwner {
        require(address(_geni) != address(0), "GEMUNIMarketplace: new address must be different address(0)");
        geni = _geni;
        emit SetGeniAddress(address(_geni));
    } 

    function setGeniPassSaleAddress(IGENIPassSale _geniPassSale) external onlyOwner {
        require(address(_geniPassSale) != address(0), "GEMUNIMarketplace: new address must be different address(0)");
        geniPassSale = _geniPassSale;
        emit SetGeniPassSaleAddress(address(_geniPassSale));
    } 

    function setFeeRate(uint value) external onlyOwner {
        require(value < 1000000, "GEMUNIMarketplace: percentage not greater than 100.0000 %");
        feeRate = value;
        emit SetFeeRate(value);
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0));
        treasury = newTreasury;
        emit SetTreasury(newTreasury);
    }

    function setMysteryBoxAddress(address _mysteryBox) external {
        require(_mysteryBox != address(0), "GENIPassSale: invalid address");
        mysteryBox = _mysteryBox;
        emit SetMysteryBoxAddress(_mysteryBox);
    }
        
    function putOnSale(address token, uint tokenId, uint price, uint startTime, uint expirationTime) external override whenNotPaused {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        require(startTime >= block.timestamp, "GEMUNIMarketplace: invalid start time");
        require(expirationTime > startTime, "GEMUNIMarketplace: invalid end time");
        SaleInfo storage saleInfo = saleInfos[token][tokenId];
        saleInfo.seller = msg.sender;
        saleInfo.startTime = startTime;
        saleInfo.expirationTime = expirationTime;
        if(token == address(geniPass)) {
            geniPass.transferFrom(msg.sender, address(this), tokenId);
            saleInfo.price = geniPassSale.getPricePass(tokenId, price, IGENIPass.PriceType.GENI);

            emit PassPutOnSale(tokenId, saleInfo.price, saleInfo.seller, startTime, expirationTime);
        } else {
            require(price > 0, "GEMUNIMarketplace: invalid price");
            IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        
            saleInfo.price = price;
            emit ItemsPutOnSale(token, tokenId, saleInfo.price, saleInfo.seller, startTime, expirationTime);
        } 

    }
    
    function updatePriceSale(address token, uint tokenId, uint price) external override whenNotPaused {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        SaleInfo storage saleInfo = saleInfos[token][tokenId];
        require(msg.sender == saleInfo.seller, "GEMUNIMarketplace: token not put on sale or user is not seller");
        require(block.timestamp <= saleInfo.expirationTime, "GEMUNIMarketplace: expired");
        require(price > 0, "GEMUNIMarketplace: invalid price");
        saleInfo.price = price;

        if(token == address(geniPass)){
            emit PassUpdateOnSale(tokenId, saleInfo.price, msg.sender);
        } else {
            emit ItemsUpdateOnSale(token, tokenId, saleInfo.price, msg.sender);
        }
    }
    
    function removeFromSale(address token, uint tokenId) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        SaleInfo memory saleInfo = saleInfos[token][tokenId];
        require(msg.sender == saleInfo.seller, "GEMUNIMarketplace: token not put on sale or user is not seller");
        if(token == address(geniPass)){
            geniPass.transferFrom(address(this), saleInfo.seller, tokenId);
            emit PassRemoveOnSale(tokenId, msg.sender);
        } else {
            IERC721(token).transferFrom(address(this), saleInfo.seller, tokenId);
            emit ItemsRemoveOnSale(token, tokenId, msg.sender);
        }
        delete saleInfos[token][tokenId];
    }

    function purchase(address token, uint tokenId, uint buyPrice) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        SaleInfo memory saleInfo = saleInfos[token][tokenId];
        address buyer = msg.sender;
        
        require(saleInfo.seller != address(0), "GEMUNIMarketplace: not for sale");
        require(block.timestamp >= saleInfo.startTime, "GEMUNIMarketplace: Sale has not started");
        require(block.timestamp <= saleInfo.expirationTime, "GEMUNIMarketplace: expired to purchase");
        require(saleInfo.seller != buyer, "GEMUNIMarketplace: owner can not buy");

        uint salePrice = saleInfo.price;
        require(buyPrice == salePrice, "GEMUNIMarketplace: invalid trade price");

        uint geniPrice = buyPrice * (1000000 - feeRate) / decimalRate / 100;
        geni.safeTransferFrom(buyer, saleInfo.seller, geniPrice);
        geni.safeTransferFrom(buyer, treasury, buyPrice - geniPrice);

        if (token == address(geniPass)) {
            geniPass.transferFrom(address(this), buyer, tokenId);
            emit PassBought(tokenId, buyer, saleInfo.seller, buyPrice);
        } else {
            IERC721(token).transferFrom(address(this), buyer, tokenId);
            emit ItemsBought(token, tokenId, buyer, saleInfo.seller, buyPrice);
        }
        
        delete saleInfos[token][tokenId];
    }
    
    function makeOffer(address token, uint tokenId, uint offerPrice, uint expirationTime) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        require(expirationTime > block.timestamp, "GEMUNIMarketplace: invalid end time");
        SaleInfo storage saleInfo = saleInfos[token][tokenId];
        address buyer = msg.sender;
        OfferInfo storage offerInfo = offerInfos[token][tokenId][buyer];
        if(saleInfo.seller == address(0)) {
            if(token == address(geniPass)) {
                require(buyer != geniPass.ownerOf(tokenId), "GEMUNIMarketplace: owner cannot offer");
            } else {
                require(buyer != gemuniItem.ownerOf(tokenId), "GEMUNIMarketplace: owner cannot offer");
            }
        } else {
            require(saleInfo.seller != buyer, "GEMUNIMarketplace: seller can not buy");
        }
        require(offerPrice > 0, "GEMUNIMarketplace: invalid price");
        require(offerInfo.priceOffer == 0, "GEMUNIMarketplace: already offered");
        
        geni.safeTransferFrom(buyer, address(this), offerPrice);
        offerInfo.priceOffer = offerPrice;
        offerInfo.expirationTime = expirationTime;
        if (token == address(geniPass)) {
            if(saleInfo.seller == address(0)) {
                emit PassOffered(tokenId, buyer, geniPass.ownerOf(tokenId), offerPrice, expirationTime);
            } else {
                emit PassOffered(tokenId, buyer, saleInfo.seller, offerPrice, expirationTime);
            }
        } else {
            if(saleInfo.seller == address(0)) {
                emit ItemsOffered(token, tokenId, buyer, gemuniItem.ownerOf(tokenId), offerPrice, expirationTime);
            } else {
                emit ItemsOffered(token, tokenId, buyer, saleInfo.seller, offerPrice, expirationTime);
            }
        }
    }
    
    function updateOffer(address token, uint tokenId, uint updateOfferPrice) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        address buyer = msg.sender;
        OfferInfo storage offerInfo = offerInfos[token][tokenId][buyer];
        require(offerInfo.priceOffer > 0, "GEMUNIMarketplace: not existed offer");
        require(block.timestamp <= offerInfo.expirationTime, "GEMUNIMarketplace: expired");
        require(updateOfferPrice > 0, "GEMUNIMarketplace: invalid price");
        uint currentOffer = offerInfo.priceOffer;
        uint requiredValue = updateOfferPrice < currentOffer ? 0 : updateOfferPrice - currentOffer;
        
        if (requiredValue > 0) {
            IERC20(geni).transferFrom(buyer, address(this), requiredValue);
        }
        
        if (updateOfferPrice < currentOffer) {
            uint returnedValue = currentOffer - updateOfferPrice;
            IERC20(geni).transfer(buyer, returnedValue);
        }
        
        offerInfo.priceOffer = updateOfferPrice;
        if (token == address(geniPass)) {
            emit PassOfferUpdated(tokenId, buyer, updateOfferPrice);
        } else {
            emit ItemsOfferUpdated(token, tokenId, buyer, updateOfferPrice);
        }
    }
    
    function cancelOffer(address token, uint tokenId) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        address buyer = msg.sender;
        OfferInfo memory offerInfo = offerInfos[token][tokenId][buyer];
        require(offerInfo.priceOffer > 0, "GEMUNIMarketplace: not existed offer");
        
        IERC20(geni).transfer(buyer, offerInfo.priceOffer);

        delete offerInfos[token][tokenId][buyer];
        if (token == address(geniPass)) {
            emit PassOfferCancelled(tokenId, buyer);
        } else {
            emit ItemsOfferCancelled(token, tokenId, buyer);
        }
    }
    
    function takeOffer(address token, uint tokenId, address buyer, uint takeOfferPrice) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GEMUNIMarketplace: invalid token");
        SaleInfo storage saleInfo = saleInfos[token][tokenId];
        OfferInfo memory offerInfo = offerInfos[token][tokenId][buyer];
        require(offerInfo.priceOffer > 0, "GEMUNIMarketplace: not existed offer");

        if (saleInfo.seller == address(0)) {
            require(msg.sender != buyer , "GEMUNIMarketplace: buyer can not take offer");
            if (token == address(geniPass)) {
                require(msg.sender == geniPass.ownerOf(tokenId), "GEMUNIMarketplace: not pass owner");
            } else {
                require(msg.sender == gemuniItem.ownerOf(tokenId), "GEMUNIMarketplace: not item owner");
            } 
        } else {
            require(saleInfo.seller != buyer, "GEMUNIMarketplace: seller can not buy");
            require(saleInfo.seller == msg.sender, "GEMUNIMarketplace: not seller");
        }
        require(block.timestamp <= offerInfo.expirationTime, "GEMUNIMarketplace: expired to purchase");
        
        uint priceOffer = offerInfo.priceOffer;
        require(takeOfferPrice == priceOffer, "GEMUNIMarketplace: invalid price");

        uint price = priceOffer * (1000000 - feeRate) / decimalRate / 100;
        geni.safeTransfer(treasury, priceOffer - price);

        if (token == address(geniPass)) {
            if (saleInfo.seller == address(0)) {
                geni.safeTransfer(msg.sender, price);
                geniPass.transferFrom(msg.sender, buyer, tokenId);
                emit PassBought(tokenId, buyer, msg.sender, priceOffer);
            } else {
                geni.safeTransfer(saleInfo.seller, price);
                geniPass.transferFrom(address(this), buyer, tokenId);
                emit PassBought(tokenId, buyer, saleInfo.seller, priceOffer);
            }
        } else {
            if (saleInfo.seller == address(0)) {
                geni.safeTransfer(msg.sender, price);
                IERC721(token).transferFrom(msg.sender, buyer, tokenId);
                emit ItemsBought(token, tokenId, buyer, msg.sender, priceOffer);
            } else {
                geni.safeTransfer(saleInfo.seller, price);
                IERC721(token).transferFrom(address(this), buyer, tokenId);
                emit ItemsBought(token, tokenId, buyer, saleInfo.seller, priceOffer);
            }
        }
        
        delete saleInfos[token][tokenId];
        delete offerInfos[token][tokenId][buyer];
    }
    
    function pause() external onlyOperator {
        _pause();
    }

    function unpause() external onlyOperator {
        _unpause();
    }

    function withdrawNftEmergency(address token, uint tokenId, address recipient) external whenPaused onlyOperator {
        require(token == address(geniPass) || token == address(gemuniItem) || token == mysteryBox, "GENIMarketplace: invalid token");
        SaleInfo memory saleInfo = saleInfos[token][tokenId];
        require(saleInfo.seller != address(0), "GENIMarketplace: not for sale");
        IERC721(token).transferFrom(address(this), recipient, tokenId);
        delete saleInfos[token][tokenId];
        emit withdrawNft(token, saleInfo.seller, recipient, tokenId);
    }

    function withdrawTokenEmergency(address token, uint amount, address recipient) external whenPaused onlyOperator {
        require(amount > 0, "GENIMarketplace: invalid price");
        require(IERC20(token).balanceOf(address(this)) >= amount, "GENIMarketplace: not enough balance");

        IERC20(token).transferFrom(address(this), recipient, amount);

        emit withdrawToken(token, recipient, amount);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract PermissionGroupUpgradeable is OwnableUpgradeable {

    mapping(address => bool) public operators;
    event AddOperator(address newOperator);
    event RemoveOperator(address operator);

    function __operatable_init() internal initializer {
        __Ownable_init();
        operators[owner()] = true;
    }

    modifier onlyOperator {
        require(operators[msg.sender], "Operatable: caller is not the operator");
        _;
    }

    function addOperator(address operator) external onlyOwner {
        operators[operator] = true;
        emit AddOperator(operator);
    }

    function removeOperator(address operator) external onlyOwner {
        operators[operator] = false;
        emit RemoveOperator(operator);
    }
}

pragma solidity ^0.8.0;
import "./IGENIPass.sol";

interface IGENIPassSale {
    struct SaleInfo {
        uint price;
        IGENIPass.PriceType priceType;
        uint startTime;
        uint expirationTime;
    }
    
    struct CreateSalePasses{
        string serialNumber;
        uint price;
        IGENIPass.PassType passType;
        IGENIPass.PriceType priceType;
        uint startTime;
        uint expirationTime;
    }

    struct CreateSalePassesWithoutMint{
        uint passId;
        uint price;
        IGENIPass.PriceType priceType;
        uint startTime;
        uint expirationTime;
    }

    struct ReferalBonus {
        uint referralBonusLv0;
        uint referralBonusLv1;
        uint referralBonusLv2;
        uint referralBonusLv3;
        uint referralBonusLv4;
    }

    struct ReferalLevelParams {
        uint startLv0;
        uint startLv1;
        uint startLv2;
        uint startLv3;
        uint startLv4;
    }
    event SetServer(address newServer);
    event SetTreasury(address newTreasury);
    event SetGeni(address newGeni);
    event SetDiscountRate(uint value);
    event SetExchange(address _exchange);
    event SetReferralLevel(uint startLv0, uint startLv1, uint startLv2, uint startLv3, uint startLv4);
    event SetReferralBonusLevel0(uint _rate);
    event SetReferralBonusLevel1(uint _rate);
    event SetReferralBonusLevel2(uint _rate);
    event SetReferralBonusLevel3(uint _rate);
    event SetReferralBonusLevel4(uint _rate);

    event PassPutOnSale(uint indexed passId, uint price, uint priceType, address seller, uint startTime, uint expirationTime);
    event PassUpdateSale(uint indexed passId, uint newPrice, address seller);
    event PassRemoveFromSale(uint indexed passId, address seller);
    event PassBought(uint indexed passId, address buyer, address seller, uint256 price, uint discountedPrice);
    event PassBoughtWithReferral(uint indexed passId, address buyer, address seller, address referal, uint nonce, uint256 price, uint discountedPrice, uint referalBonus);
    event WithdrawGeniPass(address seller, address to, uint indexed tokenId);
    event WithdrawToken(address token, address to, uint amount);
    event WithdrawETH(address recipient, uint amount);
    
    function putOnSale(uint passId, uint price, IGENIPass.PriceType priceType, uint startTime, uint expirationTime) external;
    function mintForSale(string memory serialNumber, uint price, IGENIPass.PassType passType, IGENIPass.PriceType priceType, uint startTime, uint expirationTime) external;
    function updateSale(uint passId, uint price) external;
    function removeFromSale(uint passId) external;
    function getPricePass(uint passId, uint price, IGENIPass.PriceType priceType) external view returns(uint);
    function putOnSaleBatch(CreateSalePassesWithoutMint[] memory input) external;
    function mintForSaleBatch(CreateSalePasses[] memory input) external;
    function purchase(uint passId, uint buyPrice) external payable;
    function purchaseWithReferral(uint passId, uint buyPrice, address referalAddress, uint nonce, bytes memory signature) external payable;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IGENIPass is IERC721Upgradeable {
    enum PassType { Stone, Topaz, Citrine, Ruby, Diamond }
    enum PriceType { BNB, GENI }

    struct GeniPass {
        string serialNumber;
        PassType passType;
        bool isActive;
    }
    
    event SetActive(uint indexed passId, bool isActive);
    event PassCreated(address indexed owner, uint indexed passId, uint passType, string serialNumber);
    event LockPass(uint indexed passId);
    event UnLockPass(uint indexed passId);
    
    function burn(uint tokenId) external;
    
    function mint(address to, string memory serialNumber, PassType passType) external returns(uint tokenId);
    
    function getPass(uint passId) external view returns (GeniPass memory pass);

    function exists(uint passId) external view returns (bool);

    function setActive(uint tokenId, bool _isActive) external;

    function lockPass(uint passId) external;

    function unLockPass(uint passId) external;

    function permit(address owner, address spender, uint tokenId, bytes memory _signature) external;
    
    function isLocked(uint tokenId) external returns(bool);
}

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGENI is IERC20 {
    function mint(address to, uint256 amount) external;
    
    function burn(uint amount) external;

    event SetLpToken(address lpToken);
    event SetBusd(address _busd);
    event SetExchange(address lpToken);
    event SetAntiWhaleAmountBuy(uint256 amount);
    event SetAntiWhaleAmountSell(uint256 amount);
    event SetAntiWhaleTimeSell(uint256 timeSell);
    event SetAntiWhaleTimeBuy(uint256 timeBuy);
    event AddListWhales(address[] _whales);
    event RemoveFromWhales(address[] _whales);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IGENIPass.sol";

interface IGEMUNIMarketplace {
    struct OfferInfo {
        uint priceOffer;
        uint expirationTime;
    }
    struct SaleInfo {
        address seller;
        uint price;
        uint startTime;
        uint expirationTime;
    }
    event SetGemUniItem(address newGemuniItem);
    event SetGeniAddress(address newGeni);
    event SetGeniPassSaleAddress(address newGeniPassSale);
    event SetFeeRate(uint value);
    event SetTreasury(address newTreasury);
    event SetMysteryBoxAddress(address _mysteryBox);

    event PassPutOnSale(uint indexed passId, uint price, address indexed seller, uint startTime, uint expirationTime);
    event PassUpdateOnSale(uint indexed passId, uint newPrice, address seller);
    event PassRemoveOnSale(uint indexed passId, address seller);
    event PassBought(uint indexed passId, address buyer, address seller, uint256 price);
    event PassBoughtWithReferal(uint indexed passId, address buyer, address seller, address referal, uint256 price);
    event PassOffered(uint indexed passId, address buyer, address seller, uint price, uint expirationTime);
    event PassOfferCancelled(uint indexed passId, address buyer);
    event PassOfferUpdated(uint indexed passId, address buyer, uint newOfferPrice);

    event ItemsPutOnSale(address token, uint indexed itemId, uint price, address indexed seller, uint startTime, uint expirationTime);
    event ItemsUpdateOnSale(address token, uint indexed itemId, uint newPrice, address seller);
    event ItemsRemoveOnSale(address token, uint indexed itemId, address seller);
    event ItemsBought(address token, uint indexed itemId, address buyer, address seller,  uint256 price);
    event ItemsOffered(address token, uint indexed itemId, address buyer, address seller, uint price, uint expirationTime);
    event ItemsOfferCancelled(address token, uint indexed itemId, address buyer);
    event ItemsOfferUpdated(address token, uint indexed itemId, address buyer, uint newPriceOffer);

    event withdrawNft(address token, address seller, address to, uint indexed tokenId);
    event withdrawToken(address token, address to, uint amount);
    
    function putOnSale(address token, uint tokenId, uint price, uint startTime, uint expirationTime) external;
    function updatePriceSale(address token, uint tokenId, uint price) external;
    function removeFromSale(address token, uint tokenId) external;
    function makeOffer(address token, uint itemId, uint offerPrice, uint expirationTime) external;
    function cancelOffer(address token, uint tokenId) external;
    function takeOffer(address token, uint tokenId, address buyer, uint takeOfferPrice) external;
    function updateOffer(address token, uint tokenId, uint updateOfferPrice) external;
    function purchase(address token, uint tokenId, uint buyPrice) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGEMUNIItem is IERC721 {

    /**
     * @notice mint Item
     */
    function burnItem(uint tokenId) external;
    
    /**
     * @notice mint Item
     */
    function mintItem(address _to, uint nouce, bytes memory _signature) external returns(uint tokenId);
    
    function exists() external view returns (uint);

    event ItemCreated(uint indexed tokenId, address indexed owner);
    event LockItem(uint indexed tokenId);
    event UnLockItem(uint indexed tokenId);

    function lockItem(uint tokenId) external;

    function unLockItem(uint tokenId) external;

    function permit(address owner, address spender, uint tokenId, bytes memory _signature) external;
    
    function isLocked(uint tokenId) external returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}