/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
MetaReflect Coin ($MRF) is a deflationary token designed to become scarcer over time. Holders of $MRF will earn an 8% reward from every Buy/Transfer/Sell Transaction in Binance pegged USD ($BUSD), which is automatically sent to your wallet. This generates a stable passive income.

MetaReflect.io
https://t.me/MetaReflect
https://Twitter.com/MetaReflect

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256);
    function distributeDividends() external payable;
    function withdrawDividend() external;
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}

/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
///  to token holders as dividends and allows token holders to withdraw their dividends.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 constant internal magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;
    address public rewardToken;
    IUniswapV2Router02 public uniswapV2Router;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    receive() external payable {
        distributeDividends();
    }
    /// @notice Distributes ether to token holders as dividends.
    /// @dev It reverts if the total supply of tokens is 0.
    /// It emits the `DividendsDistributed` event if the amount of received ether is greater than 0.
    /// About undistributed ether:
    ///   In each distribution, there is a small amount of ether not distributed,
    ///     the magnified amount of which is
    ///     `(msg.value * magnitude) % totalSupply()`.
    ///   With a well-chosen `magnitude`, the amount of undistributed ether
    ///     (de-magnified) in a distribution can be less than 1 wei.
    ///   We can actually keep track of the undistributed ether in a distribution
    ///     and try to distribute it in the next distribution,
    ///     but keeping track of such data on-chain costs much more than
    ///     the saved ether, so we don't do that.

    function distributeDividends() public override onlyOwner payable {
        require(totalSupply() > 0);
        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add((msg.value).mul(magnitude) / totalSupply());
            emit DividendsDistributed(msg.sender, msg.value);
            totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
        }
    }
    function withdrawDividend() public virtual override onlyOwner {
        _withdrawDividendOfUser(payable(msg.sender));
    }
    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            if (rewardToken == address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)) {
                (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
                if(!success) {
                    withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                    return 0;
                }
                return _withdrawableDividend;
            } else {
                return swapBNBForTokensAndDistributeDividend(user, _withdrawableDividend);
            }
        }
        return 0;
    }
    function swapBNBForTokensAndDistributeDividend(address holder, uint256 bnbAmount) private returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(rewardToken);

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : bnbAmount}(
            0, // accept any amount of tokens
            path,
            address(holder),
            block.timestamp
        ) {
            return bnbAmount;
        } catch {
            withdrawnDividends[holder] = withdrawnDividends[holder].sub(bnbAmount);
            return 0;
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
    function _setRewardToken(address token) internal onlyOwner {
        rewardToken = token;
    }
    function _setUniswapRouter(address router) internal onlyOwner {
        uniswapV2Router = IUniswapV2Router02(router);
    }
}

