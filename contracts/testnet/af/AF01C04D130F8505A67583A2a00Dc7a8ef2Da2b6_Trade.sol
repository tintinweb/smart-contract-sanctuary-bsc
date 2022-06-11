// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;


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

/**
 * @dev Required interface of an ERC721 compliant contract.
*/

interface IERC721 is IERC165 {

    function royaltyFee(uint256 tokenId) external view returns(uint256);
    function getCreator(uint256 tokenId) external view returns(address);
    function mintNFTLoot(address from,uint256[] calldata tokenIds, uint256[] calldata tokenTypes) external returns (bool);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */

    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */

    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1155 is IERC165 {

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    function royaltyFee(uint256 tokenId) external view returns(uint256);
    function getCreator(uint256 tokenId) external view returns(address);

}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
*/

interface IERC20 {

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
    */ 

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}
  

contract TransferProxy {

    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external  {
        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 id, uint256 value, bytes calldata data)external  {
        token.safeTransferFrom(from, to, id, value, data);
    }
    
    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external  {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }   
}

contract Trade {

    enum BuyingAssetType {ERC721}
    // Token Rarity
    enum TokenRarityType {Common, Uncommon, Rare, Epic, Legendary} 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event signerTransferred(address indexed previousOwner, address indexed newOwner);
    event SellerFee(uint8 sellerFee);
    event BuyerFee(uint8 buyerFee);
    event MintingFee(uint256 fee);
    event Paid(address sender, address admin, uint256 amount);
    event BuyAsset(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event Assetmint(address indexed from,uint256[] tokenIds);

    uint8 private buyerFeePermille;
    uint8 private sellerFeePermille;
    uint256[20000] private array;
    uint256 private length = 20000;
    uint256 private randNum;

    uint256 public mintingFee = 0.2 * 10 ** 18;

    TransferProxy public transferProxy;
    address public owner;
    address public signer;
    mapping(uint256 => bool) private usedNonce;
    mapping (uint256 => TokenRarityType) private tokenId2Rarity ;
    mapping (uint256 => TokenRarityType) private tokenType2Rarity ;
 
    struct Fee {
        uint platformFee;
        uint assetFee;
        uint royaltyFee;
        uint price;
        address tokenCreator;
    }

    /* An ECDSA signature. */
    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    struct Order {
        address seller;
        address buyer;
        address erc20Address;
        address nftAddress;
        BuyingAssetType nftType;
        uint unitPrice;
        uint amount;
        uint tokenId;
        uint qty;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
  
    constructor (uint8 _buyerFee, uint8 _sellerFee, TransferProxy _transferProxy) {
        buyerFeePermille = _buyerFee;
        sellerFeePermille = _sellerFee;
        transferProxy = _transferProxy;
        owner = msg.sender; 
        signer = msg.sender;
        tokenType2Rarity[1] = TokenRarityType.Common;
        tokenType2Rarity[2] = TokenRarityType.Common;
        tokenType2Rarity[3] = TokenRarityType.Common;
        tokenType2Rarity[4] = TokenRarityType.Uncommon;
        tokenType2Rarity[5] = TokenRarityType.Uncommon;
        tokenType2Rarity[6] = TokenRarityType.Rare;
        tokenType2Rarity[7] = TokenRarityType.Rare;
        tokenType2Rarity[8] = TokenRarityType.Epic;
        tokenType2Rarity[9] = TokenRarityType.Epic;
        tokenType2Rarity[10] = TokenRarityType.Legendary;
    }

    function buyerServiceFee() external view virtual returns (uint8) {
        return buyerFeePermille;
    }

    function sellerServiceFee() external view virtual returns (uint8) {
        return sellerFeePermille;
    }

    function setMintingfee(uint256 fee) external onlyOwner returns(bool) {
        mintingFee = fee;
        emit MintingFee(mintingFee);
        return true;
    }

    function setBuyerServiceFee(uint8 _buyerFee) external onlyOwner returns(bool) {
        buyerFeePermille = _buyerFee;
        emit BuyerFee(buyerFeePermille);
        return true;
    }

    function setSellerServiceFee(uint8 _sellerFee) external onlyOwner returns(bool) {
        sellerFeePermille = _sellerFee;
        emit SellerFee(sellerFeePermille);
        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    function changeSigner(address newSigner) external onlyOwner returns(bool){
        require(newSigner != address(0), "Ownable: new owner is the zero address");
        emit signerTransferred(signer, newSigner);
        signer = newSigner;
        return true;
    }

    function getSigner(bytes32 hash, Sign memory sign) internal pure returns(address) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s); 
    }

    function verifySellerSign(address seller, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, Sign memory sign) internal pure {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount, sign.nonce));
        require(seller == getSigner(hash, sign), "seller sign verification failed");
    }

