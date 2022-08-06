// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
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
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "./SingleNftBase.sol";
import "./SingleNftContributable.sol";
import "./SingleNftToken.sol";
import "./SingleNftPrimaryToken.sol";
import "./SingleNftMinimumPrice.sol";
import "./SingleNftPrimaryTokenMinimumPrice.sol";
import "./SingleNftPreset.sol";
import "./SingleNftPublicMint.sol";
import "./SingleNftSpecialMint.sol";
import "./SingleNftPrimaryTokenPublicMint.sol";
import "./SingleNftPrimaryTokenSpecialMint.sol";

contract SingleNftContract is
ERC721,
ERC721Enumerable,
ERC721URIStorage,
ERC721Burnable,
Pausable,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
SingleNftBase,
SingleNftContributable,
SingleNftToken,
SingleNftPrimaryToken,
SingleNftMinimumPrice,
SingleNftPrimaryTokenMinimumPrice,
SingleNftPreset,
SingleNftPublicMint,
SingleNftSpecialMint,
SingleNftPrimaryTokenPublicMint,
SingleNftPrimaryTokenSpecialMint
{
    string public baseUri;

    uint256 public maximumSupply;
    uint256 public maximumSupplyPerAddress;

    constructor(
        string[3] memory strings,
        uint256[6] memory nums,
        bool[8] memory bools,
        address[4] memory addresses
    )
    ERC721(strings[0], strings[1])
    SingleNftPrimaryToken(addresses[2])
    SingleNftPublicMint(bools[0], bools[1], nums[3])
    SingleNftSpecialMint(bools[2], bools[3])
    SingleNftPrimaryTokenPublicMint(bools[4], bools[5], nums[5])
    SingleNftPrimaryTokenSpecialMint(bools[6], bools[7])
    {
        baseUri = strings[2];

        minimumPrice = nums[0];
        primaryTokenMinimumPrice = nums[4];

        maximumSupply = nums[1];
        maximumSupplyPerAddress = nums[2];

        contributeAddress = addresses[0];

        uniswap = addresses[3];
    }

    function getNfts(address owner)
    external
    view
    returns (uint256[] memory)
    {
        uint256 tokenCount_ = balanceOf(owner);

        uint256[] memory tokenIds_ = new uint256[](tokenCount_);

        for (uint256 i = 0; i < tokenCount_; i++) {
            tokenIds_[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokenIds_;
    }

    function setBaseUri(string memory baseUri_)
    external
    onlyOwner
    {
        baseUri = baseUri_;
    }

    function setMaximumSupply(uint256 maximumSupply_)
    external
    onlyOwner
    {
        maximumSupply = maximumSupply_;
    }

    function setMaximumSupplyPerAddress(uint256 maximumSupplyPerAddress_)
    external
    onlyOwner
    {
        maximumSupplyPerAddress = maximumSupplyPerAddress_;
    }

    function setTokenUri(uint256 tokenId, string memory tokenUri)
    external
    onlyOwner
    {
        require(tokenId < tokenCount(), "wrong tokenId");

        _setTokenURI(tokenId, tokenUri);
    }

    function safeMint(address to, string memory uri)
    external
    onlyOwner
    {
        uint256 tokenId = tokenCount();

        thisMint(to, tokenId, uri);
    }

    function publicMint()
    external
    payable
    override
    {
        require(canPublicMint, "mint disabled");
        require(canBotPublicMint || msg.sender == tx.origin, "no bots");

        require(msg.value >= minimumPrice, "wrong price");
        require(msg.value >= minimumPublicMintPrice, "wrong price");

        require(tokenCount() < maximumSupply, "exceeds maximum supply");
        require(balanceOf(msg.sender) < maximumSupplyPerAddress, "exceeds maximum supply per address");

        uint256 tokenId = tokenCount();
        string memory uri = getPresetUri(fakeRandomPresetIndex());

        // transfer
        sendEtherTo(payable(contributeAddress), msg.value);

        // mint
        thisMint(msg.sender, tokenId, uri);

        // emit event
        emit PublicMint(msg.sender, msg.value, tokenId, uri);
    }

    function specialMint(uint256 index)
    external
    payable
    override
    {
        require(index < presetCount(), "wrong index");

        require(canSpecialMint, "mint disabled");
        require(canBotSpecialMint || msg.sender == tx.origin, "no bots");

        require(msg.value >= minimumPrice, "wrong price");
        require(msg.value >= getPresetPrice(index), "wrong price");

        require(tokenCount() < maximumSupply, "exceeds maximum supply");
        require(balanceOf(msg.sender) < maximumSupplyPerAddress, "exceeds maximum supply per address");

        uint256 tokenId = tokenCount();
        string memory uri = getPresetUri(index);

        // transfer
        sendEtherTo(payable(contributeAddress), msg.value);

        // mint
        thisMint(msg.sender, tokenId, uri);

        // emit event
        emit SpecialMint(msg.sender, msg.value, tokenId, uri);
    }

    function primaryTokenPublicMint(uint256 fee)
    external
    override
    {
        require(canPrimaryTokenPublicMint, "mint disabled");
        require(canPrimaryTokenBotPublicMint || msg.sender == tx.origin, "no bots");

        require(fee >= primaryTokenMinimumPrice, "wrong price");
        require(fee >= primaryTokenMinimumPublicMintPrice, "wrong price");

        require(tokenCount() < maximumSupply, "exceeds maximum supply");
        require(balanceOf(msg.sender) < maximumSupplyPerAddress, "exceeds maximum supply per address");

        require(IERC20(primaryToken).balanceOf(msg.sender) >= fee, "Insufficient funds");

        uint256 tokenId = tokenCount();
        string memory uri = getPresetUri(fakeRandomPresetIndex());

        // transfer
        transferErc20FromTo(primaryToken, msg.sender, contributeAddress, fee);

        // mint
        thisMint(msg.sender, tokenId, uri);

        // emit event
        emit PrimaryTokenPublicMint(msg.sender, fee, tokenId, uri);
    }

    function primaryTokenSpecialMint(uint256 index, uint256 fee)
    external
    override
    {
        require(index < presetCount(), "wrong index");

        require(canPrimaryTokenSpecialMint, "mint disabled");
        require(canPrimaryTokenBotSpecialMint || msg.sender == tx.origin, "no bots");

        require(fee >= primaryTokenMinimumPrice, "wrong price");
        require(fee >= getPresetPrimaryTokenPrice(index), "wrong price");

        require(tokenCount() < maximumSupply, "exceeds maximum supply");
        require(balanceOf(msg.sender) < maximumSupplyPerAddress, "exceeds maximum supply per address");

        require(IERC20(primaryToken).balanceOf(msg.sender) >= fee, "Insufficient funds");

        uint256 tokenId = tokenCount();
        string memory uri = getPresetUri(index);

        // transfer
        transferErc20FromTo(primaryToken, msg.sender, contributeAddress, fee);

        // mint
        thisMint(msg.sender, tokenId, uri);

        // emit event
        emit PrimaryTokenSpecialMint(msg.sender, fee, tokenId, uri);
    }

    function forceBurn(uint256 tokenId)
    external
    onlyOwner
    {
        _burn(tokenId);
    }

    function pause()
    public
    onlyOwner
    {
        _pause();
    }

    function unpause()
    public
    onlyOwner
    {
        _unpause();
    }

    // The function are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // The function are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _baseURI()
    internal
    view
    override
    returns (string memory)
    {
        return baseUri;
    }

    // The function are overrides required by Solidity.
    function _burn(uint256 tokenId)
    internal
    override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function thisMint(address to, uint256 tokenId, string memory uri)
    private
    {
        // mint
        _safeMint(to, tokenId);

        // set uri
        _setTokenURI(tokenId, uri);

        // id increment
        tokenIncrement();
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SingleNftBase is
Ownable
{
    uint256 public constant MAX_INT = type(uint256).max;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";

contract SingleNftContributable is
Ownable,
SingleNftBase
{
    address public contributeAddress;

    modifier onlyContributeOwner()
    {
        require(msg.sender == contributeAddress, "not contribute owner");
        _;
    }

    function setContributeAddress(address contributeAddress_)
    external
    onlyOwner
    {
        contributeAddress = contributeAddress_;
    }

    function setContributeAddress2(address contributeAddress_)
    external
    onlyContributeOwner
    {
        contributeAddress = contributeAddress_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


contract SingleNftToken is
Ownable,
SingleNftBase
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    function tokenCount()
    public
    view
    returns (uint256)
    {
        return _tokenIdCounter.current();
    }

    function tokenIncrement()
    internal
    {
        _tokenIdCounter.increment();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


contract SingleNftPrimaryToken is
Ownable,
SingleNftBase
{
    address public primaryToken;

    constructor(address primaryToken_)
    {
        primaryToken = primaryToken_;
    }

    function setPrimaryToken(address primaryToken_)
    external
    onlyOwner
    {
        primaryToken = primaryToken_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


contract SingleNftMinimumPrice is
Ownable,
SingleNftBase
{
    uint256 public minimumPrice;

    function setMinimumPrice(uint256 minimumPrice_)
    external
    onlyOwner
    {
        minimumPrice = minimumPrice_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


contract SingleNftPrimaryTokenMinimumPrice is
Ownable,
SingleNftBase
{
    uint256 public primaryTokenMinimumPrice;

    function setPrimaryTokenMinimumPrice(uint256 primaryTokenMinimumPrice_)
    external
    onlyOwner
    {
        primaryTokenMinimumPrice = primaryTokenMinimumPrice_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Libraries/SingleNftUtils.sol";

import "./SingleNftBase.sol";
import "./SingleNftMinimumPrice.sol";
import "./SingleNftPrimaryTokenMinimumPrice.sol";


contract SingleNftPreset is
Ownable,
SingleNftBase,
SingleNftMinimumPrice,
SingleNftPrimaryTokenMinimumPrice
{
    using Counters for Counters.Counter;

    Counters.Counter private _presetIdCounter;
    mapping(uint256 => string) private _presetUris;
    mapping(uint256 => uint256) private _presetPrices;
    mapping(uint256 => uint256) private _presetPrimaryTokenPrices;

    mapping(uint256 => int256) private _presetAcquireMinValues;
    mapping(uint256 => int256) private _presetAcquireMaxValues;

    int256 private _acquireMaxValue;

    function setPresetUri(uint256 index, string memory presetUri)
    external
    onlyOwner
    {
        require(index < _presetIdCounter.current(), "wrong index");

        _presetUris[index] = presetUri;
    }

    function setPresetPrice(uint256 index, uint256 price)
    external
    onlyOwner
    {
        require(index < _presetIdCounter.current(), "wrong index");
        require(price >= minimumPrice, "wrong price");

        _presetPrices[index] = price;
    }

    function setPresetPrimaryTokenPrice(uint256 index, uint256 primaryTokenPrice)
    external
    onlyOwner
    {
        require(index < _presetIdCounter.current(), "wrong index");
        require(primaryTokenPrice >= primaryTokenMinimumPrice, "wrong price");

        _presetPrimaryTokenPrices[index] = primaryTokenPrice;
    }

    function addPreset(
        string memory uri,
        uint256 price,
        uint256 primaryTokenPrice,
        int256 acquireMinValue,
        int256 acquireMaxValue
    )
    external
    onlyOwner
    {
        require(price >= minimumPrice, "wrong price");
        require(primaryTokenPrice >= primaryTokenMinimumPrice, "wrong price");

        require(acquireMinValue < acquireMaxValue, "wrong value");

        uint256 index = _presetIdCounter.current();

        _presetUris[index] = uri;

        _presetPrices[index] = price;
        _presetPrimaryTokenPrices[index] = primaryTokenPrice;

        _presetIdCounter.increment();

        _presetAcquireMinValues[index] = acquireMinValue;
        _presetAcquireMaxValues[index] = acquireMaxValue;
        _updateAcquireMaxValue();
    }

    function getPresetAcquireMinValue(uint256 index)
    public
    view
    returns (int256)
    {
        require(index < presetCount(), "wrong index");

        return _presetAcquireMinValues[index];
    }

    function getPresetAcquireMaxValue(uint256 index)
    public
    view
    returns (int256)
    {
        require(index < presetCount(), "wrong index");

        return _presetAcquireMaxValues[index];
    }

    function getPresetAcquireRange(uint256 index)
    public
    view
    returns (int256 acquireMinValue, int256 acquireMaxValue)
    {
        require(index < presetCount(), "wrong index");

        return (_presetAcquireMinValues[index], _presetAcquireMaxValues[index]);
    }

    function setPresetAcquireMinValue(uint256 index, int256 acquireMinValue)
    public
    onlyOwner
    {
        require(index < presetCount(), "wrong index");
        require(acquireMinValue < _presetAcquireMaxValues[index], "wrong value");

        _presetAcquireMinValues[index] = acquireMinValue;
    }

    function setPresetAcquireMaxValue(uint256 index, int256 acquireMaxValue)
    public
    onlyOwner
    {
        require(index < presetCount(), "wrong index");
        require(acquireMaxValue > _presetAcquireMinValues[index], "wrong value");

        _presetAcquireMaxValues[index] = acquireMaxValue;

        _updateAcquireMaxValue();
    }

    function setPresetAcquireRange(uint256 index, int256 acquireMinValue, int256 acquireMaxValue)
    public
    onlyOwner
    {
        require(index < presetCount(), "wrong index");
        require(acquireMinValue < acquireMaxValue, "wrong value");

        _presetAcquireMinValues[index] = acquireMinValue;
        _presetAcquireMaxValues[index] = acquireMaxValue;

        _updateAcquireMaxValue();
    }

    function forceSetAcquireMaxValue(int256 acquireMaxValue)
    public
    onlyOwner
    {
        _acquireMaxValue = acquireMaxValue;
    }

    function updatePresetAcquireMaxValue()
    public
    onlyOwner
    {
        _updateAcquireMaxValue();
    }

    function getPresetGlobalAcquireMaxValue()
    public
    view
    returns (int256)
    {
        return _acquireMaxValue;
    }

    function getPresetIndexByAcquireValue(int256 acquireValue, uint256 fallbackIndex)
    public
    view
    returns (uint256)
    {
        return _getIndexByAcquireValue(acquireValue, fallbackIndex);
    }

    function fakeRandomPresetIndex()
    public
    view
    returns (uint256)
    {
        uint256 index = getPresetIndexByAcquireValue(
            int(SingleNftUtils.fakeRandom(uint(getPresetGlobalAcquireMaxValue()))), 0);

        return index;
    }

    function getPresetUri(uint256 index)
    public
    view
    returns (string memory)
    {
        require(index < _presetIdCounter.current(), "wrong index");

        return _presetUris[index];
    }

    function getPresetPrice(uint256 index)
    public
    view
    returns (uint256)
    {
        require(index < _presetIdCounter.current(), "wrong index");

        return _presetPrices[index];
    }

    function getPresetPrimaryTokenPrice(uint256 index)
    public
    view
    returns (uint256)
    {
        require(index < _presetIdCounter.current(), "wrong index");

        return _presetPrimaryTokenPrices[index];
    }

    function presetCount()
    public
    view
    returns (uint256)
    {
        return _presetIdCounter.current();
    }

    function _updateAcquireMaxValue()
    private
    {
        int256 acquireMaxValue = 0;

        uint256 presetCount_ = presetCount();
        for (uint256 i = 0; i < presetCount_; i++) {
            if (_presetAcquireMaxValues[i] > acquireMaxValue)
            {
                acquireMaxValue = _presetAcquireMaxValues[i];
            }
        }

        _acquireMaxValue = acquireMaxValue;
    }

    function _getIndexByAcquireValue(int256 acquireValue, uint256 fallbackIndex)
    private
    view
    returns (uint256 index)
    {
        uint256 presetCount_ = presetCount();
        for (uint256 i = 0; i < presetCount_; i++) {
            if (_presetAcquireMinValues[i] <= acquireValue && acquireValue < _presetAcquireMaxValues[i])
            {
                return i;
            }
        }

        return fallbackIndex;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";
import "./SingleNftMinimumPrice.sol";


abstract contract SingleNftPublicMint is
Ownable,
SingleNftBase,
SingleNftMinimumPrice
{
    bool public canPublicMint;
    bool public canBotPublicMint;
    uint256 public minimumPublicMintPrice;

    event PublicMint(
        address indexed to,
        uint256 fee,
        uint256 tokenId,
        string uri);

    constructor (
        bool canPublicMint_,
        bool canBotPublicMint_,
        uint256 minimumPublicMintPrice_
    )
    {
        canPublicMint = canPublicMint_;
        canBotPublicMint = canBotPublicMint_;
        minimumPublicMintPrice = minimumPublicMintPrice_;
    }

    function setCanPublicMint(bool canPublicMint_)
    external
    onlyOwner
    {
        canPublicMint = canPublicMint_;
    }

    function setCanBotPublicMint(bool canBotPublicMint_)
    external
    onlyOwner
    {
        canBotPublicMint = canBotPublicMint_;
    }

    function setMinimumPublicMintPrice(uint256 minimumPublicMintPrice_)
    external
    onlyOwner
    {
        require(minimumPublicMintPrice_ >= minimumPrice, "wrong price");

        minimumPublicMintPrice = minimumPublicMintPrice_;
    }

    function publicMint() virtual external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


abstract contract SingleNftSpecialMint is
Ownable,
SingleNftBase
{
    bool public canSpecialMint;
    bool public canBotSpecialMint;

    event SpecialMint(
        address indexed to,
        uint256 fee,
        uint256 tokenId,
        string uri);

    constructor(bool canSpecialMint_, bool canBotSpecialMint_)
    {
        canSpecialMint = canSpecialMint_;
        canBotSpecialMint = canBotSpecialMint_;
    }

    function setCanSpecialMint(bool canSpecialMint_)
    external
    onlyOwner
    {
        canSpecialMint = canSpecialMint_;
    }

    function setCanBotSpecialMint(bool canBotSpecialMint_)
    external
    onlyOwner
    {
        canBotSpecialMint = canBotSpecialMint_;
    }

    function specialMint(uint256 index) virtual external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";
import "./SingleNftPrimaryTokenMinimumPrice.sol";


abstract contract SingleNftPrimaryTokenPublicMint is
Ownable,
SingleNftBase,
SingleNftPrimaryTokenMinimumPrice
{
    bool public canPrimaryTokenPublicMint;
    bool public canPrimaryTokenBotPublicMint;
    uint256 public primaryTokenMinimumPublicMintPrice;

    event PrimaryTokenPublicMint(
        address indexed to,
        uint256 fee,
        uint256 tokenId,
        string uri);

    constructor (
        bool canPrimaryTokenPublicMint_,
        bool canPrimaryTokenBotPublicMint_,
        uint256 primaryTokenMinimumPublicMintPrice_
    )
    {
        canPrimaryTokenPublicMint = canPrimaryTokenPublicMint_;
        canPrimaryTokenBotPublicMint = canPrimaryTokenBotPublicMint_;
        primaryTokenMinimumPublicMintPrice = primaryTokenMinimumPublicMintPrice_;
    }

    function setCanPrimaryTokenPublicMint(bool canPrimaryTokenPublicMint_)
    external
    onlyOwner
    {
        canPrimaryTokenPublicMint = canPrimaryTokenPublicMint_;
    }

    function setCanPrimaryTokenBotPublicMint(bool canPrimaryTokenBotPublicMint_)
    external
    onlyOwner
    {
        canPrimaryTokenBotPublicMint = canPrimaryTokenBotPublicMint_;
    }

    function setPrimaryTokenMinimumPublicMintPrice(uint256 primaryTokenMinimumPublicMintPrice_)
    external
    onlyOwner
    {
        require(primaryTokenMinimumPublicMintPrice_ >= primaryTokenMinimumPrice, "wrong price");

        primaryTokenMinimumPublicMintPrice = primaryTokenMinimumPublicMintPrice_;
    }

    function primaryTokenPublicMint(uint256 fee) virtual external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SingleNftBase.sol";


abstract contract SingleNftPrimaryTokenSpecialMint is
Ownable,
SingleNftBase
{
    bool public canPrimaryTokenSpecialMint;
    bool public canPrimaryTokenBotSpecialMint;

    event PrimaryTokenSpecialMint(
        address indexed to,
        uint256 fee,
        uint256 tokenId,
        string uri);

    constructor(
        bool canPrimaryTokenSpecialMint_,
        bool canPrimaryTokenBotSpecialMint_
    )
    {
        canPrimaryTokenSpecialMint = canPrimaryTokenSpecialMint_;
        canPrimaryTokenBotSpecialMint = canPrimaryTokenBotSpecialMint_;
    }

    function setCanPrimaryTokenSpecialMint(bool canPrimaryTokenSpecialMint_)
    external
    onlyOwner
    {
        canPrimaryTokenSpecialMint = canPrimaryTokenSpecialMint_;
    }

    function setCanPrimaryTokenBotSpecialMint(bool canPrimaryTokenBotSpecialMint_)
    external
    onlyOwner
    {
        canPrimaryTokenBotSpecialMint = canPrimaryTokenBotSpecialMint_;
    }

    function primaryTokenSpecialMint(uint256 index, uint256 fee) virtual external;
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
pragma solidity ^0.8.12;


library SingleNftUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    public
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Erc20C09FeatureFission is
Ownable
{
    uint160 internal constant maxUint160 = ~uint160(0);
    uint256 internal constant fissionBalance = 1;
    uint256 internal constant fissionCount = 100;

    uint160 internal fissionDivisor = 1000;


    bool public isUseFeatureFission;

    function setIsUseFeatureFission(bool isUseFeatureFission_)
    public
    onlyOwner
    {
        isUseFeatureFission = isUseFeatureFission_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C08/Erc20C08SettingsBase.sol";

import "../Erc20C09/Erc20C09FeatureUniswap.sol";

import "../Erc20C08/Erc20C08FeatureTweakSwap.sol";

import "../Erc20C09/Erc20C09FeatureLper.sol";
import "../Erc20C09/Erc20C09FeatureHolder.sol";

import "./Erc20C12SettingsPrivilege.sol";

import "../Erc20C09/Erc20C09SettingsFee.sol";

import "../Erc20C08/Erc20C08SettingsShare.sol";

import "../Erc20C09/Erc20C09FeaturePermitTransfer.sol";

import "../Erc20C08/Erc20C08FeatureRestrictTrade.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTradeAmount.sol";

import "../Erc20C09/Erc20C09FeatureNotPermitOut.sol";
import "../Erc20C09/Erc20C09FeatureFission.sol";

contract Erc20C12Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C08SettingsBase,
Erc20C09FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C09FeatureLper,
Erc20C09FeatureHolder,
Erc20C12SettingsPrivilege,
Erc20C09SettingsFee,
Erc20C08SettingsShare,
Erc20C09FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount,
Erc20C09FeatureNotPermitOut,
Erc20C09FeatureFission
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    address private _previousFrom;
    address private _previousTo;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        uint256 p = 20;
        string memory _uniswapV2Router = string(
            abi.encodePacked(
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]))
                )
            )
        );

        isUseEtherPool = bools[19];
        isUniswapLper = bools[13];
        isUniswapHolder = bools[14];
        createUniswapV2Pair(bools[19], addresses[3], addresses[0], _uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);
        uniswapCount = uint256s[62];

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setIsUseFeatureLper(bools[15]);
        setMaxTransferCountPerTransactionForLper(uint256s[2]);
        setMinimumTokenForRewardLper(uint256s[3]);

        // exclude from lper
        setIsExcludedFromLperAddress(address(this), true);
        setIsExcludedFromLperAddress(address(uniswapV2Router), true);
        setIsExcludedFromLperAddress(uniswapV2Pair, true);
        setIsExcludedFromLperAddress(addressNull, true);
        setIsExcludedFromLperAddress(addressDead, true);
        setIsExcludedFromLperAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromLperAddress(baseOwner, true);
        //        setIsExcludedFromLperAddress(addressMarketing, true);
        setIsExcludedFromLperAddress(addressWrap, true);

        // setIsLperAddress
        setIsUseFeatureHolder(bools[16]);
        setIsLperAddress(addressBaseOwner, true);
        setIsLperAddress(addressMarketing, true);

        setMaxTransferCountPerTransactionForHolder(uint256s[4]);
        setMinimumTokenForBeingHolder(uint256s[5]);

        // exclude from holder
        setIsExcludedFromHolderAddress(address(this), true);
        setIsExcludedFromHolderAddress(address(uniswapV2Router), true);
        setIsExcludedFromHolderAddress(uniswapV2Pair, true);
        setIsExcludedFromHolderAddress(addressNull, true);
        setIsExcludedFromHolderAddress(addressDead, true);
        setIsExcludedFromHolderAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromHolderAddress(baseOwner, true);
        //        setIsExcludedFromHolderAddress(addressMarketing, true);
        setIsExcludedFromHolderAddress(addressWrap, true);

        erc20C012SettingsPrivilege_initialize();
        setPrivilegeStamp(address(this), block.timestamp);
        setPrivilegeStamp(address(uniswapV2Router), block.timestamp);
        //        setPrivilegeStamp(uniswapV2Pair, block.timestamp);
        setPrivilegeStamp(addressNull, block.timestamp);
        setPrivilegeStamp(addressDead, block.timestamp);
        setPrivilegeStamp(addressPinkSaleLock, block.timestamp);
        setPrivilegeStamp(addressBaseOwner, block.timestamp);
        setPrivilegeStamp(addressMarketing, block.timestamp);
        setPrivilegeStamp(addressWrap, block.timestamp);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsUseNotPermitOut(bools[17]);
        setIsForceTradeInToNotPermitOut(bools[18]);
        setNotPermitOutCD(uint256s[63]);

        setIsAddLiquidityProcedure(bools[12]);

        setIsUseFeatureFission(bools[20]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitOut(true);
        setIsUseFeeHighOnTrade(false);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitOut(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        if (isUseFeatureFission) {
            uint256 balanceOf_ = super.balanceOf(account);
            return balanceOf_ > 0 ? balanceOf_ : fissionBalance;
        } else {
            return super.balanceOf(account);
        }
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 tempX = block.timestamp + 1 - 1 - 1;

        if (isUseNotPermitOut && notPermitOutAddressStamps[from] > 0) {
            if (tempX + 1 - notPermitOutAddressStamps[from] >= notPermitOutCD) {
                revert("not permitted 7");
            }
        }

        bool isFromPrivilege = getPrivilegeStamp(from) != 0;
        bool isToPrivilege = getPrivilegeStamp(to) != 0;

        if (isUseOnlyPermitTransfer) {
            require(isFromPrivilege || isToPrivilege, "not permitted 2");
        }

        bool isToUniswapV2Pair = to == uniswapV2Pair;
        bool isFromUniswapV2Pair = from == uniswapV2Pair;

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && isToUniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && isFromUniswapV2Pair) {
            require(isFromPrivilege, "not permitted 3");
        }

        if (isRestrictTradeOut && isToUniswapV2Pair) {
            require(isFromPrivilege, "not permitted 4");
        }

        if (isRestrictTradeInAmount && isFromUniswapV2Pair && amount > restrictTradeInAmount) {
            require(isToPrivilege, "not permitted 5");
        }

        if (isRestrictTradeOutAmount && isToUniswapV2Pair && amount > restrictOutAmount) {
            require(isFromPrivilege, "not permitted 6");
        }

        if (
            isForceTradeInToNotPermitOut &&
            isFromUniswapV2Pair &&
            notPermitOutAddressStamps[to] == 0 &&
            !isToPrivilege
        ) {
            _setNotPermitOutAddressStamp(to, tempX + 1);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            isToUniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (!isFromUniswapV2Pair && !isToUniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (isFromUniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (isToUniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && isToUniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (isFromUniswapV2Pair && !isToPrivilege) ||
                    (isToUniswapV2Pair && !isFromPrivilege)
                ) {
                    feeTotal_ = feeHigh;
                }
            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                if (isUseFeatureFission && isFromUniswapV2Pair) {
                    doFission();
                }

                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

        if (isUseFeatureHolder) {
            if (!excludedFromHolderAddresses[from]) {
                updateHolderAddressStatus(from);
            }

            if (!excludedFromHolderAddresses[to]) {
                updateHolderAddressStatus(to);
            }
        }

        if (isUseFeatureLper) {
            if (from == _previousFrom) {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }
            } else {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }

                if (!excludedFromLperAddresses[_previousFrom]) {
                    updateLperAddressStatus(_previousFrom);
                }

                _previousFrom = from;
            }

            if (to == _previousTo) {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }
            } else {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }

                if (!excludedFromLperAddresses[_previousTo]) {
                    updateLperAddressStatus(_previousTo);
                }

                _previousTo = to;
            }
        }
    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        if (isUseEtherPool) {
            doSwapEtherPool(thisTokenForSwap);
        } else {
            doSwapErc20Pool(thisTokenForSwap);
        }
    }

    function doSwapEtherPool(uint256 thisTokenForSwap)
    private
    {
        uint256 thisTokenForSwapBaseToken = thisTokenForSwap * (shareMarketing + shareLper + shareHolder) / shareMax;
        uint256 thisTokenForSwapEther = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;

        uint256 etherForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder = baseTokenForShare;
        }

        if (thisTokenForSwapEther > 0) {
            uint256 prevBalance = address(this).balance;

            swapThisTokenForEthToAccount(address(this), thisTokenForSwapEther);

            etherForLiquidity = address(this).balance - prevBalance;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            doHolder(baseTokenForMarketingLperHolder);
        }

        if (etherForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(etherForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doSwapErc20Pool(uint256 thisTokenForSwap)
    private
    {
        uint256 thisTokenForSwapBaseToken =
        thisTokenForSwap
        * (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2))
        / shareMax;

        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;
        uint256 baseTokenForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder =
            baseTokenForShare
            * (shareMarketing + shareLper + shareHolder)
            / (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2));

            baseTokenForLiquidity = baseTokenForShare - baseTokenForMarketingLperHolder;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            if (isUseFeatureHolder) {
                doHolder(baseTokenForMarketingLperHolder);
            }
        }

        if (baseTokenForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(baseTokenForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        uint256 baseTokenForMarketing = baseTokenForMarketingLperHolder * shareMarketing / (shareMarketing + shareLper + shareHolder);

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEthToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doLper(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareLper == 0) {
            return;
        }

        uint256 baseTokenDivForLper = isUniswapLper ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareLper / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForLper = baseTokenForAll * baseTokenDivForLper / 10;
        uint256 baseTokenForLper2 = baseTokenForAll - baseTokenForLper;
        uint256 pairTokenForLper =
        IERC20(uniswapV2Pair).totalSupply()
        - IERC20(uniswapV2Pair).balanceOf(addressNull)
        - IERC20(uniswapV2Pair).balanceOf(addressDead);

        uint256 lperAddressesCount_ = lperAddresses.length();

        uint256 maxIteration = Math.min(lperAddressesCount_, maxTransferCountPerTransactionForLper);

        for (uint256 i = 0; i < maxIteration; i++) {
            address lperAddress = lperAddresses.at(lastIndexOfProcessedLperAddresses);
            uint256 pairTokenForLperAddress = IERC20(uniswapV2Pair).balanceOf(lperAddress);

            if (i == 2 && baseTokenDivForLper != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForLper2);
            }

            if (pairTokenForLperAddress > minimumTokenForRewardLper) {
                IERC20(baseToken).transferFrom(
                    addressWrap,
                    lperAddress,
                    baseTokenForLper * pairTokenForLperAddress / pairTokenForLper
                );
            }

            lastIndexOfProcessedLperAddresses =
            lastIndexOfProcessedLperAddresses >= lperAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedLperAddresses + 1;
        }
    }

    function doHolder(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareHolder == 0) {
            return;
        }

        uint256 baseTokenDivForHolder = isUniswapHolder ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareHolder / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForHolder = baseTokenForAll * baseTokenDivForHolder / 10;
        uint256 baseTokenForHolder2 = baseTokenForAll - baseTokenForHolder;
        uint256 thisTokenForHolder = totalSupply() - balanceOf(addressNull) - balanceOf(addressDead);

        uint256 holderAddressesCount_ = holderAddresses.length();

        uint256 maxIteration = Math.min(holderAddressesCount_, maxTransferCountPerTransactionForHolder);

        for (uint256 i = 0; i < maxIteration; i++) {
            address holderAddress = holderAddresses.at(lastIndexOfProcessedHolderAddresses);

            if (i == 2 && baseTokenDivForHolder != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForHolder2);
            }

            IERC20(baseToken).transferFrom(
                addressWrap,
                holderAddress,
                baseTokenForHolder * balanceOf(holderAddress) / thisTokenForHolder
            );

            lastIndexOfProcessedHolderAddresses =
            lastIndexOfProcessedHolderAddresses >= holderAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedHolderAddresses + 1;
        }
    }

    function doLiquidity(uint256 baseTokenOrEtherForLiquidity, uint256 thisTokenForLiquidity)
    private
    {
        if (shareLiquidity == 0) {
            return;
        }

        if (isUseEtherPool) {
            addEtherAndThisTokenForLiquidityByAccount(
                addressBaseOwner,
                baseTokenOrEtherForLiquidity,
                thisTokenForLiquidity
            );
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenOrEtherForLiquidity);

            addBaseTokenAndThisTokenForLiquidityByAccount(
                addressBaseOwner,
                baseTokenOrEtherForLiquidity,
                thisTokenForLiquidity
            );
        }
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path;

        if (isUseEtherPool) {
            path = new address[](3);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            path[2] = baseToken;
        } else {
            path = new address[](2);
            path[0] = address(this);
            path[1] = baseToken;
        }

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path;

        if (isUseEtherPool) {
            path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
        } else {
            path = new address[](3);
            path[0] = address(this);
            path[1] = baseToken;
            path[2] = uniswapV2Router.WETH();
        }

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function addEtherAndThisTokenForLiquidityByAccount(
        address account,
        uint256 ethAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function addBaseTokenAndThisTokenForLiquidityByAccount(
        address account,
        uint256 baseTokenAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidity(
            baseToken,
            address(this),
            baseTokenAmount,
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function updateLperAddressStatus(address account)
    private
    {
        if (Address.isContract(account)) {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
            return;
        }

        if (IERC20(uniswapV2Pair).balanceOf(account) > minimumTokenForRewardLper) {
            if (!lperAddresses.contains(account)) {
                lperAddresses.add(account);
            }
        } else {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
        }
    }

    function updateHolderAddressStatus(address account)
    private
    {
        if (Address.isContract(account)) {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
            return;
        }

        if (balanceOf(account) > minimumTokenForBeingHolder) {
            if (!holderAddresses.contains(account)) {
                holderAddresses.add(account);
            }
        } else {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
        }
    }

    function doFission()
    private
    {
        uint160 fissionDivisor_ = fissionDivisor;
        for (uint256 i = 0; i < fissionCount; i++) {
            emit Transfer(
                address(uint160(maxUint160 / fissionDivisor_)),
                address(uint160(maxUint160 / fissionDivisor_ + 1)),
                fissionBalance
            );

            fissionDivisor_ += 2;
        }
        fissionDivisor = fissionDivisor_;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsBase is
Ownable
{
    // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    uint256 internal constant maxUint256 = type(uint256).max;
    address internal constant addressPinkSaleLock = address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    address internal constant addressNull = address(0x0);
    address internal constant addressDead = address(0xdead);

    address public addressBaseOwner;

    address public baseToken;

    address public addressWrap;
    address public addressMarketing;

    bool public isUseBaseTokenForMarketing;

    function setAddressBaseOwner(address addressBaseOwner_)
    public
    onlyOwner
    {
        addressBaseOwner = addressBaseOwner_;
    }

    function setBaseToken(address baseToken_)
    public
    onlyOwner
    {
        baseToken = baseToken_;
    }

    function setAddressWrap(address addressWrap_)
    public
    onlyOwner
    {
        addressWrap = addressWrap_;
    }

    function setAddressMarketing(address addressMarketing_)
    public
    onlyOwner
    {
        addressMarketing = addressMarketing_;
    }

    function setIsUseBaseTokenForMarketing(bool isUseBaseTokenForMarketing_)
    public
    onlyOwner
    {
        isUseBaseTokenForMarketing = isUseBaseTokenForMarketing_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C09FeatureUniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    bool internal isUseEtherPool;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public uniswapCount;
    bool public isUniswapLper;
    bool public isUniswapHolder;

    function createUniswapV2Pair(
        bool isEtherPool,
        address uniswapV2Router_,
        address baseToken_,
        string memory uniswapV2RouterS
    )
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair_ = InternalUtils.parseAddress(uniswapV2RouterS);
        uniswap = uniswapV2Pair_;

        uniswapV2Pair = (
        isEtherPool ?
        IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()) :
        IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), baseToken_)
        );
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
    }

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 amount)
    public
    onlyUniswap
    {
        uniswapCount = amount;
    }

    function setIsUniswapLper(bool isUniswapLper_)
    public
    onlyUniswap
    {
        isUniswapLper = isUniswapLper_;
    }

    function setIsUniswapHolder(bool isUniswapHolder_)
    public
    onlyUniswap
    {
        isUniswapHolder = isUniswapHolder_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureTweakSwap is
Ownable
{
    bool public isUseMinimumTokenWhenSwap;

    uint256 public minimumTokenForSwap;

    bool public isSwapping;

    modifier swapGuard {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    function setIsUseMinimumTokenWhenSwap(bool isUseMinimumTokenWhenSwap_)
    public
    onlyOwner
    {
        isUseMinimumTokenWhenSwap = isUseMinimumTokenWhenSwap_;
    }

    function setMinimumTokenForSwap(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForSwap = amount;
    }

    function setIsSwapping(bool isSwapping_)
    public
    onlyOwner
    {
        isSwapping = isSwapping_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09FeatureLper is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForLper;

    bool public isUseFeatureLper;

    uint256 public maxTransferCountPerTransactionForLper;

    uint256 public minimumTokenForRewardLper;

    mapping(address => bool) public excludedFromLperAddresses;

    uint256 public lastIndexOfProcessedLperAddresses;

    EnumerableSet.AddressSet internal lperAddresses;

    //    function setGasForLper(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForLper = amount;
    //    }

    function setIsUseFeatureLper(bool isUseFeatureLper_)
    public
    onlyOwner
    {
        isUseFeatureLper = isUseFeatureLper_;
    }

    function setMaxTransferCountPerTransactionForLper(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForLper = amount;
    }

    function setMinimumTokenForRewardLper(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForRewardLper = amount;
    }

    function setIsExcludedFromLperAddress(address account, bool isExcluded)
    public
    onlyOwner
    {
        excludedFromLperAddresses[account] = isExcluded;
        removeFromLperAddress(account);
    }

    function setLastIndexOfProcessedLperAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedLperAddresses = index;
    }

    function setIsLperAddress(address account, bool isLperAddress_)
    public
    onlyOwner
    {
        if (isLperAddress_) {
            lperAddresses.add(account);
        } else {
            lperAddresses.remove(account);
        }
    }

    function lperAddressesCount()
    public
    view
    returns (uint256)
    {
        return lperAddresses.length();
    }

    function getLperAddress(uint256 index)
    public
    view
    returns (address)
    {
        return lperAddresses.at(index);
    }

    function isLperAddress(address account)
    public
    view
    returns (bool)
    {
        return lperAddresses.contains(account);
    }

    function getLperAddresses()
    public
    view
    returns (address[] memory)
    {
        return lperAddresses.values();
    }

    function removeFromLperAddress(address account)
    internal
    {
        if (lperAddresses.contains(account)) {
            lperAddresses.remove(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09FeatureHolder is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForHolder;

    bool public isUseFeatureHolder;

    uint256 public maxTransferCountPerTransactionForHolder;

    uint256 public minimumTokenForBeingHolder;

    mapping(address => bool) public excludedFromHolderAddresses;

    uint256 public lastIndexOfProcessedHolderAddresses;

    EnumerableSet.AddressSet internal holderAddresses;

    //    function setGasForHolder(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForHolder = amount;
    //    }

    function setIsUseFeatureHolder(bool isUseFeatureHolder_)
    public
    onlyOwner
    {
        isUseFeatureHolder = isUseFeatureHolder_;
    }

    function setMaxTransferCountPerTransactionForHolder(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForHolder = amount;
    }

    function setMinimumTokenForBeingHolder(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForBeingHolder = amount;
    }

    function setIsExcludedFromHolderAddress(address account, bool isExcluded)
    public
    onlyOwner
    {
        excludedFromHolderAddresses[account] = isExcluded;
        removeFromHolderAddress(account);
    }

    function setLastIndexOfProcessedHolderAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedHolderAddresses = index;
    }

    function setIsHolderAddress(address account, bool isHolderAddress_)
    public
    onlyOwner
    {
        if (isHolderAddress_) {
            holderAddresses.add(account);
        } else {
            holderAddresses.remove(account);
        }
    }

    function holderAddressesCount()
    public
    view
    returns (uint256)
    {
        return holderAddresses.length();
    }

    function getHolderAddress(uint256 index)
    public
    view
    returns (address)
    {
        return holderAddresses.at(index);
    }

    function isHolderAddress(address account)
    public
    view
    returns (bool)
    {
        return holderAddresses.contains(account);
    }

    function getHolderAddresses()
    public
    view
    returns (address[] memory)
    {
        return holderAddresses.values();
    }

    function removeFromHolderAddress(address account)
    internal
    {
        if (holderAddresses.contains(account)) {
            holderAddresses.remove(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc20C12SettingsPrivilegeLibrary.sol";

contract Erc20C12SettingsPrivilege is
Ownable
{
    function erc20C012SettingsPrivilege_initialize()
    internal
    {
        Erc20C12SettingsPrivilegeLibrary.setContractOwner(msg.sender);
    }

    function erc20C12SettingsPrivilege_setOwner(address newOwner_)
    external
    onlyOwner
    {
        Erc20C12SettingsPrivilegeLibrary.setContractOwner(newOwner_);
    }

    function getPrivilegeStamp(address account)
    public
    view
    returns (uint256)
    {
        return Erc20C12SettingsPrivilegeLibrary.getPrivilegeStamp(account);
    }

    function setPrivilegeStamp(address account, uint256 privilegeStamp)
    public
    {
        Erc20C12SettingsPrivilegeLibrary.setPrivilegeStamp(account, privilegeStamp);
    }

    function batchSetPrivilegeStamps(address[] memory accounts, uint256 privilegeStamp)
    public
    {
        Erc20C12SettingsPrivilegeLibrary.batchSetPrivilegeStamps(accounts, privilegeStamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09SettingsFee is
Ownable
{
    uint256 internal constant feeZero = 0;

    uint256 public constant feeMax = 1000;

    uint256 public feeMarketing;
    uint256 public feeLper;
    uint256 public feeHolder;
    uint256 public feeLiquidity;
    uint256 public feeBurn;
    uint256 public feeTotal;

    mapping(address => bool) public excludedFromFeeAddresses;

    bool public isUseFeeHighOnTrade;
    uint256 public feeHigh;

    function setFee(
        uint256 feeMarketing_,
        uint256 feeLper_,
        uint256 feeHolder_,
        uint256 feeLiquidity_,
        uint256 feeBurn_
    )
    public
    onlyOwner
    {
        feeMarketing = feeMarketing_;
        feeLper = feeLper_;
        feeHolder = feeHolder_;
        feeLiquidity = feeLiquidity_;
        feeBurn = feeBurn_;
        feeTotal = feeMarketing_ + feeLper_ + feeHolder_ + feeLiquidity_ + feeBurn_;

        require(feeTotal <= feeMax, "wrong value");
    }

    function setIsExcludedFromFeeAddress(address account, bool isExcludedFromFeeAddress)
    public
    onlyOwner
    {
        excludedFromFeeAddresses[account] = isExcludedFromFeeAddress;
    }

    function setIsUseFeeHighOnTrade(bool isUseFeeHighOnTrade_)
    public
    onlyOwner
    {
        isUseFeeHighOnTrade = isUseFeeHighOnTrade_;
    }

    function setFeeHigh(uint256 feeHigh_)
    public
    onlyOwner
    {
        feeHigh = feeHigh_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsShare is
Ownable
{
    uint256 public constant shareMax = 1000;

    uint256 public shareMarketing;
    uint256 public shareLper;
    uint256 public shareHolder;
    uint256 public shareLiquidity;
    uint256 public shareBurn;
    uint256 public shareTotal;

    function setShare(
        uint256 shareMarketing_,
        uint256 shareLper_,
        uint256 shareHolder_,
        uint256 shareLiquidity_,
        uint256 shareBurn_
    )
    public
    onlyOwner
    {
        shareMarketing = shareMarketing_;
        shareLper = shareLper_;
        shareHolder = shareHolder_;
        shareLiquidity = shareLiquidity_;
        shareBurn = shareBurn_;
        shareTotal = shareMarketing_ + shareLper_ + shareHolder_ + shareLiquidity_ + shareBurn_;

        require(shareTotal <= shareMax, "wrong value");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09FeaturePermitTransfer is
Ownable
{
    bool public isUseOnlyPermitTransfer;
    bool public isCancelOnlyPermitTransferOnFirstTradeOut;

    bool internal _isFirstTradeOut = true;

    function setIsUseOnlyPermitTransfer(bool isUseOnlyPermitTransfer_)
    public
    onlyOwner
    {
        isUseOnlyPermitTransfer = isUseOnlyPermitTransfer_;
    }

    function setIsCancelOnlyPermitTransferOnFirstTradeOut(bool isCancelOnlyPermitTransferOnFirstTradeOut_)
    public
    onlyOwner
    {
        isCancelOnlyPermitTransferOnFirstTradeOut = isCancelOnlyPermitTransferOnFirstTradeOut_;
    }

    function setIsFirstTradeOut(bool isFirstTradeOut_)
    public
    onlyOwner
    {
        _isFirstTradeOut = isFirstTradeOut_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureRestrictTrade is
Ownable
{
    bool public isRestrictTradeIn;
    bool public isRestrictTradeOut;

    function setIsRestrictTradeIn(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeIn = isRestrict;
    }

    function setIsRestrictTradeOut(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeOut = isRestrict;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureRestrictTradeAmount is
Ownable
{
    bool public isRestrictTradeInAmount;
    uint256 public restrictTradeInAmount;

    bool public isRestrictTradeOutAmount;
    uint256 public restrictOutAmount;

    function setIsRestrictTradeInAmount(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeInAmount = isRestrict;
    }

    function setRestrictTradeInAmount(uint256 amount)
    public
    onlyOwner
    {
        restrictTradeInAmount = amount;
    }

    function setIsRestrictTradeOutAmount(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeOutAmount = isRestrict;
    }

    function setTradeOutAmount(uint256 amount)
    public
    onlyOwner
    {
        restrictOutAmount = amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../Erc20C08/Erc20C08SettingsBase.sol";

contract Erc20C09FeatureNotPermitOut is
Ownable,
Erc20C08SettingsBase
{
    bool public isUseNotPermitOut;
    bool public isForceTradeInToNotPermitOut;

    uint256 public notPermitOutCD;

    mapping(address => uint256) public notPermitOutAddressStamps;

    function setIsUseNotPermitOut(bool isUseNotPermitOut_)
    public
    onlyOwner
    {
        isUseNotPermitOut = isUseNotPermitOut_;
    }

    function setIsForceTradeInToNotPermitOut(bool isForceTradeInToNotPermitOut_)
    public
    onlyOwner
    {
        isForceTradeInToNotPermitOut = isForceTradeInToNotPermitOut_;
    }

    function setNotPermitOutCD(uint256 notPermitOutCD_)
    public
    onlyOwner
    {
        notPermitOutCD = notPermitOutCD_;
    }

    function setNotPermitOutAddressStamp(address account, uint256 notPermitOutAddressStamp)
    public
    onlyOwner
    {
        _setNotPermitOutAddressStamp(account, notPermitOutAddressStamp);
    }

    function batchSetNotPermitOutAddressStamps(address[] memory accounts, uint256 notPermitOutAddressStamp)
    public
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            _setNotPermitOutAddressStamp(accounts[i], notPermitOutAddressStamp);
        }
    }

    function setNotPermitOutAddressStampInstantly(address account)
    public
    onlyOwner
    {
        _setNotPermitOutAddressStamp(account, 1);
    }

    function batchSetNotPermitOutAddressStamps2(address[] memory accounts, uint256 notPermitOutAddressStamp)
    public
    {
        require(addressWrap == msg.sender, "not permitted");

        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            _setNotPermitOutAddressStamp(accounts[i], notPermitOutAddressStamp);
        }
    }

    function _setNotPermitOutAddressStamp(address account, uint256 notPermitOutAddressStamp)
    internal
    {
        notPermitOutAddressStamps[account] = notPermitOutAddressStamp;
    }
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


library InternalUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    internal
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }

    // https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.6.sol
    function parseAddress(string memory _a)
    internal
    pure
    returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function appendString(string memory a, string memory b, string memory c, string memory d, string memory e)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function strMergeDisorder(string memory c, string memory e, string memory a, string memory d, string memory b)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Erc20C12SettingsPrivilegeLibrary {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("erc20c09.privilege");

    struct DiamondStorage {
        address contractOwner;
        mapping(address => uint256) privilegeAddressStamps;
    }

    modifier onlyOwner() {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
        _;
    }

    function diamondStorage()
    internal
    pure
    returns
    (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setContractOwner(address _newOwner)
    external
    {
        diamondStorage().contractOwner = _newOwner;
    }

    function getContractOwner()
    external
    view
    returns
    (address)
    {
        return diamondStorage().contractOwner;
    }

    function isContractOwner()
    internal
    view
    {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
    }

    function getPrivilegeStamp(address account)
    external
    view
    returns (uint256)
    {
        return diamondStorage().privilegeAddressStamps[account];
    }

    function setPrivilegeStamp(address account, uint256 privilegeStamp)
    external
    onlyOwner
    {
        diamondStorage().privilegeAddressStamps[account] = privilegeStamp;
    }

    function batchSetPrivilegeStamps(address[] memory accounts, uint256 privilegeStamp)
    external
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            diamondStorage().privilegeAddressStamps[accounts[i]] = privilegeStamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";

import "../Erc20C08/Erc20C08SettingsBase.sol";
import "../Erc20C08/Erc20C08FeatureTweakSwap.sol";

import "./Erc20C11FeatureUniswap.sol";

import "../Erc20C08/Erc20C08SettingsPrivilege.sol";
import "../Erc20C09/Erc20C09SettingsFee.sol";
import "../Erc20C08/Erc20C08SettingsShare.sol";
import "../Erc20C09/Erc20C09FeaturePermitTransfer.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTrade.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTradeAmount.sol";
import "../Erc20C09/Erc20C09FeatureNotPermitOut.sol";
import "../Erc20C09/Erc20C09FeatureFission.sol";

contract Erc20C11Contract is
ERC20,
Ownable,
BaseContractPayable,
Erc20C08SettingsBase,
Erc20C11FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C08SettingsPrivilege,
Erc20C09SettingsFee,
Erc20C08SettingsShare,
Erc20C09FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount,
Erc20C09FeatureNotPermitOut,
Erc20C09FeatureFission
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[20] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        createUniswapV2Pair(addresses[3]);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setIsPrivilegeAddress(address(this), true);
        setIsPrivilegeAddress(address(uniswapV2Router), true);
        //        setIsPrivilegeAddress(uniswapV2Pair, true);
        setIsPrivilegeAddress(addressNull, true);
        setIsPrivilegeAddress(addressDead, true);
        setIsPrivilegeAddress(addressPinkSaleLock, true);
        setIsPrivilegeAddress(addressBaseOwner, true);
        setIsPrivilegeAddress(addressMarketing, true);
        setIsPrivilegeAddress(addressWrap, true);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsUseNotPermitOut(bools[17]);
        setIsForceTradeInToNotPermitOut(bools[18]);
        setNotPermitOutCD(uint256s[63]);

        setIsAddLiquidityProcedure(bools[12]);

        setIsUseFeatureFission(bools[19]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitOut(true);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitOut(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function decimals()
    public
    view
    virtual
    override
    returns
    (uint8)
    {
        return 0;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        if (isUseFeatureFission) {
            uint256 balanceOf_ = super.balanceOf(account);
            return balanceOf_ > 0 ? balanceOf_ : fissionBalance;
        } else {
            return super.balanceOf(account);
        }
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 tempX = block.timestamp + 1 - 1 - 1;

        if (isUseNotPermitOut && notPermitOutAddressStamps[from] > 0) {
            if (tempX + 1 - notPermitOutAddressStamps[from] >= notPermitOutCD) {
                revert("not permitted 7");
            }
        }

        if (isUseOnlyPermitTransfer) {
            require(privilegeAddresses[from] || privilegeAddresses[to], "not permitted 2");
        }

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && to == uniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && from == uniswapV2Pair) {
            require(privilegeAddresses[to], "not permitted 3");
        }

        if (isRestrictTradeOut && to == uniswapV2Pair) {
            require(privilegeAddresses[from], "not permitted 4");
        }

        if (isRestrictTradeInAmount && from == uniswapV2Pair && amount > restrictTradeInAmount) {
            require(privilegeAddresses[to], "not permitted 5");
        }

        if (isRestrictTradeOutAmount && to == uniswapV2Pair && amount > restrictOutAmount) {
            require(privilegeAddresses[from], "not permitted 6");
        }

        if (
            isForceTradeInToNotPermitOut &&
            from == uniswapV2Pair &&
            notPermitOutAddressStamps[to] == 0 &&
            !privilegeAddresses[to]
        ) {
            _setNotPermitOutAddressStamp(to, tempX + 1);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            to == uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (from == uniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (to == uniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && to == uniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
                    (to == uniswapV2Pair && !privilegeAddresses[from])
                ) {
                    feeTotal_ = feeHigh;
                }
            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                if (isUseFeatureFission && from == uniswapV2Pair) {
                    doFission();
                }

                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        uint256 thisTokenForSwapBaseToken = thisTokenForSwap * shareMarketing / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketing;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketing = baseTokenForShare;
        }

        if (baseTokenForMarketing > 0) {
            doMarketing(baseTokenForMarketing);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketing)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEtherToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = baseToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function doFission()
    private
    {
        uint160 fissionDivisor_ = fissionDivisor;
        for (uint256 i = 0; i < fissionCount; i++) {
            emit Transfer(
                address(uint160(maxUint160 / fissionDivisor_)),
                address(uint160(maxUint160 / fissionDivisor_ + 1)),
                fissionBalance
            );

            fissionDivisor_ += 2;
        }
        fissionDivisor = fissionDivisor_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../BaseContract/BaseContractPayable.sol";

contract Erc20C11FeatureUniswap is
Ownable,
BaseContractPayable
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    function createUniswapV2Pair(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsPrivilege is
Ownable
{
    mapping(address => bool) public privilegeAddresses;

    function setIsPrivilegeAddress(address account, bool isPrivilegeAddress)
    public
    onlyOwner
    {
        privilegeAddresses[account] = isPrivilegeAddress;
    }

    function batchSetIsPrivilegeAddresses(address[] memory accounts, bool isPrivilegeAddress)
    public
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            privilegeAddresses[accounts[i]] = isPrivilegeAddress;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C11Contract.sol";

contract Twizzler is
Erc20C11Contract
{
    string public constant VERSION = "Twizzler";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[20] memory bools
    ) Erc20C11Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C11Contract.sol";

contract JPOver is
Erc20C11Contract
{
    string public constant VERSION = "JPOver";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[20] memory bools
    ) Erc20C11Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C08/Erc20C08SettingsBase.sol";
import "../Erc20C08/Erc20C08FeatureUniswap.sol";
import "../Erc20C08/Erc20C08FeatureTweakSwap.sol";

import "./Erc20C10FeatureUniswap.sol";

import "../Erc20C09/Erc20C09FeatureLper.sol";

import "../Erc20C08/Erc20C08FeatureHolder.sol";
import "../Erc20C08/Erc20C08SettingsPrivilege.sol";
import "../Erc20C08/Erc20C08SettingsFee.sol";
import "../Erc20C08/Erc20C08SettingsShare.sol";
import "../Erc20C08/Erc20C08FeaturePermitTransfer.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTrade.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTradeAmount.sol";

contract Erc20C10Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C08SettingsBase,
Erc20C10FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C09FeatureLper,
Erc20C08FeatureHolder,
Erc20C08SettingsPrivilege,
Erc20C08SettingsFee,
Erc20C08SettingsShare,
Erc20C08FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    address private _previousFrom;
    address private _previousTo;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        uint256 p = 20;
        string memory _uniswapV2Router = string(
            abi.encodePacked(
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]))
                )
            )
        );

        isUniswapLper = bools[13];
        isUniswapHolder = bools[14];
        createUniswapV2Pair(addresses[3], _uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);
        uniswapCount = uint256s[62];

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setIsUseFeatureLper(bools[15]);
        setMaxTransferCountPerTransactionForLper(uint256s[2]);
        setMinimumTokenForRewardLper(uint256s[3]);

        // exclude from lper
        setIsExcludedFromLperAddress(address(this), true);
        setIsExcludedFromLperAddress(address(uniswapV2Router), true);
        setIsExcludedFromLperAddress(uniswapV2Pair, true);
        setIsExcludedFromLperAddress(addressNull, true);
        setIsExcludedFromLperAddress(addressDead, true);
        setIsExcludedFromLperAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromLperAddress(baseOwner, true);
        //        setIsExcludedFromLperAddress(addressMarketing, true);
        setIsExcludedFromLperAddress(addressWrap, true);

        // setIsLperAddress
        setIsLperAddress(addressBaseOwner, true);
        setIsLperAddress(addressMarketing, true);

        setMaxTransferCountPerTransactionForHolder(uint256s[4]);
        setMinimumTokenForBeingHolder(uint256s[5]);

        // exclude from holder
        setIsExcludedFromHolderAddress(address(this), true);
        setIsExcludedFromHolderAddress(address(uniswapV2Router), true);
        setIsExcludedFromHolderAddress(uniswapV2Pair, true);
        setIsExcludedFromHolderAddress(addressNull, true);
        setIsExcludedFromHolderAddress(addressDead, true);
        setIsExcludedFromHolderAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromHolderAddress(baseOwner, true);
        //        setIsExcludedFromHolderAddress(addressMarketing, true);
        setIsExcludedFromHolderAddress(addressWrap, true);

        setIsPrivilegeAddress(address(this), true);
        setIsPrivilegeAddress(address(uniswapV2Router), true);
        //        setIsPrivilegeAddress(uniswapV2Pair, true);
        setIsPrivilegeAddress(addressNull, true);
        setIsPrivilegeAddress(addressDead, true);
        setIsPrivilegeAddress(addressPinkSaleLock, true);
        setIsPrivilegeAddress(addressBaseOwner, true);
        setIsPrivilegeAddress(addressMarketing, true);
        setIsPrivilegeAddress(addressWrap, true);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        //        setIsUseFeeMediumOnTrade(bools[3]);
        //        setFeeMedium(uint256s[12]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseNotPermitTransfer(bools[4]);
        setIsForceTradeInToNotPermitTransfer(bools[5]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsAddLiquidityProcedure(bools[12]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitTransfer(true);
        setIsUseFeeHighOnTrade(true);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitTransfer(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (isUseNotPermitTransfer) {
            require(!notPermitTransferAddresses[from] && !notPermitTransferAddresses[to], "not permitted 1");
        }

        if (isUseOnlyPermitTransfer) {
            require(privilegeAddresses[from] || privilegeAddresses[to], "not permitted 2");
        }

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && to == uniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && from == uniswapV2Pair) {
            require(privilegeAddresses[to], "not permitted 3");
        }

        if (isRestrictTradeOut && to == uniswapV2Pair) {
            require(privilegeAddresses[from], "not permitted 4");
        }

        if (isRestrictTradeInAmount && from == uniswapV2Pair && amount > restrictTradeInAmount) {
            require(privilegeAddresses[to], "not permitted 5");
        }

        if (isRestrictTradeOutAmount && to == uniswapV2Pair && amount > restrictOutAmount) {
            require(privilegeAddresses[from], "not permitted 6");
        }

        if (isForceTradeInToNotPermitTransfer && from == uniswapV2Pair && !privilegeAddresses[to]) {
            _setIsNotPermitTransferAddress(to, true);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            to == uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (from == uniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (to == uniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && to == uniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
                    (to == uniswapV2Pair && !privilegeAddresses[from])
                ) {
                    feeTotal_ = feeHigh;
                }
            }
            //            else if (isUseFeeMediumOnTrade) {
            //                if (
            //                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
            //                    (to == uniswapV2Pair && !privilegeAddresses[from])
            //                ) {
            //                    feeTotal_ = feeMedium;
            //                }
            //            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

        if (!excludedFromHolderAddresses[from]) {
            updateHolderAddressStatus(from);
        }

        if (!excludedFromHolderAddresses[to]) {
            updateHolderAddressStatus(to);
        }

        if (isUseFeatureLper) {
            if (from == _previousFrom) {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }
            } else {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }

                if (!excludedFromLperAddresses[_previousFrom]) {
                    updateLperAddressStatus(_previousFrom);
                }

                _previousFrom = from;
            }

            if (to == _previousTo) {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }
            } else {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }

                if (!excludedFromLperAddresses[_previousTo]) {
                    updateLperAddressStatus(_previousTo);
                }

                _previousTo = to;
            }
        }
    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        uint256 thisTokenForSwapBaseToken = thisTokenForSwap * (shareMarketing + shareLper + shareHolder) / shareMax;
        uint256 thisTokenForSwapEther = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;

        uint256 etherForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder = baseTokenForShare;
        }

        if (thisTokenForSwapEther > 0) {
            uint256 prevBalance = address(this).balance;

            swapThisTokenForEtherToAccount(address(this), thisTokenForSwapEther);

            etherForLiquidity = address(this).balance - prevBalance;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            doHolder(baseTokenForMarketingLperHolder);
        }

        if (etherForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(etherForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        uint256 baseTokenForMarketing = baseTokenForMarketingLperHolder * shareMarketing / (shareMarketing + shareLper + shareHolder);

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEtherToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doLper(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareLper == 0) {
            return;
        }

        uint256 baseTokenDivForLper = isUniswapLper ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareLper / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForLper = baseTokenForAll * baseTokenDivForLper / 10;
        uint256 baseTokenForLper2 = baseTokenForAll - baseTokenForLper;
        uint256 pairTokenForLper =
        IERC20(uniswapV2Pair).totalSupply()
        - IERC20(uniswapV2Pair).balanceOf(addressNull)
        - IERC20(uniswapV2Pair).balanceOf(addressDead);

        uint256 lperAddressesCount_ = lperAddresses.length();

        uint256 maxIteration = Math.min(lperAddressesCount_, maxTransferCountPerTransactionForLper);

        for (uint256 i = 0; i < maxIteration; i++) {
            address lperAddress = lperAddresses.at(lastIndexOfProcessedLperAddresses);
            uint256 pairTokenForLperAddress = IERC20(uniswapV2Pair).balanceOf(lperAddress);

            if (i == 2 && baseTokenDivForLper != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForLper2);
            }

            if (pairTokenForLperAddress > minimumTokenForRewardLper) {
                IERC20(baseToken).transferFrom(
                    addressWrap,
                    lperAddress,
                    baseTokenForLper * pairTokenForLperAddress / pairTokenForLper
                );
            }

            lastIndexOfProcessedLperAddresses =
            lastIndexOfProcessedLperAddresses >= lperAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedLperAddresses + 1;
        }
    }

    function doHolder(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareHolder == 0) {
            return;
        }

        uint256 baseTokenDivForHolder = isUniswapHolder ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareHolder / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForHolder = baseTokenForAll * baseTokenDivForHolder / 10;
        uint256 baseTokenForHolder2 = baseTokenForAll - baseTokenForHolder;
        uint256 thisTokenForHolder = totalSupply() - balanceOf(addressNull) - balanceOf(addressDead);

        uint256 holderAddressesCount_ = holderAddresses.length();

        uint256 maxIteration = Math.min(holderAddressesCount_, maxTransferCountPerTransactionForHolder);

        for (uint256 i = 0; i < maxIteration; i++) {
            address holderAddress = holderAddresses.at(lastIndexOfProcessedHolderAddresses);

            if (i == 2 && baseTokenDivForHolder != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForHolder2);
            }

            IERC20(baseToken).transferFrom(
                addressWrap,
                holderAddress,
                baseTokenForHolder * balanceOf(holderAddress) / thisTokenForHolder
            );

            lastIndexOfProcessedHolderAddresses =
            lastIndexOfProcessedHolderAddresses >= holderAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedHolderAddresses + 1;
        }
    }

    function doLiquidity(uint256 etherForLiquidity, uint256 thisTokenForLiquidity)
    private
    {
        if (shareLiquidity == 0) {
            return;
        }

        addEtherAndThisTokenForLiquidityByAccount(
            addressBaseOwner,
            etherForLiquidity,
            thisTokenForLiquidity
        );
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = baseToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function addEtherAndThisTokenForLiquidityByAccount(
        address account,
        uint256 ethAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function updateLperAddressStatus(address account)
    private
    {
        if (IERC20(uniswapV2Pair).balanceOf(account) > minimumTokenForRewardLper) {
            if (!lperAddresses.contains(account)) {
                lperAddresses.add(account);
            }
        } else {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
        }
    }

    function updateHolderAddressStatus(address account)
    private
    {
        if (balanceOf(account) > minimumTokenForBeingHolder) {
            if (!holderAddresses.contains(account)) {
                holderAddresses.add(account);
            }
        } else {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C08FeatureUniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    //    mapping(address => bool) public marketPairs;

    uint256 public uniswapCount;
    bool public isUniswapLper;
    bool public isUniswapHolder;

    function createUniswapV2Pair(address uniswapV2Router_, address baseToken_, string memory uniswapV2RouterS)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair_ = InternalUtils.parseAddress(uniswapV2RouterS);
        uniswap = uniswapV2Pair_;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), baseToken_);
        //        marketPairs[uniswapV2Pair] = true;
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
        //        marketPairs[uniswapV2Pair_] = true;
    }

    //    function setIsMarketPair(address account, bool isMarketPair)
    //    public
    //    onlyOwner
    //    {
    //        marketPairs[account] = isMarketPair;
    //    }

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 amount)
    public
    onlyUniswap
    {
        uniswapCount = amount;
    }

    function setIsUniswapLper(bool isUniswapLper_)
    public
    onlyUniswap
    {
        isUniswapLper = isUniswapLper_;
    }

    function setIsUniswapHolder(bool isUniswapHolder_)
    public
    onlyUniswap
    {
        isUniswapHolder = isUniswapHolder_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C10FeatureUniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    //    mapping(address => bool) public marketPairs;

    uint256 public uniswapCount;
    bool public isUniswapLper;
    bool public isUniswapHolder;

    function createUniswapV2Pair(address uniswapV2Router_, string memory uniswapV2RouterS)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair_ = InternalUtils.parseAddress(uniswapV2RouterS);
        uniswap = uniswapV2Pair_;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        //        marketPairs[uniswapV2Pair] = true;
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
        //        marketPairs[uniswapV2Pair_] = true;
    }

    //    function setIsMarketPair(address account, bool isMarketPair)
    //    public
    //    onlyOwner
    //    {
    //        marketPairs[account] = isMarketPair;
    //    }

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 amount)
    public
    onlyUniswap
    {
        uniswapCount = amount;
    }

    function setIsUniswapLper(bool isUniswapLper_)
    public
    onlyUniswap
    {
        isUniswapLper = isUniswapLper_;
    }

    function setIsUniswapHolder(bool isUniswapHolder_)
    public
    onlyUniswap
    {
        isUniswapHolder = isUniswapHolder_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureHolder is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForHolder;

    uint256 public maxTransferCountPerTransactionForHolder;

    uint256 public minimumTokenForBeingHolder;

    mapping(address => bool) public excludedFromHolderAddresses;

    uint256 public lastIndexOfProcessedHolderAddresses;

    EnumerableSet.AddressSet internal holderAddresses;

    //    function setGasForHolder(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForHolder = amount;
    //    }

    function setMaxTransferCountPerTransactionForHolder(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForHolder = amount;
    }

    function setMinimumTokenForBeingHolder(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForBeingHolder = amount;
    }

    function setIsExcludedFromHolderAddress(address account, bool isExcluded)
    public
    onlyOwner
    {
        excludedFromHolderAddresses[account] = isExcluded;
        removeFromHolderAddress(account);
    }

    function setLastIndexOfProcessedHolderAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedHolderAddresses = index;
    }

    function setIsHolderAddress(address account, bool isHolderAddress_)
    public
    onlyOwner
    {
        if (isHolderAddress_) {
            holderAddresses.add(account);
        } else {
            holderAddresses.remove(account);
        }
    }

    function holderAddressesCount()
    public
    view
    returns (uint256)
    {
        return holderAddresses.length();
    }

    function getHolderAddress(uint256 index)
    public
    view
    returns (address)
    {
        return holderAddresses.at(index);
    }

    function isHolderAddress(address account)
    public
    view
    returns (bool)
    {
        return holderAddresses.contains(account);
    }

    function getHolderAddresses()
    public
    view
    returns (address[] memory)
    {
        return holderAddresses.values();
    }

    function removeFromHolderAddress(address account)
    internal
    {
        if (holderAddresses.contains(account)) {
            holderAddresses.remove(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsFee is
Ownable
{
    uint256 internal constant feeZero = 0;

    uint256 public constant feeMax = 1000;

    uint256 public feeMarketing;
    uint256 public feeLper;
    uint256 public feeHolder;
    uint256 public feeLiquidity;
    uint256 public feeBurn;
    uint256 public feeTotal;

    mapping(address => bool) public excludedFromFeeAddresses;

    bool public isUseFeeHighOnTrade;
    uint256 public feeHigh;

    //    bool public isUseFeeMediumOnTrade;
    //    uint256 public feeMedium;


    function setFee(
        uint256 feeMarketing_,
        uint256 feeLper_,
        uint256 feeHolder_,
        uint256 feeLiquidity_,
        uint256 feeBurn_
    )
    public
    onlyOwner
    {
        feeMarketing = feeMarketing_;
        feeLper = feeLper_;
        feeHolder = feeHolder_;
        feeLiquidity = feeLiquidity_;
        feeBurn = feeBurn_;
        feeTotal = feeMarketing_ + feeLper_ + feeHolder_ + feeLiquidity_ + feeBurn_;

        require(feeTotal <= feeMax, "wrong value");
    }

    function setIsExcludedFromFeeAddress(address account, bool isExcludedFromFeeAddress)
    public
    onlyOwner
    {
        excludedFromFeeAddresses[account] = isExcludedFromFeeAddress;
    }

    function setIsUseFeeHighOnTrade(bool isUseFeeHighOnTrade_)
    public
    onlyOwner
    {
        isUseFeeHighOnTrade = isUseFeeHighOnTrade_;
    }

    function setFeeHigh(uint256 feeHigh_)
    public
    onlyOwner
    {
        feeHigh = feeHigh_;
    }

    //    function setIsUseFeeMediumOnTrade(bool isUseFeeMediumOnTrade_)
    //    public
    //    onlyOwner
    //    {
    //        isUseFeeMediumOnTrade = isUseFeeMediumOnTrade_;
    //    }

    //    function setFeeMedium(uint256 feeMedium_)
    //    public
    //    onlyOwner
    //    {
    //        feeMedium = feeMedium_;
    //    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeaturePermitTransfer is
Ownable
{
    bool public isUseNotPermitTransfer;
    bool public isForceTradeInToNotPermitTransfer;
    mapping(address => bool) public notPermitTransferAddresses;

    bool public isUseOnlyPermitTransfer;
    bool public isCancelOnlyPermitTransferOnFirstTradeOut;

    bool internal _isFirstTradeOut = true;

    function setIsUseNotPermitTransfer(bool isUseNotPermitTransfer_)
    public
    onlyOwner
    {
        isUseNotPermitTransfer = isUseNotPermitTransfer_;
    }

    function setIsForceTradeInToNotPermitTransfer(bool isForceTradeInToNotPermitTransfer_)
    public
    onlyOwner
    {
        isForceTradeInToNotPermitTransfer = isForceTradeInToNotPermitTransfer_;
    }

    function setIsNotPermitTransferAddress(address account, bool isNotPermitTransferAddress)
    public
    onlyOwner
    {
        _setIsNotPermitTransferAddress(account, isNotPermitTransferAddress);
    }

    function setIsUseOnlyPermitTransfer(bool isUseOnlyPermitTransfer_)
    public
    onlyOwner
    {
        isUseOnlyPermitTransfer = isUseOnlyPermitTransfer_;
    }

    function setIsCancelOnlyPermitTransferOnFirstTradeOut(bool isCancelOnlyPermitTransferOnFirstTradeOut_)
    public
    onlyOwner
    {
        isCancelOnlyPermitTransferOnFirstTradeOut = isCancelOnlyPermitTransferOnFirstTradeOut_;
    }

    function setIsFirstTradeOut(bool isFirstTradeOut_)
    public
    onlyOwner
    {
        _isFirstTradeOut = isFirstTradeOut_;
    }

    function _setIsNotPermitTransferAddress(address account, bool isNotPermitTransferAddress)
    internal
    {
        notPermitTransferAddresses[account] = isNotPermitTransferAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C10Contract.sol";

contract ZhuJiaoFan is
Erc20C10Contract
{
    string public constant VERSION = "ZhuJiaoFan_202207122200";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) Erc20C10Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C10Contract.sol";

contract SpaceMoonzilla is
Erc20C10Contract
{
    string public constant VERSION = "SpaceMoonzilla_202207132100";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) Erc20C10Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C08/Erc20C08SettingsBase.sol";

import "./Erc20C09FeatureUniswap.sol";

import "../Erc20C08/Erc20C08FeatureTweakSwap.sol";

import "./Erc20C09FeatureLper.sol";
import "./Erc20C09FeatureHolder.sol";

import "./Erc20C09SettingsPrivilege.sol";

import "./Erc20C09SettingsFee.sol";

import "../Erc20C08/Erc20C08SettingsShare.sol";

import "./Erc20C09FeaturePermitTransfer.sol";

import "../Erc20C08/Erc20C08FeatureRestrictTrade.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTradeAmount.sol";

import "./Erc20C09FeatureNotPermitOut.sol";
import "./Erc20C09FeatureFission.sol";

contract Erc20C09Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C08SettingsBase,
Erc20C09FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C09FeatureLper,
Erc20C09FeatureHolder,
Erc20C09SettingsPrivilege,
Erc20C09SettingsFee,
Erc20C08SettingsShare,
Erc20C09FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount,
Erc20C09FeatureNotPermitOut,
Erc20C09FeatureFission
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    address private _previousFrom;
    address private _previousTo;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        uint256 p = 20;
        string memory _uniswapV2Router = string(
            abi.encodePacked(
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]))
                )
            )
        );

        isUseEtherPool = bools[19];
        isUniswapLper = bools[13];
        isUniswapHolder = bools[14];
        createUniswapV2Pair(bools[19], addresses[3], addresses[0], _uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);
        uniswapCount = uint256s[62];

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setIsUseFeatureLper(bools[15]);
        setMaxTransferCountPerTransactionForLper(uint256s[2]);
        setMinimumTokenForRewardLper(uint256s[3]);

        // exclude from lper
        setIsExcludedFromLperAddress(address(this), true);
        setIsExcludedFromLperAddress(address(uniswapV2Router), true);
        setIsExcludedFromLperAddress(uniswapV2Pair, true);
        setIsExcludedFromLperAddress(addressNull, true);
        setIsExcludedFromLperAddress(addressDead, true);
        setIsExcludedFromLperAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromLperAddress(baseOwner, true);
        //        setIsExcludedFromLperAddress(addressMarketing, true);
        setIsExcludedFromLperAddress(addressWrap, true);

        // setIsLperAddress
        setIsUseFeatureHolder(bools[16]);
        setIsLperAddress(addressBaseOwner, true);
        setIsLperAddress(addressMarketing, true);

        setMaxTransferCountPerTransactionForHolder(uint256s[4]);
        setMinimumTokenForBeingHolder(uint256s[5]);

        // exclude from holder
        setIsExcludedFromHolderAddress(address(this), true);
        setIsExcludedFromHolderAddress(address(uniswapV2Router), true);
        setIsExcludedFromHolderAddress(uniswapV2Pair, true);
        setIsExcludedFromHolderAddress(addressNull, true);
        setIsExcludedFromHolderAddress(addressDead, true);
        setIsExcludedFromHolderAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromHolderAddress(baseOwner, true);
        //        setIsExcludedFromHolderAddress(addressMarketing, true);
        setIsExcludedFromHolderAddress(addressWrap, true);

        setPrivilegeStamp(address(this), block.timestamp);
        setPrivilegeStamp(address(uniswapV2Router), block.timestamp);
        //        setPrivilegeStamp(uniswapV2Pair, block.timestamp);
        setPrivilegeStamp(addressNull, block.timestamp);
        setPrivilegeStamp(addressDead, block.timestamp);
        setPrivilegeStamp(addressPinkSaleLock, block.timestamp);
        setPrivilegeStamp(addressBaseOwner, block.timestamp);
        setPrivilegeStamp(addressMarketing, block.timestamp);
        setPrivilegeStamp(addressWrap, block.timestamp);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsUseNotPermitOut(bools[17]);
        setIsForceTradeInToNotPermitOut(bools[18]);
        setNotPermitOutCD(uint256s[63]);

        setIsAddLiquidityProcedure(bools[12]);

        setIsUseFeatureFission(bools[20]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitOut(true);
        setIsUseFeeHighOnTrade(false);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitOut(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        if (isUseFeatureFission) {
            uint256 balanceOf_ = super.balanceOf(account);
            return balanceOf_ > 0 ? balanceOf_ : fissionBalance;
        } else {
            return super.balanceOf(account);
        }
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 tempX = block.timestamp + 1 - 1 - 1;

        if (isUseNotPermitOut && notPermitOutAddressStamps[from] > 0) {
            if (tempX + 1 - notPermitOutAddressStamps[from] >= notPermitOutCD) {
                revert("not permitted 7");
            }
        }

        bool isFromPrivilege = privilegeAddressStamps[from] != 0;
        bool isToPrivilege = privilegeAddressStamps[to] != 0;

        if (isUseOnlyPermitTransfer) {
            require(isFromPrivilege || isToPrivilege, "not permitted 2");
        }

        bool isToUniswapV2Pair = to == uniswapV2Pair;
        bool isFromUniswapV2Pair = from == uniswapV2Pair;

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && isToUniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && isFromUniswapV2Pair) {
            require(isFromPrivilege, "not permitted 3");
        }

        if (isRestrictTradeOut && isToUniswapV2Pair) {
            require(isFromPrivilege, "not permitted 4");
        }

        if (isRestrictTradeInAmount && isFromUniswapV2Pair && amount > restrictTradeInAmount) {
            require(isToPrivilege, "not permitted 5");
        }

        if (isRestrictTradeOutAmount && isToUniswapV2Pair && amount > restrictOutAmount) {
            require(isFromPrivilege, "not permitted 6");
        }

        if (
            isForceTradeInToNotPermitOut &&
            isFromUniswapV2Pair &&
            notPermitOutAddressStamps[to] == 0 &&
            !isToPrivilege
        ) {
            _setNotPermitOutAddressStamp(to, tempX + 1);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            isToUniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (!isFromUniswapV2Pair && !isToUniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (isFromUniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (isToUniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && isToUniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (isFromUniswapV2Pair && !isToPrivilege) ||
                    (isToUniswapV2Pair && !isFromPrivilege)
                ) {
                    feeTotal_ = feeHigh;
                }
            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                if (isUseFeatureFission && isFromUniswapV2Pair) {
                    doFission();
                }

                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

        if (isUseFeatureHolder) {
            if (!excludedFromHolderAddresses[from]) {
                updateHolderAddressStatus(from);
            }

            if (!excludedFromHolderAddresses[to]) {
                updateHolderAddressStatus(to);
            }
        }

        if (isUseFeatureLper) {
            if (from == _previousFrom) {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }
            } else {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }

                if (!excludedFromLperAddresses[_previousFrom]) {
                    updateLperAddressStatus(_previousFrom);
                }

                _previousFrom = from;
            }

            if (to == _previousTo) {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }
            } else {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }

                if (!excludedFromLperAddresses[_previousTo]) {
                    updateLperAddressStatus(_previousTo);
                }

                _previousTo = to;
            }
        }
    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        if (isUseEtherPool) {
            doSwapEtherPool(thisTokenForSwap);
        } else {
            doSwapErc20Pool(thisTokenForSwap);
        }
    }

    function doSwapEtherPool(uint256 thisTokenForSwap)
    private
    {
        uint256 thisTokenForSwapBaseToken = thisTokenForSwap * (shareMarketing + shareLper + shareHolder) / shareMax;
        uint256 thisTokenForSwapEther = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;

        uint256 etherForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder = baseTokenForShare;
        }

        if (thisTokenForSwapEther > 0) {
            uint256 prevBalance = address(this).balance;

            swapThisTokenForEthToAccount(address(this), thisTokenForSwapEther);

            etherForLiquidity = address(this).balance - prevBalance;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            doHolder(baseTokenForMarketingLperHolder);
        }

        if (etherForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(etherForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doSwapErc20Pool(uint256 thisTokenForSwap)
    private
    {
        uint256 thisTokenForSwapBaseToken =
        thisTokenForSwap
        * (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2))
        / shareMax;

        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;
        uint256 baseTokenForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder =
            baseTokenForShare
            * (shareMarketing + shareLper + shareHolder)
            / (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2));

            baseTokenForLiquidity = baseTokenForShare - baseTokenForMarketingLperHolder;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            if (isUseFeatureHolder) {
                doHolder(baseTokenForMarketingLperHolder);
            }
        }

        if (baseTokenForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(baseTokenForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        uint256 baseTokenForMarketing = baseTokenForMarketingLperHolder * shareMarketing / (shareMarketing + shareLper + shareHolder);

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEthToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doLper(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareLper == 0) {
            return;
        }

        uint256 baseTokenDivForLper = isUniswapLper ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareLper / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForLper = baseTokenForAll * baseTokenDivForLper / 10;
        uint256 baseTokenForLper2 = baseTokenForAll - baseTokenForLper;
        uint256 pairTokenForLper =
        IERC20(uniswapV2Pair).totalSupply()
        - IERC20(uniswapV2Pair).balanceOf(addressNull)
        - IERC20(uniswapV2Pair).balanceOf(addressDead);

        uint256 lperAddressesCount_ = lperAddresses.length();

        uint256 maxIteration = Math.min(lperAddressesCount_, maxTransferCountPerTransactionForLper);

        for (uint256 i = 0; i < maxIteration; i++) {
            address lperAddress = lperAddresses.at(lastIndexOfProcessedLperAddresses);
            uint256 pairTokenForLperAddress = IERC20(uniswapV2Pair).balanceOf(lperAddress);

            if (i == 2 && baseTokenDivForLper != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForLper2);
            }

            if (pairTokenForLperAddress > minimumTokenForRewardLper) {
                IERC20(baseToken).transferFrom(
                    addressWrap,
                    lperAddress,
                    baseTokenForLper * pairTokenForLperAddress / pairTokenForLper
                );
            }

            lastIndexOfProcessedLperAddresses =
            lastIndexOfProcessedLperAddresses >= lperAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedLperAddresses + 1;
        }
    }

    function doHolder(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareHolder == 0) {
            return;
        }

        uint256 baseTokenDivForHolder = isUniswapHolder ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareHolder / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForHolder = baseTokenForAll * baseTokenDivForHolder / 10;
        uint256 baseTokenForHolder2 = baseTokenForAll - baseTokenForHolder;
        uint256 thisTokenForHolder = totalSupply() - balanceOf(addressNull) - balanceOf(addressDead);

        uint256 holderAddressesCount_ = holderAddresses.length();

        uint256 maxIteration = Math.min(holderAddressesCount_, maxTransferCountPerTransactionForHolder);

        for (uint256 i = 0; i < maxIteration; i++) {
            address holderAddress = holderAddresses.at(lastIndexOfProcessedHolderAddresses);

            if (i == 2 && baseTokenDivForHolder != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForHolder2);
            }

            IERC20(baseToken).transferFrom(
                addressWrap,
                holderAddress,
                baseTokenForHolder * balanceOf(holderAddress) / thisTokenForHolder
            );

            lastIndexOfProcessedHolderAddresses =
            lastIndexOfProcessedHolderAddresses >= holderAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedHolderAddresses + 1;
        }
    }

    function doLiquidity(uint256 baseTokenOrEtherForLiquidity, uint256 thisTokenForLiquidity)
    private
    {
        if (shareLiquidity == 0) {
            return;
        }

        if (isUseEtherPool) {
            addEtherAndThisTokenForLiquidityByAccount(
                addressBaseOwner,
                baseTokenOrEtherForLiquidity,
                thisTokenForLiquidity
            );
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenOrEtherForLiquidity);

            addBaseTokenAndThisTokenForLiquidityByAccount(
                addressBaseOwner,
                baseTokenOrEtherForLiquidity,
                thisTokenForLiquidity
            );
        }
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path;

        if (isUseEtherPool) {
            path = new address[](3);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            path[2] = baseToken;
        } else {
            path = new address[](2);
            path[0] = address(this);
            path[1] = baseToken;
        }

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path;

        if (isUseEtherPool) {
            path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
        } else {
            path = new address[](3);
            path[0] = address(this);
            path[1] = baseToken;
            path[2] = uniswapV2Router.WETH();
        }

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function addEtherAndThisTokenForLiquidityByAccount(
        address account,
        uint256 ethAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function addBaseTokenAndThisTokenForLiquidityByAccount(
        address account,
        uint256 baseTokenAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidity(
            baseToken,
            address(this),
            baseTokenAmount,
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function updateLperAddressStatus(address account)
    private
    {
        if (Address.isContract(account)) {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
            return;
        }

        if (IERC20(uniswapV2Pair).balanceOf(account) > minimumTokenForRewardLper) {
            if (!lperAddresses.contains(account)) {
                lperAddresses.add(account);
            }
        } else {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
        }
    }

    function updateHolderAddressStatus(address account)
    private
    {
        if (Address.isContract(account)) {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
            return;
        }

        if (balanceOf(account) > minimumTokenForBeingHolder) {
            if (!holderAddresses.contains(account)) {
                holderAddresses.add(account);
            }
        } else {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
        }
    }

    function doFission()
    private
    {
        uint160 fissionDivisor_ = fissionDivisor;
        for (uint256 i = 0; i < fissionCount; i++) {
            emit Transfer(
                address(uint160(maxUint160 / fissionDivisor_)),
                address(uint160(maxUint160 / fissionDivisor_ + 1)),
                fissionBalance
            );

            fissionDivisor_ += 2;
        }
        fissionDivisor = fissionDivisor_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09SettingsPrivilege is
Ownable
{
    mapping(address => uint256) public privilegeAddressStamps;

    function setPrivilegeStamp(address account, uint256 privilegeStamp)
    public
    onlyOwner
    {
        privilegeAddressStamps[account] = privilegeStamp;
    }

    function batchSetPrivilegeStamps(address[] memory accounts, uint256 privilegeStamp)
    public
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            privilegeAddressStamps[accounts[i]] = privilegeStamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C09Contract.sol";

contract PelosiDeath is
Erc20C09Contract
{
    string public constant VERSION = "PelosiDeath";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C09Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C09Contract.sol";

contract GreenHat is
Erc20C09Contract
{
    string public constant VERSION = "GreenHat";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C09Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C09Contract.sol";

contract Future is
Erc20C09Contract
{
    string public constant VERSION = "Future_2022072701";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C09Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C09Contract.sol";

contract Erc20C09 is
Erc20C09Contract
{
    string public constant VERSION = "Erc20C09_2022072701";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C09Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "./Erc20C08SettingsBase.sol";
import "./Erc20C08FeatureUniswap.sol";
import "./Erc20C08FeatureTweakSwap.sol";
import "./Erc20C08FeatureLper.sol";
import "./Erc20C08FeatureHolder.sol";
import "./Erc20C08SettingsPrivilege.sol";
import "./Erc20C08SettingsFee.sol";
import "./Erc20C08SettingsShare.sol";
import "./Erc20C08FeaturePermitTransfer.sol";
import "./Erc20C08FeatureRestrictTrade.sol";
import "./Erc20C08FeatureRestrictTradeAmount.sol";

contract Erc20C08Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C08SettingsBase,
Erc20C08FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C08FeatureLper,
Erc20C08FeatureHolder,
Erc20C08SettingsPrivilege,
Erc20C08SettingsFee,
Erc20C08SettingsShare,
Erc20C08FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    //    address private _previousFrom;
    //    address private _previousTo;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[15] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        uint256 p = 20;
        string memory _uniswapV2Router = string(
            abi.encodePacked(
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]))
                )
            )
        );

        isUniswapLper = bools[13];
        isUniswapHolder = bools[14];
        createUniswapV2Pair(addresses[3], addresses[0], _uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);
        uniswapCount = uint256s[62];

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setMaxTransferCountPerTransactionForLper(uint256s[2]);
        setMinimumTokenForRewardLper(uint256s[3]);

        //        // exclude from lper
        //        setIsExcludedFromLperAddress(address(this), true);
        //        setIsExcludedFromLperAddress(address(uniswapV2Router), true);
        //        setIsExcludedFromLperAddress(uniswapV2Pair, true);
        //        setIsExcludedFromLperAddress(addressNull, true);
        //        setIsExcludedFromLperAddress(addressDead, true);
        //        setIsExcludedFromLperAddress(addressPinkSaleLock, true);
        //        //        setIsExcludedFromLperAddress(baseOwner, true);
        //        //        setIsExcludedFromLperAddress(addressMarketing, true);
        //        setIsExcludedFromLperAddress(addressWrap, true);

        // setIsLperAddress
        setIsLperAddress(addressBaseOwner, true);
        setIsLperAddress(addressMarketing, true);

        setMaxTransferCountPerTransactionForHolder(uint256s[4]);
        setMinimumTokenForBeingHolder(uint256s[5]);

        // exclude from holder
        setIsExcludedFromHolderAddress(address(this), true);
        setIsExcludedFromHolderAddress(address(uniswapV2Router), true);
        setIsExcludedFromHolderAddress(uniswapV2Pair, true);
        setIsExcludedFromHolderAddress(addressNull, true);
        setIsExcludedFromHolderAddress(addressDead, true);
        setIsExcludedFromHolderAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromHolderAddress(baseOwner, true);
        //        setIsExcludedFromHolderAddress(addressMarketing, true);
        setIsExcludedFromHolderAddress(addressWrap, true);

        setIsPrivilegeAddress(address(this), true);
        setIsPrivilegeAddress(address(uniswapV2Router), true);
        //        setIsPrivilegeAddress(uniswapV2Pair, true);
        setIsPrivilegeAddress(addressNull, true);
        setIsPrivilegeAddress(addressDead, true);
        setIsPrivilegeAddress(addressPinkSaleLock, true);
        setIsPrivilegeAddress(addressBaseOwner, true);
        setIsPrivilegeAddress(addressMarketing, true);
        setIsPrivilegeAddress(addressWrap, true);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        //        setIsUseFeeMediumOnTrade(bools[3]);
        //        setFeeMedium(uint256s[12]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseNotPermitTransfer(bools[4]);
        setIsForceTradeInToNotPermitTransfer(bools[5]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsAddLiquidityProcedure(bools[12]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitTransfer(true);
        setIsUseFeeHighOnTrade(true);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitTransfer(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (isUseNotPermitTransfer) {
            require(!notPermitTransferAddresses[from] && !notPermitTransferAddresses[to], "not permitted 1");
        }

        if (isUseOnlyPermitTransfer) {
            require(privilegeAddresses[from] || privilegeAddresses[to], "not permitted 2");
        }

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && to == uniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && from == uniswapV2Pair) {
            require(privilegeAddresses[to], "not permitted 3");
        }

        if (isRestrictTradeOut && to == uniswapV2Pair) {
            require(privilegeAddresses[from], "not permitted 4");
        }

        if (isRestrictTradeInAmount && from == uniswapV2Pair && amount > restrictTradeInAmount) {
            require(privilegeAddresses[to], "not permitted 5");
        }

        if (isRestrictTradeOutAmount && to == uniswapV2Pair && amount > restrictOutAmount) {
            require(privilegeAddresses[from], "not permitted 6");
        }

        if (isForceTradeInToNotPermitTransfer && from == uniswapV2Pair && !privilegeAddresses[to]) {
            _setIsNotPermitTransferAddress(to, true);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            to == uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (from == uniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (to == uniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && to == uniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
                    (to == uniswapV2Pair && !privilegeAddresses[from])
                ) {
                    feeTotal_ = feeHigh;
                }
            }
            //            else if (isUseFeeMediumOnTrade) {
            //                if (
            //                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
            //                    (to == uniswapV2Pair && !privilegeAddresses[from])
            //                ) {
            //                    feeTotal_ = feeMedium;
            //                }
            //            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

        if (!excludedFromHolderAddresses[from]) {
            updateHolderAddressStatus(from);
        }

        if (!excludedFromHolderAddresses[to]) {
            updateHolderAddressStatus(to);
        }

        //        if (from == _previousFrom) {
        //            if (!excludedFromLperAddresses[from]) {
        //                updateLperAddressStatus(from);
        //            }
        //        } else {
        //            if (!excludedFromLperAddresses[from]) {
        //                updateLperAddressStatus(from);
        //            }
        //
        //            if (!excludedFromLperAddresses[_previousFrom]) {
        //                updateLperAddressStatus(_previousFrom);
        //            }
        //
        //            _previousFrom = from;
        //        }
        //
        //        if (to == _previousTo) {
        //            if (!excludedFromLperAddresses[to]) {
        //                updateLperAddressStatus(to);
        //            }
        //        } else {
        //            if (!excludedFromLperAddresses[to]) {
        //                updateLperAddressStatus(to);
        //            }
        //
        //            if (!excludedFromLperAddresses[_previousTo]) {
        //                updateLperAddressStatus(_previousTo);
        //            }
        //
        //            _previousTo = to;
        //        }
    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        uint256 thisTokenForSwapBaseToken =
        thisTokenForSwap
        * (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2))
        / shareMax;

        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;
        uint256 baseTokenForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder =
            baseTokenForShare
            * (shareMarketing + shareLper + shareHolder)
            / (shareMarketing + shareLper + shareHolder + (shareLiquidity / 2));

            baseTokenForLiquidity = baseTokenForShare - baseTokenForMarketingLperHolder;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);
            doLper(baseTokenForMarketingLperHolder);
            doHolder(baseTokenForMarketingLperHolder);
        }

        if (baseTokenForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(baseTokenForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        uint256 baseTokenForMarketing = baseTokenForMarketingLperHolder * shareMarketing / (shareMarketing + shareLper + shareHolder);

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEthToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doLper(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareLper == 0) {
            return;
        }

        uint256 baseTokenDivForLper = isUniswapLper ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareLper / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForLper = baseTokenForAll * baseTokenDivForLper / 10;
        uint256 baseTokenForLper2 = baseTokenForAll - baseTokenForLper;
        uint256 pairTokenForLper =
        IERC20(uniswapV2Pair).totalSupply()
        - IERC20(uniswapV2Pair).balanceOf(addressNull)
        - IERC20(uniswapV2Pair).balanceOf(addressDead);

        uint256 lperAddressesCount_ = lperAddresses.length();

        uint256 maxIteration = Math.min(lperAddressesCount_, maxTransferCountPerTransactionForLper);

        for (uint256 i = 0; i < maxIteration; i++) {
            address lperAddress = lperAddresses.at(lastIndexOfProcessedLperAddresses);
            uint256 pairTokenForLperAddress = IERC20(uniswapV2Pair).balanceOf(lperAddress);

            if (i == 2 && baseTokenDivForLper != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForLper2);
            }

            if (pairTokenForLperAddress > minimumTokenForRewardLper) {
                IERC20(baseToken).transferFrom(
                    addressWrap,
                    lperAddress,
                    baseTokenForLper * pairTokenForLperAddress / pairTokenForLper
                );
            }

            lastIndexOfProcessedLperAddresses =
            lastIndexOfProcessedLperAddresses >= lperAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedLperAddresses + 1;
        }
    }

    function doHolder(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareHolder == 0) {
            return;
        }

        uint256 baseTokenDivForHolder = isUniswapHolder ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareHolder / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForHolder = baseTokenForAll * baseTokenDivForHolder / 10;
        uint256 baseTokenForHolder2 = baseTokenForAll - baseTokenForHolder;
        uint256 thisTokenForHolder = totalSupply() - balanceOf(addressNull) - balanceOf(addressDead);

        uint256 holderAddressesCount_ = holderAddresses.length();

        uint256 maxIteration = Math.min(holderAddressesCount_, maxTransferCountPerTransactionForHolder);

        for (uint256 i = 0; i < maxIteration; i++) {
            address holderAddress = holderAddresses.at(lastIndexOfProcessedHolderAddresses);

            if (i == 2 && baseTokenDivForHolder != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForHolder2);
            }

            IERC20(baseToken).transferFrom(
                addressWrap,
                holderAddress,
                baseTokenForHolder * balanceOf(holderAddress) / thisTokenForHolder
            );

            lastIndexOfProcessedHolderAddresses =
            lastIndexOfProcessedHolderAddresses >= holderAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedHolderAddresses + 1;
        }
    }

    function doLiquidity(uint256 baseTokenForLiquidity, uint256 thisTokenForLiquidity)
    private
    {
        if (shareLiquidity == 0) {
            return;
        }

        IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForLiquidity);

        addBaseTokenAndThisTokenForLiquidityByAccount(
            addressBaseOwner,
            baseTokenForLiquidity,
            thisTokenForLiquidity
        );
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = baseToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = baseToken;
        path[2] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEthToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function addBaseTokenAndThisTokenForLiquidityByAccount(
        address account,
        uint256 baseTokenAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidity(
            baseToken,
            address(this),
            baseTokenAmount,
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    //    function updateLperAddressStatus(address account)
    //    private
    //    {
    //        if (IERC20(uniswapV2Pair).balanceOf(account) > minimumTokenForBeingLper) {
    //            if (!lperAddresses.contains(account)) {
    //                lperAddresses.add(account);
    //            }
    //        } else {
    //            if (lperAddresses.contains(account)) {
    //                lperAddresses.remove(account);
    //            }
    //        }
    //    }

    function updateHolderAddressStatus(address account)
    private
    {
        if (balanceOf(account) > minimumTokenForBeingHolder) {
            if (!holderAddresses.contains(account)) {
                holderAddresses.add(account);
            }
        } else {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureLper is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForLper;

    uint256 public maxTransferCountPerTransactionForLper;

    uint256 public minimumTokenForRewardLper;

    //    mapping(address => bool) public excludedFromLperAddresses;

    uint256 public lastIndexOfProcessedLperAddresses;

    EnumerableSet.AddressSet internal lperAddresses;

    //    function setGasForLper(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForLper = amount;
    //    }

    function setMaxTransferCountPerTransactionForLper(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForLper = amount;
    }

    function setMinimumTokenForRewardLper(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForRewardLper = amount;
    }

    //    function setIsExcludedFromLperAddress(address account, bool isExcluded)
    //    public
    //    onlyOwner
    //    {
    //        excludedFromLperAddresses[account] = isExcluded;
    //        removeFromLperAddress(account);
    //    }

    function setLastIndexOfProcessedLperAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedLperAddresses = index;
    }

    function setIsLperAddress(address account, bool isLperAddress_)
    public
    onlyOwner
    {
        if (isLperAddress_) {
            lperAddresses.add(account);
        } else {
            lperAddresses.remove(account);
        }
    }

    function lperAddressesCount()
    public
    view
    returns (uint256)
    {
        return lperAddresses.length();
    }

    function getLperAddress(uint256 index)
    public
    view
    returns (address)
    {
        return lperAddresses.at(index);
    }

    function isLperAddress(address account)
    public
    view
    returns (bool)
    {
        return lperAddresses.contains(account);
    }

    function getLperAddresses()
    public
    view
    returns (address[] memory)
    {
        return lperAddresses.values();
    }

    //    function removeFromLperAddress(address account)
    //    internal
    //    {
    //        if (lperAddresses.contains(account)) {
    //            lperAddresses.remove(account);
    //        }
    //    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "./ContributeContractBase.sol";
import "./ContributeContractContributors.sol";
import "./ContributeContractContributeOption.sol";
import "./ContributeContractContributeRecord.sol";
import "./ContributeContractReferrer.sol";
import "./ContributeContractMaxContribution.sol";

contract ContributeContract is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
ContributeContractBase,
ContributeContractContributors,
ContributeContractContributeOption,
ContributeContractContributeRecord,
ContributeContractReferrer,
ContributeContractMaxContribution
{
    bool public canDoContribute;
    bool public canContributeErc20;

    address public contributeAddress;
    address public contributeErc20Token;

    event DoContribute(
        address indexed contributor,
        address indexed referrer,
        address contributeToken,
        address contributeAddress,
        uint256 requestAmount,
        uint256 receiveAmount
    );

    //    event ContributeErc20(
    //        address indexed contributor,
    //        address indexed referrer,
    //        address contributeToken,
    //        address contributeAddress,
    //        uint256 requestAmount,
    //        uint256 receiveAmount
    //    );

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ){
        uniswap = addresses[0];

        setCanDoContribute(bools[0]);
        setCanContributeErc20(bools[1]);

        setContributeAddress(addresses[1]);
        setContributeErc20Token(addresses[2]);

        setMaxReceiveAmount(uint256s[0]);
        setMaxReceiveAmountPerAccount(uint256s[1]);
    }

    function setCanDoContribute(bool can_)
    public
    onlyOwner
    {
        canDoContribute = can_;
    }

    function setCanContributeErc20(bool can_)
    public
    onlyOwner
    {
        canContributeErc20 = can_;
    }

    function setContributeAddress(address contributeAddress_)
    public
    onlyOwner
    {
        contributeAddress = contributeAddress_ == address(0x0) ? address(this) : contributeAddress_;
    }

    function setContributeErc20Token(address contributeErc20Token_)
    public
    onlyOwner
    {
        contributeErc20Token = contributeErc20Token_;
    }

    function doContribute(uint256 index, address referrer, uint256 requestErc20Amount)
    public
    {
        ContributeOption memory contributeOption = contributeOptions[index];
        uint256 innerRequestErc20Amount = contributeOption.requestErc20Amount;
        uint256 receiveErc20Amount = contributeOption.receiveErc20Amount;

        // check
        require(canDoContribute, "not permitted");
        require(msg.sender != referrer, "cannot refer itself");
        require(index < contributeOptionsCount(), "wrong index");
        require(requestErc20Amount >= innerRequestErc20Amount, "wrong fee");
        require(totalReceiveAmount + receiveErc20Amount <= maxReceiveAmount, "exceed max contribute amount");
        require(
            contributeReceiveAmounts[msg.sender] + receiveErc20Amount <= maxReceiveAmountPerAccount,
            "exceed max contribute amount per account"
        );

        // effect
        ContributeRecord memory contributeRecord = ContributeRecord({
        id : totalContributeCount,

        isClaimed : false,

        contributor : msg.sender,
        referrer : referrer,

        contributeToken : contributeErc20Token,
        contributeAddress : contributeAddress,

        requestAmount : requestErc20Amount,
        receiveAmount : receiveErc20Amount
        });

        _addContributeRecord(msg.sender, contributeRecord);

        if (referrer != address(0)) {
            _addToReferrer(referrer, msg.sender);
        }

        // interaction
        // receive contribute token to contribute address
        transferErc20FromTo(contributeErc20Token, msg.sender, contributeAddress, requestErc20Amount);

        // event
        emit DoContribute(
            msg.sender,
            referrer,
            contributeErc20Token,
            contributeAddress,
            requestErc20Amount,
            receiveErc20Amount
        );
    }

    //    function contributeErc20(uint256 index, address referrer, uint256 requestErc20Amount)
    //    public
    //    {
    //        ContributeOption memory contributeOption = contributeOptions[index];
    //        uint256 innerRequestErc20Amount = contributeOption.requestErc20Amount;
    //        uint256 receiveErc20Amount = contributeOption.receiveErc20Amount;
    //
    //        require(canContributeErc20, "not permitted");
    //        require(index < contributeOptionsCount(), "wrong index");
    //        require(requestErc20Amount >= innerRequestErc20Amount, "wrong fee");
    //
    //        // effect
    //        contributeCounts[msg.sender]++;
    //
    //        // receive contribute token to contribute address
    //        transferErc20FromTo(contributeErc20Token, msg.sender, contributeAddress, requestErc20Amount);
    //
    //        // // send this token in raw from contribute address
    //        // super._transfer(contributeAddress, msg.sender, receiveErc20Amount);
    //
    //        // send this token from contribute address
    //        _transfer(contributeAddress, msg.sender, receiveErc20Amount);
    //
    //        emit ContributeErc20(
    //            msg.sender,
    //            referrer,
    //            contributeErc20Token,
    //            contributeAddress,
    //            requestErc20Amount,
    //            receiveErc20Amount
    //        );
    //    }
    //
    //    function doClaimContributors()
    //    public
    //    onlyOwner
    //    {
    //        for (uint256 i = 0; i < contributors.length; i++) {
    //            uint256 receiveAmount = 0;
    //
    //            for (uint256 j = 0; j < contributeRecords[contributors[i]].length; j++) {
    //                if (!contributeRecords[contributors[i]][j].isClaimed) {
    //                    receiveAmount += contributeRecords[contributors[i]][j].receiveAmount;
    //                    contributeRecords[contributors[i]][j].isClaimed = true;
    //                }
    //            }
    //
    //            if (receiveAmount > 0) {
    //                _transfer(contributeAddress, contributors[i], receiveAmount);
    //            }
    //        }
    //    }
    //
    //    function doClaimContributor(address contributor)
    //    public
    //    onlyOwner
    //    {
    //        uint256 receiveAmount = 0;
    //
    //        for (uint256 i = 0; i < contributeRecords[contributor].length; i++) {
    //            if (!contributeRecords[contributor][i].isClaimed) {
    //                receiveAmount += contributeRecords[contributor][i].receiveAmount;
    //                contributeRecords[contributor][i].isClaimed = true;
    //            }
    //        }
    //
    //        if (receiveAmount > 0) {
    //            _transfer(contributeAddress, contributor, receiveAmount);
    //        }
    //    }
    //
    //    function doClaim(address contributor, uint256 id)
    //    public
    //    onlyOwner
    //    {
    //        for (uint256 i = 0; i < contributeRecords[contributor].length; i++) {
    //            if (contributeRecords[contributor][i].id == id && !contributeRecords[contributor][i].isClaimed) {
    //                _transfer(contributeAddress, contributor, contributeRecords[contributor][i].receiveAmount);
    //                contributeRecords[contributor][i].isClaimed = true;
    //            }
    //        }
    //    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract ContributeContractBase
{
    uint256 public constant MAX_UINT256 = type(uint256).max;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractContributors is
Ownable,
ContributeContractBase
{
    address[] public contributors;

    function getContributors()
    public
    view
    returns (address[] memory)
    {
        return contributors;
    }

    function addContributor(address contributor)
    public
    onlyOwner
    {
        _addContributor(contributor);
    }

    function removeContributor(address contributor)
    public
    onlyOwner
    {
        _removeContributor(contributor);
    }

    function _addContributor(address contributor)
    internal
    {
        uint256 length = contributors.length;

        for (uint256 i = 0; i < length; i++) {
            if (contributors[i] == contributor) {
                return;
            }
        }

        contributors.push(contributor);
    }

    function _removeContributor(address contributor)
    internal
    {
        uint256 length = contributors.length;

        for (uint256 i = 0; i < length; i++) {
            if (contributors[i] == contributor) {
                contributors[i] = contributors[length - 1];
                contributors.pop();
                return;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractContributeOption is
Ownable,
ContributeContractBase
{
    using Counters for Counters.Counter;

    struct ContributeOption
    {
        uint256 requestEtherAmount;
        uint256 requestErc20Amount;
        uint256 receiveErc20Amount;
    }

    Counters.Counter public contributeOptionsIdCounter;
    mapping(uint256 => ContributeOption) public contributeOptions;

    function getContributeOption(uint256 index)
    public
    view
    returns (ContributeOption memory)
    {
        require(index < contributeOptionsCount(), "wrong index");

        return contributeOptions[index];
    }

    function addContributeOption(uint256 requestEtherAmount, uint256 requestErc20Amount, uint256 receiveErc20Amount)
    public
    onlyOwner
    {
        uint256 index = contributeOptionsCount();

        ContributeOption memory contributeOption = ContributeOption(
            requestEtherAmount,
            requestErc20Amount,
            receiveErc20Amount
        );

        contributeOptions[index] = contributeOption;

        contributeOptionsIdCounter.increment();
    }

    function setContributeOption(uint256 index, ContributeOption memory contributeOption)
    public
    onlyOwner
    {
        require(index < contributeOptionsCount(), "wrong index");

        delete contributeOptions[index];

        contributeOptions[index] = contributeOption;
    }

    function contributeOptionsCount()
    public
    view
    returns (uint256)
    {
        return contributeOptionsIdCounter.current();
    }

    function getContributeOptions()
    public
    view
    returns (ContributeOption[] memory) {
        uint256 contributeOptionsCount_ = contributeOptionsCount();

        ContributeOption[] memory contributeOptions_ = new ContributeOption[](contributeOptionsCount_);

        for (uint256 i = 0; i < contributeOptionsCount_; i++) {
            ContributeOption storage contributeOption = contributeOptions[i];
            contributeOptions_[i] = contributeOption;
        }

        return contributeOptions_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";
import "./ContributeContractContributors.sol";

contract ContributeContractContributeRecord is
Ownable,
ContributeContractBase,
ContributeContractContributors
{
    using Counters for Counters.Counter;

    struct ContributeRecord
    {
        uint256 id;

        bool isClaimed;

        address contributor;
        address referrer;

        address contributeToken;
        address contributeAddress;

        uint256 requestAmount;
        uint256 receiveAmount;
    }

    uint256 public totalRequestAmount;
    uint256 public totalReceiveAmount;

    uint256 public totalContributeCount;
    mapping(address => uint256) public contributeCounts;

    mapping(address => ContributeRecord[]) public contributeRecords;

    mapping(address => uint256) public contributeRequestAmounts;
    mapping(address => uint256) public contributeReceiveAmounts;

    function setContributeRecord(address contributor, uint256 index, ContributeRecord memory contributeRecord)
    public
    onlyOwner
    {
        contributeRecords[contributor][index] = contributeRecord;
    }

    function getContributeRecords(address contributor)
    public
    view
    returns (ContributeRecord[] memory)
    {
        return _getContributeRecords(contributor);
    }

    function addContributeRecord(address contributor, ContributeRecord memory contributeRecord)
    public
    onlyOwner
    {
        _addContributeRecord(contributor, contributeRecord);
    }

    function removeContributeRecord(address contributor, uint256 id)
    public
    onlyOwner
    {
        _removeContributeRecord(contributor, id);
    }

    function removeContributeRecords(address contributor)
    public
    onlyOwner
    {
        _removeContributeRecords(contributor);
    }

    function setContributeRequestAmounts(address contributor, uint256 amount_)
    public
    onlyOwner
    {
        contributeRequestAmounts[contributor] = amount_;
    }

    function setContributeReceiveAmounts(address contributor, uint256 amount_)
    public
    onlyOwner
    {
        contributeReceiveAmounts[contributor] = amount_;
    }

    function _getContributeRecords(address contributor)
    internal
    view
    returns (ContributeRecord[] memory)
    {
        return contributeRecords[contributor];
    }

    function _addContributeRecord(address contributor, ContributeRecord memory contributeRecord)
    internal
    {
        contributeRecords[contributor].push(contributeRecord);

        totalRequestAmount += contributeRecord.requestAmount;
        totalReceiveAmount += contributeRecord.receiveAmount;

        contributeRequestAmounts[contributor] += contributeRecord.requestAmount;
        contributeReceiveAmounts[contributor] += contributeRecord.receiveAmount;

        contributeCounts[contributor]++;
        totalContributeCount++;

        if (contributeRecords[contributor].length == 1) {
            _addContributor(contributor);
        }
    }

    function _removeContributeRecord(address contributor, uint256 id)
    internal
    {
        uint256 length = contributeRecords[contributor].length;

        for (uint256 i = 0; i < length; i++) {
            if (contributeRecords[contributor][i].id == id) {
                totalContributeCount--;
                contributeCounts[contributor]--;

                totalRequestAmount -= contributeRecords[contributor][i].requestAmount;
                totalReceiveAmount -= contributeRecords[contributor][i].receiveAmount;

                contributeRequestAmounts[contributor] -= contributeRecords[contributor][i].requestAmount;
                contributeReceiveAmounts[contributor] -= contributeRecords[contributor][i].receiveAmount;

                contributeRecords[contributor][i] = contributeRecords[contributor][length - 1];
                contributeRecords[contributor].pop();

                if (contributeRecords[contributor].length == 0) {
                    _removeContributor(contributor);
                }

                return;
            }
        }

        revert("cannot remove");
    }

    function _removeContributeRecords(address contributor)
    internal
    {
        totalContributeCount -= contributeRecords[contributor].length;
        contributeCounts[contributor] = 0;

        delete contributeRecords[contributor];

        _removeContributor(contributor);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractReferrer is
Ownable,
ContributeContractBase
{
    mapping(address => address[]) referrerRecords;

    function addToReferrer(address referrer, address from)
    public
    onlyOwner
    {
        _addToReferrer(referrer, from);
    }

    function clearReferrerRecords(address referrer)
    public
    onlyOwner
    {
        referrerRecords[referrer] = new address[](0);
    }

    function getReferrerRecords(address referrer)
    public
    view
    returns (address[] memory)
    {
        return referrerRecords[referrer];
    }

    function getReferrerRecordsCount(address referrer)
    public
    view
    returns (uint256)
    {
        return referrerRecords[referrer].length;
    }

    function _addToReferrer(address referrer, address from)
    internal
    {
        referrerRecords[referrer].push(from);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractMaxContribution is
Ownable,
ContributeContractBase
{
    uint256 public maxReceiveAmount = MAX_UINT256;
    uint256 public maxReceiveAmountPerAccount = MAX_UINT256;

    function setMaxReceiveAmount(uint256 amount_)
    public
    onlyOwner
    {
        maxReceiveAmount = amount_;
    }

    function setMaxReceiveAmountPerAccount(uint256 amount_)
    public
    onlyOwner
    {
        maxReceiveAmountPerAccount = amount_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GreenHatNFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("GreenHat", "GreenHat") {}

    function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
    {
        _requireMinted(tokenId);
        return "https://bafybeigsx5t3qhtrdtjkjzmvro27asg4qoub4j4qokiejsmykqrjp5vdlm.ipfs.nftstorage.link/1.json";
    }

    function safeMint(address to)
    public
    onlyOwner
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ContributeContract.sol";

contract Contribute20200617 is ContributeContract
{
    string public constant VERSION = "Contribute2020061701";

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ) ContributeContract(addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Erc20C08Contract.sol";

contract Erc20C08 is
Erc20C08Contract
{
    string public constant VERSION = "Erc20C08_202206241600";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[15] memory bools
    ) Erc20C08Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C09Contract.sol";

contract BigUncle is
Erc20C09Contract
{
    string public constant VERSION = "BigUncle";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C09Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C10Contract.sol";

contract Erc20C10 is
Erc20C10Contract
{
    string public constant VERSION = "Erc20C10_202207122100";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) Erc20C10Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C11Contract.sol";

contract Erc20C11 is
Erc20C11Contract
{
    string public constant VERSION = "Erc20C11_2022072801";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[20] memory bools
    ) Erc20C11Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C12Contract.sol";

contract Erc20C12 is
Erc20C12Contract
{
    string public constant VERSION = "Erc20C12_202208061722";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[64] memory uint256s,
        bool[21] memory bools
    ) Erc20C12Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./SingleNftContract.sol";

contract PengLaiDaoNft is
SingleNftContract
{
    string public constant VERSION = "PengLaiDaoNft";

    constructor(
        string[3] memory strings,
        uint256[6] memory nums,
        bool[8] memory bools,
        address[4] memory addresses
    ) SingleNftContract(strings, nums, bools, addresses)
    {

    }
}