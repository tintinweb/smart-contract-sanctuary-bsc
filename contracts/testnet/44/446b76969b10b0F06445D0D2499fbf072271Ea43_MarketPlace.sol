/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

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

    function isWhitelisted(address user) external returns (bool);

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

    function paymentTokens(address _token) external view returns (bool);

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

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

abstract contract ERC165 is IERC165 {
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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
}

interface ILocking {
    function userDeposits(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );
}

contract MarketPlace is ERC165 {
    using SafeERC20 for IERC20;

    address public owner;
    address public tokenAddress;
    uint256 public platformFees;
    address public Treasury;
    uint256 public orderNonce;
    IERC20 public ERC20Interface;
    IERC1155 public ERC1155Interface;
    ILocking public SNFTLockInterface;

    enum SaleType {
        BuyNow,
        DutchAuction,
        OpenForBids
    }

    struct Order {
        uint256 tokenId;
        uint256 copies;
        address seller;
        SaleType saleType;
        address paymentToken;
        uint256 startTime;
        uint256 endTime;
        uint256 startPrice;
        uint256 endPrice;
        uint256 stepInterval;
        uint256 priceStep;
    }

    struct Bid {
        address bidder;
        uint256 copies;
        uint256 amount;
        uint256 timestamp;
        address token;
    }

    mapping(uint256 => Order) public order;
    mapping(uint256 => Bid[]) public openBids;
    mapping(address => mapping(uint256 => uint256)) public index;

    constructor(
        address _token,
        address _owner,
        uint256 _platformFees,
        address _treasury,
        address _SNFTLock
    ) {
        require(
            _token != address(0) &&
                _owner != address(0) &&
                _owner != address(0) &&
                _SNFTLock != address(0),
            "Zero address"
        );
        require(_platformFees <= 50, "High fee");
        ERC1155Interface = IERC1155(_token);
        tokenAddress = _token;
        owner = (_owner);
        platformFees = _platformFees;
        Treasury = _treasury;
        SNFTLockInterface = ILocking(_SNFTLock);
    }

    function setPlatformFees(uint256 fee) external {
        require(msg.sender == owner, "Only owner");
        require(fee <= 50, "High fee"); //Max cap on platform fee is set to 50, and can be changed before deployment
        platformFees = fee;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "Only owner");
        require(newOwner != address(0), "Zero address");
        owner = payable(newOwner);
    }

    function changeTreasury(address _treasury) external returns (bool) {
        require(msg.sender == owner, "Only owner");
        require(_treasury != address(0), "Zero treasury address");
        Treasury = _treasury;
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function placeOrder(
        uint256 tokenId,
        uint256 copies,
        uint256 pricePerNFT,
        SaleType _saleType,
        uint256 _startTime,
        uint256 _endTime,
        address _paymentToken
    ) external returns (bool) {
        require(pricePerNFT > 0, "Invalid price");
        require(
            _saleType == SaleType.BuyNow || _saleType == SaleType.OpenForBids,
            "Invalid saletype"
        );
        require(ERC1155Interface.isWhitelisted(msg.sender), "Not whitelisted");
        require(
            ERC1155Interface.paymentTokens(_paymentToken),
            "ERC20: Token not enabled for payment"
        );
        if (_startTime < block.timestamp) _startTime = block.timestamp;
        ERC1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            copies,
            ""
        );
        orderNonce++;
        order[orderNonce] = Order(
            tokenId,
            copies,
            msg.sender,
            (_saleType),
            _paymentToken,
            _startTime,
            _endTime,
            pricePerNFT,
            0,
            0,
            0
        );

        return true;
    }

    function placeDutchOrder(
        uint256 _tokenId,
        uint256 _editions,
        uint256 _pricePerNFT,
        uint256 _startTime,
        uint256 _endPricePerNFT,
        address _paymentToken,
        uint256 _stepInterval,
        uint256 _priceStep
    ) external returns (bool) {
        require(ERC1155Interface.isWhitelisted(msg.sender), "Not whitelisted");
        require(
            ERC1155Interface.paymentTokens(_paymentToken),
            "Token not enabled for payment"
        );
        if (_startTime < block.timestamp) _startTime = block.timestamp;
        require(0 < _stepInterval, "0 step interval");
        require(_endPricePerNFT < _pricePerNFT, "Invalid start price");
        require(0 < _endPricePerNFT, "Invalid bottom price");
        require(
            0 < _priceStep && _priceStep < _pricePerNFT,
            "Invalid price step"
        );

        orderNonce = orderNonce + 1;
        ERC1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _editions,
            ""
        );
        order[orderNonce] = Order(
            _tokenId,
            _editions,
            msg.sender,
            (SaleType.DutchAuction),
            _paymentToken,
            _startTime,
            (_startTime +
                (((_pricePerNFT - _endPricePerNFT) * _stepInterval) /
                    _priceStep)),
            _pricePerNFT,
            _endPricePerNFT,
            _stepInterval,
            _priceStep
        );
        return true;
    }

    function buy(
        uint256 _orderNonce,
        uint256 copies,
        uint256 amount
    ) external returns (bool) {
        Order storage _order = order[_orderNonce];
        require(_order.seller != msg.sender, "Seller can't buy");
        require(_order.startTime <= block.timestamp, "Start time not reached");
        require(_order.endTime >= block.timestamp, "End time reached");
        require(_order.startPrice > 0, "NFT not in marketplace");
        require(_order.saleType == SaleType.BuyNow, "Wrong saletype");
        require(copies > 0 && copies <= _order.copies, "Invalid no of copies");
        require(
            amount ==
                (copies * _order.startPrice) +
                    ((platformFees * (copies * _order.startPrice)) / 100),
            "Incorrect price"
        );
        require(payment(_order, msg.sender, amount, 0), "Payment failed");
        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            copies,
            ""
        );

        if (_order.copies == copies) {
            delete (order[orderNonce]);
        } else {
            order[_orderNonce].copies -= copies;
        }
        return true;
    }

    function placeOpenBid(
        uint256 _orderNonce,
        uint256 copies,
        uint256 amount
    ) external returns (bool) {
        Order storage _order = order[_orderNonce];
        require(_order.seller != msg.sender, "Seller can't place bid");
        require(
            amount >=
                (copies * _order.startPrice) +
                    ((platformFees * (copies * _order.startPrice)) / 100),
            "Incorrect price"
        );
        require(_order.startTime <= block.timestamp, "Start time not reached");
        require(_order.endTime >= block.timestamp, "End time reached");
        require(_order.saleType == (SaleType.OpenForBids), "Invalid SaleType");
        require(copies > 0 && copies <= _order.copies, "Invalid no of copies");
        if (index[msg.sender][_orderNonce] != 0) {
            Bid storage currentBid = openBids[_orderNonce][
                index[msg.sender][_orderNonce] - 1
            ];
            sendValue(msg.sender, address(this), amount, _order.paymentToken);
            sendDirect(msg.sender, currentBid.amount, _order.paymentToken);
            currentBid.amount = amount;
        } else {
            sendValue(msg.sender, address(this), amount, _order.paymentToken);
            openBids[_orderNonce].push(
                Bid(
                    msg.sender,
                    copies,
                    amount,
                    block.timestamp,
                    _order.paymentToken
                )
            );
            index[msg.sender][_orderNonce] = openBids[_orderNonce].length;
        }
        return true;
    }

    function acceptOpenBid(uint256 _orderNonce, address buyer)
        external
        returns (bool)
    {
        Order storage _order = order[_orderNonce];
        require(_order.seller == msg.sender, "Not the seller");
        Bid storage _bid = openBids[_orderNonce][index[buyer][_orderNonce] - 1];
        uint256 currentBidAmount = _bid.amount;
        require(_bid.copies <= _order.copies, "Invalid no of copies");
        require(currentBidAmount > 0, "No active bids from the buyer");
        require(payment(_order, buyer, currentBidAmount, 0), "Payment failed");
        ERC1155Interface.safeTransferFrom(
            address(this),
            buyer,
            _order.tokenId,
            _bid.copies,
            ""
        );
        if (_order.copies == _bid.copies) {
            delete (order[orderNonce]);
        } else {
            order[_orderNonce].copies -= _bid.copies;
        }
        delete openBids[_orderNonce][index[buyer][_orderNonce] - 1];
        delete index[buyer][_orderNonce];
        return true;
    }

    function withdrawOpenBid(uint256 _orderNonce) external returns (bool) {
        require(
            index[msg.sender][_orderNonce] != 0,
            "No bids placed by user on selected order"
        );
        require(
            openBids[_orderNonce][index[msg.sender][_orderNonce] - 1]
                .timestamp +
                300 <=
                block.timestamp,
            "Wait at least 5 mins before withdrawaing"
        );
        uint256 currentBidAmount = openBids[_orderNonce][
            index[msg.sender][_orderNonce] - 1
        ].amount;
        require(currentBidAmount > 0, "No bid amount");
        sendDirect(
            msg.sender,
            currentBidAmount,
            openBids[_orderNonce][index[msg.sender][_orderNonce] - 1].token
        );
        delete openBids[_orderNonce][index[msg.sender][_orderNonce] - 1];
        delete index[msg.sender][_orderNonce];
        return true;
    }

    function buyDutchAuction(
        uint256 _orderNonce,
        uint256 _copies,
        uint256 tokenAmount
    ) external returns (bool) {
        Order storage _order = order[_orderNonce];
        require(_order.startPrice > 0, "NFT not in marketplace");
        require(_order.saleType == SaleType.DutchAuction, "Wrong saletype");
        require(_order.startTime <= block.timestamp, "Start time not reached");
        require(_order.seller != msg.sender, "Seller can't buy");
        require(_copies > 0 && _copies <= _order.copies, "Incorrect editions");

        uint256 currentPrice = getCurrentPrice(_orderNonce);

        uint256 totalAmount = (currentPrice * _copies);

        require(
            (totalAmount + ((platformFees * totalAmount) / 100)) <= tokenAmount,
            "Insufficient funds"
        );

        require(
            payment(
                _order,
                msg.sender,
                (totalAmount + ((platformFees * totalAmount) / 100)),
                totalAmount
            ),
            "Payment failed"
        );
        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            _copies,
            ""
        );

        if (_order.copies == _copies) {
            delete (order[orderNonce]);
        } else {
            order[_orderNonce].copies -= _copies;
        }
        return true;
    }

    function getCurrentPrice(uint256 _orderNonce)
        public
        view
        returns (uint256 currentPrice)
    {
        Order storage _order = order[_orderNonce];
        if (_order.saleType == SaleType.DutchAuction) {
            uint256 timestamp = block.timestamp;

            uint256 elapsedIntervals = (timestamp - _order.startTime) /
                _order.stepInterval;

            if (
                _order.startPrice > (elapsedIntervals * _order.priceStep) &&
                ((_order.startPrice - (elapsedIntervals * _order.priceStep)) >=
                    _order.endPrice)
            )
                currentPrice =
                    _order.startPrice -
                    (elapsedIntervals * _order.priceStep);
            else {
                currentPrice = _order.endPrice;
            }
        } else {
            currentPrice = _order.startPrice;
        }
    }

    function payment(
        Order memory _order,
        address buyer,
        uint256 amount,
        uint256 initialAmount
    ) internal returns (bool) {
        uint256 fees;
        if (_order.saleType == SaleType.BuyNow) {
            fees = amount - _order.startPrice;
        } else if (_order.saleType == SaleType.DutchAuction) {
            fees = amount - initialAmount;
        } else {
            fees = (platformFees * amount) / 100;
        }
        uint256 buyerFees = fees;
        uint256 sellerFees = fees;

        (uint256 _buyerSNFTAmount, , , , , ) = SNFTLockInterface.userDeposits(
            buyer
        );

        if (_buyerSNFTAmount > 0) {
            buyerFees = buyerFees / 2;
            amount -= buyerFees;
        }
        if(_order.saleType == SaleType.OpenForBids) {
            sendDirect(Treasury, buyerFees, _order.paymentToken);
        } else {
            sendValue(msg.sender, Treasury, buyerFees, _order.paymentToken);
        }

        (uint256 _sellerSNFTAmount, , , , , ) = SNFTLockInterface.userDeposits(
            _order.seller
        );

        if (_sellerSNFTAmount > 0) {
            sellerFees = sellerFees / 2;
        }

        if(_order.saleType == SaleType.OpenForBids) {
            sendDirect(Treasury, sellerFees, _order.paymentToken);
        } else {
            sendValue(msg.sender, Treasury, sellerFees, _order.paymentToken);
        }
        
        amount = amount - buyerFees - sellerFees;
        (address user, uint256 royaltyFee) = ERC1155Interface.royaltyInfo(
            _order.tokenId,
            (amount)
        );

        if (user != _order.seller && royaltyFee > 0) {
            amount -= royaltyFee;

            if(_order.saleType == SaleType.OpenForBids) {
                sendDirect(user, royaltyFee, _order.paymentToken);
            } else {
                sendValue(msg.sender, user, royaltyFee, _order.paymentToken);
            }
        }

        if(_order.saleType == SaleType.OpenForBids) {
            sendDirect(_order.seller, amount, _order.paymentToken);
        } else {
            sendValue(msg.sender, _order.seller, amount, _order.paymentToken);
        }
        return true;
    }

    function cancelOrder(uint256 _orderNonce) external returns (bool) {
        Order storage _order = order[_orderNonce];
        require(_order.seller == msg.sender, "Not the seller");

        require(block.timestamp >= _order.endTime, "End time not reached");

        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            _order.copies,
            ""
        );
        delete (order[_orderNonce]);
        return true;
    }

    function sendValue(
        address user,
        address to,
        uint256 amount,
        address _token
    ) internal {
        uint256 allowance;
        ERC20Interface = IERC20(_token);
        allowance = ERC20Interface.allowance(user, address(this));
        require(allowance >= amount, "Not enough allowance");
        ERC20Interface.safeTransferFrom(user, to, amount);
    }

    function sendDirect(
        address to,
        uint256 amount,
        address _token
    ) internal {
        ERC20Interface = IERC20(_token);
        ERC20Interface.safeTransfer(to, amount);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
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