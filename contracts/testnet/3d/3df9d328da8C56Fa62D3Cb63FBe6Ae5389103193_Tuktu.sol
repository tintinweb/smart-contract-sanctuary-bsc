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
pragma solidity >=0.8.0 <0.9.0;

uint8 constant UNILEVEL = 1; // Unilevel matrix (Sun, unlimited leg)
uint8 constant BINARY = 2; // Binary marix - Tow leg
uint8 constant TERNARY = 3; // Ternary matrix - Three leg

library Algorithms {
	// Factorial x! - Use recursion
	function Factorial(uint256 _x) internal pure returns (uint256 _r) {
		if (_x == 0) return 1;
		else return _x * Factorial(_x - 1);
	}

	// Exponentiation x^y - Algorithm: "exponentiation by squaring".
	function Exponential(uint256 _x, uint256 _y) internal pure returns (uint256 _r) {
		// Calculate the first iteration of the loop in advance.
		uint256 result = _y & 1 > 0 ? _x : 1;
		// Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
		for (_y >>= 1; _y > 0; _y >>= 1) {
			_x = MulDiv18(_x, _x);
			// Equivalent to "y % 2 == 1" but faster.
			if (_y & 1 > 0) {
				result = MulDiv18(result, _x);
			}
		}
		_r = result;
	}

	// https://github.com/paulrberg/prb-math
	// @notice Emitted when the ending result in the fixed-point version of `mulDiv` would overflow uint256.
	error MulDiv18Overflow(uint256 x, uint256 y);

	function MulDiv18(uint256 x, uint256 y) internal pure returns (uint256 result) {
		// How many trailing decimals can be represented.
		uint256 UNIT = 1e18;
		// Largest power of two that is a divisor of `UNIT`.
		uint256 UNIT_LPOTD = 262144;
		// The `UNIT` number inverted mod 2^256.
		uint256 UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

		uint256 prod0;
		uint256 prod1;

		assembly {
			let mm := mulmod(x, y, not(0))
			prod0 := mul(x, y)
			prod1 := sub(sub(mm, prod0), lt(mm, prod0))
		}
		if (prod1 >= UNIT) {
			revert MulDiv18Overflow(x, y);
		}
		uint256 remainder;
		assembly {
			remainder := mulmod(x, y, UNIT)
		}
		if (prod1 == 0) {
			unchecked {
				return prod0 / UNIT;
			}
		}
		assembly {
			result := mul(
				or(
					div(sub(prod0, remainder), UNIT_LPOTD),
					mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
				),
				UNIT_INVERSE
			)
		}
	}
}

