// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./OwnersUpgradeable.sol";
import "./SpringNode.sol";
import "./libraries/NodeRewards.sol";
import "./HandlerAwareUpgradeable.sol";
import "./ISpringNode.sol";
import "./ISpringPlot.sol";

struct PlotTypeSpec {
    uint256 price;
    uint256 maxNodes;
    string[] allowedNodeTypes;
    uint256 additionalGRPTime;
    uint256 waterpackGRPBoost;
}

struct PlotInstance {
    uint256[] nodeTokenIds;
    mapping(uint256 => uint256) nodeTokenIdsToIndexPlusOne;
}

/// @notice A plot houses trees (nodes) and adds additional lifetime to the
contract SpringPlot is
    ERC721EnumerableUpgradeable,
    OwnersUpgradeable,
    ISpringPlot,
    HandlerAwareUpgradeable
{
    using Counters for Counters.Counter;
    using Percentages for uint256;

    ISpringNode private _springNode;

    /// @dev Incremented at construction time, so the first plot is 1. Therefore
    /// we can use 0 as a null value, useful for mappings.
    Counters.Counter private _tokenIdCounter;

    struct PlotTypes {
        string[] names;
        mapping(string => PlotTypeSpec) types;
        mapping(string => bool) exists;
    }

    PlotTypes internal _plotTypes;

    /// @dev As the plot token IDs starts at 1, we can use 0 as a null value.
    /// We can also consider that any node mapped to a null value means that
    /// the node doesn't exist.
    mapping(uint256 => uint256) public nodeTokenIdToPlotTokenId;

    mapping(uint256 => PlotInstance) internal _instances;
    mapping(uint256 => string) public tokenIdToType;

    mapping(address => mapping(string => uint256))
        internal _userToPlotTypeToTokenId;

    string internal _defaultPlotTypeName;

    function initialize(
        IHandler _handler,
        ISpringNode springNode,
        string memory defaultPlotTypeName,
        uint256 defaultMaxNodes
    ) external initializer {
        __SpringLuckyBox_init(
            _handler,
            springNode,
            defaultPlotTypeName,
            defaultMaxNodes
        );
    }

    function __SpringLuckyBox_init(
        IHandler _handler,
        ISpringNode springNode,
        string memory defaultPlotTypeName,
        uint256 defaultMaxNodes
    ) internal onlyInitializing {
        __HandlerAware_init_unchained(_handler);
        __Owners_init_unchained();
        __ERC721_init_unchained("Spring Plot", "SP");
        __SpringLuckyBox_init_unchained(
            springNode,
            defaultPlotTypeName,
            defaultMaxNodes
        );
    }

    function __SpringLuckyBox_init_unchained(
        ISpringNode springNode,
        string memory defaultPlotTypeName,
        uint256 defaultMaxNodes
    ) internal onlyInitializing {
        _springNode = springNode;
        _tokenIdCounter.increment();
        _defaultPlotTypeName = defaultPlotTypeName;
        _setPlotType(
            defaultPlotTypeName,
            PlotTypeSpec({
                price: 0,
                maxNodes: defaultMaxNodes,
                allowedNodeTypes: new string[](0),
                additionalGRPTime: 0,
                waterpackGRPBoost: 0
            })
        );
    }

    function createNewPlot(address user, string memory plotTypeName)
        public
        onlyHandler
        returns (uint256, uint256)
    {
        require(user != address(0), "SpringPlot: Null address");
        (uint256 tokenId, PlotTypeSpec storage plotType) = _createNewPlot(
            user,
            plotTypeName
        );
        uint256 price = plotType.price;
        return (price, tokenId);
    }

    function moveNodeToPlot(
        address user,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) public onlyHandler {
        if (plotTokenId == 0) {
            plotTokenId = findOrCreateDefaultPlot(user);
        }

        _moveNodeToPlot(user, nodeTokenId, plotTokenId);
        require(
            _hasPlotValidCapacity(plotTokenId),
            "SpringPlot: Plot reached max capacity"
        );
    }

    function moveNodesToPlots(
        address user,
        uint256[][] memory nodeTokenIds,
        uint256[] memory plotTokenIds
    ) public onlyHandler {
        require(
            nodeTokenIds.length == plotTokenIds.length,
            "SpringPlot: nodeTokenIds and plotTokenIds must have the same length"
        );

        for (uint256 i = 0; i < plotTokenIds.length; i++) {
            if (plotTokenIds[i] == 0) {
                plotTokenIds[i] = findOrCreateDefaultPlot(user);
            }

            for (uint256 j = 0; j < nodeTokenIds[i].length; j++) {
                _moveNodeToPlot(user, nodeTokenIds[i][j], plotTokenIds[i]);
            }
        }
        for (uint256 i = 0; i < plotTokenIds.length; i++) {
            require(
                _hasPlotValidCapacity(plotTokenIds[i]),
                "SpringPlot: Plot reached max capacity"
            );
        }
    }

    function findOrCreateDefaultPlot(address user)
        public
        onlyHandler
        returns (uint256)
    {
        require(user != address(0), "SpringPlot: Null address");
        uint256 defaultPlotTokenId = _userToPlotTypeToTokenId[user][
            _defaultPlotTypeName
        ];
        if (
            defaultPlotTokenId == 0 ||
            _hasPlotReachedMaxCapacity(defaultPlotTokenId)
        ) {
            (uint256 totalPrice, uint256 tokenId) = createNewPlot(
                user,
                _defaultPlotTypeName
            );
            assert(totalPrice == 0);
            return tokenId;
        }

        return defaultPlotTokenId;
    }

    function setPlotType(
        string memory plotTypeName,
        uint256 price,
        uint256 maxNodes,
        string[] memory allowedNodeTypes,
        uint256 additionalGRPTime,
        uint256 waterpackGRPBoost
    ) external onlyHandler {
        _setPlotType(
            plotTypeName,
            PlotTypeSpec({
                price: price,
                maxNodes: maxNodes,
                allowedNodeTypes: allowedNodeTypes,
                additionalGRPTime: additionalGRPTime,
                waterpackGRPBoost: waterpackGRPBoost
            })
        );
    }

    //====== View API ========================================================//

    function tokensOfOwner(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](balanceOf(user));
        for (uint256 i = 0; i < balanceOf(user); i++)
            result[i] = tokenOfOwnerByIndex(user, i);
        return result;
    }

    function getPlotTypeSize() public view returns (uint256) {
        return _plotTypes.names.length;
    }

    function getPlotTypeBetweenIndexes(uint256 startIndex, uint256 endIndex)
        public
        view
        returns (PlotTypeView[] memory)
    {
        require(
            startIndex <= endIndex,
            "SpringPlot: startIndex must be less than or equal to endIndex"
        );
        require(
            endIndex <= _plotTypes.names.length,
            "SpringPlot: endIndex must be less than or equal to the number of plot types"
        );

        PlotTypeView[] memory plotTypes = new PlotTypeView[](
            endIndex - startIndex
        );
        for (uint256 i = startIndex; i < endIndex; i++) {
            string memory plotTypeName = _plotTypes.names[i];
            PlotTypeSpec memory plotTypeSpec = _getPlotType(plotTypeName);
            plotTypes[i - startIndex] = PlotTypeView({
                name: plotTypeName,
                price: plotTypeSpec.price,
                maxNodes: plotTypeSpec.maxNodes,
                allowedNodeTypes: plotTypeSpec.allowedNodeTypes,
                additionalGRPTime: plotTypeSpec.additionalGRPTime,
                waterpackGRPBoost: plotTypeSpec.waterpackGRPBoost
            });
        }

        return plotTypes;
    }

    function getPlotTypeByTokenId(uint256 tokenId)
        public
        view
        returns (PlotTypeView memory)
    {
        require(_exists(tokenId), "SpringPlot: nonexistant token ID");
        string memory plotTypeName = tokenIdToType[tokenId];
        PlotTypeSpec memory plotTypeSpec = _getPlotType(plotTypeName);

        return
            PlotTypeView({
                name: plotTypeName,
                price: plotTypeSpec.price,
                maxNodes: plotTypeSpec.maxNodes,
                allowedNodeTypes: plotTypeSpec.allowedNodeTypes,
                additionalGRPTime: plotTypeSpec.additionalGRPTime,
                waterpackGRPBoost: plotTypeSpec.waterpackGRPBoost
            });
    }

    function getPlotByTokenId(uint256 tokenId)
        public
        view
        returns (PlotInstanceView memory)
    {
        require(_exists(tokenId), "SpringPlot: nonexistant token ID");
        PlotInstance storage plot = _instances[tokenId];
        return
            PlotInstanceView({
                plotType: tokenIdToType[tokenId],
                owner: ownerOf(tokenId),
                nodeTokenIds: plot.nodeTokenIds
            });
    }

    function getPlotTypeByNodeTokenId(uint256 nodeTokenId)
        public
        view
        returns (PlotTypeView memory)
    {
        require(
            _nodeTokenIdExists(nodeTokenId),
            "SpringPlot: nonexistant node token ID"
        );
        uint256 plotTokenId = nodeTokenIdToPlotTokenId[nodeTokenId];
        return getPlotTypeByTokenId(plotTokenId);
    }

    //====== Internal API ====================================================//

    function _setPlotType(string memory name, PlotTypeSpec memory spec)
        internal
    {
        // If this check is installed again, update the tests accordingly in
        // plots.ts, as the "should allow only one plot type per user" check
        // is based on the ability to update a plot type.
        // require(!_plotTypes.exists[name], "SpringPlot: type already exists");
        _plotTypes.types[name] = spec;
        _plotTypes.names.push(name);
        _plotTypes.exists[name] = true;
    }

    function _safeGetPlotType(string memory name)
        internal
        view
        returns (bool exists, PlotTypeSpec storage spec)
    {
        exists = _plotTypes.exists[name];
        spec = _plotTypes.types[name];
    }

    function _getPlotType(string memory name)
        internal
        view
        returns (PlotTypeSpec storage)
    {
        require(_plotTypes.exists[name], "SpringPlot: nonexistant plot type");
        return _plotTypes.types[name];
    }

    function _moveNodeToPlot(
        address user,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) internal {
        require(
            _nodeTokenIdExists(nodeTokenId),
            "SpringPlot: Node does not exist"
        );
        require(_exists(plotTokenId), "SpringPlot: nonexistant token ID");
        require(ownerOf(plotTokenId) == user, "SpringPlot: Not owner");
        require(
            _springNode.ownerOf(nodeTokenId) == user,
            "SpringPlot: Not owner"
        );

        PlotTypeSpec storage plotType = _getPlotType(
            tokenIdToType[plotTokenId]
        );
        string memory nodeType = _springNode.tokenIdsToType(nodeTokenId);
        bool hasAllowedType = plotType.allowedNodeTypes.length == 0;
        for (uint256 i = 0; i < plotType.allowedNodeTypes.length; i++) {
            string memory currentAllowedType = plotType.allowedNodeTypes[i];
            if (_compareStrings(currentAllowedType, nodeType)) {
                hasAllowedType = true;
                break;
            }
        }

        require(hasAllowedType, "SpringPlot: Node type not allowed");

        (
            uint256 oldPlotTokenId,
            PlotInstance storage oldPlot
        ) = _safeGetPlotFromNodeTokenId(nodeTokenId);

        if (oldPlotTokenId != 0) {
            uint256 indexPlusOne = oldPlot.nodeTokenIdsToIndexPlusOne[
                nodeTokenId
            ];
            if (indexPlusOne != 0) {
                uint256 lastIndex = oldPlot.nodeTokenIds.length - 1;
                if (lastIndex != indexPlusOne - 1) {
                    uint256 movedTokenId = oldPlot.nodeTokenIds[lastIndex];
                    oldPlot.nodeTokenIds[indexPlusOne - 1] = movedTokenId;
                    oldPlot.nodeTokenIdsToIndexPlusOne[
                        movedTokenId
                    ] = indexPlusOne;
                }

                oldPlot.nodeTokenIds.pop();
                oldPlot.nodeTokenIdsToIndexPlusOne[nodeTokenId] = 0;
            }
        }

        PlotInstance storage newPlot = _instances[plotTokenId];
        if (newPlot.nodeTokenIdsToIndexPlusOne[nodeTokenId] == 0) {
            newPlot.nodeTokenIds.push(nodeTokenId);
            newPlot.nodeTokenIdsToIndexPlusOne[nodeTokenId] = newPlot
                .nodeTokenIds
                .length;
            nodeTokenIdToPlotTokenId[nodeTokenId] = plotTokenId;
        }
    }

    function _nodeTokenIdExists(uint256 nodeTokenId)
        internal
        view
        returns (bool)
    {
        return bytes(_getNodeTypeFromTokenId(nodeTokenId)).length != 0;
    }

    function _getNodeTypeFromTokenId(uint256 nodeTokenId)
        internal
        view
        returns (string memory)
    {
        return _springNode.tokenIdsToType(nodeTokenId);
    }

    function _safeGetPlotFromNodeTokenId(uint256 nodeTokenId)
        internal
        view
        returns (uint256 plotTokenId, PlotInstance storage plot)
    {
        plotTokenId = nodeTokenIdToPlotTokenId[nodeTokenId];
        plot = _instances[plotTokenId];
    }

    function _createNewPlot(address owner, string memory plotTypeName)
        internal
        returns (uint256 tokenId, PlotTypeSpec storage plotType)
    {
        bool plotTypeExists;
        (plotTypeExists, plotType) = _safeGetPlotType(plotTypeName);
        require(plotTypeExists, "SpringPlot: nonexistant plot type");

        tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(owner, tokenId);
        tokenIdToType[tokenId] = plotTypeName;
        _userToPlotTypeToTokenId[owner][plotTypeName] = tokenId;
    }

    function _hasPlotReachedMaxCapacity(uint256 plotTokenId)
        internal
        view
        returns (bool)
    {
        require(_exists(plotTokenId), "SpringPlot: nonexistant token ID");
        PlotInstance storage plot = _instances[plotTokenId];
        PlotTypeSpec storage plotType = _plotTypes.types[
            tokenIdToType[plotTokenId]
        ];
        return plot.nodeTokenIds.length >= plotType.maxNodes;
    }

    function _hasPlotValidCapacity(uint256 plotTokenId)
        internal
        view
        returns (bool)
    {
        require(_exists(plotTokenId), "SpringPlot: nonexistant token ID");
        PlotInstance storage plot = _instances[plotTokenId];
        PlotTypeSpec storage plotType = _plotTypes.types[
            tokenIdToType[plotTokenId]
        ];
        return plot.nodeTokenIds.length <= plotType.maxNodes;
    }

    function _compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        IHandler(_handler).plotTransferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract OwnersUpgradeable is Initializable {
    address[] public owners;
    mapping(address => bool) public isOwner;

    function __Owners_init() internal onlyInitializing {
        __Owners_init();
    }

    function __Owners_init_unchained() internal onlyInitializing {
        owners.push(msg.sender);
        isOwner[msg.sender] = true;
    }

    modifier onlySuperOwner() {
        require(owners[0] == msg.sender, "Owners: Only Super Owner");
        _;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "Owners: Only Owner");
        _;
    }

    function addOwner(address _new, bool _change) external onlySuperOwner {
        require(!isOwner[_new], "Owners: Already owner");
        isOwner[_new] = true;
        if (_change) {
            owners.push(owners[0]);
            owners[0] = _new;
        } else {
            owners.push(_new);
        }
    }

    function removeOwner(address _new) external onlySuperOwner {
        require(isOwner[_new], "Owners: Not owner");
        require(_new != owners[0], "Owners: Cannot remove super owner");
        for (uint256 i = 1; i < owners.length; i++) {
            if (owners[i] == _new) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
        isOwner[_new] = false;
    }

    function getOwnersSize() external view returns (uint256) {
        return owners.length;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IHandler.sol";
import "./OwnersUpgradeable.sol";

contract SpringNode is ERC721EnumerableUpgradeable, OwnersUpgradeable {
    using Counters for Counters.Counter;

    address public handler;
    mapping(uint256 => string) public tokenIdsToType;

    Counters.Counter private _tokenIdCounter;
    string private uriBase;

    mapping(address => bool) public isBlacklisted;

    bool public openCreateNft;

    address[] public nodeOwners;
    mapping(address => bool) public nodeOwnersInserted;

    function initialize(string memory uri, address _handler)
        external
        initializer
    {
        __SpringNode_init(uri, _handler);
    }

    function __SpringNode_init(string memory uri, address _handler)
        internal
        onlyInitializing
    {
        __Owners_init_unchained();
        __ERC721_init_unchained("Spring Node", "SN");
        __SpringNode_init_unchained(uri, _handler);
    }

    function __SpringNode_init_unchained(string memory uri, address _handler)
        internal
        onlyInitializing
    {
        uriBase = uri;
        handler = _handler;
        openCreateNft = false;
    }

    modifier onlyHandler() {
        require(msg.sender == handler, "SpringNode: God mode not activated");
        _;
    }

    // external
    function burnBatch(address user, uint256[] memory tokenIds)
        external
        onlyHandler
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(ownerOf(tokenIds[i]) == user, "SpringNode: Not nft owner");
            super._burn(tokenIds[i]);
        }
    }

    function generateNfts(
        string memory name,
        address user,
        uint256 count
    ) external onlyHandler returns (uint256[] memory) {
        require(!isBlacklisted[user], "SpringNode: Blacklisted address");
        require(openCreateNft, "SpringNode: Not open");

        if (nodeOwnersInserted[user] == false) {
            nodeOwners.push(user);
            nodeOwnersInserted[user] = true;
        }

        uint256[] memory tokenIds = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            tokenIds[i] = tokenId;
            tokenIdsToType[tokenId] = name;
            _safeMint(user, tokenId);
            _tokenIdCounter.increment();
        }

        return tokenIds;
    }

    // external setters
    function setTokenIdToType(uint256 tokenId, string memory nodeType)
        external
        onlyHandler
    {
        tokenIdsToType[tokenId] = nodeType;
    }

    function setBaseURI(string memory _new) external onlyOwners {
        uriBase = _new;
    }

    function setHandler(address _new) external onlyOwners {
        handler = _new;
    }

    function setIsBlacklisted(address _new, bool _value) external onlyOwners {
        isBlacklisted[_new] = _value;
    }

    function setOpenCreateNft(bool _new) external onlyOwners {
        openCreateNft = _new;
    }

    // external view
    function baseURI() external view returns (string memory) {
        return _baseURI();
    }

    function tokensOfOwner(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](balanceOf(user));
        for (uint256 i = 0; i < balanceOf(user); i++)
            result[i] = tokenOfOwnerByIndex(user, i);
        return result;
    }

    function tokensOfOwnerByIndexesBetween(
        address user,
        uint256 iStart,
        uint256 iEnd
    ) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            result[i - iStart] = tokenOfOwnerByIndex(user, i);
        return result;
    }

    function getNodeOwnersSize() external view returns (uint256) {
        return nodeOwners.length;
    }

    function getNodeOwnersBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (address[] memory)
    {
        address[] memory no = new address[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++) no[i - iStart] = nodeOwners[i];
        return no;
    }

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return IHandler(handler).getAttribute(tokenId);
    }

    // public

    // internal
    function _baseURI() internal view override returns (string memory) {
        return uriBase;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(
            !isBlacklisted[from] && !isBlacklisted[to],
            "SpringNode: Blacklisted address"
        );

        if (nodeOwnersInserted[to] == false) {
            nodeOwners.push(to);
            nodeOwnersInserted[to] = true;
        }

        super._transfer(from, to, tokenId);
        IHandler(handler).nodeTransferFrom(from, to, tokenId);
    }

    // ERC721 && ERC721Enumerable required overriding
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./RewardProfile.sol";
import "./Percentage.sol";
import "./Math.sol";

