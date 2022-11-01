// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import "../lib/IApePair.sol";
import "../lib/IMasterApe.sol";
import "../lib/IApeFactory.sol";
import "../lib/IPoolManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPBalanceChecker is Ownable {
    address constant PCSMasterChefV2 =
        0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    IMasterApe constant masterApe =
        IMasterApe(0x5c8D727b265DBAfaba67E050f2f739cAeEB4A6F9);
    IPoolManager constant poolManager =
        IPoolManager(0x36524d6A9FB579A0b046edfC691ED47C2de5B8bf);

    address[] public stakingContracts;

    mapping(address => IApeFactory) stakingContractToFactory;

    struct Balances {
        address stakingAddress;
        Balance[] balances;
    }

    struct Balance {
        uint256 pid;
        address lp;
        address token0;
        address token1;
        uint256 total;
        uint256 wallet;
        uint256 staked;
    }

    constructor(
        address[] memory _stakingContracts,
        IApeFactory[] memory _factoryContract
    ) Ownable() {
        for (uint256 i = 0; i < _stakingContracts.length; i++) {
            addStakingContract(_stakingContracts[i], _factoryContract[i]);
        }
    }

    function getBalance(address user)
        external
        view
        returns (Balances[] memory pBalances)
    {
        pBalances = new Balances[](stakingContracts.length);
        for (uint256 i = 0; i < stakingContracts.length; i++) {
            IMasterApe stakingContract = IMasterApe(stakingContracts[i]);
            pBalances[i].stakingAddress = address(stakingContract);

            uint256 poolLength = stakingContract.poolLength();
            uint256 apeSwapPoolLength = masterApe.poolLength();
            uint256 apeSwapJFPoolsCount = poolManager.getActivePoolCount();

            Balance[] memory tempBalances = new Balance[](
                poolLength + apeSwapPoolLength + apeSwapJFPoolsCount
            );

            for (uint256 poolId = 0; poolId < poolLength; poolId++) {
                address lpTokenAddress;
                if (address(stakingContract) == PCSMasterChefV2) {
                    lpTokenAddress = stakingContract.lpToken(poolId); //PCS uses lpToken() instead of poolInfo()[0]
                } else {
                    (lpTokenAddress, , , ) = stakingContract.poolInfo(poolId);
                }
                (uint256 amount, ) = stakingContract.userInfo(poolId, user);

                IApePair lpToken = IApePair(lpTokenAddress);

                Balance memory balance;
                balance.lp = lpTokenAddress;
                balance.pid = poolId;
                balance.wallet = lpToken.balanceOf(user);
                balance.staked = amount;
                balance.total = balance.wallet + balance.staked;
                try lpToken.token0() returns (address _token0) {
                    balance.token0 = _token0;
                } catch (bytes memory) {}
                try lpToken.token1() returns (address _token1) {
                    balance.token1 = _token1;
                } catch (bytes memory) {}

                tempBalances[poolId] = balance;
            }

            {
                for (uint256 poolId = 0; poolId < apeSwapPoolLength; poolId++) {
                    address lpTokenAddress;
                    (lpTokenAddress, , , ) = masterApe.poolInfo(poolId);
                    IApePair apeLpToken = IApePair(lpTokenAddress);

                    Balance memory balance;
                    try apeLpToken.token0() returns (address _token0) {
                        balance.token0 = _token0;
                    } catch (bytes memory) {}
                    try apeLpToken.token1() returns (address _token1) {
                        balance.token1 = _token1;
                    } catch (bytes memory) {}

                    if (
                        balance.token0 != address(0) &&
                        balance.token1 != address(0)
                    ) {
                        lpTokenAddress = stakingContractToFactory[
                            address(stakingContract)
                        ].getPair(balance.token0, balance.token1);

                        bool add = true;
                        if (lpTokenAddress != address(0)) {
                            for (uint256 n = 0; n < poolLength; n++) {
                                if (tempBalances[n].lp == lpTokenAddress) {
                                    add = false;
                                    break;
                                }
                            }

                            if (add) {
                                balance.lp = lpTokenAddress;
                                balance.wallet = IApePair(lpTokenAddress)
                                    .balanceOf(user);
                                balance.total = balance.wallet;
                            }
                        }
                    }

                    tempBalances[poolLength + poolId] = balance;
                }
            }

            {
                address[] memory apeSwapJFPools = poolManager.allActivePools();
                for (
                    uint256 poolId = 0;
                    poolId < apeSwapJFPoolsCount;
                    poolId++
                ) {
                    address lpTokenAddress = apeSwapJFPools[poolId];
                    IApePair apeLpToken = IApePair(lpTokenAddress);

                    Balance memory balance;
                    try apeLpToken.token0() returns (address _token0) {
                        balance.token0 = _token0;
                    } catch (bytes memory) {}
                    try apeLpToken.token1() returns (address _token1) {
                        balance.token1 = _token1;
                    } catch (bytes memory) {}

                    if (
                        balance.token0 != address(0) &&
                        balance.token1 != address(0)
                    ) {
                        lpTokenAddress = stakingContractToFactory[
                            address(stakingContract)
                        ].getPair(balance.token0, balance.token1);

                        bool add = true;
                        if (lpTokenAddress != address(0)) {
                            for (
                                uint256 n = 0;
                                n < poolLength + apeSwapPoolLength;
                                n++
                            ) {
                                if (tempBalances[n].lp == lpTokenAddress) {
                                    add = false;
                                    break;
                                }
                            }

                            if (add) {
                                balance.lp = lpTokenAddress;
                                balance.wallet = IApePair(lpTokenAddress)
                                    .balanceOf(user);
                                balance.total = balance.wallet;
                            }
                        }
                    }

                    tempBalances[
                        poolLength + apeSwapPoolLength + poolId
                    ] = balance;
                }
            }

            uint256 balanceCount;
            for (
                uint256 balanceIndex = 0;
                balanceIndex < tempBalances.length;
                balanceIndex++
            ) {
                if (
                    tempBalances[balanceIndex].total > 0 &&
                    tempBalances[balanceIndex].token0 != address(0)
                ) {
                    balanceCount++;
                }
            }

            Balance[] memory balances = new Balance[](balanceCount);
            uint256 newIndex = 0;

            for (
                uint256 balanceIndex = 0;
                balanceIndex < tempBalances.length;
                balanceIndex++
            ) {
                if (
                    tempBalances[balanceIndex].total > 0 &&
                    tempBalances[balanceIndex].token0 != address(0)
                ) {
                    balances[newIndex] = tempBalances[balanceIndex];
                    newIndex++;
                }
            }

            pBalances[i].balances = balances;
        }
    }

    function removeStakingContract(uint256 index) external onlyOwner {
        require(index < stakingContracts.length);
        stakingContracts[index] = stakingContracts[stakingContracts.length - 1];
        stakingContracts.pop();
    }

    function addStakingContract(
        address stakingContract,
        IApeFactory factoryContract
    ) public onlyOwner {
        stakingContracts.push(stakingContract);
        stakingContractToFactory[stakingContract] = factoryContract;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPoolManager {
    function allNewPools() external view returns (address[] memory);

    function allLegacyPools() external view returns (address[] memory);

    function viewTotalGovernanceHoldings(address userAddress)
        external
        view
        returns (uint256);

    function getActivePoolCount() external view returns (uint256);

    function allActivePools() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IMasterApe {
    function BONUS_MULTIPLIER() external view returns (uint256);

    function cake() external view returns (address);

    function cakePerBlock() external view returns (uint256);

    function devaddr() external view returns (address);

    function owner() external view returns (address);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function renounceOwnership() external;

    function startBlock() external view returns (uint256);

    function syrup() external view returns (address);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function updateMultiplier(uint256 multiplierNumber) external;

    function poolLength() external view returns (uint256);

    function checkPoolDuplicate(address _lpToken) external view;

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function dev(address _devaddr) external;

    function lpToken(uint256 input) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}