/**
 *Submitted for verification at BscScan.com on 2022-10-13
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

contract LifePay is Ownable {
    
    IPancakeRouter02 internal uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public constant c_erc20 = IERC20(0xeFa42568A6Cb3E0e5Bc6476Ee57aA21b5e18A277);

    struct User {
        uint128 id;
        uint128 reward;
        address upline;
      
        uint128 totalPayAmount;
        uint128 totalStakeAmount;
        uint128 adaptAmount;
        uint128 lastAdaptTime;

        uint128 withdrawnAmount;
        uint128 withdrawnPay;
    }

    mapping(address => User) public users; 
    mapping(uint128 => address) public id2Address;
    uint128 private nextUserId = 2;
    uint128 private dayReleaseRate = 30;

    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint128 private shopRate = 90;
    
    struct RefInfo {
        uint128 minAmount;
        uint128 refRewardRate;
    }
    mapping (uint256 => RefInfo) public refRewardRates;
    uint256 private totalPayIn;
    
    constructor(address firstAddr) public {
        users[firstAddr].id = 1;
        id2Address[1] = firstAddr;

        refRewardRates[0] = RefInfo(500*10**18, 50);
        refRewardRates[1] = RefInfo(1000*10**18, 50);
        refRewardRates[2] = RefInfo(2000*10**18, 50);
        refRewardRates[3] = RefInfo(3000*10**18, 50);
        refRewardRates[4] = RefInfo(4000*10**18, 50);
        refRewardRates[5] = RefInfo(5000*10**18, 50);
        refRewardRates[6] = RefInfo(6000*10**18, 50);
        refRewardRates[7] = RefInfo(7000*10**18, 50);
        refRewardRates[8] = RefInfo(8000*10**18, 50);
        refRewardRates[9] = RefInfo(9000*10**18, 50);
        refRewardRates[10] = RefInfo(10000*10**18, 50);
        refRewardRates[11] = RefInfo(20000*10**18, 50);
        refRewardRates[12] = RefInfo(30000*10**18, 50);
        refRewardRates[13] = RefInfo(40000*10**18, 50);
        refRewardRates[14] = RefInfo(50000*10**18, 50);
        refRewardRates[15] = RefInfo(60000*10**18, 50);
        refRewardRates[16] = RefInfo(70000*10**18, 50);
        refRewardRates[17] = RefInfo(80000*10**18, 50);
        refRewardRates[18] = RefInfo(90000*10**18, 50);
        refRewardRates[19] = RefInfo(100000*10**18, 50);
    }
    
    function register(address referrer) external {
        _register(msg.sender, referrer);
    }

    function _register(address addr, address referrer) private {
        require(!isUserExists(addr), "user already exist");
        require(isUserExists(referrer), "referrer not exists");
        uint128 id = nextUserId++;
        users[addr].id = id;
        users[addr].upline = referrer;
        users[addr].lastAdaptTime = uint128(block.timestamp);
        id2Address[id] = addr;
    }
    
    function isUserExists(address addr) public view returns (bool) {
        return (users[addr].id != 0);
    }

    function pay(address shopkeeper, uint256 usdtAmount) external {
        require(isUserExists(shopkeeper), "addr not exists");
        require(usdtAmount <= uint112(-1), "OVERFLOW");

        usdtAmount = usdtAmount*10**18/getTokenPrice();
        require(usdtAmount <= 10**26, "OVERFLOW");      // Life totalsupply
        uint128 amount = uint128(usdtAmount);


        uint128 shopAmount = amount * shopRate/100;
        c_erc20.transferFrom(msg.sender, shopkeeper, shopAmount);
        c_erc20.transferFrom(msg.sender, deadAddress, amount - shopAmount);


        User storage s = users[shopkeeper];

        uint128 interval = uint128(block.timestamp - s.lastAdaptTime);
        uint128 adaptAmount = getReleaseAmount(interval, s.totalStakeAmount);
        s.adaptAmount += adaptAmount;
        s.lastAdaptTime = uint128(block.timestamp);
        s.totalStakeAmount = s.totalStakeAmount - adaptAmount + amount - shopAmount;
        s.withdrawnPay += uint128(shopAmount);
        
        if (!isUserExists(msg.sender)) {
            _register(msg.sender, shopkeeper);
        }

        User storage m = users[msg.sender];
        
        interval = uint128(block.timestamp - m.lastAdaptTime);
        adaptAmount = getReleaseAmount(interval, m.totalStakeAmount);
        m.adaptAmount += adaptAmount;
        m.lastAdaptTime = uint128(block.timestamp);
        m.totalStakeAmount = m.totalStakeAmount - adaptAmount + amount;
        m.totalPayAmount += amount;

        totalPayIn += amount;
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
        require(isUserExists(msg.sender), "addr not exists");

        User storage m = users[msg.sender];
        uint128 interval = uint128(block.timestamp - m.lastAdaptTime);
        uint128 adaptAmount = getReleaseAmount(interval, m.totalStakeAmount);

        uint128 withdrawableAmount = m.adaptAmount + adaptAmount;
        m.totalStakeAmount -= adaptAmount;
        m.adaptAmount = 0;
        m.lastAdaptTime = uint128(block.timestamp);

        _refPayout(msg.sender, withdrawableAmount);

        withdrawableAmount += m.reward;
        c_erc20.transfer(msg.sender, withdrawableAmount);
        m.reward = 0;
        m.withdrawnAmount += withdrawableAmount;
    }

    function _refPayout(address addr, uint128 amount) private {
        address up = users[addr].upline;
        for(uint128 i = 0; i < 20; i++) {
            if(up == address(0)) break;

            if (users[up].totalStakeAmount >= refRewardRates[i].minAmount){
                users[up].reward += amount * refRewardRates[i].refRewardRate / 1000;
            }

            up = users[up].upline;
        }
    }

    function setRefRate(uint256 i, uint128 m, uint128 newR) external onlyOwner {
        refRewardRates[i].minAmount = m;
        refRewardRates[i].refRewardRate = newR;
    }

    function setShopRate(uint128 newShopRate) external onlyOwner() {
        shopRate = newShopRate;
    }

    function setDayReleaseRate(uint128 newDayReleaseRate) external onlyOwner() {
        dayReleaseRate = newDayReleaseRate;
    }

    function contractInfo() external view returns(uint256, uint128, uint128, uint128, uint256) {
        return (c_erc20.balanceOf(address(this)), nextUserId, shopRate, dayReleaseRate, totalPayIn);
    }

    function userInfo(address addr) public view returns(uint128, uint128, uint128, uint128, uint128, uint128) {
        User storage o = users[addr];
        uint128 interval;
        if (o.lastAdaptTime != 0){
            interval = uint128(block.timestamp - o.lastAdaptTime);
            interval = getReleaseAmount(interval, o.totalStakeAmount);
        }
        return (o.totalPayAmount, o.totalStakeAmount, o.adaptAmount+interval, o.reward, o.withdrawnAmount, o.withdrawnPay);
    }

    function getTokenPrice() public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(c_erc20);
        path[1] = usdtAddress;
        uint[] memory amounts = new uint[](2);
        amounts = uniswapV2Router.getAmountsOut(10**18, path);
        require(amounts[1] != 0, "priceZero");
        return amounts[1];
    }
}

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
}