/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn, 
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function factory() external view returns(address);
}

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

interface IPair is IERC20 {
    function getReserves() external view returns (
        uint112 _reserve0, 
        uint112 _reserve1, 
        uint32 _blockTimestampLast
    );

    function nonces(address signer) external view returns(uint256);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function PERMIT_TYPEHASH() external view returns(bytes32);
}

enum RequestStatus {
    Completed,
    Canceled,
    Pending,
    Liquidated
}

enum RequestAction {
    Any,
    Approve,
    Transfer,
    TransferFrom,
    SwapExactTokensForTokens,
    SwapExactETHForTokens,
    RemoveLiquidity,
    RemoveLiquidityWithPermit
}

struct Condition {
    RequestAction action;
    address sender;
    address receiver;
    uint256 initialNonce;
    address from;
    address to;
    address assetA;
    address assetB;
    address router;
    uint256 assetAAmount;
    uint256 assetAAmountMin;
    uint256 assetBAmount;
    uint256 assetBAmountMin;
    uint256 liquidityAmount;
    bool approveMax;
}

enum ResponseAction {
    TransferFrom,
    SwapExactTokensForTokens,
    SwapExactTokensForEther,
    RemoveLiquidity,
    RemoveLiquidityWithPermit
}

struct Response {
    ResponseAction action;
    address from;
    address to;
    address assetA;
    address assetB;
    address router;
    uint256 liquidityAmount;
    uint256 assetAAmount;
    uint256 assetAAmountMin;
    uint256 assetBAmount;
    uint256 assetBAmountMin;
    uint256 deadline;
    bool approveMax;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct Request {
    uint256 id;
    address requester;
    address rewardAsset;
    uint256 rewardAmount;
    uint256 deadline;
    Condition condition;
    Response response;
    RequestStatus status;
}

struct Transaction {
    uint256 gasPrice;
    uint256 gasLimit;
    uint256 value;
    uint256 nonce;
    bytes data;
    address to;
    address from;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct Proposal {
    address proposer;
    uint256 requestId;
    Transaction transaction;
}

interface ITransactionSenderVerifier {
    function getTransactionSender(
        uint256 gasPrice, 
        uint256 gasLimit, 
        uint256 value, 
        uint256 nonce, 
        bytes memory data, 
        address to, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external view returns(address);
}

interface ITransactionSimulator {
    function simulateTransaction(address requester, Response memory transaction) external view returns(bool);
}

interface ITransactionDataDecoder {
    function decodeApprove(bytes calldata data) external pure returns(address to, uint256 amount);
    function decodeTransfer(bytes calldata data) external pure returns(address to, uint256 amount);
    function decodeTransferFrom(bytes calldata data) external pure returns(address from, address to, uint256 amount);
    function decodeSwapExactTokensForTokens(bytes calldata data) external pure returns(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    );
    function decodeSwapExactETHForTokens(bytes calldata data) external pure returns(
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    );
    function decodeRemoveLiqudity(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline
    );
    function decodeRemoveLiqudityWithPermit(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline,
        bool approveMax
    );
}

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

/// @title On-chain rugpull protector
/// @author P. Zibarov
/// @notice You can use this contract to create request for processing response action after
/// will be created proposal with matching c transaction data that was detected in mempool
/// @dev This contract is on development stage, functions can have side-effects
contract RugpullProtector is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _requestsCounter;
    Counters.Counter private _proposalsCounter;
    
    /// @notice address of on-chain transaction sender verifier 
    address private _verifier;

    /// @notice address of transaction data decoder
    address private _decoder;

    /// @notice address of transaction simulator
    address private _simulator;

    uint256 public requestDuration;

    /// @notice active requests array
    uint256[] private _activeRequestsIds;

    /// @notice mapping request id -> request index in active requests array
    mapping(uint256 => uint256) private _activeRequestIndex;

    /// @notice mapping request id -> request parameters
    mapping(uint256 => Request) public requests;

