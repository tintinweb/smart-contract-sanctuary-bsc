// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "../common/IFerrumDeployer.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../common/SafeAmount.sol";
import "../common/signature/PublicMultiSigCheckable.sol";

/**
@notice Basic implementation of IronSafe
  IronSafe is a multisig wallet with a veto functionality
 */
contract BasicIronSafe is PublicMultiSigCheckable {
	using SafeERC20 for IERC20;
	string constant public NAME = "FERRUM_BASIC_IRON_SAFE";
	string constant public VERSION = "000.001";
	address constant public DEFAULT_QUORUM_ID = address(1);

    bytes32 public deploySalt; // To control the deployed address
    mapping(address=>bool) public vetoRights;
    uint256 public vetoRightsLength;

	bool private _locked;
	modifier locked() {
		require(!_locked, "BIS: Locked");
		_locked = true;
		_;
		_locked = false;
	}

	constructor () EIP712(NAME, VERSION) {
		(uint256 minSignatures,
        address[] memory addresses,
        bytes32 _deploySalt) = abi.decode(IFerrumDeployer(msg.sender).initData(),
            (uint256, address[], bytes32));
        deploySalt = _deploySalt;
        _initialize(DEFAULT_QUORUM_ID, 1, uint16(minSignatures), 0, addresses);
	}

    /**
     @notice Override the initialize method to
     */
    function initialize(
        address /*quorumId*/,
        uint64 /*groupId*/,
        uint16 /*minSignatures*/,
        uint8 /*ownerGroupId*/,
        address[] calldata /*addresses*/
    ) public pure override {
        revert("BIS: not supported");
    }

	bytes32 constant private SET_VETO = keccak256(
		"SetVeto(address to,bytes32 salt,uint64 expiry)");
    /**
    @notice Sets the veto right
    @param to The to
    @param salt The salt
    @param multiSignature The multiSignature
     */
	function setVeto(address to, bytes32 salt, uint64 expiry, bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(!vetoRights[to], "BIS: already has veto");
        require(quorumSubscriptions[to].id != address(0), "BIS: Not a quorum subscriber");
		bytes32 message = keccak256(
			abi.encode(SET_VETO, to, salt, expiry));
		verifyMsg(message, salt, multiSignature);
        vetoRights[to] = true;
        vetoRightsLength += 1;
	}

	bytes32 constant private UNSET_VETO = keccak256(
		"UnsetVeto(address to,bytes32 salt,uint64 expiry)");
    /**
    @notice Unset the veto right
    @param to Who to set the veto to
    @param salt The signature salt
    @param expiry The signature expiry
    @param multiSignature The multi signature
     */
	function unsetVeto(address to, bytes32 salt, uint64 expiry, bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(vetoRights[to], "BSI: has no veto");
		bytes32 message = keccak256(
			abi.encode(UNSET_VETO, to, salt, expiry));
		verifyMsg(message, salt, multiSignature);
        _unsetVeto(to);
    }

	bytes32 constant private SEND_ETH_SIGNED_METHOD = keccak256(
		"SendEthSignedMethod(address to,uint256 amount,bytes32 salt,uint64 expiry)");
    /**
    @notice Sent ETH
    @param to The receiver
    @param amount The amount
    @param salt The signature salt
    @param multiSignature The multi signature
     */
	function sendEthSigned(address to, uint256 amount,
		bytes32 salt, uint64 expiry, bytes memory multiSignature)
	external expiryRange(expiry) locked {
		bytes32 message = keccak256(
			abi.encode(SEND_ETH_SIGNED_METHOD, to, amount, salt, expiry));
		verifyMsg(message, salt, multiSignature);
		SafeAmount.safeTransferETH(to, amount);
	}

	bytes32 constant private SEND_SIGNED_METHOD = keccak256(
		"SendSignedMethod(address to,address token,uint256 amount,bytes32 salt,uint64 expiry)");
	function sendSigned(address to, address token, uint256 amount,
		bytes32 salt, uint64 expiry, bytes memory multiSignature
    ) external expiryRange(expiry) {
		bytes32 message = keccak256(
			abi.encode(SEND_SIGNED_METHOD, to, token, amount, salt, expiry));
		verifyMsg(message, salt, multiSignature);
		IERC20(token).safeTransfer(to, amount);
	}

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
      Also removes veto right if _address is a veto holder.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function internalRemoveFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) internal virtual override {
        super.internalRemoveFromQuorum(_address, salt, expiry, multiSignature);
        if (vetoRights[_address]) {
            _unsetVeto(_address);
        }
    }

    /*
    @notice Unset the veto right
    @param to Who to set the veto to
    @param salt The signature salt
    @param expiry The signature expiry
    @param multiSignature The multi signature
     */
	function _unsetVeto(address to
    ) internal {
        vetoRightsLength -= 1;
        delete vetoRights[to];
    }


    function verifyMsg(bytes32 message, bytes32 salt, bytes memory multisig
    ) internal {
        require(!usedHashes[salt], "MSC: Message already used");
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddress(
            digest,
            1,
            multisig);
        require(result, "BIS: invalid signature");
        usedHashes[salt] = true;
        // ensure there is at least one veto
        if (vetoRightsLength == 0) {
            return;
        }
        for (uint i=0; i<signers.length; i++) {
            if (vetoRights[signers[i]]) {
                return;
            }
        }
        require(vetoRightsLength == 0, "BIS: no veto signature");
    }

    /**
     @notice Override to use the veto signatures 
     @param message The message to verify
     @param salt The salt to be unique
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueSalt(
        bytes32 message,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal override {
        require(expectedGroupId == 0, "BIS: Unsupported group ID");
        verifyMsg(message, salt, multiSignature);
    }

    function verifyUniqueSaltWithQuorumId(
        bytes32 message,
        address expectedQuorumId,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal override {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddress(digest, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        require(
            expectedQuorumId == address(0) ||
            quorumSubscriptions[signers[0]].id == expectedQuorumId, "MSC: wrong quorum");
        usedHashes[salt] = true;
        for (uint i=0; i<signers.length; i++) {
            if (vetoRights[signers[i]]) {
                return;
            }
        }
        require(vetoRightsLength == 0, "BIS: no veto signature");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFerrumDeployer {
    function initData() external returns (bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library SafeAmount {
    using SafeERC20 for IERC20;

    /**
     @notice transfer tokens from. Incorporate fee on transfer tokens
     @param token The token
     @param from From address
     @param to To address
     @param amount The amount
     @return result The actual amount transferred
     */
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount) internal returns (uint256 result) {
        uint256 preBalance = IERC20(token).balanceOf(to);
        IERC20(token).safeTransferFrom(from, to, amount);
        uint256 postBalance = IERC20(token).balanceOf(to);
        result = postBalance - preBalance;
        require(result <= amount, "SA: actual amount larger than transfer amount");
    }

    /**
     @notice Sends ETH
     @param to The to address
     @param value The amount
     */
	function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./MultiSigCheckable.sol";

