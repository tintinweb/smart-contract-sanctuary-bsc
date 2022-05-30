/**
 *Submitted for verification at BscScan.com on 2022-05-29
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

// File: contracts/LPStaking.sol


pragma solidity ^0.8.7;




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

/**
 * LPStaking smart contract Liqidity Pool Token or LOA token staking
 * Initialization: call setRewardsPerSecond() function to set rewards for second
 * updateWithdrawalFee() to set withdrawal fees. It accepts values in days[] and fee[]. fee value provided in 1/10th of percentage.
 * stake() to stake Token
 * unstake() to unstake Token
 */
contract LPStaking is ReentrancyGuard {

    IERC20Contract public _loaToken;
    IERC20Contract public _stakeToken;
    mapping(address=> uint8) private _admins;
    address private _treasury;

    constructor(address loaContract, address stakeContract) {
        _admins[msg.sender] = 1;
        _loaToken = IERC20Contract(loaContract);
        if(loaContract == stakeContract)
            _stakeToken = _loaToken;
        else 
            _stakeToken = IERC20Contract(stakeContract);

        _rewardDistributedLast = block.timestamp;
    }

    address[] public _stakers;
    uint256[] public _withdrawDays;
    uint256[] public _withdrawFee;
    mapping(address => uint256) public _tokenStaked;
    mapping(address => uint256) public _tokenStakedAt;

    mapping(address => uint256) public _rewardTallyBefore;
    uint256 public _rewardPerTokenCumulative;

    uint256 public _rewardDistributedLast;
    uint256 public _rewardPerSec;
    uint256 public _totalStakes;

    uint256 private _lastMajorWithdrawReported;
    uint256 private _lastAmountWithdrawn;
    bool public _withdrawBlocked;
    uint256 private _withdrawLimitPercent;


    event Staked(
        address owner,
        uint256 amount
    );

    event Withdrawn(
        address owner,
        uint256 amount,
        uint256 fees
    );

    event RewardClaimed(
        address owner,
        uint256 amount
    );

    modifier validAdmin() {
        require(_admins[msg.sender] == 1, "You are not authorized.");
        _;
    }

    function addAdmin(address newAdmin) validAdmin public {
        _admins[newAdmin] = 1;
    }

    function removeAdmin(address oldAdmin) validAdmin public {
        delete _admins[oldAdmin];
    }

    function setTresury(address treasury) validAdmin public {
        _treasury = treasury;
    }

    function setRewardsPerSecond(uint256 rewardPerSec) validAdmin public {
        _rewardPerSec = rewardPerSec;
    }

    function setWithdrawConstraints(uint256 withdrawLimitPercent) validAdmin public {
        _withdrawLimitPercent = withdrawLimitPercent;
    }

    function removeWithdrawRestriction() validAdmin public {
        _withdrawBlocked = false;
    }

    function updateWithdrawalFee(uint256[] memory dayList, uint256[] memory fees) validAdmin public {
        require(dayList.length + 1 == fees.length, "Data length is incorrected.");

        for(uint256 i = 0; i < _withdrawDays.length; i++) {
            _withdrawDays.pop();
            _withdrawFee.pop();
        }
        for(uint256 i = 0; i < dayList.length; i++) {
            if(i > 0) {
                require(dayList[i] < dayList[i - 1], "Data provided should be in descending order.");
            }
            _withdrawDays.push(dayList[i]);
            _withdrawFee.push(fees[i]);
        }
        _withdrawFee.push(fees[fees.length - 1]);
    }

    function claimRewards() public {
        require(_tokenStaked[msg.sender] > 0, "User has not staked.");

        uint256 currentTime = block.timestamp;
        uint256 secs = currentTime - _rewardDistributedLast;
        uint256 rewards = _tokenStaked[msg.sender] * (_rewardPerTokenCumulative - _rewardTallyBefore[msg.sender]) 
                +   (_rewardPerSec * secs * _tokenStaked[msg.sender] / _totalStakes);

        _loaToken.transfer(msg.sender, rewards);

        _rewardPerTokenCumulative = _rewardPerTokenCumulative + (_rewardPerSec * secs / _totalStakes);
        _rewardDistributedLast = currentTime;

        emit RewardClaimed(msg.sender, rewards);
    }

    function myRewards(address owner) public view returns(uint256, uint256, uint256) {
        if(_tokenStaked[owner] == 0) {
            return (0, _rewardDistributedLast, 0);
        }
        uint256 currentTime = block.timestamp;
        uint256 secs = currentTime - _rewardDistributedLast;
        uint256 rewards = (_tokenStaked[msg.sender] * (_rewardPerTokenCumulative - _rewardTallyBefore[msg.sender])) 
                +   (_rewardPerSec * secs * _tokenStaked[msg.sender] / _totalStakes);
            
        return (rewards, _rewardDistributedLast, ((_tokenStaked[owner]* _rewardPerSec)/ _totalStakes));
    }

    function stake(uint256 amount) public {
        require(_rewardPerSec > 0, "There is no rewards allocated");
        require(_stakeToken.balanceOf(msg.sender) >= amount, "Unavailable balance.");

        uint256 currentTime = block.timestamp;
        uint256 secs = currentTime - _rewardDistributedLast;

        if(_tokenStaked[msg.sender] > 0 ) {
            uint256 rewards = (_tokenStaked[msg.sender] * (_rewardPerTokenCumulative - _rewardTallyBefore[msg.sender])) 
                +   (_rewardPerSec * secs * _tokenStaked[msg.sender] / _totalStakes);
            
            require(_loaToken.transfer(msg.sender, rewards), "Not enough LOA balance available to transfer rewards");
        }

        require(_stakeToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        _tokenStakedAt[msg.sender] = currentTime;
        _totalStakes = _totalStakes + amount;
        _tokenStaked[msg.sender] = _tokenStaked[msg.sender] + amount;
        _rewardPerTokenCumulative = _rewardPerTokenCumulative + (_rewardPerSec * secs / _totalStakes);
        _rewardDistributedLast = currentTime;
        _rewardTallyBefore[msg.sender] = _rewardPerTokenCumulative;
    }

    function unstake(uint256 withdrawAmount) public {
        require(_tokenStaked[msg.sender] >= withdrawAmount, "Unavailable balance.");

        uint256 secs = block.timestamp - _rewardDistributedLast;
        uint256 tokenStaked = _tokenStaked[msg.sender];
        if(tokenStaked > 0 && _rewardPerSec > 0) {
            uint256 rewards = (tokenStaked * (_rewardPerTokenCumulative- _rewardTallyBefore[msg.sender])) 
                +   (_rewardPerSec * secs * tokenStaked/ _totalStakes);
            
            require(_loaToken.transfer(msg.sender, rewards), "Not enough LOA balance available to transfer rewards");
        }

        unstakeWithoutRewards(withdrawAmount);
    }

    function unstakeWithoutRewards(uint256 withdrawAmount) public {
        require(_withdrawBlocked == false, "Withdraw is blocked.");
        require(_tokenStaked[msg.sender] >= withdrawAmount, "Unavailable balance.");

        uint256 currentTime = block.timestamp;
        uint256 secs = currentTime - _rewardDistributedLast;

        uint256 daysElapsed = (currentTime - _tokenStakedAt[msg.sender]) / 86400;

        uint256 deduction = _withdrawFee.length > 0 ? _withdrawFee[_withdrawFee.length - 1] : 0;
        for(uint256 i = 0; i < _withdrawDays.length; i++) {
            if(daysElapsed >= _withdrawDays[i]) {
                deduction = _withdrawFee[i];
                break;
            }
        }

        uint256 amount = withdrawAmount;

        if(deduction > 0) {
            amount -= ((deduction* withdrawAmount)/ 1000);
        }

        require(_stakeToken.transfer(msg.sender, amount), "Transfer failed");

        _totalStakes = _totalStakes - withdrawAmount;
        _tokenStaked[msg.sender] = _tokenStaked[msg.sender] - withdrawAmount;
        _rewardPerTokenCumulative = _totalStakes > 0 ? (_rewardPerTokenCumulative + (_rewardPerSec * secs / _totalStakes)) : 0;
        _rewardDistributedLast = currentTime;

        if(_tokenStaked[msg.sender] > 0) 
            _rewardTallyBefore[msg.sender] = _rewardPerTokenCumulative;
        else {
            delete _rewardTallyBefore[msg.sender];
            delete _tokenStakedAt[msg.sender];
        }


        // If amount withdrawn in last 1 hr is more than allowed percentage of total stakes then withdraw is blocked.
        if(_lastMajorWithdrawReported < currentTime - 3600) {
            _lastMajorWithdrawReported = currentTime;
            _lastAmountWithdrawn = withdrawAmount;
        } else {
            _lastAmountWithdrawn += withdrawAmount;
        }
        if(_totalStakes > 0 && _withdrawLimitPercent > 0 && (_lastAmountWithdrawn * 10000 / _totalStakes) > _withdrawLimitPercent) {
            _withdrawBlocked = true;
        }
    }


    function withdraw() validAdmin public {
        uint256 balance = _stakeToken.balanceOf(address(this)) - _totalStakes;
        _stakeToken.transferFrom(address(this), _treasury, balance);
        _loaToken.transferFrom(address(this), _treasury, _loaToken.balanceOf(address(this)));
    } 

    function extract(address tokenAddress) validAdmin public {
        if (tokenAddress == address(0)) {
            payable(_treasury).transfer(address(this).balance);
            return;
        }

        IERC20Contract token = IERC20Contract(tokenAddress);
        require(token != _stakeToken && token != _loaToken, "Invalid token address");
        token.transferFrom(address(this), _treasury, token.balanceOf(address(this)));
    }
    
}