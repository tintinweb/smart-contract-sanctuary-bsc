/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]

pragma solidity ^0.8.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/interfaces/ICohortMigrate.sol

pragma solidity 0.8.0;

interface ICohortMigrate {
    function leaveFromPool(address _to, address _pool) external;
}


// File contracts/interfaces/IUnoV2Pool.sol

pragma solidity 0.8.0;

interface IUnoV2pool {
    function enterInPool(address _behalf, uint256 _amount) external;
}


// File contracts/libraries/TransferHelper.sol

pragma solidity 0.8.0;

// from Uniswap TransferHelper library
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeApprove: approve failed");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeTransfer: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::transferFrom: transferFrom failed");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}


// File contracts/Migrate2V2.sol

pragma solidity 0.8.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Migrate2V2 is Ownable {
    struct MigratedUserInfo {
        uint256 pooledAmount;
        uint256 migratedAmount;
    }

    address immutable public COHORT;
    address immutable public USDC;
    address immutable public UNOV2_POOL;
    address immutable public ZEUS_POOL;
    address immutable public ATHENA_POOL;
    address immutable public ARTEMIS_POOL;

    mapping(address => mapping (address => MigratedUserInfo)) public userMigratedInfo; // _pool => (account => userInfo)

    event Migrate(address indexed riskPool, address indexed account, uint256 pooledAmount, uint256 migratedAmount);

    constructor(
        address _cohort,
        address _USDC,
        address _UNOV2_POOL,
        address _ZEUS_POOL,
        address _ATHENA_POOL,
        address _ARTEMIS_POOL
    ) {
        COHORT = _cohort;
        USDC = _USDC;
        UNOV2_POOL = _UNOV2_POOL;
        ZEUS_POOL = _ZEUS_POOL;
        ATHENA_POOL = _ATHENA_POOL;
        ARTEMIS_POOL = _ARTEMIS_POOL;
    }

    modifier validateRiskPool(address _pool) {
        require(_pool == ZEUS_POOL || _pool == ATHENA_POOL || _pool == ARTEMIS_POOL, "Invalid risk pool");
        _;
    }

    function migrate(address _pool, uint256 _amount) external validateRiskPool(_pool) {
        uint256 pooledAmount = IERC20(_pool).balanceOf(msg.sender);
        require(pooledAmount > 0,  "You have no deposited amount in this risk pool");
        
        ICohortMigrate(COHORT).leaveFromPool(msg.sender, _pool);

        if (_amount > 0) {
            TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), _amount);
            IUnoV2pool(UNOV2_POOL).enterInPool(msg.sender, _amount);

            userMigratedInfo[_pool][msg.sender] = MigratedUserInfo(pooledAmount, _amount);
        }

        emit Migrate(_pool, msg.sender, pooledAmount, _amount);
    }

    function grantAllowanceForSSIP() external onlyOwner {
        TransferHelper.safeApprove(USDC, UNOV2_POOL, type(uint256).max);
    }

    function revokeAllowanceFromSSIP() external onlyOwner {
        TransferHelper.safeApprove(USDC, UNOV2_POOL, 0);
    }
}