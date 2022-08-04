/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity ^0.8.0;

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function ownerOfToken(uint256 _tokenId)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function burn(
        address from,
        uint256 _tokenId,
        uint256 amount
    ) external returns (bool);

    function paymentEnabled(address token) external view returns (bool);
}

pragma solidity 0.8.0;

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity 0.8.0;

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity 0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

pragma solidity 0.8.0;

contract NewEscrow is ERC165 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address payable public admin;
    uint256 public orderNonce;
    address public tokenAddress;
    IERC1155 public ERC1155Interface;
    IERC20 public ERC20Interface;
    bool locked;

    struct Order {
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerNFT;
        uint256 saleType;
        uint256 timeline;
        address paymentToken;
    }

    struct Bid {
        address bidder;
        uint256 bidValue;
        uint256 timeStamp;
    }

    struct Fee {
        uint8 platformCutFirstHand;
        uint8 platformCutSecondHand;
        uint8 creatorRoyalty;
    }

    mapping(uint256 => Order) public order;
    mapping(uint256 => mapping(uint256 => bool)) public secondHand;
    mapping(uint256 => mapping(uint256 => Bid)) public bid;
    mapping(uint256 => mapping(uint256 => address)) private holder;
    mapping(uint256 => mapping(uint256 => bool)) private burnt;
    mapping(uint256 => uint256) public tokenEditions;
    mapping(uint256 => uint256) public flexPlatFee;
    mapping(address => Fee) public fee;
    mapping(address => mapping(uint256 => uint256)) public secondHandOrder;

    constructor(address _admin) {
        require(_admin != address(0), "Zero address");
        admin = payable(_admin);
        fee[address(this)] = Fee(10, 5, 10);
    }

    function setFees(
        uint8 _firstHandPlatFee,
        uint8 _secondHandPlatfee,
        uint8 _creatorRoyalty
    ) external {
        require(msg.sender == admin, "Not admin");
        require(
            _firstHandPlatFee <= 50 &&
                _secondHandPlatfee <= 40 &&
                _creatorRoyalty <= 40,
            "Fee too high"
        );
        fee[address(this)] = Fee(
            _firstHandPlatFee,
            _secondHandPlatfee,
            _creatorRoyalty
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    event OrderPlaced(
        Order order,
        uint256 timestamp,
        uint256 nonce,
        uint256 editionNumber
    );
    event OrderBought(
        Order order,
        uint256 timestamp,
        address buyer,
        uint256 nonce,
        uint256 editionNumber
    );
    event OrderCancelled(
        Order order,
        uint256 timestamp,
        uint256 nonce,
        uint256 editionNumber
    );
    event BidPlaced(
        Order order,
        uint256 timestamp,
        address buyer,
        uint256 nonce,
        uint256 editionNumber
    );

    event BidClaimed(
        Order order,
        uint256 timestamp,
        address buyer,
        uint256 nonce,
        uint256 editionNumber
    );

    event EditionTransferred(
        address from,
        address to,
        uint256 id,
        uint256 edition
    );

    function setTokenAddress(address _tokenAddress) external returns (bool) {
        require(msg.sender == admin, "Not admin");
        require(_tokenAddress != address(0), "Zero address");
        tokenAddress = _tokenAddress;
        ERC1155Interface = IERC1155(_tokenAddress);
        return true;
    }

    function changeAdmin(address _admin) external returns (bool) {
        require(msg.sender == admin, "Only admin");
        admin = payable(_admin);
        return true;
    }

    function currentHolder(uint256 _tokenId, uint256 _editionNumber)
        public
        view
        returns (address)
    {
        if (_editionNumber > tokenEditions[_tokenId] || _editionNumber == 0)
            return address(0);
        if (burnt[_tokenId][_editionNumber]) return address(0);
        if (holder[_tokenId][_editionNumber] == address(0)) {
            (address creator1, , , ) = ERC1155Interface.ownerOfToken(_tokenId);
            return creator1;
        }
        return holder[_tokenId][_editionNumber];
    }

    function placeOrder(
        address _creator,
        uint256 _tokenId,
        uint256 _editions,
        uint256 _pricePerNFT,
        uint256 _saleType,
        uint256 _timeline,
        uint256 _adminPlatformFee,
        address _paymentToken
    ) external returns (bool) {
        require(msg.sender == tokenAddress, "Not token address");
        if (_timeline == 0) {
            _timeline = block.timestamp;
        } else {
            _timeline = block.timestamp.add(_timeline.mul(30)); //Change 30 to 1 for unit testing and 3600 for production
        }
        tokenEditions[_tokenId] = _editions;
        flexPlatFee[_tokenId] = _adminPlatformFee;
        orderNonce = orderNonce.add(1);
        order[orderNonce] = Order(
            _creator,
            _tokenId,
            _editions,
            _pricePerNFT,
            _saleType,
            _timeline,
            _paymentToken
        );

        emit OrderPlaced(
            order[orderNonce],
            block.timestamp,
            orderNonce,
            _editions
        );

        return true;
    }

    function buyNow(
        uint256 _orderNonce,
        uint256 _editionNumber,
        uint256 _tokenAmount
    ) external returns (bool) {
        Order memory _order = order[_orderNonce];
        require(_order.seller != address(0), "Order expired");
        require(
            _order.saleType == 0 ||
                _order.saleType == 1 ||
                _order.saleType == 2,
            "Wrong saletype"
        );
        if (_order.saleType == 2) {
            require(
                secondHandOrder[_order.seller][_orderNonce] == _editionNumber,
                "Incorrect edition"
            );
        }
        if (_order.saleType == 1) {
            require(
                bid[_order.tokenId][_editionNumber].bidder == address(0),
                "Active bidding"
            );
            require(block.timestamp > _order.timeline, "Auction in progress");
        }
        require(_order.seller != msg.sender, "Seller can't buy");
        require(
            _editionNumber > 0 &&
                _editionNumber <= tokenEditions[_order.tokenId],
            "Wrong edition"
        );
        require(_tokenAmount == (_order.pricePerNFT), "Wrong price");
        require(
            currentHolder(_order.tokenId, _editionNumber) == _order.seller ||
                currentHolder(_order.tokenId, _editionNumber) == address(this),
            "Already sold"
        );
        holder[_order.tokenId][_editionNumber] = msg.sender;
        require(
            buyNowPayment(msg.sender, _order, _editionNumber, _tokenAmount),
            "Payment failed"
        );
        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            1,
            ""
        );

        emit OrderBought(
            _order,
            block.timestamp,
            msg.sender,
            _orderNonce,
            _editionNumber
        );

        if (_order.amount == 1) {
            delete order[_orderNonce];
        } else {
            order[_orderNonce].amount = order[_orderNonce].amount.sub(1);
        }
        return true;
    }

    function buyNowPayment(
        address from,
        Order memory _order,
        uint256 _editionNumber,
        uint256 payAmount
    ) internal returns (bool) {
        uint256 platformCut;
        uint256 creatorsCut;
        uint256 finalCut;
        uint256 creatorCut;
        uint256 coCreatorsCut;
        (
            address _creator,
            uint256 _percent1,
            address _coCreator,

        ) = ERC1155Interface.ownerOfToken(_order.tokenId);

        if (!secondHand[_order.tokenId][_editionNumber]) {
            if (flexPlatFee[_order.tokenId] > 0) {
                uint256 flexFee = flexPlatFee[_order.tokenId];
                platformCut = (payAmount * (flexFee)) / (100);
            } else {
                platformCut =
                    (payAmount * (fee[address(this)].platformCutFirstHand)) /
                    (100);
            }
            creatorsCut = payAmount - (platformCut);
            secondHand[_order.tokenId][_editionNumber] = true;
        } else {
            platformCut =
                (payAmount * (fee[address(this)].platformCutSecondHand)) /
                (100);
            creatorsCut =
                (payAmount * (fee[address(this)].creatorRoyalty)) /
                (100);
            finalCut = payAmount - (platformCut + (creatorsCut));
        }

        creatorCut = (creatorsCut * (_percent1)) / (100);
        coCreatorsCut = creatorsCut - (creatorCut);

        tokenPay(from, _creator, creatorCut, _order.paymentToken);
        if (coCreatorsCut > 0) {
            tokenPay(from, _coCreator, coCreatorsCut, _order.paymentToken);
        }
        tokenPay(from, admin, platformCut, _order.paymentToken);
        if (finalCut > 0) {
            tokenPay(from, _order.seller, finalCut, _order.paymentToken);
        }
        return true;
    }

    function tokenPay(
        address from,
        address to,
        uint256 amount,
        address token
    ) internal returns (bool) {
        ERC20Interface = IERC20(token);
        if (from == address(this)) {
            ERC20Interface.safeTransfer(to, amount);
        } else {
            ERC20Interface.safeTransferFrom(from, to, amount);
        }
        return true;
    }

    function placeBid(
        uint256 _orderNonce,
        uint256 _editionNumber,
        uint256 _tokenAmount
    ) external returns (bool) {
        Order memory _order = order[_orderNonce];
        require(!locked, "lock");
        locked = true;
        require(_order.seller != address(0), "Order expired");
        require(_order.seller != msg.sender, "Owner can't place bid");
        require(_order.saleType == 1 || _order.saleType == 3, "Wrong saletype");
        require(
            _editionNumber > 0 &&
                _editionNumber <= tokenEditions[_order.tokenId],
            "Wrong edition"
        );
        require(
            _tokenAmount > _order.pricePerNFT &&
                _tokenAmount >=
                (bid[_order.tokenId][_editionNumber].bidValue.mul(11).div(10)),
            "Wrong Price"
        );
        if (_order.saleType == 1) {
            require(block.timestamp <= _order.timeline, "Auction ended");
        } else {
            require(
                secondHandOrder[_order.seller][_orderNonce] == _editionNumber,
                "Wrong edition"
            );
        }
        require(checkBidStatus(_order, _editionNumber));
        tokenPay(msg.sender, address(this), _tokenAmount, _order.paymentToken);

        bid[_order.tokenId][_editionNumber] = Bid(
            msg.sender,
            _tokenAmount,
            block.timestamp
        );

        emit BidPlaced(
            _order,
            block.timestamp,
            msg.sender,
            _orderNonce,
            _editionNumber
        );
        locked = false;
        return true;
    }

    function claimAfterAuction(uint256 _orderNonce, uint256 _editionNumber)
        external
        returns (bool)
    {
        Order memory _order = order[_orderNonce];
        require(block.timestamp > _order.timeline, "Auction in progress");
        require(
            msg.sender == bid[_order.tokenId][_editionNumber].bidder,
            "Not highest bidder"
        );

        uint256 bidAmount = bid[_order.tokenId][_editionNumber].bidValue;

        delete bid[_order.tokenId][_editionNumber];

        require(
            buyNowPayment(address(this), _order, _editionNumber, bidAmount)
        );

        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            1,
            ""
        );

        holder[_order.tokenId][_editionNumber] = msg.sender;

        if (_order.amount == 1) {
            delete order[_orderNonce];
        } else {
            order[_orderNonce].amount = order[_orderNonce].amount.sub(1);
        }

        _order.pricePerNFT = bidAmount;

        emit OrderBought(
            _order,
            block.timestamp,
            msg.sender,
            _orderNonce,
            _editionNumber
        );
        return true;
    }

    function putOnSaleBuy(
        uint256 _tokenId,
        uint256 _editionNumber,
        uint256 _pricePerNFT,
        address _paymentToken
    ) internal returns (bool) {
        return
            placeSecondHandOrder(
                _tokenId,
                _editionNumber,
                _pricePerNFT,
                2,
                _paymentToken
            );
    }

    function cancelSaleOrder(uint256 _orderNonce, uint256 _editionNumber)
        external
        returns (bool)
    {
        Order memory _order = order[_orderNonce];
        require(!locked, "Re-entrant protection");
        locked = true;
        require(
            _order.saleType == 2 || _order.saleType == 3,
            "Can't cancel first hand orders"
        );
        require(_order.seller == msg.sender, "Can cancel only self orders");
        require(
            secondHandOrder[_order.seller][_orderNonce] == _editionNumber,
            "Incorrect edition"
        );
        if (_order.saleType == 3) {
            require(checkBidStatus(_order, _editionNumber));
        }

        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            1,
            ""
        );

        holder[_order.tokenId][_editionNumber] = msg.sender;

        emit OrderCancelled(
            _order,
            block.timestamp,
            _orderNonce,
            _editionNumber
        );

        delete secondHandOrder[msg.sender][_orderNonce];
        delete order[_orderNonce];
        locked = false;
        return true;
    }

    function checkBidStatus(Order memory _order, uint256 _editionNumber)
        internal
        returns (bool)
    {
        if (bid[_order.tokenId][_editionNumber].bidder != address(0)) {
            ERC20Interface = IERC20(_order.paymentToken);
            ERC20Interface.safeTransfer(
                bid[_order.tokenId][_editionNumber].bidder,
                bid[_order.tokenId][_editionNumber].bidValue
            );
        }
        return true;
    }

    function placeSecondHandOrder(
        uint256 _tokenId,
        uint256 _editionNumber,
        uint256 _pricePerNFT,
        uint256 _saleType,
        address _paymentToken
    ) public returns (bool) {
        require(
            secondHand[_tokenId][_editionNumber],
            "Edition is not in second market"
        );
        require(
            currentHolder(_tokenId, _editionNumber) == msg.sender,
            "Not owner of edition"
        );
        require(_saleType == 2 || _saleType == 3, "Wrong sale type");
        require(
            ERC1155Interface.paymentEnabled(_paymentToken),
            "Token not supported"
        );
        ERC1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            ""
        );
        orderNonce = orderNonce.add(1);
        secondHandOrder[msg.sender][orderNonce] = _editionNumber;
        holder[_tokenId][_editionNumber] = address(this);
        order[orderNonce] = Order(
            msg.sender,
            _tokenId,
            1,
            _pricePerNFT,
            _saleType,
            0,
            _paymentToken
        );

        emit OrderPlaced(
            order[orderNonce],
            block.timestamp,
            orderNonce,
            _editionNumber
        );

        return true;
    }

    function requestOffer(
        uint256 _tokenId,
        uint256 _editionNumber,
        uint256 _pricePerNFT,
        address _paymentToken
    ) external returns (bool) {
        return
            placeSecondHandOrder(
                _tokenId,
                _editionNumber,
                _pricePerNFT,
                3,
                _paymentToken
            );
    }

    function acceptOffer(uint256 _orderNonce, uint256 _editionNumber)
        external
        returns (bool)
    {
        Order memory _order = order[_orderNonce];
        require(_order.saleType == 3, "Wrong order type");
        require(_order.seller == msg.sender, "Only seller can accept offers");
        address buyer = bid[_order.tokenId][_editionNumber].bidder;
        require(buyer != address(0), "No bids placed");

        uint256 bidAmount = bid[_order.tokenId][_editionNumber].bidValue;

        delete bid[_order.tokenId][_editionNumber];

        require(
            buyNowPayment(address(this), _order, _editionNumber, bidAmount)
        );

        ERC1155Interface.safeTransferFrom(
            address(this),
            buyer,
            _order.tokenId,
            1,
            ""
        );
        holder[_order.tokenId][_editionNumber] = buyer;
        _order.pricePerNFT = bidAmount;

        emit OrderBought(
            _order,
            block.timestamp,
            buyer,
            _orderNonce,
            _editionNumber
        );

        delete order[_orderNonce];

        return true;
    }

    function transfer(
        address from,
        address to,
        uint256 id,
        uint256 editionNumber,
        bytes memory data
    ) public returns (bool) {
        require(
            secondHand[id][editionNumber],
            "Edition is not in second market"
        );
        require(currentHolder(id, editionNumber) == msg.sender, "Not owner");
        ERC1155Interface.safeTransferFrom(from, to, id, 1, data);
        holder[id][editionNumber] = to;
        emit EditionTransferred(from, to, id, editionNumber);
        return true;
    }

    function bulkTransfer(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata editionNumbers,
        bytes memory data
    ) external returns (bool) {
        require(ids.length == editionNumbers.length, "Length Mismatch");
        for (uint256 i = 0; i < ids.length; i++) {
            transfer(from, to, ids[i], editionNumbers[i], data);
        }
        return true;
    }

    function burnTokenEdition(uint256 _tokenId, uint256 _editionNumber)
        external
        returns (bool)
    {
        require(
            secondHand[_tokenId][_editionNumber],
            "Edition is not in second market"
        );
        require(
            currentHolder(_tokenId, _editionNumber) == msg.sender,
            "Not owner"
        );
        ERC1155Interface.burn(msg.sender, _tokenId, 1);
        burnt[_tokenId][_editionNumber] = true;
        emit EditionTransferred(
            msg.sender,
            address(0),
            _tokenId,
            _editionNumber
        );
        return true;
    }

    function claimBack(uint256 _orderNonce, uint256 _editionNumber)
        external
        returns (bool)
    {
        Order memory _order = order[_orderNonce];
        require(_order.saleType == 3, "Wrong order type");
        require(
            secondHandOrder[_order.seller][_orderNonce] == _editionNumber,
            "Incorrect edition"
        );
        require(
            block.timestamp >
                bid[_order.tokenId][_editionNumber].timeStamp.add(180), //replace 180 with 86400 in production //change this 10 for unit testing
            "Please wait 24 hours before claiming back"
        );
        require(
            msg.sender == bid[_order.tokenId][_editionNumber].bidder,
            "Not highest bidder"
        );
        uint256 bidAmount = bid[_order.tokenId][_editionNumber].bidValue;
        delete bid[_order.tokenId][_editionNumber];
        tokenPay(address(this), msg.sender, bidAmount, _order.paymentToken);
        emit BidClaimed(
            _order,
            block.timestamp,
            msg.sender,
            _orderNonce,
            _editionNumber
        );

        return true;
    }

    function onERC1155Received(
        address ,
        address ,
        uint256 ,
        uint256 ,
        bytes calldata 
    ) external pure returns (bytes4) {
        return (
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            )
        );
    }
}