// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./utils/CheckerManaged.sol";
import "./interfaces/IPillManager.sol";
import "./interfaces/IDispatchManager.sol";


contract RepairManager is CheckerManaged {
	IPillManager public pillManager;
	IDispatchManager public dispatchManager;

	uint public constant I_LAST_REPAIR = 1;
	uint public constant I_START_DECAY = 2;
	uint public constant I_DECAY_DURATION = 3;
	
	struct Repair {
		string name;
		uint[] prices;
		uint[] startDecays;
		uint[] decayDurations;
	}

	Repair[] private repairs;

	function init(
		address _owner,
		address _pillManager,
		address _dispatchManager,
		string[] calldata _names,
		uint[][] calldata _prices,
		uint[][] calldata _startDecays,
		uint[][] calldata _decayDurations
	)
		external
	{
		initCheckerManaged(_owner);

		pillManager = IPillManager(_pillManager);
		dispatchManager = IDispatchManager(_dispatchManager);

		require(_names.length == _prices.length, "length");
		require(_prices.length == _startDecays.length, "length");
		require(_prices.length == _decayDurations.length, "length");

		for (uint i; i < _prices.length; i++)
			setAll(i, _names[i], _prices[i], _startDecays[i], _decayDurations[i]);
	}

	// SETTERS
	function setPillManager(IPillManager _pillManager) external onlyOwner {
		pillManager = _pillManager;
	}

	function setDispatchManager(IDispatchManager _dispatchManager) external onlyOwner {
		dispatchManager = _dispatchManager;
	}

	function setAll(
		uint i,
		string calldata name,
		uint[] calldata prices, 
		uint[] calldata startDecays,
		uint[] calldata decayDurations
	) 
		public 
		onlyOwner 
	{
		uint length = repairs.length;
		require(i <= length, "i too big");

		if (i == length)
			repairs.push();
	
		require(prices.length == startDecays.length, "length");

		Repair storage repair = repairs[i];

		repair.name = name;
		for (uint j; j < prices.length; j++) {
			_setData(repair.prices, j, prices[j]);
			_setData(repair.startDecays, j, startDecays[j]);
			_setData(repair.decayDurations, j, decayDurations[j]);
		}
	}

	function setName(uint i, string calldata name) public onlyOwner {
		_ensureIndex0(i);
		repairs[i].name = name;
	}

	function setPrice(uint i, uint j, uint price) public onlyOwner {
		_ensureIndex0(i);
		_setData(repairs[i].prices, j, price);
	}
	
	function setStartDecay(uint i, uint j, uint startDecay) public onlyOwner {
		_ensureIndex0(i);
		_setData(repairs[i].startDecays, j, startDecay);
	}
	
	function setDecayDuration(uint i, uint j, uint decayDuration) public onlyOwner {
		_ensureIndex0(i);
		_setData(repairs[i].decayDurations, j, decayDuration);
	}
	
	function _setData(uint[] storage datas, uint i, uint value) private {
		uint length = datas.length;
		require(i <= length, "i too big");

		if (i == length)
			datas.push(value);
		else
			datas[i] = value;
	}

	// GETTERS
	function viewCountRepairs() external view returns (uint) {
		return repairs.length;
	}

	function viewCountPrices(uint i) external view returns (uint) {
		_ensureIndex0(i);
		return repairs[i].prices.length;
	}
	
	function viewCountStartDecays(uint i) external view returns (uint) {
		_ensureIndex0(i);
		return repairs[i].startDecays.length;
	}

	function viewCountDecayDurations(uint i) external view returns (uint) {
		_ensureIndex0(i);
		return repairs[i].decayDurations.length;
	}

	function viewName(
		uint i
	)
		external
		view
		returns (
			string memory
		)
	{
		_ensureIndex0(i);
		return repairs[i].name;
	}

	function viewPrices(
		uint i,
		uint cursor,
		uint size
	)
		external
		view
		returns (
			uint[] memory,
			uint
		)
	{
		_ensureIndex0(i);
		uint256 length = size;

		uint[] storage prices = repairs[i].prices;

		uint maxLength = prices.length;
		if (length > maxLength - cursor)
			length = maxLength - cursor;

		uint[] memory arr = new uint[](length);

		for (uint j; j < length; j++)
			arr[j] = prices[cursor + j];

		return (arr, cursor + length);
	}
	
	function viewStartDecays(
		uint i,
		uint cursor,
		uint size
	)
		external
		view
		returns (
			uint[] memory,
			uint
		)
	{
		_ensureIndex0(i);
		uint256 length = size;
		
		uint[] storage startDecays = repairs[i].startDecays;

		uint maxLength = startDecays.length;
		if (length > maxLength - cursor)
			length = maxLength - cursor;

		uint[] memory arr = new uint[](length);

		for (uint j; j < length; j++)
			arr[j] = startDecays[cursor + j];

		return (arr, cursor + length);
	}
	
	function viewDecayDurations(
		uint i,
		uint cursor,
		uint size
	)
		external
		view
		returns (
			uint[] memory,
			uint
		)
	{
		_ensureIndex0(i);
		uint256 length = size;
		
		uint[] storage decayDurations = repairs[i].decayDurations;

		uint maxLength = decayDurations.length;
		if (length > maxLength - cursor)
			length = maxLength - cursor;

		uint[] memory arr = new uint[](length);

		for (uint j; j < length; j++)
			arr[j] = decayDurations[cursor + j];

		return (arr, cursor + length);
	}
	
	function repairWithTokens(
		uint i,
		uint j,
		uint[] calldata tokenIds
	)
		external
	{
		_ensureIndex0(i);

		Repair storage repair = repairs[i];
		_ensureIndex1(repair, j);

		uint claimed = pillManager.claimReset(
			msg.sender,
			j,
			tokenIds
		);
		dispatchManager.claim(msg.sender, claimed);

		uint price = repair.prices[j] * tokenIds.length;
		setManagedData(repair, msg.sender, j, tokenIds);
		dispatchManager.create(msg.sender, price);
	}
	
	function repairWithPending(
		uint i,
		uint j,
		uint[] calldata tokenIds,
		uint[] calldata iClaim,
		uint[][] calldata tokenIdsClaim
	)
		external
	{
		_ensureIndex0(i);
		
		Repair storage repair = repairs[i];
		_ensureIndex1(repair, j);

		uint price = repair.prices[j] * tokenIds.length;
		uint claimed = pillManager.claimReset(
			msg.sender,
			j,
			tokenIds
		);
		claimed += pillManager.createWithPending(
			msg.sender,
			iClaim,
			tokenIdsClaim
		);
		require(claimed >= price, "not enough");
		setManagedData(repair, msg.sender, j, tokenIds);
		dispatchManager.claim(msg.sender, claimed - price);
	}

	function repairAirDrop(
		address from,
		uint i,
		uint j,
		uint[] calldata tokenIds
	)
		external
		canManage(msg.sender)
	{
		_ensureIndex0(i);
		
		Repair storage repair = repairs[i];
		_ensureIndex1(repair, j);

		setManagedData(repair, from, j, tokenIds);
	}
	
	function repairAirDropWithClaim(
		address from,
		uint i,
		uint j,
		uint[] calldata tokenIds
	)
		external
		canManage(msg.sender)
	{
		_ensureIndex0(i);
		
		Repair storage repair = repairs[i];
		_ensureIndex1(repair, j);
		uint claimed = pillManager.claimReset(
			from,
			j,
			tokenIds
		);
		setManagedData(repair, from, j, tokenIds);
		dispatchManager.claim(from, claimed);
	}

	function setManagedData(
		Repair storage repair,
		address from,
		uint j,
		uint[] calldata tokenIds
	) private {
		pillManager.setManagedData(
			from,
			j,
			tokenIds,
			I_LAST_REPAIR,
			block.timestamp
		);
		pillManager.setManagedData(
			from,
			j,
			tokenIds,
			I_START_DECAY,
			repair.startDecays[j]
		);
		pillManager.setManagedData(
			from,
			j,
			tokenIds,
			I_DECAY_DURATION,
			repair.decayDurations[j]
		);
	}

	function _ensureIndex0(uint i) internal view {
		require(i < repairs.length, "doesnt exist");
	}
	
	function _ensureIndex1(Repair storage repair, uint i) internal view {
		require(i < repair.prices.length &&
				i < repair.startDecays.length &&
				i < repair.decayDurations.length, 
				"doesnt exist"
			);
	}
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


interface IPillManager {
	function ownerOf(uint i, uint tokenId) external view returns (address);

	function createManagedAirDrop(
		uint i,
		address to,
		uint amount
	) external;

	function createWithPending(
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	) external returns (uint);
	
	function claimReset(
		address from,
		uint i,
		uint[] calldata tokenIds
	) external returns (uint);

	function setManagedData(
		address from,
		uint i,
		uint[] calldata tokenIds,
		uint iManagedData,
		uint value
	) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IDispatchManager {
	function create(address from, uint amount) external;
	function claim(address to, uint amount) external;
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