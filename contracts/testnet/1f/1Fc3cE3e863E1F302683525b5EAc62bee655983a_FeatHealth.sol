// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FeatHealth is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _categoryIds;
    Counters.Counter private _subCategoryIds;
    Counters.Counter private _challengeIds;
    Counters.Counter private _reportIds;
    Counters.Counter private _liveChallengeIds;

    event Deposit(address indexed userAddress, uint256 tokenAmount, uint256 depositedTime);
    event LockUp(address indexed userAddress, uint256 lockedUpTime);
    event Withdraw(address indexed userAddress, uint256 tokenAmount, uint256 withdrawTime);
    event Category(uint256 indexed categoryId, string categoryName);
    event SubCategory(uint256 categoryId, uint256 indexed subCategoryId, string subCategoryName);
    event Challenge(uint256 categoryId, uint256 subCategoryId, uint256 indexed challengeId, string challengeName, uint256 targetQuantity, uint256 rewardPercentage);
    event Report(uint256 reportId, uint256 challengeId, string videoPath, address reporter);
    event Reward(address indexed userAddress, uint256 rewardAmount);
    event Trainer(address indexed trainerAddress);
    event LiveChallenge(
        uint256 indexed liveChallengeId,
        address indexed trainer,
        uint256 subCategoryId,
        uint256 playTime,
        uint256 startTime,
        uint256 reward,
        string channelName,
        string tempToken
    );

    address public featTokenAddress;
    uint256 public minDepositAmount = 1000 * 1e18;
    uint256 public expiryLockUpTime = 30 days;
    uint256 public expirySuspensionTime = 30 days;
    uint256 public perDayChallengeCount = 5;

    struct DepositerInfo {
        uint256 amount;
        bool isDeposited;
        uint256 reward;
        uint256 lockUpTime;
        bool isLockedUp;
        uint256 suspensionTime;
        uint256 completedChallengeCount;
        uint256 challengeLimitTime;
    }

    mapping(address => DepositerInfo) public depositerInfo;

    struct CategoryInfo {
        uint256 id;
        string name;
        bool isEnable;
    }

    mapping(uint256 => CategoryInfo) public categoryInfo;

    struct SubCategoryInfo {
        uint256 id;
        uint256 categoryId;
        string name;
        bool isEnable;
    }

    mapping(uint256 => SubCategoryInfo) public subCategoryInfo;

    struct ChallengeInfo {
        uint256 id;
        uint256 categoryId;
        uint256 subCategoryId;
        string name;
        uint256 targetQuantity;
        uint256 rewardPercentage;
        bool isEnable;
    }

    mapping(uint256 => ChallengeInfo) public challengeInfo;

    struct ReportChallengeInfo {
        uint256 id;
        uint256 challengeId;
        string videoPath;
        address challenger;
        uint8 isApproved;
        string comment;
        bool isEnable;
    }

    mapping(uint256 => ReportChallengeInfo) public reportChallengeInfo;

    struct TrainerInfo {
        bool isEnable;
    }

    mapping(address => TrainerInfo) public trainerInfo;

    struct LiveChallengeInfo {
        uint256 id;
        address trainer;
        uint256 subCategoryId;
        uint256 playTime;
        uint256 startTime;
        uint256 reward;
        string channelName;
        string tempToken;
        address challenger1;
        address challenger2;
        bool isEnable;
    }

    mapping(uint256 => LiveChallengeInfo) public liveChallengeInfo;

    constructor(address _featTokenAddress) {
        featTokenAddress = _featTokenAddress;
    }

    /**
     * Making sure that the function has only access to the depositor
     */
    modifier onlyDepositer(bool isDeposited) {
        if(isDeposited){
            require(depositerInfo[msg.sender].isDeposited == true, "You are not a depositer!");
        } else {
            require(depositerInfo[msg.sender].isDeposited == false, "You have already made a deposit!");
        }
        _;
    }

    /**
     * Making sure that lock up time has either expired or not
     */
    modifier onlyExpiredLockUpTime() {
        require(
            depositerInfo[msg.sender].isDeposited == true && block.timestamp >= depositerInfo[msg.sender].lockUpTime,
            "The lockup time has not expired!"
        );
        _;
    }

    /**
     * Making sure that suspension time has either expired or not
     */
    modifier onlyExpiredSuspensionTime() {
        require(
            depositerInfo[msg.sender].isLockedUp == true && block.timestamp >= depositerInfo[msg.sender].suspensionTime,
            "The suspension time has not expired!"
        );
        _;
    }

    /**
     * Making sure that the function has only access to the depositor
     */
    modifier onlyUnLockUp() {
        require(depositerInfo[msg.sender].isLockedUp == false, "Your activity has already been stopped!");
        _;
    }

    /**
     * Making sure that the function has only access to the depositor
     */
    modifier onlyPossibleChallenge() {
        require(
            (depositerInfo[msg.sender].completedChallengeCount < perDayChallengeCount
                || depositerInfo[msg.sender].challengeLimitTime < block.timestamp),
            "Your activity has already been stopped!"
        );
        _;
    }

    /**
     * Making sure that the function has only access to the approved reporter
     */
    modifier onlyApprovedReporter(uint256 _reportId, uint8 _isApproved) {
        require(reportChallengeInfo[_reportId].isEnable && reportChallengeInfo[_reportId].challenger == msg.sender
            && reportChallengeInfo[_reportId].isApproved == _isApproved, "You did not complete the challenge!");
        _;
    }

    /**
     * Making sure that the function has only access to the depositor
     */
    modifier onlyUser(address _userAddress) {
        require(msg.sender == _userAddress, "You don't have access!");
        _;
    }

    /**
     * Making sure that the function has only access to the trainer
     */
    modifier onlyTrainer(uint256 _reportId) {
        if(_reportId > 0){
            require(
                trainerInfo[msg.sender].isEnable && reportChallengeInfo[_reportId].isEnable && reportChallengeInfo[_reportId].isApproved == 0,
                "You are not a trainer!"
            );
        } else {
            require(trainerInfo[msg.sender].isEnable, "You are not a trainer!");
        }
        _;
    }

    /**
     * Handle depositing FEAT token to this smart contract
     */
    function deposit(uint256 _amount) public onlyDepositer(false) {
        require(_amount >= minDepositAmount, "Insufficient deposit amount!");
        IBEP20 token = IBEP20(featTokenAddress);
        token.transferFrom(msg.sender, address(this), _amount);
        depositerInfo[msg.sender] = DepositerInfo({
            amount: _amount,
            isDeposited:true,
            reward: 0,
            lockUpTime: block.timestamp + expiryLockUpTime,
            isLockedUp:false,
            suspensionTime:0,
            completedChallengeCount:0,
            challengeLimitTime:0
        });
        emit Deposit(msg.sender, _amount, block.timestamp);
    }

    /**
     * Handle lock up
     */
    function lockUp() public onlyExpiredLockUpTime() {
        depositerInfo[msg.sender].isLockedUp = true;
        depositerInfo[msg.sender].suspensionTime = block.timestamp + expirySuspensionTime;
        emit LockUp(msg.sender, block.timestamp);
    }

    /**
     * Handle withdraw FEAT token
     */
    function withdraw() public onlyExpiredSuspensionTime() {
        IBEP20 token = IBEP20(featTokenAddress);
        DepositerInfo storage withdrawerInfo = depositerInfo[msg.sender];
        uint256 tokenAmount = withdrawerInfo.amount.add(withdrawerInfo.reward);
        token.transfer(msg.sender, tokenAmount);
        withdrawerInfo.amount = 0;
        withdrawerInfo.isDeposited = false;
        withdrawerInfo.reward = 0;
        withdrawerInfo.lockUpTime = 0;
        withdrawerInfo.isLockedUp = false;
        withdrawerInfo.suspensionTime = 0;
        withdrawerInfo.completedChallengeCount = 0;
        withdrawerInfo.challengeLimitTime = 0;
        emit Withdraw(msg.sender, tokenAmount, block.timestamp);
    }

    /**
     * Handle get current block time
     */
    function getBlockTimestamp() public view returns (uint) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }

    /**
     * Handle set the minimum deposit amount
     */
    function setMinDepositAmount(uint256 _amount) public onlyOwner() {
        minDepositAmount = _amount * 1e18;
    }

    /**
     * Handle set the lock up time
     */
    function setExpiryLockUpTime(uint256 _time) public onlyOwner() {
        expiryLockUpTime = _time;
    }

    /**
     * Handle set the suspension time
     */
    function setExpirySuspensionTime(uint256 _time) public onlyOwner() {
        expirySuspensionTime = _time;
    }

    /**
     * Handle set the complete chanllenge count
     */
    function setPerDayChallengeCount(uint256 _count) public onlyOwner() {
        perDayChallengeCount = _count;
    }
    
    /**
     * Handle create category
     */
    function createCategory(string memory _name) public onlyOwner() {
        _categoryIds.increment();
        uint256 newCategoryId = _categoryIds.current();
        categoryInfo[newCategoryId] = CategoryInfo({
            id: newCategoryId,
            name: _name,
            isEnable: true
        });
        emit Category(newCategoryId, _name);
    }

    /**
     * Handle update Category
     */
    function updateCategory(uint256 _id, string memory _name, bool _isEnable) public onlyOwner() {
        categoryInfo[_id] = CategoryInfo({
            id: _id,
            name: _name,
            isEnable: _isEnable
        });
    }
    
    /**
     * Handle create subCategory
     */
    function createSubCategory(uint256 _categoryId, string memory _name) public onlyOwner() {
        _subCategoryIds.increment();
        uint256 newSubCategoryId = _subCategoryIds.current();
        subCategoryInfo[newSubCategoryId] = SubCategoryInfo({
            id: newSubCategoryId,
            categoryId: _categoryId,
            name: _name,
            isEnable: true
        });
        emit SubCategory(_categoryId, newSubCategoryId, _name);
    }

    /**
     * Handle update SubCategory
     */
    function updateSubCategory(uint256 _id, uint256 _categoryId, string memory _name, bool _isEnable) public onlyOwner() {
        subCategoryInfo[_id] = SubCategoryInfo({
            id: _id,
            categoryId: _categoryId,
            name: _name,
            isEnable: _isEnable
        });
    }
    
    /**
     * Handle create challenge
     */
    function createChallenge(uint256 _categoryId, uint256 _subCategoryId, string memory _name, uint256 _targetQuantity, uint256 _rewardPercentage) public onlyOwner() {
        _challengeIds.increment();
        uint256 newChallengeId = _challengeIds.current();
        challengeInfo[newChallengeId] = ChallengeInfo({
            id: newChallengeId,
            categoryId: _categoryId,
            subCategoryId: _subCategoryId,
            name: _name,
            targetQuantity: _targetQuantity,
            rewardPercentage: _rewardPercentage,
            isEnable: true
        });
        emit Challenge(_categoryId, _subCategoryId, newChallengeId, _name, _targetQuantity, _rewardPercentage);
    }

    /**
     * Handle update challenge
     */
    function updateChallenge(uint256 _id, uint256 _categoryId, uint256 _subCategoryId, string memory _name, uint256 _targetQuantity, uint256 _rewardPercentage, bool _isEnable) public onlyOwner() {
        challengeInfo[_id] = ChallengeInfo({
            id: _id,
            categoryId: _categoryId,
            subCategoryId: _subCategoryId,
            name: _name,
            targetQuantity: _targetQuantity,
            rewardPercentage: _rewardPercentage,
            isEnable: _isEnable
        });
    }

    /**
     * Handle report challenge
     */
    function reportChallengeResult(uint256 _id, string memory _videoPath)
        public
        onlyDepositer(true) 
        onlyUnLockUp()
        onlyPossibleChallenge()
    {
        DepositerInfo storage senderInfo = depositerInfo[msg.sender];
        senderInfo.completedChallengeCount = senderInfo.completedChallengeCount.add(1);
        if(senderInfo.completedChallengeCount == 1){
            senderInfo.challengeLimitTime = block.timestamp + 1 days;
        } else if(senderInfo.completedChallengeCount > perDayChallengeCount || senderInfo.challengeLimitTime < block.timestamp){
            senderInfo.completedChallengeCount = 1;
            senderInfo.challengeLimitTime = block.timestamp + 1 days;
        }
        _reportIds.increment();
        uint256 newReportId = _reportIds.current();
        reportChallengeInfo[newReportId] = ReportChallengeInfo({
            id: newReportId,
            challengeId: _id,
            videoPath: _videoPath,
            challenger: msg.sender,
            isApproved: 0,
            comment: "",
            isEnable: true
        });
        emit Report(newReportId, _id, _videoPath, msg.sender);
    }

    /**
     * Handle approve report
     */
    function approveReport(uint256 _reportId, uint8 _isApproved, string memory _comment)
        public
        onlyTrainer(_reportId) 
    {
        reportChallengeInfo[_reportId].isApproved = _isApproved;
        reportChallengeInfo[_reportId].comment = _comment;
    }

    /**
     * Handle report challenge
     */
    function retryReportChallengeResult(uint256 _reportId, string memory _videoPath)
        public
        onlyDepositer(true) 
        onlyUnLockUp()
        onlyPossibleChallenge()
        onlyApprovedReporter(_reportId, 2)
    {
        DepositerInfo storage senderInfo = depositerInfo[msg.sender];
        senderInfo.completedChallengeCount = senderInfo.completedChallengeCount.add(1);
        if(senderInfo.completedChallengeCount == 1){
            senderInfo.challengeLimitTime = block.timestamp + 1 days;
        } else if(senderInfo.completedChallengeCount > perDayChallengeCount || senderInfo.challengeLimitTime < block.timestamp){
            senderInfo.completedChallengeCount = 1;
            senderInfo.challengeLimitTime = block.timestamp + 1 days;
        }
        reportChallengeInfo[_reportId].videoPath = _videoPath;
        reportChallengeInfo[_reportId].isApproved = 0;
        reportChallengeInfo[_reportId].comment = "";
        emit Report(_reportId, reportChallengeInfo[_reportId].challengeId, _videoPath, msg.sender);
    }

    /**
     * Handle complete challenge
     */
    function completeChallenge(uint256 _reportId)
        public
        onlyApprovedReporter(_reportId, 1)
    {
        DepositerInfo storage senderInfo = depositerInfo[msg.sender];
        uint256 userTokenAmount = senderInfo.amount + senderInfo.reward;
        uint256 rewardTokenAmount = userTokenAmount.div(100000).mul(challengeInfo[reportChallengeInfo[_reportId].challengeId].rewardPercentage);
        senderInfo.reward = senderInfo.reward.add(rewardTokenAmount);
        reportChallengeInfo[_reportId].isEnable = false;
        emit Reward(msg.sender, rewardTokenAmount);
    }

    /**
     * Handle get category list
     */
    function getCategoryList() public view returns (CategoryInfo[] memory) {
        uint totalCategoryCount = _categoryIds.current();
        uint possibleCategoryCount = 0;
        for (uint i = 0; i < totalCategoryCount; i++) {
            uint id = i + 1;
            if(categoryInfo[id].isEnable){
                possibleCategoryCount += 1;
            }
        }
        CategoryInfo[] memory categories = new CategoryInfo[](possibleCategoryCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalCategoryCount; i++) {
            uint id = i + 1;
            if(categoryInfo[id].isEnable){
                CategoryInfo storage currentCategory = categoryInfo[id];
                categories[currentIndex] = currentCategory;
                currentIndex += 1;
            }
        }
        return categories;
    }

    /**
     * Handle get SubCategory list
     */
    function getSubCategoryList() public view returns (SubCategoryInfo[] memory) {
        uint totalSubCategoryCount = _subCategoryIds.current();
        uint possibleSubCategoryCount = 0;
        for (uint i = 0; i < totalSubCategoryCount; i++) {
            uint id = i + 1;
            if(subCategoryInfo[id].isEnable && categoryInfo[subCategoryInfo[id].categoryId].isEnable){
                possibleSubCategoryCount += 1;
            }
        }
        SubCategoryInfo[] memory subCategories = new SubCategoryInfo[](possibleSubCategoryCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalSubCategoryCount; i++) {
            uint id = i + 1;
            if(subCategoryInfo[id].isEnable && categoryInfo[subCategoryInfo[id].categoryId].isEnable){
                SubCategoryInfo storage currentSubCategory = subCategoryInfo[id];
                subCategories[currentIndex] = currentSubCategory;
                currentIndex += 1;
            }
        }
        return subCategories;
    }

    /**
     * Handle get challenge list
     */
    function getChallengeList() public view returns (ChallengeInfo[] memory) {
        uint totalChallengeCount = _challengeIds.current();
        uint possibleChallengeCount = 0;
        for (uint i = 0; i < totalChallengeCount; i++) {
            uint id = i + 1;
            if(challengeInfo[id].isEnable && categoryInfo[challengeInfo[id].categoryId].isEnable && categoryInfo[challengeInfo[id].subCategoryId].isEnable){
                possibleChallengeCount += 1;
            }
        }
        ChallengeInfo[] memory challenges = new ChallengeInfo[](possibleChallengeCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalChallengeCount; i++) {
            uint id = i + 1;
            if(challengeInfo[id].isEnable && categoryInfo[challengeInfo[id].categoryId].isEnable && categoryInfo[challengeInfo[id].subCategoryId].isEnable){
                ChallengeInfo storage currentChallenge = challengeInfo[id];
                challenges[currentIndex] = currentChallenge;
                currentIndex += 1;
            }
        }
        return challenges;
    }

    /**
     * Handle get report list
     */
    function getChallengerReportList(address _challenger) public view returns (ReportChallengeInfo[] memory) {
        uint totalReportCount = _reportIds.current();
        uint challengerReportCount = 0;
        for (uint i = 0; i < totalReportCount; i++) {
            uint id = i + 1;
            if(reportChallengeInfo[id].isEnable && reportChallengeInfo[id].challenger == _challenger){
                challengerReportCount += 1;
            }
        }
        ReportChallengeInfo[] memory reports = new ReportChallengeInfo[](challengerReportCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalReportCount; i++) {
            uint id = i + 1;
            if(reportChallengeInfo[id].isEnable && reportChallengeInfo[id].challenger == _challenger){
                ReportChallengeInfo storage currentReport = reportChallengeInfo[id];
                reports[currentIndex] = currentReport;
                currentIndex += 1;
            }
        }
        return reports;
    }
    
    /**
     * Handle create trainer
     */
    function createTrainer(address _trainerAddress) public onlyOwner() {
        trainerInfo[_trainerAddress] = TrainerInfo({
            isEnable: true
        });
        emit Trainer(_trainerAddress);
    }

    /**
     * Handle update trainer
     */
    function updateTrainer(address _trainerAddress, bool _isEnable) public onlyOwner() {
        trainerInfo[_trainerAddress].isEnable = _isEnable;
    }

    /**
     * Handle get report list
     */
    function getReportList() public view returns (ReportChallengeInfo[] memory) {
        uint totalReportCount = _reportIds.current();
        uint reportCount = 0;
        for (uint i = 0; i < totalReportCount; i++) {
            uint id = i + 1;
            if(reportChallengeInfo[id].isEnable && reportChallengeInfo[id].isApproved == 0){
                reportCount += 1;
            }
        }
        ReportChallengeInfo[] memory reports = new ReportChallengeInfo[](reportCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalReportCount; i++) {
            uint id = i + 1;
            if(reportChallengeInfo[id].isEnable && reportChallengeInfo[id].isApproved == 0){
                ReportChallengeInfo storage currentReport = reportChallengeInfo[id];
                reports[currentIndex] = currentReport;
                currentIndex += 1;
            }
        }
        return reports;
    }
    
    /**
     * Handle create live challenge
     */
    function createLiveChallenge(
        uint256 _subCategoryId,
        uint256 _playTime,
        uint256 _startTime,
        uint256 _reward,
        string memory _channelName,
        string memory _tempToken
    ) public onlyTrainer(0) {
        _liveChallengeIds.increment();
        uint256 newLiveChallengeId = _liveChallengeIds.current();
        liveChallengeInfo[newLiveChallengeId] = LiveChallengeInfo({
            id: newLiveChallengeId,
            trainer: msg.sender,
            subCategoryId: _subCategoryId,
            playTime: _playTime,
            startTime: block.timestamp + _startTime,
            reward: _reward,
            channelName: _channelName,
            tempToken: _tempToken,
            challenger1: address(0),
            challenger2: address(0),
            isEnable: true
        });
        emit LiveChallenge(
            newLiveChallengeId,
            msg.sender,
            _subCategoryId,
            _playTime,
            liveChallengeInfo[newLiveChallengeId].startTime,
            _reward,
            _channelName,
            _tempToken
        );
    }

    /**
     * Handle get live challenge list
     */
    function getLiveChallengeList(address user) public view returns (LiveChallengeInfo[] memory) {
        bool trainer = trainerInfo[user].isEnable;
        uint totalLiveChallengeCount = _liveChallengeIds.current();
        uint challengeCount = 0;
        for (uint i = 0; i < totalLiveChallengeCount; i++) {
            uint id = i + 1;
            if(liveChallengeInfo[id].isEnable){
                if(trainer){
                    if(liveChallengeInfo[id].trainer == user){
                        challengeCount += 1;
                    }
                } else {
                    challengeCount += 1;
                }
            }
        }
        LiveChallengeInfo[] memory liveChallenges = new LiveChallengeInfo[](challengeCount);
        uint currentIndex = 0;
        for (uint i = 0; i < totalLiveChallengeCount; i++) {
            uint id = i + 1;
            if(liveChallengeInfo[id].isEnable){
                if(trainer){
                    if(liveChallengeInfo[id].trainer == user){
                        LiveChallengeInfo storage currentLiveChallenge = liveChallengeInfo[id];
                        liveChallenges[currentIndex] = currentLiveChallenge;
                        currentIndex += 1;
                    }
                } else {
                    LiveChallengeInfo storage currentLiveChallenge = liveChallengeInfo[id];
                    liveChallenges[currentIndex] = currentLiveChallenge;
                    currentIndex += 1;
                }
            }
        }
        return liveChallenges;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}