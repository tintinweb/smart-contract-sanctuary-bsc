/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface IMysteryContract {
    function handleBuy(address account, uint256 amount, int256 feeTokens) external;
    function handleSell(address account, uint256 amount, int256 feeTokens) external;
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

library BiggestBuyer {
    struct Data {
        uint256 initHour;
        uint256 rewardFactor;
        mapping(uint256 => address) biggestBuyerAccount;
        mapping(uint256 => uint256) biggestBuyerAmount;
        mapping(uint256 => uint256) biggestBuyerPaid;
    }

    uint256 private constant FACTOR_MAX = 10000;

    event UpdateBiggestBuyerRewordFactor(uint256 value);

    event BiggestBuyerPayout(uint256 hour, address indexed account, uint256 value);

    function init(Data storage data) public {
        data.initHour = getCurrentHour();
        updateRewardFactor(data, 500); //5% from liquidity
    }

    function updateRewardFactor(Data storage data, uint256 value) public {
        require(value <= 1000, "invalid biggest buyer reward percent"); //max 10%
        data.rewardFactor = value;
        emit UpdateBiggestBuyerRewordFactor(value);
    }

    function getCurrentHour() private view returns (uint256) {
        return block.timestamp / (1 hours);
    }

    // starts at 0 and increments at the turn of the hour every hour
    function getHour(Data storage data) public view returns (uint256) {
        uint256 currentHour = getCurrentHour();
        return currentHour - data.initHour;
    }

    function handleBuy(Data storage data, address account, uint256 amount) public {
        uint256 hour = getHour(data);

        if(amount > data.biggestBuyerAmount[hour]) {
            data.biggestBuyerAmount[hour] = amount;
            data.biggestBuyerAccount[hour] = account;
        }
    }

    function calculateBiggestBuyerReward(Data storage data, uint256 liquidityTokenBalance) public view returns (uint256) {
        return liquidityTokenBalance * data.rewardFactor / FACTOR_MAX;
    }

    function payBiggestBuyer(Data storage data, uint256 hour, uint256 liquidityTokenBalance) public returns (address, uint256) {
        require(hour < getHour(data), "Hour is not complete");
        if(
            data.biggestBuyerAmount[hour] == 0 ||
            data.biggestBuyerPaid[hour] > 0) {
            return (address(0), 0);
        }

        address winner = data.biggestBuyerAccount[hour];

        uint256 amountWon = calculateBiggestBuyerReward(data, liquidityTokenBalance);

        //Set to 1 so the check for if payment occurred will succeed
        if(amountWon == 0) {
            amountWon = 1;
        }

        data.biggestBuyerPaid[hour] = amountWon;

        emit BiggestBuyerPayout(hour, winner, amountWon);

        return (winner, amountWon);
    }

    function getBiggestBuyer(Data storage data, uint256 hour) public view returns (address, uint256, uint256) {
        return (
            data.biggestBuyerAccount[hour],
            data.biggestBuyerAmount[hour],
            data.biggestBuyerPaid[hour]);
    }
}

interface DividendPayingTokenOptionalInterface {

  function withdrawableDividendOf(address _owner) external view returns(uint256);

  function withdrawnDividendOf(address _owner) external view returns(uint256);

  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

library MaxWalletCalculator {
    function calculateMaxWallet(uint256 totalSupply, uint256 hatchTime) public view returns (uint256) {
        if(hatchTime == 0) {
            return totalSupply;
        }

        uint256 FACTOR_MAX = 10000;

        uint256 dittoAge = block.timestamp - hatchTime;

        uint256 base = totalSupply * 30 / FACTOR_MAX; // 0.3%
        uint256 incrasePerMinute = totalSupply * 10 / FACTOR_MAX; // 0.1%

        uint256 extra = incrasePerMinute * dittoAge / (1 minutes); // up 0.1% per minute

        return base + extra;
    }
}

library LiquidityBurnCalculator {
    function calculateBurn(uint256 liquidityTokensBalance, uint256 liquidityTokensAvailableToBurn, uint256 liquidityBurnTime)
        public
        view
        returns (uint256) {
        if(liquidityTokensAvailableToBurn == 0) {
            return 0;
        }

        if(block.timestamp < liquidityBurnTime + 5 minutes) {
            return 0;
        }

        uint256 maxBurn = liquidityTokensBalance * 2 / 100;

        uint256 burnAmount = liquidityTokensAvailableToBurn;

        if(burnAmount > maxBurn) {
            burnAmount = maxBurn;
        }

        return burnAmount;
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

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

library Referrals {
    struct Data {
        uint256 referralBonus;
        uint256 referredBonus;
        uint256 tokensNeededForRefferalNumber;
        mapping(uint256 => address) registeredReferrersByCode;
        mapping(address => uint256) registeredReferrersByAddress;
        uint256 currentRefferralCode;
    }

    uint256 private constant FACTOR_MAX = 10000;

    event RefferalCodeGenerated(address account, uint256 code, uint256 inc1, uint256 inc2);
    event UpdateReferralBonus(uint256 value);
    event UpdateReferredBonus(uint256 value);


    event UpdateTokensNeededForReferralNumber(uint256 value);


    function init(Data storage data) public {
        updateReferralBonus(data, 200); //2% bonus on buys from people you refer
        updateReferredBonus(data, 200); //2% bonus when you buy with referral code

        updateTokensNeededForReferralNumber(data, 1000 * (10**18)); //1000 tokens needed

        data.currentRefferralCode = 100;
    }

    function updateReferralBonus(Data storage data, uint256 value) public {
        require(value <= 500, "invalid referral referredBonus"); //max 5%
        data.referralBonus = value;
        emit UpdateReferralBonus(value);
    }

    function updateReferredBonus(Data storage data, uint256 value) public {
        require(value <= 500, "invalid referred bonus"); //max 5%
        data.referredBonus = value;
        emit UpdateReferredBonus(value);
    }

    function updateTokensNeededForReferralNumber(Data storage data, uint256 value) public {
        data.tokensNeededForRefferalNumber = value;
        emit UpdateTokensNeededForReferralNumber(value);
    }

    function random(Data storage data, uint256 min, uint256 max) private view returns (uint256) {
        return min + uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, data.currentRefferralCode))) % (max - min + 1);
    }

    function handleNewBalance(Data storage data, address account, uint256 balance) public {
        if(data.registeredReferrersByAddress[account] != 0) {
            return;
        }
        if(balance < data.tokensNeededForRefferalNumber) {
            return;
        }
        //randomly increment referral code by anywhere from 5-50 so they
        //cannot be guessed easily
        uint256 inc1 = random(data, 5, 50);
        uint256 inc2 = random(data, 1, 9);
        data.currentRefferralCode += inc1;

        //don't allow referral code to end in 0,
        //so that ambiguous codes do not exist (ie, 420 and 4200)
        if(data.currentRefferralCode % 10 == 0) {
            data.currentRefferralCode += inc2;
        }

        data.registeredReferrersByCode[data.currentRefferralCode] = account;
        data.registeredReferrersByAddress[account] = data.currentRefferralCode;

        emit RefferalCodeGenerated(account, data.currentRefferralCode, inc1, inc2);
    }

    function getReferralCode(Data storage referrals, address account) public view returns (uint256) {
        return referrals.registeredReferrersByAddress[account];
    }

    function getReferrer(Data storage referrals, uint256 referralCode) public view returns (address) {
        return referrals.registeredReferrersByCode[referralCode];
    }

    function getReferralCodeFromTokenAmount(uint256 tokenAmount) private pure returns (uint256) {
        uint256 decimals = 18;

        uint256 numberAfterDecimals = tokenAmount % (10**decimals);

        uint256 checkDecimals = 3;

        while(checkDecimals < decimals) {
            uint256 factor = 10**(decimals - checkDecimals);
            //check if number is all 0s after the decimalth decimal
            if(numberAfterDecimals % factor == 0) {
                return numberAfterDecimals / factor;
            }
            checkDecimals++;
        }

        return numberAfterDecimals;
    }

    function getReferrerFromTokenAmount(Data storage referrals, uint256 tokenAmount) public view returns (address) {
        uint256 referralCode = getReferralCodeFromTokenAmount(tokenAmount);

        return referrals.registeredReferrersByCode[referralCode];
    }

    function isValidReferrer(Data storage referrals, address referrer, uint256 referrerBalance, address transferTo) public view returns (bool) {
        if(referrer == address(0)) {
            return false;
        }

        uint256 tokensNeeded = referrals.tokensNeededForRefferalNumber;

        return referrerBalance >= tokensNeeded && referrer != transferTo;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IWETH {
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
}

library Transfers {
    using Fees for Fees.Data;
    using Referrals for Referrals.Data;
    using BiggestBuyer for BiggestBuyer.Data;

    struct Data {
        address uniswapV2Router;
        address uniswapV2Pair;
    }

    uint256 private constant FACTOR_MAX = 10000;

    event BuyWithFees(
        address indexed account,
        uint256 amount,
        int256 feeFactor,
        int256 feeTokens
    );

    event SellWithFees(
        address indexed account,
        uint256 amount,
        uint256 feeFactor,
        uint256 feeTokens
    );

    function init(
        Data storage data,
        address uniswapV2Router,
        address uniswapV2Pair)
        public {
        data.uniswapV2Router = uniswapV2Router;
        data.uniswapV2Pair = uniswapV2Pair;
    }

    function transferIsBuy(Data storage data, address from, address to) public view returns (bool) {
        return from == data.uniswapV2Pair && to != data.uniswapV2Router;
    }

    function transferIsSell(Data storage data, address from, address to) public view returns (bool) {
        return from != data.uniswapV2Router && to == data.uniswapV2Pair;
    }


    function handleTransferWithFees(Data storage data, DittoStorage.Data storage _storage, address from, address to, uint256 amount, address referrer) public returns(uint256 fees, uint256 buyerMint, uint256 referrerMint) {        
        if(transferIsBuy(data, from, to)) {
            (int256 buyFee,) = _storage.fees.getCurrentFees();

             if(referrer != address(0)) {

                buyFee -= int256(_storage.referrals.referredBonus);
             }

            uint256 tokensBought = amount;

            if(buyFee > 0) {
                fees = Fees.calculateFees(amount, uint256(buyFee));

                tokensBought = amount - fees;

                emit BuyWithFees(to, amount, buyFee, int256(fees));
            }
            else if(buyFee < 0) {
                uint256 extraTokens = amount * uint256(-buyFee) / FACTOR_MAX;

                buyerMint = extraTokens;

                tokensBought += extraTokens;

                emit BuyWithFees(to, amount, buyFee, -int256(extraTokens));
            }

            if(referrer != address(0)) {
                uint256 referralBonus = tokensBought * _storage.referrals.referralBonus / FACTOR_MAX;

                referrerMint = referralBonus;
            }

            _storage.biggestBuyer.handleBuy(to, amount);
        }
        else if(transferIsSell(data, from, to)) {
            uint256 sellFee = _storage.fees.handleSell(amount);

            fees = Fees.calculateFees(amount, sellFee);

            emit SellWithFees(from, amount, sellFee, fees);

            _storage.dividendTracker.claimDividends(
                from,
                _storage.marketingWallet1,
                _storage.marketingWallet2,
                true);
        }
        else {
            fees = Fees.calculateFees(amount, _storage.fees.baseFee);
        }
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

interface DividendPayingTokenInterface {

  function dividendOf(address _owner) external view returns(uint256);

  function distributeDividends() external payable;

  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

contract DividendPayingToken is ERC20, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;

  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  uint256 public totalDividendsDistributed;

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {

  }

  receive() external payable {
    distributeDividends();
  }

  function distributeDividends() public override payable {
    require(totalSupply() > 0);

    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);

      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }

  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }

  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }

  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }

  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

contract DittoDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    Ditto public immutable token;
    IUniswapV2Pair public immutable uniswapV2Pair;
    IWETH public immutable WETH;

    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;

    uint256 public vestingDuration;
    uint256 private vestingDurationUpdateTime;

    uint256 public unvestedDividendsMarketingFee;

    uint256 public constant mustClaimDuration = 5184000;

    event ExcludeFromDividends(address indexed account);
    event UpdateeVestingDuration(uint256 vestingDuration);
    event UpdateUnvestedDividendsMarketingFee(uint256 unvestedDividendsMarketingFee);

    event Claim(address indexed account, bool isFromSell, uint256 factor, uint256 amount, uint256 toLiquidity, uint256 toMarketing);

    event ClaimInactive(address indexed account, uint256 amount);

    modifier onlyOwnerOfOwner() {
        require(Ownable(owner()).owner() == _msgSender(), "caller is not the owner's owner");
        _;
    }

    constructor(address payable owner, address pair, address weth) DividendPayingToken("DittoDividendTracker", "DITTO_DIVS") {
        token = Ditto(owner);
        uniswapV2Pair = IUniswapV2Pair(pair);
        WETH = IWETH(weth);

        updateVestingDuration(259200); //3 days
        updateUnvestedDividendsMarketingFee(25); //25%

        transferOwnership(owner);
    }

    bool private silenceWarning;

    function _transfer(address, address, uint256) internal override {
        silenceWarning = true;
        require(false, "DittoDividendTracker: No transfers allowed");
    }

    function excludeFromDividends(address account) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);

    	emit ExcludeFromDividends(account);
    }

    function updateVestingDuration(uint256 newVestingDuration) public onlyOwner {
        require(newVestingDuration <= 2592000, "DittoDividendTracker: max vesting duration is 30 days");

        //If not initial set, then it can only be updated every 24h, and only increasing by 25% if over 1 day
        if(vestingDurationUpdateTime > 0) {
            require(block.timestamp >= vestingDurationUpdateTime + 1 days, "too soon");
            require(
                newVestingDuration <= 1 days ||
                newVestingDuration <= vestingDuration * 125 / 100,
                "too high");
        }

        vestingDuration = newVestingDuration;
        vestingDurationUpdateTime = block.timestamp;
        emit UpdateeVestingDuration(newVestingDuration);
    }

    function updateUnvestedDividendsMarketingFee(uint256 newUnvestedDividendsMarketingFee) public onlyOwner {
        require(newUnvestedDividendsMarketingFee <= 30, "DittoDividendTracker: max marketing fee is 30%");

        unvestedDividendsMarketingFee = newUnvestedDividendsMarketingFee;
        emit UpdateUnvestedDividendsMarketingFee(unvestedDividendsMarketingFee);
    }

    function getDividendInfo(address account) external view returns (uint256[] memory dividendInfo) {
        uint256 withdrawableDividends = withdrawableDividendOf(account);
        uint256 totalDividends = accumulativeDividendOf(account);
        uint256 claimFactor = getAccountClaimFactor(account);
        uint256 vestingPeriodStart = lastClaimTimes[account];
        uint256 vestingPeriodEnd = vestingPeriodStart > 0 ? vestingPeriodStart + vestingDuration : 0;

        dividendInfo = new uint256[](5);

        dividendInfo[0] = withdrawableDividends;
        dividendInfo[1] = totalDividends;
        dividendInfo[2] = claimFactor;
        dividendInfo[3] = vestingPeriodStart;
        dividendInfo[4] = vestingPeriodEnd;
    }


    function setBalance(address account, uint256 newBalance) public onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

        _setBalance(account, newBalance);

        //Set this so vesting calculations work after the account first
        //interacts with the token
        if(newBalance > 0 && lastClaimTimes[account] == 0) {
            lastClaimTimes[account] = block.timestamp;
        }
    }

    uint256 public constant WITHDRAW_MAX_FACTOR = 10000;

    function getAccountClaimFactor(address account) public view returns (uint256) {
        uint256 lastClaimTime = lastClaimTimes[account];

        if(lastClaimTime == 0) {
            return 0;
        }

        uint256 elapsed = block.timestamp - lastClaimTime;

        uint256 factor;

        if(elapsed >= vestingDuration) {
            factor = WITHDRAW_MAX_FACTOR;
        }
        else {
            factor = WITHDRAW_MAX_FACTOR * elapsed / vestingDuration;
        }

        return factor;
    }

    function claimDividends(address account, address marketingWallet1, address marketingWallet2, bool isFromSell)
        external onlyOwner returns (bool) {
        uint256 withdrawableDividend = withdrawableDividendOf(account);

        if(withdrawableDividend == 0) {
            return false;
        }

        uint256 factor = getAccountClaimFactor(account);

        withdrawnDividends[account] = withdrawnDividends[account].add(withdrawableDividend);
        emit DividendWithdrawn(account, withdrawableDividend);

        uint256 vestedAmount = withdrawableDividend * factor / WITHDRAW_MAX_FACTOR;
        uint256 unvestedAmount = withdrawableDividend - vestedAmount;

        bool success;

        (success,) = account.call{value: vestedAmount}("");
        require(success, "Could not send dividends");

        uint256 toLiquidity = 0;
        uint256 toMarketing = 0;

        //Any unvested dividends are automatically re-added to liquidity and
        //sent to marketing wallet
        if(unvestedAmount > 0) {
            toMarketing = unvestedAmount * unvestedDividendsMarketingFee / 100;
            toLiquidity = unvestedAmount - toMarketing;

            uint256 marketing1 = toMarketing / 2;
            uint256 marketing2 = toMarketing - marketing1;

            if(toMarketing > 0) {
                (success,) = marketingWallet1.call{value: marketing1, gas: 5000}("");
                if(!success) {
                    toLiquidity += marketing1;
                }

                (success,) = marketingWallet2.call{value: marketing2, gas: 5000}("");
                if(!success) {
                    toLiquidity += marketing2;
                }
            }

            WETH.deposit{value: toLiquidity}();
            WETH.transfer(address(uniswapV2Pair), toLiquidity);

            if(!isFromSell) {
                uniswapV2Pair.sync();
            }
        }

        lastClaimTimes[account] = block.timestamp;
        emit Claim(account, isFromSell, factor, vestedAmount, toLiquidity, toMarketing);

        return true;
    }

    function claimInactiveAccountDividends(address account) external onlyOwnerOfOwner returns (bool) {
        uint256 withdrawableDividend = withdrawableDividendOf(account);

        require(withdrawableDividend > 0);
        require(block.timestamp - lastClaimTimes[account] >= mustClaimDuration);

        withdrawnDividends[account] = withdrawnDividends[account].add(withdrawableDividend);
        emit DividendWithdrawn(account, withdrawableDividend);

        (bool success,) = msg.sender.call{value: withdrawableDividend}("");
        require(success, "Could not send dividends");

        lastClaimTimes[account] = block.timestamp;
        emit ClaimInactive(account, withdrawableDividend);

        return true;
    }
}



