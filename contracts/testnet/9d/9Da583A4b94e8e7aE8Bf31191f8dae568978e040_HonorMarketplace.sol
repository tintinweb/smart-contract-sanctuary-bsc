// SPDX-License-Identifier: MIT
// HONOR Protocols - NFT MarketPlace
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Metadata.sol";

contract HonorMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemsIds;
    Counters.Counter private _itemsSold;
    Counters.Counter private _itemsCanceled;

    event Received(address, uint);
        receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    address payable owner;
    uint256 listingPrice = 0 ether;
    uint256 public buyGasFee = 0.0005 ether;
    uint256 public delistGasFee = 0 ether;
    Busd public busdAddress;
    Metadata public metadataAddress;

    constructor(Busd _busdAddress, Metadata _metadataAddress) {
        owner = payable(msg.sender);
        busdAddress = _busdAddress;
        metadataAddress = _metadataAddress;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        uint256 rank;
        address payable creator;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        bool delisting;
        bool discount;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => MarketItem) private storageTokenId;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address creator,
        address seller,
        address owner,
        uint256 price
    );

    event ProductUpdated(
      uint256 indexed itemId,
      uint256 indexed oldPrice,
      uint256 indexed newPrice
    );

    event MarketItemDeleted(uint256 itemId);

    event ProductSold(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address creator,
        address seller,
        address owner,
        uint256 price,
        bool delisting
    );

     event ProductListed(
        uint256 indexed itemId
    );

    modifier onlyProductOrMarketPlaceOwner(uint256 id) {
        if (idToMarketItem[id].owner != address(0)) {
            require(idToMarketItem[id].owner == msg.sender);
        } else {
            require(
                idToMarketItem[id].seller == msg.sender || msg.sender == owner
            );
        }
        _;
    }

    modifier onlyProductSeller(uint256 id) {
        require(
            idToMarketItem[id].owner == address(0) &&
                idToMarketItem[id].seller == msg.sender, "Only the product can do this operation"
        );
        _;
    }

    modifier onlyItemOwner(uint256 id) {
        require(
            idToMarketItem[id].owner == msg.sender,
            "Only product owner can do this operation"
        );
        _;
    }

    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }
    function checkTokenId(uint256 _tokenId) public view returns (uint256) {
        return storageTokenId[_tokenId].tokenId;
    }
    function setMetadata(address _metadataAddress) external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        metadataAddress = Metadata(_metadataAddress);
    }
    function bnbBalance() public view returns (uint) {
        return address(this).balance;
    }
    function busdBalance() public view returns (uint) {
     return busdAddress.balanceOf(address(this));
    } 

    function setGasFee(uint _buyGasFee, uint _delistGasFee) external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        buyGasFee = _buyGasFee;
        delistGasFee = _delistGasFee;
    }
    function addLiquidity(address payable _to) external payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to add NFT Liquidity");
    }
    // Withdrawal BNB
    function withdraw() external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        (bool os, ) = payable(owner).call{value: address(this).balance}("");
        require(os);
    }
    // Withdrawal Busd
    function withdrawBusd() external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        busdAddress.transfer(owner, busdBalance());
    }

    // Create NFT Sale
    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Listing fee required"); // Obligates the seller to pay the listing price
        uint256 checkId = checkTokenId(tokenId);
        require(tokenId != checkId, "Please Use Resell");           // Added this function to ignore ovewrite NFT minter & itemid

        uint rank = metadataAddress.checkArmyRank(tokenId);         // Call rank from Metadata
        require(rank > 0, "No Rank, Contract Dev");
        bool Discount = metadataAddress.checkDiscount(tokenId);     // Call discount from Metadata
        MarketItem storage user = storageTokenId[tokenId];
        user.tokenId = tokenId;
        user.discount = Discount;

        _itemsIds.increment();
        uint256 itemId = _itemsIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            rank,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            price,
            false,
            false,
            Discount
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            msg.sender,
            address(0),
            price
        );
    }

    function updatePrice(uint256 id, uint256 newPrice) public onlyProductSeller(id) {
        MarketItem storage item = idToMarketItem[id];
        uint256 oldPrice = item.price;
        item.price = newPrice;

        emit ProductUpdated(id, oldPrice, newPrice);
    }

    function buySaleNFT(address _account, address nftContract, uint256 itemId, uint _price)public payable nonReentrant {
        uint256 price = idToMarketItem[itemId].price;
        require(_price == price, "Please submit the asking price in order to complete the purchase");
        
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;

        busdAddress.transferFrom(_account, seller, price);    // Send busd as payment
        // idToMarketItem[itemId].seller.transfer(msg.value);  // Send eth/bnb as payment
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();

        payable(seller).transfer(listingPrice);
        payable(seller).transfer(buyGasFee);

        emit ProductSold(
            idToMarketItem[itemId].itemId,
            idToMarketItem[itemId].nftContract,
            idToMarketItem[itemId].tokenId,
            idToMarketItem[itemId].creator,
            idToMarketItem[itemId].seller,
            payable(msg.sender),
            idToMarketItem[itemId].price,
            idToMarketItem[itemId].delisting
        );
    }

    // Delist NFT sale
    function delistSale(address nftContract, uint256 itemId) public nonReentrant
    {
        idToMarketItem[itemId].price = 0;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;
        require(msg.sender == idToMarketItem[itemId].seller, "You Not Owner");

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].delisting = true;
        _itemsSold.increment();
        _itemsCanceled.increment();

        payable(seller).transfer(listingPrice);
        payable(seller).transfer(delistGasFee);

        emit ProductSold(
            idToMarketItem[itemId].itemId,
            idToMarketItem[itemId].nftContract,
            idToMarketItem[itemId].tokenId,
            idToMarketItem[itemId].creator,
            msg.sender,
            payable(msg.sender),
            idToMarketItem[itemId].price,
            idToMarketItem[itemId].delisting
        );
    }

    // Resell, itemid available at struct
    function Resell(address nftContract, uint256 itemId, uint256 newPrice) public payable nonReentrant onlyItemOwner(itemId) {
        require(newPrice > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice,"Price must be equal to listing price");

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        uint rank = metadataAddress.checkArmyRank(tokenId);         //call rank from maintenance.sol
        bool Discount = metadataAddress.checkDiscount(tokenId);     //call discount from maintenance.sol
    
        address payable oldOwner = idToMarketItem[itemId].owner;
        idToMarketItem[itemId].owner = payable(address(0));
        idToMarketItem[itemId].seller = oldOwner;
        idToMarketItem[itemId].price = newPrice;
        idToMarketItem[itemId].sold = false;
        idToMarketItem[itemId].rank = rank;
        idToMarketItem[itemId].discount = Discount;
        _itemsSold.decrement();

        emit ProductListed(itemId);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemsIds.current();
        uint256 unsoldItemCount = _itemsIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (
                idToMarketItem[i + 1].owner == address(0) &&
                idToMarketItem[i + 1].sold == false &&
                idToMarketItem[i + 1].tokenId != 0
            ) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchSingleItem(uint256 id) public view returns (MarketItem memory) {
        return idToMarketItem[id];
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemsIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchAuthorsCreations(address author) public view returns (MarketItem[] memory){
        uint256 totalItemCount = _itemsIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].creator == author && !idToMarketItem[i + 1].sold) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].creator == author && !idToMarketItem[i + 1].sold) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// HONOR Protocols - NFT Metadata
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.7;

