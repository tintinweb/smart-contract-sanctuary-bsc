/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// File: Trade.sol


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

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 id, uint256 value, bytes calldata data) external  {
        token.safeTransferFrom(from, to, id, value, data);
    }
    
    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external  {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }   
}

contract Trade {

    enum BuyingAssetType {ERC1155, ERC721}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event signerAddressTransferred(address indexed previousSigner, address indexed newSigner);
    event SellerFee(uint8 sellerFee);
    event BuyerFee(uint8 buyerFee);
    event BuyAsset(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event CancelBid(address buyer , uint256 nonce);

    uint8 private buyerFeePermille;
    uint8 private sellerFeePermille;
    TransferProxy public transferProxy;
    address public owner;
    address public signer;
    mapping(uint256 => bool) private usedNonce;
    mapping (uint256 => Asset1155) private users;

    struct Asset1155 {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 supply;
        bool initialize;
    }

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
    }

    function buyerServiceFee() external view virtual returns (uint8) {
        return buyerFeePermille;
    }

    function sellerServiceFee() external view virtual returns (uint8) {
        return sellerFeePermille;
    }
    
    function getNonceQuantity(uint256 nonce) external view returns(uint256) {
        return users[nonce].supply;
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

    function setSignerAddress(address newSigner) external returns(bool){
        require(msg.sender == signer, "caller is not signer");
        require(newSigner != address(0), "Signer: new signer is the zero address");
        emit signerAddressTransferred(signer, newSigner);
        signer = newSigner;
        return true;
    }
        function getFees(uint paymentAmt, BuyingAssetType buyingAssetType, address buyingAssetAddress, uint tokenId) public view returns(Fee memory){
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
        if(buyingAssetType == BuyingAssetType.ERC1155)  {
            royaltyPermille = ((IERC1155(buyingAssetAddress).royaltyFee(tokenId)));
            tokenCreator = ((IERC1155(buyingAssetAddress).getCreator(tokenId)));
        }
        royaltyFee = price * royaltyPermille / 1000;
        assetFee = price - royaltyFee - sellerFee;
        return Fee(platformFee, assetFee, royaltyFee, price, tokenCreator);
    }

    function getSigner(bytes32 hash, Sign memory sign) internal pure returns(address) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s); 
    }

    function verifySellerSign(address seller, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, Sign memory sign) public pure  {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount, sign.nonce));
        require(seller == getSigner(hash, sign), "seller sign verification failed");
    }

    function verifyBuyerSign(address buyer, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, uint qty, Sign memory sign) internal pure {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount,qty, sign.nonce));
        require(buyer == getSigner(hash, sign), "buyer sign verification failed");
    }

    function verifyOwnerSign(Sign memory sign, address caller, Sign memory ownerSign) internal view {
        bytes memory encodeData = abi.encode(sign.v, sign.r, sign.s, sign.nonce); 
        bytes32 hash = keccak256(abi.encodePacked(encodeData, caller, ownerSign.nonce));
        require(signer == getSigner(hash, ownerSign), "owner sign verification failed");
    }

    function tradeAsset(Order calldata order, Fee memory fee, address buyer, address seller) internal  {
        if(order.nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), seller, buyer, order.tokenId);
        }
        if(order.nftType == BuyingAssetType.ERC1155)  {
            transferProxy.erc1155safeTransferFrom(IERC1155(order.nftAddress), seller, buyer, order.tokenId, order.qty, ""); 
        }
        if(fee.platformFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, owner, fee.platformFee);
        }
        if(fee.royaltyFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, fee.tokenCreator, fee.royaltyFee);
        }
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, seller, fee.assetFee);
    }

    function buyAsset(Order calldata order, uint256 supply, Sign calldata sign, Sign calldata ownerSign) external returns(bool) {
        require(!usedNonce[sign.nonce],"Nonce: Invalid Nonce");
        if(order.nftType == BuyingAssetType.ERC721) {
            usedNonce[sign.nonce] = true;
        }
        else if(order.nftType == BuyingAssetType.ERC1155) {
              if(users[sign.nonce].initialize){
                require(users[sign.nonce].nftAddress == order.nftAddress && users[sign.nonce].seller == order.seller && users[sign.nonce].tokenId == order.tokenId, "Nonce: Invalid Data");
                require(users[sign.nonce].supply >= order.qty, "Invalid Quantity");
                users[sign.nonce].supply -= order.qty;
                if (users[sign.nonce].supply == 0)
                    usedNonce[sign.nonce] = true;
            }
            else if(!users[sign.nonce].initialize) {
                require(supply >= order.qty, "Invalid Quantity");
                users[sign.nonce] = Asset1155(order.seller, order.nftAddress, order.tokenId, supply - order.qty, true);
            }
        }
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifyOwnerSign(sign, msg.sender, ownerSign);
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        address buyer = msg.sender;
        tradeAsset(order, fee, buyer, order.seller);
        emit BuyAsset(order.seller, order.tokenId, order.qty, msg.sender);
        return true;
    }

    function executeBid(Order calldata order, Sign calldata sign) external returns(bool) {
        require(!usedNonce[sign.nonce],"Nonce: Invalid Nonce");
        usedNonce[sign.nonce] = true;
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty, sign);
        address seller = msg.sender;
        tradeAsset(order, fee, order.buyer, seller);
        emit ExecuteBid(msg.sender , order.tokenId, order.qty, order.buyer);
        return true;
    }
    function cancelBid(uint256 nonce) external {
    // Check that the bidder is the msg.sender
    require(users[nonce].seller == msg.sender, "Bidder is not the msg.sender");

    // Check that the asset has not been initialized yet
    require(!users[nonce].initialize, "Asset has already been initialized");

    // Check that the nonce has not been used before
    require(usedNonce[nonce] == false, "Nonce has already been used");

    // Mark the nonce as used
    usedNonce[nonce] = true;

    // Emit an event to indicate that the bid has been cancelled
    emit CancelBid(msg.sender, nonce);
}
}