    /// @notice mapping proposal id -> proposal parameters
    mapping(uint256 => Proposal) public proposals;

    /// @notice addresses of allowed routers that performs response swap and removeLiquidity transactions
    mapping(address => bool) public allowedRouters;

    mapping(address => bool) public allowedTokens;

    uint256 public successFeePercent;
    uint256 public createRequestFeePercent;
    uint256 public increaseRequestDurationFeePercent;

    uint256 public hklsSuccessFeePercent;
    uint256 public hklsCreateRequestFeePercent;
    uint256 public hklsIncreaseRequestDurationFeePercent;

    uint256 public liquidationSystemFee;
    uint256 public liquidationProposerFee;

    address public hklsToken;

    address private _systemWallet;

    event CreateRequest(uint256 id, Request request);
    event CancelRequest(uint256 id);
    event ApproveProposal(uint256 id, Proposal proposal);
    event LiquidateRequest(uint256 id);
    event IncreaseRequestDuration(uint256 id, uint256 deadline);
    event PayReward(uint256 id, address rewardAsset, uint256 rewardAmount);
    event PerformTransferFromResponse(uint256 requestId, address asset, address from, address to, uint256 amount);
    event PerformSwapTokensResponse(uint256 requestId, address assetA, address assetB, uint256 amountASent, uint256 amountBReceived, address receiver);
    event PerformRemoveLiquidityResponse(uint256 requestId, address assetA, address assetB, uint256 amountA, uint256 amountB, address receiver);
    event PerformRemoveLiquidityResponseWithPermit(uint256 requestId, address assetA, address assetB, uint256 amountA, uint256 amountB, address receiver, bool approveMax);

    event UpdateVerifier(address verifier);
    event UpdateDecoder(address decoder);
    event UpdateRequestDuration(uint256 duration);
    event UpdateAllowedRouter(address router, bool allowed);
    event UpdateAllowedTokens(address token, bool allowed);

    error NotAllowed(address requester, address caller);
    error InvalidRequestTransactionReceiver();
    error WrongRequestId(uint256 requestId, uint256 currentRequestId);
    error RequestCancelledOrCompleted(uint256 requestId, RequestStatus status);
    error RequestLiquidated(uint256 requestId, uint256 deadline);
    error SenderNotVerified(address stored, address recovered);
    error TransactionNonceMissmatch(uint256 stored, uint256 actual);
    error TransactionSenderMissmatch(address stored, address actual);
    error TransactionReceiverMissmatch(address stored, address actual);
    error ConditionMissmatch(Condition condition, bytes transactionData);
    error UnsupportedRewardToken(address token);
    error UnsupportedRouter(address router);
    error EtherTransferFailed();
    error EtherFeeTransferFailed();
    error ZeroRewardAmount();
    error ZeroAddress();
    error NotAContract();
    error SimulationFailed();
    error ApproveRemovalFailed();
    error RequestNotExists(uint256 requestId);
    error RequestShouldBeLiquidated(uint256 requestId);
    error RequestAlreadyLiquidated(uint256 requestId);
    error RequestNotReadyForLiquidation(uint256 requestId);
    
    /// @notice Stores extenal contracts addresses into state
    constructor(address verifier, address decoder, address simulator, address[] memory routers, address wallet, address hkls, address[] memory tokens, uint256[] memory fees) {
        if(!Address.isContract(verifier)) revert NotAContract();
        if(!Address.isContract(decoder)) revert NotAContract();
        if(!Address.isContract(hkls)) revert NotAContract();

        _simulator = simulator;
        _verifier = verifier;
        _decoder = decoder;
        requestDuration = 26 weeks;

        hklsToken = hkls;

        if(wallet == address(0)) revert ZeroAddress();
        _systemWallet = wallet;

        createRequestFeePercent = fees[0];
        increaseRequestDurationFeePercent = fees[1];
        successFeePercent = fees[2];

        hklsSuccessFeePercent = fees[3];
        hklsCreateRequestFeePercent = fees[4];
        hklsIncreaseRequestDurationFeePercent = fees[5];
        
        liquidationSystemFee = fees[6];
        liquidationProposerFee = fees[7];

        for(uint256 i = 0; i < routers.length;) {
            if(!Address.isContract(routers[i])) revert NotAContract();
            allowedRouters[routers[i]] = true;
            unchecked{ i++; }
        }

        for(uint256 i = 0; i < tokens.length;) {
            if(!Address.isContract(tokens[i])) revert NotAContract();
            allowedTokens[tokens[i]] = true;
            unchecked{ i++; }
        }
    }

