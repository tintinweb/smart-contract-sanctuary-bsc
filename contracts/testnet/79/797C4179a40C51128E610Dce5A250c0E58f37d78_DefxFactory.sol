// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "./DefxHelpers.sol";
import "./DefxPair.sol";
import "./DefxStat.sol";

contract DefxFactory {
    using SafeMath for uint256;

    address public coinsAllower;

    address public statAddress;

    mapping(address => string) public encKeys;

    mapping(address => mapping(string => address)) public getPair;

    mapping(address => bool) public isPair;

    mapping(address => bool) public allowedCoins;

    event PairCreated(address cryptoAddress, string fiatAddress, address pair);

    address public WETH;
    address public DEFX_COIN;
    address public PANCAKE_ROUTER;

    constructor(
        address _weth,
        address _defx_coin,
        address _pancake_router
    ) {
        coinsAllower = msg.sender;
        WETH = _weth;
        DEFX_COIN = _defx_coin;
        PANCAKE_ROUTER = _pancake_router;

        // deploy DefxStat
        statAddress = address(new DefxStat());
    }

    function setAllowedCoin(address _coinAddress) public {
        require(msg.sender == coinsAllower, "Defx: FORBIDDEN");
        allowedCoins[_coinAddress] = true;
    }

    function setEncKey(string memory _key) external {
        encKeys[msg.sender] = _key;
    }

    function createPair(address cryptoAddress, string memory fiatCode) external returns (address pair) {
        require(getPair[cryptoAddress][fiatCode] == address(0), "Defx: PAIR_EXISTS"); // single check is sufficient
        require(allowedCoins[cryptoAddress], "Defx: FORBIDDEN");

        bytes memory bytecode = type(DefxPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(cryptoAddress, fiatCode));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IDefxPair(pair).initialize(cryptoAddress, fiatCode);
        getPair[cryptoAddress][fiatCode] = pair;
        isPair[pair] = true;
        emit PairCreated(cryptoAddress, fiatCode, pair);

        // allow crypto to pay fees
        TransferHelper.safeApprove(cryptoAddress, PANCAKE_ROUTER, MAX_UINT);
    }

    function buyDefxSendRewards(address feeToken) external {
        uint256 balance = IERC20(feeToken).balanceOf(address(this));

        // pay rewards
        uint256 rewards = balance.mul(200).div(10000);
        TransferHelper.safeTransfer(feeToken, msg.sender, rewards);

        // buy $DeFX Token for the rest
        uint256 amountIn = balance.sub(rewards);

        address[] memory path;
        path = new address[](3);
        path[0] = feeToken;
        path[1] = WETH;
        path[2] = DEFX_COIN;

        IPancakeRouter(PANCAKE_ROUTER).swapExactTokensForTokens(amountIn, 0, path, address(this), block.timestamp);
    }

    function burnFees() external {
        IDefxToken(DEFX_COIN).burnAll();
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./DefxInterfaces.sol";

library DefxHelpers {
    using SafeMath for uint256;

    // 0.25% (25 / 10000)
    uint256 public constant MATCH_FEE = 25;

    uint256 public constant EXPIRY_BLOCKS = 2400;
    // test data: 2400
    // prod data: 403200

    // 1h after bank details sent
    uint256 public constant SELLER_CANCEL_AFTER_BLOCKS = 1200;

    // 3% (300 / 10000)
    uint256 public constant CANCEL_PENALTY = 300;

    event DealFinished(address indexed buyer, address indexed seller, uint256 amountCrypto, uint256 amountFiat, string status);

    event OfferUpdated(bool indexed isBuy, address indexed creator, uint256 available);

    function createOffer(Offer storage offer, CreateOfferParams memory params) external {
        require(offer.collateral == 0, "Defx: OFFER_EXISTS");
        require(params._paymentMethods.length > 0, "Defx: !PAYMENT_METHODS");
        require(params._price > 0, "Defx: !PRICE");
        require(params._ratio >= 11000, "Defx: RATIO_LIMIT");

        uint256 offerCollateral;
        if (!params._isBuy || params._max == 0) {
            offerCollateral = params._available.mul(params._ratio).div(10000);
        } else {
            offerCollateral = params
                ._deposit
                // rounding collateral to ratio
                .div(params._ratio)
                .mul(params._ratio);
        }
        require(offerCollateral > 0, "Defx: INVALID_DEPOSIT");

        TransferHelper.safeTransferFrom(params._cryptoAddress, msg.sender, address(this), offerCollateral);

        offer.collateral = offerCollateral;
        offer.available = params._available;
        offer.min = params._min;
        offer.max = params._max;
        offer.price = params._price;
        offer.paymentMethods = params._paymentMethods;
        offer.desc = params._desc;
        offer.ratio = params._ratio;

        _renewOffer(offer, params._isBuy, msg.sender);
    }

    function matchOffer(
        Offer storage offer,
        Deal storage deal,
        DealLinks storage dealLinks,
        MatchParams memory params
    ) external {
        // fixed or limited offer
        uint256 amountCrypto = offer.max > 0 ? params.amountCrypto : offer.available;
        deal.amountCrypto = amountCrypto;

        require(amountCrypto <= offer.available, "Defx: INSUFFICIENT_OFFER_AVAILABLE");

        uint256 amountFiat = amountCrypto.mul(offer.price).div(10**18);
        deal.amountFiat = amountFiat;

        // for limit offer check min / max
        if (offer.max > 0) {
            require(amountFiat >= offer.min && amountFiat <= offer.max, "Defx: !MIN_MAX");
        }

        deal.isBuyerOwner = params.isBuy;
        deal.paymentMethod = params.paymentMethod;

        uint256 dealCollateral = amountCrypto.mul(offer.ratio).div(10000);
        deal.collateral = dealCollateral;
        require(dealCollateral > 0 && offer.collateral >= dealCollateral, "Defx: INSUFFICIENT_OFFER_COLLATERAL");

        uint256 fee = amountCrypto.mul(MATCH_FEE).div(10000);

        // taking collateral + fee from matcher
        TransferHelper.safeTransferFrom(params.cryptoAddress, msg.sender, address(this), deal.collateral);
        // taking fee and sending to factory
        TransferHelper.safeTransferFrom(params.cryptoAddress, msg.sender, params.factory, fee);

        offer.collateral = offer.collateral.sub(deal.collateral);
        offer.available = offer.available.sub(amountCrypto);

        _addLinks(dealLinks, params.isBuy, params.owner, msg.sender);
        _renewOffer(offer, params.isBuy, params.owner);
    }

    function _addLinks(
        DealLinks storage dealLinks,
        bool isBuy,
        address owner,
        address matcher
    ) internal {
        if (isBuy) {
            dealLinks.buyers[matcher].push(owner);
            dealLinks.sellers[owner].push(matcher);
        } else {
            dealLinks.buyers[owner].push(matcher);
            dealLinks.sellers[matcher].push(owner);
        }
    }

    function _deleteOffer(address cryptoAddress, Offer storage offer) internal {
        TransferHelper.safeTransfer(cryptoAddress, msg.sender, offer.collateral);
        offer.collateral = 0;
        offer.available = 0;
    }

    function withdraw(
        address cryptoAddress,
        Offer storage offer,
        bool isBuy,
        uint256 toWithdraw
    ) external {
        require(offer.collateral >= toWithdraw, "Defx: !BALANCE");
        if (offer.collateral == toWithdraw) {
            _deleteOffer(cryptoAddress, offer);
            return;
        }
        TransferHelper.safeTransfer(cryptoAddress, msg.sender, toWithdraw);
        offer.collateral = offer.collateral.sub(toWithdraw);
        if (!isBuy || offer.max == 0) {
            offer.available = offer.collateral.mul(10000).div(offer.ratio);
        }
    }

    function editOfferAvailable(
        address cryptoAddress,
        Offer storage offer,
        bool _isBuy,
        uint256 _available,
        uint256 _price,
        uint256 _min,
        uint256 _max
    ) external {
        require(offer.collateral > 0, "Defx: INVALID_OFFER");
        // delete offer if available is 0
        if (_available == 0) {
            _deleteOffer(cryptoAddress, offer);
            return;
        }

        uint256 requiredOfferCollateral = _max == 0 || !_isBuy
            ? _available.mul(offer.ratio).div(10000) // buy limited offer should have enough collateral for at least one max trade
            : _max.mul(10**14).mul(offer.ratio).div(_price);

        if (offer.collateral < requiredOfferCollateral) {
            // deposit
            TransferHelper.safeTransferFrom(cryptoAddress, msg.sender, address(this), requiredOfferCollateral.sub(offer.collateral));
            offer.collateral = requiredOfferCollateral;
        } else if ((_max == 0 || !_isBuy) && offer.collateral > requiredOfferCollateral) {
            // withdraw
            TransferHelper.safeTransfer(cryptoAddress, msg.sender, offer.collateral.sub(requiredOfferCollateral));
            offer.collateral = requiredOfferCollateral;
        }

        offer.available = _available;
        offer.price = _price;
        offer.min = _min;
        offer.max = _max;
        _renewOffer(offer, _isBuy, msg.sender);
    }

    function _renewOffer(
        Offer storage offer,
        bool _isBuy,
        address owner
    ) internal {
        offer.lastUpdatedBlock = block.number;
        emit OfferUpdated(_isBuy, owner, offer.available);
    }

    function editOfferParams(
        Offer storage offer,
        bool _isBuy,
        string[] memory _paymentMethods,
        string memory _desc
    ) external {
        require(offer.collateral > 0, "Defx: INVALID_OFFER");
        offer.paymentMethods = _paymentMethods;
        offer.desc = _desc;
        emit OfferUpdated(_isBuy, msg.sender, offer.available);
    }

    function editOfferPrice(
        Offer storage offer,
        bool _isBuy,
        uint256 _price
    ) external {
        require(offer.collateral > 0, "Defx: INVALID_OFFER");
        offer.price = _price;
        emit OfferUpdated(_isBuy, msg.sender, offer.available);
    }

    modifier onlyParticipant(address buyer, address seller) {
        require(buyer == msg.sender || seller == msg.sender, "Defx: FORBIDDEN");
        _;
    }

    function validateDeal(Deal memory deal) internal view {
        require(deal.collateral > 0, "Defx: NO_DEAL");
        require(deal.bankSentAtBlock == 0 || deal.bankSentAtBlock + EXPIRY_BLOCKS >= block.number, "Defx: DEAL_EXPIRED");
    }

    function cancelDeal(
        address factory,
        address cryptoAddress,
        Offer storage offer,
        Deal storage deal,
        address buyer,
        address seller,
        DealLinks storage dealLinks
    ) public onlyParticipant(buyer, seller) {
        validateDeal(deal);

        if (msg.sender == seller) {
            require(!deal.fiatSent, "Defx: FIAT_SENT");
            require(deal.bankSentAtBlock == 0 || deal.bankSentAtBlock + SELLER_CANCEL_AFTER_BLOCKS <= block.number, "Defx: DEAL_TIMEOUT");
        }

        // if fee
        if (msg.sender == buyer && deal.messages.length > 0) {
            uint256 cancellationFee = deal.amountCrypto.mul(CANCEL_PENALTY).div(10000);
            // sending fee to factory
            TransferHelper.safeTransferFrom(cryptoAddress, msg.sender, factory, cancellationFee);
        }

        // return available
        offer.available = offer.available.add(deal.amountCrypto);

        offer.collateral = offer.collateral.add(deal.collateral);
        TransferHelper.safeTransfer(cryptoAddress, deal.isBuyerOwner ? seller : buyer, deal.collateral);

        emit DealFinished(buyer, seller, deal.amountCrypto, deal.amountFiat, "cancelled");
        emit OfferUpdated(deal.isBuyerOwner, deal.isBuyerOwner ? buyer : seller, offer.available);
        incrementFailedDeal(factory, buyer, seller);

        _deleteDeal(deal);

        _cleanLinks(dealLinks, buyer, seller);
    }

    function confirmFiatReceived(
        address factory,
        address cryptoAddress,
        Offer storage offer,
        Deal storage deal,
        address buyer,
        DealLinks storage dealLinks
    ) public {
        require(deal.messages.length > 0, "Defx: NO_BANK_ACC");
        validateDeal(deal);

        // send crypto to buyer
        TransferHelper.safeTransfer(cryptoAddress, buyer, deal.amountCrypto);

        // send collateral back to buyer
        if (offer.max > 0 && deal.isBuyerOwner) {
            offer.collateral = offer.collateral.add(deal.collateral);
        } else {
            TransferHelper.safeTransfer(cryptoAddress, buyer, deal.collateral);
        }

        // send collateral to seller
        TransferHelper.safeTransfer(cryptoAddress, msg.sender, deal.collateral.sub(deal.amountCrypto));

        emit DealFinished(buyer, msg.sender, deal.amountCrypto, deal.amountFiat, "success");
        incrementCompletedDeal(factory, buyer, msg.sender);
        _deleteDeal(deal);

        _cleanLinks(dealLinks, buyer, msg.sender);
    }

    function incrementCompletedDeal(
        address factory,
        address buyer,
        address seller
    ) internal {
        IDefxStat _stats = IDefxStat(IDefxFactory(factory).statAddress());
        _stats.incrementCompletedDeal(buyer, seller);
        _stats.setFeedbackAllowed(buyer, seller);
    }

    function incrementFailedDeal(
        address factory,
        address buyer,
        address seller
    ) internal {
        IDefxStat _stats = IDefxStat(IDefxFactory(factory).statAddress());
        _stats.incrementFailedDeal(buyer, seller);
        _stats.setFeedbackAllowed(buyer, seller);
    }

    function submitFeedbackFrom(
        address factory,
        address buyer,
        bool isPositive,
        string calldata desc
    ) internal {
        IDefxStat(IDefxFactory(factory).statAddress()).submitFeedbackFrom(msg.sender, buyer, isPositive, desc);
    }

    function liquidateDeal(
        address factory,
        address cryptoAddress,
        Deal storage deal,
        address buyer,
        address seller,
        DealLinks storage dealLinks
    ) external {
        require(deal.bankSentAtBlock > 0 && deal.bankSentAtBlock + EXPIRY_BLOCKS < block.number, "Defx: VALID_DEAL");

        // send all collaterals to factory
        TransferHelper.safeTransfer(cryptoAddress, factory, deal.collateral.mul(2));

        emit DealFinished(buyer, seller, deal.amountCrypto, deal.amountFiat, "liquidated");
        incrementFailedDeal(factory, buyer, seller);

        _cleanLinks(dealLinks, buyer, seller);

        _deleteDeal(deal);
    }

    function _deleteDeal(Deal storage deal) internal {
        deal.collateral = 0;
        deal.amountCrypto = 0;
        deal.bankSentAtBlock = 0;
        deal.fiatSent = false;
        delete deal.messages;
    }

    function fiatSent(Deal storage deal) external {
        require(deal.collateral > 0, "Defx: INVALID_DEAL");
        require(deal.messages.length > 0, "Defx: NO_BANK_ACC");
        deal.fiatSent = true;
    }

    function sendMessage(
        Deal storage deal,
        address buyer,
        address seller,
        string memory encryptedForSeller,
        string memory encryptedForBuyer
    ) external onlyParticipant(buyer, seller) {
        validateDeal(deal);
        require(deal.messages.length > 0 || msg.sender == seller, "Defx: FIRST_MESSAGE_ONLY_SELLER");

        if (deal.messages.length == 0) {
            deal.bankSentAtBlock = block.number;
        }

        deal.messages.push(Message({encryptedForSeller: encryptedForSeller, encryptedForBuyer: encryptedForBuyer, from: msg.sender}));
    }

    function _cleanLinks(
        DealLinks storage dealLinks,
        address buyer,
        address seller
    ) internal {
        _removeLink(dealLinks.buyers[seller], buyer);
        _removeLink(dealLinks.sellers[buyer], seller);
    }

    function _removeLink(address[] storage array, address addrToDelete) internal {
        bool deleted;
        for (uint256 i = 0; i < array.length - 1; i++) {
            if (deleted) {
                array[i] = array[i + 1];
            } else if (array[i] == addrToDelete) {
                deleted = true;
            }
        }
        array.pop();
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "./DefxHelpers.sol";

contract DefxPair {
    event DealFinished(address indexed buyer, address indexed seller, uint256 amountCrypto, uint256 amountFiat, string status);

    address public factory;
    address public cryptoAddress;
    string public fiatCode;

    uint256 public EXPIRY_BLOCKS = DefxHelpers.EXPIRY_BLOCKS;

    DealLinks private dealLinks;

    mapping(address => mapping(bool => Offer)) public offers; /* owner => isBuyOffer */

    mapping(address => mapping(address => Deal)) /* buyer */ /* seller */
        public deals;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _tokenAddress, string memory _fiatCode) external {
        require(msg.sender == factory, "Defx: FORBIDDEN");
        cryptoAddress = _tokenAddress;
        fiatCode = _fiatCode;
    }

    modifier hasEncKey() {
        require(bytes(IDefxFactory(factory).encKeys(msg.sender)).length > 0, "Defx: NO_ENC_KEY");
        _;
    }

    function getBuyers(address seller) public view returns (address[] memory) {
        return dealLinks.buyers[seller];
    }

    function getSellers(address buyer) public view returns (address[] memory) {
        return dealLinks.sellers[buyer];
    }

    function createOffer(
        bool _isBuy,
        uint256 _deposit,
        uint256 _available,
        uint256 _min,
        uint256 _max,
        uint256 _price,
        uint256 _ratio,
        string[] memory _paymentMethods,
        string memory _desc
    ) external hasEncKey {
        // forbid create offer when there are active deals
        require((_isBuy ? dealLinks.sellers[msg.sender] : dealLinks.buyers[msg.sender]).length == 0, "Defx: ACTIVE_DEAL");

        DefxHelpers.createOffer(
            offers[msg.sender][_isBuy],
            CreateOfferParams({
                _cryptoAddress: cryptoAddress,
                _isBuy: _isBuy,
                _deposit: _deposit,
                _available: _available,
                _min: _min,
                _max: _max,
                _price: _price,
                _ratio: _ratio,
                _paymentMethods: _paymentMethods,
                _desc: _desc
            })
        );
    }

    function matchOffer(
        address owner,
        bool isBuy,
        uint256 amountCrypto,
        string memory paymentMethod,
        string memory encryptedForSeller,
        string memory encryptedForBuyer
    ) external hasEncKey {
        (Offer storage offer, Deal storage deal) = _getOfferDeal(owner, isBuy);
        require(owner != msg.sender, "Defx: SELF_MATCH");
        require(deal.collateral == 0, "Defx: DEAL_EXISTS");

        DefxHelpers.matchOffer(
            offer,
            deal,
            dealLinks,
            MatchParams({
                factory: factory,
                cryptoAddress: cryptoAddress,
                owner: owner,
                isBuy: isBuy,
                amountCrypto: amountCrypto,
                paymentMethod: paymentMethod
            })
        );
        if (isBuy) {
            require(bytes(encryptedForSeller).length > 0 && bytes(encryptedForBuyer).length > 0, "Defx: BANK_REQUIRED");
            deal.bankSentAtBlock = block.number;
            deal.messages.push(Message({encryptedForSeller: encryptedForSeller, encryptedForBuyer: encryptedForBuyer, from: msg.sender}));
        }
    }

    function getOffer(address owner, bool isBuy) external view returns (Offer memory) {
        return offers[owner][isBuy];
    }

    function getDeal(address buyer, address seller) external view returns (Deal memory) {
        return deals[buyer][seller];
    }

    function _getOfferDeal(address owner, bool isBuy) internal view returns (Offer storage off, Deal storage) {
        return (offers[owner][isBuy], isBuy ? deals[owner][msg.sender] : deals[msg.sender][owner]);
    }

    function sendMessage(
        address buyer,
        address seller,
        string memory encryptedForSeller,
        string memory encryptedForBuyer
    ) external {
        DefxHelpers.sendMessage(deals[buyer][seller], buyer, seller, encryptedForSeller, encryptedForBuyer);
    }

    function _getDealOfferByParticipants(address buyer, address seller) internal view returns (Deal storage deal, Offer storage offer) {
        deal = deals[buyer][seller];
        offer = deal.isBuyerOwner ? offers[buyer][true] : offers[seller][false];
    }

    function cancelDeal(address buyer, address seller) external {
        (Deal storage deal, Offer storage offer) = _getDealOfferByParticipants(buyer, seller);
        DefxHelpers.cancelDeal(factory, cryptoAddress, offer, deal, buyer, seller, dealLinks);
    }

    function confirmFiatReceived(address buyer) public {
        (Deal storage deal, Offer storage offer) = _getDealOfferByParticipants(buyer, msg.sender);
        DefxHelpers.confirmFiatReceived(factory, cryptoAddress, offer, deal, buyer, dealLinks);
    }

    function confirmFiatReceivedWithFeedback(
        address buyer,
        bool isPositive,
        string calldata desc
    ) external {
        confirmFiatReceived(buyer);
        DefxHelpers.submitFeedbackFrom(factory, buyer, isPositive, desc);
    }

    function fiatSent(address seller) external {
        DefxHelpers.fiatSent(deals[msg.sender][seller]);
    }

    function liquidateDeal(address buyer, address seller) external {
        DefxHelpers.liquidateDeal(factory, cryptoAddress, deals[buyer][seller], buyer, seller, dealLinks);
    }

    function withdraw(bool _isBuy, uint256 _toWithdraw) external {
        DefxHelpers.withdraw(cryptoAddress, offers[msg.sender][_isBuy], _isBuy, _toWithdraw);
    }

    function editOfferAvailable(
        bool _isBuy,
        uint256 _available,
        uint256 _price,
        uint256 _min,
        uint256 _max
    ) external {
        DefxHelpers.editOfferAvailable(cryptoAddress, offers[msg.sender][_isBuy], _isBuy, _available, _price, _min, _max);
    }

    function editOfferParams(
        bool _isBuy,
        string[] calldata _paymentMethods,
        string calldata _desc
    ) external {
        DefxHelpers.editOfferParams(offers[msg.sender][_isBuy], _isBuy, _paymentMethods, _desc);
    }

    function editOfferPrice(bool _isBuy, uint256 _price) public {
        DefxHelpers.editOfferPrice(offers[msg.sender][_isBuy], _isBuy, _price);
    }

    function renewOffer(bool _isBuy) public {
        DefxHelpers._renewOffer(offers[msg.sender][_isBuy], _isBuy, msg.sender);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "./DefxInterfaces.sol";

// DeFX User Statistics contract
contract DefxStat is IDefxStat {
    address public factory;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyPair() {
        require(IDefxFactory(factory).isPair(msg.sender), "DefxFactory: !PAIR");
        _;
    }

    mapping(address => UserProfile) public userProfile;
    mapping(address => mapping(address => bool)) /* from */ /* to */
        public feedbackAllowed;

    function getUserProfile(address account) public view returns (UserProfile memory) {
        return userProfile[account];
    }

    function setFeedbackAllowed(address a, address b) external onlyPair {
        feedbackAllowed[a][b] = true;
        feedbackAllowed[b][a] = true;
    }

    function _setFirstDeal(address account) internal {
        if (userProfile[account].firstDealBlock == 0) {
            userProfile[account].firstDealBlock = block.number;
        }
    }

    function _incrementCompletedDeal(address account) internal {
        userProfile[account].completedDeals++;
        _setFirstDeal(account);
    }

    function _incrementFailedDeal(address account) internal {
        userProfile[account].failedDeals++;
    }

    function incrementCompletedDeal(address a, address b) external onlyPair {
        _incrementCompletedDeal(a);
        _incrementCompletedDeal(b);
    }

    function incrementFailedDeal(address a, address b) external onlyPair {
        _incrementFailedDeal(a);
        _incrementFailedDeal(b);
    }

    function _submitFeedback(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) internal {
        userProfile[to].feedbacks.push(Feedback({isPositive: isPositive, desc: desc, from: from, blockNumber: block.number}));
        feedbackAllowed[from][to] = false;
    }

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external {
        require(feedbackAllowed[msg.sender][to], "DefxFactory: NOT_ALLOWED");
        _submitFeedback(msg.sender, to, isPositive, desc);
    }

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external onlyPair {
        _submitFeedback(from, to, isPositive, desc);
    }

    function setName(string calldata name) external {
        userProfile[msg.sender].name = name;
    }

    function setSocialAccounts(string calldata data) external {
        userProfile[msg.sender].socialAccounts = data;
    }

    function setUserProfile(string calldata name, string calldata socialAccounts) external {
        userProfile[msg.sender].name = name;
        userProfile[msg.sender].socialAccounts = socialAccounts;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

// ---------- LIBRATIES ----------

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
}

// --------- TYPES & CONSTANTS -------

uint256 constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

struct Message {
    string encryptedForSeller;
    string encryptedForBuyer;
    address from;
}

struct Deal {
    uint256 amountCrypto;
    uint256 collateral;
    uint256 amountFiat;
    bool isBuyerOwner;
    string paymentMethod;
    Message[] messages;
    bool fiatSent;
    uint256 bankSentAtBlock;
}

struct Offer {
    uint256 min;
    uint256 max;
    uint256 available;
    uint256 collateral;
    uint256 price;
    string[] paymentMethods;
    string desc;
    uint256 ratio;
    uint256 lastUpdatedBlock;
}

struct DealLinks {
    mapping(address => address[]) buyers;
    mapping(address => address[]) sellers;
}

struct CreateOfferParams {
    address _cryptoAddress;
    bool _isBuy;
    uint256 _deposit;
    uint256 _available;
    uint256 _min;
    uint256 _max;
    uint256 _price;
    uint256 _ratio;
    string[] _paymentMethods;
    string _desc;
}

struct MatchParams {
    address factory;
    address cryptoAddress;
    address owner;
    bool isBuy;
    uint256 amountCrypto;
    string paymentMethod;
}

struct UserProfile {
    string name;
    string socialAccounts;
    uint256 completedDeals;
    uint256 failedDeals;
    uint256 firstDealBlock;
    Feedback[] feedbacks;
}

struct Feedback {
    bool isPositive;
    string desc;
    address from;
    uint256 blockNumber;
}

// ---------- INTERFACES ---------

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IDefxFactory {
    event PairCreated(address cryptoAddress, string fiatAddress, address pair, uint256);

    function getPair(address tokenA, string memory fiatAddress) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function encKeys(address account) external view returns (string memory);

    function isPair(address pairAddr) external view returns (bool);

    function statAddress() external view returns (address);

    function setAllowedCoin(address _coinAddress) external;
}

interface IDefxPair {
    function initialize(address, string memory) external;
}

interface IDefxStat {
    function getUserProfile(address account) external view returns (UserProfile memory);

    function setFeedbackAllowed(address a, address b) external;

    function incrementCompletedDeal(address a, address b) external;

    function incrementFailedDeal(address a, address b) external;

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function setName(string calldata name) external;

    function setSocialAccounts(string calldata data) external;
}

interface IDefxToken {
    function decimals() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function burnAll() external;

    function burn(uint256 amount) external;
}

interface IERC20 {
    function decimals() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}