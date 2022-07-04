/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

//import "hardhat/console.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BusStaking is Ownable {
    IERC20 public busd;
    IERC20 public busToken;

    // Staking data
    uint public totalDeposits;
    uint public pendingClaim;
    mapping(address => uint) public lastClaimedDay;
    mapping(address => uint) public depositAmount;
    uint public totalStakers;
    uint public totalBUSDRewarded;

    // Daily history
    uint public lastDayCalculated;
    uint public lastDayCalculatedTimestamp;
    mapping(uint => uint) public dayTotalRewards;
    mapping(uint => uint) public dayTotalDeposited;

    // Launch state
    uint public rewardGenesisTiemstamp;
    bool public isClaimActive = false;

    // Mechanics
    uint STAKING_CLOSE_PERIOD = 1 days;
    uint public rewardRateDailyPercentage = 1000;

    /* Replace this constructor for unit testing
    constructor(address busd_address, address bus_token_address) {
        busd = IERC20(busd_address);
        busToken = IERC20(bus_token_address);
    }
    */

    constructor() {
        // Edit
        busToken = IERC20(0x399102e35aa2F4BAA8D2582aFB62c74c39ced277);
        // End Edit

        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    // Admin

    function initalizeClaim() external onlyOwner
    {
        rewardGenesisTiemstamp = lastDayCalculatedTimestamp = block.timestamp;
        isClaimActive = true;
    }

    function withdrawBUSD(uint amount) public onlyOwner
    {
        busd.transfer(msg.sender, amount);
    }

    function setStakingClosePeriod(uint _STAKING_CLOSE_PERIOD) public onlyOwner
    {
        STAKING_CLOSE_PERIOD = _STAKING_CLOSE_PERIOD;
    }

    function setRewardDailyRatePercentage(uint _rewardRateDailyPercentage) public onlyOwner
    {
        rewardRateDailyPercentage = _rewardRateDailyPercentage;
    }

    // Modifiers

    modifier updateReward() {
        if(isClaimActive)
        {
            uint daysSinceLastDayRewardCalculation = (block.timestamp - lastDayCalculatedTimestamp)/(STAKING_CLOSE_PERIOD);
            if(totalDeposits > 0 && daysSinceLastDayRewardCalculation > 0)
            {
                for(uint i=0; i<daysSinceLastDayRewardCalculation; i++)
                {
                    uint currentContractTokenSupply = busd.balanceOf(address(this)) - pendingClaim;
                    uint currentDayReward = ((currentContractTokenSupply * rewardRateDailyPercentage) / 10000);
                    dayTotalRewards[lastDayCalculated + i] = currentDayReward;
                    dayTotalDeposited[lastDayCalculated + i] = totalDeposits;
                    pendingClaim += currentDayReward;
                }
                lastDayCalculated = lastDayCalculated + daysSinceLastDayRewardCalculation;
                lastDayCalculatedTimestamp = block.timestamp;
            }
        }
        _;
    }
    // External functions

    function stake(uint amount) external updateReward() {
        require(isClaimActive, "Claim must be active.");
        require(amount > 0, "Amount must be greater than 0.");
        if(depositAmount[msg.sender] == 0)
        {
            totalStakers += 1;
        }
        totalDeposits += amount;

        uint firstDayToClaim = (block.timestamp - rewardGenesisTiemstamp) / (STAKING_CLOSE_PERIOD);
        lastClaimedDay[msg.sender] = firstDayToClaim;
        
        depositAmount[msg.sender] += amount;
        busToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdrawBus(uint amount) external updateReward() {
        require(amount > 0, "No amount sent.");
        require(depositAmount[msg.sender] > 0, "Sender has no deposits.");
        require(depositAmount[msg.sender] >= amount, "Sender has no enough BUS deposited to match withdraw amount.");
        claim();
        totalDeposits -= amount;
        depositAmount[msg.sender] -= amount;
        if(depositAmount[msg.sender] == 0)
        {
            totalStakers -= 1;
        }
        busToken.transfer(msg.sender, amount);
    }

    function withdrawBusWithoutClaim(uint amount) external updateReward() {
        require(amount > 0, "No amount sent.");
        require(depositAmount[msg.sender] > 0, "Sender has no deposits.");
        require(depositAmount[msg.sender] >= amount, "Sender has no enough BUS deposited to match withdraw amount.");
        totalDeposits -= amount;
        depositAmount[msg.sender] -= amount;
        if(depositAmount[msg.sender] == 0)
        {
            totalStakers -= 1;
        }
        busToken.transfer(msg.sender, amount);
    }

    function claim() public updateReward() {
        require(isClaimActive, "Claim must be active.");

        uint reward;
        uint daysClaimed;
        while(lastClaimedDay[msg.sender] + daysClaimed < lastDayCalculated)
        {
            if(dayTotalDeposited[lastClaimedDay[msg.sender] + daysClaimed] != 0)
            {
                reward += (dayTotalRewards[lastClaimedDay[msg.sender] + daysClaimed] * depositAmount[msg.sender])
                    / dayTotalDeposited[lastClaimedDay[msg.sender] + daysClaimed];
            }
            daysClaimed += 1;
        }

        lastClaimedDay[msg.sender] += daysClaimed;
        pendingClaim -= reward;
        totalBUSDRewarded += reward;
        busd.transfer(msg.sender, reward);
    }

    function calculateClaim(address participant) public view returns(uint)
    {
        if(depositAmount[participant] == 0)
        {
            return 0;
        }
        uint reward;
        uint daysClaimed;
        while(dayTotalDeposited[lastClaimedDay[participant] + daysClaimed] != 0)
        {
            reward += (dayTotalRewards[lastClaimedDay[participant] + daysClaimed] * depositAmount[participant])
                / dayTotalDeposited[lastClaimedDay[participant] + daysClaimed];
            daysClaimed+=1;
        }

        uint daysSinceLastDayRewardCalculation = (block.timestamp - lastDayCalculatedTimestamp)/(STAKING_CLOSE_PERIOD);
        uint pendingClaimAux = pendingClaim;
        uint totalDepositsAux = totalDeposits;
        for(uint i=0; i<daysSinceLastDayRewardCalculation; i++)
        {
            uint currentContractTokenSupply = busd.balanceOf(address(this)) - pendingClaimAux;
            uint currentDayReward = ((currentContractTokenSupply * rewardRateDailyPercentage) / 10000);
            reward += (currentDayReward * depositAmount[participant])
                / totalDepositsAux;
            pendingClaimAux += currentDayReward;
        }
        return reward;
    }

    function updateRewardFunction() public updateReward() {
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}