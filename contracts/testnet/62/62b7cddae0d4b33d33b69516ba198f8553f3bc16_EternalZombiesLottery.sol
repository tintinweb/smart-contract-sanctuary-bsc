/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalZombiesLottery
 * @author : saad sarwar
 */


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

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;

        _status = _NOT_ENTERED;
    }
}

interface IMinter {
    function mint(uint amount) external payable;
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external returns (uint256);
    function TOKEN_ID() external view returns (uint);
    function nftPrice() external view returns (uint);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IRandomNumGenerator {
    function requestRandomNumber() external returns(bytes32 requestId);
    function result(bytes32) external returns(uint256);
}

interface IPriceConsumer {
    function usdToBnb(uint _amountInUsd) external view returns (uint);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract EternalZombiesLottery is Ownable, ReentrancyGuard, IERC721Receiver {

    address public  RANDOM_NUMBER_GENERATOR;
    address public  PRICE_CONSUMER; // 0xaBaAD8dBA90acf6ECd558e1f4c7055F8942283b1 <= FOR MAINNET
    address payable public TREASURY;

    mapping (address => bool) public  IS_OPERATOR; // is lottery operator

    struct Bid {
        uint id; // id of this bid
        uint lottery; // id of the lottery
        address bidder;
        uint amount; // bnb received 
        bool claimed; 
    }

    struct Lottery {
        address minter; // address of the token minter or for which collection the lottery is
        uint threshold; // threshold amount of bids to reach for a successfull lottery 
        uint minBidAmount; // amount in BNB to bid for
        uint expiresAt; // or valid till
        uint amountReceived; // total bnb received for this lottery
        uint totalBids; // amount of bids for this lottery, also serves as bid ids
        uint winner; // winner bid id of this round/lottery
        bool success; // if the lottery was successfull or didn't reach the min threshold for bid amount
        bytes32 requestId;
        uint randomNumber;
    }

    mapping (uint => Lottery) public lotteries; // serves as ids for lotteries

    mapping (uint => mapping(uint => Bid)) public bids; // mapping for lottery to bids

    mapping (uint => mapping(address => Bid)) public addressToBids; // additonal mapping for fast retrieval in claim

    // latest round of each lottery collection
    mapping (address => uint) public latestRound;

    // mapping from lottery id to winner
    mapping (uint => address) public roundWinner;

    constructor(
        address randomizer,
        address priceConsumer,
        address payable treasury
    ) {
        RANDOM_NUMBER_GENERATOR = randomizer;
        PRICE_CONSUMER = priceConsumer;
        IS_OPERATOR[msg.sender] = true;
        TREASURY = treasury;
    }

    function setRandomNumGenerator(address generator) public onlyOwner() {
        RANDOM_NUMBER_GENERATOR = generator;
    }

    function setPriceConsumer(address priceConsumer) public onlyOwner() {
        PRICE_CONSUMER = priceConsumer;
    }

    function setOperator(address _operator, bool set) public onlyOwner() {
        IS_OPERATOR[_operator] = set;
    }

    function setTreasuryAddress(address payable treasury) public onlyOwner() {
        TREASURY = treasury;
    }

    function createRound(address minter, uint minBids, uint bidAmount, uint expiry) public {
        require(IS_OPERATOR[msg.sender], "EZ: not lotto operator");
        uint currentRound = latestRound[minter];
        lotteries[currentRound] = Lottery({
            minter: minter,
            threshold: minBids,
            minBidAmount: bidAmount,
            expiresAt: block.timestamp + expiry,
            amountReceived: 0,
            totalBids: 0,
            winner: 0,
            success: false,
            requestId: bytes32(0),
            randomNumber: 0
        });
        latestRound[minter] += 1;
    }

    // NOTE :- have to process this lottery first before creating a new one.

    function requestRandomNum(address minter) public {
        require(IS_OPERATOR[msg.sender], "EZ: not operator");
        Lottery storage lottery = lotteries[latestRound[minter]];
        require(lottery.expiresAt < block.timestamp, "EZ: lottery ongoing");
        require(lottery.totalBids >= lottery.threshold, "EZ: lottery threshold not met");
        require(!lottery.success, "EZ: already announced");
        lottery.requestId = IRandomNumGenerator(RANDOM_NUMBER_GENERATOR).requestRandomNumber();
        lottery.success = true;
    }

    function processLottery(address minter) public onlyOwner {
        require(IS_OPERATOR[msg.sender], "EZ: not operator");
        Lottery storage lottery = lotteries[latestRound[minter]];
        require(lottery.success, "EZ: lottery unsuccessfull");
        uint randomNumber = IRandomNumGenerator(RANDOM_NUMBER_GENERATOR).result(lottery.requestId);
        lottery.randomNumber = randomNumber;
        lottery.winner = randomNumber % lottery.totalBids;
    }

    function bid(address minter) public payable nonReentrant {
        uint currentRound = latestRound[minter];
        Lottery storage lottery = lotteries[currentRound];
        require(lottery.expiresAt > block.timestamp, "EZ: lotto expired");
        uint bnbRequired = IPriceConsumer(PRICE_CONSUMER).usdToBnb(lottery.minBidAmount);
        require(msg.value >= bnbRequired, "EZ: not enough BNB");
        lottery.amountReceived += msg.value;
        bids[currentRound][lottery.totalBids] = Bid({
            id: lottery.totalBids,
            lottery: latestRound[minter],
            bidder: msg.sender,
            amount: msg.value,
            claimed: false
        });
        addressToBids[currentRound][msg.sender] = bids[currentRound][lottery.totalBids];
        lottery.totalBids += 1;
    }

    function claim(uint roundId) public nonReentrant {
        Lottery storage lottery = lotteries[roundId];
        require(!lottery.success && lottery.totalBids < lottery.threshold, "EZ: invalid claim");
        require(lottery.expiresAt < block.timestamp, "EZ: Lottery still in progress");
        Bid storage _bid = addressToBids[roundId][msg.sender];
        require(!_bid.claimed, "EZ: already claimed");
        require(_bid.bidder == msg.sender, "EZ: not your bid");
        _bid.claimed = true;
        payable(msg.sender).transfer(_bid.amount);
    }

    function claimLottery(uint roundId) public nonReentrant {
        Lottery storage lottery = lotteries[roundId];
        require(lottery.success && lottery.randomNumber != 0, "EZ: lottery unsuccessfull");
        require(lottery.expiresAt < block.timestamp, "EZ: lottery still in process");
        Bid storage _bid = bids[roundId][lottery.winner];
        require(_bid.bidder == msg.sender, "EZ: not your bid");
        require(!_bid.claimed, "EZ: already claimed");
        uint price = IMinter(lottery.minter).nftPrice();
        IMinter(lottery.minter).mint{value: price}(1);
        uint balance = IMinter(lottery.minter).balanceOf(address(this));
        uint tokenId = IMinter(lottery.minter).tokenOfOwnerByIndex(address(this), balance - 1);
        IMinter(lottery.minter).transferFrom(address(this), _bid.bidder, tokenId);
        uint remainingBnb = lottery.amountReceived - price;
        TREASURY.transfer(remainingBnb);
        _bid.claimed = true;
    }

    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}