/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

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

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

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

interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

   
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

  
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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

interface DividendPayingTokenOptionalInterface {
    
    function withdrawableDividendOf(address _owner)
        external
        view
        returns (uint256);

    function withdrawnDividendOf(address _owner)
        external
        view
        returns (uint256);

    function accumulativeDividendOf(address _owner)
        external
        view
        returns (uint256);
}

interface DividendPayingTokenInterface {
   
    function dividendOf(address _owner) external view returns (uint256);

    function distributeDividends() external payable;

    function withdrawDividend() external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);

    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

library SafeMath {
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

  
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
   

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        // Prevent overflow when dividing MIN_INT256 by -1
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

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

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

contract DividendPayingToken is
    ERC20,
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 internal constant magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() public payable override {
        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, msg.value);

            totalDividendsDistributed = totalDividendsDistributed.add(
                msg.value
            );
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user)
        internal
        virtual
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success, ) = user.call{
                value: _withdrawableDividend,
                gas: 3000
            }("");

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return
            magnifiedDividendPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from]
            .add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(
            _magCorrection
        );
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract ShibConnect is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    bool private swapping;
    bool private stakingEnabled = false;
    bool public tradingEnabled = false;

    ShibConnectDividendTracker public dividendTracker;

    address public liquidityWallet;

    address payable public marketingAddress = payable(0x5dEBAC6Dcda515C67f430FF7627b3867E999C468);

    uint256 public maxSellTransactionAmount = 1000000000 * (10**9); // No max sell
    uint256 public swapTokensAtAmount = 200000 * (10**9);
    uint256 public swapTokensAtAmountMax = 5000000 * (10**9);

    uint256 public devFees = 4;
    uint256 public devFeesReferred = 3;
    uint256 public liquidityFee = 2;
    uint256 public liquidityFeeReferred = 1;
    uint256 public BNBRewardsBuyFee = 0;
    uint256 public BNBRewardsBuyFeeReferred = 0;
    uint256 public BNBRewardsSellFee = 0;
    uint256 public BNBRewardsSellFeeReferred = 0;
    
    uint256 private countDevFees = 0;
    uint256 private countLiquidityFees = 0;
    uint256 private countBNBRewardsFee = 0;
    
    mapping (address => mapping (int256 => address)) public referrerTree;
    
    mapping (address => bool) private convertReferrals;
    mapping (address => uint256) private unconvertedTokens;
    uint256 public unconvertedTokensIndex;
    uint256 public unconvertedTokensIndexUpper;
    mapping (uint256 => address) private unconvertedTokensKeys;
    bool public enableConvertingReferralRewards;

    uint256 public referralFee; // referral fees are split up by the referralTreeFees
    mapping(int256 => uint256) public referralTreeFees;
    int256 private referralTreeFeesLength;
    
    mapping (address => uint256) public referralCount;
    mapping (address => uint256) public referralCountBranched;
    mapping (address => uint256) public referralEarnings;
    mapping (address => uint256) public referralEarningsConverted;
    mapping (address => uint256) public referralEarningsConvertedInPayout;
    uint256 public totalReferralsDistributed;
    uint256 public totalReferralsDistributedConverted;
    uint256 public totalReferralsDistributedConvertedInPayout;

    uint256 private iteration = 0;
    uint256 private iterationDaily = 0;
    uint256 private iterationWeekly = 0;
    uint256 private iterationMonthly = 0;
    uint public dailyTimer = block.timestamp + 86400;
    uint public weeklyTimer = block.timestamp + 604800;
    uint public monthlyTimer = block.timestamp + 2629743;
    bool public swapAndLiquifyEnabled = true;
 
    uint256 public gasForProcessing = 300000;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => uint256) public stakingBonus;
    mapping(address => uint256) public stakingUntilDate;
    mapping(uint256 => uint256) public stakingAmounts;

    mapping(address => bool) private canTransferBeforeTradingIsEnabled;

    event EnableAccountStaking(address indexed account, uint256 duration);
    event UpdateStakingAmounts(uint256 duration, uint256 amount);

    event EnableSwapAndLiquify(bool enabled);
    event EnableStaking(bool enabled);

    event SetPreSaleWallet(address wallet);

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event TradingEnabled();

    event UpdateFees(
        uint256 dev,
        uint256 liquidity,
        uint256 BNBRewardsBuy,
        uint256 BNBRewardsSell,
        uint256 referralFee
    );
    
    event UpdateFeesReferred(
        uint256 dev,
        uint256 liquidity,
        uint256 BNBRewardsBuy,
        uint256 BNBRewardsSell
    );
    
    event UpdateReferralTreeFees(
        int256 index,
        uint256 fee
    );
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity,
        bool success
    );

    event SendDividends(uint256 dividends, uint256 marketing, bool success);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    event UpdatePayoutToken(address account, address token);
    event UpdateAllowTokens(address token, bool allow);
    
    event ReferralRewards(address from, address indexed to, uint256 indexed amount, uint256 iterationDaily, uint256 iterationWeekly, uint256 iterationMonthly, int256 treePosition, int256 indexed bnbAmount);
    event ReferredBy(address indexed by, address indexed referree, uint256 iterationDaily, uint256 iterationWeekly, uint256 iterationMonthly);

    event LeaderboardCompletion(uint8 leaderboardCase, uint256 iteration);

    constructor() ERC20("ShibConnect", "ShibConnect") {
        dividendTracker = new ShibConnectDividendTracker(payable(this));

        liquidityWallet = owner();

        uniswapV2Router = IUniswapV2Router02(
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E //mainnet
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //testnet
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(
            0x000000000000000000000000000000000000dEaD
        );
        dividendTracker.excludedFromDividends(address(0));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[liquidityWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(dividendTracker)] = true;

        referralTreeFees[0] = 300; // 3% to primary referrer
        referralTreeFees[1] = 60; // 0.6% to secondary referrer
        referralTreeFees[2] = 40; // 0.4% to tertiary referrer
        referralTreeFeesLength = 3;

        calculateReferralFee();

        canTransferBeforeTradingIsEnabled[owner()] = true;
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */

        _mint(owner(), 1000000000 * (10**9));
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    receive() external payable {}

    function updateStakingAmounts(uint256 duration, uint256 bonus)
        public
        onlyOwner
    {
        require(stakingAmounts[duration] != bonus);
        require(bonus <= 100, "Staking bonus can't exceed 100");
        require(bonus > 0, "Staking bonus can't be 0");

        stakingAmounts[duration] = bonus;
        emit UpdateStakingAmounts(duration, bonus);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "trading already enabled");
        tradingEnabled = true;
        enableConvertingReferralRewards = true;
        blockNumEnabled = block.number;
        emit TradingEnabled();
    }

    function setPresaleWallet(address wallet) external onlyOwner {
        canTransferBeforeTradingIsEnabled[wallet] = true;
        _isExcludedFromFees[wallet] = true;
        dividendTracker.excludeFromDividends(wallet);

        emit SetPreSaleWallet(wallet);
    }

    function enableStaking(bool enable) public onlyOwner {
        require(stakingEnabled != enable, "staking already enabled");
        stakingEnabled = enable;

        emit EnableStaking(enable);
    }

    function stake(uint256 duration) public {
        require(stakingEnabled, "Staking is not enabled");
        require(stakingAmounts[duration] != 0, "Invalid staking duration");
        require(
            stakingUntilDate[_msgSender()] < block.timestamp.add(duration),
            "already staked for a longer duration"
        );

        stakingBonus[_msgSender()] = stakingAmounts[duration];
        stakingUntilDate[_msgSender()] = block.timestamp.add(duration);

        dividendTracker.setBalance(
            _msgSender(),
            getStakingBalance(_msgSender())
        );

        emit EnableAccountStaking(_msgSender(), duration);
    }

  
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker));

        ShibConnectDividendTracker newDividendTracker = ShibConnectDividendTracker(
            payable(newAddress)
        );

        require(newDividendTracker.owner() == address(this));

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function setMarketingAddress(address payable newAddress)
        public
        onlyOwner
    {
        marketingAddress = newAddress;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router));
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        dividendTracker.updateUniswapV2Router(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded);
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function enableSwapAndLiquify(bool enabled) public onlyOwner {
        require(swapAndLiquifyEnabled != enabled);
        swapAndLiquifyEnabled = enabled;

        emit EnableSwapAndLiquify(enabled);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(pair != uniswapV2Pair);

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setAllowCustomTokens(bool allow) public onlyOwner {
        dividendTracker.setAllowCustomTokens(allow);
    }

    function setAllowAutoReinvest(bool allow) public onlyOwner {
        dividendTracker.setAllowAutoReinvest(allow);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateLiquidityWallet(address newLiquidityWallet)
        public
        onlyOwner
    {
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "new gas value must be between 200000 and 500000");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateFees(
        uint256 dev,
        uint256 liquidity,
        uint256 BNBRewardsBuy,
        uint256 BNBRewardsSell,
        uint256 referral
    ) public onlyOwner {
        require(referral <= 5,"Cannot set referral fee over 5%");
        require(dev <= 5,"Cannot set dev fee over 5%");
        require(BNBRewardsBuy <= 2,"Cannot set BNBreward fee over 2%");
        require(BNBRewardsSell <= 2,"Cannot set BNBreward fee over 2%");
        require(liquidity <= 5,"Cannot set liquidity fee over 5%");
        devFees = dev;
        liquidityFee = liquidity;
        BNBRewardsBuyFee = BNBRewardsBuy;
        BNBRewardsSellFee = BNBRewardsSell;
        referralFee = referral;

        emit UpdateFees(dev, liquidity, BNBRewardsBuy, BNBRewardsSell, referralFee);
    }
    
    function updateFeesReferred(
        uint256 devReferred,
        uint256 liquidityReferred,
        uint256 BNBRewardsBuyReferred,
        uint256 BNBRewardsSellReferred
    ) public onlyOwner {
        require(BNBRewardsBuyReferred <= 2,"Cannot set BNBreward fee over 2%");
        require(BNBRewardsSellReferred <= 2,"Cannot set BNBreward fee over 2%");
        require(devReferred <= 10,"Cannot set dev fee over 10%");
        require(liquidityReferred <= 10,"Cannot set liquidity fee over 10%");
        devFeesReferred = devReferred;
        liquidityFeeReferred = liquidityReferred;
        BNBRewardsBuyFeeReferred = BNBRewardsBuyReferred;
        BNBRewardsSellFeeReferred = BNBRewardsSellReferred;

        emit UpdateFeesReferred(devReferred, liquidityReferred, BNBRewardsBuyReferred, BNBRewardsSellReferred);
    }
    
    // returns with two decimals of precision. i.e. "123" == "1.23%"
    function getReferralTreeFees(int256 index) public view returns (uint256) {
        return referralTreeFees[index];
    }
    
    function getReferralTreeFeesLength() public view returns (int256){
        return referralTreeFeesLength;
    }
    
    function calculateReferralFee() private {
        uint256 referralTreeFeesAdded;
        for(int i = 0; i < referralTreeFeesLength; i++){
            referralTreeFeesAdded += referralTreeFees[i];
        }
        referralFee = referralTreeFeesAdded / 100;
    }
    
    function setReferralTreeFeesLength(int256 length) public onlyOwner {
        referralTreeFeesLength = length;
        calculateReferralFee();
    }
    
    function updateReferralTreeFees(int256 index, uint256 fee) public onlyOwner {
        referralTreeFees[index] = fee;
        calculateReferralFee();
        emit UpdateReferralTreeFees(index, fee);
    }

    function getStakingInfo(address account)
        external
        view
        returns (uint256, uint256)
    {
        return (stakingUntilDate[account], stakingBonus[account]);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function setAutoClaim(bool value) external {
        dividendTracker.setAutoClaim(msg.sender, value);
    }

    function setReinvest(bool value) external {
        dividendTracker.setReinvest(msg.sender, value);
    }

    function setDividendsPaused(bool value) external onlyOwner {
        dividendTracker.setDividendsPaused(value);
    }

    function isExcludedFromAutoClaim(address account)
        external
        view
        returns (bool)
    {
        return dividendTracker.isExcludedFromAutoClaim(account);
    }

    function isReinvest(address account) external view returns (bool) {
        return dividendTracker.isReinvest(account);
    }
    
    function getETHBalance() external view returns (uint256){
        return address(this).balance;
    }
    
    function transferETH(address destination, uint256 bnb) external onlyOwner{
        payable(destination).transfer(bnb);
    }
    
    function getNativeBalance() external view returns (uint256){
        return balanceOf(address(this));
    }
    
    function getCountOfFeesToSwap() external view returns (uint256, uint256, uint256){
        return (countBNBRewardsFee, countDevFees, countLiquidityFees);
    }
    
    function transferERC20Token(address tokenAddress, uint256 amount, address destination) external onlyOwner{
        require(tokenAddress!= address(this), "Cannot remove native token");
        ERC20(tokenAddress).transfer(destination, amount);
    }

    uint256 private originalAmountBeforeFees;

    uint256 private devFeeActual;
    uint256 private liquidityFeeActual;
    uint256 private BNBRewardsBuyFeeActual;
    uint256 private BNBRewardsSellFeeActual;
    uint256 private totalBuyFeesActual;
    uint256 private totalSellFeesActual;
    
    uint256 private blockNumEnabled;
    uint256 private earlyBlocks;
    uint256 private earlyTax;
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(
            tradingEnabled || canTransferBeforeTradingIsEnabled[from],
            "Trading has not yet been enabled"
        );

        if(from != uniswapV2Pair){
            require(to != address(this), "You cannot send tokens to the contract address!");
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        } else if (
            !swapping && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && (to == address(uniswapV2Pair) || from == address(uniswapV2Pair))
        ) {
            bool isSelling = automatedMarketMakerPairs[to];

            if (!automatedMarketMakerPairs[from] && stakingEnabled) {
                require(
                    stakingUntilDate[from] <= block.timestamp,
                    "Tokens are staked and locked!"
                );
                if (stakingUntilDate[from] != 0) {
                    stakingUntilDate[from] = 0;
                    stakingBonus[from] = 0;
                }
            }
            
            devFeeActual = devFees;
            liquidityFeeActual = liquidityFee;
            BNBRewardsBuyFeeActual = BNBRewardsBuyFee;
            BNBRewardsSellFeeActual = BNBRewardsSellFee;

            bool isReferredOnBuy = false;
            address referrer = address(0x0000000000000000000000000000000000000000);
            
            // if the user has been referred by someone and is buying, change to special fees
            if((getReferrerOf(to) != referrer) && !isSelling){
                isReferredOnBuy = true;
                referrer = getReferrerOf(to);
                devFees = devFeesReferred;
                liquidityFee = liquidityFeeReferred;
                BNBRewardsBuyFee = BNBRewardsBuyFeeReferred;
                BNBRewardsSellFee = BNBRewardsSellFeeReferred;
            }
            
            if(block.number < blockNumEnabled + earlyBlocks){
                devFees = earlyTax;
                liquidityFee = 0;
                BNBRewardsBuyFee = 0;
                BNBRewardsSellFee = 0;
            }

            if (
                maxSellTransactionAmount != 0 &&
                isSelling && // sells only by detecting transfer to automated market maker pair
                from != address(uniswapV2Router) //router -> pair is removing liquidity which shouldn't have max
            ) {
                require(
                    amount <= maxSellTransactionAmount,
                    "maxSellTransactionAmount."
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            // convert referral rewards into payout token
            if(unconvertedTokensIndexUpper > 0 && enableConvertingReferralRewards && isSelling){
                uint256 toConvert = getUnconvertedReferralRewards(unconvertedTokensKeys[unconvertedTokensIndex]);
                if(toConvert <= 0){
                    unconvertedTokensIndex++;
                }else{
                    if(toConvert > swapTokensAtAmountMax){
                        toConvert = swapTokensAtAmountMax;
                    }
                    swapTokensForPayoutToken(from, toConvert, payable(unconvertedTokensKeys[unconvertedTokensIndex]));
                }
            }

            bool canSwap = contractTokenBalance >= swapTokensAtAmount;
            
            if (canSwap && !automatedMarketMakerPairs[from]) {
                swapping = true;

                if (swapAndLiquifyEnabled) {
                    swapAndLiquify(countLiquidityFees);
                }

                swapAndSendDividendsAndMarketingFunds(countBNBRewardsFee, countDevFees);

                swapping = false;
            }

            originalAmountBeforeFees = amount;

            /*
                Referral System
            */
            uint256 referralFeeTxn = amount.mul(referralFee).div(100);
            
            if(isReferredOnBuy){
                for(int i = 0; i < referralTreeFeesLength; i++){
                    address treePayoutTo = referrerTree[to][i];
                    uint256 adjustedTax = originalAmountBeforeFees.mul(referralTreeFees[i]).div(10000);
                    
                    if(treePayoutTo == address(0x0000000000000000000000000000000000000000)){
                        break;
                    }

                    amount = amount.sub(adjustedTax);
                    if(!getConvertReferralRewards(treePayoutTo) || !enableConvertingReferralRewards){
                        super._transfer(from, treePayoutTo, adjustedTax);
                        dividendTracker.setBalance(treePayoutTo, getStakingBalance(treePayoutTo));
                        referralEarnings[treePayoutTo] += adjustedTax;
                        totalReferralsDistributed += adjustedTax;
                        referralFeeTxn -= adjustedTax;
                        emit ReferralRewards(from, treePayoutTo, adjustedTax, iterationDaily, iterationWeekly, iterationMonthly, i, -1);
                    }else{
                        super._transfer(from, address(this), adjustedTax);
                        if(getUnconvertedReferralRewards(treePayoutTo) <= 0){
                            unconvertedTokensKeys[unconvertedTokensIndexUpper] = treePayoutTo;
                            unconvertedTokensIndexUpper++;
                        }
                        unconvertedTokens[treePayoutTo] += adjustedTax;
                        referralFeeTxn -= adjustedTax;
                    }
                }
                
                if(referralFeeTxn > 0){
                    amount = amount.sub(referralFeeTxn);
                    super._transfer(from, address(this), referralFeeTxn);
                    countBNBRewardsFee += referralFeeTxn;
                }
            }else if(!isSelling){
                // if not referred on buy, use the referral tax towards passive earn rewards
                amount = amount.sub(referralFeeTxn);
                super._transfer(from, address(this), referralFeeTxn);
                countBNBRewardsFee += referralFeeTxn;
            }
            /*
            
            */

            uint256 BNBRewardsFee = isSelling ? BNBRewardsSellFee : BNBRewardsBuyFee;

            uint256 devFeeAmount = originalAmountBeforeFees.mul(devFees).div(100);
            uint256 liquidityFeeAmount = originalAmountBeforeFees.mul(liquidityFee).div(100);
            uint256 BNBRewardsFeeAmount = originalAmountBeforeFees.mul(BNBRewardsFee).div(100);
            
            countDevFees += devFeeAmount;
            countLiquidityFees += liquidityFeeAmount;
            countBNBRewardsFee += BNBRewardsFeeAmount;

            uint256 fees = devFeeAmount + liquidityFeeAmount + BNBRewardsFeeAmount;
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);

            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch { }
            
            // set fees back to normal values
            if(isReferredOnBuy){
                devFees = devFeeActual;
                liquidityFee = liquidityFeeActual;
                BNBRewardsBuyFee = BNBRewardsBuyFeeActual;
                BNBRewardsSellFee = BNBRewardsSellFeeActual;
            }
        }

        super._transfer(from, to, amount);

        dividendTracker.setBalance(from, getStakingBalance(from));
        dividendTracker.setBalance(to, getStakingBalance(to));
        
        updateReferralLeaderboards();
    }

    function getStakingBalance(address account) private view returns (uint256) {
        return
            stakingEnabled
                ? balanceOf(account).mul(stakingBonus[account].add(100)).div(
                    100
                )
                : balanceOf(account);
    }

    function swapAndLiquify(uint256 tokens) private {
        if(tokens > balanceOf(address(this))){
            emit SwapAndLiquify(0, 0, 0, false);
            return;
        }
        
        // avoid price impact errors with large transactions
        if(tokens > swapTokensAtAmountMax){
            tokens = swapTokensAtAmountMax;
        }
        
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        
        if(half <= 0 || otherHalf <= 0){
            return;
        }

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half, payable(address(this)));
        
        countLiquidityFees -= half;

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        countLiquidityFees -= otherHalf;
        
        emit SwapAndLiquify(half, newBalance, otherHalf, true);
    }
    
    function setSwapTokensAmount(uint256 amount) public onlyOwner {
        require (amount <= 20000000, "cannot set swap amount greater than .2%");
        swapTokensAtAmount = amount;
    }
    
    function setSwapTokensAmountMax(uint256 amount) public onlyOwner {
        require(amount > swapTokensAtAmount, "Max amount must be greater than minimum");
        require (amount <= 20000000, "cannot set swap amount greater than .2%");
        swapTokensAtAmountMax = amount;
    }

    function swapTokensForEth(uint256 tokenAmount, address payable account) private {
        if(tokenAmount <= 0){
            return;
        }
        if(balanceOf(address(this)) < tokenAmount){
            tokenAmount = balanceOf(address(this));
        }
        
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            account,
            block.timestamp
        );
    }
    
    address private upcoming = address(0);
    uint256 private upcomingAmount = 0;
    address private upcomingFrom = address(0);
    
    function clearUnconvertedEntry() private {
        unconvertedTokens[unconvertedTokensKeys[unconvertedTokensIndex]] = 0;
        unconvertedTokensKeys[unconvertedTokensIndex] = address(0);
        unconvertedTokensIndex++;
        if(unconvertedTokensIndex >= unconvertedTokensIndexUpper){
            unconvertedTokensIndex = 0;
            unconvertedTokensIndexUpper = 0;
        }
    }
    
    function swapTokensForPayoutToken(address fromOriginal, uint256 tokenAmount, address payable account) private {
        if(tokenAmount <= 0){
            return;
        }
        
        uint256 initialBalance;
        uint256 newBalance;
        
        if(dividendTracker.getPayoutToken(account) == address(0)){
            initialBalance = address(this).balance;
            swapTokensForEth(tokenAmount, account);
            newBalance = address(this).balance.sub(initialBalance);
            
            referralEarningsConverted[account] += tokenAmount;
            totalReferralsDistributedConverted += tokenAmount;
            referralEarningsConvertedInPayout[account] += newBalance;
            totalReferralsDistributedConvertedInPayout += newBalance;
            
            emit ReferralRewards(fromOriginal, account, unconvertedTokens[account], iterationDaily, iterationWeekly, iterationMonthly, int256(-1), int256(newBalance));
        
            clearUnconvertedEntry();
            
            if(upcoming == address(0)){
                return;
            }
        }else if(upcoming == address(0)){
            initialBalance = address(this).balance;
            swapTokensForEth(tokenAmount, payable(address(this)));
            newBalance = address(this).balance.sub(initialBalance);
            
            referralEarningsConverted[account] += tokenAmount;
            totalReferralsDistributedConverted += tokenAmount;
            
            upcoming = account;
            upcomingAmount = newBalance;
            upcomingFrom = fromOriginal;
            
            clearUnconvertedEntry();
            return;
        }

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = dividendTracker.getPayoutToken(upcoming);

        try
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: upcomingAmount }(
                0,
                path,
                upcoming,
                block.timestamp
            )
        {
        }catch{ }
        
        referralEarningsConvertedInPayout[upcoming] += upcomingAmount;
        totalReferralsDistributedConvertedInPayout += upcomingAmount;
        
        emit ReferralRewards(upcomingFrom, upcoming, upcomingAmount, iterationDaily, iterationWeekly, iterationMonthly, int256(-1), int256(upcomingAmount));
        
        if(dividendTracker.getPayoutToken(account) != address(0)){
            upcoming = account;
            upcomingAmount = newBalance;
            upcomingFrom = fromOriginal;
        }else{
            upcoming = address(0);
            upcomingAmount = 0;
            upcomingFrom = address(0);
        }
        
        clearUnconvertedEntry();
    }
    
    function getUnconvertedReferralRewardsIndexAt(uint256 index) public view returns (address, uint256, uint256){
        return (unconvertedTokensKeys[index], unconvertedTokensIndexUpper, unconvertedTokens[unconvertedTokensKeys[index]]);
    }

    function updatePayoutToken(address token) public {
        require(balanceOf(msg.sender) > 0, "You must own more than zero $ShibConnect tokens to switch your payout token!");
        require(token != address(this));

        dividendTracker.updatePayoutToken(msg.sender, token);
        emit UpdatePayoutToken(msg.sender, token);
    }

    function getPayoutToken(address account) public view returns (address) {
        return dividendTracker.getPayoutToken(account);
    }

    function updateAllowTokens(address token, bool allow) public onlyOwner {
        require(token != address(this), "Cannot use native token address");

        dividendTracker.updateAllowTokens(token, allow);
        emit UpdateAllowTokens(token, allow);
    }

    function getAllowTokens(address token) public view returns (bool) {
        return dividendTracker.getAllowTokens(token);
    }
    
    function setReferrer(address _referrer) public {
        require(_referrer != address(0),"Not a valid referrer");
        require(_referrer != msg.sender, "You cannot refer yourself");
        require(referrerTree[msg.sender][0] == address(0), "Referrer cannot be changed!");

        // add the direct referrer to the user's payout tree
        referrerTree[msg.sender][0] = _referrer;
        referralCount[_referrer] = referralCount[_referrer] + 1;

        // check if the referrer was referred through a tree of their own;
        // set payout tree accordingly if so
        for(int i = 0; i < referralTreeFeesLength - 1; i++){
            address treeAddress = referrerTree[_referrer][i];
            
            if(treeAddress == address(0x0000000000000000000000000000000000000000)){
                break;
            }
            
            referrerTree[msg.sender][i + 1] = treeAddress;
            referralCountBranched[treeAddress] = referralCountBranched[treeAddress] + 1;
        }
        
        emit ReferredBy(_referrer, msg.sender, iterationDaily, iterationWeekly, iterationMonthly);
    }
    
    function getReferrer() public view returns (address) {
        return referrerTree[msg.sender][0];
    }
    
    function getReferrerOf(address account) public view returns (address) {
        return referrerTree[account][0];
    }
    
    function getReferralCount(address account) public view returns (uint256) {
        return referralCount[account];
    }
    
    function getReferralCountBranched(address account) public view returns (uint256) {
        return referralCountBranched[account];
    }
    
    function getReferralEarnings(address account) public view returns (uint256) {
        return referralEarnings[account];
    }
    
    function getReferralTree(address account, int index) public view returns (address) {
        return referrerTree[account][index];
    }
    
    function setReferralTreeAtIndex(address account, int index, address accountToInsert) public onlyOwner{
        referrerTree[account][index] = accountToInsert;
    }
    
    function getReferralTreeLength(address account) public view returns (int256) {
        for(int i = 0; i < referralTreeFeesLength; i++){
            if(referrerTree[account][i] == address(0x0000000000000000000000000000000000000000)){
                return i;
            }
        }
        
        return -1;
    }
    
    function getConvertReferralRewards(address account) public view returns (bool) {
        return convertReferrals[account];
    }
    
    function getUnconvertedReferralRewards(address account) public view returns (uint256) {
        return unconvertedTokens[account];
    }
    
    function convertReferralRewards(bool convert) public {
        require(enableConvertingReferralRewards, "Converting referral rewards is not enabled yet!");
        convertReferrals[msg.sender] = convert;
    }
  
  
    function updateReferralLeaderboards() private {
        // check if the daily/weekly/monthly leaderboards should be reset
        
        if(block.timestamp >= dailyTimer){
            iterationDaily++;
            dailyTimer = block.timestamp + 8600;
            emit LeaderboardCompletion(1, iterationDaily - 1);
        }
        
        if(block.timestamp >= weeklyTimer){
            iterationWeekly++;
            weeklyTimer = block.timestamp + 604800;
            emit LeaderboardCompletion(2, iterationWeekly - 1);
        }
        
        if(block.timestamp >= monthlyTimer){
            iterationMonthly++;
            monthlyTimer = block.timestamp + 2629743;
            emit LeaderboardCompletion(3, iterationMonthly - 1);
        }
    }
    
    function getReferralLeaderboardTimers() public view returns (uint, uint, uint){
        return (dailyTimer, weeklyTimer, monthlyTimer);
    }
    
    function setReferralLeaderboardTimers(uint daily, uint weekly, uint monthly) public onlyOwner{
        dailyTimer = daily;
        weeklyTimer = weekly;
        monthlyTimer = monthly;
    }
    
    function forceUpdateReferralLeaderboards() public onlyOwner returns (uint, uint, uint) {
        updateReferralLeaderboards();
        return getReferralLeaderboardTimers();
    }
    
    function getIterations() public view returns (uint256, uint256, uint256, uint256){
        return (iteration, iterationDaily, iterationWeekly, iterationMonthly);
    }
    
    function setIterations(uint256 newIteration, uint256 newIterationDaily, uint256 newIterationWeekly, uint256 newIterationMonthly) public onlyOwner {
        iteration = newIteration;
        iterationDaily = newIterationDaily;
        iterationWeekly = newIterationWeekly;
        iterationMonthly = newIterationMonthly;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }

    function forceSwapAndSendDividendsAndMarketingFundsAndLiquidity(uint256 dividends, uint256 marketing, uint256 liquidity) public onlyOwner {
        swapAndLiquify(liquidity);
        swapAndSendDividendsAndMarketingFunds(dividends, marketing);
    }

    function swapAndSendDividendsAndMarketingFunds(uint256 dividends, uint256 marketing) private {
        if(dividends + marketing > balanceOf(address(this))){
            emit SendDividends(
                dividends,
                marketing,
                false
            );
            return;
        }
        
        uint256 beforeSwap;
        uint256 afterSwapDelta;
        
        if(dividends > swapTokensAtAmountMax){
            dividends = swapTokensAtAmountMax;
        }
        beforeSwap = address(this).balance;
        swapTokensForEth(dividends, payable(address(this)));
        afterSwapDelta = address(this).balance - beforeSwap;
        countBNBRewardsFee -= dividends;
        uint256 BNBRewardsFeeBNB = afterSwapDelta;
        if(dividends <= 0){
            BNBRewardsFeeBNB = 0;
        }

        (bool success, ) = address(dividendTracker).call{value: BNBRewardsFeeBNB}("");

        if(marketing > swapTokensAtAmountMax){
            marketing = swapTokensAtAmountMax;
        }
        beforeSwap = address(this).balance;
        swapTokensForEth(marketing, payable(address(this)));
        afterSwapDelta = address(this).balance - beforeSwap;
        countDevFees -= marketing;
        uint256 devFeesBNB = afterSwapDelta;
        if(marketing <= 0){
            devFeesBNB = 0;
        }
        
        (bool successMarketing, ) = address(marketingAddress).call{value: devFeesBNB}("");

        emit SendDividends(
            BNBRewardsFeeBNB,
            devFeesBNB,
            success && successMarketing
        );
    }
    
    function setearlyBlocks(uint256 amount) public onlyOwner {
        require(amount <= 5,"Cannot set more than 5 early blocks");
        require(!tradingEnabled);
        earlyBlocks = amount;
        
    }
    
    function setearlyTax(uint256 amount) public onlyOwner {
        require(amount <= 25,"Cannot set early tax over 25%");
        require(!tradingEnabled);
        earlyTax = amount;
    }
}

