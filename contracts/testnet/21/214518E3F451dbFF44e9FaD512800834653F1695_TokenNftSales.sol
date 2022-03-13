// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./PriceConsumerV3.sol";
import "./OwnPause.sol";
import "./TokenNft.sol";

interface IERC20Ext is IERC20 {
  function decimals() external view returns (uint8);
}

contract TokenNftSales is PriceConsumerV3, OwnPause, ReentrancyGuard {
  using SafeERC20 for IERC20Ext;

  address payable public _beneficiary;

  uint256 public _totalErc20TokensCollected;
  uint256 public _totalNativeTokensCollected;
  uint256 public _totalStablecoinTokensCollected;

  // ERC20 token
  IERC20Ext public _erc20Token;

  // stablecoin token
  IERC20Ext public _stablecoinToken;

  // TokenNft contract
  TokenNft public _tokenNft;

  // "decimals" is 18 for ERC20 tokens
  uint256 constant E18 = 10**18;

  uint256 public _tokenNftPriceUsdCent;

  bool public _buyInErc20Enabled;

  // Keep current number of minted cards
  uint256 public _tokenNumsForSaleMinted;

  // Update frequently by external background service
  uint256 public _erc20TokenPriceInUsdCent; // 100 == 1 USD (i.e. 1 ERC20 costs 1 USD)

  // whitelisted wallets only for "feel lucky" mint
  mapping(address => bool) public _whitelist;

  uint256 public _maxSupplyForSale = 10000;
  uint256 public _maxSupplyForVIP = 500; // not included in the maxSupply
  uint256 public _maxSupplyForFeelLucky = 1000;
  uint256 public _maxSupplyForGallery =
    _maxSupplyForSale - _maxSupplyForFeelLucky;

  // cryptoPaid_: "erc20", "stablecoin", "native"
  event EventBuy(
    address buyer_,
    uint256 tokenId_,
    uint256 amountPaid_,
    string cryptoPaid_,
    uint256 imageId_
  );

  event EventMintForVIP(address[] receiverList_);

  event EventSetTokenNftPriceUsdCent(uint256 tokenNftPriceUsdCent_);
  event EventSetErc20Token(address erc20TokenAddress_);
  event EventSetStablecoinToken(address stablecoinTokenAddress_);
  event EventSetBuyInErc20Enabled(bool buyInErc20Enabled_);

  event EventSetMaxSupplyForSale(uint256 maxSupplyForSale_);
  event EventSetMaxSupplyForVIP(uint256 maxSupplyForVIP_);
  event EventSetMaxSupplyForFeelLucky(uint256 maxSupplyForFeelLucky_);

  event EventSetErc20TokenPriceInUsdCent(uint256 erc20TokenPriceInUsdCent_);
  event EventSetBeneficiary(address beneficiary_);
  event EventSetWhitelist(address walletAddress_);
  event EventRemoveWhitelist(address walletAddress_);
  event EventSetWhitelistMany(address[] walletAddressList_);

  constructor(
    address tokenNftAddress_,
    uint256 tokenNftPriceUsdCent_,
    address beneficiary_
  ) {
    require(
      tokenNftAddress_ != address(0),
      "TokenNftSales: Invalid tokenNftAddress_ address"
    );

    // tokenNftPriceUsdCent_ can be zero upon deployment

    require(
      beneficiary_ != address(0),
      "TokenNftSales: Invalid beneficiary_ address"
    );

    _tokenNft = TokenNft(tokenNftAddress_);
    _tokenNftPriceUsdCent = tokenNftPriceUsdCent_;
    _beneficiary = payable(beneficiary_);
  }

  // Applicable for feel-lucky and gallery (not for VIP)
  function checkIfCanMint(address wallet_, uint256 imageId_) public view {
    // Feel lucky (with random imageId)
    if (imageId_ == 0) {
      require(
        _whitelist[wallet_],
        "TokenNftSales: Not whitelisted wallet for feel lucky"
      );

      require(
        _tokenNft.getCurrentNumForFeelLucky() < _maxSupplyForFeelLucky,
        "TokenNftSales: _maxSupplyForFeelLucky exceed"
      );
    } else {
      require(
        _tokenNft.getCurrentNumForGallery() < _maxSupplyForGallery,
        "TokenNftSales: _maxSupplyForGallery exceed"
      );
    }
  }

  ////////// Start setter /////////

  function setTokenNftPriceUsdCent(uint256 tokenNftPriceUsdCent_)
    external
    isAuthorized
  {
    require(
      tokenNftPriceUsdCent_ > 0,
      "TokenNftSales: Invalid tokenNftPriceUsdCent_"
    );

    _tokenNftPriceUsdCent = tokenNftPriceUsdCent_;

    emit EventSetTokenNftPriceUsdCent(tokenNftPriceUsdCent_);
  }

  function setStablecoinToken(address stablecoinTokenAddress_)
    public
    isAuthorized
  {
    require(
      stablecoinTokenAddress_ != address(0),
      "TokenNftSales: Invalid stablecoinTokenAddress_"
    );

    _stablecoinToken = IERC20Ext(stablecoinTokenAddress_);

    emit EventSetStablecoinToken(stablecoinTokenAddress_);
  }

  function enableBuyInErc20(
    address erc20TokenAddress_,
    uint256 erc20TokenPriceInUsdCent_
  ) external isAuthorized {
    setErc20Token(erc20TokenAddress_);
    setErc20TokenPriceInUsdCent(erc20TokenPriceInUsdCent_);
    setBuyInErc20Enabled(true);
  }

  function setErc20Token(address erc20TokenAddress_) public isAuthorized {
    require(
      erc20TokenAddress_ != address(0),
      "TokenNftSales: Invalid erc20TokenAddress_"
    );

    _erc20Token = IERC20Ext(erc20TokenAddress_);

    emit EventSetErc20Token(erc20TokenAddress_);
  }

  function setErc20TokenPriceInUsdCent(uint256 erc20TokenPriceInUsdCent_)
    public
    isAuthorized
  {
    // erc20TokenPriceInUsdCent_ can be zero
    _erc20TokenPriceInUsdCent = erc20TokenPriceInUsdCent_;

    emit EventSetErc20TokenPriceInUsdCent(erc20TokenPriceInUsdCent_);
  }

  function setBuyInErc20Enabled(bool buyInErc20Enabled_) public isAuthorized {
    _buyInErc20Enabled = buyInErc20Enabled_;

    emit EventSetBuyInErc20Enabled(buyInErc20Enabled_);
  }

  function setMaxSupplyForSale(uint256 maxSupplyForSale_) public isAuthorized {
    _maxSupplyForSale = maxSupplyForSale_;

    emit EventSetMaxSupplyForSale(maxSupplyForSale_);
  }

  function setMaxSupplyForVIP(uint256 maxSupplyForVIP_) public isAuthorized {
    require(
      maxSupplyForVIP_ < _maxSupplyForSale,
      "TokenNftSales: maxSupplyForVIP_ >= _maxSupplyForSale"
    );

    _maxSupplyForVIP = maxSupplyForVIP_;

    emit EventSetMaxSupplyForVIP(maxSupplyForVIP_);
  }

  function setMaxSupplyForFeelLucky(uint256 maxSupplyForFeelLucky_)
    public
    isAuthorized
  {
    require(
      maxSupplyForFeelLucky_ < _maxSupplyForSale,
      "TokenNftSales: maxSupplyForFeelLucky_ >= _maxSupplyForSale"
    );

    _maxSupplyForFeelLucky = maxSupplyForFeelLucky_;

    emit EventSetMaxSupplyForFeelLucky(maxSupplyForFeelLucky_);
  }

  function setBeneficiary(address beneficiary_) external isAuthorized {
    require(
      beneficiary_ != address(0),
      "TokenNftSales: Invalid beneficiary_ address"
    );
    _beneficiary = payable(beneficiary_);

    emit EventSetBeneficiary(beneficiary_);
  }

  function setWhitelist(address walletAddress_) public isAuthorized {
    require(
      walletAddress_ != address(0),
      "TokenNftSales: Invalid walletAddress_"
    );

    _whitelist[walletAddress_] = true;

    emit EventSetWhitelist(walletAddress_);
  }

  function removeWhitelist(address walletAddress_) external isAuthorized {
    require(
      walletAddress_ != address(0),
      "TokenNftSales: Invalid walletAddress_"
    );

    _whitelist[walletAddress_] = false;

    emit EventRemoveWhitelist(walletAddress_);
  }

  function setWhitelistMany(address[] memory walletAddressList_)
    external
    isAuthorized
  {
    for (uint256 i = 0; i < walletAddressList_.length; i++) {
      setWhitelist(walletAddressList_[i]);
    }

    emit EventSetWhitelistMany(walletAddressList_);
  }

  ////////// End setter /////////

  // Get price of ETH or BNB
  function getNativeCoinPriceInUsdCent() public view returns (uint256) {
    uint256 nativeCoinPriceInUsdCent = uint256(getThePrice() / 10**6);
    return nativeCoinPriceInUsdCent;
  }

  // Token price in ETH or BNB
  function getTokenNftPriceInNative() public view returns (uint256) {
    uint256 nativeCoinPriceInUsdCent = getNativeCoinPriceInUsdCent();

    uint256 tokenNftPriceInNative = (_tokenNftPriceUsdCent * E18) /
      nativeCoinPriceInUsdCent;

    return tokenNftPriceInNative;
  }

  function getTokenNftPriceInUSD() public view returns (uint256) {
    return (_tokenNftPriceUsdCent / 100);
  }

  // BUSD has 18 decimals
  function getTokenNftPriceInStablecoin() public view returns (uint256) {
    return ((_tokenNftPriceUsdCent * (10**_stablecoinToken.decimals())) / 100);
  }

  // Get token price in ERC20 tokens depending on the current price of ERC20
  function getTokenNftPriceInErc20Tokens() public view returns (uint256) {
    uint256 tokenNftPriceInErc20Tokens = (_tokenNftPriceUsdCent * E18) /
      _erc20TokenPriceInUsdCent;

    return tokenNftPriceInErc20Tokens;
  }

  // Buy token in erc20 tokens (ETH or BNB)
  // For feel-lucky else for gallery
  function buyInStablecoin(uint256 imageId_)
    external
    whenNotPaused
    nonReentrant
    returns (uint256)
  {
    require(_tokenNftPriceUsdCent > 0, "TokenNftSales: invalid token price");
    require(
      address(_stablecoinToken) != address(0),
      "TokenNftSales: _stablecoinToken not set"
    );

    uint256 tokenNftPriceInStablecoin = getTokenNftPriceInStablecoin();

    // Check if user balance has enough tokens
    require(
      tokenNftPriceInStablecoin <= _stablecoinToken.balanceOf(_msgSender()),
      "TokenNftSales: user balance does not have enough stablecoin tokens"
    );

    checkIfCanMint(_msgSender(), imageId_);

    _stablecoinToken.safeTransferFrom(
      _msgSender(),
      _beneficiary,
      tokenNftPriceInStablecoin
    );

    _totalStablecoinTokensCollected += tokenNftPriceInStablecoin;
    _tokenNumsForSaleMinted++;

    uint256 tokenId = imageId_ == 0
      ? _tokenNft.mintForFeelLucky(_msgSender())
      : _tokenNft.mintForGallery(_msgSender(), imageId_);

    emit EventBuy(
      _msgSender(),
      tokenId,
      tokenNftPriceInStablecoin,
      "stablecoin",
      imageId_
    );

    return tokenId;
  }

  // Buy token in erc20 tokens (ETH or BNB)
  // For feel-lucky else for gallery
  function buyInErc20(uint256 imageId_)
    external
    whenNotPaused
    nonReentrant
    returns (uint256)
  {
    require(_tokenNftPriceUsdCent > 0, "TokenNftSales: invalid token price");
    require(_buyInErc20Enabled, "TokenNftSales: buyInErc20 disabled");
    require(
      _erc20TokenPriceInUsdCent > 0,
      "TokenNftSales: ERC20 token price not set"
    );

    uint256 tokenNftPriceInErc20Tokens = getTokenNftPriceInErc20Tokens();

    // Check if user balance has enough tokens
    require(
      tokenNftPriceInErc20Tokens <= _erc20Token.balanceOf(_msgSender()),
      "TokenNftSales: user balance does not have enough ERC20 tokens"
    );

    checkIfCanMint(_msgSender(), imageId_);

    _erc20Token.safeTransferFrom(
      _msgSender(),
      _beneficiary,
      tokenNftPriceInErc20Tokens
    );

    _totalErc20TokensCollected += tokenNftPriceInErc20Tokens;
    _tokenNumsForSaleMinted++;

    uint256 tokenId = imageId_ == 0
      ? _tokenNft.mintForFeelLucky(_msgSender())
      : _tokenNft.mintForGallery(_msgSender(), imageId_);

    emit EventBuy(
      _msgSender(),
      tokenId,
      tokenNftPriceInErc20Tokens,
      "erc20",
      imageId_
    );

    return tokenId;
  }

  // Buy token in native coins (ETH or BNB)
  // For feel-lucky else for gallery
  function buyInNative(uint256 imageId_)
    external
    payable
    whenNotPaused
    nonReentrant
    returns (uint256)
  {
    require(
      _tokenNftPriceUsdCent > 0,
      "TokenNftSales: invalid token NFT price"
    );

    uint256 tokenNftPriceInNative = getTokenNftPriceInNative();

    // Check if user-transferred amount is enough
    require(
      msg.value >= tokenNftPriceInNative,
      "TokenNftSales: user-transferred amount not enough"
    );

    checkIfCanMint(_msgSender(), imageId_);

    // Transfer msg.value from user wallet to beneficiary
    (bool success, ) = _beneficiary.call{value: msg.value}("");
    require(success, "TokenNftSales: Native transfer to beneficiary failed");

    _totalNativeTokensCollected += msg.value;
    _tokenNumsForSaleMinted++;

    uint256 tokenId = imageId_ == 0
      ? _tokenNft.mintForFeelLucky(_msgSender())
      : _tokenNft.mintForGallery(_msgSender(), imageId_);

    emit EventBuy(_msgSender(), tokenId, msg.value, "native", imageId_);

    return tokenId;
  }

  function mintForVIP(address[] memory receiverList_)
    external
    nonReentrant
    isAuthorized
  {
    require(
      _tokenNft.getCurrentNumForVIP() < _maxSupplyForVIP,
      "TokenNftSales: _maxSupplyForVIP exceed"
    );

    _tokenNft.mintManyForVIP(receiverList_);

    emit EventMintForVIP(receiverList_);
  }

  // BNB price when running on BSC or ETH price when running on Ethereum
  function getCurrentPrice() public view returns (int256) {
    return getThePrice() / 10**8;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC721URIStorageEnumerable.sol";
import "./OwnPause.sol";

contract TokenNft is ERC721URIStorageEnumerable, OwnPause {
  using Strings for uint256;

  // First tokenId begins from 1
  // Also indicate the total number of minted tokens
  uint256 public _tokenId;

  string public _baseExtension = ".json";

  // https://base-link/vip/
  string public _baseTokenURIForVIP;
  // https://base-link/vip/1.json
  uint256 public _currentNumForVIP = 0; // current number of minted tokens for VIP

  // https://base-link/feel-lucky/
  string public _baseTokenURIForFeelLucky;
  // https://base-link/feel-lucky/1.json
  uint256 public _currentNumForFeelLucky = 0; // current number of minted tokens for feel-lucky

  // https://base-link/gallery/
  string public _baseTokenURIForGallery;
  // https://base-link/gallery/1.json
  uint256 public _currentNumForGallery = 0; // current number of minted tokens for gallery

  // https://base-link/reserved/
  string public _baseTokenURIForReserved;
  // https://base-link/reserved/1.json
  uint256 public _currentNumForReserved = 0; // current number of minted tokens for reserved

  event EventMintManyForReserved(address _receiver, uint256 _amount);

  event EventMintForVIP(
    uint256 _tokenId,
    address _tokenOwner,
    string _tokenURI
  );

  event EventMintForFeelLucky(
    uint256 _tokenId,
    address _tokenOwner,
    string _tokenURI
  );

  event EventMintForGallery(
    uint256 _tokenId,
    address _tokenOwner,
    string _tokenURI
  );

  event EventSetBaseTokenURIForVIP(string _baseTokenURIForVIP);
  event EventSetBaseTokenURIForFeelLucky(string _baseTokenURIForFeelLucky);
  event EventSetBaseTokenURIForGallery(string _baseTokenURIForGallery);

  event EventAdminTransferToken(uint256 tokenId_, address receiver_);

  constructor(
    string memory name_,
    string memory symbol_,
    string memory baseTokenURIForVIP_,
    string memory baseTokenURIForFeelLucky_,
    string memory baseTokenURIForGallery_
  ) ERC721(name_, symbol_) {
    setBaseTokenURIForAll(
      baseTokenURIForVIP_,
      baseTokenURIForFeelLucky_,
      baseTokenURIForGallery_
    );
  }

  // Apply pausable for token transfer
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    require(!paused(), "TokenNft: paused");
  }

  function setBaseTokenURIForVIP(string memory baseTokenURIForVIP_)
    public
    isAuthorized
  {
    _baseTokenURIForVIP = baseTokenURIForVIP_;

    emit EventSetBaseTokenURIForVIP(baseTokenURIForVIP_);
  }

  function setBaseTokenURIForFeelLucky(string memory baseTokenURIForFeelLucky_)
    public
    isAuthorized
  {
    _baseTokenURIForFeelLucky = baseTokenURIForFeelLucky_;

    emit EventSetBaseTokenURIForFeelLucky(baseTokenURIForFeelLucky_);
  }

  function setBaseTokenURIForGallery(string memory baseTokenURIForGallery_)
    public
    isAuthorized
  {
    _baseTokenURIForGallery = baseTokenURIForGallery_;

    emit EventSetBaseTokenURIForGallery(baseTokenURIForGallery_);
  }

  function setBaseTokenURIForAll(
    string memory baseTokenURIForVIP_,
    string memory baseTokenURIForFeelLucky_,
    string memory baseTokenURIForGallery_
  ) public isAuthorized {
    setBaseTokenURIForVIP(baseTokenURIForVIP_);
    setBaseTokenURIForFeelLucky(baseTokenURIForFeelLucky_);
    setBaseTokenURIForGallery(baseTokenURIForGallery_);
  }

  function getCurrentNumForVIP() external view returns (uint256) {
    return _currentNumForVIP;
  }

  function getCurrentNumForFeelLucky() external view returns (uint256) {
    return _currentNumForFeelLucky;
  }

  function getCurrentNumForGallery() external view returns (uint256) {
    return _currentNumForGallery;
  }

  function tokenExists(uint256 tokenId_) external view returns (bool) {
    return _exists(tokenId_);
  }

  function mintForVIP(address _receiver) public isAuthorized returns (uint256) {
    _tokenId = _tokenId + 1;
    _safeMint(_receiver, _tokenId);

    _currentNumForVIP++;
    string memory _tokenURI = string(
      abi.encodePacked(
        _baseTokenURIForVIP,
        _currentNumForVIP.toString(),
        _baseExtension
      )
    );

    _setTokenURI(_tokenId, _tokenURI);

    emit EventMintForVIP(_tokenId, _receiver, _tokenURI);

    return _tokenId;
  }

  function mintManyForVIP(address[] memory _receiverList)
    external
    isAuthorized
  {
    for (uint256 i = 0; i < _receiverList.length; i++) {
      mintForVIP(_receiverList[i]);
    }
  }

  // Mint reserved tokens for list
  function mintManyForReserved(address _receiver, uint256 _amount)
    external
    isAuthorized
  {
    for (uint256 i = 0; i < _amount; i++) {
      _tokenId = _tokenId + 1;
      _safeMint(_receiver, _tokenId);

      _currentNumForReserved++;
      string memory _tokenURI = string(
        abi.encodePacked(
          _baseTokenURIForReserved,
          _currentNumForReserved.toString(),
          _baseExtension
        )
      );

      _setTokenURI(_tokenId, _tokenURI);
    }

    emit EventMintManyForReserved(_receiver, _amount);
  }

  function mintForFeelLucky(address _receiver)
    public
    isAuthorized
    returns (uint256)
  {
    _tokenId = _tokenId + 1;
    _safeMint(_receiver, _tokenId);

    _currentNumForFeelLucky++;
    string memory _tokenURI = string(
      abi.encodePacked(
        _baseTokenURIForFeelLucky,
        _currentNumForFeelLucky.toString(),
        _baseExtension
      )
    );

    _setTokenURI(_tokenId, _tokenURI);

    emit EventMintForFeelLucky(_tokenId, _receiver, _tokenURI);

    return _tokenId;
  }

  function mintManyForFeelLucky(address[] memory _receiverList)
    external
    isAuthorized
  {
    for (uint256 i = 0; i < _receiverList.length; i++) {
      mintForFeelLucky(_receiverList[i]);
    }
  }

  function mintForGallery(address _receiver, uint256 _imageId)
    public
    isAuthorized
    returns (uint256)
  {
    _tokenId = _tokenId + 1;
    _safeMint(_receiver, _tokenId);

    _currentNumForGallery++;
    string memory _tokenURI = string(
      abi.encodePacked(
        _baseTokenURIForGallery,
        _imageId.toString(),
        _baseExtension
      )
    );

    _setTokenURI(_tokenId, _tokenURI);

    emit EventMintForGallery(_tokenId, _receiver, _tokenURI);

    return _tokenId;
  }

  function mintManyForGallery(
    address[] memory _receiverList,
    uint256[] memory _imageIdList
  ) external isAuthorized {
    require(
      _receiverList.length == _imageIdList.length,
      "TokenNft: _receiverList and _imageIdList not same length"
    );

    for (uint256 i = 0; i < _receiverList.length; i++) {
      mintForGallery(_receiverList[i], _imageIdList[i]);
    }
  }

  function adminTransferToken(uint256 tokenId_, address receiver_)
    external
    isAuthorized
  {
    require(_exists(tokenId_), "TokenNft: Token not exist");

    address tokenOwner = ownerOf(tokenId_);
    _safeTransfer(tokenOwner, receiver_, tokenId_, "");

    emit EventAdminTransferToken(tokenId_, receiver_);
  }

  function transfer(uint256 tokenId_, address receiver_) external {
    require(ownerOf(tokenId_) == _msgSender(), "TokenNft: Not token owner");

    _safeTransfer(_msgSender(), receiver_, tokenId_, "");
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

abstract contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  int256 private constant fakePrice = 2000 * 10**8; // remember to multiply by 10 ** 8

  // Price feed for ETH/USD on Ethereum and Matic
  // Price feed for BNB/USD on BSC
  constructor() {
    if (block.chainid == 1) {
      // Ethereum mainnet
      priceFeed = AggregatorV3Interface(
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
      );
    } else if (block.chainid == 4) {
      // Rinkeby
      priceFeed = AggregatorV3Interface(
        0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
      );
    } else if (block.chainid == 56) {
      // BSC mainnet
      priceFeed = AggregatorV3Interface(
        0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
      );
    } else if (block.chainid == 97) {
      // BSC testnet
      priceFeed = AggregatorV3Interface(
        0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
      );
    } else {
      // Unit-test
    }
  }

  // The returned price must be divided by 10**8
  function getThePrice() public view returns (int256) {
    if (
      block.chainid == 1 ||
      block.chainid == 4 ||
      block.chainid == 56 ||
      block.chainid == 97
    ) {
      (, int256 price, , , ) = priceFeed.latestRoundData();
      require(price > 0, "PriceConsumerV3: invalid price returned");
      return price;
    } else {
      return fakePrice;
    }
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract OwnPause is Ownable, Pausable {
    // List of _authorizedAddressList addresses
    mapping(address => bool) internal _authorizedAddressList;

    event EventGrantAuthorized(address auth_);
    event EventRevokeAuthorized(address auth_);

    modifier isOwner() {
        require(msg.sender == owner(), "OwnPause: not owner");
        _;
    }

    modifier isAuthorized() {
        require(
            msg.sender == owner() || _authorizedAddressList[msg.sender] == true,
            "OwnPause: unauthorized"
        );
        _;
    }

    function checkAuthorized(address auth_) public view returns (bool) {
        require(auth_ != address(0), "OwnPause: invalid auth_ address ");

        return auth_ == owner() || _authorizedAddressList[auth_] == true;
    }

    function grantAuthorized(address auth_) external isOwner {
        require(auth_ != address(0), "OwnPause: invalid auth_ address ");

        _authorizedAddressList[auth_] = true;

        emit EventGrantAuthorized(auth_);
    }

    function revokeAuthorized(address auth_) external isOwner {
        require(auth_ != address(0), "OwnPause: invalid auth_ address ");

        _authorizedAddressList[auth_] = false;

        emit EventRevokeAuthorized(auth_);
    }

    function pause() external isOwner {
        _pause();
    }

    function unpause() external isOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721URIStorage is ERC721 {
  using Strings for uint256;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721URIStorage: URI query for nonexistent token"
    );

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
  function _setTokenURI(uint256 tokenId, string memory _tokenURI)
    internal
    virtual
  {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
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
  function _burn(uint256 tokenId) internal virtual override {
    super._burn(tokenId);

    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }
}

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721URIStorageEnumerable is
  ERC721URIStorage,
  IERC721Enumerable
{
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
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      interfaceId == type(IERC721Enumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
   */
  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      index < ERC721.balanceOf(owner),
      "ERC721Enumerable: owner index out of bounds"
    );
    return _ownedTokens[owner][index];
  }

  /**
   * @dev Return tokenId list owned by the specified "_userAddr".
   */
  function getTokenIdsOfUserAddress(address _userAddr)
    public
    view
    returns (uint256[] memory)
  {
    uint256 tokenCount = ERC721.balanceOf(_userAddr);

    uint256[] memory tokenIds = new uint256[](tokenCount);
    for (uint256 i = 0; i < tokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_userAddr, i);
    }
    return tokenIds;
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
  function tokenByIndex(uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      index < totalSupply(),
      "ERC721Enumerable: global index out of bounds"
    );
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
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
    private
  {
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