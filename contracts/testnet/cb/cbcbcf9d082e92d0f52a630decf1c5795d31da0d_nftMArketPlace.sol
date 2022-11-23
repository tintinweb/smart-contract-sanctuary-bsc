/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: NFT marketPlace.sol


pragma solidity ^0.8.9;


// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
///0x0000000000000000000000000000000000000000
interface IERC20 {
    //Fuction that use in ERC20 token
    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address Owner) external view returns (uint256);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 token) external returns (bool);

    function approve(address spender, uint256 token) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 token
    ) external returns (bool);

    //Events use in ERC20
    event approval(address indexed Owner, address indexed to, uint256 token);
    event Transfer(address from, address to, uint256 token);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);
}

interface IERC721 is IERC165, IERC721Receiver, IERC721Metadata {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

contract nftMArketPlace {
    //   IERC721 nftToken;
    //   IERC20 token;
    string public nameOfMarket;
    using Counters for Counters.Counter;
    Counters.Counter private nftCount;
    Counters.Counter private nftsold;
    address payable public marketOwner;
    uint256 public listingprice = 0.005 ether;
    uint256 public index = 0;
    address public Owner;
    // address payable seller;
    struct nft {
        address _tokenAddress;
        address addressErc20Token;
        uint256 _id;
        address payable seller;
        // address payable owner;
        uint256 priceInEther;
        uint256 priceInTokens;
        bool listed;
    }
    struct Auction {
        uint256 index;
        address addressNftToken;
        address addressErc20Token;
        uint256 nftId;
        address creator;
        address payable currentBidOwner;
        uint256 currentBidPriceInEther;
        uint256 currentBidPriceInToken;
        uint256 endAuction;
        uint256 bidCount;
        bool listed;
    }

    mapping(uint256 => nft) public nftData;
    // mapping(uint256=>Auction) public auctionData;
    Auction[] public auctionData;

    event cancelList(uint256 _id, bool listed);
    event NewBidOnAuction(uint256 _auctionId, uint256 newBid);
    event NFTClaimed(uint256 auctionIndex, uint256 nftId, address claimedBy);
    event TokensClaimed(uint256 auctionIndex, uint256 nftId, address claimedBy);
    event cancelAuction(uint256 auctionIndex, uint256 nftId, address claimedBy);

    event nftListed(
        address _tokenAddress,
        address addressErc20Token,
        uint256 _id,
        address seller,
        uint256 priceInEther,
        uint256 priceInTokens,
        bool listed
    );
    event nftSold(
        address _tokenAddress,
        uint256 _id,
        address seller,
        uint256 price
    );
    event nftAuction(
        uint256 index,
        address addressNftToken,
        address addressErc20Token,
        uint256 nftId,
        address creator,
        address currentBidOwner,
        uint256 currentBidPrice,
        uint256 endAuction,
        uint256 bidCount,
        bool listed
    );

    constructor(string memory _nameOfMarket) {
        //   nftToken=IERC721(_nftToken);
        nameOfMarket = _nameOfMarket;
        marketOwner = payable(msg.sender);
        Owner = msg.sender;
    }

    function _Owner() public view returns (address) {
        return Owner;
    }

    modifier onlyOwner() {
        require(Owner == msg.sender, "You are not owner");
        _;
    }

    function setListingprice(uint256 Price) public onlyOwner {
        listingprice = Price;
    }

    // list NFT
    function listNft(
        address _tokenAddress,
        address _addressErc20Token,
        uint256 _id,
        uint256 _priceInEther,
        uint256 _priceInTokens
    ) public payable returns (bool) {
        require(_priceInEther > 0, "Price must be greater then 0");
        // require(_addressErc20Token != address(0), "Cannot be address 0");
        //  require(price==listingprice,"Price must be equal to set listing price");
        IERC721 nftToken = IERC721(_tokenAddress);
        nftToken.transferFrom(msg.sender, address(this), _id);
        nftCount.increment();
        _priceInEther = msg.value;
        nftData[_id] = nft(
            _tokenAddress,
            _addressErc20Token,
            _id,
            payable(msg.sender),
            _priceInEther,
            _priceInTokens,
            true
        );

        emit nftListed(
            _tokenAddress,
            _addressErc20Token,
            _id,
            msg.sender,
            _priceInEther,
            _priceInTokens,
            true
        );
        payable(msg.sender).transfer(_priceInEther);
        return true;
    }

    function cancelLIsting(uint256 id) public returns (bool) {
        require(msg.sender == nftData[id].seller, "You are not owner");
        nft storage _NFT = nftData[id];
        IERC721 _nFT = IERC721(_NFT._tokenAddress);
        _nFT.transferFrom(address(this), msg.sender, id);
        nftData[id].priceInEther = 0;
        nftData[id].priceInTokens = 0;
        nftData[id].listed = false;
        emit cancelList(id, false);
        return true;
    }

    function buy(uint256 _id) public payable returns (bool) {
        require(msg.sender != nftData[_id].seller, "seller cannot buy itself");
        nft memory _NFT = nftData[_id];
        IERC20 paymentToken = IERC20(_NFT.addressErc20Token);

        require(
            (paymentToken.balanceOf(msg.sender) > _NFT.priceInTokens &&
                paymentToken.allowance(msg.sender, address(this)) >=
                _NFT.priceInTokens) || msg.value >= _NFT.priceInEther,
            "price is less then the listing price"
        );
//  IERC20(nftData[_id].addressErc20Token).allowance(
//                 msg.sender,
//                 address(this)

        if (
            paymentToken.balanceOf(msg.sender) > _NFT.priceInTokens
            &&
            paymentToken.allowance( msg.sender,address(this)) >= _NFT.priceInTokens
        ) {
            paymentToken.transferFrom(
                msg.sender,
                _NFT.seller,
                _NFT.priceInTokens
            );
            payable(msg.sender).transfer(msg.value);
        } else {
            payable(_NFT.seller).transfer(msg.value);
        }

        // require()
        address payable buyer = payable(msg.sender);

        //  nftData[_id].seller.transfer(buyingPrice);
        //  Auction memory auction = auctionData[_id];
        IERC721 _nftToken = IERC721(nftData[_id]._tokenAddress);
        _nftToken.transferFrom(address(this), buyer, _id);
        nftData[_id].seller = buyer;
        nftData[_id].priceInEther = 0;
        nftData[_id].priceInTokens = 0;
        nftData[_id].listed = false;
        nftsold.increment();

        emit nftSold(
            nftData[_id]._tokenAddress,
            nftData[_id]._id,
            buyer,
            msg.value
        );

        return true;
        // if (nftData[_id].addressErc20Token == address(0) ) {
        //     uint256 buyingPrice = msg.value;
        //     buyingPrice = buyingPrice - listingprice;
        //     // buyingPrice = buyingPrice - listingprice;
        //     nftData[_id].seller.transfer(buyingPrice);
        //     marketOwner.transfer(listingprice);

        // } else {
        // IERC20 paymentToken = IERC20(nftData[_id].addressErc20Token);

        //     nftData[_id].seller = buyer;
        //     paymentToken.transferFrom(msg.sender,buyer, nftData[_id].price);
        // }
    }

    function createAuction(
        address _addressNftToken,
        address _addressToken,
        uint256 _nftId,
        uint256 _initialBidInEther,
        uint256 _initialBidInToken,
        uint256 _endAuction
    ) external payable returns (uint256) {
        _initialBidInEther = msg.value;
        // require(_endAuction > block.timestamp, "Invalid end date for auction");
        require(
            _initialBidInEther > 0 && _initialBidInToken > 0,
            "Invalid initial bid price"
        );
        IERC721 nftToken = IERC721(_addressNftToken);
        require(
            msg.sender == nftToken.ownerOf(_nftId),
            "Caller is not the owner of the NFT"
        );

        nftToken.transferFrom(msg.sender, address(this), _nftId);

        address payable currentBidOwner = payable(address(0));
        // if(_addressToken==address(0)){
        //    _initialBid=(msg.value);
        // }
        Auction memory newAuction = Auction({
            index: index,
            addressNftToken: _addressNftToken,
            addressErc20Token: _addressToken,
            nftId: _nftId,
            creator: msg.sender,
            currentBidOwner: currentBidOwner,
            currentBidPriceInEther: _initialBidInEther,
            currentBidPriceInToken: _initialBidInToken,
            endAuction: _endAuction,
            bidCount: 0,
            listed: true
        });
        auctionData.push(newAuction);
        index++;
        emit nftAuction(
            index,
            _addressNftToken,
            _addressToken,
            _nftId,
            msg.sender,
            currentBidOwner,
            _initialBidInEther,
            _endAuction,
            0,
            true
        );
        payable(msg.sender).transfer(_initialBidInEther);
        return index;
    }

    function _cancelAuction(uint256 _auctionIndex) public {
        // require(!isOpen(_auctionIndex), "Auction is still open");
        // require(auction.currentBidOwner==address(0), "Existing bider for this auction");

        Auction storage auction = auctionData[_auctionIndex];
        require(_auctionIndex < auctionData.length, "Invalid auction index");
        require(
            msg.sender == auction.creator,
            "Auction can be cancel only by the creator of the auction"
        );

        // Get NFT Collection contract
        IERC721 _nftToken = IERC721(auction.addressNftToken);
        _nftToken.transferFrom(address(this), auction.creator, auction.nftId);
        auction.listed = false;
        auction.currentBidPriceInEther = 0;
        auction.currentBidPriceInToken = 0;
        emit cancelAuction(_auctionIndex, auction.nftId, msg.sender);
    }

    //     function isOpen(uint256 _auctionIndex) public view returns (bool) {
    //         Auction storage auction = auctionData[_auctionIndex];
    //         if (block.timestamp > auction.endAuction) {
    //             return false;
    //             }
    //             else{
    //         return true;
    //         }
    //     }

        function getCurrentBidOwner(uint256 _auctionIndex) public view returns (address){
            require(_auctionIndex < auctionData.length, "Invalid auction index");
            return auctionData[_auctionIndex].currentBidOwner;
        }

    function bid (uint256 _auctionIndex, uint256 _newBid)external payable  returns (bool){
            require(_auctionIndex < auctionData.length, "Invalid auction index");
            Auction storage auction = auctionData[_auctionIndex];
              IERC20 paymentToken = IERC20(auction.addressErc20Token);
            // require(isOpen(_auctionIndex), "Auction is not open");
            require(msg.value > auction.currentBidPriceInEther || _newBid > auction.currentBidPriceInToken,"New bid price must be higher than the current bid");
            require(msg.sender != auction.creator, "Creator of the auction cannot place new bid" );
    
//  IERC20(nftData[_id].addressErc20Token).allowance(
//                 msg.sender,
//                 address(this)

        if ( _newBid > auction.currentBidPriceInToken) {
            paymentToken.transferFrom(
                msg.sender,
                address(this),
               _newBid
            );

            // payable(msg.sender).transfer(msg.value);
             }
        //       else {
        //     payable(address(this)).transfer(msg.value);
        // }
        if(auction.bidCount > 0){
            payable(auction.currentBidOwner).transfer(auction.currentBidPriceInEther);
            paymentToken.transfer(auction.currentBidOwner,auction.currentBidPriceInToken);

        }
                    // if(auction.addressErc20Token ==address(0)){
                    //     // uint256 currentPrice=_newBid;
                    //     // payable(address(this).transfer(_newBid));
                    //     if(_newBid >auction.currentBidPriceInEther){
                    //        auction.currentBidOwner.transfer(auction.currentBidPriceInEther);
                    //     }
                    // }
            //         // else{
            // IERC20 paymentToken = IERC20(auction.addressErc20Token);
            //    paymentToken.transferFrom(msg.sender, address(this), _newBid);
            //    if (auction.bidCount > 0) {
            //     paymentToken.transfer(auction.currentBidOwner,auction.currentBidPrice);
            //   }
            //   }

            // update auction info
            address payable newBidOwner = payable(msg.sender);
            auction.currentBidOwner = newBidOwner;
            auction.currentBidPriceInEther = msg.value;
            auction.currentBidPriceInToken=_newBid;
            auction.bidCount++;
            emit NewBidOnAuction(_auctionIndex, _newBid);

            return true;
        }

    function finalizedAuction(uint256 _auctionIndex) external  {
            require(_auctionIndex < auctionData.length, "Invalid auction index");
            // require(!isOpen(_auctionIndex), "Auction is still open");
            Auction storage auction = auctionData[_auctionIndex];
            require(msg.sender==auction.currentBidOwner ||msg.sender== auction.currentBidOwner,"NFT can be claimed  by the current bid owner or ouction creator");

            IERC721 nftToken = IERC721(auction.addressNftToken);

            nftToken.transferFrom( address(this), auction.currentBidOwner, auction.nftId);
        //  if(auction.addressErc20Token ==address(0)){
           payable( auction.creator).transfer(auction.currentBidPriceInEther);
         
            IERC20 paymentToken = IERC20(auction.addressErc20Token);
             paymentToken.transfer(auction.creator, auction.currentBidPriceInToken);
              auction.currentBidPriceInToken=0;
              auction.currentBidPriceInEther=0;
              auction.endAuction=0;
            emit NFTClaimed(_auctionIndex, auction.nftId, msg.sender);
        }

    // function claimToken  (uint256 _auctionIndex) public {
    //      require(_auctionIndex < auctionData.length, "Invalid auction index");
    //         require(!isOpen(_auctionIndex), "Auction is still open");

    //         Auction storage auction = auctionData[_auctionIndex];

    //         require(msg.sender== auction.creator,"Tokens can be claimed only by the creator of the auction" );

    //         // Get NFT Collection contract
    //         IERC721 _nftToken= IERC721(auction.addressNftToken);
    //         _nftToken.transferFrom(address(this),auction.currentBidOwner,auction.nftId);

    //         IERC20 paymentToken = IERC20(auction.addressErc20Token);
    //         paymentToken.transfer(auction.creator, auction.currentBidPrice);

    //         emit TokensClaimed(_auctionIndex, auction.nftId, msg.sender);
    //     }
}