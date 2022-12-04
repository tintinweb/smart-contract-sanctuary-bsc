/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint256);

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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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



contract GizmoStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 poolId;  
        uint256 depositTime;
        uint256 earnedToken;
        bool isActive;
    }

    struct GetPoolInfo{
        uint256 flexiApy;
        uint256 startEpoch;
        uint256 poolReward;
        uint256 totalStaked;
        uint256 lockPeriod;
        uint256 maxLockPeriod;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 emergencyWithdrawFee;
        bool isOpen;
    }

    struct PoolInfo{
        uint256 poolLimitPerUser;

        uint256 accTokenPerShare;
        uint256 rewardPerEpoch;

        uint256 lastRewardEpoch;
        uint256 startEpoch;
        uint256 rewardEndEpoch;
        uint256 lockPeriod;

        uint256 precisionFactor;
        uint256 totalStaked;
        uint256 addedReward;
        
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 emergencyWithdrawFee;
        bool isOpen;
    }

    IERC20 public token;

    struct GetRefferalInfo{
        address user;
        uint256 amount;
        uint256 BNB;
    }

    struct RefferalInfo{
        address user;
        uint256 amount;
    }

    struct Refferal{
        address referrer;
        bytes32 referrerCode;
        RefferalInfo[] information;
    }

    mapping(address => Refferal) public addressToRefferals;
    mapping(bytes32 => address) public refferalCodestoAddress;

    PoolInfo[] public poolInfo;
    mapping(address => StakeInfo[]) public stakeInfo;
    address marketingWallet;

    IUniswapV2Pair public  uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event GenerateReferralCode(address indexed user, bytes32 code);
    constructor() {
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router =  0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }
        marketingWallet=address(0xCd4B94b8b3DAB0EcacC140b13730dC7C8b66a2D6);
        token = IERC20(0xE51C522058FdF9A5906571D5dB84e69654132848);
        uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(token), address(uniswapV2Router.WETH())));

         poolInfo.push(PoolInfo({
            poolLimitPerUser: 0,
            accTokenPerShare: 0,
            rewardPerEpoch: 100e12,
            lastRewardEpoch: block.timestamp,
            startEpoch: block.timestamp,
            rewardEndEpoch: block.timestamp+ 21 hours,
            precisionFactor: 1e12,
            addedReward: 0,
            totalStaked: 0,
            lockPeriod: 7 minutes,
            depositFee: 400,
            withdrawFee: 0,
            emergencyWithdrawFee: 1000,
            isOpen: true
        }));
        poolInfo.push(PoolInfo({
            poolLimitPerUser: 0,
            accTokenPerShare: 0,
            rewardPerEpoch: 100e12,
            lastRewardEpoch: block.timestamp,
            startEpoch: block.timestamp,
            rewardEndEpoch: block.timestamp+ 30 hours,
            precisionFactor: 1e12,
            addedReward: 0,
            totalStaked: 0,
            lockPeriod: 10 minutes,
            depositFee: 400,
            withdrawFee: 0,
            emergencyWithdrawFee: 1000,
            isOpen: true
        }));
    }

    function claimStuckTokens(address _token) external onlyOwner {
        if (_token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 erc20Token = IERC20(_token);
        uint256 balance = erc20Token.balanceOf(address(this));
        erc20Token.transfer(msg.sender, balance);
    }

//=======Pool=======//
    function addPool(PoolInfo memory pool) external onlyOwner{
        poolInfo.push(pool);
    }

    function changePool(uint256 poolId,PoolInfo memory pool) external onlyOwner{
        poolInfo[poolId]=pool;
    }

    function setFees(uint256 _poolId, uint256 emFee, uint256 withFee,uint256 depFee) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        require(emFee <= 3000, "EmergencyWithdrawFee should be <= 30");
        require(withFee <= 3000, "WithdrawFee should be <= 30");
        require(depFee <= 3000, "DepositFee should be <= 30");
        pool.emergencyWithdrawFee = emFee;
        pool.withdrawFee = withFee;
        pool.depositFee = depFee;
    }

    function poolStatus(uint256 _pid,bool _isOpen) external onlyOwner{
        PoolInfo storage pool = poolInfo[_pid];
        pool.isOpen = _isOpen;
    }

    function getPoolInfo() external view returns (GetPoolInfo[] memory) {
        PoolInfo[] memory pools = poolInfo;
        GetPoolInfo[] memory poolInfos = new GetPoolInfo[](pools.length);
        for(uint256 i=0;i<pools.length;i++){
            uint256 flexAPI=pools[i].totalStaked==0?1e12:pools[i].totalStaked;
            poolInfos[i]=GetPoolInfo({
                flexiApy: (pools[i].rewardEndEpoch-pools[i].startEpoch)*pools[i].rewardPerEpoch*1e12/flexAPI,
                startEpoch: pools[i].startEpoch,
                poolReward: (pools[i].rewardEndEpoch-pools[i].startEpoch)*pools[i].rewardPerEpoch,
                totalStaked: pools[i].totalStaked,
                lockPeriod: pools[i].lockPeriod,
                maxLockPeriod: pools[i].rewardEndEpoch-pools[i].startEpoch,
                depositFee: pools[i].depositFee,
                withdrawFee: pools[i].withdrawFee,
                emergencyWithdrawFee: pools[i].emergencyWithdrawFee,
                isOpen: pools[i].isOpen
            });
        }
        return poolInfos;
    }

    function _updatePool(uint256 _poolId) internal{
        PoolInfo storage pool = poolInfo[_poolId];
   
        if (block.timestamp <= pool.lastRewardEpoch) {
            return;
        }

        if (pool.totalStaked == 0) {
            pool.lastRewardEpoch = block.timestamp;
            return;
        }
        if(pool.addedReward>pool.rewardEndEpoch-pool.startEpoch){
            uint256 increase = pool.addedReward/(pool.rewardEndEpoch-pool.startEpoch);
            pool.rewardPerEpoch+=increase;
            pool.addedReward-=(pool.rewardEndEpoch-pool.startEpoch)*increase;
        }

        uint256 multiplier = _getMultiplier(_poolId,pool.lastRewardEpoch, block.timestamp);
        uint256 tokenReward = multiplier * pool.rewardPerEpoch;
        pool.accTokenPerShare = pool.accTokenPerShare + ((tokenReward * pool.precisionFactor)/ pool.totalStaked);
        pool.lastRewardEpoch = block.timestamp;
    }

    function _getMultiplier(uint256 _poolId,uint256 _from, uint256 _to) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolId];

        if (_to <= pool.rewardEndEpoch) {
            return _to - _from;
        } else if (_from >= pool.rewardEndEpoch) {
            return 0;
        } else {
            return pool.rewardEndEpoch - _from;
        }
    }

