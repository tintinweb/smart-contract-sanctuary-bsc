/**
 *Submitted for verification at BscScan.com on 2021-09-28
*/

// File: @openzeppelin/contracts/utils/Context.sol



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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: ExoticMonsterController.sol



pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

contract ExoticMonsterController is Ownable {
    
    using SafeMath for uint256;
    
    //??????
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    //?????? ????????????
    event SelectBox(address indexed player, uint8 indexed boxid, uint256 indexed price, uint256  heroNum);
    
    event PaymentReceived(address from, uint256 amount);

    
    IBEP20 EMC20;

    //??????????????????
    struct User{
        //???????????????????????????????????????????????????
        mapping(uint256 => Hero)  myHeros ;
        
        //????????????????????????????????????????????????
        mapping(uint256 => Pool)  myPools;
        
        //????????????
        uint256 myPoint;
        
        //???????????????????????????????????????myHeros??????
        uint256 heroIds;
        
        //?????????????????????????????????myPools??????
        uint256 poolIds;
        
    }
    
    //????????????
    struct Hero{
        
        // ??????ID
        uint256 id;
        
        //???????????????
        uint256 totalTimes;
        
        //?????????????????????
        uint256 usedTimes;
        
        //????????????????????????
        uint256 lastUsedTime;
        
        //shi'fo??????bei'
        bool isPooled;
        
    }
    

    //????????????
    struct Monster{
        
        //id
        uint256 id;
        
        //???????????? 87?????? 87%
        uint256 number;
        
        //?????????????????? ??????????????????
        uint256 basePrice;
        
        //?????????????????? ???????????????-?????????????????????
        uint256 stepPrice;
         
        //?????????????????? ????????????????????????
        uint256 successPoint;

        //?????????????????? ????????????????????????-????????????????????????
        uint256 stepSuccessPoint;
        
        //?????????????????? ????????????????????????
        uint256 losePoint;
        
        //?????????????????? ????????????????????????-????????????????????????
        uint256 stepLosePoint;
    }
    
    struct Pool{

        //id
        uint256 id;

        //???????????????ID
        uint256 heroId;

        //????????????
        uint256 amount;

        //?????????
        uint256 reward;

        //????????????
        uint256 circleTime;

        //????????????
        uint256 joinTime;

        //???????????? ?????? ?????????25% ??????????????? 75%
        uint256 rate;
    }
    
    //???????????????????????????????????????
    address public _boxAddress;
    
    //??????????????????
    mapping(address => User) public users;
    
    //???????????????
    mapping(uint256 => Pool) public pools;
    
    //??????????????????
    mapping(uint256 => Hero) public heros;
    
    //????????????
    mapping(uint256 => Monster) public monsters;
    
    constructor() {

        _boxAddress = 0x6be6D58d95d878eA4D1b1a355294384C71598132;
        
        
        //????????? ?????? EMSC ??????. msg.sender ??????????????????
        EMC20  =  IBEP20(0x664d1CDdC2E5e413d0A9fA7a29b1949B3a5adF2c);
        
        //
        EMC20.approve(address(this),45000000 * 10 **18);
        
        //????????? ????????????
        monsters[1] = Monster(1,87,2315,106,15,6,1,1);
        monsters[2] = Monster(2,70,2372,141,18,7,1,1);
        monsters[3] = Monster(3,56,2457,178,23,8,1,2);
        monsters[4] = Monster(4,39,2568,267,28,11,1,3);
        monsters[5] = Monster(5,25,2854,435,35,13,1,5);  
      
        //????????? ????????????
        heros[1] = Hero(1,2,0,0,false);
        heros[2] = Hero(2,3,0,0,false);
        heros[3] = Hero(3,4,0,0,false);
        heros[4] = Hero(4,5,0,0,false);
        heros[5] = Hero(5,6,0,0,false);
              
        //????????? ????????????
        pools[1] = Pool(1,0,0,0,0,5,0);
        pools[2] = Pool(2,0,0,0,1 weeks,84,0);
        pools[3] = Pool(3,0,0,0,2 weeks,163,0);
        pools[4] = Pool(4,0,0,0,30 days,400,0);
        pools[5] = Pool(5,0,0,0,90 days,1500,0); 
        
    }
    
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }
    
    //???????????? ?????????????????????ID???????????????????????????????????????
    function inPool(uint8 poolid,uint256 amount,uint256 userHeroId) public {
        
        // msg.sender ???????????????????????????????????? 
        Hero memory userHero = users[msg.sender].myHeros[userHeroId];
        
        //???????????????Hero ???????????????????????? 1000
        require(userHero.id != 0 && amount > 1000,"This user dont hava a hero ");
        
        //?????????????????????????????????
        users[msg.sender].poolIds = users[msg.sender].poolIds + 1;

        //?????? 
        if( 1 != poolid){
            users[msg.sender].myPools[users[msg.sender].poolIds] = Pool(
                pools[poolid].id,
                userHeroId,
                amount,
                amount.mul(pools[poolid].rate.div(1000)),
                pools[poolid].circleTime,
                block.timestamp,
                pools[poolid].rate
            );
        }
        //??????
        if( 1 == poolid){
            users[msg.sender].myPools[users[msg.sender].poolIds] = Pool(
                pools[poolid].id,
                userHeroId,
                amount,
                0,
                pools[poolid].circleTime,
                block.timestamp,
                pools[poolid].rate
            );
        }
        
        
        //?????????????????????
        users[msg.sender].myHeros[userHeroId].isPooled = true;
        
    }
    
    //????????????
    function outPool(uint256 poolIds) public {
        
        Pool memory myPool = users[msg.sender].myPools[poolIds];
        
        require(myPool.amount != 0,"");
        
        uint256 reward = 0;
        
        if(myPool.id == 1){
            //??????????????????
            reward = ((block.timestamp.sub(myPool.joinTime)) % 24 hours).mul(myPool.rate.div(1000)).mul(myPool.amount);
            
        }
        if(myPool.id != 1){
            reward = myPool.reward;
        }

        // 3% ??????

        reward = reward.mul(97).div(100);
        
        //???????????????????????????
        users[msg.sender].myHeros[myPool.heroId].isPooled = false;

        EMC20.transfer(msg.sender,reward);
    }
    

    //????????????
    function selectBox(uint8 boxId) public {
        
        
        if(1 == boxId){
            //?????? ????????????
            require(EMC20.balanceOf(msg.sender) > 1800 * 10 **18,"Dont hava enough EMSC ");

            //???????????????
            EMC20.transfer(_boxAddress,1800 * 10 **18);
            
            _addHeroToUser(msg.sender);
            
            //????????????
            emit SelectBox(msg.sender,boxId,1800,1);
            
        }
        if(2 == boxId){

            require(EMC20.balanceOf(msg.sender)  > 5200 * 10 **18,"This user dont hava enough EMSC ");

            EMC20.transfer(_boxAddress,5200 * 10 **18);
            
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            
            //????????????
            emit SelectBox(msg.sender,boxId,5200,3);
        }
        if(3 == boxId){

            require(EMC20.balanceOf(msg.sender)  > 8100 * 10 **18,"This user dont hava enough EMSC ");

            EMC20.transfer(_boxAddress,8100 * 10 **18);
            
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            _addHeroToUser(msg.sender);
            
            emit SelectBox(msg.sender,boxId,8100,5);
        }
        

    }

    //???????????? ??????ID?????????????????????
    function selectMonster(uint256 monsterID,uint256 userHeroId) public {
        
        Hero memory userHero = users[msg.sender].myHeros[userHeroId];
        
        
        if(!userHero.isPooled && userHero.usedTimes == userHero.totalTimes){
            if(userHero.lastUsedTime + 6 hours < block.timestamp){
                userHero.usedTimes = 0;
            }
        }
        
        if(!userHero.isPooled && userHero.usedTimes < userHero.totalTimes){
            
            if(userHero.usedTimes == 0){
                
                userHero.lastUsedTime = block.timestamp;
                
            }

            userHero.usedTimes = userHero.usedTimes + 1;

            
            Monster memory userSelectMonster = monsters [monsterID];
            
            uint256 point = 0;
            
            uint256 price = 0 ;
            
            if(_betMonster(userSelectMonster.number)){
                
                price = userSelectMonster.basePrice + _getMonsteRadom(userSelectMonster.stepPrice);
                
                price =  price * 10 ** 16;
                
                point =  userSelectMonster.successPoint + _getMonsteRadom(userSelectMonster.stepSuccessPoint);

            }else{
                point = userSelectMonster.losePoint + _getMonsteRadom(userSelectMonster.stepLosePoint);
            }
            
            users[msg.sender].myPoint = users[msg.sender].myPoint + point;
            
            EMC20.transfer(msg.sender, price);
        }
    }

    //????????????????????????
    function _addHeroToUser(address user ) internal virtual{
       
    
       uint256 heroLevel  =  _getHero();
       
       users[user].heroIds = users[user].heroIds + 1;
       
       users[user].myHeros[users[user].heroIds] = heros[heroLevel];
       
    }

    //?????????????????????????????????

    function _getHero() internal virtual returns (uint256) {
    
        uint256 number =  uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,msg.sender))) % 10000;

        
        if( 0 <= number && number < 6100 ){
            return 1;
        }
        
        if( 6100 <= number && number < 8550 ){
            return 2;
        }
        if( 8550 <= number && number < 9750 ){
            return 3;
        }
        if( 9750 <= number && number < 9965 ){
            return 4;
        }
        if( number <= 9965 || number < 9965 ){
            return 5;
        }

        return 1;
    }
    
    //??????????????? true??????????????????
    function _betMonster(uint256 monsterNumber ) internal virtual returns (bool) {
    
        uint256 number =  uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,msg.sender))) % 100;

        if( number < monsterNumber ){
            return true;
        }
        
        return false;
    }
    
    //???????????????????????????????????????
    function _getMonsteRadom( uint256 number ) internal virtual returns (uint256) {
        uint256 num =  uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,msg.sender))) % number;
        return num;
    }
}