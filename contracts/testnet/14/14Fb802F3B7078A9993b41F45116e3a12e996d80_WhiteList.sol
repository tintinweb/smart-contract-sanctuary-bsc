/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

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

// File: contracts/WhiteList.sol


pragma solidity ^0.8.0;


contract WhiteList {
    using Counters for Counters.Counter;
    address private immutable owner;
    mapping(uint256 => address) whiteList;
    mapping(address => bool) isWhiteList;
    uint256 public maximumWL;
    Counters.Counter private currentWL;
    Counters.Counter private idxWhiteList;

    constructor(uint256 _maximumWL) {
        owner = msg.sender;
        maximumWL = _maximumWL;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function getCurrentWl() public view returns (uint256) {
        return currentWL.current();
    }

    function addWhitelist(address account) public onlyOwner {
        require(!isWhiteList[account], "Have been whitelist");
        require(currentWL.current() < maximumWL, "Max whitelist");
        currentWL.increment();
        idxWhiteList.increment();
        whiteList[idxWhiteList.current()] = account;
        isWhiteList[account] = true;
    }

    function removeFromWhiteList(address account) public onlyOwner {
        require(isWhiteList[account], "Haven't been whitelist");
        currentWL.decrement();
        isWhiteList[account] = false;
    }
}