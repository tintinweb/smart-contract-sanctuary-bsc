/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


contract Quiz {
    using SafeMath for uint256;
    address public owner;


    struct QuizDetail {
        uint256 id;
        string[] questions;
        IERC20Metadata rewardToken;
        uint256 amount;
        bool exist;
        bool over;
        uint256 startTime;
        uint256 activeTime;
        uint256[] lotteries;
    }

    mapping(uint256 => address[]) private inductees;
    mapping(uint256 => QuizDetail) private quizzes;
    mapping(address => bool) private admins;
    mapping(uint256 => mapping(uint256 => address[])) private lotteryResults;
    mapping(uint256 => address[])private remainLotteryInductees;

    uint256[] private quizIds;
    uint256[] private shouldAwardQuizIds;
    

    modifier checkQuiz(uint256 _quizId){
        require(_quizId != 0, "invalid quizId 0");
        require(quizzes[_quizId].exist, "query for nonexistent quiz");
        _;
    }


    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "Ownable: caller is not the admin");
        _;
    }

    event CreateQuiz(uint256 _quizId, string[] questions, IERC20Metadata _rewardToken, uint256 _totalReward, uint256 _startTime, uint256 _activeTime, uint256[] _lotteries);
    event Awards(bytes32 _quizId);

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function addAdmin(address _newAdmin) public onlyOwner {
        admins[_newAdmin] = true;
    }

    function delAdmin(address _newAdmin) public onlyOwner {
        admins[_newAdmin] = false;
    }


    function isQuizExist(uint256 _quizId) public view returns(bool){
        require(_quizId != 0, "invalid quizId 0");
        return quizzes[_quizId].exist;
    }

     function getQuizList()public view returns(uint256[] memory){
        return quizIds;
    }


    function quizQuantity()public view returns (uint256){
       return quizIds.length;
    }


    function createQuiz(uint256 _quizId, string[] memory _questions, IERC20Metadata _rewardToken, uint256 _totalReward, uint256 _startTime, uint256 _activeTime,uint256[] memory _lotteries) public onlyAdmin {
        require(_quizId != 0, "invalid quizId 0");
        require(!isQuizExist(_quizId), "exist quiz");
        require(_totalReward > 0, "reward amount not enough");
        require(_totalReward <= _rewardToken.balanceOf(address(this)), "token remain not enough");

        for (uint i =0 ; i < _lotteries.length; i++){
            require(_lotteries[i] > 0, "lottery winner number at least 1");
        }

        quizIds.push(_quizId);
        shouldAwardQuizIds.push(_quizId);
        quizzes[_quizId] = QuizDetail(_quizId,_questions, _rewardToken, _totalReward, true, false,_startTime, _activeTime, _lotteries);


        emit CreateQuiz(_quizId, _questions, _rewardToken, _totalReward, _startTime, _activeTime, _lotteries);
    }

   

    function getQuiz(uint256 _quizId) public view checkQuiz(_quizId) returns (QuizDetail memory) {
        return quizzes[_quizId];
    }


    function deleteQuiz(uint256 _quizId) public checkQuiz(_quizId) onlyAdmin {

        delete quizzes[_quizId];

        uint256 lastQuizIdIndex = quizIds.length - 1;
    
        for (uint256 i = 0; i <= lastQuizIdIndex; i++){
            if (quizIds[i] == _quizId ){
                if (i != lastQuizIdIndex){
                    for (uint256 j = i; j < lastQuizIdIndex; j++){
                        quizIds[j] = quizIds[j+1];
                    }
                }
                
                // delete quizIds[i];
                quizIds.pop();  
                break;
            }
        }
        _popAwardQuiz(_quizId);

        // delete(lotteryResults, _quizId);
        // delete(remainLotteryInductees, _quizId);
        
    }

    function getLotteryResults(uint256 _quizId, uint256 _index) public view checkQuiz(_quizId) returns (address[] memory){
        return lotteryResults[_quizId][_index];
    }

    function getShouldAwardQuizIds() public view returns (uint256[] memory) {
        return shouldAwardQuizIds;
    }

    function questionQuantity(uint256 _quizId)public view checkQuiz(_quizId)returns(uint256){
        return quizzes[_quizId].questions.length;
    }

    function getQuestions(uint256 _quizId) public view checkQuiz(_quizId) returns (string[] memory) {
        return quizzes[_quizId].questions;
    }

    function getQuestionByIndex(uint256 _quizId, uint256 _questionIndex) public view checkQuiz(_quizId) returns(string memory){
        require(_questionIndex < quizzes[_quizId].questions.length, "question index out of bounds");
        return quizzes[_quizId].questions[_questionIndex];
    }

    function addQuestion(uint256 _quizId, string memory _question) public checkQuiz(_quizId) onlyAdmin {
        quizzes[_quizId].questions.push(_question);
    }

     function batchAddQuestion(uint256 _quizId, string[] memory _questions) public checkQuiz(_quizId) onlyAdmin {
        for (uint256 i = 0; i < _questions.length; i ++){
            quizzes[_quizId].questions.push(_questions[i]);
        }
       
    }

    function editQuestionByIndex(uint256 _quizId, uint256 _questionIndex,string memory _question) public checkQuiz(_quizId) onlyAdmin {
        require(_questionIndex < quizzes[_quizId].questions.length, "question index out of bounds");
        quizzes[_quizId].questions[_questionIndex] = _question;
    }

    function deleteQuestionByIndex(uint256 _quizId, uint256 _questionIndex) public checkQuiz(_quizId) onlyAdmin {
        require(_questionIndex < quizzes[_quizId].questions.length, "question index out of bounds");
        uint256 lastShouldAwardQuizIdIndex = questionQuantity(_quizId) - 1;

        // When the question to delete is the last question, the swap operation is unnecessary
        if (lastShouldAwardQuizIdIndex != _questionIndex){
            for (uint256 i = _questionIndex; i < lastShouldAwardQuizIdIndex; i++) {
                quizzes[_quizId].questions[i] = quizzes[_quizId].questions[i+1];
            }
        }

        delete quizzes[_quizId].questions[lastShouldAwardQuizIdIndex];
    }

    function getInductees(uint256 _quizId) public view checkQuiz(_quizId) returns (address[] memory){
        return inductees[_quizId];
    }


    function addInductees(uint256 _quizId, address[] memory _inductees) public checkQuiz(_quizId) onlyAdmin {
        require(!quizzes[_quizId].over, "QuizDetail is time out");
        if (inductees[_quizId].length == 0) {
            inductees[_quizId] = _inductees;
            remainLotteryInductees[_quizId] = _inductees;
        } else {
            for (uint256 i = 0; i < _inductees.length; i++) {
                inductees[_quizId].push(_inductees[i]);
                remainLotteryInductees[_quizId].push(_inductees[i]);
            }
        }
        
    }

     function awards(uint256 _quizId) public checkQuiz(_quizId) onlyAdmin {
        require(!quizzes[_quizId].over, "QuizDetail is time out");
        require(quizzes[_quizId].amount <= quizzes[_quizId].rewardToken.balanceOf(address(this)), "token pool not enough");
        address[] memory thisInductees = inductees[_quizId];
        uint256 i = 0;
    
        while (i < thisInductees.length) {
            quizzes[_quizId].rewardToken.transfer(thisInductees[i], quizzes[_quizId].amount);
            i += 1;
        }
        //Todo lottery
        quizzes[_quizId].over = true;
        _popAwardQuiz(_quizId);
    }


    function drawALottery(uint256 _quizId) public checkQuiz(_quizId) onlyAdmin {
        require(!quizzes[_quizId].over, "quiz is over");
        require(quizzes[_quizId].lotteries.length > 0, "no lottery config");

        for (uint i =0 ; i < quizzes[_quizId].lotteries.length; i++) {
            _drawALotteryByIndex(_quizId, i);
        }

    }

    function drawALotteryByIndex(uint256 _quizId, uint256 _index) public checkQuiz(_quizId) onlyAdmin {
        require(!quizzes[_quizId].over, "quiz is over");
        require(quizzes[_quizId].lotteries.length > 0, "no lottery config");
        _drawALotteryByIndex(_quizId, _index);
    }

    function _drawALotteryByIndex(uint256 _quizId, uint256 _index) internal {
        require (_index <= quizzes[_quizId].lotteries.length, "lottery index out of bounds");
        require (remainLotteryInductees[_quizId].length >= quizzes[_quizId].lotteries[_index], "the number of the inductees is smaller thann lottery configuration");
        
        for (uint256 i = 0; i < quizzes[_quizId].lotteries[_index]; i++) {

            uint256 inducteeNum = remainLotteryInductees[_quizId].length;
            uint256 latestInducteeIndex = inducteeNum - 1;

            uint256 winnerIndex = _randomNumber(inducteeNum, i);
            
            lotteryResults[_quizId][_index].push(remainLotteryInductees[_quizId][winnerIndex]);
            
            if (winnerIndex != latestInducteeIndex){
                remainLotteryInductees[_quizId][winnerIndex] = remainLotteryInductees[_quizId][latestInducteeIndex];
            }

            remainLotteryInductees[_quizId].pop();
            
        }
    }

    function _randomNumber(uint256 _scope, uint256 _salt) internal view returns(uint256) {
        return uint256(keccak256(abi.encode(abi.encodePacked(block.timestamp, block.difficulty), _salt))) % _scope;
    }


    function _popAwardQuiz(uint256 _quizId)internal {
        uint256 lastShouldAwardQuizIdIndex = shouldAwardQuizIds.length - 1;

        uint256 shouldAwardQuizIdIndex = 0;
        for (uint256 i = 0; i < lastShouldAwardQuizIdIndex; i ++){
            if (shouldAwardQuizIds[i] == _quizId){
                shouldAwardQuizIdIndex = i;
            }
        }

        // When the question to delete is the last question, the swap operation is unnecessary
        if (lastShouldAwardQuizIdIndex != shouldAwardQuizIdIndex){
            shouldAwardQuizIds[shouldAwardQuizIdIndex] = shouldAwardQuizIds[lastShouldAwardQuizIdIndex];
        }
        shouldAwardQuizIds.pop();
    }
}