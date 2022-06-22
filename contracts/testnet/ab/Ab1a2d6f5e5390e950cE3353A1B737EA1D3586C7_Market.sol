/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// File: contracts/interfaces/IMarket.sol



pragma solidity 0.8.7;

interface IMarket {
    event SellToken(address seller, uint256 tokenId, uint256 price, uint256 expireTime);
    event BuyToken(address buyer, uint256 amount, uint256 tokenId);
    event CancelToken(uint256 orderId);

    enum OrderStatus {
        SELLING,
        SOLD,
        CANCEL
    }

    struct Order {
        uint256 tokenId;
        address seller;
        uint256 price;
        uint256 expireTime;
        uint256 createdTime;
        uint256 updatedTime;
        OrderStatus status;
        address receiver;
    }

    function setRelipaNFTContract(address contractAddress) external;

    function sellToken(uint256 tokenId, uint256 price, uint32 expireTime) external;

    function buyToken(uint256 orderId) payable external;

    function cancelSellToken(uint256 orderId) external;
}
// File: contracts/interfaces/INFT.sol



pragma solidity 0.8.7;

interface INFT {
      function mint(
        address receiver,
        uint32 expireTime,
        uint8 discountPercent
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(
        address to,
        uint256 tokenId
    ) external;

    function getApproved(
        uint256 tokenId
    ) view external returns(address);
}
// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Market.sol



pragma solidity 0.8.7;





contract Market is Ownable, IMarket {
    using Address for address;
    INFT public NFTAddress;
    mapping(uint256 => bool) private tokenSellingStatuses;
    mapping(uint256 => Order) public orders;
    uint256 public totalOrders = 0;
 
    modifier NFTContractMustSet() {
        require(address(NFTAddress) != address(0), "Address NFT must set");
        _;
    }

    function setRelipaNFTContract(address contractAddress) override public onlyOwner {
        require(contractAddress != address(0), "Address can not be zero address");
        require(contractAddress.isContract(), "Address must be a contract");
        NFTAddress = INFT(contractAddress);
    }

    function sellToken(uint256 tokenId, uint256 price, uint32 expireTime) override NFTContractMustSet public {
        require(!tokenSellingStatuses[tokenId], "Token already sold");
        require(isApproved(tokenId), "Token has not been approved");
        require(price > 0, "Selling price must greater than 0");
        require(expireTime >= 1800, "Expire time must greater than 30 minutes");
        totalOrders += 1;
        uint256 orderId = totalOrders;
        uint256 currentTime = block.timestamp;
        tokenSellingStatuses[tokenId] = true;
        uint256 orderExpireTime = block.timestamp + expireTime;
        orders[orderId] = Order(tokenId, msg.sender, price, orderExpireTime, currentTime, currentTime, OrderStatus.SELLING, address(0x0));
        NFTAddress.safeTransferFrom(msg.sender, owner(), tokenId);

        emit SellToken(msg.sender, tokenId, price, orderExpireTime);
    }

    function isApproved(uint256 tokenId) NFTContractMustSet view public returns(bool) {
        require(NFTAddress.getApproved(tokenId) == address(this), "Has approved yet");

        return true;
    }

    function buyToken(uint256 orderId) NFTContractMustSet override public payable {
        Order memory order = orders[orderId];
        uint256 tokenId = order.tokenId;
        require(isApproved(tokenId), "Token has not been approved");
        require(msg.value >= order.price, "You must pay greater or equal selling price");
        require(block.timestamp <= order.expireTime, "This token is not available");
        require(order.status == OrderStatus.SELLING, "Token has not been sold");

        tokenSellingStatuses[tokenId] = false;
        orders[orderId].status = OrderStatus.SOLD;
        orders[orderId].updatedTime = block.timestamp;
        orders[orderId].receiver = msg.sender;
        payable(msg.sender).transfer(msg.value);
        NFTAddress.safeTransferFrom(owner(), msg.sender, tokenId);

        emit BuyToken(msg.sender, msg.value, tokenId);
    }

    function cancelSellToken(uint256 orderId) override NFTContractMustSet public {
        Order memory order = orders[orderId];
        uint256 tokenId = order.tokenId;
        require(isApproved(tokenId), "Token has not been approved");
        require(order.seller == msg.sender, "You are not the seller");
        require(order.status == OrderStatus.SELLING, "Token has not been sold");

        order.status = OrderStatus.CANCEL;
        orders[orderId].updatedTime = block.timestamp;
        tokenSellingStatuses[tokenId] = false;
        NFTAddress.safeTransferFrom(owner(), msg.sender, tokenId);

        emit CancelToken(orderId);
    }
}