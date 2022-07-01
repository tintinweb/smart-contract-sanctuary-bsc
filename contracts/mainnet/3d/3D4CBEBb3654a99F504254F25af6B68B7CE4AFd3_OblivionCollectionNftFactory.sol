// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./OblivionCollectionNft.sol";
import "../includes/access/Ownable.sol";

contract OblivionCollectionNftFactory is Ownable {
    struct NftInfo {
        address nft;
        address deployer;
        uint timestamp;
    }

    address public mintingContract;
    NftInfo[] public nfts;

    mapping(address => address[]) public userCreatedNfts;

    event NftDeployed(string _symbol, address _nft, address _owner);

    constructor (address _mintingContract) { mintingContract = _mintingContract; }

    function setMintingContract(address _mintingContract) public onlyOwner() { mintingContract = _mintingContract; }
    function totalNftsCreated() public view returns (uint256) { return nfts.length; }
    function totalUserNfts(address _user) public view returns (uint256) { return userCreatedNfts[_user].length; }

    function deployNft(string memory _name, string memory _symbol, string memory _uri, uint256 _maxSupply, bool _whitelistMintingService, bool _whitelistOwner) public returns (address) {
        OblivionCollectionNft nft = new OblivionCollectionNft(_name, _symbol);        
        
        if (bytes(_uri).length > 0) nft.setTokenURI(_uri);
        if (_maxSupply > 0) nft.setMaxSupply(_maxSupply);
        if (_whitelistMintingService) nft.whitelistAdmin(mintingContract, true);
        if (_whitelistOwner) nft.whitelistAdmin(msg.sender, true);

        nft.transferOwnership(msg.sender);

        nfts.push(NftInfo({
            nft: address(nft),
            deployer: msg.sender,
            timestamp: block.timestamp
        }));
        
        userCreatedNfts[msg.sender].push(address(nft));
        emit NftDeployed(_symbol, address(nft), msg.sender);
        return address(nft);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../includes/access/Ownable.sol";
import "../includes/interfaces/IERC721.sol";
import "../includes/interfaces/IERC721Receiver.sol";
import "../includes/token/ERC721/extensions/IERC721Metadata.sol";
import "../includes/token/ERC721/extensions/IERC721Enumerable.sol";
import "../includes/utils/Address.sol";
import "../includes/utils/Strings.sol";
import "../includes/utils/Counters.sol";
import "../includes/utils/introspection/ERC165.sol";

abstract contract OblivionNft is Ownable, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIds;

    string      public override name;
    string      public override symbol;
    string      public          baseURI;
    uint256[]   public          allTokens;
    uint256     public          maxSupply;

    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public tokenApprovals;
    mapping(uint256 => uint256) public ownedTokensIndex;
    mapping(uint256 => uint256) public allTokensIndex;
    mapping(address => bool)    public adminWhitelist;

    mapping(address => mapping(address => bool))    public operatorApprovals;
    mapping(address => mapping(uint256 => uint256)) public ownedTokens;

    event MintNft(address to, uint date, address nft, uint tokenId, string tokenURI);

    constructor (string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner() {
        maxSupply = _maxSupply;
    }

    function setTokenURI(string memory _newTokenURI) public onlyOwner() {
        require(bytes(baseURI).length == 0, 'TokenURI is already set');
        baseURI = _newTokenURI;
    }

    function whitelistAdmin(address _admin, bool _isAdmin) public onlyOwner() {
        adminWhitelist[_admin] = _isAdmin;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return allTokens.length;
    }

    function exists(uint256 _tokenId) internal view virtual returns (bool) {
        return owners[_tokenId] != address(0);
    }

    function getApproved(uint256 _tokenId) public view virtual override returns (address) {
        require(exists(_tokenId), "ERC721: approved query for nonexistent token");
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return _interfaceId == type(IERC721).interfaceId || 
               _interfaceId == type(IERC721Metadata).interfaceId || 
               _interfaceId == type(IERC721Enumerable).interfaceId ||
               super.supportsInterface(_interfaceId);
    }

    function balanceOf(address _owner) public view virtual override returns (uint256) {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        address owner = owners[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view virtual override returns (uint256) {
        require(_index < balanceOf(_owner), "ERC721Enumerable: owner index out of bounds");
        return ownedTokens[_owner][_index];
    }

    function tokenByIndex(uint256 _index) public view virtual override returns (uint256) {
        require(_index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return allTokens[_index];
    }

    function approve(address _to, uint256 _tokenId) public virtual override {
        address owner = ownerOf(_tokenId);
        require(_to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
        _approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual override {
        _setApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view virtual returns (bool) {
        require(exists(_tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
        require(_to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(_from, _to, _tokenId);
        _approve(address(0), _tokenId);
        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _approve(address _to, uint256 _tokenId) internal virtual {
        tokenApprovals[_tokenId] = _to;
        emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal virtual {
        require(_owner != _operator, "ERC721: approve to caller");
        operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) internal returns (bool) {
        if (_to.isContract()) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 retval) {
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
        ownedTokens[_to][length] = _tokenId;
        ownedTokensIndex[_tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 _tokenId) private {
        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address _from, uint256 _tokenId) private {
        uint256 lastTokenIndex = balanceOf(_from) - 1;
        uint256 tokenIndex = ownedTokensIndex[_tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];
            ownedTokens[_from][tokenIndex] = lastTokenId;
            ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete ownedTokensIndex[_tokenId];
        delete ownedTokens[_from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 _tokenId) private {
        uint256 lastTokenIndex = allTokens.length - 1;
        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenId = allTokens[lastTokenIndex];
        allTokens[tokenIndex] = lastTokenId;
        allTokensIndex[lastTokenId] = tokenIndex;
        delete allTokensIndex[_tokenId];
        allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./OblivionNft.sol";

contract OblivionCollectionNft is OblivionNft {
    using Counters for Counters.Counter;
    using Strings for uint256;

    constructor (string memory _name, string memory _symbol) OblivionNft(_name, _symbol) { }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(exists(_tokenId) || _tokenId <= maxSupply || maxSupply == 0, "ERC721Metadata: URI query for nonexistent token");
        string memory base = baseURI;
        return bytes(base).length > 0 ? string(abi.encodePacked(base, _tokenId.toString())) : "";
    }

    function preMint(address _to, uint256 _quantity) public onlyOwner() {
        require(bytes(baseURI).length > 0, 'tokenURI is not set');
        require(maxSupply == 0 || totalSupply() + _quantity <= maxSupply, 'maximum mints reached');
        require(_to != address(0), "ERC721: mint to the zero address");

        uint256 newItemId;

        for (uint256 i = 0; i < _quantity; i++) {
            _tokenIds.increment();
            newItemId = _tokenIds.current();
            require(!exists(newItemId), "ERC721: token already minted");

            _beforeTokenTransfer(address(0), _to, newItemId);
            balances[_to] += 1;
            owners[newItemId] = _to;
            require(_checkOnERC721Received(address(0), _to, newItemId, ""), "ERC721: transfer to non ERC721Receiver implementer");
        }
    }

    function mint(address _to) public returns (uint256) {
        require(bytes(baseURI).length > 0, 'tokenURI is not set');
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(maxSupply == 0 || totalSupply() < maxSupply, 'maximum mints reached');
        require(_to != address(0), "ERC721: mint to the zero address");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        require(!exists(newItemId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), _to, newItemId);
        balances[_to] += 1;
        owners[newItemId] = _to;
        emit Transfer(address(0), _to, newItemId);

        require(_checkOnERC721Received(address(0), _to, newItemId, ""), "ERC721: transfer to non ERC721Receiver implementer");

        emit MintNft(_to, block.timestamp, address(this), newItemId, tokenURI(newItemId));        
        return newItemId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

pragma solidity ^0.8.4;

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

pragma solidity ^0.8.4;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.8.4;

import "../../../interfaces/IERC721.sol";

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

pragma solidity ^0.8.4;

import "../../../interfaces/IERC721.sol";

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../utils/introspection/IERC165.sol";

/**x
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}