import "./ArmyNFT.sol";
import "./EmblemNFT.sol";
import "./WarNFT.sol";

contract Metadata{

    address private owner;
    Busd public busdAddress;
    Honor public honorAddress;
    ArmyNFT public armyRankNFT;
    EmblemNFT public emblemRankNFT;
    WarNFT public warHeroNFT;
    address public honorDao;
    address public miningDao;
    address public earnDao;
    uint256 public BusdCost =  10 * 10 ** 18; // Price in Busd
    uint256 public HonorCost =  1 * 10 ** 18; // Price in Token
  
    mapping(uint => ArmyMetadata) ArmyMetadatas;
    mapping(uint => EmblemMetadata) EmblemMetadatas;
    mapping(uint => HeroMetadata) HeroMetadatas;
    mapping(uint256 => bool) tokenIdForDiscount; // Army Rank
    mapping(uint256 => bool) tokenIdForReset;    // Emblem Rank
    mapping(uint256 => bool) tokenIdForSupport;  // War Hero
    bool specialDay = false;

    struct ArmyMetadata {
     uint tokenid;
     uint rank;
     uint level;
     uint armyCounter;
     uint reward;
     uint mining;
     uint staking;
     uint multiplier;
     bool discount;
    }
    struct EmblemMetadata {
     uint tokenid;
     uint emblem;
     uint level;
     uint emblemCounter;
     uint reward;
     uint mining;
     uint staking;
     uint multiplier;
     bool reset;
    }
    struct HeroMetadata {
     uint tokenid;
     uint hero;
     uint level;
     uint heroCounter;
     uint reward;
     uint mining;
     uint staking;
     uint multiplier;
     bool support;
    }

    constructor(Honor _honorAddress, Busd _busdAddress, ArmyNFT _armynftAddress){
        owner = msg.sender;
        honorAddress = _honorAddress;
        busdAddress = _busdAddress;
        armyRankNFT = _armynftAddress;
    }

    // ADMIN - SET DAO SMART CONTRACT ADDRESS
    function setDaoContract(address _honorDao) external{
        require(msg.sender == owner, 'You must be the owner to run this.');
        honorDao = _honorDao;
    }
    function setMiningContract(address _miningDao) external{
        require(msg.sender == owner, 'You must be the owner to run this.');
        miningDao = _miningDao;
    }
    function setEarnContract(address _earnDao) external{
        require(msg.sender == owner, 'You must be the owner to run this.');
        earnDao = _earnDao;
    }
    // ADMIN - SET NEW NFT ADDRESS
    function setHonorNFT(address _armynftAddress, address _emblemnftAddress, address _warnftAddress) external{
        require(msg.sender == owner, 'You must be the owner to run this.');
        armyRankNFT = ArmyNFT(_armynftAddress);
        emblemRankNFT = EmblemNFT(_emblemnftAddress);
        warHeroNFT = WarNFT(_warnftAddress);
    }
    // ADMIN - SET MAINTENANCE COST
    function setCost(uint _busdCost, uint _honorCost) external{
        require(msg.sender == owner, 'You must be the owner to run this.');
        BusdCost = _busdCost;
        HonorCost = _honorCost;
    }

    // RETURNS - Check NFT Metadata Army, Emblem, Hero
    function checkMetadata(uint _collection, uint _tokenId) public view returns (uint Collection, uint TokenID, uint Rank, uint Level, uint Reward, uint Mining, uint Staking, uint Multiplier, bool Discount) {
        require(_collection >= 1 && _collection <= 3, 'Invalid Collection type');
        require(_tokenId >=1 && _tokenId <= 10000, "Invalid Token ID");
        Collection = _collection;

        if (Collection == 1){
            require(_tokenId <= armyRankNFT.totalSupply(), "NFT Not Yet Mint");
            ArmyMetadata memory Id = ArmyMetadatas[_tokenId];
            return (Collection, Id.tokenid, Id.rank, Id.level, Id.reward, Id.mining, Id.staking, Id.multiplier, Id.discount);
        }
        else if (Collection == 2){
            require(_tokenId <= emblemRankNFT.totalSupply(), "NFT Not Yet Mint");
            EmblemMetadata memory Id = EmblemMetadatas[_tokenId];            
            return (Collection, Id.tokenid, Id.emblem, Id.level, Id.reward, Id.mining, Id.staking, Id.multiplier, Id.reset);
        }
        else if (Collection == 3){
            require(_tokenId <= warHeroNFT.totalSupply(), "NFT Not Yet Mint");
            HeroMetadata memory Id = HeroMetadatas[_tokenId];                
            return (Collection, Id.tokenid, Id.hero, Id.level, Id.reward, Id.mining, Id.staking, Id.multiplier, Id.support);
        }
    }
    // RETURNS - Check Special Day
    function checkSpecialDay() public view returns(bool) {
        return specialDay;
    }
    // RETURNS - Check Army Rank
    function checkArmyRank(uint _tokenId) public view returns (uint) {
        require(_tokenId <= armyRankNFT.totalSupply(), "NFT Not Yet Mint");
        return (ArmyMetadatas[_tokenId].rank);
    }
    // RETURNS - Check Emblem Rank
    function checkEmblemRank(uint _tokenId) public view returns (uint) {  
        require(_tokenId <= emblemRankNFT.totalSupply(), "NFT Not Yet Mint"); 
        return EmblemMetadatas[_tokenId].emblem;
    }
    // RETURNS - Check War Hero Rank
    function checkHeroRank(uint _tokenId) public view returns (uint) {   
        require(_tokenId <= warHeroNFT.totalSupply(), "NFT Not Yet Mint"); 
        return HeroMetadatas[_tokenId].hero;
    }
    // RETURNS - Army Counter
    function checkArmyCounter(uint256 _tokenId) public view returns (uint256) {
        return ArmyMetadatas[_tokenId].armyCounter;
    }
    // RETURNS - Emblem Counter
    function checkEmblemCounter(uint256 _tokenId) public view returns (uint256) {
        return EmblemMetadatas[_tokenId].emblemCounter;
    }
    // RETURNS - Hero Counter
    function checkHeroCounter(uint256 _tokenId) public view returns (uint256) {
        return HeroMetadatas[_tokenId].heroCounter;
    }
    // RETURNS - Check Discount Token Id (Army Rank NFT)
    function checkDiscount(uint256 _tokenId) public view returns(bool) {
    return tokenIdForDiscount[_tokenId];
    }

    // HOLDERS - Reset Counter Army Rank NFT
    function maintenanceNFT(address _address, uint _collection, uint _busdAmount, uint _honorAmount, uint256 _tokenId) external {
        require(_collection >= 1 && _collection <= 3, 'Invalid Collection type');
        require(_busdAmount >= BusdCost, 'You must provide enough BUSD for the Maintenance NFT');
        require(_honorAmount >= HonorCost, 'You must provide enough HONOR for the Maintenance NFT');
        require(_tokenId >=1 && _tokenId <= 10000, "Invalid Token ID 1-10,000");
        uint Collection = _collection;

        if (Collection == 1){
            require(msg.sender == armyRankNFT.ownerOf(_tokenId),"Invalid Token ID");
            ArmyMetadata storage Id = ArmyMetadatas[_tokenId];                
            Id.armyCounter = 0;
        }
        else if (Collection == 2){
            require(msg.sender == emblemRankNFT.ownerOf(_tokenId),"Invalid Token ID");
            EmblemMetadata storage Id = EmblemMetadatas[_tokenId];                
            Id.emblemCounter = 0;
        }
        else if (Collection == 3){
            require(msg.sender == warHeroNFT.ownerOf(_tokenId),"Invalid Token ID");
            HeroMetadata storage Id = HeroMetadatas[_tokenId];                
            Id.heroCounter = 0;
        }
        busdAddress.transferFrom(_address, address(this), _busdAmount);
        honorAddress.transferFrom(_address, address(this), _honorAmount);
    }
    // HOLDERS - Discard Discount After Purchasing Node (FUNCTION USED BY OTHER SMART CONTRACT)
    function removeDiscount (uint256 _tokenId, bool Discount) external {
        require(msg.sender == honorDao || msg.sender == owner, 'Protected by HonorDao - Metadata');
        tokenIdForDiscount[_tokenId] = Discount;
        ArmyMetadata storage Id = ArmyMetadatas[_tokenId];
        Id.discount = Discount;
    }
    //HOLDERS - Emblem NFT, RESET Army Rank NFT (Discount Can Use Again)
    function DiscountON (address _address, uint256 _tokenId, uint256 _tokenId2) external {
        require(_address != address(0), "_address is address 0");
        require(_address == armyRankNFT.ownerOf(_tokenId),"You are not the owner of this TokenId");
        require(_address == emblemRankNFT.ownerOf(_tokenId2),"You are not the owner of this TokenId");
        require(!tokenIdForReset[_tokenId]," Emblem Already Used");
        ArmyMetadata storage Id = ArmyMetadatas[_tokenId];
        EmblemMetadata storage Id2 = EmblemMetadatas[_tokenId2];
        bool Discount = false;
        bool Reset = true;
        tokenIdForDiscount[_tokenId] = Discount;
        tokenIdForReset[_tokenId2] = Reset;
        Id.discount = Discount;
        Id2.reset = Reset;
    }
    // HOLDERS -  War Hero NFT, RESET Emblem NFT (Reset Can Use Again)
    function ResetON (address _address, uint256 _tokenId2, uint256 _tokenId3) external {
        require(_address == emblemRankNFT.ownerOf(_tokenId2),"You are not the owner of this TokenId");
        require(_address == warHeroNFT.ownerOf(_tokenId3),"You are not the owner of this TokenId");
        require(!tokenIdForSupport[_tokenId3],"War Hero Already Used");
        EmblemMetadata storage Id2 = EmblemMetadatas[_tokenId2];
        HeroMetadata storage Id3 = HeroMetadatas[_tokenId3];
        bool Reset = false;
        bool War = true;
        tokenIdForReset[_tokenId2] = Reset;
        tokenIdForSupport[_tokenId3] = War;
        Id2.reset = Reset;
        Id3.support = War;
    }

    //-----------------------------------------------------------------------------------------------------------------------------------
    // OWNER/DAO - TOKEN RANK METADATA INPUT
    function metadataInput (uint _collection, uint _tokenId, uint _rank, uint _level, uint _reward, uint _mining, uint _staking, uint _multiplier) external {
        require(msg.sender == honorDao || msg.sender == miningDao || msg.sender == earnDao || msg.sender == owner, 'Can only be used by HonorDao or owner. - MetadataInput');
        require(_collection >= 1 && _collection <= 3, 'Invalid Collection type');
        require(_rank >= 1 && _rank <= 8, 'Invalid Rank type');

        ArmyMetadata storage Id = ArmyMetadatas[_tokenId];
        EmblemMetadata storage Id2 = EmblemMetadatas[_tokenId];
        HeroMetadata storage Id3 = HeroMetadatas[_tokenId];
        uint Collection = _collection;

        if (Collection == 1){
            Id.tokenid = _tokenId;
            Id.rank = _rank;
            Id.level = _level;
            Id.reward = _reward;
            Id.mining = _mining;
            Id.staking = _staking;
            Id.multiplier = _multiplier;
        }
        else if (Collection == 2){
            Id.tokenid = _tokenId;
            Id2.emblem = _rank;
            Id2.level = _level;
            Id2.reward = _reward;
            Id2.mining = _mining;
            Id2.staking = _staking;
            Id2.multiplier = _multiplier;
        }
        else if (Collection == 3){
            Id.tokenid = _tokenId;
            Id3.hero = _rank;
            Id3.level = _level;
            Id3.reward = _reward;
            Id3.mining = _mining;
            Id3.staking = _staking;
            Id3.multiplier = _multiplier;
        }
    }

    // ADMIN - BOOLEAN METADATA INPUT
    function adminDiscount (uint256 _tokenId, uint _switch) external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        require(_switch >= 0 && _switch <= 1, 'Invalid Switch type');
        ArmyMetadata storage Id = ArmyMetadatas[_tokenId];
        if (_switch == 0){ //Discount On
            bool Discount = false;
            tokenIdForDiscount[_tokenId] = Discount;
            Id.discount = Discount;
        }
        else if (_switch == 1){ //Discount Off
            bool Discount = true;
            tokenIdForDiscount[_tokenId] = Discount;
            Id.discount = Discount;
        }
    }
    function adminReset (uint256 _tokenId, uint _switch) external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        require(_switch >= 0 && _switch <= 1, 'Invalid Switch type');
        EmblemMetadata storage Id = EmblemMetadatas[_tokenId];
        if (_switch == 0){ //Reset On
            bool Reset = false;
            tokenIdForReset[_tokenId] = Reset;
            Id.reset = Reset;
        }
        else if (_switch == 1){ //Reset Off
            bool Reset = true;
            tokenIdForReset[_tokenId] = Reset;
            Id.reset = Reset;
        }
    }
    function adminWar (uint256 _tokenId, uint _switch) external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        require(_switch >= 0 && _switch <= 1, 'Invalid Switch type');
        HeroMetadata storage Id = HeroMetadatas[_tokenId];
        if (_switch == 0){ //War On
            bool War = false;
            tokenIdForSupport[_tokenId] = War;
            Id.support = War;
        }
        else if (_switch == 1){ //War Off
            bool War = true;
            tokenIdForSupport[_tokenId] = War;
            Id.support = War;
        }
    }

    // OWNER - SPECIAL DAY ON & OFF
    function specialDayON () external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        bool on = true;
        specialDay = on;
    }
    function specialDayOFF () external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        bool off = false;
        specialDay = off;
    }
      // OWNER - WITHDRAW HONOR & BUSD
    function withdrawBusd() external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        busdAddress.transfer(owner, busdBalance());
    }
    function busdBalance() public view returns (uint) {
        return busdAddress.balanceOf(address(this));
    }
    function withdrawHonor() external {
        require(msg.sender == owner, 'You must be the owner to run this.');
        honorAddress.transfer(owner, honorBalance());
    }
    function honorBalance() public view returns (uint) {
        return honorAddress.balanceOf(address(this));
    }

    //-----------------------------------------------------------------------------------------------------------------------------------
    // HONORDAO SMART CONTRACT ACCESS
    function addCounter (address _to, uint _wdType, uint256 _tokenId, uint256 _tokenId2) external {
        require(msg.sender == honorDao, 'Protected by HONOR Dao');
        if(_wdType == 2){
            // Withdraw counter and checker for 1 NFT (5% Tax Deduction)
            require(_to == armyRankNFT.ownerOf(_tokenId),"You not owner this TokenId");
            ArmyMetadata storage TokenId = ArmyMetadatas[_tokenId];
            uint armyCounter = TokenId.armyCounter;
            TokenId.armyCounter = armyCounter + 1;
        }
        else if(_wdType == 4){
            // Withdraw counter and checker for 1 NFT (NFT Reward 5%)
            require(_to == armyRankNFT.ownerOf(_tokenId),"You not owner this TokenId");
            ArmyMetadata storage TokenId = ArmyMetadatas[_tokenId];
            uint armyCounter = TokenId.armyCounter;
            TokenId.armyCounter = armyCounter + 1;
        }
        else if(_wdType == 1){
            // Withdraw counter and checker for 2 NFTs - Remove All Tax (ROT)
            require(_tokenId != _tokenId2, "Token ID Cannot Be The Same");
            require(_to == armyRankNFT.ownerOf(_tokenId),"You not owner this TokenId - Input Token A");
            require(_to == armyRankNFT.ownerOf(_tokenId2),"You not owner this TokenId - Input Token B");

            ArmyMetadata storage TokenId = ArmyMetadatas[_tokenId];
            ArmyMetadata storage TokenId2 = ArmyMetadatas[_tokenId2];
            uint armyCounter = TokenId.armyCounter;
            uint armyCounter2 = TokenId2.armyCounter;
            TokenId.armyCounter = armyCounter + 1;
            TokenId2.armyCounter = armyCounter2 + 1;
        }
        else if(_wdType == 5){
            // Withdraw counter and checker for 2 NFTs - (NFT Reward 10%) - Army + Emblem
            require(_tokenId != _tokenId2, "Token ID Cannot Be The Same");
            require(_to == armyRankNFT.ownerOf(_tokenId),"You not owner this TokenId - Input Token A");
            require(_to == emblemRankNFT.ownerOf(_tokenId2),"You not owner this TokenId - Input Token B");

            ArmyMetadata storage TokenId = ArmyMetadatas[_tokenId];
            EmblemMetadata storage TokenId2 = EmblemMetadatas[_tokenId2];
            uint armyCounter = TokenId.armyCounter;
            uint emblemCounter = TokenId2.emblemCounter;
            TokenId.armyCounter = armyCounter + 1;
            TokenId2.emblemCounter = emblemCounter + 1;
        }
    }
}

