// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces/ILogicContract.sol";
import "./Interfaces/IStrategyContract.sol";
import "./Interfaces/IStrategyStatistics.sol";

interface AutomationCompatibleInterface {
    /**
     * @notice method that is simulated by the keepers to see if any work actually
     * needs to be performed. This method does does not actually need to be
     * executable, and since it is only ever simulated it can consume lots of gas.
     * @dev To ensure that it is never called, you may want to add the
     * cannotExecute modifier from KeeperBase to your implementation of this
     * method.
     * @param checkData specified in the upkeep registration so it is always the
     * same for a registered upkeep. This can easily be broken down into specific
     * arguments using `abi.decode`, so multiple upkeeps can be registered on the
     * same contract and easily differentiated by the contract.
     * @return upkeepNeeded boolean to indicate whether the keeper should call
     * performUpkeep or not.
     * @return performData bytes that the keeper should call performUpkeep with, if
     * upkeep is needed. If you would like to encode data to decode later, try
     * `abi.encode`.
     */
    function checkUpkeep(
        bytes calldata checkData
    ) external returns (bool upkeepNeeded, bytes memory performData);

    /**
     * @notice method that is actually executed by the keepers, via the registry.
     * The data returned by the checkUpkeep simulation will be passed into
     * this method to actually be executed.
     * @dev The input to this method should not be trusted, and the caller of the
     * method should not even be restricted to any single registry. Anyone should
     * be able call it, and the input should be validated, there is no guarantee
     * that the data passed in is the performData returned from checkUpkeep. This
     * could happen due to malicious keepers, racing keepers, or simply a state
     * change while the performUpkeep transaction is waiting for confirmation.
     * Always validate the data passed in.
     * @param performData is the data which was passed back from the checkData
     * simulation. If it is encoded, it can easily be decoded into other types by
     * calling `abi.decode`. This data should not be trusted, and should be
     * validated against the contract's current state.
     */
    function performUpkeep(bytes calldata performData) external;
}

