// SPDX-License-Identifier: MIT

// solhint-disable not-rely-on-time
pragma solidity >=0.8.10 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/MonstrosityGameStructs.sol";
import "./lib/MonstrosityGameDataHelper.sol";
import "./lib/MonstrosityGameBattle.sol";

// import "hardhat/console.sol";

contract MonstrosityNFT is ERC721, Ownable, ReentrancyGuard {
  GameData internal gameData;

  using MonstrosityGameDataHelper for GameData;
  using MonstrosityGameBattle for GameData;
  using Strings for uint256;

  // @todo SET THIS BEFORE DEPLOYMENT!!!
  string internal constant URI_PREFIX = "ipfs://__CID__/";
  string internal constant URI_SUFFIX = ".json";
  // @todo SET THIS BEFORE DEPLOYMENT!!!!!!!!!!
  uint256 internal constant MINT_PRICE = 0.15 ether;
  uint256 internal constant MINT_PERCENT_PRIZE = 60;

  bytes32 internal merkleRoot;
  address internal withdrawalAddress;
  uint256 internal supply;

  event JoinFight(uint256 indexed tokenId, bytes32 name);
  event Battle(uint256 indexed id, BattleInfo info, uint128[] monsters);
  event MonsterInjured(uint256 indexed tokenId, uint64 hp);
  event LevelUp(uint256 indexed tokenId, uint128 usedPoints);
  event Retreat(uint256 indexed tokenId);
  event Winner(uint256 indexed place, uint256 indexed tokenId);

  // solhint-disable-next-line no-empty-blocks
  constructor() ERC721("MonstrosityNFT", "MONSTER") {}

  modifier validMint(bool _public) {
    // mint is only allowed after preparation is done
    require(gameData.startTime > 0 && supply + 1 <= 10000 && msg.value >= _mintPrice(_public));

    _;
  }

  function _baseURI() internal pure override returns (string memory) {
    return URI_PREFIX;
  }

  function _mintPrice(bool _public) internal view returns (uint256) {
    GameStage _stage = gameData.stage();

    // whitelist lives only until the initial campaign starts
    if (!_public && _stage < GameStage.InitialCampaign) {
      return (MINT_PRICE * 60) / 100;
    }

    // the mint price is double from the start of the initial campaign, until the start of the final campaign
    return _stage > GameStage.Recruitment && _stage < GameStage.FinalCampaign ? MINT_PRICE * 2 : MINT_PRICE;
  }

  function _updatePools(uint256 _amount, bool _isMint) internal {
    if (_isMint) {
      // after the game starts, the token is not participating in it anymore
      if (gameData.stage() > GameStage.Recovery) {
        gameData.pools.dev += _amount;
        return;
      }

      gameData.pools.prize += (_amount * MINT_PERCENT_PRIZE) / 100;
      gameData.pools.fees += (_amount * 10) / 100;
      gameData.pools.dev += (_amount * 30) / 100;
      return;
    }

    gameData.pools.prize += (_amount * 70) / 100;
    gameData.pools.dev += (_amount * 30) / 100;
  }

  function _mint(
    address _to,
    bytes32 _name,
    uint64[4] memory _traits
  ) internal {
    // validate trait points
    uint128 _totalTraitPoints;
    uint128 i;

    while (i < 4) {
      _totalTraitPoints += _traits[i];
      i += 1;
    }

    require(_totalTraitPoints == 40);

    uint256 _tokenId = supply + 1;

    _safeMint(_to, _tokenId);
    supply += 1;

    // monsters minted after the final campaign has started won't be participating in this game
    if (gameData.stage() > GameStage.Recovery) {
      return;
    }

    gameData.recruitMonster(_tokenId, _name, _traits);
  }

  function totalSupply() public view returns (uint256) {
    return supply;
  }

  /// @dev Public mint method
  /// @param _name Monster name
  /// @param _traits Trait points
  function mint(bytes32 _name, uint64[4] calldata _traits) external payable validMint(true) nonReentrant {
    _mint(msg.sender, _name, _traits);
    _updatePools(_mintPrice(true), true);
  }

  /// @dev Whitelisted mint method, checks whitelist based on phrase and signature
  /// @param _name Monster name
  /// @param _traits Trait points
  /// @param _proof Merkle proof
  function whitelistMint(
    bytes32 _name,
    uint64[4] calldata _traits,
    bytes32[] calldata _proof
  ) external payable validMint(false) nonReentrant {
    // verify Merkle proof
    bytes32 computedHash = keccak256(abi.encodePacked(msg.sender));

    for (uint256 i = 0; i < _proof.length; i++) {
      if (computedHash <= _proof[i]) {
        // Hash(current computed hash + current element of the proof)
        computedHash = keccak256(abi.encodePacked(computedHash, _proof[i]));
      } else {
        // Hash(current element of the proof + current computed hash)
        computedHash = keccak256(abi.encodePacked(_proof[i], computedHash));
      }
    }

    // Check if the computed hash (root) is equal to the provided root
    require(computedHash == merkleRoot);

    _mint(msg.sender, _name, _traits);
    _updatePools(_mintPrice(false), true);
  }

  /// @dev Returns all NFTs in the given wallet
  function getTokenIDsInWallet(address _address) public view returns (uint256[] memory _tokenIds) {
    uint256 addressTokenCount = balanceOf(_address);
    _tokenIds = new uint256[](addressTokenCount);

    uint256 currentSupply = supply;
    uint256 currentTokenId = 1;
    uint256 tokenIndex;

    while (tokenIndex < addressTokenCount && currentTokenId <= currentSupply) {
      if (ownerOf(currentTokenId) == _address) {
        _tokenIds[tokenIndex] = currentTokenId;
        tokenIndex += 1;
      }

      currentTokenId += 1;
    }
  }

  /// @dev Returns the URI for the token, based on game stage
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    // non-existent token
    require(_exists(_tokenId));

    return string(abi.encodePacked(_baseURI(), _tokenId.toString(), URI_SUFFIX));
  }

  function startMint() external onlyOwner {
    require(gameData.startTime == 0);

    gameData.startTime = block.timestamp;
  }

  function setWithdrawalAddress(address _address) external onlyOwner {
    withdrawalAddress = payable(_address);
  }

  function setMerkleRoot(bytes32 _root) external onlyOwner {
    merkleRoot = _root;
  }

  /// @dev Replace withdrawalAddress with owner() to simply withdraw to owner's wallet.
  function withdraw() public payable onlyOwner nonReentrant {
    require(withdrawalAddress != address(0));

    uint256 amount = gameData.pools.dev;

    if (gameData.stage() == GameStage.Princess) {
      amount += gameData.pools.fees;
    }

    if (amount > address(this).balance) {
      amount = address(this).balance;
    }

    payable(withdrawalAddress).transfer(amount);
  }

  function isWinner(uint256 _tokenId) public view returns (uint256) {
    return gameData.winners[_tokenId];
  }

  function claimPrize(uint256 _tokenId) external payable nonReentrant {
    require(
      gameData.winners[_tokenId] > 0 && gameData.stage() == GameStage.Princess && ownerOf(_tokenId) == msg.sender
    );

    uint8[10] memory payout = [60, 20, 10, 4, 1, 1, 1, 1, 1, 1];
    uint256 prize = (gameData.pools.prize * payout[gameData.winners[_tokenId] - 1]) / 100;

    if (prize > address(this).balance) {
      prize = address(this).balance;
    }

    // mark the withdrawal
    gameData.winners[_tokenId] = 0;

    payable(msg.sender).transfer(prize);
  }

  function stage() public view returns (GameStage) {
    return gameData.stage();
  }

  function getMonsters(uint64 _campaign) public view returns (uint128) {
    return gameData.monsterCount[_campaign];
  }

  function getKilledMonsters(uint64 _campaign) public view returns (uint128) {
    return gameData.killedMonsters[_campaign];
  }

  function currentPrizePool() public view returns (uint256) {
    return gameData.pools.prize;
  }

  function getMonster(uint256 _tokenId) external view returns (Monster memory) {
    require(gameData.monsters[_tokenId].id > 0);
    return gameData.monsters[_tokenId];
  }

  function startCampaign() external {
    gameData.startCampaign();
  }

  function canEndBattle() external view returns (bool) {
    return gameData.canEndBattle();
  }

  function endBattle() external {
    gameData.endBattle();
  }

  /**
   * Upgrades a monster. Max 1 upgrade for each type.
   * @param _tokenId The ID of the monster to upgrade
   * @param _traits Array of trait points -- 0: armor, 1: speed, 2: stamina, 3: agility
   */
  function usePotion(uint256 _tokenId, uint64[4] calldata _traits) external payable nonReentrant {
    (uint64 _totalTraitPoints, uint256 _cost) = gameData.usePotion(_tokenId, _traits);
    _updatePools(_cost, false);

    emit LevelUp(_tokenId, _totalTraitPoints);
  }

  function canHealMonster(uint256 _tokenId) public view returns (bool) {
    return
      gameData.monsters[_tokenId].id > 0 &&
      gameData.monsters[_tokenId].hp < 4 &&
      gameData.stage() == GameStage.Recovery;
  }

  function healMonster(uint256 _tokenId) external payable {
    require(canHealMonster(_tokenId) && msg.value >= (4 - gameData.monsters[_tokenId].hp) * (MINT_PRICE / 8));

    if (gameData.monsters[_tokenId].hp == 0) {
      gameData.monsterCount[1] += 1;
    }

    gameData.monsters[_tokenId].hp = 4;
    gameData.traitPoints += gameData.monsters[_tokenId].totalTraits;

    _updatePools(msg.value, false);
  }

  /**
   * Gets the current refund amount when retreating a monster.
   * If 0, monsters cannot retreat.
   */
  function retreatRefund() public view returns (uint256) {
    uint256 _monsterCount = gameData.monsterCount[1];
    uint256 _killedMonsters = gameData.killedMonsters[1];

    if (gameData.stage() == GameStage.FinalCampaign && _monsterCount - _killedMonsters <= (_monsterCount * 10) / 100) {
      // prizePool(without upgrades!) / remainingMonsters / 20
      uint256 prize = (_monsterCount * MINT_PRICE * MINT_PERCENT_PRIZE) / 100;
      return (prize / (_monsterCount - _killedMonsters)) / 20;
    }

    return 0;
  }

  function retreat(uint256 _tokenId) external payable nonReentrant {
    require(
      gameData.monsters[_tokenId].id > 0 &&
        gameData.monsters[_tokenId].hp > 0 &&
        gameData.monsters[_tokenId].inBattle == 0 &&
        ownerOf(_tokenId) == msg.sender
    );

    uint256 prize = retreatRefund();
    require(prize > 0);

    // mark the monster as killed, it cannot be claimed against anymore
    gameData.monsters[_tokenId].hp = 0;
    gameData.killedMonsters[1] += 1;
    gameData.pools.prize -= prize;

    payable(msg.sender).transfer(prize);
    emit Retreat(_tokenId);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
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
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
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
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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
pragma solidity >=0.8.10 <0.9.0;

enum GameStage {
  Preparation,
  Recruitment,
  InitialCampaign,
  Recovery,
  FinalCampaign,
  Princess
}

struct Monster {
  uint256 id;
  uint256 location;
  uint64[4] traits; // 0: armor, 1: speed, 2: stamina, 3: agility
  uint64 totalTraits;
  uint64 potions;
  uint64 hp;
  uint64 inBattle;
}

struct BattleInfo {
  uint128 timestamp;
  uint128 location;
  uint64 id;
  uint64 area;
  uint32[4] opponentTraits;
}

struct Pools {
  uint256 prize;
  uint256 fees;
  uint256 dev;
}

struct GameData {
  uint256 startTime;
  /// @dev current campaign (0: initial, 1: final)
  uint64 campaign;
  /// @dev number of monsters ever entered to the game (not supply!)
  uint64 totalMonsters;
  /// @dev the total amount of trait points from all monsters
  uint128 traitPoints;
  /// @dev the count of the monsters IN the game (!= supply()!!!), one for each campaign
  uint128[2] monsterCount;
  uint128[2] killedMonsters;
  /// @dev save attributes for each monster (tokenId => monsterData)
  mapping(uint256 => Monster) monsters;
  /// @dev monster to location mapping (locationId => tokenId)
  mapping(uint256 => uint256) monsterLocations;
  /// @dev random location allocation cache
  mapping(uint256 => uint256) monsterLocationCache;
  mapping(uint256 => uint256) winners;
  /// @dev stores the list of monsters in the current battle
  uint128[] monstersInBattle;
  /// @dev current battle information
  BattleInfo currentBattle;
  Pools pools;
}

// SPDX-License-Identifier: MIT

// solhint-disable not-rely-on-time
pragma solidity >=0.8.10 <0.9.0;

import "./MonstrosityGameStructs.sol";

library MonstrosityGameDataHelper {
  // @todo SET THIS BEFORE DEPLOYMENT!!!!!!!!!!
  uint256 private constant TRAIT_POINT_PRICE = 0.0025 ether;

  function stage(GameData storage gameData) public view returns (GameStage) {
    // game hasn't been initialized yet
    if (gameData.startTime < 1) {
      return GameStage.Preparation;
    }

    // initial campaign
    if (gameData.campaign == 0) {
      // 2 weeks haven't passed OR less then 4K monsters
      // !!! @todo change the percent back to 4K tokens min !!!
      if (block.timestamp < gameData.startTime + 14 days || gameData.monsterCount[0] < 1000) {
        return GameStage.Recruitment;
      }

      return GameStage.InitialCampaign;
    }

    // campaign is already 1 (final), gameData.startTime was set to the end of the initial campaign
    // we need to wait for the recovery period to pass
    if (block.timestamp < gameData.startTime + 7 days) {
      return GameStage.Recovery;
    }

    // game has ended
    if (gameData.monsterCount[1] - gameData.killedMonsters[1] <= 1) {
      return GameStage.Princess;
    }

    return GameStage.FinalCampaign;
  }

  function usePotion(
    GameData storage gameData,
    uint256 _tokenId,
    uint64[4] memory _traits
  ) public returns (uint64, uint256) {
    require(
      gameData.monsters[_tokenId].id > 0 &&
        gameData.monsters[_tokenId].hp > 0 &&
        gameData.monsters[_tokenId].inBattle == 0 &&
        stage(gameData) < GameStage.Princess
    );
    uint64 _totalTraitPoints;
    uint192 i;

    // validate amounts and cost
    while (i < 4) {
      _totalTraitPoints += _traits[i];
      i += 1;
    }

    uint256 _cost = 2**gameData.monsters[_tokenId].potions * TRAIT_POINT_PRICE * _totalTraitPoints;
    require(msg.value >= _cost && (_totalTraitPoints == 4 || _totalTraitPoints == 8 || _totalTraitPoints == 12));

    i = 0;
    while (i < 4) {
      gameData.monsters[_tokenId].traits[i] += _traits[i];
      i += 1;
    }

    gameData.monsters[_tokenId].totalTraits += _totalTraitPoints;
    gameData.monsters[_tokenId].potions += 1;
    gameData.traitPoints += _totalTraitPoints;

    return (_totalTraitPoints, _cost);
  }
}

// SPDX-License-Identifier: MIT

// solhint-disable not-rely-on-time
pragma solidity >=0.8.10 <0.9.0;

import "./MonstrosityGameStructs.sol";
import "./MonstrosityGameDataHelper.sol";

// import "hardhat/console.sol";

library MonstrosityGameBattle {
  using MonstrosityGameDataHelper for GameData;

  uint64 internal constant MAP_SIZE = 120;

  event JoinFight(uint256 indexed tokenId, bytes32 name);
  event Battle(uint256 indexed id, BattleInfo info, uint128[] monsters);
  event MonsterInjured(uint256 indexed tokenId, uint64 hp);
  event Winner(uint256 indexed place, uint256 indexed tokenId);

  function _blockHash() private view returns (uint256) {
    return (uint256(blockhash(block.number - (block.number % 150) - 5)) % uint256(type(int256).max)) / block.timestamp;
  }

  function recruitMonster(
    GameData storage gameData,
    uint256 _tokenId,
    bytes32 _name,
    uint64[4] memory _traits
  ) public {
    // create and store monster and monster location
    Monster memory _monster;
    uint256 _locationsLeft = MAP_SIZE**2 - gameData.monsterCount[0] - gameData.monsterCount[1];
    // the random location
    uint256 _rs = (_blockHash() + _tokenId) % _locationsLeft;

    _monster.id = _tokenId;

    // if there's a cache at `monsterLocationCache[_rs]` then use it otherwise use `_rs` itself
    _monster.location = gameData.monsterLocationCache[_rs] == 0 ? _rs : gameData.monsterLocationCache[_rs];
    // grab a number from the tail
    gameData.monsterLocationCache[_rs] = gameData.monsterLocationCache[_locationsLeft - 1] == 0
      ? _locationsLeft - 1
      : gameData.monsterLocationCache[_locationsLeft - 1];

    _monster.hp = 4;
    _monster.traits = _traits;
    _monster.totalTraits = 40;

    gameData.traitPoints += 40;
    gameData.monsters[_tokenId] = _monster;
    gameData.monsterLocations[_monster.location] = _tokenId;

    // increase monsters in the correct campaign and in total
    gameData.monsterCount[gameData.stage() > GameStage.Recruitment ? 1 : 0] += 1;
    gameData.totalMonsters += 1;

    emit JoinFight(_tokenId, _name);
  }

  function _markMonstersInBattle(GameData storage gameData, BattleInfo memory _battle) private {
    uint128 xOffset = _battle.location % MAP_SIZE;
    uint128 yOffset = (_battle.location - xOffset) / MAP_SIZE;
    uint128 x1 = xOffset < _battle.area ? 0 : xOffset - _battle.area;
    uint128 x2 = xOffset + _battle.area + 1 >= MAP_SIZE ? MAP_SIZE : xOffset + _battle.area + 1;
    uint128 y = yOffset < _battle.area ? 0 : yOffset - _battle.area;
    uint128 y2 = yOffset + _battle.area + 1 >= MAP_SIZE ? MAP_SIZE : yOffset + _battle.area + 1;
    uint128 _tokenId;
    uint128 x;

    while (y < y2) {
      x = x1;
      while (x < x2) {
        _tokenId = uint128(gameData.monsterLocations[(y * MAP_SIZE + x)]);

        if (_tokenId > 0 && gameData.monsters[_tokenId].hp > 0) {
          gameData.monstersInBattle.push(_tokenId);
          gameData.monsters[_tokenId].inBattle = 1;
        }
        x += 1;
      }
      y += 1;
    }
  }

  function _newBattle(GameData storage gameData) private {
    BattleInfo memory _battle;
    uint256 _hash = _blockHash();
    uint64 _campaign = gameData.campaign;
    /// @dev if battle count is >1000, after every 100th battle the radius will increase by 1
    uint64 _extraArea = gameData.currentBattle.id > 1000 ? (gameData.currentBattle.id - 1000) / 100 : 0;
    uint128 _monsterCount = gameData.monsterCount[_campaign];
    uint128 _monsterCalc = ((_monsterCount - gameData.killedMonsters[_campaign]) * 100) / _monsterCount;
    uint128 _maxArea = (MAP_SIZE * 8) / 100 + _extraArea;
    uint64 _maxMinArea = (MAP_SIZE * 3) / 100 + _extraArea;
    uint64 _battleInt = 30 minutes;
    uint64 _maxAreaAdd = _campaign == 0 ? 6 : 4;
    uint64 _minArea = (100 - uint64(_monsterCalc))**2 / 800 + (MAP_SIZE / 100) + _extraArea;

    _battle.id = gameData.currentBattle.id + 1;

    // battle can be ended starting FROM this block, but it's already in effect!
    _battle.timestamp =
      uint128(
        block.timestamp < gameData.currentBattle.timestamp + _battleInt
          ? gameData.currentBattle.timestamp
          : block.timestamp
      ) +
      _battleInt;

    if (_minArea > _maxMinArea) {
      _minArea = _maxMinArea;
    }

    _battle.area = uint64(_hash % (_minArea + _maxAreaAdd > _maxArea ? _maxArea : _minArea + _maxAreaAdd));

    if (_battle.area < _minArea) {
      _battle.area = _minArea;
    }

    _battle.location = uint128(_hash % (MAP_SIZE**2));

    _markMonstersInBattle(gameData, _battle);

    // build opponent
    // sum of all trait points / remaining monsters + weight (weight increases)
    // base weight on area
    uint256 opponentTotalPoints = gameData.traitPoints /
      (_monsterCount - gameData.killedMonsters[_campaign]) +
      _battle.area *
      2;

    for (uint8 i; i < 4; i += 1) {
      _battle.opponentTraits[i] = i == 3 ? uint32(opponentTotalPoints) : uint32(_hash % opponentTotalPoints);
      opponentTotalPoints -= _battle.opponentTraits[i];
    }

    gameData.currentBattle = _battle;

    emit Battle(_battle.id, _battle, gameData.monstersInBattle);
  }

  function startCampaign(GameData storage gameData) public {
    GameStage _stage = gameData.stage();

    require(
      gameData.currentBattle.timestamp == 0 &&
        (_stage == GameStage.InitialCampaign || _stage == GameStage.FinalCampaign)
    );

    _newBattle(gameData);
  }

  /**
   * Finds the last remaining monster and adds it to the winners array
   */
  function _findLastMonster(GameData storage gameData) private {
    if (gameData.monsterCount[1] - gameData.killedMonsters[1] == 0) {
      return;
    }

    uint256 i = 1;

    while (i <= gameData.totalMonsters) {
      if (gameData.monsters[i].hp > 0) {
        gameData.winners[i] = 1;
        emit Winner(1, i);
        return;
      }

      i += 1;
    }
  }

  /**
   * Checks if a new battle is ready to be ended, or we still need to wait
   */
  function canEndBattle(GameData storage gameData) public view returns (bool) {
    GameStage _stage = gameData.stage();

    return
      block.timestamp >= gameData.currentBattle.timestamp &&
      (_stage == GameStage.InitialCampaign || _stage == GameStage.FinalCampaign);
  }

  /**
   * Ends the current battle (register damage) and creates the next one
   */
  function endBattle(GameData storage gameData) public {
    require(canEndBattle(gameData));

    if (gameData.monstersInBattle.length > 0) {
      uint128 _campaign = gameData.campaign;
      uint128 _monsters = gameData.monsterCount[_campaign];
      uint64 i;
      uint64 injured;
      uint128 _tokenId;

      while (i < gameData.monstersInBattle.length) {
        _tokenId = gameData.monstersInBattle[i];
        injured = 0;

        // update monster HP
        for (uint8 t; t < 4; t += 1) {
          if (
            gameData.monsters[_tokenId].hp > 0 &&
            gameData.currentBattle.opponentTraits[t] > gameData.monsters[_tokenId].traits[t]
          ) {
            gameData.monsters[_tokenId].hp -= 1;
            injured = 1;
          }
        }

        gameData.monsters[_tokenId].inBattle = 0;

        if (gameData.monsters[_tokenId].hp == 0) {
          // final campaign, add to winners
          if (_campaign == 1 && _monsters - gameData.killedMonsters[1] < 11) {
            gameData.winners[_tokenId] = _monsters - gameData.killedMonsters[1];
            emit Winner(_monsters - gameData.killedMonsters[1], _tokenId);
          }

          gameData.killedMonsters[_campaign] += 1;
          // remove monster's trait point from global counter
          gameData.traitPoints -= gameData.monsters[_tokenId].totalTraits;
        }

        if (injured == 1) {
          emit MonsterInjured(_tokenId, gameData.monsters[_tokenId].hp);
        }

        i += 1;
      }

      delete gameData.monstersInBattle;

      // initial campaign is done
      if (_campaign == 0 && _monsters - gameData.killedMonsters[0] <= (_monsters * 25) / 100) {
        gameData.startTime = block.timestamp;
        gameData.campaign = 1;
        gameData.currentBattle.timestamp = 0;
        gameData.monsterCount[1] += _monsters - gameData.killedMonsters[0];
        return;
      }

      // the game is over
      if (_campaign == 1 && _monsters - gameData.killedMonsters[1] < 2) {
        // at this point if there's one remaining monster, we need to find it, to put it in the winners array
        _findLastMonster(gameData);
        return;
      }
    }

    _newBattle(gameData);
  }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
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

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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