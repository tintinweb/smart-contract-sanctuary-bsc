// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract EngramTable {
    address payable public owner;
    uint256 public prizeCount;
    mapping(uint256 => prize) public prizes;

    struct prize {
        uint128 lowticket;
        uint128 highticket;
        uint256 multiFactor; //This number will be between 0 and 100,000 +  Numbers under 100,000 are considered negative multipliers
    }

    constructor() {
        owner = payable(msg.sender);
        prizes[0] = prize(0, 24999, 105000);
        prizes[1] = prize(25000, 49999, 107000);
        prizes[2] = prize(50000, 74999, 110000);
        prizes[3] = prize(75000, 89999, 114000);
        prizes[4] = prize(90000, 95999, 120000);
        prizes[5] = prize(96000, 99999, 125000);
        prizeCount = 6;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        owner.transfer(address(this).balance);
    }

    function getPrizes() external view returns (prize[6] memory) {
        prize[6] memory temp;
        temp[0] = prizes[0];
        temp[1] = prizes[1];
        temp[2] = prizes[2];
        temp[3] = prizes[3];
        temp[4] = prizes[4];
        temp[5] = prizes[5];

        return temp;
    }

    function getWinningPrize(uint128 ticket)
        external
        view
        returns (prize memory)
    {
        for (uint256 i = 0; i < prizeCount; i++) {
            if (
                prizes[i].lowticket <= ticket && prizes[i].highticket >= ticket
            ) {
                return prizes[i];
            }
        }
        return prize(0, 0, 100000);
    }
}