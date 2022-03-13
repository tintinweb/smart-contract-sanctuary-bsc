// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/address.sol";

contract PresaleBoxesContract is AccessControl, Pausable {
    using Address for address;

    bytes32 public _saleStatus;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    bytes32 public constant SALE_STATUS_ROLE = keccak256("SALE_STATUS_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant SET_WALLET_ROLE = keccak256("SET_WALLET_ROLE");
    bytes32 public constant SET_WALLET_ADMIN_ROLE = keccak256("SET_WALLET_ADMIN_ROLE");

    uint256 public PRESALE_COMMON_PER_BUYER_LIMIT = 2;
    uint256 public PRESALE_RARE_PER_BUYER_LIMIT = 2;
    uint256 public PRESALE_EPIC_PER_BUYER_LIMIT = 2;
    uint256 public PRESALE_LEGENDARY_PER_BUYER_LIMIT = 2;

    uint256 public PRESALE_COMMON_LIMIT = 200;
    uint256 public PRESALE_RARE_LIMIT = 200;
    uint256 public PRESALE_EPIC_LIMIT = 200;
    uint256 public PRESALE_LEGENDARY_LIMIT = 200;

    uint256 public PRESALE_COMMON_PRICE = 179 * (10 ** 18);
    uint256 public PRESALE_RARE_PRICE = 370 * (10 ** 18);
    uint256 public PRESALE_EPIC_PRICE = 2193 * (10 ** 18);
    uint256 public PRESALE_LEGENDARY_PRICE = 5610 * (10 ** 18);

    uint256 public presaleCommonCount = 0;
    uint256 public presaleRareCount = 0;
    uint256 public presaleEpicCount = 0;
    uint256 public presaleLegendaryCount = 0;

    address[] public presaleCommonBuyer;
    address[] public presaleRareBuyer;
    address[] public presaleEpicBuyer;
    address[] public presaleLegendaryBuyer;

    // Testnet BUSD
    address public BUSD_ADDR = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address public PRESALE_WALLET_ADDRESS;

    // Whitelist
    mapping(address => bool) public whitelisted;

    // Buyer List
    mapping ( address => uint256 ) public presaleCommonBuyers;
    mapping ( address => uint256 ) public presaleRareBuyers;
    mapping ( address => uint256 ) public presaleEpicBuyers;
    mapping ( address => uint256 ) public presaleLegendaryBuyers;

    // Whitelist Enable Flag
    bool public WHITELIST_ONLY = false;

    /**
    * @notice PresalePurchased event is triggered whenever a user PresalePurchased presale
    */
    event PresalePurchased(address indexed user, uint256 amount, bytes32 message, uint256 timestamp);

    // Whitelist event
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressBatchAdded(address[] addrs);
    event WhitelistedAddressRemoved(address addr);
    event WhitelistedAddressBatchRemoved(address[] addrs);

    constructor(address _BusdAddress, address _presaleWallet) {
        BUSD_ADDR = address(_BusdAddress);
        PRESALE_WALLET_ADDRESS = address(_presaleWallet);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(SALE_STATUS_ROLE, _msgSender());
        _setupRole(WITHDRAWER_ROLE, _msgSender());
        _setupRole(SET_WALLET_ROLE, _msgSender());
        _setupRole(SET_WALLET_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        _setSaleStatus(keccak256("PRESALE_CLOSED"));
    }

    function setSaleStatus(bytes32 status) external {
        _setSaleStatus(status);
    }

    function presaleCommonSell(uint256 amount) public whenNotPaused {
        _presaleCommonSell(amount);
    }

    function presaleRareSell(uint256 amount) public whenNotPaused {
        _presaleRareSell(amount);
    }

    function presaleEpicSell(uint256 amount) public whenNotPaused {
        _presaleEpicSell(amount);
    }

    function presaleLegendarySell(uint256 amount) public whenNotPaused {
        _presaleLegendarySell(amount);
    }

    function setWallet(bytes32 wallet, address payable addr) external returns (bool) {
        return _setWallet(wallet, addr);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function withdrawBNB(address payable to, uint256 amount) public whenNotPaused onlyRole(WITHDRAWER_ROLE) {
        (bool succeed,) = to.call{value : amount}("");
        require(succeed, "PRESALE: WITHDRAWBNB_TRANSFER_FAILED");
    }

    receive() external payable {}

    function _isSaleStatus(bytes32 status) private view returns (bool) {
        return _saleStatus == status;
    }

    function _presaleCommonSell(uint256 amount) private whenNotPaused returns (bool) {
        if (WHITELIST_ONLY) {
            require(whitelisted[msg.sender], "PRESALE: NOT_IN_PRESALE_WHITELIST");
        }
        require(_isSaleStatus(keccak256("PRESALE_OPEN")), "PRESALE: PRIVATE_SALE_IS_CLOSED");
        require(presaleCommonCount <= PRESALE_COMMON_LIMIT, "PRESALE: REACHED_COMMON_LIMIT");
        require(presaleCommonBuyers[msg.sender] < PRESALE_COMMON_PER_BUYER_LIMIT, "PRESALE: REACHED_COMMON_PER_BUYER_LIMIT");
        require(amount == PRESALE_COMMON_PRICE, "PRESALE: BUSD_AMOUNT_NOT_CORRECT");

        uint256 busdAmount = PRESALE_COMMON_PRICE;

        assert(_transferFromBUSD(_msgSender(), PRESALE_WALLET_ADDRESS, busdAmount));
        presaleCommonBuyer.push(msg.sender);
        presaleCommonCount += 1;
        presaleCommonBuyers[msg.sender] += 1;
        uint256 timestamp = block.timestamp;
        emit PresalePurchased(msg.sender, busdAmount, "presale_common", timestamp);
        return true;
    }

    function _presaleRareSell(uint256 amount) private whenNotPaused returns (bool) {
        if (WHITELIST_ONLY) {
            require(whitelisted[msg.sender], "PRESALE: NOT_IN_PRESALE_WHITELIST");
        }
        require(_isSaleStatus(keccak256("PRESALE_OPEN")), "PRESALE: PRESALE_SALE_IS_CLOSED");
        require(presaleRareCount <= PRESALE_RARE_LIMIT, "PRESALE: REACHED_RARE_LIMIT");
        require(presaleRareBuyers[msg.sender] < PRESALE_RARE_PER_BUYER_LIMIT, "PRESALE: REACHED_RARE_PER_BUYER_LIMIT");
        require(amount == PRESALE_RARE_PRICE, "PRESALE: BUSD_AMOUNT_NOT_CORRECT");

        uint256 busdAmount = PRESALE_RARE_PRICE;

        assert(_transferFromBUSD(_msgSender(), PRESALE_WALLET_ADDRESS, busdAmount));
        presaleRareBuyer.push(msg.sender);
        presaleRareCount += 1;
        presaleRareBuyers[msg.sender] += 1;
        uint256 timestamp = block.timestamp;
        emit PresalePurchased(msg.sender, busdAmount, "presale_rare", timestamp);
        return true;
    }

    function _presaleEpicSell(uint256 amount) private whenNotPaused returns (bool) {
        if (WHITELIST_ONLY) {
            require(whitelisted[msg.sender], "PRESALE: NOT_IN_PRESALE_WHITELIST");
        }
        require(_isSaleStatus(keccak256("PRESALE_OPEN")), "PRESALE: PRIVATE_SALE_IS_CLOSED");
        require(presaleEpicCount < PRESALE_EPIC_LIMIT, "PRESALE: REACHED EPIC LIMIT");
        require(presaleEpicBuyers[msg.sender] < PRESALE_EPIC_PER_BUYER_LIMIT, "PRESALE: REACHED_EPIC_PER_BUYER_LIMIT");
        require(amount == PRESALE_EPIC_PRICE, "PRESALE: BUSD AMOUNT NOT CORRECT");

        uint256 busdAmount = PRESALE_EPIC_PRICE;

        assert(_transferFromBUSD(_msgSender(), PRESALE_WALLET_ADDRESS, busdAmount));
        presaleEpicCount += 1;
        presaleEpicBuyers[msg.sender] += 1;
        presaleEpicBuyer.push(msg.sender);
        uint256 timestamp = block.timestamp;
        emit PresalePurchased(msg.sender, busdAmount, "presale_epic", timestamp);
        return true;
    }

    function _presaleLegendarySell(uint256 amount) private whenNotPaused returns (bool) {
        if (WHITELIST_ONLY) {
            require(whitelisted[msg.sender], "PRESALE: NOT_IN_PRESALE_WHITELIST");
        }
        require(_isSaleStatus(keccak256("PRESALE_OPEN")), "PRESALE: PRIVATE_SALE_IS_CLOSED");
        require(presaleLegendaryCount < PRESALE_LEGENDARY_LIMIT, "PRESALE: REACHED_LEGENDARY_LIMIT");
        require(presaleLegendaryBuyers[msg.sender] < PRESALE_LEGENDARY_PER_BUYER_LIMIT, "PRESALE: REACHED_LEGENDARY_PER_BUYER_LIMIT");
        require(amount == PRESALE_LEGENDARY_PRICE, "PRESALE:_BUSD_AMOUNT_NOT_CORRECT");

        uint256 busdAmount = PRESALE_LEGENDARY_PRICE;

        assert(_transferFromBUSD(_msgSender(), PRESALE_WALLET_ADDRESS, busdAmount));
        presaleLegendaryCount += 1;
        presaleLegendaryBuyers[msg.sender] += 1;
        presaleLegendaryBuyer.push(msg.sender);
        uint256 timestamp = block.timestamp;
        emit PresalePurchased(msg.sender, busdAmount, "presale_legendary", timestamp);
        return true;
    }

    function _transferFromBUSD(address from, address to, uint256 amount) private returns (bool) {
        bytes4 selector = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        bytes memory abiData = abi.encodeWithSelector(selector, from, to, amount);

        bytes memory returnData = Address.functionCall(BUSD_ADDR, abiData);

        return (returnData.length == 0 || abi.decode(returnData, (bool)));
    }

    function setWhitelistOnlyFlag(bool _whitelistStatus) public onlyRole(DEFAULT_ADMIN_ROLE) {
        WHITELIST_ONLY = _whitelistStatus;
    }

    function _setSaleStatus(bytes32 _status) private whenNotPaused onlyRole(SALE_STATUS_ROLE) {
        _saleStatus = _status;
    }

    function _setWallet(bytes32 wallet, address payable addr) private whenNotPaused returns (bool) {
        require(hasRole(SET_WALLET_ROLE, _msgSender()), "DWG: NOT_ALLOWED_TO_SET_WALLET");

        if (wallet == keccak256("PRESALE_SALE")) {
            PRESALE_WALLET_ADDRESS = addr;
        }
        return true;
    }

    function setPresaleCommonBoxLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_COMMON_LIMIT = amount;
    }

    function setPresaleRareBoxLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_RARE_LIMIT = amount;
    }

    function setPresaleEpicBoxLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_EPIC_LIMIT = amount;
    }

    function setPresaleLegendaryBoxLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_LEGENDARY_LIMIT = amount;
    }

    function setPresaleCommonBuyerLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_COMMON_PER_BUYER_LIMIT = amount;
    }

    function setPresaleRareBuyerLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_RARE_PER_BUYER_LIMIT = amount;
    }

    function setPresaleEpicBuyerLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_EPIC_PER_BUYER_LIMIT = amount;
    }

    function setPresaleLegendaryBuyerLimit(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_LEGENDARY_PER_BUYER_LIMIT = amount;
    }

    function setPresaleCommonBoxPrice(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_COMMON_PRICE = amount;
    }

    function setPresaleRareBoxPrice(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_RARE_PRICE = amount;
    }

    function setPresaleEpicBoxPrice(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_EPIC_PRICE = amount;
    }

    function setPresaleLegendaryBoxPrice(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PRESALE_LEGENDARY_PRICE = amount;
    }

    function setBusdAddress(address busdAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        BUSD_ADDR = busdAddress;
    }

    // Whitelist
    function presaleWhitelistAdd(address _user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        whitelisted[_user] = true;
        emit WhitelistedAddressAdded(_user);
    }

    function presaleWhitelistBatchAdd(address[] memory _users) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint size = _users.length;

        for(uint256 i = 0; i < size; i++){
            whitelisted[_users[i]] = true;
        }
        emit WhitelistedAddressBatchAdded(_users);
    }

    function presaleWhitelistRemove(address _user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        delete whitelisted[_user];
        emit WhitelistedAddressRemoved(_user);
    }

    function presaleWhitelistBatchRemove(address[] memory _users) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint size = _users.length;

        for(uint256 i = 0; i < size; i++){
            delete whitelisted[_users[i]];
        }
        emit WhitelistedAddressBatchRemoved(_users);
    }

    function getMyCommonBoxCount() public view returns(uint256) {
        if (presaleCommonBuyers[msg.sender] > 0) {
            return presaleCommonBuyers[msg.sender];
        }
        return 0;
    }

    function getMyRareBoxCount() public view returns(uint256) {
        if (presaleRareBuyers[msg.sender] > 0) {
            return presaleRareBuyers[msg.sender];
        }
        return 0;
    }

    function getMyEpicBoxCount() public view returns(uint256) {
        if (presaleEpicBuyers[msg.sender] > 0) {
            return presaleEpicBuyers[msg.sender];
        }
        return 0;
    }

    function getMyLegendaryBoxCount() public view returns(uint256) {
        if (presaleLegendaryBuyers[msg.sender] > 0) {
            return presaleLegendaryBuyers[msg.sender];
        }
        return 0;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}