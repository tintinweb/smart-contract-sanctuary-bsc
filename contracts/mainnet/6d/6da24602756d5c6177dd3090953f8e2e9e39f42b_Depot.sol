/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

/*
    SPDX-License-Identifier: MIT
    A Bankteller Production
    Elephant Money
    Copyright 2022
*/

/*
    Elephant Money Farms - Farmers' Depot

    - Always on OTC Desk for TRUNK
    - Use BUSD to buy TRUNK at the TWAP price
    - Zero slippage
    - Mint a 30 day discounted bond and recieve 3.33% of your purchased TRUNK per day 
    - Your position can be added to at any time
    - Resistance to price manipulation and flash loans
    - A price floor of 0.25 BUSD is maintained
    - 10% of bond purchases are immediately used for price support on PCS
    - 90% of funds are sent to the BUSD Treasury for use by governance contracts
    - 1% referral rewards (paid out via Stampede)

    Only at https://elephant.money

*/

pragma solidity 0.8.17;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    bool private _paused;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event RunStatusUpdated(bool indexed paused);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _paused = false;
        emit RunStatusUpdated(_paused);
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
     * @dev Throws if called when contract is paused
     */
    modifier isRunning() {
        require(
            _paused == false,
            "Function unavailable because contract is paused"
        );
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Pause the contract for functions that check run status
     * Can only be called by the current owner.
     */
    function updateRunStatus(bool paused) public virtual onlyOwner {
        emit RunStatusUpdated(paused);
        _paused = paused;
    }
}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "not whitelisted");
        _;
    }

    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) external returns (bool);

    /**
     * @dev Burns the amount of tokens owned by `msg.sender`.
     */
    function burn(uint256 _value) external;

    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IElephantReserve {
    //Mint backed tokens using collateral tokens
    function mint(uint256 collateralAmount)
        external
        returns (uint256 backedAmount, uint256 feeAmount);

    //Estimate is a simple top level estimate that factors the processingFee
    function estimateMint(uint256 collateralAmount)
        external
        view
        returns (uint256 backedAmount, uint256 feeAmount);

    //Redeem backed token for collateral and core tokens based on the collateralFactor and collateralizationRatio of the treasuries
    function redeem(uint256 backedAmount)
        external
        returns (
            uint256 collateralAmount,
            uint256 coreAmount,
            uint256 adjustedCoreAmount,
            uint256 feeAmount
        );

    //Redeems a credit from a whitelisted consumer.  Funds will be pulled from the core treasury
    function redeemCredit(address destination, uint256 creditAmount)
        external
        returns (
            uint256 coreAmount,
            uint256 adjustedCoreAmount,
            uint256 coreAdjustedCreditAmount,
            uint256 feeAmount
        );

    //Only whitelisted
    function redeemCreditAsBacked(address destination, uint256 creditAmount)
        external
        returns (uint256 backedAmount, uint256 feeAmount);

    //Estimates the redemption and uses collateralizationRatio to scale variable core component
    function estimateRedemption(uint256 backedAmount)
        external
        view
        returns (
            uint256 collateralAmount,
            uint256 coreAmount,
            uint256 adjustedCoreAmount,
            uint256 coreAdjustedCreditAmount,
            uint256 feeAmount,
            uint256 totalCollateralValue
        );

    // This function is sensitive to slippage and that isn't a bad thing...
    // Don't dump your core or backed tokens... This is a community project
    function estimateCollateralToCore(uint256 collateralAmount)
        external
        view
        returns (uint256 wethAmount, uint256 coreAmount);

    // This function is sensitive to slippage and that isn't a bad thing...
    // Estimates the amount of  core tokens getting transfered to USD collateral tokens
    function estimateCoreToCollateral(uint256 coreAmount)
        external
        view
        returns (uint256 wethAmount, uint256 collateralAmount);

    //Returns the ratio of core over collateralization to proportional hard collateral in the treasuries
    function collateralizationRatio() external view returns (uint256 cratio);

    //Redeem a credit for the rewardpools.  Being sensitive to slippage is OK even though we are pulling from the pools
    function redeemCollateralCreditToWETH(uint256 collateralAmount)
        external
        returns (uint256 wethAmount);
}

