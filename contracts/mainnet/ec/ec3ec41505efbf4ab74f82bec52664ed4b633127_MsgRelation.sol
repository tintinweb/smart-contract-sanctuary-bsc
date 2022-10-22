/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract MsgRelation {
    uint256 public head;
    mapping(uint256 => address) public indexMap;
    mapping(address => uint256) public addressMap;
    mapping(address => address) public edges;
    mapping(address => bool) public govence;

    modifier onlyGov() {
        require(govence[msg.sender], "Governance: caller is not the governor");
        _;
    }

    constructor() {
        govence[msg.sender] = true;
    }

    function setRelation(address father, address child) external onlyGov {
        addNode(father);
        addNode(child);
        if (
            !hasFatherByAddress(child) &&
            isNodeByAddress(father) &&
            isNodeByAddress(child)
        ) {
            edges[child] = father;
        }
    }

    function setRelationBySelf(address father) external {
        addNode(msg.sender);
        addNode(father);
        if (
            !hasFatherByAddress(msg.sender) &&
            isNodeByAddress(father) &&
            isNodeByAddress(msg.sender)
        ) {
            edges[msg.sender] = father;
        }
    }

    function hasRelation(address _address) external view returns (bool) {
        return edges[_address] != address(0);
    }

    function getRelation(address _address)
        external
        view
        returns (address parent)
    {
        parent = edges[_address];
        return parent;
    }

    function getRelations(address _address, uint length)
        external
        view
        returns (address[] memory)
    {
        require(length < 6, "Length must be greater than 6");
        address[] memory result = new address[](length);
        for (uint i = 0; i < length; i++) {
            _address = edges[_address];
            result[i] = _address;
        }
        return result;
    }

    function addGovernor(address _address) public onlyGov {
        govence[_address] = true;
    }

    function addNode(address _address) private {
        if (Address.isContract(_address)) {
            return;
        }
        if (addressMap[_address] == 0) {
            head = head + 1;
            indexMap[head] = _address;
            addressMap[_address] = head;
        }
    }

    function isNodeByAddress(address _address) public view returns (bool) {
        return addressMap[_address] != uint256(0);
    }

    function isNodeByIndex(uint256 _index) public view returns (bool) {
        return indexMap[_index] != address(0);
    }

    function hasFatherByAddress(address _address) public view returns (bool) {
        return edges[_address] != address(0);
    }

    function hasFatherByIndex(uint256 _index) public view returns (bool) {
        return edges[indexMap[_index]] != address(0);
    }

    function fatherOfNodeByAddress(address _address)
        public
        view
        returns (address)
    {
        require(isNodeByAddress(_address), "Node not exist!");
        return edges[_address];
    }

    function fatherOfNodeByIndex(uint256 _index) public view returns (address) {
        require(isNodeByIndex(_index), "Node not exist!");
        return edges[indexMap[_index]];
    }

    function queryIndex(address _address) public view returns (uint256) {
        require(isNodeByAddress(_address), "Node not exist!");
        return addressMap[_address];
    }

    function queryAddress(uint256 _index) public view returns (address) {
        require(isNodeByIndex(_index), "Node not exist!");
        return indexMap[_index];
    }
}