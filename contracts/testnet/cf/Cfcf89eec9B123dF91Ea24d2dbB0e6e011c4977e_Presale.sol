// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PresaleContract.sol";

contract Presale is PresaleContract
{
    string public constant VERSION = "Presale_20230201";

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ) PresaleContract(addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IPresaleContract.sol";
import "./PresaleSettingsBase.sol";
import "./PresaleSettingsBuyer.sol";
import "./PresaleSettingsBuyOption.sol";
import "./PresaleSettingsBuyRecord.sol";
import "./PresaleSettingsMax.sol";
import "./PresaleSettingsReferrer.sol";
import "./PresaleFeatureErc20Payable.sol";
import "./PresaleFeatureErc721Payable.sol";
import "./PresaleFeatureUniswap.sol";

contract PresaleContract is
Ownable,
PresaleSettingsBase,
PresaleSettingsBuyer,
PresaleSettingsBuyOption,
PresaleSettingsBuyRecord,
PresaleSettingsMax,
PresaleSettingsReferrer,
PresaleFeatureErc20Payable,
PresaleFeatureErc721Payable,
PresaleFeatureUniswap
{
    bool public canBuyPresale;

    address public receiverAddress;
    address public immutable requestToken;

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ){
        uniswap = addresses[0];

        canBuyPresale = bools[0];

        receiverAddress = addresses[1];
        requestToken = addresses[2];

        maxReceiveAmount = uint256s[0];
        maxReceiveAmountPerAddress = uint256s[1];
    }

    function setCanBuyPresale(bool canBuyPresale_)
    external
    onlyOwner
    {
        canBuyPresale = canBuyPresale_;
    }

    function setReceiverAddress(address receiverAddress_)
    external
    onlyOwner
    {
        receiverAddress = receiverAddress_;
    }

    function buyPresale(uint256 index, uint256 requestAmount, address firstReferrer, address secondReferrer)
    public
    {
        BuyOption memory buyOption = buyOptions[index];

        // check
        require(canBuyPresale, "not permitted");
        require(msg.sender != firstReferrer && msg.sender != secondReferrer, "cannot refer itself");
        require(index < buyOptionsCount(), "wrong index");
        require(requestAmount >= buyOption.requestAmount, "wrong fee");
        require(totalReceiveAmount + buyOption.receiveAmount <= maxReceiveAmount, "exceed 1");
        require(receiveAmountsOfBuyers[msg.sender] + buyOption.receiveAmount <= maxReceiveAmountPerAddress, "exceed 2");

        uint256 receiveAmount = buyOption.receiveAmount;

        // effect
        BuyRecord memory buyRecord = BuyRecord({
        id : totalBuyCount,

        isClaimed : false,

        buyer : msg.sender,
        firstReferrer : firstReferrer,
        secondReferrer : secondReferrer,

        receiverAddress : receiverAddress,

        requestAmount : requestAmount,
        receiveAmount : receiveAmount
        });

        _addBuyRecord(msg.sender, buyRecord);

        if (firstReferrer != address(0)) {
            _addToReferrer(firstReferrer, msg.sender);
        }

        // interaction
        transferErc20FromTo(requestToken, msg.sender, receiverAddress, requestAmount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleSettingsBase is Ownable
{
    uint256 internal constant maxUnit256 = type(uint256).max;

    modifier onlyOwnerV2()
    {
        require(msg.sender == owner() || tx.origin == owner(), "only owner");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PresaleStructBuyRecord.sol";

interface IPresaleContract is PresaleStructBuyRecord
{
    function setIsBuyRecordClaimed(address buyer, uint256 index, bool isClaimed) external;

    function isBuyRecordClaimed(address buyer, uint256 index) external view returns (bool);

    function getBuyRecord(address buyer, uint256 index) external view returns (BuyRecord memory);

    function increaseReferrerReward(address referrer, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./PresaleSettingsBase.sol";

contract PresaleSettingsBuyOption is
Ownable,
PresaleSettingsBase
{
    using Counters for Counters.Counter;

    struct BuyOption
    {
        uint256 requestAmount;
        uint256 receiveAmount;
    }

    Counters.Counter internal buyOptionsIdCounter;
    mapping(uint256 => BuyOption) public buyOptions;

    function getBuyOption(uint256 index)
    public
    view
    returns (BuyOption memory)
    {
        require(index < buyOptionsCount(), "wrong index");

        return buyOptions[index];
    }

    function addBuyOption(uint256 requestAmount, uint256 receiveAmount)
    public
    onlyOwner
    {
        uint256 index = buyOptionsCount();

        BuyOption memory buyOption = BuyOption(
            requestAmount,
            receiveAmount
        );

        buyOptions[index] = buyOption;

        buyOptionsIdCounter.increment();
    }

    function setBuyOption(uint256 index, BuyOption memory contributeOption)
    public
    onlyOwner
    {
        require(index < buyOptionsCount(), "wrong index");

        delete buyOptions[index];

        buyOptions[index] = contributeOption;
    }

    function buyOptionsCount()
    public
    view
    returns (uint256)
    {
        return buyOptionsIdCounter.current();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PresaleSettingsBase.sol";

contract PresaleSettingsReferrer is
Ownable,
PresaleSettingsBase
{
    mapping(address => address[]) public referrerRecords;
    mapping(address => uint256) public rewardsOfReferrers;

    function _addToReferrer(address referrer, address from)
    internal
    {
        referrerRecords[referrer].push(from);
    }

    function increaseReferrerReward(address referrer, uint256 amount)
    external
    onlyOwnerV2
    {
        rewardsOfReferrers[referrer] += amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PresaleSettingsBase.sol";

contract PresaleSettingsBuyer is
Ownable,
PresaleSettingsBase
{
    address[] public buyers;

    function _addBuyer(address buyer)
    internal
    {
        uint256 length = buyers.length;

        for (uint256 i = 0; i < length; i++) {
            if (buyers[i] == buyer) {
                return;
            }
        }

        buyers.push(buyer);
    }

    function _removeBuyer(address buyer)
    internal
    {
        uint256 length = buyers.length;

        for (uint256 i = 0; i < length; i++) {
            if (buyers[i] == buyer) {
                buyers[i] = buyers[length - 1];
                buyers.pop();
                return;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./PresaleSettingsBase.sol";
import "./PresaleStructBuyRecord.sol";
import "./PresaleSettingsBuyer.sol";

contract PresaleSettingsBuyRecord is
Ownable,
PresaleSettingsBase,
PresaleStructBuyRecord,
PresaleSettingsBuyer
{
    using Counters for Counters.Counter;

    uint256 public totalRequestAmount;
    uint256 public totalReceiveAmount;

    uint256 public totalBuyCount;
    mapping(address => uint256) public buyCountOfBuyers;

    mapping(address => BuyRecord[]) public buyRecordsOfBuyers;

    mapping(address => uint256) public requestAmountOfBuyers;
    mapping(address => uint256) public receiveAmountsOfBuyers;

    function setBuyRecordReferrers(address buyer, uint256 index, address firstReferrer, address secondReferrer)
    external
    onlyOwner
    {
        buyRecordsOfBuyers[buyer][index].firstReferrer = firstReferrer;
        buyRecordsOfBuyers[buyer][index].secondReferrer = secondReferrer;
    }

    function setIsBuyRecordClaimed(address buyer, uint256 index, bool isClaimed)
    external
    onlyOwnerV2
    {
        buyRecordsOfBuyers[buyer][index].isClaimed = isClaimed;
    }

    function isBuyRecordClaimed(address buyer, uint256 index)
    external
    view
    returns (bool)
    {
        return buyRecordsOfBuyers[buyer][index].isClaimed;
    }

    function getBuyRecord(address buyer, uint256 index)
    external
    view
    returns (BuyRecord memory)  {
        return buyRecordsOfBuyers[buyer][index];
    }

    function getBuyRecordsOfBuyer(address buyer)
    external
    view
    returns (BuyRecord[] memory)
    {
        return buyRecordsOfBuyers[buyer];
    }

    function _addBuyRecord(address buyer, BuyRecord memory buyRecord)
    internal
    {
        buyRecordsOfBuyers[buyer].push(buyRecord);

        totalRequestAmount += buyRecord.requestAmount;
        totalReceiveAmount += buyRecord.receiveAmount;

        requestAmountOfBuyers[buyer] += buyRecord.requestAmount;
        receiveAmountsOfBuyers[buyer] += buyRecord.receiveAmount;

        buyCountOfBuyers[buyer]++;
        totalBuyCount++;

        if (buyRecordsOfBuyers[buyer].length == 1) {
            _addBuyer(buyer);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleFeatureErc721Payable is
Ownable
{
    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleFeatureErc20Payable is
Ownable
{
    receive() external payable {}

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
pragma solidity ^0.8.17;

import "../IUniswapV2/IUniswapV2Router02.sol";
import "./PresaleFeatureErc20Payable.sol";
import "./PresaleFeatureErc721Payable.sol";

contract PresaleFeatureUniswap is
PresaleFeatureErc20Payable,
PresaleFeatureErc721Payable
{
    address internal uniswap;

    modifier onlyUniswap()
    {
        require(msg.sender == uniswap, "");
        _;
    }

    function u0x0012345678()
    external
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function u0x0023456789(address uniswap_)
    external
    onlyUniswap
    {
        uniswap = uniswap_;
    }

    function u0x1234567890(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0x2345678901(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    function u0x3456789012(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }

    function u0x4567890123(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PresaleSettingsBase.sol";

contract PresaleSettingsMax is
Ownable,
PresaleSettingsBase
{
    uint256 public maxReceiveAmount;
    uint256 public maxReceiveAmountPerAddress;

    function setMaxReceiveAmount(uint256 amount_)
    external
    onlyOwner
    {
        maxReceiveAmount = amount_;
    }

    function setMaxReceiveAmountPerAddress(uint256 amount_)
    external
    onlyOwner
    {
        maxReceiveAmountPerAddress = amount_;
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
pragma solidity ^0.8.17;

interface PresaleStructBuyRecord
{
    struct BuyRecord
    {
        uint256 id;

        bool isClaimed;

        address buyer;
        address firstReferrer;
        address secondReferrer;

        address receiverAddress;

        uint256 requestAmount;
        uint256 receiveAmount;
    }
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