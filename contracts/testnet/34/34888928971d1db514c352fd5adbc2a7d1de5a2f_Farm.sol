/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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





pragma solidity ^0.8.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





pragma solidity ^0.8.0;




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
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity ^0.8.0;


library SafeCast {
 
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

   
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

   
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

   
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

   
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

   
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}





pragma solidity ^0.8.0;


library SignedSafeMath {
    
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

   
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

 
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}





pragma solidity ^0.8.0;


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





pragma solidity ^0.8.0;


abstract contract Initializable {
   
    bool private _initialized;

   
    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}





pragma solidity ^0.8.0;



abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}





pragma solidity ^0.8.0;



 
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

   
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}



pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

contract Farm is Initializable, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using SafeCast for int256;

    
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
        uint256 lastDepositedAt;
    }

    uint256 private constant ACC_REWARD_PRECISION = 1e12;

    
    IERC20 public reward;

    
    IERC20 public lpToken;

    
    uint256 public accRewardPerShare;

   
    uint256 public lastRewardBlock;

   
    uint256 public rewardPerBlock;

    
    uint256 public vestingTime = 30 days;

    
    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event EmergencyWithdraw(
        address indexed user,
        uint256 amount,
        address indexed to
    );
    event Harvest(address indexed user, uint256 amount);

    event LogUpdatePool(
        uint256 lastRewardBlock,
        uint256 lpSupply,
        uint256 accRewardPerShare
    );

    
    function initialize(IERC20 _reward, IERC20 _lpToken) external initializer {
        __Ownable_init();

        reward = _reward;
        lpToken = _lpToken;
        accRewardPerShare = 0;
        lastRewardBlock = block.number;
    }

  
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyOwner {
        updatePool();
        rewardPerBlock = _rewardPerBlock;
    }

   
    function pendingReward(address _user)
        external
        view
        returns (uint256 pending)
    {
        UserInfo storage user = userInfo[_user];
        uint256 lpSupply = lpToken.balanceOf(address(this));
        uint256 accRewardPerShare_ = accRewardPerShare;

        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number.sub(lastRewardBlock);
            uint256 blockReward = blocks.mul(rewardPerBlock);
            accRewardPerShare_ = accRewardPerShare_.add(
                blockReward.mul(ACC_REWARD_PRECISION) / lpSupply
            );
        }
        pending = int256(
            user.amount.mul(accRewardPerShare_) / ACC_REWARD_PRECISION
        ).sub(user.rewardDebt).toUint256();
    }

    
    function updatePool() public {
        if (block.number > lastRewardBlock) {
            uint256 lpSupply = lpToken.balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 blocks = block.number.sub(lastRewardBlock);
                uint256 blockReward = blocks.mul(rewardPerBlock);
                accRewardPerShare = accRewardPerShare.add(
                    blockReward.mul(ACC_REWARD_PRECISION) / lpSupply
                );
            }
            lastRewardBlock = block.number;
            emit LogUpdatePool(lastRewardBlock, lpSupply, accRewardPerShare);
        }
    }

    
    function deposit(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[to];

        
        user.lastDepositedAt = block.timestamp;
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.rewardDebt.add(
            int256(amount.mul(accRewardPerShare) / ACC_REWARD_PRECISION)
        );

        lpToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, to);
    }

    
    function withdraw(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= user.lastDepositedAt.add(vestingTime), "Vesting time requires!");
        int256 accumulatedReward = int256(
            user.amount.mul(accRewardPerShare) / ACC_REWARD_PRECISION
        );
        uint256 _pendingReward = accumulatedReward
            .sub(user.rewardDebt)
            .toUint256();

        
        user.rewardDebt = accumulatedReward.sub(
            int256(amount.mul(accRewardPerShare) / ACC_REWARD_PRECISION)
        );
        user.amount = user.amount.sub(amount);

        reward.safeTransfer(to, _pendingReward);
        lpToken.safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    
    function harvest(address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256(
            user.amount.mul(accRewardPerShare) / ACC_REWARD_PRECISION
        );
        uint256 _pendingReward = accumulatedReward
            .sub(user.rewardDebt)
            .toUint256();

        
        user.rewardDebt = accumulatedReward;

       
        if (_pendingReward != 0) {
            reward.safeTransfer(to, _pendingReward);
        }

        emit Harvest(msg.sender, _pendingReward);
    }

   
   
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= user.lastDepositedAt.add(vestingTime), "Vesting time requires!");
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

       
        lpToken.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, amount, to);
    }

   
    function depositReward(uint256 amount) external onlyOwner {
        reward.safeTransferFrom(msg.sender, address(this), amount);
    }

    
    function withdrawReward(uint256 amount) external onlyOwner {
        reward.safeTransfer(msg.sender, amount);
    }

    function updateVestingTime(uint256 priodInSecond) external onlyOwner {
        vestingTime = priodInSecond;
    }

}