/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

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
abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) private {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(_previousOwner, _owner);
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) internal onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() internal {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Lock time not yet");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

abstract contract Callable is Ownable {

    /**
     * 允许的地址
     */
    mapping(address => bool) private _permitted;

    event PermissionUpdated(address indexed _caller, bool _state);

    modifier onlyPermitted() {
        require(_permitted[msg.sender], "Callable: caller not permitted");
        _;
    }

    function callable(address sender) view public returns (bool) {
        return _permitted[sender];
    }

    function setPermission(address _caller, bool _state) public onlyOwner returns (bool) {
        _permitted[_caller] = _state;
        emit PermissionUpdated(_caller, _state);
        return true;
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BatchTransfer is Callable {

    constructor(){
        setPermission(msg.sender, true);
    }

    event TransferEvent(address indexed _token, address indexed rec, uint value, uint time);

    function withdraw(address _token, uint value) external onlyPermitted() {
        IBEP20 TOKEN = IBEP20(_token);
        uint balance = TOKEN.balanceOf(address(this));
        require(balance >= value, "Balance not enough");

        TransferHelper.safeTransfer(_token, msg.sender, value);
    }

    function batchTransfer(address _token, address[] calldata accounts, uint[] calldata values) external onlyPermitted() {
        IBEP20 TOKEN = IBEP20(_token);
        require(accounts.length == values.length, "Bad data");
        uint balance = TOKEN.balanceOf(address(this));
        uint sumTotal = 0;
        uint i = 0;
        uint length = accounts.length;
        for (; i < length; i++) {
            sumTotal += values[i];
        }
        require(balance >= sumTotal, "Balance not enough");
        uint time = block.timestamp;
        for (i = 0; i < length; i++) {
            TransferHelper.safeTransfer(_token, accounts[i], values[i]);
            emit TransferEvent(_token, accounts[i], values[i], time);
        }
    }
}