/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

import "./IUniswapV2Pair.sol";

contract NF is Context,IERC20Metadata,Ownable {

    using SafeMath for uint256;

    IERC20 public usdt;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    //mainnet: 
    string private constant _name = "Never Fall";
    //mainnet: 
    string private constant _symbol = "NF";

    uint256 private _totalSupply = 100000000 * 1e18;

    uint256 public startTime; //开始时间

    uint256 private constant timeStep = 1 days;

    uint256 public lastDev; //上次发开发者奖励时间

    address public poolAddress;

    address public developAddress;

    address public lpContractAddress;

    address public marketAddress;//市值地址

    address public rootAddress;

    bool[] public lvFlag;

    address public burnAddress= 0x0000000000000000000000000000000000000000;  //黑洞地址

    address[] public leader;  //股东

    address[] public depositors; //存款人

    uint256 buyRate; 

    uint256 lv1Rate = 500;
    uint256 lv2Rate = 800;
    uint256 lv3Rate = 1000;
    uint256 lv4Rate = 1500;
    uint256 lv5Rate = 2000;
    uint256 lv6Rate = 2500;
    uint256 lv7Rate = 3000;
    uint256 lv8Rate = 3500;
    uint256 baseRate = 10000;  
    
    struct MachineInfo {  //个人呢矿机信息
        uint256 startTime; //开始时间
        uint256 staticProfit; //收益
        uint256 totalProfit;//总收益 
       }

    
    struct RewardInfo{

        uint256 staticsProfit;

        uint256 teamProfit;

        uint256 directProfit;

        uint256 machineProfit;
    }


        struct UserInfo {

        address referrer; //推荐人

        uint256 start;
   
        uint256 level; // 0,1, 2, 3, 4, 5

        uint256 validNum; //有效人数

        uint256 teamPledge; // 团队总质押额

        uint256 totalDeposit;

        uint256 totalFreezed; //已冻结

        uint256 totalRevenue; //总收益
    }
        struct OrderInfo { //NF质押订单信息
        uint256 amount;
        uint256 profit; 
        uint256 startTime;
        uint256 nowTime;
        uint256 level;
        bool isUnfreezed; //是否冻结
    }

    mapping(address=>address[]) public superiors;

    mapping(address=>UserInfo) public userInfo;

    mapping(address=>address[]) public validChildren;

    mapping(address=>RewardInfo) public rewardInfos; 

    mapping(address => MachineInfo) public machineList;

    mapping(address => OrderInfo[]) public orderInfos;

    mapping(address => UserInfo[]) public teamUsers;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    constructor(address _rootAddress,address _usdtAddress,address _poolAddress,address _developAddress,address _marketAddress){
        rootAddress  =  _rootAddress;
        marketAddress = _marketAddress;
        developAddress = _developAddress;
        usdt = IERC20(_usdtAddress);
        poolAddress = _poolAddress;
        startTime = block.timestamp;
        lastDev = block.timestamp;
        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(_name)), _getChainId(), address(this)));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

     // event
    event Deposit(address user, uint256 amount);

    event DirectProfit(address user, uint256 amount);

    event Register(address sender,address referral);

    event Withdraw(address user, uint256 withdrawable);

    function sendNFToPoolAddress() public   {//10%  给底池账户
         require(msg.sender==poolAddress,"poolAddress is err");
         uint256 amount=_totalSupply.mul(10).div(100);
         transfer(poolAddress,amount);
    }

    function sendNFTodevelopAddress() public   {  //5%  200天释放 每天 0.00025
         require(msg.sender==developAddress,"developAddress is err");
         uint256 amount=_totalSupply.mul(25).div(100000);
         if(block.timestamp > lastDev.add(timeStep)){  // 如果当前时间大于开始时间
            uint256 dayNow = getCurDay();  //获取天数
            transfer(developAddress,amount.mul(dayNow));
            lastDev = block.timestamp;
        }
        
    }

    function sendNFToMarketAdderss() public   {  //10%  给底池账户
         require(msg.sender==marketAddress,"marketAddress is err");
         uint256 amount=_totalSupply.mul(5).div(100);
         transfer(marketAddress,amount);
    }


   function getCurDay() public view returns(uint256) { // 获取天数
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function bindLeader(address _address) public   {  
         require(msg.sender==rootAddress,"rootAddress is err");
         if(leader.length>0){
            for(uint256 i = 0;i<leader.length;i++){
                require(_address!=leader[i],"Binding has been repeated"); //重复绑定
                leader.push(_address);
            }
         }   

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

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(block.timestamp <= deadline, "ERC20permit: expired");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ERC20permit: invalid signature");
        require(signatory == owner, "ERC20permit: unauthorized");

        _approve(owner, spender, amount);
    }

   function setLPContractAddress(address _address) onlyOwner public returns (bool success) {
        lpContractAddress = _address;
        return true;
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
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

         emit Transfer(sender, recipient, amount.mul(99).div(100));       
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

   //提现方法
    function withdraw() external {
     //获取总收益，如果没有就返回
   RewardInfo  storage reward =   rewardInfos[msg.sender];

    uint256 staticsProfit  =   reward.staticsProfit;
    uint256 teamProfit  =   reward.teamProfit;
    uint256 directProfit  =   reward.directProfit;
    uint256 machineProfit  =   reward.machineProfit;
    uint256 profit= staticsProfit.add(teamProfit).add(directProfit).add(machineProfit);
    if(profit>0){
     transferFrom(address(this),msg.sender,profit);
     reward.staticsProfit=0;
     reward.teamProfit=0;
     reward.directProfit=0;
     reward.machineProfit=0;
    }
    
   }

    function _getPairPrice(address _lpAddress) public view returns (uint256){
        (uint256 reserve0,uint256 reserve1,) = IUniswapV2Pair(_lpAddress).getReserves();
        return (reserve1*1e18)/reserve0;
    }

    function buyMachine(uint256 _amount) public returns (bool status)  { // 购买矿机
       require(msg.sender!=address(0),"ERC20: buy from the zero address");
      bool flag = false; //开关
      if(leader.length>0){
            for(uint256 i = 0;i<leader.length;i++){
                if(leader[i]==msg.sender){
                 flag = true;
                }
            }
         }
         else{
            return false;
         }
         require(_amount==5000*1e18,"You have to save 100 to become a leader");
         if(flag){
            usdt.transfer(address(this),_amount);
            MachineInfo storage mac=machineList[msg.sender];
           //初始化挖矿信息
            mac.startTime=block.timestamp;
            mac.staticProfit=0;
            mac.totalProfit=0;
            return true;
         }
       
    }

    function _getMachineProfit() private{
       if(leader.length>0){
           bool flag = false;
            for(uint256 i = 0;i<leader.length;i++){
                if(leader[i]==msg.sender){
                 flag = true;
                 break;
                }
            }
            if(flag){
             uint256  tianshu =  block.timestamp.sub(machineList[msg.sender].startTime).div(timeStep); //天数大于1刷新
             if(tianshu>1){
                //挖矿收益百分比  0.006  
            uint256 machinePrice = 5000*1e18;
            uint256 riqi=tianshu.sub(1);
            uint256 nowRate= _getPairPrice(lpContractAddress);
            uint256 newProfit = machinePrice.mul(nowRate).mul(6).mul(riqi).div(1000);
            
                //更新machinfo
             machineList[msg.sender].startTime=block.timestamp;
             machineList[msg.sender].staticProfit=machineList[msg.sender].staticProfit.add(newProfit);
             machineList[msg.sender].totalProfit=machineList[msg.sender].totalProfit.add(newProfit);
            
             }
            }
            
         }
    }

//  注册方法
    function register(address _referral) external {  // _referral 推荐人 、 推荐

        require(userInfo[_referral].totalDeposit > 0 , "referrer bonded");
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        user.referrer = _referral; //创建user信息  推荐人

        user.start = block.timestamp;//创建user信息  推荐时间

        emit Register(msg.sender, _referral);  //注册时间
    }

   //获取质押收益
    function _getOrderProfit() private returns(uint256){
    if(depositors.length>0){
        bool flag=false;
     for(uint256 i=0;i<depositors.length;i++){
         if(depositors[i]==msg.sender){
            flag = true;
         }
     }
    require(flag==false,"Non pledged users");
    OrderInfo[] storage orderList =  orderInfos[msg.sender];
    if(orderList.length<0){
       return 0;
    } 
     for(uint256 i=0;i<orderList.length;i++){
        OrderInfo storage order=  orderList[i];
        uint256  tianshu =  block.timestamp.sub(order.nowTime).div(timeStep).sub(1); //天数大于1刷新
        if(order.isUnfreezed==true){
          continue;
        }
        if(order.level==1){ //3个月
           if(block.timestamp.sub(order.startTime).div(timeStep)>90){
            order.isUnfreezed=true;
            continue;
           }
           if(tianshu>0){
            uint256 profit = order.amount.mul(50).div(10000);
            order.profit =  order.profit.add(profit);
            rewardInfos[msg.sender].staticsProfit=rewardInfos[msg.sender].staticsProfit.add(profit);
            order.nowTime = block.timestamp;
           }
           
        }
          if(order.level==2){ //6个月
            if(block.timestamp.sub(order.startTime).div(timeStep)>180){
            order.isUnfreezed=true;
            continue;
        }
           if(tianshu>0){
            uint256 profit = order.amount.mul(70).div(10000);
            order.profit =  order.profit.add(profit);   
            rewardInfos[msg.sender].staticsProfit=rewardInfos[msg.sender].staticsProfit.add(profit);
            order.nowTime = block.timestamp;             
           }
      
          }
          if(order.level==3){ //12个月
            if(block.timestamp.sub(order.startTime).div(timeStep)>360){
            order.isUnfreezed=true;
            continue;
        }
            if(tianshu>0){
            uint256 profit = order.amount.mul(100).div(10000);   
             order.profit =  order.profit.add(profit);   
            rewardInfos[msg.sender].staticsProfit=rewardInfos[msg.sender].staticsProfit.add(profit);
            order.nowTime = block.timestamp;              
           }  
          }
        
     }  
    }
    return 0;    
    }

    //质押 方法
    function deposit(uint256 _amount) external {              
    UserInfo storage user = userInfo[msg.sender];  //
    
    depositors.push(msg.sender);
    
    require(user.referrer != address(0), "register first");  // 未注册 不通过
    
    uint256  lv;

    user.totalDeposit=user.totalDeposit.add(_amount); //添加个人总金额
    if(user.totalDeposit>=100*1e18){
       require(user.totalDeposit.mod(100*1e18) == 0, "amount err");  
       lv=1;
     }
    if(user.totalDeposit>=100*1e18){
        require(user.totalDeposit.mod(1000*1e18) == 0, "amount err"); 
        lv=2;
     }
    if(user.totalDeposit>=100*1e18){
        require(user.totalDeposit.mod(10000*1e18) == 0, "amount err");  
        lv=3;
     }
    orderInfos[msg.sender].push(OrderInfo( 
            _amount,
            0, 
            block.timestamp,
            block.timestamp,
            lv, 
            false
        ));
        // todo 直推5%  
        transferFrom(msg.sender, user.referrer, _amount.mul(5).div(100));
        emit DirectProfit(msg.sender,_amount.mul(5).div(100));
        rewardInfos[user.referrer].directProfit=rewardInfos[user.referrer].directProfit.add(_amount.mul(5).div(100));            
        //todo 更新团队等级
       _updateTeamLevel(msg.sender);
        // todo 发放团队收益
        _sendTeamProfit(_amount);  
        transferFrom(msg.sender, address(this), _amount.mul(95).div(100));
        emit Deposit(msg.sender, _amount);
    }

 function _updateTeamLevel(address _sender) private{
     //加入有效用户和总质押
    address[] storage  topAddress  = superiors[msg.sender];  
    if(topAddress[0]==address(0)){
      return;
    }        
    address[] storage top1Children = validChildren[topAddress[0]];
    if(top1Children.length>0){
      bool flag=false;  
      for(uint256 i=0;i<top1Children.length;i++){
          if(top1Children[i]==_sender){
           flag=true; 
          }
          if(flag){
             top1Children.push(msg.sender);
          }
      } 
    }else{
       top1Children.push(msg.sender);
    }
    if(validChildren[topAddress[0]].length<3){
       return;
    }
    
    

    for(uint256 i=0;i<topAddress.length;i++){
         UserInfo storage user   =  userInfo[topAddress[i]]; 
         uint256   valid= user.validNum; //有效用户
         uint256   total = user.teamPledge; //直推总质押额度
         if(valid>=3&&valid<5){
           if(total>=1000){
             curLelve(topAddress[i],1);
           }
         }
          if(valid>=5&&valid<7){
              //有效用户是否有 2个V1 及以上
            uint256 num=   getLvNum(topAddress[i],1);
            if(num>=2){
             curLelve(topAddress[i],2);
           }
         }
          if(valid>=7&&valid<9){
              //有效用户是否有 2个V2 及以上
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
            if(num2>=3){
             curLelve(topAddress[i],3);
             continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }
          if(valid>=9&&valid<11){
              //有效用户是否有 3个V3 及以上
            uint256 num3=   getLvNum(topAddress[i],3);
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
             if(num3>=3){
             curLelve(topAddress[i],4);
              continue;
           }else if(num2>=3){
             curLelve(topAddress[i],3);
              continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }
          if(valid>=11&&valid<13){
              //有效用户是否有 3个V4 及以上
            uint256 num4=   getLvNum(topAddress[i],4);  
            uint256 num3=   getLvNum(topAddress[i],3);
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
            if(num4>=3){
            curLelve(topAddress[i],5);
             continue;
            }
            else if(num3>=3){
             curLelve(topAddress[i],4);
              continue;
           }else if(num2>=3){
             curLelve(topAddress[i],3);
              continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }
          if(valid>=13&&valid<15){
              //有效用户是否有 3个V5 及以上
            uint256 num5=   getLvNum(topAddress[i],5);  
            uint256 num4=   getLvNum(topAddress[i],4);  
            uint256 num3=   getLvNum(topAddress[i],3);
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
            if(num5>=3){
            curLelve(topAddress[i],6);
             continue;
            }
           else if(num4>=3){
            curLelve(topAddress[i],5);
             continue;
            }
            else if(num3>=3){
             curLelve(topAddress[i],4);
              continue;
           }else if(num2>=3){
             curLelve(topAddress[i],3);
              continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }
         
          if(valid>=15&&valid<20){
              //有效用户是否有 3个V6 及以上
            uint256 num6=   getLvNum(topAddress[i],6);    
            uint256 num5=   getLvNum(topAddress[i],5);  
            uint256 num4=   getLvNum(topAddress[i],4);  
            uint256 num3=   getLvNum(topAddress[i],3);
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
            if(num6>=3){
            curLelve(topAddress[i],7);
             continue;
            }
            else if(num5>=3){
            curLelve(topAddress[i],6);
             continue;
            }
           else if(num4>=3){
            curLelve(topAddress[i],5);
             continue;
            }
            else if(num3>=3){
             curLelve(topAddress[i],4);
              continue;
           }else if(num2>=3){
             curLelve(topAddress[i],3);
              continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }
          if(valid>=20){
              //有效用户是否有 3个V7 及以上
            uint256 num7=   getLvNum(topAddress[i],7);     
            uint256 num6=   getLvNum(topAddress[i],6);    
            uint256 num5=   getLvNum(topAddress[i],5);  
            uint256 num4=   getLvNum(topAddress[i],4);  
            uint256 num3=   getLvNum(topAddress[i],3);
            uint256 num2=   getLvNum(topAddress[i],2);
            uint256 num1=   getLvNum(topAddress[i],1);
            if(num7>=3){
             curLelve(topAddress[i],7);
              continue;
            }
            else  if(num6>=3){
            curLelve(topAddress[i],7);
             continue;
            }
            else if(num5>=3){
            curLelve(topAddress[i],6);
             continue;
            }
           else if(num4>=3){
            curLelve(topAddress[i],5);
             continue;
            }
            else if(num3>=3){
             curLelve(topAddress[i],4);
              continue;
           }else if(num2>=3){
             curLelve(topAddress[i],3);
              continue;
           }else if(num1>=2){
            curLelve(topAddress[i],2);
           }
         }

    }
}

    function getLvNum(address _user,uint256 lv)public view returns(uint256){
         address[] storage  valids=  validChildren[_user];
         uint number=0;
         for(uint256 i=0;i<valids.length;i++){
            UserInfo storage use=  userInfo[valids[i]];
            if(use.level>=lv){
             number+=1;
            }
         }
         return number;
    }

    function curLelve(address _user,uint256 lv) private returns(uint256){
        UserInfo storage info= userInfo[_user];
         if(info.level>lv){
            info.level=lv;
           return lv;
         }
         return  info.level;
    }

    function _sendTeamProfit(uint256 _amount) private{
    address[] storage  topAddress  = superiors[msg.sender];
    for(uint256 i=0;i<8;i++){
       address top=  topAddress[i];
       if(top==address(0)){
         break;
       }
      UserInfo storage userinfo = userInfo[top];
    
       if(userinfo.level==1){
           if(!lvFlag[0]){  //等级1奖励 5% 
            rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(_amount.mul(500).div(10000));                //团队奖励+
           }else{
            lvFlag[0]= true;
           }           
       } else if(userinfo.level==2){
             if(!lvFlag[1]){//等级2奖励 8% 
             if(lvFlag[0]){
                rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(_amount.mul(300).div(10000));                //团队奖励+
             }else{
                rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(_amount.mul(800).div(10000));
             }
             lvFlag[1] = true;
           }
       }else if(userinfo.level==3){
              if(!lvFlag[2]){//等级3奖励 10% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv3Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[2]= true;
           }
       }else if(userinfo.level==4){
             if(!lvFlag[3]){//等级4奖励 15% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){rateBase=1000;}
              if(lvFlag[3]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv4Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[3]= true;
           }
       }else if(userinfo.level==5){
            if(!lvFlag[4]){//等级5奖励 20% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){rateBase=1000;}
              if(lvFlag[3]){rateBase=1500;}
              if(lvFlag[4]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv5Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[4]= true;
           }
       }else if(userinfo.level==6){
          if(!lvFlag[5]){//等级6奖励 25% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){rateBase=1000;}
              if(lvFlag[3]){rateBase=1500;}
              if(lvFlag[4]){rateBase=2000;}
              if(lvFlag[5]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv6Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[5]= true;
       }
       }
       else if(userinfo.level==7){
            if(!lvFlag[6]){//等级7奖励 30% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){rateBase=1000;}
              if(lvFlag[3]){rateBase=1500;}
              if(lvFlag[4]){rateBase=2000;}
              if(lvFlag[5]){rateBase=2500;}
              if(lvFlag[6]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv7Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[6]= true;

           }

       }else if(userinfo.level==8){
           if(!lvFlag[7]){//等级8奖励 35% 
              uint256 rateBase=0;
              if(lvFlag[0]){rateBase=500;}
              if(lvFlag[1]){rateBase=800;}
              if(lvFlag[2]){rateBase=1000;}
              if(lvFlag[3]){rateBase=1500;}
              if(lvFlag[4]){rateBase=2000;}
              if(lvFlag[5]){rateBase=2500;}
              if(lvFlag[6]){rateBase=3000;}
              if(lvFlag[7]){
                  rewardInfos[top].teamProfit = rewardInfos[top].teamProfit.add(lv7Rate.sub(rateBase).mul(_amount).div(10000));                //团队奖励+
                  } 
               lvFlag[7]= true;
       }
       
    }   
    }           
    }

}