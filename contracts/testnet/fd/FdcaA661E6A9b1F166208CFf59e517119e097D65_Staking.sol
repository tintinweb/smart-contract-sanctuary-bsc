// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

interface ICakeToken {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

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
                // The easiest way to bubble the revert reason is using memory via assembly

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

library SafeERC20 {
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: BEP20 operation did not succeed");
        }
    }
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ICakePool {

    function deposit( uint256 _amount, uint256 _lockDuration ) external;
    function withdraw(uint256 _shares) external;
    function withdrawByAmount(uint256 _amount) external;

    function freeFeeUsers(address) external returns(bool);
    function totalShares() external returns(uint256);
    function lastHarvestedTime() external returns(uint256);
    function cakePoolPID() external returns(uint256);
    function totalBoostDebt() external returns(uint256);
    function totalLockedAmount() external returns(uint256);

}

contract Staking {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public Owner;
    uint devFee = 2;

    ICakeToken public CakeToken;
    address CakeTokenAddress;
    IERC20 public mycoinToken;
    address mycoinTokenAddress;
    address public cakePoolAddress;
    ICakePool public cakePool;
    IPancakeRouter public pancakeRouter;
    address pancakeRouterAddress;

    uint256 constant MAX_PERFORMANCE_FEE = 2000; // 20%
    uint256 constant MAX_CALL_FEE = 100; // 1%
    uint256 constant MAX_WITHDRAW_FEE = 500; // 5%
    uint256 constant MAX_WITHDRAW_FEE_PERIOD = 1 weeks; // 1 week
    uint256 constant MIN_LOCK_DURATION = 1 weeks; // 1 week
    uint256 constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days
    uint256 constant BOOST_WEIGHT_LIMIT = 500 * 1e10; // 500%
    uint256 constant PRECISION_FACTOR = 1e12; // precision factor.
    uint256 constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
    uint256 constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;
    uint256 constant MIN_WITHDRAW_AMOUNT = 0.00001 ether;
    uint256 UNLOCK_FREE_DURATION = 1 weeks; // 1 week
    uint256 MAX_LOCK_DURATION = 365 days; // 365 days
    uint256 DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
    uint256 DURATION_FACTOR_OVERDUE = 180 days; // 180 days, in order to calculate overdue fee.
    uint256 BOOST_WEIGHT = 100 * 1e10; // 100%

    uint256 performanceFee = 200; // 2%
    uint256 performanceFeeContract = 200; // 2%
    uint256 withdrawFee = 10; // 0.1%
    uint256 withdrawFeeContract = 10; // 0.1%
    uint256 overdueFee = 100 * 1e10; // 100%
    uint256 withdrawFeePeriod = 72 hours; // 3 days

    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    mapping(address => UserInfo) public userInfo;
    
    event _stake ( address account, uint cakeAmount, uint256 shares );
    event _Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event _Unlock(address indexed sender, uint256 amount, uint256 blockTimestamp);
    event _unStake ( address account, uint CakeAmount, uint MBCtoken  );

    constructor (
        address _cakeToken,
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
      ){
        Owner = msg.sender;
        CakeToken = ICakeToken(_cakeToken);
        CakeTokenAddress = _cakeToken;
        mycoinToken = IERC20(_mycoinToken);
        mycoinTokenAddress = _mycoinToken;
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeRouterAddress = _pancakeRouter;
    }

    modifier onlyOwner {
        require( msg.sender == Owner , "Not Owner");
        _;
    }

    function updateAddress(
        address _cakeToken,
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
        ) external onlyOwner {
        CakeToken = ICakeToken(_cakeToken);
        CakeTokenAddress = _cakeToken;
        mycoinToken = IERC20(_mycoinToken);
        mycoinTokenAddress = _mycoinToken;
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeRouterAddress = _pancakeRouter;
    }

    function swapTokens(address _account, uint _cakeAmount) internal {

        address[] memory path;
        path = new address[](2);
        path[0] = CakeTokenAddress;
        path[1] = mycoinTokenAddress;
        uint amountOfTokens = getAmountOutMin(_cakeAmount, path);

        CakeToken.approve(pancakeRouterAddress, _cakeAmount);
        pancakeRouter.swapExactTokensForTokens(
            _cakeAmount,
            amountOfTokens,
            path,
            _account,
            block.timestamp.mul(2)
        );

    }

    function getAmountOutMin( uint _amountIn, address[] memory _path ) internal view returns (uint) {
        uint[] memory amountOutMins = pancakeRouter.getAmountsOut(_amountIn, _path);
        return amountOutMins[_path.length - 1];
    }

    mapping (address => uint) userAmount;

    /**
     * @notice Deposit funds into the Cake Pool.
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in CAKE)
     */
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Nothing to deposit");

        userAmount[msg.sender] = userAmount[msg.sender].add(_amount);

        CakeToken.transferFrom( msg.sender, address(this), _amount );
        CakeToken.approve(cakePoolAddress, _amount);
        cakePool.deposit( _amount, 0 );

        depositOperation(_amount, 0, msg.sender);
    }

    /**
     * @notice The operation of deposite.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration
     * @param _user: User address
     */
    function depositOperation(
        uint256 _amount,
        uint256 _lockDuration,
        address _user
    ) internal {

        UserInfo storage user = userInfo[_user];
        uint totalLockedAmount = _totalLockedAmount();
        uint totalShares = _totalShares();

        if (user.shares == 0 || _amount > 0) {
            require(_amount > MIN_DEPOSIT_AMOUNT, "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT");
        }
        // Calculate the total lock duration and check whether the lock duration meets the conditions.
        uint256 totalLockDuration = _lockDuration;
        if (user.lockEndTime >= block.timestamp) {
            // Adding funds during the lock duration is equivalent to re-locking the position, needs to update some variables.
            if (_amount > 0) {
                user.lockStartTime = block.timestamp;
                totalLockedAmount -= user.lockedAmount;
                user.lockedAmount = 0;
            }
            totalLockDuration += user.lockEndTime - user.lockStartTime;
        }
        require(_lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION, "Minimum lock period is one week");
        require(totalLockDuration <= MAX_LOCK_DURATION, "Maximum lock period exceeded");

        // Update user share.
        updateUserShare(_user);

        // Update lock duration.
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
        uint256 pool = balanceOfPool();
        if (_amount > 0) {
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

            uint totalBoostDebt = _totalBoostDebt();

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

        } else {
            user.shares += currentShares;
        }

        if (_amount > 0 || _lockDuration > 0) {
            user.lastDepositedTime = block.timestamp;
        }
        totalShares += currentShares;

        user.cakeAtLastUserAction = (user.shares * balanceOfPool()) / totalShares - user.userBoostedShare;
        user.lastUserActionTime = block.timestamp;

    }

    /**
     * @notice Update user share When need to unlock or charges a fee.
     * @param _user: User address
     */
    function updateUserShare(address _user) internal {
        UserInfo storage user = userInfo[_user];
        if (user.shares > 0) {
            if (user.locked) {
                uint totalShares = _totalShares();
                uint totalBoostDebt = _totalBoostDebt();
                // Calculate the user's current token amount and update related parameters.
                uint256 currentAmount = (balanceOfPool() * (user.shares)) / totalShares - user.userBoostedShare;
                totalBoostDebt -= user.userBoostedShare;
                user.userBoostedShare = 0;
                totalShares -= user.shares;
                //Charge a overdue fee after the free duration has expired.
                if (!_freeFeeUsers(_user) && ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)) {
                    uint256 earnAmount = currentAmount - user.lockedAmount;
                    uint256 overdueDuration = block.timestamp - user.lockEndTime - UNLOCK_FREE_DURATION;
                    if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                        overdueDuration = DURATION_FACTOR_OVERDUE;
                    }
                    // Rates are calculated based on the user's overdue duration.
                    uint256 overdueWeight = (overdueDuration * overdueFee) / DURATION_FACTOR_OVERDUE;
                    uint256 currentOverdueFee = (earnAmount * overdueWeight) / PRECISION_FACTOR;
                    currentAmount -= currentOverdueFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOfPool();
                uint256 currentShares;
                if (totalShares != 0) {
                    currentShares = (currentAmount * totalShares) / (pool - currentAmount);
                } else {
                    currentShares = currentAmount;
                }
                user.shares = currentShares;
                totalShares += currentShares;
                // After the lock duration, update related parameters.
                if (user.lockEndTime < block.timestamp) {
                    uint totalLockedAmount = _totalLockedAmount();
                    user.locked = false;
                    user.lockStartTime = 0;
                    user.lockEndTime = 0;
                    totalLockedAmount -= user.lockedAmount;
                    user.lockedAmount = 0;
                }
            } else if (!_freeFeeUsers(_user)) {
                uint totalShares = _totalShares();
                // Calculate Performance fee.
                uint256 totalAmount = (user.shares * balanceOfPool()) / totalShares;
                totalShares -= user.shares;
                user.shares = 0;
                uint256 earnAmount = totalAmount - user.cakeAtLastUserAction;
                uint256 feeRate = performanceFee;
                uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
                if (currentPerformanceFee > 0) {
                    totalAmount -= currentPerformanceFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOfPool();
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

    /**
     * @notice Withdraw funds from the Cake Pool.
     */
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Nothing to withdraw");

        uint _totalAmount = userAmount[msg.sender];
        uint _totalshares = userInfo[msg.sender].shares;

        require(_totalAmount > 0, "Nothing to withdraw");

        _totalAmount = _totalAmount.mul(1e18);
        _totalshares = _totalshares.mul(1e18);
        uint _userAmount = _amount.mul(1e18);

        uint _sharesPre = _userAmount.mul(100).div(_totalAmount);
        uint _shares = _totalshares.mul(_sharesPre).div(100);

        _shares = _shares.div(1e18);

        userAmount[msg.sender] = userAmount[msg.sender].sub(_amount);

        cakePool.withdraw(_shares);
        transferCake(msg.sender, _amount);

        withdrawOperation(_shares, 0);
    }

    /**
     * @notice Withdraw all funds for a user
     */
    function withdrawAll() external {

        uint _totalAmount = userAmount[msg.sender];
        require(_totalAmount > 0, "Nothing to withdraw");

        uint _shares = userInfo[msg.sender].shares;
        userAmount[msg.sender] = 0;

        cakePool.withdraw(_shares);
        transferCake(msg.sender, _totalAmount);

        withdrawOperation(_shares, 0);

    }

    function transferCake(address _user, uint _amount) internal {

        uint256 _balance = CakeToken.balanceOf( address(this) );
        uint256 _UserBalance;
        uint256 _OwnerFee;
        uint256 _swapTokens;

        if ((_balance + 10000) > _amount) {

            _swapTokens = _balance.sub(_amount);
            _OwnerFee = _balance.mul(devFee).div(10000);
            _UserBalance = _amount.add((_swapTokens.sub(_OwnerFee)).div(2));
            _swapTokens = (_swapTokens.sub(_OwnerFee)).div(2);

            if ( _UserBalance > 0 ) {
                CakeToken.transfer( _user, _UserBalance );
            }
            if ( _OwnerFee > 0 ) {
                CakeToken.transfer( Owner, _OwnerFee );
            }
            if ( _swapTokens > 0 ) {
                swapTokens( _user, _swapTokens );
            }

            emit _unStake ( _user, _UserBalance, _swapTokens );
            
        } else {

            CakeToken.transfer( msg.sender, _balance );
            emit _unStake ( _user, _balance, 0 );
            
        }

    }

    /**
     * @notice The operation of withdraw.
     * @param _shares: Number of shares to withdraw
     * @param _amount: Number of amount to withdraw
     */
    function withdrawOperation(uint256 _shares, uint256 _amount) internal {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares <= user.shares, "Withdraw amount exceeds balance");
        require(user.lockEndTime < block.timestamp, "Still in lock");

        // Calculate the percent of withdraw shares, when unlocking or calculating the Performance fee, the shares will be updated.
        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) / user.shares;

        // Update user share.
        updateUserShare(msg.sender);

        uint totalShares = _totalShares();

        if (_shares == 0 && _amount > 0) {
            uint256 pool = balanceOfPool();
            currentShare = (_amount * totalShares) / pool; // Calculate equivalent shares
            if (currentShare > user.shares) {
                currentShare = user.shares;
            }
        } else {
            currentShare = (sharesPercent * user.shares) / PRECISION_FACTOR_SHARE;
        }
        uint256 currentAmount = (balanceOfPool() * currentShare) / totalShares;
        user.shares -= currentShare;
        totalShares -= currentShare;

        // Calculate withdraw fee
        if (!_freeFeeUsers(msg.sender) && (block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
            uint256 feeRate = withdrawFee;
            uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
            currentAmount -= currentWithdrawFee;
        }

        if (user.shares > 0) {
            user.cakeAtLastUserAction = (user.shares * balanceOfPool()) / totalShares;
        } else {
            user.cakeAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount.
     */
    function balanceOfPool() internal returns (uint256) {
        return CakeToken.balanceOf(address(cakePool)) + _totalBoostDebt();
    }

    /**
     * @notice Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() internal view returns (uint256) {
        return CakeToken.balanceOf(address(cakePool));
    }

    function _totalShares() internal returns(uint256) {
        return cakePool.totalShares();
    }
    function _totalBoostDebt() internal returns(uint256) {
        return cakePool.totalBoostDebt();
    }
    function _totalLockedAmount() internal returns(uint256) {
        return cakePool.totalLockedAmount();
    }
    function _lastHarvestedTime() internal returns(uint256) {
        return cakePool.lastHarvestedTime();
    }
    function _cakePoolPID() internal returns(uint256) {
        return cakePool.cakePoolPID();
    }
    function _freeFeeUsers(address _user) internal returns(bool) {
        return cakePool.freeFeeUsers(_user);
    }

}