//=======Stake View Operations=======//
    function pendingReward(uint256 _stakeId,address _user) public view returns (uint256) {
        StakeInfo memory stake = stakeInfo[_user][_stakeId];
        PoolInfo memory pool = poolInfo[stake.poolId];

        uint256 stakedTokenSupply = pool.totalStaked;
        if(stake.isActive==false){
            return 0;
        } else if (block.timestamp > pool.lastRewardEpoch && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(stake.poolId,pool.lastRewardEpoch, block.timestamp);
            uint256 tokenReward = multiplier * pool.rewardPerEpoch;
            uint256 adjustedTokenPerShare =
                pool.accTokenPerShare + ((tokenReward * pool.precisionFactor)/ pool.totalStaked);
            return stake.amount * adjustedTokenPerShare /pool.precisionFactor - stake.rewardDebt;
        } else {
            return stake.amount * pool.accTokenPerShare /pool.precisionFactor - stake.rewardDebt;
        }
    }
    
    function canWithdraw(uint256 _stakeId, address _user) public view returns (bool) {
        return (withdrawCountdown(_stakeId,_user)==0 && stakeInfo[_user][_stakeId].isActive);
    }

    function withdrawCountdown(uint256 _stakeId, address _user) public view returns (uint256) {
        StakeInfo storage stake = stakeInfo[_user][_stakeId];
        PoolInfo  storage pool = poolInfo[stake.poolId];
        uint256 time = block.timestamp;

        if(time > pool.rewardEndEpoch){
            return 0;
        }else if (time < stake.depositTime + pool.lockPeriod){
            return stake.depositTime + pool.lockPeriod - time;
        }else{
            return 0;
        }
    }

    function getBNBAmount(uint256 amountIn) public view returns (uint256) {
        uint256 bnbInTokenPair;
        uint256 tokenInTokenPair;
        
        if(address(uniswapV2Pair.token0()) == address(uniswapV2Router.WETH()))
            (bnbInTokenPair, tokenInTokenPair,  ) = uniswapV2Pair.getReserves();
        else
            (tokenInTokenPair, bnbInTokenPair, ) = uniswapV2Pair.getReserves();
            
        uint256 aBNBWorthOfToken = (bnbInTokenPair * amountIn * (10**18)) / tokenInTokenPair;

        return aBNBWorthOfToken/(10**18);
    }

    function userRefferalInfo(address _user) public view returns(bytes32,GetRefferalInfo[] memory) {
        Refferal memory refferalInformation = addressToRefferals[_user];
        RefferalInfo[] memory rawRefferalInfos= refferalInformation.information;
        GetRefferalInfo[] memory refferalInfos = new GetRefferalInfo[](rawRefferalInfos.length);
        for(uint256 i=0;i<rawRefferalInfos.length;i++){
            refferalInfos[i].amount = rawRefferalInfos[i].amount;
            refferalInfos[i].user = rawRefferalInfos[i].user;
            refferalInfos[i].BNB = getBNBAmount(rawRefferalInfos[i].amount);
        }
        return (refferalInformation.referrerCode,refferalInfos);
    }

    function getAllUserInfo(address _user) public view returns(uint256[] memory) {
        StakeInfo[] storage stake = stakeInfo[_user];
        PoolInfo[] storage pool = poolInfo;
        uint256 lenghtOfStake = 0;
         for(uint256 i = 0; i < stake.length; ++i)
             if(stake[i].isActive)
                lenghtOfStake+=1;
            
        uint256[] memory information = new uint256[](lenghtOfStake*8);
        uint256 j=0;
        for(uint256 i = 0; i < stake.length; ++i){
            if(stake[i].isActive){
                information[j*8+0]=stake[i].amount;
                information[j*8+1]=stake[i].depositTime;
                information[j*8+2]=pool[stake[i].poolId].lockPeriod;
                information[j*8+3]=pool[stake[i].poolId].totalStaked;
                information[j*8+4]=i;
                information[j*8+5]=pendingReward(i,_user);
                information[j*8+6]=canWithdraw(i,_user)? 1 : 0;
                information[j*8+7]=(pool[stake[i].poolId].rewardEndEpoch-pool[stake[i].poolId].startEpoch)*pool[stake[i].poolId].rewardPerEpoch;
                j+=1;
            }
        }
        return information;
    }

    
    function getAllUserHistory(address _user) public view returns(uint256[] memory) {
        StakeInfo[] storage stake = stakeInfo[_user];
        PoolInfo[] storage pool = poolInfo;
        uint256 lenghtOfStake = 0;
         for(uint256 i = 0; i < stake.length; ++i)
             if(!stake[i].isActive)
                lenghtOfStake+=1;
            
        uint256[] memory information = new uint256[](lenghtOfStake*5);
        uint256 j=0;
        for(uint256 i = 0; i < stake.length; ++i){
            if(!stake[i].isActive){
                information[j*5+0]=stake[i].amount;
                information[j*5+1]=stake[i].depositTime;
                information[j*5+2]=pool[stake[i].poolId].lockPeriod;
                information[j*5+3]=i;
                information[j*5+4]=stake[i].earnedToken;
                j+=1;
            }
        }
        return information;
    }

    function getTotalLiveStake(address _user) public view returns(uint256) {
        StakeInfo[] storage stake = stakeInfo[_user];
        uint256 amountOfAllStake = 0;
         for(uint256 i = 0; i < stake.length; ++i)
            amountOfAllStake+=stake[i].amount;
        return amountOfAllStake;
    }

