// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.12;

//import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/introspection/IERC165.sol";
//import "https://raw.githubusercontent.com/OpenZeppelin/contracts-upgradeable/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC721 is IERC165Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function Fee() external view returns (uint256 royalty);
    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address _receiver, uint256 _royaltyAmount);
    function collectionOwner() external view returns (address owner);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
contract EmpireMarketplaceV7 is Initializable{
    using SafeMath for uint256;
    struct AuctionItem {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        uint256 askingPrice;
        bool isSold;
        bool bidItem;
        uint256 bidPrice;
        address bidderAddress;
        address ERC20;
    }

    uint256 public serviceFee; //2.5% serviceFee
    address public feeAddress; // admin address where serviceFee will be sent
    address public marketplaceOwner;
    address public empireToken;
    AuctionItem[] public itemsForSale;

    //to check if item is open to market
    mapping (address => mapping (uint256 => bool)) activeItems;
    mapping(address => bool) validERC;
    mapping (address => mapping(uint256=>uint256)) auctionItemId;
    mapping (address => mapping (address => mapping(uint256 => uint256))) pendingReturns;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ItemAdded(uint id, uint tokenId, address tokenAddress, uint256 askingPrice, bool bidItem);
    event ItemSold(uint id, address buyer, uint256 askingPrice);
    event BidPlaced(uint tokenID, address bidder, uint256 bidPrice, address CollectionAdd);
    address public feeAggregatorAddress;
    uint256 public AggregatorFee;
    constructor(address _feeAgg, address _feeSim) {
        marketplaceOwner = msg.sender;
        //empireToken = _empireToken;
        //validERC[_empireToken] = true;
        serviceFee = 400;
        AggregatorFee = 100;
        //feeAggregatorAddress = address(0x2C9C756A7CFd79FEBD2fa9b4C82c10a5dB9D8996);
        feeAggregatorAddress = _feeAgg;
        feeAddress = _feeSim;
        //feeAddress = address(0x943cD6e3EBCfAF1B76c6336bd775245d4E0D7239);
    }

    modifier onlyOwner{
        require(marketplaceOwner == msg.sender);
        _;
    }
    modifier OnlyItemOwner(address tokenAddress, uint256 tokenId){
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.ownerOf(tokenId) == msg.sender);
        _;
    }
    modifier OnlyItemOwnerAuc(uint256 aucItemId){
        IERC721 tokenContract = IERC721(itemsForSale[aucItemId-1].tokenAddress);
        require(tokenContract.ownerOf(itemsForSale[aucItemId-1].tokenId) == msg.sender);
        _;
    }
    modifier HasTransferApproval(address tokenAddress, uint256 tokenId){
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.getApproved(tokenId) == address(this));
        _;
    }
    modifier ItemExists(uint256 id){
        require(itemsForSale[id-1].id == id, "Could not find Item");
        _;
    }
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(marketplaceOwner, newOwner);
        marketplaceOwner = newOwner;
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner{
        require(newFeeAddress != address(0), "newFeeAddress address cannot be 0");
        feeAddress = newFeeAddress;
    }
    
    function changeFeeAggregatorAddress(address newFeeAggregatorAddress) external onlyOwner{
        require(newFeeAggregatorAddress != address(0), "feeAggregatorAddress address cannot be 0");
        feeAggregatorAddress = newFeeAggregatorAddress;
    }

    function changeServiceFee(uint256 newFee) external onlyOwner{
        require(newFee < 3000, 'Service Should be less than 30%');
        serviceFee = newFee;
    }
    
    function changeAggregatorFee(uint256 newFee) external onlyOwner{
        require(newFee < 3000, 'Aggregator Should be less than 30%');
        require(serviceFee > newFee, 'Aggregator Fee must be less than serviceFee');
        AggregatorFee = newFee;
    }

    function addItemToMarket(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, address tokenERC20) OnlyItemOwner(tokenAddress, tokenId) HasTransferApproval(tokenAddress, tokenId) external returns(uint256) {
        require(activeItems[tokenAddress][tokenId] == false, "Item is already up for sale");

        if(tokenERC20 == address(0)){
            return _addItemSimple(tokenId, tokenAddress, askingPrice, bidItem);
        }else{
            require(validERC[tokenERC20], "ERC20 Token is not in valid list");
            return _addItemERC(tokenId, tokenAddress, askingPrice, bidItem, tokenERC20);
        }
    }

    function _addItemSimple(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem) internal returns (uint256){
        if (auctionItemId[tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), address(0)));
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;

            assert(itemsForSale[newItemId - 1].id == newItemId);
            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem);
            return newItemId;
        }
        else{
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].askingPrice = askingPrice;
            activeItems[tokenAddress][tokenId] = true;

            assert(itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id == auctionItemId[tokenAddress][tokenId]);
            emit ItemAdded(auctionItemId[tokenAddress][tokenId], tokenId, tokenAddress, askingPrice, bidItem);
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function _addItemERC(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, address tokenERC20) internal  returns (uint256){
        if (auctionItemId[tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), tokenERC20));
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;

            assert(itemsForSale[newItemId - 1].id == newItemId);
            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem);
            return newItemId;
        }
        else{
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].askingPrice = askingPrice;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].ERC20 = tokenERC20;
            activeItems[tokenAddress][tokenId] = true;

            assert(itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id == auctionItemId[tokenAddress][tokenId]);
            emit ItemAdded(auctionItemId[tokenAddress][tokenId], tokenId, tokenAddress, askingPrice, bidItem);
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function removeItem(uint256 id) public{
        address collectionAddress = itemsForSale[id-1].tokenAddress;
        require(activeItems[collectionAddress][itemsForSale[id-1].tokenId],'Already not listed in market');
        require(IERC721(collectionAddress).ownerOf(itemsForSale[id-1].tokenId) == msg.sender,'Only Item Can Remove From Market');
        activeItems[collectionAddress][itemsForSale[id-1].tokenId] = false;
        if(itemsForSale[id-1].isSold == false && itemsForSale[id-1].bidItem == true){
            pendingReturns[itemsForSale[id-1].bidderAddress][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] = itemsForSale[id-1].bidPrice;
            itemsForSale[id - 1].bidItem = false;
            itemsForSale[id - 1].bidderAddress = address(0);
            itemsForSale[id - 1].bidPrice = 0;
        }
        itemsForSale[id - 1].askingPrice = 0;
        itemsForSale[id - 1].ERC20 = address(0);

    }

    function BuyItem(uint256 id) external payable ItemExists(id) HasTransferApproval(itemsForSale[id-1].tokenAddress, itemsForSale[id-1].tokenId) {
        require(activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id-1].tokenId],'Item not listed in market');
        require(itemsForSale[id-1].isSold == false,"Item already sold");
        require(itemsForSale[id-1].bidItem == false, "Item not for instant buy");
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);
        require(msg.sender != itemOwner, "Seller cannot buy item");

        if(itemsForSale[id-1].ERC20 == address(0)){
            require(msg.value >= itemsForSale[id - 1].askingPrice, "Not enough funds set");
            _buyitemSimple(id);
        }else{
            _buyitemERC(id);
        }
    }

    function printOwner(address _collectionAddress) public view returns(address){
        return IERC721(_collectionAddress).collectionOwner();
    }

    function _royaltyData(IERC721 _collection, uint256 _tokenid, uint256 amount) public view returns(address recepient, uint256 value){
        try _collection.royaltyInfo(_tokenid, amount) returns (address _rec, uint256 _val){
            if(_rec == address(0)){
                return (_rec,0);    
            }
            return (_rec,_val);
        }catch{
            return (address(0),0);
        }
    }

    function _buyitemSimple(uint256 id) internal{
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);

        uint256 sFee = _calculateServiceFee(msg.value);
        uint256 aFee = _calculateAggregatorFee(msg.value);
        
        (address royaltyAddress, uint256 rFee) = _royaltyData(Collection ,itemsForSale[id - 1].tokenId, msg.value);
        
        (bool success, ) = itemOwner.call{value: msg.value.sub(sFee).sub(aFee).sub(rFee)}("");
        //(bool success, ) = itemOwner.call{value: msg.value}("");
        require(success, "Failed to send Ether");

        (bool success1, ) = feeAddress.call{value: sFee}("");
        require(success1, "Failed to send Ether (Service FEE)");
        
        if(aFee > 0){
            (bool success3, ) = feeAggregatorAddress.call{value: aFee}("");
            require(success3, "Failed to send Ether (Aggregator FEE)");
        }
        
        if(rFee > 0){
            (bool success2, ) = royaltyAddress.call{value: rFee}("");
            require(success2, "Failed to send Ether");
        }
        itemsForSale[id - 1].isSold = true;
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        IERC721(itemsForSale[id - 1].tokenAddress).safeTransferFrom(Collection.ownerOf(itemsForSale[id - 1].tokenId), msg.sender, itemsForSale[id - 1].tokenId);
        //itemsForSale[id - 1].seller.transfer(msg.value);

        //itemsForSale[id - 1].seller = payable(msg.sender);
        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _buyitemERC(uint256 id) internal{
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(_bi.ERC20);
        IERC721 Collection = IERC721(_bi.tokenAddress);
        
        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 val =  _bi.askingPrice;
        require(tokenERC.allowance(msg.sender,address(this)) >= val , "Not enough token funds");
        uint256 sFee = _calculateServiceFee(val);
        uint256 aFee = _calculateAggregatorFee(val);
        //uint256 rFee = _calculateRoyaltyFee(val, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(Collection ,_bi.tokenId, val);
        if(_bi.ERC20 == empireToken){
            tokenERC.transferFrom(msg.sender,itemOwner, _bi.askingPrice.sub(rFee));
            if(rFee > 0){
                tokenERC.transferFrom(msg.sender,royaltyAddress, rFee);
            }
        }else{
            tokenERC.transferFrom(msg.sender,itemOwner, val.sub(sFee).sub(aFee).sub(rFee));
            tokenERC.transferFrom(msg.sender,feeAddress, sFee);
            if(aFee > 0){
                tokenERC.transferFrom(msg.sender,feeAggregatorAddress, aFee);
            }
            if(rFee > 0){
                tokenERC.transferFrom(msg.sender,royaltyAddress, rFee);
            }
        }

        itemsForSale[id - 1].isSold = true;
        itemsForSale[id - 1].ERC20 = address(0);
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        IERC721(itemsForSale[id - 1].tokenAddress).safeTransferFrom(Collection.ownerOf(itemsForSale[id - 1].tokenId), msg.sender, itemsForSale[id - 1].tokenId);
        //itemsForSale[id - 1].seller.transfer(msg.value);

        //itemsForSale[id - 1].seller = payable(msg.sender);
        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _calculateServiceFee(uint256 _amount) public view returns(uint256){
        return _amount.mul(serviceFee-AggregatorFee).div(
            10**4
        );
    }
    
    function _calculateAggregatorFee(uint256 _amount) public view returns(uint256){
        return _amount.mul(AggregatorFee).div(
            10**4
        );
    }

    function _calculateRoyaltyFee(uint256 _amount, uint256 _royalty) public pure returns(uint256){
        return _amount.mul(_royalty).div(
            10**4
        );
    }

    function addERC20tokens(address erc20) external onlyOwner{
        validERC[erc20] = true;
    }

    function removeERC20tokens(address erc20) external onlyOwner{
        validERC[erc20] = false;
    }

    // put a bid on an item
    // modifiers: ItemExists, IsForSale, IsForBid, HasTransferApproval
    // args: auctionItemId
    // check if a bid already exists, if yes: check if this bid value is higher then prev

    function PlaceABid(uint256 aucItemId, uint256 amount) external payable ItemExists(aucItemId) HasTransferApproval(itemsForSale[aucItemId-1].tokenAddress, itemsForSale[aucItemId-1].tokenId) {
        require(activeItems[itemsForSale[aucItemId - 1].tokenAddress][itemsForSale[aucItemId-1].tokenId],'Item not listed in market');
        require(itemsForSale[aucItemId-1].isSold == false,"Item already sold");
        require(itemsForSale[aucItemId-1].bidItem == true, "Item not for bidding");

        if(itemsForSale[aucItemId-1].ERC20 == address(0)){
            require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "Not enough funds set");
            _placeBidSimple(aucItemId);
        }else{
            _placeBidERC(aucItemId, amount);
        }
    }

    function _placeBidSimple(uint256 id) internal{
        uint256 totalPrice = 0;
        if (pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id] == 0){
            totalPrice = msg.value;
        }
        else{
            totalPrice = msg.value + pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id];
        }
        require(totalPrice > itemsForSale[id-1].askingPrice, "There is already a higher asking price");
        require(totalPrice > itemsForSale[id-1].bidPrice, "There is already a higher price");

        pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id] = 0;
        if (itemsForSale[id - 1].bidPrice != 0){
            pendingReturns[itemsForSale[id-1].bidderAddress][address(0)][itemsForSale[id-1].id] = itemsForSale[id-1].bidPrice;
        }
        itemsForSale[id-1].bidPrice = totalPrice;
        itemsForSale[id-1].bidderAddress = msg.sender;

        emit BidPlaced(itemsForSale[id-1].tokenId,msg.sender,totalPrice,itemsForSale[id-1].tokenAddress);
    }

    function _placeBidERC(uint256 id, uint256 amount) internal{
        uint256 totalPrice = 0;
        IERC20Upgradeable tokenERC = IERC20Upgradeable(itemsForSale[id-1].ERC20);
        require(tokenERC.allowance(msg.sender,address(this)) >= amount , "Not enough token funds");

        if (pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] == 0){
            totalPrice = amount;
        }
        else{
            totalPrice = amount + pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id];
        }
        require(totalPrice > itemsForSale[id-1].askingPrice, "There is already a higher asking price");
        require(totalPrice > itemsForSale[id-1].bidPrice, "There is already a higher price");
        tokenERC.transferFrom(msg.sender,address(this),amount);
        pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] = 0;
        if (itemsForSale[id - 1].bidPrice != 0){
            pendingReturns[itemsForSale[id-1].bidderAddress][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] = itemsForSale[id-1].bidPrice;
        }
        itemsForSale[id-1].bidPrice = totalPrice;
        itemsForSale[id-1].bidderAddress = msg.sender;
    }

    function withdrawPrevBid(uint256 aucItemId,address _erc20) external returns(bool) {
        uint256 amount = pendingReturns[msg.sender][_erc20][aucItemId];
        require(amount > 0, 'No Amount To Withdraw');
        if (amount > 0){
            pendingReturns[msg.sender][_erc20][aucItemId] = 0;
            if(_erc20 == address(0)){
                if (!payable(msg.sender).send(amount)) {
                    // No need to call throw here, just reset the amount owing
                    pendingReturns[msg.sender][_erc20][aucItemId] = amount;
                    return false;
                }
            }else{
                IERC20Upgradeable(_erc20).transfer(msg.sender, amount);
            }
        }
        return true;
    }

    function EndAuction(uint256 aucItemId) external payable ItemExists(aucItemId) OnlyItemOwnerAuc(aucItemId) HasTransferApproval(itemsForSale[aucItemId-1].tokenAddress, itemsForSale[aucItemId-1].tokenId){
        require(activeItems[itemsForSale[aucItemId - 1].tokenAddress][itemsForSale[aucItemId-1].tokenId],'Item not listed in market');
        //require(itemsForSale[aucItemId - 1].bidPrice > itemsForSale[aucItemId - 1].askingPrice, "No Bids Exist!");
        require(itemsForSale[aucItemId-1].isSold == false,"Item already sold");
        require(itemsForSale[aucItemId-1].bidItem == true, "Item not for bidding");
        //just EndAuction
        if(itemsForSale[aucItemId-1].bidPrice == 0){
            _endAuctionOnly(aucItemId);
        }
        //End And Distribute bidPrice
        else if(itemsForSale[aucItemId-1].ERC20 == address(0)){
            //require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "Not enough funds set");
            _endAuctionSimple(aucItemId);
        }else{
            _endAuctionERC(aucItemId);
        }
    }

    function _endAuctionSimple(uint256 id) internal{
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC721 Collection = IERC721(_bi.tokenAddress);
        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 sFee = _calculateServiceFee(_bi.bidPrice);
        uint256 aFee = _calculateAggregatorFee(_bi.bidPrice);
        //uint256 rFee = _calculateRoyaltyFee(itemsForSale[id - 1].bidPrice, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(Collection ,_bi.tokenId, _bi.bidPrice);
        (bool success, ) = itemOwner.call{value: _bi.bidPrice.sub(sFee).sub(aFee).sub(rFee)}("");
        require(success, "Failed to send Ether");
        (bool success1, ) = feeAddress.call{value: sFee}("");
        require(success1, "Failed to send Ether");
        if(aFee > 0){
            (bool success3, ) = feeAggregatorAddress.call{value: aFee}("");
            require(success3, "Failed to send Ether");
        }
        if(rFee > 0){
            (bool success2, ) = royaltyAddress.call{value: rFee}("");
            require(success2, "Failed to send Ether");
        }
        Collection.safeTransferFrom(itemOwner, itemsForSale[id - 1].bidderAddress, _bi.tokenId);
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][itemsForSale[id - 1].tokenId] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
    }

    function _endAuctionERC(uint256 id) internal{
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(_bi.ERC20);
        IERC721 Collection = IERC721(_bi.tokenAddress);
        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 val = _bi.bidPrice;
        uint256 sFee = _calculateServiceFee(val);
        uint256 aFee = _calculateAggregatorFee(val);
        //uint256 rFee = _calculateRoyaltyFee(val, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(Collection ,_bi.tokenId, _bi.bidPrice);

        if(itemsForSale[id-1].ERC20 == empireToken){
            tokenERC.transfer(itemOwner, val.sub(rFee));
            if(rFee > 0){
                tokenERC.transfer(royaltyAddress, rFee);
            }
        }else{
            tokenERC.transfer(itemOwner, val.sub(sFee).sub(aFee).sub(rFee));
            tokenERC.transfer(feeAddress, sFee);
            if(aFee > 0){
                tokenERC.transfer(feeAggregatorAddress, aFee);
            }
            if(rFee > 0){
                tokenERC.transfer(royaltyAddress, rFee);
            }
        }
        Collection.safeTransferFrom(itemOwner, itemsForSale[id - 1].bidderAddress, itemsForSale[id - 1].tokenId);
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][itemsForSale[id-1].ERC20][itemsForSale[id - 1].tokenId] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
        itemsForSale[id - 1].ERC20 = address(0);
    }
    
    function _endAuctionOnly(uint256 id) internal{
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][itemsForSale[id - 1].tokenId] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library royalties{
    struct royalstr {
        address uaddress;
        uint256 pecentr;
    }
}

