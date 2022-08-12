/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract ERC165 is IERC165 {

}

abstract contract ERC721 is ERC165, IERC721 {
    using Address for address;

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
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) external virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
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
    function setApprovalForAll(address operator, bool approved) external virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
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
    ) external virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override {
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
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
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
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
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

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == 0x01ffc9a7
        || interfaceId == 0x80ac58cd
        || interfaceId == 0x5b5e139f;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
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
    function tokenByIndex(uint256 index) external view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721.balanceOf(to);
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

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;
            // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex;
            // Update the moved token's index
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

        _allTokens[tokenIndex] = lastTokenId;
        // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex;
        // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract ETHNFT is ERC721Enumerable, Ownable {
    struct UserInfo {
        uint256 totalReward;
        uint256 claimedReward;
        uint256 totalInviteReward;
        uint256 claimedInviteReward;
    }

    mapping(uint256 => string) public _uris;
    mapping(uint256 => uint256) public _properties;
    mapping(address => bool) public _minter;
    address public _cash;
    uint256 public constant _baseId = 0;
    uint256 public constant _baseId2 = 100000000;
    mapping(uint256 => uint256) public _property;
    mapping(uint256 => uint256) public _propertySupply;
    mapping(uint256 => uint256[]) public _tokenIdLinks;
    mapping(uint256 => uint256) private _tokenInitIds;
    mapping(uint256 => uint256) private _tokenActiveTime;
    uint256 private _initActiveTime;
    uint256 private _activeTime = 20 days;
    uint256 private _activeBufferTime = 22 days;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _admin;
    address private _usdtAddress;
    address private _tokenAddress;
    ISwapFactory public _factory;
    uint256 private _activeUsdtAmount;
    uint256 private _reMintUsdtAmount;
    address public _tokenReceiveAddress;
    mapping(uint256 => bool) public _excludeCheckStatusNFT;
    mapping(address => bool) public _excludeCheckStatus;

    function batchMint(address to, uint256 num) public {
        batchMintAndActive(to, num, false);
    }

    function batchMintAndActive(address to, uint256 num, bool isActive) public {
        require(_minter[msg.sender], "not minter");
        uint256 property = 1;
        uint256 tokenId = _propertySupply[property] + 1 + _baseId;
        uint256 blockTime = block.timestamp;
        for (uint256 i; i < num;) {
            _mint(to, tokenId);
            _properties[tokenId] = property;
            _tokenIdLinks[tokenId].push(tokenId);
            _tokenInitIds[tokenId] = tokenId;
            if (isActive) {
                _tokenActiveTime[tokenId] = blockTime;
            } else if (_initActiveTime > 0) {
                _tokenActiveTime[tokenId] = blockTime;
            }
        unchecked{
            ++tokenId;
            ++i;
        }
        }
        _propertySupply[property] += num;
    }

    function reMint(uint256 oldId, uint256 maxTokenAmount) external {
        address account = msg.sender;
        require(account == tx.origin, "not origin");
        uint256 tokenAmount = tokenAmountOut(_reMintUsdtAmount, _tokenAddress);
        require(tokenAmount <= maxTokenAmount, "gt maxTokenAmount");
        IERC20(_tokenAddress).transferFrom(account, _tokenReceiveAddress, tokenAmount);
        _reMint(oldId);
    }

    function reMint(uint256 oldId) external onlyAdmin {
        _reMint(oldId);
    }

    function _reMint(uint256 oldId) private {
        require(_initActiveTime > 0, "notStart");
        (uint256 initId,uint256 lastId,uint256 activeTime) = tokenBaseInfo(oldId);
        require(lastId == oldId, "not lastId");
        uint256 blockTime = block.timestamp;
        require(activeTime + _activeBufferTime < blockTime, "active");

        address to = msg.sender;
        uint256 property = 2;
        uint256 tokenId = _propertySupply[property] + 1 + _baseId2;

        _mint(to, tokenId);
        _properties[tokenId] = property;
        _tokenIdLinks[initId].push(tokenId);
        _tokenInitIds[tokenId] = initId;
        _tokenActiveTime[tokenId] = blockTime;

        _propertySupply[property] += 1;
    }

    function activeNFT(uint256 tokenId, uint256 maxTokenAmount) external {
        address account = msg.sender;
        require(account == tx.origin, "not origin");
        uint256 tokenAmount = tokenAmountOut(_activeUsdtAmount, _tokenAddress);
        require(tokenAmount <= maxTokenAmount, "gt maxTokenAmount");
        IERC20(_tokenAddress).transferFrom(account, _tokenReceiveAddress, tokenAmount);
        _activeNFT(tokenId);
    }

    function activeNFT(uint256 tokenId) external onlyAdmin {
        _activeNFT(tokenId);
    }

    function _activeNFT(uint256 tokenId) private {
        require(_initActiveTime > 0, "notStart");
        (,uint256 lastId,uint256 activeTime) = tokenBaseInfo(tokenId);
        require(lastId == tokenId, "not lastId");
        uint256 blockTime = block.timestamp;
        require(activeTime + _activeBufferTime >= blockTime, "inactive");
        _tokenActiveTime[tokenId] = blockTime;
    }

    function activeNFTAnyway(uint256 tokenId) external onlyAdmin {
        _activeNFTAnyway(tokenId);
    }

    function _activeNFTAnyway(uint256 tokenId) private {
        require(_initActiveTime > 0, "notStart");
        (,uint256 lastId,) = tokenBaseInfo(tokenId);
        require(lastId == tokenId, "not lastId");
        _tokenActiveTime[tokenId] = block.timestamp;
    }

    function activeBufferNFTAnyway(uint256 tokenId) external onlyAdmin {
        _activeBufferNFTAnyway(tokenId);
    }

    function _activeBufferNFTAnyway(uint256 tokenId) private {
        require(_initActiveTime > 0, "notStart");
        (,uint256 lastId,) = tokenBaseInfo(tokenId);
        require(lastId == tokenId, "not lastId");
        _tokenActiveTime[tokenId] = block.timestamp - _activeTime - 1;
    }

    function tokenURI(uint256 tokenId) external view virtual override returns (string memory) {
        if (_initActiveTime == 0) {
            return _uris[_properties[tokenId]];
        }
        (, , ,bool isActive,) = tokenInfo(tokenId);
        if (isActive) {
            return _uris[_properties[tokenId]];
        }
        return _uris[0];
    }

    function setUri(uint256 property, string memory uri) external onlyOwner {
        _uris[property] = uri;
    }

    function setMinter(address minter, bool enable) external onlyOwner {
        _minter[minter] = enable;
    }

    function setAdmin(address admin, bool enable) external onlyOwner {
        _admin[admin] = enable;
    }

    function setExcludeCheckStatus(address adr, bool enable) external onlyOwner {
        _excludeCheckStatus[adr] = enable;
    }

    function setExcludeCheckStatusNFT(uint256 tokenId, bool enable) external onlyOwner {
        uint256 initId = _tokenInitIds[tokenId];
        uint256 lastId = getLastId(initId);
        require(lastId == tokenId, "not lastId");
        _excludeCheckStatusNFT[tokenId] = enable;
    }

    function setCash(address cash) external onlyFunder {
        _cash = cash;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setTokenReceiveAddress(address receiveAddress) external onlyOwner {
        _tokenReceiveAddress = receiveAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
    }

    function setActiveUsdtAmount(uint256 amount) external onlyOwner {
        _activeUsdtAmount = amount * 10 ** IERC20(_usdtAddress).decimals();
    }

    function setInitActiveTime(uint256 time) external onlyOwner {
        _initActiveTime = time;
    }

    function startActive() external onlyOwner {
        require(0 == _initActiveTime, "started");
        _initActiveTime = block.timestamp;
    }

    function setActiveTime(uint256 time) external onlyOwner {
        _activeTime = time;
    }

    function setActiveBufferTime(uint256 time) external onlyOwner {
        _activeBufferTime = time;
    }

    function setReMintUsdtAmount(uint256 amount) external onlyOwner {
        _reMintUsdtAmount = amount * 10 ** IERC20(_usdtAddress).decimals();
    }

    function claimBalance(address to, uint256 amount) external onlyFunder {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _cash == msg.sender, "!Funder");
        _;
    }

    modifier onlyAdmin() {
        require(_admin[msg.sender], "!Admin");
        _;
    }

    function addReward(address account, uint256 reward) external {
        require(_tokenAddress == msg.sender, "not Token");
        _userInfo[account].totalReward += reward;
    }

    function addInviteReward(address invitor, uint256 reward) external {
        require(_tokenAddress == msg.sender, "not Token");
        _userInfo[invitor].totalInviteReward += reward;
    }

    function claimReward(address account) public {
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingReward = userInfo.totalReward - userInfo.claimedReward;
        if (pendingReward > 0) {
            userInfo.claimedReward += pendingReward;
            IERC20(_usdtAddress).transfer(account, pendingReward);
        }
    }

    function claimInviteReward(address account) public {
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingReward = userInfo.totalInviteReward - userInfo.claimedInviteReward;
        if (pendingReward > 0) {
            userInfo.claimedInviteReward += pendingReward;
            IERC20(_usdtAddress).transfer(account, pendingReward);
        }
    }

    function claimAllReward(address account) public {
        claimReward(account);
        claimInviteReward(account);
    }

    function activeSupply() public view returns (uint256){
        return _propertySupply[1];
    }

    function initIdInfo(uint256 initId) public view returns (uint256 lastId, bool isActive, address nftOwner){
        lastId = getLastId(initId);
        uint256 activeTime = getActiveTime(lastId);
        if (activeTime + _activeTime >= block.timestamp) {
            isActive = true;
        }
        nftOwner = ownerOf(lastId);
    }

    function getIdLinkLength(uint256 initId) public view returns (uint256){
        return _tokenIdLinks[initId].length;
    }

    function tokenInfo(uint256 tokenId) public view returns (uint256 initId, uint256 lastId, uint256 activeTime, bool isActive, address nftOwner){
        (initId, lastId, activeTime) = tokenBaseInfo(tokenId);
        if (activeTime + _activeTime >= block.timestamp && lastId == tokenId) {
            isActive = true;
        }
        nftOwner = ownerOf(tokenId);
    }

    function tokenBaseInfo(uint256 tokenId) public view returns (uint256 initId, uint256 lastId, uint256 activeTime){
        initId = getInitId(tokenId);
        lastId = getLastId(initId);
        activeTime = getActiveTime(tokenId);
    }

    function getInitId(uint256 tokenId) public view returns (uint256 initId){
        initId = _tokenInitIds[tokenId];
    }

    function getLastId(uint256 initId) public view returns (uint256 lastId){
        uint256[] storage idLinks = _tokenIdLinks[initId];
        lastId = idLinks[idLinks.length - 1];
    }

    function getIdLinks(uint256 initId) public view returns (uint256[] memory idLinks){
        idLinks = _tokenIdLinks[initId];
    }

    function getActiveTime(uint256 tokenId) public view returns (uint256 activeTime){
        if (_excludeCheckStatusNFT[tokenId]) {
            return block.timestamp;
        }
        activeTime = _tokenActiveTime[tokenId];
        if (0 == activeTime) {
            activeTime = _initActiveTime;
        }
    }

    function checkActive(uint256[] memory tokenIds) public view returns (bool[] memory isActives, address[] memory nftOwners){
        uint256 len = tokenIds.length;
        isActives = new bool[](len);
        nftOwners = new address[](len);
        uint256 tokenId;
        uint256 initId;
        uint256 lastId;
        uint256 activeTime;
        for (uint256 i; i < len;) {
            tokenId = tokenIds[i];
            (initId, lastId, activeTime) = tokenBaseInfo(tokenId);
            if (activeTime + _activeTime >= block.timestamp && lastId == tokenId) {
                isActives[i] = true;
            }
            nftOwners[i] = ownerOf(tokenId);
        unchecked{
            ++i;
        }
        }
    }

    function inActiveNFT(uint256[] memory tokenIds) external onlyAdmin {
        uint256 len = tokenIds.length;
        uint256 inActiveTime = block.timestamp - _activeBufferTime - 1;
        for (uint256 i; i < len;) {
            _tokenActiveTime[tokenIds[i]] = inActiveTime;
        unchecked{
            ++i;
        }
        }
    }

    function getTimes() public view returns (uint256 activeTime, uint256 activeBufferTime, uint256 blockTime, uint initActiveTime){
        activeTime = _activeTime;
        activeBufferTime = _activeBufferTime;
        blockTime = block.timestamp;
        initActiveTime = _initActiveTime;
    }

    function tokenAmountOut(uint256 usdtAmount, address tokenAddress) public view returns (uint256){
        address usdtAddress = _usdtAddress;
        address lpAddress = _factory.getPair(usdtAddress, tokenAddress);
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(lpAddress);
        if (usdtBalance == 0) {
            return 0;
        }
        return usdtAmount * tokenBalance / usdtBalance;
    }

    function getTokenInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 activeUsdtAmount, uint256 activeTokenAmount,
        uint256 reMintUsdtAmount, uint256 reMintTokenAmount
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        activeUsdtAmount = _activeUsdtAmount;
        activeTokenAmount = tokenAmountOut(activeUsdtAmount, tokenAddress);
        reMintUsdtAmount = _reMintUsdtAmount;
        reMintTokenAmount = tokenAmountOut(reMintUsdtAmount, tokenAddress);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);
        if (_excludeCheckStatus[from] || _excludeCheckStatus[to]) {
            return;
        }
        if (_initActiveTime == 0) {
            return;
        }
        if (_excludeCheckStatusNFT[tokenId]) {
            return;
        }
        (,uint256 lastId,uint256 activeTime) = tokenBaseInfo(tokenId);
        require(activeTime + _activeBufferTime >= block.timestamp && lastId == tokenId, "inActive");
    }

    function getUserInfo(address account) external view returns (
        uint256 totalReward, uint256 claimedReward,
        uint256 totalInviteReward, uint256 claimedInviteReward
    ){
        UserInfo storage userInfo = _userInfo[account];
        totalReward = userInfo.totalReward;
        claimedReward = userInfo.claimedReward;
        totalInviteReward = userInfo.totalInviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
    }

    constructor() ERC721("EthereumGOD NFT", "EthereumGOD NFT"){
        _minter[address (0x5070Bc38A2dDEdC0Db22ce6199f04F302357EB7C)] = true;
        _cash = address (0x5070Bc38A2dDEdC0Db22ce6199f04F302357EB7C);
        _uris[0] = "";
        _uris[1] = "https://gateway.pinata.cloud/ipfs/QmdhtBiSCPEBQwXQKvD2GxCBMJQ5QQXXLbbFX8gVALjfFh/eth.json";
        _uris[2] = "https://gateway.pinata.cloud/ipfs/QmdhtBiSCPEBQwXQKvD2GxCBMJQ5QQXXLbbFX8gVALjfFh/eth.json";
        //USDT
        _usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
        //SwapRouter
        _factory = ISwapFactory(ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E)).factory());
        _activeUsdtAmount = 20 * 10 ** IERC20(_usdtAddress).decimals();
        _reMintUsdtAmount = 100 * 10 ** IERC20(_usdtAddress).decimals();
        //tokenReceiveAddress
        _tokenReceiveAddress = address(0);
    }
}