    /// @notice Returns request id that will be used for next created request
    /// @dev Used for retreiving request id after request creation, because it can't be returned from write function(but still emited in CreateRequest event)
    /// @return Next not used uint request id
    function currentRequest() external view returns (uint256) {
        return _requestsCounter.current();
    }

    /// @notice Returns proposal id that will be used for next created proposal
    /// @dev Used for retreiving proposal id after proposal creation, because it can't be returned from write function(but still emited in CreateProposal event)
    /// @return Next not used uint proposal id
    function currentProposal() external view returns (uint256) {
        return _proposalsCounter.current();
    }

    /// @notice Returns array of active request ids
    /// @return Array of active request ids
    function getActiveRequestsIds() external view returns (uint256[] memory) {
        return _activeRequestsIds;
    }

    /// @notice Returns array of active request ids
    /// @dev Page counter starts with 0
    /// @dev If active request count less than requested page size, function will returns array with all active requests on this page
    /// @param page - number of requested page
    /// @param size - size of the requested page
    /// @return result - array of active requests data
    function getActiveRequestsPage(uint256 page, uint256 size) external view returns (Request[] memory result) {
        uint256 activeRequestCount = _activeRequestsIds.length;
        uint256 offset = page * size;

        if(activeRequestCount > offset) {
            uint256 count = activeRequestCount - offset;

            result = count >= size ? new Request[](size) : new Request[](count);

            uint256 resultLength = result.length;
            
            for(uint256 i; i < resultLength;) {
                result[i] = requests[_activeRequestsIds[i + offset]]; 
                unchecked{ i++; }
            }
        }
    }

    /// @notice Stores request for monitoring transaction with defined conditions and response transaction details, transfers ETH/BNB reward from requester to contract
    /// @param condition - conditions that must match with proposed transactions
    /// @param response - action that must be performed if proposed transaction matched defined conditions
    /// @return requestId - id of the created request
    function createRequestForNative(Condition memory condition, Response memory response) external payable returns (uint256 requestId) {
        if(msg.value == 0) revert ZeroRewardAmount();

        uint256 inputAmount = msg.value;

        uint256 fee = inputAmount * createRequestFeePercent / 10 ** 20;
        uint256 rewardAmount = inputAmount - fee;

        (bool sentFee,) = _systemWallet.call{ value: fee }("");
        if(!sentFee) revert EtherFeeTransferFailed();

        requestId = _createRequest(address(0), rewardAmount, condition, response);
    }

    /// @notice Stores request for monitoring transaction with defined conditions and response transaction details, transfers ERC20 token reward from requester to contract
    /// @param rewardAsset - address of the revard asset smart contract
    /// @param rewardAmount - amount of reward asset that will be sent to matching transaction proposer
    /// @param condition - conditions that must match with proposed transactions
    /// @param response - action that must be performed if proposed transaction matched defined conditions
    /// @return requestId - id of the created request
    function createRequestForTokens(
        address rewardAsset, 
        uint256 rewardAmount, 
        Condition memory condition, 
        Response memory response
    ) external returns (uint256 requestId) {
        if(!allowedTokens[rewardAsset]) revert UnsupportedRewardToken(rewardAsset);
        if(rewardAmount == 0) revert ZeroRewardAmount();

        uint256 feePercent = rewardAsset == hklsToken ? hklsCreateRequestFeePercent : createRequestFeePercent;
        uint256 fee = rewardAmount * feePercent / 10 ** 20;

        IERC20(rewardAsset).transferFrom(msg.sender, address(this), rewardAmount);
        IERC20(rewardAsset).transferFrom(msg.sender, _systemWallet, fee);

        requestId = _createRequest(rewardAsset, rewardAmount, condition, response);
    }

