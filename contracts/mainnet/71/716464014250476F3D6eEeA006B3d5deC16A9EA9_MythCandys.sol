// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ERC721.sol";
import "ERC20.sol";
import "Degen.sol";

contract MythCandys is ERC721 {
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public candyImageId;
    mapping(uint256 => bool) public candyImageIdExists;
    mapping(uint256 => candyStatStruct) public candyStats;
    struct candyStatStruct {
        address owner;
        CandyState candyState;
        uint256 imageId;
        uint256 statValue;
    }
    address public degenAddress;
    event candyMinted(
        address owner,
        uint256 candyId,
        uint256 candyStat,
        uint256 imageId
    );
    event candyImageAdded(uint256 imageId, string imageURL);
    event candyUpgraded(
        address owner,
        uint256 candyId,
        uint256 degenId,
        uint256 statType,
        uint256 oldStat,
        uint256 newStat
    );

    enum CandyState {
        OWNED,
        UPGRADED
    }

    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || msg.sender == owner,
            "Not white listed"
        );
        _;
    }

    constructor(address _degenAddress) ERC721("Myth City Candys", "MYTHCANDY") {
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        degenAddress = _degenAddress;
    }

    function setAddresses(address _degenAddress) external {
        require(msg.sender == owner, "only owner");
        if (_degenAddress != address(0)) {
            degenAddress = _degenAddress;
        }
    }

    function setImage(uint256 _imageId, string memory _imageUrl) external {
        require(msg.sender == owner, "only owner");
        candyImageId[_imageId] = _imageUrl;
        candyImageIdExists[_imageId] = true;
        emit candyImageAdded(_imageId, _imageUrl);
    }

    function removeImage(uint256 _imageId, string memory _imageUrl) external {
        require(msg.sender == owner, "only owner");
        candyImageId[_imageId] = _imageUrl;
        candyImageIdExists[_imageId] = false;
        emit candyImageAdded(_imageId, _imageUrl);
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
    }

    function transfer(uint256 _candyId, address _to) external {
        require(
            candyStats[_candyId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            candyStats[_candyId].candyState == CandyState.OWNED,
            "Cannot transfer when used"
        );
        _transfer(msg.sender, _to, _candyId);
        candyStats[_candyId].owner = _to;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _candyId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _candyId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            candyStats[_candyId].candyState == CandyState.OWNED,
            "Cannot transfer when used"
        );
        _transfer(from, _to, _candyId);
        candyStats[_candyId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            candyStats[tokenId].candyState == CandyState.OWNED,
            "Cannot transfer when used"
        );
        _safeTransfer(from, to, tokenId, data);
        candyStats[tokenId].owner = to;
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _statAmount
    ) external isWhitelisted returns (bool) {
        uint256 tempCount = tokenCount;
        require(
            candyImageIdExists[_imageId],
            "This image id is not available."
        );
        _mint(_to, tempCount);
        candyStats[tempCount].owner = _to;
        candyStats[tempCount].statValue = _statAmount;
        candyStats[tempCount].imageId = _imageId;
        emit candyMinted(_to, tempCount, _statAmount, _imageId);
        tokenCount++;
        return true;
    }

    function activateCandy(
        uint256 _candyId,
        uint256 _upgradeStat,
        uint256 _idOfItem
    ) external {
        require(_upgradeStat >= 1 && _upgradeStat <= 2, "Select correct stat");
        candyStatStruct memory tempStats = candyStats[_candyId];
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the candy can activate it"
        );
        require(tempStats.candyState == CandyState.OWNED, "Already Activated");
        MythDegen tempContract = MythDegen(degenAddress);
        MythDegen.stats memory tempDegenStat = tempContract.getStats(_idOfItem);
        require(tempDegenStat.owner == msg.sender, "You dont own that Degen");
        uint256 oldStat = 0;
        tempStats.candyState = CandyState.UPGRADED;

        candyStats[_candyId] = tempStats;
        if (_upgradeStat == 1) {
            oldStat = tempDegenStat.coreScore;
            tempContract.reGradeDegen(
                _idOfItem,
                oldStat + tempStats.statValue,
                0
            );
        } else if (_upgradeStat == 2) {
            oldStat = tempDegenStat.damageCap;
            tempContract.reGradeDegen(
                _idOfItem,
                0,
                oldStat + tempStats.statValue
            );
        }

        emit candyUpgraded(
            msg.sender,
            _candyId,
            _idOfItem,
            _upgradeStat,
            oldStat,
            oldStat + tempStats.statValue
        );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        candyStatStruct memory tempStats = candyStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        Base64.concatenate(
                            "Myth Candy #",
                            Base64.uint2str(tokenId)
                        ),
                        '",',
                        '"attributes": [{"trait_type": "Candy Id", "value": ',
                        Base64.uint2str(tokenId),
                        '},{"trait_type": "Stat Value", "value": ',
                        Base64.uint2str(tempStats.statValue),
                        '},{"trait_type": "Candy Status", "value": ',
                        Base64.uint2str(uint256(tempStats.candyState)),
                        "}",
                        "]",
                        ',"image_data" : "',
                        candyImageId[tempStats.imageId],
                        '","external_url": "mythcity.app","description":"A Sweet Piece of Candy."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "IERC721.sol";
import "IERC721Receiver.sol";
import "IERC721Metadata.sol";
import "Address.sol";
import "Context.sol";
import "Strings.sol";
import "ERC165.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

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

import "IERC721.sol";

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

import "IERC165.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

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

import "IERC20.sol";

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
pragma solidity 0.8.13;

// import "ERC20.sol";
import "ERC721.sol";
import "MythMods.sol";
import "MythCosmetic.sol";
import "MythWeapons.sol";
import "MythEquipment.sol";

