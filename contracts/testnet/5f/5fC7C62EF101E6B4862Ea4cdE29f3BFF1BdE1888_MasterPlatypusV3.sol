// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import './interfaces/IMasterPlatypusV3.sol';
import './interfaces/IMARKET.sol';
import './interfaces/IveMARKET.sol';
import './interfaces/IAsset.sol';
import './libraries/Math.sol';

contract MasterPlatypusV3 is IMasterPlatypusV3{    

    /** 
        pid:  0 - USDT_LP
              1 - DAI_LP
              2 - USDC_LP
    */
    struct LPStakedUserInfo {
        uint256 lpAmount;
        uint256 rewardAmount;
        uint256 lastTimestamp; // second
        uint256 pid;
    }

    struct PTPStakedUserInfo {
        uint256 ptpAmount;
        uint256 rewardAmount;
        uint256 lastTimestamp; // second        
    }

    address private _owner;
    IMARKET public PTP;
    IveMARKET public VePTP;

    // fantom testnet
    address private fUSDT_LP = address(0xED3b35c97Ea491E18237a74376DCe1754f9A6dA6);
    address private DAI_LP = address(0x31949BFC1Be22e1411Ff8fEbDA7f6262BDfE4f44);
    address private USDC_LP = address(0x8969A004EA0129969f7Fe9154d970865Cc295944);    

    address[] public lpTokens;    
    mapping(uint256 => mapping(address => LPStakedUserInfo)) private _lpStakedUserInfo;
    mapping(address => PTPStakedUserInfo) private _ptpStakedUserInfo;
    
    uint256 private _rfBasePTP = 1157400000; //1157400000 = 1.1574 * 10**9
    uint256 private _rfBoostPTP = 5787000000; //9000000000 = 9 * 10**9
    uint256 private _rfVePTP = 3858100000000;  // 10**(-18) * 10month *_rfVePTP = 100 => _rfVePTP = 10**20 / 10month = 3.859*10**12 = 3858100000000
    uint256 private _rfVePTPMultiple = 100;    // users can get reward maximum 100 times of staked PTP amount

    /** Reward Generation Formula
    - Total PTP Reward Amount = Base PTP Reward Amount + Boost PTP Reward Amount        
        Base PTP Reward Amount = _rfBasePTP * myStakedLPAmount * stakingTime * coverageRatio * totalLPAmountOfAllLPPool / (lpCounts * totalLPAmountOfCurrentLPPool * (10 ** 18))            
        Boost PTP Reward Amount = _rfBoostPTP * sqrt(myStakedLPAmount * myVePTPBalance) * stakingTime / sumOfAllVePTPHolders(sqrt(stakedLPAmount * VePTPBalance)) * (10 ** 18))    
        (lpCount: 3 - USDT_LP, USDC_LP, DAI_LP)    
    - VePTP Reward Amount = _rfVePTP * myStakedPTPAmount * stakingTime / (10 ** 18)
    */

    event PTPBaseFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event PTPBoostFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event VePTPFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event VePTPMultipleFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event PTPUpdated(address indexed user, address indexed oldPtp, address indexed newPtp);
    event VePTPUpdated(address indexed user, address indexed oldVePtp, address indexed newVePtp);
    event LPAdded(address indexed user, address indexed lptoken);
    event LPStaked(address indexed user, address indexed lptoken, uint256 amount);
    event LPUnStaked(address indexed user, address indexed lptoken, uint256 amount);
    event PTPStaked(address indexed user, address indexed ptptoken, uint256 amount);
    event PTPUnStaked(address indexed user, address indexed ptptoken, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PTPClaimed(address indexed user, uint256 amount);
    event VePTPClaimed(address indexed user, uint256 amount);

    constructor () {       
        _owner = msg.sender;        
        lpTokens.push(fUSDT_LP);
        lpTokens.push(DAI_LP);
        lpTokens.push(USDC_LP);
    }   

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    } 

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: same owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function isLpExist(address tk) private view returns (bool) {
        for (uint i = 0; i<lpTokens.length; i++) {
            if (lpTokens[i] == tk) return true;            
        }
        return false;
    }
    
    function addLPToken(address lpToken) public onlyOwner {
        require(lpToken != address(0), "addLPToken: zero address");
        require(Address.isContract(address(lpToken)), 'addLPToken: LP token must be a valid contract');
        require(isLpExist(lpToken) == false, "addLPToken: already exist");
        lpTokens.push(lpToken);
        emit LPAdded(msg.sender, lpToken);
    }

    function baseRewardFactorPTP() public view returns (uint256) {
        return _rfBasePTP;
    }

    function boostRewardFactorPTP() public view returns (uint256) {
        return _rfBoostPTP;
    }

    function rewardFactorVePTP() public view returns (uint256) {
        return _rfVePTP;
    }

    function rewardFactorVePTPMultiple() public view returns (uint256) {
        return _rfVePTPMultiple;
    }

    function updateBaseRewardFactorPTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateBaseRewardFactorPTP: reward factor can not be negative");
        uint256 oldFactor = _rfBasePTP;
        _rfBasePTP = newFactor;
        emit PTPBaseFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateBoostRewardFactorPTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateBoostRewardFactorPTP: reward factor can not be negative");
        uint256 oldFactor = _rfBoostPTP;
        _rfBoostPTP = newFactor;
        emit PTPBoostFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateRewardFactorVePTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateRewardFactorVePTP: reward factor can not be negative");
        uint256 oldFactor = _rfVePTP;
        _rfVePTP = newFactor;
        emit VePTPFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateRewardFactorVePTPMultiple(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateRewardFactorVePTPMultiple: multiple reward factor can not be negative");
        uint256 oldFactor = _rfVePTPMultiple;
        _rfVePTPMultiple = newFactor;
        emit VePTPMultipleFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    // LP Staking / Unstaking
    function isExistLPStakedUserInfo(uint256 pid, address user) private view returns (bool) {
        return _lpStakedUserInfo[pid][user].lpAmount > 0;
    }

    function _totalLPAmount() internal view returns (uint256) {
        uint256 totalLpAmounts;
        for (uint i=0;i<lpTokens.length;i++) {
            totalLpAmounts += IAsset(lpTokens[i]).totalSupply() / (10**IAsset(lpTokens[i]).decimals());
        }
        return totalLpAmounts;
    }

    function _coverageRatio (uint256 pid) private view returns (uint256) {
        if (IAsset(lpTokens[pid]).liability() > 0) 
            return IAsset(lpTokens[pid]).cash() * 100000 / IAsset(lpTokens[pid]).liability();
        return 0;
    }

    function _calcIncreasedBasePTPReward (uint256 pid, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60 && IAsset(lpTokens[pid]).totalSupply() > 0)
            return _rfBasePTP * userinfo.lpAmount * (block.timestamp - userinfo.lastTimestamp) * _coverageRatio(pid) * _totalLPAmount() / (lpTokens.length * (IAsset(lpTokens[pid]).totalSupply() / (10**IAsset(lpTokens[pid]).decimals())) * 10**18 * 100000);
        else return 0;
    }

    function _calcIncreasedBoostPTPReward (uint256 pid, address user, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60) {
            uint256 sum = _sumSqrtLPVe(pid);
            if (sum > 0) 
                return _rfBoostPTP * Math.sqrt(userinfo.lpAmount * VePTP.balanceOf(user)) * (block.timestamp - userinfo.lastTimestamp) / (sum * 10**18);
            else return 0;
        } else return 0;
    }

    function _sumSqrtLPVe (uint256 pid) private view returns (uint256) {
        uint256 sum;
        for (uint256 i=0;i<VePTP.holders().length;i++) {
            sum += Math.sqrt(_lpStakedUserInfo[pid][VePTP.holders()[i]].lpAmount * VePTP.balanceOf(VePTP.holders()[i]));
        }
        return sum;
    }

    function _calcPTPReward (uint256 pid, address user, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        uint256 baseIncreasedPTP = _calcIncreasedBasePTPReward(pid, userinfo);
        uint256 boostIncreasedPTP = _calcIncreasedBoostPTPReward(pid, user, userinfo);
        return userinfo.rewardAmount + baseIncreasedPTP + boostIncreasedPTP;
    }

    function _updateLPStakedUserInfoForStaking (uint256 pid, address user, uint256 amount) private {
        if (isExistLPStakedUserInfo(pid, user)) {
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
            _lpStakedUserInfo[pid][user].rewardAmount = _calcPTPReward(pid, user, userinfo);
            _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
            _lpStakedUserInfo[pid][user].lpAmount += amount / (10**IAsset(lpTokens[pid]).decimals());
        } else {
            _lpStakedUserInfo[pid][user].rewardAmount = 0;
            _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
            _lpStakedUserInfo[pid][user].lpAmount = amount / (10**IAsset(lpTokens[pid]).decimals());
        }
    }

    function _updateLPStakedUserInfoForUnStaking (uint256 pid, address user, uint256 amount) private {
        require(isExistLPStakedUserInfo(pid, user), "_updateLPStakedUserInfoForUnStaking: user didn't stake lp token");    
        _lpStakedUserInfo[pid][user].rewardAmount = 0;
        _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
        _lpStakedUserInfo[pid][user].lpAmount -= amount / (10**IAsset(lpTokens[pid]).decimals());
    }

    /**
        Whenever staking LP, should update LPStakedUserInfo
        - rewardAmount += base reward + boosted reward
        - lastTimestamp = currentTimestamp
        - lpAmount += newLPAmount            
    */
    function stakingLP (uint256 pid, uint256 amount) public { 
        require(address(PTP) != address(0), "stakingLP: PTP does not set");        
        require(IERC20(lpTokens[pid]).balanceOf(msg.sender) >= amount, "stakingLP: insufficient amount");
        IERC20(lpTokens[pid]).transferFrom(msg.sender, address(this), amount);
        _updateLPStakedUserInfoForStaking(pid, msg.sender, amount);
        emit LPStaked(msg.sender, lpTokens[pid], amount);
    }

    function stakingLPFromOther (address from, uint256 pid, uint256 amount) external override { 
        require(address(PTP) != address(0), "stakingLP: PTP does not set");        
        require(IERC20(lpTokens[pid]).balanceOf(from) >= amount, "stakingLP: insufficient amount");
        IERC20(lpTokens[pid]).transferFrom(from, address(this), amount);
        _updateLPStakedUserInfoForStaking(pid, from, amount);
        emit LPStaked(from, lpTokens[pid], amount);
    }    

    // whenever unstaking LP token, reward token should be transferred to msg sender
    function unStakingLP(uint256 pid, uint256 amount) public {
        require(address(PTP) != address(0), "unStakingLP: PTP does not set");
        require(isExistLPStakedUserInfo(pid, msg.sender), "unStakingLP: user didn't stake lp token");
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][msg.sender];
        require(userinfo.lpAmount >= amount / (10**IAsset(lpTokens[pid]).decimals()), "unStakingLP: insufficient amount");
        IERC20(lpTokens[pid]).transfer(msg.sender, amount);
        uint256 rewardAmount = _calcPTPReward(pid, msg.sender, userinfo);        
        PTP.transferWithoutFee(msg.sender, rewardAmount);
        _updateLPStakedUserInfoForUnStaking(pid, msg.sender, amount);
        emit LPUnStaked(msg.sender, lpTokens[pid], amount);
    }

    // PTP Staking / Unstaking
    function isExistPTPStakedUserInfo(address user) private view returns (bool) {
        return _ptpStakedUserInfo[user].ptpAmount > 0;
    }

    function _calcIncreasedVePTPReward (PTPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60)
            return _rfVePTP * userinfo.ptpAmount * (block.timestamp - userinfo.lastTimestamp) / (10**18);
        else return 0;
    }

    function _calcVePTPReward (address user, PTPStakedUserInfo storage userinfo) private view returns (uint256) {        
        uint256 rAmount = userinfo.rewardAmount + _calcIncreasedVePTPReward(userinfo);
        if (rAmount + VePTP.balanceOf(user) > userinfo.ptpAmount * _rfVePTPMultiple) {
            if (userinfo.ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                rAmount = userinfo.ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else return 0;
        }
        return rAmount;
    }

    // function _updatePTPStakedUserInfoForStaking (address user, uint256 amount) private {
    //     if (isExistPTPStakedUserInfo(user)) {
    //         PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[user];
    //         _ptpStakedUserInfo[user].rewardAmount = _calcVePTPReward(user, userinfo);
    //         _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
    //         _ptpStakedUserInfo[user].ptpAmount += amount;
    //     } else {
    //         _ptpStakedUserInfo[user].rewardAmount = 0;
    //         _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
    //         _ptpStakedUserInfo[user].ptpAmount = amount;
    //     }
    // }

    // logic updated
    function _updatePTPStakedUserInfoForStaking (address user, uint256 amount) private {
        _ptpStakedUserInfo[user].rewardAmount = 0;
        _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
        _ptpStakedUserInfo[user].ptpAmount += amount;
    }

    function _updatePTPStakedUserInfoForUnStaking (address user, uint256 amount) private {
        require(isExistPTPStakedUserInfo(user), "_updatePTPStakedUserInfoForUnStaking: user didn't stake PTP token");    
        _ptpStakedUserInfo[user].rewardAmount = 0;
        _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
        _ptpStakedUserInfo[user].ptpAmount -= amount;
    }

    function stakingPTP (uint256 amount) public { 
        require(address(VePTP) != address(0), "stakingPTP: VePTP does not set");        
        require(PTP.balanceOf(msg.sender) >= amount, "stakingPTP: insufficient amount");
        PTP.transferFromWithoutFee(msg.sender, address(this), amount);
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[msg.sender];
        VePTP.mint(msg.sender, _calcVePTPReward(msg.sender, userinfo));
        _updatePTPStakedUserInfoForStaking(msg.sender, amount);
        emit PTPStaked(msg.sender, address(PTP), amount);
    }

    function stakingPTPFromOther (address from, uint256 amount) external override { 
        require(address(VePTP) != address(0), "stakingPTP: VePTP does not set");        
        require(PTP.balanceOf(from) >= amount, "stakingPTP: insufficient amount");
        PTP.transferFromWithoutFee(from, address(this), amount);
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[from];
        VePTP.mint(from, _calcVePTPReward(from, userinfo));
        _updatePTPStakedUserInfoForStaking(from, amount);
        emit PTPStaked(from, address(PTP), amount);
    }

    function unStakingPTP(uint256 amount) public {
        require(address(VePTP) != address(0), "unStakingPTP: PTP does not set");
        require(isExistPTPStakedUserInfo(msg.sender), "unStakingPTP: user didn't stake ptp token");
        //PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[msg.sender];
        //require(userinfo.ptpAmount >= amount, "unStakingPTP: insufficient amount");
        PTP.transferWithoutFee(msg.sender, amount);        
        //VePTP.mint(msg.sender, _calcVePTPReward(msg.sender, userinfo));
        VePTP.deleteBalance(msg.sender);
        _updatePTPStakedUserInfoForUnStaking(msg.sender, amount);
        emit PTPUnStaked(msg.sender, address(PTP), amount);
    }

    // Claim PTP
    function _updateLPStakedUserInfoForClaim (uint256 pid, address user) private {        
        _lpStakedUserInfo[pid][user].rewardAmount = 0;
        _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
    }

    function _updateLPStakedUserInfoForMultiClaim (address user) private {    
        for (uint256 i=0;i<lpTokens.length;i++) {
            _updateLPStakedUserInfoForClaim(i, user);
        }            
    }

    function claimPTP(uint256 pid) external {
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][msg.sender];
        uint256 rewardAmount = _calcPTPReward(pid, msg.sender, userinfo);
        PTP.transferWithoutFee(msg.sender, rewardAmount*10**PTP.decimals());
        _updateLPStakedUserInfoForClaim(pid, msg.sender);
        emit PTPClaimed(msg.sender, rewardAmount*10**PTP.decimals());
    }

    function multiClaimPTP() external {
        _multiClaimPTP(msg.sender);
    }

    function _multiClaimPTP(address user) private {
        uint256 rewardAmount;
        for (uint256 i=0;i<lpTokens.length;i++) {
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[i][user];
            rewardAmount += _calcPTPReward(i, user, userinfo);                      
        }
        PTP.transferWithoutFee(user, rewardAmount*10**PTP.decimals());
        _updateLPStakedUserInfoForMultiClaim(user);
        emit PTPClaimed(user, rewardAmount*10**PTP.decimals());
    }

    // Claim vePTP
    function _updatePTPStakedUserInfoForClaim (address user) private {        
        _ptpStakedUserInfo[user].rewardAmount = 0;
        _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
    }

    function claimVePTP() external {
        _claimVePTP();
    }

    function _claimVePTP() private {
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[msg.sender];
        uint256 rewardAmount = _calcVePTPReward(msg.sender, userinfo);
        VePTP.mint(msg.sender, rewardAmount);
        _updatePTPStakedUserInfoForClaim(msg.sender);
        emit VePTPClaimed(msg.sender, rewardAmount);
    }

    function updatePTP(IMARKET newPtp) public onlyOwner {
        require(address(newPtp) != address(0), "updatePTP: zero address");
        require(Address.isContract(address(newPtp)), "updatePTP: invalied contract");
        emit PTPUpdated(msg.sender, address(PTP), address(newPtp));
        PTP = newPtp;        
    }

    function updateVePTP(IveMARKET newVePtp) public onlyOwner {
        require(address(newVePtp) != address(0), "updateVePTP: zero address");
        require(Address.isContract(address(newVePtp)), "updateVePTP: invalied contract");        
        emit VePTPUpdated(msg.sender, address(VePTP), address(newVePtp));
        VePTP = newVePtp;        
    }

    function lpStakedInfo(uint256 pid, address user) public view returns (uint256 lpAmount, uint256 rewardAmount) {
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
        rewardAmount = _calcPTPReward(pid, user, userinfo);
        lpAmount = userinfo.lpAmount * (10**IAsset(lpTokens[pid]).decimals());
    }

    function multiLpStakedInfo(address user) 
        public 
        view 
        returns (
            uint256,
            uint256[] memory, 
            uint256[] memory
        ) 
    {        
        uint256 totalRewardAmount;
        uint256[] memory lpAmounts = new uint256[](lpTokens.length);
        uint256[] memory rewardAmounts = new uint256[](lpTokens.length);
        for (uint i = 0; i<lpTokens.length; i++) {   
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[i][user];
            uint256 rAmount = _calcPTPReward(i, user, userinfo);
            totalRewardAmount += rAmount;
            lpAmounts[i] = userinfo.lpAmount * (10**IAsset(lpTokens[i]).decimals());
            rewardAmounts[i] = rAmount;
        }
        return (totalRewardAmount, lpAmounts, rewardAmounts);
    }

    function ptpStakedInfo(address user) public view returns (uint256 ptpAmount, uint256 rewardAmount) {
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[user];
        rewardAmount = _calcVePTPReward(user, userinfo);
        ptpAmount = userinfo.ptpAmount;
    }  

    function calcVePTPReward (address user, uint256 ptpAmount, uint256 stakingTimeSecond) public view returns (uint256) {                
        uint256 rAmount = _rfVePTP * ptpAmount * stakingTimeSecond / (10**18);
        if (rAmount + VePTP.balanceOf(user) > ptpAmount * _rfVePTPMultiple) {
            if(ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                rAmount = ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else return 0;
        }
        return rAmount;
    }

    function coverageRatio (uint256 pid) public view returns (uint256) {
        return _coverageRatio(pid);
    }

    function baseAPR (uint256 pid) external view override returns (uint256) {     
        if (IAsset(lpTokens[pid]).totalSupply() > 0)   
            return _rfBasePTP * (365 * 24 * 60 * 60) * _coverageRatio(pid) * _totalLPAmount() * 100 * 10**18 / (lpTokens.length * (IAsset(lpTokens[pid]).totalSupply() / (10**IAsset(lpTokens[pid]).decimals())) * 10**18 * 100000);
        else return 0;
    }

    function boostedAPR (uint256 pid, address user) external view override returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid);
        if (isExistLPStakedUserInfo(pid, user) && sum > 0) {   
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
            return _rfBoostPTP * Math.sqrt(VePTP.balanceOf(user)) * (365 * 24 * 60 * 60) * 100 * 10**18 / (Math.sqrt(userinfo.lpAmount) * sum * 10**18);      
        }
        return 0;
    }

    function estimatedBoostedAPRFromVePTP (uint256 pid, address user, uint256 lpAmount, uint256 vePTPAmount) public view returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid) - Math.sqrt(_lpStakedUserInfo[pid][user].lpAmount * VePTP.balanceOf(user)) + Math.sqrt(lpAmount * vePTPAmount);
        if (sum > 0) {            
            return _rfBoostPTP * Math.sqrt(vePTPAmount) * (365 * 24 * 60 * 60) * 100 * 10**18 / (Math.sqrt(lpAmount) * sum * 10**18);                       
        }
        return 0;
    }

    function estimatedBoostedAPRFromPTP (uint256 pid, address user, uint256 lpAmount, uint256 ptpAmount, uint256 stakingTimeSecond) public view returns (uint256) {        
        uint256 vePTPAmount = _rfVePTP * ptpAmount * stakingTimeSecond / (10**18);
        if (vePTPAmount + VePTP.balanceOf(user) > ptpAmount * _rfVePTPMultiple) {
            if(ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                vePTPAmount = ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else vePTPAmount = 0;
        }

        uint256 sum = _sumSqrtLPVe(pid) - Math.sqrt(_lpStakedUserInfo[pid][user].lpAmount * VePTP.balanceOf(user)) + Math.sqrt(lpAmount * vePTPAmount);
        if (sum > 0) {            
            return _rfBoostPTP * Math.sqrt(vePTPAmount) * (365 * 24 * 60 * 60) * 100 * 10**18 / (Math.sqrt(lpAmount) * sum * 10**18);                       
        } 
        return 0;
    }

    function medianBoostedAPR (uint256 pid) external view override returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid);
        uint256 sumAPR;
        uint256 holdersCount = VePTP.holders().length;
        uint256 boostingUserCount;
        for (uint256 i=0;i<holdersCount;i++) {
            address user = VePTP.holders()[i];
            if (isExistLPStakedUserInfo(pid, user) && sum > 0) {            
                LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
                sumAPR += _rfBoostPTP * Math.sqrt(VePTP.balanceOf(user)) * (365 * 24 * 60 * 60) * 100 * 10**18 / (Math.sqrt(userinfo.lpAmount) * sum * 10**18); 
                boostingUserCount++;          
            }
        }
        
        if (boostingUserCount > 0) {
            return sumAPR / boostingUserCount;
        }

        return 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IMasterPlatypusV3 {        

    function stakingLPFromOther (address from, uint256 pid, uint256 amount) external;   

    function stakingPTPFromOther (address from, uint256 amount) external;

    function baseAPR (uint256 pid) external view returns (uint256);

    function boostedAPR (uint256 pid, address user) external view returns (uint256);

    function medianBoostedAPR (uint256 pid) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @dev Interface of the VePtp
 */
interface IMARKET {    

    function transferWithoutFee(address to, uint256 amount) external;

    function transferFromWithoutFee(address from, address to, uint256 amount) external;

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @dev Interface of the VePtp
 */
interface IveMARKET {    

    function mint(address dst, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function deleteBalance(address account) external;

    function holders() external view returns (address[] memory);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

interface IAsset {
    function maxSupply() external view returns (uint256);

    function aggregateAccount() external view returns (address);

    function underlyingToken() external view returns (address);

    function decimals() external view returns (uint8);

    function underlyingTokenBalance() external view returns (uint256);

    function cash() external view returns (uint256);

    function liability() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

// a library for performing various math operations

library Math {
    uint256 public constant WAD = 10**18;

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }
}