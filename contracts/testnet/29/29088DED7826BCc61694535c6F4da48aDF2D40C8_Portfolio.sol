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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EquaProtocol
 * @author kotsmile
 */

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './utils/MathLib.sol';
import './utils/ZkLib.sol';

interface RequesterStandart {
    function solve(uint256 requestId, bytes memory answer) external;
}

interface RequesterZkProof {
    function solveZkProof(
        uint256 requestId,
        bytes memory answer,
        ZkLib.Proof memory proof
    ) external;
}

contract EquaProtocol is Ownable {
    using SafeERC20 for IERC20;

    enum RequestStatus {
        NONE,
        PENDING,
        SOLVED,
        CANCELED
    }

    struct ProblemDefinition {
        string problem;
        bool zkProofRequired;
        string inputFormat;
        string outputFormat;
    }

    // never change
    struct Problem {
        bytes32 problemId;
        ProblemDefinition definition;
        uint256 timestamp;
        address author;
    }

    struct Request {
        uint256 requestId;
        bytes32 problemId;
        uint256 solutionId;
        bool cache;
        uint256 reward;
        bytes input;
        bytes32 inputHashed;
        RequestStatus status;
        uint256 timestamp;
        address sender;
    }

    struct Solution {
        bool solved;
        uint256 solutionId;
        bytes32 problemId;
        uint256 requestId;
        bytes input;
        bytes answer;
        ZkLib.Proof proof;
    }

    uint256 public protocolFeeX10000 = 1_50;
    address public feeHolder;

    IERC20 public immutable EQUA;

    bytes32[] public problemIds;
    mapping(bytes32 => Problem) public problems;
    mapping(address => bytes32[]) public userProblems;

    Request[] public requests;
    mapping(address => uint256[]) public userRequests;
    mapping(bytes32 => uint256[]) public problemRequests;

    uint256 public currentSolutionId = 1;

    event ProblemCreation(bytes32 indexed problemId, uint256 indexed sender);

    uint256 constant ZERO = 0;
    ZkLib.Proof ZERO_PROOF =
        ZkLib.Proof({
            a: ZkLib.G1Point(0, 0),
            b: ZkLib.G2Point([ZERO, ZERO], [ZERO, ZERO]),
            c: ZkLib.G1Point(0, 0)
        });

    /// @dev sender => problemId => inputHashed => Solution
    mapping(address => mapping(bytes32 => mapping(bytes32 => Solution))) public solutions;

    modifier onlyPending(uint256 requestId) {
        require(requests[requestId].status == RequestStatus.PENDING, '');
        _;
    }

    modifier onlySender(uint256 requestId) {
        require(requests[requestId].sender == msg.sender, '');
        _;
    }

    constructor(IERC20 token_, address feeHolder_) {
        EQUA = token_;
        feeHolder = feeHolder_;
    }

    function defineProblem(ProblemDefinition memory definition)
        external
        returns (bytes32 problemId)
    {
        problemId = keccak256(
            abi.encode(
                definition.inputFormat,
                definition.outputFormat,
                definition.problem
            )
        );

        if (problems[problemId].problemId == problemId) return problemId;

        Problem memory problem_ = Problem({
            problemId: problemId,
            definition: definition,
            timestamp: block.timestamp,
            author: msg.sender
        });

        problemIds.push(problemId);

        problems[problemId] = problem_;
        userProblems[msg.sender].push(problemId);
        emit ProblemCreation(problemId, block.timestamp);
    }

    function request(
        bytes32 problemId,
        bytes memory input,
        uint256 reward,
        bool cache
    ) external returns (uint256 requestId) {
        address sender = msg.sender;

        EQUA.safeTransferFrom(sender, address(this), reward);

        requestId = requests.length;

        Request memory request_ = Request({
            sender: sender,
            requestId: requestId,
            problemId: problemId,
            solutionId: 0,
            cache: cache,
            input: input,
            inputHashed: MathLib.hashBytes(input),
            reward: reward,
            timestamp: block.timestamp,
            status: RequestStatus.PENDING
        });

        requests.push(request_);
        userRequests[msg.sender].push(requestId);
        problemRequests[problemId].push(requestId);

        _checkCachedSolution(requestId);
    }

    function cancel(uint256 requestId)
        public
        onlyPending(requestId)
        onlySender(requestId)
    {
        Request storage request_ = requests[requestId];

        require(msg.sender == request_.sender);

        request_.status = RequestStatus.CANCELED;
        EQUA.transfer(msg.sender, request_.reward);
    }

    function solve(uint256 requestId, bytes memory answer) public onlyPending(requestId) {
        require(
            !problems[requests[requestId].problemId].definition.zkProofRequired,
            'Problem does not require Zk-proof'
        );

        _solve(requestId, msg.sender);
        _cacheSolution(requestId, answer, ZERO_PROOF);

        RequesterStandart(requests[requestId].sender).solve(requestId, answer);
    }

    function solveZK(
        uint256 requestId,
        bytes memory answer,
        ZkLib.Proof memory proof
    ) public onlyPending(requestId) {
        require(
            problems[requests[requestId].problemId].definition.zkProofRequired,
            'Problem require Zk-proof'
        );

        _solve(requestId, msg.sender);
        _cacheSolution(requestId, answer, proof);

        RequesterZkProof(requests[requestId].sender).solveZkProof(
            requestId,
            answer,
            proof
        );
    }

    // cache system
    function _checkCachedSolution(uint256 requestId) internal {
        if (requests[requestId].cache) {
            Request memory request_ = requests[requestId];

            Solution memory solution = solutions[request_.sender][request_.problemId][
                request_.inputHashed
            ];

            if (solution.solved) {
                requests[requestId].status = RequestStatus.SOLVED;
                if (problems[request_.problemId].definition.zkProofRequired) {
                    try
                        RequesterZkProof(requests[requestId].sender).solveZkProof(
                            requestId,
                            solution.answer,
                            solution.proof
                        )
                    {
                        _solve(requestId, feeHolder);
                    } catch {
                        requests[requestId].status = RequestStatus.PENDING;
                    }
                } else {
                    try
                        RequesterStandart(requests[requestId].sender).solve(
                            requestId,
                            solution.answer
                        )
                    {
                        _solve(requestId, feeHolder);
                    } catch {
                        requests[requestId].status = RequestStatus.PENDING;
                    }
                }
            }
        }
    }

    function _cacheSolution(
        uint256 requestId,
        bytes memory answer,
        ZkLib.Proof memory proof
    ) internal {
        Request storage request_ = requests[requestId];
        Solution memory solution = Solution({
            solved: true,
            solutionId: currentSolutionId++,
            requestId: requestId,
            problemId: request_.problemId,
            input: request_.input,
            answer: answer,
            proof: proof
        });
        request_.solutionId = solution.solutionId;
        if (requests[requestId].cache) {
            solutions[request_.sender][request_.problemId][
                request_.inputHashed
            ] = Solution({
                solved: true,
                solutionId: currentSolutionId++,
                requestId: requestId,
                problemId: request_.problemId,
                input: request_.input,
                answer: answer,
                proof: proof
            });
        }
    }

    function _solve(uint256 requestId, address solver) internal {
        Request storage request_ = requests[requestId];
        request_.status = RequestStatus.SOLVED;

        uint256 fee = (request_.reward * protocolFeeX10000) / 10000;
        EQUA.transfer(solver, request_.reward - fee);
        EQUA.transfer(feeHolder, fee);
    }

    /// @dev returns list of problems
    /// @param offset start of indexing
    /// @param limit max amount of elements in response
    ///
    /// @return problems_ array of problems
    function getProblems(uint256 offset, uint256 limit)
        external
        view
        returns (Problem[] memory problems_)
    {
        require(offset < problemIds.length, 'Offset > poblemsIds.length');

        problems_ = new Problem[](limit);
        uint256 length = MathLib.min(limit + offset, problemIds.length);

        for (uint256 i = offset; i < length; i++)
            problems_[i - offset] = problems[problemIds[i]];
    }

    function getRequestsOfProblem(
        bytes32 problemId,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory) {
        require(offset < problemRequests[problemId].length, 'Offset > poblemsIds.length');

        uint256[] memory requestIds = new uint256[](limit);
        uint256 length = MathLib.min(limit + offset, problemRequests[problemId].length);
        for (uint256 i = offset; i < length; ++i) {
            requestIds[i - offset] = problemRequests[problemId][i];
        }
        return requestIds;
    }

    function getProblemsUser(address user) external view returns (Problem[] memory) {
        uint256 length = userProblems[user].length;
        Problem[] memory problems_ = new Problem[](userProblems[user].length);
        for (uint256 i; i < length; ++i) problems_[i] = problems[userProblems[user][i]];
        return problems_;
    }

    function getRequestsUser(address user) external view returns (Request[] memory) {
        uint256 length = userRequests[user].length;
        Request[] memory requests_ = new Request[](userRequests[user].length);
        for (uint256 i; i < length; ++i) requests_[i] = requests[userRequests[user][i]];
        return requests_;
    }

    function udpateFee(address newFeeHolder, uint256 newProtocolFeeX10000)
        external
        onlyOwner
    {
        require(newProtocolFeeX10000 < 5_00);
        feeHolder = newFeeHolder;
        protocolFeeX10000 = newProtocolFeeX10000;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Portfolio
 * @author kotsmile
 */

import '../EquaProtocol.sol';
import '../zk/BetaVerifier.sol';

contract Portfolio {
    EquaProtocol public immutable equaProtocol;
    IERC20 public immutable EQUA;
    bytes32 public immutable problemId;

    uint256[31] public index = [
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_33,
        3_01,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_03,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00
    ];
    uint256[31] public assetCorr = [
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_33,
        3_01,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_03,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00
    ];
    uint256[31] public assetNot = [
        3_00,
        1_23,
        5_05,
        6_05,
        4_28,
        5_38,
        6_06,
        4_28,
        5_10,
        6_05,
        4_28,
        13_05,
        7_10,
        5_28,
        6_05,
        7_05,
        5_28,
        3_05,
        8_05,
        6_28,
        10_05,
        8_05,
        6_28,
        7_05,
        7_05,
        7_05,
        5_28,
        6_00,
        7_00,
        5_23,
        6_00
    ];

    uint256 public ans;
    bytes public input;

    constructor(EquaProtocol equaProtocol_) {
        equaProtocol = equaProtocol_;
        EQUA = equaProtocol.EQUA();
        problemId = 0x97f8d16b26a5664fd22a510645e83985a1fdc0fb2bfa4e94d02e0a0d0ad02f17;
    }

    function solveZkProof(
        uint256,
        bytes memory answer_,
        BetaVerifier.Proof memory proof
    ) external {
        uint256 ans_ = abi.decode(answer_, (uint256));

        uint256[62] memory input_ = abi.decode(input, (uint256[62]));
        bytes memory temp = abi.encode(input_, ans_);
        uint256[63] memory input__ = abi.decode(temp, (uint256[63]));

        require(BetaVerifier.verifyTx(proof, input__), 'Zk proof wrong');
        ans = ans_;
    }

    function askCorr() external {
        input = abi.encode(assetCorr, index);
        EQUA.approve(address(equaProtocol), 2 ether);
        equaProtocol.request(problemId, input, 2 ether, false);
    }

    function askNot() external {
        input = abi.encode(assetNot, index);
        EQUA.approve(address(equaProtocol), 2 ether);
        equaProtocol.request(problemId, input, 2 ether, false);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MathLib
 * @author kotsmile
 */

library MathLib {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    function hashBytes(bytes memory b) internal pure returns (bytes32) {
        return keccak256(abi.encode(b));
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ZkLib
 * @author kotsmile
 */

library ZkLib {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }
    struct VerifyingKey {
        G1Point alpha;
        G2Point beta;
        G2Point gamma;
        G2Point delta;
        G1Point[] gamma_abc;
    }
    struct Proof {
        G1Point a;
        G2Point b;
        G1Point c;
    }
}

// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

library BetaVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x16741665b4be4c6332f1df500c04bd23949154941f8782454e0e5da0b151b4a3), uint256(0x2166ded1cc09eaa74fe2fb4016e783c3e017d5b1d492ef5c65a8e26c56d654a6));
        vk.beta = Pairing.G2Point([uint256(0x25f9ee3a83878de15f3ecd0b87bc484d766bad551439be1d2e42bcfbccaa3e6c), uint256(0x0cc1f39f28db312d3c2f4ee0f8f85a7aace5feaaf6b22d05719fefa55ae723bf)], [uint256(0x2f7f90bf3bd5d6be7e349f0fdeec1a68abe468277da80d8be70aa70d1861a808), uint256(0x14e77e3e5fd98d2d843b4cd37b549fe7fdb5a647197b4ad459cd799de0d2a336)]);
        vk.gamma = Pairing.G2Point([uint256(0x28a59174467d5db3e54d0fd19da2df72ce99ca1494eac7eb47ad043fb58a9ef7), uint256(0x30395bf85d1fbc02b95c6f096cb2f2e0a41e8efbee2e0a8a5623203a20d4ca7e)], [uint256(0x0e3d9599e255650337bf9457805dcd0e3da2f29dfef1e614eaf155225f4bba3d), uint256(0x038c09e050bfe7c200dcc964fdb7bb765557bd16cccdd39016f0c2986fb30c0f)]);
        vk.delta = Pairing.G2Point([uint256(0x19d43887ee45c673c099894ccc8a5bc3d2acba0e8758e762a317bb4271c306c3), uint256(0x3051b7900a32757fe8a43103ae2a99c0fec96fdca4285a3cd87bf7c177cbb6de)], [uint256(0x0a3dcaea758bd9aa37848325ceaafeafba1edda282b086b386068dcefa6368f5), uint256(0x2108dc6690be9eb7c60d8ad1109950b6525bb66dc094303eba700b83c76161fa)]);
        vk.gamma_abc = new Pairing.G1Point[](64);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1552e27381ddb93ca5e0065a2d432381e544d84d352ae1fcf7406b119a3317f8), uint256(0x25ef5d501639e3908ee5aac69c5abd5b2f00b6aae31a620359fec2fce2be52bd));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x260a879f5925da54b3b8c134ec26d00c9dc5fd7803e42d367891da6b48fb3acf), uint256(0x26821608c934591187bab9c1e30c3d2465ac957e6bcaf333b16091fb9f58c9fe));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0a0b957e35553e137b50c3782502e71935647bd78e777e3b839378897765591f), uint256(0x0da727e90fde90dec5831bb1a7df036bb6e64c10829f6f8023c768163eda4d47));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1929832e92e53c432d9bb39f13134f30bedd98e8a0224cca79abf15d7bb78e4b), uint256(0x2ce5f4305c0f6c3c8f5d5bb7459140cae697d47915fb436998a0d5bf2b832fbd));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2e2bab4e58b64cca0872a85b43028381749322b01f06e77a0632b4373fd448e4), uint256(0x15389b684129cd29732f76bb05afd20fcb4af5b15da9dcb4173f819ca3fca420));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0ed5736d976a54cebc8d331adad8ced7b29062ad3655f7519ddd320cc5713210), uint256(0x1bf2fd993258404f3e04e275e96775d4f8d7fca274a294f7c49345a4862cb819));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x29727fb69b2ed8e654ee3ddfb0346f6a0cdbd861128366867c6ced025abf9c5d), uint256(0x09a62a851c959c1183451998bed4427a3892e5bb7152ba87081ffb89f937c5f8));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2647fc0ff36809f68665264e468cad7699a837f7cf4dd9752e344cb02e209c8b), uint256(0x133ef635edfdb56547792b0e199f8fa0e3175257e9848526b0c2ce564a116466));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x002702703eda82ec7e7291bc4d0994e33e55e0ab56b9070d91d59855d386b4f3), uint256(0x283d17fa607dd665104141e60e8b94db6344765c929ba407a1c3768c18f0846b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x14e6a753cd22e71d9b78d08f649d19f1b18a8872b420d5098b87198e1f13ea6f), uint256(0x092e006c20c095fbfa71485ca8f46a884e7ca8cdc6ccdaa36fdc02dd7a322553));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x111e044dbe365b2e5aff29d4190c21d2c239846f2bc8987f5ab53a653dd82a5c), uint256(0x28d9467700d327ed6704ac0e9cb1f0d4ce1205ebb0f25049ad614a2f8927d492));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2df4d7ac16fab74f5f102c891a6c246c0fccce3302a5bcd916b42bf8d4a5b4d0), uint256(0x0170feb14af1533b368a13846b77cd4916e6ef9ec50500369737d025209a8888));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x254fb1808d2185a78fbf1de875c8b6d86d1fbe7b60a315016fc26354c36c387f), uint256(0x10e56968a59820afa6c14a2b812fc81de2d4e04cc7225fe8559686d9b74524a5));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x224e5a86e6a1561d53ac08446c7a7f009a2e071d7076595afe68f1b15ccd2843), uint256(0x169aac9a69b2eafeada08f4b91837e3ffd2f79c91dca5ce6dfd3b7827e248381));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1190a29a1183643f896f1ae9554518f44993c4c608d9a782be012de18b67b4ed), uint256(0x1f1cf4d4574415cde749002ced108f1fa0394fff223d974706d4f98ee0f91681));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x29ecbc621cea19e1a55e180daf5923c69b34a28f5cca7ed85e9e5efd2925866f), uint256(0x238a37a9acf16d13c96c6a4f643ddf3db1c5c67080157998da2e8c4c5f23120e));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x077776e4fbc9ee18eca9c7b813d4d1f482a5ac60ecbb7eca48727a57e47493f3), uint256(0x1152b5c83351e6e634691229074b670a5ddda28c03a4e3eacf9a2a717a6d814a));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x04fafed63205790a3258f138667223fa3b2eea8da1479b1e3fd214d083b017e2), uint256(0x068653c7daacf0c63ea1ec7f8c6b227f5aa46bf077342d4a4451c49c9aaa5c32));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x141b4310afb3dc1e6b27ea52d7e46829fdfd20d4a19bafb7efe307953a0afeb0), uint256(0x00aef4d3f039c6f9deb22ac4a6d5a73dd8921cbaee1c0db13a423d60bb0ddd01));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1a0668b504f73ad5dc606a817ad9d38d7949b222d83b0772482c4a87157a6eeb), uint256(0x26c41cb27ad073845700d560ef5bf451259307d05df20dd76fce2f71e43cbbf7));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0be69636848b97aeaeb6eef315a364c73d821c6bc2b080018a2ad8279e176e56), uint256(0x0fee992227ca1da8a68f0adc9fb4b7375ad35a07d999934652be332811c7a152));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x158978c204c45b46c19e41f62b600f1ec643a70e6d101e8142688b321c185025), uint256(0x0f8f44a8981f6f0ed0d53c440451fb43d1e5e4d95986ab3d6865f16926df6c4d));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2f3484a886f1632c410dda529556507d35d6e6cb2bcc0947a35064981baf67ea), uint256(0x2df331c8d81ff1224a580d5476741d7fd767763706faeccd7914bf891aaba95e));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x25c298725a3f6ef02ab2beb7d0094172d50d841251647849dd5cef3e940694a3), uint256(0x21f0a7596255cd5ee1afecfa0c96dee3ce3327f4f5d73ef5aa4bb04688fdc861));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x2079ac3433107214c2ea10eef2332427bf45539067ba2c03634d806bf5d72a22), uint256(0x259dbb8c5644f0b01e52deb342dcdf77f52ef99208d12198d20fd646d4085051));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1a34c41da07a468b503edabbb3289ee5e8d0dc83f1ab4aa50e8a4d0135d9de5f), uint256(0x07c5d49e23b9008e1aabd2f1bae767956519dcb18aebf14b9a1b9bb97f01d5eb));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x1bb4bdb3ee25ce15b19271a119b6780dae913ff577b73122bc941da56abb610a), uint256(0x06b1fd41baf32cd47d393ad4133b8ebb2f048112e84000e475ac29eb82b3a157));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x20480ca8f604e482146d1be79b2d5cbf37addec1ea988bd36b33233535527999), uint256(0x2522d4ceb2901c250f10b4889ad0d6e28807cc0a30be5bba5e146aad4541a60a));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x18025c8ac58c3f13ccca5f71ddf33870037aa7dc80e49e9b459634908020b311), uint256(0x16d3ebe7fc42b6c3bb57b4ad536112864023c730d819d10f8dcad74c78e632b6));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2acb9e8852d4964690a93443900406e75940af2ee112521fc831889a27fdd378), uint256(0x0b87739878882b9adad6b7a8a7cbceb56aa691a94f9fb5a30844453507a4f6da));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0437ca18194993d569b18c861f319a209fb813b784c535ab5240b26787ad8be6), uint256(0x29bc45367f32587e4d241e42db2aac43d3518c7ba702fa03de1c59072b3731b3));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x03cb81421f2bc59730d4b0cc7d3e7390e62820469724d9df92027b18c76d5619), uint256(0x2342a65966710b3607f73b01a5e1ae2169981733390b44d38b2cb7c8a6482ca1));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x03f315f8e93528a395c1a089c88d899f69312927483db46ea3d61814910b0031), uint256(0x1c6b5308e7f6be54fec707e726878a03add438003ea880ab370a29b7e1fcaeff));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x094ee2ef205f6972b57f481f739a3d3bc29f06b72bc8b28ad5d64152025fec8b), uint256(0x2c5637c695e50113392e6bf8d95ae223d61ae3535eb025485d9c6b232af75b28));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x086618f514bc0e200198233007e65505efdbc63816f7ae604c8210eac30cc09d), uint256(0x0f0456876d5a69c4ca403ad80fe6c1f622e88125184313196dbdb9116edfcb37));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0814f01da72a58fe16486294bac3ff0ca56c7c2a9326c6ca2d8840d992b5d703), uint256(0x240dbf55a0bbe7b28a26285e41f2fa02ba3b68b6a4dc01bbfad2bfff90a8b4a9));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x13029267c2f1e319b08a1d73830c79845622fec41c171d5ee6a5b8bfc62332df), uint256(0x25255160aba8f552621602d388b40f7cff7bf5d0343c699bbecfaa9bdf1ef871));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0e2cac25536a4c90f894ad6840b2067152033494c1d083bd146aa5e500d219a7), uint256(0x0c8d2aa4f1535637fb63a2329bef6f4a2144795b86160f651feb2d0c18abe009));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0585d1e27905fb7ef4def9a6ece5d7df84c7e7c4279b63c0c14f6ad8e00088ab), uint256(0x0efc2d9a022c9a4ec5326e51224e0f6963ccece34e70e385053da297fbd45416));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0c19cabf34c40189ea0577625f71de785e76ba1d0bfc4808041ee94dd613c672), uint256(0x0131c16871e508a711f37f2c6e14a4fffdbf37544e061e09a99c00cc6a0194a8));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x0b5de6f38b5a53af3f3fcc6c923582998f03fe66c6df2d02968c060883ba1459), uint256(0x2f45d659ae13c1a933c631dda015e43856e071cebc8bd397db34b6b333f2a3aa));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0c59d5a7ce6371e601032450e2b3d2ebd4cda3b5d52aab7d04a7b28eff683d93), uint256(0x2976e6059f14b37db676c2f5566d12c577fb689149f86b6ece37058bf3d7d6d2));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x1f72135f7894077f20caab8895baed469f617c77743a3e131d2c43ceab48295c), uint256(0x11d510890d890d1dc47f2d2cff2b4c4be5c742ca3cd154e5c387d0c808809ccf));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x06ac921363a55c5f6bcba58ee612073233d434afe52fd9bd0aff488d5f724e18), uint256(0x02334e1b2430682df1e4ce20b68d2b7680462324729df37cadc8edb662b6708e));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0a06e33d63b76e49c726cecfc235f602211c189a7acd2cff4e1fb61768584a31), uint256(0x0cc168edc9472f6bc333287f732b140165551a61b7ebb78c6c09ab3f7c4f8600));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2898a71c5225cc85aafba9f21cfcd38df504d685cf68d9b6d1d4a70f747739e9), uint256(0x0b4c04a02521f554d1003d744174c160a9ac0e96f3473ecfc8611672848f2cea));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x091c1eed6721f20848faa34689212d4e0d05a722bcd03ffad53a375979eac178), uint256(0x037dd356e368e9e7ef83e27ff2a6a71aec8f578bb1a396de30f2dac05142a9be));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x15107c88864d1af4d398f3ea73a03d78e58471591f4f0d2741e7ffa045f8e685), uint256(0x199c0221afe199cbc92a18696c7bdbea02cd2d274cf231ddedd5f2df3065901a));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x06096c32fc433152165562cdc85ee4d5ccd4ddd61f4dc21c28575a9458efab35), uint256(0x1181310718a80d617bc8d874301ab3d4f2f4e276ae90a0a332fb15a9f7937672));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x1b683545481514130e9eddf0b6b51673402383edea9b5b8fdc4f59118da89214), uint256(0x291e27e933d90821ee6f1ce53c2e71c7636e54164fd12c807d3f7b59e907935b));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2dc6db8ae966127ff7c89c453f89f15e00ff4b0606bbdc3aa30c67dab96bbc24), uint256(0x25b2513b91abc88353c1c1fe8ac5f512db3f002f412b42fd24eeb3ac15998693));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x22f7f2f3f405d1e910a377a85c7a12581ecb25fd54689ea87783b74af2223c44), uint256(0x08e1b845cbd5d68f7b296d2f806051c224ec6edab3fb5e966bce00638ee012e9));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x0cd632fd1fcf54236bac0cff1eec47408fcaafabf9a8620791c7b460c0a13fd8), uint256(0x2e0fef8f7470990407ab4cd7a47075c5e92ed5b76960ebc487047084649032b1));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x19d47d34f60464050e100db29a5472f0b64e73bc55bdcbed8173d0f95dcd3b83), uint256(0x2500f29e4ac80afa36eb53d8ac0bd8e46e3c479dae4d4ed7003542d640c9e275));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x0bfc6b00c670026abae45287c34e069938faa4fb3e11f3ed5958563afa42d0bd), uint256(0x1bba1f790431ede35827e267e7645dcb33c7e3498dfc40dc38911e210f530eea));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x0f9a1a01c3b3a4e2cba3c7bd36691d8c46aef6dddf5a401001230885c90483a1), uint256(0x294cdda02e8af8f0916305f6351e30eaf283076b3b55a21b1bbdbbd4d86eadd2));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2a30a3b718e1f7a00a14da7febe45a426812f79aac303cf740826a33daf364d1), uint256(0x1b0076a392b66945b271d93810b28e7a8390b72c8af68ee6c3255ff87973e405));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x093cab0e6593da6b5a5a1e6d78cb98a6caa26815c568d2e64620344a701e6667), uint256(0x09e9723f0bd34b04df6f502e84ac6ea01956bb387a647894c59485202aa84e42));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x14d01a368f229ad593bdacd8f83474353e697244fcf7f971b9b898236fe04a41), uint256(0x254695f98c1fb378766b9f7bdfe32805824d383e62c18d3e248f8387940265dd));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x170bddfce2ca801b1078c41aa906520b88ed4c3a057b3b479d050a5c8839b58b), uint256(0x014c17df9af38b800693e85bb1299982290e1678e99da1783beac627e20dbf0d));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x134c9a8ba889b84913de3d98e5a1d2b164f8f376e7f4ddd761b405e9923f16f1), uint256(0x2276406cd1700c6f83bb7b97f1b31034b79a5dfa766a02067ab723d28baa37b3));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x031cf5d1e7cb6fcedfc0e544300a66164051d457aaadbd43f58ca40cbe2c1f12), uint256(0x03fc36672cc606a92783dfd6605404df6b03754b142066c9cda8252ca8555371));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x2e0f936961db878dcd34f710052ff427e4fe62399cb8c701630e5d2d2b4126f9), uint256(0x27db53d658cf42ff1cdaa9a7c20ba6eff99a48c22d483649ca9ea49a442ed03a));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x0f4b786dc131664a21f0d8f38254a0b9fa098048c664d898a251854d57a20e91), uint256(0x285118f6709ae53a63a8fe27c05e368b419154d7e7f78e4a1bb3e8cba3d83dac));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[63] memory input
        ) internal view returns (bool r) {
        uint[] memory inputValues = new uint[](63);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}