library auc{
    struct AuctionItem {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        uint256 askingPrice;
        bool isSold;
        bool bidItem;
        uint256 bidPrice;
        address bidderAddress;
        address ERC20;
        uint256[2] itype;
    }
}

interface IERC721 is IERC165Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function _royal(uint256 tokenId, string memory rtype) external view returns (royalties.royalstr memory);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function setApprovalForAllFromMarket(address origin, address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC1155Upgradeable is IERC165Upgradeable {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function _royal(uint256 tokenId, string memory rtype) external view returns (royalties.royalstr memory);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function setApprovalForAllFromMarket(address origin, address operator, bool _approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

abstract contract marketplace is Initializable{
    using SafeMath for uint256;
    
    uint256 public serviceFee; //2.5% serviceFee
    address public feeAddress; // admin address where serviceFee will be sent
    address internal marketplaceOwner;
    auc.AuctionItem[] public itemsForSale;

    //to check if item is open to market
    mapping (address => mapping (uint256 => bool)) activeItems;
    mapping(address => bool) public validERC;
    mapping (address => mapping(uint256=>uint256)) auctionItemId;
    mapping (address => mapping (address => mapping(uint256 => uint256))) pendingReturns;
    mapping(uint256 => mapping(address => mapping(address => bool))) internal checkOrder;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ItemAdded(uint id, uint tokenId, address tokenAddress, uint256 askingPrice, bool bidItem);
    event ItemSold(uint id, address buyer, uint256 askingPrice);
    event BidPlaced(uint tokenID, address bidder, uint256 bidPrice, address CollectionAdd);
    

    function initialize(address _feeAddress) external initializer {
        marketplaceOwner = msg.sender;
        serviceFee = 250;
        feeAddress = _feeAddress;
    }

    modifier onlyOwner{
        require(marketplaceOwner == msg.sender);
        _;
    }
    
    function ItemExists(uint256 id) private view{
        require(itemsForSale[id-1].id == id, "NF");
        //_;
    }

    function placeOrder(
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem,
        address tokenERC20,
        uint256[2] memory _type
    ) external returns(uint256) {
        require(_type[0] <= 1,"Invalid");
        require(activeItems[tokenAddress][tokenId] == false, "inactive");
        if(!IERC721(tokenAddress).isApprovedForAll(msg.sender,address(this))){
            IERC721(tokenAddress).setApprovalForAllFromMarket(msg.sender,address(this),true);
        }
        if(bidItem){
            require(_type[0] == 0, "onlySingle");
        }

        if(tokenERC20 == address(0)){
            return _addItemSimple(tokenId, tokenAddress, askingPrice, bidItem, [_type[0], _type[1]]);
        }else{
            require(validERC[tokenERC20], "invalid Token");
            return _addItemERC(tokenId, tokenAddress, askingPrice, bidItem, tokenERC20, [_type[0], _type[1]]);
        }
    }

    function _addItemSimple(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, uint256[2] memory _type) internal returns (uint256) {
        if(_type[0] == 1){
            IERC1155Upgradeable _multiContract = IERC1155Upgradeable(tokenAddress);
            require(_multiContract.balanceOf(msg.sender,tokenId) >= _type[1],"Blnc");
        }else{
            IERC721 tokenContract = IERC721(tokenAddress);
            require(tokenContract.ownerOf(tokenId) == msg.sender, "onlyOwner NFT");   
        }
        if (auctionItemId[tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(auc.AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), address(0), [_type[0], _type[1]]));
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            //assert(itemsForSale[newItemId - 1].id == newItemId);
            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem);
            return newItemId;
        }
        else{
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].askingPrice = askingPrice;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].itype[0] = _type[0];
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].itype[1] = _type[1];
            activeItems[tokenAddress][tokenId] = true;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            //assert(itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id == auctionItemId[tokenAddress][tokenId]);
            emit ItemAdded(auctionItemId[tokenAddress][tokenId], tokenId, tokenAddress, askingPrice, bidItem);
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function _addItemERC(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, address tokenERC20, uint256[2] memory _type) internal  returns (uint256){
        if(_type[0] == 1){
            IERC1155Upgradeable _multiContract = IERC1155Upgradeable(tokenAddress);
            require(_multiContract.balanceOf(msg.sender,tokenId) >= _type[1],"blnc");
        }else{
            IERC721 tokenContract = IERC721(tokenAddress);
            require(tokenContract.ownerOf(tokenId) == msg.sender, "oNlyOwner");   
        }
        if (auctionItemId[tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(auc.AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), tokenERC20, [_type[0], _type[1]]));
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem);
            return newItemId;
        }
        else{
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].askingPrice = askingPrice;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].ERC20 = tokenERC20;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].itype[0] = _type[0];
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].itype[1] = _type[1];
            activeItems[tokenAddress][tokenId] = true;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            //assert(itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id == auctionItemId[tokenAddress][tokenId]);
            emit ItemAdded(auctionItemId[tokenAddress][tokenId], tokenId, tokenAddress, askingPrice, bidItem);
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function cancelOrder(uint256 id) external{
        address collectionAddress = itemsForSale[id-1].tokenAddress;
        require(activeItems[collectionAddress][itemsForSale[id-1].tokenId],"Inactive");
        require(IERC721(collectionAddress).ownerOf(itemsForSale[id-1].tokenId) == msg.sender,"tOwner");
        require(checkOrder[itemsForSale[id-1].tokenId][collectionAddress][msg.sender],"NF");
        activeItems[collectionAddress][itemsForSale[id-1].tokenId] = false;
        checkOrder[itemsForSale[id-1].tokenId][collectionAddress][msg.sender] = false;
        if(itemsForSale[id - 1].bidItem == true){
            _endAuctionOnly(id);
        }else{
            itemsForSale[id - 1].askingPrice = 0;
            itemsForSale[id - 1].itype[1] = 0;
            itemsForSale[id - 1].ERC20 = address(0);
        }
    }

    function editOrder(uint256 id, uint256 newPrice) external{
        address collectionAddress = itemsForSale[id-1].tokenAddress;
        require(activeItems[collectionAddress][itemsForSale[id-1].tokenId],"Inactive");
        require(itemsForSale[id-1].bidItem == false, "not instant");
        require(checkOrder[itemsForSale[id-1].tokenId][collectionAddress][msg.sender],"onlyOwner");
        itemsForSale[id-1].askingPrice = newPrice;
        //return true;
    }

    function buyItem(address from, uint256 id, uint256 numOfTokens) external payable {
        ItemExists(id);
        require(activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id-1].tokenId],"inactive");
        require(itemsForSale[id-1].isSold == false,"sold");
        require(itemsForSale[id-1].bidItem == false, "not instant");
        require(itemsForSale[id-1].itype[1] >= numOfTokens,"Not enough");

        if(itemsForSale[id-1].itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(itemsForSale[id - 1].tokenAddress);
            require(Collection.balanceOf(from,itemsForSale[id - 1].tokenId) >= numOfTokens, "sellerM blnc");
        }else{
            IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
            require(Collection.ownerOf(itemsForSale[id - 1].tokenId) == from, "sellerS blnc");
        }
        

        if(itemsForSale[id-1].ERC20 == address(0)){
            require(msg.value >= itemsForSale[id - 1].askingPrice.mul(numOfTokens), "amount");
            _buyitemSimple(from,id,numOfTokens);
        }else{
            _buyitemERC(from,id,numOfTokens);
        }
    }
    
    function getRoyalties(uint256 amount, IERC721 _collection, uint256 tokenid_, IERC20Upgradeable tokenERC) internal returns(uint256){
        try _collection._royal(tokenid_, "artist") returns (royalties.royalstr memory d){
            royalties.royalstr memory agent = _collection._royal(tokenid_,"agent");
            uint256[2] memory royalFees;
            address[2] memory royalAddress;
            if(d.uaddress != address(0) && d.pecentr != 0){
                royalFees[0] = _calculateRoyaltyFee(amount, d.pecentr);
                royalAddress[0] = d.uaddress;
                if(tokenERC == IERC20Upgradeable(address(0))){
                    (bool success2, ) = royalAddress[0].call{value: royalFees[0]}("");
                    require(success2, "sendissue RAr");
                }else{
                    tokenERC.transferFrom(msg.sender,royalAddress[0], royalFees[0]);
                }
            }
            if(agent.uaddress != address(0) && d.pecentr != 0){
                royalFees[1] = _calculateRoyaltyFee(amount, agent.pecentr);
                royalAddress[1] = agent.uaddress;
                if(tokenERC == IERC20Upgradeable(address(0))){
                    (bool success3, ) = royalAddress[1].call{value: royalFees[1]}("");
                    require(success3, "sendIssue RAg");
                }else{
                    tokenERC.transferFrom(msg.sender,royalAddress[0], royalFees[0]);
                }
            }
            if(tokenERC == IERC20Upgradeable(address(0))){
                (bool success1, ) = feeAddress.call{value: _calculateServiceFee(amount)}("");
                require(success1, "sendIssue SF");
            }else{
                tokenERC.transferFrom(msg.sender,feeAddress, _calculateServiceFee(amount));
            }
            return amount.sub(_calculateServiceFee(amount)).sub(royalFees[0]).sub(royalFees[1]);
        }catch{
            if(tokenERC == IERC20Upgradeable(address(0))){
                (bool success1, ) = feeAddress.call{value: _calculateServiceFee(amount)}("");
                require(success1, "sendIssue SF");
            }else{
                tokenERC.transferFrom(msg.sender,feeAddress, _calculateServiceFee(amount));
            }
            return amount.sub(_calculateServiceFee(amount));
        }
    }

    function getAucRoyaltiesERC(uint256 amount, IERC721 _collection, uint256 tokenid_, IERC20Upgradeable tokenERC) internal returns(uint256){
        try _collection._royal(tokenid_, "artist") returns (royalties.royalstr memory d){
            royalties.royalstr memory agent = _collection._royal(tokenid_,"agent");
            uint256[2] memory royalFees;
            address[2] memory royalAddress;
            if(d.uaddress != address(0) && d.pecentr != 0){
                royalFees[0] = _calculateRoyaltyFee(amount, d.pecentr);
                royalAddress[0] = d.uaddress;
                tokenERC.transfer(royalAddress[0], royalFees[0]);
            }
            if(agent.uaddress != address(0) && d.pecentr != 0){
                royalFees[1] = _calculateRoyaltyFee(amount, agent.pecentr);
                royalAddress[1] = agent.uaddress;
                tokenERC.transfer(royalAddress[0], royalFees[0]);
            }
            tokenERC.transfer(feeAddress, _calculateServiceFee(amount));
            return amount.sub(_calculateServiceFee(amount)).sub(royalFees[0]).sub(royalFees[1]);
        }catch{
            tokenERC.transfer(feeAddress, _calculateServiceFee(amount));
            return amount.sub(_calculateServiceFee(amount));
        }
    }
  
    function _buyitemSimple(address from, uint256 id, uint256 numOfTokens) internal{
        
        IERC721 CollectionA = IERC721(itemsForSale[id - 1].tokenAddress);
        (bool success, ) = from.call{value: getRoyalties(msg.value, CollectionA, itemsForSale[id - 1].tokenId,IERC20Upgradeable(address(0)))}("");
        require(success, "sendIssue V");

        if(itemsForSale[id - 1].itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(itemsForSale[id - 1].tokenAddress);
            Collection.safeTransferFrom(from,msg.sender,itemsForSale[id - 1].tokenId,numOfTokens,"");
            if(itemsForSale[id - 1].itype[1] == numOfTokens){
                itemsForSale[id - 1].isSold = true;
                activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
                checkOrder[itemsForSale[id - 1].tokenId][itemsForSale[id - 1].tokenAddress][from] = false;
            }else{
                itemsForSale[id-1].itype[1] -= numOfTokens;
            }
        }else{
            //IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
            CollectionA.safeTransferFrom(from,msg.sender,itemsForSale[id - 1].tokenId);
            itemsForSale[id - 1].isSold = true;
            checkOrder[itemsForSale[id - 1].tokenId][itemsForSale[id - 1].tokenAddress][from] = false;
            activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        }

        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _buyitemERC(address from, uint256 id, uint256 numOfTokens) internal{
        IERC20Upgradeable tokenERC = IERC20Upgradeable(itemsForSale[id-1].ERC20);
        
        IERC721 CollectionA = IERC721(itemsForSale[id - 1].tokenAddress);
        
        tokenERC.transferFrom(msg.sender,from, getRoyalties(itemsForSale[id - 1].askingPrice.mul(numOfTokens), CollectionA, itemsForSale[id - 1].tokenId,tokenERC));
        
        if(itemsForSale[id - 1].itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(itemsForSale[id - 1].tokenAddress);
            Collection.safeTransferFrom(from,msg.sender,itemsForSale[id - 1].tokenId,numOfTokens,"");
            if(itemsForSale[id - 1].itype[1] == numOfTokens){
                itemsForSale[id - 1].isSold = true;
                activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
                checkOrder[itemsForSale[id - 1].tokenId][itemsForSale[id - 1].tokenAddress][from] = false;
                itemsForSale[id - 1].ERC20 = address(0);
            }else{
                itemsForSale[id-1].itype[1] -= numOfTokens;
            }
        }else{
            CollectionA.safeTransferFrom(from,msg.sender,itemsForSale[id - 1].tokenId);
            itemsForSale[id - 1].isSold = true;
            activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
            checkOrder[itemsForSale[id - 1].tokenId][itemsForSale[id - 1].tokenAddress][from] = false;
            itemsForSale[id - 1].ERC20 = address(0);
        }
        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _calculateServiceFee(uint256 _amount) private view returns(uint256){
        return _amount.mul(serviceFee).div(
            10**4
        );
    }
    
    function _calculateRoyaltyFee(uint256 _amount, uint256 _royalty) private pure returns(uint256){
        return _amount.mul(_royalty).div(
            10**4
        );
    }

    function addERC20tokens(address erc20) external onlyOwner{
        validERC[erc20] = true;
    }

    function removeERC20tokens(address erc20) external onlyOwner{
        validERC[erc20] = false;
    }

    // put a bid on an item
    // modifiers: ItemExists, IsForSale, IsForBid, HasTransferApproval
    // args: auctionItemId
    // check if a bid already exists, if yes: check if this bid value is higher then prev

    function PlaceABid(uint256 aucItemId, uint256 amount) external payable {
        ItemExists(aucItemId);
        require(activeItems[itemsForSale[aucItemId - 1].tokenAddress][itemsForSale[aucItemId-1].tokenId],'inactive');
        require(itemsForSale[aucItemId-1].isSold == false,"sold");
        require(itemsForSale[aucItemId-1].bidItem == true, "noBidA");

        if(itemsForSale[aucItemId-1].ERC20 == address(0)){
            require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "less val");
            _placeBidSimple(aucItemId);
        }else{
            _placeBidERC(aucItemId, amount);
        }
    }

    function _placeBidSimple(uint256 id) internal{
        uint256 totalPrice = 0;
        if (pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id] == 0){
            totalPrice = msg.value;
        }
        else{
            totalPrice = msg.value + pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id];
        }
        require(totalPrice > itemsForSale[id-1].askingPrice, "lessBid_AP");
        require(totalPrice > itemsForSale[id-1].bidPrice, "lessBid_BP");

        pendingReturns[msg.sender][address(0)][itemsForSale[id-1].id] = 0;
        if (itemsForSale[id - 1].bidPrice != 0){
            pendingReturns[itemsForSale[id-1].bidderAddress][address(0)][itemsForSale[id-1].id] = itemsForSale[id-1].bidPrice;
        }
        itemsForSale[id-1].bidPrice = totalPrice;
        itemsForSale[id-1].bidderAddress = msg.sender;

        emit BidPlaced(itemsForSale[id-1].tokenId,msg.sender,totalPrice,itemsForSale[id-1].tokenAddress);
    }

    function _placeBidERC(uint256 id, uint256 amount) internal{
        uint256 totalPrice = 0;
        IERC20Upgradeable tokenERC = IERC20Upgradeable(itemsForSale[id-1].ERC20);
        require(tokenERC.allowance(msg.sender,address(this)) >= amount , "allowance");

        if (pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] == 0){
            totalPrice = amount;
        }
        else{
            totalPrice = amount + pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id];
        }
        require(totalPrice > itemsForSale[id-1].askingPrice, "lessBid_AP");
        require(totalPrice > itemsForSale[id-1].bidPrice, "lessBid_BP");
        tokenERC.transferFrom(msg.sender,address(this),amount);
        pendingReturns[msg.sender][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] = 0;
        if (itemsForSale[id - 1].bidPrice != 0){
            pendingReturns[itemsForSale[id-1].bidderAddress][itemsForSale[id-1].ERC20][itemsForSale[id-1].id] = itemsForSale[id-1].bidPrice;
        }
        itemsForSale[id-1].bidPrice = totalPrice;
        itemsForSale[id-1].bidderAddress = msg.sender;
    }

    function withdrawPrevBid(uint256 aucItemId,address _erc20) external{
        uint256 amount = pendingReturns[msg.sender][_erc20][aucItemId];
        require(amount > 0, 'noPending');
        if (amount > 0){
            pendingReturns[msg.sender][_erc20][aucItemId] = 0;
            if(_erc20 == address(0)){
                if (!payable(msg.sender).send(amount)) {
                    // No need to call throw here, just reset the amount owing
                    pendingReturns[msg.sender][_erc20][aucItemId] = amount;
                    //return false;
                }
            }else{
                IERC20Upgradeable(_erc20).transfer(msg.sender, amount);
            }
        }
    }

    function EndAuction(uint256 aucItemId) external payable {
        ItemExists(aucItemId);
        require(activeItems[itemsForSale[aucItemId - 1].tokenAddress][itemsForSale[aucItemId-1].tokenId],'Item not listed in market');
        
        require(itemsForSale[aucItemId-1].isSold == false,"sold");
        require(itemsForSale[aucItemId-1].bidItem == true, "for buy");
        IERC721 Collection = IERC721(itemsForSale[aucItemId - 1].tokenAddress);
        require(Collection.ownerOf(itemsForSale[aucItemId - 1].tokenId) == msg.sender, "sellerS blnc");
        //just EndAuction
        if(itemsForSale[aucItemId-1].bidPrice == 0){
            _endAuctionOnly(aucItemId);
        }
        //End And Distribute bidPrice
        else if(itemsForSale[aucItemId-1].ERC20 == address(0)){
            //require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "Not enough funds set");
            _endAuctionSimple(aucItemId);
        }else{
            _endAuctionERC(aucItemId);
        }
    }

    function _endAuctionSimple(uint256 id) internal{
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);
        
        (bool success, ) = itemOwner.call{value: getRoyalties(itemsForSale[id - 1].bidPrice, Collection, itemsForSale[id - 1].tokenId, IERC20Upgradeable(address(0)))}("");
        require(success, "sndIssue V");
        
        Collection.safeTransferFrom(itemOwner, itemsForSale[id - 1].bidderAddress, itemsForSale[id - 1].tokenId);
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][itemsForSale[id - 1].tokenId] = 0;
        
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
    }

    function _endAuctionERC(uint256 id) internal{
        IERC20Upgradeable tokenERC = IERC20Upgradeable(itemsForSale[id-1].ERC20);
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);
        //uint256 val = itemsForSale[id - 1].bidPrice;
        
        tokenERC.transfer(itemOwner, getRoyalties(itemsForSale[id - 1].bidPrice,Collection,itemsForSale[id - 1].tokenId,tokenERC));
        
        Collection.safeTransferFrom(itemOwner, itemsForSale[id - 1].bidderAddress, itemsForSale[id - 1].tokenId);
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][itemsForSale[id-1].ERC20][itemsForSale[id - 1].tokenId] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
        itemsForSale[id - 1].ERC20 = address(0);
    }

    function _endAuctionOnly(uint256 id) internal{
        activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][itemsForSale[id - 1].ERC20][itemsForSale[id - 1].tokenId] = itemsForSale[id - 1].bidPrice;
        checkOrder[itemsForSale[id - 1].tokenId][itemsForSale[id - 1].tokenAddress][msg.sender] = false;
        itemsForSale[id - 1].askingPrice = 0;
        itemsForSale[id - 1].itype[1] = 0;
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
        itemsForSale[id - 1].ERC20 = address(0);
    }
}