/**
 * @dev This removes adminOnly and other relevant methods from a multiSigCheckable.
 */
abstract contract PublicMultiSigCheckable is MultiSigCheckable {
    /**
    @notice Initialize a quorum
        Override this to allow public creatig new quorums.
        If you allow public creating quorums, you MUST NOT have
        customized groupIds. Make sure groupId is created from
        hash of a quorum and is not duplicate.
    @param quorumId The unique quorumID
    @param groupId The groupID, which can be shared by quorums (if managed)
    @param minSignatures The minimum number of signatures for the quorum
    @param ownerGroupId The owner group ID. Can modify this quorum (if managed)
    @param addresses List of addresses in the quorum
    */
    function initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] calldata addresses
    ) public override virtual {
			_initialize(quorumId, groupId, minSignatures, ownerGroupId, addresses);
    }

    /**
    @notice Disable force removal
     */
    function forceRemoveFromQuorum(address
    ) external override virtual {
			revert("PMSC: Not supported");
    }

    /**
    @notice Disable cancellation
     */
    function cancelSaltedSignature(
        bytes32,
        uint64,
        bytes memory
    ) external override virtual {
			revert("PMSC: Not supported");
    }
}

// SPDX-License-Identifier: MIT

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
pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../WithAdmin.sol";
import "./MultiSigLib.sol";

/**
 @notice
    Base class for contracts handling multisig transactions
      Rules:
      - First set up the master governance quorum (groupId 1). onlyOwner
	  - Owner can remove public or custom quorums, but cannot remove governance
	  quorums.
	  - Once master governance is setup, governance can add / remove any quorums
	  - All actions can only be submitted to chain by admin or owner
 */
