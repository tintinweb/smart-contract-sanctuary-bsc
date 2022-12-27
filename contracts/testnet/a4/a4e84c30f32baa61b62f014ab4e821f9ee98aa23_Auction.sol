/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;

    function ownerOf(
        uint256 tokenId
    ) external 
    returns (address);

    function owner() external returns (address);
}

contract Auction is Ownable {
    address public _contractPlatformForFee;
    address public _contractOwner;
    uint public _rolayteForPlatform;

    
    mapping (IERC721 => uint) public auctionNftsInMarket;
    mapping (IERC721 => mapping (uint => address)) public auctionNftsOwnerInMarket;
    mapping (IERC721 => mapping (uint => bool)) public auctionsStatus;
    mapping (IERC721 => mapping (uint => uint)) public auctionsDuration;
    mapping (IERC721 => mapping (uint => uint)) public auctionStartPriceAt;
    mapping (IERC721 => mapping (uint => uint)) public auctionEndPriceAt;
    mapping (IERC721 => mapping (uint => uint256)) public auctionStartingPrice;
    mapping (IERC721 => mapping (uint => uint256)) public auctionRoyalte;
    mapping (IERC721 => mapping (uint => address)) public auctionLastBider;
    mapping (IERC721 => mapping (uint => mapping (address => uint256))) public auctionLastBiderPrice;
    mapping (IERC721 => mapping (uint => uint256)) public auctionCountBid;


    mapping (IERC721 => uint) public normalNftsInMarket;
    mapping (IERC721 => mapping (uint => address)) public normalNftsOwnerInMarket;
    mapping (IERC721 => mapping (uint => uint256)) public normalNftsPrice;
    mapping (IERC721 => mapping (uint => uint256)) public normalNftsRoyalte;
    mapping (IERC721 => mapping (uint => bool)) public normallistStatus;

    event AddToAuctionMarket(address indexed from, address indexed collection,  uint nftID, uint256 startPrice, uint auctionDuration, uint royalte);
    event AddToNormalMarket(address indexed from, address indexed collection,  uint nftID, uint256 price, uint royalte);
    event Purchase(address indexed previousOwner, address indexed newOwner, uint price, uint nftID);
    event TransferReceived(address _from, uint _amount);
    event TransferSend(address indexed _to, uint _amount);

    // Auction Codes
    uint256 public balance;
    

    receive() payable external {
        balance += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }

    constructor(address _platform, uint _royalte) {
        _contractOwner = msg.sender;
        _contractPlatformForFee = _platform;
        _rolayteForPlatform = _royalte;
    }

    function addToAuctionMarket(address _nft, uint _nftId, uint _royalte, uint256 _startPrice, uint _auctionsDuration) public returns (bool){
        
        auctionsStatus[IERC721(_nft)][_nftId] = true;
        auctionsDuration[IERC721(_nft)][_nftId] = _auctionsDuration * 1 days;
        auctionStartPriceAt[IERC721(_nft)][_nftId] = block.timestamp;
        auctionEndPriceAt[IERC721(_nft)][_nftId] =  block.timestamp + _auctionsDuration * 1 days;
        auctionStartingPrice[IERC721(_nft)][_nftId] = _startPrice;
        auctionRoyalte[IERC721(_nft)][_nftId] = _royalte;
        
        auctionNftsInMarket[IERC721(_nft)] = _nftId;
        auctionNftsOwnerInMarket[IERC721(_nft)][_nftId] = msg.sender;

        IERC721(_nft).transferFrom(msg.sender, address(this), _nftId);

        emit AddToAuctionMarket(msg.sender, _nft, _nftId, _startPrice, _auctionsDuration, _royalte);

        return true;
        
    }

    function bidAuction(address _nft, uint _nftId) external payable {

        uint256 _bid = msg.value;

        // check for expired auction
        require(block.timestamp < auctionEndPriceAt[IERC721(_nft)][_nftId], "auction expired");

        require(_bid > auctionStartingPrice[IERC721(_nft)][_nftId], "your value not enough for this auction");
        require(msg.value > auctionLastBiderPrice[IERC721(_nft)][_nftId][auctionLastBider[IERC721(_nft)][_nftId]], "your value not enough for this auction");
        
        
        if (auctionCountBid[IERC721(_nft)][_nftId] >= 1){
            // return back mondey for miner bider
            address minerBider = auctionLastBider[IERC721(_nft)][_nftId];
            uint256 minerBidPrice = auctionLastBiderPrice[IERC721(_nft)][_nftId][minerBider];
            payable(minerBider).transfer(minerBidPrice);
            balance = balance - minerBidPrice;
            emit TransferSend(minerBider, minerBidPrice);

            // set new bider
            auctionLastBider[IERC721(_nft)][_nftId] = msg.sender;
            auctionLastBiderPrice[IERC721(_nft)][_nftId][msg.sender] = _bid;
            auctionCountBid[IERC721(_nft)][_nftId] = auctionCountBid[IERC721(_nft)][_nftId] + 1; 
            balance = balance + _bid;
            emit TransferReceived(msg.sender, msg.value);

        } else {
            // set new bider
            auctionLastBider[IERC721(_nft)][_nftId] = msg.sender;
            auctionLastBiderPrice[IERC721(_nft)][_nftId][msg.sender] = _bid;
            auctionCountBid[IERC721(_nft)][_nftId] = auctionCountBid[IERC721(_nft)][_nftId] + 1; 
            balance = balance + _bid;
            emit TransferReceived(msg.sender, msg.value);
        }

    }



    function withdrawAuction(address _nft, uint _nftId) external {
        // TODO: af not bid return token
        // Check for item exist on Auction or not
        // require(auctionsStatus[IERC721(_nft)][_nftId] == true, "Item not exist for auction");

        // check for expired auction
        // require(block.timestamp > auctionEndPriceAt[IERC721(_nft)][_nftId], "auction not expired");

        address ownerOfCollection = auctionNftsOwnerInMarket[IERC721(_nft)][_nftId];
        
        if (msg.sender == ownerOfCollection){

            if (auctionCountBid[IERC721(_nft)][_nftId] >= 1){
            
                address buyer = auctionLastBider[IERC721(_nft)][_nftId];
                uint256 lastBid = auctionLastBiderPrice[IERC721(_nft)][_nftId][buyer];
                address payable tokenOwner = payable(ownerOfCollection);
                address payable platformOwner = payable(_contractPlatformForFee);
                address payable collectionOwner = payable(IERC721(_nft).owner());

                IERC721(_nft).transferFrom(address(this), buyer, _nftId);

                uint _commissionPlatform = lastBid * _rolayteForPlatform / 100;
                uint _commissionOwner = lastBid * auctionRoyalte[IERC721(_nft)][_nftId] / 100;
                uint _sellerValue = lastBid - _commissionOwner - _commissionPlatform;
                
                collectionOwner.transfer(_commissionOwner);
                platformOwner.transfer(_commissionPlatform);
                tokenOwner.transfer(_sellerValue);

                balance = balance - lastBid;
                auctionStartingPrice[IERC721(_nft)][_nftId] = lastBid;
                auctionsStatus[IERC721(_nft)][_nftId] = false;
                auctionNftsOwnerInMarket[IERC721(_nft)][_nftId] = buyer;
                delete auctionLastBider[IERC721(_nft)][_nftId];
                delete auctionLastBiderPrice[IERC721(_nft)][_nftId][buyer];
                delete auctionsDuration[IERC721(_nft)][_nftId];
                delete auctionStartPriceAt[IERC721(_nft)][_nftId];
                delete auctionEndPriceAt[IERC721(_nft)][_nftId];

                emit Purchase(tokenOwner, buyer, lastBid, _nftId);
            } else {
                auctionsStatus[IERC721(_nft)][_nftId] = false;
            }
            
        }
       
    }


    function addToNormalMarket(address _nft, uint _nftId, uint _royalte, uint256 _price) public returns ( uint ) {
        normalNftsInMarket[IERC721(_nft)] = _nftId;
        normalNftsOwnerInMarket[IERC721(_nft)][_nftId] = msg.sender;
        normalNftsPrice[IERC721(_nft)][_nftId] = _price;
        normalNftsRoyalte[IERC721(_nft)][_nftId] = _royalte;
        normallistStatus[IERC721(_nft)][_nftId] = true;
        IERC721(_nft).transferFrom(msg.sender, address(this), _nftId);
        emit AddToNormalMarket(msg.sender, _nft, _nftId, _price, _royalte);
        return _nftId;
    }



    function buyNormal(address _nft, uint _nftId) external payable {

        address ownerOfCollection = normalNftsOwnerInMarket[IERC721(_nft)][_nftId];
        address payable tokenOwner = payable(ownerOfCollection);
        address payable platformOwner = payable(_contractPlatformForFee);
        address payable collectionOwner = payable(IERC721(_nft).owner());
        address payable buyer = payable(msg.sender);
        
        IERC721(_nft).transferFrom(address(this), buyer, _nftId);

        uint _commissionPlatform = normalNftsPrice[IERC721(_nft)][_nftId] * _rolayteForPlatform / 100;
        uint _commissionOwner = normalNftsPrice[IERC721(_nft)][_nftId] * normalNftsRoyalte[IERC721(_nft)][_nftId] / 100;
        uint _sellerValue = normalNftsPrice[IERC721(_nft)][_nftId] - _commissionOwner - _commissionPlatform;
        
        tokenOwner.transfer(_sellerValue);
        collectionOwner.transfer(_commissionOwner);
        platformOwner.transfer(_commissionPlatform);

        // If buyer sent more than price, we send them back their rest of funds
        if (msg.value > normalNftsPrice[IERC721(_nft)][_nftId]) {
            buyer.transfer(msg.value - normalNftsPrice[IERC721(_nft)][_nftId]);
        }
        normalNftsOwnerInMarket[IERC721(_nft)][_nftId] = buyer;
        normallistStatus[IERC721(_nft)][_nftId] = false;

        emit Purchase(tokenOwner, buyer, normalNftsPrice[IERC721(_nft)][_nftId], _nftId);
    }

    
}