/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

/*  
 * TicketLotteryTest
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

library EnumerableSet {
    struct Set {bytes32[] _values;mapping(bytes32 => uint256) _indexes;}

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {return false;}
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {return false;}
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {return set._indexes[value] != 0;}
    function _length(Set storage set) private view returns (uint256) {return set._values.length;}
    function _at(Set storage set, uint256 index) private view returns (bytes32) {return set._values[index];}
    function _values(Set storage set) private view returns (bytes32[] memory) {return set._values;}

    // AddressSet
    struct AddressSet {Set _inner;}
    function add(AddressSet storage set, address value) internal returns (bool) {return _add(set._inner, bytes32(uint256(uint160(value))));}
    function remove(AddressSet storage set, address value) internal returns (bool) {return _remove(set._inner, bytes32(uint256(uint160(value))));}
    function contains(AddressSet storage set, address value) internal view returns (bool) {return _contains(set._inner, bytes32(uint256(uint160(value))));}
    function length(AddressSet storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(AddressSet storage set, uint256 index) internal view returns (address) {return address(uint160(uint256(_at(set._inner, index))));}
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {result := store}
        return result;
    }

}

contract ArrayTest {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet[41] private players;
    address[] public winners;

    constructor() {

    }

    receive() external payable {}


    function addPlayers(address[] calldata playersToBeAdded, uint256[] calldata ticketsOfPlayer) external {
        for(uint256 i = 0; i < playersToBeAdded.length; i++){
            players[ticketsOfPlayer[i]].add(playersToBeAdded[i]);
        }
    }

    function deletePlayer(address playerToBeDeleted) public {
        for(uint256 i = 1; i < 41; i++){
            if(players[i].contains(playerToBeDeleted)) players[i].remove(playerToBeDeleted);
        }
    }

    struct Player{
        address wallet;
        uint256 tickets;
        uint256 position;
    }

    function getAllData() external view returns(Player[] memory){
        uint256 totalPlayers;

        for(uint256 i = 1; i < 41; i++){
            totalPlayers += players[i].length();
        }
        Player[] memory everyOne = new Player[](totalPlayers);
        uint256 index;

        for(uint256 i = 1; i < 41; i++){
            address[] memory group = players[i].values();
            for(uint256 j = 0; j < group.length; j++){
                everyOne[index].wallet = group[j];
                everyOne[index].tickets = i;
                everyOne[index].position = j;
                index++;
            }
        }
        return everyOne;
    }

    function chooseRandomWinner(uint256 randomNumber) external {
        uint256 totalTickets;
        uint256 winnerLevel = 1;

        for(uint256 i = 1; i < 41; i++){
            totalTickets += players[i].length() * i;
        }

        randomNumber = randomNumber % (totalTickets + 1); 
        
        for(uint256 i = 1; i < 41; i++){
            if(players[i].length() * i <= randomNumber) {
                randomNumber -= players[i].length() * i;
                winnerLevel++;
            }
        }
        address winner = players[winnerLevel].at(randomNumber%winnerLevel);
        winners.push(winner);
        deletePlayer(winner);
    }

    function winningLevel(uint256 randomNumber) external view returns(uint256) {
        uint256 totalTickets;
        uint256 winnerLevel = 1;

        for(uint256 i = 1; i < 41; i++){
            totalTickets += players[i].length() * i;
        }
        randomNumber = randomNumber % (totalTickets + 1); 

        for(uint256 i = 1; i < 41; i++){
            if(players[i].length() * i <= randomNumber) {
                randomNumber -= players[i].length() * i;
                winnerLevel++;
            }
        }
        return winnerLevel;
    }
    
    function winningIndex(uint256 randomNumber) external view returns(uint256) {
        uint256 totalTickets;
        uint256 winnerLevel = 1;

        for(uint256 i = 1; i < 41; i++){
            totalTickets += players[i].length() * i;
        }

        randomNumber = randomNumber % (totalTickets + 1); 

        for(uint256 i = 1; i < 41; i++){
            if(players[i].length() * i <= randomNumber) {
                randomNumber -= players[i].length() * i;
                winnerLevel++;
            }
        }
        return randomNumber%winnerLevel;
    }

    function winningAddress(uint256 randomNumber) external view returns(address) {
        uint256 totalTickets;
        uint256 winnerLevel = 1;

        for(uint256 i = 1; i < 41; i++){
            totalTickets += players[i].length() * i;
        }
        randomNumber = randomNumber % (totalTickets + 1); 

        for(uint256 i = 1; i < 41; i++){
            if(players[i].length() * i <= randomNumber) {
                randomNumber -= players[i].length() * i;
                winnerLevel++;
            }
        }
        address winner = players[winnerLevel].at(randomNumber%winnerLevel);
        return winner;
    }

    function getAddressAtIndex(uint256 index, uint256 ticketLevel) external view returns(address) {
        address winner = players[ticketLevel].at(index);
        return winner;
    }
}