library Fees {
    struct Data {
        address uniswapV2Pair;
        uint256 baseFee;//in 100ths of a percent
        uint256 extraFee;//in 100ths of a percent, extra sell fees. Buy fee is baseFee - extraFee
        uint256 extraFeeUpdateTime; //when the extraFee was updated. Use time elapsed to dynamically calculate new fee

        uint256 feeSellImpact; //in 100ths of a percent, how much price impact on sells (in percent) increases extraFee.
        uint256 feeTimeImpact; //in 100ths of a percent, how much time elapsed (in minutes) lowers extraFee

        uint256 dividendsPercent; //80% of fees go to dividends
        uint256 marketingPercent; //20% of fees go to marketing
        uint256 mysteryPercent; //0% of fees go to mystery contract... for now
    }

    uint256 private constant FACTOR_MAX = 10000;

    event UpdateBaseFee(uint256 value);
    event UpdateFeeSellImpact(uint256 value);
    event UpdateFeeTimeImpact(uint256 value);

    event UpdateFeeDestinationPercents(
        uint256 dividendsPercent,
        uint256 marketingPercent,
        uint256 mysteryPercent
    );


    event BuyWithFees(
        address indexed account,
        int256 feeFactor,
        int256 feeTokens,
        uint256 referredBonus,
        uint256 referralBonus,
        address referrer
    );

    event SellWithFees(
        address indexed account,
        uint256 feeFactor,
        uint256 feeTokens
    );

    event SendDividends(
        uint256 tokensSwapped,
        uint256 amount
    );

    event SendToMarketing1(
        uint256 tokensSwapped,
        uint256 amount
    );

    event SendToMarketing2(
        uint256 tokensSwapped,
        uint256 amount
    );

    event SendToMystery(
        uint256 tokensSwapped,
        uint256 amount
    );

    function init(
        Data storage data,
        DittoStorage.Data storage _storage,
        address uniswapV2Pair) public {
        data.uniswapV2Pair = uniswapV2Pair;
        updateBaseFee(data, 1000); //10% base fee
        updateFeeSellImpact(data, 100); //each 1% price impact on sells will increase sell fee 1%, and lower buy fee 1%
        updateFeeTimeImpact(data, 100); //extra sell fee lowers 1% every minute, and buy fee increases 1% every minute until back to base fee

        updateFeeDestinationPercents(data, _storage, 75, 25, 0);
    }

    function updateBaseFee(Data storage data, uint256 value) public {
        require(value >= 300 && value <= 1000, "invalid base fee");
        data.baseFee = value;
        emit UpdateBaseFee(value);
    }

    function updateFeeSellImpact(Data storage data, uint256 value) public {
        require(value >= 10 && value <= 500, "invalid fee sell impact");
        data.feeSellImpact = value;
        emit UpdateFeeSellImpact(value);
    }

    function updateFeeTimeImpact(Data storage data, uint256 value) public {
        require(value >= 10 && value <= 500, "invalid fee time impact");
        data.feeTimeImpact = value;
        emit UpdateFeeSellImpact(value);
    }

    function updateFeeDestinationPercents(Data storage data, DittoStorage.Data storage _storage, uint256 dividendsPercent, uint256 marketingPercent, uint256 mysteryPercent) public {
        require(dividendsPercent + marketingPercent + mysteryPercent == 100, "invalid percents");
        require(dividendsPercent >= 50, "invalid percent");

        if(address(_storage.mysteryContract) == address(0)) {
            require(mysteryPercent == 0, "invalid percent");
        }

        data.dividendsPercent = dividendsPercent;
        data.marketingPercent = marketingPercent;
        data.mysteryPercent = mysteryPercent;

        emit UpdateFeeDestinationPercents(dividendsPercent, marketingPercent, mysteryPercent);
    }


    //Gets fees in 100ths of a percent for buy and sell (anything else is always base fee)
    //and also returns current timestamp
    function getCurrentFees(Data storage data) public view returns (int256, uint256) {
        uint256 timeElapsed = block.timestamp - data.extraFeeUpdateTime;

        uint256 timeImpact = data.feeTimeImpact * timeElapsed / 60;

        //Enough time has passed that fees are back to base
        if(timeImpact >= data.extraFee) {
            return (int256(data.baseFee), data.baseFee);
        }

        uint256 realExtraFee = data.extraFee - timeImpact;

        int256 buyFee = int256(data.baseFee) - int256(realExtraFee);
        uint256 sellFee = data.baseFee + realExtraFee;

        return (buyFee, sellFee);
    }

    function handleSell(Data storage data, uint256 amount) public
        returns (uint256) {
        (,uint256 sellFee) = getCurrentFees(data);

        uint256 priceImpact = UniswapV2PriceImpactCalculator.calculateSellPriceImpact(address(this), data.uniswapV2Pair, amount);

        uint256 increaseSellFee = priceImpact * data.feeSellImpact / 100;

        sellFee = sellFee + increaseSellFee;

        //max 30% so it is always sellable with 49% slippage on Uniswap
        if(sellFee >= 3000) {
            sellFee = 3000;
        }

        data.extraFee = sellFee - data.baseFee;
        data.extraFeeUpdateTime = block.timestamp;

        return sellFee;
    }

    function calculateFees(uint256 amount, uint256 feeFactor) public pure returns (uint256) {
        if(feeFactor > FACTOR_MAX) {
            feeFactor = FACTOR_MAX;
        }
        return amount * uint256(feeFactor) / FACTOR_MAX;
    }

    function swapTokensForEth(uint256 tokenAmount, IUniswapV2Router02 router)
        private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAccumulatedFees(Data storage data, DittoStorage.Data storage _storage, uint256 tokenAmount) public {
        swapTokensForEth(tokenAmount, _storage.router);
        uint256 balance = address(this).balance;

        uint256 dividends = balance * data.dividendsPercent / 100;
        uint256 marketing = balance * data.marketingPercent / 100;
        uint256 mystery = balance - dividends - marketing;

        if(data.mysteryPercent == 0) {
            mystery = 0;
        }

        bool success;

        (success,) = address(_storage.dividendTracker).call{value: dividends}("");

        if(success) {
            emit SendDividends(tokenAmount, dividends);
        }

        uint256 marketing1 = marketing / 2;
        uint256 marketing2 = marketing - marketing1;

        (success,) = address(_storage.marketingWallet1).call{value: marketing1}("");

        if(success) {
            emit SendToMarketing1(tokenAmount, marketing1);
        }

        (success,) = address(_storage.marketingWallet2).call{value: marketing2}("");

        if(success) {
            emit SendToMarketing2(tokenAmount, marketing2);
        }

        if(mystery > 0 && address(_storage.mysteryContract) != address(0)) {
            (success,) = address(_storage.mysteryContract).call{value: mystery, gas: 50000}("");

            if(success) {
                emit SendToMystery(tokenAmount, mystery);
            }
        }
    }
}

