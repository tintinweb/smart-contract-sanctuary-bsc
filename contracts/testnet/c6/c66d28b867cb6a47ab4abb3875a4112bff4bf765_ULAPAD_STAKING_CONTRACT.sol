/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// SAFE MATH LIBRARY -----------------------------------------------------------

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// ADDRESS LIBRARY -------------------------------------------------------------

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            'Address: insufficient balance'
        );

        (bool success, ) = recipient.call{value: amount}('');
        require(
            success,
            'Address: unable to send value, recipient may have reverted'
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, 'Address: low-level call failed');
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                'Address: low-level call with value failed'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            'Address: insufficient balance for call'
        );
        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                'Address: low-level static call failed'
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), 'Address: static call to non-contract');

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                'Address: low-level delegate call failed'
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), 'Address: delegate call to non-contract');

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SAFE ERC20 LIBRARY ----------------------------------------------------------

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeERC20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeERC20: decreased allowance below zero'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            'SafeERC20: low-level call failed'
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                'SafeERC20: ERC20 operation did not succeed'
            );
        }
    }
}

// IERC20 INTERFACE ------------------------------------------------------------

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// CONTEXT ABSTRACT ------------------------------------------------------------

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OWNABLE ABSTRACT ------------------------------------------------------------

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ULAPAD STAKING SMART CONTRACT -----------------------------------------------

