/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// File: contracts/study/FilDistribution.sol

pragma solidity >=0.8.13;


contract FilDistribution {
    address private admin;
    struct FilReward {
        uint256 reward;
        uint256 date;
    }
    struct FilOrder {
        address user;
        uint256 Tib;
        uint256 contractDays;
        // uint256 proportion;
        uint256 startIndex;
        uint256 startDate;
    }
    FilReward[] public filRewards;
    mapping(address => FilOrder[]) public userOrders;
    mapping(address => uint256) public userWithdraw;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function caculateIncome(FilOrder memory fo)
        public
        view
        returns (uint256 release, uint256 locked)
    {
        uint256 maxIndex;

        if ((filRewards.length - 1 - fo.startIndex) <= fo.contractDays) {
            maxIndex = filRewards.length - 1;
        } else {
            maxIndex = fo.startIndex + fo.contractDays;
        }
        release = release + (filRewards[fo.startIndex].reward * fo.Tib) / 4;
        locked = locked + (filRewards[fo.startIndex].reward * fo.Tib * 3) / 4;
        for (uint256 i = fo.startIndex + 1; i < maxIndex; i++) {
            release =
                release +
                ((filRewards[i].reward * fo.Tib) / 4) +
                (locked / 180);
            locked =
                locked +
                ((filRewards[i].reward * fo.Tib * 3) / 4) -
                (locked / 180);
        }
        if ((filRewards.length - fo.startIndex) >= fo.contractDays + 180) {
            release = release + locked;
            locked = 0;
        }
    }

    function userIncome(address _userAddress)
        public
        view
        returns (uint256 release, uint256 locked)
    {
        uint256 releaseTemp;
        uint256 lockedTemp;
        for (uint256 i = 0; i < userOrders[_userAddress].length; i++) {
            (releaseTemp, lockedTemp) = caculateIncome(
                userOrders[_userAddress][i]
            );
            release = release + releaseTemp;
            locked = locked + lockedTemp;
        }
    }

    function addUserOrder(address _userAddress, uint256 _tib) public {
        FilOrder memory fo;
        fo.user = _userAddress;
        fo.Tib = _tib;
        fo.startDate = block.timestamp;
        fo.contractDays = 540;
        fo.startIndex = filRewards.length - 1;
        userOrders[_userAddress].push(fo);
    }

    function addFilRewads(uint256 _rewards) public {
        FilReward memory fr;
        fr.reward = _rewards;
        fr.date = block.timestamp;
        filRewards.push(fr);
    }

    function addTEST10daysFilRewads() public {
        for (uint256 i = 0; i < 10; i++) {
            FilReward memory fr;
            fr.reward = (0.0139 * 10**18);
            fr.date = block.timestamp;
            filRewards.push(fr);
        }
    }

    function addTEST100daysFilRewads() public {
        for (uint256 i = 0; i < 100; i++) {
            FilReward memory fr;
            fr.reward = (0.0139 * 10**18);
            fr.date = block.timestamp;
            filRewards.push(fr);
        }
    }

    function addTEST1YearFilRewads() public {
        for (uint256 i = 0; i < 366; i++) {
            FilReward memory fr;
            fr.reward = (0.0139 * 10**18);
            fr.date = block.timestamp;
            filRewards.push(fr);
        }
    }
}