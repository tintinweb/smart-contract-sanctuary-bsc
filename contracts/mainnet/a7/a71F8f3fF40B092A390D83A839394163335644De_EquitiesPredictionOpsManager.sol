// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

import ".././Interface/IBhavishPrediction.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

interface IBhavishEquitiesPrediction is IBhavishPrediction {
    function shouldExecuteRound() external view returns (bool);

    function isStartPredictionMarket() external view returns (bool);
}

contract EquitiesPredictionOpsManager is Ownable {
    IBhavishEquitiesPrediction[] public predictionMarkets;

    constructor(IBhavishEquitiesPrediction[] memory _bhavishPrediction) {
        for (uint256 i = 0; i < _bhavishPrediction.length; i++) {
            setPredicitionMarket(_bhavishPrediction[i]);
        }
    }

    function setPredicitionMarket(IBhavishEquitiesPrediction _bhavishPredicition) public onlyOwner {
        require(address(_bhavishPredicition) != address(0), "Invalid predicitions");

        predictionMarkets.push(_bhavishPredicition);
    }

    function removePredictionMarket(IBhavishPrediction _bhavishPrediction) public onlyOwner {
        require(address(_bhavishPrediction) != address(0), "Invalid predicitions");

        for (uint256 i = 0; i < predictionMarkets.length; i++) {
            if (predictionMarkets[i] == _bhavishPrediction) {
                predictionMarkets[i] = predictionMarkets[predictionMarkets.length - 1];
                predictionMarkets.pop();
                break;
            }
        }
    }

    /**
     * perform  task execution
     */
    function execute() public {
        for (uint256 i = 0; i < predictionMarkets.length; i++) {
            if (predictionMarkets[i].shouldExecuteRound() || predictionMarkets[i].isStartPredictionMarket()) {
                predictionMarkets[i].executeRound();
            }
        }
    }

    /**
     *checks the pre condition before executing op task
     */
    function canPerformTask() external view returns (bool canPerform) {
        for (uint256 i = 0; i < predictionMarkets.length; i++) {
            canPerform = predictionMarkets[i].shouldExecuteRound() || predictionMarkets[i].isStartPredictionMarket();
            if (canPerform) break;
        }
    }
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

interface IBhavishPrediction {
    enum RoundState {
        CREATED,
        STARTED,
        ENDED,
        CANCELLED
    }

    struct Round {
        uint256 roundId;
        RoundState roundState;
        uint256 upPredictAmount;
        uint256 downPredictAmount;
        uint256 totalAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        uint256 startPrice;
        uint256 endPrice;
        uint256 roundStartTimestamp;
        uint256 roundEndTimestamp;
    }

    struct BetInfo {
        uint256 upPredictAmount;
        uint256 downPredictAmount;
        uint256 amountDispersed;
    }

    struct AssetPair {
        bytes32 underlying;
        bytes32 strike;
    }

    struct PredictionMarketStatus {
        bool startPredictionMarketOnce;
        bool createPredictionMarketOnce;
    }

    /**
     * @notice Create Round Zero round
     * @dev callable by Operator
     * @param _roundzeroStartTimestamp: round zero round start timestamp
     */
    function createPredictionMarket(uint256 _roundzeroStartTimestamp) external;

    /**
     * @notice Start Zero round
     * @dev callable by Operator
     */
    function startPredictionMarket() external;

    /**
     * @notice Execute round
     * @dev Callable by Operator
     */
    function executeRound() external;

    function getCurrentRoundDetails() external view returns (IBhavishPrediction.Round memory);

    function refundUsers(uint256 _predictRoundId, address userAddress) external;

    function getAverageBetAmount(uint256[] calldata roundIds, address userAddress) external returns (uint256);
}

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