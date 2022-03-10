// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./contracts/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract IMediaModified {
    mapping(uint256 => address) public tokenCreators;
    address public marketContract;
}
interface IBCNFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function mint(uint256 _level, address _to) external returns(uint256);
    function approve(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
}

contract BCNFTMarketplace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Use OpenZeppelin's SafeMath library to prevent overflows.
    using Address for address;
    using SafeMath for uint256;

    // ============ Constants ============

    // The minimum amount of time left in an auction after a new bid is created; 15 min.
    uint16 public constant TIME_BUFFER = 900;
    // The BNB needed above the current bid for a new bid to be valid; 0.001 BNB.
    uint8 public constant MIN_BID_INCREMENT_PERCENT = 10;
    // Interface constant for ERC721, to check values in constructor.
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;
    // Allows external read `getVersion()` to return a version for the auction.
    uint256 private constant RESERVE_AUCTION_VERSION = 1;

    uint256 public marketFeeForBNB = 70; //  marketplace fee
    uint256 public marketFeeForToken = 50;
    uint256 public mintPrice = 22; // mint price

    // ============ Immutable Storage ============

    // The address of the ERC721 contract for tokens auctioned via this contract.
    address public immutable nftContract;
    // The address of the WBNB contract, so that BNB can be transferred via
    // WBNB if native BNB transfers fail.
    address public immutable WBNBAddress;
    // The address that initially is able to recover assets.
    address public immutable adminRecoveryAddress;
    // buys/sells of NFTs through the marketplace, 5% tax goes stakingpool
    address public immutable stakingPool;
    // buys/sells of NFTs through the marketplace, 2% tax goes development address
    address public immutable developmentAddress;

    bool private _adminRecoveryEnabled;

    bool private _paused;

    IBCNFT public iBCNFT;

    mapping(uint256 => uint256) public price;
    mapping(uint256 => bool) public listedMap;
    // A mapping of all of the auctions currently running.
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => address) public creatorMap;
    mapping(uint256 => uint256) public royaltyMap;
    mapping(uint256 => address) public ownerMap;
    mapping(string => address) public tokenAddressMap;
    mapping(uint256 => string) public paymentTokenMap;
    mapping(string => address) public payoutAddressMap;

    // ============ Structs ============

    struct Auction {
        // The value of the current highest bid.
        uint256 amount;
        // The amount of time that the auction should run for,
        // after the first bid was made.
        uint256 duration;
        // The time of the first bid.
        uint256 firstBidTime;
        // The minimum price of the first bid.
        uint256 reservePrice;
        string paymentType;
        uint8 CreatorFeePercent;
        // The address of the auction's Creator. The Creator
        // can cancel the auction if it hasn't had a bid yet.
        address Creator;
        // The address of the current highest bid.
        address payable bidder;
        // The address that should receive funds once the NFT is sold.
        address payable fundsRecipient;
    }

    // ============ Events ============

    // All of the details of a new auction,
    // with an index created for the tokenId.
    event AuctionCreated(
        uint256 indexed tokenId,
        uint256 auctionStart,
        uint256 duration,
        uint256 reservePrice,
        string paymentType,
        address Creator
    );

    // All of the details of a new bid,
    // with an index created for the tokenId.
    event AuctionBid(
        uint256 indexed tokenId,
        address nftContractAddress,
        address sender,
        uint256 value
    );

    // All of the details of an auction's cancelation,
    // with an index created for the tokenId.
    event AuctionCanceled(
        uint256 indexed tokenId,
        address nftContractAddress,
        address Creator
    );

    // All of the details of an auction's close,
    // with an index created for the tokenId.
    event AuctionEnded(
        uint256 indexed tokenId,
        address nftContractAddress,
        address Creator,
        address winner,
        uint256 amount,
        address nftCreator
    );

    // When the Creator recevies fees, emit the details including the amount,
    // with an index created for the tokenId.
    event CreatorFeePercentTransfer(
        uint256 indexed tokenId,
        address Creator,
        uint256 amount
    );

    // Emitted in the case that the contract is paused.
    event Paused(address account);
    // Emitted when the contract is unpaused.
    event Unpaused(address account);
    event Minted(
        address indexed minter,
        uint256 nftID,
        bool status
    );
    event Purchase(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 price,
        uint256 nftID
    );
    event PriceUpdate(
        address indexed owner,
        uint256 oldPrice,
        uint256 newPrice,
        uint256 nftID
    );
    event NftListStatus(address indexed owner, uint256 nftID, bool isListed);

    // ============ Modifiers ============

    // Reverts if the sender is not admin, or admin
    // functionality has been turned off.
    modifier onlyAdminRecovery() {
        require(
            // The sender must be the admin address, and
            // adminRecovery must be set to true.
            adminRecoveryAddress == msg.sender && adminRecoveryEnabled(),
            "Caller does not have admin privileges"
        );
        _;
    }

    // Reverts if the sender is not the auction's Creator.
    modifier onlyCreator(uint256 tokenId) {
        require(
            auctions[tokenId].Creator == msg.sender,
            "Can only be called by auction Creator"
        );
        _;
    }

    // Reverts if the sender is not the auction's Creator or winner.
    modifier onlyCreatorOrWinner(uint256 tokenId) {
        require(
            auctions[tokenId].Creator == msg.sender ||
                auctions[tokenId].bidder == msg.sender,
            "Can only be called by auction Creator"
        );
        _;
    }

    // Reverts if the contract is paused.
    modifier whenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }

    // Reverts if the auction does not exist.
    modifier auctionExists(uint256 tokenId) {
        // The auction exists if the Creator is not null.
        require(!auctionCreatorIsNull(tokenId), "Auction doesn't exist");
        _;
    }

    // Reverts if the auction exists.
    modifier auctionNonExistant(uint256 tokenId) {
        // The auction does not exist if the Creator is null.
        require(auctionCreatorIsNull(tokenId), "Auction already exists");
        _;
    }

    // Reverts if the auction is expired.
    modifier auctionNotExpired(uint256 tokenId) {
        require(
            // Auction is not expired if there's never been a bid, or if the
            // current time is less than the time at which the auction ends.
            auctions[tokenId].firstBidTime == 0 ||
                block.timestamp < auctionEnds(tokenId),
            "Auction expired"
        );
        _;
    }

    // Reverts if the auction is not complete.
    // Auction is complete if there was a bid, and the time has run out.
    modifier auctionComplete(uint256 tokenId) {
        require(
            // Auction is complete if there has been a bid, and the current time
            // is greater than the auction's end time.
            auctions[tokenId].firstBidTime > 0 &&
                block.timestamp >= auctionEnds(tokenId),
            "Auction hasn't completed"
        );
        _;
    }

    // ============ Constructor ============

    constructor(
        address nftContract_,
        address WBNBAddress_,
        address adminRecoveryAddress_,
        address bcPaymentAddress_,
        address bcTokenAddress_,
        address stakingPool_,
        address developmentAddress_
    ) {
        // require(
        //     IERC165(nftContract_).supportsInterface(ERC721_INTERFACE_ID),
        //     "Contract at nftContract_ address does not support NFT interface"
        // );
        // Initialize immutable memory.
        nftContract = nftContract_;
        WBNBAddress = WBNBAddress_;
        adminRecoveryAddress = adminRecoveryAddress_;
        payoutAddressMap["BC"] = bcPaymentAddress_;
        tokenAddressMap["BC"] = bcTokenAddress_;
        stakingPool = stakingPool_;
        developmentAddress = developmentAddress_;
        // Initialize mutable memory.
        _paused = false;
        _adminRecoveryEnabled = true;

        iBCNFT = IBCNFT(nftContract_);
    }
    
    function addCreatorMap(
        uint256[] memory _newtokenIds,
        address[] memory _creators,
        uint256[] memory _prices,
        address[] memory _owners,
        uint256[] memory _royalties,
        bool[] memory _listedMap
    ) external onlyOwner {
        require(
            _newtokenIds.length == _creators.length,
            "tokenIDs and creators are not mismatched"
        );
        require(
            _newtokenIds.length == _prices.length,
            "tokenIDs and _prices are not mismatched"
        );
        require(
            _newtokenIds.length == _owners.length,
            "tokenIDs and _owners are not mismatched"
        );
        require(
            _newtokenIds.length == _royalties.length,
            "tokenIDs and _royalties are not mismatched"
        );
        require(
            _newtokenIds.length == _listedMap.length,
            "tokenIDs and _listedMap are not mismatched"
        );

        for (uint256 i = 0; i < _newtokenIds.length; i++) {
            _tokenIds.increment();
            creatorMap[_newtokenIds[i]] = _creators[i];
            price[_newtokenIds[i]] = _prices[i];
            ownerMap[_newtokenIds[i]] = _owners[i];
            royaltyMap[_newtokenIds[i]] = _royalties[i];
            listedMap[_newtokenIds[i]] = _listedMap[i];
        }
    }

    function openTrade(
        uint256 _id,
        uint256 _price,
        string memory paymentType
    ) public {
        require(ownerMap[_id] == msg.sender, "sender is not owner");
        require(listedMap[_id] == false, "Already opened");
        iBCNFT.approve(address(this), _id);
        iBCNFT.transferFrom(msg.sender, address(this), _id);
        listedMap[_id] = true;
        price[_id] = _price;
        paymentTokenMap[_id] = paymentType;
    }

    function closeTrade(uint256 _id) external {
        require(ownerMap[_id] == msg.sender, "sender is not owner");
        require(listedMap[_id] == true, "Already colsed");
        iBCNFT.transferFrom(address(this), msg.sender, _id);
        listedMap[_id] = false;
        if (auctions[_id].Creator == msg.sender) {
            delete auctions[_id];
        }
    }

    function giveaway(
        address _to,
        uint256 _id
    ) external {
        if (listedMap[_id] == false) {
            iBCNFT.transferFrom(msg.sender, _to, _id); 
        } else {
            require(ownerMap[_id] == msg.sender, "sender is not owner");
            iBCNFT.transferFrom(address(this), _to, _id);
            listedMap[_id] == false;
        }
        ownerMap[_id] = _to;
    }

    function burn(uint256 _id) external {
        iBCNFT.burn(_id);
        delete creatorMap[_id];
        delete royaltyMap[_id];
        delete ownerMap[_id];
        delete price[_id];
    }

    function mint(uint256 number, uint256[] memory _level) public {
        for (uint256 i = 0; i < number; i++) {
            _tokenIds.increment();

            uint256 newTokenId = _tokenIds.current();
            creatorMap[newTokenId] = msg.sender;
            ownerMap[newTokenId] = msg.sender;
            listedMap[newTokenId] = false;
            // require (msg.value >= price[newTokenId], "msg.value should be equal to the buyAmount");
            iBCNFT.mint(_level[i], msg.sender);
            emit Minted(msg.sender, newTokenId, false);
        }
        transferBNBOrWBNB(payable(adminRecoveryAddress), mintPrice.div(100).mul(number));
    }

    function buy(uint256 _id, uint256 _price, string memory paymentType) external payable {
        _validate(_id);
        require(price[_id] == _price, "Error, price is not match");
        require(keccak256(abi.encodePacked((paymentType))) == keccak256(abi.encodePacked((paymentTokenMap[_id]))), "Error, Payment Type is not match");
        address _previousOwner = ownerMap[_id];

        // 5% commission cut
        uint256 _royaltyValue = price[_id].mul(royaltyMap[_id]).div(100);
        // _owner.transfer(_owner, _sellerValue);
        if (keccak256(abi.encodePacked((paymentType))) == keccak256(abi.encodePacked(("BNB")))) {
            require(msg.value >= price[_id], "msg.value should be equal to the buyAmount");
            uint256 _commissionValue = price[_id].mul(marketFeeForBNB).div(1000);
            uint256 _sellerValue = price[_id].sub(_commissionValue).sub(_royaltyValue);
            transferBNBOrWBNB(payable(ownerMap[_id]), _sellerValue);
            transferBNBOrWBNB(payable(creatorMap[_id]), _royaltyValue);
            transferBNBOrWBNB(payable(stakingPool), _commissionValue.div(7).mul(5)); // 5% tax goes staking pool
            transferBNBOrWBNB(payable(developmentAddress), _commissionValue.div(7).mul(2)); // 2% goes development address
        } else {
            require(IERC20(tokenAddressMap[paymentType]).balanceOf(msg.sender) >= price[_id], "token balance should be greater than the buyAmount");
            uint256 _commissionValue = price[_id].mul(marketFeeForToken).div(1000);
            uint256 _sellerValue = price[_id].sub(_commissionValue).sub(_royaltyValue);
            require(IERC20(tokenAddressMap[paymentType]).transferFrom(msg.sender, ownerMap[_id], _sellerValue));
            require(IERC20(tokenAddressMap[paymentType]).transferFrom(msg.sender, creatorMap[_id], _royaltyValue));
            require(IERC20(tokenAddressMap[paymentType]).transferFrom(msg.sender, adminRecoveryAddress, _commissionValue.div(7).mul(5))); // 5% goes staking pool
            require(IERC20(tokenAddressMap[paymentType]).transferFrom(msg.sender, payoutAddressMap[paymentType], _commissionValue.div(7).mul(2))); // 2% goes development address
        }
        iBCNFT.transferFrom(address(this), msg.sender, _id);
        ownerMap[_id] = msg.sender;
        listedMap[_id] = false;
        emit Purchase(_previousOwner, msg.sender, price[_id], _id);
    }

    function _validate(uint256 _id) internal view {
        bool isItemListed = listedMap[_id];
        require(isItemListed, "Item not listed currently");
        require(
            msg.sender != iBCNFT.ownerOf(_id),
            "Can not buy what you own"
        );
        // require(address(msg.sender).balance >= price[_id], "Error, the amount is lower");
    }

    function updatePrice(
        uint256 _tokenId,
        uint256 _price,
        string memory paymentType
    ) public returns (bool) {
        uint256 oldPrice = price[_tokenId];
        require(
            msg.sender == ownerMap[_tokenId],
            "Error, you are not the owner"
        );
        price[_tokenId] = _price;
        paymentTokenMap[_tokenId] = paymentType;

        emit PriceUpdate(msg.sender, oldPrice, _price, _tokenId);
        return true;
    }

    function updateListingStatus(uint256 _tokenId, bool shouldBeListed)
        public
        returns (bool)
    {
        require(
            msg.sender == iBCNFT.ownerOf(_tokenId),
            "Error, you are not the owner"
        );
        listedMap[_tokenId] = shouldBeListed;
        emit NftListStatus(msg.sender, _tokenId, shouldBeListed);

        return true;
    }

    // ============ Create Auction ============

    function createAuction(
        uint256 tokenId,
        uint256 duration,
        uint256 reservePrice,
        string memory paymentType,
        address Creator
    ) external nonReentrant whenNotPaused auctionNonExistant(tokenId) {
        // Check basic input requirements are reasonable.
        require(Creator != address(0));
        // Initialize the auction details, including null values.

        ownerMap[tokenId] = msg.sender;
        openTrade(tokenId, reservePrice, paymentType);

        uint256 auctionStart = block.timestamp;
        auctions[tokenId] = Auction({
            duration: duration,
            reservePrice: reservePrice,
            paymentType: paymentType,
            CreatorFeePercent: 50,
            Creator: Creator,
            fundsRecipient: payable(adminRecoveryAddress),
            amount: 0,
            firstBidTime: auctionStart,
            bidder: payable(address(0))
        });

        // Transfer the NFT into this auction contract, from whoever owns it.

        // Emit an event describing the new auction.
        emit AuctionCreated(
            tokenId,
            auctionStart,
            duration,
            reservePrice,
            paymentType,
            Creator
        );
    }

    // ============ Create Bid ============

    function createBid(
        uint256 tokenId,
        string memory paymentType,
        uint256 amount
    )
        external
        payable
        nonReentrant
        whenNotPaused
        auctionExists(tokenId)
        auctionNotExpired(tokenId)
    {
        // Validate that the user's expected bid value matches the BNB deposit.
        require(amount > 0, "Amount must be greater than 0");

        require(
            keccak256(abi.encodePacked((paymentType))) ==
                keccak256(abi.encodePacked((auctions[tokenId].paymentType))),
            "PaymentType is not mismatched"
        );

        if (
            keccak256(abi.encodePacked((paymentType))) ==
            keccak256(abi.encodePacked(("BNB")))
        ) {
            require(amount == msg.value, "Amount doesn't equal msg.value");
        } else {
            require(
                amount >=
                    IERC20(tokenAddressMap[paymentType]).balanceOf(msg.sender),
                "Insufficient token balance"
            );
        }
        // Check if the current bid amount is 0.
        if (auctions[tokenId].amount == 0) {
            // If so, it is the first bid.
            // auctions[tokenId].firstBidTime = block.timestamp;
            // We only need to check if the bid matches reserve bid for the first bid,
            // since future checks will need to be higher than any previous bid.
            require(
                amount >= auctions[tokenId].reservePrice,
                "Must bid reservePrice or more"
            );
        } else {
            // Check that the new bid is sufficiently higher than the previous bid, by
            // the percentage defined as MIN_BID_INCREMENT_PERCENT.
            require(
                amount >=
                    auctions[tokenId].amount.add(
                        // Add 10% of the current bid to the current bid.
                        auctions[tokenId]
                            .amount
                            .mul(MIN_BID_INCREMENT_PERCENT)
                            .div(100)
                    ),
                "Must bid more than last bid by MIN_BID_INCREMENT_PERCENT amount"
            );

            // Refund the previous bidder.
            if (
                keccak256(abi.encodePacked((paymentType))) ==
                keccak256(abi.encodePacked(("BNB")))
            ) {
                transferBNBOrWBNB(
                    auctions[tokenId].bidder,
                    auctions[tokenId].amount
                );
            } else {
                require(
                    IERC20(tokenAddressMap[paymentType]).transfer(
                        auctions[tokenId].bidder,
                        auctions[tokenId].amount
                    )
                );
            }
        }
        // Update the current auction.
        auctions[tokenId].amount = amount;
        auctions[tokenId].bidder = payable(msg.sender);
        // Compare the auction's end time with the current time plus the 15 minute extension,
        // to see whBNBer we're near the auctions end and should extend the auction.
        if (auctionEnds(tokenId) < block.timestamp.add(TIME_BUFFER)) {
            // We add onto the duration whenever time increment is required, so
            // that the auctionEnds at the current time plus the buffer.
            auctions[tokenId].duration += block.timestamp.add(TIME_BUFFER).sub(
                auctionEnds(tokenId)
            );
        }
        // Emit the event that a bid has been made.
        emit AuctionBid(tokenId, nftContract, msg.sender, amount);
    }

    // ============ End Auction ============

    function endAuction(uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
        auctionComplete(tokenId)
        onlyCreatorOrWinner(tokenId)
    {
        // Store relevant auction data in memory for the life of this function.
        address winner = auctions[tokenId].bidder;
        uint256 amount = auctions[tokenId].amount;
        address Creator = auctions[tokenId].Creator;
        string memory paymentType = auctions[tokenId].paymentType;
        // Remove all auction data for this token from storage.
        delete auctions[tokenId];
        // We don't use safeTransferFrom, to prevent reverts at this point,
        // which would break the auction.
        if (winner == address(0)) {
            iBCNFT.transferFrom(address(this), Creator, tokenId);
            ownerMap[tokenId] = Creator;
        } else {
            iBCNFT.transferFrom(address(this), winner, tokenId);
            if (
                keccak256(abi.encodePacked((paymentType))) ==
                keccak256(abi.encodePacked(("BNB")))
            ) {
                uint256 _commissionValue = amount.mul(marketFeeForBNB).div(
                    1000
                );
                transferBNBOrWBNB(
                    payable(adminRecoveryAddress),
                    _commissionValue.div(2)
                );
                transferBNBOrWBNB(
                    payable(payoutAddressMap[paymentType]),
                    _commissionValue.div(2)
                );
                if (Creator == creatorMap[tokenId]) {
                    transferBNBOrWBNB(
                        payable(Creator),
                        amount.sub(_commissionValue)
                    );
                } else {
                    uint256 _royaltyValue = amount.mul(royaltyMap[tokenId]).div(
                        100
                    );
                    transferBNBOrWBNB(
                        payable(creatorMap[tokenId]),
                        _royaltyValue
                    );
                    transferBNBOrWBNB(
                        payable(Creator),
                        amount.sub(_royaltyValue).sub(_commissionValue)
                    );
                }
            } else {
                uint256 _commissionValue = amount.mul(marketFeeForToken).div(
                    1000
                );
                require(
                    IERC20(tokenAddressMap[paymentType]).transfer(
                        adminRecoveryAddress,
                        _commissionValue.div(2)
                    )
                );
                require(
                    IERC20(tokenAddressMap[paymentType]).transfer(
                        payoutAddressMap[paymentType],
                        _commissionValue.div(2)
                    )
                );
                if (Creator == creatorMap[tokenId]) {
                    require(
                        IERC20(tokenAddressMap[paymentType]).transfer(
                            Creator,
                            amount.sub(_commissionValue)
                        )
                    );
                } else {
                    uint256 _royaltyValue = amount.mul(royaltyMap[tokenId]).div(
                        100
                    );
                    require(
                        IERC20(tokenAddressMap[paymentType]).transfer(
                            creatorMap[tokenId],
                            _royaltyValue
                        )
                    );
                    require(
                        IERC20(tokenAddressMap[paymentType]).transfer(
                            Creator,
                            amount.sub(_royaltyValue).sub(_commissionValue)
                        )
                    );
                }
            }

            ownerMap[tokenId] = winner;
        }
        listedMap[tokenId] = false;
        // Emit an event describing the end of the auction.
        emit AuctionEnded(
            tokenId,
            nftContract,
            Creator,
            winner,
            amount,
            creatorMap[tokenId]
        );
    }

    // ============ Cancel Auction ============

    function cancelAuction(uint256 tokenId)
        external
        nonReentrant
        auctionExists(tokenId)
        onlyCreator(tokenId)
    {
        // Check that there hasn't already been a bid for this NFT.
        require(
            uint256(auctions[tokenId].amount) == 0,
            "Auction already started"
        );
        // Pull the creator address before removing the auction.
        address Creator = auctions[tokenId].Creator;
        // Remove all data about the auction.
        delete auctions[tokenId];
        // Transfer the NFT back to the Creator.
        iBCNFT.transferFrom(address(this), Creator, tokenId);
        listedMap[tokenId] = false;
        ownerMap[tokenId] = Creator;
        // Emit an event describing that the auction has been canceled.
        emit AuctionCanceled(tokenId, nftContract, Creator);
    }

    // ============ Admin Functions ============

    // Irrevocably turns off admin recovery.
    function turnOffAdminRecovery() external onlyAdminRecovery {
        _adminRecoveryEnabled = false;
    }

    function pauseContract() external onlyAdminRecovery {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpauseContract() external onlyAdminRecovery {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    // Allows the admin to transfer any BNB from this contract to the recovery address.
    function recoverBNB(uint256 amount)
        external
        onlyAdminRecovery
        returns (bool success)
    {
        // Attempt an BNB transfer to the recovery account, and return true if it succeeds.
        success = attemptBNBTransfer(payable(adminRecoveryAddress), amount);
    }

    // ============ Miscellaneous Public and External ============

    // Returns true if the contract is paused.
    function paused() public view returns (bool) {
        return _paused;
    }

    // Returns true if admin recovery is enabled.
    function adminRecoveryEnabled() public view returns (bool) {
        return _adminRecoveryEnabled;
    }


    // ============ Private Functions ============

    // Will attempt to transfer BNB, but will transfer WBNB instead if it fails.
    function transferBNBOrWBNB(address payable to, uint256 value) public {
        // Try to transfer BNB to the given recipient.
        if (!attemptBNBTransfer(to, value)) {
            // If the transfer fails, wrap and send as WBNB, so that
            // the auction is not impeded and the recipient still
            // can claim BNB via the WBNB contract (similar to escrow).
            IWBNB(WBNBAddress).deposit{value: value}();
            IWBNB(WBNBAddress).transfer(to, value);
            // At this point, the recipient can unwrap WBNB.
        }
    }

    // Sending BNB is not guaranteed complete, and the mBNBod used here will return false if
    // it fails. For example, a contract can block BNB transfer, or might use
    // an excessive amount of gas, thereby griefing a new bidder.
    // We should limit the gas used in transfers, and handle failure cases.
    function attemptBNBTransfer(address payable to, uint256 value)
        public
        returns (bool)
    {
        // Here increase the gas limit a reasonable amount above the default, and try
        // to send BNB to the recipient.
        // NOTE: This might allow the recipient to attempt a limited reentrancy attack.
        (bool success, ) = to.call{value: value, gas: 30000}("");
        return success;
    }

    // Returns true if the auction's Creator is set to the null address.
    function auctionCreatorIsNull(uint256 tokenId) private view returns (bool) {
        // The auction does not exist if the Creator is the null address,
        // since the NFT would not have been transferred in `createAuction`.
        return auctions[tokenId].Creator == address(0);
    }

    // Returns the timestamp at which an auction will finish.
    function auctionEnds(uint256 tokenId) private view returns (uint256) {
        // Derived by adding the auction's duration to the time of the first bid.
        // NOTE: duration can be extended conditionally after each new bid is added.
        return auctions[tokenId].firstBidTime.add(auctions[tokenId].duration);
    }

    /** ADMIN FUNCTION */

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setTokenAddress(
        string memory _paymentToken,
        address _tokenAddress,
        address _payoutAddress
    ) public onlyOwner {
        tokenAddressMap[_paymentToken] = _tokenAddress;
        payoutAddressMap[_paymentToken] = _payoutAddress;
    }

    function setMarketFeeForBNB(uint256 _newMarketFeeForBNB)
        external
        onlyOwner
    {
        require(_newMarketFeeForBNB > 1, "Invalid MarketFee For BNB");
        marketFeeForBNB = _newMarketFeeForBNB;
    }

    function setMarketFeeForToken(uint256 _newMarketFeeForToken)
        external
        onlyOwner
    {
        require(_newMarketFeeForToken > 1, "Invalid MarketFee For Token");
        marketFeeForToken = _newMarketFeeForToken;
    }

    function withdrawToken(string memory _tokenName, uint256 _amount)
        public
        onlyOwner
    {
        uint256 token_bal = IERC20(tokenAddressMap[_tokenName]).balanceOf(
            address(this)
        ); //how much MST buyer has
        require(_amount <= token_bal, "Insufficient token balance to withdraw");
        require(
            IERC20(tokenAddressMap[_tokenName]).transfer(msg.sender, token_bal)
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter = 1;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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