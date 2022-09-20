// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.17;

contract RNG {
    struct eventsStruct {
        mapping(uint256 => bool) numbers;
        mapping(uint256 => bool) checkNumberExcluded;
        uint256[] numbersArray;
        uint256[] excludedNumbers;
        uint256 startTimeStamp;
        uint256 endTimeStamp;
        uint256 range;
        uint256 numberOfWinners;
        uint256 crrDecidedWinnersLen;
        bool status;
        bool existStatus;
    }

    mapping(uint256 => eventsStruct) public events;

    uint8 eventId = 0;
    uint256[] randomWinners;
    address public owner;

    event eventAdded(uint256 eventId, bool status);
    event randomWinnerNumber(
        uint256 eventId,
        uint256[] newWinners,
        uint256[] totalWinners
    );
    event dataReset(uint256 eventId, bool status);
    event removeAndReset(uint256 eventId, bool status);
    event ownerChanged(address currentOwner, address newOwner);
    event addedNumbersToExclude(uint256 eventId, uint256[] numbersToExclude);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Owner: Caller is not an owner");
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "Address: Invalid address");
        _;
    }

    function changeOwner(address _newAddress) public onlyOwner {
        address crrOwner = owner;
        owner = _newAddress;
        emit ownerChanged(crrOwner, _newAddress);
    }

    // Add event
    function addEvent(
        uint256 _startTimeStamp,
        uint256 _endTimeStamp,
        uint256 _range,
        uint256 _numberOfWinners,
        uint256[] memory _numbersToExclude
    ) public onlyOwner returns (bool) {
        require(
            block.timestamp < _endTimeStamp,
            "TimeStamp: End timestamp should be greater than current timestamp"
        );
        require(events[eventId].existStatus == false, "Event: Already exist");
        require(
            _range > _numbersToExclude.length,
            "Event: Range must be greater then numbers to exclude"
        );
        require(
            _range >= _numberOfWinners,
            "Event: Range must be greater or equal then number of winners"
        );
        require(
            _range >= (_numbersToExclude.length + _numberOfWinners),
            "Event: Range must be greater or equal"
        );

        eventsStruct storage eventObject = events[eventId];
        eventObject.startTimeStamp = _startTimeStamp;
        eventObject.endTimeStamp = _endTimeStamp;
        eventObject.range = _range;
        eventObject.numberOfWinners = _numberOfWinners;
        eventObject.existStatus = true;
        eventObject.excludedNumbers = _numbersToExclude;

        for (uint8 i = 0; i < _numbersToExclude.length; i++) {
            eventObject.checkNumberExcluded[_numbersToExclude[i]] = true;
        }

        emit eventAdded(eventId, true);
        eventId++;
        return true;
    }

    // find random number
    function randomWinner(uint256 _eventId, uint8 loopToIterate)
        public
        onlyOwner
        returns (uint256[] memory)
    {
        eventsStruct storage choosedEvent = events[_eventId];
        require(
            choosedEvent.existStatus == true,
            "Event with this Id not Exist"
        );
        require(choosedEvent.status == false, "Lottery: Already Dised");
        require(
            (choosedEvent.startTimeStamp <= block.timestamp) &&
                (block.timestamp <= choosedEvent.endTimeStamp),
            "TimeStamp: Shoud be in timestamp"
        );

        uint256 randomNumber;
        uint256 count = 0;

        do {
            randomNumber =
                uint256(
                    keccak256(
                        abi.encodePacked(block.timestamp, msg.sender, count)
                    )
                ) %
                choosedEvent.range;

            if (
                choosedEvent.numbers[randomNumber] == false &&
                choosedEvent.checkNumberExcluded[randomNumber] != true
            ) {
                choosedEvent.numbers[randomNumber] = true;
                choosedEvent.numbersArray.push(randomNumber);
                randomWinners.push(randomNumber);
                loopToIterate--;
            }

            count++;
        } while (loopToIterate > 0);

        if (choosedEvent.numbersArray.length == choosedEvent.numberOfWinners) {
            choosedEvent.status = true;
        }

        choosedEvent.crrDecidedWinnersLen = choosedEvent.numbersArray.length;
        uint256[] memory tempArray;
        uint256[] memory newWinners = randomWinners;
        randomWinners = tempArray;

        emit randomWinnerNumber(
            _eventId,
            newWinners,
            choosedEvent.numbersArray
        );
        return (randomWinners);
    }

    // Get Excluded Winners
    function getExcludedNumbers(uint256 _eventId)
        public
        view
        returns (uint256[] memory)
    {
        require(
            events[_eventId].existStatus == true,
            "Event: Event with this id not exist"
        );

        return events[_eventId].excludedNumbers;
    }

    // Get winners
    function getAllWinners(uint256 _eventId)
        public
        view
        returns (uint256[] memory)
    {
        require(
            events[_eventId].existStatus == true,
            "Event: Event with this id not exist"
        );

        return events[_eventId].numbersArray;
    }

    // Check winner
    function checkWinner(uint256 _eventId, uint256 _number)
        public
        view
        returns (bool)
    {
        require(
            events[_eventId].existStatus == true,
            "Event: Event with this id not exist"
        );
        bool check = false;

        if (events[_eventId].numbers[_number] == true) {
            check = true;
        }

        return check;
    }

    // Reset the winners
    function resetData(uint256 _eventId) public onlyOwner returns (bool) {
        eventsStruct storage choosedEvent = events[_eventId];
        require(
            choosedEvent.existStatus == true,
            "Event with this Id not Exist"
        );

        uint256[] memory tempArray;
        for (uint8 i = 0; i < choosedEvent.numbersArray.length; i++) {
            choosedEvent.numbers[choosedEvent.numbersArray[i]] = false;
        }

        choosedEvent.numbersArray = tempArray;
        choosedEvent.status = false;

        emit dataReset(_eventId, true);
        return true;
    }

    // Remove and reset event data
    function removeAndResetEvent(uint256 _eventId)
        public
        onlyOwner
        returns (bool)
    {
        eventsStruct storage choosedEvent = events[_eventId];
        require(choosedEvent.existStatus == true, "Event: ID not exist");

        uint256[] memory tempArray;
        choosedEvent.existStatus = false;
        choosedEvent.startTimeStamp = 0;
        choosedEvent.endTimeStamp = 0;
        choosedEvent.range = 0;
        choosedEvent.status = false;

        for (uint8 i = 0; i < choosedEvent.numbersArray.length; i++) {
            choosedEvent.numbers[choosedEvent.numbersArray[i]] = false;
        }

        for (uint8 i = 0; i < choosedEvent.excludedNumbers.length; i++) {
            choosedEvent.checkNumberExcluded[
                choosedEvent.excludedNumbers[i]
            ] = false;
        }

        choosedEvent.numbersArray = tempArray;
        choosedEvent.excludedNumbers = tempArray;
        emit removeAndReset(_eventId, true);
        return true;
    }

    function addAddressesToExclude(
        uint256 _eventId,
        uint256[] memory _numbersToExclude
    ) public onlyOwner returns (bool) {
        eventsStruct storage choosedEvent = events[_eventId];
        require(choosedEvent.existStatus == true, "Event: ID not exist");

        for (uint8 i = 0; i < _numbersToExclude.length; i++) {
            if (
                choosedEvent.checkNumberExcluded[_numbersToExclude[i]] != true
            ) {
                choosedEvent.excludedNumbers.push(_numbersToExclude[i]);
                choosedEvent.checkNumberExcluded[_numbersToExclude[i]] = true;
            }
        }

        emit addedNumbersToExclude(_eventId, _numbersToExclude);
        return true;
    }

    // Get current time stamp
    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}