/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {      
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract GrimaceStaking is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 unlockTime;
        uint256 totalEarned;
    }

    // Info of this pool.
    struct PoolInfo {
        IERC20 stakingToken;
        IERC20 rewardToken;
        string stakeTokenLogo;
        string rewardTokenLogo;
        uint256 lastRewardBlock; // Last block number that Tokens distribution occurs.
        uint256 accRewardPerShare; // Accumulated Tokens per share, times 1e12. See below.
        uint256 rewardPerBlock;
        address poolOwner;
        uint256 lockDuration;
        uint256 startTime;
        uint256 endTime;
    }    

    PoolInfo public poolInfo;
    uint256 public totalStaked;

    mapping(address => UserInfo) public userInfo;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event EmergencyUnstake(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 pending);

    constructor(
    ) ERC20("Grimace Token", "sGrimace") {
        
    }

    modifier onlyAdmin() {
        require(
            msg.sender == poolInfo.poolOwner || msg.sender == owner(),
            "Message sender must be the contract's owner."
        );
        _;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override onlyAdmin {
        super._transfer(from, to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override
        onlyAdmin
    {
        super._burn(account, amount);
    }

    function view1() external view returns (uint256) {
        uint256 lastblock = 200000000;
        return block.number.sub(lastblock);
    }

    function view2() external view returns (uint256) {
        uint256 lastblock = 200000000;
        uint256 curblock = block.number;
        return curblock.sub(lastblock);
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 _accRewardPerShare = poolInfo.accRewardPerShare;

        uint256 lpSupply = totalStaked;

        if (block.number > poolInfo.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number.sub(poolInfo.lastRewardBlock);

            uint256 reward = blocks.mul(poolInfo.rewardPerBlock);

            _accRewardPerShare = _accRewardPerShare.add(
                reward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(_accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    function updatePool() internal {
        if (block.number <= poolInfo.lastRewardBlock) {
            return;
        }
        if (block.timestamp < poolInfo.startTime) {
            return;
        }

        uint256 lpSupply = totalStaked;

        if (lpSupply == 0) {
            poolInfo.lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = block.number.sub(poolInfo.lastRewardBlock);
        uint256 reward = blocks.mul(poolInfo.rewardPerBlock);

        poolInfo.accRewardPerShare = poolInfo.accRewardPerShare.add(
            reward.mul(1e12).div(lpSupply)
        );
        poolInfo.lastRewardBlock = block.number;
    }

    // Withdraw primary tokens from STAKING.
    function harvest() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];        

        updatePool();

        uint256 pending = user.amount.mul(poolInfo.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );

        require(pending > 0, "Insufficient pending rewards to claim!");

        uint256 rewardBalance = poolInfo.rewardToken.balanceOf(address(this));
        require(
            pending <= rewardBalance,
            "Insufficient reward tokens in the Pool!"
        );
        poolInfo.rewardToken.safeTransfer(address(msg.sender), pending);

        user.rewardDebt = user.amount.mul(poolInfo.accRewardPerShare).div(1e12);
        user.totalEarned += pending;

        emit Harvest(msg.sender, pending);
    }

    // Stake primary tokens
    function stake(uint256 _amount) public nonReentrant {
        require(block.timestamp >= poolInfo.startTime, "Staking's not started!");
        require(block.timestamp < poolInfo.endTime, "Staking's ended!");

        if (poolInfo.lastRewardBlock == 0) {
            poolInfo.lastRewardBlock = block.number;
        }

        UserInfo storage user = userInfo[msg.sender];

        updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(poolInfo.accRewardPerShare).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                uint256 rewardBalance = poolInfo.rewardToken.balanceOf(address(this));
                require(
                    pending <= rewardBalance,
                    "Insufficient reward tokens in the Pool!"
                );
                poolInfo.rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            poolInfo.stakingToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }

        totalStaked += _amount;

        user.rewardDebt = user.amount.mul(poolInfo.accRewardPerShare).div(1e12);
        //user reward = (current_acc - pre_acc) * user.amount = current_acc*user.amount-pre_acc*user.amount
        //user.rewardDebt represent pre_acc*user.amount
        user.unlockTime = block.timestamp + poolInfo.lockDuration;

        _mint(msg.sender, _amount);

        emit Stake(msg.sender, _amount);
    }

    function unstake(uint256 _amount) public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        require(user.amount >= _amount, "Unstake: insufficient staked tokens!");
        require(
            user.unlockTime <= block.timestamp,
            "May not do normal withdraw early"
        );

        updatePool();

        uint256 pending = user.amount.mul(poolInfo.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            uint256 rewardBalance = poolInfo.rewardToken.balanceOf(address(this));
            require(
                pending <= rewardBalance,
                "Insufficient reward tokens in the Pool!"
            );
            poolInfo.rewardToken.safeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            poolInfo.stakingToken.safeTransfer(address(msg.sender), _amount);
            totalStaked -= _amount;
        }
        user.rewardDebt = user.amount.mul(poolInfo.accRewardPerShare).div(1e12);

        uint256 _burnAmount = balanceOf(msg.sender);
        if (_amount < _burnAmount) _burnAmount = _amount;
        _burn(msg.sender, _burnAmount);

        emit Unstake(msg.sender, _amount);
    }

    function emergencyUnstake() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        require(amount > 0, "Insufficient staked tokens to unstake!");
        user.amount = 0;
        user.rewardDebt = 0;
        user.unlockTime = 0;
        poolInfo.stakingToken.safeTransfer(address(msg.sender), amount);

        uint256 _burnAmount = balanceOf(msg.sender);
        if (amount < _burnAmount) _burnAmount = amount;
        _burn(msg.sender, _burnAmount);

        emit EmergencyUnstake(msg.sender, amount);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyAdmin {
        uint256 remainingReward = poolInfo.rewardToken.balanceOf(address(this));
        if (address(poolInfo.rewardToken) == address(poolInfo.stakingToken)) {
            if (remainingReward >= totalStaked) {
                remainingReward = remainingReward.sub(totalStaked);
            } else {
                remainingReward = 0;
            }
        }
        require(
            _amount <= poolInfo.rewardToken.balanceOf(address(this)),
            "Insufficient reward tokens to take out"
        );
        poolInfo.rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    function emergencyAllRewardWithdraw() external onlyAdmin {
        uint256 remainingReward = poolInfo.rewardToken.balanceOf(address(this));
        if (address(poolInfo.rewardToken) == address(poolInfo.stakingToken)) {
            if (remainingReward >= totalStaked) {
                remainingReward = remainingReward.sub(totalStaked);
            } else {
                remainingReward = 0;
            }
        }
        poolInfo.rewardToken.safeTransfer(address(msg.sender), remainingReward);
    }

    function updateStartTime() external onlyAdmin {
        poolInfo.startTime = block.timestamp;
    }

    function updateEndTime(uint256 _endTime) external onlyAdmin {
        poolInfo.endTime = _endTime;
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyAdmin {
        updatePool();
        poolInfo.rewardPerBlock = _rewardPerBlock;
    }

    function updateLockDuration(uint256 _lockDuration) external onlyAdmin {
        poolInfo.lockDuration = _lockDuration;
    }
}