    /// @notice Changes request status to Canceled and returns reward amount to requester
    /// @param requestId - request id that should be canceled
    function cancelRequest(uint256 requestId) external {
        Request memory request = requests[requestId];
        
        if(request.requester == address(0)) revert RequestNotExists({ requestId: requestId });
        if(msg.sender != request.requester) revert NotAllowed({ requester: request.requester, caller: msg.sender });
        if(request.status == RequestStatus.Canceled || request.status == RequestStatus.Completed) revert RequestCancelledOrCompleted({ requestId: requestId, status: request.status });

        if(request.rewardAsset == address(0)) {
            (bool sent,) = request.requester.call{ value: request.rewardAmount }("");
            if(!sent) revert EtherTransferFailed();
        } else {
            IERC20(request.rewardAsset).transfer(msg.sender, request.rewardAmount);

            (bool success,) = request.rewardAsset.delegatecall(
                abi.encodeWithSignature("approve(address,uint256)", address(this), 0)
            );

            if(!success) revert ApproveRemovalFailed();
        }

        requests[requestId].status = RequestStatus.Canceled;

        _removeFromActiveRequests(requestId);

        emit CancelRequest(requestId);
    }

    function liquidateRequest(uint256 requestId) external {
        Request memory request = requests[requestId];

        if(request.requester == address(0)) revert RequestNotExists({ requestId: requestId });
        if(request.status == RequestStatus.Canceled || request.status == RequestStatus.Completed) revert RequestCancelledOrCompleted({ requestId: requestId, status: request.status });
        if(block.timestamp < request.deadline) revert RequestNotReadyForLiquidation({ requestId: requestId });
        if(request.status == RequestStatus.Liquidated) revert RequestAlreadyLiquidated({ requestId: requestId });

        _liquidateRequest(request);
    }

    function increaseRequestDuration(uint256 requestId) external {
        Request memory request = requests[requestId];

        if(request.requester == address(0)) revert RequestNotExists({ requestId: requestId });
        if(request.requester != msg.sender) revert NotAllowed(request.requester, msg.sender);

        if(request.rewardAsset == address(0)) {
            uint256 rewardAmount = request.rewardAmount;
            uint256 fee = rewardAmount * increaseRequestDurationFeePercent / 10 ** 20;

            (bool sentFee,) = _systemWallet.call{ value: fee }("");
            if(!sentFee) revert EtherFeeTransferFailed();

            requests[requestId].rewardAmount = rewardAmount - fee;
        } else {
            uint256 feePercent = request.rewardAsset == hklsToken ? hklsIncreaseRequestDurationFeePercent : increaseRequestDurationFeePercent;
            uint256 fee = request.rewardAmount * feePercent / 10 ** 20;

            IERC20(request.rewardAsset).transferFrom(msg.sender, _systemWallet, fee);
        }

        uint256 newDeadline = request.deadline + requestDuration;
        requests[requestId].deadline = newDeadline;

        emit IncreaseRequestDuration(requestId, newDeadline);
    }