contract MetaReflect is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    string private _name = "MetaReflect";
    string private _symbol = "MRF";
    uint8 private _decimals = 9;
    


    MetaReflectDividendTracker public dividendTracker;

    bool public isTradingEnabled;
    uint256 private _tradingPausedTimestamp;

    // initialSupply
    uint256 constant initialSupply = (10**15) * (10**9);

    // max wallet is 2% of initialSupply
    uint256 public maxWalletAmount = initialSupply * 200 / 10000;
    // max buy and sell tx is 0.125% of initialSupply
    uint256 public maxTxAmount = initialSupply * 125 / 100000100000;

    bool private _swapping;
    uint256 public minimumTokensBeforeSwap = (25 * (10**10)) * (10**9);//250 billion
    uint256 public gasForProcessing = 300000;

    address public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    //address public DEXROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;// MAINNET
    //address public DEXROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;// TESTNET
    address public DEXROUTER_ADDRESS = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;// TESTNET kiemtienonline360

    //address public WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;// MAINNET
    //address public WBNB_ADDRESS = 0x0000000000000000000000000000000000000000;// TESTNET
    address public WBNB_ADDRESS=0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;// TESTNET

    //BUSD
    //address public dividendToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // MAINNET
    //address public dividendToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // TESTNET
    address public dividendToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // // TESTNET kiemtienonline360

    address public stakingAddress = 0xe31dDB8051E4495441C00cCDd8438fc02997A7bd;
    address public marketingWallet = 0x89Bc6fF6dE33B8a931567282B5e43ad525f5DadC;
    address public liquidityWallet = 0xfA1b7F42a23e36BEf69332d16eF01367315459eF;

    struct CustomTaxPeriod {
        bytes23 periodName;
        uint8 blocksInPeriod;
        uint256 timeInPeriod;
        uint256 liquidityFeeOnBuy;
        uint256 liquidityFeeOnSell;
        uint256 marketingFeeOnBuy;
        uint256 marketingFeeOnSell;
        uint256 buyBackFeeOnBuy;
        uint256 buyBackFeeOnSell;
        uint256 stakingFeeOnBuy;
        uint256 stakingFeeOnSell;
        uint256 holdersFeeOnBuy;
        uint256 holdersFeeOnSell;
    }

    // Base taxes
    CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,4,4,1,1,1,1,8,8);
    CustomTaxPeriod private _base = CustomTaxPeriod('default',0,0,1,1,4,4,1,1,1,1,8,8);

    // Launch taxes
    bool private _isLaunched;
    uint256 private _launchStartTimestamp;
    uint256 private _launchBlockNumber;
    CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',3,0,1,100,2,0,1,0,1,0,5,0);

    uint256 private _launchedBlockedTimeLimit = 172800;//allows addresses blocked while in launch mode to resume trading after time limit
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
    mapping (address => bool) private _isExcludedFromMaxWalletLimit;
    mapping (address => bool) private _isBlocked;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256) private _buyTimesInLaunch;

    uint256 private _liquidityFee;
    uint256 private _marketingFee;
    uint256 private _buyBackFee;
    uint256 private _stakingFee;
    uint256 private _holdersFee;
    uint256 private _totalFee;

    event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
    event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
    event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFeesChange(address indexed account, bool isExcluded);
    event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
    event StakingAddressChange(address indexed newStakingAddress, address indexed oldStakingAddress);
    event GasForProcessingChange(uint256 indexed newValue, uint256 indexed oldValue);
    event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 stakingFee, uint256 holdersFee);
    event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
    event BlockedAccountChange(address indexed holder, bool indexed status);
    event CharityHourChange(bool indexed newValue, bool indexed oldValue);
    event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
    event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
    event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
    event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
    event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
    event MinTokenAmountForDividendsChange(uint256 indexed newValue, uint256 indexed oldValue);
    event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
    event DividendsSent(uint256 tokensSwapped);
    event StakingTokensSent(uint256 tokensSent);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
    event ClaimBNBOverflow(uint256 amount);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);
    event FeesApplied(uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 stakingFee, uint256 holdersFee, uint256 totalFee);
    event DividendTokenChange(address newValue, address oldValue);

    constructor() ERC20(_name, _symbol) {
       
        dividendTracker = new MetaReflectDividendTracker();
        dividendTracker.setRewardToken(dividendToken);
        dividendTracker.setUniswapRouter(DEXROUTER_ADDRESS);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(DEXROUTER_ADDRESS);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(dividendTracker)] = true;
        _isExcludedFromFee[liquidityWallet] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[stakingAddress] = true;

        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(DEAD_ADDRESS));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(stakingAddress);

        _isExcludedFromMaxTransactionLimit[address(dividendTracker)] = true;
        _isExcludedFromMaxTransactionLimit[address(this)] = true;
        _isExcludedFromMaxTransactionLimit[liquidityWallet] = true;
        _isExcludedFromMaxTransactionLimit[marketingWallet] = true;
        _isExcludedFromMaxTransactionLimit[stakingAddress] = true;

        _isExcludedFromMaxWalletLimit[address(dividendTracker)] = true;
        _isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
        _isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[liquidityWallet] = true;
        _isExcludedFromMaxWalletLimit[marketingWallet] = true;
        _isExcludedFromMaxWalletLimit[stakingAddress] = true;

        _mint(owner(), initialSupply);
        