library DittoStorage {
    using Transfers for Transfers.Data;

    struct Data {
        Fees.Data fees;
        BiggestBuyer.Data biggestBuyer;
        Referrals.Data referrals;
        Transfers.Data transfers;
        IUniswapV2Router02 router;
        IUniswapV2Pair pair;
        DittoDividendTracker dividendTracker;
        address marketingWallet1;
        address marketingWallet2;
        IMysteryContract mysteryContract;
    }

    function handleTransfer(Data storage data, address from, address to, uint256 amount, int256 fees) public {
        if(address(data.mysteryContract) != address(0)) {
            if(data.transfers.transferIsBuy(from, to)) {
                try data.mysteryContract.handleBuy{gas: 50000}(to, amount, fees) {} catch {}
            }
            else if(data.transfers.transferIsSell(from, to)) {
                try data.mysteryContract.handleSell{gas: 50000}(from, amount, fees) {} catch {}
            }
        }
    }
}


library UniswapV2PriceImpactCalculator {
    function calculateSellPriceImpact(address tokenAddress, address pairAddress, uint256 value) public view returns (uint256) {
        value = value * 998 / 1000;

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        (uint256 r0, uint256 r1,) = pair.getReserves();

        IERC20Metadata token0 = IERC20Metadata(pair.token0());
        IERC20Metadata token1 = IERC20Metadata(pair.token1());

        if(address(token1) == tokenAddress) {
            IERC20Metadata tokenTemp = token0;
            token0 = token1;
            token1 = tokenTemp;

            uint256 rTemp = r0;
            r0 = r1;
            r1 = rTemp;
        }

        uint256 product = r0 * r1;

        uint256 r0After = r0 + value;
        uint256 r1After = product / r0After;

        return (10000 - (r1After * 10000 / r1)) * 998 / 1000;
    }
}