contract Automation is Pausable, Ownable, AutomationCompatibleInterface {
    address public keeper;
    address public strategyStatistics;

    bool public isEasy;

    struct KeeperVenusCalldata {
        address venusStrategy;
        uint256 venusBorrowRateMax;
        uint256 venusBorrowRateMin;
        uint256 venusLendingMin;
    }

    event SetKeeper(address keeper);
    event SetStrategyStatistics(address strategyStatistics);

    event VenusLending(address strategy);
    event VenusBuild(address strategy, uint256 amount);
    event VenusDestory(address strategy, uint256 percentage);
    event VenusClaimXVS(address strategy);
    event VenusClaimFarming(address strategy);
    event perform(uint256);

    constructor() {
        isEasy = true;
    }

    receive() external payable {}

    /*** modifiers ***/

    modifier onlyKeeper() {
        require(msg.sender == keeper, "K0");
        _;
    }

    /*** Owner function ***/

    /**
     * @notice set Keeper address
     * @param _keeper venus Strategy address
     */
    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0), "K1");
        keeper = _keeper;

        emit SetKeeper(_keeper);
    }

    /**
     * @notice set StrategyStatistics address
     * @param _strategyStatistics StrategyStatistics address
     */
    function setStrategyStatistics(
        address _strategyStatistics
    ) external onlyOwner {
        require(_strategyStatistics != address(0), "K1");
        strategyStatistics = _strategyStatistics;

        emit SetStrategyStatistics(_strategyStatistics);
    }

    function setIsEasy(bool _isEasy) external onlyOwner {
        isEasy = _isEasy;
    }

    /**
     * @notice Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*** Keeper Perform function ***/

    /**
     * @notice Keeper call to perform claimVenusXVS
     * @param strategy address of Venus Strategy
     */
    function performVenusClaimXVS(
        address strategy
    ) external whenNotPaused onlyKeeper {
        if (!isEasy) {
            IStrategyVenus(strategy).claimRewards(0);
        }

        emit VenusClaimXVS(strategy);
    }

    /**
     * @notice Keeper call to perform claimVenusFarming
     * @param strategy address of Venus Strategy
     */
    function performVenusClaimFarming(
        address strategy
    ) external whenNotPaused onlyKeeper {
        IStrategyVenus(strategy).claimRewards(1);

        emit VenusClaimFarming(strategy);
    }

    /**
     * @notice Keeper call to perform Build/Destroy for borrowRate
     * @param strategy address of Venus Strategy
     * @param _max venusBorrowRateMax (< 10000)
     * @param _min venusBorrowRateMax (< 10000)
     */
    function performVenusBorrowRate(
        address strategy,
        uint256 _max,
        uint256 _min
    ) public whenNotPaused onlyKeeper {
        require(_max >= _min, "K2");
        require(_max <= 10000, "K3");

        (
            uint256 totalBorrowLimitUSD,
            ,
            ,
            uint256 borrowRate,

        ) = IStrategyStatistics(strategyStatistics).getStrategyBalance(
                IStrategyContract(strategy).logic(),
                0
            );

        borrowRate = borrowRate / 1e14;

        // If borrowRate > max, destory (rate - max) / rate + 1%
        if (borrowRate > _max) {
            uint256 destroyPercentage = ((borrowRate - _max) * 10000) /
                borrowRate +
                100;
            IStrategyVenus(strategy).destroy(destroyPercentage);

            emit VenusDestory(strategy, destroyPercentage);
            return;
        }

        // If borrowRate < min, build (min - rate + 1%) * borrowLimit
        if (borrowRate < _min) {
            uint256 buildAmountUSD = (totalBorrowLimitUSD *
                (_min - borrowRate + 100)) / 10000;
            IStrategyVenus(strategy).build(buildAmountUSD);

            emit VenusBuild(strategy, buildAmountUSD);
            return;
        }
    }

    /**
     * @notice Keeper call to perform VenusLending
     * @param strategy address of Venus Strategy
     * @param venusLendingMin min value for venus lending in USD (decimal : 18)
     * @return : true - lending is done, false - available amount is not enough
     */
    function performVenusLending(
        address strategy,
        uint256 venusLendingMin
    ) public whenNotPaused onlyKeeper returns (bool) {
        if (_checkVenusLending(strategy, venusLendingMin)) {
            IStrategyVenus(strategy).lendToken();
            IStrategyVenus(strategy).build(venusLendingMin);

            emit VenusLending(strategy);
            emit VenusBuild(strategy, venusLendingMin);
            return true;
        }

        return false;
    }

    /*** Chainlink function ***/

    /**
     * @notice Chainlink call to perform check
     * @param checkData calldata from Chainlink
     * @return upkeepNeeded if true performUpkeep() is run
     * @return performData data passed to performUpkeep()
     */
    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        whenNotPaused
        returns (bool upkeepNeeded, bytes memory performData)
    {
        // Decode calldata
        KeeperVenusCalldata memory venusCalldata = abi.decode(
            checkData,
            (KeeperVenusCalldata)
        );

        upkeepNeeded = false;
        uint8 checkResult = 0;

        // Check VenusLending
        if (
            !upkeepNeeded &&
            _checkVenusLending(
                venusCalldata.venusStrategy,
                venusCalldata.venusLendingMin
            )
        ) {
            upkeepNeeded = true;
            checkResult = 1;
        }

        // Check Venus BorrowRate
        if (
            !upkeepNeeded &&
            _checkVenusBorrowRate(
                venusCalldata.venusStrategy,
                venusCalldata.venusBorrowRateMax,
                venusCalldata.venusBorrowRateMin
            )
        ) {
            upkeepNeeded = true;
            checkResult = 2;
        }

        performData = abi.encode(checkResult, venusCalldata);
    }

    /**
     * @notice Chainlink call to perform keep
     * @param performData calldata from Chainlink, generated from checkUpkeep()
     */
    function performUpkeep(
        bytes calldata performData
    ) external override whenNotPaused {
        // Decode data
        (uint256 checkResult, KeeperVenusCalldata memory venusCalldata) = abi
            .decode(performData, (uint256, KeeperVenusCalldata));

        if (isEasy) {
            emit perform(checkResult);
        } else {
            // Venus Lending
            if (
                checkResult == 1 &&
                performVenusLending(
                    venusCalldata.venusStrategy,
                    venusCalldata.venusLendingMin
                )
            ) {
                return;
            }

            // Venus BorrowRate
            if (checkResult == 2) {
                performVenusBorrowRate(
                    venusCalldata.venusStrategy,
                    venusCalldata.venusBorrowRateMax,
                    venusCalldata.venusBorrowRateMin
                );
            }
        }
    }

    /*** Private function ***/

    /**
     * @notice Check venus Lending available
     * @param strategy address of Venus Strategy
     * @param venusLendingMin min value for venus lending in USD (decimal : 18)
     * @return : true - available about is enough - available amount is not enough
     */
    function _checkVenusLending(
        address strategy,
        uint256 venusLendingMin
    ) public view returns (bool) {
        return
            IStrategyStatistics(strategyStatistics).getStrategyAvailable(
                IStrategyContract(strategy).logic(),
                0
            ) > venusLendingMin
                ? true
                : false;
    }

    /**
     * @notice Check venus Borrow Rate available
     * @param strategy address of Venus Strategy
     * @param _max venusBorrowRateMax (< 10000)
     * @param _min venusBorrowRateMax (< 10000)
     * @return : true - build/destory is required, false - no need to perform
     */
    function _checkVenusBorrowRate(
        address strategy,
        uint256 _max,
        uint256 _min
    ) public view returns (bool) {
        // Get Strategy Borrow rate
        (, , , uint256 borrowRate, ) = IStrategyStatistics(strategyStatistics)
            .getStrategyBalance(IStrategyContract(strategy).logic(), 0);

        borrowRate = borrowRate / 1e14;

        // If borrowRate > max, destory ( rate - min)
        if (borrowRate > _max) {
            return true;
        }

        // If borrowRate < min, build (min - rate) * borrowLimit
        if (borrowRate < _min) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface ILogicContract {
    function addXTokens(
        address token,
        address xToken,
        uint8 leadingTokenType
    ) external;

    function approveTokenForSwap(address token) external;

    function claim(address[] calldata xTokens, uint8 leadingTokenType) external;

    function mint(address xToken, uint256 mintAmount)
        external
        returns (uint256);

    function borrow(
        address xToken,
        uint256 borrowAmount,
        uint8 leadingTokenType
    ) external returns (uint256);

    function repayBorrow(address xToken, uint256 repayAmount) external;

    function redeemUnderlying(address xToken, uint256 redeemAmount)
        external
        returns (uint256);

    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function addLiquidityETH(
        address swap,
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH);

    function addEarnToStorage(uint256 amount) external;

    function enterMarkets(address[] calldata xTokens, uint8 leadingTokenType)
        external
        returns (uint256[] memory);

    function returnTokenToStorage(uint256 amount, address token) external;

    function takeTokenFromStorage(uint256 amount, address token) external;

    function returnETHToMultiLogicProxy(uint256 amount) external;

    function deposit(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external;

    function returnToken(uint256 amount, address token) external; // for StorageV2 only

    function multiLogicProxy() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IStrategyContract {
    function releaseToken(uint256 amount, address token) external;

    function logic() external view returns (address);
}

interface IStrategyVenus {
    function farmingPair() external view returns (address);

    function lendToken() external;

    function build(uint256 usdAmount) external;

    function destroy(uint256 percentage) external;

    function claimRewards(uint8 mode) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
struct XTokenInfo {
    string name;
    address xToken;
    uint256 totalSupply;
    uint256 totalSupplyUSD;
    uint256 lendingAmount;
    uint256 lendingAmountUSD;
    uint256 borrowAmount;
    uint256 borrowAmountUSD;
    uint256 borrowLimitUSD;
    uint256 underlyingBalance;
    uint256 priceUSD;
}

struct FarmingPairInfo {
    uint256 index;
    address lpToken;
    uint256 farmingAmount;
    uint256 rewardsAmount;
    uint256 rewardsAmountUSD;
}

struct WalletInfo {
    string name;
    address token;
    uint256 balance;
    uint256 balanceUSD;
}

struct PriceInfo {
    address token;
    uint256 priceUSD;
}

interface IStrategyStatistics {
    function getStrategyAvailable(address logic, uint8 strategyType)
        external
        view
        returns (uint256 totalAvailableUSD);

    function getStrategyBalance(address logic, uint8 strategyType)
        external
        view
        returns (
            uint256 totalBorrowLimitUSD,
            uint256 totalSupplyUSD,
            uint256 totalBorrowUSD,
            uint256 percentLimit,
            XTokenInfo[] memory xTokensInfo
        );
}