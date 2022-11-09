// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GNT is Ownable{
    IERC20 public usdt;
    uint256 private constant baseDivider = 10000;
    uint256 private constant freezeDay = 10 days;    //10 days default
    uint256 private constant maxFreezeDay = 40 days;    // 40 days default
    uint256 private constant timeskip = 1 days;    //1 days default
    uint256[5] private packagePrice = [50e18, 250e18, 500e18, 1000e18, 2000e18];
    uint256 private constant cyclePercent = 1500;
    uint32 private constant feePercents = 300;
    uint256 private constant referDepth = 3;

    uint256 private constant lvl1Dep = 50000e18;    //default 50000e18  
    uint256 private constant lvl2Dep = 100000e18;   //default 100000e18

    uint256 private constant lvl1Count = 25;    //default 25  
    uint256 private constant lvl2Count = 50;    //default 50

    address public feeReceivers;
    uint256 public startTime;
    uint256 public totalUser = 1;
    uint256 public totalDeposit;
    uint256 public totalDepositCount;
    uint256 public totalWithdraw;
    uint256 public totalReferWithdraw;

    address public defaultRefer;

    struct OrderInfo {
        uint256 maxpack;
        uint256 start;  //last //freeze
    }

    mapping(address => OrderInfo) public orderInfos;

    struct UserInfo {
        address referrer;
        uint256 totalDep;
        uint256 depCount;
        uint256 withdrawable;
        uint256 recWithdraw;
        uint256 refReward;
        uint256 recRefReward;
        uint256 lastDep;
        uint256 split;
        uint256 level;
        uint256 teamCount;
        uint256 teamTotalDep;
    }

    mapping(address=>UserInfo) public userInfo;
    mapping(address=>mapping(uint256 => address[])) public teamUsers;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event WithdrawRef(address user, uint256 amount);

    constructor(address _usdt, address _feeReceivers, address _defaultRefer) {
        usdt = IERC20(_usdt);   
        feeReceivers = _feeReceivers;
        startTime = block.timestamp; 
        defaultRefer = _defaultRefer;
        UserInfo storage user = userInfo[defaultRefer];
        user.referrer = feeReceivers;
    }

    //Get VIEW 
    function getData() external view returns 
        (uint256 _startTime, uint256 _totalUser, uint256 _totalDeposit, uint256 _totalDepositCount, uint256 _totalWithdraw, uint256 _totalReferWithdraw) 
    {
        return (startTime, totalUser, totalDeposit, totalDepositCount, totalWithdraw, totalReferWithdraw);
    }

    function getDownlineDep(address _account) external view returns 
        (uint256[] memory _deposit) 
    {   
        uint256[] memory dep = new uint256[](4);
        uint256 lvlDep;
        dep[0] = orderInfos[_account].maxpack;
        for(uint256 i = 0; i < referDepth; i++){
            for(uint256 j = 0; j < teamUsers[_account][i].length; j++){
                lvlDep += orderInfos[teamUsers[_account][i][j]].maxpack;
            }
            dep[i+1] = lvlDep;
            lvlDep = 0;
        }
        return dep;
    }

    //Write External
    function register(address _referral, uint256 _packageID, bool _isSplit) external {
        require(userInfo[_referral].totalDep > 0 || _referral == defaultRefer || _referral != msg.sender, "invalid refer");
        require(userInfo[defaultRefer].totalDep > 0 , "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.teamCount = 1;
        totalUser += 1;

        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            UserInfo storage user_up = userInfo[upline];
            user_up.teamCount += 1;

            teamUsers[upline][i].push(msg.sender);
            if(upline == feeReceivers) break;
            upline = userInfo[upline].referrer;
        }

        if(_isSplit == true)
            depositBySplit(_packageID);
        else
            deposit(_packageID);

        emit Register(msg.sender, _referral);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= 25e18 && (_amount % 25e18) == 0 && _amount <= 1000e18, "Amount Error");
        require(userInfo[msg.sender].split >= _amount, "Insufficient Income");
        require(userInfo[_receiver].referrer == address(0), "Activated");
        UserInfo storage user = userInfo[msg.sender];
        user.split -= _amount;
        UserInfo storage user_rec = userInfo[_receiver];
        user_rec.split += _amount;
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function depositBySplit(uint256 _packageID) private {
        require(userInfo[msg.sender].totalDep == 0, "Actived");
        require(_packageID < 5, "Invalid Package ID");
        
        UserInfo storage user = userInfo[msg.sender];
        if(userInfo[msg.sender].split > packagePrice[_packageID] / 2){
            usdt.transferFrom(msg.sender, address(this), packagePrice[_packageID] - packagePrice[_packageID] / 2);
            user.split -= packagePrice[_packageID] / 2;
        }
        else{
            usdt.transferFrom(msg.sender, address(this), packagePrice[_packageID] - user.split);
            user.split = 0;
        }
        
        UserInfo storage dev = userInfo[feeReceivers];
        dev.withdrawable += packagePrice[_packageID]* uint256(feePercents) / baseDivider;

        OrderInfo storage order = orderInfos[msg.sender];
        order.start = block.timestamp + freezeDay;
        order.maxpack = packagePrice[_packageID];

        user.totalDep += packagePrice[_packageID];
        user.depCount += 1;
        user.lastDep = block.timestamp;

        totalDepositCount += 1;
        totalDeposit += packagePrice[_packageID];
        
        user.teamTotalDep += packagePrice[_packageID];
        
        address upline = user.referrer;
        uint256 reward = (packagePrice[_packageID] * 300) / baseDivider;

        for(uint256 i = referDepth; i > 0; i--){
            UserInfo storage user_up = userInfo[upline];
            user_up.teamTotalDep += packagePrice[_packageID];
            if(user_up.teamTotalDep >= lvl1Dep && user_up.teamCount >= lvl1Count && teamUsers[upline][2].length != 0){
                user_up.level = 1;
                reward = (packagePrice[_packageID] * i * 100) / baseDivider;
            }
            if(user_up.teamTotalDep >= lvl2Dep && user_up.teamCount >= lvl2Count && teamUsers[upline][2].length != 0){
                user_up.level = 2;
                reward = (packagePrice[_packageID] * (i+1) * 100) / baseDivider;
            }
            
            user_up.refReward += reward;
            reward = 0;
            if(upline == defaultRefer) break;
            upline = userInfo[upline].referrer;
        }

        emit DepositBySplit(msg.sender, packagePrice[_packageID]);
    }

    function deposit(uint256 _packageID) public {
        UserInfo storage user = userInfo[msg.sender];
        require(orderInfos[msg.sender].start < block.timestamp, "Package Order Freeze");
        require(user.referrer != address(0), "register first");
        require(_packageID < 5, "Invalid Package ID");
        require(packagePrice[_packageID] >= orderInfos[msg.sender].maxpack, "Unable downgrade package");
        
        usdt.transferFrom(msg.sender, address(this), packagePrice[_packageID]);

        UserInfo storage dev = userInfo[feeReceivers];
        dev.withdrawable += packagePrice[_packageID]* uint256(feePercents) / baseDivider;

        OrderInfo storage order = orderInfos[msg.sender];
        uint256 teamDep = packagePrice[_packageID];
        if(order.start != 0){
            user.withdrawable += order.maxpack + ((order.maxpack * cyclePercent * 7000) / (baseDivider*baseDivider));
            user.split += (order.maxpack * cyclePercent * 3000) / (baseDivider*baseDivider);
            teamDep = 0;
        }
        
        uint256 dayFreeze = freezeDay + (user.depCount / 2) * timeskip;
        if(dayFreeze > maxFreezeDay)
            dayFreeze = maxFreezeDay;

        order.start = block.timestamp + dayFreeze;
        if(order.maxpack < packagePrice[_packageID]){
            teamDep = packagePrice[_packageID] - order.maxpack;
            order.maxpack = packagePrice[_packageID];
        }

        user.totalDep += packagePrice[_packageID];
        user.depCount += 1;
        user.lastDep = block.timestamp;

        totalDepositCount += 1;
        totalDeposit += packagePrice[_packageID];

        user.teamTotalDep += teamDep;
        
        address upline = user.referrer;
        uint256 reward = (packagePrice[_packageID] * 300) / baseDivider;

        for(uint256 i = referDepth; i > 0; i--){
            UserInfo storage user_up = userInfo[upline];
            user_up.teamTotalDep += teamDep;
            if(user_up.teamTotalDep >= lvl1Dep && user_up.teamCount >= lvl1Count && teamUsers[upline][2].length != 0){
                user_up.level = 1;
                reward = (packagePrice[_packageID] * i * 100) / baseDivider;
            }
            if(user_up.teamTotalDep >= lvl2Dep && user_up.teamCount >= lvl2Count && teamUsers[upline][2].length != 0){
                user_up.level = 2;
                reward = (packagePrice[_packageID] * (i+1) * 100) / baseDivider;
            }

            user_up.refReward += reward;
            reward = 0;
            
            if(upline == defaultRefer) break;
            upline = userInfo[upline].referrer;
        }

        emit Deposit(msg.sender, packagePrice[_packageID]);
    }

    function withdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 cbalance = usdt.balanceOf(address(this));
        uint256 total_wd = user.withdrawable + user.refReward;

        if(cbalance <= total_wd){
            total_wd = cbalance;
            if(user.withdrawable <= cbalance){
                totalWithdraw += user.withdrawable;
                user.recWithdraw -= user.withdrawable;
                cbalance -= user.withdrawable;
                user.withdrawable = 0;
                
                user.refReward -= cbalance;
                user.recRefReward += cbalance;
                totalReferWithdraw += cbalance;
            }else{
                user.withdrawable -= cbalance;
                user.recWithdraw += cbalance;
                totalWithdraw += cbalance;
            }
        }else{
            user.recWithdraw += user.withdrawable;
            totalWithdraw += user.withdrawable;
            user.withdrawable = 0;

            user.recRefReward += user.refReward;
            totalReferWithdraw += user.refReward;
            user.refReward = 0;
        }   

        usdt.transfer(msg.sender, total_wd);
        emit Withdraw(msg.sender, total_wd);      
    }

    function withdrawRef() external {
        uint256 cbalance = usdt.balanceOf(address(this));
        UserInfo storage user = userInfo[msg.sender];

        uint256 wdAmount = user.refReward;
        
        if(cbalance <= user.refReward){
            wdAmount = cbalance;
        }

        user.refReward -= wdAmount;
        user.recRefReward += wdAmount;
        totalReferWithdraw += wdAmount;
        usdt.transfer(msg.sender, wdAmount);
        emit WithdrawRef(msg.sender, wdAmount);
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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