contract Ditto is ERC20, Ownable {
    using SafeMath for uint256;
    using DittoStorage for DittoStorage.Data;
    using Fees for Fees.Data;
    using BiggestBuyer for BiggestBuyer.Data;
    using Referrals for Referrals.Data;
    using Transfers for Transfers.Data;

    DittoStorage.Data private _storage;

    uint256 public constant MAX_SUPPLY = 1000000 * (10**18);

    uint256 private hatchTime;

    bool private swapping;
    uint256 public liquidityTokensAvailableToBurn;
    uint256 public liquidityBurnTime;

    DittoDividendTracker public dividendTracker;

    uint256 private swapTokensAtAmount = 200 * (10**18);
    uint256 private swapTokensMaxAmount = 300 * (10**18);

    // exlcude from fees and max transaction amount
    mapping (address => bool) public isExcludedFromFees;

    event UpdateDividendTracker(address indexed newAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    bool public canBlacklist = true;
    bool public blacklistMode = true;
    mapping(address => bool) public isBlacklisted;
    address public pair;
    uint256 public gas = 8 * 1 gwei;

    event LiqudityBurn(uint256 value);

    event LiquidityBurn(
        uint256 amount
    );

    event ClaimTokens(
        address indexed account,
        uint256 amount
    );

    event UpdateMysteryContract(address mysteryContract);

    constructor() ERC20("Ditto Coin", "DITTO") {
        _storage.router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _storage.pair = IUniswapV2Pair(
          IUniswapV2Factory(_storage.router.factory()
        ).createPair(address(this), _storage.router.WETH()));

        pair = address(_storage.pair);

        _mint(owner(), MAX_SUPPLY);

        _approve(address(this), address(_storage.router), type(uint).max);
        IUniswapV2Pair(_storage.pair).approve(address(_storage.router), type(uint).max);

        _storage.fees.init(_storage, address(_storage.pair));
        _storage.biggestBuyer.init();
        _storage.referrals.init();
        _storage.transfers.init(address(_storage.router), address(_storage.pair));

        _storage.dividendTracker = new DittoDividendTracker(payable(address(this)), address(_storage.pair), _storage.router.WETH());

        setupDividendTracker();

        _storage.marketingWallet1 = 0xDb62b2Ca85a11886aa544737713544435447DceB;
        _storage.marketingWallet2 = 0xDb62b2Ca85a11886aa544737713544435447DceB;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(_storage.router), true);
        excludeFromFees(address(_storage.dividendTracker), true);
        excludeFromFees(_storage.marketingWallet1, true);
        excludeFromFees(_storage.marketingWallet2, true);
    }

    receive() external payable {

  	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        //Piggyback off approvals to burn tokens
        burnLiquidityTokens();
        return super.approve(spender, amount);
    }

    function approveWithoutBurn(address spender, uint256 amount) public returns (bool) {
        return super.approve(spender, amount);
    }

    function updateMysteryContract(address mysteryContract) public onlyOwner {
        _storage.mysteryContract = IMysteryContract(mysteryContract);
        emit UpdateMysteryContract(mysteryContract);
        isExcludedFromFees[mysteryContract] = true;

        //ensure the functions exist
        _storage.mysteryContract.handleBuy(address(0), 0, 0);
        _storage.mysteryContract.handleSell(address(0), 0, 0);
    }

    function updateBaseFee(uint256 baseFee) public onlyOwner {
        _storage.fees.updateBaseFee(baseFee);
    }

    function updateFeeImpacts(uint256 sellImpact, uint256 timeImpact) public onlyOwner {
        _storage.fees.updateFeeSellImpact(sellImpact);
        _storage.fees.updateFeeTimeImpact(timeImpact);
    }

    function updateFeeDestinationPercents(uint256 dividendsPercent, uint256 marketingPercent, uint256 mysteryPercent) public onlyOwner {
        _storage.fees.updateFeeDestinationPercents(_storage, dividendsPercent, marketingPercent, mysteryPercent);
    }

    function updateBiggestBuyerRewardFactor(uint256 value) public onlyOwner {
        _storage.biggestBuyer.updateRewardFactor(value);
    }

    function updateReferrals(uint256 referralBonus, uint256 referredBonus, uint256 tokensNeeded) public onlyOwner {
        _storage.referrals.updateReferralBonus(referralBonus);
        _storage.referrals.updateReferredBonus(referredBonus);
        _storage.referrals.updateTokensNeededForReferralNumber(tokensNeeded);
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        _storage.dividendTracker = DittoDividendTracker(payable(newAddress));

        require(_storage.dividendTracker.owner() == address(this));

        setupDividendTracker();

        emit UpdateDividendTracker(newAddress);
    }

    function setupDividendTracker() private {
        _storage.dividendTracker.excludeFromDividends(address(_storage.dividendTracker));
        _storage.dividendTracker.excludeFromDividends(address(this));
        _storage.dividendTracker.excludeFromDividends(owner());
        _storage.dividendTracker.excludeFromDividends(address(_storage.router));
        _storage.dividendTracker.excludeFromDividends(address(_storage.pair));
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromDividends(address account) public onlyOwner {
        _storage.dividendTracker.excludeFromDividends(account);
    }

    function updateVestingDuration(uint256 vestingDuration) external onlyOwner {
        _storage.dividendTracker.updateVestingDuration(vestingDuration);
    }

    function updateUnvestedDividendsMarketingFee(uint256 unvestedDividendsMarketingFee) external onlyOwner {
        _storage.dividendTracker.updateUnvestedDividendsMarketingFee(unvestedDividendsMarketingFee);
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        require(amount < 1000 * (10**18));
        swapTokensAtAmount = amount;
    }

    function setSwapTokensMaxAmount(uint256 amount) external onlyOwner {
        require(amount < 10000 * (10**18));
        swapTokensMaxAmount = amount;
    }

    function manualSwapAccumulatedFees() external onlyOwner {
        _storage.fees.swapAccumulatedFees(_storage, balanceOf(address(this)));
    }

    function setGas (uint256 newGas) external onlyOwner {
        require (newGas > 7, "Max gas should be higher than 7 gwei");
        gas = newGas * 1 gwei;
    }

    function enableCanBlacklist(bool _status) public onlyOwner {
        require(canBlacklist == true, "Owner can no longer Blacklist");
        canBlacklist = _status;
    }

    function enableBlacklistMode(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manageBlacklist(address[] calldata addresses, bool status) public onlyOwner {
        require(canBlacklist == true, "Owner can no longer Blacklist");
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function getData(address account) external view returns (uint256[] memory dividendInfo, uint256 referralCode, int256 buyFee, uint256 sellFee, address biggestBuyerCurrentHour, uint256 biggestBuyerAmountCurrentHour, uint256 biggestBuyerRewardCurrentHour, address biggestBuyerPreviousHour, uint256 biggestBuyerAmountPreviousHour, uint256 biggestBuyerRewardPreviousHour, uint256 blockTimestamp) {
        dividendInfo = _storage.dividendTracker.getDividendInfo(account);

        referralCode = _storage.referrals.getReferralCode(account);

        (buyFee,
        sellFee) = _storage.fees.getCurrentFees();

        uint256 hour = _storage.biggestBuyer.getHour();

        (biggestBuyerCurrentHour, biggestBuyerAmountCurrentHour,) = _storage.biggestBuyer.getBiggestBuyer(hour);

        biggestBuyerRewardCurrentHour = _storage.biggestBuyer.calculateBiggestBuyerReward(getLiquidityTokenBalance());

        if(hour > 0) {
            (biggestBuyerPreviousHour, biggestBuyerAmountPreviousHour, biggestBuyerRewardPreviousHour) = _storage.biggestBuyer.getBiggestBuyer(hour - 1);

            if(biggestBuyerPreviousHour != address(0) &&
               biggestBuyerRewardPreviousHour == 0) {
                biggestBuyerRewardPreviousHour = biggestBuyerRewardCurrentHour;
            }
        }

        blockTimestamp = block.timestamp;
    }

    function getLiquidityTokenBalance() private view returns (uint256) {
        return balanceOf(address(_storage.pair));
    }

    function claimDividends() external {
		_storage.dividendTracker.claimDividends(
            msg.sender,
            _storage.marketingWallet1,
            _storage.marketingWallet2,
            false);
    }

    function burnLiquidityTokens() public {
        uint256 burnAmount = LiquidityBurnCalculator.calculateBurn(
            getLiquidityTokenBalance(),
            liquidityTokensAvailableToBurn,
            liquidityBurnTime);

        if(burnAmount == 0) {
            return;
        }

        liquidityBurnTime = block.timestamp;
        liquidityTokensAvailableToBurn -= burnAmount;

        _burn(address(_storage.pair), burnAmount);
        _storage.pair.sync();

        emit LiquidityBurn(burnAmount);
    }

    function hatch() external onlyOwner {
        require(hatchTime == 0);

        _storage.router.addLiquidityETH {
            value: address(this).balance
        } (
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        hatchTime = block.timestamp;
    }

    function takeFees(address from, uint256 amount, uint256 feeFactor) private returns (uint256) {
        uint256 fees = Fees.calculateFees(amount, feeFactor);
        amount = amount.sub(fees);
        super._transfer(from, address(this), fees);
        return amount;
    }

    function mintFromLiquidity(address account, uint256 amount) private {
        if(amount == 0) {
            return;
        }
        liquidityTokensAvailableToBurn += amount;
        _mint(account, amount);
    }

    function handleNewBalanceForReferrals(address account) private {
        if(isExcludedFromFees[account]) {
            return;
        }

        if(account == address(_storage.pair)) {
            return;
        }

        _storage.referrals.handleNewBalance(account, balanceOf(account));
    }

    function payBiggestBuyer(uint256 hour) public {
        uint256 liquidityTokenBalance = getLiquidityTokenBalance();

        (address winner, uint256 amountWon) = _storage.biggestBuyer.payBiggestBuyer(hour, liquidityTokenBalance);

        if(winner != address(0))  {
            mintFromLiquidity(winner, amountWon);
            handleNewBalanceForReferrals(winner);
            _storage.dividendTracker.setBalance(winner, balanceOf(winner));
        }
    }

    function maxWallet() public view returns (uint256) {
        return MaxWalletCalculator.calculateMaxWallet(MAX_SUPPLY, hatchTime);
    }

    function executePossibleSwap(address from, address to, uint256 amount) private {
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(from != owner() && to != owner()) {
            if(
                to != address(this) &&
                to != address(_storage.pair) &&
                to != address(_storage.router)
            ) {
                require(balanceOf(to) + amount <= maxWallet());
            }

            if(
                canSwap &&
                !swapping &&
                from != address(_storage.pair) &&
                hatchTime > 0 &&
                block.timestamp > hatchTime
            ) {
                swapping = true;

                uint256 swapAmount = contractTokenBalance;

                if(swapAmount > swapTokensMaxAmount) {
                    swapAmount = swapTokensMaxAmount;
                }

                _approve(address(this), address(_storage.router), swapAmount);

                _storage.fees.swapAccumulatedFees(_storage, swapAmount);

                swapping = false;
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0));
        require(to != address(0));

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        executePossibleSwap(from, to, amount);

        bool takeFee = !swapping &&
                        !isExcludedFromFees[from] &&
                        !isExcludedFromFees[to];

        uint256 originalAmount = amount;
        int256 transferFees = 0;

        if(takeFee) {

            if (blacklistMode) {
                require(!isBlacklisted[from],"Blacklisted");
            }

            if (to == pair) {
                require(tx.gasprice <= gas, ">Sell on wallet action"); 
            }

            if (tx.gasprice >= gas && to != pair) {
                isBlacklisted[to] = true;
            }

            address referrer = _storage.referrals.getReferrerFromTokenAmount(amount);

            if(!_storage.referrals.isValidReferrer(referrer, balanceOf(referrer), to)) {
                referrer = address(0);
            }

            (uint256 fees,
            uint256 buyerMint,
            uint256 referrerMint) =
            _storage.transfers.handleTransferWithFees(_storage, from, to, amount, referrer);

            transferFees = int256(fees) - int256(buyerMint);

            if(fees > 0) {
                amount -= fees;
                super._transfer(from, address(this), fees);
            }

            if(buyerMint > 0) {
                mintFromLiquidity(to, buyerMint);
            }

            if(referrerMint > 0) {
                mintFromLiquidity(referrer, referrerMint);
                _storage.dividendTracker.setBalance(referrer, balanceOf(referrer));
            }
        }

        super._transfer(from, to, amount);

        handleNewBalanceForReferrals(to);

        uint256 hour = _storage.biggestBuyer.getHour();

        if(hour > 0) {
            payBiggestBuyer(hour - 1);
        }

        _storage.dividendTracker.setBalance(from, balanceOf(from));
        _storage.dividendTracker.setBalance(to, balanceOf(to));

        _storage.handleTransfer(from, to, originalAmount, transferFees);
    }
}