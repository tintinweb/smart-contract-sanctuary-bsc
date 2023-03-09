// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../library/CollectionReader.sol";
import "../royalty/ICollectionRoyaltyReader.sol";
import "../payment-token/IPaymentTokenCheck.sol";
import "../market-settings/IMarketSettings.sol";
import "./IERC721Bids.sol";
import "./OperatorDelegation.sol";

contract ERC721Bids is IERC721Bids, OperatorDelegation, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    constructor(address marketSettings_) {
        _marketSettings = IMarketSettings(marketSettings_);
    }

    IMarketSettings private _marketSettings;

    mapping(address => ERC721Bids) private _erc721Bids;

    /**
     * @dev See {IERC721Bids-enterBidForToken}.
     */
    function enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp,
        address paymentToken,
        address bidder
    ) external {
        require(
            bidder == _msgSender() || isApprovedOperator(bidder, _msgSender()),
            "sender not bidder or approved operator"
        );

        (bool isValid, string memory message) = _checkEnterBidAction(
            erc721Address,
            tokenId,
            value,
            expireTimestamp,
            paymentToken,
            bidder
        );

        require(isValid, message);

        _enterBidForToken(
            erc721Address,
            tokenId,
            value,
            expireTimestamp,
            paymentToken,
            bidder
        );
    }

    /**
     * @dev See {IERC721Bids-enterBidForTokens}.
     */
    function enterBidForTokens(EnterBidInput[] calldata newBids, address bidder)
        external
    {
        require(
            bidder == _msgSender() || isApprovedOperator(bidder, _msgSender()),
            "sender not bidder or approved operator"
        );

        for (uint256 i = 0; i < newBids.length; i++) {
            address erc721Address = newBids[i].erc721Address;
            uint256 tokenId = newBids[i].tokenId;
            uint256 value = newBids[i].value;
            uint256 expireTimestamp = newBids[i].expireTimestamp;
            address paymentToken = newBids[i].paymentToken;

            (bool isValid, string memory message) = _checkEnterBidAction(
                erc721Address,
                tokenId,
                value,
                expireTimestamp,
                paymentToken,
                bidder
            );

            if (isValid) {
                _enterBidForToken(
                    erc721Address,
                    tokenId,
                    value,
                    expireTimestamp,
                    paymentToken,
                    bidder
                );
            } else {
                emit EnterBidFailed(
                    erc721Address,
                    tokenId,
                    message,
                    _msgSender()
                );
            }
        }
    }

    /**
     * @dev See {IERC721Bids-withdrawBidForToken}.
     */
    function withdrawBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) external {
        Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[bidder];

        (bool isValid, string memory message) = _checkWithdrawBidAction(bid);

        require(isValid, message);

        _withdrawBidForToken(erc721Address, bid);
    }

    /**
     * @dev See {IERC721Bids-withdrawBidForTokens}.
     */
    function withdrawBidForTokens(WithdrawBidInput[] calldata bids) external {
        for (uint256 i = 0; i < bids.length; i++) {
            address erc721Address = bids[i].erc721Address;
            uint256 tokenId = bids[i].tokenId;
            address bidder = bids[i].bidder;
            Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[
                bidder
            ];

            (bool isValid, string memory message) = _checkWithdrawBidAction(
                bid
            );

            if (isValid) {
                _withdrawBidForToken(erc721Address, bid);
            } else {
                emit WithdrawBidFailed(
                    erc721Address,
                    tokenId,
                    message,
                    _msgSender()
                );
            }
        }
    }

    /**
     * @dev See {IERC721Bids-acceptBidForToken}.
     */
    function acceptBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder,
        uint256 value
    ) external {
        Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[bidder];
        address tokenOwner = CollectionReader.tokenOwner(
            erc721Address,
            tokenId
        );

        (bool isValid, string memory message) = _checkAcceptBidAction(
            erc721Address,
            bid,
            value,
            tokenOwner
        );

        require(isValid, message);

        _acceptBidForToken(erc721Address, bid, tokenOwner);
    }

    /**
     * @dev See {IERC721Bids-acceptBidForTokens}.
     */
    function acceptBidForTokens(AcceptBidInput[] calldata bids) external {
        for (uint256 i = 0; i < bids.length; i++) {
            address erc721Address = bids[i].erc721Address;
            uint256 tokenId = bids[i].tokenId;
            address bidder = bids[i].bidder;
            uint256 value = bids[i].value;
            Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[
                bidder
            ];
            address tokenOwner = CollectionReader.tokenOwner(
                erc721Address,
                tokenId
            );

            (bool isValid, string memory message) = _checkAcceptBidAction(
                erc721Address,
                bid,
                value,
                tokenOwner
            );

            if (isValid) {
                _acceptBidForToken(erc721Address, bid, tokenOwner);
            } else {
                emit AcceptBidFailed(
                    erc721Address,
                    tokenId,
                    message,
                    _msgSender()
                );
            }
        }
    }

    /**
     * @dev See {IERC721Bids-removeExpiredBids}.
     */
    function removeExpiredBids(RemoveExpiredBidInput[] calldata bids) external {
        for (uint256 i = 0; i < bids.length; i++) {
            address erc721Address = bids[i].erc721Address;
            uint256 tokenId = bids[i].tokenId;
            address bidder = bids[i].bidder;
            Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[
                bidder
            ];

            if (
                bid.expireTimestamp != 0 &&
                bid.expireTimestamp <= block.timestamp
            ) {
                _removeBid(erc721Address, tokenId, bidder);
            }
        }
    }

    /**
     * @dev check if enter bid action is valid
     * if not valid, return the reason
     */
    function _checkEnterBidAction(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp,
        address paymentToken,
        address bidder
    ) private view returns (bool isValid, string memory message) {
        isValid = false;

        if (!_marketSettings.isCollectionTradingEnabled(erc721Address)) {
            message = "trading is not open";
            return (isValid, message);
        }
        if (value == 0) {
            message = "value cannot be 0";
            return (isValid, message);
        }
        if (
            expireTimestamp - block.timestamp <
            _marketSettings.actionTimeOutRangeMin()
        ) {
            message = "expire time below minimum";
            return (isValid, message);
        }
        if (
            expireTimestamp - block.timestamp >
            _marketSettings.actionTimeOutRangeMax()
        ) {
            message = "expire time above maximum";
            return (isValid, message);
        }
        if (!_isAllowedPaymentToken(erc721Address, paymentToken)) {
            message = "payment token not enabled";
            return (isValid, message);
        }
        address _paymentToken = _getPaymentTokenAddress(paymentToken);
        if (IERC20(_paymentToken).balanceOf(bidder) < value) {
            message = "insufficient balance";
            return (isValid, message);
        }
        if (IERC20(_paymentToken).allowance(bidder, address(this)) < value) {
            message = "insufficient allowance";
            return (isValid, message);
        }
        address tokenOwner = CollectionReader.tokenOwner(
            erc721Address,
            tokenId
        );
        if (tokenOwner == bidder) {
            message = "token owner cannot bid";
            return (isValid, message);
        }

        isValid = true;
    }

    /**
     * @dev enter a bid
     */
    function _enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp,
        address paymentToken,
        address bidder
    ) private {
        Bid memory bid = Bid(
            tokenId,
            value,
            bidder,
            expireTimestamp,
            paymentToken
        );

        _erc721Bids[erc721Address].tokenIds.add(tokenId);
        _erc721Bids[erc721Address].bids[tokenId].bidders.add(bidder);
        _erc721Bids[erc721Address].bids[tokenId].bids[bidder] = bid;

        emit TokenBidEntered(erc721Address, bidder, tokenId, bid, _msgSender());
    }

    /**
     * @dev check if withdraw bid action is valid
     * if not valid, return the reason
     */
    function _checkWithdrawBidAction(Bid memory bid)
        private
        view
        returns (bool isValid, string memory message)
    {
        isValid = false;

        if (bid.bidder == address(0)) {
            message = "bid does not exist";
            return (isValid, message);
        }

        if (
            bid.bidder != _msgSender() &&
            !isApprovedOperator(bid.bidder, _msgSender())
        ) {
            message = "sender not bidder or approved operator";
            return (isValid, message);
        }

        isValid = true;
    }

    /**
     * @dev withdraw a bid
     */
    function _withdrawBidForToken(address erc721Address, Bid memory bid)
        private
    {
        _removeBid(erc721Address, bid.tokenId, bid.bidder);

        emit TokenBidWithdrawn(
            erc721Address,
            bid.bidder,
            bid.tokenId,
            bid,
            _msgSender()
        );
    }

    /**
     * @dev check if accept bid action is valid
     * if not valid, return the reason
     */
    function _checkAcceptBidAction(
        address erc721Address,
        Bid memory bid,
        uint256 value,
        address tokenOwner
    ) private view returns (bool isValid, string memory message) {
        isValid = false;

        Status status = _getBidStatus(erc721Address, bid);
        if (status != Status.ACTIVE) {
            message = "bid is not valid";
            return (isValid, message);
        }
        if (value != bid.value) {
            message = "accepting value differ from bid";
            return (isValid, message);
        }
        if (
            tokenOwner != _msgSender() &&
            !isApprovedOperator(tokenOwner, _msgSender())
        ) {
            message = "sender not owner or approved operator";
            return (isValid, message);
        }
        if (
            !_isApprovedToTransferToken(erc721Address, bid.tokenId, tokenOwner)
        ) {
            message = "transferred not approved";
            return (isValid, message);
        }
        isValid = true;
    }

    /**
     * @dev accept a bid
     */
    function _acceptBidForToken(
        address erc721Address,
        Bid memory bid,
        address tokenOwner
    ) private nonReentrant {
        (
            FundReceiver[] memory fundReceivers,
            ICollectionRoyaltyReader.RoyaltyAmount[] memory royaltyInfo,
            uint256 serviceFee
        ) = _getFundReceiversOfBid(erc721Address, bid, tokenOwner);

        _sendFundToReceivers(bid.bidder, fundReceivers);

        // Send token to bidder
        IERC721(erc721Address).safeTransferFrom(
            tokenOwner,
            bid.bidder,
            bid.tokenId
        );

        _removeBid(erc721Address, bid.tokenId, bid.bidder);

        emit TokenBidAccepted({
            erc721Address: erc721Address,
            seller: tokenOwner,
            tokenId: bid.tokenId,
            bid: bid,
            serviceFee: serviceFee,
            royaltyInfo: royaltyInfo,
            sender: _msgSender()
        });
    }

    /**
     * @dev remove bid from storage
     */
    function _removeBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) private {
        if (_erc721Bids[erc721Address].bids[tokenId].bidders.contains(bidder)) {
            // Step 1: delete the bid and the address
            delete _erc721Bids[erc721Address].bids[tokenId].bids[bidder];
            _erc721Bids[erc721Address].bids[tokenId].bidders.remove(bidder);

            // Step 2: if no bid left
            if (
                _erc721Bids[erc721Address].bids[tokenId].bidders.length() == 0
            ) {
                _erc721Bids[erc721Address].tokenIds.remove(tokenId);
            }
        }
    }

    /**
     * @dev get list of fund receivers, amount, and payment token
     * Note:
     * List of receivers
     * - Seller of token
     * - Service fee receiver
     * - royalty receivers
     */
    function _getFundReceiversOfBid(
        address erc721Address,
        Bid memory bid,
        address tokenOwner
    )
        private
        view
        returns (
            FundReceiver[] memory fundReceivers,
            ICollectionRoyaltyReader.RoyaltyAmount[] memory royaltyInfo,
            uint256 serviceFee
        )
    {
        address paymentToken = _getPaymentTokenAddress(bid.paymentToken);

        royaltyInfo = ICollectionRoyaltyReader(
            _marketSettings.royaltyRegsitry()
        ).royaltyInfo(erc721Address, bid.tokenId, bid.value);

        fundReceivers = new FundReceiver[](royaltyInfo.length + 2);

        uint256 amountToSeller = bid.value;
        for (uint256 i = 0; i < royaltyInfo.length; i++) {
            address royaltyReceiver = royaltyInfo[i].receiver;
            uint256 royaltyAmount = royaltyInfo[i].royaltyAmount;

            fundReceivers[i + 2] = FundReceiver({
                account: royaltyReceiver,
                amount: royaltyAmount,
                paymentToken: paymentToken
            });

            amountToSeller -= royaltyAmount;
        }

        (address feeReceiver, uint256 feeAmount) = _marketSettings
            .serviceFeeInfo(bid.value);
        serviceFee = feeAmount;

        fundReceivers[1] = FundReceiver({
            account: feeReceiver,
            amount: serviceFee,
            paymentToken: paymentToken
        });

        amountToSeller -= serviceFee;

        fundReceivers[0] = FundReceiver({
            account: tokenOwner,
            amount: amountToSeller,
            paymentToken: paymentToken
        });
    }

    /**
     * @dev map payment token address
     * Address 0 is mapped to wrapped ether address.
     * For a given chain, wrapped ether represent it's
     * corresponding wrapped coin. e.g. WBNB for BSC, WFTM for FTM
     */
    function _getPaymentTokenAddress(address _paymentToken)
        private
        view
        returns (address paymentToken)
    {
        paymentToken = _paymentToken;

        if (_paymentToken == address(0)) {
            paymentToken = _marketSettings.wrappedEther();
        }
    }

    /**
     * @dev send payment token
     */
    function _sendFund(
        address paymentToken,
        address from,
        address to,
        uint256 value
    ) private {
        require(paymentToken != address(0), "payment token can't be 0 address");
        IERC20(paymentToken).safeTransferFrom(from, to, value);
    }

    /**
     * @dev send funds to a list of receivers
     */
    function _sendFundToReceivers(
        address from,
        FundReceiver[] memory fundReceivers
    ) private {
        for (uint256 i; i < fundReceivers.length; i++) {
            _sendFund(
                fundReceivers[i].paymentToken,
                from,
                fundReceivers[i].account,
                fundReceivers[i].amount
            );
        }
    }

    /**
     * @dev See {IERC721Bids-getBidderTokenBid}.
     */
    function getBidderTokenBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) public view returns (BidStatus memory) {
        Bid memory bid = _erc721Bids[erc721Address].bids[tokenId].bids[bidder];
        Status status = _getBidStatus(erc721Address, bid);

        return
            BidStatus({
                tokenId: bid.tokenId,
                value: bid.value,
                bidder: bid.bidder,
                expireTimestamp: bid.expireTimestamp,
                paymentToken: bid.paymentToken,
                status: status
            });
    }

    /**
     * @dev See {IERC721Bids-getTokenBids}.
     */
    function getTokenBids(address erc721Address, uint256 tokenId)
        public
        view
        returns (BidStatus[] memory bids)
    {
        uint256 bidderCount = _erc721Bids[erc721Address]
            .bids[tokenId]
            .bidders
            .length();

        bids = new BidStatus[](bidderCount);
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Bids[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            bids[i] = getBidderTokenBid(erc721Address, tokenId, bidder);
        }
    }

    /**
     * @dev See {IERC721Bids-getTokenHighestBid}.
     */
    function getTokenHighestBid(address erc721Address, uint256 tokenId)
        public
        view
        returns (BidStatus memory highestBid)
    {
        uint256 bidderCount = _erc721Bids[erc721Address]
            .bids[tokenId]
            .bidders
            .length();
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Bids[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            BidStatus memory bid = getBidderTokenBid(
                erc721Address,
                tokenId,
                bidder
            );
            if (bid.status == Status.ACTIVE && bid.value > highestBid.value) {
                highestBid = bid;
            }
        }
    }

    /**
     * @dev See {IERC721Bids-numTokenWithBidsOfCollection}.
     */
    function numTokenWithBidsOfCollection(address erc721Address)
        public
        view
        returns (uint256)
    {
        return _erc721Bids[erc721Address].tokenIds.length();
    }

    /**
     * @dev See {IERC721Bids-getHighestBidsOfCollection}.
     */
    function getHighestBidsOfCollection(
        address erc721Address,
        uint256 from,
        uint256 size
    ) external view returns (BidStatus[] memory highestBids) {
        uint256 tokenCount = numTokenWithBidsOfCollection(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            highestBids = new BidStatus[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Bids[erc721Address].tokenIds.at(i + from)
                });
            }
        }
    }

    /**
     * @dev See {IERC721Bids-getBidderBidsOfCollection}.
     */
    function getBidderBidsOfCollection(
        address erc721Address,
        address bidder,
        uint256 from,
        uint256 size
    ) external view returns (BidStatus[] memory bidderBids) {
        uint256 tokenCount = numTokenWithBidsOfCollection(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            bidderBids = new BidStatus[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                bidderBids[i] = getBidderTokenBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Bids[erc721Address].tokenIds.at(i + from),
                    bidder: bidder
                });
            }
        }
    }

    /**
     * @dev address of market settings contract
     */
    function marketSettingsContract() external view returns (address) {
        return address(_marketSettings);
    }

    /**
     * @dev update market settings contract
     */
    function updateMarketSettingsContract(address newMarketSettingsContract)
        external
        onlyOwner
    {
        address oldMarketSettingsContract = address(_marketSettings);
        _marketSettings = IMarketSettings(newMarketSettingsContract);

        emit MarketSettingsContractUpdated(
            oldMarketSettingsContract,
            newMarketSettingsContract
        );
    }

    /**
     * @dev check if payment token is allowed for a collection
     */
    function _isAllowedPaymentToken(address erc721Address, address paymentToken)
        private
        view
        returns (bool)
    {
        return
            paymentToken == address(0) ||
            IPaymentTokenCheck(_marketSettings.paymentTokenRegistry())
                .isAllowedPaymentToken(erc721Address, paymentToken);
    }

    /**
     * @dev check if a token or a collection if approved
     *  to be transferred by this contract
     */
    function _isApprovedToTransferToken(
        address erc721Address,
        uint256 tokenId,
        address account
    ) private view returns (bool) {
        return
            CollectionReader.isTokenApproved(erc721Address, tokenId) ||
            CollectionReader.isAllTokenApproved(
                erc721Address,
                account,
                address(this)
            );
    }

    /**
     * @dev get current status of a bid
     */
    function _getBidStatus(address erc721Address, Bid memory bid)
        private
        view
        returns (Status)
    {
        if (bid.bidder == address(0)) {
            return Status.NOT_EXIST;
        }
        if (!_marketSettings.isCollectionTradingEnabled(erc721Address)) {
            return Status.TRADE_NOT_OPEN;
        }
        if (bid.expireTimestamp < block.timestamp) {
            return Status.EXPIRED;
        }
        if (
            CollectionReader.tokenOwner(erc721Address, bid.tokenId) ==
            bid.bidder
        ) {
            return Status.ALREADY_TOKEN_OWNER;
        }
        if (!_isAllowedPaymentToken(erc721Address, bid.paymentToken)) {
            return Status.INVALID_PAYMENT_TOKEN;
        }

        address paymentToken = _getPaymentTokenAddress(bid.paymentToken);
        if (IERC20(paymentToken).balanceOf(bid.bidder) < bid.value) {
            return Status.INSUFFICIENT_BALANCE;
        }
        if (
            IERC20(paymentToken).allowance(bid.bidder, address(this)) <
            bid.value
        ) {
            return Status.INSUFFICIENT_ALLOWANCE;
        }

        return Status.ACTIVE;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface ICollectionRoyaltyReader {
    struct RoyaltyAmount {
        address receiver;
        uint256 royaltyAmount;
    }

    /**
     * @dev Get collection royalty receiver list
     * @param collectionAddress to read royalty receiver
     * @return list of royalty receivers and their shares
     */
    function royaltyInfo(
        address collectionAddress,
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (RoyaltyAmount[] memory);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IPaymentTokenCheck {
    /**
     * @dev Check if a payment token is allowed for a collection
     */
    function isAllowedPaymentToken(address collectionAddress, address token)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IOperatorDelegation.sol";

contract OperatorDelegation is IOperatorDelegation, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Allowed operator contracts will be reviewed
    // to make sure the original caller is the owner.
    // And the operator contract is a just a delegator contract
    // that does what the owner intended
    EnumerableSet.AddressSet private _allowedOperators;
    mapping(address => string) private _operatorName;
    mapping(address => EnumerableSet.AddressSet) private _operatorApprovals;

    /**
     * @dev See {IOperatorDelegation-setApprovalToOperator}.
     */
    function setApprovalToOperator(address operator, bool approved) public {
        _setApprovalToOperator(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IOperatorDelegation-isOperatorAllowed}.
     */
    function isOperatorAllowed(address operator) public view returns (bool) {
        return _allowedOperators.contains(operator);
    }

    /**
     * @dev See {IOperatorDelegation-isApprovedOperator}.
     */
    function isApprovedOperator(address owner, address operator)
        public
        view
        returns (bool)
    {
        return
            isOperatorAllowed(operator) &&
            _operatorApprovals[owner].contains(operator);
    }

    /**
     * @dev See {IOperatorDelegation-getOperator}.
     */
    function getOperator(address operator)
        external
        view
        returns (OperatorInfo memory operatorInfo)
    {
        if (isOperatorAllowed(operator)) {
            operatorInfo = OperatorInfo({
                operator: operator,
                name: _operatorName[operator]
            });
        }
    }

    /**
     * @dev See {IOperatorDelegation-getAllowedOperators}.
     */
    function getAllowedOperators()
        external
        view
        returns (OperatorInfo[] memory operators)
    {
        operators = new OperatorInfo[](_allowedOperators.length());

        for (uint256 i; i < _allowedOperators.length(); i++) {
            operators[i] = OperatorInfo({
                operator: _allowedOperators.at(i),
                name: _operatorName[_allowedOperators.at(i)]
            });
        }
    }

    /**
     * @dev See {IOperatorDelegation-getOwnerApprovedOperators}.
     */
    function getOwnerApprovedOperators(address owner)
        external
        view
        returns (OwnerOperatorInfo[] memory operators)
    {
        uint256 ownerOperatorCount = _operatorApprovals[owner].length();
        operators = new OwnerOperatorInfo[](ownerOperatorCount);

        for (uint256 i; i < ownerOperatorCount; i++) {
            address operator = _operatorApprovals[owner].at(i);
            operators[i] = OwnerOperatorInfo({
                operator: operator,
                name: _operatorName[operator],
                allowed: _allowedOperators.contains(operator)
            });
        }
    }

    /**
     * @dev See {IOperatorDelegation-addAllowedOperator}.
     */
    function addAllowedOperator(address newOperator, string memory operatorName)
        external
        onlyOwner
    {
        require(
            !_allowedOperators.contains(newOperator),
            "operator already in allowed list"
        );

        _allowedOperators.add(newOperator);
        _operatorName[newOperator] = operatorName;

        emit AllowedOperatorAdded(newOperator, operatorName, _msgSender());
    }

    /**
     * @dev See {IOperatorDelegation-removeAllowedOperator}.
     */
    function removeAllowedOperator(address operator) external onlyOwner {
        require(
            _allowedOperators.contains(operator),
            "operator not in allowed list"
        );

        string memory operatorName = _operatorName[operator];

        _allowedOperators.remove(operator);
        delete _operatorName[operator];

        emit AllowedOperatorRemoved(operator, operatorName, _msgSender());
    }

    /**
     * @dev See {IOperatorDelegation-updateOperatorName}.
     */
    function updateOperatorName(address operator, string memory newName)
        external
        onlyOwner
    {
        require(
            _allowedOperators.contains(operator),
            "operator not in allowed list"
        );

        string memory oldName = _operatorName[operator];

        require(
            keccak256(abi.encodePacked((newName))) ==
                keccak256(abi.encodePacked((oldName))),
            "operator name unchanged"
        );

        _operatorName[operator] = newName;

        emit OperatorNameUpdated(operator, oldName, newName, _msgSender());
    }

    /**
     * @dev Approve `operator` to operate on behalf of `owner`
     */
    function _setApprovalToOperator(
        address owner,
        address operator,
        bool approved
    ) private {
        require(
            _allowedOperators.contains(operator),
            "operator not in allowed list"
        );
        require(owner != operator, "approve to sender");

        if (approved) {
            _operatorApprovals[owner].add(operator);
        } else {
            _operatorApprovals[owner].remove(operator);
        }

        string memory operatorName = _operatorName[operator];
        emit OperatorApproved(owner, operator, approved, operatorName);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IOperatorDelegation {
    struct OperatorInfo {
        address operator;
        string name;
    }

    struct OwnerOperatorInfo {
        address operator;
        string name;
        bool allowed;
    }

    event OperatorApproved(
        address indexed owner,
        address indexed operator,
        bool approved,
        string operatorName
    );

    event AllowedOperatorAdded(
        address indexed operator,
        string operatorName,
        address sender
    );

    event AllowedOperatorRemoved(
        address indexed operator,
        string operatorName,
        address sender
    );

    event OperatorNameUpdated(
        address indexed operator,
        string previousName,
        string newName,
        address sender
    );

    /**
     * @dev Approve or remove `operator` as an operator for the sender.
     */
    function setApprovalToOperator(address operator, bool _approved) external;

    /**
     * @dev check if operator is in the allowed list
     */
    function isOperatorAllowed(address operator) external view returns (bool);

    /**
     * @dev check if the `operator` is allowed to manage on behalf of `owner`.
     */
    function isApprovedOperator(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev check details of operator by address
     */
    function getOperator(address operator)
        external
        view
        returns (OperatorInfo memory);

    /**
     * @dev get the allowed list of operators
     */
    function getAllowedOperators()
        external
        view
        returns (OperatorInfo[] memory);

    /**
     * @dev get approved operators of a given address
     */
    function getOwnerApprovedOperators(address owner)
        external
        view
        returns (OwnerOperatorInfo[] memory);

    /**
     * @dev add allowed operator to allowed list
     */
    function addAllowedOperator(address newOperator, string memory operatorName)
        external;

    /**
     * @dev remove allowed operator from allowed list
     */
    function removeAllowedOperator(address operator) external;

    /**
     * @dev update name of an operator
     */
    function updateOperatorName(address operator, string memory newName)
        external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../royalty/ICollectionRoyaltyReader.sol";

interface IERC721Bids {
    struct EnterBidInput {
        address erc721Address;
        uint256 tokenId;
        uint256 value;
        uint256 expireTimestamp;
        address paymentToken;
    }

    struct WithdrawBidInput {
        address erc721Address;
        uint256 tokenId;
        address bidder;
    }

    struct AcceptBidInput {
        address erc721Address;
        uint256 tokenId;
        address bidder;
        uint256 value;
    }

    struct RemoveExpiredBidInput {
        address erc721Address;
        uint256 tokenId;
        address bidder;
    }

    struct Bid {
        uint256 tokenId;
        uint256 value;
        address bidder;
        uint256 expireTimestamp;
        address paymentToken;
    }

    struct TokenBids {
        EnumerableSet.AddressSet bidders;
        mapping(address => Bid) bids;
    }

    struct ERC721Bids {
        EnumerableSet.UintSet tokenIds;
        mapping(uint256 => TokenBids) bids;
    }

    struct FundReceiver {
        address account;
        uint256 amount;
        address paymentToken;
    }

    enum Status {
        NOT_EXIST, // 0: bid doesn't exist
        ACTIVE, // 1: bid is active and valid
        TRADE_NOT_OPEN, // 2: trade not open
        EXPIRED, // 3: bid has expired
        ALREADY_TOKEN_OWNER, // 4: bidder is token owner
        INVALID_PAYMENT_TOKEN, // 5: payment token is not allowed
        INSUFFICIENT_BALANCE, // 6: insufficient payment token balance
        INSUFFICIENT_ALLOWANCE // 7: insufficient payment token allowance
    }

    struct BidStatus {
        uint256 tokenId;
        uint256 value;
        address bidder;
        uint256 expireTimestamp;
        address paymentToken;
        Status status;
    }

    event TokenBidEntered(
        address indexed erc721Address,
        address indexed bidder,
        uint256 tokenId,
        Bid bids,
        address sender
    );
    event TokenBidWithdrawn(
        address indexed erc721Address,
        address indexed bidder,
        uint256 tokenId,
        Bid bid,
        address sender
    );
    event TokenBidAccepted(
        address indexed erc721Address,
        address indexed seller,
        uint256 tokenId,
        Bid bid,
        uint256 serviceFee,
        ICollectionRoyaltyReader.RoyaltyAmount[] royaltyInfo,
        address sender
    );

    event EnterBidFailed(
        address indexed erc721Address,
        uint256 tokenId,
        string message,
        address sender
    );
    event WithdrawBidFailed(
        address indexed erc721Address,
        uint256 tokenId,
        string message,
        address sender
    );
    event AcceptBidFailed(
        address indexed erc721Address,
        uint256 tokenId,
        string message,
        address sender
    );

    event MarketSettingsContractUpdated(
        address previousMarketSettingsContract,
        address newMarketSettingsContract
    );

    /**
     * @dev enter bid for token
     * @param erc721Address collection address
     * @param tokenId token ID to bid on
     * @param value bid price
     * @param expireTimestamp bid expire time
     * @param paymentToken erc20 token for payment
     * @param bidder address of bidder
     * Note:
     * paymentToken: When using address 0 as payment token,
     * it refers to wrapped coin of the chain, e.g. WBNB, WFTM, etc.
     * bidder: bidder is a required field because
     * sender can be a delegated operator, therefore bidder
     * address needs to be included
     */
    function enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp,
        address paymentToken,
        address bidder
    ) external;

    /**
     * @dev batch enter bids
     * @param newBids details of new bid
     * @param bidder address of bidder
     * Note:
     * Refer to enterBidForToken comments for input params def
     */
    function enterBidForTokens(EnterBidInput[] calldata newBids, address bidder)
        external;

    /**
     * @dev withdraw bid for token
     * @param erc721Address collection address
     * @param tokenId token ID of the bid
     * @param bidder address of bidder
     */
    function withdrawBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) external;

    /**
     * @dev batch withdraw bids
     * @param bids details of bid to withdraw
     * Note:
     * Refer to withdrawBidForToken comments for input params def
     */
    function withdrawBidForTokens(WithdrawBidInput[] calldata bids) external;

    /**
     * @dev accept bid for token
     * @param erc721Address collection address
     * @param tokenId token ID to accept bid of
     * @param value bid price
     * @param bidder address of bidder
     * Note:
     * value is required to avoid bidder frontrun
     */
    function acceptBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder,
        uint256 value
    ) external;

    /**
     * @dev batch accept bids
     * @param bids details of bid to accept
     * Note:
     * Refer to acceptBidForToken comments for input params def
     */
    function acceptBidForTokens(AcceptBidInput[] calldata bids) external;

    /**
     * @dev Remove expired bids
     * @param bids list bids to remove
     * anyone can removed expired bids
     */
    function removeExpiredBids(RemoveExpiredBidInput[] calldata bids) external;

    /**
     * @dev get bid details of a bid
     * @param erc721Address collection address
     * @param tokenId token ID to read
     * @param bidder address of bidder
     */
    function getBidderTokenBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) external view returns (BidStatus memory);

    /**
     * @dev get bids details of a token
     * @param erc721Address collection address
     * @param tokenId token ID to read
     */
    function getTokenBids(address erc721Address, uint256 tokenId)
        external
        view
        returns (BidStatus[] memory bids);

    /**
     * @dev get highest bid of a token
     * @param erc721Address collection address
     * @param tokenId token ID to read
     */
    function getTokenHighestBid(address erc721Address, uint256 tokenId)
        external
        view
        returns (BidStatus memory highestBid);

    /**
     * @dev get number of token with bids of a collection
     * @param erc721Address collection address
     */
    function numTokenWithBidsOfCollection(address erc721Address)
        external
        view
        returns (uint256);

    /**
     * @dev get batch of highest bids of a collection
     * @param erc721Address collection address
     * @param from index of token to read
     * @param size amount of tokens to read
     */
    function getHighestBidsOfCollection(
        address erc721Address,
        uint256 from,
        uint256 size
    ) external view returns (BidStatus[] memory highestBids);

    /**
     * @dev get batch of bids from a bidder of a collection
     * @param erc721Address collection address
     * @param bidder address of bidder
     * @param from index of token to read
     * @param size amount of tokens to read
     */
    function getBidderBidsOfCollection(
        address erc721Address,
        address bidder,
        uint256 from,
        uint256 size
    ) external view returns (BidStatus[] memory bidderBids);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IMarketSettings {
    event RoyaltyRegistryChanged(
        address previousRoyaltyRegistry,
        address newRoyaltyRegistry
    );

    event PaymentTokenRegistryChanged(
        address previousPaymentTokenRegistry,
        address newPaymentTokenRegistry
    );

    /**
     * @dev fee denominator for service fee
     */
    function FEE_DENOMINATOR() external view returns (uint256);

    /**
     * @dev address to wrapped coin of the chain
     * e.g.: WETH, WBNB, WFTM, WAVAX, etc.
     */
    function wrappedEther() external view returns (address);

    /**
     * @dev address of royalty registry contract
     */
    function royaltyRegsitry() external view returns (address);

    /**
     * @dev address of payment token registry
     */
    function paymentTokenRegistry() external view returns (address);

    /**
     * @dev Show if trading is enabled
     */
    function isTradingEnabled() external view returns (bool);

    /**
     * @dev Show if trading is enabled
     */
    function isCollectionTradingEnabled(address collectionAddress)
        external
        view
        returns (bool);

    /**
     * @dev Surface minimum trading time range
     */
    function actionTimeOutRangeMin() external view returns (uint256);

    /**
     * @dev Surface maximum trading time range
     */
    function actionTimeOutRangeMax() external view returns (uint256);

    /**
     * @dev Service fee receiver
     */
    function serviceFeeReceiver() external view returns (address);

    /**
     * @dev Service fee fraction
     * @return fee fraction based on denominator
     */
    function serviceFeeFraction() external view returns (uint256);

    /**
     * @dev Service fee receiver and amount
     * @param salePrice price of token
     */
    function serviceFeeInfo(uint256 salePrice)
        external
        view
        returns (address, uint256);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

library CollectionReader {
    function collectionOwner(address collectionAddress)
        internal
        view
        returns (address owner)
    {
        try Ownable(collectionAddress).owner() returns (address _owner) {
            owner = _owner;
        } catch {}
    }

    function tokenOwner(address erc721Address, uint256 tokenId)
        internal
        view
        returns (address owner)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.ownerOf(tokenId) returns (address _owner) {
            owner = _owner;
        } catch {}
    }

    /**
     * @dev check if this contract has approved to transfer this erc721 token
     */
    function isTokenApproved(address erc721Address, uint256 tokenId)
        internal
        view
        returns (bool isApproved)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            if (tokenOperator == address(this)) {
                isApproved = true;
            }
        } catch {}
    }

    /**
     * @dev check if this contract has approved to all of this owner's erc721 tokens
     */
    function isAllTokenApproved(
        address erc721Address,
        address owner,
        address operator
    ) internal view returns (bool isApproved) {
        IERC721 _erc721 = IERC721(erc721Address);

        try _erc721.isApprovedForAll(owner, operator) returns (
            bool _isApproved
        ) {
            isApproved = _isApproved;
        } catch {}
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

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