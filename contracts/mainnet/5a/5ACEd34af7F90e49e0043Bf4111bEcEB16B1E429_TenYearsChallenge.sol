pragma solidity ^0.7.0;

contract TenYearsChallenge {
    address public owner;
    Contribution[] public queue;
    uint256 public head;
    mapping(address => bool) public isChallenged;

    struct Contribution {
        uint256 amount;
        uint256 unlockTimestamp;
    }

    constructor() public payable {
        owner = msg.sender;

        // start challenge
        queue.push(Contribution(msg.value, block.timestamp + 10 * 365 days));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function upsert(uint256 index, uint256 timestamp) public payable {
        if (index >= head && index < queue.length) {
            // Update existing contribution amount without updating timestamp.
            Contribution storage contribution = queue[index];
            contribution.amount += msg.value;
        } else {
            // Append a new contribution. Require that each contribution unlock
            // at least 1 day after the previous one.
            require(timestamp >= queue[queue.length - 1].unlockTimestamp + 1 days);

            Contribution memory contribution;
            contribution.amount = msg.value;
            contribution.unlockTimestamp = timestamp;
            queue.push(contribution);
        }
    }

    function withdraw(uint256 index, address payable receiver) public {
        require(block.timestamp >= queue[index].unlockTimestamp, "still on locking");
        require(!isChallenged[msg.sender], "already challenged");
        isChallenged[msg.sender] = true;

        // Withdraw this and any earlier contributions.
        uint256 total = 0;
        for (uint256 i = head; i <= index; i++) {
            total += queue[i].amount;
        }

        // Move the head of the queue forward so we don't have to loop over
        // already-withdrawn contributions.
        head = index + 1;
        receiver.transfer(total);
    }
}