/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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


contract DataStorage {
    using SafeMath for uint256;
    address public owner;
    mapping(address => bool) public operators;
    mapping(string => address[]) public admins;


    struct QuizDetail {
        uint256 id;
        string app_id;
        string[] questions;
        uint256 amount;
        int256 group;
        uint botType;
        bool exist;
        bool over;
        uint256 startTime;
        uint256 activeTime;
        string title;
        string photo;
        uint256 participate;
    }

    uint256[] private shouldAwardQuizIds;
    mapping(uint256 => address[]) private inductees;
    mapping(uint256 => QuizDetail) private quizzes;
    mapping(string => uint256[]) public appQuizzes;

    struct Lottery {
        IERC20 token;
        uint256[] amounts;
        uint256[] fixedNum;
        uint256[] proportionNum;
        uint256 totalAmount;
        bool isEth;
        bool over;
        bool exist;
    }

    mapping(address => uint256) private ethBank;
    mapping(address => mapping(IERC20 => uint256)) private erc20Bank;
    mapping(uint256 => mapping(uint256 => address[])) private lotteryResults;
    mapping(uint256 => Lottery) private lotteries;
    mapping(uint256 => address) private lotteryCreator;



    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyOperator(){
        require(operators[msg.sender], "Only Operator");
        _;
    }

    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
        operators[_newOwner] = true;
    }

    function addOperator(address _newOperator) public onlyOwner {
        operators[_newOperator] = true;
    }

    function addAdmin(string memory _appId, address _admin) public onlyOwner {
        admins[_appId].push(_admin);
    }

    function delAdmin(string memory _appId, address _delAdmin) public onlyOwner {
        for (uint i = 0; i < admins[_appId].length; i++) {
            if (admins[_appId][i] == _delAdmin) {
                admins[_appId][i] = address(0);
                return;
            }
        }
    }

    function checkAdmin(string memory _appId, address _sender) public view returns (bool){
        for (uint i = 0; i < admins[_appId].length; i++) {
            if (admins[_appId][i] == _sender) {
                return true;
            }
        }
        return false;
    }


    function getAppAdmins(string memory _appId) public view returns (address[] memory){
        return admins[_appId];
    }



    constructor() {
        owner = msg.sender;
        operators[msg.sender] = true;
    }


    //Quiz
    function setQuiz(string memory _appId, QuizDetail memory _quiz) public onlyOperator {
        if (!quizzes[_quiz.id].exist) {
            shouldAwardQuizIds.push(_quiz.id);
            appQuizzes[_appId].push(_quiz.id);
        }
        quizzes[_quiz.id] = _quiz;
    }

    function overQuiz(uint256 _quizId) public onlyOperator {
        quizzes[_quizId].over = true;
        _popAwardQuiz(_quizId);
    }

    function getQuiz(uint256 _quizId) public  view returns (QuizDetail memory) {
        return quizzes[_quizId];
    }

    function getQuizzes(uint256[] memory _quizIds) public view returns (QuizDetail[] memory) {
        QuizDetail[] memory details = new QuizDetail[](_quizIds.length);
        for (uint i = 0; i < _quizIds.length; i++) {
            details[i] = quizzes[_quizIds[i]];
        }
        return details;
    }

    function addInductees(uint256 _quizId, address[] memory _inductees, uint256 _participate) public onlyOperator {
        quizzes[_quizId].participate = _participate;
        inductees[_quizId] = _inductees;
    }

    function getInductees(uint256 _quizId) public view returns (address[] memory){
        return inductees[_quizId];
    }

    function getShouldAwardQuizIds() public view returns (uint256[] memory){
        return shouldAwardQuizIds;
    }

    function getAppQuizIds(string memory _appId) public view returns (uint256[] memory){
        return appQuizzes[_appId];
    }

    function _popAwardQuiz(uint256 _quizId) internal {
        bool hasQuizId = false;
        uint256 index = 0;
        for (uint i = 0; i < shouldAwardQuizIds.length; i++) {
            if (shouldAwardQuizIds[i] == _quizId) {
                hasQuizId = true;
                index = i;
                break;
            }
        }
        if (hasQuizId) {
            shouldAwardQuizIds[index] = shouldAwardQuizIds[shouldAwardQuizIds.length - 1];
            shouldAwardQuizIds.pop();
        }
    }


    //Lottery

    function setLottery(address _creator, uint256 _lotteryId, Lottery memory _lottery) public onlyOperator {
        if (!lotteries[_lotteryId].exist) {
            lotteryCreator[_lotteryId] = _creator;
        }
        lotteries[_lotteryId] = _lottery;
    }

    function overLottery(uint256 _lotteryId) public onlyOperator {
        lotteries[_lotteryId].over = true;
    }

    function getLottery(uint256 _lotteryId) public view returns (Lottery memory) {
        return lotteries[_lotteryId];
    }

    function getLotteries(uint256[] memory _lotteryIds) public view returns (Lottery[] memory){
        Lottery[] memory details = new Lottery[](_lotteryIds.length);
        for (uint i = 0; i < _lotteryIds.length; i++) {
            details[i] = lotteries[_lotteryIds[i]];
        }
        return details;
    }


    function setLotteryResult(uint256 _lotteryId, uint256 _index, address[] memory _winner) public onlyOperator {
        lotteryResults[_lotteryId][_index] = _winner;
    }

    function getLotteryResult(uint256 _lotteryId, uint256 _index) public view returns (address[] memory){
        return lotteryResults[_lotteryId][_index];
    }

    function getLotteryCreator(uint256 _lotteryId) public view returns (address){
        return lotteryCreator[_lotteryId];
    }

    function setEthBank(address _holder, uint256 _amount) public onlyOperator {
        ethBank[_holder] = _amount;
    }

    function getEthBank(address _holder) public view returns (uint256){
        return ethBank[_holder];
    }

    function setErc20Bank(address _holder, IERC20 _token, uint256 _amount) public onlyOperator {
        erc20Bank[_holder][_token] = _amount;
    }

    function getErc20Bank(address _holder, IERC20 _token) public view returns (uint256){
        return erc20Bank[_holder][_token];
    }


}