/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/**
 *Welcome to Metadroid Gold Miner Overload
*/

// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.10;

contract GoldMiner {
    uint256 private GOLDS_TO_HATCH_1MINERS = 2592000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    bool private seeded = false;

    uint256 private ref_div_1k = 100;
    uint256 private dev_fee_div_1k = 10;
    uint256 private marketing_fee_div_1k = 10;
    uint256 private project_fee_div_1k = 10;
    address payable dev_address;
    address payable marketing_address;
    address payable project_address;

    mapping(address => uint256) private goldMiners;
    mapping(address => uint256) private claimedGold;
    mapping(address => uint256) private lastHarvest;
    mapping(address => address) private referrals;
    uint256 private marketGolds;

    event GoldBought(uint256 value);
    event GoldSold(uint256 value);

    constructor(
        address payable _dev_address,
        address payable _marketing_address,
        address payable _project_address
    ) {
        require(!isContract(_dev_address));
        require(!isContract(_marketing_address));
        require(!isContract(_project_address));
        dev_address = _dev_address;
        marketing_address = _marketing_address;
        project_address = _project_address;
    }

    function harvestGolds(address ref) public {
        require(seeded);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 goldsUsed = getMyGolds();
        uint256 newMiners = goldsUsed / GOLDS_TO_HATCH_1MINERS;
        goldMiners[msg.sender] += newMiners;
        claimedGold[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;

        //send referral golds
        claimedGold[referrals[msg.sender]] += (goldsUsed * ref_div_1k) / 1000;

        //boost market to nerf miners hoarding
        marketGolds += goldsUsed / 5;
    }

    function sellGolds() public {
        require(seeded);
        uint256 hasGolds = getMyGolds();
        uint256 goldValue = calculateGoldSell(hasGolds);
        if (getBalance() < goldValue) {
            goldValue = getBalance();
        }
        uint256 fee1 = dev_fee(goldValue);
        uint256 fee2 = marketing_fee(goldValue);
        uint256 fee3 = project_fee(goldValue);
        dev_address.transfer(fee1);
        marketing_address.transfer(fee2);
        project_address.transfer(fee3);

        claimedGold[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketGolds = marketGolds + hasGolds;
        payable(msg.sender).transfer(goldValue - fee1 - fee2 - fee3);
        emit GoldSold(goldValue);
    }

    function seedMarket(uint256 _marketGolds) public payable {
        require(dev_address == msg.sender);
        seeded = true;
        marketGolds = _marketGolds;
    }

    function buyGolds(address ref) public payable {
        if (!seeded) {
            if (msg.sender == dev_address) {
                seedMarket(259000000);
            } else revert("Contract not yet started.");
        }
        uint256 goldsBought = calculateGoldBuy(
            msg.value,
            address(this).balance - msg.value
        );
        uint256 fee1 = dev_fee(msg.value);
        uint256 fee2 = marketing_fee(msg.value);
        uint256 fee3 = project_fee(msg.value);

        dev_address.transfer(fee1);
        marketing_address.transfer(fee2);
        project_address.transfer(fee3);

        claimedGold[msg.sender] += goldsBought;
        emit GoldBought(msg.value);
        harvestGolds(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 input,
        uint256 reserve_input,
        uint256 reserve_output
    ) private view returns (uint256) {
        return
            (PSN * reserve_output) /
            ((PSNH * reserve_input) /
                (reserve_input + PSNH) +
                (PSN * reserve_input) /
                input +
                1);
    }

    function calculateGoldSell(uint256 rubies) public view returns (uint256) {
        return calculateTrade(rubies, marketGolds, address(this).balance);
    }

    function calculateGoldBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketGolds);
    }

    function calculateGoldBuySimple(uint256 eth) public view returns (uint256) {
        return calculateGoldBuy(eth, address(this).balance);
    }

    function dev_fee(uint256 amount) private view returns (uint256) {
        return (amount * dev_fee_div_1k) / 1000;
    }

    function marketing_fee(uint256 amount) private view returns (uint256) {
        return (amount * marketing_fee_div_1k) / 1000;
    }

    function project_fee(uint256 amount) private view returns (uint256) {
        return (amount * project_fee_div_1k) / 1000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint256) {
        return goldMiners[msg.sender];
    }

    function getMyGolds() public view returns (uint256) {
        return claimedGold[msg.sender] + getGoldsSinceLastHarvest(msg.sender);
    }

    function getGoldsSinceLastHarvest(address adr)
        public
        view
        returns (uint256)
    {
        uint256 secondsPassed = min(
            GOLDS_TO_HATCH_1MINERS,
            block.timestamp - lastHarvest[adr]
        );
        return secondsPassed * goldMiners[adr];
    }

    function goldRewards() public view returns (uint256) {
        uint256 hasGolds = getMyGolds();
        uint256 goldsValue = calculateGoldSell(hasGolds);
        return goldsValue;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}