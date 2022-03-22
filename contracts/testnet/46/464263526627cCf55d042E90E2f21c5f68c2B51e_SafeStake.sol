//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./AffinityDistributor.sol";
import "./Utils.sol";
import "./Auth.sol";
import "./IDEXRouter.sol";
import "./ReflectionLocker02.sol";
import "./ISafeAffinity.sol";
import "./SafeAffinity.sol";
import "./SafeMaster.sol";


contract SafeStake is Auth, Pausable {
    using SafeMath for uint256;

    IERC20 public rewardsToken;
    SafeMaster safeMaster;

    // TODO APR calc
    uint public aprCount;
    uint public lastDistributed;
    uint public currentAPR;
    mapping (uint => uint[2]) APRs; // APRs[aprCount] = [lastDistributed, currentAPR]
    
    mapping (address => bool) excludeSwapperRole;
    mapping (address => ReflectionLocker02) public lockers;

    ReflectionLocker02[] public lockersArr;
    AffinityDistributor distributor;

    uint public permittedDuration; // in second 
    uint public permissionFee; // 100 = 1%

    struct Share {
        uint256 lastStakeTime;
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }


    SafeAffinity safeAffinity;
    
    IERC20 safeEarn;
    IERC20 safeVault;

    IDEXRouter public router;
    uint public lunchTime;

    struct TokenPool {
        uint totalShares;
        uint totalDividends;
        uint totalDistributed;
        uint dividendsPerShare;
        IERC20 stakingToken;
    }

    TokenPool public tokenPool;

    //Shares by token vault
    mapping ( address => Share) public shares;

    // uint public duration = 14 days;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    constructor (address _router, address _rewardsToken, address _stakingToken, address _safeEarnAddr, address _safeVaultAddr, address _safeMasterAddr, uint256 _permittedDuration, uint256 _permissionFee) Auth (msg.sender) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        rewardsToken = IERC20(_rewardsToken);
        tokenPool.stakingToken = IERC20(_stakingToken);
        safeAffinity = SafeAffinity(payable(_stakingToken));
        lunchTime = block.timestamp;
        distributor = safeAffinity.distributor() ;
        safeEarn = IERC20(_safeEarnAddr);
        safeVault = IERC20(_safeVaultAddr);
        safeMaster = SafeMaster(_safeMasterAddr);
        permittedDuration = _permittedDuration;
        permissionFee = _permissionFee;
        lastDistributed = block.timestamp;
    }

    function lunch() external authorized {
        lunchTime = block.timestamp;
    }

    // Lets you stake token A. Creates a reflection locker to handle the reflections in an efficient way.
    function enterStaking(uint256 amount) external whenNotPaused {
        if (amount == 0)
            amount = tokenPool.stakingToken.balanceOf(msg.sender);

        require(amount <= tokenPool.stakingToken.balanceOf(msg.sender), "Insufficient balance to enter staking");
        require(tokenPool.stakingToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");

        // Gather user's privilage parameter 
        bool userIsFeeExempt = safeAffinity.getIsFeeExempt(msg.sender);
        bool userIsTxLimitExempt = safeAffinity.getIsTxLimitExempt(msg.sender);
        // give user privilage to stake for unlimited amount & no tax
        // safeAffinity.setIsFeeAndTXLimitExempt(msg.sender, true, true);
        safeMaster.delegateExemptFee(msg.sender, true, true);
        bool success = tokenPool.stakingToken.transferFrom(msg.sender, address(this), amount);
        // Set the privilage level to user original setting
        // safeAffinity.setIsFeeAndTXLimitExempt(msg.sender, userIsFeeExempt, userIsTxLimitExempt);
        safeMaster.delegateExemptFee(msg.sender, userIsFeeExempt, userIsTxLimitExempt);

        require(success, "Failed to fetch tokens towards the staking contract");

        // Create a reflection locker for type A pool
        if (address(tokenPool.stakingToken) == address(safeAffinity)) {
            bool lockerExists = address(lockers[msg.sender]) == address (0);

            ReflectionLocker02 locker;
            if (!lockerExists) {
                locker = lockers[msg.sender];
            } else {
                locker = new ReflectionLocker02(msg.sender, SafeAffinity(safeAffinity), address(safeAffinity.distributor()), address(safeEarn), address(safeVault), address(this), address(router));
                lockersArr.push(locker); //Stores locker in array
                lockers[msg.sender] = locker; //Stores it in a mapping
                address lockerAdd = address(lockers[msg.sender]);
                // safeAffinity.setIsFeeAndTXLimitExempt(lockerAdd, true, true);
                safeMaster.delegateExemptFee(lockerAdd, true, true);

                emit ReflectionLockerCreated(lockerAdd);
            }
            tokenPool.stakingToken.transfer(address(locker), amount);
        }

        // Give out rewards if already staking
        if (shares[msg.sender].amount > 0) {
            giveStakingReward(msg.sender);
        }

        addShareHolder(msg.sender, amount);
        emit EnterStaking(msg.sender, amount);
    }

    function reflectionsEarnInLocker(address holder) public view returns (uint) {
        return safeEarn.balanceOf(address(lockers[holder])) + distributor.getUnpaidEarnEarnings(address(lockers[holder]));
    }

    
    function reflectionsVaultInLocker(address holder) public view returns (uint) {
        return safeVault.balanceOf(address(lockers[holder])) + distributor.getUnpaidVaultEarnings(address(lockers[holder]));
    }

    
    function leaveStaking(uint amt) external {
        require(shares[msg.sender].amount > 0, "You are not currently staking.");

        // Pay native token rewards.
        if (getUnpaidEarnings(msg.sender) > 0) {
            giveStakingReward(msg.sender);
        }

        uint amtEarnClaimed = 0;
        uint amtVaultClaimed = 0;

        // Get rewards & stake from locker
        uint permissionRate = shares[msg.sender].lastStakeTime + permittedDuration > block.timestamp ? permissionFee : 0;
        lockers[msg.sender].claimTokens(amt, permissionRate);
        
        amtEarnClaimed = lockers[msg.sender].claimEarnReflections();
        amtVaultClaimed = lockers[msg.sender].claimVaultReflections();

        if (amt == 0) {
            amt = shares[msg.sender].amount;
            removeShareHolder();
        } else {
            _removeShares(amt);
        }

        emit LeaveStaking(msg.sender, amt, amtEarnClaimed, amtVaultClaimed);
    }


    function giveStakingReward(address shareholder) internal {
        require(shares[shareholder].amount > 0, "You are not currently staking");

        uint256 amount = getUnpaidEarnings(shareholder);

        if(amount > 0){
            tokenPool.totalDistributed = tokenPool.totalDistributed.add(amount);
            rewardsToken.transfer(shareholder, amount);
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    
    function harvest() external whenNotPaused {
        require(getUnpaidEarnings(msg.sender) > 0 || reflectionsEarnInLocker(msg.sender) > 0 || reflectionsVaultInLocker(msg.sender) > 0, "No earnings yet ser");
        uint unpaid = getUnpaidEarnings(msg.sender);
        uint amtEarnClaimed = 0;
        uint amtVaultClaimed = 0;
        // uint amtMoonClaimed = 0;
        if (!isLiquid(getUnpaidEarnings(msg.sender))) {
            getRewardsToken(address(this).balance);
        }
        amtEarnClaimed = lockers[msg.sender].claimEarnReflections();
        amtVaultClaimed = lockers[msg.sender].claimVaultReflections();
        
        giveStakingReward(msg.sender);
        emit Harvest(msg.sender, unpaid, amtEarnClaimed, amtVaultClaimed);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function distributeRewards() payable authorized public {
        require(!paused(), "Contract has been paused.");
        // require(block.timestamp < (lunchTime + duration), "Contract has ended.");

        // TODO APR calc
        uint dividendPerShareBefore = tokenPool.dividendsPerShare;
        
        if (!excludeSwapperRole[msg.sender]) {
            getRewardsToken(address(this).balance);
        } 

        // TODO APR calc
        aprCount ++;
        currentAPR = (((tokenPool.dividendsPerShare - dividendPerShareBefore) / (block.timestamp - lastDistributed)) * 60 * 60 * 24 * 365);
        lastDistributed = block.timestamp;
        APRs[aprCount] = [lastDistributed, currentAPR];
    }
    
    receive() external payable {}

    // Update pool shares and user data
    function addShareHolder(address shareholder, uint amount) internal {
        tokenPool.totalShares = tokenPool.totalShares.add(amount);
        shares[shareholder].amount = shares[shareholder].amount + amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        
        if (shares[shareholder].lastStakeTime == 0 || shares[shareholder].lastStakeTime + permittedDuration > block.timestamp) {
            shares[shareholder].lastStakeTime = block.timestamp;
        }
    }

    function removeShareHolder() internal {

        tokenPool.totalShares = tokenPool.totalShares.sub(shares[msg.sender].amount);
        shares[msg.sender].amount = 0;
        shares[msg.sender].totalExcluded = 0;
    }

    function _removeShares(uint amt) internal {
        tokenPool.totalShares = tokenPool.totalShares.sub(amt);
        shares[msg.sender].amount = shares[msg.sender].amount.sub(amt);
        shares[msg.sender].totalExcluded = getCumulativeDividends(shares[msg.sender].amount);
    }


    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(tokenPool.dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function isLiquid(uint amount) internal view returns (bool){
        return rewardsToken.balanceOf(address(this)) > amount;
    }

    function getRewardsTokenPath() internal view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardsToken);
        return path;
    }

    function getRewardsToken(uint amt) internal returns (uint) {
        uint256 balanceBefore = rewardsToken.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amt}(
            0,
            getRewardsTokenPath(),
            address(this),
            block.timestamp + 10
        );
        uint256 amount = rewardsToken.balanceOf(address(this)).sub(balanceBefore);

        tokenPool.totalDividends = tokenPool.totalDividends.add(amount);
        tokenPool.dividendsPerShare = tokenPool.dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(tokenPool.totalShares));
        return amount;
    }
    
    function setSwapperExcluded(address _add, bool _excluded) external authorized {
        excludeSwapperRole[_add] = _excluded;
    }
    
    function emergencyWithdraw() external {
        uint permissionRate = shares[msg.sender].lastStakeTime + permittedDuration > block.timestamp ? permissionFee : 0;
        lockers[msg.sender].claimTokens(0, permissionRate);
        removeShareHolder();
    }

    function pause(bool _pauseStatus) external authorized {
        if (_pauseStatus) {
            _pause();
        } else {
            _unpause();
        }
    }

    function getPreviousAPR(uint _aprCount) view public returns(uint[2] memory) {
        return APRs[_aprCount];
    }

    function rewardsTokenAddr() view public returns(address) {
        return address(rewardsToken);
    }

    //Events
    event ReflectionLockerCreated(address);
    event EnterStaking(address, uint);
    event LeaveStaking(address, uint, uint, uint);
    event Harvest(address, uint, uint, uint);
    event PoolLiquified(uint, uint);

}