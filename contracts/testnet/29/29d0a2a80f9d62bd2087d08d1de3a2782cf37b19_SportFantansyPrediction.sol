/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

pragma solidity 0.8.13;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IERC20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SportFantansyPrediction is Ownable{
    using SafeMath for uint256;

    event MatchCreated(uint256 matchId, uint256 timeStart, uint256 timeEnd);
    event MatchResulted(uint256 matchId, uint256 result);
    event Predicted(uint256 matchId, address indexed user, uint256 result, uint256 rewardValue);
    event RewardClaimed(uint256 matchId, uint256 rewardValue);

    uint256 public matchCount;
    uint256 public matchCurrentCount;
    address public rewardPoolAddress = 0xc4EA293b0C80710b3b1e31F47435305Ff671CbcE;
    mapping(uint256 => uint256) indexToMatch;
    mapping(uint256 => bool) matchEnded;
    mapping(uint256 => uint256) matchToTimeStart;
    mapping(uint256 => uint256) matchToTimeEnd;



    // 1 is first team win, 2 is sencond team win, 3 is draw
    mapping(uint256 => uint256) matchToResult;
    mapping(address => mapping(uint256 => uint256)) userPredictions;
    mapping(address => mapping(uint256 => uint256)) userMatchReward;
    mapping(address => mapping(uint256 => bool)) userMatchClaimed; 

    address public SFS = 0x47797cd034EBBbA4f523833ccbB55f96021062ca;
    uint256 public minPredictRequire = 60000000000;

    struct Match{
        uint256 index;
        uint256 matchId;
        bool isEnded;
        uint256 startTime;
        uint256 endTime;
        uint256 result;
    }

    constructor(){}

    function setRewardPoolAddress(address account) public onlyOwner {
        rewardPoolAddress = account;
    }

    function setSFS(address addr) public onlyOwner {
        SFS = addr;
    }

    function setMinPredictRequire(uint256 amount) public onlyOwner {
        minPredictRequire = amount;
    }

    function getUserBalance(address user) external view returns (uint256) {
        return IERC20(SFS).balanceOf(user);
    }

    function getTotalReward() external view returns (uint256){
        return IERC20(SFS).balanceOf(rewardPoolAddress);
    }

    function getCurrentUserReward(address user) external view returns (uint256){
        uint256 totalHold = IERC20(SFS).balanceOf(user);
        uint256 totalSupply = IERC20(SFS).totalSupply();
        uint256 totalReward = IERC20(SFS).balanceOf(rewardPoolAddress);

        return totalReward.div(totalSupply.div(totalHold)) + totalReward.div(totalSupply.mod(totalHold));
    }

    function isMatchEnded(uint256 _matchId) external view returns(bool) {
        return matchEnded[_matchId];
    }

    function isMatchStarted(uint256 _matchId) external view returns(bool) {
        return block.timestamp > matchToTimeStart[_matchId];
    }

    function isEnounghSFS(address user) external view returns(bool){
        return  IERC20(SFS).balanceOf(user) > minPredictRequire;
    }

    function isPredicted(uint256 _matchId, address user) external view returns(bool) {
        return userPredictions[user][_matchId] > 0;
    }

    function isClaimAble(uint256 _matchId,address user) external view returns(bool) {
        if(matchEnded[_matchId] == true
        && userMatchClaimed[user][_matchId] == false
        && userPredictions[user][_matchId] == matchToResult[_matchId]){
            return true;
        }

        return false;
    }

    function getAllMatchs() external view returns(Match[] memory)  {
        Match[] memory allMatchs = new Match[](matchCount);
        uint256 i = 0;
        for(i; i < matchCount; i++){
            uint256 index = matchCount - i;
            uint256 matchId = indexToMatch[index];
            bool isEnded = matchEnded[matchId];
            uint256 startTime = matchToTimeStart[matchId];
            uint256 endTime = matchToTimeEnd[matchId];
            uint256 result = matchToResult[matchId];

            allMatchs[i] = Match(index,matchId,isEnded,startTime,endTime,result);
        }

        return allMatchs;
    }

    function getCurrentMatchs() external view returns(Match[] memory)  {
        Match[] memory currentMatchs = new Match[](matchCurrentCount);
        uint256 i = 0;
        for(i; i < matchCurrentCount; i++){
            uint256 index = matchCount - i;
            uint256 matchId = indexToMatch[index];
            bool isEnded = false;
            uint256 startTime = matchToTimeStart[matchId];
            uint256 endTime = matchToTimeEnd[matchId];
            // 0 is result of not ended match
            uint256 result = 0;

            currentMatchs[i] = Match(index,matchId,isEnded,startTime,endTime,result);
        }

        return currentMatchs;
    }

    function getEndedMatchs() external view returns(Match[] memory){
        uint256 matchEndedCount = matchCount - matchCurrentCount;
        Match[] memory endedMatchs = new Match[](matchEndedCount);
        uint256 i = 0;
        for(i; i < matchEndedCount; i++){
            uint256 index = matchEndedCount - i;
            uint256 matchId = indexToMatch[index];
            bool isEnded = true;
            uint256 startTime = matchToTimeStart[matchId];
            uint256 endTime = matchToTimeEnd[matchId];
            uint256 result = matchToResult[matchId];

            endedMatchs[i] = Match(index,matchId,isEnded,startTime,endTime,result);
        }

        return endedMatchs;
    }


    function addMatch(uint256 _timeStart, uint256 _timeEnd) public onlyOwner{
        require(_timeStart > block.timestamp && _timeEnd > block.timestamp, "time error");
        require(_timeStart < _timeEnd, "time error");
        
        matchCount = matchCount +1;
        uint256 matchId = ((uint256(keccak256(abi.encodePacked(block.timestamp,block.number,msg.sender))))) +1;
        indexToMatch[matchCount] = matchId;
        matchEnded[matchId] = false;
        
        matchToTimeStart[matchId] = _timeStart;
        matchToTimeEnd[matchId] = _timeEnd;

        matchCurrentCount = matchCurrentCount + 1;

        emit MatchCreated(matchId,_timeStart, _timeEnd);
    }

    function updateResult(uint256 _matchId,uint256 _stResult,uint256 _ndResult)public onlyOwner{
        require(matchToTimeStart[_matchId] > 0, "match error");
        require(block.timestamp > matchToTimeEnd[_matchId], "match has not ended!");
        require(matchEnded[_matchId] == false, "match has ended!");
        uint256 result;
        
        if(_stResult == _ndResult){
            result = 3;
        }else if(_stResult > _ndResult){
            result = 1;
        }else{
            result = 2;
        }

        matchToResult[_matchId] = result;
        matchEnded[_matchId] = true;
        matchCurrentCount = matchCurrentCount - 1;

        emit MatchResulted(_matchId, result);
    }

    function claimReward(uint256 _matchId) public{
        require(matchEnded[_matchId] == true, "match has not ended!");
        uint256 predictedResult = userPredictions[msg.sender][_matchId];
        require(predictedResult > 0, "not predicted yet!");
        require(predictedResult == matchToResult[_matchId] , "predicted wrong result!");
        require(userMatchClaimed[msg.sender][_matchId] == false, "has claimed yet!");

        uint256 rewardValue = userMatchReward[msg.sender][_matchId];
        IERC20(SFS).transferFrom(rewardPoolAddress, msg.sender, rewardValue);
        userMatchClaimed[msg.sender][_matchId] = true;

        emit RewardClaimed(_matchId, rewardValue);
    }

    function predict(uint256 _matchId, uint256 _result) public {
        require(_matchId > 0, "match error");
        require(matchEnded[_matchId] == false, "match has ended!");
        require(block.timestamp < matchToTimeStart[_matchId], "match has started!");
        require(_result > 0 && _result <=3, "result error");
        require(IERC20(SFS).balanceOf(msg.sender) >= minPredictRequire, "not enough SFS to predict");

        userPredictions[msg.sender][_matchId] = _result;
        
        uint256 totalHold = IERC20(SFS).balanceOf(msg.sender);
        uint256 totalSupply = IERC20(SFS).totalSupply();
        uint256 totalReward = IERC20(SFS).balanceOf(rewardPoolAddress);
        uint256 rewardValue = totalReward.div(totalSupply.div(totalHold)) + totalReward.div(totalSupply.mod(totalHold));
        userMatchReward[msg.sender][_matchId] = rewardValue;
        userMatchClaimed[msg.sender][_matchId] = false;

        emit Predicted(_matchId, msg.sender, _result, rewardValue);

    }

}