contract TrustMarketPlace is Initializable, marketplace{
    
    function name() external pure returns(string memory){
        return "Trust Marketplace";
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "0A");
        emit OwnershipTransferred(marketplaceOwner, newOwner);
        marketplaceOwner = newOwner;
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner{
        require(newFeeAddress != address(0), "0A");
        feeAddress = newFeeAddress;
    }
    
    function changeServiceFee(uint256 newFee) external onlyOwner{
        require(newFee < 3000, "> 30%");
        serviceFee = newFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/TimersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract IGovernorUpgradeable is Initializable, IERC165Upgradeable {
    function __IGovernor_init() internal onlyInitializing {
        __IGovernor_init_unchained();
    }

    function __IGovernor_init_unchained() internal onlyInitializing {
    }
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /**
     * @dev Emitted when a proposal is created.
     */
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    /**
     * @dev Emitted when a proposal is canceled.
     */
    event ProposalCanceled(uint256 proposalId);

    /**
     * @dev Emitted when a proposal is executed.
     */
    event ProposalExecuted(uint256 proposalId);

    /**
     * @dev Emitted when a vote is cast.
     *
     * Note: `support` values should be seen as buckets. There interpretation depends on the voting module used.
     */
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    /**
     * @notice module:core
     * @dev Name of the governor instance (used in building the ERC712 domain separator).
     */
    function name() public view virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Version of the governor instance (used in building the ERC712 domain separator). Default: "1"
     */
    function version() public view virtual returns (string memory);

    /**
     * @notice module:voting
     * @dev A description of the possible `support` values for {castVote} and the way these votes are counted, meant to
     * be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of
     * key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.
     *
     * There are 2 standard keys: `support` and `quorum`.
     *
     * - `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
     * - `quorum=bravo` means that only For votes are counted towards quorum.
     * - `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.
     *
     * NOTE: The string can be decoded by the standard
     * https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams[`URLSearchParams`]
     * JavaScript class.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Hashing function used to (re)build the proposal id from the proposal details..
     */
    function hashProposal(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Current state of a proposal, following Compound's convention
     */
    function state(uint256 proposalId) public view virtual returns (ProposalState);

    /**
     * @notice module:core
     * @dev Block number used to retrieve user's votes and quorum. As per Compound's Comp and OpenZeppelin's
     * ERC20Votes, the snapshot is performed at the end of this block. Hence, voting for this proposal starts at the
     * beginning of the following block.
     */
    function proposalSnapshot(uint256 proposalId) public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Block number at which votes close. Votes close at the end of this block, so it is possible to cast a vote
     * during this block.
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in number of block, between the proposal is created and the vote starts. This can be increassed to
     * leave time for users to buy voting power, of delegate it, before the voting of a proposal starts.
     */
    function votingDelay() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in number of blocks, between the vote start and vote ends.
     *
     * NOTE: The {votingDelay} can delay the start of the vote. This must be considered when setting the voting
     * duration compared to the voting delay.
     */
    function votingPeriod() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Minimum number of cast voted required for a proposal to be successful.
     *
     * Note: The `blockNumber` parameter corresponds to the snaphot used for counting vote. This allows to scale the
     * quroum depending on values such as the totalSupply of a token at this block (see {ERC20Votes}).
     */
    function quorum(uint256 blockNumber) public view virtual returns (uint256);
    function votesQuorum() public view virtual returns (uint256);

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at a specific `blockNumber`.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     */
    function getVotes(address account, uint256 blockNumber) public view virtual returns (uint256);

    /**
     * @notice module:voting
     * @dev Returns weither `account` has cast a vote on `proposalId`.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool);

    /**
     * @dev Create a new proposal. Vote start {IGovernor-votingDelay} blocks after the proposal is created and ends
     * {IGovernor-votingPeriod} blocks after the voting starts.
     *
     * Emits a {ProposalCreated} event.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256 proposalId);

    /**
     * @dev Execute a successful proposal. This requires the quorum to be reached, the vote to be successful, and the
     * deadline to be reached.
     *
     * Emits a {ProposalExecuted} event.
     *
     * Note: some module can modify the requirements for execution, for example by adding an additional timelock.
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual returns (uint256 proposalId);

    /**
     * @dev Cast a vote
     *
     * Emits a {VoteCast} event.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual returns (uint256 balance);

    /**
     * @dev Cast a with a reason
     *
     * Emits a {VoteCast} event.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual returns (uint256 balance);

    /**
     * @dev Cast a vote using the user cryptographic signature.
     *
     * Emits a {VoteCast} event.
     */
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual returns (uint256 balance);
    uint256[50] private __gap;
}
abstract contract GovernorUpgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, EIP712Upgradeable, IGovernorUpgradeable {
    using SafeCastUpgradeable for uint256;
    using TimersUpgradeable for TimersUpgradeable.BlockNumber;

    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

    struct ProposalCore {
        TimersUpgradeable.BlockNumber voteStart;
        TimersUpgradeable.BlockNumber voteEnd;
        bool executed;
        bool canceled;
    }

    string private _name;

    mapping(uint256 => ProposalCore) private _proposals;

    /**
     * @dev Restrict access to governor executing address. Some module might override the _executor function to make
     * sure this modifier is consistant with the execution model.
     */
    modifier onlyGovernance() {
        require(_msgSender() == _executor(), "Governor: onlyGovernance");
        _;
    }

    /**
     * @dev Sets the value for {name} and {version}
     */
    function __Governor_init(string memory name_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __EIP712_init_unchained(name_, version());
        __IGovernor_init_unchained();
        __Governor_init_unchained(name_);
    }

    function __Governor_init_unchained(string memory name_) internal onlyInitializing {
        _name = name_;
    }

    /**
     * @dev Function to receive ETH that will be handled by the governor (disabled if executor is a third party contract)
     */
    receive() external payable virtual {
        require(_executor() == address(this));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IGovernorUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IGovernor-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IGovernor-version}.
     */
    function version() public view virtual override returns (string memory) {
        return "1";
    }

    /**
     * @dev See {IGovernor-hashProposal}.
     *
     * The proposal id is produced by hashing the RLC encoded `targets` array, the `values` array, the `calldatas` array
     * and the descriptionHash (bytes32 which itself is the keccak256 hash of the description string). This proposal id
     * can be produced from the proposal data which is part of the {ProposalCreated} event. It can even be computed in
     * advance, before the proposal is submitted.
     *
     * Note that the chainId and the governor address are not part of the proposal id computation. Consequently, the
     * same proposal (with same operation and same description) will have the same id if submitted on multiple governors
     * accross multiple networks. This also means that in order to execute the same operation twice (on the same
     * governor) the proposer will have to change the description in order to avoid proposal id conflicts.
     */
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual override returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    /**
     * @dev See {IGovernor-state}.
     */
    function state(uint256 proposalId) public view virtual override returns (ProposalState) {
        ProposalCore memory proposal = _proposals[proposalId];

        if (proposal.executed) {
            return ProposalState.Executed;
        } else if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.voteStart.getDeadline() >= block.number) {
            return ProposalState.Pending;
        } else if (proposal.voteEnd.getDeadline() >= block.number) {
            return ProposalState.Active;
        } else if (proposal.voteEnd.isExpired()) {
            return
                _quorumReached(proposalId) && _voteSucceeded(proposalId)
                    ? ProposalState.Succeeded
                    : ProposalState.Defeated;
        } else {
            revert("Governor: unknown proposal id");
        }
    }

    /**
     * @dev See {IGovernor-proposalSnapshot}.
     */
    function proposalSnapshot(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteStart.getDeadline();
    }

    /**
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteEnd.getDeadline();
    }

    /**
     * @dev Part of the Governor Bravo's interface: _"The number of votes required in order for a voter to become a proposer"_.
     */
    function proposalThreshold() public view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Amount of votes already cast passes the threshold limit.
     */
    function _quorumReached(uint256 proposalId) internal view virtual returns (bool);

    /**
     * @dev Is the proposal successful or not.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual returns (bool);

    /**
     * @dev Register a vote with a given support and voting weight.
     *
     * Note: Support is generic and can represent various things depending on the voting system used.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual;

    /**
     * @dev See {IGovernor-propose}.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual override returns (uint256) {
        require(
            getVotes(msg.sender, block.number - 1) >= proposalThreshold(),
            "GovernorCompatibilityBravo: proposer votes below proposal threshold"
        );

        uint256 proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        require(targets.length == values.length, "Governor: invalid proposal length");
        require(targets.length == calldatas.length, "Governor: invalid proposal length");
        require(targets.length > 0, "Governor: empty proposal");

        ProposalCore storage proposal = _proposals[proposalId];
        require(proposal.voteStart.isUnset(), "Governor: proposal already exists");

        uint64 snapshot = block.number.toUint64() + votingDelay().toUint64();
        uint64 deadline = snapshot + votingPeriod().toUint64();

        proposal.voteStart.setDeadline(snapshot);
        proposal.voteEnd.setDeadline(deadline);

        emit ProposalCreated(
            proposalId,
            _msgSender(),
            targets,
            values,
            new string[](targets.length),
            calldatas,
            snapshot,
            deadline,
            description
        );

        return proposalId;
    }

    /**
     * @dev See {IGovernor-execute}.
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual override returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);

        ProposalState status = state(proposalId);
        require(
            status == ProposalState.Succeeded || status == ProposalState.Queued,
            "Governor: proposal not successful"
        );
        _proposals[proposalId].executed = true;

        emit ProposalExecuted(proposalId);

        _execute(proposalId, targets, values, calldatas, descriptionHash);

        return proposalId;
    }

    /**
     * @dev Internal execution mechanism. Can be overriden to implement different execution mechanism
     */
    function _execute(
        uint256, /* proposalId */
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 /*descriptionHash*/
    ) internal virtual {
        string memory errorMessage = "Governor: call reverted without message";
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            AddressUpgradeable.verifyCallResult(success, returndata, errorMessage);
        }
    }

    /**
     * @dev Internal cancel mechanism: locks up the proposal timer, preventing it from being re-submitted. Marks it as
     * canceled to allow distinguishing it from executed proposals.
     *
     * Emits a {IGovernor-ProposalCanceled} event.
     */
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        ProposalState status = state(proposalId);

        require(
            status != ProposalState.Canceled && status != ProposalState.Expired && status != ProposalState.Executed,
            "Governor: proposal not active"
        );
        _proposals[proposalId].canceled = true;

        emit ProposalCanceled(proposalId);

        return proposalId;
    }

    /**
     * @dev See {IGovernor-castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual override returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev See {IGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual override returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, reason);
    }

    /**
     * @dev See {IGovernor-castVoteBySig}.
     */
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override returns (uint256) {
        address voter = ECDSAUpgradeable.recover(
            _hashTypedDataV4(keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support))),
            v,
            r,
            s
        );
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev Internal vote casting mechanism: Check that the vote is pending, that it has not been cast yet, retrieve
     * voting weight using {IGovernor-getVotes} and call the {_countVote} internal function.
     *
     * Emits a {IGovernor-VoteCast} event.
     */
    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason
    ) internal virtual returns (uint256) {
        ProposalCore storage proposal = _proposals[proposalId];
        require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        uint256 weight = getVotes(account, proposal.voteStart.getDeadline());
        _countVote(proposalId, account, support, weight);

        emit VoteCast(account, proposalId, support, weight, reason);

        return weight;
    }

    /**
     * @dev Address through which the governor executes action. Will be overloaded by module that execute actions
     * through another contract such as a timelock.
     */
    function _executor() internal view virtual returns (address) {
        return address(this);
    }
    uint256[48] private __gap;
}
abstract contract GovernorSettingsUpgradeable is Initializable, GovernorUpgradeable {
    uint256 private _votingDelay;
    uint256 private _votingPeriod;
    uint256 private _proposalThreshold;

    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);
    event ProposalThresholdSet(uint256 oldProposalThreshold, uint256 newProposalThreshold);

    /**
     * @dev Initialize the governance parameters.
     */
    function __GovernorSettings_init(
        uint256 initialVotingDelay,
        uint256 initialVotingPeriod,
        uint256 initialProposalThreshold
    ) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __IGovernor_init_unchained();
        __GovernorSettings_init_unchained(initialVotingDelay, initialVotingPeriod, initialProposalThreshold);
    }

    function __GovernorSettings_init_unchained(
        uint256 initialVotingDelay,
        uint256 initialVotingPeriod,
        uint256 initialProposalThreshold
    ) internal onlyInitializing {
        _setVotingDelay(initialVotingDelay);
        _setVotingPeriod(initialVotingPeriod);
        _setProposalThreshold(initialProposalThreshold);
    }

    /**
     * @dev See {IGovernor-votingDelay}.
     */
    function votingDelay() public view virtual override returns (uint256) {
        return _votingDelay;
    }

    /**
     * @dev See {IGovernor-votingPeriod}.
     */
    function votingPeriod() public view virtual override returns (uint256) {
        return _votingPeriod;
    }

    /**
     * @dev See {Governor-proposalThreshold}.
     */
    function proposalThreshold() public view virtual override returns (uint256) {
        return _proposalThreshold;
    }

    /**
     * @dev Update the voting delay. This operation can only be performed through a governance proposal.
     *
     * Emits a {VotingDelaySet} event.
     */
    function setVotingDelay(uint256 newVotingDelay) public virtual onlyGovernance {
        _setVotingDelay(newVotingDelay);
    }

    /**
     * @dev Update the voting period. This operation can only be performed through a governance proposal.
     *
     * Emits a {VotingPeriodSet} event.
     */
    function setVotingPeriod(uint256 newVotingPeriod) public virtual onlyGovernance {
        _setVotingPeriod(newVotingPeriod);
    }

    /**
     * @dev Update the proposal threshold. This operation can only be performed through a governance proposal.
     *
     * Emits a {ProposalThresholdSet} event.
     */
    function setProposalThreshold(uint256 newProposalThreshold) public virtual onlyGovernance {
        _setProposalThreshold(newProposalThreshold);
    }

    /**
     * @dev Internal setter for the voting delay.
     *
     * Emits a {VotingDelaySet} event.
     */
    function _setVotingDelay(uint256 newVotingDelay) internal virtual {
        emit VotingDelaySet(_votingDelay, newVotingDelay);
        _votingDelay = newVotingDelay;
    }

    /**
     * @dev Internal setter for the voting period.
     *
     * Emits a {VotingPeriodSet} event.
     */
    function _setVotingPeriod(uint256 newVotingPeriod) internal virtual {
        // voting period must be at least one block long
        require(newVotingPeriod > 0, "GovernorSettings: voting period too low");
        emit VotingPeriodSet(_votingPeriod, newVotingPeriod);
        _votingPeriod = newVotingPeriod;
    }

    /**
     * @dev Internal setter for the proposal threshold.
     *
     * Emits a {ProposalThresholdSet} event.
     */
    function _setProposalThreshold(uint256 newProposalThreshold) internal virtual {
        emit ProposalThresholdSet(_proposalThreshold, newProposalThreshold);
        _proposalThreshold = newProposalThreshold;
    }
    uint256[47] private __gap;
}
abstract contract GovernorCountingSimpleUpgradeable is Initializable, GovernorUpgradeable {
    function __GovernorCountingSimple_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __IGovernor_init_unchained();
        __GovernorCountingSimple_init_unchained();
    }

    function __GovernorCountingSimple_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;

    /**
     * @dev See {IGovernor-COUNTING_MODE}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    /**
     * @dev See {IGovernor-hasVoted}.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId)
        public
        view
        virtual
        returns (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        )
    {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];
        return (proposalvote.againstVotes, proposalvote.forVotes, proposalvote.abstainVotes);
    }

    /**
     * @dev See {Governor-_quorumReached}.
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];

        return quorum(proposalSnapshot(proposalId)) <= proposalvote.forVotes + proposalvote.abstainVotes;
    }

    /**
     * @dev See {Governor-_voteSucceeded}. In this module, the forVotes must be strictly over the againstVotes.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];
        uint256 total = proposalvote.forVotes+proposalvote.againstVotes+proposalvote.abstainVotes;
        if(total < 101){
            return false;
        }
        return proposalvote.forVotes >= (total/100)*votesQuorum();
        //return proposalvote.forVotes > proposalvote.againstVotes;
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual override {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];

        require(!proposalvote.hasVoted[account], "GovernorVotingSimple: vote already cast");
        proposalvote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalvote.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposalvote.forVotes += weight;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalvote.abstainVotes += weight;
        } else {
            revert("GovernorVotingSimple: invalid value for enum VoteType");
        }
    }
    uint256[49] private __gap;
}
abstract contract GovernorVotesUpgradeable is Initializable, GovernorUpgradeable {
    ERC20VotesUpgradeable public token;

    function __GovernorVotes_init(ERC20VotesUpgradeable tokenAddress) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __IGovernor_init_unchained();
        __GovernorVotes_init_unchained(tokenAddress);
    }

    function __GovernorVotes_init_unchained(ERC20VotesUpgradeable tokenAddress) internal onlyInitializing {
        token = tokenAddress;
    }

    /**
     * Read the voting weight from the token's built in snapshot mechanism (see {IGovernor-getVotes}).
     */
    function getVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {
        return token.getPastVotes(account, blockNumber);
    }
    uint256[50] private __gap;
}
abstract contract GovernorVotesQuorumFractionUpgradeable is Initializable, GovernorVotesUpgradeable {
    uint256 private _quorumNumerator;
    uint256 private _votesQuorum;

    event QuorumNumeratorUpdated(uint256 oldQuorumNumerator, uint256 newQuorumNumerator);

    function __GovernorVotesQuorumFraction_init(uint256 quorumNumeratorValue,uint256 votesPercentage) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __IGovernor_init_unchained();
        __GovernorVotesQuorumFraction_init_unchained(quorumNumeratorValue,votesPercentage);
    }

    function __GovernorVotesQuorumFraction_init_unchained(uint256 quorumNumeratorValue, uint256 votesQ) internal onlyInitializing {
        _updateQuorumNumerator(quorumNumeratorValue);
        _updateVotesQuorum(votesQ);
    }

    function quorumNumerator() public view virtual returns (uint256) {
        return _quorumNumerator;
    }

    function quorumDenominator() public view virtual returns (uint256) {
        return 100;
    }

    function votesQuorum() public view virtual override returns (uint256) {
        return _votesQuorum;
    }

    function quorum(uint256 blockNumber) public view virtual override returns (uint256) {
        return (token.getPastTotalSupply(blockNumber) * quorumNumerator()) / quorumDenominator();
    }

    function updateQuorumNumerator(uint256 newQuorumNumerator) external virtual onlyGovernance {
        _updateQuorumNumerator(newQuorumNumerator);
    }

    function updateVotesQuorum(uint256 votesQ) external virtual onlyGovernance {
        _updateVotesQuorum(votesQ);
    }

    function _updateQuorumNumerator(uint256 newQuorumNumerator) internal virtual {
        require(
            newQuorumNumerator <= quorumDenominator(),
            "GovernorVotesQuorumFraction: quorumNumerator over quorumDenominator"
        );

        uint256 oldQuorumNumerator = _quorumNumerator;
        _quorumNumerator = newQuorumNumerator;

        emit QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator);
    }

    function _updateVotesQuorum(uint256 votesQ) internal virtual {
        require(
            votesQ < 95,
            "GovernorVotesQuorumFraction: cast voted percentage must be less than 95%"
        );
        _votesQuorum = votesQ;
    }
    uint256[49] private __gap;
}