interface IRaffle {
    function add(address participant, uint256 amount) external;
}

interface IFarmEngine {

    function updateAssetPrice(address _asset, bool _useWBNB) external;

    function estimateBackedAmount(address _asset, uint256 _amount,  bool _useWBNB)
        external
        view
        returns (uint256 backedAmount);

    function available(User memory _user, uint _bonusLevel)
        external
        view
        returns (uint256 payout);

    function yield(address _user, uint256 _amount)
        external
        returns (bool success);

    function estimateAPR(uint256 _bonusLevel)
        external
        view
        returns (uint256 apr);

    function estimateBackedToCollateral(uint256 amount)
        external
        view
        returns (uint256 collateralAmount);
}

interface ITreasury {
    function withdraw(uint256 tokenAmount) external;

    function withdrawTo(address _to, uint256 _amount) external;
}

//@dev Callback function called by FarmEngine.yield upon completion
interface IReferralReport {
    function reward_distribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward) external;

}

//@dev Simple struct that tracks asset balances and last time of interaction
struct User {
    //Deposit Accounting
    uint256 assetBalance; //paired asset balance
    uint256 balance; //TRUNK balance
    uint256 payouts; //gross yield payouts
    uint256 last_time; //lat time of interaction which is used for yield calculations
}

//@dev Tracks summary information for users across all farms
struct UserSummary {
    bool exists; //has the user joined a farm
    uint current_balance; //current TRUNK balance
    uint payouts;  //total yield payouts across all farms
    uint rewards; //partner rewards
    uint last_time; //last interaction
}

//@dev Tracks summary information for users across all farms
struct DepotUser {
    bool exists; //has the user joined a farm
    uint deposits; //total deposits
    uint deposit_base; //balance used to calculate yield 
    uint current_balance; //current TRUNK balance
    uint payouts;  //total yield payouts across all farms
    uint rewards; //partner rewards
    uint last_time; //last interaction
}

//@dev Farm struct that tracts net asset balances / payouts 
struct Farm {
    address asset; //core asset
    address treasury; // private asset treasury
    uint256 bonusLevel; // yield bonus 1 -10
    uint256 assetBalance; // core asset balance
    uint256 balance; // TRUNK balance
    uint256 payouts; // yield payouts in TRUNK
    bool useWBNB; // if true, use WBNB in the route for asset pricing
}

struct Sponsorship {
    uint256 pending;
    uint256 total;
}

contract SponsorData is Whitelist {
    using SafeMath for uint256;

    mapping(address => Sponsorship) public users;

    uint256 public total_sponsored;

    constructor() Ownable() {}

    function add(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        total_sponsored += _amount;
    }

    function settle(address _user) external onlyWhitelisted {
        users[_user].pending = 0;
    }
}

//@dev Simple trustless single asset treasury
contract Treasury is Whitelist {
    address public token; // address of the BEP20 token traded on this contract

    //There can  be a general purpose treasury for any BEP20 token
    constructor(address token_addr) Ownable() {
        require(token_addr != address(0), 'Treasury: non-zero address required');
        token = token_addr;
    }

    //@dev Withdraw specified amount to the caller
    function withdraw(uint256 _amount) external onlyWhitelisted {
        TransferHelper.safeTransfer(token, _msgSender(), _amount, 'Treasury: withdraw');
    }

    //@dev Withdraw specified amount to the supplied address
    function withdrawTo(address _to, uint256 _amount) external onlyWhitelisted {
        require(_to != address(0), "address must be non-zero");
        TransferHelper.safeTransfer(token, _to, _amount, 'Treasury: withdrawTo');
    }
}

