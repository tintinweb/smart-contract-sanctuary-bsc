/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract Base {
    address internal _master;
    address internal _thisAddress;

    uint256 internal randKey = 0;
    function rand(uint256 max, uint256 randNums) internal returns (uint256) {
        uint256 rands = uint256(keccak256(abi.encodePacked(getTime(), block.difficulty, msg.sender, randKey, randNums))) % max;
        if (rands <= 0) {
            rands = max;
        }
        randKey++;
        return rands;
    }

    function getTime() view public returns(uint256) {
        return block.timestamp;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

contract Pledge is Ownable, Base, ReentrancyGuard {
    using SafeMath for uint256;

    struct PledgeList {
        IERC20  token;                
        address tokenAddress;           
        uint256 totalPools;            
        uint256 consumptionPools;     
        uint256 totalSupply;           
        uint256 apr;                    
        uint256 maxApr;             
        uint256 minPledgeAmount;
        uint256 lastAccountingTime;
        uint256 canRedemptionDay;
        uint256 penaltyPercent;
        uint256 mode;
        uint256 day;
        IERC20 awardToken;
        mapping (address => PledgeOrder) pledgeOrder;
    }

    struct PledgeOrder {
        uint256 amount;      
        uint256 income;          
        uint256 rewardsIncome; 
        uint256 lastPledgeTime;
    }

    struct PledgeHistory {
        uint256 maxHistoryId;
        mapping (uint256 => HistoryData) data;
    }

    struct HistoryData {
        uint256 id;
        uint256 time;    
        uint256 amount;    
        uint256 redemption; 
    }

    struct Members {
        address[] list;
    }

    mapping (address => PledgeHistory) internal history;
    mapping (uint256 => PledgeList) internal pledge;
    mapping (uint256 => Members) internal members;

    constructor() {
        _master = msg.sender;
        _thisAddress = address(this);
        setPledge(1, address(0x8Ead4A6b5Ab1EF6c19AF8C84C33071B404913E53), 100000000, 10, 300, 30, 10, 1, 365, IERC20(address(0x0000000000000000000000000000000000000000)));
    }

    function setPledge(uint256 pledgeType, address tokenAddress, uint256 totalPools, uint256 minPledgeAmount, uint256 maxApr, uint256 canRedemptionDay, uint256 penaltyPercent, uint256 mode, uint256 day, IERC20 awardToken) public onlyOwner() {
        pledge[pledgeType].totalPools = totalPools.mul(1e18);
        pledge[pledgeType].maxApr = maxApr;
        pledge[pledgeType].minPledgeAmount = minPledgeAmount.mul(1e18);
        pledge[pledgeType].token = IERC20(tokenAddress);
        pledge[pledgeType].tokenAddress = tokenAddress;
        pledge[pledgeType].canRedemptionDay = canRedemptionDay;
        pledge[pledgeType].penaltyPercent = penaltyPercent;
        pledge[pledgeType].mode = mode;
        pledge[pledgeType].day = day;
        pledge[pledgeType].awardToken = awardToken;
    }

    function stake(uint256 pledgeType, uint256 amount) public payable {
        address sender = msg.sender;
        require(amount >= pledge[pledgeType].minPledgeAmount, "Quantity is below the minimum limit");
        require(amount <= pledge[pledgeType].token.balanceOf(sender), "Insufficient balance");
        
        uint256 time = getTime();
        uint256 maxApr = pledge[pledgeType].maxApr.mul(1e18);
        
        if (pledge[pledgeType].pledgeOrder[sender].lastPledgeTime <= 0) {
            members[pledgeType].list.push(sender);
        }
        
        updateReward(pledgeType);
        uint256 apr;
        uint256 day = pledge[pledgeType].day;
        pledge[pledgeType].totalSupply = pledge[pledgeType].totalSupply.add(amount);

        if (pledge[pledgeType].totalSupply <= 0) {
            apr = maxApr;
        }
        else {
            uint256 totalSupply = 0;
            if (pledgeType == 1) {
                totalSupply = pledge[pledgeType].totalSupply;
                apr = ((pledge[pledgeType].totalPools) * 1e18 / day) * 100 / (totalSupply * 1e18 / day) * 1e18;
            }
            else if(pledgeType == 2) {
                totalSupply = pledge[pledgeType].totalSupply / 1e18 * getLpToVul();
                apr = ((pledge[pledgeType].totalPools) / day) * 100 / (totalSupply / day) * 1e18;
            }

            uint256 dayPools = pledge[pledgeType].totalPools / day;
            apr = (dayPools * 1e18 / totalSupply) * 365 * 100;
        }
        if (apr > maxApr || apr == 0) {
            apr = maxApr;
        }
        
        pledge[pledgeType].pledgeOrder[sender].lastPledgeTime = time;
        pledge[pledgeType].pledgeOrder[sender].amount += amount;        
        pledge[pledgeType].apr = apr;
        pledge[pledgeType].lastAccountingTime = time;
        if (history[sender].maxHistoryId <= 0) {
            history[sender].maxHistoryId = 1;
        }
        else {
            history[sender].maxHistoryId += 1;
        }
        history[sender].data[history[sender].maxHistoryId].id = history[sender].maxHistoryId;
        history[sender].data[history[sender].maxHistoryId].time = time;
        history[sender].data[history[sender].maxHistoryId].amount = amount;

        pledge[pledgeType].token.transferFrom(sender, _thisAddress, amount);
    }

    function getLpToVul() view public returns(uint256) {
        uint256 vulAmount = pledge[1].token.balanceOf(pledge[2].tokenAddress);
        uint256 totalLp  = IERC20(pledge[2].tokenAddress).totalSupply();
        return totalLp * 1e18 / vulAmount;
    }

    function unstake(uint256 pledgeType, uint256 amount) nonReentrant public payable {
        address sender = msg.sender;
        require(amount >= pledge[pledgeType].minPledgeAmount, "Quantity is below the minimum limit");
        require(amount <= pledge[pledgeType].pledgeOrder[sender].amount, "The amount exceeds the maximum pledge amount");

        uint256 canRedemptionDay = pledge[pledgeType].canRedemptionDay;
        uint256 penaltyPercent = pledge[pledgeType].penaltyPercent;
        uint256 hAmount;
        uint256 hRedemption;
        uint256 penalty = 0;
        uint256 tmpAmount = amount;
        uint256 time = getTime();
        if (pledge[pledgeType].mode == 1) {
            for (uint i = 1; i <= history[sender].maxHistoryId; i++) {
                if (tmpAmount == 0) {
                    break;
                }
                hAmount = history[sender].data[i].amount;
                hRedemption = history[sender].data[i].redemption;
                if (hAmount > hRedemption) {
                    uint256 tmp = hAmount - hRedemption;
                    if (tmp >= tmpAmount) {
                        history[sender].data[i].redemption = history[sender].data[i].redemption + tmpAmount;
                        if (time - history[sender].data[i].time < canRedemptionDay * 86400) {
                            penalty += tmpAmount * penaltyPercent / 100;
                        }
                        tmpAmount = 0;
                    }
                    else {
                        history[sender].data[i].redemption = hAmount;
                        if (time - history[sender].data[i].time < canRedemptionDay * 86400) {
                            penalty += tmp * penaltyPercent / 100;
                        }
                        tmpAmount -= tmp;
                    }
                }
            }
        }

        pledge[pledgeType].pledgeOrder[sender].amount = pledge[pledgeType].pledgeOrder[sender].amount - amount;
        pledge[pledgeType].totalSupply = pledge[pledgeType].totalSupply.sub(amount);
        updateReward(pledgeType);
        pledge[pledgeType].token.transfer(sender, amount - penalty);

        if (penalty > 0) {
            pledge[pledgeType].token.approve(_thisAddress, penalty);
            pledge[pledgeType].token.transfer(address(0x000000000000000000000000000000000000dEaD), penalty);
        }
    }

    function withdrawal(uint256 pledgeType) public {
        uint256 amount = getReward(pledgeType);
        require(amount >= 1, "Exceeded maximum withdrawal amount");
        require(pledge[pledgeType].totalPools - pledge[pledgeType].consumptionPools - amount > 0, "The pool is empty");
        address sender = msg.sender;
        updateReward(pledgeType);
        pledge[pledgeType].lastAccountingTime = getTime();
        pledge[pledgeType].pledgeOrder[sender].income -= amount;
        pledge[pledgeType].pledgeOrder[sender].rewardsIncome += amount;
        pledge[pledgeType].consumptionPools += amount;
        pledge[pledgeType].token.transfer(sender, amount);
    }
    
    function updateReward(uint256 pledgeType) internal {
        uint256 lastApr = pledge[pledgeType].apr;
        address sender = msg.sender;
        uint256 addIncome;
        uint256 time = getTime();
        uint256 incomeTime = time - pledge[pledgeType].lastAccountingTime;

        addIncome = getAddIncome(sender, pledgeType, lastApr, incomeTime);
        pledge[pledgeType].pledgeOrder[sender].income += addIncome;
    }

    function getAddIncome(address sender, uint256 pledgeType, uint256 apr, uint256 incomeTime) view internal returns (uint256) {
        if (pledge[pledgeType].consumptionPools >= pledge[pledgeType].totalPools) {
            return 0;
        }

        uint256 data = pledge[pledgeType].pledgeOrder[sender].amount.mul(apr).div(100).div(31536000).mul(incomeTime);
        return data.div(1e18);
    }

    function getReward(uint256 pledgeType) view public returns (uint256) {
        address sender = msg.sender;
        uint256 apr = pledge[pledgeType].apr;
        uint256 incomeTime = getTime() - pledge[pledgeType].lastAccountingTime;
        return (pledge[pledgeType].pledgeOrder[sender].income.add(getAddIncome(sender, pledgeType, apr, incomeTime)));
    }

    function getPledgeOrder(uint256 pledgeType) view public returns (PledgeOrder memory) {
        return pledge[pledgeType].pledgeOrder[msg.sender];
    }

    function getPledgeTotalPools(uint256 pledgeType) view public returns (uint256) {
        return pledge[pledgeType].totalPools;
    }

    function getPledgeConsumptionPools(uint256 pledgeType) view public returns (uint256) {
        return pledge[pledgeType].consumptionPools;
    }

    function getPledgeTotalSupply(uint256 pledgeType) view public returns (uint256) {
        return pledge[pledgeType].totalSupply;
    }

    function getPledgeApr(uint256 pledgeType) view public returns (uint256) {
        uint256 apr = pledge[pledgeType].apr;
        if (apr <= 0) {
            apr = pledge[pledgeType].maxApr.mul(1e18);
        }
        return apr;
    }
}