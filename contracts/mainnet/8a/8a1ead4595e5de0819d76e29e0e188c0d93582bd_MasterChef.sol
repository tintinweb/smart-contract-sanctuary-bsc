/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract STR is Context, IERC20, Ownable {

    function balanceOf(address account) public view override returns (uint256) {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {}
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract MasterChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 stakedBlock;    // Staked block number. It is updated every time users stake.
    }

    // Info of each pool. This contract has several reward method. First method is one that has reward per block and Second method has fixed apr.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Strs to distribute per block.
        uint256 fixedApr;         // If lpToken is STR, the apr is fixed.
        uint256 lastRewardBlock;  // Last block number that Strs distribution occurs.
        uint256 accStrPerShare;   // Accumulated Strs per share, times 1e18. See below.
        uint16 withdrawFeeBP;     // Withdraw fee in basis points.
        uint256 lpSupply;
        uint256 lockingPeriod;    // Locking block numbers.
    }

    // The Str TOKEN!
    STR public Str;
    address public feeAddress;

    // Str tokens created per block.
    uint256 public StrPerBlock;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    constructor(
        STR _Str,
        address _feeAddress       
    ) public {
        Str = _Str;
        feeAddress = _feeAddress;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(IERC20 _lpToken, uint256 _allocPoint, uint256 _fixedApr, uint16 _withdrawFeeBP, uint256 _lockingPeriod) external onlyOwner {
        _lpToken.balanceOf(address(this));
        uint256 lastRewardBlock = block.number;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            fixedApr: _fixedApr,
            lastRewardBlock: lastRewardBlock,
            accStrPerShare: 0,
            withdrawFeeBP: _withdrawFeeBP,
            lpSupply: 0,
            lockingPeriod: _lockingPeriod            
        }));
    }

    // Update the given pool's Str allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint256 _fixedApr, uint16 _withdrawFeeBP, uint256 _lockingPeriod) external onlyOwner {
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        if(poolInfo[_pid].allocPoint != 0 && poolInfo[_pid].fixedApr == 0) {
            poolInfo[_pid].allocPoint = _allocPoint;
        }
        if(poolInfo[_pid].allocPoint == 0 && poolInfo[_pid].fixedApr != 0) {
            poolInfo[_pid].fixedApr = _fixedApr;
        }
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
        poolInfo[_pid].lockingPeriod = _lockingPeriod;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // View function to see pending Strs on frontend.
    function pendingStr(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accStrPerShare = pool.accStrPerShare;
        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 StrReward = 0;
            if (pool.allocPoint != 0 && pool.fixedApr == 0) {
                StrReward = multiplier.mul(StrPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
                accStrPerShare = accStrPerShare.add(StrReward.mul(1e18).div(pool.lpSupply));
            }
            else if(pool.allocPoint == 0 && pool.fixedApr != 0) {
                accStrPerShare = accStrPerShare.add(multiplier.mul(1e18).mul(pool.fixedApr).div(100).div(10512000));
            }
        }
        return user.amount.mul(accStrPerShare).div(1e18).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 accStrPerShare = pool.accStrPerShare;
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (pool.allocPoint != 0 && pool.fixedApr == 0) {
            uint256 StrReward = multiplier.mul(StrPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            pool.accStrPerShare = accStrPerShare.add(StrReward.mul(1e18).div(pool.lpSupply));
        }
        else if(pool.allocPoint == 0 && pool.fixedApr != 0) {
            pool.accStrPerShare = accStrPerShare.add(multiplier.mul(1e18).mul(pool.fixedApr).div(100).div(10512000));
        }
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for Str allocation.
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accStrPerShare).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                safeStrTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            uint256 balancebefore=pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            uint256 final_amount=pool.lpToken.balanceOf(address(this)).sub(balancebefore);
            user.amount = user.amount.add(final_amount);
            pool.lpSupply=pool.lpSupply.add(final_amount);
            user.stakedBlock = block.number;
        }
        user.rewardDebt = user.amount.mul(pool.accStrPerShare).div(1e18);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(block.number - user.stakedBlock > pool.lockingPeriod, "Withdraw: locking is not released yet!");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accStrPerShare).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            safeStrTransfer(msg.sender, pending);
        }
        if (_amount > 0) {            
            if (pool.withdrawFeeBP > 0) {
                user.amount = user.amount.sub(_amount);
                uint256 withdrawFee = _amount.mul(pool.withdrawFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, withdrawFee);
                pool.lpToken.safeTransfer(msg.sender, _amount.sub(withdrawFee));                
                pool.lpSupply=pool.lpSupply.sub(_amount);
            }
            else {
                user.amount = user.amount.sub(_amount);
                pool.lpToken.safeTransfer(msg.sender, _amount);
                pool.lpSupply=pool.lpSupply.sub(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accStrPerShare).div(1e18);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.number - user.stakedBlock > pool.lockingPeriod, "Withdraw: locking is not released yet!");
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        
        if (pool.lpSupply >= amount) {
            pool.lpSupply = pool.lpSupply.sub(amount);
        } else {
            pool.lpSupply = 0; 
        }
        uint256 withdrawFee = amount.mul(pool.withdrawFeeBP).div(10000);
        pool.lpToken.safeTransfer(feeAddress, withdrawFee);
        pool.lpToken.safeTransfer(msg.sender, amount.sub(withdrawFee));
    }

    // Safe Str transfer function, just in case if rounding error causes pool to not have enough FOXs.
    function safeStrTransfer(address _to, uint256 _amount) internal {
        uint256 StrBal = Str.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > StrBal) {
            transferSuccess = Str.transfer(_to, StrBal);
        } else {
            transferSuccess = Str.transfer(_to, _amount);
        }
        require(transferSuccess, "safeStrTransfer: Transfer failed");
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0),"non-zero");
        feeAddress = _feeAddress;
    }

    function updateEmissionRate(uint256 _StrPerBlock) external onlyOwner {
        massUpdatePools();
        StrPerBlock = _StrPerBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function isWithdrawable(uint256 _pid) external view returns (bool) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(block.number - user.stakedBlock > pool.lockingPeriod) {
            return true;
        }
        return false;
    }
    
}