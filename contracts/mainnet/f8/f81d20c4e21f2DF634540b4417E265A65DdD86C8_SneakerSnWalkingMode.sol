/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20Full {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external returns (bool);
}

interface ISneakerSnUsers
{
    function isUserExists(address user) external view returns (bool);
    function isUserBotsExists(address user) external view returns (bool);
    function getUser(address user) external view returns (uint,address,uint,uint8,bool);
    function getUserSneakerConditions(address user, uint16 sneaker) external view returns (bool);
    function addUserSneaker(address user, uint8 sneaker, bool activate, bool ignoreConditions) external;
    function getUserSneaker(address user, uint8 sneaker) external view returns (bool,bool,bool,bool,uint16,uint);
    function updateUserSneakerFlag(address user, uint8 sneaker, uint8 flag, bool value) external;
    function updateUserSneakerRCount(address user, uint8 sneaker, uint16 count, bool add) external;
    function getUserReferrer(address user) external view returns (address);
    function getUserReferrer(address user, uint8 sneaker) external view returns (address, bool);
    function getUserAddress(uint user) external view returns (address);
    function isUserSneakerExists(address user, uint8 sneaker) external view returns (bool);
    function setUserSneakerActiveWaiter(address user, uint8 sneaker, uint waiter, bool active) external;
    function getUserSneakerActiveWaiter(address user, uint8 sneaker) external view returns (uint);
    function setUserSneakerConditions(address user, uint8 sneaker) external;
}

interface ISneakerSnBoosts
{
    function getBoostBonus(address user, uint8 sneaker, uint8 game, bool use) external returns (uint);
    function getBoostBonus(address user, uint8 sneaker, uint8 game) external view returns (uint);
}

