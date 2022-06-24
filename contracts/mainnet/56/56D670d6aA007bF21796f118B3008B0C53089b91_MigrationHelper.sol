/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT

/**
 *From celebrity with science and wisdom
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
   */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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

//
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

//
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IMasterChef {
    function owner() external view returns (address);
    function poolInfo(uint256 _pid) external view returns (IBEP20,uint256, uint256, uint256);
    function poolLength() external view returns (uint256);
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;
    function updatePool(uint256 _pid) external;
    function transferOwnership(address newOwner) external;
}

contract MigrationHelper is Ownable {

    address immutable public MasterChefV1Addr;

    address immutable public MasterChefV1OriginOwner;

    uint256 immutable public MasterChefV2Pid;

    bool public isBackupAllocPoints;

    uint256 public totalAllocPoints;

    mapping(uint256 => uint256) public prevAllocPoints;

    uint256[] public localPools;

    constructor(
        address _MasterChefV1Addr,
        uint256 _MasterChefV2Pid
    ) public {
        MasterChefV1Addr = _MasterChefV1Addr;
        MasterChefV1OriginOwner = IMasterChef(_MasterChefV1Addr).owner();
        MasterChefV2Pid = _MasterChefV2Pid;
    }

    function addPoolToMigrate(uint256[] memory pools) external onlyOwner {
        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];

            require(prevAllocPoints[pid] == 0, "pid already set");

            (, uint256 allocPoint, ,) = IMasterChef(MasterChefV1Addr).poolInfo(pid);

            if (allocPoint > 0) {
                totalAllocPoints = totalAllocPoints + allocPoint;
                prevAllocPoints[pid] = allocPoint;
                localPools.push(pid);
            }
        }
    }

    function removePoolToMigrate(uint256[] memory pools) external onlyOwner {
        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];

            (, uint256 allocPoint, ,) = IMasterChef(MasterChefV1Addr).poolInfo(pid);

            if (allocPoint > 0) {
                totalAllocPoints = totalAllocPoints - allocPoint;
            }

            prevAllocPoints[pid] = 0;
        }
    }

    function hasBackupAllocPoints(bool _status) external onlyOwner {
        isBackupAllocPoints = _status;
    }

    function transferOwnershipForMasterChefV1() external onlyOwner {
        IMasterChef(MasterChefV1Addr).transferOwnership(MasterChefV1OriginOwner);
    }

    function set(uint256 _pid) external onlyOwner {
        require(isBackupAllocPoints, "has not backup allocPoints yet");

        _updatePool(_pid);

        // set allocPoint to 0 except MCv2Pid to 1
        if (_pid == MasterChefV2Pid) {
            IMasterChef(MasterChefV1Addr).set(_pid, 1, false);
        } else if (prevAllocPoints[_pid] > 0) {
            IMasterChef(MasterChefV1Addr).set(_pid, 0, false);
        }
    }

    function batchSet(uint256[] memory pools) external onlyOwner {
        require(isBackupAllocPoints, "has not backup allocPoints yet");

        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];
            // update pool
            _updatePool(pid);
        }

        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];
            // set allocPoint to 0 except MCv2Pid to 1
            if (pid == MasterChefV2Pid) {
                IMasterChef(MasterChefV1Addr).set(pid, 1, false);
            } else if (prevAllocPoints[pid] > 0) {
                IMasterChef(MasterChefV1Addr).set(pid, 0, false);
            }
        }
    }

    function recover(uint256 _pid) external onlyOwner {
        require(isBackupAllocPoints, "has not backup allocPoints yet");

        _updatePool(_pid);

        if (prevAllocPoints[_pid] > 0) {
            IMasterChef(MasterChefV1Addr).set(_pid, prevAllocPoints[_pid], false);
        }
    }

    function batchRecover(uint256[] memory pools) external onlyOwner {
        require(isBackupAllocPoints, "has not backup allocPoints yet");

        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];
            // update pool
            _updatePool(pid);
        }

        for (uint256 i; i < pools.length; i++) {
            // get pid of the pools array
            uint256 pid = pools[i];
            // set allocPoint back to origin value
            if (prevAllocPoints[pid] > 0) {
                IMasterChef(MasterChefV1Addr).set(pid, prevAllocPoints[pid], false);
            }
        }
    }

    function kill() external onlyOwner {
        require(MasterChefV1OriginOwner == IMasterChef(MasterChefV1Addr).owner(),
            "should not hold MasterChefV1 ownership"
        );

        selfdestruct(msg.sender);
    }

    function _updatePool(uint256 _pid) internal {
        require(_pid > 0, "pid0 is not settable");

        IMasterChef(MasterChefV1Addr).updatePool(_pid);
    }
}