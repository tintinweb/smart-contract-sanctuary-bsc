// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../strategies/IBonfireStrategicCalls.sol";
import "../strategies/IBonfireStrategyAccumulator.sol";

/*
 * Strategies can be suggested by anyone, but owner needs to add them.
 * Strategies are dedicated to a single Token and need to implement
 * IBonfireStrategicCalls interface.
 * AlwaysStrategies will be executed at any call (up to maxCount many of them
 * from first to last)
 * RandomStrategies will be executed randomly (up to the remaining from
 * maxCount)
 * It's up to the admin to make sure that strategies are either 'always' or
 * 'random', the contract doesn't check that.
 * The only problem with strategies occuring in both though is that the quote
 * will most likely not be accurate anymore.
 */

contract BonfireStrategyAccumulator is IBonfireStrategyAccumulator, Ownable {
    mapping(address => address[]) public randomStrategies;
    mapping(address => address[]) public alwaysStrategies;
    mapping(address => address[]) public suggestedStrategies;
    address[] public tokens;

    uint256 _hiddenRandomValue;

    event StrategySuggestionEvent(
        address indexed strategy,
        address indexed sender,
        address indexed token
    );
    event AlwaysStrategyUpdate(
        address indexed strategy,
        address indexed token,
        bool enable
    );
    event RandomStrategyUpdate(
        address indexed strategy,
        address indexed token,
        bool enable
    );
    event TokenAdded(address token);

    constructor(address admin) Ownable() {
        transferOwnership(admin);
    }

    modifier ensure(uint256 deadline) {
        require(
            deadline >= block.timestamp,
            "BonfireStrategyAccumulator: expired"
        );
        _;
    }

    function tokenRegistered(address token)
        external
        view
        override
        returns (bool)
    {
        if (alwaysStrategies[token].length > 0) return true;
        else if (randomStrategies[token].length > 0) return true;
        else return false;
    }

    function currentRandomValue() public view returns (uint256 value) {
        value = _hiddenRandomValue;
    }

    function projectedRandomValue(uint256 _currentRandomValue)
        public
        pure
        returns (uint256 value)
    {
        value = uint256(keccak256(abi.encode(_currentRandomValue)));
    }

    function randomValue() internal returns (uint256 value) {
        value = _hiddenRandomValue;
        _hiddenRandomValue = projectedRandomValue(value);
    }

    function alwaysStrategiesLength(address token)
        external
        view
        returns (uint256)
    {
        return alwaysStrategies[token].length;
    }

    function randomStrategiesLength(address token)
        external
        view
        returns (uint256)
    {
        return randomStrategies[token].length;
    }

    function _addToken(address token) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) return;
        }
        tokens.push(token);
        emit TokenAdded(token);
    }

    function setApproveForRandom(address strategy, bool enable)
        external
        onlyOwner
    {
        address token = IBonfireStrategicCalls(strategy).token();
        _addToken(token);
        emit RandomStrategyUpdate(strategy, token, enable);
        for (uint256 i = 0; i < randomStrategies[token].length; i++) {
            if (randomStrategies[token][i] == strategy) {
                require(
                    enable == false,
                    "BonfireStrategyAccumulator: wrong setting"
                );
                randomStrategies[token][i] = randomStrategies[token][
                    randomStrategies[token].length - 1
                ];
                randomStrategies[token].pop();
                return;
            }
        }
        require(enable == true, "BonfireStrategyAccumulator: wrong setting");
        randomStrategies[token].push(strategy);
    }

    function setApproveForAlways(address strategy, bool enable)
        external
        onlyOwner
    {
        address token = IBonfireStrategicCalls(strategy).token();
        _addToken(token);
        emit AlwaysStrategyUpdate(strategy, token, enable);
        for (uint256 i = 0; i < alwaysStrategies[token].length; i++) {
            if (alwaysStrategies[token][i] == strategy) {
                require(
                    enable == false,
                    "BonfireStrategyAccumulator: wrong setting"
                );
                alwaysStrategies[token][i] = alwaysStrategies[token][
                    alwaysStrategies[token].length - 1
                ];
                alwaysStrategies[token].pop();
                return;
            }
        }
        require(enable == true, "BonfireStrategyAccumulator: wrong setting");
        alwaysStrategies[token].push(strategy);
    }

    function suggestStrategy(address strategy) external {
        address token = IBonfireStrategicCalls(strategy).token();
        suggestedStrategies[token].push(strategy);
        emit StrategySuggestionEvent(strategy, token, msg.sender);
    }

    function quote(
        address token,
        uint256 threshold,
        uint256 maxCount
    )
        external
        view
        override
        returns (uint256 expectedGains, uint256 expectedCount)
    {
        for (uint256 i = 0; i < alwaysStrategies[token].length; i++) {
            uint256 g = IBonfireStrategicCalls(alwaysStrategies[token][i])
                .quote();
            if (g > threshold) {
                expectedCount++;
                expectedGains += g;
            }
            if (maxCount == expectedCount)
                return (expectedGains, expectedCount);
        }
        uint256 remaining = maxCount - expectedCount;
        remaining = remaining < randomStrategies[token].length
            ? remaining
            : randomStrategies[token].length;
        if (remaining == 0)
            //since maxCount must have been > 0 in the line before this means there are no random strategies
            return (expectedGains, expectedCount);
        uint256 value = currentRandomValue();
        uint256 testWorthy = randomStrategies[token].length;
        bool[] memory used = new bool[](testWorthy);
        uint256 index = value % testWorthy;
        for (uint256 _i = 0; _i < remaining; _i++) {
            uint256 g;
            while (g < threshold) {
                while (used[index] == true) {
                    index = value % randomStrategies[token].length;
                    value = projectedRandomValue(value);
                }
                g = IBonfireStrategicCalls(randomStrategies[token][index])
                    .quote();
                testWorthy--;
                if (testWorthy == 0)
                    return (expectedGains + g, expectedCount + 1);
                used[index] = true;
            }
            expectedGains += g;
            expectedCount++;
        }
    }

    function execute(
        address token,
        uint256 threshold,
        uint256 deadline,
        address to,
        uint256 maxCount
    )
        external
        override
        ensure(deadline)
        returns (uint256 gains, uint256 count)
    {
        for (uint256 i = 0; i < alwaysStrategies[token].length; i++) {
            uint256 g = IBonfireStrategicCalls(alwaysStrategies[token][i])
                .execute(threshold, to);
            if (g > 0) {
                count++;
                gains += g;
                if (count == maxCount) return (gains, count);
            }
        }
        uint256 remaining = maxCount - count;
        remaining = remaining < randomStrategies[token].length
            ? remaining
            : randomStrategies[token].length;
        if (remaining == 0)
            //since maxCount must have been > 0 in the line before this means there are no random strategies
            return (gains, count);
        uint256 testWorthy = randomStrategies[token].length;
        uint256 index = randomValue() % randomStrategies[token].length;
        bool[] memory used = new bool[](testWorthy);
        for (uint256 _i = 0; _i < remaining; _i++) {
            uint256 g;
            while (g == 0) {
                while (used[index] == true) {
                    index = randomValue() % randomStrategies[token].length;
                }
                g = IBonfireStrategicCalls(randomStrategies[token][index])
                    .execute(threshold, to);
                testWorthy--;
                used[index] = true;
                if (testWorthy == 0) return (gains, count);
            }
            count++;
            gains += g;
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategicCalls {
    function token() external view returns (address token);

    function quote() external view returns (uint256 expectedGains);

    function execute(uint256 threshold, address to)
        external
        returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategyAccumulator {
    function tokenRegistered(address token)
        external
        view
        returns (bool registered);

    function quote(
        address token,
        uint256 threshold,
        uint256 maxCount
    ) external view returns (uint256 expectedGains, uint256 expectedCount);

    function execute(
        address token,
        uint256 threshold,
        uint256 deadline,
        address to,
        uint256 maxCount
    ) external returns (uint256 gains, uint256 count);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}