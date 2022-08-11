// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./OblivionNft1155.sol";
import "../includes/access/Ownable.sol";


contract OblivionNft1155Factory is Ownable {
    struct NftInfo {
        address nft;
        address deployer;
        uint timestamp;
    }

    address public mintingContract;
    NftInfo[] public nfts;

    mapping(address => address[]) public userCreatedNfts;

    event NftDeployed(address _nft, address _owner);

    constructor (address _mintingContract) { mintingContract = _mintingContract; }

    function setMintingContract(address _mintingContract) public onlyOwner() { mintingContract = _mintingContract; }
    function totalNftsCreated() public view returns (uint256) { return nfts.length; }
    function totalUserNfts(address _user) public view returns (uint256) { return userCreatedNfts[_user].length; }

    function deployNft(string memory _baseUri, string[] memory _tokenUris, uint256[] memory _maxSupplies, bool _whitelistMintingService, bool _whitelistOwner) public returns (address) {
        OblivionNft1155 nft = new OblivionNft1155(_baseUri);
        nft.setBaseUri(_baseUri);

        for (uint i = 0; i < _tokenUris.length; i++) {
            nft.setTokenUri(i, _tokenUris[i]);
            nft.setMaxSupply(i, _maxSupplies[i]);
        }
            
        
        if (_whitelistMintingService) nft.whitelistAdmin(mintingContract, true);
        if (_whitelistOwner) nft.whitelistAdmin(msg.sender, true);

        nft.transferOwnership(msg.sender);

        nfts.push(NftInfo({
            nft: address(nft),
            deployer: msg.sender,
            timestamp: block.timestamp
        }));

        userCreatedNfts[msg.sender].push(address(nft));
        emit NftDeployed(address(nft), msg.sender);
        return address(nft);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../includes/interfaces/IERC1155.sol";
import "../includes/interfaces/IERC1155Receiver.sol";
import "../includes/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "../includes/access/Ownable.sol";
import "../includes/utils/Address.sol";
import "../includes/utils/introspection/ERC165.sol";
import "../includes/utils/Strings.sol";

contract OblivionNft1155 is ERC165, IERC1155, IERC1155MetadataURI, Ownable {
    using Address for address;
    using Strings for uint256;

    mapping(uint256 => mapping(address => uint256)) public balances;
    mapping(uint256 => uint256)                     public totalSupplies;
    mapping(uint256 => uint256)                     public maxSupplies;
    mapping(address => mapping(address => bool))    public operatorApprovals;
    mapping(uint256 => string)                      public tokenURIs;
    mapping(address => bool)                        public adminWhitelist;

    string public baseURI = "";

    constructor(string memory _uri) { baseURI = _uri; }

    function setBaseUri(string memory _baseUri) public onlyOwner() { baseURI = _baseUri; }

    function setTokenUri(uint256 _tokenId, string memory _tokenUri) public {
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(bytes(tokenURIs[_tokenId]).length == 0, 'token URI already set');
        tokenURIs[_tokenId] = _tokenUri; 
        emit URI(uri(_tokenId), _tokenId);
    }

    function setTokenUris(uint256[] memory _tokenIds, string[] memory _tokenUris) public {
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(_tokenIds.length == _tokenUris.length, 'incorrect parameters');

        for (uint i = 0; i < _tokenIds.length; i++) {
            require(bytes(tokenURIs[_tokenIds[i]]).length == 0, 'token URI already set');
            tokenURIs[_tokenIds[i]] = _tokenUris[i]; 
            emit URI(uri(_tokenIds[i]), _tokenIds[i]);
        }
    }

    function whitelistAdmin(address _admin, bool _isAdmin) public onlyOwner() {
        adminWhitelist[_admin] = _isAdmin;
    }

    function setMaxSupply(uint256 _id, uint256 _maxSupply) public {
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        maxSupplies[_id] = _maxSupply;
    }

    function mint(address _to, uint256 _id, uint256 _amount) public {
        _mint(_to, _id, _amount, "");
    }

    function mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) public {
        _mint(_to, _id, _amount, _data);
    }

    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts) public {
        _mintBatch(_to, _ids, _amounts, "");
    }

    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public {
        _mintBatch(_to, _ids, _amounts, _data);
    }

    function burn(address _from, uint256 _id, uint256 _amount) public {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender), "ERC1155: caller is not token owner nor approved");
        _burn(_from, _id, _amount);
    }

    function burnBatch(address _from, uint256[] memory _ids, uint256[] memory _amounts) public {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender), "ERC1155: caller is not token owner nor approved");
        _burnBatch(_from, _ids, _amounts);
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            _interfaceId == type(IERC1155).interfaceId ||
            _interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = tokenURIs[_tokenId];
        return bytes(tokenURI).length > 0 ? tokenURI : baseURI;
    }

    function balanceOf(address _account, uint256 _id) public view virtual override returns (uint256) {
        require(_account != address(0), "ERC1155: address zero is not a valid owner");
        return balances[_id][_account];
    }

    function balanceOfBatch(address[] memory _accounts, uint256[] memory _ids) public view virtual
            override returns (uint256[] memory) {
        require(_accounts.length == _ids.length, "ERC1155: accounts and ids length mismatch");
        uint256[] memory batchBalances = new uint256[](_accounts.length);

        for (uint256 i = 0; i < _accounts.length; ++i) 
            batchBalances[i] = balanceOf(_accounts[i], _ids[i]);

        return batchBalances;
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual override {
        _setApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _account, address _operator) public view virtual override returns (bool) {
        return operatorApprovals[_account][_operator];
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) public {
        safeTransferFrom(_from, _to, _id, _amount, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) public virtual override {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender), "ERC1155: caller is not token owner nor approved");
        _safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts) public {
        safeBatchTransferFrom(_from, _to, _ids, _amounts, "");
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public virtual override {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender), "ERC1155: caller is not token owner nor approved");
        _safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) internal virtual {
        require(_to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;
        uint256 fromBalance = balances[_id][_from];

        require(fromBalance >= _amount, "ERC1155: insufficient balance for transfer");
        
        unchecked {
            balances[_id][_from] = fromBalance - _amount;
        }
        
        balances[_id][_to] += _amount;

        emit TransferSingle(operator, _from, _to, _id, _amount);
        _doSafeTransferAcceptanceCheck(operator, _from, _to, _id, _amount, _data);
    }

    function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) internal virtual {
        require(_ids.length == _amounts.length, "ERC1155: ids and amounts length mismatch");
        require(_to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 amount = _amounts[i];

            uint256 fromBalance = balances[id][_from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                balances[id][_from] = fromBalance - amount;
            }
            balances[id][_to] += amount;
        }

        emit TransferBatch(operator, _from, _to, _ids, _amounts);
        _doSafeBatchTransferAcceptanceCheck(operator, _from, _to, _ids, _amounts, _data);
    }

    function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) internal virtual {
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(_to != address(0), "ERC1155: mint to the zero address");
        require(bytes(tokenURIs[_id]).length > 0, 'ERC1155: token URI is not set for token ID');
        require(maxSupplies[_id] == 0 || maxSupplies[_id] >= totalSupplies[_id] + _amount, 'ERC1155: amount exceeds max supply');

        address operator = msg.sender;

        balances[_id][_to] += _amount;
        totalSupplies[_id] += _amount;
        emit TransferSingle(operator, address(0), _to, _id, _amount);
        _doSafeTransferAcceptanceCheck(operator, address(0), _to, _id, _amount, _data);
    }

    function _mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) internal virtual {
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(_to != address(0), "ERC1155: mint to the zero address");
        require(_ids.length == _amounts.length, "ERC1155: ids and amounts length mismatch");
        
        address operator = msg.sender;

        for (uint256 i = 0; i < _ids.length; i++) {
            require(bytes(tokenURIs[_ids[i]]).length > 0, 'ERC1155: token URI is not set for token ID');
            require(maxSupplies[_ids[i]] == 0 || maxSupplies[_ids[i]] >= totalSupplies[_ids[i]] + _amounts[i], 'ERC1155: amount exceeds max supply');
            balances[_ids[i]][_to] += _amounts[i];
            totalSupplies[_ids[i]] += _amounts[i];
        }

        emit TransferBatch(operator, address(0), _to, _ids, _amounts);
        _doSafeBatchTransferAcceptanceCheck(operator, address(0), _to, _ids, _amounts, _data);
    }

    function _burn(address _from, uint256 _id, uint256 _amount) internal virtual {
        require(_from != address(0), "ERC1155: burn from the zero address");

        address operator = msg.sender;

        uint256 fromBalance = balances[_id][_from];
        require(fromBalance >= _amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            balances[_id][_from] = fromBalance - _amount;
            totalSupplies[_id] -= _amount;
        }

        emit TransferSingle(operator, _from, address(0), _id, _amount);
    }

    function _burnBatch(address _from, uint256[] memory _ids, uint256[] memory _amounts) internal virtual {
        require(_from != address(0), "ERC1155: burn from the zero address");
        require(_ids.length == _amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 amount = _amounts[i];

            uint256 fromBalance = balances[id][_from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                balances[id][_from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, _from, address(0), _ids, _amounts);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal virtual {
        require(_owner != _operator, "ERC1155: setting approval status for self");
        operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function _doSafeTransferAcceptanceCheck(
        address _operator,
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) private {
        if (_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155Received(_operator, _from, _id, _amount, _data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
        address _operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) private {
        if (_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _amounts, _data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.4;

import "../../../interfaces/IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.4;

import "../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.4;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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