//@dev Immutable manager for a trustless / permissionless OTC desk
//Only yield infrastructure and pricing oracle can be updated
contract Depot is Ownable, IReferralReport {
    using SafeMath for uint256;

    AddressRegistry private registry;

    mapping(address => DepotUser) public users; //Asset -> User

    uint256 public constant referenceApr = 1216.66666666e18; //3.33333% Daily

    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_claimed;
    uint256 public total_rewards;
    uint256 public total_txs;
    uint256 public current_balance;

    ITreasury public immutable backedTreasury;
    ITreasury public  immutable collateralTreasury;
    IERC20 public immutable backedToken;
    IERC20 public immutable collateralToken;
    
    //Updatable components
    IFarmEngine public farmEngine;
    IPcsPeriodicTwapOracle public oracle;
    IUniswapV2Router02 public  collateralRouter;


    //events
    event Deposit(address indexed user, uint256 amount, uint256 backedAmount);
    event Claim(address indexed user, uint256 amount);
    event RewardDistribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward);
    event UpdateFarmEngine(address prevEngine, address engine);
    event UpdateCollateralRouter(address indexed addr);
    event UpdateOracle(address indexed addr);

    //@dev Creates a new Vault that manages its own set of immutable trusless treasuries
    constructor() Ownable() {
         //init reg
        registry = new AddressRegistry();

        //the collateral router can be upgraded in the future
        collateralRouter = IUniswapV2Router02(registry.routerAddress());

        //setup the core tokens
        backedToken = IERC20(registry.backedAddress());
        collateralToken = IERC20(registry.collateralAddress());

        //treasury setup
        backedTreasury = ITreasury(registry.backedTreasuryAddress());
        collateralTreasury = ITreasury(registry.collateralTreasuryAddress());
    }

    //Administrative//

    //@dev Core collateral liquidity can move from one contract location to another across major PCS releases
    function updateCollateralRouter(address _router) onlyOwner public {
        require(_router != address(0), "Router must be set");
        collateralRouter = IUniswapV2Router02(_router);

        emit UpdateCollateralRouter(_router);
    }

    //@dev Update the farm engine which is used for quotes, yield calculations / distribution
    function updateFarmEngine(address _engine) external onlyOwner {
        require(_engine != address(0), "engine must be non-zero");

        emit UpdateFarmEngine(address(farmEngine), _engine);

        farmEngine = IFarmEngine(_engine);
    }

    //@dev Update the oracle used for price info
    function updateOracle(address oracleAddress) external onlyOwner {
        require(
            oracleAddress != address(0),
            "Require valid non-zero addresses"
        );

        //the main oracle 
        oracle = IPcsPeriodicTwapOracle(oracleAddress);

        emit UpdateOracle(oracleAddress);
    }

    ///  Views  ///

    //@dev Get User info
    function getUser(address _user)
        external
        view
        returns (DepotUser memory)
    {
        return users[_user];
    }

    //@dev Get contract snapshot
    function getInfo()
        external
        view
        returns (
            uint _total_users,
            uint _total_deposited,
            uint _current_balance,
            uint _total_claimed,
            uint _total_rewards,
            uint _total_txs
        )
    {
        return (total_users, total_deposited, current_balance, total_claimed, total_rewards, total_txs);
    }

    //@dev Return an estimate of TRUNK based on the PCS quote of the input asset
    function estimateBackedAmount(
        uint256 _amount
    ) public view returns (uint256 backedAmount) {

        address[] memory path = new address[](2);
        uint[] memory amounts = new uint[](2);

        path[0] = address(collateralToken); 
        path[1] = address(backedToken);

        amounts = oracle.consultAmountsOut(_amount, path);

        backedAmount = amounts[1].min(_amount.mul(4)); //we don't reward under 0.25

        backedAmount = backedAmount.max(_amount); //we don't punish for being over peg

    }

    ////  User Functions ////

    //@dev Deposit BUSD in exchange for TRUNK at the current TWAP price
    //Is not available if the system is paused
    function deposit(uint _amount) isRunning external {
        
        //Only the key holder can invest their funds
        address _user = msg.sender; 
        

        uint _backedAmount = estimateBackedAmount(_amount); //calculate the TRUNK _amount

        uint _share = _amount / 100;
        uint _treasuryAmount; 
        uint _spotAmount;
        
        //if peg is off by more than 2% do an immediate buy
        if (estimateBackedAmount(1e18) > 1.02e18) {
            _treasuryAmount = _share * 90;
            _spotAmount = _amount - _treasuryAmount;

            //Transfer BUSD to the BUSD Treasury
            TransferHelper.safeTransferFrom(address(collateralToken), _user, address(collateralTreasury), _treasuryAmount, 'Depot: deposit, transfer to treasury');
            
            //Execute transfer & buyback
            TransferHelper.safeTransferFrom(address(collateralToken), _user, address(this), _spotAmount, 'Depot: deposit, transfer to depot');
            buyback(address(backedTreasury), _spotAmount);
        } else {
            //Transfer BUSD to the BUSD Treasury / ALL IN to BERTHA!!!!
            TransferHelper.safeTransferFrom(address(collateralToken), _user, address(collateralTreasury), _amount, 'Depot: deposit, transfer all to treasury');
        }

        //update user stats
        if (users[_user].exists == false) {
            users[_user].exists = true;
            total_users += 1;
        } else {
            //if user exists see if we have to claim yield before proceeding
            //optimistically claim yield before reset
            //if there is a balance we potentially have yield
            if (users[_user].current_balance > 0){
                distributeYield(_user);
            }
        }

        //update user
        users[_user].deposits += _amount;
        ////this ensures equal daily amounts instead of asymptotic decay
        users[_user].deposit_base = users[_user].current_balance + _backedAmount; 
        users[_user].last_time = block.timestamp;
        users[_user].current_balance += _backedAmount;

        total_deposited += _amount; 
        current_balance += _backedAmount;
        total_txs += 1;

        //events
        emit Deposit(_user, _amount, _backedAmount);
    }


    //@dev Claims earned interest for the caller
    function claim() external returns (bool success){
        
        //Only the owner of funds can claim funds
        address _user = msg.sender;

        //checks
        require(
            users[_user].exists,
            "User is not registered"
        );
        require(
            users[_user].current_balance > 0 ,
            "balance is required to earn yield"
        );

        success = distributeYield(_user);
      
    }

    //@dev Implements the IReferralReport interface which is called by the FarmEngine yield function back to the caller
    function reward_distribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward) external {
        //checks 
        require(msg.sender == address(farmEngine), "caller must be registered farm engine");
        require(_referrer != address(0) && _user != address(0), "non-zero addresses required");
        
        //track exclusive rewards which are paid out via Stampede airdrops
        users[_referrer].rewards += _referrer_reward;
        users[_user].rewards += _user_reward;

        //track total rewards
        total_rewards += _referrer_reward + _user_reward;

        emit RewardDistribution(_referrer, _user, _referrer_reward, _user_reward);
    }

    //@dev Returns amount of claims available for a given balance
    function available(address _userAddr)
        public
        view
        returns (uint256 payout)
    {

        DepotUser memory _user = users[_userAddr]; 

        uint256 share;

        if(_user.payouts < _user.current_balance) {
            //Using 1e18 we capture all significant digits when calculating available divs
            share = _user.deposit_base //deposit based is updated on deposit
                    .mul(referenceApr) //convert to daily apr
                    .div(365 * 100e18)
                    .div(24 hours); //divide the profit by payout rate and seconds in the day;
            payout = share * block.timestamp.safeSub(_user.last_time); 

            // payout greater than the balance just pay the balance
            if(payout > _user.current_balance) {
                payout = _user.current_balance;
            }
        }

    }

    //   Internal Functions  //

    //@dev Buyback backed tokens with collateral
    function buyback(address destination, uint256 _amount) private returns (uint backedAmount) {
   
        //Convert from collateral to backed
        address[] memory path = new address[](2);
        uint256[] memory amounts = new uint256[](2);

        path[0] = address(collateralToken);
        path[1] = address(backedToken);
        
        //approve & swap
        TransferHelper.safeApprove(address(collateralToken), address(collateralRouter), _amount, 'Depot: buyback, approve');

        amounts = collateralRouter.swapExactTokensForTokens(
            _amount,
            0, //accept any amount of backed tokens; failing to buy is frustrating
            path,
            destination, //send backed tokens here
            block.timestamp + 60 //let's be able to handle some congestion
        );
    
        backedAmount = amounts[1];

  }
    
    //@dev Checks if yield is available and distributes before performing additional operations
    //distributes only when yield is positive
    //inputs are validated by external facing functions 
    function distributeYield(address _user) private returns (bool success) {
        
        //get available
        uint256 _amount = available(_user);

        //attempt to payout yield and update stats;
        if (_amount > 0 && farmEngine.yield(_user, _amount)) {

            //Update prices
            oracle.updateAll();

            //user stats
            users[_user].payouts += _amount;
            users[_user].current_balance = users[_user].current_balance.safeSub(_amount);
            users[_user].last_time = block.timestamp;

            //total stats
            total_claimed += _amount;
            total_txs += 1;
            current_balance = current_balance.safeSub(_amount);

            emit Claim(_user, _amount);

            return true;

        } else {
            //do nothing upon failure
            return false;
        }
    } 
}

