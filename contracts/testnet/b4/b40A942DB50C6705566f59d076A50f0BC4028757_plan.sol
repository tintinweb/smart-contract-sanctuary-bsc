/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract plan is Ownable{

    uint256 public startTime;
    using SafeMath for uint256;
    uint256 private constant timeStep = 1 days;
    uint256 public basePrice = uint256(20).mul(1e18);    
    uint[8] public levelIncome = [uint256(5).mul(1e18), uint256(1).mul(1e17), uint256(5).mul(1e16), uint256(5).mul(1e16), uint256(5).mul(1e16), uint256(5).mul(1e16), uint256(5).mul(1e16), uint256(5).mul(1e16)];
    uint[7] public rewardIncome = [uint256(10).mul(1e18), uint256(20).mul(1e18), uint256(100).mul(1e18), uint256(200).mul(1e18), uint256(750).mul(1e18),uint256(5000).mul(1e18), uint256(10000).mul(1e18)];

    struct rankReward{
        uint256 teamReq;
        uint256 income;
    }

    struct capp{
        uint256 teamReq;
        uint256 income;
    }

    mapping(uint256 => rankReward) public rank_reward;
    mapping(uint256 => capp) public capping;

    struct UserInfo{
        uint256 id;       
        address sponsor;
        uint256 balance;
        uint256 directs;
        uint256 team;
        uint256 total_deposit;         
        uint256 total_commision;
        uint256 reward;
        uint256 rank;
        uint256 payouts;               
        uint32 timeJoined;
        uint32 activeOn;
    }     

    IBEP20 constant private  BUSD = IBEP20(0x325a4deFFd64C92CF627Dd72d118f1b8361c5691);
    mapping (address => bool) public isRegistered;
   
    mapping(address => UserInfo) private users;

     
    event Registered(address user, address ref);
    uint256 public total_users = 0;

    constructor() payable {

       

        startTime = block.timestamp;

        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].sponsor = address(this);
        users[msg.sender].timeJoined = uint32(block.timestamp);     
        users[msg.sender].total_deposit = basePrice;

        rank_reward[1] = rankReward(10,uint256(10).mul(1e18));
        rank_reward[2] = rankReward(50,uint256(20).mul(1e18));
        rank_reward[3] = rankReward(300,uint256(100).mul(1e18));
        rank_reward[4] = rankReward(1000,uint256(200).mul(1e18));
        rank_reward[5] = rankReward(5000,uint256(750).mul(1e18));
        rank_reward[6] = rankReward(20000,uint256(5000).mul(1e18));
        rank_reward[7] = rankReward(50000,uint256(10000).mul(1e18));
        
        capping[1] = capp(0,uint256(20).mul(1e18));
        capping[2] = capp(40,uint256(50).mul(1e18));
        capping[3] = capp(200,uint256(100).mul(1e18));
        capping[4] = capp(800,uint256(200).mul(1e18));
        capping[5] = capp(5000,uint256(300).mul(1e18));
        capping[6] = capp(20000,uint256(500).mul(1e18));
        capping[7] = capp(50000,uint256(1000).mul(1e18));


        emit Registered(msg.sender, address(this)); 
        
    }

    mapping(address=> mapping(uint256 =>uint256)) public today_income;

    address private x;
    address private _dup_parent;
    function register(address _upline) external returns (bool){
       
        require(users[_upline].total_deposit > 0,"Sponsor Not Active.");
       
        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].id=total_users;
        users[msg.sender].sponsor = _upline;
        users[msg.sender].timeJoined  = uint32(block.timestamp);
        
         
        emit Registered(msg.sender, _upline);
        return true;
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getcapping(uint256 team) public view returns(uint256){
        uint256 cp;
        for(uint40 i = 1 ; i < 7;i++){
            if(capping[i].teamReq>=team){
                cp = capping[i].income;
            }
        }
        return cp;
    }

    function updateRank(address userid) internal{
        for(uint40 i = 1 ; i < 7;i++){
            if(users[userid].team >= rank_reward[i].teamReq && users[userid].rank < i){
                users[userid].rank = i;
                users[userid].reward = users[userid].reward.add(rank_reward[i].income);
                users[userid].total_commision = users[userid].total_commision.add(rank_reward[i].income);
                users[userid].balance = users[userid].balance.add(rank_reward[i].income);
            }
        }
    }

    function deposit() public returns(bool){
         require(BUSD.balanceOf(msg.sender)>= basePrice,"Insufficient Fund in account.");
         require(users[msg.sender].total_deposit == 0,"Already Active.");
          BUSD.transferFrom(msg.sender, address(this), basePrice);
          users[msg.sender].total_deposit += basePrice;
          users[msg.sender].activeOn = uint32(block.timestamp);
          
          address _upline = users[msg.sender].sponsor;
          users[_upline].directs++;

            x = _upline;
            uint256 currDay = getCurDay();
            uint256 tm ;
            uint256 cp ;
            for(uint i = 0 ; i < levelIncome.length ; i++ ){
                if(x != address(0)){
                    if(users[x].directs>=i){
                        tm = users[x].team;
                        cp = getcapping(tm);
                        if(today_income[x][currDay].add(levelIncome[i]) <= cp){

                            today_income[x][currDay] = today_income[x][currDay].add(levelIncome[i]);
                            BUSD.transfer(x, levelIncome[i]);
                            users[x].total_commision += levelIncome[i];
                            users[x].payouts += levelIncome[i];
                            
                        }
                        users[x].team ++;
                        updateRank(x);
                    }
                    x = users[x].sponsor;
                }else{
                    break;
                }            
            }
            return true;
    }

    uint256 private roi_per = uint256(75).mul(1e16);
    function calRoi(address usr) public view returns(uint256){        
        uint256 mydays;
        uint256 incm;
        if(users[usr].activeOn > 0){
            uint256 tm = uint256(block.timestamp).sub(uint256(users[usr].activeOn));
            mydays = tm.div(timeStep);
        }
        if(mydays>0){
            incm = mydays.mul(roi_per);
            uint256 total_eligible = users[usr].total_deposit.mul(3);
            if(users[usr].total_commision.add(incm)>total_eligible){
                uint256 pending_income = total_eligible.sub(users[usr].total_commision);
                if(pending_income>0){
                    incm = pending_income;
                }else{
                    incm = 0 ;
                }
            }            
        }
        return incm;
    }
    
    function withdrawal(uint256 amt) external returns(bool){
        uint256 roi = calRoi(msg.sender);
        if(roi>0){
            users[msg.sender].total_commision = users[msg.sender].total_commision.add(roi);
            users[msg.sender].balance = users[msg.sender].balance.add(roi);
        }

        require(users[msg.sender].balance>=amt , "Insufficient Fund in wallet");
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(msg.sender, amt);

        users[msg.sender].balance = users[msg.sender].balance.sub(amt);
        users[msg.sender].payouts = users[msg.sender].payouts.add(amt);
        return true;
    }


    function withdraw(address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }



}