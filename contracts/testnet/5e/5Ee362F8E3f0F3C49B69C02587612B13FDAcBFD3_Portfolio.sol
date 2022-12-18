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

    function solve(
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

    function solve(
        uint256,
        bytes memory answer_,
        BetaVerifier.Proof memory proof
    ) external {
        uint256 ans_ = abi.decode(answer_, (uint256));

        uint256[62] memory input_ = abi.decode(input, (uint256[62]));
        bytes memory temp = abi.encode(input_, ans_);
        uint256[63] memory input__ = abi.decode(temp, (uint256[63]));
        require(BetaVerifier.verifyTx(proof, input__));
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
        vk.alpha = Pairing.G1Point(uint256(0x189f7bb042e0ba90217842fd4bf1d5ce73adb6fabb34a8749be0f59a8ab379af), uint256(0x0c1cd5f04cba0b021afd5def817a93f01b78d851caba446a5c13872fc71b89cc));
        vk.beta = Pairing.G2Point([uint256(0x156de359c9b9c02eb2e85de1808bdba3047289c4d5a5f1c4ed97ec9a9ae7a6bc), uint256(0x2fb206075549301769d697f753ec48e22a3c9d8899e519cb0e0da7b5694acb31)], [uint256(0x20ecfd4dabcb3ec7c6c7ebf65ad8e25d94d5e72229f27ac867272862896f0bf7), uint256(0x06165e42d53bad9a589d2c16e6e6ca2c9adebef594a596c238b9c3e842175ccf)]);
        vk.gamma = Pairing.G2Point([uint256(0x1f69c46d468f827a8e917eb3eef35a6528b352969fa1afa8bda133a4559f4fca), uint256(0x2747425bd9fd28319e5d5d6443b1693b8fd9e8ca9ce5a6b2b7e04cc7009f421f)], [uint256(0x18c8bb7fc8d711247a50ce23e7871b7408fdc647aeb246ba7b5556f09a0ce2d1), uint256(0x2f85265a0aa77eca8bb68d87c7471c9ccd585f544077a3ad99f5916fff0d9183)]);
        vk.delta = Pairing.G2Point([uint256(0x281dcbeb22375bfb8a0370d5d8ef93c08cc3f3faaa76f4ba7943bcf579eb538e), uint256(0x1afea56c7e3a5d69cdc48f92d69e245e0a79c31478099bbbb5c37dadcc7956bb)], [uint256(0x17846ed6410577e287207d6508bc7947234fcd5a19f80078c5a16e45983fb8f7), uint256(0x2d0526e58135f9f05ca03e6d953bf992820663459b874f364e48f80e1539ee46)]);
        vk.gamma_abc = new Pairing.G1Point[](64);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0f4e972b115b7c4ba54d3a3c321d682ad67b311e64d77549d4525824b4125188), uint256(0x0dc5b850711593055b5c327fb7c5c30e98ddbdf58f6494bc044dd1078fd1e6df));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x255a3f7a02579ff3251512178e2926861b3198014dc1e3b402d6c8f06a634bcb), uint256(0x2b429a4ed98a6e6f37325e5eb43e70aa728389ee831d533e5b3277d4a5838990));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x02ca864e4fa01ea19030b694d1b1800d7210d9f184f257fb9c21d09d61266fbd), uint256(0x14d7eee3de263809701c85db4cfcd5bc870da0fa73e020c787b82e3b4619b2fa));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1cc989ce68a49fff1dbe9260ed91ebaa96759170c7f383734d8b2b20354fd168), uint256(0x0a6b5ef8a1c18cc4eb9297eab6e0bdff9366e31192ebae4fb321b7ee83c69069));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x19a39517358d0a0f95636593a9e142565e60411a72c4aa4745e5c3df684d1fe3), uint256(0x1f40a7348fee715218ea9764b7ebb57c3b5899504ecd76d89787123efc2d0758));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x127438121d75f8798b1699fbf503e6eacfa568ff7196b390759f338295baae29), uint256(0x07e68c818c08a4651952e0c778bf372e2f39a6632b97cedf4382b0e763e741a6));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1ffcecbdc6f70f6f56c11e98bdb64be8aa9a4c5138a4b1aacb1cbfd4334aa3f4), uint256(0x113d2ec93ecc7f17397d88372843dfef5bf0d70be5c8ab6b94287ac7acdee278));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1060ad7f7be0932486fb02c7c9dd0a19ce30142d95f1169b99d1fef8f2814d21), uint256(0x141436fb631c6df50c8e1620c66f0dc508ba5ac7f0ee27b45c93102d09717a1d));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0191e765564fb6baac619195aa75cbd8eb1ca6f035849a39cf32db6c4b927795), uint256(0x298393d82ea03ae0a4397e565de66af28d8e3f1fbca2a05450862278f08f568c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x02b1848b76dccf230412c893218ee2cbf59552beb61f6f7a4d5a82eef3d6114b), uint256(0x2c991bd0ec53ed36ec5a8ae124bf91789812e494dff4e8aa22ec43a2472483c6));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x27a899ac5d0632b7f2abcddd8dd0476dccef2a12be1aafd67fd67f16c94b870b), uint256(0x07386544ba646c0858a27f5e4bd288c4e23e868461a61b4055ed8aa7cecef064));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x135edb10ccd11dc57b8277901db5c1c44965bc7f158737384dcd0ee8df0c58dd), uint256(0x03107b4b720837bedbcc13be210287f509c3ff6689b28e5b3e29a221f135d8cc));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0371e42be27a4b975931c1fd5698705c889b28898663b5f3371c3f65beb66286), uint256(0x013f1839400d6ebe4084690f30722da5b2a9008a5c78988297d4a29bf0c22270));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x18cb49486d956cb4998c3085f23fe1a49c997a3b37d6cad556740109bde4b552), uint256(0x0f5ef9f66720051377564704fa67cc97c1fcc2d0d4f513c61e9311fff551fbd6));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1e9b25114649ff0d8d88b85da0bc7db65d8f21170e8aa119cc6545ebdd38199f), uint256(0x2675d9864da2750bbdfa5a7558ef96aaba45bb126f585ecc0f8d81c7f1bf9619));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x250c041f2e4fa0cab2d24bd64c76b89e6f22fbbc2df250ed8e3a028d21e22f12), uint256(0x132e2b811f70b0ae8457e62b123cdb12710b84e5baa3429c514fcd5c8ccb0c60));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x10867155b17000a87bbf24cdfa1bef4a18fc7c93b45db39fba5996a7db3faac3), uint256(0x062cc5e1ab1cb6d1f24877269fade4a27b7a72e2a733785986b5030cead1fdfe));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2e5713638f4f78f276a92fb5662ad112656755b6108877999647120dc1e76574), uint256(0x1095eab2ae26266e2d91784572d41feb6069212508180b5854d2f42723a93184));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x04a7b754e11563579dbaa534f2507aa715a5220094d64b8aa273bcf1e5508705), uint256(0x18f780e9e9e9177ebe2bf867d0666ee75fc0f0272cbf89fb516ac8e7edfc9f9e));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x17346f570f8c6e3e1585171b16a3baff9a7bb87e17c22999d25398744c440658), uint256(0x05d6ccea425511e7bbcdb959feb64f2e181978d3bf6fa37f87c427621a72b629));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x28ab3dea54d85090f11e4140988f6aff8c84ed5c57cdc47d016c4fcc9394f4ce), uint256(0x2f62083f32ffa523c69c5f62a0d262a24d298b5279d31f8aa7a76c1db369dfdd));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x19d284e1632bba0ae40b64edc265283c5948a7ca8d99587b8459661ff05668ad), uint256(0x14c31c0d54e85ca72423ab9e16d08b4159a8ecb827d2d8454b71aff31d7367fb));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x16408f9af6ead03033ee70652f62507e79eb3df745b564a283c5bce25a65d5b8), uint256(0x2f8fb136bf9d02294d6afe7c32a6505f0d77a39657896846f681cd8bab66a6d2));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0f87a2d0b853d38ac14ac9db4d7f28e10dc5483424d6535d6279c8180eba7f91), uint256(0x0170e7a321209cce1da04fa7467a51e441d2d4eb73897d93437c9ec32e85d2ad));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x242340ec229841a65ad845dcb38f6864536c381080503655d9f3a57f7a900a7c), uint256(0x12efd5e9561e5877f6e927683fe6528d49f4477cd85b04d2393dd5a18e3409b6));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x25859fda6f775c6fded7c72158e16a73d08b2f1228660ef59f744f2670181079), uint256(0x25b66ab4f074709da64638cc174b73a4e282f7e54fab076c37fd961b55f9bece));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0d7236fa3b7c14b9db0541524a132df95edfa92f667371e93ce59b6c5e3d0cae), uint256(0x11413763e907e931362788020b59f6bda8ca26505f8815e315bdcffdd57544b6));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x18f8ff4c617558b037ae6dec9eb584ab292e73914d374d41892584399293a4e7), uint256(0x110008966c39d0cc198755080c8de6d0fce6c9ea560d882bb621623cdac5c560));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x16e1b40e45a491e6aa9ab0458ee5720a5a7e9cde72a11b80f49dc4c956847ad2), uint256(0x0905017d42c690839da7d6dc079dcff12440c4b6eb1f16b2e8755196c56673d3));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x0ccb8f8902270e1708e06952c70ea654f1a204714fe513e5d039dec98537c955), uint256(0x0e795fad40f200050797fff2fa221b7909c5228d38be0b5190196700192f0786));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x18162c72cd900f166467a03cc6cd7907eed1592d2aff7c06ffacb2097342ebf7), uint256(0x206dc2086365bbdb07909206f5d464627892dce6f8c0b7b381d4bcb8be2e5f26));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2e47039bd6d4f20c23421486756c9b1186854dbd7b9257e87fad6a927843e9ff), uint256(0x24054e3056d4095d82f8c209e153f08ed28e96688558addfd9d4ab6e0a704bcd));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2208ab31a7bea2d84fbade0146a05c8665da5a670fdfb21334db9299e52ec3ac), uint256(0x0cc28b35596b22c0be802ed60df90ac96bd8e5770f9c7e75116ec35cd11c5004));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x15107b55b617479fe4335f293f6053dba24142c48c9066ceabea36749b5c2f62), uint256(0x26dda65707e8ce73f3b34c22f09e02213255c9887aa7aa56045564d335cb6b8f));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x1d3c2412fc6f05c4074ca65ca3d2b2d0e10d1a8d1bcac09fb0d1679b511f9678), uint256(0x1dea72fa238fd74a28892a5539a0bdaf0977a56da52316ec5f0cac2367300a1c));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x288e4111d92af614a93a1fda4b629073894babbf91e016c8f61d8e47df6d2da7), uint256(0x2be188feb398cc967d3e1128a1ec68050c1e82988e2194782dd1eedeed96e260));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x201b00fed7d34bfcb21f8fb771a6d2226299ccd703b0c1e894b9bbd167288a26), uint256(0x094abb981dda3221e1f2d25983265b4bfec278b9d6d555599ac5e6d4fa03fc4f));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0de582094465c0173a03ce3f5245140182a08e52f54f478b785e8fc73e96f8c9), uint256(0x13be83e469a12924d04d79b020aeba0c3046502e03ffc2b6b6292e0cb7b6d6e9));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x192816fde96ce18e605b1c01ac1e57ae937b31f18f093706ec7a640e379c7935), uint256(0x2c6a106f816d9cd73057e80cfc86e501fb92fe252a6d0f5b2d48dfca787314c7));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x15c5f9bc98acf38cbedff1671c0bd9931c6b1dbb8efa87f6db47216a3223e96a), uint256(0x08ea9c908e57e8e5237b01ced298e32f6289b9f9e7c557b87c536b01140b9de0));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2089aeee18dbd81e767d87161b60bc8b3232939297c9604ea724658f9fd841a7), uint256(0x1cbffd85a33d9183b444217067cecd6694af9e9368c88bd9951348ae750bf88a));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0f8ce0ff843aaefe9b75d011d88ebe4b39f75a6bea6b68eb9409c4591d1c5e0b), uint256(0x1bbeb4bc93ad65575d245d1e7e4f0d259e7ba6ff7caef7565daeb117fe59b4ba));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x12757aac9e9b2ca49ed6c8f5d077f199856895c017b2bdb022a5fd8224255f0d), uint256(0x09d1e20bb0c9644bef8f6834fb275538db029bee73018c2d57a961068e31e5ff));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x06235808ec2f64c308fbe2f44936b423dd8383d78bfba5154b65bba4831fcaab), uint256(0x14353d62841696ee9a6a76528afd96957c55448a99056f84679887e8cb5d7777));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0e77d57a5217de19743e7be4dd859b69a005dee1e25ffb02a5ce2fb9e6749555), uint256(0x28432fe63dd13bb56d2a829261ebacafb87e7c0e0a42d37e0667bead99f0a1c5));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x193a76a99ef6055204b3756c8f9cd620a47fd782203246e2c0933b522b1db3dc), uint256(0x007ec546f7d94b104b869de6b69a21ba6e3e9d7803f4b028895e4a6b363501cf));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x1f227711006266f305f5e3db7d2863c7331d11cfd82ece4983c168b76d920e4c), uint256(0x1c0f925164181fa7b9ea944924006eb766ac3c335aa95a7de1d267ef7f829d98));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2b9f65eed7d8e701cde2b31fcdf8568ec90c7ef721d6dbafdc19cc18b9aa1008), uint256(0x27c439b6212ab93d41cd9b29689a6d77eea8d36842eb5eb6b3f40e8e59e6c0d1));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x1b78ff5c86c52a47c8184b1cbd0bfcaae37c9985fbcbaea32e17553b03efd3fd), uint256(0x0fec0a09e0be452e6da5dec6a64645c034c1b36df34ee1c9758534b9148bb33d));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x23a7a1fcf42857af8fe3685a9aaa844426ce838104fa1f60eb53a3b4be36a93c), uint256(0x13a206117659cd79d35907234a0f5b1b2b74d97439f88bf5f4d24b11924b7aea));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x1a66a605dcd829f5ae44c1385ed6df3f82836d3548fb12338e1557c82976ac3d), uint256(0x0f5fe74d2487d033cf54699d59eda2819378557b0a328a852890bc243c15b69a));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x115947f06db8f07cd72b9b31de1439128b28124276b2466a5b0c81f96c24da12), uint256(0x29379e1ba7e874212e4cb6153d2bd39640bfa5ee439da6e3001ea9edbd193c2b));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1a8c567b7e7b36a5e411bb7089767d1c18427baf933cbaf8538eaf43cf2447e7), uint256(0x01778d467f75972169f083f356834048ad70383ff27e230faa39364d75db59cf));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x1195fd593557dcb57bc5f990ba550c82717df42911e8900bab45d84b956b4753), uint256(0x17074c0138262ec24c89fc6540ad1aaa85dd7cc44b3d8655d6b68e8f25cd6626));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x050c2eb74c474ac06ac96d69669e001ba94c7d38459327d721dc958c77b497ca), uint256(0x2c42aeb7caeec4ea5c67fede6d184aafad43ddf624fbbffd4e4b310125be9c14));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x2973b5ae58888b679562cbb1acfb1bbe1a179241203356fc7024215165b3b92e), uint256(0x08423db4e40d6b1978bfa3a46559d3a81cfc3cde90e8ee50242796782007bf20));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2fe8649b66331a36af52a905bea3a9e73813733c33125b1e63ded524e3a376c1), uint256(0x21fb6b954b97006eb44e13337fa395a6686ddb23a8587d2742add9ddc9026949));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x08c4c6ccb3b0a6a9df588acc408162a6c8a43d9c5a367934afe794e52424fd64), uint256(0x2a1329039aeb6199d05d7933022a20c148f5fb75450b88ebe1f73bbd04f9d3b3));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x1b8c6b7cda14acd1d5d7af133f40aec510f6bc147915a7bc9a0d37fd705c98a3), uint256(0x1e027f0524c0c114351e33c43a8c45ab896c95982bc3ffbe44061d6901864e8b));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x14eea94c4b8df6044b12388756c5275530cd111b4a9c8e1f055e7c516fcfd251), uint256(0x253c3cdec7436cb8f34ee722415c7050887b6462c3e2492d526fd9375c370260));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x097835e88cd21d26e21b57253652c3713ea45d6315561aeccae302415de543c1), uint256(0x0b50ad06956dc594fe3f15395f568da60038ba45fdcf762fd75d2ac79b3efb0f));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x07ded015df515947064e59a685adc0d6e709e1cf3212af8d48c2f79e81ea111e), uint256(0x2d674d8f9f29bd6132e3e6ea0b0ebd44a75323eb565b6dacd0ba95a977a36c7b));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x233bb06284780bfbe04f5decf3922352b956e9715cb167730ab51d066d7d24e4), uint256(0x2ff6f7fda59df85469f2d43724a0d4fcd8d02ee5034e96c2120372c0d5f16676));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x2a89f14bb54866942252c631e0a72ad9f35718aef0914a30673cc53f885c129a), uint256(0x2190a046be1b06b5a9eaf77ec83497c366b761885dbf280a6ccda567afa76e83));
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