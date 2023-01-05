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
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
pragma solidity >=0.8.0 <0.9.0;

library Constant {
	uint256 internal constant _MEMORY_LENGTH = 1000000;
}

library AddressArray {
	function remove(address[] storage _array, address _address) internal returns (bool) {
		require(_array.length > 0, "Can't remove from empty array");
		uint256 _oldlength = _array.length;
		// Move the last element into the place to delete
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_array[i] = _array[_array.length - 1];
				break;
			}
		}
		// Remove
		_array.pop();
		// Confirm remove
		return (_array.length == _oldlength - 1) ? true : false;
	}

	function add(address[] storage _array, address _address) internal returns (bool) {
		uint256 _oldlength = _array.length;
		// Check exists
		bool _existed = false;
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_existed = true;
				break;
			}
		}
		// Add
		if (_existed == false) _array.push(_address);
		// Confirm add
		return ((_array.length == _oldlength + 1) && _array[_array.length - 1] == _address) ? true : false;
	}
}

library Uint256Array {
	function RemoveValue(uint256[] storage _Array, uint256 _Value) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		// Move the last element into the place to delete
		for (uint256 i = 0; i < _Array.length; i++) {
			if (_Array[i] == _Value) {
				_Array[i] = _Array[_Array.length - 1];
				break;
			}
		}
		// Remove
		_Array.pop();
	}

	function RemoveIndex(uint256[] storage _Array, uint256 _Index) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		require(_Array.length > _Index, "Index out of range");
		// Move the last element into the place to delete
		_Array[_Index] = _Array[_Array.length - 1];
		// Remove
		_Array.pop();
	}

	function TrimRight(uint256[] memory _Array) internal view returns (uint256[] memory _Return) {
		uint256 count;
		for (uint256 i = 0; i < _Array.length; i++) {
			if (_Array[i] != 0) count++;
			else break;
		}
		uint256[] memory temp = new uint256[](count);
		for (uint256 j = 0; j < count; j++) {
			temp[j] = _Array[j];
		}
		return temp;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";

struct TreeView {
	uint256 AccountID; // Is NodeID
	uint256 UplineID;
	uint8 SponsorLevel; // Is SL
}

library SmartMatrix {
	using Uint256Array for uint256[];

	struct Matrixer {
		uint256 UplineID;
		uint256 LimitedLegs; // 2 or 3, 0 = no limit
		uint256[] Line1IDs; // List of F1 IDs. Line1IDs.length <= LimitedLegs
		// Info in matrix
		uint256[] PathToRoot;
		uint256 LineOfRoot; // is line number in matrix root. = PathToRoot.length
		uint256[] PathToSponsor;
		uint256 LineOfSponsor; // is line number in matrix sponsor. = PathToSponsor.length
	}

	// struct Matrixes {
	// 	Matrixer Unilevel; // Sun tree
	// 	Matrixer Binary; // 2 leg tree
	// 	Matrixer Ternary; // 3 leg tree
	// }

	struct Node {
		uint256 NodeID; // Is AccountID
		uint256 SponsorID;
		uint8 SL; // Sponsor level (X3 Program level)
		// Matrixes Matrix;
		// Matrixer[3] Matrix; // Unilevel, Binary, Ternary
		mapping(uint8 => Matrixer) Matrix;
	}

	function InitializeMatrixesBeforeStarting(
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint256 _StartingAt
	) internal returns (uint256 _RootNode) {
		uint8 Unilevel = 1; // 0;
		uint8 Binary = 2; // 1;
		uint8 Ternary = 3; // 2;

		_Nodes[_StartingAt].Matrix[Unilevel] = Matrixer({
			UplineID: 0,
			LimitedLegs: type(uint256).max,
			Line1IDs: new uint256[](0),
			PathToRoot: new uint256[](0),
			LineOfRoot: 0,
			PathToSponsor: new uint256[](0),
			LineOfSponsor: 0
		});

		_Nodes[_StartingAt].Matrix[Binary] = Matrixer({
			UplineID: 0,
			LimitedLegs: 2,
			Line1IDs: new uint256[](0),
			PathToRoot: new uint256[](0),
			LineOfRoot: 0,
			PathToSponsor: new uint256[](0),
			LineOfSponsor: 0
		});

		_Nodes[_StartingAt].Matrix[Ternary] = Matrixer({
			UplineID: 0,
			LimitedLegs: 3,
			Line1IDs: new uint256[](0),
			PathToRoot: new uint256[](0),
			LineOfRoot: 0,
			PathToSponsor: new uint256[](0),
			LineOfSponsor: 0
		});

		_Nodes[_StartingAt].NodeID = _StartingAt;
		_Nodes[_StartingAt].SponsorID = 0;
		_Nodes[_StartingAt].SL = 15;
		_RootNode = _Nodes[_StartingAt].NodeID;
	}

	// Initialize new node to three matrix: Unilevel, Binary & Ternary
	function InitNewNodeToMatrixes(Node storage _Node, mapping(uint256 => SmartMatrix.Node) storage _Nodes) internal {
		uint8 Unilevel = 1; // Unilevel matrix (Sun)
		uint8 Binary = 2; // Binary marix (Tow leg)
		uint8 Ternary = 3; // Ternary matrix (Three leg)

		// Add new node to Unilevel Matrix (Sponsor Matrix)
		_Node.Matrix[Unilevel] = Matrixer({
			UplineID: _Node.SponsorID,
			LimitedLegs: type(uint256).max,
			Line1IDs: new uint256[](0),
			PathToRoot: _Nodes[_Node.SponsorID].Matrix[Unilevel].PathToRoot, //.push(_Node.SponsorID),
			LineOfRoot: _Nodes[_Node.SponsorID].Matrix[Unilevel].LineOfRoot + 1,
			PathToSponsor: new uint256[](0),
			LineOfSponsor: 1
		});
		_Node.Matrix[Unilevel].PathToRoot.push(_Node.SponsorID);
		_Node.Matrix[Unilevel].PathToSponsor.push(_Node.SponsorID);
		_Nodes[_Node.SponsorID].Matrix[Unilevel].Line1IDs.push(_Node.NodeID); // Update upline node

		// Find lower node on shortest leg of soponsor node in Binary matrix
		uint256 binarylowernodeid = FindLowerNodeOnShortestLegInSponsorNode(_Node, _Nodes, Binary);
		// Add new node to Binary Matrix
		_Node.Matrix[Binary] = Matrixer({
			UplineID: binarylowernodeid,
			LimitedLegs: 2,
			Line1IDs: new uint256[](0),
			PathToRoot: _Nodes[binarylowernodeid].Matrix[Binary].PathToRoot, //.push(binarylowernodeid),
			LineOfRoot: _Nodes[binarylowernodeid].Matrix[Binary].LineOfRoot + 1,
			PathToSponsor: _Nodes[binarylowernodeid].Matrix[Binary].PathToSponsor, //.push(binarylowernodeid),
			LineOfSponsor: _Nodes[binarylowernodeid].Matrix[Binary].LineOfSponsor + 1
		});
		_Node.Matrix[Binary].PathToRoot.push(binarylowernodeid);
		_Node.Matrix[Binary].PathToSponsor.push(binarylowernodeid);
		_Nodes[binarylowernodeid].Matrix[Binary].Line1IDs.push(_Node.NodeID); // Update upline node

		// Find lower node on shortest leg of soponsor node in Ternary matrix
		uint256 ternarylowernodeid = FindLowerNodeOnShortestLegInSponsorNode(_Node, _Nodes, Ternary);
		// Add new node to Ternary Matrix
		_Node.Matrix[Ternary] = Matrixer({
			UplineID: ternarylowernodeid,
			LimitedLegs: 3,
			Line1IDs: new uint256[](0),
			PathToRoot: _Nodes[ternarylowernodeid].Matrix[Ternary].PathToRoot, //.push(ternarylowernodeid),
			LineOfRoot: _Nodes[ternarylowernodeid].Matrix[Ternary].LineOfRoot + 1,
			PathToSponsor: _Nodes[ternarylowernodeid].Matrix[Ternary].PathToSponsor, //.push(ternarylowernodeid),
			LineOfSponsor: _Nodes[ternarylowernodeid].Matrix[Ternary].LineOfSponsor + 1
		});
		_Node.Matrix[Ternary].PathToRoot.push(ternarylowernodeid);
		_Node.Matrix[Ternary].PathToSponsor.push(ternarylowernodeid);
		_Nodes[ternarylowernodeid].Matrix[Ternary].Line1IDs.push(_Node.NodeID); // Update upline node

		// Update upline nodes
		_Node.SL = 1; // SL1
		UpdateSponsorLevel(_Node, _Nodes);
	}

	function UpdateSponsorLevel(Node storage _Node, mapping(uint256 => SmartMatrix.Node) storage _Nodes) internal {
		uint8 Unilevel = 1; // Unilevel matrix (Sponsor matrix)

		if (_Node.Matrix[Unilevel].LineOfSponsor > 3)
			if (_Nodes[_Node.SponsorID].SL == 1 && _Nodes[_Node.SponsorID].Matrix[Unilevel].Line1IDs.length == 2) {
				_Nodes[_Node.SponsorID].SL = 2; // sponsor1 is SL1 become to SL2

				uint256 sponsor2 = _Nodes[_Node.SponsorID].SponsorID;
				uint256 sponsor3 = _Nodes[sponsor2].SponsorID;
				uint256 sponsor4 = _Nodes[sponsor3].SponsorID;

				if (_Nodes[sponsor2].SL < 5 && _Nodes[_Node.SponsorID].Matrix[Unilevel].Line1IDs.length >= 3) {
					_Nodes[sponsor2].SL += 1; // sponsor2 is SL2 (or 3,4) become to: SL3 (or 4,5)

					// sponsor3 is not max and have more than 10 F1
					if (
						_Nodes[sponsor2].SL == 5 &&
						_Nodes[sponsor3].SL < 15 &&
						_Nodes[sponsor3].Matrix[Unilevel].Line1IDs.length >= 10
					) {
						uint8 line1sl5count = 0;
						for (uint256 i = 0; i < _Nodes[sponsor3].Matrix[Unilevel].Line1IDs.length; i++) {
							if (_Nodes[_Nodes[sponsor3].Matrix[Unilevel].Line1IDs[i]].SL >= 5) {
								line1sl5count += 1;
								if (line1sl5count >= 10) {
									_Nodes[sponsor3].SL = 15; // has 10 F1.SL >= 5
									break;
								}
							}
						}
					}
				}

				if (
					_Nodes[sponsor3].SL >= 5 && _Nodes[sponsor3].SL < 14 && _Nodes[sponsor3].Matrix[Unilevel].Line1IDs.length >= 3
				) {
					_Nodes[sponsor3].SL += 1; // sponsor3 is SL5 (or 6-13) become to: SL6 (or 7-14)
				}

				// sponsor4 is not max
				if (_Nodes[sponsor4].SL < 15 && _Nodes[sponsor4].Matrix[Unilevel].Line1IDs.length >= 3) {
					uint256 line3sl2count;
					for (uint256 i = 0; i < _Nodes[sponsor4].Matrix[Unilevel].Line1IDs.length; i++)
						// F1 i
						for (
							uint256 j;
							j < _Nodes[_Nodes[sponsor4].Matrix[Unilevel].Line1IDs[i]].Matrix[Unilevel].Line1IDs.length;
							j++
						)
							// F2 j of F1 i
							for (
								uint256 k = 0;
								k <
								_Nodes[_Nodes[_Nodes[sponsor4].Matrix[Unilevel].Line1IDs[i]].Matrix[Unilevel].Line1IDs[j]]
									.Matrix[Unilevel]
									.Line1IDs
									.length;
								k++
							)
								// F3 k of F2 j of F1 i
								if (
									_Nodes[
										_Nodes[_Nodes[_Nodes[sponsor4].Matrix[1].Line1IDs[i]].Matrix[1].Line1IDs[j]]
											.Matrix[Unilevel]
											.Line1IDs[k]
									].SL >= 2
								) {
									line3sl2count += 1;
									if (line3sl2count >= 27) {
										_Nodes[sponsor4].SL = 15; // has 27 F3.SL >= 2
										break;
									}
								}
				}
			}
	}

	// Find lower node in matrix including the sponsor node
	function FindLowerNodeOnShortestLegInSponsorNode(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix
	) internal view returns (uint256 _LowerNodeID) {
		Node storage sponsornode = _Nodes[_Node.SponsorID];
		_LowerNodeID = FindLowerNodeIDOnShortestLegInNode(sponsornode, _Nodes, _Matrix);
	}

	// Find lower node in matrix including node
	function FindLowerNodeIDOnShortestLegInNode(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix
	) internal view returns (uint256 _LowerNodeID) {
		(uint256[] memory nodeids /* uint256 _NodeCount */, ) = SelectAllChildrenNodeIDInNode(_Node, _Nodes, _Matrix);

		uint256[] memory temp = new uint256[](0);
		// Find the node are not enough leg. Line1IDs.length < LimitedLegs
		for (uint256 i = 0; i < nodeids.length; i++) {
			if (_Nodes[nodeids[i]].Matrix[_Matrix].Line1IDs.length < _Nodes[nodeids[i]].Matrix[_Matrix].LimitedLegs)
				temp[temp.length] = nodeids[i];
		}
		nodeids = temp; // nodes are not enough leg
		temp = new uint256[](0);
		// Find the nodes on shortest leg
		uint256 shortest = type(uint256).max;
		for (uint256 i = 0; i < nodeids.length; i++) {
			if (_Nodes[nodeids[i]].Matrix[_Matrix].LineOfSponsor < shortest) {
				shortest = _Nodes[nodeids[i]].Matrix[_Matrix].LineOfSponsor;
				temp = new uint256[](0);
				temp[0] = nodeids[i];
				continue;
			}
			if (_Nodes[nodeids[i]].Matrix[_Matrix].LineOfSponsor == shortest) temp[temp.length] = nodeids[i];
		}
		// If more than 1 node, take the leftmost
		_LowerNodeID = temp[0];
	}

	// Select all nodes in the sponsor node including the sponsor node in Matrix
	function SelectAllChildrenNodeIDInSponsorNode(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix
	) internal view returns (uint256[] memory _NodeIDs) {
		Node storage sponsornode = _Nodes[_Node.SponsorID];
		(_NodeIDs /* _NodeCount */, ) = SelectAllChildrenNodeIDInNode(sponsornode, _Nodes, _Matrix);
	}

	// Select all children nodes in this node including this node in Matrix
	function SelectAllChildrenNodeIDInNode(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix
	) internal view returns (uint256[] memory _NodeIDs, uint256 _NodeCount) {
		uint256 _MEMORY_LENGTH = 100;
		uint256[] memory a = new uint256[](_MEMORY_LENGTH);

		a[0] = _Node.NodeID;
		a[1] = 2;
		_NodeIDs = a;

		// uint256[] memory temp1 = new uint256[](0);
		// temp1 = _NodeIDs;
		// // Select all children node in node
		// while (temp1.length > 0) {
		// 	uint256[] memory temp2 = new uint256[](0);
		// 	for (uint256 i = 0; i < temp1.length; i++) {
		// 		if (_Nodes[temp1[i]].Matrix[_Matrix].Line1IDs.length > 0) {
		// 			// If F1 existed
		// 			for (uint256 j = 0; j < _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs.length; j++) {
		// 				_NodeIDs[_NodeIDs.length] = _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs[j];
		// 				temp2[temp2.length] = _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs[j];
		// 			}
		// 		}
		// 	}
		// 	temp1 = temp2; // End while when temp2.length = 0
		// }

		_NodeCount = a.length;
	}

	function SelectAllChildrenNodeIDInNodeTest(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix,
		uint256 _Length
	) internal view returns (uint256[] memory _NodeIDs, uint256 _NodeCount) {
		uint256 _MEMORY_LENGTH = 100;
		uint256[] memory a = new uint256[](_Length);

		a[0] = _Node.NodeID;
		a[1] = 2;
		_NodeIDs = a;

		// uint256[] memory temp1 = new uint256[](0);
		// temp1 = _NodeIDs;
		// // Select all children node in node
		// while (temp1.length > 0) {
		// 	uint256[] memory temp2 = new uint256[](0);
		// 	for (uint256 i = 0; i < temp1.length; i++) {
		// 		if (_Nodes[temp1[i]].Matrix[_Matrix].Line1IDs.length > 0) {
		// 			// If F1 existed
		// 			for (uint256 j = 0; j < _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs.length; j++) {
		// 				_NodeIDs[_NodeIDs.length] = _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs[j];
		// 				temp2[temp2.length] = _Nodes[temp1[i]].Matrix[_Matrix].Line1IDs[j];
		// 			}
		// 		}
		// 	}
		// 	temp1 = temp2; // End while when temp2.length = 0
		// }

		_NodeCount = a.length;
	}

	// Select to Front end
	function SelectAllChildrenNodeIDInNodeReturnTreeviewToFrontend(
		Node storage _Node,
		mapping(uint256 => SmartMatrix.Node) storage _Nodes,
		uint8 _Matrix
	) internal view returns (TreeView[] memory _Treeview) {
		uint256[] memory NodeIDs = new uint256[](0);
		uint256 NodeCount;
		(NodeIDs, NodeCount) = SelectAllChildrenNodeIDInNode(_Node, _Nodes, _Matrix);
		for (uint256 i = 0; i < NodeCount; i++) {
			_Treeview[i] = TreeView({
				AccountID: _Nodes[NodeIDs[i]].NodeID,
				UplineID: _Nodes[NodeIDs[i]].Matrix[_Matrix].UplineID,
				SponsorLevel: _Nodes[NodeIDs[i]].SL
			});
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library SmartProgram {
	struct XProgramer {
		// Cycle info
		uint256 UplineID; // Current upline ID in current cycle
		uint RecycleCount; // Number of recycle
		// Level info
		uint256 PriceOfLevel; // 1$ - 50k$
		bool Actived; // Is the level activated or not
		uint8 MaxClaimCount; // ??? Number of times the account can claim at current level, if the next level is not activated
	}

	struct X3Program {
		uint256[3] Line1; // 3 AccountIDs, limit the number of positions in the line
		XProgramer Info; // Information of level and current cycle on each specific level
	}

	struct X6Program {
		uint256[2] Line1;
		uint256[4] Line2;
		XProgramer Info;
	}

	struct X7Program {
		uint256[2] Line1;
		uint256[4] Line2;
		uint256[8] Line3;
		XProgramer Info;
	}

	struct X8Program {
		uint256[3] Line1;
		uint256[9] Line2;
		XProgramer Info;
	}

	struct X9Program {
		uint256[3] Line1;
		uint256[9] Line2;
		uint256[27] Line3;
		XProgramer Info;
	}

	struct XProgram {
		uint256 XProgramID; // Is AccountID
		mapping(uint8 => X3Program) X3; // Level 0: Promo 1$, Level 1: 5$ - default pirce of each Xprogram
		// Each account can have 60 active cycles at the same time
		mapping(uint8 => X6Program) X6; // Level 0: Promo 1$, Level 1-15: level of each Xprogram
		mapping(uint8 => X7Program) X7;
		mapping(uint8 => X8Program) X8;
		mapping(uint8 => X9Program) X9;
	}

	function InitXprogram(XProgram storage _XProgram, uint256[16] storage _PirceOfLevel) internal {
		for (uint8 i = 0; i <= 15; i++) {
			// Initialize level pirce of each level
			_XProgram.X3[i].Info.PriceOfLevel = _PirceOfLevel[i];
			_XProgram.X6[i].Info.PriceOfLevel = _PirceOfLevel[i];
			_XProgram.X7[i].Info.PriceOfLevel = _PirceOfLevel[i];
			_XProgram.X8[i].Info.PriceOfLevel = _PirceOfLevel[i];
			_XProgram.X9[i].Info.PriceOfLevel = _PirceOfLevel[i];
		}
	}

	// Select X3 program return to array
	function SelectX3Programs(XProgram storage _XProgram) internal view returns (X3Program[] memory _X3Programs) {
		for (uint8 i = 0; i <= 1; i++) {
			_X3Programs[i] = _XProgram.X3[i];
		}
	}

	function SelectX6Programs(XProgram storage _XProgram) internal view returns (X6Program[] memory _X6Programs) {
		for (uint8 i = 0; i <= 15; i++) {
			_X6Programs[i] = _XProgram.X6[i];
		}
	}

	function SelectX7Programs(XProgram storage _XProgram) internal view returns (X7Program[] memory _X7Programs) {
		for (uint8 i = 0; i <= 15; i++) {
			_X7Programs[i] = _XProgram.X7[i];
		}
	}

	function SelectX8Programs(XProgram storage _XProgram) internal view returns (X8Program[] memory _X8Programs) {
		for (uint8 i = 0; i <= 15; i++) {
			_X8Programs[i] = _XProgram.X8[i];
		}
	}

	function SelectX9Programs(XProgram storage _XProgram) internal view returns (X9Program[] memory _X9Programs) {
		for (uint8 i = 0; i <= 15; i++) {
			_X9Programs[i] = _XProgram.X9[i];
		}
	}

	// X3 program recycle, renew all positions for new cycle
	function X3Recycle(X3Program storage _X3Program, uint256 _NewUplineID) internal {
		_X3Program.Line1 = [0, 0, 0];
		_X3Program.Info.UplineID = _NewUplineID; // Upline has higher sponsor level on Unilevel matrix (Sponsor matrix)
		_X3Program.Info.RecycleCount += 1;
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./SmartMatrix.sol";
import "./SmartProgram.sol";
import "./Library.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract TuktuBase {
	// Pirce of level in each xprogram. 0: Promo, 1-15: level pirce
	uint256[16] public PirceOfLevel = [
		1e18,
		5e18,
		10e18,
		20e18,
		40e18,
		80e18,
		160e18,
		320e18,
		640e18,
		1250e18,
		2500e18,
		5000e18,
		10000e18,
		20000e18,
		30000e18,
		50000e18
	];

	using Address for address;

	using SmartMatrix for SmartMatrix.Node;
	using SmartProgram for SmartProgram.XProgram;
	using SmartProgram for SmartProgram.X3Program;
	using SmartProgram for SmartProgram.X6Program;
	using SmartProgram for SmartProgram.X7Program;
	using SmartProgram for SmartProgram.X8Program;
	using SmartProgram for SmartProgram.X9Program;

	struct Account {
		uint256 AccountID;
		bytes10 Affiliate; // For share link. User can modify
		address Address; // ERC20 address of User
		// Config
		uint256 RegTime; // Registration date
		bool AutoNextLevel;
		// Ext
		uint256 Level; // Level of project (Ex: Silver, Gold, Emeral,...)
		bool Active; // User's status in project
		uint256 LastActiveTime; // Last activation date
	}

	uint256 private _RootNode;
	uint256 private _numAccount; // Total account number
	mapping(bytes10 => uint256) Affiliates; // To AccountID. Affiliates is used as AccountID
	mapping(uint256 => Account) Accounts; // AccountID to account info
	mapping(uint256 => SmartMatrix.Node) Nodes; // AccountID to node info
	mapping(uint256 => SmartProgram.XProgram) XPrograms;

	constructor(uint256 _StartingAt) {
		_RootNode = SmartMatrix.InitializeMatrixesBeforeStarting(Nodes, _StartingAt);

		Accounts[_RootNode].AccountID = _RootNode;
		Accounts[_RootNode].Affiliate = bytes10(bytes("Affiliate"));
		Accounts[_RootNode].Address = msg.sender;
		Accounts[_RootNode].RegTime = block.timestamp;
		Accounts[_RootNode].AutoNextLevel = true;

		XPrograms[_RootNode].XProgramID = _RootNode;
		XPrograms[_RootNode].InitXprogram(PirceOfLevel);

		Affiliates[bytes10(bytes("Affiliate"))] = _RootNode;
	}

	function _registration(address _NewAccountAddress) internal {
		uint8 Ternary = 2;
		uint256 _SponsorID = Nodes[_RootNode].FindLowerNodeIDOnShortestLegInNode(Nodes, Ternary);
		_registration(_NewAccountAddress, _SponsorID);
	}

	function _registration(address _NewAccountAddress, uint256 _SponsorID) internal {
		uint256 NewAccountID = _GetNewAccountID();
		bytes10 NewAffiliate = _GetNewAffiliate();
		_registration(NewAccountID, NewAffiliate, _NewAccountAddress, _SponsorID);
	}

	function _registration(
		uint256 NewAccountID,
		bytes10 NewAffiliate,
		address _NewAccountAddress,
		uint256 _SponsorID
	) internal {
		require(_NewAccountAddress.isContract() == false, "Registration: can not contract");
		require(_SponsorID != 0, "Registration: sponsorid can not zezo");

		Affiliates[NewAffiliate] = NewAccountID;

		// Init new account
		Accounts[NewAccountID].AccountID = NewAccountID;
		Accounts[NewAccountID].Affiliate = NewAffiliate;
		Accounts[NewAccountID].Address = _NewAccountAddress;
		Accounts[NewAccountID].RegTime = block.timestamp;
		Accounts[NewAccountID].AutoNextLevel = true;

		// Init new node on matrixes (Three matrix: Unilevel, Binary & Ternary)
		Nodes[NewAccountID].NodeID = NewAccountID;
		Nodes[NewAccountID].SponsorID = _SponsorID;
		Nodes[NewAccountID].InitNewNodeToMatrixes(Nodes);

		// Init all XProgram
		XPrograms[NewAccountID].XProgramID = NewAccountID;
		XPrograms[NewAccountID].InitXprogram(PirceOfLevel);
		// XPrograms[NewAccountID].X3[0].CheckActived();
	}

	function _GetNewAffiliate() internal view returns (bytes10 Affiliate) {
		uint i;
		while (true) {
			Affiliate = bytes10(keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, i++)));
			if (Affiliates[Affiliate] == 0) return Affiliate;
		}
	}

	function _GetNewAccountID() internal returns (uint256 NewAccountID) {
		while (true) {
			unchecked {
				_numAccount += 1;
				if (Accounts[_numAccount].AccountID == 0) return _numAccount;
			}
		}
	}

	function _ChangeAddress(uint256 _AccountID, address _NewAddress) internal {
		Accounts[_AccountID].Address = _NewAddress;
	}

	function _ChangeAffiliate(uint256 _AccountID, bytes10 _NewAffiliate) internal {
		bytes10 oldaffiliate = Accounts[_AccountID].Affiliate;
		require(
			keccak256(abi.encodePacked(oldaffiliate)) != keccak256(abi.encodePacked(_NewAffiliate)),
			"Affiliate: new like old"
		);
		require(Affiliates[_NewAffiliate] == 0 && Affiliates[oldaffiliate] != 0, "Affiliate: does not existed");

		Accounts[_AccountID].Affiliate = _NewAffiliate;
		Affiliates[_NewAffiliate] = _AccountID;
		Affiliates[oldaffiliate] = 0;
	}

	// Return a list of account id of Address
	function _GetAccountIDOfAddress(address _address) internal view returns (uint256[] memory _AccountIDs) {
		for (uint256 i = 0; i <= _numAccount; i++) if (Accounts[i].Address == _address) _AccountIDs[_AccountIDs.length] = i;
	}

	// Return a account id LATEST of Address
	function _GetAccountIDLatestOfAddress(address _address) internal view returns (uint256 _AccountID) {
		uint256[] memory _AccountIDs = _GetAccountIDOfAddress(_address);
		if (_AccountIDs.length > 0) {
			_AccountID = _AccountIDs[0];
			for (uint256 i = 1; i < _AccountIDs.length; i++) {
				if (Accounts[_AccountIDs[i]].RegTime > Accounts[_AccountID].RegTime) _AccountID = _AccountIDs[i];
			}
		} else return 0;
	}

	function _SelectAllChildrenNodesOfAccountOnMatrix(
		uint256 _AccountID,
		uint8 _Matrix
	) internal view returns (TreeView[] memory _Treeview) {
		_Treeview = Nodes[_AccountID].SelectAllChildrenNodeIDInNodeReturnTreeviewToFrontend(Nodes, _Matrix);
	}
}

interface ITuktu {}

contract Tuktu is TuktuBase, ITuktu {
	using Uint256Array for uint256[];

	constructor(uint256 _StartingAt) TuktuBase(_StartingAt) {}

	// ----------------------------------------------------------------------
	// Add some node for testnet
	function Test(uint256 number) public {
		for (uint8 i = 0; i < number; i++) _registration(msg.sender);
	}

	function TestViewAccount(uint256 _AccountID) public view returns (Account memory _Account) {
		_Account = Accounts[_AccountID];
	}

	function TestSelectAllNode(
		uint256 _NodeID,
		uint8 _Matrix
	) public view returns (uint256[] memory _NodeIDs, uint256 _NodeCount, uint256[] memory _Test, uint256 _TestLength, uint256 _Length) {
		(_NodeIDs, _NodeCount) = SmartMatrix.SelectAllChildrenNodeIDInNodeTest(Nodes[_NodeID], Nodes, _Matrix, _Length);
		_Test = _NodeIDs.TrimRight();
		_TestLength = _Test.length;
	}

	struct NodeTest {
		uint256 NodeID; // Is AccountID
		uint256 SponsorID;
		uint8 SL;
	}

	function TestViewNode(uint256 _NodeID) public view returns (NodeTest memory _Node) {
		_Node = NodeTest({ NodeID: Nodes[_NodeID].NodeID, SponsorID: Nodes[_NodeID].SponsorID, SL: Nodes[_NodeID].SL });
	}

	function TestViewMatrixer(
		uint256 _NodeID,
		uint8 _Matrix
	) public view returns (SmartMatrix.Matrixer memory _Matrixer) {
		_Matrixer = Nodes[_NodeID].Matrix[_Matrix];
	}

	function TestViewAffiliate(uint256 _AccountID) public view returns (string memory _Affiliate) {
		_Affiliate = string(abi.encode(Accounts[_AccountID].Affiliate));
	}

	function SelectOnMatrix(uint256 _AccountID, uint8 _Matrix) public view returns (TreeView[] memory _TernaryTreeview) {
		require(_AccountID != 0 && Nodes[_AccountID].NodeID == _AccountID, "_AccountID dose not existed");
		_TernaryTreeview = _SelectAllChildrenNodesOfAccountOnMatrix(_AccountID, _Matrix);
	}

	// ----------------------------------------------------------------------

	modifier onlyAccountOwner(uint256 _AccountID) {
		require(Accounts[_AccountID].Address == msg.sender, "Account: caller is not the owner");
		_;
	}

	fallback() external {}

	receive() external payable {}

	// Registration
	function Registration() public {
		_registration(msg.sender);
	}

	function Registration(string memory _Affiliate) public {
		bytes10 AffiliateRef = bytes10(bytes(_Affiliate));
		(Affiliates[AffiliateRef] != 0 && Affiliates[AffiliateRef] == Accounts[Affiliates[AffiliateRef]].AccountID)
			? _registration(msg.sender, Affiliates[AffiliateRef])
			: _registration(msg.sender);
	}

	function Registration(uint256 _SponsorID) public {
		(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID)
			? _registration(msg.sender, _SponsorID)
			: _registration(msg.sender);
	}

	function Registration(address _AddressOfSponsor) public {
		require(_AddressOfSponsor != address(0), "Registration: can not address(0)");
		uint256 latestaccountid = _GetAccountIDLatestOfAddress(_AddressOfSponsor);
		latestaccountid != 0 ? _registration(msg.sender, latestaccountid) : _registration(msg.sender);
	}

	function Registration(address _AddressOfNewAccount, uint256 _SponsorID) public {
		require(_AddressOfNewAccount != address(0), "Registration: can not address(0)");
		(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID)
			? _registration(_AddressOfNewAccount, _SponsorID)
			: _registration(_AddressOfNewAccount);
	}

	// Config
	function ChangeAffiliate(uint256 _AccountID, string memory _NewAffiliate) public onlyAccountOwner(_AccountID) {
		bytes10 AffiliateNew = bytes10(bytes(_NewAffiliate));
		require(AffiliateNew.length != 0, "ChangeAffiliate: can not empty");
		_ChangeAffiliate(_AccountID, AffiliateNew);
	}

	function ChangeAddress(uint256 _AccountID, address _NewAddress) public onlyAccountOwner(_AccountID) {
		require(_NewAddress != address(0), "ChangeAddress: can not zezo address");
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID);
		_ChangeAddress(_AccountID, _NewAddress);
	}

	// Tree view
	function SelectAllChildrenAccountOfAccountOnUnilevelMatrix(
		uint256 _AccountID
	) public view onlyAccountOwner(_AccountID) returns (TreeView[] memory _UnilevelTreeview) {
		require(_AccountID != 0 && Nodes[_AccountID].NodeID == _AccountID, "_AccountID dose not existed");
		uint8 Unilevel = 1; // Unilevel Matrix (Sun)
		_UnilevelTreeview = _SelectAllChildrenNodesOfAccountOnMatrix(_AccountID, Unilevel);
	}

	function SelectAllChildrenAccountOfAccountOnBinaryMatrix(
		uint256 _AccountID
	) public view onlyAccountOwner(_AccountID) returns (TreeView[] memory _BinaryTreeview) {
		require(_AccountID != 0 && Nodes[_AccountID].NodeID == _AccountID, "_AccountID dose not existed");
		uint8 Binary = 2; // Binary marix (Tow leg)
		_BinaryTreeview = _SelectAllChildrenNodesOfAccountOnMatrix(_AccountID, Binary);
	}

	function SelectAllChildrenAccountOfAccountOnTernaryMatrix(
		uint256 _AccountID
	) public view onlyAccountOwner(_AccountID) returns (TreeView[] memory _TernaryTreeview) {
		require(_AccountID != 0 && Nodes[_AccountID].NodeID == _AccountID, "_AccountID dose not existed");
		uint8 Ternary = 3; // Ternary matrix (Three leg)
		_TernaryTreeview = _SelectAllChildrenNodesOfAccountOnMatrix(_AccountID, Ternary);
	}

	// Dashboard
	function AccountOfAddress(address _address) public view returns (uint256[] memory _AccountIDs) {
		require(_address != address(0), "Dashboard: can not zezo address");
		_AccountIDs = _GetAccountIDOfAddress(_address);
	}
}