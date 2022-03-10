// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;
import "./libraries/SafeMath.sol";
import './libraries/TransferHelper.sol';
import './interfaces/IERC20.sol';

contract CifiStaking {
    using SafeMath  for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewarded;
        uint256 rewardDebt;
        uint256 lastDepositTimeStamp;
    }

    // pool info
    uint256 public totalStakedAmount;
    uint256 public lastRewardTimeStamp;
    address public cifiToken;
    uint256 public accCifiPerShare;
    address public adminAddress;
    // CIFI tokens created per Sec.
    uint256 public rewardPerSec = 83333333333333333; // 7200 CIFI per day
    
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    uint256 public lockedTime = 7 * 24 * 3600; // 7days
    uint private unlocked = 1;

    uint256 public startStakingTimeStamp;
    uint256 public stakingPeriod = 30 * 24 * 3600; // 30days

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    modifier lock() {
        require(unlocked == 1, 'CifiStaking: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address _cifiToken) public {
        adminAddress = msg.sender;
        cifiToken = _cifiToken;
        totalStakedAmount = 0;
        startStakingTimeStamp = block.timestamp;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "!ADMIN");
        _;
    }
    function setAdmin(address _adminAddress) public onlyAdmin {
        adminAddress = _adminAddress;
    }

    function getStakedPeriod(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to < _from) {
            return 0;
        } else {
            uint256 st = _from;
            uint256 ed = startStakingTimeStamp.add(stakingPeriod);
            if (_from < startStakingTimeStamp) {
                st = startStakingTimeStamp;
            }
            if (_to < ed) {
                ed = _to;
            }
            if (ed > st) {
                return ed.sub(st);
            } else {
                return 0;
            }
            
        }
    }

    function getReward(address _user) external view returns (uint256) {
        uint256 _accCifiPerShare = accCifiPerShare;
        UserInfo storage user = userInfo[_user];
        if (block.timestamp > lastRewardTimeStamp) {
            uint256 stakedPeriod = getStakedPeriod(lastRewardTimeStamp, block.timestamp);
            uint256 cifiReward = stakedPeriod.mul(rewardPerSec);
            _accCifiPerShare = _accCifiPerShare.add(cifiReward.mul(1e12).div(totalStakedAmount));
        }
        return user.amount.mul(_accCifiPerShare).div(1e12).sub(user.rewardDebt);
    }

    function updatePool() internal {
        if (block.timestamp <= lastRewardTimeStamp) {
            return;
        }
        if (totalStakedAmount == 0) {
            lastRewardTimeStamp = block.timestamp;
            return;
        }
        uint256 stakedPeriod = getStakedPeriod(lastRewardTimeStamp, block.timestamp);
        uint256 cifiReward = stakedPeriod.mul(rewardPerSec);
        accCifiPerShare = accCifiPerShare.add(cifiReward.mul(1e12).div(totalStakedAmount));
        lastRewardTimeStamp = block.timestamp;
    }

    function deposit(uint256 amount) public lock {
        uint256 currentTimeStamp = block.timestamp;
        require(currentTimeStamp < startStakingTimeStamp + stakingPeriod, "Staking had been closed.");
        require(amount > 0, "invaild amount");
        TransferHelper.safeTransferFrom(cifiToken, msg.sender, address(this), amount);
        UserInfo storage user = userInfo[msg.sender];

        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accCifiPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                TransferHelper.safeTransfer(cifiToken, msg.sender, pending);
                user.rewarded = user.rewarded.add(pending);
            }
        }
        user.amount = user.amount.add(amount);
        totalStakedAmount = totalStakedAmount.add(amount);
        user.rewardDebt = user.amount.mul(accCifiPerShare).div(1e12);
        user.lastDepositTimeStamp = block.timestamp;
        emit Deposit(msg.sender, amount);
    }

    function withdraw() public lock {
        UserInfo storage user = userInfo[msg.sender];
        require(user.lastDepositTimeStamp > 0, "invalid user");
        require(user.amount > 0, "not staked");
        updatePool();
        uint256 withdrawAmount = user.amount;
        user.amount = 0;
        totalStakedAmount = totalStakedAmount - withdrawAmount;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(cifiToken, msg.sender, withdrawAmount);
        emit Withdraw(msg.sender, withdrawAmount);
    }

    function reward() public lock {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 pending = user.amount.mul(accCifiPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            if (user.lastDepositTimeStamp + lockedTime < block.timestamp) {
                pending = pending.mul(9).div(10);
            }
            TransferHelper.safeTransfer(cifiToken, msg.sender, pending);
            user.rewarded = user.rewarded.add(pending);
        }
        user.rewardDebt = user.amount.mul(accCifiPerShare).div(1e12);
        emit Reward(msg.sender, pending);
    }

    function exit() public lock {
        UserInfo storage user = userInfo[msg.sender];
        require(user.lastDepositTimeStamp > 0, "invalid user");
        require(user.amount > 0, "not staked");
        updatePool();
        uint256 withdrawAmount = user.amount;
        user.amount = 0;
        uint256 pending = withdrawAmount.mul(accCifiPerShare).div(1e12).sub(user.rewardDebt);
        totalStakedAmount = totalStakedAmount - withdrawAmount;
        user.rewardDebt = 0;
        if (user.lastDepositTimeStamp + lockedTime < block.timestamp) {
            pending = pending.mul(9).div(10);
        }
        uint256 amount = withdrawAmount.add(pending);
        user.rewarded = user.rewarded + pending;
        TransferHelper.safeTransfer(cifiToken, msg.sender, amount);
        emit Withdraw(msg.sender, withdrawAmount);
        emit Reward(msg.sender, pending);
    }

    function emergencyWithdraw(uint amount) external lock onlyAdmin {
        require(IERC20(cifiToken).balanceOf(address(this)) >= amount, "Withdraw-Overflow");
        TransferHelper.safeTransfer(cifiToken, msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
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
        return div(a, b, 'SafeMath: division by zero');
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
    function div(uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}