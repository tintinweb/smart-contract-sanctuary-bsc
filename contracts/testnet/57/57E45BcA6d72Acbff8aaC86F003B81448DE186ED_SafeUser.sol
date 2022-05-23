// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.6;

import '@openzeppelin/contracts/utils/Context.sol';

/**
 * This is a contract copied from 'Ownable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _pendingOwner;

    event ChangePendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pendingOwner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        if (_pendingOwner != address(0)) {
            emit ChangePendingOwner(_pendingOwner, address(0));
            _pendingOwner = address(0);
        }
    }

    function setPendingOwner(address pendingOwner_) public virtual onlyOwner {
        require(pendingOwner_ != address(0), "Ownable: pendingOwner is the zero address");
        emit ChangePendingOwner(_pendingOwner, pendingOwner_);
        _pendingOwner = pendingOwner_;
    }

    function acceptOwner() public virtual onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        emit ChangePendingOwner(_pendingOwner, address(0));
        _pendingOwner = address(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;

pragma abicoder v2;

import "../core/SafeOwnable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IAirdropPool {
    function balanceOf(address account) external view returns (uint256);
}

interface IPledgePool {
    function balanceOf(address account)
        external
        view
        returns (uint256, uint256);
}

/**
 * This is a contract copied from 'Ownable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
contract SafeUser is SafeOwnable {
    using Address for address;

    mapping(address => address) private userMap;
    mapping(address => address[]) private inviters;
    mapping(address => uint8) private userLevel;
    IPledgePool public pledge;
    IAirdropPool public airdrop;
    address public token;

    struct UserInfo {
        address account;
        uint8 level;
        uint256 airdropAmount;
        uint256 pledgeAmount;
    }

    constructor() {
        userMap[msg.sender] = address(this);
    }

    function setAirdropPool(address _airdrop) external onlyOwner {
        airdrop = IAirdropPool(_airdrop);
    }

    function setPledgePool(address _pledge) external onlyOwner {
        pledge = IPledgePool(_pledge);
    }

    function setToken(address _token) external onlyOwner {
        token = _token;
    }

    function setUserLevel(address account, uint8 level) external onlyOwner {
        userLevel[account] = level;
    }

    function setLevel(address account) public {
        require(address(airdrop) == msg.sender, "not owner");
        if (userLevel[account] > 0) return;
        userLevel[account] = 1;
    }

    function getUserLevel(address account) public view returns (uint8) {
        return userLevel[account];
    }

    function getReferrer(address account) public view returns (address) {
        return userMap[account];
    }

    function getInviters(address account)
        public
        view
        returns (address[] memory)
    {
        return inviters[account];
    }

    function getInviterInfo(address account, uint256 page)
        public
        view
        returns (UserInfo[] memory)
    {
        uint256 size = 20;
        UserInfo[] memory info = new UserInfo[](size);
        if (page > 0) {
            uint256 startIndex = (page - 1) * size;
            address[] memory list = inviters[account];
            uint256 length = list.length;
            for (uint256 i = 0; i < size; i++) {
                if (startIndex + i >= length) {
                    break;
                }
                info[i].account = list[startIndex + i];
                info[i].level = getUserLevel(info[i].account);
                info[i].airdropAmount = airdrop.balanceOf(info[i].account);
                (uint256 pl, ) = pledge.balanceOf(info[i].account);
                info[i].pledgeAmount = pl;
            }
        }
        return info;
    }

    function setReferrer(address _referrer) external {
        require(userMap[msg.sender] == address(0), "not sender");
        require(userMap[_referrer] != address(0), "not referrer");
        userMap[msg.sender] = _referrer;
        inviters[_referrer].push(msg.sender);
    }

    function setTokenFromReferrer(address account, address _referrer) public {
        require(msg.sender == token, "not token");
        if (account.isContract() || _referrer.isContract()) return;
        if (userMap[account] != address(0)) return;
        if (userMap[_referrer] == address(0)) return;

        userMap[account] = _referrer;
        inviters[_referrer].push(account);
    }

    function getUserNode(address account) public view returns (address) {
        address referrer = getReferrer(account);
        for (uint256 index = 0; index != 20; index++) {
            if (referrer == address(0)) {
                break;
            }

            if (getUserLevel(referrer) == 3) {
                return referrer;
            }
            referrer = getReferrer(referrer);
        }
    }

    function getV2AndV3(address account)
        public
        view
        returns (address v2, address v3)
    {
        address referrer = getReferrer(account);
        for (uint256 index = 0; index != 30; index++) {
            if (referrer == address(0)) {
                break;
            }
            if (v2 != address(0) && v3 != address(0)) {
                break;
            }
            uint8 level = getUserLevel(referrer);
            if (level == 2 && index <= 20) {
                v2 = referrer;
            }
            if (level == 3) {
                v3 = referrer;
            }

            referrer = getReferrer(referrer);
        }
    }
}