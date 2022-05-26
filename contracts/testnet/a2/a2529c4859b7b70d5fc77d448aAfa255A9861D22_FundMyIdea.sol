// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract FundMyIdea {
    struct Idea {
        address createdBy;
        string name;
        string description;
        uint256 balance;
        uint256 amount;
    }

    struct Fee {
        uint8 percent;
        uint256 balance;
        uint256 amount;
    }

    address owner;
    Fee fee;
    mapping(uint256 => Idea) public ideas;
    uint256 nextIdeaId = 0;

    event Funded(address sender, uint256 value, uint256 ideaId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this.");
        _;
    }

    constructor(uint8 feePercent) {
        owner = msg.sender;
        fee = Fee({percent: feePercent, balance: 0, amount: 0});
    }

    function registerIdea(string memory ideaName, string memory ideaDescription)
        public
        returns (uint256)
    {
        uint256 ideaId = nextIdeaId;
        ideas[ideaId] = Idea({
            createdBy: msg.sender,
            name: ideaName,
            description: ideaDescription,
            balance: 0,
            amount: 0
        });
        nextIdeaId++;
        return ideaId;
    }

    function fundIdea(uint256 ideaId) public payable {
        // Check.
        require(ideaId < nextIdeaId, "Idea should be defined.");
        require(msg.value > 0, "Can't fund zero.");

        // Define payment parts.
        uint256 feePartAmount = (msg.value * fee.percent) / 100;
        uint256 ideaPartAmount = msg.value - feePartAmount;

        // Update fee balance.
        fee.balance += feePartAmount;
        fee.amount += feePartAmount;

        // Update idea balance.
        ideas[ideaId].balance += ideaPartAmount;
        ideas[ideaId].amount += ideaPartAmount;
    }

    function withdrawIdea(uint256 ideaId) public {
        // Check.
        require(ideaId < nextIdeaId, "Idea should be defined.");
        require(
            ideas[ideaId].createdBy == msg.sender,
            "Only idea creator can withdraw."
        );
        require(ideas[ideaId].balance > 0, "Can't withdraw zero.");

        // Withdraw.
        payable(msg.sender).transfer(ideas[ideaId].balance);

        // Reset idea balance.
        ideas[ideaId].balance = 0;
    }

    function withdrawFee() public onlyOwner {
        payable(msg.sender).transfer(fee.balance);
        fee.balance = 0;
    }

    function getLastIdeaId() public view returns (uint256) {
        return nextIdeaId - 1;
    }

    function getFeePercent() public view returns (uint256) {
        return fee.percent;
    }

    function getFee() public view onlyOwner returns (Fee memory) {
        return fee;
    }
}