    /// @notice Validates proposed transaction for stored conditions matching. If matches - stores proposal data into state, 
    /// perform response transaction and transfer reward to transaction proposer
    /// @param requestId - request id that might match proposed transaction data
    /// @param transaction - transaction data that will used for sender, receiver, called method, parameters and other validation
    function createProposal(uint256 requestId, Transaction calldata transaction) external {
        Request memory request = requests[requestId];

        if(request.requester == address(0)) revert RequestNotExists({ requestId: requestId });
        if(request.status == RequestStatus.Completed || request.status == RequestStatus.Canceled) revert RequestCancelledOrCompleted({ requestId: requestId, status: request.status });
        if(request.status == RequestStatus.Liquidated) revert RequestLiquidated({ requestId: requestId, deadline: request.deadline });

        _validateProposal(request, transaction);
        _performResponse(request);
        _payReward(request);
        
        Proposal memory proposal = Proposal(msg.sender, requestId, transaction);
        uint256 proposalId = _proposalsCounter.current();
        proposals[proposalId] = proposal;
        _proposalsCounter.increment();

        requests[requestId].status = RequestStatus.Completed;

        _removeFromActiveRequests(requestId);
        
        emit ApproveProposal(proposalId, proposal);
    }

    /// @notice Stores request for monitoring transaction into state and increment reuqests counter
    /// @param rewardAsset - address of the revard asset smart contract
    /// @param rewardAmount - amount of reward asset that will be sent to matching transaction proposer
    /// @param condition - conditions that must match with proposed transactions
    /// @param response - action that must be performed if proposed transaction matched defined conditions
    /// @return requestId - id of the created request
    function _createRequest(
        address rewardAsset, 
        uint256 rewardAmount, 
        Condition memory condition, 
        Response memory response
    ) internal returns (uint256 requestId) {
        if(!Address.isContract(condition.receiver)) revert InvalidRequestTransactionReceiver();
        requestId = _requestsCounter.current();

        uint256 deadline = block.timestamp + requestDuration;

        Request memory request = Request(requestId, msg.sender, rewardAsset, rewardAmount, deadline, condition, response, RequestStatus.Pending);

        if((response.action == ResponseAction.SwapExactTokensForTokens ||
            response.action == ResponseAction.SwapExactTokensForEther ||
            response.action == ResponseAction.RemoveLiquidity ||
            response.action == ResponseAction.RemoveLiquidityWithPermit) && 
            !allowedRouters[response.router]
        ) revert UnsupportedRouter({ router: response.router });

        if(!ITransactionSimulator(_simulator).simulateTransaction(msg.sender, response)) revert SimulationFailed();

        requests[requestId] = request;
        _requestsCounter.increment();
        _addToActiveRequests(requestId);

        emit CreateRequest(requestId, request);
    }

    /// @notice Verifies proposed transaction sender, nonce and data
    /// @param request - request that conditions should match with proposed transaction
    /// @param transaction - proposed transactions
    function _validateProposal(Request memory request, Transaction calldata transaction) internal view {
        
        address sender = ITransactionSenderVerifier(_verifier).getTransactionSender(
            transaction.gasPrice, 
            transaction.gasLimit, 
            transaction.value, 
            transaction.nonce, 
            transaction.data, 
            transaction.to, 
            transaction.v, 
            transaction.r, 
            transaction.s
        );

        if(sender != transaction.from) revert SenderNotVerified({ stored: transaction.from, recovered: sender });
        if(sender != request.condition.sender) revert TransactionSenderMissmatch({ stored: request.condition.sender, actual: sender });
        if(transaction.to != request.condition.receiver) revert TransactionReceiverMissmatch({ stored: request.condition.sender, actual: sender });

        if(transaction.nonce < request.condition.initialNonce) 
            revert TransactionNonceMissmatch({ stored: request.condition.initialNonce, actual: transaction.nonce });

        if(!_validateProposedTransactionData(request.condition, transaction.data)) 
            revert ConditionMissmatch({ condition: request.condition, transactionData: transaction.data });
    }

    /// @notice Validates proposed transaction data based on conditions and function selector 
    /// @param condition - id of the request that conditions should match with proposed transaction
    /// @param data - transaction data includes function selector and call parameters

