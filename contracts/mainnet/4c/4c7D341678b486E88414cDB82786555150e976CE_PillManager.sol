// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IDispatchManager.sol";
import "./utils/CheckerManaged.sol";
import "./interfaces/IPill.sol";


contract PillManager is CheckerManaged {
	// STORAGE
	IDispatchManager public dispatchManager;

	address[] public contracts;

	// INIT
	function init(
		address _owner,
		address _dispatchManager,
		address[] calldata addrs
	)
		external
	{
		initCheckerManaged(_owner);

		dispatchManager = IDispatchManager(_dispatchManager);

		for(uint i; i < addrs.length; i++)
			setContract(i, addrs[i]);
	}

	// SETTERS
	function setDispatchManager(
		IDispatchManager _dispatchManager
	)
		external
		onlyOwner
	{
		dispatchManager = _dispatchManager;
	}

	function setContract(
		uint i,
		address addr
	)
		public
		onlyOwner
	{
		uint length = contracts.length;

		require(i <= length, "i too big");

		if (i == length)
			contracts.push(addr);
		else 
			contracts[i] = addr;
	}

	// GETTERS
	function viewCountContracts() external view returns (uint) {
		return contracts.length;
	}

	function viewContracts(
		uint cursor, 
		uint size
	) 
		external 
		view 
		returns (
			address[] memory, 
			uint
		)
	{
		uint256 length = size;

		uint maxLength = contracts.length;
		if (length > maxLength - cursor)
			length = maxLength - cursor;

		address[] memory arr = new address[](length);

		for (uint i; i < length; i++)
			arr[i] = contracts[cursor + i];

		return (arr, cursor + length);
	}

	function ownerOf(uint i, uint tokenId) external returns (address) {
		_ensureIndex(i);
		return IPill(contracts[i]).ownerOf(tokenId);
	}

	// CORE
	function createManagedWithTokens(
		uint i,
		address to,
		uint amount
	)
		external
		isNotContract(msg.sender)
		isNotContract(to)
	{
		_ensureIndex(i);
		uint price = IPill(contracts[i]).managerMint(to, amount);
		dispatchManager.create(msg.sender, price);
	}
	
	function createManagedWithPending(
		uint i,
		address to,
		uint amount,
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	)
		external
		isNotContract(msg.sender)
		isNotContract(to)
	{
		_ensureSender(from);
		_ensureIndex(i);
		uint claimed = _claim(from, iData, tokenIds);
		uint price = IPill(contracts[i]).managerMint(to, amount);
		_ensurePrice(claimed, price);
		dispatchManager.claim(from, claimed - price);
	}

	function createManagedAirDrop(
		uint i,
		address to,
		uint amount
	)
		external
		canManage(msg.sender)
	{
		_ensureIndex(i);
		IPill(contracts[i]).managerMint(to, amount);
	}
	
	function createWithPending(
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	)
		external
		canManage(msg.sender)
		returns (uint)
	{
		return _claim(from, iData, tokenIds);
	}

	function claim(
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	) 
		external 
	{
		_ensureSender(from);
		uint total = _claim(from, iData, tokenIds);
		dispatchManager.claim(from, total);
	}

	function claimReset(
		address from,
		uint i,
		uint[] calldata tokenIds
	)
		external
		canManage(msg.sender)
		returns (uint)
	{
		return IPill(contracts[i]).claim(from, tokenIds);
	}

	function _claim(
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	)
		private
		returns (uint total) 
	{
		_ensureLength(iData, tokenIds);
		for (uint i; i < iData.length; i++) {
			_ensureIndex(iData[i]);
			total += IPill(contracts[iData[i]]).claim(from, tokenIds[i]);
		}
	}

	function setManagedData(
		address from,
		uint i,
		uint[] calldata tokenIds,
		uint iManagedData,
		uint value
	)
		external
		canManage(msg.sender)
	{
		_ensureIndex(i);
		IPill(contracts[i]).setData(from, tokenIds, iManagedData, value);
	}
	
	function _ensureIndex(uint i) internal view {
		require(i < contracts.length, "data doesnt exist");
	}

	function _ensureSender(address from) internal view {
		require(msg.sender == from || msg.sender == owner, "Cannot claim for others");
	}

	function _ensurePrice(uint provided, uint expected) internal pure {
		require(provided >= expected, "not enough");
	}

	function _ensureLength(uint[] calldata iData, uint[][] calldata tokenIds) internal pure {
		require(iData.length == tokenIds.length, "length");
	}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IDispatchManager {
	function create(address from, uint amount) external;
	function claim(address to, uint amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Proxied.sol";

contract CheckerManaged is Proxied {
	// STORAGE
	mapping(address => bool) public isManager;
	bool public onlyHuman;

	function initCheckerManaged(address _owner) internal {
		initProxied(_owner);
		onlyHuman = true;
	}

	// MODIFIERS
	modifier canManage(address addr) {
		require(isManager[addr] || addr == owner, "Not manager");
		_;
	}

	modifier isNotContract(address addr) {
		if (onlyHuman && Address.isContract(addr))
			require(isManager[addr], "Contract");
		_;
	}

	// SETTERS
	function setIsManager(address addr, bool value) external onlyOwner {
		isManager[addr] = value;
	}
	
	function setOnlyHuman(bool _onlyHuman) external onlyOwner {
		onlyHuman = _onlyHuman;
	}

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IPill {
	function ownerOf(uint tokenId) external returns (address);

	function managerMint(
		address to,
		uint amount
	) external returns (uint);

	function managerBurn(
		address from,
		uint[] calldata tokenIds
	) external returns (uint);

	function managerTransferFrom(
		address from,
		address to,
		uint[] calldata tokenIds
	) external;

	function setData(
		address from,
		uint[] calldata tokenIds,
		uint iData,
		uint value
	) external;

	function claim(
		address from,
		uint[] calldata tokenIds
	) external returns (uint) ;
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

pragma solidity ^0.8.0;


contract Proxied {
	address public owner;

	modifier onlyOwner() {
		require(msg.sender == owner, "OnlyOwner");
		_;
	}

	function initProxied(address _owner) internal {
		require(owner == address(0), "proxy init");
		owner = _owner;
	}

	function setOwner(address _owner) external onlyOwner {
		require(_owner != address(0), "owner != address(0)");
		owner = _owner;
	}
}