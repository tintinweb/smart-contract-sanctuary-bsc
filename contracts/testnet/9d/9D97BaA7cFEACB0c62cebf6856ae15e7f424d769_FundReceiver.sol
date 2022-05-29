// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

interface IERC20 {
    function decimals() external view returns (uint8 _decimals);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);
}

contract FundReceiver is Ownable, ReentrancyGuard {
    address public token;
    uint256 public tokensPerBnb; // will be updated when presale ends
    uint256 public totalCapacity;
    uint256 public totalRaised;
    mapping(address => uint256) public contributions;
    address[] public contributors;
    mapping(address => uint256) public returnedTokens;

    uint256[] public allowedContributeAmounts = [
        1 ether,
        2 ether,
        3 ether,
        4 ether,
        5 ether
    ];

    constructor(address _token, uint256 _totalCapacity) {
        token = _token;
        totalCapacity = _totalCapacity * (1 ether);
    }

    receive() external payable {}

    function inContributors(address addr) public view returns (bool) {
        for (uint256 index = 0; index < contributors.length; index++) {
            if (contributors[index] == addr) {
                return true;
            }
        }
        return false;
    }

    function updateTokenAddress(address addr) public onlyOwner {
        token = addr;
    }

    function updateTokensPerBnb(uint256 val) public onlyOwner {
        tokensPerBnb = val;
    }

    function updateTotalCapacity(uint256 _totalCapacity) public onlyOwner {
        totalCapacity = _totalCapacity;
    }

    function isContributeAmountLegal(uint256 amount)
        internal
        view
        returns (bool)
    {
        for (
            uint256 index = 0;
            index < allowedContributeAmounts.length;
            index++
        ) {
            if (allowedContributeAmounts[index] == amount) {
                return true;
            }
        }
        return false;
    }

    function contribute() public payable nonReentrant {
        require(
            isContributeAmountLegal(msg.value),
            'contribution amount is illegal'
        );
        require(totalRaised < totalCapacity, 'funds filled');
        require(
            totalRaised + msg.value <= totalCapacity,
            'try to contribute less'
        );

        uint256 amount = msg.value;
        if (amount > totalCapacity - totalRaised) {
            amount = totalCapacity - totalRaised;
        }
        totalRaised += amount;

        contributions[msg.sender] += amount;
        if (!inContributors(msg.sender)) {
            contributors.push(msg.sender);
        }

        if (msg.value - amount > 0) {
            payable(msg.sender).transfer(msg.value - amount);
        }
    }

    function disperseTokens(uint8 mode) public onlyOwner {
        if (mode == 0) {
            for (uint256 index = 0; index < contributors.length; index++) {
                uint256 amount = returnedTokens[contributors[index]];
                if (amount > 0) {
                    IERC20(token).transferFrom(
                        msg.sender,
                        contributors[index],
                        amount
                    );
                }
            }
            return;
        }

        for (uint256 index = 0; index < contributors.length; index++) {
            uint256 amount = returnedTokens[contributors[index]];
            if (amount > 0) {
                IERC20(token).transfer(contributors[index], amount);
            }
        }
        return;
    }

    function updateReturnedTokens() public onlyOwner {
        for (uint256 index = 0; index < contributors.length; index++) {
            address contributor = contributors[index];
            uint256 contribution = contributions[contributor];
            uint256 returnedTokenAmount = (contribution / 1 ether) *
                tokensPerBnb;
            returnedTokens[contributor] = returnedTokenAmount;
        }
    }

    function withdrawTokens(address _token, uint256 amount) public onlyOwner {
        if (_token == address(0x0)) {
            if (amount != 0) {
                payable(msg.sender).transfer(amount);
            } else {
                uint256 bnbBalance = address(this).balance;
                payable(msg.sender).transfer(bnbBalance);
            }
            return;
        }
        if (amount != 0) {
            IERC20(_token).transfer(msg.sender, amount);
        } else {
            uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transfer(msg.sender, tokenBalance);
        }
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}