// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./INFT.sol";
import "./access/IMarketCurrencyManager.sol";
import "./access/IMarketAccessManagerV2.sol";
import "./MarketV3Storage.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MarketV3 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public duration; //seconds

    mapping(address => bool) nfts;
    IMarketAccessManagerV2 private accessManager;
    MarketV3Storage private marketStorage;
    IMarketCurrencyManager private currencyManager;
    address vault;

    bytes32 private constant LISTING_ROLE = keccak256("LISTING_ROLE");
    bytes32 private constant UPDATE_PRICE_ROLE = keccak256("UPDATE_PRICE_ROLE");

    event Purchase(
        address indexed previousOwner,
        address indexed newOwner,
        address indexed nft,
        uint256 nftId,
        address currency,
        uint256 listingPrice,
        uint256 price,
        uint256 sellerAmount,
        uint256 commissionAmount,
        uint256 time
    );

    event Listing(
        address indexed owner,
        address indexed nft,
        uint256 indexed nftId,
        address listingUser,
        address currency,
        uint256 listingPrice,
        uint256 listingTime,
        uint256 openTime
    );

    event PriceUpdate(
        address indexed owner,
        address indexed nft,
        uint256 nftId,
        uint256 oldPrice,
        uint256 newPrice,
        uint256 time
    );

    event UnListing(
        address indexed owner,
        address indexed nft,
        uint256 indexed nftId,
        uint256 time
    );

    constructor(
        IMarketAccessManagerV2 _accessManager,
        MarketV3Storage _marketStorage,
        IMarketCurrencyManager _currencyManager,
        address _vault,
        uint256 _duration
    ) {
        require(_vault != address(0), "Error: Vault address(0)");
        require(
            address(_accessManager) != address(0),
            "Error: AccessManager address(0)"
        );
        require(
            address(_marketStorage) != address(0),
            "Error: MarketV3Storage address(0)"
        );

        require(
            address(_currencyManager) != address(0),
            "Error: CurrencyManager address(0)"
        );

        accessManager = _accessManager;
        marketStorage = _marketStorage;
        currencyManager = _currencyManager;
        vault = _vault;
        duration = _duration;
    }

    function setAccessManager(IMarketAccessManagerV2 _accessManager)
        external
        onlyOwner
    {
        require(
            address(_accessManager) != address(0),
            "Error: AccessManager address(0)"
        );
        accessManager = _accessManager;
    }

    function setVauld(address _vault) external onlyOwner {
        require(_vault != address(0), "Error: Vault address(0)");
        vault = _vault;
    }

    function setDuration(uint256 _duration) external onlyOwner {
        duration = _duration;
    }

    function setNFT(address[] memory _nfts, bool[] memory _isSupports)
        external
        onlyOwner
    {
        require(_nfts.length == _isSupports.length, "Error: invalid input");

        for (uint256 i = 0; i < _nfts.length; i++) {
            require(address(_nfts[i]) != address(0), "Error: NFT address(0)");
            nfts[_nfts[i]] = _isSupports[i];
        }
    }

    function setStorage(MarketV3Storage _marketStorage) external onlyOwner {
        require(
            address(_marketStorage) != address(0),
            "Error: MarketV3Storage address(0)"
        );
        marketStorage = _marketStorage;
    }

    function setCurrencyManager(IMarketCurrencyManager _currencyManager)
        external
        onlyOwner
    {
        require(
            address(_currencyManager) != address(0),
            "Error: CurrencyManager address(0)"
        );
        currencyManager = _currencyManager;
    }

    function getItem(address _nft, uint256 _nftId)
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        require(nfts[_nft], "Error: NFT not support");
        require(INFT(_nft).exists(_nftId), "Error: wrong nftId");

        address owner;
        address currency;
        uint256 price;
        uint256 listingTime;
        uint256 openTime;
        (owner, currency, price, listingTime, openTime) = marketStorage
            .getItem(_nft, _nftId);
        uint256 gene;
        (, , , gene, ) = INFT(_nft).get(_nftId);

        return (owner, currency, price, gene, listingTime, openTime);
    }

    function listing(
        address _nft,
        uint256 _nftId,
        address _currency,
        uint256 _price
    ) external whenNotPaused {
        require(
            accessManager.isAllowed(_nft, _nftId, LISTING_ROLE, _msgSender()),
            "Error: Not have listing permisison"
        );

        require(nfts[_nft], "Error: NFT not support");
        require(INFT(_nft).exists(_nftId), "Error: wrong nftId");
        require(
            INFT(_nft).ownerOf(_nftId) == _msgSender(),
            "Error: you are not the owner"
        );
        address owner;
        (owner, , , , ) = marketStorage.getItem(_nft, _nftId);
        require(owner == address(0), "Error: item listing already");

        //check currency
        bool valid;
        uint256 minAmount;
        (, minAmount, valid) = currencyManager.getCurrency(_nft, _currency);
        require(valid, "Error: Currency invalid");
        require(_price >= minAmount, "Error: price invalid");

        marketStorage.addItem(
            _nft,
            _nftId,
            _msgSender(),
            _currency,
            _price,
            block.timestamp,
            block.timestamp + duration
        );
        //transfer NFT for market contract
        INFT(_nft).transferFrom(_msgSender(), address(this), _nftId);
        emit Listing(
            _msgSender(),
            _nft,
            _nftId,
            _msgSender(),
            _currency,
            _price,
            block.timestamp,
            block.timestamp + duration
        );
    }

    function listingByAdmin(
        address[] memory _nfts,
        uint256[] memory _nftIds,
        address[] memory _currencies,
        uint256[] memory _prices,
        uint256[] memory _durations
    ) external whenNotPaused {
        require(_nfts.length == _nftIds.length, "Error: Input invalid");
        require(_nftIds.length == _currencies.length, "Error: Input invalid");
        require(_nftIds.length == _prices.length, "Error: Input invalid");
        require(_nftIds.length == _durations.length, "Error: Input invalid");

        for (uint256 i = 0; i < _nftIds.length; i++) {
            require(
                accessManager.isAllowed(
                    _nfts[i],
                    _nftIds[i],
                    LISTING_ROLE,
                    _msgSender()
                ),
                "Error: Not have listing permisison"
            );
            require(nfts[_nfts[i]], "Error: NFT not support");
            require(INFT(_nfts[i]).exists(_nftIds[i]), "Error: wrong nftId");
            require(
                INFT(_nfts[i]).ownerOf(_nftIds[i]) == _msgSender(),
                "Error: you are not the owner"
            );
            address owner;
            (owner, , , , ) = marketStorage.getItem(_nfts[i], _nftIds[i]);
            require(owner == address(0), "Error: item listing already");

            marketStorage.addItem(
                _nfts[i],
                _nftIds[i],
                _msgSender(),
                _currencies[i],
                _prices[i],
                block.timestamp,
                block.timestamp + _durations[i]
            );
            //transfer NFT for market contract
            INFT(_nfts[i]).transferFrom(
                _msgSender(),
                address(this),
                _nftIds[i]
            );
            emit Listing(
                _msgSender(),
                _nfts[i],
                _nftIds[i],
                _msgSender(),
                _currencies[i],
                _prices[i],
                block.timestamp,
                block.timestamp + _durations[i]
            );
        }
    }

    function buy(
        address _nft,
        uint256 _nftId,
        uint256 _amount
    ) external payable whenNotPaused nonReentrant {
        address owner;
        address currency;
        uint256 price;
        uint256 openTime;
        (owner, currency, price, , openTime) = marketStorage.getItem(
            _nft,
            _nftId
        );
        if (currency == address(0)) {
            _amount = msg.value;
        }
        validate(_nft, _nftId, _amount, owner, currency, price, openTime);

        address previousOwner = INFT(_nft).ownerOf(_nftId);
        address newOwner = _msgSender();

        uint256 commissionAmount;
        uint256 sellerAmount;
        (commissionAmount, sellerAmount) = trade(
            _nft,
            _nftId,
            currency,
            _amount,
            owner
        );

        emit Purchase(
            previousOwner,
            newOwner,
            _nft,
            _nftId,
            currency,
            price,
            _amount,
            sellerAmount,
            commissionAmount,
            block.timestamp
        );
    }

    function validate(
        address _nft,
        uint256 _nftId,
        uint256 _amount,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _openTime
    ) internal view {
        require(nfts[_nft], "Error: NFT not support");
        require(INFT(_nft).exists(_nftId), "Error: wrong nftId");
        require(_owner != address(0), "Item not listed currently");
        require(
            _msgSender() != INFT(_nft).ownerOf(_nftId),
            "Can not buy what you own"
        );
        require(block.timestamp >= _openTime, "Item still lock");
        if (_currency == address(0)) {
            require(msg.value >= _price, "Error: the amount is lower");
        } else {
            require(_amount >= _price, "Error: the amount is lower");
        }
    }

    function trade(
        address _nft,
        uint256 _nftId,
        address _currency,
        uint256 _amount,
        address _nftOwner
    ) internal returns (uint256, uint256) {
        address buyer = _msgSender();

        INFT(_nft).transferFrom(address(this), buyer, _nftId);

        uint256 commission;
        (commission, , ) = currencyManager.getCurrency(_nft, _currency);
        uint256 commissionAmount = (_amount * commission) / 10000;
        uint256 sellerAmount = _amount - commissionAmount;

        if (_currency == address(0)) {
            payable(_nftOwner).transfer(sellerAmount);
            payable(vault).transfer(commissionAmount);
        } else {
            IERC20(_currency).safeTransferFrom(buyer, _nftOwner, sellerAmount);
            IERC20(_currency).safeTransferFrom(buyer, vault, commissionAmount);

            //transfer BNB back to user if currency is not address(0)
            if (msg.value != 0) {
                payable(_msgSender()).transfer(msg.value);
            }
        }

        marketStorage.deleteItem(_nft, _nftId);
        return (commissionAmount, sellerAmount);
    }

    function updatePrice(
        address[] memory _nfts,
        uint256[] memory _nftIds,
        uint256[] memory _prices
    ) public whenNotPaused returns (bool) {
        require(_nftIds.length == _nfts.length, "Error: Input invalid");
        require(_nftIds.length == _prices.length, "Error: Input invalid");
        for (uint256 i = 0; i < _nftIds.length; i++) {
            require(
                accessManager.isAllowed(
                    _nfts[i],
                    _nftIds[i],
                    UPDATE_PRICE_ROLE,
                    _msgSender()
                ),
                "Error: Not have listing permisison"
            );
            require(nfts[_nfts[i]], "Error: NFT not support");

            address nftOwner;
            address currency;
            uint256 oldPrice;
            uint256 listingTime;
            uint256 openTime;
            (
                nftOwner,
                currency,
                oldPrice,
                listingTime,
                openTime
            ) = marketStorage.getItem(_nfts[i], _nftIds[i]);

            require(_msgSender() == nftOwner, "Error: you are not the owner");
            marketStorage.updateItem(
                _nfts[i],
                _nftIds[i],
                nftOwner,
                currency,
                _prices[i],
                listingTime,
                openTime
            );

            emit PriceUpdate(
                _msgSender(),
                _nfts[i],
                _nftIds[i],
                oldPrice,
                _prices[i],
                block.timestamp
            );
        }

        return true;
    }

    function unListing(address[] memory _nfts, uint256[] memory _nftIds)
        public
        whenNotPaused
        returns (bool)
    {
        require(_nfts.length == _nftIds.length, "Error: invalid input");

        for (uint256 i = 0; i < _nftIds.length; i++) {
            require(nfts[_nfts[i]], "Error: NFT not support");

            address nftOwner;
            (nftOwner, , , , ) = marketStorage.getItem(_nfts[i], _nftIds[i]);
            require(_msgSender() == nftOwner, "Error: you are not the owner");

            marketStorage.deleteItem(_nfts[i], _nftIds[i]);

            INFT(_nfts[i]).transferFrom(
                address(this),
                _msgSender(),
                _nftIds[i]
            );

            emit UnListing(_msgSender(), _nfts[i], _nftIds[i], block.timestamp);
        }

        return true;
    }

    function getCurrency(address _nft, address _currency)
        external
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        return currencyManager.getCurrency(_nft, _currency);
    }

    function getConfig()
        external
        view
        onlyOwner
        returns (
            address,
            address,
            address
        )
    {
        return (
            address(accessManager),
            address(marketStorage),
            address(currencyManager)
        );
    }

    /* ========== EMERGENCY ========== */
    /*
    Users make mistake by transfering usdt/busd ... to contract address. 
    This function allows contract owner to withdraw those tokens and send back to users.
    */
    function rescueStuckErc20(address _token) external onlyOwner {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(owner(), _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMarketCurrencyManager {
    function setCurrencies(
        address[] memory _nfts,
        address[] memory _currencies,
        uint256[] memory _commisions,
        uint256[] memory _minAmounts,
        bool[] memory _valids
    ) external;

    function getCurrency(address _nft, address _currency)
        external
        view
        returns (
            uint256,
            uint256,
            bool
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMarketAccessManagerV2 {
    function isAllowed(
        address _nft,
        uint256 _nftId,
        bytes32 _role,
        address _caller
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketV3Storage is Ownable {
    struct Item {
        address owner;
        address currency;
        uint256 price;
        uint256 listingTime;
        uint256 openTime;
    }
    mapping(address => mapping(uint256 => Item)) items;
    // mapping(uint256 => Item) public items;

    address public market;

    modifier onlyMarket() {
        require(market == _msgSender(), "Storage: only market");
        _;
    }

    function setMarket(address _market) external onlyOwner {
        require(_market != address(0), "Error: address(0)");
        market = _market;
    }

    function addItem(
        address _nft,
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) public onlyMarket {
        items[_nft][_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function addItems(
        address[] memory _nfts,
        uint256[] memory _nftIds,
        address[] memory _owners,
        address[] memory _currencies,
        uint256[] memory _prices,
        uint256[] memory _listingTimes,
        uint256[] memory _openTimes
    ) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            addItem(
                _nfts[i],
                _nftIds[i],
                _owners[i],
                _currencies[i],
                _prices[i],
                _listingTimes[i],
                _openTimes[i]
            );
        }
    }

    function deleteItem(address _nft,uint256 _nftId) public onlyMarket {
        delete items[_nft][_nftId];
    }

    function deleteItems(address[] memory _nfts,uint256[] memory _nftIds) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            deleteItem(_nfts[i], _nftIds[i]);
        }
    }

    function updateItem(
        address _nft,
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) external onlyMarket {
        items[_nft][_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function getItem(address _nft, uint256 _nftId)
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            items[_nft][_nftId].owner,
            items[_nft][_nftId].currency,
            items[_nft][_nftId].price,
            items[_nft][_nftId].listingTime,
            items[_nft][_nftId].openTime
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface INFT {
    function get(uint256 _nftId)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function exists(uint256 _id) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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