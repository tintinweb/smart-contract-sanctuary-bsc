pragma solidity ^0.8.0;

contract Owner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Messenger is Owner {
    uint cost;
    bool public enabled;
    event UpdateCost(uint newCost);
    event UpdateEnabled(string newStatus);
    event NewText(address to, string number, string message);

    constructor() public {
        cost = 380000000000000;
        enabled = true;
    }

    function changeCost(uint price) onlyOwner public {
        cost = price;
        emit UpdateCost(cost);
    }

    function pauseContract() onlyOwner public {
        enabled = false;
        emit UpdateEnabled("Texting has been disabled");
    }

    function enableContract() onlyOwner public {
        enabled = true;
        emit UpdateEnabled("Texting has been enabled");
    }

    function withdraw() onlyOwner public {
        address payable receiver = payable(owner);
        receiver.transfer(address(this).balance);
    }

    function costWei() public view returns (uint) {
        return cost;
    }

    function sendText(address to, string memory phoneNumber, string memory textBody) external payable {
        require(enabled, "SC is disabled");
        require(msg.value >= cost, "Not enough cost");
        sendMsg(to, phoneNumber, textBody);
    }

    function sendMsg(address to, string memory num, string memory body) internal {
        emit NewText(to, num, body);
    }
}