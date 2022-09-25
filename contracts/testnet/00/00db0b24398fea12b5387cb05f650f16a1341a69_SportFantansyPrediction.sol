/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

pragma solidity 0.8.13;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = 0x80f0309FEd2454D58FC11Ad27c2e9e97a4cb4121;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

    function isEnounghSFS() external view returns(bool){
        return  IERC20(SFS).balanceOf(msg.sender) > minPredictRequire;
    }

    function isPredicted(uint256 _matchId) external view returns(bool) {
        return userPredictions[msg.sender][_matchId] > 0;
    }

    function isClaimAble(uint256 _matchId) external view returns(bool) {
        if(matchEnded[_matchId] == true
        && userMatchClaimed[msg.sender][_matchId] == false
        && userPredictions[msg.sender][_matchId] == matchToResult[_matchId]){
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
        
        matchToTimeStart[matchCount] = _timeStart;
        matchToTimeEnd[matchCount] = _timeEnd;

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
        userMatchClaimed[msg.sender][_matchId] == true;

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