//=======Deposit&Withdraw=======//
    function deposit(uint256 _poolId,uint256 _amount,bytes32 _refereeCode) public nonReentrant{
        require (_amount > 0, 'amount 0');
        PoolInfo storage pool = poolInfo[_poolId];

        require(pool.isOpen,'pool is closed');
        require(pool.startEpoch < block.timestamp && pool.rewardEndEpoch > block.timestamp ,'pool has not started yet or has ended');
        
        _updatePool(_poolId);
        token.safeTransferFrom(address(msg.sender), address(this), _amount);
        if(pool.depositFee>0){
            uint256 fee = (_amount * pool.depositFee) / 10_000;
            _amount = _amount - fee;
            if(refferalCodestoAddress[_refereeCode]!=address(0x0) && refferalCodestoAddress[_refereeCode]!=address(msg.sender)){
                uint256 discountedFee = fee/4;
                token.safeTransfer(refferalCodestoAddress[_refereeCode],discountedFee);
                RefferalInfo[] storage refferalUser=addressToRefferals[refferalCodestoAddress[_refereeCode]].information;
                bool flag=true;
                for(uint256 i=0;i<refferalUser.length;i++){
                    if(refferalUser[i].user==msg.sender){
                        refferalUser[i].amount+=discountedFee;
                        flag=false;
                        break;
                    }
                }
                if(flag){
                    addressToRefferals[refferalCodestoAddress[_refereeCode]].information.push(RefferalInfo({amount:discountedFee,user:msg.sender}));
                }
                fee=(2*discountedFee);
                _amount+=discountedFee;
            }

            token.safeTransfer(address(marketingWallet), fee/2);
            pool.addedReward+= fee/2;
        }
        pool.totalStaked += _amount;

        if (pool.poolLimitPerUser>0) {
            require(_amount+ getTotalLiveStake(msg.sender) <= pool.poolLimitPerUser, "User amount above limit");
        }
        stakeInfo[msg.sender].push(StakeInfo({
            amount: _amount,
            poolId: _poolId,
            depositTime: block.timestamp,
            rewardDebt: ((_amount*pool.accTokenPerShare)/pool.precisionFactor),
            isActive: true,
            earnedToken: 0
        }));

        bytes32 refereeBytes32;
        if(addressToRefferals[msg.sender].referrer==address(0)){
            refereeBytes32 = keccak256(abi.encodePacked(block.timestamp,msg.sender,_amount));
            refferalCodestoAddress[refereeBytes32]=msg.sender;
            addressToRefferals[msg.sender].referrer=msg.sender;
            addressToRefferals[msg.sender].referrerCode=refereeBytes32;
            emit GenerateReferralCode(msg.sender, refereeBytes32); 
        }
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _stakeId) public nonReentrant{
        require(canWithdraw(_stakeId,msg.sender),'cannot withdraw yet or already withdrawn');
        StakeInfo storage stake = stakeInfo[msg.sender][_stakeId];
        PoolInfo storage pool = poolInfo[stake.poolId];
        _updatePool(stake.poolId);
        uint256 _pendingReward = pendingReward(_stakeId, msg.sender);
        
        uint256 _amount = stake.amount;
        pool.totalStaked -= _amount;

       
        if(pool.withdrawFee>0){
            uint256 fee = (_amount * pool.withdrawFee) / 10_000;
            _amount -= fee;
            token.safeTransfer(address(marketingWallet), fee/2);
            pool.addedReward+= fee/2;
        }

        _amount += _pendingReward;
        stake.isActive=false;
        stake.earnedToken+=_pendingReward;

        token.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw(uint256 _stakeId) public nonReentrant{
        require(!canWithdraw(_stakeId,msg.sender),'Use normal withdraw instead');
        StakeInfo storage stake = stakeInfo[msg.sender][_stakeId];
        PoolInfo storage pool = poolInfo[stake.poolId];
        require(stake.isActive,'already withdrawn');

        uint256 _amount = stake.amount ;
        stake.isActive=false;
        pool.totalStaked-= _amount;
        _updatePool(stake.poolId);
        if(pool.emergencyWithdrawFee>0){
            uint256 fee = (_amount * pool.emergencyWithdrawFee) / 10_000;
            _amount -= fee;
            token.safeTransfer(address(marketingWallet), fee/2);
            pool.addedReward+= fee/2;
        }
       
        token.safeTransfer(address(msg.sender), _amount);

        emit EmergencyWithdraw(msg.sender, _amount);
    }


}