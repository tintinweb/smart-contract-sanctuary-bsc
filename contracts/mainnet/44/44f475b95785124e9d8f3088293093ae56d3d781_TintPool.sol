/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.1;


/**
 * Welcome To TinyTesla Family
 * DEV Shakil Hossain
 * @dev Collection of functions related to the address type
 */


library Address {

    function isContract(address account) internal view returns (bool) {
     

        return account.code.length > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

   
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

  
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

 
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

   
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

   
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
              
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



interface IERC20 {
  
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

  
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

  
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

  
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
       
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
      
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }

function _onlyOwner() private view {
require(owner() == _msgSender(), "Ownable: caller is not the owner");
}
   
    modifier onlyOwner() {
           _onlyOwner();
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


abstract contract Pausable is Context {
  
    event Paused(address account);

   
    event Unpaused(address account);

    bool private _paused;

   
    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

   
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

  
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

  
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IMasterChefV2 {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingTint(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

interface IBoostContract {
    function onTintPoolUpdate(
        address _user,
        uint256 _lockedAmount,
        uint256 _lockedDuration,
        uint256 _totalLockedAmount,
        uint256 _maxLockDuration
    ) external;
}

interface IVTint {
    function deposit(
        address _user,
        uint256 _amount,
        uint256 _lockDuration
    ) external;

    function withdraw(address _user) external;
}

contract TintPool is Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 tintAtLastUserAction; // keep track of tint deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    IERC20 public immutable token; // tint token.

    IMasterChefV2 public immutable masterchefV2;

    address public boostContract; // boost contract used in Masterchef.
    address public VTint;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public freePerformanceFeeUsers; // free performance fee users.
    mapping(address => bool) public freeWithdrawFeeUsers; // free withdraw fee users.
    mapping(address => bool) public freeOverdueFeeUsers; // free overdue fee users.

    uint256 public totalShares;
    address public admin;
    address public treasury;
    address public operator;
    uint256 public tintPoolPID;
    uint256 public totalBoostDebt; // total boost debt.
    uint256 public totalLockedAmount; // total lock amount.

    uint256 public constant MAX_PERFORMANCE_FEE = 2000; // 20%
    uint256 public constant MAX_WITHDRAW_FEE = 500; // 5%
    uint256 public constant MAX_OVERDUE_FEE = 100 * 1e10; // 100%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 1 weeks; // 1 week
    uint256 public constant MIN_LOCK_DURATION = 1 weeks; // 1 week
    uint256 public constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days
    uint256 public constant BOOST_WEIGHT_LIMIT = 5000 * 1e10; // 5000%
    uint256 public constant PRECISION_FACTOR = 1e12; // precision factor.
    uint256 public constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;
    uint256 public constant MIN_WITHDRAW_AMOUNT = 0.00001 ether;
    uint256 public UNLOCK_FREE_DURATION = 1 weeks; // 1 week
    uint256 public MAX_LOCK_DURATION = 365 days; // 365 days
    uint256 public DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
    uint256 public DURATION_FACTOR_OVERDUE = 180 days; // 180 days, in order to calculate overdue fee.
    uint256 public BOOST_WEIGHT = 100 * 1e10; // 100%

    uint256 public performanceFee = 200; // 2%
    uint256 public performanceFeeContract = 200; // 2%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeeContract = 10; // 0.1%
    uint256 public overdueFee = 100 * 1e10; // 100%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event Deposit(address indexed sender, uint256 amount, uint256 shares, uint256 duration, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(address indexed sender, uint256 amount);
    event Pause();
    event Unpause();
    event Init();
    event Lock(
        address indexed sender,
        uint256 lockedAmount,
        uint256 shares,
        uint256 lockedDuration,
        uint256 blockTimestamp
    );
    event Unlock(address indexed sender, uint256 amount, uint256 blockTimestamp);
    event NewAdmin(address admin);
    event NewTreasury(address treasury);
    event NewOperator(address operator);
    event NewBoostContract(address boostContract);
    event NewVTintContract(address VTint);
    event FreeFeeUser(address indexed user, bool indexed free);
    event NewPerformanceFee(uint256 performanceFee);
    event NewPerformanceFeeContract(uint256 performanceFeeContract);
    event NewWithdrawFee(uint256 withdrawFee);
    event NewOverdueFee(uint256 overdueFee);
    event NewWithdrawFeeContract(uint256 withdrawFeeContract);
    event NewWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event NewMaxLockDuration(uint256 maxLockDuration);
    event NewDurationFactor(uint256 durationFactor);
    event NewDurationFactorOverdue(uint256 durationFactorOverdue);
    event NewUnlockFreeDuration(uint256 unlockFreeDuration);
    event NewBoostWeight(uint256 boostWeight);

  
    constructor(
        IERC20 _token,
        IMasterChefV2 _masterchefV2,
        address _admin,
        address _treasury,
        address _operator,
        uint256 _pid
    ) {
        token = _token;
        masterchefV2 = _masterchefV2;
        admin = _admin;
        treasury = _treasury;
        operator = _operator;
        tintPoolPID = _pid;
    }

    function init(IERC20 dummyToken) external onlyOwner {
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(address(masterchefV2), balance);
        masterchefV2.deposit(tintPoolPID, balance);
        emit Init();
    }

    /**
     * @notice Checks if the msg.sender is the admin address.
     */
     function _onlyAdmin() private view{
            require(msg.sender == admin, "admin: wut?");
     }
    modifier onlyAdmin() {
        _onlyAdmin();
     
        _;
    }

   
    modifier onlyOperatorOrTintOwner(address _user) {
        require(msg.sender == _user || msg.sender == operator, "Not operator or tint owner");
        _;
    }

    function updateBoostContractInfo(address _user) internal {
        if (boostContract != address(0)) {
            UserInfo storage user = userInfo[_user];
            uint256 lockDuration = user.lockEndTime - user.lockStartTime;
            IBoostContract(boostContract).onTintPoolUpdate(
                _user,
                user.lockedAmount,
                lockDuration,
                totalLockedAmount,
                DURATION_FACTOR
            );
        }
    }


    function updateUserShare(address _user) internal {
        UserInfo storage user = userInfo[_user];
        if (user.shares > 0) {
            if (user.locked) {
                uint256 currentAmount = (balanceOf() * (user.shares)) / totalShares - user.userBoostedShare;
                totalBoostDebt -= user.userBoostedShare;
                user.userBoostedShare = 0;
                totalShares -= user.shares;
                if (!freeOverdueFeeUsers[_user] && ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)) {
                    uint256 earnAmount = currentAmount - user.lockedAmount;
                    uint256 overdueDuration = block.timestamp - user.lockEndTime - UNLOCK_FREE_DURATION;
                    if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                        overdueDuration = DURATION_FACTOR_OVERDUE;
                    }
                    uint256 overdueWeight = (overdueDuration * overdueFee) / DURATION_FACTOR_OVERDUE;
                    uint256 currentOverdueFee = (earnAmount * overdueWeight) / PRECISION_FACTOR;
                    token.safeTransfer(treasury, currentOverdueFee);
                    currentAmount -= currentOverdueFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOf();
                uint256 currentShares;
                if (totalShares != 0) {
                    currentShares = (currentAmount * totalShares) / (pool - currentAmount);
                } else {
                    currentShares = currentAmount;
                }
                user.shares = currentShares;
                totalShares += currentShares;
                if (user.lockEndTime < block.timestamp) {
                    user.locked = false;
                    user.lockStartTime = 0;
                    user.lockEndTime = 0;
                    totalLockedAmount -= user.lockedAmount;
                    user.lockedAmount = 0;
                    emit Unlock(_user, currentAmount, block.timestamp);
                }
            } else if (!freePerformanceFeeUsers[_user]) {
                uint256 totalAmount = (user.shares * balanceOf()) / totalShares;
                totalShares -= user.shares;
                user.shares = 0;
                uint256 earnAmount = totalAmount - user.tintAtLastUserAction;
                uint256 feeRate = performanceFee;
                if (_isContract(_user)) {
                    feeRate = performanceFeeContract;
                }
                uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
                if (currentPerformanceFee > 0) {
                    token.safeTransfer(treasury, currentPerformanceFee);
                    totalAmount -= currentPerformanceFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOf();
                uint256 newShares;
                if (totalShares != 0) {
                    newShares = (totalAmount * totalShares) / (pool - totalAmount);
                } else {
                    newShares = totalAmount;
                }
                user.shares = newShares;
                totalShares += newShares;
            }
        }
    }    
    function unlock(address _user) external onlyOperatorOrTintOwner(_user) whenNotPaused {
        UserInfo storage user = userInfo[_user];
        require(user.locked && user.lockEndTime < block.timestamp, "Cannot unlock yet");
        depositOperation(0, 0, _user);
    }

    function deposit(uint256 _amount, uint256 _lockDuration) external whenNotPaused {
        require(_amount > 0 || _lockDuration > 0, "Nothing to deposit");
        depositOperation(_amount, _lockDuration, msg.sender);
    }

    function depositOperation(
        uint256 _amount,
        uint256 _lockDuration,
        address _user
    ) internal {
        UserInfo storage user = userInfo[_user];
        if (user.shares == 0 || _amount > 0) {
            require(_amount > MIN_DEPOSIT_AMOUNT, "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT");
        }
        uint256 totalLockDuration = _lockDuration;
        if (user.lockEndTime >= block.timestamp) {
            if (_amount > 0) {
                user.lockStartTime = block.timestamp;
                totalLockedAmount -= user.lockedAmount;
                user.lockedAmount = 0;
            }
            totalLockDuration += user.lockEndTime - user.lockStartTime;
        }
        require(_lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION, "Minimum lock period is one week");
        require(totalLockDuration <= MAX_LOCK_DURATION, "Maximum lock period exceeded");

        if (VTint != address(0)) {
            IVTint(VTint).deposit(_user, _amount, _lockDuration);
        }
        harvest();
        if (totalShares == 0) {
            uint256 stockAmount = available();
            token.safeTransfer(treasury, stockAmount);
        }

        updateUserShare(_user);
        if (_lockDuration > 0) {
            if (user.lockEndTime < block.timestamp) {
                user.lockStartTime = block.timestamp;
                user.lockEndTime = block.timestamp + _lockDuration;
            } else {
                user.lockEndTime += _lockDuration;
            }
            user.locked = true;
        }

        uint256 currentShares;
        uint256 currentAmount;
        uint256 userCurrentLockedBalance;
        uint256 pool = balanceOf();
        if (_amount > 0) {
            token.safeTransferFrom(_user, address(this), _amount);
            currentAmount = _amount;
        }

        // Calculate lock funds
        if (user.shares > 0 && user.locked) {
            userCurrentLockedBalance = (pool * user.shares) / totalShares;
            currentAmount += userCurrentLockedBalance;
            totalShares -= user.shares;
            user.shares = 0;

            // Update lock amount
            if (user.lockStartTime == block.timestamp) {
                user.lockedAmount = userCurrentLockedBalance;
                totalLockedAmount += user.lockedAmount;
            }
        }
        if (totalShares != 0) {
            currentShares = (currentAmount * totalShares) / (pool - userCurrentLockedBalance);
        } else {
            currentShares = currentAmount;
        }

        // Calculate the boost weight share.
        if (user.lockEndTime > user.lockStartTime) {
            // Calculate boost share.
            uint256 boostWeight = ((user.lockEndTime - user.lockStartTime) * BOOST_WEIGHT) / DURATION_FACTOR;
            uint256 boostShares = (boostWeight * currentShares) / PRECISION_FACTOR;
            currentShares += boostShares;
            user.shares += currentShares;

            // Calculate boost share , the user only enjoys the reward, so the principal needs to be recorded as a debt.
            uint256 userBoostedShare = (boostWeight * currentAmount) / PRECISION_FACTOR;
            user.userBoostedShare += userBoostedShare;
            totalBoostDebt += userBoostedShare;

            // Update lock amount.
            user.lockedAmount += _amount;
            totalLockedAmount += _amount;

            emit Lock(_user, user.lockedAmount, user.shares, (user.lockEndTime - user.lockStartTime), block.timestamp);
        } else {
            user.shares += currentShares;
        }

        if (_amount > 0 || _lockDuration > 0) {
            user.lastDepositedTime = block.timestamp;
        }
        totalShares += currentShares;

        user.tintAtLastUserAction = (user.shares * balanceOf()) / totalShares - user.userBoostedShare;
        user.lastUserActionTime = block.timestamp;

        // Update user info in Boost Contract.
        updateBoostContractInfo(_user);

        emit Deposit(_user, _amount, currentShares, _lockDuration, block.timestamp);
    }

    function withdrawByAmount(uint256 _amount) public whenNotPaused {
        require(_amount > MIN_WITHDRAW_AMOUNT, "Withdraw amount must be greater than MIN_WITHDRAW_AMOUNT");
        withdrawOperation(0, _amount);
    }

   
    function withdraw(uint256 _shares) public whenNotPaused {
        require(_shares > 0, "Nothing to withdraw");
        withdrawOperation(_shares, 0);
    }

  
    function withdrawOperation(uint256 _shares, uint256 _amount) internal {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares <= user.shares, "Withdraw amount exceeds balance");
        require(user.lockEndTime < block.timestamp, "Still in lock");

        if (VTint != address(0)) {
            IVTint(VTint).withdraw(msg.sender);
        }
        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) / user.shares;

        // Harvest token from MasterchefV2.
        harvest();

        // Update user share.
        updateUserShare(msg.sender);

        if (_shares == 0 && _amount > 0) {
            uint256 pool = balanceOf();
            currentShare = (_amount * totalShares) / pool; // Calculate equivalent shares
            if (currentShare > user.shares) {
                currentShare = user.shares;
            }
        } else {
            currentShare = (sharesPercent * user.shares) / PRECISION_FACTOR_SHARE;
        }
        uint256 currentAmount = (balanceOf() * currentShare) / totalShares;
        user.shares -= currentShare;
        totalShares -= currentShare;

        // Calculate withdraw fee
        if (!freeWithdrawFeeUsers[msg.sender] && (block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
            uint256 feeRate = withdrawFee;
            if (_isContract(msg.sender)) {
                feeRate = withdrawFeeContract;
            }
            uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
            token.safeTransfer(treasury, currentWithdrawFee);
            currentAmount -= currentWithdrawFee;
        }

        token.safeTransfer(msg.sender, currentAmount);

        if (user.shares > 0) {
            user.tintAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        } else {
            user.tintAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

      
        updateBoostContractInfo(msg.sender);

        emit Withdraw(msg.sender, currentAmount, currentShare);
    }

  
    function withdrawAll() external {
        withdraw(userInfo[msg.sender].shares);
    }

   
    function harvest() internal {
        uint256 pendingTint = masterchefV2.pendingTint(tintPoolPID, address(this));
        if (pendingTint > 0) {
            uint256 balBefore = available();
            masterchefV2.withdraw(tintPoolPID, 0);
            uint256 balAfter = available();
            emit Harvest(msg.sender, (balAfter - balBefore));
        }
    }

 
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Cannot be zero address");
        admin = _admin;
        emit NewAdmin(admin);
    }


    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
        emit NewTreasury(treasury);
    }

   
    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Cannot be zero address");
        operator = _operator;
        emit NewOperator(operator);
    }

   
    function setBoostContract(address _boostContract) external onlyAdmin {
        require(_boostContract != address(0), "Cannot be zero address");
        boostContract = _boostContract;
        emit NewBoostContract(boostContract);
    }

    function setVTintContract(address _VTint) external onlyAdmin {
        require(_VTint != address(0), "Cannot be zero address");
        VTint = _VTint;
        emit NewVTintContract(VTint);
    }

    function setFreePerformanceFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freePerformanceFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }

  
    function setOverdueFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freeOverdueFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }


    function setWithdrawFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freeWithdrawFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }


    function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
        emit NewPerformanceFee(performanceFee);
    }

  
    function setPerformanceFeeContract(uint256 _performanceFeeContract) external onlyAdmin {
        require(
            _performanceFeeContract <= MAX_PERFORMANCE_FEE,
            "performanceFee cannot be more than MAX_PERFORMANCE_FEE"
        );
        performanceFeeContract = _performanceFeeContract;
        emit NewPerformanceFeeContract(performanceFeeContract);
    }

    function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
        emit NewWithdrawFee(withdrawFee);
    }

    function setOverdueFee(uint256 _overdueFee) external onlyAdmin {
        require(_overdueFee <= MAX_OVERDUE_FEE, "overdueFee cannot be more than MAX_OVERDUE_FEE");
        overdueFee = _overdueFee;
        emit NewOverdueFee(_overdueFee);
    }

    function setWithdrawFeeContract(uint256 _withdrawFeeContract) external onlyAdmin {
        require(_withdrawFeeContract <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFeeContract = _withdrawFeeContract;
        emit NewWithdrawFeeContract(withdrawFeeContract);
    }

    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyAdmin {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
        emit NewWithdrawFeePeriod(withdrawFeePeriod);
    }

    function setMaxLockDuration(uint256 _maxLockDuration) external onlyAdmin {
        require(
            _maxLockDuration <= MAX_LOCK_DURATION_LIMIT,
            "MAX_LOCK_DURATION cannot be more than MAX_LOCK_DURATION_LIMIT"
        );
        MAX_LOCK_DURATION = _maxLockDuration;
        emit NewMaxLockDuration(_maxLockDuration);
    }

    function setDurationFactor(uint256 _durationFactor) external onlyAdmin {
        require(_durationFactor > 0, "DURATION_FACTOR cannot be zero");
        DURATION_FACTOR = _durationFactor;
        emit NewDurationFactor(_durationFactor);
    }

  
    function setDurationFactorOverdue(uint256 _durationFactorOverdue) external onlyAdmin {
        require(_durationFactorOverdue > 0, "DURATION_FACTOR_OVERDUE cannot be zero");
        DURATION_FACTOR_OVERDUE = _durationFactorOverdue;
        emit NewDurationFactorOverdue(_durationFactorOverdue);
    }

    function setUnlockFreeDuration(uint256 _unlockFreeDuration) external onlyAdmin {
        require(_unlockFreeDuration > 0, "UNLOCK_FREE_DURATION cannot be zero");
        UNLOCK_FREE_DURATION = _unlockFreeDuration;
        emit NewUnlockFreeDuration(_unlockFreeDuration);
    }

    function setBoostWeight(uint256 _boostWeight) external onlyAdmin {
        require(_boostWeight <= BOOST_WEIGHT_LIMIT, "BOOST_WEIGHT cannot be more than BOOST_WEIGHT_LIMIT");
        BOOST_WEIGHT = _boostWeight;
        emit NewBoostWeight(_boostWeight);
    }

  
    function inCaseTokensGetStuck(address _token) external onlyAdmin {
        require(_token != address(token), "Token cannot be same as deposit token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    
    function pause() external onlyAdmin whenNotPaused {
        _pause();
        emit Pause();
    }

    function unpause() external onlyAdmin whenPaused {
        _unpause();
        emit Unpause();
    }

  
    function calculatePerformanceFee(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (user.shares > 0 && !user.locked && !freePerformanceFeeUsers[_user]) {
            uint256 pool = balanceOf() + calculateTotalPendingTintRewards();
            uint256 totalAmount = (user.shares * pool) / totalShares;
            uint256 earnAmount = totalAmount - user.tintAtLastUserAction;
            uint256 feeRate = performanceFee;
            if (_isContract(_user)) {
                feeRate = performanceFeeContract;
            }
            uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
            return currentPerformanceFee;
        }
        return 0;
    }
    function calculateOverdueFee(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (
            user.shares > 0 &&
            user.locked &&
            !freeOverdueFeeUsers[_user] &&
            ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)
        ) {
            uint256 pool = balanceOf() + calculateTotalPendingTintRewards();
            uint256 currentAmount = (pool * (user.shares)) / totalShares - user.userBoostedShare;
            uint256 earnAmount = currentAmount - user.lockedAmount;
            uint256 overdueDuration = block.timestamp - user.lockEndTime - UNLOCK_FREE_DURATION;
            if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                overdueDuration = DURATION_FACTOR_OVERDUE;
            }
       
            uint256 overdueWeight = (overdueDuration * overdueFee) / DURATION_FACTOR_OVERDUE;
            uint256 currentOverdueFee = (earnAmount * overdueWeight) / PRECISION_FACTOR;
            return currentOverdueFee;
        }
        return 0;
    }

    function calculatePerformanceFeeOrOverdueFee(address _user) internal view returns (uint256) {
        return calculatePerformanceFee(_user) + calculateOverdueFee(_user);
    }

  
    function calculateWithdrawFee(address _user, uint256 _shares) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (user.shares < _shares) {
            _shares = user.shares;
        }
        if (!freeWithdrawFeeUsers[msg.sender] && (block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
            uint256 pool = balanceOf() + calculateTotalPendingTintRewards();
            uint256 sharesPercent = (_shares * PRECISION_FACTOR) / user.shares;
            uint256 currentTotalAmount = (pool * (user.shares)) /
                totalShares -
                user.userBoostedShare -
                calculatePerformanceFeeOrOverdueFee(_user);
            uint256 currentAmount = (currentTotalAmount * sharesPercent) / PRECISION_FACTOR;
            uint256 feeRate = withdrawFee;
            if (_isContract(msg.sender)) {
                feeRate = withdrawFeeContract;
            }
            uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
            return currentWithdrawFee;
        }
        return 0;
    }

    
    function calculateTotalPendingTintRewards() public view returns (uint256) {
        uint256 amount = masterchefV2.pendingTint(tintPoolPID, address(this));
        return amount;
    }

    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : (((balanceOf() + calculateTotalPendingTintRewards()) * (1e18)) / totalShares);
    }

  
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function balanceOf() public view returns (uint256) {
        return token.balanceOf(address(this)) + totalBoostDebt;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}