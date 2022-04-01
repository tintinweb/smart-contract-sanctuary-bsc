/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

pragma solidity ^0.6.8;
// import "hardhat/console.sol";

interface IERC721 {
    function burn(uint256 tokenId) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        string calldata _payload
    ) external;

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    function ownerOf(uint256 _tokenId) external returns (address _owner);

    function getApproved(uint256 _tokenId) external returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

contract AuctionNFT {
    struct Bid {
        address payable user;
        uint256 amount;
    }

    struct Order {
        uint256 tokenId;
        address nftAddress;
        address buyer;
        address payable seller;
        uint256 price;
        uint256 startTime;
        uint256 deadline;
        uint256 bidCount;
        uint256[] bidList;
        mapping(uint256 => Bid) bids;
        mapping(address => bool) bidder;
        mapping(address => uint256) bidNo;
        uint256 fee;
        uint256 royalityPercent;
        address payable royalityAddress;
        uint256 highestBid;
        uint256[] bundleIds; // Add Bundle Ids for NFT Bundles
        string orderType; // single || bundle
        bool isOpenForBids;
    }

    address public owner;
    uint256 public orderFee;
    address payable benefactor;

    mapping(uint256 => Order) public pendingOrders;
    mapping(uint256 => Order) public completedOrders;
    mapping(uint256 => Order) public cancelledOrders;

    mapping(uint256 => bool) public isTokenListed;
    uint256[] orderList;

    string constant IS_OWNER = "003008";
    string constant NOT_ENOUGH_PAYMENT = "004001";
    string constant NOT_APPROVED_FOR_ALL = "004002";
    string constant ONLY_SELLER_CANCEL = "004003";
    string constant PROVIDE_VALID_FEE = "004004";
    string constant IS_SELLER_ADMIN = "004005";
    string constant NEED_TO_APPROVE = "004006";
    string constant BID_SHOULD_GREATER = "004007";
    string constant ITSELF_SELLER = "004008";
    string constant AUCTION_ENDED = "004009";
    string constant AUCTION_NOT_ENDED = "0040010";
    string constant NOT_APPROVED = "004011";
    string constant NOT_VALID_BIDDER = "0040012";

    event AddAuction(
        uint256 _orderNumber,
        uint256 _tokenId,
        address _nftAddress,
        address _seller,
        uint256 _price,
        uint256 _startTime,
        uint256 _deadline,
        address _royalityAddress,
        uint256 _royalityPercent,
        bool _isOpenForBids
    );
    event CancelAuction(uint256 _orderNumber, address _seller);
    event AddBid(
        uint256 _orderNumber,
        uint256 _bidAmount,
        address _bidder,
        uint256 _bidCount,
        address _nftAddress,
        uint256 _tokenId
    );
    event FinalizeAuction(
        uint256 _orderNumber,
        bool _isConfirm,
        address _seller,
        address _nftAddress
    );
    event AddBundleAuction(
        uint256 _orderNumber,
        address _nftAddress,
        address _seller,
        uint256 _price,
        uint256 _startTime,
        uint256 _deadline,
        address _royalityAddress,
        uint256 _royalityPercent,
        bool _isOpenForBids,
        string _nftType
    );
    event CancelBid(uint256 _orderNumber, uint256 _bidNo, address _bidder, uint256 _amount);

    modifier isOwner() {
        require(msg.sender == owner, IS_OWNER);
        _;
    }

    modifier isSellerOrAdmin(uint256 orderNumber) {
        require(
            msg.sender == owner ||
                msg.sender == pendingOrders[orderNumber].seller,
            IS_SELLER_ADMIN
        );
        _;
    }

    constructor(uint256 fee) public {
        require(fee <= 10000, PROVIDE_VALID_FEE);
        orderFee = fee;
        benefactor = msg.sender;
        owner = msg.sender;
    }

    function _computeFee(uint256 _price) public view returns (uint256) {
        return (_price * orderFee) / 10000;
    }

    function computeRoyality(uint256 _price, uint256 _royality)
        public
        pure
        returns (uint256)
    {
        return (_price * _royality) / 10000;
    }

    function changeFee(uint256 fee) public isOwner {
        require(fee <= 10000, PROVIDE_VALID_FEE);
        orderFee = fee;
    }

    function changeBenefactor(address payable newBenefactor) public isOwner {
        benefactor = newBenefactor;
    }

    function addAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 orderNumber,
        uint256 startTime,
        uint256 deadline,
        uint256 royalityPercent,
        address payable royalityAddress,
        bool isOpenForBids
    ) public {
        address tokenOwner = IERC721(nftAddress).getApproved(tokenId);
        require(
            IERC721(nftAddress).isApprovedForAll(msg.sender, address(this)) ==
                true,
            NEED_TO_APPROVE
        );
        require(
            IERC721(nftAddress).getApproved(tokenId) == address(this),
            NOT_APPROVED
        );
        pendingOrders[orderNumber].tokenId = tokenId;
        pendingOrders[orderNumber].nftAddress = nftAddress;
        pendingOrders[orderNumber].buyer = address(this);
        pendingOrders[orderNumber].seller = msg.sender;
        pendingOrders[orderNumber].price = price;
        pendingOrders[orderNumber].startTime = startTime;
        pendingOrders[orderNumber].orderType = "single";
        pendingOrders[orderNumber].deadline = deadline;
        pendingOrders[orderNumber].royalityPercent = royalityPercent;
        pendingOrders[orderNumber].royalityAddress = royalityAddress;
        pendingOrders[orderNumber].isOpenForBids = isOpenForBids;
        isTokenListed[tokenId] = true;

        orderList.push(orderNumber);

        emit AddAuction(
            orderNumber,
            tokenId,
            nftAddress,
            msg.sender,
            price,
            startTime,
            deadline,
            royalityAddress,
            royalityPercent,
            isOpenForBids
        );
    }

    // Client side, should first call [NFTADDRESS].approve(Swap.sol.address, tokenId)
    // in order to authorize this contract to transfer nft to buyer
    function addMultiAuction(
        address nftAddress,
        uint256[] memory tokenId,
        uint256 price,
        uint256[] memory orderNumber,
        uint256 startTime,
        uint256 deadline,
        uint256 royalityPercent,
        address payable royalityAddress,
        bool isOpenForBids
    ) public {
        require(
            IERC721(nftAddress).isApprovedForAll(msg.sender, address(this)) ==
                true,
            NEED_TO_APPROVE
        );
        for (uint256 i = 0; i < tokenId.length; i++) {
            pendingOrders[orderNumber[i]].tokenId = tokenId[i];
            pendingOrders[orderNumber[i]].nftAddress = nftAddress;
            pendingOrders[orderNumber[i]].buyer = address(this);
            pendingOrders[orderNumber[i]].seller = msg.sender;
            pendingOrders[orderNumber[i]].price = price;
            pendingOrders[orderNumber[i]].startTime = startTime;
            pendingOrders[orderNumber[i]].deadline = deadline;
            pendingOrders[orderNumber[i]].royalityPercent = royalityPercent;
            pendingOrders[orderNumber[i]].royalityAddress = royalityAddress;
            pendingOrders[orderNumber[i]].isOpenForBids = isOpenForBids;
            isTokenListed[tokenId[i]] = true;

            orderList.push(orderNumber[i]);

            emit AddAuction(
                orderNumber[i],
                tokenId[i],
                nftAddress,
                msg.sender,
                price,
                startTime,
                deadline,
                royalityAddress,
                royalityPercent,
                isOpenForBids
            );
        }
    }

    function addMultiAuctionForAdmin(
        address nftAddress,
        uint256[] memory tokenId,
        uint256 price,
        uint256[] memory orderNumber,
        uint256 startTime,
        address seller,
        uint256 deadline,
        uint256 royalityPercent,
        address payable royalityAddress,
        bool isOpenForBids
    ) public {
        require(msg.sender == owner, IS_OWNER);
        for (uint256 i = 0; i < tokenId.length; i++) {
            pendingOrders[orderNumber[i]].tokenId = tokenId[i];
            pendingOrders[orderNumber[i]].nftAddress = nftAddress;
            pendingOrders[orderNumber[i]].buyer = address(this);
            pendingOrders[orderNumber[i]].seller = payable(seller);
            pendingOrders[orderNumber[i]].price = price;
            pendingOrders[orderNumber[i]].startTime = startTime;
            pendingOrders[orderNumber[i]].deadline = deadline;
            pendingOrders[orderNumber[i]].royalityPercent = royalityPercent;
            pendingOrders[orderNumber[i]].royalityAddress = royalityAddress;
            pendingOrders[orderNumber[i]].isOpenForBids = isOpenForBids;
            isTokenListed[tokenId[i]] = true;
            orderList.push(orderNumber[i]);

            emit AddAuction(
                orderNumber[i],
                tokenId[i],
                nftAddress,
                seller,
                price,
                startTime,
                deadline,
                royalityAddress,
                royalityPercent,
                isOpenForBids
            );
        }
    }

    function bid(uint256 orderNumber) public payable {
        Order storage order = pendingOrders[orderNumber];
        require(msg.value >= order.price, NOT_ENOUGH_PAYMENT);

        require(order.seller != msg.sender, ITSELF_SELLER);
        // require(msg.value > order.highestBid, BID_SHOULD_GREATER); // Added for bid more than highest bid
        if (!order.isOpenForBids) require(now <= order.deadline, AUCTION_ENDED);
        require(
            IERC721(order.nftAddress).isApprovedForAll(
                order.seller,
                address(this)
            ) == true,
            NEED_TO_APPROVE
        );
        for (uint256 i = 1; i <= order.bidCount; i++) {
            if (order.bids[i].user == msg.sender) {
                require(msg.value > order.bids[i].amount, BID_SHOULD_GREATER);
                order.bids[i].user.transfer(order.bids[i].amount);
                delete order.bids[i];
            }
        }
        order.bidCount = order.bidCount + 1;
        order.bidList.push(order.bidCount);
        order.bids[order.bidCount].user = msg.sender;
        order.bids[order.bidCount].amount = msg.value;
        if(order.highestBid < msg.value)
        order.highestBid = msg.value;
        order.bidder[msg.sender] = true;
        order.bidNo[msg.sender] = order.bidCount;

        emit AddBid(
            orderNumber,
            msg.value,
            msg.sender,
            order.bidCount,
            order.nftAddress,
            order.tokenId
        );
    }

    function finalizeAution(uint256 orderNumber, bool isConfirm)
        public
        isSellerOrAdmin(orderNumber)
    {
        Order storage order = pendingOrders[orderNumber];
        if (!order.isOpenForBids)
            require(now >= order.deadline, AUCTION_NOT_ENDED);
        if (isConfirm) {
            (address buyer, uint256 amount) = getMaximumBid(orderNumber);
            IERC721(order.nftAddress).safeTransferFrom(
                order.seller,
                buyer,
                order.tokenId
            );
            uint256 _fee = _computeFee(amount);
            uint256 _royality = computeRoyality(amount, order.royalityPercent);
            order.seller.transfer(amount - (_fee + _royality));
            benefactor.transfer(_fee);
            order.royalityAddress.transfer(_royality);
            order.fee = _fee;
            for (uint256 i = 1; i <= order.bidCount; i++) {
                if (order.bids[i].user != buyer) {
                    order.bids[i].user.transfer(order.bids[i].amount);
                }
            }
            completedOrders[orderNumber] = order;
            isTokenListed[order.tokenId] = false;
            delete pendingOrders[orderNumber];
        } else {
            for (uint256 i = 1; i <= order.bidCount; i++) {
                order.bids[i].user.transfer(order.bids[i].amount);
            }
            cancelledOrders[orderNumber] = order;
            isTokenListed[order.tokenId] = false;
            delete pendingOrders[orderNumber];
        }
        emit FinalizeAuction(
            orderNumber,
            isConfirm,
            msg.sender,
            order.nftAddress
        );
    }

    function finalizeBundleAution(uint256 orderNumber, bool isConfirm)
        public
        isSellerOrAdmin(orderNumber)
    {
        Order storage order = pendingOrders[orderNumber];
        if (!order.isOpenForBids)
            require(now >= order.deadline, AUCTION_NOT_ENDED);
        if (isConfirm) {
            (address buyer, uint256 amount) = getMaximumBid(orderNumber);

            for (uint256 i = 1; i < order.bundleIds.length; i++) {
                IERC721(order.nftAddress).safeTransferFrom(
                    order.seller,
                    buyer,
                    order.bundleIds[i]
                );
                isTokenListed[order.tokenId] = false;
            }
            uint256 _fee = _computeFee(amount);
            uint256 _royality = computeRoyality(amount, order.royalityPercent);
            order.seller.transfer(amount - (_fee + _royality));
            benefactor.transfer(_fee);
            order.royalityAddress.transfer(_royality);
            order.fee = _fee;
            for (uint256 i = 1; i <= order.bidCount; i++) {
                if (order.bids[i].user != buyer) {
                    order.bids[i].user.transfer(order.bids[i].amount);
                }
            }
            completedOrders[orderNumber] = order;
            delete pendingOrders[orderNumber];
        } else {
            for (uint256 i = 1; i <= order.bidCount; i++) {
                order.bids[i].user.transfer(order.bids[i].amount);
            }
            cancelledOrders[orderNumber] = order;
            isTokenListed[order.tokenId] = false;
            delete pendingOrders[orderNumber];
        }
        emit FinalizeAuction(
            orderNumber,
            isConfirm,
            msg.sender,
            order.nftAddress
        );
    }

    function getBidsCount(uint256 orderNumber) public view returns (uint256) {
        Order storage order = pendingOrders[orderNumber];

        return order.bidCount;
    }

    function getMaximumBid(uint256 orderNumber)
        public
        view
        returns (address, uint256)
    {
        Order storage order = pendingOrders[orderNumber];

        uint256 highestBid = 0;
        address biddingUser;

        for (uint256 i = 1; i <= order.bidCount; i++) {
            if (order.bids[i].amount > highestBid) {
                highestBid = order.bids[i].amount;
                biddingUser = order.bids[i].user;
            }
        }
        return (biddingUser, highestBid);
    }

    function getBidByIndex(uint256 orderNumber, uint256 index)
        public
        view
        returns (address user, uint256 amount)
    {
        Order storage order = pendingOrders[orderNumber];
        return (order.bids[index].user, order.bids[index].amount);
    }

    function cancelAuction(uint256 orderNumber) public {
        Order storage order = pendingOrders[orderNumber];
        require(order.seller == msg.sender, ONLY_SELLER_CANCEL);
        for (uint256 i = 1; i <= order.bidCount; i++) {
            order.bids[i].user.transfer(order.bids[i].amount);
            delete order.bids[i];
        }
        cancelledOrders[orderNumber] = order;
        isTokenListed[order.tokenId] = false;
        delete pendingOrders[orderNumber];
        emit CancelAuction(orderNumber, msg.sender);
    }

    function cancelBundleAuction(uint256 orderNumber) public {
        Order storage order = pendingOrders[orderNumber];
        require(order.seller == msg.sender, ONLY_SELLER_CANCEL);
        for (uint256 i = 1; i <= order.bidCount; i++) {
            order.bids[i].user.transfer(order.bids[i].amount);
            delete order.bids[i];
        }
        cancelledOrders[orderNumber] = order;
        for (uint256 j = 0; j < order.bundleIds.length; j++) {
            isTokenListed[order.bundleIds[j]] = false;
        }
        delete pendingOrders[orderNumber];
        emit CancelAuction(orderNumber, msg.sender);
    }

    function cancelBid(uint256 orderNumber) public {
        Order storage order = pendingOrders[orderNumber];
        require(order.bidder[msg.sender], NOT_VALID_BIDDER);
        require(order.isOpenForBids, AUCTION_ENDED);

        uint256 bidNo = order.bidNo[msg.sender];
        (address buyer, uint256 amount) = getMaximumBid(orderNumber);
        uint256 highBidT;
        if (amount == order.highestBid && order.bidCount > 1) {
            if (order.highestBid != order.bids[1].amount)
                highBidT = order.bids[1].amount;
            else highBidT = order.bids[2].amount;
            for (uint256 i = 1; i <= order.bidCount; i++) {
                if (
                    msg.sender == order.bids[i].user &&
                    highBidT < order.bids[i].amount
                ) {
                    order.highestBid = order.bids[i].amount;
                    order.bids[bidNo].user.transfer(order.bids[bidNo].amount);
                }
                if (i >= bidNo) {
                    order.bids[i].user = order.bids[i + 1].user;
                    order.bids[i].amount = order.bids[i + 1].amount;
                }
            }
        }
        order.bidCount--;
        emit CancelBid(orderNumber, bidNo, msg.sender, amount);
    }

    function addNftBundle(
        // Make a bundle of NFT and Sale on Market Place
        address nftAddress,
        uint256[] memory tokenId,
        uint256 price,
        uint256 orderNumber,
        uint256 startTime,
        uint256 deadline,
        uint256 royalityPercent,
        address payable royalityAddress,
        bool isOpenForBids
    ) public {
        require(
            IERC721(nftAddress).isApprovedForAll(msg.sender, address(this)) ==
                true,
            NEED_TO_APPROVE
        );
        for (uint256 i = 0; i < tokenId.length; i++) {
            // Check all nfts making bundle
            require(
                IERC721(nftAddress).getApproved(tokenId[i]) == address(this),
                NOT_APPROVED
            );
            require(!isTokenListed[tokenId[i]] , "Token is Already Listed");
            require(IERC721(nftAddress).ownerOf(tokenId[i]) == msg.sender ,"Should be owner");
            pendingOrders[orderNumber].bundleIds.push(tokenId[i]); // Maintain all Bundle IDs on generate Bundle
        }
        pendingOrders[orderNumber].nftAddress = nftAddress;
        pendingOrders[orderNumber].buyer = address(this);
        pendingOrders[orderNumber].seller = msg.sender;
        pendingOrders[orderNumber].price = price;
        pendingOrders[orderNumber].startTime = startTime;
        pendingOrders[orderNumber].deadline = deadline;
        pendingOrders[orderNumber].orderType = "bundle";
        pendingOrders[orderNumber].royalityPercent = royalityPercent;
        pendingOrders[orderNumber].royalityAddress = royalityAddress;
        pendingOrders[orderNumber].isOpenForBids = isOpenForBids;
        orderList.push(orderNumber);

        emit AddBundleAuction(
            orderNumber,
            nftAddress,
            msg.sender,
            price,
            startTime,
            deadline,
            royalityAddress,
            royalityPercent,
            isOpenForBids,
            "bundle"
        );
    }
}