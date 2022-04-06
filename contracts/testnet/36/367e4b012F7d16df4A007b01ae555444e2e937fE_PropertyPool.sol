// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyPool is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC721HolderUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using Counters for Counters.Counter;

  struct WhitelistInput {
    address wallet;
    uint256 allocation;
  }
  struct Whitelist {
    address wallet;
    uint256 allocation;
    uint256 claim;
    uint256 reserve;
    bool enabled;
  }
  struct ReserveStruct {
    address wallet;
    uint256 value;
    uint propertyType;
    bool claimed;
    uint256 timestamp;
    bool isWhitelist;
  }

  Counters.Counter public reserveIds;
  mapping(uint256 => ReserveStruct) public reserves;
  uint256 public constant NOMINATOR = 10_000;
  // Whitelist map
  mapping(address => Whitelist) public whitelist;
  mapping(uint256 => uint256) public propertyTypes;
  mapping(uint256 => uint256) public propertyLimits;
  mapping(uint256 => uint256) public specialPrices;
  mapping(uint256 => uint256) public regularPrices;
  //  Status: not available = 0, available = 1, sold = 2
  mapping(uint256 => uint8) public propertyStatus;
  mapping(address => mapping(uint256 => uint256)) public reservation;
  mapping(address => mapping(uint256 => uint256)) public claims;
  mapping(uint256 => uint256) public refNFTIDs;
  mapping(uint256 => uint256) public typesCount;

  uint256 public minimumDepositPercentage;
  uint256 public whitelistReserveStartTime;
  uint256 public publicReserveStartTime;
  bool public reserveEnabled;
  uint256 public claimStartTime;
  bool public claimEnabled;
  bool public refIdMode;
  bool public buyEnabled;

  address[] public whitelistUsers;

  IERC20Upgradeable public nafterToken;
  IERC721Upgradeable public nft;
  uint256 public feePercentage;
  uint256 public claimTime;
  address public assetHolder;
  event Reserve(address indexed user, uint256 propertyType, uint256 reserveId, bool isWhitelist);
  event Claim(address indexed user, uint256 nftId, uint256 reserveId);
  event Buy(address indexed user, uint256 nftId);

  /**
   * @dev Constructor
   * @param _nafterToken Nafter token address
   */
  function __PropertyPool_init(IERC20Upgradeable _nafterToken) external initializer {
    __Ownable_init();
    __ReentrancyGuard_init();
    nafterToken = _nafterToken;
    minimumDepositPercentage = 5_000; // 50% by default
  }

  /**
   * @dev Set addresses
   * @param _nafterToken Nafter token address
   * @param _nft NFT contract address
   */
  function setAddresses(IERC20Upgradeable _nafterToken, IERC721Upgradeable _nft) external onlyOwner {
    nafterToken = _nafterToken;
    nft = _nft;
  }

  /**
   * @dev Set fee percentage and claim time
   * @param _feePercentage Fee Percentage 10% will be 1000
   * @param _claimTime Set claim  time
   */
  function setConfig(uint256 _feePercentage, uint256 _claimTime) external onlyOwner {
    feePercentage = _feePercentage;
    claimTime = _claimTime;
  }

  /**
   * @dev Set prices against types
   * @param _types List of types
   * @param _specialPrices List of reservePrices
   * @param _regularPrices List of buyPrices
   */
  function setPropertyPrices(
    uint256[] memory _types,
    uint256[] memory _specialPrices,
    uint256[] memory _regularPrices
  ) external onlyOwner {
    require((_types.length == _specialPrices.length) && (_types.length == _regularPrices.length), "length is invalid");
    for (uint256 index = 0; index < _types.length; index++) {
      specialPrices[_types[index]] = _specialPrices[index];
      regularPrices[_types[index]] = _regularPrices[index];
    }
  }

  /**
   * @dev Set prices against types
   * @param _types List of types
   * @param _limits List of Prices
   */
  function setPropertyLimits(uint256[] memory _types, uint256[] memory _limits) external onlyOwner {
    require(_types.length == _limits.length, "length is invalid");
    for (uint256 index = 0; index < _types.length; index++) {
      propertyLimits[_types[index]] = _limits[index];
    }
  }

  /**
   * @dev Set reserve config
   * @param _reserveEnabled Reserve enabled
   * @param _whitelistReserveStartTime Start time of reserve
   * @param _publicReserveStartTime Start time of reserve
   */
  function setReserveConfig(
    bool _reserveEnabled,
    uint256 _whitelistReserveStartTime,
    uint256 _publicReserveStartTime
  ) external onlyOwner {
    reserveEnabled = _reserveEnabled;
    whitelistReserveStartTime = _whitelistReserveStartTime;
    publicReserveStartTime = _publicReserveStartTime;
  }

  /**
   * @dev Set reserve config
   * @param _claimEnabled Claim enabled
   * @param _claimStartTime Start time of claim
   */
  function setClaimConfig(bool _claimEnabled, uint256 _claimStartTime) external onlyOwner {
    claimEnabled = _claimEnabled;
    claimStartTime = _claimStartTime;
  }

  function setUseRefIdMode(bool _refIdMode) external onlyOwner {
    refIdMode = _refIdMode;
  }

  function setBuyEnable(bool _buyEnable) external onlyOwner {
    buyEnabled = _buyEnable;
  }

  function setMinimumDepositPercentage(uint256 _minimumDepositPercentage) external onlyOwner {
    minimumDepositPercentage = _minimumDepositPercentage;
  }

  /**
   * @dev Import nft ids, both parameters length should be matched
   * @param _ids NFT Ids
   * @param _types Types ids
   */
  function importPropertyTypeIds(uint256[] memory _ids, uint256[] memory _types) external onlyOwner {
    require(_ids.length == _types.length, "length is invalid");
    for (uint256 index = 0; index < _ids.length; index++) {
      if (propertyStatus[_ids[index]] == 0) {
        propertyStatus[_ids[index]] = 1;
      }
      propertyTypes[_ids[index]] = _types[index];
    }
  }

  /**
   * @dev map external NFT Ids
   * @param _ids NFT Ids
   * @param _externalIds External Ids
   */
  function importRefIds(uint256[] memory _ids, uint256[] memory _externalIds) external onlyOwner {
    require(refIdMode == true, "ref id mode should be true");
    for (uint256 index = 0; index < _ids.length; index++) {
      refNFTIDs[_ids[index]] = _externalIds[index];
    }
  }

  /**
   * @dev Set Asset holder
   * @param _assetHolder Address of asset holder
   */
  function setAssetHolder(address _assetHolder) external onlyOwner {
    assetHolder = _assetHolder;
  }

  /**
   * @dev Add list to whitelist
   * @param _inputs Input array of whitelist
   */
  function addWhitelist(WhitelistInput[] memory _inputs) external onlyOwner {
    uint256 addressesLength = _inputs.length;
    for (uint256 i = 0; i < addressesLength; i++) {
      WhitelistInput memory input = _inputs[i];
      if (whitelist[input.wallet].wallet == address(0)) {
        whitelistUsers.push(input.wallet);
      }
      Whitelist memory _whitelist = Whitelist(input.wallet, input.allocation, 0, 0, true);

      whitelist[input.wallet] = _whitelist;
    }
  }

  /**
   * @dev Remove from whitelist
   * @param _addresses List of addresses to remove
   */
  function removeWhitelist(address[] memory _addresses) external onlyOwner {
    uint256 addressesLength = _addresses.length;

    for (uint256 i = 0; i < addressesLength; i++) {
      address _address = _addresses[i];
      Whitelist memory _whitelistSnapshot = whitelist[_address];
      whitelist[_address] = Whitelist(
        _address,
        _whitelistSnapshot.allocation,
        _whitelistSnapshot.claim,
        _whitelistSnapshot.reserve,
        false
      );
    }
  }

  /**
   * @dev Withdraw NFT token
   */
  function withdrawNAFTToken() external {
    address sender_ = _msgSender();
    require(assetHolder == sender_, "you are not asset holder");
    uint256 balance = nafterToken.balanceOf(address(this));
    nafterToken.safeTransfer(sender_, balance);
  }

  /**
   * @dev Withdraw NFT Ids
   * @param _ids NFT Ids
   */
  function withdrawNFTs(uint256[] memory _ids) external onlyOwner {
    address sender_ = _msgSender();
    for (uint256 index = 0; index < _ids.length; index++) {
      nft.transferFrom(address(this), sender_, _ids[index]);
    }
  }

  /**
   * @dev Get minimum reserve value of type
   * @param _type Property NFT Id
   */
  function minimumAmount(uint256 _type) public view returns (uint256) {
    bool isWhitelistTime = block.timestamp < publicReserveStartTime;
    uint256 minimumAmount_ = regularPrices[_type] + ((regularPrices[_type] * feePercentage) / NOMINATOR);
    if (isWhitelistTime) {
      minimumAmount_ = specialPrices[_type] + ((specialPrices[_type] * feePercentage) / NOMINATOR);
    }
    minimumAmount_ = (minimumAmount_ * minimumDepositPercentage) / NOMINATOR;
    return minimumAmount_;
  }

  /**
   * @dev Get minimum reserve value of type
   * @param _type Property NFT Id
   * @param _reserveId Reserve Id
   */
  function remainAmount(uint256 _type, uint256 _reserveId) public view returns (uint256) {
    bool isWhitelist = reserves[_reserveId].isWhitelist;
    uint256 price_ = regularPrices[_type] + ((regularPrices[_type] * feePercentage) / NOMINATOR);
    if (isWhitelist) {
      price_ = specialPrices[_type] + ((specialPrices[_type] * feePercentage) / NOMINATOR);
    }
    uint256 remaining_ = price_ - reserves[_reserveId].value;
    return remaining_;
  }

  /**
   * @dev Reserve a new Property
   * @param _type Property NFT Id
   */
  function reserve(uint256 _type, uint256 _amount) external nonReentrant {
    require(reserveEnabled == true && block.timestamp > whitelistReserveStartTime, "Reservation has not started yet");
    bool isWhitelistTime = block.timestamp < publicReserveStartTime;
    uint256 minimumAmount_ = minimumAmount(_type);
    address sender_ = _msgSender();
    require(_amount >= minimumAmount_, "Incorrect reservation amount");

    if (isWhitelistTime == true) {
      Whitelist storage _whitelist = whitelist[sender_];
      require(_whitelist.enabled == true, "User is not whitelisted");
      require(_whitelist.allocation > 0, "Your allocation is 0");
      require(_whitelist.reserve < _whitelist.allocation, "You cannot reserve more");
      _whitelist.reserve++;
    }
    require(typesCount[_type] < propertyLimits[_type], "Out of stock");
    reservation[sender_][_type]++;
    nafterToken.safeTransferFrom(sender_, address(this), _amount);
    typesCount[_type]++;

    reserveIds.increment();

    reserves[reserveIds.current()] = ReserveStruct(sender_, _amount, _type, false, block.timestamp, isWhitelistTime);
    emit Reserve(sender_, _type, reserveIds.current(), isWhitelistTime);
  }

  /**
   * @dev Complete the property
   * @param _id Id of property
   */
  function claim(uint256 _id, uint256 _reserveId) external nonReentrant {
    require(claimEnabled == true && block.timestamp > claimStartTime, "Claim has not started yet");
    address sender_ = _msgSender();
    uint256 propertyType_ = propertyTypes[_id];

    if (reserves[_reserveId].isWhitelist == true) {
      Whitelist storage _whitelist = whitelist[sender_];
      require(_whitelist.enabled == true, "User is not whitelisted");
      _whitelist.claim++;
    }

    require(propertyStatus[_id] == 1, "This property is not available");
    require(block.timestamp > reserves[_reserveId].timestamp + claimTime, "You need to wait");
    require(claims[sender_][propertyType_] < reservation[sender_][propertyType_], "Cannot claim this property");
    require(reserves[_reserveId].wallet == sender_, "Cannot claim this reservation");
    require(reserves[_reserveId].propertyType == propertyType_, "Property type is incorrect");
    require(reserves[_reserveId].claimed == false, "Reservation is claimed");

    claims[sender_][propertyType_]++;
    propertyStatus[_id] = 2;
    reserves[_reserveId].claimed = true;
    uint256 remaining_ = remainAmount(propertyType_, _reserveId);
    if (remaining_ > 0) {
      nafterToken.safeTransferFrom(sender_, address(this), remaining_);
    }

    uint256 id_ = _id;
    if (refIdMode == true) {
      id_ = refNFTIDs[_id];
    }
    nft.transferFrom(address(this), sender_, id_);
    emit Claim(sender_, _id, _reserveId);
  }

  /**
   * @dev Complete the property
   * @param _id Id of property
   */
  function buy(uint256 _id) external nonReentrant {
    address sender_ = _msgSender();
    uint256 propertyType_ = propertyTypes[_id];

    require(buyEnabled == true, "Public sale has not started yet");
    require(propertyStatus[_id] == 1, "This property is not available");

    propertyStatus[_id] = 2;
    nafterToken.safeTransferFrom(sender_, address(this), regularPrices[propertyType_]);

    uint256 id_ = _id;
    if (refIdMode == true) {
      id_ = refNFTIDs[_id];
    }
    nft.transferFrom(address(this), sender_, id_);
    emit Buy(sender_, _id);
  }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal initializer {
        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}