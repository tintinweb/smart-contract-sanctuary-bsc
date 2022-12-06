/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
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

contract ICO is Ownable {      

    IERC20 stakingToken;
    IERC20 stakingFromToken;
    using SafeMath for uint256;
    uint32 total_user = 10000000;
    uint32 total_invest = 0;
    uint256 randNonce = 0; 
    struct User {
        uint256 id;        
        address sponsor;
        uint40 directs;        
        uint256 balance;               
        uint256 commision;               
        uint256 claimed_income;               
        uint256 total_deposit;               
        uint256 team_deposit;               
        bool status;               
        uint256 claimed_reward;               
        uint40 timestamp;       
    }
    mapping (address => User) public users;
    
    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
        uint256 freezed;
    }
    mapping(address => OrderInfo[]) public orderInfos;
    mapping(address => address[]) public directs;

    address admin;
    bool isEnable;
    uint256 public ratePerToken;
    uint256 public devidend;
    uint256 private constant dayPerCycle = 730 days; 
    uint256 private constant rewardAfter =  30 days;
    uint256 private constant rewardPer = 500; 
    uint256 private constant baseDivider = 10000; 

    mapping (uint256 => address) public addresses;

    constructor (address addr) payable {
        payable(addr).transfer(msg.value);
        admin = payable(msg.sender);
        total_user++;         
        uint256 hax = getHEXaddress();
        addresses[hax]=admin;
        stakingToken = IERC20(0xdD9732015afeBE5ffBe249DfDb95c8fBbE77A6d4);
        stakingFromToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        
        isEnable = true;
        ratePerToken = 33;
        devidend = 1;
        users[msg.sender].id = hax; 
        users[msg.sender].sponsor = address(this);
        users[msg.sender].timestamp = uint40(block.timestamp);
        
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle);
        orderInfos[msg.sender].push(OrderInfo(
            0, 
            block.timestamp, 
            unfreezeTime,
            false,
            0
        ));
    }
    
    
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }
    
    function register(uint256 sp) external returns(bool){
        address upline = addresses[sp];        
        require(users[upline].timestamp != 0, "Sponsor not Exists.");
        require(orderInfos[upline].length > 0, "Sponsor not Active.");
        require(users[msg.sender].timestamp == 0, "Address Already Registered.");
        User storage user = users[msg.sender];
        
        total_user++;
        uint256 hax = getHEXaddress();        

        addresses[hax]=msg.sender;

        user.id=hax;        
        user.sponsor = upline;
        user.timestamp = uint40(block.timestamp);
        users[upline].directs++;
        directs[upline].push(msg.sender);
        return true;
    }

    function deposit(uint256 amount) external returns (bool) {
        require(isEnable == true, "ICO Disabled");
        require(users[msg.sender].timestamp > 0, "Address Already Registered.");
        require(amount > 0, "BEP20: Amount Should be greater then 0!"); 
        require(amount <= stakingFromToken.balanceOf(msg.sender), "BEP20: Insufficient Fund!");
        
        uint256 tokens = amount.mul(ratePerToken).div(devidend);

        stakingFromToken.transferFrom(msg.sender, admin, amount);

        uint256 unfreezeTime = block.timestamp.add(dayPerCycle);
        orderInfos[msg.sender].push(OrderInfo(
            tokens, 
            block.timestamp, 
            unfreezeTime,
            false,
            0
        ));

        uint256 tcom = tokens.mul(22).div(100);
        users[msg.sender].status =  true; 
        users[msg.sender].total_deposit +=  tokens; 
        users[users[msg.sender].sponsor].commision +=  tcom;    
        users[users[msg.sender].sponsor].balance +=  tcom;    
        updateTeamNum(msg.sender,tokens);
        return true;
    }

     function unfreeze(uint256 ordrId)external returns(bool){
        
        OrderInfo storage order = orderInfos[msg.sender][ordrId];
        User storage user = users[msg.sender];

        uint256 blnc = (uint256(block.timestamp).sub(order.start)).div(rewardAfter);
        uint256 newIncome = order.amount.mul(rewardPer).div(baseDivider);
        uint256 desIncome = newIncome.mul(blnc);
        uint256 incm = order.amount.add(desIncome).sub(order.freezed);

        if(incm>0 && order.amount > order.freezed.add(incm)){
            order.freezed = order.freezed.add(incm);
            user.commision = user.commision.add(incm);
            user.balance = user.balance.add(incm);
        }

        return true;
     }

    

    function updateTeamNum(address _user, uint256 amount) private {
        User storage user = users[_user];
        address upline = user.sponsor;
        for(uint256 i = 0; i < 50; i++){
            if(upline != address(0)){
                users[upline].team_deposit += amount;              
                upline = users[upline].sponsor;
            }else{
                break;
            }
        }
    }

    function claimIncome(uint256 amnt)public returns(bool){
        require(users[msg.sender].balance >=amnt ,"Insufficient Income.");
        require(users[msg.sender].status == true ,"User Blocked.");
        stakingToken.transfer(msg.sender, amnt);
        users[msg.sender].balance -= amnt;
        users[msg.sender].claimed_income += amnt;
        return true;
    }

    uint256[] private rewardincome = [2500,10000,20000,150000,500000,1000000];
    function calculateBusinessReward(address addr) public view returns(uint256){
        User storage user = users[addr];
        uint256 my_business = user.total_deposit.add(user.team_deposit);
        uint256 ret;
        if(my_business>0){
            uint256 myextb ;
            if(my_business.div(1e18)>=100000 && my_business.div(1e18) < 500000){
                myextb = businessInRatio(addr, 100000);
                if(myextb>=100000){
                    ret = rewardincome[0].mul(1e18);
                }
            }else if(my_business.div(1e18)>=500000 && my_business.div(1e18) < 2500000){
                myextb = businessInRatio(addr, 500000);
                if(myextb>=500000){
                    ret = (rewardincome[0].add(rewardincome[1])).mul(1e18);
                }
            }else if(my_business.div(1e18)>=2500000 && my_business.div(1e18) < 10000000){
                myextb = businessInRatio(addr, 2500000);
                if(myextb>=2500000){
                    ret = (rewardincome[0].add(rewardincome[1]).add(rewardincome[2])).mul(1e18);
                }
            }else if(my_business.div(1e18)>=10000000 && my_business.div(1e18) < 50000000){
                myextb = businessInRatio(addr, 10000000);
                if(myextb>=10000000){
                    ret = (rewardincome[0].add(rewardincome[1]).add(rewardincome[2]).add(rewardincome[3])).mul(1e18);
                }
            }else if(my_business.div(1e18)>= 50000000 && my_business.div(1e18) < 250000000){
                myextb = businessInRatio(addr, 50000000);
                if(myextb>=50000000){
                    ret = (rewardincome[0].add(rewardincome[1]).add(rewardincome[2]).add(rewardincome[3]).add(rewardincome[4])).mul(1e18);
                }
            }else if(my_business.div(1e18)>= 250000000){
                myextb = businessInRatio(addr, 250000000);
                if(myextb>=250000000){
                    ret = (rewardincome[0].add(rewardincome[1]).add(rewardincome[2]).add(rewardincome[3]).add(rewardincome[4]).add(rewardincome[5])).mul(1e18);
                }
            }
        }
        return ret;
    }

    function businessInRatio(address _usr,uint256 amnt)internal view returns(uint256){        
        uint256 mybsns;
        if(amnt>0){
            uint256 mxbsns = amnt.mul(40).div(100);
            address[] storage direc = directs[_usr];
            address upl; 
            for(uint32 j=0;j<direc.length;j++){
                upl = direc[j];
                if(users[upl].total_deposit.add(users[upl].team_deposit) > mxbsns){
                    mybsns = mybsns.add(mxbsns);
                }else{
                    mybsns = mybsns.add(users[upl].total_deposit.add(users[upl].team_deposit));
                }
            }
        }        
        return mybsns;
    }

    function seleToken(uint256 amount)external returns(bool){
        require(stakingFromToken.balanceOf(msg.sender)>= amount,"Insufficient Fund");
        uint256 tokens = amount.div(ratePerToken).div(devidend);
        stakingToken.transferFrom(msg.sender,admin,amount);
        stakingFromToken.transfer(msg.sender,tokens);
        return true;
    }

    function claimReward()external returns(bool){
        uint256 myrwrd = calculateBusinessReward(msg.sender);
        if(myrwrd > users[msg.sender].claimed_reward){
            uint256 pending = myrwrd.sub(users[msg.sender].claimed_reward);
            users[msg.sender].claimed_reward += pending;
            users[msg.sender].claimed_income += pending;
            users[msg.sender].balance += pending;
        }
        return true;
    }

    function getHEXaddress()public returns(uint256){
        uint256 aa = randMod(999999999);
        if(addresses[aa] == address(0)){            
            return aa;
        }else{
            return getHEXaddress();
        }        
    }

    function randMod(uint256 mdl) internal returns(uint256)
    {
        // increase nonce
        randNonce++; 
        uint randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % mdl;
        
        return randomnumber += 10000000;
    
    }

    function withdraw(IERC20 TKN,uint256 amount,address addr)external onlyOwner returns(bool){
        TKN.transfer(addr, amount);
        return true;
    }

    function changeToken(IERC20 _stakTkn,IERC20 _stakfrm)external onlyOwner{
        stakingToken = _stakTkn;
        stakingFromToken = _stakfrm;
    }
    
    function changeRate(uint256 _rate,uint256 _devidnd)external onlyOwner{
        ratePerToken = _rate;
        devidend = _devidnd;
    }
    function BlockUser(address addr,bool stts)external onlyOwner{
        users[addr].status = stts;
        
    }

    function migrate(address usr, uint256 _id,address _sponsor, uint40 _directs, uint256 _balance, uint256 _commision, uint256 _claimed_income, uint256 _total_deposit, uint256 _team_deposit, bool _status, uint256 _claimed_reward, uint40 _timestamp)public onlyOwner returns(bool){
        addresses[_id]=usr;
        users[usr].id= _id;        
        users[usr].sponsor= _sponsor;        
        users[usr].directs= _directs;        
        users[usr].balance= _balance;        
        users[usr].commision= _commision;        
        users[usr].claimed_income= _claimed_income;        
        users[usr].total_deposit= _total_deposit;        
        users[usr].team_deposit= _team_deposit;        
        users[usr].status= _status;        
        users[usr].claimed_reward= _claimed_reward;        
        users[usr].timestamp= _timestamp;
        return true;
    }

    function migrateOrder(address usr, uint256 _cnt,uint256[] memory _amount, uint256[] memory _start, uint256[] memory _unfreeze, uint256[] memory _freezed)public onlyOwner returns(bool){
        
        for(uint256 c = 0;c<_cnt;c++){

            orderInfos[usr][c]=OrderInfo(
                _amount[c], 
                _start[c], 
                _unfreeze[c],
                false,
                _freezed[c]
            );             
        }                
        return true;
    }

    function migrateDirect(address usr, uint256 _cnt,address[] memory _dirs) public onlyOwner returns(bool){
       
        for(uint256 c = 0;c<_cnt;c++){
            directs[usr][c]=_dirs[c];             
        }                
        return true;
    }

}