contract SneakerSnWalkingMode {
    using SafeMath for uint;

    address public owner;
    address public snkAddress;
    address public usersContract;
    address public boostsContract;

    bool public paused;
    bool public burnSnkActive;
    bool public mintSnkActive;
    bool public boostsActive;
    bool public referralRewardActive;

    uint public minStakeAmount;
    uint public walkStakePeriod;
    uint public walksCount;
    uint public nextWalkId;

    struct Walk {
        bool active;
        address user;
        uint8 sneaker;
        uint percentage;
        uint boostBonus;
        uint stakeAmount;
        uint profitAmount;
        uint lastWithdrawn;
        uint created;
    }

    mapping (address => bool) public dapps;
    mapping (uint8 => uint) public stakeSneakerPercentages;
    mapping (uint => Walk) public walks;
    mapping (address => mapping (uint8 => uint)) public userSneakersActiveWalk;

    //event Donate(address indexed user, uint value);
    event WalkAdded(uint indexed id, address indexed user, uint8 sneaker, uint percetnage, uint boostBonus, uint amount, uint created);
    event WalkClosed(uint indexed id, address indexed user, uint amountRewards, uint amountWithdrawn, uint withdrawnAt);
    event WalkProfitWithdrawn(uint indexed id, address indexed user, uint amountWithdrawn, uint withdrawnAt);
    event WalkUpdated(uint indexed id, bool active, address user, uint8 sneaker, uint percentage, uint boostBonus, uint stakeAmount);
    event WalkReferralReward(address indexed user, address indexed referral, uint stakeId, uint line, uint amount, bool missed);

    modifier onlyContractOwner() { 
        require(msg.sender == owner, "onlyOwner"); 
        _; 
    }

    modifier onlyDapp() { 
        require(dapps[msg.sender] == true || msg.sender == owner, "onlyDapp"); 
        _; 
    }

    modifier onlyUnpaused() { 
        require(!paused || msg.sender == owner, "paused"); 
        _; 
    }

    function changeAddress(uint8 setting, address valueAddress) public onlyContractOwner() {
        if (setting == 1) {
            snkAddress = valueAddress;
        } else if (setting == 2) {
            usersContract = valueAddress;
        } else if (setting == 3) {
            boostsContract = valueAddress;
        }
    }

    function changeUint(uint8 setting, uint valueUint) public onlyContractOwner() {
        if (setting == 1) {
            minStakeAmount = valueUint;
        } else if (setting == 2) {
            walkStakePeriod = valueUint;
        }
    }

    function changeBool(uint8 setting) public onlyContractOwner() {
        if (setting == 1) {
            paused = !paused;
        } else if (setting == 2) {
            burnSnkActive = !burnSnkActive;
        } else if (setting == 3) {
            mintSnkActive = !mintSnkActive;
        } else if (setting == 4) {
            boostsActive = !boostsActive;
        } else if (setting == 6) {
            referralRewardActive = !referralRewardActive;
        }
    }

    function getActiveSneakerWalk(address user, uint8 sneaker) public view returns(uint walkId) {
        require(sneaker > 0, "sneaker require");
        require(user != address(0), "user require");

        return userSneakersActiveWalk[user][sneaker];
    }

    function updateActiveSneakerWalk(address user, uint8 sneaker, uint activeWalkId) public onlyContractOwner() {
        require(sneaker > 0, "sneaker require");
        require(user != address(0), "user require");

        userSneakersActiveWalk[user][sneaker] = activeWalkId;
    }

    function getWalk(uint walkId) public view returns(bool active, address user, uint8 sneaker, uint percentage, uint boostBonus) {
        require(walkId > 0, "walk id require");
        require(walks[walkId].user != address(0), "walk not found");

        return (walks[walkId].active, walks[walkId].user, walks[walkId].sneaker, walks[walkId].percentage, walks[walkId].boostBonus);
    }

    function getWalkProfit(uint walkId) public view returns(uint stakeAmount, uint profitAmount, uint lastWithdrawn, uint created) {
        require(walkId > 0, "walk id require");
        require(walks[walkId].user != address(0), "walk not found");

        return (walks[walkId].stakeAmount, walks[walkId].profitAmount, walks[walkId].lastWithdrawn, walks[walkId].created);
    }

    function updateWalk(uint walkId, bool active, address user, uint8 sneaker, uint percentage, uint boostBonus, uint stakeAmount) public onlyContractOwner() {
        require(walkId > 0, "walk id require");
        require(walks[walkId].user != address(0), "walk not found");
        require(user != address(0), "user address is require");

        walks[walkId].active = active; 
        walks[walkId].user = user; 
        walks[walkId].sneaker = sneaker;
        walks[walkId].percentage = percentage;
        walks[walkId].boostBonus = boostBonus;
        walks[walkId].stakeAmount = stakeAmount;

        emit WalkUpdated(walkId, walks[walkId].active, walks[walkId].user, walks[walkId].sneaker, walks[walkId].percentage, walks[walkId].boostBonus, walks[walkId].stakeAmount);
    }

    constructor() public {
        owner = msg.sender;
        snkAddress = address(0xB250E9B5565BE5B5AD63486f65aB922C5Bd0bF86);
        usersContract = address(0x2F3c2b0EAD7D2157bcE4930f7c7f59cDea889D76);

        paused = false;
        burnSnkActive = false;
        mintSnkActive = false;
        boostsActive = false;
        referralRewardActive = true;

        minStakeAmount = 1 * 1e8; // 1 SNK
        walkStakePeriod = 1 days;
        nextWalkId = 1;

        _initStakeSneakerPercentages();
    }

    function _initStakeSneakerPercentages() private {
        stakeSneakerPercentages[0] = 0;
        stakeSneakerPercentages[1] = 1000; // 1000 => 1%
        stakeSneakerPercentages[2] = 1125;
        stakeSneakerPercentages[3] = 1250;
        stakeSneakerPercentages[4] = 1375;
        stakeSneakerPercentages[5] = 1500;
        stakeSneakerPercentages[6] = 1625;
        stakeSneakerPercentages[7] = 1750;
        stakeSneakerPercentages[8] = 1875;
        stakeSneakerPercentages[9] = 2000;
        stakeSneakerPercentages[10] = 2125;
        stakeSneakerPercentages[11] = 2250;
        stakeSneakerPercentages[12] = 2375;
        stakeSneakerPercentages[13] = 2500;
        stakeSneakerPercentages[14] = 2625;
        stakeSneakerPercentages[15] = 2750;
        stakeSneakerPercentages[16] = 2875;
        stakeSneakerPercentages[17] = 3000;
        stakeSneakerPercentages[18] = 3125;
        stakeSneakerPercentages[19] = 3250;
        stakeSneakerPercentages[20] = 3375;
        stakeSneakerPercentages[21] = 3500;
        stakeSneakerPercentages[22] = 3625;
        stakeSneakerPercentages[23] = 3750;
        stakeSneakerPercentages[24] = 3875;
        stakeSneakerPercentages[25] = 4000; //4000 => 4%
    }
    
    function receiveApproval(address spender, uint value, address tokenAddress, bytes memory extraData)
    public 
    onlyUnpaused()
    {
        require(value >= minStakeAmount, "bad value");
        require(spender != address(0), "bad spender");
        require(extraData.length > 0, "sneaker id require");

        if (tokenAddress == snkAddress) {
            IERC20Full token = IERC20Full(tokenAddress);
            require(token.balanceOf(spender) >= value, "tokens not enough");

            uint8 sneaker = 0;
            assembly {
                sneaker := mload(add(extraData, 0x01))
            }

            require(sneaker > 0, "invalid sneaker");
            require(token.transferFrom(spender, address(this), value), "error transfer tokens");

            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(!users.isUserBotsExists(spender), "user banned");
            
            bool purchased = false;
            bool transferred = false;
            (purchased,,,transferred,,) = users.getUserSneaker(spender, sneaker);
            require(purchased, "sneaker exists");
            require(!transferred, "sneaker transferred");
            require(stakeSneakerPercentages[sneaker] > 0, "percentage invalid");
            require(userSneakersActiveWalk[spender][sneaker] == 0, "sneaker is already walk");

            if (burnSnkActive) {
                token.burn(value);
            }
            
            _stake(spender, sneaker, value);
            walksCount++;
        } else {
            IERC20Full token = IERC20Full(tokenAddress);
            require(token.transferFrom(spender, address(this), value));
        }
    }

    function _stake(address user, uint8 sneaker, uint amount) private {
        uint boostBonus = 0;
        if (boostsActive) {
            boostBonus = ISneakerSnBoosts(boostsContract).getBoostBonus(user, sneaker, 3, true);
        }

        Walk memory walk = Walk(true, user, sneaker, stakeSneakerPercentages[sneaker] + boostBonus, boostBonus, amount, 0, 0, block.timestamp);
        walks[nextWalkId] = walk;
        userSneakersActiveWalk[user][sneaker] = nextWalkId;

        if (referralRewardActive) {
            _transferReferrals(user, sneaker, nextWalkId, amount);
        }

        emit WalkAdded(nextWalkId, user, sneaker, stakeSneakerPercentages[sneaker] + boostBonus, boostBonus, amount, block.timestamp);
        nextWalkId++;
    }

    function _transferReferrals(address user, uint8 sneaker, uint stakeId, uint amount) private {
        ISneakerSnUsers users = ISneakerSnUsers(usersContract);

        address referral = address(0);
        bool purchased = false;
        (referral, purchased) = users.getUserReferrer(user, sneaker);
        for (uint line = 1; line <= 5; line++) {
            if (referral == address(0)) {
                break;
            }

            uint rewardAmount = 0;
            if (line == 1) {
                rewardAmount = amount.div(100).mul(5);
            } else if (line == 2) {
                rewardAmount = amount.div(100).mul(2);
            }  else if (line >= 3) {
                rewardAmount = amount.div(100).mul(1);
            }

            if (purchased == false) {
                emit WalkReferralReward(user, referral, stakeId, line, rewardAmount, true);

                (referral, purchased) = users.getUserReferrer(referral, sneaker);
                continue;
            }
            
            if (rewardAmount > 0) {
                if (mintSnkActive) {
                    require(IERC20Full(snkAddress).mint(referral, rewardAmount), "error mint SNK Tokens");
                } else {
                    require(IERC20Full(snkAddress).transfer(referral, rewardAmount), "error transfer SNK Tokens");
                }

                emit WalkReferralReward(user, referral, stakeId, line, rewardAmount, false);
            }

            (referral, purchased) = users.getUserReferrer(referral, sneaker);
        }
    }

    function closeWalks(uint[] memory walkIds) public onlyUnpaused() {
        require(walkIds.length > 0, "walks require");

        for (uint i = 0; i < walkIds.length; i++) {
            if (walkIds[i] != 0) {
                _closeWalk(walkIds[i]);
            }
        }
    }

    function closeWalk(uint walkId) public onlyUnpaused() {
        _closeWalk(walkId);
    }

    function _closeWalk(uint walkId) private {
        require(walks[walkId].user != address(0), "walk not found");
        require(walks[walkId].active == true, "walk status invalid");

        address user = msg.sender;
        if (user != owner && dapps[user] == false) {
            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(users.isUserExists(msg.sender), "user not found");
            require(!users.isUserBotsExists(msg.sender), "user banned");
        } else {
            user = walks[walkId].user;
        }
        require(user != address(0), "user address require");
        require(user == walks[walkId].user, "user address invalid");

        require(walks[walkId].created + walkStakePeriod <= block.timestamp, "walk period invalid");

        uint profitTokensAmount = getAvailableProfitAmount(walkId);

        walks[walkId].profitAmount = walks[walkId].profitAmount.add(profitTokensAmount);
        walks[walkId].active = false;
        userSneakersActiveWalk[user][walks[walkId].sneaker] = 0;

        //if (profitTokensAmount > 0) {
            walks[walkId].lastWithdrawn = block.timestamp;

            if (mintSnkActive) {
                require(IERC20Full(snkAddress).mint(walks[walkId].user, profitTokensAmount + walks[walkId].stakeAmount), "error mint SNK Tokens");
            } else {
                require(IERC20Full(snkAddress).transfer(walks[walkId].user, profitTokensAmount + walks[walkId].stakeAmount), "error transfer SNK Tokens");
            }
        //}

        emit WalkClosed(walkId, walks[walkId].user, profitTokensAmount, walks[walkId].stakeAmount, walks[walkId].lastWithdrawn);
    }

    function withdrawProfitWalks(uint[] memory walkIds) public onlyUnpaused() {
        require(walkIds.length > 0, "walks require");

        for (uint i = 0; i < walkIds.length; i++) {
            if (walkIds[i] != 0) {
                _withdrawProfitWalk(walkIds[i], 0);
            }
        }
    }

    function withdrawProfitWalk(uint walkId) public onlyUnpaused() {
        _withdrawProfitWalk(walkId, 0);
    }

    function withdrawProfitWalk(uint walkId, uint amount) public onlyUnpaused() {
        _withdrawProfitWalk(walkId, amount);
    }

    function _withdrawProfitWalk(uint walkId, uint amount) private {
        require(walks[walkId].user != address(0), "walk not found");
        require(walks[walkId].active == true, "walk status invalid");

        address user = msg.sender;
        if (user != owner && dapps[user] == false) {
            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(users.isUserExists(msg.sender), "user not found");
            require(!users.isUserBotsExists(msg.sender), "user banned");
        } else {
            user = walks[walkId].user;
        }
        require(user != address(0), "user address require");
        require(user == walks[walkId].user, "user address invalid");

        require(walks[walkId].created + walkStakePeriod < block.timestamp, "walk period invalid");

        uint profitTokensAmount = getAvailableProfitAmount(walkId);
        require(profitTokensAmount > 0, "not enough tokens for withdraw");
        if (amount == 0) {
            amount = profitTokensAmount;
        } else {
            require(profitTokensAmount >= amount, "amount invalid");
        }

        walks[walkId].profitAmount = walks[walkId].profitAmount.add(amount);
        walks[walkId].lastWithdrawn = block.timestamp;

        if (mintSnkActive) {
            require(IERC20Full(snkAddress).mint(walks[walkId].user, amount), "error mint SNK Tokens");
        } else {
            require(IERC20Full(snkAddress).transfer(walks[walkId].user, amount), "error transfer SNK Tokens");
        }

        emit WalkProfitWithdrawn(walkId, walks[walkId].user, amount, walks[walkId].lastWithdrawn);
    }

    function getAvailableProfitAmount(uint walkId) public view returns (uint amount) {
        require(walkId > 0, "walk id require");
        require(walks[walkId].active, "walk closed");

        uint walkDays = (block.timestamp - walks[walkId].created) / walkStakePeriod;
        if (walkDays == 0) {
            return 0;
        } else {
            uint profitAmount = walks[walkId].stakeAmount.div(100000).mul(walks[walkId].percentage).mul(walkDays);
            profitAmount = profitAmount.sub(walks[walkId].profitAmount);
            return profitAmount;
        }
    }
    
    function withdraw(address token, uint value) public onlyContractOwner() {
        if (token == address(0)) {
            address payable ownerPayable = payable(owner);
            if (value > 0) {
                ownerPayable.transfer(value);
            } else {
                ownerPayable.transfer(address(this).balance);
            }
        } else {
            if (value > 0) {
                IERC20Full(token).transfer(owner, value);
            } else {
                IERC20Full(token).transfer(owner, IERC20Full(token).balanceOf(address(this)));
            }
        }
    }
}