    function _validateProposedTransactionData(Condition memory condition, bytes calldata data) internal view returns(bool) {
        RequestAction action = condition.action;

        if(action == RequestAction.Any) {
            return true;
        }

        if(action == RequestAction.Approve) {
            (address to, uint256 amount) = ITransactionDataDecoder(_decoder).decodeApprove(data);

            if(amount >= condition.assetAAmount && to == condition.to) return true;
        }
        
        if(action == RequestAction.Transfer) {
            (address to, uint256 amount) = ITransactionDataDecoder(_decoder).decodeTransfer(data);

            if(amount >= condition.assetAAmount && to == condition.to) return true;
        }

        if(action == RequestAction.TransferFrom) {
            (address from, address to, uint256 amount) = ITransactionDataDecoder(_decoder).decodeTransferFrom(data);

            if(from == condition.from && amount >= condition.assetAAmount && to == condition.to) return true;
        }

        if(action == RequestAction.SwapExactTokensForTokens) {
            (uint256 amountIn, uint256 amountOutMin, address[] memory path, address to,) = ITransactionDataDecoder(_decoder).decodeSwapExactTokensForTokens(data);

            if(
                amountIn >= condition.assetAAmount &&
                amountOutMin >= condition.assetBAmountMin &&
                path[0] == condition.assetA &&
                path[1] == condition.assetB &&
                to == condition.to
            ) return true;
        }

        if(action == RequestAction.RemoveLiquidity) {
            (
                address tokenA, 
                address tokenB, 
                uint256 liquidity, 
                uint256 amountAMin, 
                uint256 amountBMin, 
                address to,
            ) = ITransactionDataDecoder(_decoder).decodeRemoveLiqudity(data);

            if(
                tokenA == condition.assetA && 
                tokenB == condition.assetB &&
                liquidity >= condition.liquidityAmount &&
                amountAMin >= condition.assetAAmountMin &&
                amountBMin >= condition.assetBAmountMin &&
                to == condition.to
            ) return true;
        }

        if(action == RequestAction.RemoveLiquidityWithPermit) {
            (
                address tokenA, 
                address tokenB, 
                uint256 liquidity, 
                uint256 amountAMin, 
                uint256 amountBMin, 
                address to,
                ,
                bool approveMax
            ) = ITransactionDataDecoder(_decoder).decodeRemoveLiqudityWithPermit(data);

            if(
                tokenA == condition.assetA && 
                tokenB == condition.assetB &&
                liquidity >= condition.liquidityAmount &&
                amountAMin >= condition.assetAAmountMin &&
                amountBMin >= condition.assetBAmountMin &&
                to == condition.to &&
                approveMax == condition.approveMax
            ) return true;
        }

        return false;
    }

    /// @notice Performs response transaction with parameters that stored in request
    /// @param request - request 
    function _performResponse(Request memory request) internal {
        Response memory response = request.response;

        if(response.action == ResponseAction.TransferFrom) {
            IERC20(response.assetA).transferFrom(response.from, response.to, response.assetAAmount);
            emit PerformTransferFromResponse(request.id, response.assetA, response.from, response.to, response.assetAAmount);
        }

        if (response.action == ResponseAction.SwapExactTokensForTokens) {
            IERC20(response.assetA).transferFrom(request.requester, address(this), response.assetAAmount);
            IERC20(response.assetA).approve(response.router, response.assetAAmount);

            address[] memory path;
            path = new address[](2);
            path[0] = response.assetA;
            path[1] = response.assetB;

            (uint256[] memory amounts) = IRouter(response.router).swapExactTokensForTokens(
                response.assetAAmount,
                response.assetBAmountMin,
                path,
                request.requester,
                response.deadline
            );

            emit PerformSwapTokensResponse(request.id, response.assetA, response.assetB, amounts[0], amounts[1], request.requester);
        }
        
        if (response.action == ResponseAction.RemoveLiquidity) {
            address factoryAddress = IRouter(response.router).factory();
            address pairAddress = IFactory(factoryAddress).getPair(response.assetA, response.assetB);

            IERC20(pairAddress).approve(response.router, response.assetAAmount);
            IERC20(pairAddress).transferFrom(request.requester, address(this), response.liquidityAmount);

            (uint256 amountA, uint256 amountB) = IRouter(response.router).removeLiquidity(
                response.assetA,
                response.assetB,
                response.liquidityAmount,
                response.assetAAmountMin,
                response.assetBAmountMin,
                request.requester,
                response.deadline
            );

            emit PerformRemoveLiquidityResponse(request.id, response.assetA, response.assetB, amountA, amountB, request.requester);
        }

        if (response.action == ResponseAction.RemoveLiquidityWithPermit) {
            (uint256 amountA, uint256 amountB) = IRouter(response.router).removeLiquidityWithPermit(
                response.assetA,
                response.assetB,
                response.liquidityAmount,
                response.assetAAmountMin,
                response.assetBAmountMin,
                request.requester,
                response.deadline,
                response.approveMax,
                response.v,
                response.r,
                response.s
            );

            emit PerformRemoveLiquidityResponseWithPermit(request.id, response.assetA, response.assetB, amountA, amountB, request.requester, response.approveMax);
        }
    }

