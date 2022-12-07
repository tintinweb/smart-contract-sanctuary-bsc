/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILGTPool {
    function isUserExists(address addr) external view returns (bool);
    function users(address account) external view returns (uint256, address);
}

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract LianGoPay is Ownable {
    IERC20 private constant c_erc20 = IERC20(0x55d398326f99059fF775485246999027B3197955);
    ILGTPool public constant c_lgtPool = ILGTPool(0xf84f56f54c0C0F6E981EEC0e4C14025D2B3b4C94);

    struct User {
        uint128 totalPayAmount;
        uint128 totalStakeAmount;
        uint128 adaptAmount;
        uint128 lastAdaptTime;

        uint128 withdrawnAmount;
        uint128 withdrawnPay;

        uint128 refReward;
    }
    mapping(address => User) public users; 

    address public constant feeAddress1 = 0xa24bbc4c45aa305C44D2A7104f0E699Fd4790E7C;
    address public constant feeAddress2 = 0x6a8fE3B7b725342a712FbC4f297847f496DD6880;
    uint128 private shopRate = 87;
    uint128 private dayReleaseRate = 50;
    uint256 private totalPayIn;
    
    struct RefInfo {
        uint128 minAmount;
        uint128 refRewardRate;
    }
    mapping (uint256 => RefInfo) public refRewardRates;
    
    constructor() public {
        refRewardRates[0] = RefInfo(2000*10**18, 50);
        refRewardRates[1] = RefInfo(4000*10**18, 50);
        refRewardRates[2] = RefInfo(6000*10**18, 50);
        refRewardRates[3] = RefInfo(8000*10**18, 50);
        refRewardRates[4] = RefInfo(10000*10**18, 50);
        refRewardRates[5] = RefInfo(12000*10**18, 50);
        refRewardRates[6] = RefInfo(14000*10**18, 50);
        refRewardRates[7] = RefInfo(16000*10**18, 50);
        refRewardRates[8] = RefInfo(18000*10**18, 50);
        refRewardRates[9] = RefInfo(20000*10**18, 50);
        refRewardRates[10] = RefInfo(22000*10**18, 50);
        refRewardRates[11] = RefInfo(24000*10**18, 50);
        refRewardRates[12] = RefInfo(26000*10**18, 50);
        refRewardRates[13] = RefInfo(28000*10**18, 50);
        refRewardRates[14] = RefInfo(30000*10**18, 50);
        refRewardRates[15] = RefInfo(32000*10**18, 50);
        refRewardRates[16] = RefInfo(34000*10**18, 50);
        refRewardRates[17] = RefInfo(36000*10**18, 50);
        refRewardRates[18] = RefInfo(38000*10**18, 50);
        refRewardRates[19] = RefInfo(40000*10**18, 50);
    }
    
    function pay(address shopkeeper, uint128 amount) external {
        require(c_lgtPool.isUserExists(shopkeeper), "shopkeeper not exists");
        require(c_lgtPool.isUserExists(msg.sender), "msgsender not exists");

        c_erc20.transferFrom(msg.sender, address(this), amount);
        uint128 shopAmount = amount * shopRate/100;
        c_erc20.transfer(shopkeeper, shopAmount);
        c_erc20.transfer(feeAddress1, amount/100);
        c_erc20.transfer(feeAddress2, amount/50);

        User storage s = users[shopkeeper];

        uint128 interval = uint128(block.timestamp - s.lastAdaptTime);
        uint128 adaptAmount = getReleaseAmount(interval, s.totalStakeAmount);
        s.adaptAmount += adaptAmount;
        s.lastAdaptTime = uint128(block.timestamp);
        s.totalStakeAmount = s.totalStakeAmount - adaptAmount + amount - shopAmount;
        s.withdrawnPay += shopAmount;

        User storage m = users[msg.sender];
        
        interval = uint128(block.timestamp - m.lastAdaptTime);
        adaptAmount = getReleaseAmount(interval, m.totalStakeAmount);
        m.adaptAmount += adaptAmount;
        m.lastAdaptTime = uint128(block.timestamp);
        m.totalStakeAmount = m.totalStakeAmount - adaptAmount + amount;
        m.totalPayAmount += amount;

        totalPayIn += uint256(amount);
    }

    function getReleaseAmount(uint128 intervalSeconds, uint128 stakeAmount) public view returns(uint128) {
        if (intervalSeconds == 0 || stakeAmount == 0) {
            return 0;
        }
        uint128 intervalDays = intervalSeconds/(24*3600);
        if (intervalDays == 0) {
            return uint128(stakeAmount * dayReleaseRate * intervalSeconds/(100000*24*3600));
        }

        uint128 amount = 0;
        for (uint128 i = 0; i < intervalDays; i++) {
            uint128 oneReleaseAmount = uint128(stakeAmount * dayReleaseRate/100000);
            amount += oneReleaseAmount;
            stakeAmount -= oneReleaseAmount;
        }

        amount += uint128((intervalSeconds-24*3600*intervalDays)*stakeAmount*dayReleaseRate/(100000*24*3600));
        return amount;
    }
    
    function withdraw() external {
        require(c_lgtPool.isUserExists(msg.sender), "addr not exists");

        User storage m = users[msg.sender];
        uint128 interval = uint128(block.timestamp - m.lastAdaptTime);
        uint128 adaptAmount = getReleaseAmount(interval, m.totalStakeAmount);
        uint128 withdrawableAmount = m.adaptAmount + adaptAmount;
        m.adaptAmount = 0;
        m.lastAdaptTime = uint128(block.timestamp);

        _refPayout(msg.sender, withdrawableAmount);

        interval = m.refReward;
        withdrawableAmount += interval;
        c_erc20.transfer(msg.sender, withdrawableAmount);

        interval += adaptAmount;
        if(m.totalStakeAmount > interval) {
            m.totalStakeAmount -= interval;
        } else {
            m.totalStakeAmount = 0;
        }
        m.refReward = 0;
        m.withdrawnAmount += withdrawableAmount;
    }

    function _refPayout(address addr, uint128 amount) private {
        (uint256 id, address up) = c_lgtPool.users(addr);
        for(uint128 i = 0; i < 20; i++) {
            if(up == address(0)) break;

            if (users[up].totalStakeAmount >= refRewardRates[i].minAmount){
                users[up].refReward += amount * refRewardRates[i].refRewardRate / 1000;
            }

            (id, up) = c_lgtPool.users(up);
        }
    }

    function setRefRate(uint256 i, uint128 m, uint128 newR) external onlyOwner {
        refRewardRates[i].minAmount = m;
        refRewardRates[i].refRewardRate = newR;
    }

    function setShopRate(uint128 newShopRate) external onlyOwner() {
        require(newShopRate <= 100, "data err");
        shopRate = newShopRate;
    }

    function setDayReleaseRate(uint128 newDayReleaseRate) external onlyOwner() {
        require(newDayReleaseRate <= 100000, "data err");
        dayReleaseRate = newDayReleaseRate;
    }

    function contractInfo() external view returns(uint256, uint128, uint128, uint256) {
        return (c_erc20.balanceOf(address(this)), shopRate, dayReleaseRate, totalPayIn);
    }

    function userInfo(address addr) public view returns(uint128, uint128, uint128, uint128, uint128, uint128) {
        User storage o = users[addr];
        uint128 interval;
        if (o.lastAdaptTime != 0){
            interval = uint128(block.timestamp - o.lastAdaptTime);
            interval = getReleaseAmount(interval, o.totalStakeAmount);
        }
        return (o.totalPayAmount, o.totalStakeAmount, o.adaptAmount+interval, o.refReward, o.withdrawnAmount, o.withdrawnPay);
    }
}