// SPDX-License-Identifier: MIT
// HONOR Protocols - Army Rank NFT Collection
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Busd.sol";

contract ArmyNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  Busd public busdAddress;
  string internal baseURI;
  string internal baseExtension = ".json";
  uint256 public busdCost =  300 * 10 ** 18; // Price in busd
  uint256 public maxSupply = 10000;
  uint256 public pubSupply = 9500; // Total supply for public mint
  uint256 maxMintAmount = 1;
  uint256 maxMintAmountDev = 10; // Dev max mint
  bool internal paused = false;
  mapping(address => bool) public whitelisted;
  mapping(uint256 => PubSale) public Counters; 

  struct PubSale {
    uint Counter;
  }

  constructor(string memory _name, string memory _symbol, string memory _initBaseURI, Busd _busdAddress) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    // devMint(msg.sender, 5);
    busdAddress = _busdAddress;
  }

  // Internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // Public
  function mint(address _address, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount, "Minimun Mint is 1 Per Purchase");
    require(supply + _mintAmount <= maxSupply, "Cant Mint Anymore, Sold Out");
    require(busdAddress.balanceOf(_address) >= busdCost, "Not Enough BUSD");

    if (msg.sender != owner()) {
        if(whitelisted[msg.sender] != true) {
          uint CheckCount = Counters[1].Counter;
          require(CheckCount < pubSupply, "Public Sale, Sold Out");
          require(busdAddress.balanceOf(_address) >= busdCost * _mintAmount, "Not Enough BUSD");
          PubSale storage Sale = Counters[1];
          Sale.Counter = Sale.Counter + 1;
        }
    }
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_address, supply + i);
    }
    busdAddress.transferFrom(msg.sender, address(this), busdCost);
  }

  // Mint for dev
  function devMint(address _to, uint256 _mintAmount) public payable onlyOwner {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmountDev);
    require(supply + _mintAmount <= maxSupply, "Cant Mint Anymore, SOLD OUT");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
    }
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
      for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
      }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
      ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
      : "";
  }

  //Owner - Set
  function setBusdCost(uint256 _newBusdCost) external onlyOwner {
    busdCost = _newBusdCost;
  }
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }
  function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
    baseExtension = _newBaseExtension;
  }
  function pause(bool _state) external onlyOwner {
    paused = _state;
  }
 function whitelistUser(address _user) external onlyOwner {
    whitelisted[_user] = true;
  }
  function removeWhitelistUser(address _user) external onlyOwner {
    whitelisted[_user] = false;
  }

  // Owner - Withdrawal Busd
  function withdrawBusd() external onlyOwner {
    busdAddress.transfer(owner(), busdBalance());
  }
  function busdBalance() public view returns (uint) {
    return busdAddress.balanceOf(address(this));
  }

}