abstract contract MultiSigCheckable is WithAdmin, EIP712 {
    uint16 public constant GOVERNANCE_GROUP_ID_MAX = 256;
    uint32 constant WEEK = 3600 * 24 * 7;
    struct Quorum {
        address id;
        uint64 groupId; // GroupId: 0 => General, 1 => Governance, >1 => Custom
        uint16 minSignatures;
        // If the quorum is owned, only owner can change its config.
        // Owner must be a governence q (id <256)
        uint8 ownerGroupId;
    }
    event QuorumCreated(Quorum quorum);
    event QuorumUpdated(Quorum quorum);
    event AddedToQuorum(address quorumId, address subscriber);
    event RemovedFromQuorum(address quorumId, address subscriber);

    mapping(bytes32 => bool) public usedHashes;
    mapping(address => Quorum) public quorumSubscriptions; // Repeating quorum defs to reduce reads
    mapping(address => Quorum) public quorums;
    mapping(address => uint256) public quorumsSubscribers;
    mapping(uint256 => bool) internal groupIds; // List of registered group IDs
    address[] public quorumList; // Only for transparency. Not used. To sanity check quorums offchain

    modifier governanceGroupId(uint64 expectedGroupId) {
        require(
            expectedGroupId < GOVERNANCE_GROUP_ID_MAX,
            "MSC: must be governance"
        );
        _;
    }

    modifier expiryRange(uint64 expiry) {
        require(block.timestamp < expiry, "CR: signature timed out");
        require(expiry < block.timestamp + WEEK, "CR: expiry too far");
        _;
    }

    /**
     @notice Force remove from quorum (if managed)
        to allow last resort option in case a quorum
        goes rogue. Overwrite if you don't need an admin control
        No check on minSig so if the no of members drops below
        minSig, the quorum becomes unusable.
     @param _address The address to be removed from quorum
     */
    function forceRemoveFromQuorum(address _address)
        external
        virtual
        onlyAdmin
    {
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        _removeFromQuorum(_address, q.id);
    }

    bytes32 constant REMOVE_FROM_QUORUM_METHOD =
        keccak256("RemoveFromQuorum(address _address,bytes32 salt,uint64 expiry)");

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function removeFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external virtual {
        internalRemoveFromQuorum(_address, salt, expiry, multiSignature);
    }

    bytes32 constant ADD_TO_QUORUM_METHOD =
        keccak256(
            "AddToQuorum(address _address,address quorumId,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Adds an address to the quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to be added
     @param quorumId The quorum ID
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function addToQuorum(
        address _address,
        address quorumId,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(
            abi.encode(ADD_TO_QUORUM_METHOD, _address, quorumId, salt, expiry)
        );
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorum not found");
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        require(quorumSubscriptions[_address].id == address(0), "MSC: user already in a quorum");
        quorumSubscriptions[_address] = q;
        quorumsSubscribers[q.id] += 1;
        emit AddedToQuorum(quorumId, _address);
    }

    bytes32 constant UPDATE_MIN_SIGNATURE_METHOD =
        keccak256(
            "UpdateMinSignature(address quorumId,uint16 minSignature,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Updates the min signature for a quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param quorumId The quorum ID
     @param minSignature The new minSignature
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function updateMinSignature(
        address quorumId,
        uint16 minSignature,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(minSignature > 0, "MSC: minSignature required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorumId not found");
        require(
            quorumsSubscribers[q.id] >= minSignature,
            "MSC: minSignature is too large"
        );
        bytes32 message = keccak256(
            abi.encode(
                UPDATE_MIN_SIGNATURE_METHOD,
                quorumId,
                minSignature,
                salt,
                expiry
            )
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        quorums[quorumId].minSignatures = minSignature;
    }

    bytes32 constant CANCEL_SALTED_SIGNATURE =
        keccak256("CancelSaltedSignature(bytes32 salt)");

    /**
     @notice Cancel a salted signature
        Remove this method if public can create groupIds.
        People can write bots to prevent a person to execute a signed message.
        This is useful for cases that the signers have signed a message
        and decide to change it.
        They can cancel the salt first, then issue a new signed message.
     @param salt The signature salt
     @param expectedGroupId Expected group ID for the signature
     @param multiSignature The multisig encoded signature
    */
    function cancelSaltedSignature(
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) external virtual {
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(abi.encode(CANCEL_SALTED_SIGNATURE, salt));
        require(
            expectedGroupId != 0 && expectedGroupId < 256,
            "MSC: not governance groupId"
        );
        verifyUniqueSalt(message, salt, expectedGroupId, multiSignature);
    }

    /**
    @notice Initialize a quorum
        Override this to allow public creatig new quorums.
        If you allow public creating quorums, you MUST NOT have
        customized groupIds. Make sure groupId is created from
        hash of a quorum and is not duplicate.
    @param quorumId The unique quorumID
    @param groupId The groupID, which can be shared by quorums (if managed)
    @param minSignatures The minimum number of signatures for the quorum
    @param ownerGroupId The owner group ID. Can modify this quorum (if managed)
    @param addresses List of addresses in the quorum
    */
    function initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] calldata addresses
    ) public virtual onlyAdmin {
        _initialize(quorumId, groupId, minSignatures, ownerGroupId, addresses);
    }

    /**
     @notice Initializes a quorum
     @param quorumId The quorum ID
     @param groupId The group ID
     @param minSignatures The min signatures
     @param ownerGroupId The owner group ID
     @param addresses The initial addresses in the quorum
     */
    function _initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] memory addresses
    ) internal virtual {
        require(quorumId != address(0), "MSC: quorumId required");
        require(addresses.length > 0, "MSC: addresses required");
        require(minSignatures != 0, "MSC: minSignatures required");
        require(
            minSignatures <= addresses.length,
            "MSC: minSignatures too large"
        );
        require(quorums[quorumId].id == address(0), "MSC: already initialized");
        require(ownerGroupId == 0 || ownerGroupId != groupId, "MSC: self ownership not allowed");
        if (groupId != 0) {
            ensureUniqueGroupId(groupId);
        }
        Quorum memory q = Quorum({
            id: quorumId,
            groupId: groupId,
            minSignatures: minSignatures,
            ownerGroupId: ownerGroupId
        });
        quorums[quorumId] = q;
        quorumList.push(quorumId);
        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                quorumSubscriptions[addresses[i]].id == address(0),
                "MSC: only one quorum per subscriber"
            );
            quorumSubscriptions[addresses[i]] = q;
        }
        quorumsSubscribers[quorumId] = addresses.length;
        emit QuorumCreated(q);
    }

    /**
     @notice Ensures groupID is unique. Override this method if your business
      logic requires special management of groupId and ownerGroupIds such that
      duplicate groupIds are allowed.
     @param groupId The groupId
     */
    function ensureUniqueGroupId(uint256 groupId
    ) internal virtual {
        require(groupId != 0, "MSC: groupId required");
        require(!groupIds[groupId], "MSC: groupId is not unique");
        groupIds[groupId] = true;
    }

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function internalRemoveFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) internal virtual expiryRange(expiry) {
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        bytes32 message = keccak256(
            abi.encode(REMOVE_FROM_QUORUM_METHOD, _address, salt, expiry)
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        uint256 subs = quorumsSubscribers[q.id];
        require(subs >= quorums[q.id].minSignatures + 1, "MSC: quorum becomes ususable");
        _removeFromQuorum(_address, q.id);
    }


    /**
     @notice Remove an address from the quorum
     @param _address the address
     @param qId The quorum ID
     */
    function _removeFromQuorum(address _address, address qId) internal {
        delete quorumSubscriptions[_address];
        quorumsSubscribers[qId] = quorumsSubscribers[qId] - 1;
        emit RemovedFromQuorum(qId, _address);
    }

    /**
     @notice Checking salt's uniqueness because same message can be signed with different people.
     @param message The message to verify
     @param salt The salt to be unique
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueSalt(
        bytes32 message,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (, bool result) = tryVerify(message, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        usedHashes[salt] = true;
    }

    function verifyUniqueSaltWithQuorumId(
        bytes32 message,
        address expectedQuorumId,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddress(digest, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        require(
            expectedQuorumId == address(0) ||
            quorumSubscriptions[signers[0]].id == expectedQuorumId, "MSC: wrong quorum");
        usedHashes[salt] = true;
    }

    /**
     @notice Verifies the a unique un-salted message
     @param message The message hash
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueMessageDigest(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (bytes32 salt, bool result) = tryVerify(
            message,
            expectedGroupId,
            multiSignature
        );
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message digest already used");
        usedHashes[salt] = true;
    }

    /**
     @notice Tries to verify a digest message
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     @return result Identifies success or failure
     */
    function tryVerifyDigest(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result) {
        (result, ) = tryVerifyDigestWithAddress(
            digest,
            expectedGroupId,
            multiSignature
        );
    }

    /**
     @notice Returns if the digest can be verified
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig. Note that this
        format requires signatures to be sorted in the order of signers (as bytes)
     @return result Identifies success or failure
     @return signers Lis of signers.
     */
    function tryVerifyDigestWithAddress(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result, address[] memory signers) {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        MultiSigLib.Sig[] memory signatures = MultiSigLib.parseSig(
            multiSignature
        );
        require(signatures.length > 0, "MSC: no zero len signatures");
        signers = new address[](signatures.length);

        address _signer = ECDSA.recover(
            digest,
            signatures[0].v,
            signatures[0].r,
            signatures[0].s
        );
        signers[0] = _signer;
        address quorumId = quorumSubscriptions[_signer].id;
        if (quorumId == address(0)) {
            return (false, new address[](0));
        }
        require(
            expectedGroupId == 0 || quorumSubscriptions[_signer].groupId == expectedGroupId,
            "MSC: invalid groupId for signer"
        );
        Quorum memory q = quorums[quorumId];
        for (uint256 i = 1; i < signatures.length; i++) {
            _signer = ECDSA.recover(
                digest,
                signatures[i].v,
                signatures[i].r,
                signatures[i].s
            );
            quorumId = quorumSubscriptions[_signer].id;
            if (quorumId == address(0)) {
                return (false, new address[](0));
            }
            require(
                q.id == quorumId,
                "MSC: all signers must be of same quorum"
            );

            require(
                expectedGroupId == 0 || q.groupId == expectedGroupId,
                "MSC: invalid groupId for signer"
            );
            signers[i] = _signer;
            // This ensures there are no duplicate signers
            require(signers[i - 1] < _signer, "MSC: Sigs not sorted");
        }
        require(
            signatures.length >= q.minSignatures,
            "MSC: not enough signatures"
        );
        return (true, signers);
    }

    /**
     @notice Tries to verify a message hash
        @dev example message;

        bytes32 constant METHOD_SIG =
            keccak256("WithdrawSigned(address token,address payee,uint256 amount,bytes32 salt)");
        bytes32 message = keccak256(abi.encode(
          METHOD_SIG,
          token,
          payee,
          amount,
          salt
     @param message The message
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
    */
    function tryVerify(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bytes32 digest, bool result) {
        digest = _hashTypedDataV4(message);
        result = tryVerifyDigest(digest, expectedGroupId, multiSignature);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract WithAdmin is Ownable {
	address public admin;
	event AdminSet(address admin);

	function setAdmin(address _admin) external onlyOwner {
		admin = _admin;
		emit AdminSet(_admin);
	}

	modifier onlyAdmin() {
		require(msg.sender == admin || msg.sender == owner(), "WA: not admin");
		_;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library MultiSigLib {
	struct Sig { uint8 v; bytes32 r; bytes32 s; }

	/**
	 * Signature is encoded as below:
	 * every two bytes32, is an (r, s) pair.
	 * last bytes32 is the v's array.
	 * If we have more than 32 sigs, more
	 * bytes at the end are dedicated to vs.
	 */
	function parseSig(bytes memory multiSig)
	internal pure returns (Sig[] memory sigs) {
		uint cnt = multiSig.length / 32;
		cnt = cnt * 32 * 2 / (2*32+1);
		uint vLen = (multiSig.length / 32) - cnt;
		require(cnt - (cnt / 2 * 2) == 0, "MSL: Invalid sig size");
		sigs = new Sig[](cnt / 2);
		uint rPtr = 0x20;
		uint sPtr = 0x40;
		uint vPtr = multiSig.length - (vLen * 0x20) + 1;
		for (uint i=0; i<cnt / 2; i++) {
			bytes32 r;
			bytes32 s;
			uint8 v;
			assembly {
					r := mload(add(multiSig, rPtr))
					s := mload(add(multiSig, sPtr))
					v := mload(add(multiSig, vPtr))
			}
			rPtr = rPtr + 0x40;
			sPtr = sPtr + 0x40;
			vPtr = vPtr + 1;

			sigs[i].v = v;
			sigs[i].r = r;
			sigs[i].s = s;
		}
	}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT

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
}

// SPDX-License-Identifier: MIT

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