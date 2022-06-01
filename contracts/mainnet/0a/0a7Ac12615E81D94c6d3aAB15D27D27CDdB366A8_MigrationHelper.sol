/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: contracts/MigrationHelper.sol


pragma solidity ^0.8.7;



// import "hardhat/console.sol";

interface IERC20Contract {
    // External ERC20 contract
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Staking {
    mapping(address => uint256) public _tokenStaked;
    mapping(address => uint256) public _tokenStakedAt;

    mapping(address => uint256) public _rewardTallyBefore;
    uint256 public _rewardPerTokenCumulative;

    uint256 public _rewardPerSec;
    uint256 public _totalStakes;
}

/**
 * LPStaking smart contract Liqidity Pool Token or LOA token staking
 * Initialization: call setRewardsPerSecond() function to set rewards for second
 * updateWithdrawalFee() to set withdrawal fees. It accepts values in days[] and fee[]. fee value provided in 1/10th of percentage.
 * stake() to stake Token
 * unstake() to unstake Token
 */
contract MigrationHelper {

    IERC20Contract public _loaToken;
    Staking public _stakingContract;
    mapping(address=> uint8) private _admins;
    address private _treasury;
    uint256  public MULTIPLIER = 1_000_000_000_000;

    constructor(address loaContract, address treasury, address stakingContract) {
        _admins[msg.sender] = 1;
        _stakingContract = Staking(stakingContract);
        _loaToken = IERC20Contract(loaContract);
        _treasury = treasury;
    }

    mapping(address => uint256) public _rewardTallyBefore;
    mapping(address => uint8) public _rewardDistributed;
    uint256 public _rewardPerTokenCumulative;

    uint256 public _rewardDistributedLast = 1653998400;
    uint256 public _rewardPerSec;
    uint256 public _totalStakes;
    uint256 public _endtime;

    uint256 private _lastMajorWithdrawReported;
    uint256 private _lastAmountWithdrawn;
    bool public _withdrawBlocked;
    uint256 public _withdrawLimitPercent;

    modifier validAdmin() {
        require(_admins[msg.sender] == 1, "You are not authorized.");
        _;
    }

    function modifyAdmin(address adminAddress, bool add) validAdmin public {
        if(add)
            _admins[adminAddress] = 1;
        else {
            require(adminAddress != msg.sender, "Cant remove self as admin");
            delete _admins[adminAddress];
        }
    }

    function setRewardsPerSecond(uint256 rewardPerSec) validAdmin public {
        _rewardPerSec = rewardPerSec;
    }

    function setEndTime(uint256 endtime) validAdmin public {
        _endtime = endtime;
        _totalStakes = _stakingContract._totalStakes();
    }

    function harvest() public {
        require(_rewardDistributed[msg.sender] == 0, "User has harvested already.");
        require(_stakingContract._tokenStaked(msg.sender) > 0, "User has not staked.");
        require(_endtime > 0, "harvest is not enabled.");

        uint256 currentTime = block.timestamp;
        if(currentTime > _endtime) {
            currentTime = _endtime;
        }

        uint256 rewards = calcRewards(msg.sender);
        _loaToken.transfer(msg.sender, rewards);
        _rewardDistributed[msg.sender] = 1;
    }

    function register(address[] memory senders) public {
        require(_rewardPerSec > 0, "There is no rewards allocated");

        for(uint256 i = 0 ; i < senders.length; i++) {
            address sender = senders[i];
            uint256 timestamp = _stakingContract._tokenStakedAt(sender);

            if(timestamp == 0)
                continue;

            uint256 currentTime = timestamp;
            if(currentTime < _rewardDistributedLast) {
                currentTime = _rewardDistributedLast;
            }

            uint256 secs = currentTime - _rewardDistributedLast;

            _rewardPerTokenCumulative = _rewardPerTokenCumulative + (_rewardPerSec * secs * MULTIPLIER / _totalStakes);
            _rewardDistributedLast = currentTime;
            _rewardTallyBefore[sender] = _rewardPerTokenCumulative;
        }
    }

    function calcRewards(address sender) public view returns (uint256) {
        if(_stakingContract._tokenStakedAt(sender) == 0)
            return 0;

        uint256 endtime = block.timestamp > _endtime ? _endtime : block.timestamp;
        uint256 secs = 0;
        if(_rewardDistributedLast < endtime) {
            secs = endtime - _rewardDistributedLast;
        }
        
        if(_stakingContract._tokenStaked(sender) > 0 ) {
                uint256 rewards = (_stakingContract._tokenStaked(sender) * (_rewardPerTokenCumulative - _rewardTallyBefore[sender])) / MULTIPLIER
                    +   (_rewardPerSec * secs * _stakingContract._tokenStaked(sender) / _totalStakes);
                return rewards;
            }
        return 0;
    }

    function extract(address tokenAddress) validAdmin public {
        if (tokenAddress == address(0)) {
            payable(_treasury).transfer(address(this).balance);
            return;
        }

        IERC20Contract token = IERC20Contract(tokenAddress);
        token.transfer(_treasury, token.balanceOf(address(this)));
    }

}