library AffiliateCreator {
	// https://stackoverflow.com/questions/67893318/solidity-how-to-represent-bytes32-as-string
	function ToHex16(bytes16 data) internal pure returns (bytes32 result) {
		result =
			(bytes32(data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
			((bytes32(data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64);
		result =
			(result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
			((result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32);
		result =
			(result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
			((result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16);
		result =
			(result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
			((result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8);
		result =
			((result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4) |
			((result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8);
		result = bytes32(
			0x3030303030303030303030303030303030303030303030303030303030303030 +
				uint256(result) +
				(((uint256(result) + 0x0606060606060606060606060606060606060606060606060606060606060606) >> 4) &
					0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
				7
		);
	}

	function ToHex(bytes32 data) internal pure returns (string memory) {
		return string(abi.encodePacked("0x", ToHex16(bytes16(data)), ToHex16(bytes16(data << 128))));
	}

	function Creator(bytes32 _Bytes32, uint8 _len) internal pure returns (bytes16 _r) {
		string memory s = ToHex(_Bytes32);
		bytes memory b = bytes(s);
		bytes memory r = new bytes(_len);
		for (uint i = 0; i < _len; ++i) r[i] = b[i + 3];
		return bytes16(bytes(r));
	}
}

library AddressArray {
	function RemoveValue(address[] storage _Array, address _address) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		// Move the last element into the place to delete
		for (uint256 i = 0; i < _Array.length; ++i) {
			if (_Array[i] == _address) {
				_Array[i] = _Array[_Array.length - 1];
				break;
			}
		}
		_Array.pop();
	}

	function RemoveIndex(address[] storage _Array, uint64 _Index) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		require(_Array.length > _Index, "Index out of range");
		// Move the last element into the place to delete
		_Array[_Index] = _Array[_Array.length - 1];
		_Array.pop();
	}

	function AddNoDuplicate(address[] storage _Array, address _address) internal {
		for (uint256 i = 0; i < _Array.length; ++i) if (_Array[i] == _address) return;
		_Array.push(_address);
	}
}

library Uint32Array {
	function RemoveValue(uint32[] storage _Array, uint32 _Value) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		// Move the last element into the place to delete
		for (uint32 i = 0; i < _Array.length; ++i) {
			if (_Array[i] == _Value) {
				_Array[i] = _Array[_Array.length - 1];
				break;
			}
		}
		_Array.pop();
	}

	function RemoveIndex(uint32[] storage _Array, uint64 _Index) internal {
		require(_Array.length > 0, "Can't remove from empty array");
		require(_Array.length > _Index, "Index out of range");
		// Move the last element into the place to delete
		_Array[_Index] = _Array[_Array.length - 1];
		_Array.pop();
	}

	function AddNoDuplicate(uint32[] storage _Array, uint32 _Value) internal {
		for (uint32 i = 0; i < _Array.length; ++i) if (_Array[i] == _Value) return;
		_Array.push(_Value);
	}

	function TrimRight(uint32[] memory _Array) internal pure returns (uint32[] memory _Return) {
		require(_Array.length > 0, "Can't trim from empty array");
		uint32 count;
		for (uint32 i = 0; i < _Array.length; ++i) {
			if (_Array[i] != 0) count++;
			else break;
		}
		_Return = new uint32[](count);
		for (uint32 j = 0; j < count; ++j) {
			_Return[j] = _Array[j];
		}
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";
import "./TMatrix.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract TAccount is TMatrix {
	using Address for address;
	using Uint32Array for uint32[];
	using AffiliateCreator for bytes32;

	struct Account {
		uint32 AccountID;
		bytes16 Affiliate; // For share link. User can modify
		address Address; // Address only, One address can have multiple accounts
		uint32 RegTime; // Registration datetime
		bool AutoNextLevel;
		bool Stoped; // User can stop account and withdraw all
	}

	// uint32 private RootAccount;
	uint32 private numAccount; // Total account number
	mapping(uint32 => Account) Accounts; // AccountID to user info
	mapping(bytes16 => uint32) Affiliates; // To AccountID. Affiliates is used as AccountID
	mapping(address => uint32[]) AccountOf; // Accounts of address

	constructor(uint32 _Starting) TMatrix(_Starting) {
		InitializeAccount(_Starting);
	}

	function InitializeAccount(uint32 Starting) private {
		// RootAccount = Starting;
		Accounts[Starting] = Account({
			AccountID: Starting,
			Affiliate: bytes16(bytes("Affiliate")),
			Address: msg.sender,
			RegTime: uint32(block.timestamp),
			AutoNextLevel: true,
			Stoped: false
		});
		Affiliates[bytes16(bytes("Affiliate"))] = Starting;
		AccountOf[msg.sender].push(Starting);

		// XPrograms[_RootNode].XProgramID = _RootNode;
		// XPrograms[_RootNode].InitXprogram(PirceOfLevel);
	}

	function _registration(address _NewAccountAddress) internal {
		// Is lower node on shortest leg of root node in Ternary matrix
		uint32 sponsorid = FindSponsor();
		_registration(_NewAccountAddress, sponsorid);
	}

	function _registration(address _NewAccountAddress, uint32 _SponsorID) internal {
		uint32 NewAccountID = _AccountIDCreator();
		bytes16 NewAffiliate = _AffiliateCreator();
		_registration(NewAccountID, NewAffiliate, _NewAccountAddress, _SponsorID);
	}

	function _registration(
		uint32 _NewAccountID,
		bytes16 _NewAffiliate,
		address _NewAccountAddress,
		uint32 _SponsorID
	) internal {
		require(_NewAccountAddress.isContract() == false, "Registration: can not contract");

		// Init new account
		Accounts[_NewAccountID] = Account({
			AccountID: _NewAccountID,
			Affiliate: _NewAffiliate,
			Address: _NewAccountAddress,
			RegTime: uint32(block.timestamp),
			AutoNextLevel: true,
			Stoped: false
		});
		Affiliates[_NewAffiliate] = _NewAccountID;
		AccountOf[_NewAccountAddress].push(_NewAccountID);

		// Init new node on matrix (Three matrix: Unilevel, Binary & Ternary)
		InitNode(_NewAccountID, _SponsorID);

		// Init all XProgram
	}

	function _AffiliateCreator() internal view returns (bytes16 _Affiliate) {
		uint256 i;
		while (true) {
			_Affiliate = bytes32(keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, ++i))).Creator(8);
			if (Affiliates[_Affiliate] == 0) return _Affiliate;
		}
	}

	function _AccountIDCreator() internal returns (uint32 _NewAccountID) {
		while (true) {
			unchecked {
				++numAccount;
				if (Accounts[numAccount].AccountID == 0) return numAccount;
			}
		}
	}

	function _ChangeAddress(uint32 _AccountID, address _NewAddress) internal {
		Accounts[_AccountID].Address = _NewAddress;
		AccountOf[msg.sender].RemoveValue(_AccountID);
		AccountOf[_NewAddress].AddNoDuplicate(_AccountID);
	}

	function _ChangeAffiliate(uint32 _AccountID, bytes16 _NewAffiliate) internal {
		Affiliates[Accounts[_AccountID].Affiliate] = 0;
		Affiliates[_NewAffiliate] = _AccountID;
		Accounts[_AccountID].Affiliate = _NewAffiliate;
	}

	function _AccountsOf(address _address) internal view returns (uint32[] memory _AccountIDs) {
		return AccountOf[_address];
	}

	// Return a account id LATEST of Address
	function _GetLatestAccountsOf(address _address) internal view returns (uint32 _AccountID) {
		uint32[] memory accounts = _AccountsOf(_address);
		if (accounts.length > 0) {
			_AccountID = accounts[0];
			for (uint32 i = 1; i < accounts.length; ++i)
				if (Accounts[accounts[i]].RegTime > Accounts[_AccountID].RegTime) _AccountID = accounts[i];
		} else return 0;
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";

abstract contract TMatrix {
	using Uint32Array for uint32[];
	using Algorithms for uint32;

	struct ColumnsY {
		// Each position per RowsX (Line/Row of root)
		uint32 NodeID; // NodeID != 0 when this node is missing leg
		bool isMissingLeg; // If TRUE: This nodeID is not enough leg
	}

	struct RowsX {
		// Each line/Row of root
		mapping(uint32 => ColumnsY) Y; // Columns
		bool isFull; // Full or not full NodeIDs in each positions of Y
		uint32[] NodeIDsMissingLeg; // List of NodeIDs missing leg on this X.
		uint32 YExistedCount; // If YExistedCount == MaxYOfXCount then Y is FULL
	}

	mapping(uint8 => mapping(uint32 => RowsX)) MatrixStorage; // Unilevel, Binary, Ternary

	struct Info {
		uint32 UplineID;
		uint32[] X1IDs; // List of F1 IDs. X1IDs.length <= LIMITED_LEG
		uint32[] PathFromRoot; // X Of Root: is line number in matrix root, and = PathToRoot.length
		uint32[] PathToSponsor; // X Of Sponsor: is line number in matrix of sponsor, and = PathToSponsor.length
		uint32 Y;
		uint32 FullYToXOfRoot; // >= X Of Root
	}

	struct Node {
		uint32 NodeID;
		uint32 SponsorID;
		uint8 SL; // Sponsor level
		mapping(uint8 => Info) InfoOf; // Unilevel, Binary, Ternary
	}

	mapping(uint32 => Node) Nodes; // AccountID to node info
	uint32 private RootID;

	constructor(uint32 _Starting) {
		InitializeMatrix(_Starting);
	}

	function InitializeMatrix(uint32 _Starting) private {
		RootID = _Starting;
		Node storage newnode = Nodes[RootID];
		newnode.NodeID = RootID;
		newnode.SponsorID = 0;
		newnode.SL = 15;

		newnode.InfoOf[UNILEVEL] = Info({
			UplineID: 0,
			X1IDs: new uint32[](0),
			PathFromRoot: new uint32[](0),
			PathToSponsor: new uint32[](0),
			Y: 1,
			FullYToXOfRoot: 0
		});

		newnode.InfoOf[BINARY] = Info({
			UplineID: 0,
			X1IDs: new uint32[](0),
			PathFromRoot: new uint32[](0),
			PathToSponsor: new uint32[](0),
			Y: 1,
			FullYToXOfRoot: 0
		});
		MatrixStorage[BINARY][0].isFull = true;
		MatrixStorage[BINARY][0].YExistedCount = 1;
		MatrixStorage[BINARY][0].NodeIDsMissingLeg.push(newnode.NodeID);
		MatrixStorage[BINARY][0].Y[1] = ColumnsY({ NodeID: newnode.NodeID, isMissingLeg: true });

		newnode.InfoOf[TERNARY] = Info({
			UplineID: 0,
			X1IDs: new uint32[](0),
			PathFromRoot: new uint32[](0),
			PathToSponsor: new uint32[](0),
			Y: 1,
			FullYToXOfRoot: 0
		});
		MatrixStorage[TERNARY][0].YExistedCount = 1;
		MatrixStorage[TERNARY][0].isFull = true;
		MatrixStorage[TERNARY][0].NodeIDsMissingLeg.push(newnode.NodeID);
		MatrixStorage[TERNARY][0].Y[1] = ColumnsY({ NodeID: newnode.NodeID, isMissingLeg: true });
	}

	// Initialize new node to three matrix: Unilevel, Binary & Ternary
	function InitNode(uint32 _NodeID, uint32 _SponsorID) internal virtual {
		Node storage newnode = Nodes[_NodeID];
		newnode.NodeID = _NodeID;
		newnode.SponsorID = _SponsorID;
		newnode.SL = 1;

		// Add new node to Unilevel Matrix (Sponsor Matrix)
		newnode.InfoOf[UNILEVEL] = Info({
			UplineID: _SponsorID,
			X1IDs: new uint32[](0),
			PathFromRoot: Nodes[_SponsorID].InfoOf[UNILEVEL].PathFromRoot, //.push(_SponsorID),
			PathToSponsor: new uint32[](0), //.push(_SponsorID),
			Y: uint32(Nodes[_SponsorID].InfoOf[UNILEVEL].X1IDs.length + 1),
			FullYToXOfRoot: 0
		});
		newnode.InfoOf[UNILEVEL].PathFromRoot.push(_SponsorID);
		newnode.InfoOf[UNILEVEL].PathToSponsor.push(_SponsorID);
		Nodes[_SponsorID].InfoOf[UNILEVEL].X1IDs.push(_NodeID); // Update upline nodes

		// Update sponsor level for upline when node changes from SL1 to SL2
		if (Nodes[_SponsorID].InfoOf[UNILEVEL].X1IDs.length == 3) _UpdateSponsorLevelForUpline(newnode);

		// Initialize new node for Binary, Ternary matrix and update matrix storage
		_InitNode(newnode, BINARY);
		_InitNode(newnode, TERNARY);
	}

	function _InitNode(Node storage _newnode, uint8 _MATRIX) private {
		if (Nodes[_newnode.SponsorID].InfoOf[_MATRIX].X1IDs.length < _MATRIX) {
			// Sponsor not enougth leg (sponsor is a missing leg Node)
			_newnode.InfoOf[_MATRIX].UplineID = _newnode.SponsorID;
			_UpdateNodeAndMatrixStorage(_newnode, _MATRIX);
		} else {
			_newnode.InfoOf[_MATRIX].UplineID = _FindUplineID(_newnode, _MATRIX);
			_UpdateNodeAndMatrixStorage(_newnode, _MATRIX);
		}
	}

	// Is lower node on shortest leg of root node in Ternary matrix
	function FindSponsor() internal virtual returns (uint32 _SponsorID) {
		uint32 sfyx = Nodes[RootID].InfoOf[TERNARY].FullYToXOfRoot;
		do {
			++sfyx;
			if (MatrixStorage[TERNARY][sfyx].isFull) continue;
			_SponsorID = MatrixStorage[TERNARY][--sfyx].NodeIDsMissingLeg[0];
			if (sfyx > Nodes[RootID].InfoOf[TERNARY].FullYToXOfRoot) Nodes[RootID].InfoOf[TERNARY].FullYToXOfRoot = sfyx;
			break;
		} while (true);
	}

	// UplineID: Is lower node on shortest leg of soponsor node in matrix
	function _FindUplineID(Node storage _newnode, uint8 _MATRIX) private view returns (uint32 _UplineID) {
		uint32 sid = _newnode.SponsorID;
		uint32 sx = uint32(Nodes[sid].InfoOf[_MATRIX].PathFromRoot.length); // X Of Root;
		uint32 sfyx = Nodes[sid].InfoOf[_MATRIX].FullYToXOfRoot;
		uint32 sy = Nodes[sid].InfoOf[_MATRIX].Y;

		uint32 XCountFromSponsor; // Count row from Sponsor of _newnode
		uint32 MaxYOfXCount;
		uint32[2] memory RangeYOfXCountOnYRoot; // 0: min/begin pos, 1: max/end pos - On row of root
		uint32[] memory MissingLeg;
		uint32 MissingLegLength;

		XCountFromSponsor = sfyx - sx;
		sx = sfyx;

		do {
			++XCountFromSponsor; // Begin loop from row [XCountFromSponsor + 1], is row of sponsor
			++sx; // Begin loop from row [sx + 1], is rows of root

			if (MatrixStorage[_MATRIX][sx].isFull) continue; // Row in root is full

			// If row [sx] is not full, then row [sx - 1] has some node missing leg
			// Calculate sponsor Y posiotn range on row [sx - 1] of root (row [XCountFromSponsor + 1] of sponsor)
			MaxYOfXCount = uint32(Algorithms.Exponential(_MATRIX, XCountFromSponsor - 1)); // x^y
			MissingLegLength = uint32(MatrixStorage[_MATRIX][sx - 1].NodeIDsMissingLeg.length);

			// Here: Row x is not full but Row x in Sponsor maybe is full
			if (--MaxYOfXCount >= MissingLegLength) {
				// Use missing leg array
				MissingLeg = new uint32[](MissingLegLength);
				MissingLeg = MatrixStorage[_MATRIX][sx - 1].NodeIDsMissingLeg;
				for (uint32 i = 0; i < MissingLegLength; ++i) {
					if (
						Nodes[MissingLeg[i]].InfoOf[_MATRIX].Y >= RangeYOfXCountOnYRoot[0] &&
						Nodes[MissingLeg[i]].InfoOf[_MATRIX].Y <= RangeYOfXCountOnYRoot[1]
					) return MissingLeg[i];
				}
			} else {
				// Use Range Y of sponsor
				RangeYOfXCountOnYRoot[1] = MaxYOfXCount * sy;
				RangeYOfXCountOnYRoot[0] = (MaxYOfXCount * (sy - 1)) + 1;
				for (uint32 y = RangeYOfXCountOnYRoot[0]; y <= RangeYOfXCountOnYRoot[1]; ++y) {
					if (MatrixStorage[_MATRIX][sx - 1].Y[y].NodeID != 0 && MatrixStorage[_MATRIX][sx - 1].Y[y].isMissingLeg)
						return MatrixStorage[_MATRIX][sx - 1].Y[y].NodeID;
				}
			}
		} while (true);
	}

	// Update info and matrix storage for new node
	function _UpdateNodeAndMatrixStorage(Node storage _newnode, uint8 _MATRIX) private {
		uint32 sid = _newnode.SponsorID;
		uint32 nid = _newnode.NodeID;
		uint32 ny;

		uint32 uid = _newnode.InfoOf[_MATRIX].UplineID;
		uint32 ux1ids = uint32(Nodes[uid].InfoOf[_MATRIX].X1IDs.length);
		uint32 uy = Nodes[uid].InfoOf[_MATRIX].Y;
		uint32 ux = uint32(Nodes[uid].InfoOf[_MATRIX].PathFromRoot.length); // X Of Root;

		if (_MATRIX == BINARY) {
			if (ux1ids == 0) ny = (uy * 2) - 1; // Left to Right
			if (ux1ids == 1) ny = (uy * 2);
		}

		if (_MATRIX == TERNARY) {
			if (ux1ids == 0) ny = (uy * 3) - 2; // Left to Right
			if (ux1ids == 1) ny = (uy * 3) - 1;
			if (ux1ids == 2) ny = (uy * 3);
		}

		// update new node
		_newnode.InfoOf[_MATRIX].Y = ny;
		_newnode.InfoOf[_MATRIX].X1IDs = new uint32[](0);
		_UpdatePath(_newnode, _MATRIX);

		// Here: New node will be inside row x = ux + 1. (Update matrix storage)
		MatrixStorage[_MATRIX][ux + 1].Y[ny] = ColumnsY({ NodeID: nid, isMissingLeg: true });
		MatrixStorage[_MATRIX][ux + 1].NodeIDsMissingLeg.push(nid);
		++MatrixStorage[_MATRIX][ux + 1].YExistedCount;

		// If upline full leg
		if (ux1ids == _MATRIX - 1) {
			// Update sponsor
			if (sid == uid) ++Nodes[sid].InfoOf[_MATRIX].FullYToXOfRoot; // Sponsor not enougth leg -> Full leg

			// Update upline
			MatrixStorage[_MATRIX][ux].NodeIDsMissingLeg.RemoveValue(uid);
			delete MatrixStorage[_MATRIX][ux].Y[uy];

			// Check isFull RowsX = ux + 1
			if (MatrixStorage[_MATRIX][ux + 1].YExistedCount == Algorithms.Exponential(_MATRIX, ux + 1))
				MatrixStorage[_MATRIX][ux + 1].isFull = true;
		}

		Nodes[uid].InfoOf[_MATRIX].X1IDs.push(nid); // Update upline
		if (sid != uid && ux - 1 > Nodes[sid].InfoOf[_MATRIX].FullYToXOfRoot)
			Nodes[sid].InfoOf[_MATRIX].FullYToXOfRoot = ux - 1; // Update sponsor
	}

	// Find and update path to sponsor for new noode, update PathFromRoot, FullYToXOfRoot
	function _UpdatePath(Node storage _newnode, uint8 _MATRIX) private {
		uint32 sid = _newnode.SponsorID;
		uint32 uid = _newnode.InfoOf[_MATRIX].UplineID;

		// Update path from root
		_newnode.InfoOf[_MATRIX].PathFromRoot = Nodes[uid].InfoOf[_MATRIX].PathFromRoot;
		_newnode.InfoOf[_MATRIX].PathFromRoot.push(uid);
		_newnode.InfoOf[_MATRIX].FullYToXOfRoot = uint32(_newnode.InfoOf[_MATRIX].PathFromRoot.length);

		// Find and update path to sponsor
		do {
			if (uid != 0) {
				if (uid != sid) {
					_newnode.InfoOf[_MATRIX].PathToSponsor.push(uid);
					uid = Nodes[uid].InfoOf[_MATRIX].UplineID;
				} else {
					_newnode.InfoOf[_MATRIX].PathToSponsor.push(sid);
					break;
				}
			} else break;
		} while (true);
	}

	// Update sponsor level for upline when node changes from SL1 to SL2
	function _UpdateSponsorLevelForUpline(Node storage _Node) private {}

	/////////////////////////////////////////////////////////////////////////////////////

	function _SelectX1IDsOfNode(
		uint32 _NodeID,
		uint8 _MATRIX
	) internal view virtual returns (uint32[] memory _NodeIDs) {
		return Nodes[_NodeID].InfoOf[_MATRIX].X1IDs;
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";
import "./TAccount.sol";

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol"
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

// interface ITuktu {}

contract Tuktu is TAccount {
	using Uint32Array for uint32[];

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

	constructor(uint32 _Starting) TAccount(_Starting) {}

	///////////////////////////////////////////////////////////
	function TestRegistration(uint8 _num) public {
		for (uint8 i = 0; i < _num; ++i) Registration();
	}

	struct RC {
		uint32 NodeID; // NodeID != 0 when this node is missing leg
		bool isMissingLeg; // If TRUE: This nodeID is not enough leg
		bool isFull; // Full or not full NodeIDs in each positions of Y
		uint32[] NodeIDsMissingLeg; // List of NodeIDs missing leg on this X.
		uint32 YExistedCount; // If YExistedCount == MaxYOfXCount then Y is FULL
	}

	function ViewRoot(
		uint32 RootID,
		uint8 _RowX,
		uint8 _ColY
	) public view returns (Info memory _Info1, Info memory _Info2, RC memory _RC2, Info memory _Info3, RC memory _RC3) {
		_Info1 = Nodes[RootID].InfoOf[1];

		_Info2 = Nodes[RootID].InfoOf[2];
		_RC2 = RC({
			NodeID: MatrixStorage[2][_RowX].Y[_ColY].NodeID,
			isMissingLeg: MatrixStorage[2][_RowX].Y[_ColY].isMissingLeg,
			isFull: MatrixStorage[2][_RowX].isFull,
			NodeIDsMissingLeg: MatrixStorage[2][_RowX].NodeIDsMissingLeg,
			YExistedCount: MatrixStorage[2][_RowX].YExistedCount
		});

		_Info3 = Nodes[RootID].InfoOf[3];
		_RC3 = RC({
			NodeID: MatrixStorage[3][_RowX].Y[_ColY].NodeID,
			isMissingLeg: MatrixStorage[3][_RowX].Y[_ColY].isMissingLeg,
			isFull: MatrixStorage[3][_RowX].isFull,
			NodeIDsMissingLeg: MatrixStorage[3][_RowX].NodeIDsMissingLeg,
			YExistedCount: MatrixStorage[3][_RowX].YExistedCount
		});
	}

	///////////////////////////////////////////////////////////

	modifier onlyAccountOwner(uint32 _AccountID) {
		require(msg.sender == Accounts[_AccountID].Address, "Account: caller is not the owner");
		_;
	}

	fallback() external {}

	receive() external payable {}

	// Registration
	function Registration() public {
		_registration(msg.sender);
	}

	function Registration(string memory _Affiliate) public {
		bytes16 affiliateref = bytes16(bytes(_Affiliate));
		(Affiliates[affiliateref] != 0 && Affiliates[affiliateref] == Accounts[Affiliates[affiliateref]].AccountID)
			? _registration(msg.sender, Affiliates[affiliateref])
			: _registration(msg.sender);
	}

	function Registration(uint32 _SponsorID) public {
		(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID)
			? _registration(msg.sender, _SponsorID)
			: _registration(msg.sender);
	}

	function Registration(address _AddressOfSponsor) public {
		require(_AddressOfSponsor != address(0), "Registration: can not zero address");
		uint32 latestaccountid = _GetLatestAccountsOf(_AddressOfSponsor);
		latestaccountid != 0 ? _registration(msg.sender, latestaccountid) : _registration(msg.sender);
	}

	function Registration(address _NewAccountAddress, uint32 _SponsorID) public {
		require(_NewAccountAddress != address(0), "Registration: can not zero address");
		(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID)
			? _registration(_NewAccountAddress, _SponsorID)
			: _registration(_NewAccountAddress);
	}

	// Config
	function ChangeAffiliate(uint32 _AccountID, string memory _NewAffiliate) public onlyAccountOwner(_AccountID) {
		require(bytes(_NewAffiliate).length != 0, "Affiliate: can not empty");
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		bytes16 newaffiliate = bytes16(bytes(_NewAffiliate));
		bytes16 oldaffilitae = Accounts[_AccountID].Affiliate;
		require(
			keccak256(abi.encodePacked(oldaffilitae)) != keccak256(abi.encodePacked(newaffiliate)),
			"same affiliate already exists"
		);
		require(Affiliates[newaffiliate] == 0 && Affiliates[oldaffilitae] == _AccountID, "Affiliate: does not existed");
		_ChangeAffiliate(_AccountID, newaffiliate);
	}

	function ChangeAddress(uint32 _AccountID, address _NewAddress) public onlyAccountOwner(_AccountID) {
		require(_NewAddress != address(0), "can not zezo address");
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		require(Accounts[_AccountID].Address != _NewAddress, "same address already exists");
		_ChangeAddress(_AccountID, _NewAddress);
	}

	// Dashboard
	function AccountsOfAddress(address _address) public view returns (uint32[] memory _AccountIDs) {
		require(_address != address(0), "Dashboard: can not zero address");
		_AccountIDs = _AccountsOf(_address);
	}

	// Tree view
	struct Treeview {
		uint32 AccountID;
		address Address;
		string Affiliate;
		uint32 SponsorLevel;
		uint32 RegTime;
	}

	function _ReturnTreeviewArray(uint32 _AccountID, uint8 _MATRIX) private view returns (Treeview[] memory _Treeviews) {
		uint32[] memory _AccountIDs = _SelectX1IDsOfNode(_AccountID, _MATRIX);
		uint32 len = uint32(_AccountIDs.length);
		if (len > 0) {
			_Treeviews = new Treeview[](len);
			for (uint32 i = 0; i < len; ++i) {
				_Treeviews[i] = Treeview({
					AccountID: _AccountIDs[i],
					Address: Accounts[_AccountIDs[i]].Address,
					Affiliate: string(abi.encode(Accounts[_AccountIDs[i]].Affiliate)),
					SponsorLevel: Nodes[_AccountIDs[i]].SL,
					RegTime: Accounts[_AccountIDs[i]].RegTime
				});
			}
		}
	}

	function F1OfAccountOnUnilevel(uint32 _AccountID) public view returns (Treeview[] memory _Treeviews) {
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		return _ReturnTreeviewArray(_AccountID, UNILEVEL);
	}

	function F1OfAccountOnBinary(uint32 _AccountID) public view returns (Treeview[] memory _Treeviews) {
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		return _ReturnTreeviewArray(_AccountID, BINARY);
	}

	function F1OfAccountOnTernary(uint32 _AccountID) public view returns (Treeview[] memory _Treeviews) {
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		return _ReturnTreeviewArray(_AccountID, TERNARY);
	}
}