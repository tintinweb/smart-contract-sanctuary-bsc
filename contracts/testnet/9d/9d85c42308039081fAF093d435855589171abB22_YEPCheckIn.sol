/**
 *Submitted for verification at BscScan.com on 2023-01-09
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

// File: CheckIn.sol


pragma solidity 0.8.16;


contract YEPCheckIn {
    using Counters for Counters.Counter;
    Counters.Counter private _guestCheckedIn;

    mapping (uint256 => uint256) itemTokenId;
    mapping (uint256 => string) itemToPhoneNum;
    mapping (string => uint256) phoneNumToTokenId;

    uint256 public totalNfts;

    constructor(uint256[] memory totalNftIds){
        totalNfts = totalNftIds.length;
        
        for (uint256 i = 0; i < totalNfts; i++){
            itemTokenId[i + 1] = totalNftIds[i];
        }
    }

    function checkIn(string memory phoneNumber) public {
        require(_guestCheckedIn.current() + 1 <= totalNfts, "Out of stock");
        require(phoneNumToTokenId[phoneNumber] == 0, "Phone number registered");

        _guestCheckedIn.increment();
        itemToPhoneNum[_guestCheckedIn.current()] = phoneNumber;
        phoneNumToTokenId[phoneNumber] = itemTokenId[_guestCheckedIn.current()];
    }

    function guestCheckedIn() public view returns(uint256){
        return _guestCheckedIn.current();
    }

    function phoneNumberToTokenId(string memory phoneNum) public view returns (uint256){
        return phoneNumToTokenId[phoneNum];
    }
}