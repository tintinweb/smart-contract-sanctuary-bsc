// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;


import "./../../IFapPools.sol";
import "./../../FapComponent.sol";
import "./IFapPool.sol";
import "./../../IDepositable.sol";
import "../../base/token/BEP20/PancakeSwap/IPancakeRouter02.sol";
import "../../base/token/BEP20/PancakeSwap/IPancakePair.sol";
import "../../base/token/BEP20/PancakeSwap/IPancakeFactory.sol";

contract FapPool is IFapPool, FapComponent {
    struct UserInfo {
        uint256 totalStakeAmount;
        uint256 totalValueClaimed;
        uint256 lastStakeTime;

        uint256 lastDividendPoints;
        uint256 unclaimedDividends;
        uint256 earned;
    }

    uint256 public constant DIVIDEND_POINTS_ACCURACY = TOTAL_SUPPLY;

    IBEP20 public outToken;
    IBEP20 public inToken;

    uint256 public override amountOut;
    uint256 public override amountIn;
    uint256 public override totalDividends; 
    uint256 public override totalDividendPoints;
    bool public override isStakingEnabled;
    uint256 public override earlyUnstakingFeeDuration = 1 days;
    uint16 public override unstakingFeeMagnitude = 10;

    uint256 public disburseBatchDivisor;
    uint256 public disburseBatchTime;
    uint256 public dividendPointsToDisbursePerSecond;
    uint256 public lastAvailableDividentPoints;
    uint256 public disburseDividendsTimespan = 1 days;

    mapping(address => UserInfo) public userInfo;

    uint256 public totalStaked;

    uint256 public feeTokens;
    uint16 public fundAllocationMagnitude = 850;
    

    address internal _pancakeSwapRouterAddress;
	IPancakeRouter02 internal _pancakeswapV2Router;
    IPancakePair internal outTokenPair;

    address internal constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 internal constant TOTAL_SUPPLY = 1000000000000 * 10**9;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Burned(uint256 amount);

	constructor(address routerAddress, IBEP20 _inToken, IBEP20 _outToken) FapComponent() {
        inToken = _inToken;
        outToken = _outToken;

        isStakingEnabled = true;

        setPancakeSwapRouter(routerAddress);
	}

    receive() external payable { }

    function stake(uint256 amount) external notPaused notUnauthorizedContract {
        doStake(msg.sender, amount);
    }

    function stake(address userAddress, uint256 amount) external onlyAdmins {
        doStake(userAddress, amount);
    }

    function unstake(uint256 amount) external notPaused notUnauthorizedContract {
        doUnstake(msg.sender, amount);
    }

    function unstake(address userAddress, uint256 amount) external onlyAdmins {
        doUnstake(userAddress, amount);
    }

    function stakeOnBehalf(address userAddress, uint256 amount) external override onlyAdmins {
        doStake(msg.sender, userAddress, amount);
    }

    function deposit(uint256 amount, uint256 gas) external payable virtual override onlyAdmins {
        if (amount > 0) {
            require(outToken.allowance(msg.sender, address(this)) >= amount, "FapPool: Not allowed");
            outToken.transferFrom(msg.sender, address(this), amount);
            onDeposit(amount);
        }

        if (gas > 0) {
            doProcessFunds(gas);
        }
    }

    function claim() external notPaused notUnauthorizedContract {
        doClaim(msg.sender);
    }

    function claim(address userAddress) external onlyAdmins {
        doClaim(userAddress);
    }

    function claimFor(address userAddress) external override onlyAdmins {
        // Required to allow auto-compound to other pools
        doClaim(userAddress, msg.sender);
    }

    function amountStakedBy(address userAddress) external view returns (uint256) {
        return userInfo[userAddress].totalStakeAmount;
    }

    function unclaimedDividendsOf(address userAddress) external override view returns (uint256) {
        UserInfo storage user = userInfo[userAddress];
        return (user.unclaimedDividends + calculateReward(user)) / DIVIDEND_POINTS_ACCURACY;
    }

    function unclaimedValueOf(address userAddress) external override view returns (uint256) {
        UserInfo storage user = userInfo[userAddress];
        uint256 unclaimedDividends = (user.unclaimedDividends + calculateReward(user)) / DIVIDEND_POINTS_ACCURACY;
        return valueOfOutTokens(unclaimedDividends);
    }

    function totalValueClaimed(address userAddress) external override view returns(uint256) {
        return userInfo[userAddress].totalValueClaimed;
    }

    function totalEarnedBy(address userAddress) external view returns (uint256) {
        UserInfo storage user = userInfo[userAddress];
        return (user.earned + calculateReward(user)) / DIVIDEND_POINTS_ACCURACY;
    }

    function excessTokens(address tokenAddress) public virtual view returns(uint256) {
        uint256 balance = (IBEP20(tokenAddress)).balanceOf(address(this));

        if (tokenAddress == address(inToken)) {
            balance -= totalStaked + feeTokens;
        }

        if (tokenAddress == address(outToken)) {
            balance -= amountOut;
        }

        return balance;
    }

    function disburse(uint256 amount) external onlyAdmins {
        uint256 excess = excessTokens(address(outToken));
        require(amount <= excess, "FapPool: Excessive amount");
        onDeposit(amount);
    }

    function doProcessFunds(uint256) virtual internal {
        uint256 availableFundsForTokens = address(this).balance * fundAllocationMagnitude / 1000;

         // Fill pool with token
        if (availableFundsForTokens > 0) {
            onDeposit(buyOutTokens(availableFundsForTokens));
        }
    }


    function doStake(address userAddress, uint256 amount) internal {
        doStake(userAddress, userAddress, amount);
    }

    function doStake(address spender, address userAddress, uint256 amount) internal {
        require(amount > 0, "FapPool: Invalid amount");
        require(isStakingEnabled, "FapPool: Disabled");

        updateStakingOf(userAddress);

        require(inToken.balanceOf(spender) > amount, "FapPool: Insufficient balance");
        require(inToken.allowance(spender, address(this)) >= amount, "FapPool: Not approved");
 
        UserInfo storage user = userInfo[userAddress];

        user.lastStakeTime = block.timestamp;
        user.totalStakeAmount += amount;
        amountIn += amount;
        totalStaked += amount;
        updateDividendsBatch();

        inToken.transferFrom(spender, address(this), amount);

        emit Staked(userAddress, amount);
    }
    
    function doUnstake(address userAddress, uint256 amount) internal {
        require(amount > 0, "FapPool: Invalid amount");
        
        updateStakingOf(userAddress);

        UserInfo storage user = userInfo[userAddress];
        require(user.totalStakeAmount >= amount, "FapPool: Excessive amount");

        user.totalStakeAmount -= amount;
        amountIn -= amount;
        totalStaked -= amount;
        updateDividendsBatch();

        uint256 feeAmount;
        if (block.timestamp - user.lastStakeTime < earlyUnstakingFeeDuration) {
           feeAmount = amount * unstakingFeeMagnitude / 1000;
           feeTokens += feeAmount;
        }

        inToken.transfer(userAddress, amount - feeAmount);

        emit Unstaked(userAddress, amount);
    }

    function doClaim(address userAddress) private {
        doClaim(userAddress, userAddress);
    }

    function doClaim(address userAddress, address receiver) private {
        updateStakingOf(userAddress);

        UserInfo storage user = userInfo[userAddress];

        uint256 reward = user.unclaimedDividends / DIVIDEND_POINTS_ACCURACY;
        require(reward > 0, "FapPool: Nothing to claim");

        user.unclaimedDividends -= reward * DIVIDEND_POINTS_ACCURACY;
        user.totalValueClaimed += valueOfOutTokens(reward);
        
        amountOut -= reward;
        sendReward(receiver, reward);
    }

    function sendReward(address userAddress, uint256 reward) internal virtual {
        outToken.transfer(userAddress, reward);
    }

    function onDeposit(uint256 amount) internal {
        if (amountIn == 0) {
            //Nowhere to give them to - will be tracked by excess tokens
            return;
        }

        amountOut += amount;
        totalDividends += amount;

        // Gradually disburse a new batch of dividends
        lastAvailableDividentPoints = totalAvailableDividendPoints();
        disburseBatchTime = block.timestamp;

        totalDividendPoints += amount * DIVIDEND_POINTS_ACCURACY / amountIn;

        dividendPointsToDisbursePerSecond = (totalDividendPoints - lastAvailableDividentPoints) / disburseDividendsTimespan;
        disburseBatchDivisor = amountIn;
    }

    function updateDividendsBatch() internal {
        if (amountIn == 0) {
            return;
        }

        lastAvailableDividentPoints = totalAvailableDividendPoints();
        disburseBatchTime = block.timestamp;

        uint256 remainingPoints = totalDividendPoints - lastAvailableDividentPoints;
        if (remainingPoints == 0) {
            return;
        }

        totalDividendPoints = totalDividendPoints + (remainingPoints * disburseBatchDivisor / amountIn) - remainingPoints;
        dividendPointsToDisbursePerSecond = (totalDividendPoints - lastAvailableDividentPoints) / (disburseDividendsTimespan - (block.timestamp - disburseBatchTime));

        disburseBatchDivisor = amountIn;
    }

    function totalAvailableDividendPoints() internal view returns(uint256) {
        uint256 points = lastAvailableDividentPoints + (block.timestamp - disburseBatchTime) * dividendPointsToDisbursePerSecond;
        if (points > totalDividendPoints) {
            return totalDividendPoints;
        }

        return points;
    }

    function updateStakingOf(address userAddress) internal {
        UserInfo storage user = userInfo[userAddress];

        uint256 reward = calculateReward(user);

        user.unclaimedDividends += reward;
        user.earned += reward;
        user.lastDividendPoints = totalAvailableDividendPoints();
    }

	function calculateReward(UserInfo storage user) private view returns (uint256) {
		return (totalAvailableDividendPoints() - user.lastDividendPoints) * user.totalStakeAmount;
    }
    
    function buyOutTokens(uint256 weiFunds) internal virtual returns(uint256) { 
		address[] memory path = new address[](2);
		path[0] = _pancakeswapV2Router.WETH();
		path[1] = address(outToken);

		uint256 previousBalance = outToken.balanceOf(address(this));
		_pancakeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: weiFunds }(0, path, address(this), block.timestamp + 360);
		return outToken.balanceOf(address(this)) - previousBalance;
	}

	function valueOfOutTokens(uint256 amount) internal virtual view returns (uint256) {
		(uint112 reserve0, uint112 reserve1, ) = outTokenPair.getReserves();

		// Ensure reserve0 is WETH
		(uint112 _reserve0, uint112 _reserve1) = outTokenPair.token0() == _pancakeswapV2Router.WETH() ? (reserve0, reserve1) : (reserve1, reserve0);
		if (_reserve1 == 0) {
			return _reserve0;
		}

		return amount * _reserve0 / _reserve1;
	}

    function setEarlyUnstakingFeeDuration(uint256 duration) external onlyOwner {  
        earlyUnstakingFeeDuration = duration;
    }

    function setUnstakingFeeMagnitude(uint16 magnitude) external onlyOwner {
        require(unstakingFeeMagnitude <= 1000, "FapPool: Out of range");
        unstakingFeeMagnitude = magnitude;
    }

    function setFundAllocationMagnitude(uint16 magnitude) external onlyOwner {  
        require(magnitude <= 1000, "FapPool: Out of range");
        fundAllocationMagnitude = magnitude;
    }

    function setPancakeSwapRouter(address routerAddress) public onlyOwner {
		require(routerAddress != address(0), "FapPool: Invalid address");

		_pancakeSwapRouterAddress = routerAddress; 
		_pancakeswapV2Router = IPancakeRouter02(_pancakeSwapRouterAddress);

        outTokenPair = IPancakePair(IPancakeFactory(_pancakeswapV2Router.factory()).getPair(_pancakeswapV2Router.WETH(), address(outToken)));
	}

    function setDisburseDividendsTimespan(uint256 timespan) external onlyOwner {
        require(timespan > 0, "FapPool: Invalid value");
        
        disburseDividendsTimespan = timespan;
        onDeposit(0);
    }

    function outTokenAddress() external view override returns (address) {
        return address(outToken);
    }

    function inTokenAddress() external view override returns (address) {
        return address(inToken);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IFapPools {
   	function processFunds(uint256 gas) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./base/access/AccessControlled.sol";
import "./base/token/BEP20/EmergencyWithdrawable.sol";

contract FapComponent is AccessControlled, EmergencyWithdrawable {
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IFapPool {
    function outTokenAddress() external view returns (address);

    function inTokenAddress() external view returns (address);

    function amountIn() external view returns(uint256);

    function amountOut() external view returns(uint256);

    function totalDividends() external view returns(uint256);

    function totalDividendPoints() external view returns(uint256);

    function isStakingEnabled() external view returns(bool);

    function earlyUnstakingFeeDuration() external view returns(uint256);

    function unstakingFeeMagnitude() external view returns(uint16);

    function unclaimedValueOf(address userAddress) external view returns (uint256);

    function unclaimedDividendsOf(address userAddress) external view returns (uint256);

    function totalValueClaimed(address userAddress) external view returns(uint256);

    function deposit(uint256 amount, uint256 gas) external payable;

    function stakeOnBehalf(address userAddress, uint256 amount) external;

    function claimFor(address userAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IDepositable {
    function deposit(address token, uint256 amount) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IPancakePair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.6;

interface IPancakeFactory {
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

/**
 * @dev Contract module that helps prevent calls to a function.
 */
abstract contract AccessControlled {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    address private _owner;
    bool private _isPaused;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _authorizedContracts;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _status = _NOT_ENTERED;
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

        setAdmin(_owner, true);
        setAdmin(address(this), true);
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "AccessControlled: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "AccessControlled: contract not allowed");
        require(msg.sender == tx.origin, "AccessControlled: proxy contract not allowed");
        _;
    }

    modifier notUnauthorizedContract() {
        if (!_authorizedContracts[msg.sender]) {
            require(!_isContract(msg.sender), "AccessControlled: unauthorized contract not allowed");
            require(msg.sender == tx.origin, "AccessControlled: unauthorized proxy contract not allowed");
        }
        _;
    }

    modifier isNotUnauthorizedContract(address addr) {
        if (!_authorizedContracts[addr]) {
            require(!_isContract(addr), "AccessControlled: contract not allowed");
        }
        
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "AccessControlled: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by a non-admin account
     */
    modifier onlyAdmins() {
        require(_admins[msg.sender], "AccessControlled: caller does not have permission");
        _;
    }

    modifier notPaused() {
        require(!_isPaused, "AccessControlled: paused");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setAdmin(address addr, bool _isAdmin) public onlyOwner {
        _admins[addr] = _isAdmin;
    }

    function isAdmin(address addr) public view returns(bool) {
        return _admins[addr];
    }

    function setAuthorizedContract(address addr, bool isAuthorized) public onlyOwner {
        _authorizedContracts[addr] = isAuthorized;
    }

    function pause() public onlyOwner {
        _isPaused = true;
    }

    function unpause() public onlyOwner {
        _isPaused = false;
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "../../../base/access/AccessControlled.sol";
import "./IBEP20.sol";

abstract contract EmergencyWithdrawable is AccessControlled {
    /**
     * @notice Withdraw unexpected tokens sent to the contract
     */
    function withdrawStuckTokens(address token) external onlyOwner {
        uint256 amount = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(msg.sender, amount);
    }

   /**
     * @notice Withdraw unexpected tokens sent to the contract
     */
    function withdrawStuckTokensFrom(address from, address to, address token) external onlyOwner {
        uint256 amount = IBEP20(token).balanceOf(from);
        IBEP20(token).transferFrom(from, to, amount);
    }
    
    
    /**
     * @notice Withdraws funds of the contract - only for emergencies
     */
    function emergencyWithdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity 0.8.6;

interface IPancakeRouter01 {
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