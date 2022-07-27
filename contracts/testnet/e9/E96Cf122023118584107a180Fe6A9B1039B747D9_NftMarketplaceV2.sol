// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder, ERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {RoyaltiesInfo, AccessControlEnumerable} from "./RoyaltiesInfo.sol";

contract NftMarketplaceV2 is RoyaltiesInfo, ERC721Holder, ERC1155Holder, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    enum TokenType {
        ERC20,
        ERC721,
        ERC1155
    }

    struct TokenInfo {
        TokenType tokenType;
        address tokenAddress;
        uint256 id; // For ERC20 must be 0
        uint256 amount; // For ERC721 must be 0
    }

    struct AuctionData {
        TokenInfo tokenInfo;
        address seller;
        uint32 startTime;
        uint32 endTime;
        address bidToken; // for native token use address(0)
        uint256 lastBidAmount;
        address lastBidder;
    }

    // public

    /// @notice Role that manages auctions
    bytes32 public constant AUCTION_MANAGER = keccak256("AUCTION_MANAGER");

    /// @notice True if the creation of new auctions is paused by an admin.
    bool public isPausedCreation;

    /// @notice Get information for an auction.
    mapping(bytes32 => AuctionData) public auctionData;
    /// @notice Check if some auction has already been completed or not.
    mapping(bytes32 => bool) public isAuctionCompleted;

    /// @notice Fee percentage of the marketplace (denominator 10000). Max value is 1000 (10%).
    uint256 public feePercentage = 2_50; // 2.5%
    /// @notice Address that will receive all marketplace fees.
    address public feeReceiver;

    // private

    EnumerableSet.Bytes32Set private _activeAuctions;

    uint256 private constant _MAX_GAS_FOR_NATIVE_TRANSFER = 200_000;
    uint256 private constant _MAX_GAS_FOR_TOKEN_TRANSFER = 1_000_000;

    address private constant _ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // events

    /// @notice The event is emitted when fees of the marketplace were transferred.
    /// @param feeReceiver Address that received fees
    /// @param token Address of a token that was transferred
    /// @param amount Fee amount
    event FeeTransferred(address indexed feeReceiver, address indexed token, uint256 amount);
    /// @notice The event is emitted when royalties were transferred.
    /// @param royaltyReceiver Address that received royalties
    /// @param token Address of a token that was transferred
    /// @param amount Royalty amount
    event RoyaltyTransferred(
        address indexed royaltyReceiver,
        address indexed token,
        uint256 amount
    );

    /// @notice The event is emitted when an admin (`manager`) has set new fee percentages (`newValue`) for the marketplace.
    /// @param manager Address of the admin that has changed fee percentages for the marketplace
    /// @param oldValue Previous value of fee percentages for the marketplace
    /// @param newValue New value of fee percentages for the marketplace
    event FeePercentageChange(address indexed manager, uint256 oldValue, uint256 newValue);
    /// @notice The event is emitted when an admin (`manager`) has set a new fee receiver (`newValue`) for the marketplace.
    /// @param manager Address of an admin that has changed fee receiver for the marketplace
    /// @param oldValue Previous fee receiver of the marketplace
    /// @param newValue New fee receiver of the marketplace
    event FeeReceiverChange(
        address indexed manager,
        address indexed oldValue,
        address indexed newValue
    );

    /// @notice The event is emitted when `user` creates a new auction (`auctionId`) to sell his nft.
    /// @param user User that creates auction
    /// @param tokenInfo Information about NFT that user puts on sale
    /// @param startTime Time when the auction will start
    /// @param endTime Time when the auction will end
    /// @param minPrice Minimum price in token `bidToken`
    /// @param bidToken Address of a token that will be accepted for a bid (0xeee address is used for the native token)
    /// @param auctionId Unique identifier for this new auction
    event AuctoinCreated(
        address indexed user,
        TokenInfo tokenInfo,
        uint256 startTime,
        uint256 endTime,
        uint256 minPrice,
        address indexed bidToken,
        bytes32 auctionId
    );
    /// @notice The event is emitted when `user` makes a bid on the auction (`auctionId`).
    /// @param auctionId Auction identifier for which `user` makes a bid
    /// @param user User that makes a bid
    /// @param bidToken Address of the token that bids `user` (0xeee address is used for the native token)
    /// @param bidAmount Amount of the bid
    event BidMade(
        bytes32 auctionId,
        address indexed user,
        address indexed bidToken,
        uint256 bidAmount
    );
    /// @notice The event is emitted when to the auction (`auctionId`) comes a new bid with a bigger amount of the bid.
    /// @param auctionId Auction identifier in which `user` made the bid
    /// @param user User that gets his bid back
    /// @param bidToken Address of the token that will be refunded to the `user` (0xeee address is used for the native token)
    /// @param bidAmount Amount of refund
    event BidRefund(
        bytes32 auctionId,
        address indexed user,
        address indexed bidToken,
        uint256 bidAmount
    );
    /// @notice The event is emitted when `seller` cancels his auction (`auctionId`).
    /// It may happen when to this auction there wasn't any bid made and
    /// for this auction function {endAuction} was called.
    /// @param auctionId Auction identifier which was canceled
    /// @param seller User that created an auction
    /// @param tokenInfo Token info for NFT that was selling in this auction
    event AuctionCalceled(bytes32 auctionId, address indexed seller, TokenInfo tokenInfo);
    /// @notice The event is emitted when the auction (`auctionId`) was successfully closed.
    /// @param auctionId Auction identifier which was successfully closed
    /// @param seller User that sells NFT
    /// @param buyer User that buys NFT
    /// @param tokenInfoSell Token info for NFT
    /// @param tokenInfoBid Token info for bid token (0xeee address is used for the native token)
    event AuctionEnded(
        bytes32 auctionId,
        address indexed seller,
        address indexed buyer,
        TokenInfo tokenInfoSell,
        TokenInfo tokenInfoBid
    );

    /// @notice The event is emitted when an admin (`manager`) toggles the pause of the marketplace.
    /// @param manager Address of an admin that made this swap
    /// @param oldValue Previous value of the pause
    /// @param newValue New value of the pause
    event PauseToggled(address indexed manager, bool oldValue, bool newValue);
    /// @notice The event is emitted when an admin (`manager`) deletes an auction (`auctionId`).
    /// @param manager Address of an admin that deleted the auction
    /// @param auctionId Auction identifier which was deleted
    event AucitonDeleted(address indexed manager, bytes32 auctionId);
    /// @notice The event is emitted when token transfer failed.
    /// @param to Receiver address
    /// @param tokenAddress Token address
    /// @param tokenType Type of the token (ERC20 = 0, ERC721 = 1, ERC1155 = 2)
    /// @param id Token id that were tried to transfer. For ERC20 it will be zero
    /// @param amount Amount of the token. For ERC721 it will be zero
    /// @param errorString Error message of the transfer. For ERC20 it can be "NftMarketplaceV2: ERC20 transfer result false" means that transfer succedded but the result is false
    event BadTokenTransfer(
        address indexed to,
        address indexed tokenAddress,
        TokenType tokenType,
        uint256 id,
        uint256 amount,
        string errorString
    );
    /// @notice The event is emitted when transfer of the native token failed.
    /// @param to Receiver address
    /// @param amount Amount of the token. For ERC721 it will be zero
    /// @param errorString Error message of the transfer
    event BadNativeTokenTransfer(address indexed to, uint256 amount, string errorString);

    /// @notice The constructor of the marketplace.
    /// @param _feeReceiver Address of a fee receiver of the marketplace
    constructor(address _feeReceiver) {
        require(_feeReceiver != address(0), "NftMarketplaceV2: Zero address");
        feeReceiver = _feeReceiver;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUCTION_MANAGER, msg.sender);

        emit FeePercentageChange(msg.sender, 0, feePercentage);
        emit FeeReceiverChange(msg.sender, address(0), _feeReceiver);
    }

    // external

    /// @notice Create a new auction.
    /// @param tokenInfo Token info for the NFT that will be placed on sale
    /// @param startTime Time when this auction will start
    /// @param endTime Time when this auction will end
    /// @param minPrice Minimum price for this NFT
    /// @param bidToken Address of the token that will be accepted for bids (0xeee address is used for the native token)
    function createAuction(
        TokenInfo calldata tokenInfo,
        uint32 startTime,
        uint32 endTime,
        uint256 minPrice,
        address bidToken
    ) external nonReentrant returns (bytes32 auctionId) {
        require(!isPausedCreation, "NftMarketplaceV2: Creation paused");

        require(tokenInfo.tokenType != TokenType.ERC20, "NftMarketplaceV2: Only NFT");
        _verifyToken(tokenInfo);

        if (bidToken != _ETH_ADDRESS) {
            require(bidToken.isContract(), "NftMarketplaceV2: bidToken is not a contract");
            require(IERC20Metadata(bidToken).decimals() > 0, "NftMarketplaceV2: Not ERC20");
        }
        require(
            startTime < endTime && endTime > block.timestamp,
            "NftMarketplaceV2: Wrong start/end time"
        );

        AuctionData memory _auctionData = AuctionData({
            tokenInfo: tokenInfo,
            seller: msg.sender,
            startTime: startTime,
            endTime: endTime,
            bidToken: bidToken,
            lastBidAmount: minPrice,
            lastBidder: address(0)
        });
        auctionId = _getAuctionId(_auctionData);

        require(auctionData[auctionId].seller == address(0), "NftMarketplaceV2: Existing auction");
        require(isAuctionCompleted[auctionId] == false, "NftMarketplaceV2: Auction is completed");

        auctionData[auctionId] = _auctionData;
        _activeAuctions.add(auctionId);

        _transferNFT(tokenInfo, msg.sender, address(this), true, false);

        emit AuctoinCreated(
            msg.sender,
            tokenInfo,
            startTime,
            endTime,
            minPrice,
            bidToken,
            auctionId
        );
    }

    /// @notice Make a bid to the auction with id `auctionId`.
    /// @param auctionId Auction identifier to which the bid will be made
    /// @param amount Amount of the bid
    function bid(bytes32 auctionId, uint256 amount) external nonReentrant {
        AuctionData storage _auctionData = auctionData[auctionId];
        require(_auctionData.seller != address(0), "NftMarketplaceV2: No such open auction");

        require(
            block.timestamp >= _auctionData.startTime,
            "NftMarketplaceV2: Auction is not started"
        );
        require(block.timestamp < _auctionData.endTime, "NftMarketplaceV2: Auction has ended");

        address bidToken = _auctionData.bidToken;
        uint256 lastBidAmount = _auctionData.lastBidAmount;
        address lastBidder = _auctionData.lastBidder;

        require(
            amount >
                (
                    lastBidder != address(0) || lastBidAmount == 0
                        ? lastBidAmount
                        : lastBidAmount - 1
                ),
            "NftMarketplaceV2: Too low amount"
        );

        if (lastBidder != address(0)) {
            _transferERC20(bidToken, address(this), lastBidder, lastBidAmount, true, false);

            emit BidRefund(auctionId, lastBidder, bidToken, lastBidAmount);
        }

        _transferERC20(bidToken, msg.sender, address(this), amount, true, false);

        _auctionData.lastBidder = msg.sender;
        _auctionData.lastBidAmount = amount;

        emit BidMade(auctionId, msg.sender, bidToken, amount);
    }

    /// @notice Make a bid with native token to the auction with id `auctionId`.
    /// @param auctionId Auction identifier to which the bid will be made
    function bidNative(bytes32 auctionId) external payable nonReentrant {
        AuctionData storage _auctionData = auctionData[auctionId];
        require(_auctionData.seller != address(0), "NftMarketplaceV2: No such open auction");

        require(
            block.timestamp >= _auctionData.startTime,
            "NftMarketplaceV2: Auction is not started"
        );
        require(block.timestamp < _auctionData.endTime, "NftMarketplaceV2: Auction has ended");

        address bidToken = _auctionData.bidToken;
        require(bidToken == _ETH_ADDRESS, "NftMarketplaceV2: Use {bid} function");

        uint256 lastBidAmount = _auctionData.lastBidAmount;
        address lastBidder = _auctionData.lastBidder;

        require(
            msg.value >
                (
                    lastBidder != address(0) || lastBidAmount == 0
                        ? lastBidAmount
                        : lastBidAmount - 1
                ),
            "NftMarketplaceV2: Too low amount"
        );

        if (lastBidder != address(0)) {
            _transferNative(address(this), lastBidder, lastBidAmount, true, false);

            emit BidRefund(auctionId, lastBidder, bidToken, lastBidAmount);
        }

        _auctionData.lastBidder = msg.sender;
        _auctionData.lastBidAmount = msg.value;

        emit BidMade(auctionId, msg.sender, bidToken, msg.value);
    }

    /// @notice Function for ending the auction. Can be called only when endTime of an auction has passed.
    /// If there are no bids, NFT will be refunded to a seller of an auction.
    /// If there is a bid, an auction will be processed.
    /// @param auctionId Auction identifier that will be ended
    function endAuction(bytes32 auctionId) external nonReentrant {
        AuctionData storage _auctionData = auctionData[auctionId];

        address seller = _auctionData.seller;
        require(seller != address(0), "NftMarketplaceV2: No such open auction");

        require(block.timestamp >= _auctionData.endTime, "NftMarketplaceV2: Not ended yet");

        address lastBidder = _auctionData.lastBidder;
        if (lastBidder == address(0)) {
            TokenInfo memory tokenInfo = _auctionData.tokenInfo;
            _transferNFT(tokenInfo, address(this), seller, true, false);

            emit AuctionCalceled(auctionId, seller, tokenInfo);
        } else {
            TokenInfo memory tokenInfo = _auctionData.tokenInfo;

            uint256 price = _auctionData.lastBidAmount;

            (address royaltyReceiver, uint256 royaltyAmount) = getRoyaltyInfo(
                tokenInfo.tokenAddress,
                tokenInfo.id,
                price
            );

            address bidToken = _auctionData.bidToken;

            _transferNFT(tokenInfo, address(this), lastBidder, true, false);

            if (bidToken == _ETH_ADDRESS) {
                _transferNativeWithFee(
                    address(this),
                    seller,
                    price,
                    royaltyReceiver,
                    royaltyAmount
                );
            } else {
                _transferERC20WithFee(
                    bidToken,
                    address(this),
                    seller,
                    price,
                    royaltyReceiver,
                    royaltyAmount
                );
            }

            emit AuctionEnded(
                auctionId,
                seller,
                lastBidder,
                tokenInfo,
                TokenInfo({
                    tokenType: TokenType.ERC20,
                    tokenAddress: bidToken,
                    id: 0,
                    amount: price
                })
            );
        }

        delete auctionData[auctionId];
        isAuctionCompleted[auctionId] = true;
        _activeAuctions.remove(auctionId);
    }

    // external admin

    /// @notice Admin function (AUCTION_MANAGER role) for setting new values for fee percentages and fee receiver of the marketplace.
    /// @param newValueFeePercentage New value of the marketplace fee percentages
    /// @param newValueFeeReceiver New value of the marketplace fee receiver
    function setFeeInfo(uint256 newValueFeePercentage, address newValueFeeReceiver)
        external
        onlyRole(AUCTION_MANAGER)
    {
        require(newValueFeePercentage <= 10_00, "NftMarketplaceV2: Too big percentage"); // 10% max
        require(newValueFeeReceiver != address(0), "NftMarketplaceV2: Zero address");

        uint256 oldValueFeePercentage = feePercentage;
        if (oldValueFeePercentage != newValueFeePercentage) {
            feePercentage = newValueFeePercentage;

            emit FeePercentageChange(msg.sender, oldValueFeePercentage, newValueFeePercentage);
        }

        address oldValueFeeReceiver = feeReceiver;
        if (oldValueFeeReceiver != newValueFeeReceiver) {
            feeReceiver = newValueFeeReceiver;

            emit FeeReceiverChange(msg.sender, oldValueFeeReceiver, newValueFeeReceiver);
        }
    }

    /// @notice Admin function (AUCTION_MANAGER role) for deleting auction (`auctionId`) is case of
    /// wrong parameters and if NFT or a bid token reverts token transfer (or gas ddos).
    /// @param auctionId Auction identifier that will be deleted
    /// @param requireSuccessSeller If NFT maliciously reverts transfers, the bidder's funds can be locked.
    /// This parameter can be set to false not to check NFT transfer results
    /// @param setGasLimitForSellerTransfer If NFT maliciously spends a lot of the gas (or unlimited amount of the gas), the bidder's funds can be locked.
    /// This parameter can be set to true if there is a need in setting gas limit to nft transfer
    /// @param requireSuccessBuyer If bid token maliciously reverts transfers, the seller's funds can be locked.
    /// This parameter can be set to false not to check bid token transfer results
    /// @param setGasLimitForBuyerTransfer If bid token maliciously spends a lot of the gas (or unlimited amount of the gas), the seller's funds can be locked.
    /// This parameter can be set to true if there is a need in setting gas limit to bid token transfer
    function deleteAuction(
        bytes32 auctionId,
        bool requireSuccessSeller,
        bool setGasLimitForSellerTransfer,
        bool requireSuccessBuyer,
        bool setGasLimitForBuyerTransfer
    ) external nonReentrant onlyRole(AUCTION_MANAGER) {
        AuctionData storage _auctionData = auctionData[auctionId];

        address seller = _auctionData.seller;
        require(seller != address(0), "NftMarketplaceV2: No such open auction");

        TokenInfo memory tokenInfo = _auctionData.tokenInfo;
        _transferNFT(
            tokenInfo,
            address(this),
            seller,
            requireSuccessSeller,
            setGasLimitForSellerTransfer
        );

        address lastBidder = _auctionData.lastBidder;
        if (lastBidder != address(0)) {
            address bidToken = _auctionData.bidToken;
            if (bidToken == _ETH_ADDRESS) {
                _transferNative(
                    address(this),
                    lastBidder,
                    _auctionData.lastBidAmount,
                    requireSuccessBuyer,
                    setGasLimitForBuyerTransfer
                );
            } else {
                _transferERC20(
                    bidToken,
                    address(this),
                    lastBidder,
                    _auctionData.lastBidAmount,
                    requireSuccessBuyer,
                    setGasLimitForBuyerTransfer
                );
            }
        }

        delete auctionData[auctionId];
        _activeAuctions.remove(auctionId);
        isAuctionCompleted[auctionId] = true;

        emit AucitonDeleted(msg.sender, auctionId);
    }

    /// @notice Admin function (AUCTION_MANAGER role) for pausing/unpausing creation of auctions on the marketplace.
    function togglePause() external onlyRole(AUCTION_MANAGER) {
        bool oldValue = isPausedCreation;
        isPausedCreation = !oldValue;

        emit PauseToggled(msg.sender, oldValue, !oldValue);
    }

    // external view

    /// @notice Function to get the number of active auctions on the contract.
    /// @return Amount of active auctions on the contract
    function activeAuctionsLength() external view returns (uint256) {
        return _activeAuctions.length();
    }

    /// @notice Function to get an element in the _activeAuctions array on the `index` index.
    /// @param index Index in the _activeAuctions array
    /// @return Auction id at index `index` in the array _activeAuctions
    function activeAuctionsAt(uint256 index) external view returns (bytes32) {
        return _activeAuctions.at(index);
    }

    /// @notice Function to find out if a certain auction id is active.
    /// @param auctionId Auction id to check
    /// @return True if auction `auctionId` is active
    function activeAuctionsContains(bytes32 auctionId) external view returns (bool) {
        return _activeAuctions.contains(auctionId);
    }

    // public view

    /// @notice The function of the ERC165 standard.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControlEnumerable)
        returns (bool)
    {
        return
            AccessControlEnumerable.supportsInterface(interfaceId) ||
            ERC1155Receiver.supportsInterface(interfaceId);
    }

    // private

    function _transferERC20(
        address token,
        address from,
        address to,
        uint256 amount,
        bool requireSuccess,
        bool setGasLimit
    ) private {
        require(token.isContract(), "NftMarketplaceV2: Token is not a contract");
        if (from == address(this)) {
            uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_TOKEN_TRANSFER : gasleft();
            (bool success, bytes memory data) = token.call{gas: gasLimit}(
                abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
            );
            bool isSucceeded = _checkTransferResult(success, data);
            if (requireSuccess) {
                require(
                    isSucceeded,
                    success ? "NftMarketplaceV2: ERC20 transfer result false" : _getRevertMsg(data)
                );
            } else if (!isSucceeded) {
                string memory errorMessage = success
                    ? "NftMarketplaceV2: ERC20 transfer result false"
                    : _getRevertMsg(data);
                emit BadTokenTransfer(to, token, TokenType.ERC20, 0, amount, errorMessage);
            }
        } else {
            uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_TOKEN_TRANSFER : gasleft();
            (bool success, bytes memory data) = token.call{gas: gasLimit}(
                abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
            );
            bool isSucceeded = _checkTransferResult(success, data);
            if (requireSuccess) {
                require(
                    isSucceeded,
                    success ? "NftMarketplaceV2: ERC20 transfer result false" : _getRevertMsg(data)
                );
            } else if (!isSucceeded) {
                string memory errorMessage = success
                    ? "NftMarketplaceV2: ERC20 transferFrom result false"
                    : _getRevertMsg(data);
                emit BadTokenTransfer(to, token, TokenType.ERC20, 0, amount, errorMessage);
            }
        }
    }

    function _transferNFT(
        TokenInfo memory tokenInfo,
        address from,
        address to,
        bool requireSuccess,
        bool setGasLimit
    ) private {
        if (tokenInfo.tokenType == TokenType.ERC721) {
            uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_TOKEN_TRANSFER : gasleft();
            (bool success, bytes memory data) = tokenInfo.tokenAddress.call{gas: gasLimit}(
                abi.encodeWithSignature(
                    "safeTransferFrom(address,address,uint256)",
                    from,
                    to,
                    tokenInfo.id
                )
            );
            if (requireSuccess) {
                require(success, _getRevertMsg(data));
            } else if (!success) {
                emit BadTokenTransfer(
                    to,
                    tokenInfo.tokenAddress,
                    tokenInfo.tokenType,
                    tokenInfo.id,
                    tokenInfo.amount,
                    _getRevertMsg(data)
                );
            }
        } else if (tokenInfo.tokenType == TokenType.ERC1155) {
            uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_TOKEN_TRANSFER : gasleft();
            (bool success, bytes memory data) = tokenInfo.tokenAddress.call{gas: gasLimit}(
                abi.encodeWithSelector(
                    IERC1155.safeTransferFrom.selector,
                    from,
                    to,
                    tokenInfo.id,
                    tokenInfo.amount,
                    ""
                )
            );
            if (requireSuccess) {
                require(success, _getRevertMsg(data));
            } else if (!success) {
                emit BadTokenTransfer(
                    to,
                    tokenInfo.tokenAddress,
                    tokenInfo.tokenType,
                    tokenInfo.id,
                    tokenInfo.amount,
                    _getRevertMsg(data)
                );
            }
        }
    }

    function _transferNative(
        address from,
        address to,
        uint256 amount,
        bool requireSuccess,
        bool setGasLimit
    ) private {
        require(from == msg.sender || from == address(this), "NftMarketplaceV2: Wrong from");
        if (from == msg.sender) {
            require(amount == msg.value, "NftMarketplaceV2: Wrong amount");

            if (to != address(this)) {
                uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_NATIVE_TRANSFER : gasleft();
                (bool success, bytes memory data) = to.call{value: amount, gas: gasLimit}("");
                if (requireSuccess) {
                    require(success, "NftMarketplaceV2: Transfer native");
                }
                if (!success) {
                    emit BadTokenTransfer(
                        to,
                        _ETH_ADDRESS,
                        TokenType.ERC20,
                        0,
                        amount,
                        _getRevertMsg(data)
                    );
                }
            }
        } else {
            require(address(this).balance >= amount, "NftMarketplaceV2: Not enough native balance");
            uint256 gasLimit = setGasLimit ? _MAX_GAS_FOR_NATIVE_TRANSFER : gasleft();
            (bool success, bytes memory data) = to.call{value: amount, gas: gasLimit}("");
            if (requireSuccess) {
                require(success, "NftMarketplaceV2: Transfer native");
            }
            if (!success) {
                emit BadTokenTransfer(
                    to,
                    _ETH_ADDRESS,
                    TokenType.ERC20,
                    0,
                    amount,
                    _getRevertMsg(data)
                );
            }
        }
    }

    function _transferERC20WithFee(
        address token,
        address from,
        address to,
        uint256 amount,
        address royaltyReceiver,
        uint256 royaltyAmount
    ) private {
        uint256 feeAmount = (amount * feePercentage) / 100_00;

        // not more than 50%
        if (royaltyAmount > amount / 2) {
            royaltyAmount = amount / 2;
        }

        uint256 transferAmount = amount - feeAmount - royaltyAmount;
        if (transferAmount > 0) {
            _transferERC20(token, from, to, transferAmount, true, false);
        }

        if (feeAmount > 0) {
            address _feeReceiver = feeReceiver;
            _transferERC20(token, from, _feeReceiver, feeAmount, true, false);

            emit FeeTransferred(_feeReceiver, token, feeAmount);
        }

        if (royaltyAmount > 0) {
            _transferERC20(token, from, royaltyReceiver, royaltyAmount, true, false);

            emit RoyaltyTransferred(royaltyReceiver, token, royaltyAmount);
        }
    }

    function _transferNativeWithFee(
        address from,
        address to,
        uint256 amount,
        address royaltyReceiver,
        uint256 royaltyAmount
    ) private {
        uint256 feeAmount = (amount * feePercentage) / 100_00;

        // not more than 50%
        if (royaltyAmount > amount / 2) {
            royaltyAmount = amount / 2;
        }

        uint256 transferAmount = amount - feeAmount - royaltyAmount;
        if (transferAmount > 0) {
            _transferNative(from, to, transferAmount, true, false);
        }

        if (feeAmount > 0) {
            address _feeReceiver = feeReceiver;
            _transferNative(from, _feeReceiver, feeAmount, true, false);

            emit FeeTransferred(_feeReceiver, _ETH_ADDRESS, feeAmount);
        }

        if (royaltyAmount > 0) {
            _transferNative(from, royaltyReceiver, royaltyAmount, true, false);

            emit RoyaltyTransferred(royaltyReceiver, _ETH_ADDRESS, royaltyAmount);
        }
    }

    // private view

    function _verifyToken(TokenInfo calldata tokenInfo) private view {
        require(tokenInfo.tokenAddress.isContract(), "NftMarketplaceV2: Not a contract");
        if (tokenInfo.tokenType == TokenType.ERC20) {
            require(tokenInfo.id == 0, "NftMarketplaceV2: ERC20 id");
            require(tokenInfo.amount > 0, "NftMarketplaceV2: ERC20 amount");
        } else if (tokenInfo.tokenType == TokenType.ERC721) {
            require(
                IERC165(tokenInfo.tokenAddress).supportsInterface(bytes4(0x80ac58cd)),
                "NftMarketplaceV2: ERC721 type"
            );
            require(tokenInfo.amount == 0, "NftMarketplaceV2: ERC721 amount");
        } else if (tokenInfo.tokenType == TokenType.ERC1155) {
            require(
                IERC165(tokenInfo.tokenAddress).supportsInterface(bytes4(0xd9b67a26)),
                "NftMarketplaceV2: ERC1155 type"
            );
            require(tokenInfo.amount > 0, "NftMarketplaceV2: ERC1155 amount");
        }
    }

    // private pure

    function _getAuctionId(AuctionData memory _auctionData) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _auctionData.tokenInfo,
                    _auctionData.seller,
                    _auctionData.startTime,
                    _auctionData.endTime,
                    _auctionData.bidToken
                )
            );
    }

    function _checkTransferResult(bool success, bytes memory data) private pure returns (bool) {
        return success && (data.length > 0 ? abi.decode(data, (bool)) : true);
    }

    function _getRevertMsg(bytes memory revertData)
        private
        pure
        returns (string memory errorMessage)
    {
        // revert data format:
        // 4 bytes - Function selector for Error(string)
        // 32 bytes - Data offset
        // 32 bytes - String length
        // other - String data

        // If the revertData length is less than 68, then the transaction failed silently (without a revert message)
        if (revertData.length <= 68) return "";

        uint256 index = revertData.length - 1;
        while (index > 68 && revertData[index] == bytes1(0)) {
            index--;
        }
        uint256 numberOfZeroElements = revertData.length - 1 - index;

        uint256 errorLength = revertData.length - 68 - numberOfZeroElements;
        bytes memory rawErrorMessage = new bytes(errorLength);

        for (uint256 i = 0; i < errorLength; ++i) {
            rawErrorMessage[i] = revertData[i + 68];
        }
        errorMessage = string(rawErrorMessage);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/// @title Contract that implements functionality for fetching info about royalties for a collection.
contract RoyaltiesInfo is AccessControlEnumerable {
    using Address for address;

    struct RoyaltyInfo {
        bool isEnabled;
        address royaltyReceiver;
        uint16 royaltyPercentage;
    }

    /// @notice Role that manages royalties info
    bytes32 public constant ROYALTY_MANAGER = keccak256("ROYALTY_MANAGER");

    /// @notice Holds an information about royalties that are set by an admin.
    /// Can be changed in functions setRoyalty() and disableAdminRoyalty().
    mapping(address => RoyaltyInfo) public royaltiesInfo;

    /// @notice Amount of royalties in percent (denominator 10000) for a collection in case when royalty receiver is the owner of the collection. Max value can be 1000 (10%).
    /// Can be changed in setDefaultFeeForOwner() function.
    uint16 public defaultFeeForOwner = 2_50; // 2.5%

    /// @notice Event is emmited when an admin of the contract (`manager`) has added a new royalty config (`royaltyReceiver` will receive `royaltyPercentage` percentages) for a collection `token`.
    /// @param manager Admin of the contract that has set a new royalty config for a collection `token`.
    /// @param token Address of a collection.
    /// @param royaltyReceiver Address that will receive all royalties for the collection `token`.
    /// @param royaltyPercentage Amount of percentages for royalties for the collection `token` (denominator 10000).
    event AddedAdminRoyalty(
        address indexed manager,
        address indexed token,
        address indexed royaltyReceiver,
        uint16 royaltyPercentage
    );

    /// @notice Event is emmited when an admin of the contract (`manager`) has deleted royalty config for a collection `token`.
    /// @param manager Admin of the contract that has deleted royalty config for a collection `token`.
    /// @param token Address of a collection.
    event DisabledAdminRoyalty(address indexed manager, address indexed token);

    /// @notice Event is emmited when an admin of the contract (`manager`) has changed value for defaultFeeForOwner variable from `oldValue` to `newValue`.
    /// @param manager Admin of the contract that has changed value for defaultFeeForOwner variable from `oldValue` to `newValue`.
    /// @param oldValue Previous value of defaultFeeForOwner variable.
    /// @param newValue New value for defaultFeeForOwner variable.
    event ChangedDefaultFeeForOwner(address indexed manager, uint256 oldValue, uint256 newValue);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ROYALTY_MANAGER, msg.sender);

        emit ChangedDefaultFeeForOwner(msg.sender, 0, defaultFeeForOwner);
    }

    /// @notice Admin function (ROYALTY_MANAGER role) for setting royalty config for a collection `token`.
    /// @dev Changes mapping royaltiesInfo.
    /// @param token Address of a collection (only ERC721 and ERC1155).
    /// @param royaltyReceiver Address that will collect all the royalties for the collection `token`.
    /// @param royaltyPercentage Percentage for royalties for the collection `token` (denominator 10000). Max value can be 1000 (10%).
    function setRoyalty(
        address token,
        address royaltyReceiver,
        uint16 royaltyPercentage
    ) external onlyRole(ROYALTY_MANAGER) {
        require(token.isContract(), "RoyaltiesInfo: Not a contract");
        // 0x80ac58cd - ERC721
        // 0xd9b67a26 - ERC1155
        require(
            IERC165(token).supportsInterface(bytes4(0x80ac58cd)) ||
                IERC165(token).supportsInterface(bytes4(0xd9b67a26)),
            "RoyaltiesInfo: Wrong interface"
        );

        require(royaltyPercentage <= 10_00 && royaltyPercentage > 0, "RoyaltiesInfo: Percentage"); // 10%
        require(royaltyReceiver != address(0), "RoyaltiesInfo: royaltyReceiver");

        royaltiesInfo[token] = RoyaltyInfo({
            isEnabled: true,
            royaltyReceiver: royaltyReceiver,
            royaltyPercentage: royaltyPercentage
        });

        emit AddedAdminRoyalty(msg.sender, token, royaltyReceiver, royaltyPercentage);
    }

    /// @notice Admin function (ROYALTY_MANAGER role) for setting new value (`newValue`) for defaultFeeForOwner variable.
    /// @dev Changes variable defaultFeeForOwner.
    /// @param newValue New value for variable defaultFeeForOwner.
    function setDefaultFeeForOwner(uint16 newValue) external onlyRole(ROYALTY_MANAGER) {
        require(newValue <= 10_00, "NftMarketplace: Too big percent"); // 10%

        uint256 oldValue = defaultFeeForOwner;
        require(oldValue != newValue, "NftMarketplace: No change");
        defaultFeeForOwner = newValue;

        emit ChangedDefaultFeeForOwner(msg.sender, oldValue, newValue);
    }

    /// @notice Admin function (ROYALTY_MANAGER role) for deleting royaly config for a collection `token`.
    /// @dev Changes mapping royaltiesInfo.
    /// @param token Address of a collection.
    function disableAdminRoyalty(address token) external onlyRole(ROYALTY_MANAGER) {
        require(royaltiesInfo[token].isEnabled == true, "RoyaltiesInfo: Disabled");

        delete royaltiesInfo[token];

        emit DisabledAdminRoyalty(msg.sender, token);
    }

    /// @notice Function for getting royalty info for a collection `token`.
    /// @dev Priority for royalty source:
    /// 1) Royalty config;
    /// 2) Info from ERC2981 standard;
    /// 3) Owner of a collection.
    /// If a collection doesn't have any of these items, there will be no royalties for the colleciton.
    /// @param token Address of a colleciton.
    /// @param tokenId Id of a collection that is sold.
    /// @param salePrice Sale price for this `tokenId`.
    /// @return royaltyReceiver Address that will receive royalties for collection `token`.
    /// @return royaltyAmount Amount of royaly in tokens.
    function getRoyaltyInfo(
        address token,
        uint256 tokenId,
        uint256 salePrice
    ) public view returns (address royaltyReceiver, uint256 royaltyAmount) {
        RoyaltyInfo memory royaltyInfoToken = royaltiesInfo[token];
        if (royaltyInfoToken.isEnabled) {
            return (
                royaltyInfoToken.royaltyReceiver,
                (royaltyInfoToken.royaltyPercentage * salePrice) / 100_00
            );
        } else {
            try IERC2981(token).royaltyInfo(tokenId, salePrice) returns (
                address receiver,
                uint256 amount
            ) {
                return (receiver, amount);
            } catch (bytes memory) {}

            try Ownable(token).owner() returns (address owner) {
                return (owner, (defaultFeeForOwner * salePrice) / 100_00);
            } catch (bytes memory) {
                return (address(0), 0);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}