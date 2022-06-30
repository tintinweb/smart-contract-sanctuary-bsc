/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC721Metadata {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC721Enumerable {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Initializable {
    //@openzeppelin/upgrades/contracts/Initializable.sol

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the initial owner.
     */
    function _initializeOwnable(address owner_) internal {
        _setOwner(owner_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

library SafeToken {
    using Address for address;

    function safeTransfer(
        IToken token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IToken token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IToken token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeToken: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeToken: Token operation did not succeed");
        }
    }
}

struct MintToken {
    address[] recipients;
    uint256 uriId;
}

struct TokenUri {
    uint256 uriId;
    string uri;
}

struct Price {
    address asset;
    uint256 value;
}

string constant ERR_ZERO_URI_ID = "zero uri id";

contract CatsAndDogsCollection is Ownable, IERC165, IERC721, IERC721Metadata, IERC721Enumerable, Initializable {
    using SafeToken for IToken;

    string private name_;
    string private symbol_;
    mapping(uint256 => address) private owners_;
    mapping(address => uint256) private balances_;
    mapping(uint256 => address) private tokenApprovals_;
    mapping(address => mapping(address => bool)) private operatorApprovals_;
    mapping(address => mapping(uint256 => uint256)) private ownedTokens_; // Mapping from owner to list of owned token IDs
    mapping(uint256 => uint256) private ownedTokensIndex_; // Mapping from token ID to index of the owner tokens list
    uint256[] private allTokens_; // Array with all token ids, used for enumeration
    mapping(uint256 => uint256) private allTokensIndex_; // Mapping from token id to position in the allTokens array
    mapping(uint256/*token id*/ => uint256/*token URI id*/) public tokenUriIds_;
    mapping(uint256/*token URI id*/ => string/*URI*/) public tokenURIs_;
    mapping(address => uint256) public prices_;
    address public revenueOwner_;
    uint256 public tokenIdGenerator_;

    function version() external pure returns (string memory) {return "Cats & Dogs Collection v2";}

    constructor() initializer {}

    function initialize(
        address _owner,
        address _revenueOwner,
        string memory _name,
        string memory _symbol,
        TokenUri[] calldata _tokenURIs,
        Price[] calldata _prices) public initializer {

        _ensureNotZeroAddress(_owner);
        _initializeOwnable(_owner);

        _setRevenueOwner(_revenueOwner);

        name_ = _name;
        symbol_ = _symbol;

        _setTokenURIs(_tokenURIs);
        _setPrices(_prices);
    }

    function name() external view virtual override returns (string memory) {
        return name_;
    }

    function symbol() external view virtual override returns (string memory) {
        return symbol_;
    }

    function tokenURI(uint256 _tokenId) external view virtual override returns (string memory) {
        return _exists(_tokenId)
        ? tokenURIs_[tokenUriIds_[_tokenId]]
        : "";
    }

    // -----------------------------------------------------------------------------------------------------------------
    // management

    function setRevenueOwner(address _newRevenueOwner) onlyOwner external {
        _setRevenueOwner(_newRevenueOwner);
    }

    function _setRevenueOwner(address _newRevenueOwner) private {
        _ensureNotZeroAddress(_newRevenueOwner);
        require(revenueOwner_ != _newRevenueOwner, "already done");
        revenueOwner_ = _newRevenueOwner;
    }

    function setPrices(Price[] calldata _prices) external onlyOwner {
        _setPrices(_prices);
    }

    function _setPrices(Price[] calldata _prices) private {
        for (uint16 i = 0; i < _prices.length; ++i) {
            prices_[_prices[i].asset] = _prices[i].value;
        }
    }

    function setTokenURIs(TokenUri[] calldata _tokenURIs) external onlyOwner {
        _setTokenURIs(_tokenURIs);
    }

    function _setTokenURIs(TokenUri[] calldata _tokenURIs) private {
        for (uint16 i = 0; i < _tokenURIs.length; ++i) {
            tokenURIs_[_tokenURIs[i].uriId] = _tokenURIs[i].uri;
        }
    }

    // -----------------------------------------------------------------------------------------------------------------
    // processing

    function calcMintPrice(uint256 _tokenAmount, address _fromAsset) public view returns (uint256 fromAmount) {
        uint256 assetPrice = prices_[_fromAsset];
        return (assetPrice != 0) ? assetPrice * _tokenAmount : 0;
    }

    function mintFromToken(uint256 _uriId, uint256 _tokenAmount, IToken _fromAsset, uint256 _fromAmount) external returns (bool) {
        require(address(_fromAsset) != address(0), "wrong mint function");

        _fromAsset.safeTransferFrom(msg.sender, revenueOwner_, _fromAmount);
        _mintFrom(_uriId, _tokenAmount, address(_fromAsset), _fromAmount);

        return true;
    }

    function mintFromCoin(uint256 _uriId, uint256 _tokenAmount) external payable returns (bool) {
        (bool sent,) = revenueOwner_.call{value : msg.value}("");
        require(sent, "payment send failed");

        _mintFrom(_uriId, _tokenAmount, address(0), msg.value);

        return true;
    }

    function _mintFrom(uint256 _uriId, uint256 _tokenAmount, address _fromAsset ,uint256 _fromAmount) private {
        require(_uriId != 0, ERR_ZERO_URI_ID);
        require(_tokenAmount != 0, "zero token amount");
        require(_fromAmount != 0, "zero purchase amount");
        require(prices_[_fromAsset] != 0, "asset not supported");
        require(_fromAmount >= calcMintPrice(_tokenAmount, _fromAsset), "payment mismatch");

        for (uint16 i = 0; i < _tokenAmount; ++i) {
            _mintTo(msg.sender, _uriId);
        }
    }

    function mintTo(address _recipient, uint256 _uriId) external onlyOwner returns (bool) {
        require(_uriId != 0, ERR_ZERO_URI_ID);
        _mintTo(_recipient, _uriId);
        return true;
    }

    function mintBatch(MintToken[] calldata _tokens) external onlyOwner returns (bool) {
        uint256 recipientsCount;
        uint256 uriId;

        for (uint16 i = 0; i < _tokens.length; ++i) {
            uriId = _tokens[i].uriId;
            recipientsCount = _tokens[i].recipients.length;

            require(uriId != 0, ERR_ZERO_URI_ID);

            for (uint16 j = 0; j < recipientsCount; ++j) {
                if(!_isContract(_tokens[i].recipients[j])) {
                    _mintTo(_tokens[i].recipients[j], uriId);
                }
            }
        }

        return true;
    }

    function _mintTo(address _recipient, uint256 _uriId) private {
        uint256 tokenId = ++tokenIdGenerator_;
        _safeMint(_recipient, tokenId);
        _setTokenUriId(tokenId, _uriId);
    }

    function _safeMint(address _to, uint256 _tokenId) internal virtual {
        _safeMint(_to, _tokenId, "");
    }

    function _safeMint(address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        _mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address _to, uint256 _tokenId) internal virtual {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(!_exists(_tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), _to, _tokenId);

        balances_[_to] += 1;
        owners_[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    function _setTokenUriId(uint256 _tokenId, uint256 _uriId) internal virtual {
        require(_exists(_tokenId), "uri set for nonexistent token");
        require(bytes(tokenURIs_[_uriId]).length > 0, "empty token uri");
        tokenUriIds_[_tokenId] = _uriId;
    }

    // -----------------------------------------------------------------------------------------------------------------
    // erc721 impl

    function balanceOf(address _account) public view virtual override returns (uint256) {
        return balances_[_account];
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        address owner = owners_[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable virtual override {
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable virtual override {
        _safeTransfer(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable virtual override {
        address owner = ownerOf(_tokenId);

        require(_approved != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");

        _approve(_approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external virtual override {
        require(_operator != _msgSender(), "ERC721: approve to caller");

        operatorApprovals_[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(_msgSender(), _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view virtual override returns (address) {
        require(_exists(_tokenId), "ERC721: approved query for nonexistent token");

        return tokenApprovals_[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {
        return operatorApprovals_[_owner][_operator];
    }

    function supportsInterface(bytes4 _interfaceId) external view virtual override returns (bool) {
        return _interfaceId == type(IERC165).interfaceId
            || _interfaceId == type(IERC721).interfaceId
            || _interfaceId == type(IERC721Metadata).interfaceId
            || _interfaceId == type(IERC721Enumerable).interfaceId;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view virtual override returns (uint256) {
        require(_index < balanceOf(_owner), "ERC721Enumerable: owner index out of bounds");
        return ownedTokens_[_owner][_index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return allTokens_.length;
    }

    function tokenByIndex(uint256 _index) public view virtual override returns (uint256) {
        require(_index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return allTokens_[_index];
    }

    function _exists(uint256 _tokenId) internal view virtual returns (bool) {
        return owners_[_tokenId] != address(0);
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view virtual returns (bool) {
        require(_exists(_tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) internal returns (bool) {
        if (_isContract(_to)) {
            try IERC721Receiver(_to).onERC721Received(_msgSender(), _from, _tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(_to).onERC721Received.selector;
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

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(_tokenId) == _from, "ERC721: transfer of token that is not own");
        require(_to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(_from, _to, _tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), _tokenId);

        balances_[_from] -= 1;
        balances_[_to] += 1;
        owners_[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function _approve(address _to, uint256 _tokenId) internal virtual {
        tokenApprovals_[_tokenId] = _to;
        emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }

    function _isContract(address _addr) private view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId) internal virtual {
        if (_from == address(0)) {
            _addTokenToAllTokensEnumeration(_tokenId);
        } else if (_from != _to) {
            _removeTokenFromOwnerEnumeration(_from, _tokenId);
        }
        if (_to == address(0)) {
            _removeTokenFromAllTokensEnumeration(_tokenId);
        } else if (_to != _from) {
            _addTokenToOwnerEnumeration(_to, _tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address _to, uint256 _tokenId) private {
        uint256 length = balanceOf(_to);
        ownedTokens_[_to][length] = _tokenId;
        ownedTokensIndex_[_tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 _tokenId) private {
        allTokensIndex_[_tokenId] = allTokens_.length;
        allTokens_.push(_tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address _from, uint256 _tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(_from) - 1;
        uint256 tokenIndex = ownedTokensIndex_[_tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = ownedTokens_[_from][lastTokenIndex];

            ownedTokens_[_from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            ownedTokensIndex_[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete ownedTokensIndex_[_tokenId];
        delete ownedTokens_[_from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 _tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = allTokens_.length - 1;
        uint256 tokenIndex = allTokensIndex_[_tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = allTokens_[lastTokenIndex];

        allTokens_[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        allTokensIndex_[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete allTokensIndex_[_tokenId];
        allTokens_.pop();
    }

    // -----------------------------------------------------------------------------------------------------------------
    // heplers

    function _ensureNotZeroAddress(address _addr) private pure {
        require(_addr != address(0), "zero address");
    }
}