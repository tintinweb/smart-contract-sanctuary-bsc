/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

    function getProjectIDbyToken(uint256 tokenID)external returns(uint256);

    function getProjectDetail(uint256 projectID)external returns (bytes32);

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
abstract contract ReentrancyGuard {
   
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
library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value),"ERC20: Transfer Failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value),"ERC20: TransferFrom Failed");
    }
}

library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}


contract MarketPlace is ERC165,ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public platformFees;
    address public Treasury;
    uint256 public orderNonce;
    IERC1155 public ERC1155Interface;

    enum SaleType {
        BuyNow,
        DutchAuction    
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

    //Events 
    event PlatformFeesUpdated(uint256 fees, uint256 timestamp);
    event OwnerUpdated(address newOwner, uint256 timestamp);
    event TreasuryUpdated(address newTreasury, uint256 timestamp);
    event OrderPlaced(Order _order, uint256 _orderNonce, uint256 timestamp);
    event OrderCancelled(Order _order, uint256 _orderNonce, uint256 timestamp);
    event ItemBought(
        Order _order,
        uint256 _orderNonce,
        uint256 _copies,
        uint256 timestamp
    );
    
    //Mappings
    mapping(uint256 => Order) public order;
    mapping(uint256 => uint256)public totalRaise;
    mapping(uint256 => mapping(address => uint256))public userLimit;
    mapping(uint256 => uint256)internal projectRaise;
    constructor(
        address _token,
        address _owner,
        uint256 _platformFees,
        address _treasury
    ) {
        require(
            _token != address(0) &&
            _owner != address(0) &&
            _treasury != address(0),
            "Zero address"
        );
        require(_platformFees <= 5000, "High fee");
        ERC1155Interface = IERC1155(_token);
        owner = (_owner);
        platformFees = _platformFees;
        Treasury = _treasury;
        emit OwnerUpdated(_owner, block.timestamp);
        emit PlatformFeesUpdated(_platformFees, block.timestamp);
    }
    /**
     *  Requirements:
     *  `fee` platform fees to be added to the contract
     *  @dev to set the platform fees of the contract
     */
    function setPlatformFees(uint256 fee) external {
        require(msg.sender == owner, "Only owner");
        require(fee <= 5000, "High fee"); //Max cap on platform fee is set to 50, and can be changed before deployment
        platformFees = fee;
        emit PlatformFeesUpdated(platformFees, block.timestamp);
    }

     /**
     *  Requirements:
     *  `newOwner` address of the new owner
     *  @dev to change the owner of the contract
     */
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "Only owner");
        require(newOwner != address(0), "Zero address");
        owner = payable(newOwner);
        emit OwnerUpdated(newOwner, block.timestamp);
    }

     /**
     *  Requirements:
     *  `_treasury` address of the treasury
     *  @dev to change the treasury address of the contract
     */
    function changeTreasury(address _treasury) external returns (bool) {
        require(msg.sender == owner, "Only owner");
        require(_treasury != address(0), "Zero treasury address");
        Treasury = _treasury;
        emit TreasuryUpdated(_treasury, block.timestamp);
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
    
     /**
     *  Requirements:
     *  `_tokenId` NFT Id to be placed on sale
     *  `_copies` number of copies to be placed on sale
     *  `_pricePerNFT` price of the NFT
     *  `_startTime` sale start time
     *  `_endTime` sale end time
     *  `_paymentToken` address of the payment token
     *  @dev to place an order of NFTs for sale 
     */
    function placeOrder(
        uint256 _tokenId,
        uint256 _copies,
        uint256 _pricePerNFT,
        uint256 _startTime,
        uint256 _endTime,
        address _paymentToken
    ) external returns (bool){

        require(ERC1155Interface.isWhitelisted(msg.sender), "Not whitelisted");
       
         require(_pricePerNFT > 0, "Invalid price");
         require(
            ERC1155Interface.paymentTokens(_paymentToken),
            "ERC20: Token not enabled for payment"
        );

        if (_startTime < block.timestamp) _startTime = block.timestamp;
        require(_endTime > block.timestamp,"End time cannot be less than current timestamp");
       
        ERC1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _copies,
            ""
        );
        orderNonce++;
        order[orderNonce] = Order(
            _tokenId,
            _copies,
            msg.sender,
             SaleType.BuyNow,
            _paymentToken,
            _startTime,
            _endTime,
            _pricePerNFT,
            0,
            0,
            0
        );
        emit OrderPlaced(order[orderNonce], orderNonce, block.timestamp);
        return true;
    
    }
      /**
     *  Requirements:
     *  `_tokenId` NFT ID to be placed on sale
     *  `_editions` number of copies to be placed on sale
     *  `_pricePerNFT` price of the NFT
     *  `_startTime` sale start time
     *  `_endTime` sale end time
     *  `_paymentToken` address of the payment token
     *  `_stepInterval` time interal at which price of NFT is decreased
     *  `_priceStep` value decrease in the price of NFT 
     *  @dev to place an order of NFTs for dutch sale 
     */
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
        emit OrderPlaced(order[orderNonce], orderNonce, block.timestamp);
        return true;
    }
     /**
     *  Requirements:
     *  `_orderNonce` order to be accessed
     *  `_copies` number of copies to be bought
     *  `_amount` price to be paid for NFT
     *  `_allowance` number od NFTs allowed 
     *  `_proof` validation of authenticated user
     *  @dev to buy NFT 
     */
    function buy(
        uint256 _orderNonce,
        uint256 _copies,
        uint256 _amount,
        uint256 _allowance,
        bytes32[] calldata _proof
    ) external nonReentrant returns (bool) {
        Order memory _order = order[_orderNonce];

        require(_order.seller != msg.sender, "Seller can't buy");

        uint256 _projectID = ERC1155Interface.getProjectIDbyToken(_order.tokenId);
        bytes32 _rootHash = ERC1155Interface.getProjectDetail(_projectID);

        require(
            verify(msg.sender, _allowance, _proof, _rootHash),
            "User not authenticated");
        require(
            _copies <= _allowance && (userLimit[_projectID][msg.sender]+ _copies) <= _allowance,
            "User reached it's NFT limit");

        updateUserLimit(_projectID,msg.sender,_copies);
        
        require(_order.startTime <= block.timestamp, "Start time not reached");
        require(_order.endTime >= block.timestamp, "End time reached");
        require(_order.startPrice > 0, "NFT not in marketplace");
        require(_order.saleType == SaleType.BuyNow, "Wrong saletype");
        require(_copies > 0 && _copies <= _order.copies, "Invalid no of copies");
        require(
            _amount ==
                (_copies * _order.startPrice) +
                    ((platformFees * (_copies * _order.startPrice)) / 10000),
            "Incorrect price"
        );

        if (_order.copies == _copies) {
            delete (order[orderNonce]);
        } else {
            order[_orderNonce].copies -= _copies;
        }

        require(
            payment(_order, msg.sender, _amount, (_order.startPrice * _copies)),
            "Payment failed"
        );
        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            _copies,
            ""
        );
        
        addTotalRaise(_order.tokenId, _copies * _order.startPrice);
        addProjectRaise(_projectID, _copies * _order.startPrice);

         emit ItemBought(
            _order,
            _orderNonce,
            _copies,
            block.timestamp
        );
        return true;
    }

     /**
     *  Requirements:
     *  `_orderNonce` order to be accessed
     *  `_copies` number of copies to be bought
     *  `_tokenAmount` price to be paid for NFT
     *  `_allowance` number od NFTs allowed 
     *  `_proof` validation of authenticated user
     *  @dev to buy NFT in dutch auction
     */
    function buyDutchAuction(
        uint256 _orderNonce,
        uint256 _copies,
        uint256 _tokenAmount,
        uint256 _allowance,
        bytes32[] calldata _proof      
    ) external nonReentrant returns (bool) {
        Order memory _order = order[_orderNonce];
       
        uint256 _projectID = ERC1155Interface.getProjectIDbyToken(_order.tokenId);
        bytes32  _rootHash= ERC1155Interface.getProjectDetail(_projectID);

        require(verify(msg.sender, _allowance, _proof, _rootHash),
                "User not authenticated");
        require(_copies <= _allowance && (userLimit[_projectID][msg.sender]+ _copies) <= _allowance,
                "User reached it's NFT limit");
        
        updateUserLimit(_projectID,msg.sender,_copies);
    
        require(_order.startPrice > 0, "NFT not in marketplace");
        require(_order.saleType == SaleType.DutchAuction, "Wrong saletype");
        require(_order.startTime <= block.timestamp, "Start time not reached");
        require(_order.seller != msg.sender, "Seller can't buy");
        require(_copies > 0 && _copies <= _order.copies, "Incorrect editions");

        uint256 currentPrice = getCurrentPrice(_orderNonce);
        uint256 totalAmount = (currentPrice * _copies);

        require(
            (totalAmount + ((platformFees * totalAmount) / 10000)) <= _tokenAmount,
            "Insufficient funds"
        );

        if (_order.copies == _copies) {
            delete (order[orderNonce]);
        } else {
            order[_orderNonce].copies -= _copies;
        }
        require(
            payment(
                _order,
                msg.sender,
                (totalAmount + ((platformFees * totalAmount) / 10000)),
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
        
        addTotalRaise(_order.tokenId, _copies * currentPrice);
        addProjectRaise(_projectID,_copies * currentPrice);
        emit ItemBought(
            _order,
            _orderNonce,
            _copies,
            block.timestamp
        );
        return true;
    }

     /**
     *  Requirements:
     *  `_orderNonce` order to be accessed
     *  @dev to retreive the current price of NFT
     */
    function getCurrentPrice(uint256 _orderNonce)
        public
        view
        returns (uint256 currentPrice)
    {
        Order memory _order = order[_orderNonce];
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
        
        fees = amount - initialAmount;
       
        uint256 buyerFees = fees;
        uint256 sellerFees = fees;
        
        amount = amount - buyerFees - sellerFees;

        sendValue(buyer, Treasury, buyerFees + sellerFees, _order.paymentToken);
        sendValue(buyer, _order.seller, amount, _order.paymentToken);
        
        return true;
    }

    /**
     *  Requirements:
     *  `_orderNonce` order to be accessed
     *  @dev to cancel order
     */
    function cancelOrder(uint256 _orderNonce) external nonReentrant returns (bool) {
        Order memory _order = order[_orderNonce];

        require(_order.seller == msg.sender, "Not the seller");
        require(block.timestamp >= _order.endTime, "End time not reached");

        delete (order[_orderNonce]);
        ERC1155Interface.safeTransferFrom(
            address(this),
            msg.sender,
            _order.tokenId,
            _order.copies,
            ""
        );
        emit OrderCancelled(_order, _orderNonce, block.timestamp);
      
        return true;
    }

    /**
     *  Requirements:
     *  `_projectID` Id of the project to be acccessed
     *  @dev to retreive the current funds raised by each project
     */
    function getProjectRaisedFunds(uint256 _projectID)external view returns(uint256){
        return projectRaise[_projectID];
    }
    
    function sendValue(
        address user,
        address to,
        uint256 amount,
        address _token
    ) internal {
        uint256 allowance;
        allowance = IERC20(_token).allowance(user, address(this));
        require(allowance >= amount, "Not enough allowance");
        IERC20(_token).safeTransferFrom(user, to, amount);
    }

    function addTotalRaise(uint256 _tokenId, uint256 _amount)internal{
        totalRaise[_tokenId] += _amount;
    }

    function addProjectRaise(uint256 _projectId, uint256 _amount)internal{
        projectRaise[_projectId] += _amount;
    }

    function verify(
        address user,
        uint256 amount,
        bytes32[] calldata proof,
        bytes32 rootHash
    ) public pure returns (bool) {
        return (
            MerkleProof.verify(
                proof,
                rootHash,
                keccak256(abi.encodePacked(user, amount))
            )
        );
    }
    
    function updateUserLimit(uint256 _projectID, address _user, uint256 _copies)internal{
         userLimit[_projectID][_user] += _copies;
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