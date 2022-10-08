// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./MobiusPledge.sol";
import "./Member.sol";
import "./WithdrawAll.sol";

contract Mobius is ERC721Enumerable, WithdrawAll {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public baseURI;

    uint256 public mintPrice = 100 * 1e18;
    uint256 public mintPriceAdd = 10 * 1e18;
    uint256 public mintCountBase = 300;
    address public mintToken;

    address public uniswapV2Router;
    address public usdtToken;

    address  public pledgeContract;
    Member public memberContract;

    mapping(uint256 => bool) public pledgePermission;

    uint256 public stcMintCoolingTime = 48 * 3600;
    //    uint256 public stcMintCoolingTime = 0 * 3600;

    mapping(uint256 => uint256) public stcMintTime;

    address  public stcContract;

    bool public transferSwitch;

    mapping(uint256 => bool) public transferWhiteList;

    mapping(address => bool) public marketContractWhiteList;

    constructor() ERC721("Mobius", "MOBIUS") {

    }

    function getList(address _addr) public view returns (uint256[]memory idArr){
        uint256 startIndex = 0;
        uint256 endIndex = balanceOf(_addr);
        idArr = new uint256[](endIndex);
        uint index;
        for (; startIndex < endIndex; startIndex++) {
            uint256 nftId = tokenOfOwnerByIndex(_addr, startIndex);
            idArr[index] = nftId;
            index++;
        }
    }

    function getMintAmount() public view returns (uint256) {
        uint256 _mintPrice = pendingMintPrice();
        return _mintAmount(_mintPrice);
    }

    function pendingMintPrice() public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        uint256 _base = _totalSupply / mintCountBase;

        return mintPrice + _base * mintPriceAdd;
    }

    function _mintAmount(uint256 _mintPrice) internal view returns (uint256) {
        require(uniswapV2Router != address(0), "Mobius: uniswapV2Router contract is not configured.");
        address[] memory path = new address[](2);
        path[0] = usdtToken;
        path[1] = mintToken;
        return IUniswapV2Router02(uniswapV2Router).getAmountsOut(_mintPrice, path)[1];
    }

    function mint(address recipient, uint256 stcId) external returns (uint256){

        require(ERC721(stcContract).ownerOf(stcId) == msg.sender, "Mobius:stc no permission");
        require(memberContract.inviter(msg.sender) != address(0), "Mobius:Please register first");

        uint256 _mintTime = stcMintTime[stcId];


        require(_mintTime == 0 || _mintTime + stcMintCoolingTime < block.timestamp, "Mobius:The cooldown time is not up");

        IERC20(mintToken).transferFrom(msg.sender, address(0), getMintAmount());

        stcMintTime[stcId] = block.timestamp;

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);

        if (_mintTime == 0) {
            pledgePermission[newItemId] = true;
        }

        return newItemId;

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {

        super._beforeTokenTransfer(from, to, tokenId);

        if (from != address(0) && to != address(0)) {

            bool isMarket = marketContractWhiteList[msg.sender];

            require(isMarket || transferSwitch || transferWhiteList[tokenId], "Mobius:No permission to transfer");

            bool isDeposit = MobiusPledge(pledgeContract).getDeposit(tokenId);
            require(!isDeposit, "Mobius:under pledge");

            if (isMarket && !pledgePermission[tokenId]) {
                pledgePermission[tokenId] = true;
            }
        }


    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setMintPriceAdd(uint256 _mintPriceAdd) external onlyOwner {
        mintPriceAdd = _mintPriceAdd;
    }

    function setMintCountBase(uint256 _mintCountBase) external onlyOwner {
        mintCountBase = _mintCountBase;
    }

    function setMintToken(address _mintToken) external onlyOwner {
        mintToken = _mintToken;
    }

    function setUniswapV2Router(address _uniswapV2Router) external onlyOwner {
        uniswapV2Router = _uniswapV2Router;
    }

    function setUsdtToken(address _usdtToken) external onlyOwner {
        usdtToken = _usdtToken;
    }

    function setPledgeContract(address _pledgeContract) external onlyOwner {
        pledgeContract = _pledgeContract;
    }

    function setPledgePermission(uint256 _tokenId, bool _status) external onlyOwner {
        pledgePermission[_tokenId] = _status;
    }

    function setStcMintCoolingTime(uint256 _stcMintCoolingTime) external onlyOwner {
        stcMintCoolingTime = _stcMintCoolingTime;
    }

    function setStcContract(address _stcContract) external onlyOwner {
        stcContract = _stcContract;
    }

    function setTransferSwitch(bool _transferSwitch) external onlyOwner {
        transferSwitch = _transferSwitch;
    }

    function setTransferWhiteList(uint256 _tokenId, bool _status) external onlyOwner {
        transferWhiteList[_tokenId] = _status;
    }

    function setMarketContractWhiteList(address _marketContract, bool _status) external onlyOwner {
        marketContractWhiteList[_marketContract] = _status;
    }

    function setMemberContract(Member _memberContract) external onlyOwner {
        memberContract = _memberContract;
    }

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

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
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
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
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

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
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
        address owner = ERC721.ownerOf(tokenId);

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router02 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Mobius.sol";
import "./Member.sol";
import "./MobiusMarket.sol";

contract MobiusPledge is Ownable, ReentrancyGuard {

    uint256 public totalReward;
    uint256 public maxReward = 10_500_000 * 1e18;
    uint256 public constant ACC_TOKEN_PRECISION = 1e18;
    // The amount of allocation points assigned to the token.
    uint256 public allocReward = 347222222222222222;
    // Accumulated Tokens per share.
    uint256 public tokenPerShare = 0;
    // Last block number that token update action is executed.
    uint256 public lastRewardBlock = 0;
    // The total amount of user shares in each pool. After considering the share boosts.
    uint256 public totalBoostedShare = 0;

    uint256[] public pendingDec = [700, 600, 500, 400, 0];

    struct NftInfo {
        address owner;
        uint256 amount;
        uint256 rewardDebt;
        uint256 pending;
        uint256 pendingCount;
        uint256 total;
        uint256 invalid; // 0 normal  1 invalid
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pending;
        uint256 total;
        uint256 nftAmount;
        uint256 nftTotal;
    }

    /// @notice Info of user.
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => NftInfo) public nftInfo;

    address public withdrawToken;

    address public mobiusContract;
    uint256 public maxNftCount = 0;
    uint256 public maxDepositCount = 0;
    uint256 public depositCount = 0;
    uint256 public depositAmount = 1000;

    address public memberContract;
    uint256[] public memberLevelRewardRate = [200, 100];
    address public marketContract;
    address public uniswapV2Router;
    address public usdtToken;
    address public stcToken;

    event Update(uint256 lastRewardBlock, uint256 tokenSupply, uint256 tokenPerShare);
    event Deposit(address indexed user, uint256 tokenId, uint256 amount, uint256 timestamp);
    event Reward(address indexed user, address indexed superior, uint256 amount, uint256 timestamp);
    event RewardDec(address indexed user, address indexed superior, uint256 amount, uint256 timestamp);
    event WithdrawPending(address indexed user, uint256 pending, uint256 timestamp);
    event WithdrawNftPending(address indexed user, uint256 tokenId, uint256 pending, uint256 amount, uint256 timestamp);

    constructor() {
        //        lastRewardBlock = block.number;
    }

    function pendingTotalReward() external view returns (uint256) {

        if (lastRewardBlock == 0) {
            return 0;
        }

        uint256 multiplier = block.number - lastRewardBlock;

        uint256 tokenReward = multiplier * allocReward;

        return totalReward + tokenReward;
    }

    /// @notice View function for checking pending Token rewards.
    /// @param _user Address of the user.
    function pendingToken(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 _tokenPerShare = getTokenPerShare();

        uint256 boostedAmount = user.amount * _tokenPerShare / ACC_TOKEN_PRECISION - user.rewardDebt;
        return boostedAmount;
    }

    /// @notice View function for checking pending Token rewards.
    /// @param _tokenId Address of the user.
    function pendingTokenId(uint256 _tokenId) external view returns (uint256) {
        NftInfo memory nft = nftInfo[_tokenId];
        uint256 _tokenPerShare = getTokenPerShare();

        uint256 boostedAmount = nft.amount * _tokenPerShare;
        return boostedAmount / ACC_TOKEN_PRECISION - nft.rewardDebt;
    }

    /// @notice View function for checking pending Token rewards.
    function getTokenPerShare() internal view returns (uint256) {
        uint256 _tokenPerShare = tokenPerShare;

        if (lastRewardBlock == 0) {
            return _tokenPerShare;
        }

        uint256 tokenSupply = totalBoostedShare;

        uint256 multiplier = block.number - lastRewardBlock;

        uint256 tokenReward = multiplier * allocReward;

        if (tokenReward > 0 && tokenSupply != 0) {
            tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;

            _tokenPerShare = _tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
        }

        return _tokenPerShare;
    }

    /// @notice Update reward variables for the given.
    function update() public {
        if (depositCount == maxDepositCount && lastRewardBlock == 0) {
            lastRewardBlock = block.number;
        } else if (lastRewardBlock > 0) {
            uint256 multiplier = block.number - lastRewardBlock;
            if (multiplier > 0) {
                uint256 tokenSupply = totalBoostedShare;
                if (tokenSupply > 0) {
                    uint256 tokenReward = multiplier * allocReward;
                    tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;
                    totalReward += tokenReward;
                    tokenPerShare = tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
                }
                lastRewardBlock = block.number;
                emit Update(block.number, tokenSupply, tokenPerShare);
            }
        }
    }

    function getDeposit(uint256 _tokenId) external view returns (bool) {
        NftInfo memory nft = nftInfo[_tokenId];
        return nft.amount > 0 || nft.invalid == 1;
    }

    function recastPrice() public view returns (uint256) {
        require(marketContract != address(0), "Mobius: marketContract contract is not configured.");

        uint256 sellPrice = MobiusMarket(marketContract).pendingSellPrice();

        return _priceToAmount(sellPrice);
    }

    function _priceToAmount(uint256 _usdtPrice) internal view returns (uint256) {
        require(uniswapV2Router != address(0), "Mobius: uniswapV2Router contract is not configured.");
        address[] memory path = new address[](2);
        path[0] = usdtToken;
        path[1] = stcToken;
        return IUniswapV2Router02(uniswapV2Router).getAmountsOut(_usdtPrice, path)[1];
    }

    function recast(uint256 _tokenId) external {

        uint256 _recastPrice = recastPrice();

        IERC20(stcToken).transferFrom(msg.sender, address(0), _recastPrice);

        NftInfo storage nft = nftInfo[_tokenId];
        require(nft.amount == 0 && nft.invalid == 1, "MobiusPledge: Invalid NFT");

        _deposit(_tokenId, nft);
    }


    function deposit(uint256 _tokenId) public {
        NftInfo storage nft = nftInfo[_tokenId];
        require(nft.invalid == 0, "MobiusPledge: Invalid NFT");
        depositCount += 1;
        _deposit(_tokenId, nft);
    }


    /// @notice Deposit tokens.
    /// @param _tokenId Amount of LP tokens to deposit.
    function _deposit(uint256 _tokenId, NftInfo storage nft) internal nonReentrant {

        address _user = msg.sender;

        address _mobiusContract = mobiusContract;
        require(Member(memberContract).inviter(_user) != address(0), "MobiusPledge:Please register first");
        require(Mobius(_mobiusContract).totalSupply() >= maxNftCount, "MobiusPledge:nft count not reached");
        require(Mobius(_mobiusContract).pledgePermission(_tokenId), "MobiusPledge:deposit no permission");
        require(Mobius(_mobiusContract).ownerOf(_tokenId) == msg.sender, "MobiusPledge:deposit no owner");

        //        NftInfo storage nft = nftInfo[_tokenId];

        uint256 amount = nft.amount;

        require(amount == 0, "MobiusPledge:deposit repeat");

        update();

        if (amount > 0) {
            nft.pending += (amount * tokenPerShare / ACC_TOKEN_PRECISION) - nft.rewardDebt;
        }

        uint256 _depositAmount = depositAmount;

        // nft
        nft.owner = _user;
        amount += _depositAmount;
        nft.amount = amount;
        nft.rewardDebt = amount * tokenPerShare / ACC_TOKEN_PRECISION;

        // user nft
        userInfo[_user].nftAmount += _depositAmount;

        // superior
        // Update total boosted share.
        totalBoostedShare += _superiorReward(_depositAmount, _user);

        emit Deposit(_user, _tokenId, _depositAmount, block.timestamp);
    }

    function _superiorReward(uint256 _depositAmount, address _user) internal returns (uint256) {

        uint256 _totalBoostedShare = _depositAmount;

        uint256[] memory _memberLevelRewardRate = memberLevelRewardRate;

        uint256 len = _memberLevelRewardRate.length;

        address _superior = _user;

        for (uint256 i = 0; i < len; i++) {

            _superior = Member(memberContract).inviter(_superior);

            if (_superior == address(0) || _superior == address(1)) {
                break;
            }

            uint256 _rate = _memberLevelRewardRate[i];

            uint256 levelReward = _depositAmount * _rate / 1000;
            UserInfo storage user = userInfo[_superior];
            uint256 amount = user.amount;
            if (amount > 0) {
                user.pending = user.pending + (amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;
            }
            amount = amount + levelReward;
            user.amount = amount;
            user.rewardDebt = amount * tokenPerShare / ACC_TOKEN_PRECISION;
            _totalBoostedShare += levelReward;

            emit Reward(_user, _superior, levelReward, block.timestamp);
        }

        return _totalBoostedShare;

    }

    /// @notice WithdrawPending LP tokens.
    function withdrawPending() external {

        require(withdrawToken != address(0), "MobiusPledge:withdrawToken address cannot be empty");

        address _user = msg.sender;

        update();

        UserInfo storage user = userInfo[_user];

        uint256 pending = user.pending + (user.amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;
        user.pending = 0;
        user.rewardDebt = user.amount * tokenPerShare / ACC_TOKEN_PRECISION;
        user.total += pending;
        if (pending > 0) {
            IERC20(withdrawToken).transfer(_user, pending);
        }


        emit WithdrawPending(_user, pending, block.timestamp);
    }

    /// @notice withdrawNftPending LP tokens.
    function withdrawNftPending(uint256[] memory _tokenIds) external {

        address _withdrawToken = withdrawToken;

        require(_withdrawToken != address(0), "MobiusPledge: withdrawToken address cannot be empty");

        update();

        uint256 len = _tokenIds.length;

        uint256 _tokenPerShare = tokenPerShare;
        uint256 _ACC_TOKEN_PRECISION = ACC_TOKEN_PRECISION;

        for (uint256 i = 0; i < len; i++) {

            uint256 tokenId = _tokenIds[i];

            NftInfo storage nft = nftInfo[tokenId];
            UserInfo storage user = userInfo[nft.owner];

            address nftOwner = nft.owner;

            require(nftOwner == msg.sender, "MobiusPledge: Not the owner");

            uint256 _odlDepositAmount = nft.amount;

            uint256 pending = nft.pending + (_odlDepositAmount * _tokenPerShare / _ACC_TOKEN_PRECISION) - nft.rewardDebt;
            nft.pending = 0;

            if (pending == 0) continue;

            uint256 _pendingCount = nft.pendingCount;

            uint256 _newDepositAmount = _pendingCount < pendingDec.length ? pendingDec[_pendingCount] : 0;

            uint256 _depositAmount = _odlDepositAmount - _newDepositAmount;

            uint256 _totalBoostedShare = _superiorRewardDec(_depositAmount, nftOwner);
            totalBoostedShare -= _totalBoostedShare + _depositAmount;

            if (_newDepositAmount == 0) {
                nft.amount = 0;
                nft.rewardDebt = 0;
                nft.pendingCount = 0;
                nft.invalid = 1;
            } else {
                nft.amount -= _depositAmount;
                nft.pendingCount += 1;
                nft.rewardDebt = nft.amount * _tokenPerShare / _ACC_TOKEN_PRECISION;
            }

            user.nftAmount -= _depositAmount;

            if (pending > 0) {
                nft.total += pending;
                user.total += pending;
                user.nftTotal += pending;
                IERC20(_withdrawToken).transfer(nftOwner, pending);
            }


            emit WithdrawNftPending(nftOwner, tokenId, pending, _newDepositAmount, block.timestamp);

        }


    }

    function _superiorRewardDec(uint256 _depositAmount, address _user) internal returns (uint256) {

        uint256[] memory _memberLevelRewardRate = memberLevelRewardRate;

        uint256 len = _memberLevelRewardRate.length;

        uint256 _totalBoostedShare = 0;

        address _superior = _user;

        for (uint256 i = 0; i < len; i++) {

            _superior = Member(memberContract).inviter(_superior);

            if (_superior == address(0) || _superior == address(1)) {
                break;
            }

            uint256 _rate = _memberLevelRewardRate[i];

            uint256 levelReward = _depositAmount * _rate / 1000;

            UserInfo storage user = userInfo[_superior];
            uint256 amount = user.amount;
            if (amount > 0) {
                user.pending = user.pending + (amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;
            }
            user.amount -= levelReward;
            user.rewardDebt = user.amount * tokenPerShare / ACC_TOKEN_PRECISION;
            _totalBoostedShare += levelReward;

            emit RewardDec(_user, _superior, levelReward, block.timestamp);

        }

        return _totalBoostedShare;

    }

    function setMaxReward(uint256 _maxReward) external onlyOwner {
        maxReward = _maxReward;
    }

    function setAllocReward(uint256 _allocReward) external onlyOwner {
        allocReward = _allocReward;
    }

    function setWithdrawToken(address _withdrawToken) external onlyOwner {
        withdrawToken = _withdrawToken;
    }

    function setMobiusContract(address _mobiusContract) external onlyOwner {
        mobiusContract = _mobiusContract;
    }

    function setMaxNftCount(uint256 _maxNftCount) external onlyOwner {
        maxNftCount = _maxNftCount;
    }

    function setMaxDepositCount(uint256 _maxDepositCount) external onlyOwner {
        maxDepositCount = _maxDepositCount;
    }

    function setDepositAmount(uint256 _depositAmount) external onlyOwner {
        depositAmount = _depositAmount;
    }

    function setMemberContract(address _memberContract) external onlyOwner {
        memberContract = _memberContract;
    }

    function setMemberLevelRewardRate(uint256[] memory _rates) external onlyOwner {
        memberLevelRewardRate = _rates;
    }

    function setMarketContract(address _marketContract) external onlyOwner {
        marketContract = _marketContract;
    }

    function setUniswapV2Router(address _uniswapV2Router) external onlyOwner {
        uniswapV2Router = _uniswapV2Router;
    }

    function setUsdtToken(address _usdtToken) external onlyOwner {
        usdtToken = _usdtToken;
    }

    function setStcToken(address _stcToken) external onlyOwner {
        stcToken = _stcToken;
    }

    function setPendingDec(uint256[] memory _pendingDec) external onlyOwner {
        pendingDec = _pendingDec;
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MobiusPledge.sol";
import "./WithdrawAll.sol";

contract Member is WithdrawAll {

    address  public pledgeContract;

    mapping(address => address) public inviter;

//    mapping(address => bool) public users;

    event Invite(address indexed from, address indexed superior, uint256 timestamp);

    constructor() {

    }

    function inviteOwner(address from, address superior) public onlyOwner returns (bool) {

        require(inviter[from] == address(0), "Member: The current user has been bound");

        _invite(from, superior);

        return true;
    }

    function invite(address superior) public returns (bool) {
        address from = _msgSender();

        if (pledgeContract != address(0) && superior != address(1)) {
            uint256 nftAmount;
            (,,,,nftAmount,) = MobiusPledge(pledgeContract).userInfo(superior);
            require(nftAmount > 0, "Member: must have a pledge");
        }
        if (inviter[from] == address(0)) {
            _invite(from, superior);
        }

        return true;
    }

    function _invite(address from, address superior) private {

        require(from != superior, "Member: The superior cannot be himself");

        inviter[from] = superior;
//        users[from] = true;
        emit Invite(from, superior, block.timestamp);
    }


    function setPledgeContract(address _pledgeContract) external onlyOwner {
        pledgeContract = _pledgeContract;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract WithdrawAll is Ownable {

    function withdrawEth(address payable receiver, uint amount) public onlyOwner payable {
        uint balance = address(this).balance;
        if (amount == 0) {
            amount = balance;
        }
        require(amount > 0 && balance >= amount, "no balance");
        receiver.transfer(amount);
    }

    function withdrawToken(address receiver, address tokenAddress, uint amount) public onlyOwner {
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        if (amount == 0) {
            amount = balance;
        }

        require(amount > 0 && balance >= amount, "bad amount");
        IERC20(tokenAddress).transfer(receiver, amount);
    }

    function withdrawNft(address receiver, address nftAddress, uint256 tokenId) public onlyOwner {
        IERC721(nftAddress).transferFrom(address(this), receiver, tokenId);
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./Mobius.sol";
import "./WithdrawAll.sol";

contract MobiusMarket is WithdrawAll {

    address public marketAddress;
    address public daoAddress;
    address public liquidityAddress;

    address public uniswapV2Router;
    address public stcToken;
    address public usdtToken;

    address public mobiusContract;

    uint256 public sellPrice = 300 * 1e18;
    uint256 public sellPriceAdd = 20 * 1e18;
    uint256 public sellCountBase = 300;

    uint256 public liquidityFee = 300;
    uint256 public destroyFee = 120;
    uint256 public marketFee = 50;
    uint256 public daoFee = 30;

    struct Order {
        address owner;
        uint256 price;
        address recipient;
    }

    mapping(uint256 => Order) public order;

    event Sell(address indexed from, uint256 tokenId, uint256 price, uint256 timestamp);
    event Buy(address indexed from, address indexed to, uint256 tokenId, uint256 price, uint256 timestamp);

    constructor() {

    }

    function pendingSellPrice() public view returns (uint256) {

        uint256 totalSupply = Mobius(mobiusContract).totalSupply();

        uint256 _base = totalSupply / sellCountBase;

        return sellPrice + _base * sellPriceAdd;
    }

    function sell(uint256 tokenId) public returns (bool) {

        Order storage _order = order[tokenId];

        require(_order.owner == address(0), "MobiusMarket: Can only be sold once");

        uint256 _sellPrice = pendingSellPrice();

        IERC721(mobiusContract).transferFrom(msg.sender, address(this), tokenId);

        _order.owner = msg.sender;
        _order.price = _sellPrice;

        emit Sell(msg.sender, tokenId, _sellPrice, block.timestamp);

        return true;
    }

    function buy(uint256 tokenId, address recipient) public returns (bool) {

        Order memory _order = order[tokenId];

        require(_order.recipient == address(0), "MobiusMarket: The order has been completed.");

        uint256 price = _order.price;

        uint256 _liquidity = price * liquidityFee / 1000;
        uint256 _destroy = price * destroyFee / 1000;
        uint256 _market = price * marketFee / 1000;
        uint256 _dao = price * daoFee / 1000;

        address _usdtToken = usdtToken;

        address _owner = _order.owner;

        IERC20(_usdtToken).transferFrom(msg.sender, address(this), price);

        IERC20(_usdtToken).transfer(_owner, price - _liquidity - _destroy - _market - _dao);
        IERC20(_usdtToken).transfer(marketAddress, _market);
        IERC20(_usdtToken).transfer(daoAddress, _dao);


        swapUSDTApprove(_destroy + _liquidity);
        swapAndDestroy(_destroy);
        swapAndLiquidity(_liquidity);

        IERC721(mobiusContract).transferFrom(address(this), recipient, tokenId);

        _order.recipient = msg.sender;

        emit Buy(_owner, recipient, tokenId, price, block.timestamp);

        return true;
    }

    function swapUSDTApprove(uint256 tokens) private {

        IERC20(usdtToken).approve(uniswapV2Router, tokens);

    }

    function swapAndDestroy(uint256 tokens) private {
        address[] memory path = new address[](2);

        path[0] = usdtToken;
        path[1] = stcToken;

        // make the swap
        IUniswapV2Router02(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokens,
            0,
            path,
            address(0),
            block.timestamp
        );

    }

    function swapAndLiquidity(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        address _uniswapV2Router = uniswapV2Router;
        address _stcToken = stcToken;
        address _usdtToken = usdtToken;

        uint256 initialBalance = IERC20(_stcToken).balanceOf(address(this));

        swapTokensForTokens(_uniswapV2Router, _usdtToken, _stcToken, half);

        uint256 newBalance = IERC20(_stcToken).balanceOf(address(this)) - initialBalance;

        addLiquidity(_uniswapV2Router, _usdtToken, _stcToken, otherHalf, newBalance);

    }


    function swapTokensForTokens(address _uniswapV2Router, address _usdtToken, address _stcToken, uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _usdtToken;
        path[1] = _stcToken;

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function addLiquidity(address _uniswapV2Router, address _usdtToken, address _stcToken, uint256 token0Amount, uint256 token1Amount) private {
        IERC20(_stcToken).approve(_uniswapV2Router, token1Amount);
        IUniswapV2Router02(_uniswapV2Router).addLiquidity(
            _usdtToken,
            _stcToken,
            token0Amount,
            token1Amount,
            0,
            0,
            liquidityAddress,
            block.timestamp
        );

    }

    function setMarketAddress(address _marketAddress) external onlyOwner {
        marketAddress = _marketAddress;
    }

    function setDaoAddress(address _daoAddress) external onlyOwner {
        daoAddress = _daoAddress;
    }

    function setLiquidityAddress(address _liquidityAddress) external onlyOwner {
        liquidityAddress = _liquidityAddress;
    }

    function setUniswapV2Router(address _uniswapV2Router) external onlyOwner {
        uniswapV2Router = _uniswapV2Router;
    }

    function setStcToken(address _stcToken) external onlyOwner {
        stcToken = _stcToken;
    }

    function setUsdtToken(address _usdtToken) external onlyOwner {
        usdtToken = _usdtToken;
    }

    function setMobiusContract(address _mobiusContract) external onlyOwner {
        mobiusContract = _mobiusContract;
    }

    function setSellPrice(uint256 _sellPrice) external onlyOwner {
        sellPrice = _sellPrice;
    }

    function setSellPriceAdd(uint256 _sellPriceAdd) external onlyOwner {
        sellPriceAdd = _sellPriceAdd;
    }


    function setSellCountBase(uint256 _sellCountBase) external onlyOwner {
        sellCountBase = _sellCountBase;
    }

    function setLiquidityFee(uint256 _liquidityFee) external onlyOwner {
        liquidityFee = _liquidityFee;
    }

    function setDestroyFee(uint256 _destroyFee) external onlyOwner {
        destroyFee = _destroyFee;
    }

    function setMarketFee(uint256 _marketFee) external onlyOwner {
        marketFee = _marketFee;
    }

    function setDaoFee(uint256 _daoFee) external onlyOwner {
        daoFee = _daoFee;
    }
}