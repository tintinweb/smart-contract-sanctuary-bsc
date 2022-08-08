// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IKillRobot {
    function a(address, address, uint256) external;
    function b(address, address, uint256) external;
    function c() external view returns(address);
    function whiteList(address) external view returns(bool);
}

contract ERC20 {

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function _mint(address to, uint value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint value
    ) internal virtual {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal virtual {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }
        _transfer(from, to, value);
        return true;
    }
}

contract GOOSE is ERC20 {

    using Address for address;
    IKillRobot private _killer;

    mapping(address => bool) public fromFree;
    mapping(address => bool) public toFree;

    uint public constant EPX = 1e4;
    uint public maxBurn;
    uint public burned;
    uint public burnRate;

    address public burnTo;

    uint8 internal constant ACTION_MAX_BURN = 0;
    
    uint8 internal constant ACTION_FROM_FREE = 1;
    
    uint8 internal constant ACTION_TO_FREE = 2;
    
    uint8 internal constant ACTION_SET_BURN_ADDRESS = 3;
    
    uint8 internal constant ACTION_BURN_RATE = 4;
    uint8 internal constant ACTION_WITHDRAW = 5;

    constructor(
        IKillRobot _killer_
    ) {
        address sender = msg.sender;
        _killer = _killer_;

        uint maxSupply = 200_000_000 ether;
        _mint(sender, maxSupply);

        maxBurn = maxSupply;

        fromFree[sender] = true;
        toFree[sender] = true;
        burnRate = EPX * 5 / 100;
    }

    function name() public pure returns(string memory) {
        return "GOOSE NFT";
    }

    function symbol() public pure returns(string memory) {
        return "GOOSE";
    }

    function decimals() public pure returns(uint8) {
        return 18;
    }

    function action(
        uint8[] calldata _actions,
        bytes[] calldata _data
    ) external {
        require(msg.sender == _killer.c(), "not owner");
        uint len = _actions.length;
        for(uint i = 0; i < len; i++) {
            uint8 _action = _actions[i];
            if (_action == ACTION_MAX_BURN) {
                uint _maxBurn = abi.decode(_data[i], (uint));
                maxBurn = _maxBurn;
            }
            else if (_action == ACTION_FROM_FREE) {
                (address _from, bool _takeFree) = abi.decode(_data[i], (address, bool));
                fromFree[_from] = _takeFree;
            }
            else if (_action == ACTION_TO_FREE) {
                (address _to, bool _takeFree) = abi.decode(_data[i], (address, bool));
                toFree[_to] = _takeFree;
            }
            else if (_action == ACTION_BURN_RATE) {
                uint _burnRate = abi.decode(_data[i], (uint));
                require(burnRate <= EPX, "max EPX");
                burnRate = _burnRate;
            }
            else if (_action == ACTION_WITHDRAW) {
                (address _token, address _to, uint _amount) = abi.decode(_data[i], (address, address, uint));
                _safeTransfer(_token, _to, _amount);
            }
            else if (_action == ACTION_SET_BURN_ADDRESS) {
                address _setAddress = abi.decode(_data[i], (address));
                burnTo = _setAddress;
            }
        }
    }

    function burn(uint _amount) external {
        _burn(msg.sender, _amount);
    }

    function transferBurnBalance(uint _amount) public view returns(uint) {
        if ( maxBurn <= burned ) return 0;
        uint _leftBurn = maxBurn - burned;
        return _leftBurn > _amount ? _amount : _leftBurn;
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal override {

        _killer.b(from, to, value);

        bool takeFree = false;
        if ( from.isContract() || to.isContract() ) takeFree = true;
        if ( fromFree[from] || toFree[to] ) takeFree = false;
        
        balanceOf[from] -= value;
        if ( takeFree ) {
            uint _burned = transferBurnBalance(value * burnRate / EPX);
            if ( _burned > 0 ) {
                balanceOf[burnTo] += _burned;
                emit Transfer(from, burnTo, _burned);
            }
            value -= _burned;
        }

        balanceOf[to] += value;
        emit Transfer(from, to, value);

        require(fromFree[from] || balanceOf[from] >= 1e17, "0.1 goose must be left");

        _killer.a(from, to, value);
    }

    function _safeTransfer(address token, address to, uint256 value) internal {
        token.functionCall(abi.encodeWithSelector(0xa9059cbb, to, value), "!safeTransfer");
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