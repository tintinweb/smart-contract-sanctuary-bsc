/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LPMinner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    constructor() {
        _creator = msg.sender;
    }

    address immutable _creator;
    uint256 public recomNeed = 1*(10**16);
    uint256 public recomPrice = 1*(10**16);
    uint256 public recomFirstRate = 15;
    uint256 public recomSecondRate = 5;

    bool public rewardWithdrawSwitch;
    address public minerToken;
    address public usdtToken;
    address public micUsdtPair;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public platTotalAmount;
    uint256 public userDepositInterval;
    mapping(address => uint256) public lastDepositTimestamp;
    mapping(address => uint256) public userUsdt;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;

    function setRewardWithdrawSwitch(bool _bool) public onlyOwner {
        rewardWithdrawSwitch = _bool;
    }

    function setUserDepositInterval(uint256 _userDepositInterval) public onlyOwner {
        userDepositInterval = _userDepositInterval;
    }

    function initToken(
        address _minerToken,
        address _usdtToken,
        address _micUsdtPair
    ) public onlyOwner {
        minerToken = _minerToken;
        usdtToken = _usdtToken;
        micUsdtPair = _micUsdtPair;
    }

    function setRecomCFG(uint256 _recomPrice,uint256 _recomFirstRate,uint256 _recomSecondRate,uint256 _recomNeed) public onlyOwner {
        recomPrice = _recomPrice;
        recomFirstRate = _recomFirstRate;
        recomSecondRate = _recomSecondRate;
        recomNeed = _recomNeed;
    }

    function setStartTimestamp(uint256 _startTimestamp) public onlyOwner {
        startTimestamp = _startTimestamp;
    }

    function setEndTimestamp(uint256 _endTimestamp) public onlyOwner {
        endTimestamp = _endTimestamp;
    }

    mapping(address => address) public parentAddress;
    mapping(address => address[]) public childrenAddress;

    function setParentAddress(address _addr) public {
        require(_addr != msg.sender, "ParentAddress can not set to youself");
        require(parentAddress[msg.sender] == address(0), "ParentAddress is exist");
        require(parentAddress[_addr] != address(0) || _addr == _creator, "ParentAddress is not actived");
        parentAddress[msg.sender] = _addr;
        childrenAddress[_addr].push(msg.sender);
    }

    function getChildrenAddress(address _addr) public view returns (address[] memory) {
        return childrenAddress[_addr];
    }

    struct UserCurrentInfo {
        uint256 amount;
        uint256 amountLp;
        uint256 amountHashPower;
        uint256 rewardDebt;
        uint256 totalAward;
    }
    struct UserDepositInfo {
        uint256 amount;
        uint256 amountLp;
        uint256 amountHashPower;
        uint256 rewardDebt;
        uint256 totalAward;
        uint256 lockTimestampUtil;
        bool status;
    }
    struct PoolInfo {
        uint256 allocPoint;
        uint256 lockSecond;
        uint256 hashRate;
        bool status;
        uint256 totalAmount;
        uint256 totalAmountLP;
        uint256 accAwardPerShare;
        uint256 lastRewardTimestamp;
    }

    uint256 public awardPerSecond;
    uint256 public totalAllocPoint = 0;
    PoolInfo[] public poolInfos;
    mapping(address => UserCurrentInfo) public userCurrentInfos;
    mapping(address => mapping(uint256 => UserDepositInfo[])) public userDepositInfos;
    mapping(address => uint256) public availableWithdrawBalance;

    function addShareholder(address shareholder) private {
        if( !_updated[shareholder] ){
            shareholderIndexes[shareholder] = shareholders.length;
            shareholders.push(shareholder);
            _updated[shareholder] = true;
        }
    }

    function removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        _updated[shareholder] = false;
    }

    function addShareholders(address shareholder) external onlyOwner {
        addShareholder(shareholder);
    }

    function removeShareholders(address shareholder) external onlyOwner {
        removeShareholder(shareholder);
    }

    function setAwardPerSecond(uint256 _awardPerSecond) public onlyOwner {
        massUpdatePools();
        awardPerSecond = _awardPerSecond;
    }

    function allPool() public view returns (PoolInfo[] memory) {
        return poolInfos;
    }

    function add(
        uint256 _allocPoint,
        uint256 _lockSecond,
        uint256 _hashRate,
        bool _status,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTimestamp = block.timestamp > startTimestamp ? block.timestamp : startTimestamp;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfos.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lockSecond: _lockSecond,
                hashRate: _hashRate,
                status: _status,
                totalAmount: 0,
                totalAmountLP: 0,
                accAwardPerShare: 0,
                lastRewardTimestamp: lastRewardTimestamp
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _lockSecond,
        uint256 _hashRate,
        bool _status,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        require(_pid < poolInfos.length, "Pool id is not exist");
        totalAllocPoint = totalAllocPoint.sub(poolInfos[_pid].allocPoint).add(_allocPoint);
        poolInfos[_pid].allocPoint = _allocPoint;
        poolInfos[_pid].lockSecond = _lockSecond;
        poolInfos[_pid].hashRate = _hashRate;
        poolInfos[_pid].status = _status;
    }

    function massUpdatePools() public {
        uint256 length = poolInfos.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfos[_pid];
        if (block.timestamp > pool.lastRewardTimestamp) {
            uint256 timeSeconds;
            if (pool.totalAmount > 0) {
                if (block.timestamp > endTimestamp) {
                    timeSeconds = endTimestamp.sub(pool.lastRewardTimestamp);
                } else {
                    timeSeconds = block.timestamp.sub(pool.lastRewardTimestamp);
                }
                uint256 reward = timeSeconds.mul(awardPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
                pool.accAwardPerShare = pool.accAwardPerShare.add(reward.mul(1e18).div(platTotalAmount));
            }
            pool.lastRewardTimestamp = pool.lastRewardTimestamp.add(timeSeconds);
            poolInfos[_pid] = pool;
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(parentAddress[msg.sender] != address(0), "Your are not actived");
        PoolInfo memory pool = updatePool(_pid);
        require(pool.status, "This pool is unopen");
        uint256 _micWorth = calcMicWorth(_amount);
        if (pool.lockSecond == 0) {
            userCurrentInfos[msg.sender].amount = userCurrentInfos[msg.sender].amount.add(_micWorth);
            userCurrentInfos[msg.sender].amountLp = userCurrentInfos[msg.sender].amountLp.add(_amount);
            userCurrentInfos[msg.sender].amountHashPower = userCurrentInfos[msg.sender].amountHashPower.add(_micWorth.mul(pool.hashRate).div(1e18));
            userCurrentInfos[msg.sender].rewardDebt = userCurrentInfos[msg.sender].rewardDebt.add(_micWorth.mul(poolInfos[_pid].accAwardPerShare).div(1e18));
        } else {
            require(lastDepositTimestamp[msg.sender].add(userDepositInterval) <= block.timestamp, "Operation limit");
            userDepositInfos[msg.sender][_pid].push(
                UserDepositInfo({
                    amount: _micWorth,
                    amountLp: _amount,
                    amountHashPower: _micWorth.mul(pool.hashRate).div(1e18),
                    rewardDebt: _micWorth.mul(pool.accAwardPerShare).div(1e18),
                    totalAward: 0,
                    lockTimestampUtil: block.timestamp.add(pool.lockSecond),
                    status: true
                })
            );
            lastDepositTimestamp[msg.sender] = block.timestamp;
        }
        IERC20(micUsdtPair).safeTransferFrom(address(msg.sender), address(this), _amount);
        pool.totalAmount = pool.totalAmount.add(_micWorth);
        pool.totalAmountLP = pool.totalAmountLP.add(_amount);
        poolInfos[_pid] = pool;
        platTotalAmount = platTotalAmount.add(_micWorth);
        addShareholder(msg.sender);
    }

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        uint256 _index
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        if (pool.lockSecond == 0) {
            require(userCurrentInfos[msg.sender].amountLp >= _amount, "Insufficient balance of currentAmount");
            uint256 withdrawRate = _amount.mul(1e18).div(userCurrentInfos[msg.sender].amountLp);
            uint256 withdrawUsdt = userCurrentInfos[msg.sender].amount.mul(withdrawRate).div(1e18);

            uint256 accumulatedAward = userCurrentInfos[msg.sender].amount.mul(pool.accAwardPerShare).div(1e18);
            uint256 _pending = accumulatedAward.sub(userCurrentInfos[msg.sender].rewardDebt);
            userCurrentInfos[msg.sender].rewardDebt = accumulatedAward.sub(withdrawUsdt.mul(pool.accAwardPerShare).div(1e18));
            userCurrentInfos[msg.sender].amount = userCurrentInfos[msg.sender].amount.sub(withdrawUsdt);
            userCurrentInfos[msg.sender].amountLp = userCurrentInfos[msg.sender].amountLp.sub(_amount);
            userCurrentInfos[msg.sender].totalAward = userCurrentInfos[msg.sender].totalAward.add(_pending);

            availableWithdrawBalance[msg.sender] = availableWithdrawBalance[msg.sender].add(_pending);
            IERC20(micUsdtPair).safeTransfer(msg.sender, _amount);
            pool.totalAmount = pool.totalAmount.sub(withdrawUsdt);
            pool.totalAmountLP = pool.totalAmountLP.sub(_amount);
            platTotalAmount = platTotalAmount.sub(withdrawUsdt);
        } else {
            UserDepositInfo storage depositInfo = userDepositInfos[msg.sender][_pid][_index];
            require(depositInfo.status, "The deposit is withdraw");
            require(depositInfo.lockTimestampUtil <= block.timestamp, "The deposit is not unlock");
            require(depositInfo.amountLp == _amount, "You must withdraw all amount of deposit");
            depositInfo.status = false;
            uint256 accumulatedAward = depositInfo.amount.mul(pool.accAwardPerShare).div(1e18);
            depositInfo.totalAward = accumulatedAward.sub(depositInfo.rewardDebt);

            availableWithdrawBalance[msg.sender] = availableWithdrawBalance[msg.sender].add(depositInfo.totalAward);
            IERC20(micUsdtPair).safeTransfer(msg.sender, _amount);
            pool.totalAmount = pool.totalAmount.sub(depositInfo.amount);
            pool.totalAmountLP = pool.totalAmountLP.sub(depositInfo.amountLp);
            platTotalAmount = platTotalAmount.sub(depositInfo.amount);
        }

        poolInfos[_pid] = pool;
    }

    function harvest(uint256 _pid) public {
        require(rewardWithdrawSwitch, "Can not harvest now");
        PoolInfo memory pool = updatePool(_pid);
        if (pool.lockSecond == 0) {
            uint256 accumulatedAward = userCurrentInfos[msg.sender].amount.mul(pool.accAwardPerShare).div(1e18);
            uint256 _pending = accumulatedAward.sub(userCurrentInfos[msg.sender].rewardDebt);
            userCurrentInfos[msg.sender].rewardDebt = accumulatedAward;
            if (availableWithdrawBalance[msg.sender] > 0) {
                _pending = _pending.add(availableWithdrawBalance[msg.sender]);
                availableWithdrawBalance[msg.sender] = 0;
            }
            if (_pending != 0) {
                userCurrentInfos[msg.sender].totalAward = userCurrentInfos[msg.sender].totalAward.add(_pending);
                IERC20(minerToken).transfer(msg.sender, _pending);
                minnerRecom(msg.sender,_pending);
            }
        } else {
            UserDepositInfo[] storage userDepositInfosPool = userDepositInfos[msg.sender][_pid];
            uint256 totalPedding = 0;
            uint256 accAwardPerShare = pool.accAwardPerShare;
            for (uint256 i = 0; i < userDepositInfosPool.length; i++) {
                if (!userDepositInfosPool[i].status) {
                    continue;
                }
                uint256 _pending = userDepositInfosPool[i].amount.mul(accAwardPerShare).div(1e18).sub(userDepositInfosPool[i].rewardDebt);
                userDepositInfosPool[i].rewardDebt = userDepositInfosPool[i].rewardDebt.add(_pending);
                userDepositInfosPool[i].totalAward = userDepositInfosPool[i].totalAward.add(_pending);
                totalPedding = totalPedding.add(_pending);
            }
            if (availableWithdrawBalance[msg.sender] > 0) {
                totalPedding = totalPedding.add(availableWithdrawBalance[msg.sender]);
                availableWithdrawBalance[msg.sender] = 0;
            }
            if (totalPedding != 0) {
                IERC20(minerToken).transfer(msg.sender, totalPedding);
                minnerRecom(msg.sender,totalPedding);
            }
        }
    }

    function harvestBatch() public {
        require(rewardWithdrawSwitch, "Can not harvest now");
        massUpdatePools();
        uint256 totalPedding = 0;
        for (uint256 i = 0; i < poolInfos.length; i++) {
            if (poolInfos[i].lockSecond == 0) {
                uint256 accumulatedAward = userCurrentInfos[msg.sender].amount.mul(poolInfos[i].accAwardPerShare).div(1e18);
                uint256 _pending = accumulatedAward.sub(userCurrentInfos[msg.sender].rewardDebt);
                userCurrentInfos[msg.sender].rewardDebt = accumulatedAward;
                if (_pending != 0) {
                    userCurrentInfos[msg.sender].totalAward = userCurrentInfos[msg.sender].totalAward.add(_pending);
                    totalPedding = totalPedding.add(_pending);
                }
            } else {
                UserDepositInfo[] storage userDepositInfosPool = userDepositInfos[msg.sender][i];
                uint256 accAwardPerShare = poolInfos[i].accAwardPerShare;
                for (uint256 j = 0; j < userDepositInfosPool.length; j++) {
                    if (!userDepositInfosPool[j].status) {
                        continue;
                    }
                    uint256 _pending = userDepositInfosPool[j].amount.mul(accAwardPerShare).div(1e18).sub(userDepositInfosPool[j].rewardDebt);
                    userDepositInfosPool[j].rewardDebt = userDepositInfosPool[j].rewardDebt.add(_pending);
                    userDepositInfosPool[j].totalAward = userDepositInfosPool[j].totalAward.add(_pending);
                    totalPedding = totalPedding.add(_pending);
                }
            }
        }
        if (availableWithdrawBalance[msg.sender] > 0) {
            totalPedding = totalPedding.add(availableWithdrawBalance[msg.sender]);
            availableWithdrawBalance[msg.sender] = 0;
        }
        if (totalPedding != 0) {
            IERC20(minerToken).transfer(msg.sender, totalPedding);
            minnerRecom(msg.sender,totalPedding);
        }
    }

    function pending(address _addr, uint256 _pid) external view returns (uint256) {
        uint256 accAwardPerShare = poolInfos[_pid].accAwardPerShare;
        uint256 lpSupply = poolInfos[_pid].totalAmount;
        if (poolInfos[_pid].lockSecond == 0) {
            if (block.timestamp > poolInfos[_pid].lastRewardTimestamp && lpSupply != 0) {
                uint256 timeSeconds = (block.timestamp > endTimestamp) ? endTimestamp.sub(poolInfos[_pid].lastRewardTimestamp) : block.timestamp.sub(poolInfos[_pid].lastRewardTimestamp);
                uint256 reward = timeSeconds.mul(awardPerSecond).mul(poolInfos[_pid].allocPoint).div(totalAllocPoint);
                accAwardPerShare = accAwardPerShare.add(reward.mul(1e18).div(platTotalAmount));
            }
            return uint256(userCurrentInfos[_addr].amount.mul(accAwardPerShare).div(1e18)).sub(userCurrentInfos[_addr].rewardDebt);
        } else {
            uint256 totalPeding = 0;
            UserDepositInfo[] memory userDepositInfosPool = userDepositInfos[_addr][_pid];
            for (uint256 i = 0; i < userDepositInfosPool.length; i++) {
                totalPeding = totalPeding.add(pendingDeposit(_addr, _pid, i));
            }
            return totalPeding;
        }
    }

    function pendingDeposit(
        address _addr,
        uint256 _pid,
        uint256 _index
    ) public view returns (uint256) {
        UserDepositInfo storage userDepositInfo = userDepositInfos[_addr][_pid][_index];
        if (!userDepositInfo.status) {
            return 0;
        }
        uint256 accAwardPerShare = poolInfos[_pid].accAwardPerShare;
        uint256 lpSupply = poolInfos[_pid].totalAmount;
        if (block.timestamp > poolInfos[_pid].lastRewardTimestamp && lpSupply != 0) {
            uint256 timeSeconds = (block.timestamp > endTimestamp) ? endTimestamp.sub(poolInfos[_pid].lastRewardTimestamp) : block.timestamp.sub(poolInfos[_pid].lastRewardTimestamp);
            uint256 reward = timeSeconds.mul(awardPerSecond).mul(poolInfos[_pid].allocPoint) / totalAllocPoint;
            accAwardPerShare = accAwardPerShare.add(reward.mul(1e18).div(platTotalAmount));
        }
        return uint256(userDepositInfo.amount.mul(accAwardPerShare).div(1e18)).sub(userDepositInfo.rewardDebt);
    }

    function calcMicWorth(uint256 lpAmount) public view returns (uint256) {
        uint256 usdtPairBalance = IERC20(usdtToken).balanceOf(micUsdtPair);
        uint256 totalSupply = IERC20(micUsdtPair).totalSupply();
        return lpAmount.mul(usdtPairBalance).div(totalSupply);
    }

    function childrenTotal(address _addr) public view returns (UserCurrentInfo memory currentTotal, UserDepositInfo memory depositTotal) {
        address[] memory children = childrenAddress[_addr];
        currentTotal = UserCurrentInfo({amount: 0, amountLp: 0, amountHashPower: 0, rewardDebt: 0, totalAward: 0});
        depositTotal = UserDepositInfo({amount: 0, amountLp: 0, amountHashPower: 0, rewardDebt: 0, totalAward: 0, lockTimestampUtil: 0, status: false});
        for (uint256 i = 0; i < children.length; i++) {
            currentTotal.amount += userCurrentInfos[children[i]].amount;
            currentTotal.amountLp += userCurrentInfos[children[i]].amountLp;
            currentTotal.amountHashPower += userCurrentInfos[children[i]].amountHashPower;
            currentTotal.rewardDebt += userCurrentInfos[children[i]].rewardDebt;
            currentTotal.totalAward += userCurrentInfos[children[i]].totalAward;
            UserDepositInfo memory depositSubTotal = userDepositTotal(children[i]);
            depositTotal.amount += depositSubTotal.amount;
            depositTotal.amountLp += depositSubTotal.amountLp;
            depositTotal.amountHashPower += depositSubTotal.amountHashPower;
            depositTotal.rewardDebt += depositSubTotal.rewardDebt;
            depositTotal.totalAward += depositSubTotal.totalAward;
        }
    }

    function userDepositPoolInfos(address _addr, uint256 _pid) public view returns (UserDepositInfo[] memory) {
        return userDepositInfos[_addr][_pid];
    }

    function userDepositTotal(address _addr) public view returns (UserDepositInfo memory depositTotal) {
        for (uint256 i = 0; i < poolInfos.length; i++) {
            UserDepositInfo[] memory depositsPool = userDepositInfos[_addr][i];
            for (uint256 j; j < depositsPool.length; j++) {
                if (depositsPool[j].status) {
                    depositTotal.amount += depositsPool[j].amount;
                    depositTotal.amountLp += depositsPool[j].amountLp;
                    depositTotal.amountHashPower += depositsPool[j].amountHashPower;
                    depositTotal.rewardDebt += depositsPool[j].rewardDebt;
                    depositTotal.totalAward += depositsPool[j].totalAward;
                }
            }
        }
    }

    function minnerRecom(address addr,uint256 amount) private {
        address recomFirst = parentAddress[addr];
        if (recomFirst!= address(0)){
            UserDepositInfo memory depositSubTotal = userDepositTotal(recomFirst);
            if ((userCurrentInfos[recomFirst].amount).add(depositSubTotal.amount) >=recomPrice ){
                IERC20(minerToken).transfer(recomFirst, amount.mul(recomFirstRate).div(100));
            }
            address recomSecond = parentAddress[recomFirst];
            if (recomSecond != address(0)){
                depositSubTotal = userDepositTotal(recomSecond);
                if ((userCurrentInfos[recomSecond].amount).add(depositSubTotal.amount) >=recomPrice ){
                    IERC20(minerToken).transfer(recomSecond, amount.mul(recomSecondRate).div(100));
                }
            }
        }
    }

    function initSale() external onlyOwner {
        uint256 tokenAmount = 10**12;
        address[] memory path = new address[](2);
        path[0] = minerToken;
        path[1] = usdtToken;
        IERC20(minerToken).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }

    function shareUsdt(uint256 shareUsdtAmount) external onlyOwner{
        uint256 totalTokenDeposit = 0;
        uint256 userTokenDeposit = 0;
        for (uint256 i = 0; i < poolInfos.length; i++) {
            totalTokenDeposit += poolInfos[i].totalAmountLP;
        }

        for (uint256 i = 0; i < shareholders.length; i++) {
            address shareUser = shareholders[i];
            userTokenDeposit = (userCurrentInfos[shareUser].amountLp).add((userDepositTotal(shareUser)).amountLp);

            if (userTokenDeposit>0){
                userUsdt[shareUser] = userUsdt[shareUser].add(userTokenDeposit.mul(shareUsdtAmount).div(totalTokenDeposit));
            }else{
                removeShareholder(shareUser);
            }
            
        }        
    }

    function getUsdt() public {
        uint256 userShareUsdt = userUsdt[msg.sender];
        if (userShareUsdt>0){
            uint112 totalUSDT;
        
            IUniswapV2Pair pair = IUniswapV2Pair(micUsdtPair);
            (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
            if (pair.token0()==usdtToken){
                totalUSDT = reserve0;
            }else{
                totalUSDT = reserve1;
            }

            IERC20(usdtToken).transfer(msg.sender, userShareUsdt);
            
            address recomFirst = parentAddress[msg.sender];
            if (recomFirst!= address(0)){
                UserDepositInfo memory depositSubTotal = userDepositTotal(recomFirst);
                if ((userCurrentInfos[recomFirst].amountLp).add(depositSubTotal.amountLp).add(IERC20(micUsdtPair).balanceOf(recomFirst)).mul(totalUSDT).div(IERC20(micUsdtPair).totalSupply())>=recomNeed){
                    IERC20(usdtToken).transfer(recomFirst,userShareUsdt.mul(30).div(100));
                }
                address recomSecond = parentAddress[recomFirst];
                if (recomSecond != address(0)){
                    depositSubTotal = userDepositTotal(recomSecond);
                    if ((userCurrentInfos[recomSecond].amountLp).add(depositSubTotal.amountLp).add(IERC20(micUsdtPair).balanceOf(recomSecond)).mul(totalUSDT).div(IERC20(micUsdtPair).totalSupply())>=recomNeed){
                        IERC20(usdtToken).transfer(recomSecond,userShareUsdt.mul(10).div(100));
                    }
                }
            }
            userUsdt[msg.sender] = 0;
        }
    }

}