/** **/
    }

    receive() external payable {}

    // Setters
    function _getNow() private view returns (uint256) {
        return block.timestamp;
    }
    function launch() public onlyOwner {
        _launchStartTimestamp = _getNow();
        _launchBlockNumber = block.number;
        isTradingEnabled = true;
        _isLaunched = true;
    }
    function cancelLaunch() public onlyOwner {
        require(this.isInLaunch(), "MetaReflect: Launch is not set");
        _launchStartTimestamp = 0;
        _launchBlockNumber = 0;
        _isLaunched = false;
    }
    function activateTrading() public onlyOwner {
        isTradingEnabled = true;
    }
    function deactivateTrading() public onlyOwner {
        isTradingEnabled = false;
        _tradingPausedTimestamp = _getNow();
    }
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "MetaReflect: The dividend tracker already has that address");
        MetaReflectDividendTracker newDividendTracker = MetaReflectDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "MetaReflect: The new dividend tracker must be owned by the  token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(uniswapV2Pair));
        newDividendTracker.excludeFromDividends(address(stakingAddress));
        emit DividendTrackerChange(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "MetaReflect: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit AutomatedMarketMakerPairChange(pair, value);
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFee[account] != excluded, "MetaReflect: Account is already the value of 'excluded'");
        _isExcludedFromFee[account] = excluded;
        emit ExcludeFromFeesChange(account, excluded);
    }
    function excludeFromDividends(address account) public onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }
    function excludeFromMaxTransactionLimit(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromMaxTransactionLimit[account] != excluded, "MetaReflect: Account is already the value of 'excluded'");
        _isExcludedFromMaxTransactionLimit[account] = excluded;
        emit ExcludeFromMaxTransferChange(account, excluded);
    }
    function excludeFromMaxWalletLimit(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromMaxWalletLimit[account] != excluded, "MetaReflect: Account is already the value of 'excluded'");
        _isExcludedFromMaxWalletLimit[account] = excluded;
        emit ExcludeFromMaxWalletChange(account, excluded);
    }
    function blockAccount(address account) public onlyOwner {
        uint256 currentTimestamp = _getNow();
        require(!_isBlocked[account], "MetaReflect: Account is already blocked");
        if (_isLaunched) {
            require(currentTimestamp.sub(_launchStartTimestamp) < _launchedBlockedTimeLimit, "MetaReflect: Time to block accounts has expired");
        }
        _isBlocked[account] = true;
        emit BlockedAccountChange(account, true);
    }
    function unblockAccount(address account) public onlyOwner {
        require(_isBlocked[account], "MetaReflect: Account is not blcoked");
        _isBlocked[account] = false;
        emit BlockedAccountChange(account, false);
    }
    function setWallets(address newLiquidityWallet, address newMarketingWallet) public onlyOwner {
        if(liquidityWallet != newLiquidityWallet) {
            require(newLiquidityWallet != address(0), "MetaReflect: The liquidityWallet cannot be 0");
            emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
            liquidityWallet = newLiquidityWallet;
        }
        if(marketingWallet != newMarketingWallet) {
            require(newMarketingWallet != address(0), ": The marketingWallet cannot be 0");
            emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
            marketingWallet = newMarketingWallet;
        }
    }
    function setStakingAddress(address newStakingAddress) public onlyOwner {
        require(newStakingAddress != address(0), "MetaReflect: The stakingAddress cannot be 0");

        excludeFromFees(newStakingAddress,true);
        excludeFromDividends(newStakingAddress);
        excludeFromMaxWalletLimit(newStakingAddress,true);
        excludeFromMaxTransactionLimit(newStakingAddress,true);

        emit StakingAddressChange(newStakingAddress, stakingAddress);
        stakingAddress = newStakingAddress;
    }
    function setAllFeesToZero() public onlyOwner {
        _setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0);
        emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0);
        _setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0);
        emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0);
    }
    function resetAllFees() public onlyOwner {
        _setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.buyBackFeeOnBuy, _default.stakingFeeOnBuy, _default.holdersFeeOnBuy);
        emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.buyBackFeeOnBuy, _default.stakingFeeOnBuy,  _default.holdersFeeOnBuy);
        _setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.buyBackFeeOnSell, _default.stakingFeeOnSell,  _default.holdersFeeOnSell);
        emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.buyBackFeeOnSell, _default.stakingFeeOnSell, _default.holdersFeeOnSell);
    }

    // Base fees
    function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _stakingFeeOnBuy, uint256 _holdersFeeOnBuy) public onlyOwner {
        _setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
        emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
    }
    function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
        _setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
        emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
    }
    function setUniswapRouter(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "MetaReflect: The router already has that address");
        emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        dividendTracker.setUniswapRouter(newAddress);
    }
    function setGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "MetaReflect: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "MetaReflect: Cannot update gasForProcessing to same value");
        emit GasForProcessingChange(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }
    function setMaxTransactionAmount(uint256 newValue) public onlyOwner {
        require(newValue != maxTxAmount, "MetaReflect: Cannot update maxTxAmount to same value");
        emit MaxTransactionAmountChange(newValue, maxTxAmount);
        maxTxAmount = newValue;
    }
    function setMaxWalletAmount(uint256 newValue) public onlyOwner {
        require(newValue != maxWalletAmount, "MetaReflect: Cannot update maxWalletAmount to same value");
        emit MaxWalletAmountChange(newValue, maxWalletAmount);
        maxWalletAmount = newValue;
    }
    function setMinimumTokensBeforeSwap(uint256 newValue) public onlyOwner {
        require(newValue != minimumTokensBeforeSwap, "MetaReflect: Cannot update minimumTokensBeforeSwap to same value");
        emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
        minimumTokensBeforeSwap = newValue;
    }
    function setMinimumTokenBalanceForDividends(uint256 newValue) public onlyOwner {
        dividendTracker.setTokenBalanceForDividends(newValue);
    }
    function setClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.setClaimWait(claimWait);
    }
    function setDividendToken(address newDividendToken) external onlyOwner {
        require(newDividendToken != dividendToken, "MetaReflect: Cannot update dividend token to same value");
        require(newDividendToken != address(0), "MetaReflect: The dividend token cannot be 0");
        require(newDividendToken != address(this), "MetaReflect: The dividend token cannot be set to the current contract");
        emit DividendTokenChange(newDividendToken, dividendToken);
        dividendToken = newDividendToken;
        dividendTracker.setRewardToken(dividendToken);
    }
    function isInLaunch() external view returns (bool) {
        uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
        uint256 timeSinceLaunch = currentTimestamp.sub(_launchStartTimestamp);
        uint256 blocksSinceLaunch = block.number.sub(_launchBlockNumber);
        uint256 totalLaunchTime =  _launch1.timeInPeriod;

        if(_isLaunched && (timeSinceLaunch < totalLaunchTime || blocksSinceLaunch < _launch1.blocksInPeriod )) {
            return true;
        } else {
            return false;
        }
    }
    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }
    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }
    function getWithdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }
    function getDividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }
    function getAccountDividendsInfo(address account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(account);
    }
    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }
    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){
        return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.buyBackFeeOnBuy, _base.stakingFeeOnBuy, _base.holdersFeeOnBuy);
    }
    function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256){
        return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.buyBackFeeOnSell, _base.stakingFeeOnSell, _base.holdersFeeOnSell);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }
    function processDividendTracker(uint256 gas) external onlyOwner{
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }
    function claimBNBOverflow(uint256 amount) external onlyOwner{
        require(amount < address(this).balance, "MetaReflect: Cannot send more than contract balance");
        (bool success,) = address(owner()).call{value : amount}("");
        if (success){
            emit ClaimBNBOverflow(amount);
        }
    }
    function buyBackAndBurn(uint256 amount) external onlyOwner {
        _swapBNBForTokens(DEAD_ADDRESS, amount);
    }

    // Main
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool isBuyFromLp = automatedMarketMakerPairs[from];
        bool isSelltoLp = automatedMarketMakerPairs[to];
        bool _isInLaunch = this.isInLaunch();

        uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();

        if(from != owner() && to != owner()) {
            require(isTradingEnabled, "MetaReflect: Trading is currently disabled.");
            require(!_isBlocked[to], "MetaReflect: Account is blocked");
            require(!_isBlocked[from], "MetaReflect: Account is blocked");
            if (_isInLaunch && currentTimestamp.sub(_launchStartTimestamp) <= 300 && isBuyFromLp) {
                require(currentTimestamp.sub(_buyTimesInLaunch[to]) > 60, "MetaReflect: Cannot buy more than once per min in first 5min of launch");
            }
            if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
                require(amount <= maxTxAmount, "MetaReflect: Buy amount exceeds the maxTxBuyAmount.");
            }
            if (!_isExcludedFromMaxWalletLimit[to]) {
                require(balanceOf(to).add(amount) <= maxWalletAmount, "MetaReflect: Expected wallet amount exceeds the maxWalletAmount.");
            }
        }

        _adjustTaxes(isBuyFromLp, isSelltoLp);

        bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

        if (
            isTradingEnabled &&
            canSwap &&
            !_swapping &&
            _totalFee > 0 &&
            automatedMarketMakerPairs[to] &&
            from != liquidityWallet && to != liquidityWallet &&
            from != marketingWallet && to != marketingWallet &&
            from != stakingAddress && to != stakingAddress
        ) {
            _swapping = true;
            _swapAndLiquify();
            _swapping = false;
        }

        bool takeFee =
        !_swapping &&
        isTradingEnabled &&
        !(_isExcludedFromFee[from] || _isExcludedFromFee[to]) //false if address is excluded
        ;

        if (takeFee) {
            uint256 fee = amount.mul(_totalFee).div(100);
            amount = amount.sub(fee);
            super._transfer(from, address(this), fee);
            emit FeesApplied(_liquidityFee, _marketingFee, _buyBackFee, _stakingFee, _holdersFee, _totalFee);
        }

        if (_isInLaunch && currentTimestamp.sub(_launchStartTimestamp) <= 300) {
            if (to != owner() && isBuyFromLp  && currentTimestamp.sub(_buyTimesInLaunch[to]) > 60) {
                _buyTimesInLaunch[to] = currentTimestamp;
            }
        }

        super._transfer(from, to, amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!_swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {}
        }
    }
    function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp) private {
        uint256 blocksSinceLaunch = block.number.sub(_launchBlockNumber);

        _liquidityFee = 0;
        _marketingFee = 0;
        _buyBackFee = 0;
        _stakingFee = 0;
        _holdersFee = 0;

        if (isBuyFromLp) {
            _liquidityFee = _base.liquidityFeeOnBuy;
            _marketingFee = _base.marketingFeeOnBuy;
            _buyBackFee = _base.buyBackFeeOnBuy;
            _stakingFee = _base.stakingFeeOnBuy;
            _holdersFee = _base.holdersFeeOnBuy;

            if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
                _liquidityFee = _launch1.liquidityFeeOnBuy;
                _marketingFee = _launch1.marketingFeeOnBuy;
                _buyBackFee = _launch1.buyBackFeeOnBuy;
                _stakingFee = _launch1.stakingFeeOnBuy;
                _holdersFee = _launch1.holdersFeeOnBuy;
            }
        }
        if (isSelltoLp) {
            _liquidityFee = _base.liquidityFeeOnSell;
            _marketingFee = _base.marketingFeeOnSell;
            _buyBackFee = _base.buyBackFeeOnSell;
            _stakingFee = _base.stakingFeeOnSell;
            _holdersFee = _base.holdersFeeOnSell;

            if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
                _liquidityFee = _launch1.liquidityFeeOnSell;
                _marketingFee = _launch1.marketingFeeOnSell;
                _buyBackFee = _launch1.buyBackFeeOnSell;
                _stakingFee = _launch1.stakingFeeOnSell;
                _holdersFee = _launch1.holdersFeeOnSell;
            }
        }
        _totalFee = _liquidityFee.add(_marketingFee).add(_buyBackFee).add(_stakingFee).add(_holdersFee);
    }
    function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
        uint256 _liquidityFeeOnSell,
        uint256 _marketingFeeOnSell,
        uint256 _buyBackFeeOnSell,
        uint256 _stakingFeeOnSell,
        uint256 _holdersFeeOnSell
    ) private {
        if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
            emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
            map.liquidityFeeOnSell = _liquidityFeeOnSell;
        }
        if (map.marketingFeeOnSell != _marketingFeeOnSell) {
            emit CustomTaxPeriodChange(_marketingFeeOnSell, map.marketingFeeOnSell, 'marketingFeeOnSell', map.periodName);
            map.marketingFeeOnSell = _marketingFeeOnSell;
        }
        if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
            emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
            map.buyBackFeeOnSell = _buyBackFeeOnSell;
        }
        if (map.stakingFeeOnSell != _stakingFeeOnSell) {
            emit CustomTaxPeriodChange(_stakingFeeOnSell, map.stakingFeeOnSell, 'stakingFeeOnSell', map.periodName);
            map.stakingFeeOnSell = _stakingFeeOnSell;
        }
        if (map.holdersFeeOnSell != _holdersFeeOnSell) {
            emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
            map.holdersFeeOnSell = _holdersFeeOnSell;
        }
    }
    function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
        uint256 _liquidityFeeOnBuy,
        uint256 _marketingFeeOnBuy,
        uint256 _buyBackFeeOnBuy,
        uint256 _stakingFeeOnBuy,
        uint256 _holdersFeeOnBuy
    ) private {
        if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
            emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
            map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
        }
        if (map.marketingFeeOnBuy != _marketingFeeOnBuy) {
            emit CustomTaxPeriodChange(_marketingFeeOnBuy, map.marketingFeeOnBuy, 'marketingFeeOnBuy', map.periodName);
            map.marketingFeeOnBuy = _marketingFeeOnBuy;
        }
        if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
            emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
            map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
        }
        if (map.stakingFeeOnBuy != _stakingFeeOnBuy) {
            emit CustomTaxPeriodChange(_stakingFeeOnBuy, map.stakingFeeOnBuy, 'stakingFeeOnBuy', map.periodName);
            map.stakingFeeOnBuy = _stakingFeeOnBuy;
        }
        if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
            emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
            map.holdersFeeOnBuy = _holdersFeeOnBuy;
        }
    }
    function _swapAndLiquify() private {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 initialBNBBalance = address(this).balance;

        uint256 amountToLiquify = contractTokenBalance.mul(_liquidityFee).div(_totalFee).div(2);
        uint256 amountForStaking = contractTokenBalance.mul(_stakingFee).div(_totalFee);
        uint256 amountToSwap = contractTokenBalance.sub((amountToLiquify));

        _swapTokensForBNB(amountToSwap);

        uint256 bnbBalanceFromSwap = address(this).balance.sub(initialBNBBalance);
        uint256 totalBNBFee = _totalFee.sub(_liquidityFee.div(2));

        uint256 amountBNBLiquidity  = bnbBalanceFromSwap.mul(_liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing  = bnbBalanceFromSwap.mul(_marketingFee).div(totalBNBFee);
        uint256 amountBNBBuyBack    = bnbBalanceFromSwap.mul(_buyBackFee).div(totalBNBFee);
        uint256 amountBNBDividend   = bnbBalanceFromSwap.sub((amountBNBLiquidity.add(amountBNBMarketing).add(amountBNBBuyBack)));

        payable(marketingWallet).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            _addLiquidity(amountToLiquify, amountBNBLiquidity);
            emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
        }

        (bool stakingSuccess) = IERC20(address(this)).transfer(address(stakingAddress), amountForStaking);
        if(stakingSuccess) {
            emit StakingTokensSent(amountForStaking);
        }

        (bool dividendSuccess,) = address(dividendTracker).call{value: amountBNBDividend}("");
        if(dividendSuccess) {
            emit DividendsSent(amountBNBDividend);
        }
    }
    function _swapTokensForBNB(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapBNBForTokens(address to_, uint256 coinAmount_) private{
        address[] memory path = new address[](2);
        path[0] = WBNB_ADDRESS;
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: coinAmount_}(
            0,
            path,
            to_,
            block.timestamp
        );
    }
    function _addLiquidity(uint256 tokenAmount, uint256 coinAmount) private {
        _approve(address(this), address(uniswapV2Router), coinAmount);
        uniswapV2Router.addLiquidityETH{value: coinAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}

contract MetaReflectDividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using SafeMathUint for uint256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;

    uint256 public lastProcessedIndex;
    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("MetaReflect_Dividend_Tracker", "MetaReflect_Dividend_Tracker") {
        claimWait = 3600;
        minimumTokenBalanceForDividends = (10**10) * (10**9); //100 billion * decimals
    }

    function setRewardToken(address token) external onlyOwner {
        _setRewardToken(token);
    }
    function setUniswapRouter(address router) external onlyOwner {
        _setUniswapRouter(router);
    }
    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }
    function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
        require(minimumTokenBalanceForDividends != newValue, "MetaReflect_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
        minimumTokenBalanceForDividends = newValue;
    }
    function setClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "MetaReflect_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "MetaReflect_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
    function getAccount(address _account)
    public view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableDividends,
        uint256 totalDividends,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;
        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }
    function getAccountAtIndex(uint256 index)
    public view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }
        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
        processAccount(account, true);
    }
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;
            uint256 newGasLeft = gasleft();
            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }

    function _transfer(address from, address to, uint256 value) internal  override {
        require(false, "MetaReflect_Dividend_Tracker: No transfers allowed");
        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }
}