contract ULAPAD_STAKING_CONTRACT is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Token config ------------------------------------------------------------
    IERC20 public _stakingTokenContract;

    // Pools config ------------------------------------------------------------
    struct Pool {
        uint256 unlockDays;
        uint256 apr;
    }

    Pool[] public _pools;

    uint256 public _emergencyWithdrawFee;

    // Staking state control config --------------------------------------------
    bool public _stakingEnable;

    // Staking config ----------------------------------------------------------
    struct Staker {
        uint256 stakedTokens;
        uint256 earnedTokens;
        uint256 claimedTokens;
        uint256 updatedAt;
    }

    uint256 public _totalStakers;

    uint256 public _totalStakedTokens;

    mapping(uint256 => uint256) public _totalStakedPerPool;

    mapping(address => mapping(uint256 => Staker)) public _stakerPool;

    constructor() {
        _stakingEnable = false;
    }

    // Token contract configuration modules ------------------------------------

    function setStakingTokenContract(address __tokenContract)
        external
        onlyOwner
    {
        _stakingTokenContract = IERC20(__tokenContract);
    }

    // Pool configuration modules ----------------------------------------------

    function totalPools() external view returns (uint256) {
        return _pools.length;
    }

    function addPool(uint256 __unlockDays, uint256 __apr) external onlyOwner {
        require(
            __unlockDays > 0,
            'ULAPAD: Pool unlock day can not set be zero'
        );
        require(__apr > 0, 'ULAPAD: Pool apr can not set be zero');

        _pools.push(Pool(__unlockDays, __apr));
    }

    function updatePool(
        uint256 __poolIndex,
        uint256 __unlockDays,
        uint256 __apr
    ) external onlyOwner {
        require(__poolIndex < _pools.length, 'ULAPAD: Invalid pool index');
        require(
            __unlockDays > 0,
            'ULAPAD: Pool unlock day can not set be zero'
        );
        require(__apr > 0, 'ULAPAD: Pool apr can not set be zero');

        _pools[__poolIndex] = Pool(__unlockDays, __apr);
    }

    function removePool() external onlyOwner {
        require(_pools.length > 0, 'ULAPAD: Staking pools now empty');

        _pools.pop();
    }

    function setEmergencyWithdrawFee(uint256 __feeByPercent)
        external
        onlyOwner
    {
        require(__feeByPercent < 100, 'ULAPAD: Invalid emergency withdraw fee');

        _emergencyWithdrawFee = __feeByPercent;
    }

    // Staking state configuration modules -------------------------------------

    function enableStaking() external onlyOwner {
        require(
            address(_stakingTokenContract) != address(0),
            'ULAPAD: Staking token contract address must be set'
        );
        uint256 __tokenBalance = _stakingTokenContract.balanceOf(address(this));
        require(__tokenBalance > 0, 'ULAPAD: Insufficient token balance');
        require(_pools.length > 0, 'ULAPAD: Staking pool not found yet');

        _stakingEnable = true;
    }

    function disableStaking() external onlyOwner {
        require(_stakingEnable, 'ULAPAD: Staking still disable');

        _stakingEnable = false;
    }

    // Staking modules ---------------------------------------------------------

    function stake(uint256 __amount, uint256 __poolIndex) external {
        require(__amount > 0, 'ULAPAD: Stake amount must be greater than zero');
        uint256 __tokenBalance = _stakingTokenContract.balanceOf(_msgSender());
        require(
            __tokenBalance >= __amount,
            'ULAPAD: Insufficient token balance'
        );
        require(__poolIndex < _pools.length, 'ULAPAD: Invalid pool index');
        require(_stakingEnable, 'ULAPAD: Staking was not enabled yet');

        _stakingTokenContract.safeTransferFrom(
            _msgSender(),
            address(this),
            __amount
        );

        Staker memory __staker = _stakerPool[_msgSender()][__poolIndex];
        uint256 __extraReward = getExtraReward(_msgSender(), __poolIndex);
        _totalStakedTokens = _totalStakedTokens.add(__amount);
        _totalStakedPerPool[__poolIndex] = _totalStakedPerPool[__poolIndex].add(
            __amount
        );
        if (__staker.stakedTokens > 0) {
            _stakerPool[_msgSender()][__poolIndex] = Staker(
                __staker.stakedTokens.add(__amount),
                __staker.earnedTokens.add(__extraReward),
                __staker.claimedTokens,
                block.timestamp
            );
        } else {
            _stakerPool[_msgSender()][__poolIndex] = Staker(
                __amount,
                0,
                0,
                block.timestamp
            );
            _totalStakers = _totalStakers.add(1);
        }
    }

    function unStake(uint256 __amount, uint256 __poolIndex) external {
        require(
            __amount > 0,
            'ULAPAD: Un-Stake amount must be greater than zero'
        );
        uint256 __stakedBalance = _stakerPool[_msgSender()][__poolIndex]
            .stakedTokens;
        require(
            __stakedBalance >= __amount,
            'ULAPAD: Insufficient token balance'
        );
        require(__poolIndex < _pools.length, 'ULAPAD: Invalid pool index');
        require(_stakingEnable, 'ULAPAD: Staking was not enabled yet');

        Pool memory __pool = _pools[__poolIndex];
        Staker memory __staker = _stakerPool[_msgSender()][__poolIndex];
        uint256 __extraReward = getExtraReward(_msgSender(), __poolIndex);
        _totalStakedTokens = _totalStakedTokens.sub(__amount);
        _totalStakedPerPool[__poolIndex] = _totalStakedPerPool[__poolIndex].sub(
            __amount
        );
        if (__staker.stakedTokens.sub(__amount) == 0) {
            _totalStakers = _totalStakers.sub(1);
        }
        _stakerPool[_msgSender()][__poolIndex] = Staker(
            __staker.stakedTokens.sub(__amount),
            __staker.earnedTokens.add(__extraReward),
            __staker.claimedTokens,
            block.timestamp
        );

        if (
            block.timestamp < __staker.updatedAt.add(__pool.unlockDays * 1 days)
        ) {
            uint256 __holdAmount = __amount.mul(_emergencyWithdrawFee).div(100);
            uint256 __unStakeAmount = __amount.sub(__holdAmount);
            _stakingTokenContract.safeTransfer(_msgSender(), __unStakeAmount);
        } else {
            _stakingTokenContract.safeTransfer(_msgSender(), __amount);
        }
    }

    function claimReward(uint256 __poolIndex) external {
        require(__poolIndex < _pools.length, 'ULAPAD: Invalid pool index');
        require(_stakingEnable, 'ULAPAD: Staking was not enabled yet');

        Staker memory __staker = _stakerPool[_msgSender()][__poolIndex];
        uint256 __extraReward = getExtraReward(_msgSender(), __poolIndex);
        uint256 __totalReward = __staker.earnedTokens.add(__extraReward);
        _stakerPool[_msgSender()][__poolIndex] = Staker(
            __staker.stakedTokens,
            0,
            __staker.claimedTokens.add(__totalReward),
            block.timestamp
        );

        _stakingTokenContract.safeTransfer(_msgSender(), __totalReward);
    }

    function getTotalReward(address __address, uint256 __poolIndex)
        external
        view
        returns (uint256)
    {
        require(__poolIndex < _pools.length, 'ULAPAD: Invalid pool index');

        Staker memory __staker = _stakerPool[__address][__poolIndex];
        uint256 __extraReward = getExtraReward(__address, __poolIndex);

        return __staker.earnedTokens.add(__extraReward);
    }

    function getExtraReward(address __address, uint256 __poolIndex)
        private
        view
        returns (uint256)
    {
        Pool memory __pool = _pools[__poolIndex];
        Staker memory __staker = _stakerPool[__address][__poolIndex];
        uint256 __rewardPerYear = __staker.stakedTokens.mul(__pool.apr).div(
            100
        );
        uint256 __rewardPerSecond = __rewardPerYear.div(365 days);

        return block.timestamp.sub(__staker.updatedAt).mul(__rewardPerSecond);
    }

    // Withdraw token modules --------------------------------------------------

    receive() external payable {}

    function withdrawEther() external onlyOwner {
        require(
            address(this).balance > 0,
            'ULAPAD: No Ether available to withdraw'
        );

        payable(address(_msgSender())).transfer(address(this).balance);
    }

    function withdrawToken(IERC20 __tokenContract) external onlyOwner {
        uint256 __tokenBalance = __tokenContract.balanceOf(address(this));
        require(__tokenBalance > 0, 'ULAPAD: Insufficient token balance');

        __tokenContract.safeTransfer(_msgSender(), __tokenBalance);
    }
}