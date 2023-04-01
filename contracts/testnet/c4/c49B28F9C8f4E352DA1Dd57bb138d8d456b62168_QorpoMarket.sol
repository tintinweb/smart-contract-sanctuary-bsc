/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: contracts/interfaces/IERC721Receiver.sol



pragma solidity >= 0.8.0 <0.9.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// File: contracts/standards/ERC721Holder.sol


pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// File: contracts/interfaces/IERC20.sol



pragma solidity >= 0.8.0 <0.9.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// File: contracts/interfaces/IERC165.sol



pragma solidity >= 0.8.0 <0.9.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// File: contracts/standards/ERC165.sol



pragma solidity >=0.8.0 <0.9.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// File: contracts/interfaces/IERC1155Receiver.sol



pragma solidity >= 0.8.0 <0.9.0;



interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// File: contracts/standards/ERC1155Receiver.sol


pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
// File: contracts/standards/ERC1155Holder.sol



pragma solidity ^0.8.0;


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
// File: contracts/interfaces/IERC721.sol



pragma solidity >= 0.8.0 <0.9.0;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// File: contracts/interfaces/IERC1155.sol



pragma solidity >= 0.8.0 <0.9.0;


interface IERC1155 is IERC165 {
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
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// File: contracts/utils/Counters.sol



pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value;
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
// File: contracts/utils/Ownable.sol


pragma solidity >=0.8.0 <0.9.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _changeOwner(msg.sender);
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function renounceOwnership() public virtual onlyOwner {
        _changeOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function _changeOwner(address newOwner) internal virtual {
        address old = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(old, newOwner);
    }
}
// File: contracts/qorpoMarket/qorpoMarket.sol


pragma solidity >=0.7.0 <0.9.0;









interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

contract QorpoMarket is Ownable, ERC1155Holder, ERC721Holder{
    using Counters for Counters.Counter;
    struct Offer{
        address nftAddress;
        uint256 nftTokenId;
        uint256 amount;
        address seller;
        uint256 createdAt;
    }
    uint8 _ERC20 = 1;
    uint8 _ERC721 = 2;
    uint8 _ERC1155 = 3;
    uint16 marketFeePerMille = 0;
    Counters.Counter private offerId;
    mapping(uint256 => Offer) offers;
    mapping (uint256 => mapping (address => uint256)) public offerPrices;


    event CreateMarketOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId,
     address[] paymentCurrencies, uint256[] paymentPrices, uint256 amount, address seller);
    event BuyMarketOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId,
     address paymentCurrency, uint256 price, uint256 amount, address seller);
    event CancelMarketOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId, uint256 amount, address seller);
    event RoyaltyPayment(address from, address indexed to, address indexed tokenAddress, uint256 indexed amount, address nftAddress, uint256 tokenId);

    function createOffer(address[] calldata paymentCurrencies, uint256[] calldata paymentPrices, address nftAddress, uint256 nftTokenId, uint256 amount)
    public returns (uint256){   
        require(paymentCurrencies.length <= 5, "Market: only up to 5 payment options are allowed");
        require(amount>0, "Market: amount should be greater than 0");
        require(paymentCurrencies.length>0, "Market: offer must have at least 1 payment option");
        uint8 contractType = determineContractType(nftAddress);
        if(contractType==2){
            require(amount==1, "Market: amount has to be equal to 1 in case of ERC721");
            IERC721(nftAddress).transferFrom(msg.sender, address(this), nftTokenId);
        }
        else if(contractType==3){
            IERC1155(nftAddress).safeTransferFrom(msg.sender, address(this), nftTokenId, amount, "");
        }
        else{
            revert("Market: Not valid NFT standard");
        }
        offerId.increment();
        require(paymentCurrencies.length==paymentPrices.length, "Market: payment addresses must have same lenght as prices");
        for (uint i=0; i<paymentCurrencies.length; i++){
             require(paymentPrices[i]>0, "Market: price should be greater than 0");
             offerPrices[offerId.current()][paymentCurrencies[i]] = paymentPrices[i];       
        }
        offers[offerId.current()] = Offer(nftAddress, nftTokenId, amount, msg.sender, block.number);
        emit CreateMarketOffer(offerId.current(), nftAddress, nftTokenId, paymentCurrencies, paymentPrices, amount, msg.sender);
        return offerId.current();
    }

    function buyOffer(uint256 _offerId, address paymentCurrency) public payable{
        require(offers[_offerId].createdAt != 0, "Market: offer is not valid");
        require(offerPrices[_offerId][paymentCurrency] != 0, "Market: ivalid payment token address");
        Offer memory offer = offers[_offerId];
        delete offers[_offerId];
        uint price = offerPrices[_offerId][paymentCurrency];
        uint256 priceAfterFee = uint256(price*(1000-marketFeePerMille)/1000);
        uint256 royaltyAmount = 0;
        address royaltyReceiver = address(0);
        if(IERC165(offer.nftAddress).supportsInterface(0x2a55205a)){
            (royaltyReceiver, royaltyAmount) = IERC2981(offer.nftAddress).royaltyInfo(offer.nftTokenId, priceAfterFee);
        }
        if(paymentCurrency!=address(0)){
            if(priceAfterFee-royaltyAmount>0){
                IERC20(paymentCurrency).transferFrom(msg.sender, offer.seller, priceAfterFee-royaltyAmount);
            }
            if(price-priceAfterFee > 0){
                IERC20(paymentCurrency).transferFrom(msg.sender, address(this), price-priceAfterFee);
            }
            if(royaltyAmount != 0){
                IERC20(paymentCurrency).transferFrom(msg.sender, royaltyReceiver, royaltyAmount);
                emit RoyaltyPayment(msg.sender, royaltyReceiver, paymentCurrency, royaltyAmount, offer.nftAddress,
                offer.nftTokenId);
            }
        }
        else{
            require(msg.value >= price, "Market: not enough natives send");
            if(priceAfterFee-royaltyAmount>0){
                payable(offer.seller).transfer(priceAfterFee-royaltyAmount);
            }
            if(royaltyAmount != 0){
                payable(royaltyReceiver).transfer(royaltyAmount);
                emit RoyaltyPayment(msg.sender, royaltyReceiver, paymentCurrency, royaltyAmount, offer.nftAddress,
                offer.nftTokenId);
            }
        }
        uint8 contractType = determineContractType(offer.nftAddress);
        if(contractType==2){
            IERC721(offer.nftAddress).transferFrom(address(this), msg.sender, offer.nftTokenId);
        }
        else{
            IERC1155(offer.nftAddress).safeTransferFrom(address(this), msg.sender, offer.nftTokenId, offer.amount, "");
        }
        emit BuyMarketOffer(_offerId, offer.nftAddress, offer.nftTokenId, paymentCurrency, price, offer.amount, msg.sender);
    }
    function cancelOffer(uint256 _offerId) public{
        require(offers[_offerId].createdAt != 0, "Market: offer is not valid");
        require(offers[_offerId].seller == msg.sender, "Market: you are not eligible for refund");
        Offer memory offer = offers[_offerId];
        delete offers[_offerId];
        uint8 contractType = determineContractType(offer.nftAddress);
        if(contractType==2){
            IERC721(offer.nftAddress).transferFrom(address(this), msg.sender, offer.nftTokenId);
        }
        else{
            IERC1155(offer.nftAddress).safeTransferFrom(address(this), msg.sender, offer.nftTokenId, offer.amount, "");
        }
        emit CancelMarketOffer(_offerId, offer.nftAddress, offer.nftTokenId, offer.amount, msg.sender);
    }
    function getOffer(uint256 _offerId) public view returns(Offer memory){
        return offers[_offerId];
    }

    function getOfferCreator(uint256 _offerId) public view returns(address){
        return offers[_offerId].seller;
    }

    function withdraw(address contract_address, uint8 standard, uint256 tokenId, uint256 amount) public onlyOwner{
        if(contract_address==address(0)){
            payable(msg.sender).transfer(amount);
        }
        else if(standard==_ERC20){
            if(amount==0) amount = IERC20(contract_address).balanceOf(address(this));
            IERC20(contract_address).transfer(msg.sender, amount);
        }
        else if(standard==_ERC721){
            IERC721(contract_address).transferFrom(address(this), msg.sender, tokenId);
        }
        else if(standard==_ERC1155){
            if(amount==0) amount = IERC1155(contract_address).balanceOf(address(this), tokenId);
            IERC1155(contract_address).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        }
        
    }

    function getMarketFeePerMille() public view returns(uint16){
        return marketFeePerMille;
    }

    function setMarketFee(uint16 newFeePerMille) public onlyOwner{
        require(newFeePerMille >= 0 && newFeePerMille<=1000, "Market: invalid fee value");
        marketFeePerMille = newFeePerMille;
    }

    function determineContractType(address contractAddress) internal view returns(uint8){
        bytes4 IERC1155_ID = 0xd9b67a26;
        bytes4 IERC721_ID = 0x80ac58cd;
        (bool isSuccess, bytes memory response) = contractAddress.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)",IERC1155_ID));
        if(isSuccess){
            if(abi.decode(response, (bool)))return 3;
            (isSuccess,response) = contractAddress.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)",IERC721_ID));
            if(isSuccess && abi.decode(response, (bool))) return 2;
        }
        (isSuccess,) = contractAddress.staticcall(abi.encodeWithSignature("balanceOf(address,uint256)",msg.sender, 1));
        if(isSuccess) return 3;
        (isSuccess,) = contractAddress.staticcall(abi.encodeWithSignature("balanceOf(address)",msg.sender));
        if(isSuccess){
            (isSuccess,) = contractAddress.staticcall(abi.encodeWithSignature("decimals()"));
            if(isSuccess) return 1;
            return 2;
        }
        return 0;
    } 
}