contract MythDegen is ERC721 {
    address public cosmeticAddress;
    address public modsAddress;
    address public weaponsAddress;
    address public equipmentAddress;

    mapping(uint256 => stats) public degenStats;
    mapping(uint256 => equippedItems) public degenEquips;
    mapping(uint256 => cosmetics) public degenCosmetics;
    mapping(uint256 => defaultCosmetics) public degenDefaults;

    mapping(address => bool) public cosmeticWhitelist;
    mapping(address => bool) public degenWhitelist;
    mapping(address => bool) public whitelistedAddresses;

    mapping(uint256 => uint256) public defaultBackground;
    mapping(uint256 => uint256) public defaultEye;
    mapping(uint256 => uint256) public defaultMouth;
    mapping(uint256 => uint256) public defaultSkinColor;
    mapping(uint256 => uint256) public defaultNose;
    mapping(uint256 => uint256) public defaultHair;
    mapping(uint256 => mapping(uint256 => bool)) public defaultExists;

    address payable public owner;
    uint256 public tokenCount;

    struct equippedItems {
        uint256 weaponData;
        uint256 equipmentData;
        uint256 faceModData;
    }
    struct defaultCosmetics {
        uint256 background;
        uint256 bodyColor;
        uint256 nose;
        uint256 eyes;
        uint256 mouth;
        uint256 hair;
    }
    struct cosmetics {
        uint256 backgroundData;
        uint256 skinColorData;
        uint256 eyeData;
        uint256 eyeWearData;
        uint256 mouthData;
        uint256 noseData;
        uint256 hairData;
        uint256 headData;
        uint256 bodyData;
        uint256 bodyOuterData;
        uint256 chainData;
    }
    struct stats {
        uint256 coreScore;
        uint256 damageCap;
        address owner;
        bool inMission;
    }
    event defaultAdded(
        uint256 layerType,
        uint256 defaultId,
        uint256 cosmeticId
    );

    event itemEquipped(
        address owner,
        uint256 degenId,
        uint256 itemType,
        uint256 oldId,
        uint256 newId
    );

    event degenOnMission(uint256 degenId, bool onMission);

    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Not white listed");
        _;
    }
    modifier isDegenWhitelisted() {
        require(degenWhitelist[msg.sender], "Not Degen white listed");
        _;
    }
    modifier isCosmeticWhitelisted() {
        require(cosmeticWhitelist[msg.sender], "Not Cosmetic white listed");
        _;
    }

    constructor() ERC721("Myth City Degen", "MYDGN") {
        tokenCount = 1;
        owner = payable(msg.sender);
        whitelistedAddresses[msg.sender] = true;
        degenWhitelist[msg.sender] = true;
        cosmeticWhitelist[msg.sender] = true;
    }

    function setOnMission(uint256 _degenId, bool _missionSet)
        external
        isDegenWhitelisted
        returns (bool)
    {
        emit degenOnMission(_degenId, _missionSet);
        degenStats[_degenId].inMission = _missionSet;
    }

    function setAddresses(
        address _cosmetics,
        address _mods,
        address _weapons,
        address _equipments
    ) external isWhitelisted returns (bool) {
        cosmeticAddress = _cosmetics;
        modsAddress = _mods;
        weaponsAddress = _weapons;
        equipmentAddress = _equipments;
    }

    function forceTransferEquips(
        uint256 _degenId,
        address _from,
        address _to
    ) internal returns (bool) {
        equippedItems memory tempEquips = degenEquips[_degenId];
        if (tempEquips.faceModData > 0) {
            MythCityMods tempMods = MythCityMods(modsAddress);
            require(
                tempMods.overrideOwner(tempEquips.faceModData, _from, _to),
                "failed to transfer mods"
            );
        }
        if (tempEquips.weaponData > 0) {
            MythCityWeapons tempWeapons = MythCityWeapons(weaponsAddress);
            require(
                tempWeapons.overrideOwner(tempEquips.weaponData, _from, _to),
                "Failed to transfer Weapons"
            );
        }
        if (tempEquips.equipmentData > 0) {
            MythCityEquipment tempEquipment = MythCityEquipment(
                equipmentAddress
            );
            require(
                tempEquipment.overrideOwner(
                    tempEquips.equipmentData,
                    _from,
                    _to
                ),
                "Failed To transfer Equipment"
            );
        }

        MythCosmetic tempCosmeticContract = MythCosmetic(cosmeticAddress);
        require(
            tempCosmeticContract.overrideOwnerOfDegen(_degenId, _from, _to),
            "Failed To transfer Cosmetics"
        );
        return true;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _degenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _degenId),
            "ERC721: caller is not token owner or approved"
        );
        _transfer(from, _to, _degenId);
        degenStats[_degenId].owner = _to;
        require(
            forceTransferEquips(_degenId, from, _to),
            "Failed to transfer equips"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, data);
        degenStats[tokenId].owner = to;
        require(
            forceTransferEquips(tokenId, from, to),
            "Failed to transfer equips"
        );
    }

    // function withdraw() external {
    //     require(msg.sender == owner, "Not owner");
    //     owner.transfer(address(this).balance);
    // }

    function mint(
        address _to,
        uint256 _core,
        uint256 _damage,
        uint256[6] calldata _defaults
    ) public isDegenWhitelisted {
        uint256 tempCount = tokenCount;
        _mint(_to, tempCount);
        degenStats[tempCount] = stats(_core, _damage, _to, false);
        for (uint256 i = 0; i < 6; i++) {
            require(
                defaultExists[i][_defaults[i]],
                "This default cosmetic is not available"
            );
            if (i == 0) {
                degenDefaults[tempCount].background = _defaults[i];
            } else if (i == 1) {
                degenDefaults[tempCount].bodyColor = _defaults[i];
            } else if (i == 2) {
                degenDefaults[tempCount].nose = _defaults[i];
            } else if (i == 3) {
                degenDefaults[tempCount].eyes = _defaults[i];
            } else if (i == 4) {
                degenDefaults[tempCount].mouth = _defaults[i];
            } else if (i == 5) {
                degenDefaults[tempCount].hair = _defaults[i];
            }
        }
        tokenCount++;
    }

    // function changeDegenDefaults(
    //     uint256 _degenId,
    //     uint256[6] calldata _defaults
    // ) external isDegenWhitelisted {
    //     for (uint256 i = 0; i < 6; i++) {
    //         require(
    //             defaultExists[i][_defaults[i]],
    //             "This default cosmetic is not available"
    //         );
    //         if (i == 0) {
    //             degenDefaults[_degenId].background = _defaults[i];
    //         } else if (i == 1) {
    //             degenDefaults[_degenId].bodyColor = _defaults[i];
    //         } else if (i == 2) {
    //             degenDefaults[_degenId].nose = _defaults[i];
    //         } else if (i == 3) {
    //             degenDefaults[_degenId].eyes = _defaults[i];
    //         } else if (i == 4) {
    //             degenDefaults[_degenId].mouth = _defaults[i];
    //         } else if (i == 5) {
    //             degenDefaults[_degenId].hair = _defaults[i];
    //         }
    //     }
    // }

    // function burnToken(uint256 _id) external isWhitelisted {
    //     _burn(_id);
    // }

    // function upgradeDegen(
    //     uint256 _degenId,
    //     uint256 _addedCore,
    //     uint256 _addedDamage
    // ) external isDegenWhitelisted {
    //     degenStats[_degenId].coreScore += _addedCore;
    //     degenStats[_degenId].damageCap += _addedDamage;
    //     emit degenReGrade(
    //         _degenId,
    //         degenStats[_degenId].coreScore,
    //         degenStats[_degenId].damageCap
    //     );
    // }

    function reGradeDegen(
        uint256 _degenId,
        uint256 _newCore,
        uint256 _newDamage
    ) external isDegenWhitelisted returns (bool) {
        if (_newCore > 0) {
            degenStats[_degenId].coreScore = _newCore;
        }
        if (_newDamage > 0) {
            degenStats[_degenId].damageCap = _newDamage;
        }
        return true;
    }

    function getDegenEquips(uint256 _degenId)
        public
        view
        returns (equippedItems memory)
    {
        return degenEquips[_degenId];
    }

    function getDegenTotalCore(uint256 _degenId) public view returns (uint256) {
        uint256[2] memory _degenStats = getDegenStats(_degenId);
        uint256 overallCore = _degenStats[0] * 10**18;
        uint256 bonusCore = (overallCore / 100000) * _degenStats[1];
        overallCore = (overallCore + bonusCore) / 10**18;
        return overallCore;
    }

    function getDegenStats(uint256 _degenId)
        public
        view
        returns (uint256[2] memory)
    {
        uint256[2] memory tempNumbers;
        tempNumbers[0] += degenStats[_degenId].coreScore;
        tempNumbers[1] += degenStats[_degenId].damageCap;

        equippedItems memory tempDegen = degenEquips[_degenId];
        if (tempDegen.faceModData > 0) {
            MythCityMods tempMods = MythCityMods(modsAddress);
            MythCityMods.itemStat memory tempStats = tempMods.getStats(
                tempDegen.faceModData
            );
            tempNumbers[1] += tempStats.modStat;
        }
        if (tempDegen.equipmentData > 0) {
            MythCityEquipment tempEquipment = MythCityEquipment(
                equipmentAddress
            );
            MythCityEquipment.itemStat memory tempStats = tempEquipment
                .getStats(tempDegen.equipmentData);
            tempNumbers[0] += tempStats.equipmentStat;
        }
        if (tempDegen.weaponData > 0) {
            MythCityWeapons tempWeapon = MythCityWeapons(weaponsAddress);
            MythCityWeapons.itemStat memory tempStats = tempWeapon.getStats(
                tempDegen.weaponData
            );
            tempNumbers[0] += tempStats.weaponCore;
            tempNumbers[1] += tempStats.weaponDamage;
        }

        return tempNumbers;
    }

    function addCosmeticDefault(
        uint256 _layerType,
        uint256[] calldata _imageId,
        uint256[] calldata _urls
    ) external isWhitelisted {
        require(
            _imageId.length == _urls.length,
            "Lists need to be same length"
        );
        for (uint256 i = 0; i < _urls.length; i++) {
            require(_layerType >= 0 && _layerType <= 5, "");

            if (_layerType == 0) {
                defaultBackground[_imageId[i]] = _urls[i];
            } else if (_layerType == 1) {
                defaultSkinColor[_imageId[i]] = _urls[i];
            } else if (_layerType == 2) {
                defaultNose[_imageId[i]] = _urls[i];
            } else if (_layerType == 3) {
                defaultEye[_imageId[i]] = _urls[i];
            } else if (_layerType == 4) {
                defaultMouth[_imageId[i]] = _urls[i];
            } else if (_layerType == 5) {
                defaultHair[_imageId[i]] = _urls[i];
            }
            defaultExists[_layerType][_imageId[i]] = true;
            emit defaultAdded(_layerType, _imageId[i], _urls[i]);
        }
    }

    function updateWhitelist(address _address) external {
        require(msg.sender == owner, "Only owner can change the whitelist");
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
    }

    function alterCosmeticAddress(address _address) external isWhitelisted {
        cosmeticWhitelist[_address] = !cosmeticWhitelist[_address];
    }

    function alterDegenAddress(address _address) external isWhitelisted {
        degenWhitelist[_address] = !degenWhitelist[_address];
    }

    // function equipCosmetics(uint256 _degenId, uint256[] calldata _cosmeticIds)
    //     external
    // {
    //     for (uint256 i = 0; i < _cosmeticIds.length; i++) {
    //         equipCosmetic(_degenId, _cosmeticIds[i]);
    //     }
    // }

    function equipCosmetic(uint256 _degenId, uint256 _cosmeticId) public {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        MythCosmetic tempCosmetics = MythCosmetic(cosmeticAddress);
        MythCosmetic.itemStat memory tempStats = tempCosmetics.getStats(
            _cosmeticId
        );
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the cosmetic can use it"
        );
        bool isEquipped = tempCosmetics.equipCosmetic(_cosmeticId, _degenId);
        require(isEquipped, "Cosmetic was not equipped");

        uint256 _layerId = tempStats.layerType;
        if (_layerId == 0) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].backgroundData
            );
            degenCosmetics[_degenId].backgroundData = _cosmeticId;
        } else if (_layerId == 1) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].skinColorData
            );
            degenCosmetics[_degenId].skinColorData = _cosmeticId;
        } else if (_layerId == 2) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].eyeData
            );
            degenCosmetics[_degenId].eyeData = _cosmeticId;
        } else if (_layerId == 3) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].eyeWearData
            );
            degenCosmetics[_degenId].eyeWearData = _cosmeticId;
        } else if (_layerId == 4) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].mouthData
            );
            degenCosmetics[_degenId].mouthData = _cosmeticId;
        } else if (_layerId == 5) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].noseData
            );
            degenCosmetics[_degenId].noseData = _cosmeticId;
        } else if (_layerId == 6) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].hairData
            );
            degenCosmetics[_degenId].hairData = _cosmeticId;
        } else if (_layerId == 7) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].headData
            );
            degenCosmetics[_degenId].headData = _cosmeticId;
        } else if (_layerId == 8) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].bodyData
            );
            degenCosmetics[_degenId].bodyData = _cosmeticId;
        } else if (_layerId == 9) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].bodyOuterData
            );
            degenCosmetics[_degenId].bodyOuterData = _cosmeticId;
        } else if (_layerId == 10) {
            emit itemEquipped(
                msg.sender,
                _degenId,
                0,
                _cosmeticId,
                degenCosmetics[_degenId].chainData
            );
            degenCosmetics[_degenId].chainData = _cosmeticId;
        }
    }

    // function unequipCosmetics(uint256 _degenId, uint256[] calldata _layerIds)
    //     external
    // {
    //     for (uint256 i = 0; i < _layerIds.length; i++) {
    //         unequipCosmetic(_degenId, _layerIds[i]);
    //     }
    // }

    function unequipCosmetic(uint256 _degenId, uint256 _layerId) public {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        MythCosmetic tempCosmetics = MythCosmetic(cosmeticAddress);

        uint256 oldId = tempCosmetics.getIdOfCosmeticLayerAndDegen(
            _degenId,
            _layerId
        );
        bool isEquipped = tempCosmetics.unequipCosmetic(_degenId, _layerId);
        emit itemEquipped(msg.sender, _degenId, 0, oldId, 0);
        require(isEquipped, "Cosmetic was not un equipped");
        if (_layerId == 0) {
            delete degenCosmetics[_degenId].backgroundData;
        } else if (_layerId == 1) {
            delete degenCosmetics[_degenId].skinColorData;
        } else if (_layerId == 2) {
            delete degenCosmetics[_degenId].eyeData;
        } else if (_layerId == 3) {
            delete degenCosmetics[_degenId].eyeWearData;
        } else if (_layerId == 4) {
            delete degenCosmetics[_degenId].mouthData;
        } else if (_layerId == 5) {
            delete degenCosmetics[_degenId].noseData;
        } else if (_layerId == 6) {
            delete degenCosmetics[_degenId].hairData;
        } else if (_layerId == 7) {
            delete degenCosmetics[_degenId].headData;
        } else if (_layerId == 8) {
            delete degenCosmetics[_degenId].bodyData;
        } else if (_layerId == 9) {
            delete degenCosmetics[_degenId].bodyOuterData;
        } else if (_layerId == 10) {
            delete degenCosmetics[_degenId].chainData;
        }
    }

    function equipMod(uint256 _degenId, uint256 _modId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change mods when in mission"
        );
        MythCityMods tempMods = MythCityMods(modsAddress);
        MythCityMods.itemStat memory tempStats = tempMods.getStats(_modId);
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the mod can use it"
        );
        bool isEquipped = tempMods.equipMod(_modId, _degenId);
        require(isEquipped, "Mod was not equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            2,
            degenEquips[_degenId].faceModData,
            _modId
        );
        degenEquips[_degenId].faceModData = _modId;
    }

    function unequipMod(uint256 _degenId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change mods when in mission"
        );
        require(degenEquips[_degenId].faceModData > 0, "No mod equipped");
        MythCityMods tempMods = MythCityMods(modsAddress);
        bool isEquipped = tempMods.unequipMod(_degenId);
        require(isEquipped, "Mod was not un equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            2,
            degenEquips[_degenId].faceModData,
            0
        );
        delete degenEquips[_degenId].faceModData;
    }

    function equipWeapon(uint256 _degenId, uint256 _weaponId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change weapon when in mission"
        );
        MythCityWeapons tempWeapons = MythCityWeapons(weaponsAddress);
        MythCityWeapons.itemStat memory tempStats = tempWeapons.getStats(
            _weaponId
        );
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the weapon can use it"
        );
        bool isEquipped = tempWeapons.equipWeapon(_weaponId, _degenId);
        require(isEquipped, "Weapon was not equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            1,
            degenEquips[_degenId].weaponData,
            _weaponId
        );
        degenEquips[_degenId].weaponData = _weaponId;
    }

    function unequipWeapon(uint256 _degenId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change weapon when in mission"
        );
        require(degenEquips[_degenId].weaponData > 0, "No weapon equipped");
        MythCityWeapons tempWeapons = MythCityWeapons(weaponsAddress);
        bool isEquipped = tempWeapons.unequipWeapon(_degenId);
        require(isEquipped, "Weapon was not un equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            1,
            degenEquips[_degenId].weaponData,
            0
        );
        delete degenEquips[_degenId].weaponData;
    }

    function equipEquipment(uint256 _degenId, uint256 _equipmentId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change equipment when in mission"
        );
        MythCityEquipment tempEquipment = MythCityEquipment(equipmentAddress);
        MythCityEquipment.itemStat memory tempStats = tempEquipment.getStats(
            _equipmentId
        );
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the equipment can use it"
        );
        bool isEquipped = tempEquipment.equipEquipment(_equipmentId, _degenId);
        require(isEquipped, "Equipment was not equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            3,
            degenEquips[_degenId].equipmentData,
            _equipmentId
        );
        degenEquips[_degenId].equipmentData = _equipmentId;
    }

    function unequipEquipment(uint256 _degenId) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can use it"
        );
        require(
            !degenStats[_degenId].inMission,
            "Cant change equipment when in mission"
        );
        require(
            degenEquips[_degenId].equipmentData > 0,
            "No equipment equipped"
        );
        MythCityEquipment tempEquipment = MythCityEquipment(equipmentAddress);
        bool isEquipped = tempEquipment.unequipEquipment(_degenId);
        require(isEquipped, "Equipment was not un equipped");
        emit itemEquipped(
            msg.sender,
            _degenId,
            3,
            degenEquips[_degenId].equipmentData,
            0
        );
        delete degenEquips[_degenId].equipmentData;
    }

    function getWingsURL(uint256 _degenId) public view returns (string memory) {
        equippedItems memory tempEquipped = degenEquips[_degenId];
        if (tempEquipped.equipmentData == 0) {
            return "";
        }
        MythCityEquipment tempEquipment = MythCityEquipment(equipmentAddress);
        MythCityEquipment.itemStat memory tempStats = tempEquipment.getStats(
            tempEquipped.equipmentData
        );
        if (tempStats.isWings) {
            return tempEquipment.getImageURL(tempEquipped.equipmentData);
        } else {
            return "";
        }
    }

    function getDegenImage(uint256 _id)
        public
        view
        returns (string[13] memory)
    {
        string[13] memory tempList;
        tempList[0] = getBackgroundURL(_id);
        tempList[1] = getWingsURL(_id);
        tempList[2] = getSkinColorURL(_id);
        tempList[3] = getModURL(_id);
        tempList[4] = getEyeURL(_id);
        tempList[5] = getEyeWearURL(_id);
        tempList[6] = getMouthURL(_id);
        tempList[7] = getNoseURL(_id);
        tempList[8] = getHairURL(_id);
        tempList[9] = getHeadURL(_id);
        tempList[10] = getBodyURL(_id);
        tempList[11] = getBodyOuterURL(_id);
        tempList[12] = getChainURL(_id);
        return tempList;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        concatenate("Myth Degen #", Base64.uint2str(tokenId)),
                        '",',
                        '"attributes": [{"trait_type": "Degen Core Score","display_type": "number", "value": ',
                        Base64.uint2str(degenStats[tokenId].coreScore),
                        '},{"trait_type": "Degen Damage Cap","display_type": "number", "value": ',
                        Base64.uint2str(degenStats[tokenId].damageCap),
                        "},",
                        getExtraMetaData(tokenId),
                        "]",
                        ',"image_data" : "data:image/svg+xml;base64,',
                        Base64.encode(bytes(getImageLayers(tokenId))),
                        '","external_url": "mythcity.app","description":"A Myth City Degenerate. Will it go higher than the rest?"',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getExtraMetaData(uint256 _degenId)
        public
        view
        returns (string memory)
    {
        string memory json = concatenate(getWeaponURI(_degenId), ",");
        json = concatenate(json, getModURI(_degenId));
        json = concatenate(json, ",");
        json = concatenate(json, getEquipmentURI(_degenId));
        return json;
    }

    function getModURI(uint256 _degenId) public view returns (string memory) {
        equippedItems memory tempEquips = degenEquips[_degenId];
        if (tempEquips.faceModData > 0) {
            MythCityMods tempMods = MythCityMods(modsAddress);
            string memory json = tempMods.getDegenData(tempEquips.faceModData);

            return json;
        } else {
            string
                memory modMetaString = '{"trait_type":"Mod Id","value":0},{"trait_type":"Mod Damage","value":0},{"trait_type":"Mod Image Url","value":""}';
            return modMetaString;
        }
    }

    function getEquipmentURI(uint256 _degenId)
        public
        view
        returns (string memory)
    {
        equippedItems memory tempEquips = degenEquips[_degenId];
        if (tempEquips.equipmentData > 0) {
            MythCityEquipment tempEquipment = MythCityEquipment(
                equipmentAddress
            );
            string memory json = tempEquipment.getDegenData(
                tempEquips.equipmentData
            );

            return json;
        } else {
            string
                memory equipmentMetaString = '{"trait_type":"Equipment Id","value":0},{"trait_type":"Equipment Core","value":0},{"trait_type":"Equipment Route","value":0},{"trait_type":"Equipment Image Url","value":""}';
            return equipmentMetaString;
        }
    }

    function getWeaponURI(uint256 _degenId)
        public
        view
        returns (string memory)
    {
        equippedItems memory tempEquips = degenEquips[_degenId];
        if (tempEquips.weaponData > 0) {
            MythCityWeapons tempWeapons = MythCityWeapons(weaponsAddress);
            string memory json = tempWeapons.getDegenData(
                tempEquips.weaponData
            );
            return json;
        } else {
            string
                memory weaponMetaString = '{"trait_type":"Weapon Id","value":0},{"trait_type":"Weapon Core","value":0},{"trait_type":"Weapon Damage","value":0},{"trait_type":"Weapon Type","value":0},{"trait_type":"Weapon Image Url","value":""}';
            return weaponMetaString;
        }
    }

    function getImageLayers(uint256 _id) public view returns (string memory) {
        string memory innerString = "";
        string[13] memory tempList = getDegenImage(_id);
        for (uint256 i = 0; i < 13; i++) {
            if (bytes(tempList[i]).length != bytes("").length) {
                string memory tempIMG = concatenate(
                    '<image href="',
                    tempList[i]
                );
                tempIMG = concatenate(tempIMG, ' "/>');
                innerString = concatenate(innerString, tempIMG);
            }
        }
        return
            concatenate(
                concatenate(
                    '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 512 512">',
                    innerString
                ),
                "</svg>"
            );
    }

    function concatenate(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    function getStats(uint256 _id) external view returns (stats memory) {
        return degenStats[_id];
    }

    function getModURL(uint256 _id) public view returns (string memory) {
        if (degenEquips[_id].faceModData == 0) {
            return "";
        }
        return
            MythCityMods(modsAddress).getImageFromId(
                degenEquips[_id].faceModData
            );
    }

    function getBackgroundURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].backgroundData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    0,
                    defaultBackground[degenDefaults[_id].background]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].backgroundData
            );
    }

    function getNoseURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].noseData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    5,
                    defaultNose[degenDefaults[_id].nose]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].noseData
            );
    }

    function getBodyURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].bodyData == 0) {
            return "";
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].bodyData
            );
    }

    function getBodyOuterURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].bodyOuterData == 0) {
            return "";
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].bodyOuterData
            );
    }

    function getHairURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].hairData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    6,
                    defaultHair[degenDefaults[_id].hair]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].hairData
            );
    }

    function getHeadURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].headData == 0) {
            return "";
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].headData
            );
    }

    function getEyeURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].eyeData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    2,
                    defaultEye[degenDefaults[_id].eyes]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].eyeData
            );
    }

    function getMouthURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].mouthData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    4,
                    defaultMouth[degenDefaults[_id].mouth]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].mouthData
            );
    }

    function getSkinColorURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].skinColorData == 0) {
            return
                MythCosmetic(cosmeticAddress).getUrl(
                    1,
                    defaultSkinColor[degenDefaults[_id].bodyColor]
                );
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].skinColorData
            );
    }

    function getChainURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].chainData == 0) {
            return "";
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].chainData
            );
    }

    function getEyeWearURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].eyeWearData == 0) {
            return "";
        }
        return
            MythCosmetic(cosmeticAddress).getImageURL(
                degenCosmetics[_id].eyeWearData
            );
    }
}