contract TrustGovernorV1 is Initializable, GovernorUpgradeable, GovernorSettingsUpgradeable, GovernorCountingSimpleUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    mapping(uint256 => bool) public isExecuted;
    function initialize(ERC20VotesUpgradeable _token) initializer public {
        __Governor_init("Trust Governor");
        __GovernorSettings_init(1 /* 1 block */, 180000 /* 1 week */, 1e18);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(_token);
        __GovernorVotesQuorumFraction_init(50,80);
    }

    function approveProposal(uint256 _id) public onlyGovernance{
        isExecuted[_id] = true;
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function votesQuorum()
        public
        view
        override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.votesQuorum();
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(IGovernorUpgradeable, GovernorVotesUpgradeable)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(GovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Votes.sol)

pragma solidity ^0.8.0;

import "./draft-ERC20PermitUpgradeable.sol";
import "../../../utils/math/MathUpgradeable.sol";
import "../../../utils/math/SafeCastUpgradeable.sol";
import "../../../utils/cryptography/ECDSAUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC20 to support Compound-like voting and delegation. This version is more generic than Compound's,
 * and supports token supply up to 2^224^ - 1, while COMP is limited to 2^96^ - 1.
 *
 * NOTE: If exact COMP compatibility is required, use the {ERC20VotesComp} variant of this module.
 *
 * This extension keeps a history (checkpoints) of each account's vote power. Vote power can be delegated either
 * by calling the {delegate} function directly, or by providing a signature to be used with {delegateBySig}. Voting
 * power can be queried through the public accessors {getVotes} and {getPastVotes}.
 *
 * By default, token balance does not account for voting power. This makes transfers cheaper. The downside is that it
 * requires users to delegate to themselves in order to activate checkpoints and have their voting power tracked.
 * Enabling self-delegation can easily be done by overriding the {delegates} function. Keep in mind however that this
 * will significantly increase the base gas cost of transfers.
 *
 * _Available since v4.2._
 */
abstract contract ERC20VotesUpgradeable is Initializable, ERC20PermitUpgradeable {
    function __ERC20Votes_init_unchained() internal onlyInitializing {
    }
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegates;
    mapping(address => Checkpoint[]) private _checkpoints;
    Checkpoint[] private _totalSupplyCheckpoints;

    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to an account's voting power.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return SafeCastUpgradeable.toUint32(_checkpoints[account].length);
    }

    /**
     * @dev Get the address `account` is currently delegating to.
     */
    function delegates(address account) public view virtual returns (address) {
        return _delegates[account];
    }

    /**
     * @dev Gets the current votes balance for `account`
     */
    function getVotes(address account) public view returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }

    /**
     * @dev Retrieve the number of votes for `account` at the end of `blockNumber`.
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastVotes(address account, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }

    /**
     * @dev Retrieve the `totalSupply` at the end of `blockNumber`. Note, this value is the sum of all balances.
     * It is but NOT the sum of all the delegated votes!
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastTotalSupply(uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    /**
     * @dev Lookup a value in a list of (sorted) checkpoints.
     */
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `blockNumber`.
        //
        // During the loop, the index of the wanted checkpoint remains in the range [low-1, high).
        // With each iteration, either `low` or `high` is moved towards the middle of the range to maintain the invariant.
        // - If the middle checkpoint is after `blockNumber`, we look in [low, mid)
        // - If the middle checkpoint is before or equal to `blockNumber`, we look in [mid+1, high)
        // Once we reach a single value (when low == high), we've found the right checkpoint at the index high-1, if not
        // out of bounds (in which case we're looking too far in the past and the result is 0).
        // Note that if the latest checkpoint available is exactly for `blockNumber`, we end up with an index that is
        // past the end of the array, so we technically don't find a checkpoint after `blockNumber`, but it works out
        // the same.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].votes;
    }

    /**
     * @dev Delegate votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual {
        _delegate(_msgSender(), delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= expiry, "ERC20Votes: signature expired");
        address signer = ECDSAUpgradeable.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "ERC20Votes: invalid nonce");
        _delegate(signer, delegatee);
    }

    /**
     * @dev Maximum token supply. Defaults to `type(uint224).max` (2^224^ - 1).
     */
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }

    /**
     * @dev Snapshots the totalSupply after it has been increased.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        require(totalSupply() <= _maxSupply(), "ERC20Votes: total supply risks overflowing votes");

        _writeCheckpoint(_totalSupplyCheckpoints, _add, amount);
    }

    /**
     * @dev Snapshots the totalSupply after it has been decreased.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);

        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, amount);
    }

    /**
     * @dev Move voting power when tokens are transferred.
     *
     * Emits a {DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        _moveVotingPower(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Change delegation for `delegator` to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) private {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[src], _subtract, amount);
                emit DelegateVotesChanged(src, oldWeight, newWeight);
            }

            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[dst], _add, amount);
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = SafeCastUpgradeable.toUint224(newWeight);
        } else {
            ckpts.push(Checkpoint({fromBlock: SafeCastUpgradeable.toUint32(block.number), votes: SafeCastUpgradeable.toUint224(newWeight)}));
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Timers.sol)

pragma solidity ^0.8.0;

/**
 * @dev Tooling for timepoints, timers and delays
 */
