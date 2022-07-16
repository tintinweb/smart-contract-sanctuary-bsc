// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IClashFantasyCards {
    function getInternalUserTokenByIdV2(address from, uint256 tokenId)
        external
        view
        returns (
            address _cardOwner,
            uint256 _amount,
            uint256 _hasMana,
            uint256 _cardLevel,
            uint256 _typeOf,
            uint256 _cardState
        );

    function getCardState(address _from, uint256 _tokenId) external view returns (uint256);

    function getCard(uint256 _tokenId)
        external
        view
        returns (
            uint256,
            bool,
            address,
            uint256,
            uint256,
            uint256
        );

    function getInternalUserTokenById(address from, uint256 tokenId)
        external
        view
        returns (
            uint256 _amount,
            uint256 _aditionalId,
            uint256 _manaPower,
            uint256 _hasMana,
            uint256 _fansyExtra,
            uint256 _cardLevel,
            uint256 _energy,
            uint256 _typeOf
        );

    function updateCardState(
        address _from,
        uint256 _tokenId,
        uint256 _state
    ) external;
}

contract ClashFantasyDecksV4 is ERC1155Upgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    IERC20 private contractErc20;
    IClashFantasyCards private contractCards;

    address private adminContract;

    address private walletPrimary;
    address private walletSecondary;

    uint256[] private deckTableLevel;

    uint256[] private activateDuration;
    uint256[] private deckMaxCard;

    uint256[] private priceAddCard;
    uint256 private priceDeck;

    struct Decks {
        uint256 amount;
        uint256 typeOf;
        bool exists;
        uint256 token;
        uint256 deckLevel;
        uint256 activatePoint;
        uint256 deckState;
        uint256 manaSum;
        uint256 fansySum;
    }

    struct UserRefToken {
        uint256 index;
        bool exists;
    }

    struct Cards {
        bool exists;
        uint256 token;
        uint256 typeOf;
    }

    struct DeckInfo {
        uint256 token;
        bool exists;
        address wallet;
        uint256 isFree;
    }

    mapping(uint256 => uint256[]) activatePrice;
    mapping(uint256 => uint256[]) manaPowerGivenToDeckByLevelRarity;

    mapping(address => mapping(uint256 => UserRefToken)) public userRefTokenId;

    mapping(address => Decks[]) private decksArray;

    mapping(uint256 => DeckInfo) private deckInfoArray;

    mapping(uint256 => Cards[]) private cardsInDecks;

    mapping(address => bool) private externalContract;

    mapping(address => uint256) deckGiftArr;

    mapping(uint256 => Cards) private cardInDeck;
    
    address private walletTax;
    uint256 percentageTax;

    uint256[] private reRollPrice;
    mapping(uint256 => uint256) private deckReRollCount;
    uint256 private random;

    modifier onlyAdminOwner() {
        require(
            adminContract == msg.sender,
            "Only the contract admin owner can call this function"
        );
        _;
    }
    modifier existsRef(address _address, uint256 _tokenId) {
        require(userRefTokenId[_address][_tokenId].exists, "User Deck Not Found");
        _;
    }

    modifier existsCardRef(uint256 _tokenId, uint256 _cardId) {
        // checkExistsElement(_cardId, _tokenId);
        // require(exists != 0, "Card doest exist in Deck");
        _;
    }

    modifier existsDeckInfoExist(uint256 _tokenId) {
        require(deckInfoArray[_tokenId].exists, "Deck Info Token Not Found");
        _;
    }

    modifier onlyExternal() {
        require(externalContract[msg.sender], "ClashFantasyDeck contract invalid");
        _;
    }

    modifier limitCardDeck(address _address, uint256 _tokenId) {
        require(userRefTokenId[_address][_tokenId].exists, "User Deck Not Found");
        uint256 upToMax = deckMaxCard[
            decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index].typeOf
        ];
        require(cardsInDecks[_tokenId].length < upToMax, "Deck limit reached");
        _;
    }

    event Minted(uint256 currentToken, address sender, uint256 _amount, uint256 level);
    event Burned(uint256 currentToken, address sender, uint256 _amount, uint256 level);
    event Transfered(
        address from,
        address to,
        uint256 rest,
        uint256 id,
        uint256 amount,
        bytes data
    );

    function initialize(IERC20 _token, IClashFantasyCards _contractCards) public initializer {
        __ERC1155_init("https://metadata.clashfantasy.com/decks/{id}.json");
        adminContract = msg.sender;
        activateDuration = [7, 15, 30];
        deckMaxCard = [10, 10, 8];
        contractErc20 = _token;
        contractCards = _contractCards;
        priceDeck = 50;
    }

    function getGiftDeckState(address _from) public view returns (uint256) {
        return deckGiftArr[_from];
    }

    function giftDeck() public {
        require(deckGiftArr[msg.sender] == 0, "Gift deck already obtained");
        uint256 _typeOf = 2;
        uint256 levelChoose = 1;
        uint256 current = tokenIds.current();

        userRefTokenId[msg.sender][current] = UserRefToken(decksArray[msg.sender].length, true);

        decksArray[msg.sender].push(Decks(1, _typeOf, true, current, levelChoose, 0, 1, 0, 0));
        deckInfoArray[current] = DeckInfo(current, true, msg.sender, 1);

        _mint(msg.sender, current, 1, "");
        tokenIds.increment();
        deckGiftArr[msg.sender] = 1;

        emit Minted(current, msg.sender, 1, levelChoose);
    }

    function buyDeck(uint256 _typeOf) public {
        _typeOf = 2;
        uint256 current = tokenIds.current();
        random++;
        (uint256 levelChoose, ) = randomLevel(deckTableLevel);

        uint256 resultPrice = priceDeck * 10**18;
        transferAmount(resultPrice);

        userRefTokenId[msg.sender][current] = UserRefToken(decksArray[msg.sender].length, true);

        decksArray[msg.sender].push(Decks(1, _typeOf, true, current, levelChoose, 0, 1, 0, 0));
        deckInfoArray[current] = DeckInfo(current, true, msg.sender, 0);

        _mint(msg.sender, current, 1, "");
        tokenIds.increment();

        emit Minted(current, msg.sender, 1, levelChoose);
    }

    function deckReRoll(uint256 _tokenId) 
        public 
        existsRef(msg.sender, _tokenId)
    {
        require(deckInfoArray[_tokenId].isFree == 0, "deckReRoll: not valid for free deck");
        require(deckReRollCount[_tokenId] < 6, "deckReRoll: limit reached");
        
        Decks storage deck = decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index];
        uint256 resultPrice = reRollPrice[deckReRollCount[_tokenId]] * 10**18;
        transferAmount(resultPrice);
        random++;
        (uint256 levelChoose, ) = randomLevel(deckTableLevel);
        deck.deckLevel = levelChoose;
        
        deckReRollCount[_tokenId]++;
    }

    function addCardToDeck(uint256 _tokenId, uint256 _cardId)
        public
        existsRef(msg.sender, _tokenId)
    {
        Decks storage deck = decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index];
        require(cardsInDecks[_tokenId].length < deckMaxCard[deck.typeOf], "Deck limit reached");
        require(deck.deckState == 1, "activateDeck: Deck must be enabled");
        (
            address _cardOwner,
            uint256 _amount,
            uint256 _hasMana,
            uint256 _cardLevel,
            uint256 _typeOf,
            uint256 _cardState
        ) = contractCards.getInternalUserTokenByIdV2(msg.sender, _cardId);
        require(_cardOwner == msg.sender, "ClashFantasyDeck: Card Must be the owner");
        require(_cardState != 1, "ClashFantasyDeck: Card Must be Enabled");
        require(_hasMana == 1 && _amount > 0, "addCardToDeck: Card Must have mana || Card Amount 0");
        require(_cardLevel <= deck.deckLevel, "addCardToDeck: Cannot add a card higher level than the deck");
        
        checkExistsElement(_cardId, _tokenId);

        uint256 resultPrice = priceAddCard[deck.deckLevel - 1] * 10**16;
        transferAmount(resultPrice);

        contractCards.updateCardState(msg.sender, _cardId, 3);

        cardsInDecks[_tokenId].push(Cards(true, _cardId, _typeOf));

        cardInDeck[_cardId] = Cards(true, _tokenId, 0);

        (uint256 mana, uint256 fansy) = normalizeManaSum(_tokenId);
        deck.manaSum = mana;
        deck.fansySum = fansy;
    }

    function getDeckByCardId(uint256 _cardId) public view returns(bool, uint256){
        return ( cardInDeck[_cardId].exists , cardInDeck[_cardId].token );
    }

    function activateDeck(uint256 _tokenId, uint256 _index) public existsRef(msg.sender, _tokenId) {
        Decks storage deck = decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index];

        require(deck.deckState == 1, "activateDeck: Deck must be enabled");
        require(activateDuration.length > _index, "activateDeck: Duration offset");

        uint256 resultPrice = activatePrice[_index][deck.deckLevel - 1] * 10**18;
        transferAmount(resultPrice);

        uint256 _append = activateDuration[_index];
        decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index].activatePoint = _append;
    }

    function getActivateDuration() public view returns (uint256[] memory) {
        uint256[] memory act = new uint256[](activateDuration.length);
        for (uint256 index = 0; index < activateDuration.length; index++) {
            act[index] = (activateDuration[index]);
        }
        return act;
    }

    function withdrawCardDeck(uint256 _tokenId, uint256 _cardId)
        public
        existsRef(msg.sender, _tokenId)
    {
        Decks storage deck = decksArray[msg.sender][userRefTokenId[msg.sender][_tokenId].index];
        removeByValueCardsInDecks(_cardId, _tokenId);
        contractCards.updateCardState(msg.sender, _cardId, 1);
        (uint256 mana, uint256 fansy) = normalizeManaSum(_tokenId);
        deck.manaSum = mana;
        deck.fansySum = fansy;

        cardInDeck[_cardId].exists = false;
    }

    function getDeckInfo(uint256 _tokenId)
        public
        view
        existsDeckInfoExist(_tokenId)
        returns (
            uint256,
            bool,
            address,
            uint256,
            uint256
        )
    {
        return (
            deckInfoArray[_tokenId].token,
            deckInfoArray[_tokenId].exists,
            deckInfoArray[_tokenId].wallet,
            cardsInDecks[_tokenId].length,
            deckInfoArray[_tokenId].isFree
        );
    }

    function getCardsInDeckArr(uint256 _tokenId) public view returns (uint256[] memory) {
        uint256[] memory cards = new uint256[](cardsInDecks[_tokenId].length);
        for (uint256 index = 0; index < cardsInDecks[_tokenId].length; index++) {
            cards[index] = cardsInDecks[_tokenId][index].token;
        }
        return cards;
    }

    function getCardsInDeck(uint256 _tokenId) public view returns (Cards[] memory) {
        return cardsInDecks[_tokenId];
    }

    function getUserRefTokenId(uint256 _tokenId) public view returns (UserRefToken[] memory) {
        UserRefToken[] memory tokens = new UserRefToken[](1);
        for (uint256 index = 0; index < 1; index++) {
            tokens[index] = UserRefToken(
                userRefTokenId[msg.sender][_tokenId].index,
                userRefTokenId[msg.sender][_tokenId].exists
            );
        }
        return tokens;
    }

    function getDeckState(address _from, uint256 _tokenId)
        public
        view
        existsRef(_from, _tokenId)
        returns (uint256)
    {
        Decks storage deck = decksArray[_from][userRefTokenId[_from][_tokenId].index];

        return (deck.deckState);
    }

    function updateDeckEnergy(
        uint256 _tokenId,
        address _from
    ) public onlyExternal {
        Decks storage deck = decksArray[_from][userRefTokenId[_from][_tokenId].index];
        deck.activatePoint--;
    }

    function updateDeckState(
        address _from,
        uint256 _tokenId,
        uint256 state
    ) external onlyExternal {
        Decks storage deck = decksArray[_from][userRefTokenId[_from][_tokenId].index];
        deck.deckState = state;
    }

    function getUserDecks(address _from) public view returns (Decks[] memory) {
        return decksArray[_from];
    }

    function getDeckById(address _from, uint256 _tokenId)
        public
        view
        existsRef(_from, _tokenId)
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Decks storage deck = decksArray[_from][userRefTokenId[_from][_tokenId].index];
        uint256 amount = cardsInDecks[_tokenId].length;
        return (
            deck.typeOf,
            deck.deckLevel,
            deck.activatePoint,
            deck.manaSum,
            deck.fansySum,
            deck.deckState,
            amount
        );
    }

    function getDeckReRollCount(uint256 _tokenId) public view returns(uint256) {
        return deckReRollCount[_tokenId];
    }

    function getDeckReRollCountArr(uint256[] memory _tokenId) public view returns(uint256[] memory) {
        uint256[] memory myArray = new uint256[](_tokenId.length);
        for (uint256 i = 0; i < _tokenId.length; i++) {
            myArray[i] = deckReRollCount[_tokenId[i]];
        }
        return myArray;
    }

    function setDeckTableLevel(uint256[] memory _arr) public onlyAdminOwner {
        deckTableLevel = _arr;
    }

    function transferTo(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external onlyExternal {
        require(from != to, "ERC1155: caller cannot be the same");
        require(balanceOf(from, id) > 0, "ERC1155: check token balance");

        require(cardsInDecks[id].length == 0, "ClashFantasyDecks: Deck need to be empty");
        //validar market
        DeckInfo storage deckInfo = deckInfoArray[id];
        require(deckInfo.wallet == from, "Must be the owner of the card");

        deckInfo.wallet = to;

        userRefTokenId[to][id] = UserRefToken(decksArray[to].length, true);

        Decks storage retFrom = decksArray[from][userRefTokenId[from][id].index];

        uint256 rest = retFrom.amount - amount;
        retFrom.amount = rest;

        decksArray[to].push(
            Decks(
                amount,
                retFrom.typeOf,
                retFrom.exists,
                retFrom.token,
                retFrom.deckLevel,
                retFrom.activatePoint,
                1, //retFrom.deckState,
                retFrom.manaSum,
                retFrom.fansySum
            )
        );

        _safeTransferFrom(from, to, id, amount, "");

        emit Transfered(from, to, amount, id, amount, "");
    }

    function setPriceAddCard(uint256[] memory _price) public onlyAdminOwner {
        priceAddCard = _price;
    }

    function setPriceDeck(uint256 _price) public onlyAdminOwner {
        priceDeck = _price;
    }

    function setActivateDuration(uint256[] memory _activateDuration) public onlyAdminOwner {
        activateDuration = _activateDuration;
    }

    function setActivatePrice(uint256[] memory _activatePrice, uint256 _index)
        public
        onlyAdminOwner
    {
        activatePrice[_index] = _activatePrice;
    }

    function setManaPowerGivenToDeckByLevelRarity(
        uint256[] memory _manaPowerGivenToDeckByLevelRarity,
        uint256 _index
    ) public onlyAdminOwner {
        manaPowerGivenToDeckByLevelRarity[_index] = _manaPowerGivenToDeckByLevelRarity;
    }

    function getAdmin() public view returns (address) {
        return adminContract;
    }

    function setExternalContract(address _contract) external onlyAdminOwner {
        externalContract[_contract] = true;
    }

    function setPercentageTax(uint256 _percentageTax) public onlyAdminOwner {
        percentageTax = _percentageTax;
    }
    
    function setWalletTax(address _walletTax) public onlyAdminOwner {
        walletTax = _walletTax;
    }

    function setReRollPrice(uint256[] memory _data) public onlyAdminOwner {
        reRollPrice = _data;
    }

    function version() public pure returns (string memory) {
        return "v4";
    }

    //internal
    function randomLevel(uint256[] memory data) internal view returns (uint256, uint256) {
        uint256 count = 0;
        uint256[] memory myArray = new uint256[](1000);
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = 0; j < data[i]; j++) {
                myArray[count] = i;
                count++;
            }
        }
        uint256 purchasenumber = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, msg.sender, random, tokenIds.current())
            )
        ) % 1000;
        return (myArray[purchasenumber] + 1, myArray[purchasenumber]);
    }

    function normalizeManaSum(uint256 _tokenId) internal view returns (uint256, uint256) {
        uint256 mana = 0;
        uint256 fansy = 0;
        for (uint256 index = 0; index < cardsInDecks[_tokenId].length; index++) {
            (
                ,
                ,
                uint256 _manaPower,
                ,
                uint256 _fansyExtra,
                uint256 _cardLevel,
                ,
                uint256 _typeOf
            ) = contractCards.getInternalUserTokenById(
                    msg.sender,
                    cardsInDecks[_tokenId][index].token
                );
            mana += calculateMaxManaGivenToDeck(_cardLevel, _typeOf, _manaPower);
            fansy += _fansyExtra;
        }
        return (mana, fansy);
    }

    function calculateMaxManaGivenToDeck(
        uint256 _cardLevel,
        uint256 _typeOf,
        uint256 _mana
    ) internal view returns (uint256) {
        uint256 max = manaPowerGivenToDeckByLevelRarity[_typeOf][_cardLevel - 1] * 10;
        uint256 amount = ((_mana * 10) * max) / 100;
        return amount;
    }

    function checkExistsElement(uint256 _cardId, uint256 _tokenId) internal view {
        uint256 i = 0;
        for (uint256 index = 0; index < cardsInDecks[_tokenId].length; index++) {
            if (cardsInDecks[_tokenId][index].token == _cardId) {
                i++;
            }
        }
        require(i == 0, "checkExistsElement: Card Token Id Already in a Deck");

        // return i;
    }

    function removeByValueCardsInDecks(uint256 value, uint256 _tokenId) internal {
        uint256 i = findCardsInDecks(value, _tokenId);
        removeByIndexCardsInDecks(i, _tokenId);
    }

    function findCardsInDecks(uint256 value, uint256 _tokenId) internal view returns (uint256) {
        uint256 i = 0;
        while (cardsInDecks[_tokenId][i].token != value) {
            i++;
        }
        return i;
    }

    function removeByIndexCardsInDecks(uint256 i, uint256 _tokenId) internal {
        while (i < cardsInDecks[_tokenId].length - 1) {
            cardsInDecks[_tokenId][i] = cardsInDecks[_tokenId][i + 1];
            i++;
        }
        cardsInDecks[_tokenId].pop();
    }

    function transferAmount(uint256 _amount) internal {
        uint256 balance = contractErc20.balanceOf(msg.sender);
        require(balance >= _amount, "transferAmount: Check the token balance");

        uint256 allowance = contractErc20.allowance(msg.sender, address(this));
        require(allowance == _amount, "transferAmount: Check the token allowance");

        uint256 toTaxWallet = (_amount / uint256(100)) * percentageTax;
        uint256 normalTransfer = (_amount / uint256(100)) * uint256( 100 - percentageTax );
        uint256 half = normalTransfer / 2;

        contractErc20.transferFrom(msg.sender, walletTax, toTaxWallet);
        contractErc20.transferFrom(msg.sender, walletPrimary, half);
        contractErc20.transferFrom(msg.sender, walletSecondary, half);
    }

    function setWalletPrimary(address _address) public onlyAdminOwner {
        walletPrimary = _address;
    }

    function setWalletSecondary(address _address) public onlyAdminOwner {
        walletSecondary = _address;
    }

    function getWallets() public view returns (address, address) {
        return (walletPrimary, walletSecondary);
    }

    //override
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
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
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
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
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
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