/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: contracts/utils/TokenAccessControl.sol


pragma solidity >=0.7.0 <0.9.0;

contract TokenAccessControl {

    bool public paused = false;
    address public owner;
    address public newContractOwner;
    mapping(address => bool) public authorizedContracts;

    event Pause();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
    }

    modifier ifNotPaused {
        require(!paused, "Ownable: contract is paused");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuthorizedContract {
        require(authorizedContracts[msg.sender], "Ownable: caller is authorized contract");
        _;
    }

    modifier onlyOwnerOrAuthorizedContract {
        require(authorizedContracts[msg.sender] || msg.sender == owner, "Ownable: caller is authorized contract or owner");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newContractOwner = _newOwner;
    }

    function acceptOwnership() public ifNotPaused {
        require(msg.sender == newContractOwner);
        emit OwnershipTransferred(owner, newContractOwner);
        owner = newContractOwner;
        newContractOwner = address(0);
    }

    function setAuthorizedContract(address _operator, bool _approve) public onlyOwner {
        if (_approve) {
            authorizedContracts[_operator] = true;
        } else {
            delete authorizedContracts[_operator];
        }
    }

    function setPause(bool _paused) public onlyOwner {
        paused = _paused;
        if (paused) {
            emit Pause();
        }
    }

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
// File: contracts/qorpoMarket/marketMinting.sol


pragma solidity >=0.7.0 <0.9.0;



interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId)  external;
    function mintTo(address _to, address _royaltyReceiver)  external;
}

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function mintTo( address _to, uint256 _tokenId, uint256 _amount)  external;
}