library TimersUpgradeable {
    struct Timestamp {
        uint64 _deadline;
    }

    function getDeadline(Timestamp memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(Timestamp storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(Timestamp storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(Timestamp memory timer) internal view returns (bool) {
        return timer._deadline > block.timestamp;
    }

    function isExpired(Timestamp memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.timestamp;
    }

    struct BlockNumber {
        uint64 _deadline;
    }

    function getDeadline(BlockNumber memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(BlockNumber storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(BlockNumber storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline > block.number;
    }

    function isExpired(BlockNumber memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.number;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20PermitUpgradeable.sol";
import "../ERC20Upgradeable.sol";
import "../../../utils/cryptography/draft-EIP712Upgradeable.sol";
import "../../../utils/cryptography/ECDSAUpgradeable.sol";
import "../../../utils/CountersUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal onlyInitializing {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
    uint256[45] private __gap;
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
library CountersUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/**
 * @dev Interface of the BEP165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({BEP165Checker}).
 *
 * For an implementation, see {BEP165}.
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

/**
 * @dev Required interface of an BEP721 compliant contract.
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

/**
 * @title BEP721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from BEP721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title BEP-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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


/**
 * @dev Implementation of the {IBEP165} interface.
 *
 * Contracts that want to implement BEP165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {BEP165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) _operatorApprovals;

    mapping(uint256 => mapping(address => bool)) public checker;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IBEP165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IBEP721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "BEP721: balance query for the zero address"
        );
        return _balances[owner];
    }

    /**
     * @dev See {IBEP721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "BEP721: owner query for nonexistent token"
        );
        return owner;
    }

    /**
     * @dev See {IBEP721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IBEP721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IBEP721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "BEP721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IBEP721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "BEP721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "BEP721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IBEP721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "BEP721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IBEP721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "BEP721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }


    /**
     * @dev See {IBEP721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IBEP721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        // require(
        //     _isApprovedOrOwner(_msgSender(), tokenId),
        //     "BEP721: transfer caller is not owner nor approved"
        // );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IBEP721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IBEP721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            msg.sender == from || isApprovedForAll(from,msg.sender),
            "Not a Owner"
        );
        _safeTransfer(from, to, tokenId, _data);
        if (msg.sender != from) {
            checker[tokenId][from] = false;
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the BEP721 protocol to prevent tokens from being forever locked.
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
     * - If `to` refers to a smart contract, it must implement {IBEP721Receiver-onBEP721Received}, which is called upon a safe transfer.
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
        require(
            _checkOnBEP721Received(from, to, tokenId, _data),
            "BEP721: transfer to non BEP721Receiver implementer"
        );
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
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "BEP721: operator query for nonexistent token"
        );
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IBEP721Receiver-onBEP721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-BEP721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IBEP721Receiver-onBEP721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnBEP721Received(address(0), to, tokenId, _data),
            "BEP721: transfer to non BEP721Receiver implementer"
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
        require(to != address(0), "BEP721: mint to the zero address");
        require(!_exists(tokenId), "BEP721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
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
        require(
            ERC721Upgradeable.ownerOf(tokenId) == from,
            "BEP721: transfer of token that is not own"
        );
        require(to != address(0), "BEP721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IBEP721Receiver-onBEP721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnBEP721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721ReceiverUpgradeable(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "BEP721: transfer to non BEP721Receiver implementer"
                    );
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
}
/**
 * @title BEP-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev This implements an optional extension of {BEP721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
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
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721Upgradeable.balanceOf(to);
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

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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
    uint256[46] private __gap;
}

/**
 * @dev BEP721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    struct Metadata {
        string name;
        string ipfsimage;
        string ipfsmetadata;
    }
    mapping(uint256 => Metadata) token_id;
    
    function __ERC721URIStorage_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal initializer {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
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

/**
 * @title BEP721 Burnable Token
 * @dev BEP721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}

interface IERC20Upgradeable {
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

contract Trust721V2 is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable
{
    using SafeMathUpgradeable for uint256;
    event Approve(
        address indexed owner,
        bool approved
    );

    event OrderPlace(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );

    event CancelOrder(address indexed from, uint256 indexed tokenId);
    event ChangePrice(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );
    
    struct Order {
        uint256 tokenId;
        uint256 price;
    }
    mapping(address => mapping(uint256 => Order)) public order_place;

    struct royalstr {
        address uaddress;
        uint256 pecentr;
    }

    mapping(uint256 => mapping(string => royalstr)) public _royal;

    mapping(uint256 => mapping(address => bool)) public checkOrder;
    mapping(uint256 => uint256) public totalQuantity;
    mapping(uint256 => address) public _creator;

    uint256 private serviceValue;
    address public serviceFeeAddress;
    string private _currentBaseURI;
    uint256 private tokenCreator;
    mapping(uint256 => string) tokenURIs;
    address marketPlaceAddress;

    function initialize(uint256 _serviceValue, address _serviceFeeAddress, address _market, string memory _name, string memory _symbol) public initializer  {
        ERC721Upgradeable.__ERC721_init(_name, _symbol);
        __Ownable_init();
        serviceValue = _serviceValue;
        serviceFeeAddress = _serviceFeeAddress;
        marketPlaceAddress = _market;
    }



    function getServiceFee() public view returns (uint256) {
        return serviceValue;
    }

    function serviceFunction(uint256 _serviceValue) public onlyOwner {
        serviceValue = _serviceValue;
    }

    function marketFunction(address _marketAddress) public onlyOwner {
        marketPlaceAddress = _marketAddress;
    }


    function setApproval(address operator, bool approved)
        public
    {
        setApprovalForAll(operator, approved);
    }

    function safeMint(address to) public onlyOwner {
        tokenCreator++;
        _safeMint(to, tokenCreator);
    }

    function setApprovalForAllFromMarket(address origin, address operator, bool approved)
        public
        virtual
    {
        require(operator == marketPlaceAddress, "BEP721: approve to caller");

        _operatorApprovals[origin][operator] = approved;
        emit ApprovalForAll(origin, operator, approved);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _currentBaseURI = baseURI;
    }

    function setTokenCreator(uint256 tokenCreator_) public onlyOwner {
        tokenCreator = tokenCreator_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mint(
        string memory tokenURI_,
        address[] memory royaddress,
        uint256[] memory royPer
    ) public returns(uint256){
        if(!isApprovedForAll(msg.sender,marketPlaceAddress)){
            setApprovalForAll(marketPlaceAddress, true);
        }
        tokenCreator++;
        tokenURIs[tokenCreator] = tokenURI_;
        _creator[tokenCreator] = msg.sender;
        _safeMint(msg.sender, tokenCreator);
        _royal[tokenCreator]["artist"].uaddress = royaddress[0];
        _royal[tokenCreator]["agent"].uaddress = royaddress[1];
        _royal[tokenCreator]["artist"].pecentr = royPer[0];
        _royal[tokenCreator]["agent"].pecentr = royPer[1];
        return tokenCreator;
    }

    function orderPlace(uint256 tokenId, uint256 _price) public {
        _orderPlace(msg.sender, tokenId, _price);
    }

    function _orderPlace(
        address from,
        uint256 tokenId,
        uint256 _price
    ) internal {
        require(ownerOf(tokenId) == from, "Is Not a Owner");
        Order memory order;
        order.tokenId = tokenId;
        order.price = _price;
        order_place[from][tokenId] = order;
        checkOrder[tokenId][from] = true;
        emit OrderPlace(from, tokenId, _price);
    }

    function get(uint256 tokenId)
        external
        view
        returns (string memory name, string memory ipfsimage)
    {
        require(_exists(tokenId), "token not minted");
        ipfsimage = tokenURIs[tokenId];
        name = "NFT";
    }

    function calc(
        uint256 amount,
        uint256 artist,
        uint256 agent
    )
        internal
        view
        returns (
            uint256[4] memory
        )
    {
        uint256 fee = serviceValue!=0?pBEPent(amount, serviceValue):0;
        uint256 artist_ = (artist !=0) ? pBEPent(amount, artist) : 0;
        uint256 agent_ = (agent !=0) ? pBEPent(amount, agent):0;
        uint256 netamount = amount.sub(fee).sub(artist_).sub(agent_);
        return [fee, artist_, agent_, netamount];
    }

    function pBEPent(uint256 value1, uint256 value2)
        public
        pure
        returns (uint256)
    {
        uint256 result = value1.mul(value2).div(10**4);
        return (result);
    }

    function saleToken(
        address payable from,
        uint256 tokenId
    ) public payable {
        require(checkOrder[tokenId][from],"Not available for buying");
        checker[tokenId][from] = true;
        _saleToken(from, tokenId);
        saleTokenTransfer(from, tokenId);
    }

    function _saleToken(
        address payable from,
        uint256 tokenId
    ) internal {
        require(msg.value == order_place[from][tokenId].price, "Insufficient Balance");
        
        address payable admin = payable(serviceFeeAddress);
        address payable create = payable(_royal[tokenId]["agent"].uaddress);
        address payable create2 = payable(_royal[tokenId]["artist"].uaddress);

        uint256[4] memory calcs= calc(
                order_place[from][tokenId].price,
                _royal[tokenId]["agent"].pecentr,
                _royal[tokenId]["artist"].pecentr
            );
        admin.transfer(calcs[0]);
        create.transfer(calcs[1]);
        create2.transfer(calcs[2]);
        from.transfer(calcs[3]);
    }

    function saleTokenTransfer(address payable from, uint256 tokenId) internal {
        if (checkOrder[tokenId][from] == true) {
            delete order_place[from][tokenId];
            checkOrder[tokenId][from] = false;
        }
        tokenTrans(tokenId, from, msg.sender);
    }

    function tokenTrans(
        uint256 tokenId,
        address from,
        address to
    ) internal {
        safeTransferFrom(from, to, tokenId);
    }

    function tokenOwners(uint256[] memory tokenIDs) external view returns(address[] memory){
        address[] memory owns = new address[](tokenIDs.length );
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            owns[i] = _owners[tokenIDs[i]];
        }
        return owns;
    }

    function cancelOrder(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Is Not a Owner");
        delete order_place[msg.sender][tokenId];
        checkOrder[tokenId][msg.sender] = false;
        emit CancelOrder(msg.sender, tokenId);
    }

    function changePrice(uint256 value, uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Is Not a Owner");
        require(value > 0, "Price Must Be Greater Than 0");
        order_place[msg.sender][tokenId].price = value;
        emit ChangePrice(msg.sender, tokenId, value);
    }

    function burnToken(uint256 id, address from) public {
        require(
            ownerOf(id) == from,
            "Your Not a Token Owner or insufficient Token Balance"
        );
        if (ownerOf(id) == from) {
            if (checkOrder[id][from] == true) {
                delete order_place[from][id];
                checkOrder[id][from] = false;
            }
        }
        burn(id);
        //balances[id][msg.sender] -=1;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";


abstract contract ERC20VotesUpgradeable is Initializable, ERC20PermitUpgradeable {
    function __ERC20Votes_init_unchained() internal initializer {
    }
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegates;
    mapping(address => Checkpoint[]) private _checkpoints;
    Checkpoint[] private _totalSupplyCheckpoints;

    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to an account's voting power.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return SafeCastUpgradeable.toUint32(_checkpoints[account].length);
    }

    /**
     * @dev Get the address `account` is currently delegating to.
     */
    function delegates(address account) public view virtual returns (address) {
        return _delegates[account];
    }

    /**
     * @dev Gets the current votes balance for `account`
     */
    function getVotes(address account) public view returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }

    /**
     * @dev Retrieve the number of votes for `account` at the end of `blockNumber`.
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastVotes(address account, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }

    /**
     * @dev Retrieve the `totalSupply` at the end of `blockNumber`. Note, this value is the sum of all balances.
     * It is but NOT the sum of all the delegated votes!
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastTotalSupply(uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    /**
     * @dev Lookup a value in a list of (sorted) checkpoints.
     */
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `blockNumber`.
        //
        // During the loop, the index of the wanted checkpoint remains in the range [low-1, high).
        // With each iteration, either `low` or `high` is moved towards the middle of the range to maintain the invariant.
        // - If the middle checkpoint is after `blockNumber`, we look in [low, mid)
        // - If the middle checkpoint is before or equal to `blockNumber`, we look in [mid+1, high)
        // Once we reach a single value (when low == high), we've found the right checkpoint at the index high-1, if not
        // out of bounds (in which case we're looking too far in the past and the result is 0).
        // Note that if the latest checkpoint available is exactly for `blockNumber`, we end up with an index that is
        // past the end of the array, so we technically don't find a checkpoint after `blockNumber`, but it works out
        // the same.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].votes;
    }

    /**
     * @dev Delegate votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual {
        _delegate(_msgSender(), delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= expiry, "ERC20Votes: signature expired");
        address signer = ECDSAUpgradeable.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "ERC20Votes: invalid nonce");
        _delegate(signer, delegatee);
    }

    /**
     * @dev Maximum token supply. Defaults to `type(uint224).max` (2^224^ - 1).
     */
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }

    /**
     * @dev Snapshots the totalSupply after it has been increased.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        require(totalSupply() <= _maxSupply(), "ERC20Votes: total supply risks overflowing votes");

        _writeCheckpoint(_totalSupplyCheckpoints, _add, amount);
    }

    /**
     * @dev Snapshots the totalSupply after it has been decreased.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);

        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, amount);
    }

    /**
     * @dev Move voting power when tokens are transferred.
     *
     * Emits a {DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        _moveVotingPower(from, to, amount);
    }

    /**
     * @dev Change delegation for `delegator` to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) private {
        if(getVotes(src) >= amount){
            if (src != dst && amount > 0) {
                if (src != address(0)) {
                    if(getVotes(src) >= amount){
                        (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[src], _subtract, amount);
                        emit DelegateVotesChanged(src, oldWeight, newWeight);
                    }
                }

                if (dst != address(0)) {
                    (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[dst], _add, amount);
                    emit DelegateVotesChanged(dst, oldWeight, newWeight);
                }
            }
        }else{
            if (src != address(0)) {
                if(getVotes(src) >= amount){
                    (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[src], _subtract, amount);
                    emit DelegateVotesChanged(src, oldWeight, newWeight);
                }
            }

            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[dst], _add, amount);
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = SafeCastUpgradeable.toUint224(newWeight);
        } else {
            ckpts.push(Checkpoint({fromBlock: SafeCastUpgradeable.toUint32(block.number), votes: SafeCastUpgradeable.toUint224(newWeight)}));
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
    uint256[47] private __gap;
}
contract TrustDAO is Initializable, ERC20Upgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable {
    
    mapping(address => bool) public owners;

    modifier onlyOwners{
        require(owners[msg.sender],'Not an owner address');
        _;
    }

    function initialize(address _stakingContract) initializer public {
        __ERC20_init("TrustDao Voting", "TDV");
        __Ownable_init();
        __ERC20Permit_init("TrustDao Voting");
        owners[msg.sender] = true;
        owners[_stakingContract] = true;
    }

    function mint(address to, uint256 amount) external onlyOwners returns (bool){
        _mint(to, amount);
        return true;
    }

    function addOwner(address own_) external onlyOwners {
        owners[own_] = true;
    }

    function removeOwner(address own_) external onlyOwners {
        owners[own_] = false;
    }

    function transfer(address recipient, uint256 amount) public override(ERC20Upgradeable) returns (bool) {
        require(owners[msg.sender] || owners[recipient], "only contract can move voting rights");
        super.transfer(recipient,amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20Upgradeable) returns (bool) {
        require(owners[msg.sender] || owners[recipient], "only contract can move voting rights");
        super.transferFrom(sender,recipient,amount);
        return true;
    }

    function burn(uint256 amount) external onlyOwners returns (bool){
        require(balanceOf(msg.sender) >= amount,'Insufficient Tokens');
        _burn(msg.sender, amount);
        return true;
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
        _approve(to, msg.sender, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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

/**
 * @dev Implementation of the {IBEP165} interface.
 *
 * Contracts that want to implement BEP165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {BEP165Storage} provides an easier to use but more expensive implementation.
 */
 abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

/**
 * @dev Required interface of an BEP1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev Interface of the optional BEP1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}


contract ERC1155Upgradeable  is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    struct Metadata {
        string name;
        string ipfsimage;
        string ipfsmetadata;
    }

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) public _balances;

    mapping(uint256 => string) token_id;
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) public _operatorApprovals;
    mapping(uint256 => address) public _creator;
    mapping(uint256 => mapping(address => bool)) public checker;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    // constructor(
    //     string memory uri_,
    //     string memory name_,
    //     string memory symbol_
    // ) {
    //     _setURI(uri_);
    //     _name = name_;
    //     _symbol = symbol_;
    // }
    
    function __ERC1155_init(string memory uri_, string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_, name_, symbol_);
    }

    function __ERC1155_init_unchained(string memory uri_, string memory name_, string memory symbol_) internal initializer {
        _setURI(uri_);
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IBEP721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IBEP721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IBEP165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IBEP1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory ipfsmetadata)
    {
        // return _uri;
        string memory uri_ = token_id[tokenId];
        return string(abi.encodePacked("https://ipfs.io/ipfs/",uri_));
    }

    /**
     * @dev See {IBEP1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "BEP1155: balance query for the zero address"
        );
        return _balances[id][account];
    }

    /**
     * @dev See {IBEP1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "BEP1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IBEP1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _msgSender() != operator,
            "BEP1155: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IBEP1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IBEP1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from,msg.sender),
            "BEP1155: caller is not owner"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IBEP1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, address(this)),
            "BEP1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IBEP1155Receiver-onBEP1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "BEP1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        uint256 fromBalance = _balances[id][from];
        require(
            fromBalance >= amount,
            "BEP1155: insufficient balance for transfer"
        );
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:BEP1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IBEP1155Receiver-onBEP1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "BEP1155: ids and amounts length mismatch"
        );
        require(to != address(0), "BEP1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "BEP1155: insufficient balance for transfer"
            );
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IBEP1155Receiver-onBEP1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "BEP1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            account,
            id,
            amount,
            data
        );
    }

    /**
     * @dev xref:ROOT:BEP1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IBEP1155Receiver-onBEP1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "BEP1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "BEP1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }
        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "BEP1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        uint256 accountBalance = _balances[id][account];
        require(
            accountBalance >= amount,
            "BEP1155: burn amount exceeds balance"
        );
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:BEP1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "BEP1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "BEP1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(
                accountBalance >= amount,
                "BEP1155: burn amount exceeds balance"
            );
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("BEP1155: BEP1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("BEP1155: transfer to non BEP1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector
                ) {
                    revert("BEP1155: BEP1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("BEP1155: transfer to non BEP1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


/**
 * @dev Extension of {BEP1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155BurnableUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155Burnable_init_unchained();
    }

    function __ERC1155Burnable_init_unchained() internal initializer {
    }
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
    uint256[50] private __gap;
}

interface IERC20Upgradeable {
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

contract TrustMultiV1 is Initializable,ERC1155Upgradeable, OwnableUpgradeable, ERC1155BurnableUpgradeable {
    event Approve(
        address indexed owner,
        bool approved
    );
    event OrderPlace(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );
    event CancelOrder(address indexed from, uint256 indexed tokenId);
    event ChangePrice(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );

    event Mint(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed numOfTokens
    );

    

    using SafeMathUpgradeable for uint256;

    struct Order {
        uint256 tokenId;
        uint256 price;
        uint256 noOfTokens;
    }

    mapping(address => mapping(uint256 => Order)) public order_place;
    mapping(uint256 => mapping(address => bool)) public checkOrder;
    mapping(uint256 => uint256) public totalQuantity;

    struct royalstr {
        address uaddress;
        uint256 pecentr;
    }

    mapping(uint256 => mapping(string => royalstr)) public _royal;
    uint256 private serviceValue;

    string private _currentBaseURI;
    uint256 public tokenCreator;
    address public serviceFeeAddress;
    mapping(uint256 => uint256) public tokenQuantity;
    address marketPlaceAddress;
    
    
    function initialize(uint256 _serviceValue, address _serviceFeeAddress, address _marketAddress, string memory _name, string memory _symbol) public initializer  {
        ERC1155Upgradeable.__ERC1155_init("", _name, _symbol);
        __Ownable_init();
        serviceValue = _serviceValue;
        serviceFeeAddress = _serviceFeeAddress;
        marketPlaceAddress = _marketAddress;
    }

    function getServiceFee() public view returns (uint256) {
        return serviceValue;
    }

    function serviceFunction(uint256 _serviceValue) public onlyOwner {
        serviceValue = _serviceValue;
    }

    function marketFunction(address _marketAddress) public onlyOwner {
        marketPlaceAddress = _marketAddress;
    }

    function setServiceAddress(address _serviceFeeAddress) public onlyOwner {
        serviceFeeAddress = _serviceFeeAddress;
    }

    function setApproval(address operator, bool approved)
        public
    {
        setApprovalForAll(operator, approved);
        emit Approve(operator , approved);
    }

    function setApprovalForAllFromMarket(address origin, address operator, bool approved)
        public
        virtual
    {
        require(operator == marketPlaceAddress, "BEP721: approve to caller");

        _operatorApprovals[origin][operator] = approved;
        emit ApprovalForAll(origin, operator, approved);
    }

    function mint(
        address[] memory royaddress,
        uint256[] memory royPer,
        uint256 nooftoken,
        string memory ipfsHash
    ) public returns(uint256) {
        require(
            royaddress.length == 2 && royPer.length == 2,
            "Invalid royalty list"
        );
        if(!isApprovedForAll(msg.sender,address(this))){
            setApprovalForAll(marketPlaceAddress,true);
        }
        tokenCreator++;
        _mint(msg.sender, tokenCreator, nooftoken, "");
        token_id[tokenCreator] = ipfsHash;
        _creator[tokenCreator] = msg.sender;
        _royal[tokenCreator]["artist"].uaddress = royaddress[0];
        _royal[tokenCreator]["agent"].uaddress = royaddress[1];
        _royal[tokenCreator]["artist"].pecentr = royPer[0];
        _royal[tokenCreator]["agent"].pecentr = royPer[1];
        tokenQuantity[tokenCreator] += nooftoken;
        emit Mint(msg.sender,tokenCreator,nooftoken);
        return tokenCreator;
    }

    // ETH TRANSFER PURCHASE
    function saleToken(
        address payable from,
        uint256 tokenId,
        uint256 numOfTokens
    ) public payable {
        require(_balances[tokenId][from] >= numOfTokens,"Not enough amount of tokens for sale");
        require(checkOrder[tokenId][from],"Not available for buying");
        require( 
            numOfTokens <= order_place[from][tokenId].noOfTokens,
            "Number of tokens must be less than or equalto available selling tokens"
        );
        require(
            msg.value == order_place[from][tokenId].price.mul(numOfTokens),
            "Insufficient Balance"
        );
        checker[tokenId][from] = true;
        _saleToken(from, tokenId, numOfTokens);
        saleTokenTransfer(from, tokenId,numOfTokens);
    }

    function _saleToken(
        address payable from,
        uint256 tokenId,
        uint256 numOfTokens
    ) internal {
        address payable create = payable(_royal[tokenId]["agent"].uaddress);
        address payable create2 = payable(
            _royal[tokenId]["artist"].uaddress
        );
        uint256[4] memory calcs= calc(
            order_place[from][tokenId].price.mul(numOfTokens),
            _royal[tokenId]["agent"].pecentr,
            _royal[tokenId]["artist"].pecentr
        );
        address payable admin = payable(serviceFeeAddress);
        admin.transfer(calcs[0]);
        create.transfer(calcs[1]);
        create2.transfer(calcs[2]);
        from.transfer(calcs[3]);
    }

    function saleTokenTransfer(
        address from,
        uint256 tokenId,
        uint256 NOFToken
    ) internal {
        
        if(NOFToken < order_place[from][tokenId].noOfTokens){
            order_place[from][tokenId].noOfTokens -= NOFToken;
        }else{
            delete order_place[from][tokenId];
            checkOrder[tokenId][from] = false;
        }
        safeTransferFrom(from, msg.sender, tokenId, NOFToken, "");
    }

    function calc(
        uint256 amount,
        uint256 artist,
        uint256 agent
    )
        internal
        view
        returns (
            uint256[4] memory
        )
    {
        uint256 fee = serviceValue != 0 ? pBEPent(amount, serviceValue):0;
        uint256 artist_ = (artist !=0) ? pBEPent(amount, artist) : 0;
        uint256 agent_ = (agent !=0) ? pBEPent(amount, agent):0;
        uint256 netamount = amount.sub(fee).sub(artist_).sub(agent_);
        return [fee, artist_, agent_, netamount];
    }

    function pBEPent(uint256 value1, uint256 value2)
        public
        pure
        returns (uint256)
    {
        uint256 result = value1.mul(value2).div(10**4);
        return (result);
    }

    function orderPlace(uint256 tokenId, uint256 _price, uint256 noOfTokens) public {
        require(noOfTokens > 0, "Number of tokens must be greater than 0");
        require(_balances[tokenId][msg.sender] >= noOfTokens, "Is Not a Owner");
        Order memory order;
        order.tokenId = tokenId;
        order.price = _price;
        order.noOfTokens = noOfTokens;
        order_place[msg.sender][tokenId] = order;
        checkOrder[tokenId][msg.sender] = true;
        emit OrderPlace(msg.sender, tokenId, _price);
    }

    function cancelOrder(uint256 tokenId) public {
        require(checkOrder[tokenId][msg.sender],"Order Not Available");
        require(_balances[tokenId][msg.sender] > 0, "Is Not a Owner");
        delete order_place[msg.sender][tokenId];
        checkOrder[tokenId][msg.sender] = false;
        emit CancelOrder(msg.sender, tokenId);
    }

    function changePrice(uint256 value, uint256 tokenId) public {
        require(checkOrder[tokenId][msg.sender],"Order Not Available");
        require(_balances[tokenId][msg.sender] > 0, "Is Not a Owner");
        //require(value < order_place[msg.sender][tokenId].price);
        order_place[msg.sender][tokenId].price = value;
        emit ChangePrice(msg.sender, tokenId, value);
    }

    function burnToken(
        address from,
        uint256 tokenId,
        uint256 NOFToken
    ) public {
        require(
            (_balances[tokenId][from] >= NOFToken && from == msg.sender) ||
                msg.sender == owner(),
            "Your Not a Token Owner or insufficient Token Balance"
        );
        require(
            _balances[tokenId][from] >= NOFToken,
            "Your Not a Token Owner or insufficient Token Balance"
        );
        
        if (_balances[tokenId][from] == NOFToken) {
            if (checkOrder[tokenId][from] == true) {
                if(NOFToken < order_place[from][tokenId].noOfTokens){
                    order_place[from][tokenId].noOfTokens -= NOFToken;
                }else{
                    delete order_place[from][tokenId];
                    checkOrder[tokenId][from] = false;
                }
            }
        }
        burn(from, tokenId, NOFToken);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerQueryForNonexistentToken();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

interface IERC2981Royalties {
    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _value - the sale price of the NFT asset specified by _tokenId
    /// @return _receiver - address of who should be sent the royalty payment
    /// @return _royaltyAmount - the royalty payment amount for value sale price
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

abstract contract ERC2981PerTokenRoyalties is ERC165Upgradeable, IERC2981Royalties {
    struct Royalty {
        address recipient;
        uint256 value;
    }

    mapping(uint256 => Royalty) internal _royalties;


    /// @dev Sets token royalties
    /// @param id the token id fir which we register the royalties
    /// @param recipient recipient of the royalties
    /// @param value percentage (using 2 decimals - 10000 = 100, 0 = 0)
    function _setTokenRoyalty(
        uint256 id,
        address recipient,
        uint256 value
    ) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');

        _royalties[id] = Royalty(recipient, value);
    }

    /// @inheritdoc IERC2981Royalties
    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        Royalty memory royalty = _royalties[tokenId];
        return (royalty.recipient, (value * royalty.value) / 1000);
    }
}


contract ERC721A is 
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable,
    ERC2981PerTokenRoyalties {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function _init (string memory name_, string memory symbol_) public initializer {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 1;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
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
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        safeTransferFrom(from, to, tokenId, '');
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
        _transfer(from, to, tokenId);
        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        _mint(to, quantity, _data, true);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
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
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev This is equivalent to _burn(tokenId, false)
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
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
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}

contract MetaRebelsV1 is Initializable, ERC721A{
    using StringsUpgradeable for uint256;
    uint _tokenIds;
    //mapping (uint256 => royal.royalties) public royalty;
    address public owner;
    address treasuryWallet;
    string  _mainURI;
    bool public _isMint;

    mapping(address => bool) public freeWhitelists;
    mapping(address => bool) public whitelistSpots;
    uint256 public mintFee;
    uint256 mintStopTime;
    uint256 mintingRound;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function initialize(string memory _name, string memory _symbol, string memory _mUri) public initializer  {
        ERC721A._init(_name, _symbol);
        owner = msg.sender;
        _tokenIds = 1;
        _mainURI = _mUri;
        mintingRound = 1;
        _isMint = true;
        mintStopTime = 1653397095;
    }

    function changeMintStatus(bool _status) external onlyOwner{
    	require(_status != _isMint,'Mint already in same status');
    	_isMint = _status;
    }

    function updateMintStopTime(uint256 _time) external onlyOwner{
        mintStopTime = _time;
    }

    function updateMintFee(uint256 fee_) external onlyOwner{
        mintFee = fee_;
    }

    function updateMintRound(uint256 _round) external onlyOwner{
        require(_round == 1 || _round == 2 || _round == 3,"Invalid Round");
        mintingRound = _round;
    }

    function addFreeWL(address[] memory _wl)external onlyOwner{
        for(uint i = 0; i < _wl.length; i++){
            if(!freeWhitelists[_wl[i]]){
                freeWhitelists[_wl[i]] = true;
            }
        }
    }

    function addWLSpots(address[] memory _wl)external onlyOwner{
        for(uint i = 0; i < _wl.length; i++){
            if(!whitelistSpots[_wl[i]]){
                whitelistSpots[_wl[i]] = true;
            }
        }
    }

    function removeFreeWL(address _wlAddress) external onlyOwner{
        require(freeWhitelists[_wlAddress],"Already Removed");
        freeWhitelists[_wlAddress] = false;
    }

    function removeWhiteListSpot(address _wlAddress) external onlyOwner{
        require(whitelistSpots[_wlAddress],"Already Removed");
        whitelistSpots[_wlAddress] = false;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner, 'Only Owner');
        _;
    }
    
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "00");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function updateTreasury(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "00");
        treasuryWallet = newOwner;
    }

    function updateMainURI(string memory _mainuri) external virtual onlyOwner {
        _mainURI = _mainuri;
    }
    
    function mint() public payable {
    	require(msg.value == mintFee,"Insufficient Price");
        require(mintStopTime > block.timestamp,"Minting Stopped");
    	require(_isMint, "Currently Minting Is Off");
        if(mintingRound == 1){
            require(freeWhitelists[msg.sender], "Only DAO");
            freeWhitelists[msg.sender] = false;
        }else if(mintingRound == 2){
            require(whitelistSpots[msg.sender], "Only whitelisted");
            whitelistSpots[msg.sender] = false;
        }
        _safeMint(msg.sender, 1);
        //_tokenIds++;
        //_setTokenRoyalty(_tokenIds, , _royalty);
        // royalty[_tokenIds].account = msg.sender;
        // royalty[_tokenIds].percent = _royalty;
    }

    function withdrawTreasury() external onlyOwner returns(bool){
        (bool success, ) = treasuryWallet.call{value: address(this).balance}("");
        return success;
    }
    
    function bulkTransfer(address[] memory to, uint[] memory tokenIds) public virtual{
        require( to.length == tokenIds.length, "Lenght not matched, Invalid Format");
        require( to.length <= 400, "You can transfer max 400 tokens");
        for(uint i = 0; i < to.length; i++){
            safeTransferFrom(msg.sender, to[i], tokenIds[i]);
        }
    }
    
    function multiSendTokens(address to, uint[] memory tokenIds) public virtual{
        require( tokenIds.length <= 400, "You can transfer max 400 tokens");
        for(uint i = 0; i < tokenIds.length; i++){
            safeTransferFrom(msg.sender, to, tokenIds[i]);
        }
    }

    function baseURI() external view returns (string memory) {
        return _mainURI;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_mainURI,tokenId.toString(),".json"));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
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

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Staker{
    
    struct data{
        uint256 stakedAmount;
        uint256 historyId;
        uint256 lastRewardTime;
        uint256 claimed;
    }
    
 }

contract stakeTenup is Initializable {
    
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Staker for Staker.data;
    using SafeMath for uint256;

    // ERC20 basic token contract being held
    IERC20Upgradeable private  _token;
    
    uint private activeStakers;
    address private owner;
    mapping(address => Staker.data) public stakers;
    uint256[] private historyIndex;
    mapping(uint256 => uint256) public stakingAPY;
    uint256 public totalStaked;
    uint256 public totalClaimed;
    uint256 private minimum;
    
    event NewStake(uint256 amount, address indexed staker, uint256 index);
    event Claimed(uint256 reward, address indexed staker);
    event UnStaked(uint256 amount, address indexed staker);

    function initialize(IERC20Upgradeable token_, uint256 _apy, uint256 _minimum) public initializer  {
        _token = token_;
        owner = msg.sender;
        historyIndex.push(block.timestamp);

        // 100 = 1% or 10 = 0.1% or 1 = 0.01%
        stakingAPY[block.timestamp] = _apy;
        minimum = _minimum;  
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable");
        _;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20Upgradeable) {
        return _token;
    }
    
    /**
     * Stake Amount in the contract.
     */
    function StakeAmount(uint256 _amount) public{
        require(_amount >= minimum, "0x11");
        require(stakers[msg.sender].stakedAmount == 0 ,"0x12");
        
        //stake
        _stake(_amount);
    }
    
    function _stake(uint256 _amount) internal{
        stakers[msg.sender].stakedAmount = _amount;
        stakers[msg.sender].historyId = historyIndex.length-1;
        stakers[msg.sender].lastRewardTime = block.timestamp;
        
        totalStaked += _amount;
        token().safeTransferFrom(msg.sender, address(this), _amount);
        
        activeStakers++;
        emit NewStake(_amount, msg.sender, historyIndex.length-1);
    }

    /**
     * UnStake Amount Without Claiming Rewards
    **/
    function emergencyEndstake() external{
        require(msg.sender == tx.origin, '0x21');
        uint256 sAmount = stakers[msg.sender].stakedAmount;
        require(sAmount != 0, '0x22');
        
        totalStaked -= sAmount;
        activeStakers--;
        _token.safeTransfer(msg.sender, sAmount);
        stakers[msg.sender].stakedAmount = 0;
        emit UnStaked(sAmount, msg.sender);
    }


    function showRewards(address _staker) public view returns(uint256){
        Staker.data memory stakee = stakers[_staker];
        uint256 claimableAmount;
        if(block.timestamp.sub(stakers[_staker].lastRewardTime).div(1 days) > 0){
            uint256 laster = stakee.lastRewardTime;
            for(uint i = stakee.historyId; i < (historyIndex.length); i++){
                uint256 apy = stakingAPY[historyIndex[i]];
                if(laster < block.timestamp){
                    if(i < (historyIndex.length-1)){
                        if(historyIndex[i+1] > block.timestamp){
                            uint256 PDR = stakers[_staker].stakedAmount.mul(apy).div(10000).div(365);
                            claimableAmount += block.timestamp.sub(laster).div(1 days).mul(PDR);
                            laster = block.timestamp;
                        }else{
                            uint256 PDR = stakers[_staker].stakedAmount.mul(apy).div(10000).div(365);
                            claimableAmount += historyIndex[i+1].sub(laster).div(1 days).mul(PDR);
                            laster = historyIndex[i+1];
                        }
                    }else{
                        uint256 PDR = stakers[_staker].stakedAmount.mul(apy).div(10000).div(365);
                        claimableAmount += block.timestamp.sub(laster).div(1 days).mul(PDR);
                        laster = block.timestamp;
                    }
                }
            }
        }
        return claimableAmount;
    }

    function stakersActive() public view virtual returns (uint256) {
        return activeStakers;
    }
    
    function redeem() public {
        require(msg.sender == tx.origin, "0x31");
        require(stakers[msg.sender].stakedAmount != 0,"0x32");
        uint256 rewards = showRewards(msg.sender);
        require(rewards != 0, "0x33");
        require(rewards < RemainingRewardsPot(), "0x34");

        _token.safeTransfer(msg.sender,rewards);
        stakers[msg.sender].lastRewardTime = block.timestamp;
        stakers[msg.sender].claimed += rewards;
        stakers[msg.sender].historyId = historyIndex.length-1;
        totalClaimed += rewards;
        emit Claimed(rewards, msg.sender);
    }

    function endStake() public{
        require(msg.sender == tx.origin, "0x51");
        uint256 sAmount = stakers[msg.sender].stakedAmount;
        require(sAmount != 0,"0x52");
        uint256 rewards = showRewards(msg.sender);
        require(rewards < RemainingRewardsPot(), "0x53");

        totalStaked -= sAmount;
        activeStakers--;
        _token.safeTransfer(msg.sender, sAmount+rewards);
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].claimed += rewards;
        emit UnStaked(sAmount, msg.sender);
    }

    function calculatePerDayRewards(uint256 amount) public view returns(uint256){
        uint256 perDayReward = amount.mul(stakingAPY[historyIndex[historyIndex.length-1]]).div(10000).div(365);
        return (perDayReward);
    }

    function currentAPY() external view returns(uint256){
        return (stakingAPY[historyIndex[historyIndex.length-1]]);
    }
    
    function name() external pure returns(string memory){
        return "Stake Tenup";
    }
    
    function RemainingRewardsPot() public view virtual returns (uint256) {
        return token().balanceOf(address(this)) - totalStaked;
    }
    
    function withdrawRewardsPot(uint256 amount) public onlyOwner {
        require(amount < RemainingRewardsPot(), 'Insufficient funds in RewardPot');
        _token.safeTransfer(msg.sender, amount);
    }

    
    //For Testing Purpose
    function changeLastRewardTime(uint256 _lastrewardTime, address _stakero) public onlyOwner{
        stakers[_stakero].lastRewardTime = _lastrewardTime;
    }

    /**
     * Update APY
    **/
    function updateAPY(uint256 _newAPY) external onlyOwner {
        require(_newAPY < 40000, 'cannot exceed 400%');
        historyIndex.push(block.timestamp);
        stakingAPY[block.timestamp] = _newAPY;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IvotingTokens{
    function balanceOf(
        address account
    ) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function burn(
        uint256 amount
    ) external returns (bool);
    function mint(
        address account,
        uint256 amount
    ) external returns (bool);
}

interface IERC1155Upgradeable is IERC165Upgradeable {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function setApprovalForAllFromMarket(address origin, address operator, bool _approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Staker{
    struct data{
        uint256 stakedAmount;
        bool status;
        uint256 stakedNFTs;
        bool isDAO;
    }
}


contract lockTrustV2 is Initializable,ERC1155Holder {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Staker for Staker.data;
    using SafeMath for uint256;
    

    // ERC20 basic token contract being held
    IERC20Upgradeable private  _token;
    IvotingTokens private _votingToken;
    
    uint private liveStakers;
    address private owner;
    mapping(address => Staker.data) public stakers;
    uint256 public totalLocked;
    uint256 public stakersLimit;
    uint256 public minLockAmount;
    IERC20Upgradeable private _safeVotingToken;
    
    event NewStake(uint256 amount, address staker, uint256 package);
    mapping(address => bool) public _owners;
    mapping(address => bool) public whitelistedCollections;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public stakedNFTBalances;
    mapping(address => mapping(address => uint256[])) public stakeTokenids;
    uint256 public daoMembers;

    function initialize(IERC20Upgradeable token_) public initializer  {
        _token = token_;
        owner = msg.sender;
        _owners[msg.sender] = true;
        stakersLimit = 1000;
        minLockAmount = 200 ether;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwners() {
        require(_owners[msg.sender], "Ownable: caller is not the owner!");
        _;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20Upgradeable) {
        return _token;
    }

    /**
     * @return the voting token being held.
     */
    function votingToken() public view virtual returns (IvotingTokens) {
        return _votingToken;
    }

    function safeVotingToken() public view virtual returns (IERC20Upgradeable) {
        return _safeVotingToken;
    }

    function stakedTokens(address _staker, address collection_) external view returns(uint256[] memory){
        return stakeTokenids[_staker][collection_];
    }
    
    /**
     * Stake Amount in the contract.
     */
    function StakeAmount() external{
        require(stakersLimit > liveStakers,"Staking Limit Exceeded");
        require(!stakers[msg.sender].status,"Already staked with this account");
        
        _lockNow();
        
    }
    
    function _lockNow() internal{
        stakers[msg.sender].stakedAmount = minLockAmount;
        stakers[msg.sender].status = true;
        
        totalLocked += minLockAmount;
        token().safeTransferFrom(msg.sender, address(this), minLockAmount);
        if(stakers[msg.sender].stakedAmount >= minLockAmount && stakers[msg.sender].stakedNFTs >= 20){
            votingToken().mint(msg.sender, minLockAmount);
            stakers[msg.sender].isDAO = true;
            daoMembers++;
        }
        
        liveStakers++;
        emit NewStake(minLockAmount,msg.sender,1);
    }

    function stakeNFTs(address collection_ ,uint256[] memory tokenIds, uint256[] memory amounts_) external {
        IERC1155Upgradeable coll_ = IERC1155Upgradeable(collection_);
        require(coll_.isApprovedForAll(msg.sender,address(this)), "caller Not Approved");
        require(stakersLimit > daoMembers, "Staking Limit Exceeded");
        require(!stakers[msg.sender].isDAO, "Already DAO Member");
        require(whitelistedCollections[collection_], "Not Whitelisted Collection");
        require(stakeTokenids[msg.sender][collection_].length == 0,"Already staked this collection");
        //uint256[] memory amounts_  = new uint256[](tokenIds.length );
        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tmp_blncs = coll_.balanceOf(msg.sender, tokenIds[i]);
            require(tmp_blncs >= amounts_[i], "Insufficient Balance");
            stakedNFTBalances[msg.sender][collection_][tokenIds[i]] = amounts_[i];
            total = total.add(amounts_[i]);
        }
        coll_.safeBatchTransferFrom(msg.sender, address(this), tokenIds, amounts_, "");
        stakers[msg.sender].stakedNFTs = stakers[msg.sender].stakedNFTs.add(total);
        stakeTokenids[msg.sender][collection_] = tokenIds;
        
        if(stakers[msg.sender].stakedAmount >= minLockAmount && stakers[msg.sender].stakedNFTs >= 20){
            votingToken().mint(msg.sender, minLockAmount);
            stakers[msg.sender].isDAO = true;
            daoMembers ++;
        }
    }

    function unStakeNFTS(address collection_) external {
        IERC1155Upgradeable coll_ = IERC1155Upgradeable(collection_);
        uint256[] memory tokenArray = stakeTokenids[msg.sender][collection_];
        require(whitelistedCollections[collection_], "Not Whitelisted Collection");
        require(tokenArray.length > 0,"No NFTs Staked");
        require(msg.sender == tx.origin, 'invalid');
        
        uint256[] memory amounts_  = new uint256[](tokenArray.length);
        uint256 total;
        for (uint256 i = 0; i < tokenArray.length; i++) {
            amounts_[i] = stakedNFTBalances[msg.sender][collection_][tokenArray[i]];
            total += stakedNFTBalances[msg.sender][collection_][tokenArray[i]];
            stakedNFTBalances[msg.sender][collection_][tokenArray[i]] = 0;  
        }

        coll_.safeBatchTransferFrom(address(this), msg.sender, stakeTokenids[msg.sender][collection_], amounts_, "");
        stakers[msg.sender].stakedNFTs = stakers[msg.sender].stakedNFTs.sub(total);
        delete stakeTokenids[msg.sender][collection_];

        if(stakers[msg.sender].isDAO == true && stakers[msg.sender].stakedNFTs < 20){
            require(votingToken().balanceOf(msg.sender) >= stakers[msg.sender].stakedAmount, 'no vote found');
            safeVotingToken().safeTransferFrom(msg.sender, address(this), stakers[msg.sender].stakedAmount);
            votingToken().burn(stakers[msg.sender].stakedAmount);
            stakers[msg.sender].isDAO = false;
            daoMembers --;
        }
    }

    function stakersActive() public view virtual returns (uint256) {
        return liveStakers;
    }
    
    function endStake() public{
        require(msg.sender == tx.origin, 'Invalid Request');
        require(stakers[msg.sender].status, 'You are not a staker');
        
        totalLocked -= stakers[msg.sender].stakedAmount;
        
        liveStakers--;
        _token.safeTransfer(msg.sender, stakers[msg.sender].stakedAmount);
        if(stakers[msg.sender].isDAO == true){
            require(votingToken().balanceOf(msg.sender) >= stakers[msg.sender].stakedAmount, 'no vote found');
            safeVotingToken().safeTransferFrom(msg.sender, address(this), stakers[msg.sender].stakedAmount);
            votingToken().burn(stakers[msg.sender].stakedAmount);
            stakers[msg.sender].isDAO = false;
            daoMembers --;
        }
        stakers[msg.sender].status = false;
        stakers[msg.sender].stakedAmount = 0;
    }

    function endStakeByOwner(address stakerAddress) public onlyOwner{
        require(msg.sender == tx.origin, 'Invalid Request');
        require(stakers[stakerAddress].status, 'You are not a staker');
        require(votingToken().balanceOf(stakerAddress) >= stakers[stakerAddress].stakedAmount, 'You must have equal voting tokens to end the stake');
        
        totalLocked -= stakers[stakerAddress].stakedAmount;
        
        liveStakers--;
        _token.safeTransfer(stakerAddress, stakers[stakerAddress].stakedAmount);
        if(stakers[stakerAddress].isDAO == true){
            require(votingToken().balanceOf(stakerAddress) >= stakers[stakerAddress].stakedAmount, 'no vote found');
            safeVotingToken().safeTransferFrom(stakerAddress, address(this), stakers[stakerAddress].stakedAmount);
            votingToken().burn(stakers[stakerAddress].stakedAmount);
            stakers[stakerAddress].isDAO = false;
            daoMembers --;
        }
        stakers[stakerAddress].status = false;
        stakers[stakerAddress].stakedAmount = 0;
    }

    function setToken(IERC20Upgradeable Token_) public onlyOwner {
        _token = Token_;
    }

    function setVotingToken(IvotingTokens vToken_) public onlyOwner {
        _votingToken = vToken_;
    }

    function setSafeVotingToken(IERC20Upgradeable vToken_) public onlyOwner {
        _safeVotingToken = vToken_;
    }

    function changeWhitelisted(address collection_, bool status_) public onlyOwner {
        whitelistedCollections[collection_] = status_;
    }

    function addOwner(address owner_) public onlyOwner{
        _owners[owner_] = true;
    }

    function removeOwner(address owner_) public onlyOwner{
        _owners[owner_] = false;
    }
    
    function changeStakersLimit(uint256 _limit) public onlyOwners{
        require(_limit > 0,"Stakers Limit Must Be greater than 0");
        stakersLimit = _limit;
    }    

    function currentTimestamp() public view returns(uint256){
        return block.timestamp;
    }   
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

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

//import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
interface IvotingTokens{
    function balanceOf(
        address account
    ) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function burn(
        uint256 amount
    ) external returns (bool);
    function mint(
        address account,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Staker{
    struct data{
        uint256 stakedAmount;
        bool status;
    }
}


contract lockTrustV1 is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Staker for Staker.data;
    using SafeMath for uint256;

    // ERC20 basic token contract being held
    IERC20Upgradeable private  _token;
    IvotingTokens private _votingToken;
    
    uint private liveStakers;
    address private owner;
    mapping(address => Staker.data) public stakers;
    uint256 public totalLocked;
    uint256 public stakersLimit;
    uint256 public minLockAmount;
    IERC20Upgradeable private _safeVotingToken;
    
    event NewStake(uint256 amount, address staker, uint256 package);
    mapping(address => bool) public _owners;

    function initialize(IERC20Upgradeable token_) public initializer  {
        _token = token_;
        owner = msg.sender;
        _owners[msg.sender] = true;
        stakersLimit = 1000;
        minLockAmount = 200 ether;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwners() {
        require(_owners[msg.sender], "Ownable: caller is not the owner!");
        _;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20Upgradeable) {
        return _token;
    }

    /**
     * @return the voting token being held.
     */
    function votingToken() public view virtual returns (IvotingTokens) {
        return _votingToken;
    }

    function safeVotingToken() public view virtual returns (IERC20Upgradeable) {
        return _safeVotingToken;
    }
    
    /**
     * Stake Amount in the contract.
     */
    function StakeAmount() public{
        require(stakersLimit > liveStakers,"Staking Limit Exceeded");
        require(!stakers[msg.sender].status,"Already staked with this account");
        
        _lockNow();
        
    }
    
    function _lockNow() internal{
        stakers[msg.sender].stakedAmount = minLockAmount;
        stakers[msg.sender].status = true;
        
        totalLocked += minLockAmount;
        token().safeTransferFrom(msg.sender, address(this), minLockAmount);
        votingToken().mint(msg.sender, minLockAmount);
        safeVotingToken().approve(address(this),200 ether);
        
        liveStakers++;
        emit NewStake(minLockAmount,msg.sender,1);
    }

    function stakersActive() public view virtual returns (uint256) {
        return liveStakers;
    }
    
    function endStake() public{
        require(msg.sender == tx.origin, 'Invalid Request');
        require(stakers[msg.sender].status, 'You are not a staker');
        require(votingToken().balanceOf(msg.sender) >= stakers[msg.sender].stakedAmount, 'You must have equal voting tokens to end the stake');
        
        totalLocked -= stakers[msg.sender].stakedAmount;
        
        liveStakers--;
        safeVotingToken().safeTransferFrom(msg.sender, address(this), stakers[msg.sender].stakedAmount);
        _token.safeTransfer(msg.sender, stakers[msg.sender].stakedAmount);
        votingToken().burn(stakers[msg.sender].stakedAmount);
        stakers[msg.sender].status = false;
        stakers[msg.sender].stakedAmount = 0;
    }

    function endStakeByOwner(address stakerAddress) public onlyOwner{
        require(msg.sender == tx.origin, 'Invalid Request');
        require(stakers[stakerAddress].status, 'You are not a staker');
        require(votingToken().balanceOf(stakerAddress) >= stakers[stakerAddress].stakedAmount, 'You must have equal voting tokens to end the stake');
        
        totalLocked -= stakers[stakerAddress].stakedAmount;
        
        liveStakers--;
        safeVotingToken().safeTransferFrom(stakerAddress, address(this), stakers[stakerAddress].stakedAmount);
        _token.safeTransfer(stakerAddress, stakers[stakerAddress].stakedAmount);
        votingToken().burn(stakers[stakerAddress].stakedAmount);
        stakers[stakerAddress].status = false;
        stakers[stakerAddress].stakedAmount = 0;
    }
    
    function setVotingToken(IvotingTokens vToken_) public onlyOwner {
        _votingToken = vToken_;
    }

    function setSafeVotingToken(IERC20Upgradeable vToken_) public onlyOwner {
        _safeVotingToken = vToken_;
    }

    function addOwner(address owner_) public onlyOwner{
        _owners[owner_] = true;
    }

    function removeOwner(address owner_) public onlyOwner{
        _owners[owner_] = false;
    }
    
    //For Testing Purpose
    // function changeLastRewardTime(uint256 _lastrewardTime) public onlyOwner{
    //     stakers[msg.sender].lastRewardTime = _lastrewardTime;
    // }

    function changeStakersLimit(uint256 _limit) public onlyOwners{
        require(_limit > 0,"Stakers Limit Must Be greater than 0");
        stakersLimit = _limit;
    }    

    function currentTimestamp() public view returns(uint256){
        return block.timestamp;
    }
    
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library royalties{
    struct royalstr {
        address uaddress;
        uint256 pecentr;
    }
}

library auc{
    struct AuctionItem {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        uint256 askingPrice;
        bool isSold;
        bool bidItem;
        uint256 bidPrice;
        address bidderAddress;
        address ERC20;
        uint256[2] itype;
    }
}

interface IERC721 is IERC165Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function _royal(uint256 tokenId, string memory rtype) external view returns (royalties.royalstr memory);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function setApprovalForAllFromMarket(address origin, address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC1155Upgradeable is IERC165Upgradeable {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function _royal(uint256 tokenId, string memory rtype) external view returns (royalties.royalstr memory);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function setApprovalForAllFromMarket(address origin, address operator, bool _approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

abstract contract marketplace is Initializable{
    using SafeMath for uint256;
    
    uint256 internal serviceFee; //2.5% serviceFee
    address internal feeAddress; // admin address where serviceFee will be sent
    address internal marketplaceOwner;
    mapping(address => auc.AuctionItem[]) public itemsForSale;

    mapping(address => bool) internal validERC;
    mapping (address => mapping(address=>mapping(uint256=>uint256))) internal auctionItemId;
    mapping (address => mapping (address => mapping(address => mapping(uint256 => uint256)))) public pendingReturns;
    mapping(uint256 => mapping(address => mapping(address => bool))) public checkOrder;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ItemAdded(uint id, uint tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, uint256 numOfTokens, address indexed from, address erc20);
    event ItemSold(uint id, address indexed buyer, uint256 askingPrice, uint256 numOfTokens, address indexed from);
    event BidPlaced(uint id, address indexed bidder, uint256 bidPrice, address CollectionAdd, address indexed from);
    event EditOrder(uint256 id, uint256 newPrice, address indexed from);
    event CancelOrder(uint256 id, address indexed from);
    event BidRedeemed(uint256 id, address indexed from, address indexed redeemer, address erc20, uint256 amount);
    

    function initialize(address _feeAddress) external initializer {
        marketplaceOwner = msg.sender;
        serviceFee = 250;
        feeAddress = _feeAddress;
    }

    modifier onlyOwner{
        require(marketplaceOwner == msg.sender,"-1");
        _;
    }

    function placeOrder(
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem,
        address tokenERC20,
        uint256[2] memory _type
    ) external returns(uint256) {
        require(_type[0] <= 1,"0");
        require(checkOrder[tokenId][tokenAddress][msg.sender] == false, "1");
        if(!IERC721(tokenAddress).isApprovedForAll(msg.sender,address(this))){
            IERC721(tokenAddress).setApprovalForAllFromMarket(msg.sender,address(this),true);
        }
        if(bidItem){
            require(_type[0] == 0,"2");
        }

        if(tokenERC20 == address(0)){
            return _addItemSimple(tokenId, tokenAddress, askingPrice, bidItem, [_type[0], _type[1]]);
        }else{
            require(validERC[tokenERC20], "3");
            return _addItemERC(tokenId, tokenAddress, askingPrice, bidItem, tokenERC20, [_type[0], _type[1]]);
        }
    }

    function _addItemSimple(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, uint256[2] memory _type) internal returns (uint256) {
        if(_type[0] == 1){
            IERC1155Upgradeable _multiContract = IERC1155Upgradeable(tokenAddress);
            require(_multiContract.balanceOf(msg.sender,tokenId) >= _type[1],"4");
        }else{
            IERC721 tokenContract = IERC721(tokenAddress);
            require(tokenContract.ownerOf(tokenId) == msg.sender, "5");   
        }
        if (auctionItemId[msg.sender][tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale[msg.sender].length + 1;
            itemsForSale[msg.sender].push(auc.AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), address(0), [_type[0], _type[1]]));
            auctionItemId[msg.sender][tokenAddress][tokenId] = newItemId;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem, _type[1], msg.sender, address(0));
            return newItemId;
        }
        else{
            uint256 aucID = auctionItemId[msg.sender][tokenAddress][tokenId] - 1;
            itemsForSale[msg.sender][aucID].isSold = false;
            itemsForSale[msg.sender][aucID].bidItem = bidItem;
            itemsForSale[msg.sender][aucID].askingPrice = askingPrice;
            itemsForSale[msg.sender][aucID].ERC20 = address(0);
            itemsForSale[msg.sender][aucID].itype[0] = _type[0];
            itemsForSale[msg.sender][aucID].itype[1] = _type[1];
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            emit ItemAdded(aucID+1, tokenId, tokenAddress, askingPrice, bidItem, _type[1], msg.sender, address(0));
            return aucID+1;
        }
    }

    function _addItemERC(uint256 tokenId, address tokenAddress, uint256 askingPrice, bool bidItem, address tokenERC20, uint256[2] memory _type) internal  returns (uint256){
        if(_type[0] == 1){
            IERC1155Upgradeable _multiContract = IERC1155Upgradeable(tokenAddress);
            require(_multiContract.balanceOf(msg.sender,tokenId) >= _type[1],"6");
        }else{
            IERC721 tokenContract = IERC721(tokenAddress);
            require(tokenContract.ownerOf(tokenId) == msg.sender, "7");   
        }
        if (auctionItemId[msg.sender][tokenAddress][tokenId] == 0){ //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale[msg.sender].length + 1;
            itemsForSale[msg.sender].push(auc.AuctionItem(newItemId, tokenAddress, tokenId, askingPrice, false, bidItem, 0, address(0), tokenERC20, [_type[0], _type[1]]));
            
            auctionItemId[msg.sender][tokenAddress][tokenId] = newItemId;
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            emit ItemAdded(newItemId, tokenId, tokenAddress, askingPrice, bidItem, _type[1], msg.sender, tokenERC20);
            return newItemId;
        }
        else{
            uint256 aucID = auctionItemId[msg.sender][tokenAddress][tokenId] - 1;
            itemsForSale[msg.sender][aucID].isSold = false;
            itemsForSale[msg.sender][aucID].bidItem = bidItem;
            itemsForSale[msg.sender][aucID].askingPrice = askingPrice;
            itemsForSale[msg.sender][aucID].ERC20 = tokenERC20;
            itemsForSale[msg.sender][aucID].itype[0] = _type[0];
            itemsForSale[msg.sender][aucID].itype[1] = _type[1];
            
            checkOrder[tokenId][tokenAddress][msg.sender] = true;

            emit ItemAdded(aucID+1, tokenId, tokenAddress, askingPrice, bidItem, _type[1], msg.sender, tokenERC20);
            return aucID+1;
        }
    }

    function cancelOrder(uint256 id) external{
        address collectionAddress = itemsForSale[msg.sender][id-1].tokenAddress;
        //require(IERC721(collectionAddress).ownerOf(itemsForSale[msg.sender][id-1].tokenId) == msg.sender,"8");
        require(checkOrder[itemsForSale[msg.sender][id-1].tokenId][collectionAddress][msg.sender],"9");
        checkOrder[itemsForSale[msg.sender][id-1].tokenId][collectionAddress][msg.sender] = false;
        if(itemsForSale[msg.sender][id - 1].bidItem == true){
            _endAuctionOnly(id);
        }else{
            itemsForSale[msg.sender][id - 1].askingPrice = 0;
        }
        emit CancelOrder(id, msg.sender);
    }

    function editOrder(uint256 id, uint256 newPrice) external{
        address collectionAddress = itemsForSale[msg.sender][id-1].tokenAddress;
        require(itemsForSale[msg.sender][id-1].bidItem == false, "10");
        require(checkOrder[itemsForSale[msg.sender][id-1].tokenId][collectionAddress][msg.sender],"11");
        itemsForSale[msg.sender][id-1].askingPrice = newPrice;
        emit EditOrder(id, itemsForSale[msg.sender][id-1].askingPrice, msg.sender);
    }

    function buyItem(address from, uint256 id, uint256 numOfTokens) external payable {
        auc.AuctionItem memory dt = itemsForSale[from][id - 1];
        require(checkOrder[dt.tokenId][dt.tokenAddress][from],"12");
        require(dt.isSold == false,"13");
        require(dt.bidItem == false, "14");
        require(dt.itype[1] >= numOfTokens,"15");
        require(from != msg.sender, "15-1");

        if(dt.itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(dt.tokenAddress);
            require(Collection.balanceOf(from,dt.tokenId) >= numOfTokens, "16");
        }else{
            IERC721 Collection = IERC721(dt.tokenAddress);
            require(Collection.ownerOf(dt.tokenId) == from, "17");
        }
        

        if(dt.ERC20 == address(0)){
            require(msg.value >= dt.askingPrice.mul(numOfTokens), "18");
            _buyitemSimple(from,id,numOfTokens);
        }else{
            _buyitemERC(from,id,numOfTokens);
        }
    }
    
    function getRoyalties(uint256 amount, IERC721 _collection, uint256 tokenid_, IERC20Upgradeable tokenERC) internal returns(uint256){
        uint256 sF = _calculateServiceFee(amount);
        try _collection._royal(tokenid_, "artist") returns (royalties.royalstr memory d){
            royalties.royalstr memory agent = _collection._royal(tokenid_,"agent");
            uint256[2] memory royalFees;
            address[2] memory royalAddress;
            if(d.uaddress != address(0) && d.pecentr != 0){
                royalFees[0] = _calculateRoyaltyFee(amount, d.pecentr);
                royalAddress[0] = d.uaddress;
                if(tokenERC == IERC20Upgradeable(address(0))){
                    (bool success2, ) = royalAddress[0].call{value: royalFees[0]}("");
                    require(success2, "20");
                }else{
                    tokenERC.transferFrom(msg.sender,royalAddress[0], royalFees[0]);
                }
            }
            if(agent.uaddress != address(0) && d.pecentr != 0){
                royalFees[1] = _calculateRoyaltyFee(amount, agent.pecentr);
                royalAddress[1] = agent.uaddress;
                if(tokenERC == IERC20Upgradeable(address(0))){
                    (bool success3, ) = royalAddress[1].call{value: royalFees[1]}("");
                    require(success3, "21");
                }else{
                    tokenERC.transferFrom(msg.sender,royalAddress[0], royalFees[0]);
                }
            }
            if(tokenERC == IERC20Upgradeable(address(0))){
                (bool success1, ) = feeAddress.call{value: sF}("");
                require(success1, "22");
            }else{
                tokenERC.transferFrom(msg.sender,feeAddress, sF);
            }
            return amount.sub(sF).sub(royalFees[0]).sub(royalFees[1]);
        }catch{
            if(tokenERC == IERC20Upgradeable(address(0))){
                (bool success1, ) = feeAddress.call{value: sF}("");
                require(success1, "23");
            }else{
                tokenERC.transferFrom(msg.sender,feeAddress, sF);
            }
            return amount.sub(sF);
        }
    }

    function getRoyaltiesView(uint256 amount, IERC721 _collection, uint256 tokenid_) external view returns(uint256[2] memory, address[2] memory){
        try _collection._royal(tokenid_, "artist") returns (royalties.royalstr memory d){
            royalties.royalstr memory agent = _collection._royal(tokenid_,"agent");
            uint256[2] memory royalFees;
            address[2] memory royalAddress;
            if(d.uaddress != address(0) && d.pecentr != 0){
                royalFees[0] = _calculateRoyaltyFee(amount, d.pecentr);
                royalAddress[0] = d.uaddress;
            }
            if(agent.uaddress != address(0) && d.pecentr != 0){
                royalFees[1] = _calculateRoyaltyFee(amount, agent.pecentr);
                royalAddress[1] = agent.uaddress;
            }
            return (royalFees,royalAddress);
        }catch{
            return ([uint256(0),uint256(0)],[address(0),address(0)]);
        }
    }

    function getAucRoyaltiesERC(uint256 amount, IERC721 _collection, uint256 tokenid_, IERC20Upgradeable tokenERC) internal returns(uint256){
        uint256 sF = _calculateServiceFee(amount);
        try _collection._royal(tokenid_, "artist") returns (royalties.royalstr memory d){
            royalties.royalstr memory agent = _collection._royal(tokenid_,"agent");
            uint256[2] memory royalFees;
            address[2] memory royalAddress;
            if(d.uaddress != address(0) && d.pecentr != 0){
                royalFees[0] = _calculateRoyaltyFee(amount, d.pecentr);
                royalAddress[0] = d.uaddress;
                tokenERC.transfer(royalAddress[0], royalFees[0]);
            }
            if(agent.uaddress != address(0) && d.pecentr != 0){
                royalFees[1] = _calculateRoyaltyFee(amount, agent.pecentr);
                royalAddress[1] = agent.uaddress;
                tokenERC.transfer(royalAddress[0], royalFees[0]);
            }
            tokenERC.transfer(feeAddress, sF);
            return amount.sub(sF).sub(royalFees[0]).sub(royalFees[1]);
        }catch{
            tokenERC.transfer(feeAddress, sF);
            return amount.sub(sF);
        }
    }
  
    function _buyitemSimple(address from, uint256 id, uint256 numOfTokens) internal{
        auc.AuctionItem memory aucB = itemsForSale[from][id - 1];
        IERC721 CollectionA = IERC721(aucB.tokenAddress);
        (bool success, ) = from.call{value: getRoyalties(msg.value, CollectionA, aucB.tokenId,IERC20Upgradeable(address(0)))}("");
        require(success, "25");

        if(aucB.itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(aucB.tokenAddress);
            Collection.safeTransferFrom(from,msg.sender,aucB.tokenId,numOfTokens,"");
            if(aucB.itype[1] == numOfTokens){
                itemsForSale[from][id - 1].isSold = true;
                
                checkOrder[aucB.tokenId][aucB.tokenAddress][from] = false;
            }else{
                itemsForSale[from][id-1].itype[1] -= numOfTokens;
            }
        }else{
            
            CollectionA.safeTransferFrom(from,msg.sender,aucB.tokenId);
            itemsForSale[from][id - 1].isSold = true;
            checkOrder[aucB.tokenId][aucB.tokenAddress][from] = false;
        }

        emit ItemSold(id, msg.sender, aucB.askingPrice, numOfTokens, from);
    }

    function _buyitemERC(address from, uint256 id, uint256 numOfTokens) internal{
        auc.AuctionItem memory aucB = itemsForSale[from][id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(aucB.ERC20);
        
        IERC721 CollectionA = IERC721(aucB.tokenAddress);
        
        tokenERC.transferFrom(msg.sender,from, getRoyalties(aucB.askingPrice.mul(numOfTokens), CollectionA, aucB.tokenId,tokenERC));
        
        if(aucB.itype[0] == 1){
            IERC1155Upgradeable Collection = IERC1155Upgradeable(aucB.tokenAddress);
            Collection.safeTransferFrom(from,msg.sender,aucB.tokenId,numOfTokens,"");
            if(aucB.itype[1] == numOfTokens){
                itemsForSale[from][id - 1].isSold = true;
                //activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
                checkOrder[aucB.tokenId][aucB.tokenAddress][from] = false;
                itemsForSale[from][id - 1].ERC20 = address(0);
            }else{
                itemsForSale[from][id-1].itype[1] -= numOfTokens;
            }
        }else{
            CollectionA.safeTransferFrom(from,msg.sender,aucB.tokenId);
            itemsForSale[from][id - 1].isSold = true;
            //activeItems[itemsForSale[id - 1].tokenAddress][itemsForSale[id - 1].tokenId] = false;
            checkOrder[aucB.tokenId][aucB.tokenAddress][from] = false;
            itemsForSale[from][id - 1].ERC20 = address(0);
        }
        emit ItemSold(id, msg.sender, aucB.askingPrice, numOfTokens, from);
    }

    function _calculateServiceFee(uint256 _amount) private view returns(uint256){
        return _amount.mul(serviceFee).div(
            10**4
        );
    }
    
    function _calculateRoyaltyFee(uint256 _amount, uint256 _royalty) private pure returns(uint256){
        return _amount.mul(_royalty).div(
            10**4
        );
    }

    function addERC20tokens(address erc20, bool status) external onlyOwner{
        validERC[erc20] = status;
    }

    // put a bid on an item
    // modifiers: ItemExists, IsForSale, IsForBid, HasTransferApproval
    // args: auctionItemId
    // check if a bid already exists, if yes: check if this bid value is higher then prev

    function PlaceABid(address from, uint256 aucItemId, uint256 amount) external payable {
        auc.AuctionItem memory aucP = itemsForSale[from][aucItemId - 1];
        require(checkOrder[aucP.tokenId][aucP.tokenAddress][from],"inactive");
        require(aucP.isSold == false,"sold");
        require(aucP.bidItem == true, "noBidA");
        require(from != msg.sender, "15-1");

        if(aucP.ERC20 == address(0)){
            //require(msg.value >= itemsForSale[from][aucItemId - 1].askingPrice, "less val");
            _placeBidSimple(from, aucItemId);
        }else{
            _placeBidERC(from, aucItemId, amount);
        }
    }

    function _placeBidSimple(address from, uint256 id) internal{
        uint256 totalPrice = 0;
        auc.AuctionItem memory aucP = itemsForSale[from][id - 1];
        if (pendingReturns[msg.sender][address(0)][from][aucP.id] == 0){
            totalPrice = msg.value;
        }
        else{
            totalPrice = msg.value + pendingReturns[msg.sender][address(0)][from][aucP.id];
        }
        require(totalPrice > aucP.askingPrice, "lessBid_AP");
        require(totalPrice > aucP.bidPrice, "lessBid_BP");

        pendingReturns[msg.sender][address(0)][from][aucP.id] = 0;
        if (aucP.bidPrice != 0 && aucP.bidderAddress != msg.sender){
            pendingReturns[aucP.bidderAddress][address(0)][from][aucP.id] = aucP.bidPrice;
        }
        itemsForSale[from][id-1].bidPrice = totalPrice;
        itemsForSale[from][id-1].bidderAddress = msg.sender;

        emit BidPlaced(aucP.id, msg.sender, totalPrice,aucP.tokenAddress, from);
    }

    function _placeBidERC(address from, uint256 id, uint256 amount) internal{
        uint256 totalPrice = 0;
        auc.AuctionItem memory aucP = itemsForSale[from][id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(aucP.ERC20);
        require(tokenERC.allowance(msg.sender,address(this)) >= amount , "allowance");

        if (pendingReturns[msg.sender][aucP.ERC20][from][aucP.id] == 0){
            totalPrice = amount;
        }
        else{
            totalPrice = amount + pendingReturns[msg.sender][aucP.ERC20][from][aucP.id];
        }
        require(totalPrice > aucP.askingPrice, "lessBid_AP");
        require(totalPrice > aucP.bidPrice, "lessBid_BP");
        tokenERC.transferFrom(msg.sender,address(this),amount);
        pendingReturns[msg.sender][aucP.ERC20][from][aucP.id] = 0;
        if (aucP.bidPrice != 0 && aucP.bidderAddress != msg.sender){
            pendingReturns[aucP.bidderAddress][aucP.ERC20][from][aucP.id] = aucP.bidPrice;
        }
        itemsForSale[from][id-1].bidPrice = totalPrice;
        itemsForSale[from][id-1].bidderAddress = msg.sender;
        emit BidPlaced(aucP.id,msg.sender,totalPrice,aucP.tokenAddress, from);
    }

    function withdrawPrevBid(address from, uint256 aucItemId,address _erc20) external{
        uint256 amount = pendingReturns[msg.sender][_erc20][from][aucItemId];
        require(amount > 0, 'noPending');
        pendingReturns[msg.sender][_erc20][from][aucItemId] = 0;
        if(_erc20 == address(0)){
            if (!payable(msg.sender).send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender][_erc20][from][aucItemId] = amount;
                //return false;
            }
        }else{
            IERC20Upgradeable(_erc20).transfer(msg.sender, amount);
        }
        emit BidRedeemed(aucItemId, from, msg.sender, _erc20, amount);
    }

    function EndAuction(uint256 aucItemId) external payable {
        auc.AuctionItem memory aucM = itemsForSale[msg.sender][aucItemId - 1];
        require(checkOrder[aucM.tokenId][aucM.tokenAddress][msg.sender],"NF");
        require(aucM.isSold == false,"sold");
        require(aucM.bidItem == true, "for buy");
        IERC721 Collection = IERC721(aucM.tokenAddress);
        require(Collection.ownerOf(aucM.tokenId) == msg.sender, "sellerS blnc");
        //just EndAuction
        if(aucM.bidPrice == 0){
            _endAuctionOnly(aucItemId);
        }
        //End And Distribute bidPrice
        else if(aucM.ERC20 == address(0)){
            //require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "Not enough funds set");
            _endAuctionSimple(aucItemId);
        }else{
            _endAuctionERC(aucItemId);
        }
    }

    function _endAuctionSimple(uint256 id) internal{
        auc.AuctionItem memory aucM = itemsForSale[msg.sender][id - 1];
        IERC721 Collection = IERC721(aucM.tokenAddress);
        address itemOwner = Collection.ownerOf(aucM.tokenId);
        
        (bool success, ) = itemOwner.call{value: getRoyalties(aucM.bidPrice, Collection, aucM.tokenId, IERC20Upgradeable(address(0)))}("");
        require(success, "sndIssue V");
        
        Collection.safeTransferFrom(itemOwner, aucM.bidderAddress, aucM.tokenId);
        checkOrder[aucM.tokenId][aucM.tokenAddress][itemOwner] = false;
        itemsForSale[msg.sender][id - 1].isSold = true;
        pendingReturns[aucM.bidderAddress][address(0)][msg.sender][aucM.id] = 0;
        
        itemsForSale[msg.sender][id - 1].bidderAddress = address(0);
        itemsForSale[msg.sender][id - 1].bidPrice = 0;
        itemsForSale[msg.sender][id - 1].bidItem = false;
        emit ItemSold(id, aucM.bidderAddress, aucM.bidPrice, 1, msg.sender);
    }

    function _endAuctionERC(uint256 id) internal{
        auc.AuctionItem memory aucM = itemsForSale[msg.sender][id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(aucM.ERC20);
        IERC721 Collection = IERC721(aucM.tokenAddress);
        address itemOwner = Collection.ownerOf(aucM.tokenId);
        //uint256 val = itemsForSale[id - 1].bidPrice;
        
        tokenERC.transfer(itemOwner, getAucRoyaltiesERC(aucM.bidPrice,Collection,aucM.tokenId,tokenERC));
        
        Collection.safeTransferFrom(itemOwner, aucM.bidderAddress, aucM.tokenId);
        checkOrder[aucM.tokenId][aucM.tokenAddress][itemOwner] = false;
        itemsForSale[msg.sender][id - 1].isSold = true;
        pendingReturns[aucM.bidderAddress][aucM.ERC20][msg.sender][aucM.id] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[msg.sender][id - 1].bidderAddress = address(0);
        itemsForSale[msg.sender][id - 1].bidPrice = 0;
        itemsForSale[msg.sender][id - 1].bidItem = false;
        itemsForSale[msg.sender][id - 1].ERC20 = address(0);
        emit ItemSold(id, aucM.bidderAddress, aucM.bidPrice, 1, msg.sender);
    }

    function _endAuctionOnly(uint256 id) internal{
        itemsForSale[msg.sender][id - 1].isSold = true;
        pendingReturns[itemsForSale[msg.sender][id - 1].bidderAddress][itemsForSale[msg.sender][id - 1].ERC20][msg.sender][itemsForSale[msg.sender][id - 1].id] = itemsForSale[msg.sender][id - 1].bidPrice;
        checkOrder[itemsForSale[msg.sender][id - 1].tokenId][itemsForSale[msg.sender][id - 1].tokenAddress][msg.sender] = false;
        itemsForSale[msg.sender][id - 1].askingPrice = 0;
        //itemsForSale[msg.sender][id - 1].itype[1] = 0;
        itemsForSale[msg.sender][id - 1].bidderAddress = address(0);
        itemsForSale[msg.sender][id - 1].bidPrice = 0;
        itemsForSale[msg.sender][id - 1].bidItem = false;
        //itemsForSale[msg.sender][id - 1].ERC20 = address(0);
    }
}

contract TrustMarketPlaceV1 is Initializable, marketplace{
    
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "0A");
        marketplaceOwner = newOwner;
        emit OwnershipTransferred(marketplaceOwner, newOwner);
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner{
        require(newFeeAddress != address(0), "0A");
        feeAddress = newFeeAddress;
    }
    
    function changeServiceFee(uint256 newFee) external onlyOwner{
        require(newFee < 3000, ">30%");
        serviceFee = newFee;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Staker{
    struct data{
        uint256 amountLocked;
        uint256 last;
        uint256 redeemed;
        bool status;
    }
}


contract stakeHorse is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Staker for Staker.data;
    using SafeMath for uint256;

    // ERC20 basic token contract being held
    IERC20Upgradeable private  _token;
    
    uint private activeUsers;
    address private owner;
    mapping(address => Staker.data) public stakers;
    uint256 private APY;
    uint256 updatedTime;
    uint256 public totalLocked;
    uint256 public totalRedeemed;
    uint256 private stakersLimit;
    uint256 public maturityDays;
    uint256 private minimum;
    
    event Staked(uint256 amount, address staker);
    
    function initialize(IERC20Upgradeable token_, uint256 apy0) public initializer  {
        _token = token_;
        owner = msg.sender;
        updatedTime = block.timestamp;
        
        // 100 = 1% or 10 = 0.1% or 1 = 0.01% 
        APY = apy0;
        maturityDays = 14;
        stakersLimit = 100000;
        minimum = 200 ether;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20Upgradeable) {
        return _token;
    }

    /**
     * Stake Amount in the contract.
     */
    function StakeAmount(uint256 _amount) public{
        require(stakersLimit > activeUsers,"Limit Exceeded");
        require(!stakers[msg.sender].status,"Already Staked");
        require(_amount >= minimum, "Low Amount");
        
        _locker(_amount);
        
    }
    
    function _locker(uint256 _amount) internal{
        token().safeTransferFrom(msg.sender, address(this), _amount);
        totalLocked += _amount;
        stakers[msg.sender].amountLocked = _amount;
        stakers[msg.sender].last = block.timestamp;
        stakers[msg.sender].status = true;
        activeUsers++;
        emit Staked(_amount,msg.sender);
    }
    
    function claimAble(address _stake) public view returns(uint256, uint256){
        require(stakers[_stake].status,'You are not a staker');
        Staker.data memory stakee = stakers[_stake];
        uint256 perDayReward = stakee.amountLocked.mul(APY).div(10000).div(365);
        uint256 claimableDays;
        if(stakee.last > updatedTime){
            claimableDays = block.timestamp.sub(stakee.last).div(1 days);
        }else{
            if(updatedTime > block.timestamp){
                claimableDays = 0;
            }else{
                claimableDays = block.timestamp.sub(updatedTime).div(1 days);
            }
        }
        return (claimableDays,perDayReward.mul(claimableDays));
    }

    function stakersActive() external view virtual returns (uint256) {
        return activeUsers;
    }
    
    /**
        * ClaimRewards:
        * Calculate and transfer rewards to staker, calculate reward from last reward time or update time 
        * if staking apy event occurs between staking period
     **/
    function redeem() public{
        require(msg.sender == tx.origin, 'Invalid');
        require(stakers[msg.sender].status, 'non staker');
        require(block.timestamp.sub(stakers[msg.sender].last).div(1 days) > maturityDays,'Rewards not matured');
        uint256 perDayReward = stakers[msg.sender].amountLocked.mul(APY).div(10000).div(365);
        uint256 claimableDays;
        
        if(stakers[msg.sender].last > updatedTime){
            claimableDays = block.timestamp.sub(stakers[msg.sender].last).div(1 days);
        }else{
            if(updatedTime > block.timestamp){
                claimableDays = 0;
            }else{
            	claimableDays = block.timestamp.sub(updatedTime).div(1 days);
            	require(claimableDays > maturityDays,'Rewards no matured');
            }
        }
        
        uint256 claimableReward = perDayReward.mul(claimableDays);
        require(claimableReward < RewardPot(), 'Reward Pot is empty');
        stakers[msg.sender].last = block.timestamp;
        stakers[msg.sender].redeemed += claimableReward;
        totalRedeemed += claimableReward;


        _token.safeTransfer(msg.sender,claimableReward);
    }
    
    function endStake() public{
        require(msg.sender == tx.origin, 'Invalid');
        require(stakers[msg.sender].status, 'non staker');
        uint256 claimableDays = block.timestamp.sub(stakers[msg.sender].last).div(1 days);
        uint256 claimableReward = 0;
        if(claimableDays > maturityDays){
            if(stakers[msg.sender].last < updatedTime){
                if(updatedTime > block.timestamp){
                    claimableDays = 0;
                }else{
                    claimableDays = block.timestamp.sub(updatedTime).div(1 days);
                }
            }
            if(claimableDays > maturityDays){
	            uint256 perDayReward = stakers[msg.sender].amountLocked.mul(APY).div(10000).div(365);
	            claimableReward = perDayReward.mul(claimableDays);
	            require(claimableReward < RewardPot(), 'Reward Pot is empty');
	        }
        }
        stakers[msg.sender].last = block.timestamp;
        stakers[msg.sender].redeemed += claimableReward;
        totalRedeemed += claimableReward;
        totalLocked -= stakers[msg.sender].amountLocked;
        
        activeUsers--;
        _token.safeTransfer(msg.sender, stakers[msg.sender].amountLocked+claimableReward);
        stakers[msg.sender].status = false;
        stakers[msg.sender].amountLocked = 0;
    }

    function emergencyEndstake() public{
        require(msg.sender == tx.origin, 'Invalid');
        require(stakers[msg.sender].status, 'non staker');
        totalLocked -= stakers[msg.sender].amountLocked;
        
        activeUsers--;
        _token.safeTransfer(msg.sender, stakers[msg.sender].amountLocked);
        stakers[msg.sender].status = false;
        stakers[msg.sender].amountLocked = 0;
    }

    function calculatePerDayRewards(uint256 amount) external view returns(uint256){
        uint256 perDayReward = amount.mul(APY).div(10000).div(365);
        return (perDayReward);
    }
    
    function RewardPot() public view virtual returns (uint256) {
        return token().balanceOf(address(this)) - totalLocked;
    }
    
    function withdrawRewardsPot(uint256 amount) external onlyOwner {
        require(amount < RewardPot(), 'Insufficient');
        _token.safeTransfer(msg.sender, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner{
    	require(newOwner != address(0), "ZeroAddress");
    	owner = newOwner;
    }
    
    function setToken(IERC20Upgradeable Token_) external onlyOwner {
        _token = Token_;
    }

    //For Testing Purpose
    function changeLastRewardTime(uint256 _lastrewardTime) external onlyOwner{
        stakers[msg.sender].last = _lastrewardTime;
    }

    function changeStakersLimit(uint256 _limit) external onlyOwner{
        require(_limit > 0,"> 0");
        stakersLimit = _limit;
    }

    function changeMinimum(uint256 _minimum) external onlyOwner{
    	require(_minimum > 0,"> 0");
        minimum = _minimum;
    }

    function changeMaturityDays(uint256 _days) external onlyOwner{
    	require(_days > 0,"> 0");
        maturityDays = _days;
    }

    function currentTimestamp() external view returns(uint256){
        return block.timestamp;
    }
    
    /**
     * Change APY Functions:
     * Change APY with update time , so every staker should need to claim their rewards,
     * before any change apy event occurs
    **/
    function changeStakingAPY(uint256 newAPY, uint256 _stoppedTill) public onlyOwner{
        require(newAPY < 150000, '> 1500%');
        APY = newAPY;
        updatedTime = _stoppedTill;
    }
    
}