    function _liquidateRequest(Request memory request) internal {

        requests[request.id].status = RequestStatus.Liquidated;

        uint256 proposerFeeAmount = request.rewardAmount * liquidationProposerFee / 10 ** 20;
        uint256 systemFeeAmount = request.rewardAmount * liquidationSystemFee / 10 ** 20;
        uint256 leftRewardAmount = request.rewardAmount - systemFeeAmount - proposerFeeAmount;
        
        if(request.rewardAsset == address(0)) {
            (bool sentToProposer,) = msg.sender.call{ value: proposerFeeAmount }("");
            if(!sentToProposer) revert EtherTransferFailed();
            (bool sentToSystem,) = _systemWallet.call{ value: systemFeeAmount }("");
            if(!sentToSystem) revert EtherTransferFailed();
            (bool sentToRequester,) = request.requester.call{ value: leftRewardAmount }("");
            if(!sentToRequester) revert EtherTransferFailed();
        } else {
            IERC20(request.rewardAsset).transfer(msg.sender, proposerFeeAmount);
            IERC20(request.rewardAsset).transfer(msg.sender, systemFeeAmount);
            IERC20(request.rewardAsset).transfer(request.requester, leftRewardAmount);
        }

        _removeFromActiveRequests(request.id);

        emit LiquidateRequest(request.id);
    }

    /// @notice Transfers reward amount to the matching transaction proposer
    /// @param request- request
    function _payReward(Request memory request) internal {
        if(request.rewardAsset == address(0)) {
            (bool sent,) = msg.sender.call{ value: request.rewardAmount }("");
            if(!sent) revert EtherTransferFailed();
        } else {
            IERC20(request.rewardAsset).transfer(msg.sender, request.rewardAmount);
        }

        emit PayReward(request.id, request.rewardAsset, request.rewardAmount);
    }

    /// @notice Adds request id to active requests array
    /// @param requestId - active request identifier
    function _addToActiveRequests(uint256 requestId) internal {
        _activeRequestIndex[requestId] = _activeRequestsIds.length;
        _activeRequestsIds.push(requestId);
    }

    /// @notice Removes request id from active requests array
    /// @param requestId - cancelled or completed request identifier
    function _removeFromActiveRequests(uint256 requestId) internal {
        uint256 lastRequestIndex = _activeRequestsIds.length - 1;
        uint256 requestIndex = _activeRequestIndex[requestId];
        uint256 lastRequestId = _activeRequestsIds[lastRequestIndex];
        _activeRequestsIds[requestIndex] = lastRequestId;
        _activeRequestIndex[lastRequestId] = requestIndex;
        delete _activeRequestIndex[requestId];
        _activeRequestsIds.pop();
    }
}