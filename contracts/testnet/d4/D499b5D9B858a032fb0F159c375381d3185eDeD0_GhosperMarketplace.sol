// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GhosperMarketplace is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    // Global
    mapping(address => bool) public isAcceptableCollection;
    mapping(uint256 => address) public acceptableCollections;
    mapping(address => uint256) public acceptableCollectionIndexes;
    uint256 public acceptableCollectionCount;

    uint256 public fee;
    address payable public treasury;

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        treasury = payable(0x2C0b73164AF92a89d30Af163912B38F45b7f7b65);
        fee = 10;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "SetTreasury: Invalid treasury");
        treasury = payable(_treasury);
    }

    function _addCollectionEnumerable(address _collection) internal {
        isAcceptableCollection[_collection] = true;
        acceptableCollections[acceptableCollectionCount] = _collection;
        acceptableCollectionIndexes[_collection] = acceptableCollectionCount;
        acceptableCollectionCount++;
    }

    function _removeCollectionEnumerable(address _collection) internal {
        isAcceptableCollection[_collection] = false;
        acceptableCollections[
            acceptableCollectionIndexes[_collection]
        ] = acceptableCollections[acceptableCollectionCount - 1];
        acceptableCollectionIndexes[
            acceptableCollections[acceptableCollectionCount - 1]
        ] = acceptableCollectionIndexes[_collection];
        acceptableCollectionCount--;
    }

    function addAcceptableCollection(address _collection) external onlyOwner {
        require(_collection != address(0), "AC: Invalid collection");
        require(
            isAcceptableCollection[_collection] != true,
            "AC: Already acceptable"
        );

        _addCollectionEnumerable(_collection);
    }

    function removeAcceptableCollection(address _collection)
        external
        onlyOwner
    {
        require(_collection != address(0), "RC: Invalid collection");
        require(
            isAcceptableCollection[_collection] != false,
            "RC: Already not acceptable"
        );

        _removeCollectionEnumerable(_collection);
    }

    // Order
    struct Order {
        bool isActive;
        address payable maker;
        address currency;
        uint256 price;
        uint256 timestamp;
    }

    struct OrderData {
        address collection;
        uint256 tokenId;
        address maker;
        address currency;
        uint256 price;
        uint256 timestamp;
    }

    mapping(address => mapping(uint256 => Order)) public orders;
    mapping(address => mapping(uint256 => uint256))
        public activeOrderTokenIdsForCollection;
    mapping(address => mapping(uint256 => uint256))
        public activeOrderTokenIndexesForCollection;
    mapping(address => uint256) public activeOrderCountForCollection;
    uint256 public activeOrderCount;

    event OrderCreated(
        address owner,
        address collection,
        uint256 tokenId,
        address currency,
        uint256 price
    );
    event OrderCanceled(address owner, address collection, uint256 tokenId);
    event OrderDone(
        address seller,
        address buyer,
        address collection,
        uint256 tokenId,
        address currency,
        uint256 price
    );
    event OrdersFrozen(uint256 activeOrderCount);

    function _addOrderEnumerable(
        address _collection,
        uint256 _tokenId,
        Order memory order
    ) internal {
        if (order.isActive == false) return;
        orders[_collection][_tokenId] = order;
        activeOrderTokenIdsForCollection[_collection][
            activeOrderCountForCollection[_collection]
        ] = _tokenId;
        activeOrderTokenIndexesForCollection[_collection][
            _tokenId
        ] = activeOrderCountForCollection[_collection];
        activeOrderCountForCollection[_collection]++;
        activeOrderCount++;
    }

    function _removeOrderEnumerable(address _collection, uint256 _tokenId)
        internal
    {
        if (orders[_collection][_tokenId].isActive == false) return;
        orders[_collection][_tokenId].isActive = false;
        activeOrderTokenIdsForCollection[_collection][
            activeOrderTokenIndexesForCollection[_collection][_tokenId]
        ] = activeOrderTokenIdsForCollection[_collection][
            activeOrderCountForCollection[_collection] - 1
        ];
        activeOrderTokenIndexesForCollection[_collection][
            activeOrderTokenIdsForCollection[_collection][
                activeOrderCountForCollection[_collection] - 1
            ]
        ] = activeOrderTokenIndexesForCollection[_collection][_tokenId];
        activeOrderCountForCollection[_collection]--;
        activeOrderCount--;
    }

    function _createOrder(
        address _collection,
        uint256 _tokenId,
        address _currency,
        uint256 _price
    ) internal nonReentrant {
        require(
            isAcceptableCollection[_collection],
            "COd: Not acceptable collection"
        );
        require(
            IERC721(_collection).ownerOf(_tokenId) == msg.sender,
            "COd: Not owned nft"
        );
        require(
            IERC721(_collection).getApproved(_tokenId) == address(this),
            "COd: Not approved nft"
        );
        require(
            orders[_collection][_tokenId].isActive == false,
            "COd: Already ordered"
        );

        IERC721(_collection).transferFrom(msg.sender, address(this), _tokenId);
        _addOrderEnumerable(
            _collection,
            _tokenId,
            Order(true, payable(msg.sender), _currency, _price, block.timestamp)
        );

        emit OrderCreated(msg.sender, _collection, _tokenId, _currency, _price);
    }

    function createOrder(
        address _collection,
        uint256 _tokenId,
        address _currency,
        uint256 _price
    ) external {
        _createOrder(_collection, _tokenId, _currency, _price);
    }

    function createOrders(
        address[] memory _collections,
        uint256[] memory _tokenIds,
        address[] memory _currencies,
        uint256[] memory _prices
    ) external {
        require(
            (_collections.length == _tokenIds.length) &&
                (_collections.length == _currencies.length) &&
                (_collections.length == _prices.length),
            "COd: Invalid params"
        );

        for (uint256 i = 0; i < _collections.length; i++)
            _createOrder(
                _collections[i],
                _tokenIds[i],
                _currencies[i],
                _prices[i]
            );
    }

    function _cancelOrder(address _collection, uint256 _tokenId)
        internal
        nonReentrant
    {
        require(orders[_collection][_tokenId].isActive, "XOd: Not ordered nft");
        require(
            orders[_collection][_tokenId].maker == msg.sender,
            "XOd: Invalid permission"
        );
        require(
            IERC721(_collection).ownerOf(_tokenId) == address(this),
            "XOd: Not reserved nft"
        );

        IERC721(_collection).transferFrom(address(this), msg.sender, _tokenId);
        _removeOrderEnumerable(_collection, _tokenId);

        emit OrderCanceled(msg.sender, _collection, _tokenId);
    }

    function cancelOrder(address _collection, uint256 _tokenId) external {
        _cancelOrder(_collection, _tokenId);
    }

    function cancelOrders(
        address[] memory _collections,
        uint256[] memory _tokenIds
    ) external {
        require(_collections.length == _tokenIds.length, "XOd: Invalid params");

        for (uint256 i = 0; i < _collections.length; i++)
            _cancelOrder(_collections[i], _tokenIds[i]);
    }

    function _buyOrder(address _collection, uint256 _tokenId)
        internal
        nonReentrant
    {
        Order memory order = orders[_collection][_tokenId];
        require(order.isActive, "BOd: Not ordered nft");
        require(
            IERC721(_collection).ownerOf(_tokenId) == address(this),
            "BOd: Not reserved nft"
        );
        require(msg.sender != order.maker, "BOd: Buying owned order");

        uint256 originPrice = (order.price * (1000 - fee)) / 1000;
        if (order.currency == address(0)) {
            require(msg.value >= order.price, "BOd: Not enough fund");

            order.maker.transfer(originPrice);
            treasury.transfer(order.price - originPrice);
            if (msg.value > order.price)
                payable(msg.sender).transfer(msg.value - order.price);
        } else {
            require(
                IERC20(order.currency).balanceOf(msg.sender) >= order.price,
                "BOd: Not enough balance"
            );
            require(
                IERC20(order.currency).allowance(msg.sender, address(this)) >=
                    order.price,
                "BOd: Not enough approval"
            );

            IERC20(order.currency).transferFrom(
                msg.sender,
                order.maker,
                originPrice
            );
            IERC20(order.currency).transferFrom(
                msg.sender,
                treasury,
                order.price - originPrice
            );
        }

        IERC721(_collection).transferFrom(address(this), msg.sender, _tokenId);
        _removeOrderEnumerable(_collection, _tokenId);

        emit OrderDone(
            order.maker,
            msg.sender,
            _collection,
            _tokenId,
            order.currency,
            order.price
        );
    }

    function buyOrder(address _collection, uint256 _tokenId) external payable {
        _buyOrder(_collection, _tokenId);
    }

    function buyOrders(
        address[] memory _collections,
        uint256[] memory _tokenIds
    ) external payable {
        require(_collections.length == _tokenIds.length, "BOd: Invalid params");
        for (uint256 i = 0; i < _collections.length; i++)
            _buyOrder(_collections[i], _tokenIds[i]);
    }

    function getActiveOrders() external view returns (OrderData[] memory) {
        OrderData[] memory activeOrders = new OrderData[](activeOrderCount);
        uint256 index = 0;
        for (uint256 i = 0; i < acceptableCollectionCount; i++) {
            address collection = acceptableCollections[i];
            for (
                uint256 j = 0;
                j < activeOrderCountForCollection[collection];
                j++
            ) {
                uint256 tokenId = activeOrderTokenIdsForCollection[collection][
                    j
                ];
                Order storage order = orders[collection][tokenId];
                if (order.isActive)
                    activeOrders[index++] = OrderData(
                        collection,
                        tokenId,
                        order.maker,
                        order.currency,
                        order.price,
                        order.timestamp
                    );
            }
        }

        return activeOrders;
    }

    function freezeAllOrders() external onlyOwner {
        uint256 activeOrderCount_ = activeOrderCount;
        for (uint256 i = 0; i < acceptableCollectionCount; i++) {
            address collection = acceptableCollections[i];
            for (
                uint256 j = 0;
                j < activeOrderCountForCollection[collection];
                j++
            ) {
                uint256 tokenId = activeOrderTokenIdsForCollection[collection][
                    j
                ];
                Order storage order = orders[collection][tokenId];
                if (order.isActive) {
                    IERC721(collection).transferFrom(
                        address(this),
                        order.maker,
                        tokenId
                    );
                    order.isActive = false;
                }
            }
            activeOrderCountForCollection[collection] = 0;
        }
        activeOrderCount = 0;

        emit OrdersFrozen(activeOrderCount_);
    }

    // Offer
    struct Offer {
        address payable maker;
        address currency;
        uint256 price;
        uint256 timestamp;
    }

    struct OffersForToken {
        uint256 activeOfferCountForToken;
        mapping(uint256 => Offer) offersForToken;
    }

    struct OfferData {
        address collection;
        uint256 tokenId;
        address[] makers;
        address[] currencies;
        uint256[] prices;
        uint256[] timestamps;
    }

    mapping(address => mapping(uint256 => OffersForToken)) public offers;
    mapping(address => mapping(uint256 => uint256))
        public activeOfferTokenIdsForCollection;
    mapping(address => mapping(uint256 => uint256))
        public activeOfferTokenIndexesForCollection;
    mapping(address => uint256) public activeOfferCountForCollection;
    uint256 public activeOfferCount;

    event OfferCreated(
        address maker,
        address collection,
        uint256 tokenId,
        address currency,
        uint256 price
    );
    event OfferCanceled(
        address maker,
        address collection,
        uint256 tokenId,
        address currency,
        uint256 price
    );
    event OfferAccepted(
        address seller,
        address buyer,
        address collection,
        uint256 tokenId,
        address currency,
        uint256 price
    );
    event OffersFrozen(uint256 activeOfferCount);

    function _addOfferEnumerable(
        address _collection,
        uint256 _tokenId,
        Offer memory offer
    ) internal {
        offers[_collection][_tokenId].offersForToken[
            offers[_collection][_tokenId].activeOfferCountForToken
        ] = offer;
        if (offers[_collection][_tokenId].activeOfferCountForToken == 0) {
            activeOfferTokenIdsForCollection[_collection][
                activeOfferCountForCollection[_collection]
            ] = _tokenId;
            activeOfferTokenIndexesForCollection[_collection][
                _tokenId
            ] = activeOfferCountForCollection[_collection];
            activeOfferCountForCollection[_collection]++;
            activeOfferCount++;
        }
        offers[_collection][_tokenId].activeOfferCountForToken++;
    }

    function _removeOfferEnumerable(
        address _collection,
        uint256 _tokenId,
        uint256 _offerIndex
    ) internal {
        OffersForToken storage offersForToken = offers[_collection][_tokenId];

        offersForToken.offersForToken[_offerIndex] = offersForToken
            .offersForToken[offersForToken.activeOfferCountForToken - 1];
        offersForToken.activeOfferCountForToken--;

        if (offersForToken.activeOfferCountForToken == 0) {
            activeOfferTokenIdsForCollection[_collection][
                activeOfferTokenIndexesForCollection[_collection][_tokenId]
            ] = activeOfferTokenIdsForCollection[_collection][
                activeOfferCountForCollection[_collection] - 1
            ];
            activeOfferTokenIndexesForCollection[_collection][
                activeOfferTokenIdsForCollection[_collection][
                    activeOfferCountForCollection[_collection] - 1
                ]
            ] = activeOfferTokenIndexesForCollection[_collection][_tokenId];
            activeOfferCountForCollection[_collection]--;
            activeOfferCount--;
        }
    }

    function _createOffer(
        address _collection,
        uint256 _tokenId,
        address _currency,
        uint256 _price
    ) internal nonReentrant {
        require(
            isAcceptableCollection[_collection],
            "COf: Not acceptable collection"
        );
        require(_price > 0, "COf: Invalid price");
        require(
            IERC721(_collection).ownerOf(_tokenId) != msg.sender,
            "COf: Offerring owned nft"
        );
        if (_currency == address(0)) {
            require(msg.value >= _price, "COf: Not enough fund");

            if (msg.value > _price)
                payable(msg.sender).transfer(msg.value - _price);
        } else {
            require(
                IERC20(_currency).balanceOf(msg.sender) >= _price,
                "COf: Not enough balance"
            );
            require(
                IERC20(_currency).allowance(msg.sender, address(this)) >=
                    _price,
                "COf: Not enough approval"
            );

            IERC20(_currency).transferFrom(msg.sender, address(this), _price);
        }

        _addOfferEnumerable(
            _collection,
            _tokenId,
            Offer(payable(msg.sender), _currency, _price, block.timestamp)
        );

        emit OfferCreated(msg.sender, _collection, _tokenId, _currency, _price);
    }

    function createOffer(
        address _collection,
        uint256 _tokenId,
        address _currency,
        uint256 _price
    ) external payable {
        _createOffer(_collection, _tokenId, _currency, _price);
    }

    function createOffers(
        address[] memory _collections,
        uint256[] memory _tokenIds,
        address[] memory _currencies,
        uint256[] memory _prices
    ) external payable {
        require(
            _collections.length == _tokenIds.length &&
                _collections.length == _currencies.length &&
                _collections.length == _prices.length,
            "COf: Invalid params"
        );

        for (uint256 i = 0; i < _collections.length; i++)
            _createOffer(
                _collections[i],
                _tokenIds[i],
                _currencies[i],
                _prices[i]
            );
    }

    function _cancelOffer(
        address _collection,
        uint256 _tokenId,
        uint256 _myOfferIndex
    ) internal nonReentrant {
        OffersForToken storage offersForToken = offers[_collection][_tokenId];
        require(
            isAcceptableCollection[_collection],
            "XOf: Not acceptable collection"
        );
        require(
            offersForToken.activeOfferCountForToken > _myOfferIndex,
            "XOf: Not offered index"
        );

        uint256 _offerIndex = 0;
        if (IERC721(_collection).ownerOf(_tokenId) == msg.sender) {
            _offerIndex = _myOfferIndex;
        } else {
            for (
                _offerIndex = 0;
                _offerIndex < offersForToken.activeOfferCountForToken;
                _offerIndex++
            )
                if (
                    offersForToken.offersForToken[_offerIndex].maker ==
                    msg.sender
                ) {
                    if (_myOfferIndex == 0) break;
                    _myOfferIndex--;
                }

            require(
                offersForToken.activeOfferCountForToken > _offerIndex,
                "XOf: Not offered index"
            );
            require(
                offersForToken.offersForToken[_offerIndex].maker == msg.sender,
                "XOf: Invalid permission"
            );
        }

        Offer memory offer = offersForToken.offersForToken[_offerIndex];
        if (offer.currency == address(0)) offer.maker.transfer(offer.price);
        else IERC20(offer.currency).transfer(offer.maker, offer.price);

        _removeOfferEnumerable(_collection, _tokenId, _offerIndex);

        emit OfferCanceled(
            msg.sender,
            _collection,
            _tokenId,
            offer.currency,
            offer.price
        );
    }

    function cancelOffer(
        address _collection,
        uint256 _tokenId,
        uint256 _myOfferIndex
    ) external {
        _cancelOffer(_collection, _tokenId, _myOfferIndex);
    }

    function cancelOffers(
        address[] memory _collections,
        uint256[] memory _tokenIds,
        uint256[] memory _myOfferIndexes
    ) external {
        require(
            _collections.length == _tokenIds.length &&
                _collections.length == _myOfferIndexes.length,
            "XOf: Invalid params"
        );

        for (uint256 i = 0; i < _collections.length; i++)
            _cancelOffer(_collections[i], _tokenIds[i], _myOfferIndexes[i]);
    }

    function _acceptOffer(
        address _collection,
        uint256 _tokenId,
        uint256 _offerIndex
    ) internal nonReentrant {
        require(
            isAcceptableCollection[_collection],
            "AOf: Not acceptable collection"
        );
        require(
            IERC721(_collection).ownerOf(_tokenId) == msg.sender ||
                (IERC721(_collection).ownerOf(_tokenId) == address(this) &&
                    orders[_collection][_tokenId].isActive),
            "AOf: Invalid permission"
        );
        require(
            IERC721(_collection).getApproved(_tokenId) == address(this),
            "AOf: Not approved nft"
        );
        require(
            offers[_collection][_tokenId].activeOfferCountForToken >
                _offerIndex,
            "AOf: Not offered index"
        );

        Offer memory offer = offers[_collection][_tokenId].offersForToken[
            _offerIndex
        ];

        uint256 originPrice = (offer.price * (1000 - fee)) / 1000;
        if (offer.currency == address(0)) {
            payable(msg.sender).transfer(originPrice);
            treasury.transfer(offer.price - originPrice);
        } else {
            IERC20(offer.currency).transfer(offer.maker, originPrice);
            IERC20(offer.currency).transfer(
                treasury,
                offer.price - originPrice
            );
        }

        if (orders[_collection][_tokenId].isActive == true) {
            IERC721(_collection).transferFrom(
                address(this),
                offer.maker,
                _tokenId
            );
            _removeOrderEnumerable(_collection, _tokenId);
        } else
            IERC721(_collection).transferFrom(
                msg.sender,
                offer.maker,
                _tokenId
            );

        _removeOfferEnumerable(_collection, _tokenId, _offerIndex);

        emit OfferAccepted(
            msg.sender,
            offer.maker,
            _collection,
            _tokenId,
            offer.currency,
            offer.price
        );
    }

    function acceptOffer(
        address _collection,
        uint256 _tokenId,
        uint256 _offerIndex
    ) external {
        _acceptOffer(_collection, _tokenId, _offerIndex);
    }

    function getActiveOffers() external view returns (OfferData[] memory) {
        OfferData[] memory activeOffers = new OfferData[](activeOfferCount);
        uint256 index = 0;
        for (uint256 i = 0; i < acceptableCollectionCount; i++) {
            address collection = acceptableCollections[i];
            for (
                uint256 j = 0;
                j < activeOfferCountForCollection[collection];
                j++
            ) {
                uint256 tokenId = activeOfferTokenIdsForCollection[collection][
                    j
                ];
                OffersForToken storage offersForToken = offers[collection][
                    tokenId
                ];
                OfferData memory offerData = OfferData(
                    collection,
                    tokenId,
                    new address[](offersForToken.activeOfferCountForToken),
                    new address[](offersForToken.activeOfferCountForToken),
                    new uint256[](offersForToken.activeOfferCountForToken),
                    new uint256[](offersForToken.activeOfferCountForToken)
                );
                for (
                    uint256 g = 0;
                    g < offersForToken.activeOfferCountForToken;
                    g++
                ) {
                    offerData.makers[g] = offersForToken
                        .offersForToken[g]
                        .maker;
                    offerData.currencies[g] = offersForToken
                        .offersForToken[g]
                        .currency;
                    offerData.prices[g] = offersForToken
                        .offersForToken[g]
                        .price;
                    offerData.timestamps[g] = offersForToken
                        .offersForToken[g]
                        .timestamp;
                }
                activeOffers[index++] = offerData;
            }
        }

        return activeOffers;
    }

    function getActiveOffer(address _collection, uint256 _tokenId)
        external
        view
        returns (OfferData memory offerData)
    {
        require(
            isAcceptableCollection[_collection],
            "GOf: Not acceptable collection"
        );

        OffersForToken storage offersForToken = offers[_collection][_tokenId];
        offerData = OfferData(
            _collection,
            _tokenId,
            new address[](offersForToken.activeOfferCountForToken),
            new address[](offersForToken.activeOfferCountForToken),
            new uint256[](offersForToken.activeOfferCountForToken),
            new uint256[](offersForToken.activeOfferCountForToken)
        );
        for (uint256 g = 0; g < offersForToken.activeOfferCountForToken; g++) {
            offerData.makers[g] = offersForToken.offersForToken[g].maker;
            offerData.currencies[g] = offersForToken.offersForToken[g].currency;
            offerData.prices[g] = offersForToken.offersForToken[g].price;
            offerData.timestamps[g] = offersForToken
                .offersForToken[g]
                .timestamp;
        }
    }

    function freezeAllOffers() external onlyOwner {
        uint256 activeOfferCount_ = activeOfferCount;
        for (uint256 i = 0; i < acceptableCollectionCount; i++) {
            address collection = acceptableCollections[i];
            for (
                uint256 j = 0;
                j < activeOfferCountForCollection[collection];
                j++
            ) {
                uint256 tokenId = activeOfferTokenIdsForCollection[collection][
                    j
                ];
                OffersForToken storage offersForToken = offers[collection][
                    tokenId
                ];
                for (
                    uint256 g = 0;
                    g < offersForToken.activeOfferCountForToken;
                    g++
                ) {
                    Offer storage offer = offersForToken.offersForToken[g];
                    if (offer.currency == address(0))
                        payable(offer.maker).transfer(offer.price);
                    else
                        IERC20(offer.currency).transfer(
                            offer.maker,
                            offer.price
                        );
                }
                offersForToken.activeOfferCountForToken = 0;
            }
            activeOfferCountForCollection[collection] = 0;
        }
        activeOfferCount = 0;

        emit OffersFrozen(activeOfferCount_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
    function getApproved(uint256 tokenId) external view returns (address operator);

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
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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