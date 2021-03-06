/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Otc.sol


pragma solidity ^0.8.0;



interface Mall{      
    
    struct mallInfo {
        uint256 allNum;
        uint256 currentNum;
        bool state;
    }
    function isMall(address input) external view returns(bool);
    function getMallInfo(address _address) external view returns(mallInfo memory);
    
}

interface Token{      
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
}

contract Otc is Ownable{
    using SafeMath for uint256;

    Token token;
    Mall mallContact;
    address private _dev;
    address public man;
    constructor(address mall, address erc20,address dev){
         mallContact = Mall(mall);
         token=Token(erc20);
         _dev=dev;
         man=msg.sender;
    }

    uint private unlocked = 1;
    
    

    //??????
    struct user {
        address userid;//??????
        uint256 uid;
        uint256 tradeNum;//????????????
        uint256 goodNum;//??????
        uint256 badNum;//??????
        uint256 publishNum;//??????????????????ad??????
        uint256 unPublishNum;//????????????????????????
        uint256 createOrderNum; //??????????????????????????????
        uint256 unOrderNum;//????????????????????????
        uint256 freeTime;//???????????????????????????

    }

    //??????
    struct ad {
        uint256 aid;//??????id
        uint256 classes;//??????0??????1??????
        uint256 allNum;//?????????
        uint256 currectNum;//????????????
        uint256 tradeNum;//???????????????
        uint256 price;//??????RMB
        uint256 state;//0??????1?????????2??????3??????
        uint256 lastTime;
        // uint256[] pay;//????????????
        // string explain;//????????????
        // string phone;//????????????
        address mallid;//????????????
        string unit;
        
    }
    //??????
    struct order{
        uint256 orderid;//??????id
        uint256 aid;//??????id
        uint256 classes;//??????0??????1??????
        uint256 state;//0??????????????????1?????????5?????????2?????????3?????????4??????
        uint256 num;//????????????
        uint256 fee;//?????????
        uint256 numInpool;//????????????
        uint256 price;//??????RMB
        uint256 lastTime;
        address userid;//??????
        address mallid;//??????
        string unit;
    }

    mapping (address => user) public userInfo;//????????????
    mapping (uint256 => ad) public adInfo;//????????????aid
    mapping (uint256 => order) public orderInfo;//????????????orderid

    mapping (address => uint256) public adBuyCountOn;//?????????????????????
    mapping (address => uint256) public adSellCountOn;//?????????????????????

    mapping (address => uint256) public allAdCount;//???????????????AD???
    mapping (address => uint256) public allOrderCount;//???????????????order???
    mapping (address => uint256) public allOrderMallCount;//???????????????order???

    user[] public users;//????????????
    ad[] public ads;//????????????
    order[] public orders;//????????????
    // address[] public whiteList;//????????????
    // address[] public blackList;//????????????

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
 
    //????????????????????????
    function getMall(address mallAddress) public view returns(uint){
        return mallContact.getMallInfo(mallAddress).currentNum;
    }
    //register
    function register() public lock{
        userInfo[msg.sender]=user(msg.sender,users.length,0,0,0,0,0,0,0,block.timestamp);
        users.push(userInfo[msg.sender]);
    }
    //publish
    function publish(uint256 classes ,uint256 allNum, uint256 price,string memory unit) public lock{
        //????????????????????????
        //????????????????????????
        //????????????????????????
        require(userInfo[msg.sender].userid != address(0) && userInfo[msg.sender].freeTime<block.timestamp && mallContact.isMall(msg.sender));
        // require(allNum % 100 ether ==0 && allNum >=100 ether);
        require(allNum<=mallContact.getMallInfo(msg.sender).currentNum.div(2));
        if(classes==0){//????????????
            require(adBuyCountOn[msg.sender]==0);
            adBuyCountOn[msg.sender]+=1;
        }else if(classes==1){//????????????
            require(adSellCountOn[msg.sender]==0);
            adSellCountOn[msg.sender]+=1;
        }

        adInfo[ads.length]=ad(ads.length,classes,allNum,allNum,0,price,0,block.timestamp,msg.sender,unit);
        ads.push(adInfo[ads.length]);
        userInfo[msg.sender].publishNum+=1;
        users[userInfo[msg.sender].uid].publishNum=userInfo[msg.sender].publishNum;
        allAdCount[msg.sender]+=1;
    }

    //cancelPublish
    function cancelPublish(uint256 aid) public lock{
        if(msg.sender==owner()){
            require(adInfo[aid].state!=3);
        }else{
            require(msg.sender==adInfo[aid].mallid && adInfo[aid].state==0);
        }
        adInfo[aid].state=3;
        ads[aid].state=3;
        if(adInfo[aid].classes==0){
            adBuyCountOn[adInfo[aid].mallid]=adBuyCountOn[adInfo[aid].mallid].sub(1);
        }else{
            adSellCountOn[adInfo[aid].mallid]=adSellCountOn[adInfo[aid].mallid].sub(1);
        }
        
            userInfo[msg.sender].unPublishNum+=1;
            users[userInfo[msg.sender].uid].unPublishNum=userInfo[msg.sender].unPublishNum;
        // if(msg.sender!=owner()){
        //     userInfo[msg.sender].unPublishNum=userInfo[msg.sender].unPublishNum.add(1);
        // }
        
    }
    //createOrder
    function createOrder(uint256 aid ,uint256 num) public lock{
        //??????????????????ID ????????????<=?????????????????? ?????????????????? ??????????????????
        require(adInfo[aid].mallid !=address(0) && adInfo[aid].currectNum >= num);
        require(userInfo[msg.sender].freeTime < block.timestamp && userInfo[adInfo[aid].mallid].freeTime < block.timestamp);
        // require(num % 100 ether ==0 && num >= 100 ether);
        orderInfo[orders.length]=order(orders.length,aid,adInfo[aid].classes,0,num,_getFee(msg.sender),0,adInfo[aid].price,block.timestamp,msg.sender,adInfo[aid].mallid,adInfo[aid].unit);
        orders.push(orderInfo[orders.length]);
        
        userInfo[msg.sender].createOrderNum+=1;
        users[userInfo[msg.sender].uid].createOrderNum=userInfo[msg.sender].createOrderNum;
        allOrderCount[msg.sender]+=1;
        allOrderMallCount[adInfo[aid].mallid]+=1;
    }

    //receiveOrder????????????
    function receiveOrder(uint256 orderid) public lock{
        require(userInfo[msg.sender].freeTime < block.timestamp && userInfo[orderInfo[orderid].mallid].freeTime < block.timestamp && msg.sender==orderInfo[orderid].mallid);
        require(adInfo[orderInfo[orderid].aid].state==0,"e601");
        //order ?????????1????????????
        orderInfo[orderid].state=1;
        orders[orderid].state=1;
        // orderInfo[orderid].lastTime=block.timestamp;
        //ad ?????????
        adInfo[orderInfo[orderid].aid].currectNum=adInfo[orderInfo[orderid].aid].currectNum.sub(orderInfo[orderid].num);
        ads[orderInfo[orderid].aid].currectNum=adInfo[orderInfo[orderid].aid].currectNum;
        //ad ??????????????????
        adInfo[orderInfo[orderid].aid].state=1;
        ads[orderInfo[orderid].aid].state=1;
    }

    //cancelOrder
    function cancelOrder(uint256 orderid) public lock{
        //??????????????????ID //???????????????0-1
        require(msg.sender==owner() || msg.sender==orderInfo[orderid].mallid || msg.sender==orderInfo[orderid].userid);
        require(orderInfo[orderid].mallid !=address(0) && orderInfo[orderid].state<=2);
        if(orderInfo[orderid].state==2||orderInfo[orderid].state==1){//???????????????????????????2????????? ?????????????????? ??????????????????
            // if(orderInfo[orderid].state==2){
            //     require(msg.sender==owner());
            // }
            //???????????????????????????U?????????U
            if(orderInfo[orderid].numInpool>0){
                if(orderInfo[orderid].classes==0){
                    token.transfer(orderInfo[orderid].userid,orderInfo[orderid].numInpool);
                }else{
                    token.transfer(orderInfo[orderid].mallid,orderInfo[orderid].numInpool);
                }
                
            }
            
             //???????????????4
            //ad ?????????
            //ad ??????????????????
            adInfo[orderInfo[orderid].aid].state=0;
            adInfo[orderInfo[orderid].aid].currectNum+=orderInfo[orderid].num;
            ads[orderInfo[orderid].aid]=adInfo[orderInfo[orderid].aid];
        }
        orderInfo[orderid].state=5;
        orders[orderid].state=5;

        orderInfo[orderid].numInpool=0;
        orders[orderid].numInpool=0;
        if(msg.sender==orderInfo[orderid].userid){

            
            
            
            if(userInfo[msg.sender].unOrderNum>=2){
                userInfo[msg.sender].freeTime=block.timestamp+24*60*60;
                userInfo[msg.sender].unOrderNum=0;
                users[userInfo[msg.sender].uid].unOrderNum=0;
            }else{
                userInfo[msg.sender].unOrderNum+=1;
                users[userInfo[msg.sender].uid].unOrderNum=userInfo[msg.sender].unOrderNum;
            }
        }
    }

    

    //deposit
    function deposit(uint256 orderid ) public lock{
        //??????????????????ID ????????????<=?????????????????? ?????????????????? ??????????????????
        require(orderInfo[orderid].state==1,"608");
        require(orderInfo[orderid].mallid !=address(0) && orderInfo[orderid].numInpool <orderInfo[orderid].num,"609");
        require(userInfo[msg.sender].freeTime < block.timestamp && userInfo[orderInfo[orderid].mallid].freeTime < block.timestamp,"610");
        //??????????????????num //???????????????
        require(token.balanceOf(msg.sender)>=orderInfo[orderid].num.sub(orderInfo[orderid].numInpool) && token.allowance(msg.sender,address(this))>=orderInfo[orderid].num,"611");
        //??????num?????????
        token.transferFrom(msg.sender,address(this),orderInfo[orderid].num.sub(orderInfo[orderid].numInpool));
        orderInfo[orderid].state=2;
        orderInfo[orderid].numInpool+=orderInfo[orderid].num.sub(orderInfo[orderid].numInpool);
        orders[orderid]=orderInfo[orderid];
    }

    //pay?????????
    function pay(uint256 orderid ) public lock{
        require(orderInfo[orderid].state==2);
        //??????????????????ID ????????????<=?????????????????? ?????????????????? ??????????????????
        require(orderInfo[orderid].mallid !=address(0) && orderInfo[orderid].numInpool>=orderInfo[orderid].num);
        require(userInfo[msg.sender].freeTime < block.timestamp && userInfo[orderInfo[orderid].mallid].freeTime < block.timestamp);
        //??????????????????num //???????????????

        if(orderInfo[orderid].classes==0){
            require(msg.sender==orderInfo[orderid].mallid);
        }else{
            require(msg.sender==orderInfo[orderid].userid);
        }
        
        orderInfo[orderid].state=3;
        orders[orderid].state=3;
    }

    function judgment(uint256 orderid ,address win) public{
        require(msg.sender==man);
        require(orderInfo[orderid].state==3);
        if(orderInfo[orderid].numInpool>0){
    
            token.transfer(win,orderInfo[orderid].numInpool.sub(_getFee(orderInfo[orderid].userid)));

        }
         //ad
        //????????????????????????
        //?????????????????? ?????????????????????2
        //????????????
        adInfo[orderInfo[orderid].aid].tradeNum+=orderInfo[orderid].num;
        if(adInfo[orderInfo[orderid].aid].tradeNum>=adInfo[orderInfo[orderid].aid].allNum){
            adInfo[orderInfo[orderid].aid].state=2;
            adInfo[orderInfo[orderid].aid].lastTime=block.timestamp;

            if(adInfo[orderInfo[orderid].aid].classes==0){
                adBuyCountOn[orderInfo[orderid].mallid]=adBuyCountOn[orderInfo[orderid].mallid].sub(1);
            }else{
                adSellCountOn[orderInfo[orderid].mallid]=adSellCountOn[orderInfo[orderid].mallid].sub(1);
            }

        }else{
             adInfo[orderInfo[orderid].aid].state=0;
        }
        ads[orderInfo[orderid].aid]=adInfo[orderInfo[orderid].aid];

        //order
        //?????????????????? ????????????????????????????????????
        //??????4?????????
        //????????????
      
        orderInfo[orderid].state=4;
        orders[orderid].state=4;

        address lost = orderInfo[orderid].userid==win?orderInfo[orderid].mallid:orderInfo[orderid].userid;

        if(userInfo[lost].badNum>=2){
            userInfo[lost].freeTime=block.timestamp+10*365*24*60*60;
            userInfo[lost].badNum=0;
            users[userInfo[lost].uid].badNum=0;
        }else{
            userInfo[lost].badNum+=1;
            userInfo[lost].freeTime=block.timestamp+10*24*60*60;
            users[userInfo[lost].uid].badNum=userInfo[lost].badNum;
            users[userInfo[lost].uid].freeTime=userInfo[lost].freeTime;
        }

        orderInfo[orderid].numInpool=0;
        orders[orderid].numInpool=0;


        // userInfo[win].tradeNum=userInfo[win].tradeNum.add(1);
        // users[userInfo[win].uid].tradeNum=userInfo[win].tradeNum;
        
    }

    //trade//??????
    function trade(uint256 orderid,address puser1,address puser2 ) public lock{
        require(orderInfo[orderid].mallid !=address(0));
        
            if(orderInfo[orderid].classes==0){
                require( msg.sender==orderInfo[orderid].userid);
            }else{
                require( msg.sender==orderInfo[orderid].mallid);
            }
        
         //ad
        //????????????????????????
        //?????????????????? ?????????????????????2
        //????????????
        adInfo[orderInfo[orderid].aid].tradeNum+=orderInfo[orderid].num;
        if(adInfo[orderInfo[orderid].aid].tradeNum>=adInfo[orderInfo[orderid].aid].allNum){
            adInfo[orderInfo[orderid].aid].state=2;
            adInfo[orderInfo[orderid].aid].lastTime=block.timestamp;

            if(adInfo[orderInfo[orderid].aid].classes==0){
                adBuyCountOn[orderInfo[orderid].mallid]=adBuyCountOn[orderInfo[orderid].mallid].sub(1);
            }else{
                adSellCountOn[orderInfo[orderid].mallid]=adSellCountOn[orderInfo[orderid].mallid].sub(1);
            }
            
        }else{
             adInfo[orderInfo[orderid].aid].state=0;
        }
        ads[orderInfo[orderid].aid]=adInfo[orderInfo[orderid].aid];
        //order
        //?????????????????? ????????????????????????????????????
        //??????4?????????
        //????????????
        uint256 _fee=_getFee(orderInfo[orderid].userid);
        if(orderInfo[orderid].classes==0){
                token.transfer(orderInfo[orderid].mallid,orderInfo[orderid].numInpool.sub(_fee));
        }else{
                token.transfer(orderInfo[orderid].userid,orderInfo[orderid].numInpool.sub(_fee));
        }
        orderInfo[orderid].state=4;
        orders[orderid].state=4;
        //orderInfo[orderid].lastTime=block.timestamp;
        
         //??????????????????+1
        //????????????+1
        userInfo[orderInfo[orderid].userid].tradeNum=userInfo[orderInfo[orderid].userid].tradeNum.add(1);
        users[userInfo[orderInfo[orderid].userid].uid].tradeNum=userInfo[orderInfo[orderid].userid].tradeNum;
        userInfo[orderInfo[orderid].mallid].tradeNum=userInfo[orderInfo[orderid].mallid].tradeNum.add(1);
        users[userInfo[orderInfo[orderid].mallid].uid].tradeNum=userInfo[orderInfo[orderid].mallid].tradeNum;

        //??????1???20% ??????2???10% 70%??????????????????
        token.transfer(puser1,_fee.mul(200).div(1000));
        token.transfer(puser2,_fee.mul(100).div(1000));
        token.transfer(_dev,_fee.mul(700).div(1000));

        orderInfo[orderid].numInpool=0;
        orders[orderid].numInpool=0;
    }

    function _getFee(address _userid) private view returns(uint256){
        uint256  per ;
        if(userInfo[_userid].tradeNum<=10){
            per =20-userInfo[_userid].tradeNum ;
        }else{
            per=10 ;
        }
        return per.mul(1 ether);
    }

    //??????AD??????
    function getAds() public view returns (ad[] memory) {
        ad[] memory result= new ad[](ads.length);
        for (uint i = 0; i < ads.length; i++) {
                result[i] = ads[i];
        } 
        return result;
    }

    //???????????????????????????AD??????
    function getAdsByAddress(address input) public view returns (ad[] memory) {
        ad[] memory result ;
        result= new ad[](allAdCount[input]);
        uint counter = 0;
        for (uint i = 0; i < ads.length; i++) {
            if (ads[i].mallid== input) {
                result[counter] = ads[i];
                counter++;
            }
        }
            
        return result;
    }
    //?????????????????????????????????????????????
    function getOrdersByUserid(address userid) public view returns (order[] memory) {
        order[] memory result ;
        result= new order[](allOrderCount[userid]);
        uint counter = 0;
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].userid== userid) {
                result[counter] = orders[i];
                counter++;
            }
        }
            
        return result;
    }

    //???????????????????????????????????????
    function getOrdersByMallid(address mallid) public view returns (order[] memory) {
        order[] memory result ;
        result= new order[](allOrderMallCount[mallid]);
        uint counter = 0;
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].mallid== mallid) {
                result[counter] = orders[i];
                counter++;
            }
        }
            
        return result;
    }


    

}