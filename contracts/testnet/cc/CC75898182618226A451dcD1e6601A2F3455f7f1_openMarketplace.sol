// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";




contract openMarketplace is  ReentrancyGuard,Ownable,ERC721Holder {

    using Counters for Counters.Counter;
    Counters.Counter private _listingId;
    


    event ItemListed(address indexed seller,address indexed nftAddress, uint256 indexed tokenId,uint256 price);
    event ItemBought(address indexed buyer,address indexed nftAddress, uint256 indexed tokenId,uint256 price);
    event ItemCancelled(address indexed seller,address indexed nftAddress, uint256 indexed tokenId); 

     
    struct Listing {
        uint256 listingId;
        address nftAddress;
        uint256 tokenId;
        uint256 priceInWei;
        address  seller;
        address acceptedToken;
    }

     mapping(uint256=>Listing) private listingIdTOListingNft;

     mapping(address=>mapping(uint256=>Listing)) private nftAddressToTokenIdToListing;
     mapping(address=>Listing[]) private ownerToListingArray;
     

    //  mapping(address=>Listing) private nftAddressToMyNft;

  
    // Plateform NFTs Listing Fee
    uint256 private _platformFee =0.00001 ether;
    


    // seller ---->amount earned by profit
    mapping(address=>uint256) private profits;


    mapping(address=>bool) private isAcceptedERC20TokenMap;
    address[] private AcceptedERC20Tokens;


    function getListingId(address _nftAddress,uint256 _tokenId) external view returns (Listing memory) {
      return nftAddressToTokenIdToListing[_nftAddress][_tokenId];

    }

    function setAcceptedERCToken(address _ERC20Address) external onlyOwner {
        require(isAcceptedERC20TokenMap[_ERC20Address]==false,"already added ERc20 Token");
      isAcceptedERC20TokenMap[_ERC20Address]= true;
       AcceptedERC20Tokens.push(_ERC20Address);

     }


    function getERCTokenList() external view returns(address[] memory){
        return AcceptedERC20Tokens;
    }

    function checkIsAcceptedToken(address _acceptedToken) external view returns(bool){
        return isAcceptedERC20TokenMap[_acceptedToken];
    }


    // Modifier
    modifier isAcceptedERC20Token(address _ERC20Address) {
         require(isAcceptedERC20TokenMap[_ERC20Address]==true,"Not Allowed this Token For Trade");
         _;
     }

    modifier alreadyListed(address _nft,uint256 _tokenId) {
        Listing memory check = nftAddressToTokenIdToListing[_nft][_tokenId];
        require(check.priceInWei == 0, "NFT already Listed");
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender){
        IERC721 id = IERC721(nftAddress);
        address owner = id.ownerOf(tokenId);
        require(owner==spender,"you are not the owner of NFT");
        _;
    }

    modifier isListed(uint256 _listingId) {
         Listing memory item = listingIdTOListingNft[_listingId];
        require(item.priceInWei > 0, "Item not Listed");
        _;
    }



    function listNft(address nft,uint256 tokenId,address _acceptedToken, uint256 _priceInWei) external isAcceptedERC20Token(_acceptedToken) alreadyListed(nft,tokenId) isOwner(nft,tokenId,msg.sender) nonReentrant{
            require(_priceInWei >0, "very low value !!!!");
            _listingId.increment();
            // IERC20(_acceptedToken).approve(address(this),_priceInWei);
            // IERC721(nft).setApprovalForAll(address(this),true);
            nftAddressToTokenIdToListing[nft][tokenId]=Listing(_listingId.current(), nft, tokenId, _priceInWei,msg.sender,_acceptedToken);
            ownerToListingArray[msg.sender].push(Listing(_listingId.current(), nft, tokenId, _priceInWei,msg.sender,_acceptedToken));
            listingIdTOListingNft[_listingId.current()]=Listing(_listingId.current(), nft, tokenId, _priceInWei,msg.sender,_acceptedToken);
            IERC721(nft).safeTransferFrom(msg.sender,address(this),tokenId);
        
    }


    function buyNft(uint256 _listingId,uint256 _priceInWei) external payable 
    isListed(_listingId)  nonReentrant {
        Listing memory item = listingIdTOListingNft[_listingId];
        require(msg.value ==_platformFee,"Platform fee not sufficient");
        require(msg.sender != item.seller,"You aare the the owner of this nft so you can't use this buy method");
        require(item.priceInWei== _priceInWei,"market  price of this nft not match");
        profits[item.seller] += _priceInWei;
        //deleting the struct of current seller
        delete(listingIdTOListingNft[_listingId]);
        delete(nftAddressToTokenIdToListing[item.nftAddress][item.tokenId]);
        IERC20(item.acceptedToken).transferFrom(msg.sender,item.seller,_priceInWei);
        IERC721(item.nftAddress).safeTransferFrom(address(this),msg.sender,item.tokenId);
        emit ItemBought(msg.sender,item.nftAddress,item.tokenId,item.priceInWei);
    }

    function cancelListing(uint256 _listingId) external isListed(_listingId){
        Listing memory item = listingIdTOListingNft[_listingId];
        require(item.seller==msg.sender,"You are not the listing owner of this nft");
        delete(listingIdTOListingNft[_listingId]);
        IERC721(item.nftAddress).safeTransferFrom(address(this),msg.sender,item.tokenId);
        // emit ItemCancelled(msg.sender,item.nftAddress,item.tokenId,item.priceInWei);
    }
    
    
     function updateListing(uint256 _listingId,uint256 _newPriceInWei) external isListed(_listingId) {
         Listing memory item = listingIdTOListingNft[_listingId];
         require(item.seller==msg.sender,"You are not the listing owner of this nft");
         IERC721(item.nftAddress).safeTransferFrom(address(this),msg.sender,item.tokenId);
         listingIdTOListingNft[_listingId].priceInWei=_newPriceInWei;
         emit ItemListed(msg.sender,item.nftAddress,item.tokenId,item.priceInWei);
     }




     function withdrow() external onlyOwner nonReentrant{
         (bool success,)= payable(msg.sender).call{value: address(this).balance} ("");
         require(success,"withdrow failed");
     }

     function getListedNftById(uint256 _listingId)  external view returns(Listing memory){
         return listingIdTOListingNft[_listingId]; 
     }

    function geAlltListedNftByOwner(address _ownerAddress) external view returns(Listing[] memory){
         return ownerToListingArray[_ownerAddress];
      }

      // all the NFTs currently listed to be sold on the marketplace
    function getAllNFTs() public view returns (Listing[] memory) {
        uint nftCount = _listingId.current();
        Listing[] memory tokens = new Listing[](nftCount);
        uint currentIndex = 0;
        //at the moment currentlyListed is true for all, if it becomes false in the future we will
        //filter out currentlyListed == false over here
        for(uint i=0;i<nftCount;i++)
        {
            uint currentId = i + 1;
            Listing storage currentItem = listingIdTOListingNft[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        //the array 'tokens' has the list of all NFTs in the marketplace
        return tokens;
    }

     function getProfitsAmount(address _seller) external view returns(uint256) {
        return profits[_seller];
    }

    function setPlatformFee(uint256 platformFee) external onlyOwner{
        _platformFee=platformFee;
    } 

    function getPlatformFee() external view returns (uint256) {
        return _platformFee;
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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