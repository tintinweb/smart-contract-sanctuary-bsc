/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// File: contracts\Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

// File: contracts\Ownable.sol


pragma solidity ^0.8.7;
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

// File: contracts\ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.7;

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

// File: contracts\VerifySellSignature.sol


pragma solidity ^0.8.7;

contract verifySellSignature{

	function getMessageHashFixSell(address _NFTcontract,uint256 _tokenId, uint256 _price,uint256 _timeOfCreation) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_NFTcontract,_tokenId,_price,_timeOfCreation));
	}

    function getMessageHashAuctionSell(address _nftContract,uint256 _tokenId,uint256 _SellerPrice,uint256 _timeOfOrder,uint256 _auctionDuraton) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_nftContract,_tokenId,_SellerPrice,_timeOfOrder,_auctionDuraton));
	}

	function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash));
	}

	function verifyFixSell(address _signer, address _NFTcontract,uint256 _tokenId, uint256 _price,uint256 _timeOfCreation, bytes memory _signature) public pure returns(bool){
		bytes32 messageHash = getMessageHashFixSell(_NFTcontract,_tokenId,_price,_timeOfCreation);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
		return recoverSigner(ethSignedMessageHash , _signature) == _signer;
	}

    function verifyAuctionSell(address _signer,address _nftContract,uint256 _tokenId,uint256 _SellerPrice,uint256 _timeOfOrder,uint256 _auctionDuraton,bytes memory _signature)public pure returns(bool){
		bytes32 messageHash = getMessageHashAuctionSell(_nftContract,_tokenId,_SellerPrice,_timeOfOrder,_auctionDuraton);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
		return recoverSigner(ethSignedMessageHash , _signature) == _signer;
	}

	function recoverSigner(bytes32 _ethSignedMessageHash , bytes memory _signature) public pure returns(address){
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
		return ecrecover(_ethSignedMessageHash,v,r,s);
	}

	function splitSignature(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v){
		require(_sig.length == 65, "invalid signature length");
		assembly{
			r := mload(add(_sig,32))
			s := mload(add(_sig,64))
			v := byte(0, mload(add(_sig,96)))
		}
	}
}

// File: contracts\SwotMarketPlace.sol


pragma solidity ^0.8.7;
interface Inft{
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
    function royaltyInfo(uint256 , uint256 ) external view returns (address, uint256);   
}


