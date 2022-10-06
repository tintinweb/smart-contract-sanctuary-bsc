/**
 *Submitted for verification at BscScan.com on 2022-10-06
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

    event MatchCreated(uint256 matchId, string stTeam, string ndTeam, uint256 startTime);
    event MatchResulted(uint256 matchId,string stTeam, string ndTeam, uint256 startTime,bool isEnded, uint256 result);
    event Predicted(uint256 matchId, address indexed user, uint256 result);
    event RewardClaimed(uint256 matchId, address indexed user,uint256 rewardValue);

    uint256 public matchCount;
    uint256 public endedMatchCount;
    uint256 public currentMatchCount;
    address public rewardPoolAddress = 0xc4EA293b0C80710b3b1e31F47435305Ff671CbcE;

    // 1 is first team win, 2 is sencond team win, 3 is draw
    mapping(address => mapping(uint256 => uint256)) userPredictions;
    mapping(address => mapping(uint256 => bool)) userMatchClaimed; 

    address public SFS = 0x74cA4408af615cC95cc2aA9a80071e8694A0dC9D;
    uint256 public minPredictRequire = 60000000000;

    struct Match{
        uint256 matchId;
        string stTeam;
        string ndTeam;
        bool isEnded;
        uint256 startTime;
        uint256 result;
    }

    Match[] private _matches;

    constructor(){}

     function addMatch(uint256 _startTime,string memory _stTeam,string memory _ndTeam) public onlyOwner{
        require(_startTime > block.timestamp, "time error");
        
        uint256 matchId = matchCount;

        _matches.push(Match(matchId,_stTeam,_ndTeam,false,_startTime, 0));

        matchCount = matchCount +1;
        currentMatchCount = currentMatchCount +1;

        emit MatchCreated(matchId,_stTeam,_ndTeam,_startTime);
    }
    function isPredicted(uint256 _matchId, address user) external view returns(bool) {
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");

        return userPredictions[user][_matchId] > 0;
    }
    function isClaimAble(uint256 _matchId,address user) external view returns(bool) {
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        Match memory _match =_matches[_matchId];
        if(_match.isEnded == true
        && userMatchClaimed[user][_matchId] == false
        && userPredictions[user][_matchId] == _match.result){
            return true;
        }

        return false;
    }

    function claimReward(uint256 _matchId) public{
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        Match memory _match =_matches[_matchId];
        require(_match.isEnded == true, "match has not ended!");

        uint256 predictedResult = userPredictions[msg.sender][_matchId];
        require(predictedResult > 0, "not predicted yet!");
        require(predictedResult == _match.result , "predicted wrong result!");
        require(userMatchClaimed[msg.sender][_matchId] == false, "has claimed yet!");

        uint256 totalHold = IERC20(SFS).balanceOf(msg.sender);
        uint256 totalSupply = IERC20(SFS).totalSupply();
        uint256 totalReward = IERC20(SFS).balanceOf(rewardPoolAddress);
        uint256 rewardValue = totalReward.div(totalSupply.div(totalHold)) + totalReward.div(totalSupply.mod(totalHold)) ;
        IERC20(SFS).transferFrom(rewardPoolAddress, msg.sender, rewardValue);
        userMatchClaimed[msg.sender][_matchId] = true;

        emit RewardClaimed(_matchId, msg.sender,rewardValue);
    }

    function predict(uint256 _matchId, uint256 _result) public {
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        require(_result > 0 && _result <=3, "result error");
        require(IERC20(SFS).balanceOf(msg.sender) >= minPredictRequire, "not enough SFS to predict");

        Match memory _match =_matches[_matchId];

        require(_match.isEnded == false, "match has ended!");
        require(block.timestamp < _match.startTime, "match has started!");

        userPredictions[msg.sender][_matchId] = _result;
        
        userMatchClaimed[msg.sender][_matchId] = false;

        emit Predicted(_matchId, msg.sender, _result);

    }

    function updateResult(uint256 _matchId,uint256 _stResult,uint256 _ndResult)public onlyOwner{
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        

        require(_matches[_matchId].isEnded == false, "match has ended!");
        
        if(_stResult == _ndResult){
            _matches[_matchId].result = 3;
        }else if(_stResult > _ndResult){
            _matches[_matchId].result = 1;
        }else{
            _matches[_matchId].result = 2;
        }

        _matches[_matchId].isEnded = true;

        currentMatchCount = currentMatchCount - 1;
        endedMatchCount = endedMatchCount + 1;

        emit MatchResulted(_matchId, _matches[_matchId].stTeam,_matches[_matchId].ndTeam, _matches[_matchId].startTime, _matches[_matchId].isEnded, _matches[_matchId].result);
    }


    function getCurrentMatches() external view returns(Match[] memory)  {
        Match[] memory currentMatches = new Match[](currentMatchCount);
        uint256 count =0;

        for(uint256 i = 0; i < matchCount; i++){
            if(_matches[i].isEnded == false){
                currentMatches[count] = _matches[i];
                count ++;
            }
        }
        return currentMatches;
    }

    function getEndedMatches() external view returns(Match[] memory){
        Match[] memory endedMatches = new Match[](endedMatchCount);
        uint256 count = 0;
        for(uint256 i = 0; i < matchCount; i++){
            if(_matches[i].isEnded == true){
                endedMatches[count] = _matches[i];
                count ++;

            }
        }

        return endedMatches;
    }

    function getAllMatches() external view returns(Match[] memory)  {
        Match[] memory allMatches = new Match[](matchCount);
        for( uint256 i = 0; i < matchCount; i++){
            allMatches[i] = _matches[i];
        }
        return allMatches;
    }

    function isMatchStarted(uint256 _matchId) external view returns(bool) {
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        Match memory _match = _matches[_matchId];
        return block.timestamp > _match.startTime ;
    }

    function isMatchEnded(uint256 _matchId) external view returns(bool) {
        require(_matchId >= 0 && _matchId < matchCount, "not found matchId");
        Match memory _match = _matches[_matchId];
        return _match.isEnded;
    }


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

    function isEnounghSFS(address user) external view returns(bool){
        return  IERC20(SFS).balanceOf(user) > minPredictRequire;
    }

}