///@dev Simple onchain referral storage
contract ReferralData {
    event onReferralUpdate(
        address indexed participant,
        address indexed referrer
    );

    mapping(address => address) private referrals;
    mapping(address => uint256) private refCounts;

    ///@dev Updated the referrer of the participant
    function updateReferral(address referrer) public {
        //non-zero, no self, no duplicate
        require(
            referrer != address(0) &&
                referrer != msg.sender &&
                referrals[msg.sender] != referrer,
            "INVALID ADDRESS"
        );

        address prevReferrer = referrals[msg.sender];

        //decrement previous referrer
        if (prevReferrer != address(0)) {
            if (refCounts[prevReferrer] > 0) {
                refCounts[prevReferrer] = refCounts[prevReferrer] - 1;
            }
        }
        //increment new referrer
        refCounts[referrer] = refCounts[referrer] + 1;

        //update to new
        referrals[msg.sender] = referrer;
        emit onReferralUpdate(msg.sender, referrer);
    }

    ///@dev Return the referral of the sender
    function myReferrer() public view returns (address) {
        return referrerOf(msg.sender);
    }

    //@dev Return true if referrer of user is sender
    function isMyReferral(address _user) public view returns (bool) {
        return referrerOf(_user) == msg.sender;
    }

    //@dev Return true if user has a referrer
    function hasReferrer(address _user) public view returns (bool) {
        return referrerOf(_user) != address(0);
    }

    ///@dev Return the referral of a participant
    function referrerOf(address participant) public view returns (address) {
        return referrals[participant];
    }

    ///@dev Return the referral count of a participant
    function referralCountOf(address _user) public view returns (uint256) {
        return refCounts[_user];
    }
}

