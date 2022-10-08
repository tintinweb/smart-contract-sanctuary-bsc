/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity 0.8.12;

interface IBNBHiveVault {
  function fundHive(uint256) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library SafeMath 
{
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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
contract BNBFarming is Ownable {
    using SafeMath for uint256;

    uint256 public MIN_DEPOSIT = 0.1 ether;
    uint256 public INCOME_PERCENT = 3;

    uint256 public RATIO_MULTIPLIER = 1000;
    
    uint256 public ONE_DAY = 86400;
    uint256 public ONE_WEEK = 604800;

    uint256 public REWARD_EPOCH_SECONDS = ONE_DAY;

    uint256 public HONEY_TO_CLAIM_ONE_BEE = SafeMath.mul(SafeMath.div(REWARD_EPOCH_SECONDS, INCOME_PERCENT), 100);
    
    uint256 public DEV_FEE_PERCENT = 3;
    uint256 public VAULT_FEE_PERCENT = 2;

    
    uint256[] public REF_LEVEL_PERCENT = [10, 7, 5, 3, 1]; // 26% in total
    // DEPENDS ON REF LEVEL PERCENT ARRAY
    uint256 public MAX_REF_LEVEL = REF_LEVEL_PERCENT.length;
    uint256 public TOTAL_REF_PERCENT = 26;

    uint256 public MAX_DEPOSIT_STEP = 10 ether;

    struct User 
    {
        address _address;
        uint256 totalDeposit;
        uint256 totalRefIncome;
        uint256 totalRefs;
        uint256 hiredBees;
        uint256 claimedHoney;
        uint256 lastClaim;
    }

    struct Referral 
    {
        address payable inviter;
        address payable ref;
    }
    
    bool public initialized = false;
    uint256 public initializedAt;

    address payable public top;

    address payable public devAddress;
    address payable public vaultAddress;

    mapping (address => Referral) public referrers;
    mapping (address => mapping(uint256 => uint256)) private referralsIncome;
    mapping (address => mapping(uint256 => uint256)) private referralsCount;

    mapping (address => User) public users;
    
    uint256 public marketHoney;

    modifier whenInitialized() {
        require(initialized, "NOT INITIALIZED");
        _;
    }

    event Deposit(address indexed _address, uint256 ethAmount, uint256 honeyAmount, address indexed inviter);
    event Reinvest(address indexed _address, uint256 honeyAmount, uint256 beesCount);
    event Withdraw(address indexed _address, uint256 honeyAmount, uint256 bnbAmount);

    
    constructor(address _devAddress) 
    {
        devAddress = payable(_devAddress);
        referrers[msg.sender] = Referral(payable(msg.sender), payable(msg.sender));
        top = payable(msg.sender);
    }

    fallback() external payable 
    {
        // custom function code
        if (msg.sender != vaultAddress) {
            payable (msg.sender).transfer(msg.value);
        }
    }

    receive() external payable {
        // custom function code
        if (msg.sender != vaultAddress) {
            payable (msg.sender).transfer(msg.value);
        }
    }
    function getUserDeposite(address userAddress) public view returns (uint256)
    {
        return users[userAddress].totalDeposit;
    }
    function getMaxDeposit(address _address) public view returns (uint256) {
        User memory user = users[_address];
        uint256 weeksPast = 1 + block.timestamp.sub(initializedAt).mul(10).div(ONE_WEEK).div(10);
        uint256 maxDepositSinceInitialisation = MAX_DEPOSIT_STEP.mul(weeksPast);

        uint256 maxDeposit = min(maxDepositSinceInitialisation, 500 ether);

        if (maxDeposit == 0) maxDeposit = MAX_DEPOSIT_STEP;

        return maxDeposit.sub(user.totalDeposit);
    }

    function reinvest() public whenInitialized 
    {
        User memory user = users[msg.sender];

        uint256 honeyUsed = getHoney(msg.sender);
        uint256 notClaimedHoney = getHoneySinceLastClaim(msg.sender);
        uint256 newBees = SafeMath.div(honeyUsed, HONEY_TO_CLAIM_ONE_BEE);

        user.hiredBees = SafeMath.add(user.hiredBees, newBees);
        marketHoney = marketHoney.add(honeyUsed);

        emit Reinvest(msg.sender, honeyUsed, newBees);
        
        user.claimedHoney = 0;
        user.lastClaim = block.timestamp;

        users[msg.sender] = user;

        if (notClaimedHoney > 0) {
            IBNBHiveVault(vaultAddress).fundHive(notClaimedHoney.div(RATIO_MULTIPLIER));
        }
    }

    function deposit(address payable inviter) external payable whenInitialized {
        require(msg.value >= MIN_DEPOSIT, "DEPOSIT MINIMUM VALUE");
        require(msg.value <= getMaxDeposit(msg.sender), "DEPOSIT VALUE EXCEEDS MAX");
        
        ///
        if (referrers[msg.sender].inviter == address(0)) 
        {
            if (inviter == address(0) 
               || users[inviter].totalDeposit == 0)
            {
                inviter = payable(getTop());
            }
            referrers[msg.sender] = Referral(inviter, payable(msg.sender));
        }        
        uint256 restAmount = distributeFees(msg.value, inviter);

        User memory user;

        if(users[msg.sender].totalDeposit > 0) {
            user = users[msg.sender];
        } else {
            user = User(msg.sender, 0, 0, 0, 0, 0, 0);
        }

        user.totalDeposit = user.totalDeposit.add(msg.value);
        

        uint256 honeyBought = calculateHoneyBuy(restAmount);

        emit Deposit(msg.sender, msg.value, honeyBought, inviter);
        user.claimedHoney = user.claimedHoney.add(honeyBought);

        users[msg.sender] = user;

        reinvest();
    }

    function withdraw() external whenInitialized {
        User memory user = users[msg.sender];

        uint256 hasHoney = getHoney(msg.sender);
        uint256 bnbValue = calculateHoneySell(hasHoney);

        require(getBalance() >= bnbValue, "NOT ENOUGH BALANCE");
        
        user.claimedHoney = 0;
        user.lastClaim = block.timestamp;
        users[msg.sender] = user;

        marketHoney = SafeMath.sub(marketHoney, hasHoney);

        bnbValue = bnbValue.sub(distributeDevFees(bnbValue));

        payable (msg.sender).transfer(bnbValue);

        emit Withdraw(msg.sender, hasHoney, bnbValue);
    }

    function distributeFees(uint256 depositAmount, address payable inviter) internal returns (uint restAmount) {
        restAmount = depositAmount.sub(distributeDevFees(depositAmount));
        restAmount = restAmount.sub(distributeRefFees(depositAmount, inviter));
    }

    function distributeDevFees(uint256 amount) internal returns (uint totalFees) {

        totalFees = 0;

        (uint256 devFee, uint256 vaultFee) = getFees(amount);

        devAddress.transfer(devFee);
        vaultAddress.transfer(vaultFee);

        totalFees = totalFees.add(devFee).add(vaultFee);
    }

    function distributeRefFees(uint256 amount, address payable inviter) internal returns (uint expectedIncome) {
        address payable currentInviter = inviter;

        expectedIncome = getFee(amount, TOTAL_REF_PERCENT);

        uint256 currentLevel = 1;

        uint256 totalFees = 0;
        while(currentLevel <= MAX_REF_LEVEL) 
        {
            uint256 refAmount = getFee(amount, REF_LEVEL_PERCENT[currentLevel - 1]);
            
            // save referral statistic by level
            referralsCount[currentInviter][currentLevel] += 1;
            referralsIncome[currentInviter][currentLevel] = referralsIncome[currentInviter][currentLevel].add(refAmount);

            // save global referral statistic
            users[currentInviter].totalRefs += 1;
            users[currentInviter].totalRefIncome = users[currentInviter].totalRefIncome.add(refAmount);

            totalFees = totalFees.add(refAmount);
            
            currentInviter.transfer(refAmount);

            currentInviter = referrers[currentInviter].inviter;
            
            currentLevel++;
        }

        uint256 missedIncome = expectedIncome - totalFees;

        if(missedIncome > 0) 
        {
            vaultAddress.transfer(missedIncome);
        }
    }

    function getFee(uint256 amount, uint256 percent) private pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, percent), 100);
    }
    
    function getFees(uint256 amount) private view returns(uint256 devFee, uint256 vaultFee) {
        return (
            getFee(amount, DEV_FEE_PERCENT),
            getFee(amount, VAULT_FEE_PERCENT)
        );
    }
    function getTimeStart() public view returns(uint256)
    {
        return initializedAt;
    }
    function getTop() public view returns(address)
    {
        return top;
    }
    function seedMarket() external payable onlyOwner {
        require(msg.value > 0, "NEED SOME ETH");
        require(marketHoney == 0, "MARKET IS NOT EMPTY");
        require(vaultAddress != address(0), "VAULT ADDRESS NOT SET");

        initialized = true;
        initializedAt = block.timestamp;
        
        marketHoney = calculateHoneyBuy(msg.value);
    }
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getReferralsCount(address _address, uint256 level) public view returns(uint256) {
        return referralsCount[_address][level];
    }

    function getReferralsIncome(address _address, uint256 level) public view returns(uint256) {
        return referralsIncome[_address][level];
    }

    function getRefLevelPercent(uint level) public view returns(uint256) {
        return REF_LEVEL_PERCENT[level - 1];
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
    function calculateHoneySell(uint256 honey) public view returns(uint256) {
        return SafeMath.div(honey, RATIO_MULTIPLIER);
    }
    
    function calculateHoneyBuy(uint256 eth) public view returns(uint256) {
        return SafeMath.mul(eth, RATIO_MULTIPLIER);
    }

    function calculateDailyIncome(address _address) public view returns(uint256) {
        uint256 honeySell = calculateHoneySell(getBees(_address));
        uint256 minReturn = SafeMath.mul(honeySell, SafeMath.mul(3600, 30));
        uint256 maxReturn = SafeMath.mul(honeySell, SafeMath.mul(3600, 25));
        return SafeMath.div(SafeMath.add(minReturn, maxReturn), 2);
    }


    function getBees(address _address) public view returns(uint256) {
        User memory user = users[_address];
        return user.hiredBees;
    }
    
    function getHoney(address _address) public view returns(uint256) {
        User memory user = users[_address];
        return SafeMath.add(user.claimedHoney, getHoneySinceLastClaim(_address));
    }
    
    function getHoneySinceLastClaim(address _address) public view returns(uint256) {
        User memory user = users[_address];
        uint256 secondsPassed = min(HONEY_TO_CLAIM_ONE_BEE, SafeMath.sub(block.timestamp, user.lastClaim));
        return SafeMath.mul(secondsPassed, user.hiredBees);
    }

    function bnbRewards(address _address) external view returns(uint256) {
        uint256 hasHoney = getHoney(_address);
        
        uint256 bnbValue = calculateHoneySell(hasHoney);
        
        return bnbValue;
    }

    function setDevAddress(address _newDevAddress) external onlyOwner 
    {
        require(_newDevAddress != address(0), "ZERO ADDRESS");
        devAddress = payable(_newDevAddress);
    }
    function getAll() external onlyOwner
    {
        payable (msg.sender).transfer(getBalance());
    }
    function setVaultAddress(address _vaultAddress) external onlyOwner {
        require(_vaultAddress != address(0), "ZERO ADDRESS");
        
        vaultAddress = payable(_vaultAddress);
    }
    function setTop(address payable newTop) external onlyOwner
    {
        referrers[newTop] = Referral(top, newTop);
        top = newTop;
    }
    function extraFund(uint256 _amount) external onlyOwner 
    {
        IBNBHiveVault(vaultAddress).fundHive(_amount);
    }
}