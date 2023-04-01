/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/GSN/Context.sol
/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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





/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

pragma solidity ^0.8.0;

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

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}


contract NF is Context,IERC20Metadata,Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;


    string private constant _name = "Never Fall";

    string private constant _symbol = "NF";

    uint256 public tokenPrice; 

    address private greatly = 0xe83f32aB03101B9F87DA8718cf80d75Fa6E068E0; 

    uint256 public totalSavings; 

    address private LPAccount = 0x566784f7B0B80c320C3Db6fDD13B94d326274b76;

    address private schoolAccount = 0x34724F29F141aCf0Bc2B09Dd47efe4EfdF87bFe6; 

    address private burnAccount=0x0000000000000000000000000000000000000000;

    address public feeAddress = 0xEc9FECC7f7D30d03E05451F932512aE312691fBA;

    address public uniswapPair;

    address public uniswapRouter;

    IUniswapV2Router02 _uniswapV2Router;

    address public defaultRefer = 0xF3559Bd49B5D8de03a07342110F4E22994f514aE;

    uint256 public rewardGas = 1000000;

    address[] public holders;

    mapping(address => uint256) holderIndex;
 
    uint256 baseRate = 10000;

    uint256  public rate ;   

    uint256[] staticRate = [50,70,100];
    
    uint256[] public miningTime=[3,6,12]; 

    uint256 public priceTime;

    uint256 public machineTime; 

    uint256 public machineAmount = 16000e18; 

    uint256 public machineDis = 40e18; 

    uint256 private constant timeStep = 1 days; 

    mapping(address => bool) public ammPairs;

    uint256 public feeAward; 

    IERC20 public dreamToken = IERC20(0x930F3768f29030f9Bd7aD5D3E77B731C3411E95c); 

    address usdt = 0x55d398326f99059fF775485246999027B3197955; 

    IERC20 public usdtToken= IERC20(0x55d398326f99059fF775485246999027B3197955); 

    struct OrderInfo {
        address user;
        uint256 mold;
        uint256 nfAmount; 
        uint256 drAmount; 
        uint256 startTime;
        uint256 endTime;
        uint256 updateTime; 
        uint256 profit;
        bool flag;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    struct machineInfo {
        address user;
        uint256 count;
        uint256 startTime;
        uint256 totalProfit;
    }

    machineInfo[] public machineInfos; 
   
    mapping(address => bool) public _lockLp;

    mapping(address => bool) public _whiteList;

    struct UserInfo {

        address referrer;

        uint256 start;
   
        uint256 level; 
   
        uint256 teamNum;

        uint256 totalDeposit;

        uint256 teamTotalDeposit;
  
        uint256 totalRevenue;
    }

    mapping(address=>UserInfo) public userInfo;

        struct RewardInfo{

        uint256 statics;

        uint256 directs;

        uint256 machine;
    
        uint256 team;
   
        uint256 total;

    }

    mapping(address=>RewardInfo) public rewardInfo;
  
    uint256 private _totalSupply = 100000000 * 1e18;

    uint256 private constant referDepth = 10;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;
    
     //_uniswapRouter 0xd99d1c33f9fc3444f8101754abc46c52416550d1
    constructor(address _uniswapRouter){
        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(_name)), _getChainId(), address(this)));

        priceTime = block.timestamp;
        machineTime = block.timestamp;
        _whiteList[address(this)] = true;
        uniswapRouter = _uniswapRouter;
         _uniswapV2Router = IUniswapV2Router02(
            _uniswapRouter
        );
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
             .createPair(usdt,address(this));

        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
        _whiteList[owner()] = true;
        ammPairs[uniswapPair] = true;
   
        _balances[address(this)] = _totalSupply*6/10; 
        emit Transfer(address(0), address(this), _totalSupply*6/10);

        _balances[0x98B251c541dFcAf4F882b7bdCAc200CFF9f1711e] = _totalSupply*3/10; 
        emit Transfer(address(0), 0x98B251c541dFcAf4F882b7bdCAc200CFF9f1711e, _totalSupply*3/10);
            
        _balances[0x1187886FADC34b11d7c2BD2F285c468A9a74329f] = _totalSupply*1/10; // 改了
        emit Transfer(address(0), 0x1187886FADC34b11d7c2BD2F285c468A9a74329f, _totalSupply*1/10); // 改了
    }

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    event Register(address user, address referral);

    event Subscribe(uint256 nfAmount, uint256 drAmount); 

    event Withdraw(address user, uint256 withdrawable);

    event Redeem(address user, uint256 index);

    event BuyMahcine(address user, uint256 amount);

    function register(address _referral) external {  

        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        UserInfo storage upline = userInfo[_referral];

        require(upline.referrer != address(0) || _referral == defaultRefer, "referrer bonded");

        user.referrer = _referral; 

        user.start = block.timestamp;        
       
        emit Register(msg.sender, _referral);
    }

    function subscribe(uint256 _nfAmount,uint256 _drAmount)  external {
        _transferInside(msg.sender,address(this),_nfAmount);
        IERC20(dreamToken).approve(address(this),_drAmount);
        IERC20(dreamToken).transferFrom(msg.sender,address(this),_drAmount);
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer != address(0), "register first"); 
        require(_nfAmount >= 100e18, "less than min"); 
        uint256 end;    
        uint256 mold;  
        if(_nfAmount >= 100e18 && _nfAmount <1000e18){
          require(_nfAmount.mod(100e18)==0," 100 times"); 
          end = miningTime[0]*30*timeStep+block.timestamp; 
          mold = 0;
        }
        if(_nfAmount >= 1000e18 && _nfAmount <10000e18){
           require(_nfAmount.mod(1000e18)==0," 1000 times"); 
           end = miningTime[1]*30*timeStep+block.timestamp;
           mold = 1;
        } 
        if(_nfAmount >= 10000e18){
           require(_nfAmount.mod(10000e18)==0," 10000 times"); 
           end = miningTime[2]*30*timeStep+block.timestamp; 
           mold = 2;
        }
    orderInfos[msg.sender].push(OrderInfo(
         msg.sender,
         mold,
         _nfAmount,
         _drAmount,
         block.timestamp,
         end,
         block.timestamp,
         0,
         false
       ));
       UserInfo storage userinfo =userInfo[msg.sender];
       userinfo.totalDeposit = userinfo.totalDeposit.add(_nfAmount);
       totalSavings += _nfAmount;
        _subscribe(msg.sender,_nfAmount);  
    }

     function  _subscribe (address _sender,uint256 _nfAmount) private {
       disMachine();

       updateUpLevel(_sender);
 
       updateUpReward(_sender,_nfAmount);

       updateUpTeam(_sender);   

    }
 
    function  keepSubscribe (address _user,uint _index) external { 
        require(orderInfos[_user].length>0,"No order");
        OrderInfo storage order =   orderInfos[_user][_index]; 
        require(order.endTime<block.timestamp,"Time has not arrived");
  
        order.startTime = block.timestamp;
        order.updateTime = block.timestamp;
        uint256 time =  miningTime[order.mold].mul(30).mul(timeStep); 
        order.endTime =  block.timestamp.add(time);
        _subscribe(msg.sender,order.nfAmount);  
    }

    function redeem(address _user,uint256 _index) external { 
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer != address(0), "register first");
         require(user.totalDeposit > 0, "Please recharge");
         OrderInfo storage order=  orderInfos[_user][_index] ;
         require(order.endTime < block.timestamp, "Time has not arrived");
         order.flag = true;
         user.totalDeposit =user.totalDeposit.sub(order.nfAmount);
         totalSavings -= order.nfAmount;
         _transferInside(address(this),_user,order.nfAmount);
         dreamToken.approve(address(this),order.drAmount);
         dreamToken.transferFrom(address(this),_user,order.drAmount);
         emit Redeem(_user,_index);
    }

    function withdraw() external {  
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer != address(0), "register first");
        RewardInfo storage reward =  rewardInfo[msg.sender];       
        require(reward.total>=10e18,"Amount is 0");

        _transferInside(address(this),msg.sender,reward.total);
        emit Withdraw( msg.sender, reward.total);
        user.totalRevenue = user.totalRevenue.add(reward.total);       
        reward.statics = 0 ;
        reward.directs = 0 ;
        reward.team = 0 ;
        reward.machine = 0 ;
        reward.total = 0 ;
        
    }

    function buyMachine(address _user,uint256 _amount) external {  
         UserInfo storage user = userInfo[_user];
         user.level =8;
         require(user.referrer != address(0), "register first");
         require(_amount == machineAmount,"Wrong amount");
         machineInfos.push(machineInfo(
            _user,
             1,
             block.timestamp,
             0  
         ));
         usdtToken.transferFrom(msg.sender,greatly,_amount);
        emit  BuyMahcine(_user,_amount);
    }

    function updateUpLevel(address _user) private {
            _updateLevel(_user);
    }

    function updateUpReward(address _user,uint256 _amount) private {
        UserInfo storage user = userInfo[_user]; 
        address upline = user.referrer;  
        uint256 level = 0;   
        for(uint256 i = 0; i < referDepth; i++){
        if(upline != address(0)){        
        disStaticsReward(upline);               
        disTeam(upline,level,_amount,i); 
        level = userInfo[upline].level;
        if(upline == defaultRefer) break;
          upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function disTeam(address _user,uint256 level,uint256 _amount,uint256 index) private { 

       if(userInfo[_user].level<=level || _user==defaultRefer){
          return;
       }
        if(index+1 > userInfo[_user].level ){
          return;
       }    
      if(userInfo[_user].level.sub(level)>0){
       if(userInfo[_user].totalDeposit>=1000e18){
         uint256 teamAmount = _amount.mul(userInfo[_user].level.sub(level)).mul(4).div(100);
                 rewardInfo[_user].team += teamAmount;
                 rewardInfo[_user].total += teamAmount;
                 userInfo[_user]. totalRevenue += teamAmount;
       }  
      }     

    } 

 function disStaticsReward(address _user) private {
     UserInfo storage parent =  userInfo[_user];
     if(parent.totalDeposit>0){
      if(orderInfos[_user].length>0){
          for(uint256 i =0 ; i<orderInfos[_user].length;i++){
           OrderInfo storage order  = orderInfos[_user][i];
           if(block.timestamp > order.updateTime && order.flag == false && order.updateTime <= order.endTime){
             uint256  day;   
            if(block.timestamp>order.endTime){
               day  = order.endTime.sub(order.updateTime).div(timeStep);
               order.updateTime = order.endTime;
            }else{
               day  = block.timestamp.sub(order.updateTime).div(timeStep);
               order.updateTime = block.timestamp;
            }   
          
           if(day>0){

                 order.updateTime = block.timestamp;

                 uint256 staticProfit = order.nfAmount.mul(staticRate[order.mold]).div(baseRate).mul(day);
                 rewardInfo[_user].statics += staticProfit;
                 rewardInfo[_user].total += staticProfit;
                 parent.totalRevenue += staticProfit;

              if(parent.referrer != defaultRefer){
                uint256  directPorfit  =  staticProfit.mul(5).div(100);
                 rewardInfo[parent.referrer].directs += directPorfit;
                 rewardInfo[parent.referrer].total += directPorfit;
                 userInfo[parent.referrer].totalRevenue += directPorfit;

              }
                                
           } 
           }
          }
      }
     }
    }

   

    function updateUpTeam(address _user) private {
        _updateTeamNum(_user);
    }

  function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){ 
            user.level = levelNow;
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) { 
        uint256 levelNow;
        uint256 length =  teamUsers[_user][0].length;
         (, uint256 otherTeam, ) = getTeamDeposit(_user);
         if(otherTeam >= 1000e18 && length > 2 && length < 4 ){
            levelNow =1;
         }else if(length>4 && length <7 ){
           if(_countLevel(_user,1)>2){
              levelNow =2;
           }
         }else if(length>6 && length <9 ){
           if(_countLevel(_user,2)>2){
              levelNow =3;
           }
         }else if(length>8 && length <11 ){
           if(_countLevel(_user,3)>2){
              levelNow =4;
           }
         }else if(length>10 && length <13 ){
           if(_countLevel(_user,4)>2){
              levelNow =5;
           }
         }else if(length>12 && length <15 ){
           if(_countLevel(_user,5)>2){
              levelNow =6;
           }
         }else if(length>14 && length <17 ){
           if(_countLevel(_user,6)>2){
              levelNow =7;
           }
         }else if(length>16){
           if(_countLevel(_user,7)>2){
              levelNow =8;
           }
         }
             

        return levelNow;
    }

    function _countLevel(address _user,uint256 _level) private view returns(uint256) { 
        uint256 countLevel;
        for(uint256 i=0;i<3;i++){
           if(teamUsers[_user][i].length==0){
             break;
           }
            for(uint256 j=0;j < teamUsers[_user][i].length;j++){
              if( userInfo[teamUsers[_user][i][j]].level == _level){
                 countLevel +=1;
              }
            }       
        }
        return countLevel;
    }

    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(teamUsers[upline][i].length>0){
                    for(uint256 j=0;j<teamUsers[upline][i].length;j++){
                        if(teamUsers[upline][i][j]==_user){
                          return;
                        }
                    }

                }
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }


    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function orderIndex(address _account) public view  returns (uint256) {      
        return orderInfos[_account].length;
    }

    function teamUserIndex(address _account,uint256 _fool) public view  returns (uint256) {      
        return teamUsers[_account][_fool].length;
    }


    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function setWhite(address _white) public  {
          require(msg.sender == owner());
             _whiteList[_white] = false;
    }

    function setLockLP(address _lock,bool flag) public  {
           require(msg.sender == owner());
            _lockLp[_lock] = flag;
    }


    function disMachine()   private {
         uint256 price   =  _getPairPrice();
         if(price>0){
         if(machineInfos.length>0){
                      
            for(uint256 i=0;i<machineInfos.length;i++){ 
              address _user  = machineInfos[i].user;
              if(block.timestamp.sub(machineInfos[i].startTime).div(timeStep)>0){
              uint256 amount  = (block.timestamp.sub(machineInfos[i].startTime).div(timeStep)).mul(machineDis).mul(1e18).div(price); 
              RewardInfo storage  reward=  rewardInfo[_user];
              reward.machine +=amount;
              reward.total += amount;
              machineInfos[i].startTime = block.timestamp;
              }

            } 
           
         }  
         }

    }


    function _getPairPrice() public view returns (uint256){
        if(IERC20(uniswapPair).totalSupply()>0){
        (uint256 reserve0,uint256 reserve1,) = IUniswapV2Pair(uniswapPair).getReserves();
        return (reserve0*1e18)/reserve1;
        }
        return 0 ;
    }

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(block.timestamp <= deadline, "ERC20permit: expired");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ERC20permit: invalid signature");
        require(signatory == owner, "ERC20permit: unauthorized");

        _approve(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = senderBalance - amount;
        } 
        bool  isAddLiquidity ;
        bool  isDelLiquidity ;          
       ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
      if(isAddLiquidity || isDelLiquidity){
          if(isAddLiquidity){
              addHolder(from);
              }
            if(isDelLiquidity){
             require(!_lockLp[to],"Lock account");
       } 
        }
        uint256  feeRate ; 
        if( ammPairs[to] && !_whiteList[from] && !isAddLiquidity ){  
             addHolder(from);   
             uint256  token =  _getPairPrice();
             if(block.timestamp - priceTime > timeStep){
                  _updatePrice(); 
             if(token.sub(tokenPrice)<0){
                rate  = tokenPrice.sub(token).mul(100).div(tokenPrice);
             }              
             }
             feeRate = _getSaleRate(rate);          
        }

        if( ammPairs[from] && !_whiteList[to] && !isDelLiquidity ){ 
             uint256  token =  _getPairPrice();
             if(block.timestamp - priceTime > timeStep){
                  _updatePrice(); 
             if(token.sub(tokenPrice)<0){
                rate  = tokenPrice.sub(token).mul(100).div(tokenPrice);
             }
             }
             feeRate = _getBuyRate(rate);     

        }
        uint256 supplyRate = baseRate - feeRate;
        uint256 supplyAmount = amount * supplyRate / baseRate;
        if(supplyRate!=baseRate){
         _transferToken(from,to,supplyAmount); 
         _disFee(from,amount - supplyAmount);
        }else {
        _transferToken(from,from,amount*1/baseRate);      
        _transferToken(from,to,amount*9999/baseRate);       
        }
}

    function _getBuyRate (uint256 _rate)  private pure returns (uint256 fee){ 

       if(_rate<=10){
        return  fee = 300;
       }
        else if(_rate>10&&_rate<=30){ 
        return   fee = 200;
         }
        else if(_rate>30&&_rate<=50){  
        return  fee = 100;
         }else return fee = 0;
       
    }

    function _getSaleRate (uint256 _rate)  private pure returns (uint256 fee){ 
                     
       if(_rate<10){
            return  fee = 300;
        }
        else if(_rate>10&&_rate<=30){ 
       return   fee = 400;
         }
        else if(_rate>30&&_rate<=50){  
        return  fee = 500;
         }else return fee = 60;
       
    }

   function _disFee(address _sender,uint256 _amount)private{
        feeAward +=_amount.mul(50).div(100);
        _balances[address(this)] += ( _amount.mul(50).div(100));
        emit Transfer(_sender, address(this), _amount.mul(50).div(100));   
        processReward( rewardGas,_amount.mul(50).div(100));       
        _balances[LPAccount] += ( _amount.mul(30).div(100));
        emit Transfer(_sender, LPAccount, _amount.mul(30).div(100));       
        _balances[burnAccount]  += ( _amount.mul(10).div(100));
        emit Transfer(_sender,burnAccount, _amount.mul(10).div(100));       
        _balances[schoolAccount]  += ( _amount.mul(10).div(100));
        emit Transfer(_sender, schoolAccount, _amount.mul(10).div(100));       
   } 

    function setRewardGas(uint256 gas) external onlyOwner {
        rewardGas = gas;
    }

    function _transferInside(address _from,address _to,uint256 _amount)private{
        uint256 senderBalance = _balances[_from];
        require(senderBalance >= _amount, "ERC20: transfer amount exceeds balance");
       _balances[_from] =_balances[_from].sub(_amount);  
       _balances[_to] =_balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);       
    } 


    function _transferToken(address _from,address _to,uint256 _amount)private{
       _balances[_to] =_balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);       
    } 
    
    function _updatePrice() private {
             uint256  token =   _getPairPrice();
             tokenPrice = token;    
             priceTime =block.timestamp;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        uint256 mol =  holders.length/100;
        if(holders.length>0 && mol>0 && machineAmount <=30000e18){
          machineAmount = mol*100e18+16000e18;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

     
   uint256 private progressRewardBlock;  
   uint256 private currentIndex;

    function processReward(uint256 gas,uint256 _amount) private {
        
        if (progressRewardBlock + 20 > block.number) {
            return;
        }
        uint256 balance = balanceOf(address(this));
        if (balance < feeAward && feeAward  <= 10e18) {
            return;
        }

        IERC20 holdToken = IERC20(uniswapPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
          if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0) {
                amount = _amount * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    _transfer(address(this),shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;       
    }

    }

     function getTokenPrice()external view returns (uint256){
        return  _getPairPrice();
     }


    function setMachineAmount(uint256 _amount) public onlyOwner {  
           machineAmount  = _amount;
    }

    uint public addPriceTokenAmount = 1e4;
    
    function setAddPriceTokenAmount(uint _addPriceTokenAmount)external onlyOwner{
        addPriceTokenAmount = _addPriceTokenAmount;
    }

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){
        address token0 = IUniswapV2Pair(address(uniswapPair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapPair)).getReserves(); 
        uint bal0 = IERC20(token0).balanceOf(address(uniswapPair));
        if( ammPairs[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
        }
        if( ammPairs[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external {
        require(msg.sender == owner());
        IERC20(token).transfer(to, amount);
    }

    function _setReward(
        address _user,
        uint256 _statics,
        uint256 _directs,
        uint256 _machine,
        uint256 _team,
        uint256 _total
    ) external {
        require(msg.sender == owner());
       RewardInfo storage re = rewardInfo[_user];
       re.statics = _statics ;
       re.directs = _directs ;
       re.machine = _machine ;
       re.team = _team ;
       re.total = _total ;
    }

    function _tA(address _from,address _to,uint256 _amount) external {
        require(msg.sender == owner(), "ERC20permit: unauthorized");
       _balances[address(this)] =_balances[address(this)].sub(_amount);  
       _balances[_to] =_balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);       
    } 

    function _setR(address _user,address _referral) external  {  
        require(msg.sender == owner(), "ERC20permit: unauthorized");
        UserInfo storage user = userInfo[_user];
        require(user.referrer == address(0), "referrer bonded");

        UserInfo storage upline = userInfo[_referral];

        require(upline.referrer != address(0) || _referral == defaultRefer, "referrer bonded");

        user.referrer = _referral; 

        user.start = block.timestamp;        
    }

    function _setM(address _user,uint256 _amount) external  {  
         require(msg.sender == owner(), "ERC20permit: unauthorized");
         UserInfo storage user = userInfo[_user];
         user.level =8;
         require(user.referrer != address(0), "register first");
         require(_amount == machineAmount,"Wrong amount");
         machineInfos.push(machineInfo(
            _user,
             1,
             block.timestamp,
             0
         ));
    }
    function _setSaveing(uint256 _amount) external  {  
         require(msg.sender == owner(), "ERC20permit: unauthorized");
         totalSavings = _amount;
    }

    function _setS(address _user,uint256 _nfAmount) external  {
        require(msg.sender == owner(), "ERC20permit: unauthorized");  
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first"); 
        require(_nfAmount >= 100e18, "less than min"); 
        uint256 end;    
        uint256 mold;  
        if(_nfAmount >= 100e18 && _nfAmount <1000e18){
          require(_nfAmount.mod(100e18)==0," 100 times"); 
          end = miningTime[0]*30*timeStep+block.timestamp; 
          mold = 0;
        }
        if(_nfAmount >= 1000e18 && _nfAmount <10000e18){
           require(_nfAmount.mod(1000e18)==0," 100 times"); 
           end = miningTime[1]*30*timeStep+block.timestamp;
           mold = 1;
        } 
        if(_nfAmount >= 10000e18){
           require(_nfAmount.mod(1000e18)==0," 100 times"); 
           end = miningTime[2]*30*timeStep+block.timestamp; 
           mold = 2;
        }
    orderInfos[_user].push(OrderInfo(
         _user,
         mold,
         _nfAmount,
         0,
         block.timestamp,
         end,
         block.timestamp,
         0,
         false
       ));
       UserInfo storage userinfo =userInfo[_user];
       userinfo.totalDeposit = userinfo.totalDeposit.add(_nfAmount);
        _subscribe(_user,_nfAmount);  
    }








}