/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/*
    SPDX-License-Identifier: MIT
    A Bankteller Production
    Elephant Money
    Copyright 2022
*/

/*
    Elephant Money Farms

    Open Source - the code managing your funds is fully open source
    Trustless - The EMF Vault is immutable and owns private treasuries for assets
    Your Keys - Only your keys can deposit and withdraw to the EMF Vault
    Lossless - No impermanent loss, these farms are dual staking pools
    Flashloan Proof - Yield is calculated based on staked TRUNK, not BUSD value
    High Stable Coin Yield - Stake TRUNK at a discount to support TVL and peg at 1 BUSD
    Zero Dilution - APR rates are based on base rate x bonus levels
    Competitive Rates - Earn peg adjusted rates up to 125% APR at launch
    No Fees - No deposit/withdraw fees on your hard earned money
    No Taxes - No taxes on the yield you earn, real yield

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
    IERC20 public token; // address of the BEP20 token traded on this contract

    //There can  be a general purpose treasury for any BEP20 token
    constructor(address token_addr) Ownable() {
        token = IERC20(token_addr);
    }

    //@dev Withdraw specified amount to the caller
    function withdraw(uint256 _amount) external onlyWhitelisted {
        require(token.transfer(_msgSender(), _amount));
    }

    //@dev Withdraw specified amount to the supplied address
    function withdrawTo(address _to, uint256 _amount) external onlyWhitelisted {
        require(_to != address(0), "address must be non-zero");
        require(token.transfer(_to, _amount));
    }
}

//@dev Immutable manager for trustless yield farms and treasuries for Elephant Money
//Only bonus levels and price routing can be updated
contract Vault is Ownable, IReferralReport {
    using SafeMath for uint256;

    mapping(address => UserSummary) public summary;
    mapping(address => Farm) public farms;
    mapping(address => mapping(address => User)) public users; //Asset -> User

    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_claimed;
    uint256 public total_rewards;
    uint256 public total_txs;
    uint256 public current_balance;

    address public constant backedAddress =
        address(0xdd325C38b12903B727D16961e61333f4871A70E0); //TRUNK
    Treasury public backedTreasury;
    IERC20 public backedToken;
    IFarmEngine public farmEngine;


    event Deposit(
        address indexed asset,
        address indexed user,
        uint256 assetAmount,
        uint256 amount
    );
    event Withdraw(
        address indexed asset,
        address indexed user,
        uint256 assetAmount,
        uint256 amount
    );
     event Claim(
        address indexed asset,
        address indexed user,
        uint256 amount
    );
    event RegisterFarm(
        address indexed asset,
        address treasury,
        uint256 bonusLevel,
        bool useWBNB
    );
    event RewardDistribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward);
    
    event UpdateFarm(address asset, uint256 bonusLevel, bool useWBNB);
    event UpdateFarmEngine(address prevEngine, address engine);

    //@dev Creates a new Vault that manages its own set of immutable trusless treasuries
    constructor() Ownable() {
        backedTreasury = new Treasury(backedAddress); //farm specific treasury for TRUNK
        backedToken = IERC20(backedAddress);
        backedTreasury.addAddressToWhitelist(address(this));
    }

    //Administrative//

    //@dev Register Farm and create trustless treasury for a given asset
    function registerFarm(
        address _asset,
        uint256 _bonusLevel,
        bool _useWBNB
    ) external onlyOwner {
        require(
            farms[_asset].treasury == address(0),
            "Farm is already registered"
        );
        require(_asset != address(0), "Need non-zero addresses");
        require(
            _bonusLevel >= 1 && _bonusLevel <= 10,
            "bonus level is out of range, 1-10"
        );

        //setup 
        farms[_asset].asset = _asset;
        farms[_asset].bonusLevel = _bonusLevel;
        farms[_asset].useWBNB = _useWBNB;

        //create treasury
        Treasury treasury = new Treasury(_asset); //this is the owner
        farms[_asset].treasury = address(treasury);
        
        //whitelist vault; only the vault can access and is the owner.  This relationship is immutable
        treasury.addAddressToWhitelist(address(this)); //only this core can access farm funds

        emit RegisterFarm(_asset, address(treasury), _bonusLevel, _useWBNB);
        
    }

    //@dev Update bonus level and PCS path for a given asset
    function updateFarm(
        address _asset,
        uint256 _bonusLevel,
        bool _useWBNB
    ) external onlyOwner {
        require(
            farms[_asset].treasury != address(0),
            "Farm registration is  required"
        );
        require(_asset != address(0), "Need non-zero addresses");
        require(
            _bonusLevel >= 1 && _bonusLevel <= 10,
            "bonus level is out of range, 1-10"
        );

        farms[_asset].bonusLevel = _bonusLevel;
        farms[_asset].useWBNB = _useWBNB;

        emit UpdateFarm(_asset, _bonusLevel, _useWBNB);
    }


    //@dev Update the farm engine which is used for quotes, yield calculations / distribution
    function updateFarmEngine(address _engine) external onlyOwner {
        require(_engine != address(0), "engine must be non-zero");

        emit UpdateFarmEngine(address(farmEngine), _engine);

        farmEngine = IFarmEngine(_engine);
    }

    ///  Views  ///

    //@dev Get User info
    function getUser(address _asset, address _user)
        external
        view
        returns (User memory)
    {
        return users[_asset][_user];
    }

    //@dev Get UserSummary
    function getUserSummary(address _user)
        external
        view
        returns (UserSummary memory)
    {
        return summary[_user];
    }

    //@dev Get Farm info
    function getFarm(address _asset) external view returns (Farm memory) {
        return farms[_asset];
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
        address _asset,
        uint256 _amount
    ) external view returns (uint256 backedAmount) {

        backedAmount = farmEngine.estimateBackedAmount(_asset, _amount, farms[_asset].useWBNB);

    }

    ////  User Functions ////

    //@dev Deposit specified asset and matching BUSD value of TRUNK  for the caller;
    function deposit(address _asset, uint256 _assetAmount) external {
        
        //Only the key holder can invest their funds
        address _user = msg.sender; 
        
        IERC20 assetToken = IERC20(_asset);

        //check balances
        require(
            farms[_asset].treasury != address(0),
            "Farm registration is  required"
        );
        require(
            _assetAmount <= assetToken.balanceOf(_user),
            "Insufficient amount of non-native asset"
        );

        uint256 _amount = farmEngine.estimateBackedAmount(_asset, _assetAmount, farms[_asset].useWBNB); //calculate the TRUNK _amount
        require(
            _amount <= backedToken.balanceOf(_user),
            "Insufficient amount of TRUNK"
        );

        //transfer funds
        require(
            backedToken.transferFrom(
                _user,
                address(backedTreasury), //directly to private TRUNK Treasury
                _amount
            ),
            "TRUNK token transfer failed"
        );

        require(
            assetToken.transferFrom(
                _user,
                farms[_asset].treasury, //dedicated asset treasuries
                _assetAmount
            ),
            "asset token transfer failed"
        );


        //update user stats
        if (summary[_user].exists == false) {
            summary[_user].exists = true;
            total_users += 1;
        } else {
            //if user exists see if we have to claim yield before proceeding
            //optimistically claim yield before reset
            //if there is a balance we potentially have yield
            if (users[_asset][_user].balance > 0){
                distributeYield(_asset, _user);
            }
        }

        //update user
        users[_asset][_user].balance += _amount;
        users[_asset][_user].assetBalance += _assetAmount;
        users[_asset][_user].last_time = block.timestamp;
        summary[_user].last_time = block.timestamp;
        summary[_user].current_balance += _amount * 2;

        //update farm
        farms[_asset].balance += _amount;
        farms[_asset].assetBalance += _assetAmount;

        total_deposited += _amount * 2; //_assetAmount is equal to _amount at time of addition and tracked by  TRUNK
        current_balance += _amount * 2;
        total_txs += 1;

        //events
        emit Deposit(_asset, _user, _assetAmount, _amount);
    }

    //@dev Withdraw the caller's associated balance
    function withdraw(address _asset) external {
        
        //Only the owner of funds can withdraw
        address _user = msg.sender;

        //checks
        require(
            farms[_asset].treasury != address(0),
            "Farm registration is  required"
        );
        require(
            summary[_user].exists,
            "User is not registered in a farm"
        );
        
        //tmps
        uint256 _userBalance = users[_asset][_user].balance;
        uint256 _userAssetBalance = users[_asset][_user].assetBalance;

        //checks
        require (_userBalance > 0 && _userAssetBalance > 0, "non-zero balances required");
        require(
            farms[_asset].balance >= _userBalance,
            "Backed asset deficit detected"
        );
        require(
            farms[_asset].assetBalance >= _userAssetBalance,
            "Core asset deficit detected"
        );

        //optimistically claim yield before reset
        distributeYield(_asset, _user);

        //farm; has to be performed before the reset
        farms[_asset].balance = farms[_asset].balance.sub(_userBalance);
        farms[_asset].assetBalance = farms[_asset].assetBalance.sub(
            _userAssetBalance
        );

        //reset
        users[_asset][_user].balance = 0;
        users[_asset][_user].assetBalance = 0;
        users[_asset][_user].last_time = block.timestamp;
        summary[_user].last_time = block.timestamp;
        summary[_user].current_balance = summary[_user].current_balance.sub(_userBalance * 2);

        //transfer tokens
        ITreasury assetTreasury = ITreasury(farms[_asset].treasury);

        current_balance = current_balance.sub(_userBalance * 2);
        total_txs += 1;

        backedTreasury.withdrawTo(_user, _userBalance);
        assetTreasury.withdrawTo(_user, _userAssetBalance);

        //events
        emit Withdraw(_asset, _user, _userAssetBalance, _userBalance);
    }

    //@dev Claims earned interest for the caller for a given asset
    function claim(address _asset) external returns (bool success){
        
        //Only the owner of funds can claim funds
        address _user = msg.sender;

        //checks
        require(
            farms[_asset].treasury != address(0),
            "Farm registration is  required"
        );
        require(
            summary[_user].exists,
            "User is not registered in a farm"
        );
        require(
            users[_asset][_user].balance > 0 &&
                users[_asset][_user].assetBalance > 0,
            "balance is required to earn yield"
        );

        return distributeYield(_asset, _user);

        
    }

    //@dev Implements the IReferralReport interface which is called by the FarmEngine yield function back to the caller
    function reward_distribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward) external {
        //checks 
        require(msg.sender == address(farmEngine), "caller must be registered farm engine");
        require(_referrer != address(0) && _user != address(0), "non-zero addresses required");
        
        //track farm exclusive rewards which are paid out via Stampede airdrops
        summary[_referrer].rewards += _referrer_reward;
        summary[_user].rewards += _user_reward;

        //track total rewards
        total_rewards += _referrer_reward + _user_reward;

        emit RewardDistribution(_referrer, _user, _referrer_reward, _user_reward);
    }

    //@dev Return available yield for given user
    function available(address _asset, address _user) external view returns (uint256 amount) {

        amount = farmEngine.available(users[_asset][_user], farms[_asset].bonusLevel);
    }


    //   Internal Functions  //
    
    //@dev Checks if yield is available and distributes before performing additional operations
    //distributes only when yield is positive
    //inputs are validated by external facing functions 
    function distributeYield(address _asset, address _user) private returns (bool success) {
        
        //get available
        uint256 _amount = farmEngine.available(
            users[_asset][_user],
            farms[_asset].bonusLevel
        );

        //attempt to payout yield and update stats; 
        if (_amount > 0 && farmEngine.yield(_user, _amount)) {

            //user stats
            users[_asset][_user].payouts += _amount;
            summary[_user].payouts += _amount; 
            //last time determines earnings so  update only on success
            users[_asset][_user].last_time = block.timestamp;
            summary[_user].last_time = block.timestamp;

            //farm stats
            farms[_asset].payouts += _amount;

            total_claimed += _amount;
            total_txs += 1;

            emit Claim(_asset, _user, _amount);

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
}

//@dev Provides PCS Oracle services for TRUNK and orchestrates yield generation
contract FarmEngine is Whitelist, IFarmEngine {
    using SafeMath for uint256;

    IERC20 public backedToken;
    IERC20 public collateralToken;
    ITreasury public backedTreasury;

    AddressRegistry private registry;

    uint256 private constant minimumAmount = 1e18;
    uint256 public constant referenceApr = 250;
    uint256 public primaryScaler = 20;

    uint256 public constant sweepThreshold = 100e18; //large deposits should be processed immediately by those who can afford it

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
    event UpdateReserve(address indexed addr);
    event UpdateReferralData(address indexed addr);
    event UpdateSponsorData(address indexed addr);
    event UpdatePrimaryScaler(uint256 prev_Scaler, uint256 scaler);

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
        //Add referral bonus for referrer, 1%
        processReferralBonus(_user, _amount.div(100), msg.sender);

        //Get TRUNK
        backedTreasury.withdraw(_amount); //this is called because the primary 

        require(
            backedToken.transfer(_user, _amount),
            "Failed to transfer claim"
        );

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
        payout = scaleByPeg(share * block.timestamp.safeSub(_user.last_time)); //scale by peg and then asset
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

        amounts = collateralRouter.getAmountsOut(_amount, path);

        backedAmount =  (_useWBNB) ? amounts[3] : amounts[2];
    }

    //@dev Return an estimate of BUSD based on TRUNK input using PCS LP price
    function estimateBackedToCollateral(uint256 amount)
        external
        view
        returns (uint256 collateralAmount)
    {
        address[] memory path = new address[](2);
        uint256[] memory amounts;

        path[0] = address(backedToken);
        path[1] = address(collateralToken);

        amounts = collateralRouter.getAmountsOut(amount, path);

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
        uint256 collateralBalance = collateralToken.balanceOf(
            registry.backedLPAddress()
        );
        uint256 backedBalance = backedToken.balanceOf(
            registry.backedLPAddress()
        );

        scaledAmount = amount.mul(collateralBalance).div(backedBalance);

        scaledAmount = scaledAmount.min(amount); //we don't reward over peg
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