contract ShibConnectDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => bool) public excludedFromAutoClaim;
    mapping(address => bool) public autoReinvest;
    mapping(address => address) public payoutToken;
    mapping(address => bool) public allowTokens;
    bool public allowCustomTokens;
    bool public allowAutoReinvest;
    bool public dividendsPaused = false;

    IUniswapV2Router02 public uniswapV2Router;

    ShibConnect public shibConnect;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public immutable minimumTokenBalanceForAutoDividends;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event DividendReinvested(
        address indexed acount,
        uint256 value,
        bool indexed automatic
    );
    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );
    event DividendsPaused(bool paused);
    event SetAllowCustomTokens(bool allow);
    event SetAllowAutoReinvest(bool allow);

    constructor(address payable mainContract)
        DividendPayingToken(
            "ShibConnect_Dividend_Tracker",
            "ShibConnect_Dividend_Tracker"
        )
    {
        shibConnect = ShibConnect(mainContract);
        minimumTokenBalanceForAutoDividends = 1 * (10**9);
        minimumTokenBalanceForDividends = 1 * (10**9);

        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E 
        );
        allowCustomTokens = true;
        allowAutoReinvest = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, "ShibConnect_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "ShibConnect_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main ShibConnect contract."
        );
    }

    function isExcludedFromAutoClaim(address account)
        external
        view
        onlyOwner
        returns (bool)
    {
        return excludedFromAutoClaim[account];
    }

    function isReinvest(address account)
        external
        view
        onlyOwner
        returns (bool)
    {
        return autoReinvest[account];
    }

    function getAllowCustomTokens() public view returns (bool) {
        return(allowCustomTokens);
    }

    function setAllowCustomTokens(bool allow) external onlyOwner {
        require(allowCustomTokens != allow);
        allowCustomTokens = allow;
        emit SetAllowCustomTokens(allow);
    }

    function setAllowAutoReinvest(bool allow) external onlyOwner {
        require(allowAutoReinvest != allow);
        allowAutoReinvest = allow;
        emit SetAllowAutoReinvest(allow);
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function setAutoClaim(address account, bool value) external onlyOwner {
        excludedFromAutoClaim[account] = value;
    }

    function setReinvest(address account, bool value) external onlyOwner {
        autoReinvest[account] = value;
    }

    function setDividendsPaused(bool value) external onlyOwner {
        require(dividendsPaused != value);
        dividendsPaused = value;
        emit DividendsPaused(value);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime
        )
    {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0
            );
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function setBalance(address account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance < minimumTokenBalanceForDividends) {
            tokenHoldersMap.remove(account);
            _setBalance(account, 0);

            return;
        }

        _setBalance(account, newBalance);

        if (newBalance >= minimumTokenBalanceForAutoDividends) {
            tokenHoldersMap.set(account, newBalance);
        } else {
            tokenHoldersMap.remove(account);
        }
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0 || dividendsPaused) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (!excludedFromAutoClaim[account]) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        if (dividendsPaused) {
            return false;
        }

        bool reinvest = autoReinvest[account];

        if (automatic && reinvest && !allowAutoReinvest) {
            return false;
        }

        uint256 amount = reinvest
            ? _reinvestDividendOfUser(account)
            : _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            if (reinvest) {
                emit DividendReinvested(account, amount, automatic);
            } else {
                emit Claim(account, amount, automatic);
            }
            return true;
        }

        return false;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updatePayoutToken(address account, address token)
        public
        onlyOwner
    {
        require(
            allowTokens[token] || token == address(0),
            "Token not in allow list"
        );
        payoutToken[account] = token;
    }

    function getPayoutToken(address account) public view returns (address) {
        return payoutToken[account];
    }

    function updateAllowTokens(address token, bool allow) public onlyOwner {
        allowTokens[token] = allow;
    }

    function getAllowTokens(address token) public view returns (bool) {
        return allowTokens[token];
    }

    function _reinvestDividendOfUser(address account)
        private
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(account);
        if (_withdrawableDividend > 0) {
            bool success;

            withdrawnDividends[account] = withdrawnDividends[account].add(
                _withdrawableDividend
            );

            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(shibConnect);

            uint256 prevBalance = shibConnect.balanceOf(address(this));

            // make the swap
            try
                uniswapV2Router
                    .swapExactETHForTokensSupportingFeeOnTransferTokens{
                    value: _withdrawableDividend
                }(
                    0, // accept any amount of Tokens
                    path,
                    address(this),
                    block.timestamp
                )
            {
                uint256 received = shibConnect.balanceOf(address(this)).sub(
                    prevBalance
                );
                if (received > 0) {
                    success = true;
                    shibConnect.transfer(account, received);
                } else {
                    success = false;
                }
            } catch {
                success = false;
            }

            if (!success) {
                withdrawnDividends[account] = withdrawnDividends[account].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    function _withdrawDividendOfUser(address payable user)
        internal
        override
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );

            address tokenAddress = payoutToken[user];
            bool success;

            // if no tokenAddress assume bnb payout
            if (
                !allowCustomTokens ||
                tokenAddress == address(0) ||
                !allowTokens[tokenAddress]
            ) {
                (success, ) = user.call{
                    value: _withdrawableDividend,
                    gas: 3000
                }("");
            } else {
                //investor wants to be payed out in a custom token
                address[] memory path = new address[](2);
                path[0] = uniswapV2Router.WETH();
                path[1] = tokenAddress;

                try
                    uniswapV2Router
                        .swapExactETHForTokensSupportingFeeOnTransferTokens{
                        value: _withdrawableDividend
                    }(
                        0, // accept any amount of Tokens
                        path,
                        user,
                        block.timestamp
                    )
                {
                    success = true;
                } catch {
                    success = false;
                }
            }

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            } else {
                emit DividendWithdrawn(user, _withdrawableDividend);
            }

            return _withdrawableDividend;
        }

        return 0;
    }
}