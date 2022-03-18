// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;

import "./libraries/SafeMath.sol";
import "./TransferProxy.sol";

contract Trade {
    using SafeMath for uint256;

    enum BuyingAssetType {ERC1155, ERC721}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SellerFee(uint8 sellerFee);
    event BuyerFee(uint8 buyerFee);
    event BuyAsset(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);

    uint8 private buyerFeePermille;
    uint8 private sellerFeePermille;
    TransferProxy public transferProxy;
    address public owner;
    mapping(uint256 => bool) private usedNonce;

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
    }

    function buyerServiceFee() public view virtual returns (uint8) {
        return buyerFeePermille;
    }

    function sellerServiceFee() public view virtual returns (uint8) {
        return sellerFeePermille;
    }

    function setBuyerServiceFee(uint8 _buyerFee) public onlyOwner returns(bool) {
        buyerFeePermille = _buyerFee;
        emit BuyerFee(buyerFeePermille);
        return true;
    }

    function setSellerServiceFee(uint8 _sellerFee) public onlyOwner returns(bool) {
        sellerFeePermille = _sellerFee;
        emit SellerFee(sellerFeePermille);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    function getSigner(bytes32 hash, Sign memory sign) internal pure returns(address) {
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s);
    }

    function verifySellerSign(address seller, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, Sign memory sign) internal pure {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount));
        require(seller == getSigner(hash, sign), "seller sign verification failed");
    }

    function verifyBuyerSign(address buyer, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, uint qty, Sign memory sign) internal pure {
        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount,qty));
        require(buyer == getSigner(hash, sign), "buyer sign verification failed");
    }

    function getFees(uint paymentAmt, BuyingAssetType buyingAssetType, address buyingAssetAddress, uint tokenId) internal view returns(Fee memory){
        address tokenCreator;
        uint platformFee;
        uint royaltyFee;
        uint assetFee;
        uint royaltyPermille;
        uint price = paymentAmt.mul(1000).div((1000+buyerFeePermille));
        uint buyerFee = paymentAmt.sub(price);
        uint sellerFee = price.mul(sellerFeePermille).div(1000);
        platformFee = buyerFee.add(sellerFee);
        if(buyingAssetType == BuyingAssetType.ERC721) {
            royaltyPermille = ((IERC721(buyingAssetAddress).royaltyFee(tokenId)));
            tokenCreator = ((IERC721(buyingAssetAddress).getCreator(tokenId)));
        }
        if(buyingAssetType == BuyingAssetType.ERC1155)  {
            royaltyPermille = ((IERC1155(buyingAssetAddress).royaltyFee(tokenId)));
            tokenCreator = ((IERC1155(buyingAssetAddress).getCreator(tokenId)));
        }
        royaltyFee = price.mul(royaltyPermille).div(1000);
        assetFee = price.sub(royaltyFee).sub(sellerFee);
        return Fee(platformFee, assetFee, royaltyFee, price, tokenCreator);
    }


    function tradeAsset(Order memory order, Fee memory fee) internal virtual {
        if(order.nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), order.seller, order.buyer, order.tokenId);
        }
        if(order.nftType == BuyingAssetType.ERC1155)  {
            transferProxy.erc1155safeTransferFrom(IERC1155(order.nftAddress), order.seller, order.buyer, order.tokenId, order.qty, "");
        }
        if(fee.platformFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, owner, fee.platformFee);
        }
        if(fee.royaltyFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, fee.tokenCreator, fee.royaltyFee);
        }
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, order.seller, fee.assetFee);
    }

    function buyAsset(Order memory order, Sign memory sign) public returns(bool) {
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        order.buyer = msg.sender;
        tradeAsset(order, fee);
        emit BuyAsset(order.seller , order.tokenId, order.qty, msg.sender);
        return true;
    }

    function executeBid(Order memory order, Sign memory sign) public returns(bool) {
        Fee memory fee = getFees(order.amount, order.nftType, order.nftAddress, order.tokenId);
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty, sign);
        order.seller = msg.sender;
        tradeAsset(order, fee);
        emit ExecuteBid(msg.sender , order.tokenId, order.qty, order.buyer);
        return true;
    }
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    event tokenBaseURI(string value);

    function balanceOf(address owner) external view returns (uint256 balance);

    function royaltyFee(uint256 tokenId) external view  returns(uint256);

    function getCreator(uint256 tokenId) external view returns(address);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

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

function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    event tokenBaseURI(string value);


    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function royaltyFee(uint256 tokenId) external view returns(uint256);
    function getCreator(uint256 tokenId) external view returns(address);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
* @dev Integer modulo of two numbers, truncating the remainder.
    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./token/interfaces/IERC20.sol";
import "./token/interfaces/IERC721.sol";
import "./token/interfaces/IERC1155.sol";

contract TransferProxy {

    event operatorChanged(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    address public owner;
    address public operator;

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
    */

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "OperatorRole: caller does not have the Operator role");
        _;
    }

    /** change the OperatorRole from contract creator address to trade contractaddress
@param _operator :trade address 
        */

    function changeOperator(address _operator) public onlyOwner returns(bool) {
        require(_operator != address(0), "Operator: new operator is the zero address");
        operator = _operator;
        emit operatorChanged(address(0),operator);
        return true;
    }

    /** change the Ownership from current owner to newOwner address
@param newOwner : newOwner address */

    function transferOwnership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
        return true;
    }

    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external onlyOperator {
        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 tokenId, uint256 value, bytes calldata data) external onlyOperator {
        token.safeTransferFrom(from, to, tokenId, value, data);
    }

    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external onlyOperator {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }
}