// SPDX-License-Identifier: MIT
// HONOR Protocols - Emblem NFT Collection
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Honor.sol";
import "./Busd.sol";

// Mock Emblem NFT
contract EmblemNFT is ERC721Enumerable, Ownable {
      constructor(string memory _name, string memory _symbol, string memory _initBaseURI) ERC721(_name, _symbol) {
  }
}

// SPDX-License-Identifier: MIT
// HONOR Protocols - War Hero NFT Collection
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Honor.sol";
import "./Busd.sol";

// Mock War Hero NFT
contract WarNFT is ERC721Enumerable, Ownable {
      constructor(string memory _name, string memory _symbol, string memory _initBaseURI) ERC721(_name, _symbol) {
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// DuanFX
//-----------------------------------------------------------------------------------------------------------------------------------
pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock BUSD Token
contract Busd is ERC20 {
  constructor() ERC20('Mock BUSD token', 'mBUSD') {
    _mint(msg.sender, 2000000 * 10 ** 18);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// HONOR Protocols - Token
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------
pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Honor is ERC20 {
  address private owner;
  address public honorDao; // Nodes @ Yield Rank
  address public miningDao; // Mining & Staking
  address public earnDao; // Anything to Earn
  uint public maxSupply = 25000000 * 10 ** 18; // Reserved for Staking, Mining & ATE in Honor Ecosystem and Utilities - 25M

  constructor() ERC20('Honor Token', 'HONOR') {
    owner = msg.sender;
    _mint(msg.sender, 2500000 * 10 ** 18); // Intial Total Supply for Node Reward Pool & LP - 2.5M
  }

  function setDaoContract(address _honorDao) external{
    require(msg.sender == owner, 'You must be the owner to run this.');
    honorDao = _honorDao;
  }
  function setMiningContract(address _miningDao) external{
    require(msg.sender == owner, 'You must be the owner to run this.');
    miningDao = _miningDao;
  }
  function setEarnContract(address _earnDao) external{
    require(msg.sender == owner, 'You must be the owner to run this.');
    earnDao = _earnDao;
  }

  function mint(uint256 _amount) public {
    uint256 supply = totalSupply();
    require(msg.sender == honorDao || msg.sender == miningDao || msg.sender == earnDao || msg.sender == owner, 'Can only be used by HonorDao or owner. - Token');
    require(_amount + supply <= maxSupply, "Max Supply 25,000,000");
    _mint(msg.sender, _amount);
  }

  function burn(uint256 _amount) public {
    require(msg.sender == honorDao || msg.sender == miningDao || msg.sender == earnDao || msg.sender == owner, 'Can only be used by HonorDao or owner. - Token');
    _burn(msg.sender, _amount);
  }
}