    function verifyBuyerSign(address buyer, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, uint qty, Sign memory sign) internal pure {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount,qty, sign.nonce));
        require(buyer == getSigner(hash, sign), "buyer sign verification failed");
    }

    function verifySign(uint256 tokenLength,uint256 seed,Sign memory sign) internal view  {
        bytes32 hash = keccak256(abi.encodePacked(address(this),tokenLength, msg.sender, seed, sign.nonce));
        require(signer == getSigner(hash, sign),"Sign: owner sign verification failed");
    }

    function getFees(uint paymentAmt, BuyingAssetType buyingAssetType, address buyingAssetAddress, uint tokenId) internal view returns(Fee memory){
        address tokenCreator;
        uint platformFee;
        uint royaltyFee;
        uint assetFee;
        uint royaltyPermille;
        uint price = paymentAmt * 1000 / (1000 + buyerFeePermille);
        uint buyerFee = paymentAmt - price;
        uint sellerFee = price * sellerFeePermille / 1000;
        platformFee = buyerFee + sellerFee;
        if(buyingAssetType == BuyingAssetType.ERC721) {
            royaltyPermille = ((IERC721(buyingAssetAddress).royaltyFee(tokenId)));
            tokenCreator = ((IERC721(buyingAssetAddress).getCreator(tokenId)));
        }
        royaltyFee = price * royaltyPermille / 1000;
        assetFee = price - royaltyFee - sellerFee;
        return Fee(platformFee, assetFee, royaltyFee, price, tokenCreator);
    }

    function tradeAsset(Order calldata order, Fee memory fee, address buyer, address seller) internal virtual {
        if(order.nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), seller, buyer, order.tokenId);
        }
        if(fee.platformFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, owner, fee.platformFee);
        }
        if(fee.royaltyFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, fee.tokenCreator, fee.royaltyFee);
        }
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, seller, fee.assetFee);
    }

    function buyAsset(Order calldata order, Sign calldata sign) external returns(bool) {
        require(!usedNonce[sign.nonce],"Nonce : Invalid Nonce");
        usedNonce[sign.nonce] = true;
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        address buyer = msg.sender;
        tradeAsset(order, fee, buyer, order.seller);
        emit BuyAsset(order.seller, order.tokenId, order.qty, msg.sender);
        return true;
    }

    function executeBid(Order calldata order, Sign calldata sign) external returns(bool) {
        require(!usedNonce[sign.nonce],"Nonce : Invalid Nonce");
        usedNonce[sign.nonce] = true;
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty, sign);
        address seller = msg.sender;
        tradeAsset(order, fee, order.buyer, seller);
        emit ExecuteBid(msg.sender , order.tokenId, order.qty, order.buyer);
        return true;
    }
   
    function getRandom(uint256 salt) private returns(uint256) {
            require(length != 0,"Minting limit exceeds");
            uint256 rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, salt)));
            uint256 randId = rand % length;
            if(array[randId] == 0)
                randNum = randId;
            else
                randNum = array[randId];       
            array[randId] =  array[length-1] == 0 ? length-1 : array[length-1];
            delete array[length-1];
            length--;
            return randNum;
    }

    function getNumber(uint256 salt,uint256 tokenLength) internal returns(uint256[] memory){
        uint256[] memory result = new uint256[](tokenLength);
        for(uint256 i = 0; i < tokenLength; i++){
            result[i] = getRandom(salt)+1;
        }
        return result;    
    }

    function getCategory(uint256 tokenId) internal pure returns(uint256) {
        require(tokenId > 0 && tokenId <= 20000,"tokenId must be greater than zero");
        if((tokenId >= 1 )&&(tokenId<=3800)){
            return 1;
        }
        else if((tokenId >=3801)&&(tokenId<=7600)){
            return 2;
        }
        else if((tokenId >=7601)&&(tokenId<=11400)){
            return 3;
        }
        else if((tokenId >=11401)&&(tokenId<=13900)){
            return 4;
        }
        else if((tokenId >=13901)&&(tokenId<=16400)){
            return 5;
        }
        else if((tokenId >=16401)&&(tokenId<=17700)){
            return 6;
        }
        else if((tokenId >=17701)&&(tokenId<=19000)){
            return 7;
        }
        else if((tokenId >=19001)&&(tokenId<=19460)){
            return 8;
        }
        else if((tokenId >=19461)&&(tokenId<=19920)){
            return 9;
        }
        else if((tokenId >=19921)&&(tokenId<=20000)){
            return 10;
        }
        
        return 99;
    }

    function getTokenType(uint256[] memory tokenIds) internal pure returns(uint256[] memory){
        uint256[] memory tokenRarity = new uint256[](tokenIds.length);
        require(tokenIds.length <= 10, "TokenIds length must be 10");
        for(uint256 i = 0;i<tokenIds.length; i++){
            tokenRarity[i] = getCategory(tokenIds[i]);
        }
        return tokenRarity;   
    }
    
    function getFee(uint256 fee) internal returns(bool){
        if((payable(owner).send(fee))){
            emit Paid(msg.sender, owner, fee);
            return true;
        }    
        return false;
    }

    function mint(address nftaddress, uint256 tokenLength, uint256 seed, Sign memory sign) external payable returns(uint256[] memory tokenId){
        uint256[] memory tokenRarity = new uint256[](tokenLength);
        require(seed != 0, "Seed value must be greater than zero");
        require(tokenLength <= 10, "Max limit : 10 Mint in a Batch") ;
        bool isPaid = getFee(mintingFee * tokenLength);
        require(isPaid, "failed on transfer");
        verifySign(tokenLength, seed, sign);
        tokenId = getNumber(seed, tokenLength);
        tokenRarity =  getTokenType(tokenId);
        IERC721(nftaddress).mintNFTLoot(msg.sender, tokenId, tokenRarity);
        emit Assetmint(msg.sender, tokenId);
        return tokenId;
    }
}