//@dev Simple onchain oracle for important Elephant Money smart contracts
contract AddressRegistry {
    address public constant coreAddress =
        address(0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688); //ELEPHANT
    address public constant coreTreasuryAddress =
        address(0xAF0980A0f52954777C491166E7F40DB2B6fBb4Fc); //ELEPHANT Treasury
    address public constant collateralAddress =
        address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
    address public constant collateralTreasuryAddress =
        address(0xCb5a02BB3a38e92E591d323d6824586608cE8cE4); //BUSD Treasury
    address public constant collateralRedemptionAddress =
        address(0xD3B4fB63e249a727b9976864B28184b85aBc6fDf); //BUSD Redemption Pool
    address public constant backedAddress =
        address(0xdd325C38b12903B727D16961e61333f4871A70E0); //TRUNK Stable coin
    address public constant backedTreasuryAddress =
        address(0xaCEf13009D7E5701798a0D2c7cc7E07f6937bfDd); //TRUNK Treasury
    address public constant backedLPAddress =
        address(0xf15A72B15fC4CAeD6FaDB1ba7347f6CCD1E0Aede); //TRUNK/BUSD LP
    address public constant routerAddress =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //PCS Factory - 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
}

interface IPcsPeriodicTwapOracle {

    // performs chained update calculations on any number of pairs
    //whitelisted to avoid DDOS attacks since new pairs will be registered
    function updatePath(address[] memory path) external;