library Base64 {
    string internal constant TABLE_ENCODE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes internal constant TABLE_DECODE =
        hex"0000000000000000000000000000000000000000000000000000000000000000"
        hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
        hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
        hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function concatenate(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                // read 4 characters
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                // write 3 bytes
                let output := add(
                    add(
                        shl(
                            18,
                            and(
                                mload(add(tablePtr, and(shr(24, input), 0xFF))),
                                0xFF
                            )
                        ),
                        shl(
                            12,
                            and(
                                mload(add(tablePtr, and(shr(16, input), 0xFF))),
                                0xFF
                            )
                        )
                    ),
                    add(
                        shl(
                            6,
                            and(
                                mload(add(tablePtr, and(shr(8, input), 0xFF))),
                                0xFF
                            )
                        ),
                        and(mload(add(tablePtr, and(input, 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}
// {"trait_type": "Class", "value": "Bartender"}
// {"trait_type": "Race", "value": "Ape"}
// {"trait_type": "Strength", "max_value": 100, "value": 81}
// {"trait_type": "Intelligence", "max_value": 100, "value": 73}
// {"trait_type": "Attractiveness", "max_value": 100, "value": 15}
// {"trait_type": "Tech Skill", "max_value": 100, "value": 81}
// {"trait_type": "Cool", "max_value": 100, "value": 92}
// {"trait_type": "Reward Rate", "value": 3}
// {"trait_type": "Eyes", "value": "Suspicious"}
// {"trait_type": "Ability", "value": "Dead Eye"}
// {"trait_type": "Location", "value": "Citadel Tower"}
// {"trait_type": "Additional Item", "value": "Wooden Cup"}
// {"trait_type": "Weapon", "value": "None"}
// {"trait_type": "Vehicle", "value": "Car 6"}
// {"trait_type": "Apparel", "value": "Suit 1"}
// {"trait_type": "Helm", "value": "Pilot Helm"}
// {"trait_type": "Gender", "value": "Male"}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ERC721.sol";
import "Degen.sol";

contract MythCityMods is ERC721 {
    //Myth Mods will have a image id, item stat
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public modURL;
    mapping(uint256 => string) public modName;
    mapping(uint256 => bool) public modExists;
    mapping(uint256 => uint256) public degenToMod;

    mapping(uint256 => itemStat) public modStats;

    event modAdded(uint256 id, string url, string nameOfToken);
    event modEquipped(
        uint256 modId,
        uint256 degenId,
        uint256 oldId,
        address owner
    );
    event modRegrade(uint256 modId, uint256 modStat);
    event modMinted(
        address to,
        uint256 imageId,
        uint256 itemStat,
        string modName
    );
    event ownerChanged(address to, uint256 modId);
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 modStat;
        uint256 degenIdEquipped;
        uint256 nameOfModId;
    }
    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || msg.sender == owner,
            "Not white listed"
        );
        _;
    }

    constructor(address _degenAddress) ERC721("Myth City Mod", "MYTHMOD") {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        whitelistedAddresses[_degenAddress] = true;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getDegenData(uint256 _modId) public view returns (string memory) {
        itemStat memory tempStats = modStats[_modId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Mod Id","display_type": "number", "value":',
                uint2str(_modId),
                '},{"trait_type":"Mod Damage","value":',
                uint2str(tempStats.modStat),
                '},{"trait_type":"Mod Image Url","value":"',
                getImageFromId(_modId),
                '"}'
            )
        );

        return json;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        itemStat memory tempStats = modStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        modName[tempStats.nameOfModId],
                        '",',
                        '"attributes": [{"trait_type": "Mod Id","display_type": "number",  "value":  ',
                        Base64.uint2str(tokenId),
                        '},{"trait_type": "Degen Id equipped to","display_type": "number",  "value": ',
                        Base64.uint2str(tempStats.degenIdEquipped),
                        '},{"trait_type": "Mod Damage", "value": ',
                        Base64.uint2str(tempStats.modStat),
                        "}",
                        "]",
                        ',"image_data" : "',
                        modURL[tempStats.imageId],
                        '","external_url": "mythcity.app","description":"Mods Used by Degenerates to boost their damage output."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getStats(uint256 _modId) public view returns (itemStat memory) {
        return modStats[_modId];
    }

    function getImageFromId(uint256 _id) public view returns (string memory) {
        return modURL[modStats[_id].imageId];
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }

    function transfer(uint256 _modId, address _to) external {
        require(
            modStats[_modId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            modStats[_modId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(msg.sender, _to, _modId);
        modStats[_modId].owner = _to;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _modId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _modId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            modStats[_modId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(from, _to, _modId);
        modStats[_modId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            modStats[tokenId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _safeTransfer(from, to, tokenId, data);
        modStats[tokenId].owner = to;
    }

    function equipMod(uint256 _modId, uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            modStats[_modId].degenIdEquipped == 0,
            "Mod is already Equipped"
        );
        modStats[_modId].degenIdEquipped = _degenId;
        uint256 tempOldId = degenToMod[_degenId];
        modStats[degenToMod[_degenId]].degenIdEquipped = 0;
        degenToMod[_degenId] = _modId;
        emit modEquipped(_modId, _degenId, tempOldId, modStats[_modId].owner);
        return true;
    }

    function unequipMod(uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        delete modStats[degenToMod[_degenId]].degenIdEquipped;
        uint256 tempOldId = degenToMod[_degenId];
        delete degenToMod[_degenId];
        emit modEquipped(
            0,
            _degenId,
            tempOldId,
            modStats[degenToMod[_degenId]].owner
        );
        return true;
    }

    function overrideOwner(
        uint256 _modId,
        address _from,
        address _newOwner
    ) external isWhitelisted returns (bool) {
        _transfer(_from, _newOwner, _modId);
        modStats[_modId].owner = _newOwner;
        return true;
    }

    function upgradeModStat(uint256 _modId, uint256 _statUpgrade)
        external
        isWhitelisted
    {
        modStats[_modId].modStat += _statUpgrade;
        emit modRegrade(_modId, modStats[_modId].modStat);
    }

    function regradeModStat(uint256 _modId, uint256 _statRegrade)
        external
        isWhitelisted
        returns (bool)
    {
        modStats[_modId].modStat = _statRegrade;
        emit modRegrade(_modId, modStats[_modId].modStat);
        return true;
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _modStat,
        uint256 _modName
    ) external isWhitelisted returns (bool) {
        _mint(_to, tokenCount);
        emit modMinted(_to, _imageId, _modStat, modName[_modName]);
        modStats[tokenCount] = itemStat(_to, _imageId, _modStat, 0, _modName);
        tokenCount++;
        return true;
    }

    function removeMod(uint256 _id) external isWhitelisted {
        delete modExists[_id];
        delete modURL[_id];
        delete modName[_id];
    }

    function changeMod(
        string[10] calldata _url,
        uint256[10] calldata _id,
        string[10] calldata _names
    ) external isWhitelisted {
        for (uint256 i = 0; i < 10; i++) {
            if (_id[i] > 0) {
                emit modAdded(_id[i], _url[i], _names[i]);
                modExists[_id[i]] = true;
                modURL[_id[i]] = _url[i];
                modName[_id[i]] = _names[i];
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "ERC721.sol";
import "Degen.sol";

contract MythCosmetic is ERC721 {
    address public owner;
    uint256 public tokenCount;

    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => itemStat) public cosmeticStats;
    mapping(uint256 => mapping(uint256 => string)) public cosmeticURL;
    mapping(uint256 => mapping(uint256 => string)) public cosmeticName;
    mapping(uint256 => mapping(uint256 => bool)) public cosmeticExists;
    mapping(uint256 => mapping(uint256 => uint256)) public degenToCosmetic;

    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    event ownerChanged(address to, uint256 cosmeticId);
    event cosmeticMinted(
        address to,
        uint256 imageId,
        uint256 layerType,
        uint256 nameId
    );

    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 layerType;
        uint256 nameId;
        uint256 degenIdEquipped;
    }
    event cosmeticAdded(
        uint256 layerType,
        uint256 layerId,
        string imageURL,
        string imageName
    );
    event cosmeticRemoved(uint256 layerType, uint256 layerId);
    event cosmeticEquipped(
        uint256 degenId,
        uint256 layerType,
        uint256 layerId,
        uint256 oldId,
        address owner,
        string imageName
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }
    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || owner == msg.sender,
            "Not white listed"
        );
        _;
    }

    constructor(address _degenAddress)
        ERC721("Myth City Cosmetics", "MYTHCOS")
    {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        whitelistedAddresses[_degenAddress] = true;
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }

    function overrideOwnerOfDegen(
        uint256 _degenId,
        address _from,
        address newOwner
    ) external isWhitelisted returns (bool) {
        for (uint256 i = 0; i < 8; i++) {
            uint256 tempCosmeticId = degenToCosmetic[_degenId][i];
            if (tempCosmeticId > 0) {
                cosmeticStats[tempCosmeticId].owner = newOwner;
                _transfer(_from, newOwner, tempCosmeticId);
            }
        }
        return true;
    }

    function getImageURL(uint256 _id) public view returns (string memory) {
        itemStat memory tempStats = cosmeticStats[_id];
        return cosmeticURL[tempStats.layerType][tempStats.imageId];
    }

    function getCosmeticName(uint256 _id) public view returns (string memory) {
        itemStat memory tempStats = cosmeticStats[_id];
        return cosmeticName[tempStats.layerType][tempStats.imageId];
    }

    function getUrl(uint256 _layer, uint256 _id)
        public
        view
        returns (string memory)
    {
        return cosmeticURL[_layer][_id];
    }

    function getName(uint256 _layer, uint256 _id)
        public
        view
        returns (string memory)
    {
        return cosmeticName[_layer][_id];
    }

    function getStats(uint256 _cosmeticId)
        public
        view
        returns (itemStat memory)
    {
        return cosmeticStats[_cosmeticId];
    }

    function idExists(uint256 _layerType, uint256 _itemId)
        public
        view
        returns (bool)
    {
        return cosmeticExists[_layerType][_itemId];
    }

    function equipCosmetic(uint256 _cosmeticId, uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            cosmeticStats[_cosmeticId].degenIdEquipped == 0,
            "Cosmetic is already Equipped"
        );
        uint256 tempLayerType = cosmeticStats[_cosmeticId].layerType;
        cosmeticStats[_cosmeticId].degenIdEquipped = _degenId;
        cosmeticStats[degenToCosmetic[_degenId][tempLayerType]]
            .degenIdEquipped = 0;
        uint256 tempOldId = degenToCosmetic[_degenId][tempLayerType];
        degenToCosmetic[_degenId][tempLayerType] = _cosmeticId;
        emit cosmeticEquipped(
            _degenId,
            tempLayerType,
            _cosmeticId,
            tempOldId,
            cosmeticStats[_cosmeticId].owner,
            cosmeticName[tempLayerType][_cosmeticId]
        );
        return true;
    }

    function getIdOfCosmeticLayerAndDegen(uint256 _degenId, uint256 _layerId)
        public
        view
        returns (uint256)
    {
        return degenToCosmetic[_degenId][_layerId];
    }

    function unequipCosmetic(uint256 _degenId, uint256 _layerId)
        external
        isWhitelisted
        returns (bool)
    {
        delete cosmeticStats[degenToCosmetic[_degenId][_layerId]]
            .degenIdEquipped;
        uint256 tempOldId = degenToCosmetic[_degenId][_layerId];
        address ownerAddress = cosmeticStats[
            degenToCosmetic[_degenId][_layerId]
        ].owner;
        delete degenToCosmetic[_degenId][_layerId];
        emit cosmeticEquipped(
            _degenId,
            _layerId,
            0,
            tempOldId,
            ownerAddress,
            ""
        );
        return true;
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _layerType,
        uint256 _nameId
    ) external isWhitelisted returns (bool) {
        require(idExists(_layerType, _imageId), "This id does not exist");
        uint256 tempCount = tokenCount;
        emit cosmeticMinted(_to, _imageId, _layerType, _nameId);
        _mint(_to, tempCount);
        cosmeticStats[tempCount] = itemStat(
            _to,
            _imageId,
            _layerType,
            _nameId,
            0
        );
        tokenCount++;
        return true;
    }

    function removeCosmetic(uint256 _layerType, uint256 _id)
        external
        onlyOwner
    {
        delete cosmeticURL[_layerType][_id];
        delete cosmeticExists[_layerType][_id];
        delete cosmeticName[_layerType][_id];
        emit cosmeticRemoved(_layerType, _id);
    }

    function addCosmeticImageId(
        uint256 _layerType,
        uint256[] calldata _imageId,
        string[] calldata _urls,
        string[] calldata _imageNames
    ) external isWhitelisted {
        require(
            _imageId.length == _urls.length &&
                _urls.length == _imageNames.length,
            "Lists need to be same length"
        );
        for (uint256 i = 0; i < _urls.length; i++) {
            emit cosmeticAdded(
                _layerType,
                _imageId[i],
                _urls[i],
                _imageNames[i]
            );
            cosmeticURL[_layerType][_imageId[i]] = _urls[i];
            cosmeticExists[_layerType][_imageId[i]] = true;
            cosmeticName[_layerType][_imageId[i]] = _imageNames[i];
        }
    }

    function getAttributeData(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        itemStat memory tempStats = cosmeticStats[tokenId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Cosmetic Id","display_type": "number", "value":',
                Base64.uint2str(tokenId),
                '},{"trait_type":"Layer Id","display_type": "number","value":',
                Base64.uint2str(tempStats.layerType),
                '},{"trait_type":"Image Id","display_type": "number", "value":',
                Base64.uint2str(tempStats.imageId),
                '},{"trait_type":"Equipped to Degen Id","display_type": "number", "value":',
                Base64.uint2str(tempStats.degenIdEquipped),
                "}"
            )
        );

        return json;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        itemStat memory tempStats = cosmeticStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        cosmeticName[tempStats.layerType][tempStats.imageId],
                        '",',
                        '"attributes": [',
                        getAttributeData(tokenId),
                        "]",
                        ',"image" : "',
                        cosmeticURL[tempStats.layerType][tempStats.imageId],
                        ' ","external_url": "mythcity.app","description":"Cosmetics used to override the looks of a Degenerate."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function transfer(uint256 _cosmeticId, address _to) external {
        require(
            cosmeticStats[_cosmeticId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            cosmeticStats[_cosmeticId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(msg.sender, _to, _cosmeticId);
        cosmeticStats[_cosmeticId].owner = _to;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _cosmeticId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _cosmeticId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            cosmeticStats[_cosmeticId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(from, _to, _cosmeticId);
        cosmeticStats[_cosmeticId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            cosmeticStats[tokenId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _safeTransfer(from, to, tokenId, data);
        cosmeticStats[tokenId].owner = to;
    }

    function overrideOwner(
        uint256 _cosmeticId,
        address _from,
        address _newOwner
    ) external isWhitelisted returns (bool) {
        _transfer(_from, _newOwner, _cosmeticId);
        cosmeticStats[_cosmeticId].owner = _newOwner;
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ERC721.sol";
import "MythWeaponSkins.sol";
import "Degen.sol";

contract MythCityWeapons is ERC721 {
    //Myth Weapons will have a image id, core stat and damage stat
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public weaponURL;
    mapping(uint256 => string) public weaponName;
    mapping(uint256 => bool) public weaponExists;
    mapping(uint256 => uint256) public degenToWeapon;

    mapping(uint256 => itemStat) public weaponStats;
    mapping(uint256 => uint256) public weaponSkins;
    address public weaponSkinAddress;

    event weaponAdded(uint256 id, string url, string nameOfToken);
    event skinEquipped(address owner, uint256 oldID, uint256 newId);
    event weaponEquipped(
        uint256 weaponId,
        uint256 degenId,
        uint256 oldId,
        address owner
    );
    event weaponRegrade(
        uint256 weaponId,
        uint256 weaponCore,
        uint256 weaponDamage
    );
    event weaponMinted(
        address to,
        uint256 imageId,
        uint256 weaponCore,
        uint256 weaponDamage,
        uint256 weaponType,
        string weaponName
    );
    event ownerChanged(address to, uint256 weaponId);
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);

    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 weaponCore;
        uint256 weaponDamage;
        uint256 degenIdEquipped;
        uint256 weaponType;
        uint256 nameOfWeaponId;
    }
    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || msg.sender == owner,
            "Not white listed"
        );
        _;
    }

    constructor(address _degenAddress) ERC721("Myth City Weapons", "MYTHWEP") {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        whitelistedAddresses[_degenAddress] = true;
    }

    function getStats(uint256 _weaponId) public view returns (itemStat memory) {
        return weaponStats[_weaponId];
    }

    function setSkinsAddress(address _address) external isWhitelisted {
        weaponSkinAddress = _address;
    }

    function getDegenData(uint256 _weaponId)
        public
        view
        returns (string memory)
    {
        itemStat memory tempStats = weaponStats[_weaponId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Weapon Id","display_type": "number", "value":',
                uint2str(_weaponId),
                '},{"trait_type":"Weapon Core","value":',
                uint2str(tempStats.weaponCore),
                '},{"trait_type":"Weapon Damage","value":',
                uint2str(tempStats.weaponDamage),
                '},{"trait_type":"Weapon Type","display_type": "number", "value":',
                uint2str(tempStats.weaponType),
                '},{"trait_type":"Weapon Image Url","value":"',
                getImageFromId(_weaponId),
                '"}'
            )
        );

        return json;
    }

    function getWeaponData(uint256 _weaponId)
        public
        view
        returns (string memory)
    {
        itemStat memory tempStats = weaponStats[_weaponId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Weapon Id","display_type": "number", "value":',
                uint2str(_weaponId),
                '},{"trait_type":"Weapon Core","value":',
                uint2str(tempStats.weaponCore),
                '},{"trait_type":"Weapon Damage","value":',
                uint2str(tempStats.weaponDamage),
                '},{"trait_type":"Weapon Type","display_type": "number", "value":',
                uint2str(tempStats.weaponType),
                '},{"trait_type":"Degen Equipped To","display_type": "number", "value":',
                uint2str(tempStats.degenIdEquipped),
                '},{"trait_type":"Weapon Skin Equipped","display_type": "number", "value":',
                uint2str(weaponSkins[_weaponId]),
                "}"
            )
        );

        return json;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        itemStat memory tempStats = weaponStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        weaponName[tempStats.nameOfWeaponId],
                        '",',
                        '"attributes": [',
                        getWeaponData(tokenId),
                        "]",
                        ',"image_data" : "',
                        getImageFromId(tokenId),
                        ' ","external_url": "mythcity.app","description":"Weapons Used by Degenerates to solve their problems."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getImageFromId(uint256 _id) public view returns (string memory) {
        if (weaponSkins[_id] > 0) {
            MythCityWeaponSkins tempSkins = MythCityWeaponSkins(
                weaponSkinAddress
            );
            return (tempSkins.getImageURL(weaponSkins[_id]));
        } else {
            return weaponURL[weaponStats[_id].imageId];
        }
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }

    function transfer(uint256 _weaponId, address _to) external {
        require(
            weaponStats[_weaponId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            weaponStats[_weaponId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        uint256 tempSkins = weaponSkins[_weaponId];
        if (tempSkins > 0) {
            MythCityWeaponSkins tempSkinContract = MythCityWeaponSkins(
                weaponSkinAddress
            );
            require(
                tempSkinContract.overrideOwner(tempSkins, msg.sender, _to),
                "failed to transfer weapon skin"
            );
        }
        _transfer(msg.sender, _to, _weaponId);
        weaponStats[_weaponId].owner = _to;
        emit ownerChanged(_to, _weaponId);
    }

    function equipSkin(uint256 _weaponId, uint256 _skinId) external {
        require(
            weaponStats[_weaponId].owner == msg.sender,
            "Only the owner of the Weapon can use it"
        );

        MythCityWeaponSkins tempSkins = MythCityWeaponSkins(weaponSkinAddress);
        MythCityWeaponSkins.itemStat memory tempStats = tempSkins.getStats(
            _skinId
        );
        require(
            tempStats.owner == msg.sender &&
                tempStats.weaponType == weaponStats[_weaponId].weaponType,
            "Only the owner of the skin can use it or the weapon is not the same type"
        );
        bool isEquipped = tempSkins.equipSkin(_weaponId, _skinId);
        require(isEquipped, "Skin was not equipped");
        emit skinEquipped(msg.sender, weaponSkins[_weaponId], _skinId);
        weaponSkins[_weaponId] = _skinId;
    }

    function unequipSkin(uint256 _weaponId) external {
        require(
            weaponStats[_weaponId].owner == msg.sender,
            "Only the owner of the Weapon can use it"
        );
        require(weaponSkins[_weaponId] > 0, "No Skin equipped");
        MythCityWeaponSkins tempSkins = MythCityWeaponSkins(weaponSkinAddress);
        bool isEquipped = tempSkins.unequipSkin(_weaponId);
        require(isEquipped, "Skin was not un equipped");
        emit skinEquipped(msg.sender, weaponSkins[_weaponId], 0);
        delete weaponSkins[_weaponId];
    }

    function equipWeapon(uint256 _weaponId, uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            weaponStats[_weaponId].degenIdEquipped == 0,
            "Weapon is already Equipped"
        );
        weaponStats[_weaponId].degenIdEquipped = _degenId;
        uint256 tempOldId = degenToWeapon[_degenId];
        weaponStats[degenToWeapon[_degenId]].degenIdEquipped = 0;
        degenToWeapon[_degenId] = _weaponId;
        emit weaponEquipped(
            _weaponId,
            _degenId,
            tempOldId,
            weaponStats[degenToWeapon[_degenId]].owner
        );
        return true;
    }

    function unequipWeapon(uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        delete weaponStats[degenToWeapon[_degenId]].degenIdEquipped;
        uint256 tempOldId = degenToWeapon[_degenId];
        delete degenToWeapon[_degenId];
        emit weaponEquipped(
            0,
            _degenId,
            tempOldId,
            weaponStats[degenToWeapon[_degenId]].owner
        );
        return true;
    }

    function forceTransferEquips(
        uint256 _weaponId,
        address _from,
        address _to
    ) internal returns (bool) {
        uint256 tempSkins = weaponSkins[_weaponId];
        if (tempSkins > 0) {
            MythCityWeaponSkins tempSkinContract = MythCityWeaponSkins(
                weaponSkinAddress
            );
            require(
                tempSkinContract.overrideOwner(tempSkins, _from, _to),
                "failed to transfer weapon skin"
            );
        }
        return true;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _weaponId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _weaponId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            weaponStats[_weaponId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(from, _to, _weaponId);
        require(
            forceTransferEquips(_weaponId, from, _to),
            "Failed to transfer Skins"
        );
        weaponStats[_weaponId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            weaponStats[tokenId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _safeTransfer(from, to, tokenId, data);
        require(
            forceTransferEquips(tokenId, from, to),
            "Failed to transfer Skins"
        );
        weaponStats[tokenId].owner = to;
    }

    function overrideOwner(
        uint256 _weaponId,
        address _from,
        address _newOwner
    ) external isWhitelisted returns (bool) {
        uint256 tempSkins = weaponSkins[_weaponId];
        if (tempSkins > 0) {
            MythCityWeaponSkins tempSkinContract = MythCityWeaponSkins(
                weaponSkinAddress
            );
            require(
                tempSkinContract.overrideOwner(tempSkins, _from, _newOwner),
                "failed to transfer weapon skin"
            );
        }
        weaponStats[_weaponId].owner = _newOwner;
        _transfer(_from, _newOwner, _weaponId);
        return true;
    }

    function upgradeWeaponStat(
        uint256 _weaponId,
        uint256 _weaponCore,
        uint256 _weaponDamage
    ) external isWhitelisted {
        weaponStats[_weaponId].weaponCore += _weaponCore;
        weaponStats[_weaponId].weaponDamage += _weaponDamage;
        emit weaponRegrade(
            _weaponId,
            weaponStats[_weaponId].weaponCore,
            weaponStats[_weaponId].weaponDamage
        );
    }

    function regradeWeaponStat(
        uint256 _weaponId,
        uint256 _weaponCore,
        uint256 _weaponDamage
    ) external isWhitelisted returns (bool) {
        if (_weaponCore > 0) {
            weaponStats[_weaponId].weaponCore = _weaponCore;
        }
        if (_weaponDamage > 0) {
            weaponStats[_weaponId].weaponDamage = _weaponDamage;
        }
        emit weaponRegrade(
            _weaponId,
            weaponStats[_weaponId].weaponCore,
            weaponStats[_weaponId].weaponDamage
        );
        return true;
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _weaponCore,
        uint256 _weaponDamage,
        uint256 _weaponType,
        uint256 _nameId
    ) external isWhitelisted returns (bool) {
        _mint(_to, tokenCount);
        emit weaponMinted(
            _to,
            _imageId,
            _weaponCore,
            _weaponDamage,
            _weaponType,
            weaponName[_nameId]
        );
        weaponStats[tokenCount] = itemStat(
            _to,
            _imageId,
            _weaponCore,
            _weaponDamage,
            0,
            _weaponType,
            _nameId
        );
        tokenCount++;
        return true;
    }

    function removeWeapon(uint256 _id) external isWhitelisted {
        delete weaponExists[_id];
        delete weaponURL[_id];
        delete weaponName[_id];
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function changeWeapon(
        string[10] calldata _url,
        uint256[10] calldata _id,
        string[10] calldata _names
    ) external isWhitelisted {
        for (uint256 i = 0; i < 10; i++) {
            if (_id[i] > 0) {
                emit weaponAdded(_id[i], _url[i], _names[i]);
                weaponExists[_id[i]] = true;
                weaponURL[_id[i]] = _url[i];
                weaponName[_id[i]] = _names[i];
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ERC721.sol";
import "Degen.sol";

contract MythCityWeaponSkins is ERC721 {
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public skinURL;
    mapping(uint256 => bool) public skinExists;
    mapping(uint256 => string) public skinName;
    mapping(uint256 => uint256) public weaponToSkin;
    mapping(uint256 => itemStat) public skinStats;
    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 weaponIdEquipped;
        uint256 weaponType;
        uint256 nameOfSkinId;
    }
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    event skinMinted(
        address to,
        uint256 imageId,
        uint256 weaponType,
        string skinName
    );
    event ownerChanged(address to, uint256 weaponId);
    event skinEquipped(uint256 weaponId, uint256 skinId);
    event skinURLAdded(uint256 skinId, string imageURL, string nameOfToken);
    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || msg.sender == owner,
            "Not white listed"
        );
        _;
    }

    constructor(address _weaponAddress)
        ERC721("Myth City Weapon Skins", "WEPSKIN")
    {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        whitelistedAddresses[_weaponAddress] = true;
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }

    function changeSkinURLs(
        string[10] calldata _url,
        uint256[10] calldata _id,
        string[10] calldata _names
    ) external isWhitelisted {
        for (uint256 i = 0; i < 10; i++) {
            if (_id[i] > 0) {
                emit skinURLAdded(_id[i], _url[i], _names[i]);
                skinExists[i] = true;
                skinURL[i] = _url[i];
                skinName[i] = _names[i];
            }
        }
    }

    function getStats(uint256 _skinId) public view returns (itemStat memory) {
        return skinStats[_skinId];
    }

    function overrideOwner(
        uint256 _skinId,
        address _from,
        address _newOwner
    ) external isWhitelisted returns (bool) {
        _transfer(_from, _newOwner, _skinId);
        skinStats[_skinId].owner = _newOwner;
        return true;
    }

    function transfer(uint256 _skinId, address _to) external {
        require(
            skinStats[_skinId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            skinStats[_skinId].weaponIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        skinStats[_skinId].owner = _to;
        _transfer(msg.sender, _to, _skinId);
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _skinId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _skinId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            skinStats[_skinId].weaponIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(from, _to, _skinId);
        skinStats[_skinId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            skinStats[tokenId].weaponIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _safeTransfer(from, to, tokenId, data);
        skinStats[tokenId].owner = to;
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _weaponType,
        uint256 _skinName
    ) external isWhitelisted returns (bool) {
        _mint(_to, tokenCount);
        emit skinMinted(_to, _imageId, _weaponType, skinName[_skinName]);
        skinStats[tokenCount] = itemStat(
            _to,
            _imageId,
            0,
            _weaponType,
            _skinName
        );
        tokenCount++;
        return true;
    }

    function equipSkin(uint256 _weaponId, uint256 _skinId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            skinStats[_skinId].weaponIdEquipped == 0,
            "Skin is already Equipped"
        );
        skinStats[_skinId].weaponIdEquipped = _weaponId;
        skinStats[weaponToSkin[_weaponId]].weaponIdEquipped = 0;
        weaponToSkin[_weaponId] = _skinId;
        emit skinEquipped(_weaponId, _skinId);
        return true;
    }

    function unequipSkin(uint256 _weaponId)
        external
        isWhitelisted
        returns (bool)
    {
        delete skinStats[weaponToSkin[_weaponId]].weaponIdEquipped;
        delete weaponToSkin[_weaponId];
        emit skinEquipped(_weaponId, 0);
        return true;
    }

    function getImageURL(uint256 _id) public view returns (string memory) {
        return skinURL[_id];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        itemStat memory tempStats = skinStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        skinName[tempStats.nameOfSkinId],
                        '",',
                        '"attributes": [{"trait_type": "Skin id","display_type": "number",  "value": ',
                        Base64.uint2str(tokenId),
                        '},{"trait_type": "Weapon Id equipped to","display_type": "number",  "value": ',
                        Base64.uint2str(tempStats.weaponIdEquipped),
                        '},{"trait_type": "Weapon Type","display_type": "number",  "value": ',
                        Base64.uint2str(tempStats.weaponType),
                        "}",
                        "]",
                        ',"image" : "',
                        skinURL[tempStats.imageId],
                        ' ","external_url": "mythcity.app","description":"Weapon Skins that make you look even COOLER."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ERC721.sol";
import "Degen.sol";

contract MythCityEquipment is ERC721 {
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public equipmentURL;
    mapping(uint256 => string) public equipmentName;
    mapping(uint256 => bool) public equipmentExists;
    mapping(uint256 => uint256) public degenToEquipment;

    mapping(uint256 => itemStat) public equipmentStats;
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    event equipmentAdded(uint256 id, string url, string nameOfToken);
    event equipmentEquipped(
        uint256 equipmentId,
        uint256 degenId,
        uint256 oldId,
        address owner
    );
    event equipmentRegrade(uint256 equipmentId, uint256 equipmentStat);
    event equipmentMinted(
        address to,
        uint256 imageId,
        uint256 itemStat,
        uint256 routeType,
        bool isWings,
        string equipmentName
    );
    event ownerChanged(address to, uint256 equipmentId);
    struct itemStat {
        bool isWings;
        address owner;
        uint256 imageId;
        uint256 equipmentStat;
        uint256 degenIdEquipped;
        uint256 equipmentRouteBoost;
        uint256 nameOfEquipmentId;
    }
    modifier isWhitelisted() {
        require(
            whitelistedAddresses[msg.sender] || msg.sender == owner,
            "Not white listed"
        );
        _;
    }

    constructor(address _degenAddress)
        ERC721("Myth City Equipment", "MYTHEQP")
    {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
        whitelistedAddresses[_degenAddress] = true;
    }

    function getStats(uint256 _id) public view returns (itemStat memory) {
        return equipmentStats[_id];
    }

    function getDegenData(uint256 _equipmentId)
        public
        view
        returns (string memory)
    {
        itemStat memory tempStats = equipmentStats[_equipmentId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Equipment Id","display_type": "number", "value":',
                uint2str(_equipmentId),
                '},{"trait_type":"Equipment Core","value":',
                uint2str(tempStats.equipmentStat),
                '},{"trait_type":"Equipment Route","display_type": "number", "value":',
                uint2str(tempStats.equipmentRouteBoost),
                '},{"trait_type":"Equipment Image Url","value":"',
                getImageFromId(_equipmentId),
                '"}'
            )
        );
        return json;
    }

    function getEquipmentData(uint256 _equipmentId)
        public
        view
        returns (string memory)
    {
        itemStat memory tempStats = equipmentStats[_equipmentId];
        string memory json = string(
            abi.encodePacked(
                '{"trait_type":"Equipment Id","display_type": "number", "value":',
                uint2str(_equipmentId),
                '},{"trait_type":"Equipment Core","value":',
                uint2str(tempStats.equipmentStat),
                '},{"trait_type":"Equipment Route","display_type": "number", "value":',
                uint2str(tempStats.equipmentRouteBoost),
                '},{"trait_type":"Degen Equipped To","display_type": "number", "value":',
                uint2str(tempStats.degenIdEquipped),
                "}"
            )
        );

        return json;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        itemStat memory tempStats = equipmentStats[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        equipmentName[tempStats.nameOfEquipmentId],
                        '",',
                        '"attributes": [',
                        getEquipmentData(tokenId),
                        "]",
                        ',"image_data" : "',
                        getImageFromId(tokenId),
                        ' ","external_url": "mythcity.app", "description":"Equipment Used by Degenerates to help them on their missions."',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getImageFromId(uint256 _id) public view returns (string memory) {
        return equipmentURL[equipmentStats[_id].imageId];
    }

    function getImageURL(uint256 _equipmentId)
        public
        view
        returns (string memory)
    {
        return equipmentURL[equipmentStats[_equipmentId].imageId];
    }

    function equipEquipment(uint256 _equipmentId, uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            equipmentStats[_equipmentId].degenIdEquipped == 0,
            "Equipment is already Equipped"
        );
        equipmentStats[_equipmentId].degenIdEquipped = _degenId;
        uint256 oldId = degenToEquipment[_degenId];
        equipmentStats[degenToEquipment[_degenId]].degenIdEquipped = 0;
        degenToEquipment[_degenId] = _equipmentId;
        emit equipmentEquipped(
            _equipmentId,
            _degenId,
            oldId,
            equipmentStats[_equipmentId].owner
        );
        return true;
    }

    function unequipEquipment(uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        delete equipmentStats[degenToEquipment[_degenId]].degenIdEquipped;
        uint256 oldId = degenToEquipment[_degenId];
        address tempOwner = equipmentStats[degenToEquipment[_degenId]].owner;
        delete degenToEquipment[_degenId];
        emit equipmentEquipped(0, _degenId, oldId, tempOwner);
        return true;
    }

    function transfer(uint256 _equipmentId, address _to) external {
        require(
            equipmentStats[_equipmentId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            equipmentStats[_equipmentId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(msg.sender, _to, _equipmentId);
        equipmentStats[_equipmentId].owner = _to;
    }

    function transferFrom(
        address from,
        address _to,
        uint256 _equipmentId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _equipmentId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            equipmentStats[_equipmentId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _transfer(from, _to, _equipmentId);
        equipmentStats[_equipmentId].owner = _to;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        require(
            equipmentStats[tokenId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        _safeTransfer(from, to, tokenId, data);
        equipmentStats[tokenId].owner = to;
    }

    function overrideOwner(
        uint256 _equipmentId,
        address _from,
        address _newOwner
    ) external isWhitelisted returns (bool) {
        _transfer(_from, _newOwner, _equipmentId);
        equipmentStats[_equipmentId].owner = _newOwner;
        return true;
    }

    function upgradeEquipmentStat(uint256 _equipmentId, uint256 _statUpgrade)
        external
        isWhitelisted
    {
        equipmentStats[_equipmentId].equipmentStat += _statUpgrade;
        emit equipmentRegrade(
            _equipmentId,
            equipmentStats[_equipmentId].equipmentStat
        );
    }

    function regradeEquipmentStat(uint256 _equipmentId, uint256 _statRegrade)
        external
        isWhitelisted
        returns (bool)
    {
        equipmentStats[_equipmentId].equipmentStat = _statRegrade;
        emit equipmentRegrade(
            _equipmentId,
            equipmentStats[_equipmentId].equipmentStat
        );
        return true;
    }

    function mint(
        bool _isWings,
        address _to,
        uint256 _imageId,
        uint256 _equipmentStat,
        uint256 _route,
        uint256 _nameId
    ) external isWhitelisted returns (bool) {
        _mint(_to, tokenCount);
        emit equipmentMinted(
            _to,
            _imageId,
            _equipmentStat,
            _route,
            _isWings,
            equipmentName[_nameId]
        );
        equipmentStats[tokenCount] = itemStat(
            _isWings,
            _to,
            _imageId,
            _equipmentStat,
            0,
            _route,
            _nameId
        );
        tokenCount++;
        return true;
    }

    function removeEquipment(uint256 _id) external isWhitelisted {
        delete equipmentExists[_id];
        delete equipmentURL[_id];
        delete equipmentName[_id];
    }

    function changeEquipment(
        string[10] calldata _url,
        uint256[10] calldata _id,
        string[10] calldata _names
    ) external isWhitelisted {
        for (uint256 i = 0; i < 10; i++) {
            if (_id[i] > 0) {
                emit equipmentAdded(_id[i], _url[i], _names[i]);
                equipmentExists[_id[i]] = true;
                equipmentURL[_id[i]] = _url[i];
                equipmentName[_id[i]] = _names[i];
            }
        }
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }
}