/**
 *Submitted for verification at BscScan.com on 2022-06-01
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


contract QuizRecord {
    using SafeMath for uint256;
    address public owner;


    struct Question {
        string content;
        IERC20Metadata rewardToken;
        uint256 amount;
        bool exist;
        bool over;
    }

    mapping(uint256 => address[]) inductees;
    mapping(uint256 => Question)  questions;
    IERC20Metadata[] public rewardPool;

    modifier isExistsQuestion(uint256 _id){
        require(questions[_id].exist, "Not exists question");
        _;
    }


    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    event CreateQuestion(uint256 _id, string content, IERC20Metadata _rewardToken, uint256 _totalReward);
    event Awards(bytes32 _id);

    function getQuestion(uint256 _questionId) public view isExistsQuestion(_questionId) returns (Question memory) {
        return questions[_questionId];
    }


    function createNewQuestion(uint256 _id, string memory _content, IERC20Metadata _rewardToken, uint256 _totalReward) public {
        require(!questions[_id].exist, "exist question");
        require(_totalReward > 0, "reward amount not enough");
        require(_totalReward <= _rewardToken.balanceOf(address(this)), "token remain not enough");
        questions[_id] = Question(_content, _rewardToken, _totalReward, true, false);
        rewardPool[rewardPool.length] = _rewardToken;
        emit CreateQuestion(_id, _content, _rewardToken, _totalReward);
    }

    function addInductees(uint256 _id, address[] memory _inductees) public isExistsQuestion(_id) onlyOwner {
        require(!questions[_id].over, "question is time out");
        address[] memory currentInductees = inductees[_id];
        uint256 index = currentInductees.length;
        for (uint256 i = 0; i < _inductees.length; i += 1) {
            currentInductees[index + i] = _inductees[i];
        }
        inductees[_id] = currentInductees;
    }

    function awards(uint256 _id) public isExistsQuestion(_id) {
        require(!questions[_id].over, "question is time out");
        require(questions[_id].amount <= questions[_id].rewardToken.balanceOf(address(this)), "token pool not enough");
        address[] memory thisInductees = inductees[_id];
        uint256 i = 0;
        uint256 inducteesNum = thisInductees.length;
        uint256 singleReward = questions[_id].amount.div(inducteesNum);
        while (i < thisInductees.length) {
            //TransferHelper.safeTransferFrom(questions[_id].rewardToken, this, thisInductees[i], singleReward);
            questions[_id].rewardToken.transferFrom(address(this), thisInductees[i], singleReward);
            i += 1;
        }
        questions[_id].over = true;
    }
}