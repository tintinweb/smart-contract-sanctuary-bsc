// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// Import this file to use console.log
//import "hardhat/console.sol";
import "./AbstractAuction.sol";
import "./Ownable.sol";

contract EventTest is AbstractAuction, Ownable {

    uint256 internal _index;

    mapping(uint256 => Auction) public auctions;
    mapping(address => uint256[]) public userAuctions;

    event AuctionCreated(uint256 indexed auctionId, uint256 tokenType);
    event AuctionStarted(uint256 indexed auctionId, uint256 timestamp);
    event AuctionEnded(
        uint256 indexed auctionId,
        address winner,
        uint256 highestBid
    );
    event AuctionClosed(
        uint256 indexed auctionId,
        address winner,
        uint256 highestBid
    );
    event AuctionCanceled(uint256 indexed auctionId);
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed token,
        uint256 id,
        address bidder,
        uint256 bidPrice
    );
    function create(address _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _initialDate,
        Asset _paidIn,
        address _assetAddress,
        uint256 _timeframeId
    ) public {
        _index++;
        uint256 auctionId = _index;
        Auction memory a;

        a.token.tokenType = TokenType.ERC721;
        a.token.addr = _token;
        a.token.id = _tokenId;
        a.initialPrice = _initialPrice;
        a.highest.bid = _initialPrice;
        a.timeframe = TIMEFRAMES[_timeframeId];
        if (_initialDate != 0) {
            if (_initialDate <= block.timestamp) {
                _initialDate = block.timestamp;
            }
        } else {
            _initialDate = block.timestamp;
        }

        a.initialDate = _initialDate;
        a.seller = _msgSender();
        a.paidIn = _paidIn;
        a.assetAddress = _assetAddress;

        auctions[auctionId] = a;

        userAuctions[_msgSender()].push(auctionId);
        emit AuctionCreated(auctionId, uint256(TokenType.ERC721));
    }
    function start(uint256 auctionId) public {
        Auction storage a = auctions[auctionId];
        a.biddingStart = block.timestamp;
        auctions[auctionId] = a;
        emit AuctionStarted(auctionId, a.biddingStart);
    }
    function end(uint256 auctionId) public {
        Auction storage a = auctions[auctionId];
        emit AuctionEnded(auctionId, a.highest.bidder, a.highest.bid);
    }
    function close(uint256 auctionId) public {
        Auction storage a = auctions[auctionId];
        emit AuctionEnded(auctionId, a.highest.bidder, a.highest.bid);
    }
    function cancel(uint256 auctionId) public {
        emit AuctionCanceled(auctionId);
    }
    function bid(uint256 auctionId) public {
        Auction storage a = auctions[auctionId];
        emit BidPlaced(
            auctionId,
            a.token.addr,
            a.token.id,
            _msgSender(),
            1e17
        );
    }
}