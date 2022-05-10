/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

pragma solidity >=0.4.22 <0.7.0;

abstract contract SlotMachineInterface {

    function StopReels(uint[4] memory randomNumbers, address payable player) public virtual;
}

contract Ownable {
    address payable owner;
    constructor() public {
        owner = msg.sender;
    }

    modifier IsOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
}

contract RandomNumberOracle is Ownable {

    event RandomNumberRequest(address indexed player, address callingSlotMachine);

    function RequestRandomNumbers(address payable player, address callingSlotMachine) public {
        emit RandomNumberRequest(player, callingSlotMachine);
    }

    function sendRandomNumbers(uint[4] memory randomNumbers, address payable player, address slotMachineAddress) public IsOwner {
        SlotMachineInterface slotMachine = SlotMachineInterface(slotMachineAddress);
        slotMachine.StopReels(randomNumbers, player);
    }
}