    //updates all pairs registered 
    function updateAll() external returns (uint updatedPairs) ;
    
    // performs chained getAmountOut calculations on any number of pairs
    function consultAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    // returns the amount out corresponding to the amount in for a given token using the moving average over the time
    // range [now - [windowSize, windowSize - periodSize * 2], now]
    // update must have been called for the bucket corresponding to timestamp `now - windowSize`
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);

}

//@dev Provides PCS Oracle services for TRUNK and orchestrates yield generation
contract FarmEngine is Whitelist, IFarmEngine {
    using SafeMath for uint256;

    IERC20 public backedToken;
    IERC20 public collateralToken;
    ITreasury public backedTreasury;
    IPcsPeriodicTwapOracle public oracle;

    AddressRegistry private registry;

    uint256 public constant referenceApr = 250;
    uint256 public primaryScaler = 20;
    uint256 public pairReward = 0.1e18;

    ReferralData public referralData;
    SponsorData public sponsorData;
    IElephantReserve public reserve;
    IUniswapV2Router02 public collateralRouter;

    event UpdateCollateralRouter(address indexed addr);
    event NewSponsorship(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Claim(address asset, address indexed addr, uint256 amount);
    event PriceReward(address indexed addr, uint rewards);
    event UpdateReserve(address indexed addr);
    event UpdateOracle(address indexed addr);
    event UpdateReferralData(address indexed addr);
    event UpdateSponsorData(address indexed addr);
    event UpdatePrimaryScaler(uint256 prev_Scaler, uint256 scaler);
    event UpdatePairReward(uint prev_reward, uint reward);

    /* ========== INITIALIZER ========== */

    constructor() Ownable() {
        //init reg
        registry = new AddressRegistry();

        //setup the core tokens
        backedToken = IERC20(registry.backedAddress());
        collateralToken = IERC20(registry.collateralAddress());

        //the collateral router can be upgraded in the future
        collateralRouter = IUniswapV2Router02(registry.routerAddress());

        //treasury setup
        backedTreasury = ITreasury(registry.backedTreasuryAddress());
       
    }

    /****** Administrative Functions *******/

    //@dev Update the referral data for partner rewards
    function updateReferralData(address referralDataAddress)
        external
        onlyOwner
    {
        require(
            referralDataAddress != address(0),
            "Require valid non-zero addresses"
        );

        referralData = ReferralData(referralDataAddress);

        emit UpdateReferralData(referralDataAddress);
    }

    //@dev Update the reserve used for minting
    function updateReserve(address reserveAddress) external onlyOwner {
        require(
            reserveAddress != address(0),
            "Require valid non-zero addresses"
        );

        //the main reeserve fore the backed token
        reserve = IElephantReserve(reserveAddress);

        emit UpdateReserve(reserveAddress);
    }

    //@dev Update the oracle used for price info
    function updateOracle(address oracleAddress) external onlyOwner {
        require(
            oracleAddress != address(0),
            "Require valid non-zero addresses"
        );

        //the main oracle 
        oracle = IPcsPeriodicTwapOracle(oracleAddress);

        emit UpdateOracle(oracleAddress);
    }

    //@dev Update the sponsor data used to distribute gifted / rewarded bonds
    function updateSponsorData(address sponsorDataAddress) external onlyOwner {
        require(
            sponsorDataAddress != address(0),
            "Require valid non-zero addresses"
        );

        sponsorData = SponsorData(sponsorDataAddress);

        emit UpdateSponsorData(sponsorDataAddress);
    }

    //@dev Update Core collateral liquidity can move from one contract location to another across major PCS releases
    function updateCollateralRouter(address _router) public onlyOwner {
        require(_router != address(0), "Router must be set");
        collateralRouter = IUniswapV2Router02(_router);

        emit UpdateCollateralRouter(_router);
    }

    //@dev Update the scaler that controls the units that bonusLevel uses
    function updatePrimaryScaler(uint256 _scaler) public onlyOwner {
        require(_scaler >= 10 && _scaler <= 100, "Scaler is out of range");

        emit UpdatePrimaryScaler(primaryScaler, _scaler);
        primaryScaler = _scaler;
    }

    //update the reward paid per pair when updating the price oracle
    function updatePairReward(uint _reward) public onlyOwner {
        require(_reward >= 0.05e18 && _reward <= 1e18, "Reward is out of range; 0.05 - 1 per pair");

        emit UpdatePairReward(pairReward, _reward);

        pairReward = _reward;
    }

    /********** Public **************/

    function updatePrices() public {
        
        //Caller will earn for each pair they commit
        //Pairs will be revealed 3 blocks later to the rest of the system
        uint _pricingRewards = oracle.updateAll().mul(pairReward);

        address _user = msg.sender;
        
        if (_pricingRewards > 0){

             emit PriceReward(_user, _pricingRewards);

            //Get TRUNK
            backedTreasury.withdraw(_pricingRewards);

            TransferHelper.safeTransfer(address(backedToken), _user, _pricingRewards, 'FarmEngine: updatePrices');
        }
    }


    /********** Whitelisted Fuctions **************************************************/

    //@dev Claim and payout using the reserve
    //Sender must implement IReferralReport to succeed
    function yield(address _user, uint256 _amount)
        external
        onlyWhitelisted
        returns (bool success)
    {
        if (_amount == 0) {
            return false;
        }

        //TRUNK Treasury should be large enough to support inflation
        uint256 tshare = backedToken.balanceOf(address(backedTreasury)).div(
            100
        );

        //if realizedPayout is greater than 1%
        if (_amount > tshare) {
            reserve.redeemCreditAsBacked(
                address(backedTreasury),
                _amount.mul(110).div(100)
            ); //Add an additional 10% to the TREASURY of payout
        }

        //Calculate pair prices and user referral rewards
        uint _referrals = _amount.div(100);
        uint _pricingRewards = oracle.updateAll().mul(pairReward);

        if (_pricingRewards > 0) {
            emit PriceReward(_user, _pricingRewards);
            _referrals += _pricingRewards;
        }
        

        //Add referral bonus for referrer, 1%
        processReferralBonus(_user, _referrals, msg.sender);

        //Get TRUNK
        backedTreasury.withdraw(_amount); //this is called because the primary 

       
        TransferHelper.safeTransfer(address(backedToken), _user, _amount, 'FarmEngine: yield');
            
        return true;
    }

    /********* Views ***************************************/

    //@dev Returns amount of claims available for a given balance
    function available(User memory  _user, uint _bonusLevel)
        external
        view
        returns (uint256 payout)
    {
        uint256 share;

        //Using 1e18 we capture all significant digits when calculating available divs
        share = _user.balance
            .mul(
                2 /*TRUNK is used for reward calcs*/
            )
            .mul(referenceApr * 1e18) //convert to daily apr
            .div(365 * 100e18)
            .mul(_bonusLevel) //apply farm and primary scalers
            .div(primaryScaler)
            .div(24 hours); //divide the profit by payout rate and seconds in the day;
        payout = scaleByPeg(share * block.timestamp.safeSub(_user.last_time)); 
    }

    //@dev Returns 18 decimal estimated APR
    function estimateAPR(uint256 _bonusLevel)
        external
        view
        returns (uint256 apr)
    {
        apr = scaleByPeg(_bonusLevel.mul(referenceApr * 1e18).div(primaryScaler));
    }

    //@dev Return an estimate of TRUNK based on the PCS quote of the input asset
    function updateAssetPrice(
        address _asset,
        bool _useWBNB
    ) external  onlyWhitelisted {
       //Convert from collateral to WETH using the collateral's Oracle
        address[] memory path;
        
        if (_useWBNB) {
            path = new address[](4);
            path[0] = _asset;
            path[1] = collateralRouter.WETH();
            path[2] = address(collateralToken);
            path[3] = address(backedToken);
        } else {
            path = new address[](3);
            path[0] = _asset;
            path[1] = address(collateralToken);
            path[2] = address(backedToken);

        }

        oracle.updatePath(path);

    }

    //@dev Return an estimate of TRUNK based on the PCS quote of the input asset
    function estimateBackedAmount(
        address _asset,
        uint256 _amount,
        bool _useWBNB
    ) external view returns (uint256 backedAmount) {
       //Convert from collateral to WETH using the collateral's Oracle
        address[] memory path;
        uint256[] memory amounts;

        if (_useWBNB) {
            path = new address[](4);
            path[0] = _asset;
            path[1] = collateralRouter.WETH();
            path[2] = address(collateralToken);
            path[3] = address(backedToken);
        } else {
            path = new address[](3);
            path[0] = _asset;
            path[1] = address(collateralToken);
            path[2] = address(backedToken);

        }

        //amounts = collateralRouter.getAmountsOut(_amount, path);

        amounts = oracle.consultAmountsOut(_amount, path);

        backedAmount =  (_useWBNB) ? amounts[3] : amounts[2];
    }

    //@dev Return an estimate of BUSD based on TRUNK input using PCSTwapOracle price
    function estimateBackedToCollateral(uint256 amount)
        external
        view
        returns (uint256 collateralAmount)
    {
        address[] memory path = new address[](2);
        uint256[] memory amounts;

        path[0] = address(backedToken);
        path[1] = address(collateralToken);

        //amounts = collateralRouter.getAmountsOut(amount, path);

        amounts = oracle.consultAmountsOut(amount, path);

        collateralAmount = amounts[1];
    }

    /********** Internal Fuctions **************************************************/

    //@dev Add referral bonus if applicable
    function processReferralBonus(address _user, uint256 _amount, address referral_report) private {
        address _referrer = referralData.referrerOf(_user);

        //Need to have an upline
        if (_referrer == address(0)) {
            return;
        }

        //partners split 50/50
        uint256 _share = _amount.div(2);

        //We operate side effect free and just add to pending sponsorships
        sponsorData.add(_referrer, _share);
        sponsorData.add(_user, _share);

        //Report the reward distribution to the caller
        IReferralReport report = IReferralReport(referral_report);
        report.reward_distribution(_referrer, _user, _share, _share);

        emit NewSponsorship(_user, _referrer, _share);
        emit NewSponsorship(_referrer, _user, _share);
    } 

    //@dev Return the scaled amount of TRUNK base on how off peg it is from 1                                              
    function scaleByPeg(uint256 amount)
        private
        view
        returns (uint256 scaledAmount)
    {
        address[] memory path = new address[](2);
        uint[] memory amounts = new uint[](2);

        path[0] = address(backedToken);
        path[1] = address(collateralToken);


        amounts = oracle.consultAmountsOut(amount, path);

        scaledAmount = amount.min(amounts[1]); //we don't reward over peg
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

}

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('STF', notes));
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('ST', notes));
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value,
        string memory notes
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), string.concat('SA', notes));
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value, string memory notes) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, string.concat('STE', notes));
    }
}