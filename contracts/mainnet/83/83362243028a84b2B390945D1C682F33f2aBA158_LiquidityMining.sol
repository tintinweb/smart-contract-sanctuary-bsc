/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract LiquidityMining {
    IERC20 public constant c_erc20stake = IERC20(0x9535A3Fd02849e9798E741c5cc0Ff023cf809Fe0);
    IERC20 public constant c_erc20reward = IERC20(0xb0fd95723534aF7a08021813bc9f792a083947B2);

    uint256 public immutable periodFinish = block.timestamp + 3500 days;
    uint256 public constant rewardRate = 23148148148148148;

    uint256 private _totalSupply;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    struct User {
        uint256 id;
        address upline;
        uint256 stakeAmount;
        uint256 userRewardPerTokenPaid;
        uint256 rewards;

        uint256 downlineAmount;
        uint256 withdrawn;
        uint256 refReward;
        uint256 validDirectNum;
    }
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    uint256 public nextUserId = 2;

    uint256 public constant validLPamount = 300*10**18;
    uint256 public constant selfValidLPamount = 300*10**18;
    struct RefInfo {
        uint256 minNum;
        uint256 refRewardRate;
    }
    mapping (uint256 => RefInfo) public refRewardRates;

    constructor(address _first) {
        id2Address[1] = _first;
        users[_first].id = 1;

        refRewardRates[0] = RefInfo(1, 50);
        refRewardRates[1] = RefInfo(1, 50);
        refRewardRates[2] = RefInfo(2, 50);
        refRewardRates[3] = RefInfo(2, 50);
        refRewardRates[4] = RefInfo(3, 50);
        refRewardRates[5] = RefInfo(3, 50);
        refRewardRates[6] = RefInfo(4, 50);
        refRewardRates[7] = RefInfo(4, 50);
        refRewardRates[8] = RefInfo(5, 50);
        refRewardRates[9] = RefInfo(5, 50);
        refRewardRates[10] = RefInfo(6, 50);
        refRewardRates[11] = RefInfo(6, 50);
        refRewardRates[12] = RefInfo(7, 50);
        refRewardRates[13] = RefInfo(7, 50);
        refRewardRates[14] = RefInfo(8, 50);
        refRewardRates[15] = RefInfo(8, 50);
        refRewardRates[16] = RefInfo(9, 50);
        refRewardRates[17] = RefInfo(9, 50);
        refRewardRates[18] = RefInfo(10, 50);
        refRewardRates[19] = RefInfo(10, 50);
    }

    modifier updateReward(address account) {
        uint256 rpts = rewardPerToken();
        rewardPerTokenStored = rpts;
        lastUpdateTime = lastTimeRewardApplicable();
        
        User storage s = users[account];
        s.rewards += s.stakeAmount * (rpts - s.userRewardPerTokenPaid)/1e18;
        s.userRewardPerTokenPaid = rpts;
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / _totalSupply;
    }

    function register(address up) public {
        require(isUserExists(up), "up not exist");
        require(!isUserExists(msg.sender), "user exist");
        
        uint256 id = nextUserId++;
        users[msg.sender].id = id;
        users[msg.sender].upline = up;
        id2Address[id] = msg.sender;
    }

    function registerAndStake(address up, uint256 amount) public updateReward(msg.sender) {
        if (!isUserExists(msg.sender)) {
            register(up);
        }
        _stake(msg.sender, amount);
    }
    
    function stake(uint256 amount) public updateReward(msg.sender) {
        require(isUserExists(msg.sender), "user not exist");
        _stake(msg.sender, amount);
    }

    function _stake(address addr, uint256 amount) private {
        c_erc20stake.transferFrom(addr, address(this), amount);

        uint256 before = users[addr].stakeAmount;
        users[addr].stakeAmount += amount;
        uint256 afterAmount = before + amount;

        _totalSupply += amount;
        _addGen(addr, amount);
    
        if ( before < validLPamount && afterAmount >= validLPamount ) {
            address up = users[addr].upline;
            if ( up != address(0) ) {
                users[up].validDirectNum++;
            }
        }        
    }

    function _addGen(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            users[up].downlineAmount += amount;
            up = users[up].upline;
        }
    }

    function redeem(uint256 amount) public updateReward(msg.sender) {
        c_erc20stake.transfer(msg.sender, amount);

        uint256 before = users[msg.sender].stakeAmount;
        users[msg.sender].stakeAmount -= amount;
        uint256 afterAmount = before - amount;

        _totalSupply -= amount;
        _removeGen(msg.sender, amount);
    
        if ( before >= validLPamount && afterAmount < validLPamount ) {
            address up = users[msg.sender].upline;
            if ( up != address(0) ) {
                users[up].validDirectNum--;
            }
        }
    }

    function _removeGen(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            users[up].downlineAmount -= amount;
            up = users[up].upline;
        }
    }

    function exit() external {
        redeem(users[msg.sender].stakeAmount);
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        User storage s = users[msg.sender];
        uint256 r = s.rewards;
        _refPayout(msg.sender, r);
        r += s.refReward;
        c_erc20reward.transfer(msg.sender, r);

        s.rewards = 0;
        s.refReward = 0;
        s.withdrawn += r;
    }

    function _refPayout(address addr, uint256 amount) private {
        uint256 sv = selfValidLPamount;
        address up = users[addr].upline;
        for(uint256 i = 0; i < 20; i++) {
            if(up == address(0)) break;
            if (users[up].stakeAmount >= sv && users[up].validDirectNum >= refRewardRates[i].minNum){
                users[up].refReward += amount * refRewardRates[i].refRewardRate / 1000;
            }
            up = users[up].upline;
        }
    }

    function isUserExists(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }

    function userInfoByAddr(address addr) public view returns(uint256, address, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        User storage s = users[addr];
        uint256 earned = s.rewards + s.stakeAmount*(rewardPerToken() - s.userRewardPerTokenPaid)/1e18;
        return (s.id, addr, s.upline, s.stakeAmount, earned, _totalSupply, c_erc20reward.balanceOf(address(this)), s.refReward, s.downlineAmount, s.withdrawn, s.validDirectNum);
    }

    function userInfoById(uint256 userid) external view returns (uint256, address, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        address addr = id2Address[userid];
        return userInfoByAddr(addr);
    }

    function getRate() external view returns(uint256) {
        uint256 rate = 10000 * rewardRate * 365 days * c_erc20stake.totalSupply() / ( 2 * _totalSupply * c_erc20reward.balanceOf(address(c_erc20stake)));
        return rate;
    }
}