struct Node {
    //--- Base attributes
    address owner;
    uint256 creationTime;
    uint256 lastClaimTime;
    uint256 obtainingTime;
    string feature;
    //--- Reward computation related
    uint256 accumulatedRewards;
    uint256 lastRewardUpdateTime;
    uint256 lastLifetime;
    uint256[] fertilizerCreationTime;
    uint256[] fertilizerDuration;
    uint256[] fertilizerBoost;
    uint256 plotAdditionalLifetime;
}

abstract contract NodeRewards {
    using Percentages for uint256;

    function _price() internal view virtual returns (uint256);

    function _baseRewardsPerSecond() internal view virtual returns (uint256);

    function _timeToGRP() internal view returns (uint256) {
        return _price() / _baseRewardsPerSecond();
    }

    function _initialLifetime() internal view returns (uint256) {
        // 2,5x GRP : 1 + 0,5 GRP at 100%, 1 GRP at 50%
        return (5 * _timeToGRP()) / 2;
    }

    function _newNode() internal view returns (Node memory) {
        return
            Node({
                owner: address(0),
                creationTime: block.timestamp,
                lastClaimTime: block.timestamp,
                obtainingTime: block.timestamp,
                feature: "",
                accumulatedRewards: 0,
                lastRewardUpdateTime: block.timestamp,
                lastLifetime: _initialLifetime(),
                fertilizerCreationTime: new uint256[](0),
                fertilizerDuration: new uint256[](0),
                fertilizerBoost: new uint256[](0),
                plotAdditionalLifetime: 0
            });
    }

    function _persistRewards(Node storage node) internal {
        node.accumulatedRewards +=
            _calculateBaseNodeRewards(node) -
            node.accumulatedRewards;
        node.lastLifetime = Math.subOrZero(
            node.lastLifetime,
            Math.subOrZero(block.timestamp, node.lastRewardUpdateTime)
        );
        node.lastRewardUpdateTime = block.timestamp;

        for (uint256 i = 0; i < node.fertilizerBoost.length; i++) {
            if (
                block.timestamp >
                (node.fertilizerCreationTime[i] + node.fertilizerDuration[i])
            ) {
                node.fertilizerBoost[i] = node.fertilizerBoost[
                    node.fertilizerBoost.length - 1
                ];
                node.fertilizerBoost.pop();

                node.fertilizerCreationTime[i] = node.fertilizerCreationTime[
                    node.fertilizerCreationTime.length - 1
                ];
                node.fertilizerCreationTime.pop();

                node.fertilizerDuration[i] = node.fertilizerDuration[
                    node.fertilizerDuration.length - 1
                ];
                node.fertilizerDuration.pop();
            }
        }
    }

    function _extendLifetime(
        Node storage node,
        uint256 ratioOfGRPExtended,
        uint256 amount
    ) internal {
        _persistRewards(node);
        node.lastLifetime += Percentages.times(ratioOfGRPExtended, _timeToGRP()) * amount;
    }

    function _addFertilizer(
        Node storage node,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256 amount
    ) internal {
        _persistRewards(node);
        for (uint256 i = 0; i < amount; i++) {
            node.fertilizerCreationTime.push(block.timestamp);
            node.fertilizerDuration.push(durationEffect);
            node.fertilizerBoost.push(rewardBoost);
        }
    }

    function _calculateBaseNodeRewards(Node storage node)
        internal
        view
        returns (uint256)
    {
        uint256 baseRewards = GRPDependantRewardProfile
            .integrateRewardsFromLifetime(
                _price(),
                _baseRewardsPerSecond(),
                node.lastLifetime + node.plotAdditionalLifetime,
                Math.subOrZero(block.timestamp, node.lastRewardUpdateTime)
            );

        for (uint256 i = 0; i < node.fertilizerBoost.length; i++) {
            // Each fertilizer has a duration effect that is not dependant
            // on the lifetime of the node. However, the rewards might have
            // been accumulated from a previous operation. Therefore, we
            // need to remove the accumulated rewards from the fertilizer
            // boost calculation, hence computing the rewards from
            // now until the known end time of the fertilizer.
            uint256 fertilizerBoost = GRPDependantRewardProfile
                .integrateFertilizerAdditionalRewards(
                    _baseRewardsPerSecond(),
                    node.fertilizerBoost[i],
                    Math.subOrZero(
                        node.fertilizerDuration[i] +
                            node.fertilizerCreationTime[i],
                        node.lastRewardUpdateTime
                    ),
                    Math.subOrZero(block.timestamp, node.lastRewardUpdateTime)
                );

            baseRewards += fertilizerBoost;
        }

        return baseRewards + node.accumulatedRewards;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IHandler.sol";

abstract contract HandlerAwareUpgradeable is Initializable {
    IHandler internal _handler;
    modifier onlyHandler() {
        require(msg.sender == address(_handler));
        _;
    }

    function __HandlerAware_init(IHandler handler) internal onlyInitializing {
        __HandlerAware_init_unchained(handler);
    }

    function __HandlerAware_init_unchained(IHandler handler) internal onlyInitializing {
        _handler = handler;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ISpringNode is IERC721Enumerable {
	function generateNfts(
		string memory name,
		address user,
		uint count
	)
		external
		returns(uint[] memory);
	
	function burnBatch(address user, uint[] memory tokenIds) external;

	function setTokenIdToNodeType(uint tokenId, string memory nodeType) external;

	function tokenIdsToType(uint256 tokenId) external view returns (string memory nodeType);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

struct PlotTypeView {
    string name;
    uint256 maxNodes;
    uint256 price;
    string[] allowedNodeTypes;
    uint256 additionalGRPTime;
    uint256 waterpackGRPBoost;
}

struct PlotInstanceView {
    string plotType;
    address owner;
    uint256[] nodeTokenIds;
}

/// @notice A plot houses trees (nodes) and adds additional lifetime to the
/// nodes it owns.
/// @dev Token IDs should start at `1`, so we can use `0` as a null value.
interface ISpringPlot is IERC721EnumerableUpgradeable {
    function createNewPlot(address user, string memory plotTypeName)
        external
        returns (uint256 price, uint256 tokenId);

    function moveNodeToPlot(
        address user,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) external;

    function moveNodesToPlots(
        address user,
        uint256[][] memory nodeTokenId,
        uint256[] memory plotTokenId
    ) external;

    function setPlotType(
        string memory name,
        uint256 price,
        uint256 maxNodes,
        string[] memory allowedNodeTypes,
        uint256 additionalGRPTime,
        uint256 waterpackGRPBoost
    ) external;

    /// @dev Returns the plot type of an instanciated plot, given its `tokenId`.
    /// Reverts if the plot doesn't exist.
    function getPlotTypeByTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    function findOrCreateDefaultPlot(address user)
        external
        returns (uint256 tokenId);

    function getPlotTypeByNodeTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    // /// @dev Returns the total amount of plot types.
    // function getPlotTypeSize() external view returns (uint256 plotTypeAmount);

    // /// @dev Returns the plot type at a given `index`. Use along with
    // /// {getPlotTypeSize} to enumerate all plot types, or {getPlotTypes}.
    // function getPlotTypeByIndex(uint256 index) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the plot type with a given `name`. Reverts if the plot type
    // /// doesn't exist.
    // function getPlotTypeByName(string memory name) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the list of all enumerable plot types.
    // function getPlotTypes() external view returns (PlotTypeView[] memory);

    // /// @dev Returns the number of plots detained by a given user.
    // function getPlotsOfUserSize(address user) external view
    //     returns (uint256 plotAmount);

    /// @dev Returns the plot instance of a given token id. Reverts if the plot
    /// doesn't exist.
    function getPlotByTokenId(uint256 tokenId)
        external
        view
        returns (PlotInstanceView memory);

    // /// @dev Returns the plot instance of a given user at a given `index`. Use
    // /// along with {getPlotsOfUserSize} to enumerate all plots of a user, or
    // /// {getPlotsOfUser}.
    // function getPlotsOfUserByIndex(address user, uint256 index) external view
    //     returns (PlotTypeInstance memory);

    // /// @dev Returns the list of all plots of a given user.
    // function getPlotsOfUser(address user) external view
    //     returns (PlotTypeInstance[] memory);

    // /// @dev Returns the token ID of the next available plot of a given type for
    // /// a given user, or `0` if no plot is available.
    // function getPlotTokenIdOfNextEmptyOfType(address user, string memory plotType) external view
    //     returns (uint256 plotTokenIdOrZero);

    // /// @dev Returns the token ID of the plot housing the given node. Reverts if
    // /// the node token ID is not attributed.
    // function getPlotTokenIdOfNodeTokenId(uint256 nodeTokenId) external view
    //     returns (uint256 plotTokenId);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IHandler {
    function nodeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function plotTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory);

    function getNodeTypesNames() external view returns (string[] memory);

    function getTokenIdNodeTypeName(uint256 key)
        external
        view
        returns (string memory);

    function nft() external view returns (address);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./Math.sol";
import "./Percentage.sol";

library GRPDependantRewardProfile {
    /**
     * @dev Computes rewards emitted by a node based on its lifetime.
     *
     * @param price Price of this type of node
     * @param baseRewardsPerSecond Base reward emitted per second
     * @param lastKnownLifetime Last known lifetime of the node instance
     * @param duration Time window on which we compute the rewards (in seconds)
     * @return rewards The computed rewards
     *
     * Implementation details :
     *
     * Every node has an implicit lifetime (implicit in the sense that we
     * can't update the node's state on the storage each passing second, so
     * we compute it on the fly). The lifetime expresses the number of
     * seconds remaining until the node is considered to be "dried out".
     *
     * We can therefore represent the emitted rewards as a function of the
     * lifetime : {https://cutt.ly/XGWNa0R} (`r` the time needed to reach the
     * GRP and `b` the base rewards of the node).
     * This reward function returns the rewards emitted every second at a
     * given point in the node's lifetime. This specific function is centered
     * around 0, so we can shift it to the correct point in the lifetime, 0
     * being the point in time when the node is dried out.
     *
     * Now to get the emitted rewards during any given lifetime window, we
     * can simply integrate the reward function over that window. In our case,
     * we want to compute the rewards from the last known lifetime until now
     * (left as a parameter, as `duration`). First, we shift the rewards
     * function to the last known lifetime :
     * {https://cutt.ly/OGWNdVW} (`l` is the actual node lifetime).
     * Then, we can integrate this function from `0` to `duration` :
     * {https://cutt.ly/aGWNhjH} (`x` is our `duration`).
     *
     * Graphing these functions might help to understand the math :
     * {https://www.desmos.com/calculator/kkmo0two9q}
     */
    function integrateRewardsFromLifetime(
        uint256 price,
        uint256 baseRewardsPerSecond,
        uint256 lastKnownLifetime,
        uint256 duration
    ) internal pure returns (uint256 rewards) {
        uint256 b = baseRewardsPerSecond;
        uint256 r = price / baseRewardsPerSecond;
        uint256 l = lastKnownLifetime;
        uint256 t = duration;

        uint256 res =
            (
                b *
                (
                    (t + 10 * Math.min(t, Math.subOrZero(l, r))) +
                    9 * Math.min(t, Math.max(l, Math.subOrZero(l, r)))
                )
            ) / 20;
        
        return res;
    }

    /// @dev Computes the rewards emitted by a fertilizer based on the time
    /// passed since its activation.
    ///
    /// @param baseRewardsPerSecond Base reward emitted per second
    /// @param percentageOfBaseRewards Percentage of the base rewards of the
    /// fertilizer
    /// @param effectDuration Duration of the effect of the fertilizer
    /// @param lifetimeSinceActivation Time since the fertilizer was activated
    ///
    /// @return The computed rewards
    function integrateFertilizerAdditionalRewards(
        uint256 baseRewardsPerSecond,
        uint256 percentageOfBaseRewards,
        uint256 effectDuration,
        uint256 lifetimeSinceActivation
    )
        internal
        pure
        returns (uint256)
    {
        return Percentages.times(percentageOfBaseRewards, baseRewardsPerSecond) *
            Math.min(lifetimeSinceActivation, effectDuration);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.8;


library Percentages {
	function from(uint32 val) internal pure returns (uint256) {
		require(val <= 10000, "Percentages: out of bounds");
		return val;
	}

	function times(uint256 p, uint256 val) internal pure returns (uint256) {
		return val * p / 10000;
	}
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

library Math {
    function subOrZero(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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