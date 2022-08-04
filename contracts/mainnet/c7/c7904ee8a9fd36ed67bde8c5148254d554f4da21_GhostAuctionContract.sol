// SPDX-License-Identifier: no-license
pragma solidity ^0.8.15;

import "./interfaces/IERC721.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IERC721Receiver.sol";
import "./ERC721Holder.sol";
import "./abstracts/MarketRewards.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GhostAuctionContract is Ownable, ERC721Holder {
    bytes32 public MarketplaceStatus;

    /* Rewards & Taxes */
    IDEXRouter public router;
    MarketRewards public marketRewards;
    mapping(address => uint256) public pendingRewards; // For the rewards before contract sells them.

    address public immutable wbnbAddress;
    address payable public devWallet;

    /* Fees */
    Fees public fees;
    mapping(uint256 => uint256) public dailyFees;
    address public feeAddress;

    /* Auction Settings */
    mapping(address => mapping(address => uint256)) public minimumBidPrices; // NFT - token - price
    mapping(address => mapping(address => uint256)) public minimumBidIncrements; // NFT - token - increment
    address[] private acceptablePaymentTokens;
    address[] private acceptableNFTs;
    uint256 public maximumListingDuration = 10 days;
    uint256 public minimumListingDuration = 1 days;

    /* Auction History */
    Auction[] public auctions;
    mapping(address => uint256[]) public userAuctionsCreated;
    mapping(address => uint256[]) public userBidHistory;
    mapping(address => uint256[]) public userPurchaseHistory;
    mapping(address => uint256[]) public userBidsWon;
    mapping(address => mapping(uint256 => uint256[])) public previousBidHistory; // bidder - auctionID - bids
    mapping(uint256 => uint256[]) public auctionBidHistory;
    mapping(uint256 => uint256[2]) public auctionBlocks; // auctionID - [startBlock, endBlock]
    uint256 public bidsWon = 0;
    uint256 public buyOutCount = 0;
    mapping(address => mapping(uint256 => Auction))
        public auctionsForCollections;

    /* Structs */
    struct Auction {
        uint256 auctionID;
        uint256 price;
        IBEP20 paymentToken;
        IERC721 nft;
        bool bidOnly;
        bytes32 status;
        uint256 tokenID;
        uint256 minimumBidAmount;
        address createdBy;
        address highestBidder;
        uint256 highestBidAmount;
        uint256 biddingFeePaid;
        uint256 listingFeeAmount;
        uint256 endBlock;
    }

    struct Fees {
        uint256 listingFeePercentage;
        uint256 biddingFeePercentage;
        uint256 auctionCreatorBiddingFeePercentage;
        uint256 buyOutFeePercentage;
    }

    /* Events */
    event NFTAdded(address indexed nftAddress);
    event NFTRemoved(address indexed nftAddress);
    event TokenAdded(address indexed tokenAddress);
    event TokenRemoved(address indexed tokenAddress);
    event BidReceived(
        address indexed bidder,
        uint256 indexed auctionID,
        uint256 bidAmount
    );
    event BuyOut(
        address indexed buyer,
        uint256 indexed auctionID,
        uint256 amount
    );
    event AuctionCancelled(uint256 indexed auctionID);
    event AuctionFinalized(
        address indexed buyer,
        uint256 indexed auctionID,
        uint256 time
    );
    event CreateAuction(
        address indexed _creator,
        address indexed _paymentToken,
        uint256 _price,
        address indexed _nft,
        uint256 _endBlock,
        uint256 id,
        bool buyOutOnly,
        uint256 minimumBidAmount
    );

    constructor(
        address feeAddress_,
        address routerAddress_,
        address marketAddress_,
        address wbnbAddress_,
        address devWallet_
    ) {
        /* Initialize market status and states */
        MarketplaceStatus = "Active";
        fees = Fees({
            listingFeePercentage: 0,
            biddingFeePercentage: 0,
            auctionCreatorBiddingFeePercentage: 0,
            buyOutFeePercentage: 0
        });

        /* Set wbnb address */
        wbnbAddress = wbnbAddress_;

        /* Set fee receiver address */
        feeAddress = feeAddress_;

        /* Set dev wallet */
        devWallet = payable(devWallet_);

        /* Set router */
        router = IDEXRouter(routerAddress_);

        /* Set marketplace reward address */
        marketRewards = MarketRewards(marketAddress_);
    }

    function createAuction(
        address paymentTokenAddress,
        uint256 _price,
        address nftAddress,
        uint256 _durationBlocks,
        uint256 tokenID,
        bool _bidOnly,
        uint256 _minimumBidAmount
    ) external {
        require(
            MarketplaceStatus == "Active",
            "createAuction: Marketplace is not active"
        );
        require(
            _durationBlocks <= maximumListingDuration,
            "createAuction: Longer than maximum listing time."
        );
        require(
            _durationBlocks >= minimumListingDuration,
            "createAuction: Shorter than minimum listing time."
        );
        require(
            isAcceptablePaymentToken(paymentTokenAddress) == true,
            "createAuction: Payment token is not acceptable."
        );
        require(
            isAcceptableNFT(nftAddress) == true,
            "createAuction: NFT is not acceptable."
        );
        require(
            minimumBidPrices[nftAddress][paymentTokenAddress] <
                _minimumBidAmount,
            "createAuction: Lower than minimum bid price for this nft."
        );
        IERC721 pNft = IERC721(nftAddress);
        require(
            pNft.balanceOf(msg.sender) >= 1,
            "createAuction: User does not own the nft they are trying to list."
        );
        require(
            pNft.ownerOf(tokenID) == msg.sender,
            "createAuction: User does not own the given nft with id"
        );
        uint256 _id = auctions.length;
        uint256 _feeAmount = getListingFee(_price, _durationBlocks);
        pNft.transferFrom(msg.sender, address(this), tokenID);
        uint256 _startBlock = block.timestamp;
        uint256 _endblock = _startBlock + _durationBlocks;

        auctions.push(
            Auction({
                auctionID: _id,
                createdBy: msg.sender,
                status: "Active",
                paymentToken: IBEP20(paymentTokenAddress),
                nft: pNft,
                price: _price,
                tokenID: tokenID,
                bidOnly: _bidOnly,
                endBlock: _endblock,
                highestBidAmount: 0,
                minimumBidAmount: _minimumBidAmount,
                highestBidder: address(0),
                biddingFeePaid: 0,
                listingFeeAmount: _feeAmount
            })
        );

        auctionsForCollections[nftAddress][tokenID] = Auction({
            auctionID: _id,
            createdBy: msg.sender,
            status: "Active",
            paymentToken: IBEP20(paymentTokenAddress),
            nft: pNft,
            price: _price,
            tokenID: tokenID,
            bidOnly: _bidOnly,
            endBlock: _endblock,
            highestBidAmount: 0,
            minimumBidAmount: _minimumBidAmount,
            highestBidder: address(0),
            biddingFeePaid: 0,
            listingFeeAmount: _feeAmount
        });

        auctionBlocks[_id] = [_startBlock, _endblock];
        userAuctionsCreated[msg.sender].push(_id);
        emit CreateAuction(
            msg.sender,
            paymentTokenAddress,
            _price,
            nftAddress,
            _endblock,
            _id,
            _bidOnly,
            _minimumBidAmount
        );
    }

    function bid(uint256 auctionID, uint256 amount) external {
        require(
            MarketplaceStatus == "Active" ||
                MarketplaceStatus == "Purchase Only",
            "bid: Marketplace is not active."
        );
        Auction storage auction = auctions[auctionID];
        require(
            auction.status == "Active",
            "bid: Requested auction is not active"
        );
        require(
            auctionBlocks[auctionID][1] >= block.timestamp,
            "bid: Listing has expired."
        );
        require(
            auction.createdBy != msg.sender,
            "bid: Auction creator cannot bid on their own listing"
        );
        require(
            auction.highestBidAmount < amount,
            "bid: There is already a higher bid on this listing."
        );
        require(
            auction.minimumBidAmount <= amount,
            "bid: Given bid amount is below the minimum amount specified by lister"
        );
        require(
            amount >=
                auction.highestBidAmount +
                    minimumBidIncrements[address(auction.nft)][
                        address(auction.paymentToken)
                    ],
            "bid: Given bid amount is below the minimum bid increment"
        );
        uint256 biddingFee = getBiddingFee(amount);
        require(
            auction.paymentToken.balanceOf(msg.sender) >= (amount + biddingFee),
            "bid: Bidder does not have enough tokens to bid on this listing."
        );
        uint256 previousHighestBidAmount = auction.highestBidAmount;
        address previousHighestBidder = auction.highestBidder;
        if (
            previousHighestBidder != address(0)
        ) // If there is a bidder, return their tokens before receiving the new bid
        {
            previousBidHistory[previousHighestBidder][auction.auctionID].push(
                previousHighestBidAmount
            );
            auction.paymentToken.transfer(
                previousHighestBidder,
                previousHighestBidAmount
            );
        }
        uint256 creatorBiddingReturn = (biddingFee *
            fees.auctionCreatorBiddingFeePercentage) / 10000;
        auction.paymentToken.transferFrom(
            msg.sender,
            feeAddress,
            biddingFee - creatorBiddingReturn
        );
        auction.paymentToken.transferFrom(
            msg.sender,
            auction.createdBy,
            creatorBiddingReturn
        );
        auction.paymentToken.transferFrom(msg.sender, address(this), amount);
        auctions[auctionID].listingFeeAmount = getListingFee(
            amount,
            auctionBlocks[auctionID][1] - auctionBlocks[auctionID][0]
        );
        auctions[auctionID].highestBidAmount = amount;
        auctions[auctionID].highestBidder = msg.sender;
        auctions[auctionID].biddingFeePaid = biddingFee;
        userBidHistory[msg.sender].push(auction.auctionID);
        auctionBidHistory[auction.auctionID].push(amount);
        emit BidReceived(msg.sender, auctionID, amount);
    }

    function buyOut(uint256 auctionID) external {
        require(
            MarketplaceStatus == "Active" ||
                MarketplaceStatus == "Purchase Only",
            "buyOut: Marketplace is not active."
        );
        Auction storage auction = auctions[auctionID];
        require(
            auction.bidOnly == false,
            "buyOut: This auction is for bidding only."
        );
        require(
            auctionBlocks[auctionID][1] >= block.timestamp,
            "buyOut: Listing has expired."
        );
        require(
            auction.createdBy != msg.sender,
            "buyOut: Auction creator cannot buy their own listing out"
        );
        require(auction.status == "Active", "buyOut: Listing is not active.");
        uint256 buyOutFee = (auction.price * fees.buyOutFeePercentage) / 10000;
        uint256 rewardFee = (auction.price * 1000) / 10000; //10%
        require(
            auction.paymentToken.balanceOf(msg.sender) >=
                (buyOutFee + auction.price),
            "buyOut: Buyer does not have enough tokens to buy this item."
        );
        if (auction.highestBidder != address(0)) {
            auction.paymentToken.transfer(
                auction.highestBidder,
                auction.highestBidAmount
            );
        }
        auctions[auctionID].listingFeeAmount = getListingFee(
            auction.price,
            auctionBlocks[auctionID][1] - auctionBlocks[auctionID][0]
        );
        pendingRewards[address(auction.paymentToken)] += rewardFee;
        auction.paymentToken.transferFrom(
            msg.sender,
            address(this),
            auction.price
        );
        auction.paymentToken.transfer(
            auction.createdBy,
            auction.price - rewardFee
        );
        auction.nft.safeTransferFrom(
            address(this),
            msg.sender,
            auction.tokenID
        );
        auctions[auctionID].status = "Bought Out";
        auctionsForCollections[address(auction.nft)][auction.tokenID]
            .status = "Bought Out";
        userPurchaseHistory[msg.sender].push(auction.auctionID);
        buyOutCount++;
        emit BuyOut(msg.sender, auctionID, auction.price);
    }

    function finalizeAuction(uint256 auctionID) external {
        require(
            MarketplaceStatus == "Active" ||
                MarketplaceStatus == "Purchase Only",
            "finalizeAuction: Marketplace is not active."
        );
        Auction storage auction = auctions[auctionID];
        require(
            auctionBlocks[auctionID][1] < block.timestamp,
            "finalizeAuction: Listing did not expire yet."
        );
        auctions[auctionID].status = "Finished";
        auctionsForCollections[address(auction.nft)][auction.tokenID]
            .status = "Finished";
        uint256 rewardFee = (auction.highestBidAmount * 1000) / 10000; //10%
        if (auction.highestBidder != address(0)) {
            auctions[auctionID].listingFeeAmount = getListingFee(
                auction.highestBidAmount,
                auctionBlocks[auctionID][1] - auctionBlocks[auctionID][0]
            );
            auction.nft.safeTransferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenID
            );
            auction.paymentToken.transfer(
                auction.createdBy,
                auction.highestBidAmount - rewardFee
            );
            pendingRewards[address(auction.paymentToken)] += rewardFee;
            userBidsWon[auction.highestBidder].push(auction.auctionID);
            bidsWon++;
        } else {
            auction.nft.safeTransferFrom(
                address(this),
                auction.createdBy,
                auction.tokenID
            );
        }

        emit AuctionFinalized(
            auction.highestBidder,
            auctionID,
            block.timestamp
        );
    }

    function cancelAuction(uint256 auctionID) external {
        require(
            MarketplaceStatus == "Active" ||
                MarketplaceStatus == "Purchase Only",
            "cancelAuction: Marketplace is not active."
        );
        Auction storage auction = auctions[auctionID];
        require(
            auction.createdBy == msg.sender,
            "cancelAuction: Not authorized."
        );
        require(
            auctionBlocks[auctionID][1] >= block.timestamp,
            "cancelAuction: Listing has already expired."
        );
        require(
            auction.status == "Active",
            "cancelAuction: Listing is not active."
        );
        require(
            auction.paymentToken.balanceOf(msg.sender) >=
                auction.biddingFeePaid,
            "cancelAuction: Not enough funds to cover the biddingFees"
        );

        require(
            auction.highestBidder == address(0),
            "Cannot cancel an auction with active bids"
        );

        auction.nft.safeTransferFrom(
            address(this),
            auction.createdBy,
            auction.tokenID
        );
        auctions[auctionID].status = "Cancelled";
        auctionsForCollections[address(auction.nft)][auction.tokenID]
            .status = "Cancelled";
        emit AuctionCancelled(auctionID);
    }

    /* Swaps */
    function swapForRewards(address addr_) external onlyOwner {
        require(isAcceptablePaymentToken(addr_), "Token not supported");
        uint256 amountToSwap_ = pendingRewards[addr_];

        if (addr_ == wbnbAddress) {
            if (amountToSwap_ > 0) {
                IWETH(wbnbAddress).withdraw(amountToSwap_);
                pendingRewards[wbnbAddress] = 0;
            }
        } else if (amountToSwap_ > 0) {
            sellToken(addr_, amountToSwap_);
        }
    }

    function swapForRewards() external onlyOwner {
        address paymentToken_;
        uint256 pendingReward_;
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            paymentToken_ = acceptablePaymentTokens[i];
            pendingReward_ = pendingRewards[paymentToken_];
            if (paymentToken_ == wbnbAddress) {
                if (pendingReward_ > 0) {
                    pendingRewards[wbnbAddress] = 0;
                    IWETH(wbnbAddress).withdraw(pendingReward_);
                }
            } else if (pendingReward_ > 0) {
                sellToken(paymentToken_, pendingReward_);
            }
        }

        uint256 minterReward = address(this).balance / 4;
        uint256 holderReward = address(this).balance / 2;
        uint256 devReward = (address(this).balance -
            (minterReward + holderReward));

        //Transfer 25% to minters and 50% to holders to the Reward Contract
        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();

        //Transfer 25% to the development wallet
        devWallet.transfer(devReward);
    }

    /* Public functions */
    function getLength_AcceptableNFTs() external view returns (uint256) {
        return acceptableNFTs.length;
    }

    function getLength_AcceptablePaymentTokens()
        external
        view
        returns (uint256)
    {
        return acceptablePaymentTokens.length;
    }

    function isAcceptableNFT(address addr) public view returns (bool) {
        for (uint256 i = 0; i < acceptableNFTs.length; i++) {
            if (acceptableNFTs[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function getLength_Auctions() external view returns (uint256) {
        return auctions.length;
    }

    function getLength_AuctionBidHistory(uint256 auctionID)
        external
        view
        returns (uint256)
    {
        return auctionBidHistory[auctionID].length;
    }

    function getLength_UserBidHistory(address addr)
        external
        view
        returns (uint256)
    {
        return userBidHistory[addr].length;
    }

    function getLength_PreviousBidHistory(address addr, uint256 auctionID)
        external
        view
        returns (uint256)
    {
        return previousBidHistory[addr][auctionID].length;
    }

    function getLength_BidsWonByUser(address addr)
        external
        view
        returns (uint256)
    {
        return userBidsWon[addr].length;
    }

    function getLength_UserPurchaseHistory(address addr)
        external
        view
        returns (uint256)
    {
        return userPurchaseHistory[addr].length;
    }

    function getLength_AuctionsCreatedByUser(address addr)
        external
        view
        returns (uint256)
    {
        return userAuctionsCreated[addr].length;
    }

    function getListingFee(uint256 price, uint256 durationBlocks)
        public
        view
        returns (uint256)
    {
        return
            ((price * fees.listingFeePercentage) / 10000) +
            getTotalDailyListingFee(price, durationBlocks);
    }

    function getTotalDailyListingFee(uint256 price, uint256 durationBlocks)
        public
        view
        returns (uint256)
    {
        return
            (price * getDailyFeePercentageForDuration(durationBlocks)) / 10000;
    }

    function getDailyFeePercentageForDuration(uint256 durationBlocks)
        public
        view
        returns (uint256)
    {
        uint256 listingDays = durationBlocks / (1 days);
        uint256 totalPercentages = 0;
        for (uint256 i = 0; i < listingDays + 1; i++) {
            totalPercentages += dailyFees[i];
        }
        return totalPercentages;
    }

    function getBiddingFee(uint256 price) public view returns (uint256) {
        return (price * fees.biddingFeePercentage) / 10000;
    }

    function viewAuctionByCollectionAndTokenID(
        address collection,
        uint256 tokenID
    ) external view returns (Auction memory auctionsInfo) {
        return auctionsForCollections[collection][tokenID];
    }

    function getAcceptablePaymentTokens()
        external
        view
        returns (address[] memory)
    {
        return acceptablePaymentTokens;
    }

    function getAcceptableNFTs() external view returns (address[] memory) {
        return acceptableNFTs;
    }

    /* Helper functions */
    function sellToken(address contractAddress, uint256 amount) internal {
        pendingRewards[contractAddress] = 0;

        address[] memory path = new address[](2);
        path[0] = contractAddress;
        path[1] = router.WETH();

        IBEP20(contractAddress).approve(address(router), amount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function isAcceptablePaymentToken(address addr_)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            if (acceptablePaymentTokens[i] == addr_) {
                return true;
            }
        }
        return false;
    }

    function addAcceptablePaymentToken(address addr_) private {
        if (!isAcceptablePaymentToken(addr_)) {
            acceptablePaymentTokens.push(addr_);
            emit TokenAdded(addr_);
        }
    }

    function addAcceptableNFT(address addr_) private {
        if (!isAcceptableNFT(addr_)) {
            acceptableNFTs.push(addr_);
            emit NFTAdded(addr_);
        }
    }

    function removeAcceptablePaymentToken(address addr_) private {
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++) {
            if (acceptablePaymentTokens[i] == addr_) {
                acceptablePaymentTokens[i] = acceptablePaymentTokens[
                    acceptablePaymentTokens.length - 1
                ];
                acceptablePaymentTokens.pop();
                emit TokenRemoved(addr_);
                break;
            }
        }
    }

    function removeAcceptableNFT(address addr_) private {
        for (uint256 i = 0; i < acceptableNFTs.length; i++) {
            if (acceptableNFTs[i] == addr_) {
                acceptableNFTs[i] = acceptableNFTs[acceptableNFTs.length - 1];
                acceptableNFTs.pop();
                emit NFTRemoved(addr_);
                break;
            }
        }
    }

    /* Admin actions */
    function setDevWallet(address addr) external onlyOwner {
        require(addr != address(0), "Can not be the zero address.");
        devWallet = payable(addr);
    }

    function adminCancelAuction(uint256 auctionID) external onlyOwner {
        Auction storage auction = auctions[auctionID];
        require(auction.status == "Active", "adminCancelAuction: not active.");
        if (auction.highestBidder != address(0)) {
            auction.paymentToken.transfer(
                auction.highestBidder,
                auction.highestBidAmount
            );
        }
        auction.nft.safeTransferFrom(
            address(this),
            auction.createdBy,
            auction.tokenID
        );
        auctions[auctionID].status = "Cancelled";
        auctionsForCollections[address(auction.nft)][auction.tokenID]
            .status = "Cancelled";
        emit AuctionCancelled(auctionID);
    }

    function emergencyCancelAuctions() external onlyOwner {
        for (uint256 auctionID = 0; auctionID < auctions.length; auctionID++) {
            Auction storage auction = auctions[auctionID];
            if (auction.status == "Active") {
                if (auction.highestBidder != address(0)) {
                    auction.paymentToken.transfer(
                        auction.highestBidder,
                        auction.highestBidAmount
                    );
                }
                auction.nft.safeTransferFrom(
                    address(this),
                    auction.createdBy,
                    auction.tokenID
                );
                auctions[auctionID].status = "Cancelled";
                auctionsForCollections[address(auction.nft)][auction.tokenID]
                    .status = "Cancelled";
                emit AuctionCancelled(auctionID);
            }
        }
    }

    function emergencyFinalizeAuctions() external onlyOwner {
        for (uint256 auctionID = 0; auctionID < auctions.length; auctionID++) {
            Auction storage auction = auctions[auctionID];
            uint256 rewardFee = (auction.highestBidAmount * 1000) / 10000; //10%
            if (
                auction.status == "Active" &&
                auctionBlocks[auctionID][1] < block.timestamp
            ) {
                if (auction.highestBidder != address(0)) {
                    auction.paymentToken.transfer(
                        auction.createdBy,
                        auction.highestBidAmount - rewardFee
                    );
                    pendingRewards[address(auction.paymentToken)] += rewardFee;
                    auction.nft.safeTransferFrom(
                        address(this),
                        auction.highestBidder,
                        auction.tokenID
                    );
                } else {
                    auction.nft.safeTransferFrom(
                        address(this),
                        auction.createdBy,
                        auction.tokenID
                    );
                }
                auctions[auctionID].status = "Finalized";
                auctionsForCollections[address(auction.nft)][auction.tokenID]
                    .status = "Finalized";
                emit AuctionFinalized(
                    auction.highestBidder,
                    auctionID,
                    block.timestamp
                );
            }
        }
    }

    function adminFinalizeAuction(uint256 auctionID) external onlyOwner {
        Auction storage auction = auctions[auctionID];
        require(
            auctionBlocks[auctionID][1] < block.timestamp,
            "adminFinalizeAuction: Listing did not expire yet."
        );
        auctions[auctionID].status = "Finalized";
        auctionsForCollections[address(auction.nft)][auction.tokenID]
            .status = "Finalized";
        uint256 rewardFee = (auction.highestBidAmount * 1000) / 10000; //10%
        if (auction.highestBidder != address(0)) {
            auction.nft.safeTransferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenID
            );
            auction.paymentToken.transfer(
                auction.createdBy,
                auction.highestBidAmount - rewardFee
            );
            pendingRewards[address(auction.paymentToken)] += rewardFee;
            userBidsWon[auction.highestBidder].push(auction.auctionID);
            bidsWon++;
        } else {
            auction.nft.safeTransferFrom(
                address(this),
                auction.createdBy,
                auction.tokenID
            );
        }

        emit AuctionFinalized(
            auction.highestBidder,
            auctionID,
            block.timestamp
        );
    }

    function setMinimumBidPrice(
        address nftAddress,
        address paymentTokenAddress,
        uint256 amount
    ) external onlyOwner {
        require(nftAddress != address(0), "setMinimumBidPrice: Not good");
        require(
            paymentTokenAddress != address(0),
            "setMinimumBidPrice: Not good"
        );
        require(
            isAcceptableNFT(nftAddress) == true,
            "setMinimumBidPrice: Not in the acceptable NFT list."
        );
        require(
            isAcceptablePaymentToken(paymentTokenAddress) == true,
            "setMinimumBidPrice: Not in the acceptable token list."
        );
        minimumBidPrices[nftAddress][paymentTokenAddress] = amount;
    }

    function setMinimumBidIncrement(
        address nftAddress_,
        address paymentTokenAddress_,
        uint256 increment_
    ) external onlyOwner {
        require(nftAddress_ != address(0), "setMinimumBidIncrement: Not good");
        require(
            paymentTokenAddress_ != address(0),
            "setMinimumBidIncrement: Not good"
        );
        require(
            isAcceptableNFT(nftAddress_) == true,
            "setMinimumBidIncrement: Not in the acceptable NFT list."
        );
        require(
            isAcceptablePaymentToken(paymentTokenAddress_) == true,
            "setMinimumBidIncrement: Not in the acceptable token list."
        );
        minimumBidIncrements[nftAddress_][paymentTokenAddress_] = increment_;
    }

    function setListingFeePercentage(uint256 _feePercentage)
        external
        onlyOwner
    {
        require(_feePercentage <= 10000, "setListingFeePercentage: Not good.");
        require(
            fees.listingFeePercentage != _feePercentage,
            "setListingFeePercentage: Already set."
        );
        fees.listingFeePercentage = _feePercentage;
    }

    function setBiddingFeePercentage(uint256 _feePercentage)
        external
        onlyOwner
    {
        require(_feePercentage <= 10000, "setBiddingFeePercentage: Not good.");
        require(
            fees.biddingFeePercentage != _feePercentage,
            "setBiddingFeePercentage: Already set."
        );
        fees.biddingFeePercentage = _feePercentage;
    }

    function setAuctionCreatorBiddingFeePercentage(uint256 _feePercentage)
        external
        onlyOwner
    {
        require(
            _feePercentage <= 10000,
            "setAuctionCreatorBiddingFeePercentage: Not good."
        );
        require(
            fees.auctionCreatorBiddingFeePercentage != _feePercentage,
            "setAuctionCreatorBiddingFeePercentage: Already set."
        );
        fees.auctionCreatorBiddingFeePercentage = _feePercentage;
    }

    function setBuyOutFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 10000, "setBuyOutFeePercentage: Not good.");
        require(
            fees.buyOutFeePercentage != _feePercentage,
            "setAuctionCreatorBiddingFeePercentage: Already set."
        );
        fees.buyOutFeePercentage = _feePercentage;
    }

    function transferToDevWallet() external onlyOwner {
        devWallet.transfer(address(this).balance);
    }

    function addBNBToRewardContract() external onlyOwner {
        uint256 minterReward = address(this).balance / 4;
        uint256 holderReward = address(this).balance / 2;

        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();
    }

    function setMarketReward(address addr_) external onlyOwner {
        require(addr_ != address(0), "Can not be the zero address.");
        marketRewards = MarketRewards(addr_);
    }

    function setRouter(address addr_) external onlyOwner {
        require(addr_ != address(0), "Can not be the zero address.");
        router = IDEXRouter(addr_);
    }

    function setMarketplaceStatus_Active() external onlyOwner {
        require(
            MarketplaceStatus != "Active",
            "activateMarketplace: Already active"
        );
        MarketplaceStatus = "Active";
    }

    function setMarketplaceStatus_Inactive() external onlyOwner {
        require(
            MarketplaceStatus != "Inactive",
            "deactivateMarketplace: Already deactivated"
        );
        MarketplaceStatus = "Inactive";
    }

    function setMarketplaceStatus_PurchaseOnly() external onlyOwner {
        require(
            MarketplaceStatus != "Purchase Only",
            "deactivateMarketplace: Already deactivated"
        );
        MarketplaceStatus = "Purchase Only";
    }

    function setDailyFeePercentage(uint256 dayIndex, uint256 _feePercentage)
        external
        onlyOwner
    {
        require(_feePercentage <= 10000, "setDailyFeePercentage: Not good.");
        dailyFees[dayIndex] = _feePercentage;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "setFeeAddress: Not good");
        require(feeAddress != _feeAddress, "setFeeAddress: Already set.");
        feeAddress = _feeAddress;
    }

    function setMaximumListingDuration(uint256 duration) external onlyOwner {
        require(
            maximumListingDuration != duration,
            "setMaximumListingDuration: Duration already set."
        );
        maximumListingDuration = duration;
    }

    function setMinimumListingDuration(uint256 duration) external onlyOwner {
        require(
            minimumListingDuration != duration,
            "setMinimumListingDuration: Duration already set."
        );
        minimumListingDuration = duration;
    }

    function setAcceptableNFT(address addr_, bool acceptable_)
        external
        onlyOwner
    {
        require(addr_ != address(0), "setAcceptablePaymentToken: Not good");
        if (acceptable_) {
            addAcceptableNFT(addr_);
        } else {
            removeAcceptableNFT(addr_);
        }
    }

    function setAcceptablePaymentToken(address addr_, bool acceptable_)
        external
        onlyOwner
    {
        require(addr_ != address(0), "setAcceptablePaymentToken: Not good");
        if (acceptable_) {
            addAcceptablePaymentToken(addr_);
        } else {
            removeAcceptablePaymentToken(addr_);
        }
    }

    /* Fallback */
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./interfaces/IERC721Receiver.sol";

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

// SPDX-License-Identifier: No License

pragma solidity ^0.8.15;

abstract contract MarketRewards {
    function reflectToMinters() public payable virtual;

    function reflectToHolders() public payable virtual;
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
pragma solidity ^0.8.15;

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