contract MarketMinting is TokenAccessControl {
    using Counters for Counters.Counter;
    struct Offer {
        address nftAddress;
        uint256 nftTokenId; // 0 for erc721
        uint256 amount; // always 1 for erc721
        address paymentTokenAddress;
        uint256 price;
        uint256 fee;
        address seller;
        address buyer;
        address royaltyReceiver;
        uint createdAtBlock;
    }
    Counters.Counter private offerId;
    mapping (uint256 => Offer) offers;
    uint _offerValidityBlocks = 100;

    uint8 constant _ERC20 = 1;
    uint8 constant _ERC721 = 2;
    uint8 constant _ERC1155 = 3;
   
    bytes4 constant private IERC165_ID = 0x01ffc9a7;
    bytes4 constant private IERC1155_ID = 0xd9b67a26;
    bytes4 constant private IERC721_ID = 0x80ac58cd;
    bytes4 constant private IERC2981_ID = 0x2a55205a;

    event CreateMarketMintingOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId, uint256 amount,
     address paymentTokenAddress, uint256 price, uint256 fee, address seller, address buyer, address royaltyReceiver);
    event BuyMarketMintingOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId,
     uint256 amount, address paymentTokenAddress, uint256 price, address seller, address buyer, address royaltyReceiver);
    event CancelMarketMintingOffer(uint256 indexed offerId, address nftAddress, uint256 nftTokenId, uint256 amount, address seller, address buyer);
    event RoyaltyPayment(address from, address indexed to, address indexed tokenAddress, uint256 indexed amount, address nftAddress, uint256 tokenId);
    constructor() {
    }

    function createOffer(address nftAddress, uint256 nftTokenId, uint256 amount, address paymentTokenAddress,
     uint256 price, uint256 fee, address seller, address buyer, address royaltyReceiver) external onlyOwner returns (uint256 _offerId) {
        offerId.increment();
        require(price>0, "price should be greater than 0");
        require(fee>=0, "fee cannot be negative");
        require(fee<price, "fee cannot be greather than the price");
        offers[offerId.current()] = Offer(nftAddress, nftTokenId, amount, paymentTokenAddress, price, fee, seller, buyer, royaltyReceiver, block.number);
        emit CreateMarketMintingOffer(offerId.current(), nftAddress, nftTokenId, amount, paymentTokenAddress, price, fee,  seller, buyer, royaltyReceiver);
        return offerId.current();
    }

    function buyOffer(uint256 _offerId) external payable {
        Offer memory offer = offers[_offerId];
        require(offer.seller != address(0), "offer is not valid");
        require(offer.buyer == msg.sender, "you are not eligible to buy this offer");
        require(offer.createdAtBlock+_offerValidityBlocks >= block.number, "offer is not valid");
        delete offers[_offerId];
        uint256 royaltyAmount = 0;
        address royaltyReceiver = address(0);
        uint256 priceAfterFee = offer.price - offer.fee;

        if(IERC165(offer.nftAddress).supportsInterface(IERC1155_ID)){
            IERC1155(offer.nftAddress).mintTo(msg.sender, offer.nftTokenId, offer.amount);
        }
        else{
            IERC721(offer.nftAddress).mintTo(msg.sender, offer.royaltyReceiver);
        }

        if(IERC165(offer.nftAddress).supportsInterface(IERC2981_ID)){
            (royaltyReceiver, royaltyAmount) = IERC2981(offer.nftAddress).royaltyInfo(offer.nftTokenId, priceAfterFee);
        }
        if(offer.paymentTokenAddress!=address(0)){
            IERC20(offer.paymentTokenAddress).transferFrom(msg.sender, offer.seller, priceAfterFee-royaltyAmount);
            if(royaltyAmount != 0){
                IERC20(offer.paymentTokenAddress).transferFrom(msg.sender, royaltyReceiver, royaltyAmount);
                emit RoyaltyPayment(msg.sender, royaltyReceiver, offer.paymentTokenAddress, royaltyAmount, offer.nftAddress,
                offer.nftTokenId);
            }
            if(offer.fee!=0){
                IERC20(offer.paymentTokenAddress).transferFrom(msg.sender, address(this), offer.fee);
            }
        }
        else{
            require(msg.value >= offer.price, "insufficient funds for buy");
            if(priceAfterFee-royaltyAmount>0){
                payable(offer.seller).transfer(priceAfterFee-royaltyAmount);
            }
            if(royaltyAmount > 0){
                payable(royaltyReceiver).transfer(royaltyAmount);
                emit RoyaltyPayment(msg.sender, royaltyReceiver, offer.paymentTokenAddress, royaltyAmount, offer.nftAddress,
                offer.nftTokenId);
            }
        }
        emit BuyMarketMintingOffer(_offerId, offer.nftAddress, offer.nftTokenId, offer.amount, offer.paymentTokenAddress, offer.price,
        offer.seller, offer.buyer, offer.royaltyReceiver);
    }

    function cancelOffer(uint256 _offerId) public onlyOwner{
        require(offers[_offerId].seller != address(0), "offer is not valid");
        Offer memory offer = offers[_offerId];
        delete offers[_offerId];
        emit CancelMarketMintingOffer(_offerId, offer.nftAddress, offer.nftTokenId, offer.amount, offer.seller, offer.buyer);
    }

    function setOfferValidity(uint blockCountValidity) public onlyOwner{
        _offerValidityBlocks = blockCountValidity;
    }

    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return (_interfaceID == IERC165_ID);
    }

    receive() external payable {

    }

    fallback() external payable {

    }

    function withdraw(address contractAddress, uint8 standard, uint256 tokenId, uint256 amount) public onlyOwner{
        if(contractAddress==address(0)){
            payable(msg.sender).transfer(amount);
        }
        else if(standard==_ERC20){
            if(amount==0) amount = IERC20(contractAddress).balanceOf(address(this));
            IERC20(contractAddress).transfer(msg.sender, amount);
        }
        else if(standard==_ERC721){
            IERC721(contractAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        }
        else if(standard==_ERC1155){
            if(amount==0) amount = IERC1155(contractAddress).balanceOf(address(this), tokenId);
            IERC1155(contractAddress).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        }
    }
}