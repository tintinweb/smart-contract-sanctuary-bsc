/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.8.0;

library StakeSet {

    struct Item {
        uint id;
        uint createTime;
        uint payTokenAmount;
        address payTokenAddr;
        address owner;
    }

    struct Set {
        Item[] _values;
        // id => index
        mapping (uint => uint) _indexes;
    }

    function add(Set storage set, Item memory value) internal returns (bool) {
        if (!contains(set, value.id)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value.id] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, Item memory value) internal returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value.id];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            Item memory lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue.id] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value.id];

            return true;
        } else {
            return false;
        }
    }

    function contains(Set storage set, uint valueId) internal view returns (bool) {
        return set._indexes[valueId] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(Set storage set, uint256 index) internal view returns (Item memory) {
        require(set._values.length > index, "StakeSet: index out of bounds");
        return set._values[index];
    }

    function idAt(Set storage set, uint256 valueId) internal view returns (Item memory) {
        require(set._indexes[valueId] != 0, "StakeSet: set._indexes[valueId] != 0");
        uint index = set._indexes[valueId] - 1;
        require(set._values.length > index, "StakeSet: index out of bounds");
        return set._values[index];
    }

}

pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;
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


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {

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

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

pragma solidity ^0.8.0;
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

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

// SPDX-License-Identifier: MIT
contract StakePool is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using StakeSet for StakeSet.Set;


    ///////////////////////////////// constant /////////////////////////////////
    uint constant DECIMALS = 10 ** 18;

    // todo: wethToken address
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant KORO_ADDRESS = 0x50c2DC0E1213EF1A2f809e6C24C8EEE6A07eCC55;

    ///////////////////////////////// storage /////////////////////////////////
    uint public currentId;
    uint private _totalSupply;
    uint private _totalWeight;
    uint private _rate = 2;
    address public poundageAddress;

    mapping(address => uint) private _balances;
    mapping(address => uint) private _weights;
    mapping(address => StakeSet.Set) private _stakeOf;
    mapping(address => uint) public _KValueOf;
    uint public _totalKValueOf = 0;
    uint public _totalKBalanceOf = 0;

    // withdrawn stakeId
    uint[] public withdrawIdOf;


    //emit Stake(msg.sender, _payToken, item.id, _payTokenAmount);
    event Stake(address indexed user, address indexed payToken, uint stakeId, uint payTokenAmount);
    event Withdraw(address indexed user, uint indexed stakeId, uint payTokenAmount);

    constructor () {
        
    }

    //poundageAddress
    function setPoundageAddress(address account) public onlyOwner{
        require(account != address(0), "ERC20: fundAddress to the zero address");
        poundageAddress = account;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    //_rate
    function rate() public view returns (uint) {
        return _rate;
    }

    function setRate(uint _value) public onlyOwner{
        _rate = _value;
    }

    function balanceOf(address account) public view returns (uint) {
        return _stakeOf[account]._values.length;
    }

    /**
     * @dev get stake item by '_account' and '_index'
     */
    function getStakeOf(address _account, uint _index) external view returns (StakeSet.Item memory) {
        require(_stakeOf[_account].length() > _index, "getStakeOf: _stakeOf[_account].length() > _index");
        return _stakeOf[_account].at(_index);
    }

    /**
     * @dev get '_account' stakes by page
     */
    function getStakes(address _account, uint _index, uint _offset) external view returns (StakeSet.Item[] memory items) {
        uint totalSize = balanceOf(_account);
        if (0 == totalSize || totalSize <= _index) return items;
        uint offset = _offset;
        if (totalSize < _index + offset) {
            offset = totalSize - _index;
        }

        items = new StakeSet.Item[](offset);
        for (uint i = 0; i < offset; i++) {
            items[i] = _stakeOf[_account].at(_index + i);
        }
    }

    function withdrawLen() public view returns (uint) {
        return withdrawIdOf.length;
    }

    function getWithdrawIds(uint _index, uint _offset) external view returns (uint[] memory res) {
        uint totalSize = withdrawLen();
        if (0 == totalSize || totalSize <= _index) return res;
        uint offset = totalSize < _index + _offset ? totalSize - _index : _offset;

        res = new uint[](offset);
        for (uint i = 0; i < offset; i++) {
            res[i] = withdrawIdOf[_index + i];
        }
    }


    function saveKoro(uint _amount)external {
        require(0 < _amount, "saveKoro: 0 < _amount");
        IERC20(KORO_ADDRESS).safeTransferFrom(msg.sender, address(this), _amount);
        _KValueOf[msg.sender] += _amount;
        _totalKValueOf += _amount;
        _totalKBalanceOf +=_amount;
    }


    function stake(address _payToken, uint _payTokenAmount) external payable {
        // transfer to this
        if (0 < msg.value) { // pay with ETH
            require(_payToken == WETH_ADDRESS, "stake: _payToken = WETH_ADDRESS");
            require(_payTokenAmount == msg.value, "stake: payTokenAmount == msg.value");
        } else { // pay with payToken
            IERC20(_payToken).safeTransferFrom(msg.sender, address(this), _payTokenAmount);
        }

        _totalSupply = _totalSupply.add(1);
        _balances[msg.sender] = _balances[msg.sender].add(1);


        // update _stakeOf
        StakeSet.Item memory item;
        item.id = ++currentId;
        item.createTime = block.timestamp;
        item.payTokenAmount = _payTokenAmount;
        item.payTokenAddr = _payToken;
        item.owner = msg.sender;
        _stakeOf[msg.sender].add(item);
        _stakeOf[address(0)].add(item);

        emit Stake(msg.sender, _payToken, item.id, _payTokenAmount);
    }

    /**
     * @dev withdraw stake
     * @param _stakeId  stakeId
     */
    function withdraw(uint _stakeId) external {
        require(currentId >= _stakeId, "withdraw: currentId >= _stakeId");

        // get _stakeOf
        StakeSet.Item memory item = _stakeOf[msg.sender].idAt(_stakeId);
        //poundageAddress
        uint poundageAmount = item.payTokenAmount * _rate / 100;
        uint payTokenAmount = item.payTokenAmount - poundageAmount;
        if (WETH_ADDRESS == item.payTokenAddr) { // pay with ETH
            payable(msg.sender).transfer(payTokenAmount);
            payable(poundageAddress).transfer(poundageAmount);
        } else { // pay with payToken
            IERC20(item.payTokenAddr).safeTransfer(msg.sender, payTokenAmount);
            IERC20(item.payTokenAddr).safeTransfer(poundageAddress, poundageAmount);
        }

        _totalSupply = _totalSupply.sub(1);
        _balances[msg.sender] = _balances[msg.sender].sub(1);


        // update _stakeOf
        _stakeOf[msg.sender].remove(item);
        _stakeOf[address(0)].remove(item);
        // update withdrawIdOf
        withdrawIdOf.push(_stakeId);

        emit Withdraw(msg.sender, _stakeId, payTokenAmount);
    }

    function withdrawKoro()external {
        require(0 < _KValueOf[msg.sender], "withdrawKoro: 0 < _KValueOf");
        IERC20(KORO_ADDRESS).safeTransfer(msg.sender, _KValueOf[msg.sender]);
        _totalKValueOf -= _KValueOf[msg.sender];
        _KValueOf[msg.sender] = 0;
    }

    receive() external payable {}
    fallback() external {}

}