contract SwotMarketPlace is Ownable,ReentrancyGuard,verifySellSignature{
        
    struct AuctionPriceSell{
        address buyer;
        uint256 endingPrice;         
    }

    uint256 public PlatformFees;       //2.5%=250 on selling Price will be charged for using the Platform to sell The NFT
        
    mapping(address => bool) public NFTcreates;
    
    mapping(bytes => bool) fixPriceSignatureChecking;
    mapping(bytes => bool) AuctionPriceSignatureChecking;
    mapping(address=>mapping(uint256=>AuctionPriceSell)) public bids;   
    mapping(address => uint256) public pendingReturns;

    event sellDetails(address indexed NFTcontract,uint256 tokenId, uint price);
        
    constructor(uint256 _platformfees){
        SetMarketPlaceFeesPercentage(_platformfees);                
    }

    function SetMarketPlaceFeesPercentage(uint256 _feesPercentage) public onlyOwner returns(uint256 NewFee){
        PlatformFees = _feesPercentage;                                                 //Set MarketPlace charge 
        return PlatformFees;
    }
    

    function setNftCreationContract(address NftcreateAddress) public onlyOwner{
        NFTcreates[NftcreateAddress] = true;
    }       
      
    function priceOfNft(address NFTcreate,uint256 _tokenId, uint256 _price) view public returns(uint256 priceTobePaid, uint256 royaltyAmount, address royaltyOwner, uint256 platformCharge){
        require(NFTcreates[NFTcreate],"No contract exist");
        (royaltyOwner,royaltyAmount) = Inft(NFTcreate).royaltyInfo(_tokenId,_price);
        platformCharge = _price*(PlatformFees)/10000;
        priceTobePaid = _price + royaltyAmount + platformCharge;
        return (priceTobePaid,royaltyAmount,royaltyOwner,platformCharge);
    }    

    function buyAtFixedPrice(address _nftContract,uint256 _tokenId,uint256 _price,uint256 _timeOfOrder,bytes calldata _signature) public nonReentrant payable {
        uint256 amountTobeReturned;  
        address _owner;    
        require(NFTcreates[_nftContract],"No contract exist");
        require(!fixPriceSignatureChecking[_signature],"Already sold using this signature");
        _owner = Inft(_nftContract).ownerOf(_tokenId);
        require(verifyFixSell(_owner,_nftContract,_tokenId,_price,_timeOfOrder,_signature),"Signature doesnot match with the signer"); 
        (uint256 priceTobePaid,uint256 royaltyAmount,address royaltyOwner, uint256 platformCharge) = priceOfNft(_nftContract,_tokenId,_price);          
        require(msg.value >= priceTobePaid,"Low Balance");
        payable(_owner).transfer(_price);                         //Seller Payment 
        payable(royaltyOwner).transfer(royaltyAmount);            //Royalty Payment to creator
        payable(owner()).transfer(platformCharge);	              //MarketPlace Charge payment to the owner of the marketPlace 
        if(msg.value > priceTobePaid){
            amountTobeReturned = msg.value - priceTobePaid;
            payable(msg.sender).transfer(amountTobeReturned);      //if exceed amount paid by the buyer, the excess amount is returned 
        }                
        Inft(_nftContract).safeTransferFrom(_owner,msg.sender,_tokenId,"");
        fixPriceSignatureChecking[_signature] = true;
        emit sellDetails(_nftContract,_tokenId,_price);
    }
    
    function currentHighestPrice(address _nftContract,uint _tokenId) public view returns(address buyer, uint256 price){
        require(NFTcreates[_nftContract],"No contract exist");
        return (bids[_nftContract][_tokenId].buyer, bids[_nftContract][_tokenId].endingPrice);
    }

    function CancelAuctionPriceNFTtSell(address _nftContract,uint256 _tokenId,uint256 _SellerPrice,uint256 _timeOfOrder,uint256 _auctionDuraton,bytes calldata _signature) public nonReentrant{   
        require(NFTcreates[_nftContract],"No contract exist");
        require(!AuctionPriceSignatureChecking[_signature],"Already sold using this signature");
        address _owner = Inft(_nftContract).ownerOf(_tokenId);
        require(verifyAuctionSell(_owner,_nftContract,_tokenId,_SellerPrice,_timeOfOrder,_auctionDuraton,_signature),"Signature doesnot match with the signer");     
        require(block.timestamp <= _timeOfOrder + _auctionDuraton,"Auction already ended"); 
        AuctionPriceSell storage details = bids[_nftContract][_tokenId];                
        if(details.endingPrice != 0){
            uint amount = details.endingPrice;
            (uint256 priceTobePaid,,,) = priceOfNft(_nftContract,_tokenId,amount);            
            payable(details.buyer).transfer(priceTobePaid);
            delete bids[_nftContract][_tokenId];                                   
        }           
    }

    function buyAtAuctionPrice(address _nftContract,uint256 _tokenId,uint256 _SellerPrice,uint256 _timeOfOrder,uint256 _auctionDuraton,uint256 _BuyerPrice,bytes calldata _signature) public nonReentrant payable{
        require(NFTcreates[_nftContract],"No contract exist");
        require(!AuctionPriceSignatureChecking[_signature],"Already sold using this signature");
        address _owner = Inft(_nftContract).ownerOf(_tokenId);
        require(verifyAuctionSell(_owner,_nftContract,_tokenId,_SellerPrice,_timeOfOrder,_auctionDuraton,_signature),"Signature doesnot match with the signer");     
        require(block.timestamp <= _timeOfOrder + _auctionDuraton,"Auction already ended");
        (uint256 priceTobePaid,,,) = priceOfNft(_nftContract,_tokenId,_BuyerPrice); 
        require(msg.value >= priceTobePaid,"Low Balance");
        AuctionPriceSell storage details = bids[_nftContract][_tokenId];  
        require(_BuyerPrice > details.endingPrice,"Highest bid exist"); 
        if(msg.value > priceTobePaid){
            uint256 amountTobeReturned = msg.value - priceTobePaid;
            payable(msg.sender).transfer(amountTobeReturned);                        //if exceed amount paid by the buyer, the excess amount is returned 
        }        
        if(details.endingPrice != 0){  
            (uint amountReturned,,,) = priceOfNft(_nftContract,_tokenId,details.endingPrice);                 
            payable(details.buyer).transfer(amountReturned);   
        }
        details.buyer = msg.sender;
        details.endingPrice = _BuyerPrice;
    }   
    
    function auctionEnd(address _nftContract,uint256 _tokenId,uint256 _SellerPrice,uint256 _timeOfOrder,uint256 _auctionDuraton,bytes calldata _signature) public nonReentrant{
        require(NFTcreates[_nftContract],"No contract exist");
        require(!AuctionPriceSignatureChecking[_signature],"Already sold using this signature");
        address _owner = Inft(_nftContract).ownerOf(_tokenId);
        require(verifyAuctionSell(_owner,_nftContract,_tokenId,_SellerPrice,_timeOfOrder,_auctionDuraton,_signature),"Signature doesnot match with the signer");     
        require(block.timestamp >= _timeOfOrder + _auctionDuraton,"Auction already ended");
        AuctionPriceSell memory details = bids[_nftContract][_tokenId];                        
        if(details.endingPrice > 0){
            (,uint256 royaltyAmount, address royaltyOwner, uint256 platformCharge) = priceOfNft(_nftContract,_tokenId,details.endingPrice);
            payable(_owner).transfer(details.endingPrice);  
            payable(royaltyOwner).transfer(royaltyAmount);
            payable(owner()).transfer(platformCharge);
            Inft(_nftContract).safeTransferFrom(_owner,details.buyer,_tokenId,"");
            emit sellDetails(_nftContract,_tokenId,details.endingPrice);
        }          
        delete bids[_nftContract][_tokenId];
        AuctionPriceSignatureChecking[_signature] = true;                    
    }    
}