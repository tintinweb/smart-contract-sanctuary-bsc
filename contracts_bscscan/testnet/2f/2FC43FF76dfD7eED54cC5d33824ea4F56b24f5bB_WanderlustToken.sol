/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// Buy tax 6% ( Also trasnfer tax ) ----------------------- GOOD --- YEZZIR

// 2% TOKENS SENT TO wallet X ( Stake conttract ) ----------------------- GOOD --- YEZZIR

// 2% Auto liq ----------------------- GOOD --- YEZZIR

// 2% Tokens SOLD and BNB sent to marketing wallet ----------------------- GOOD --- YEZZIR



// Sell tax  ----------------------- GOOD --- YEZZIR

// 3% Tokens sent to wallet X ( stake contract ) ----------------------- GOOD --- YEZZIR

// 3% Auto liq ----------------------- GOOD --- YEZZIR

// 4% Tokens sold and BNB sent to marketing wallet ----------------------- GOOD --- YEZZIR



// Ability To cahnge % of Buy and Sell tax AND turn it off if needed ----------------------- GOOD --- YEZZIR

// Max hold per wallet is 2% of supply ( function to buypass this if Whitelisted ) ----------------------- GOOD --- YEZZIR

// Ability to return Lost BNB and Any bep token in tokenn contract to deployer wallet ----------------------- GOOD --- YEZZIR

// Whitelist ( Ignores max % hold and Tax FROM and To the wallet ) ----------------------- GOOD --- YEZZIR

// Blacklist ----------------------- GOOD ---- YEZZIR

// AntiSnipe ----------------------- GOOD --- YEZZIR

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
                "Address: low-level call with value failed"
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
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
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

contract WanderlustToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address payable public marketingAddress =
        payable(0xeb6D18BC9D2C80308e6224De78062453364Cec1D); // Marketing Address
    address payable public stakeAddress =
        payable(0xfe1D791893B9b7e42eC8Ee19a4526C4db69f6626); // Stake Address
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    // mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bool) private _isBlacklisted;
    address[] private _blacklisted;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000 * 10**6 * 10**9;
    // uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Wanderlust";
    string private constant _symbol = "LUST";
    uint8 private constant _decimals = 9;

    uint256 public _taxFee = 4; // CONFIRMED?
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _marketingFee = 50; // CONFIRMED? (default to buyFee)
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _stakeFee = 50; // CONFIRMED? (default to buyFee)
    uint256 private _previousStakeFee = _stakeFee;

    uint256 public _liquidityFee = 2; // CONFIRMED?
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _buyTaxFee = 4; // CONFIRMED? (stake + marketing address)
    uint256 public _buyMarketingFee = 50; // CONFIRMED? (1/2)
    uint256 public _buyStakeFee = 50; // CONFIRMED? (1/2)
    uint256 public _buyLiquidityFee = 2; // CONFIRMED?

    uint256 public _sellTaxFee = 7; // CONFIRMED? (stake + marketing address)
    uint256 public _sellMarketingFee = 57; // CONFIRMED? (4/7)
    uint256 public _sellStakeFee = 43; // CONFIRMED? (3/7)
    uint256 public _sellLiquidityFee = 3; // CONFIRMED?

    // uint256 public _startTimeForSwap;
    // uint256 public _intervalMinutesForSwap = 1 * 30 seconds;

    uint256 public _maxTxAmount = 3000 * 10**6 * 10**9; // 3,000,000,000 MM, aka ~30 BNB at start
    // uint256 private minimumTokensBeforeSwap = 200 * 10**6 * 10**9;

    uint256 initialBlock;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _tOwned[_msgSender()] = _tTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // ROPSTEN or HARDHAT
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[stakeAddress] = true;

        // _startTimeForSwap = block.timestamp;
        initialBlock = block.number;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) external override returns (bool) {
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
        external
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
        external
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

    function isBlacklisted(address account)
        external
        view
        returns (bool)
    {
        return _isBlacklisted[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    // function minimumTokensBeforeSwapAmount() external view returns (uint256) {
    //     return minimumTokensBeforeSwap;
    // }

    function addBlacklist(address account) external onlyOwner {
        require(!_isBlacklisted[account], "Account is already blacklisted");
        _isBlacklisted[account] = true;
        _blacklisted.push(account);
    }

    function removeBlacklist(address account) external onlyOwner {
        require(_isBlacklisted[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _blacklisted.length; i++) {
            if (_blacklisted[i] == account) {
                _blacklisted[i] = _blacklisted[_blacklisted.length - 1];
                _isBlacklisted[account] = false;
                _blacklisted.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(block.number > initialBlock, "Be ware of snipers");

        // Ensure sender is not blacklisted
        require(!_isBlacklisted[from], "Account is blacklisted");

        // Make sure amount doesnt exceed max transfer unless owner
        if (from != owner() && to != owner()) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        // Handle wallet cap of 2%
        if (!_isExcludedFromFee[to]) {
          require(totalSupply().mul(2).div(100) > balanceOf(to).add(amount), "Transfer receiver balance cannot be greater than 2% of total supply");
        }

        uint256 taxFee = 0;
        uint256 liqFee = 0;

        // If any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
          taxFee = 0;
          liqFee = 0;
        } else {
            // Buy
            if (from == uniswapV2Pair) {
                taxFee = _buyTaxFee;
                liqFee = _buyLiquidityFee;

                // Handle taxes
                distributeTaxes(from, amount, taxFee, _buyMarketingFee);

                // Handle auto liquidity
                autoLiquidity(from, amount, liqFee);
            }
            // Sell
            if (to == uniswapV2Pair) {
                // removeAllFee();
                taxFee = _sellTaxFee;
                liqFee = _sellLiquidityFee;

                // Handle taxes
                distributeTaxes(from, amount, taxFee, _sellMarketingFee);

                // Handle auto liquidity
                autoLiquidity(from, amount, liqFee);
            }

            if (to != uniswapV2Pair && from != uniswapV2Pair) {
                taxFee = 0;
                liqFee = 0;
            }
        }

        _tokenTransfer(from, to, amount, taxFee, liqFee);
    }

    function distributeTaxes(address from, uint256 tAmount, uint256 tFee, uint256 tMarketingFee) private lockTheSwap {
        if (tFee == 0) return;
        uint256 initialBalance = address(this).balance;
        uint256 initialTokenBalance = balanceOf(address(this));
        uint256 taxes = tAmount.mul(tFee).div(100);
        // Send tokens (taxes) here first
        _tokenTransfer(from, address(this), taxes, 0, 0);

        uint256 transferredTokenBalance = balanceOf(address(this)).sub(initialTokenBalance);
        uint256 marketingAmount = transferredTokenBalance.mul(tMarketingFee).div(100);
        uint256 stakeAmount = transferredTokenBalance.sub(marketingAmount);

        // Handle stake token fee
        if (stakeAmount > 0) {
          _tokenTransfer(address(this), stakeAddress, stakeAmount, 0, 0);
        }

        // Handle marketing BNB fee
        swapTokensForEth(marketingAmount);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        if (transferredBalance > 0) {
          transferToAddressETH(
            marketingAddress,
            transferredBalance
          );
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        if (half == 0 || otherHalf == 0) return;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function autoLiquidity(address from, uint256 tAmount, uint256 tLiq) private lockTheSwap {
        if (tLiq == 0) return;
        uint256 initialTokenBalance = balanceOf(address(this));
        uint256 tokenAmount = tAmount.mul(tLiq).div(100);
        // Send tokens (tokenAmount) here first
        _tokenTransfer(from, address(this), tokenAmount, 0, 0);

        uint256 transferredTokenBalance = balanceOf(address(this)).sub(initialTokenBalance);

        swapAndLiquify(transferredTokenBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // Make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // Accept any amount of Tokens
            path,
            address(this), // The contract
            block.timestamp.add(300)
        );

        emit SwapETHForTokens(amount, path);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 taxFee,
        uint256 liqFee
    ) private {
        uint256 tTransferAmount = getTransferAmount(tAmount, taxFee, liqFee);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getTransferAmount (uint256 tAmount, uint256 taxFee, uint256 liqFee) private pure returns (uint256) {
        uint256 tFee = calculateTaxFee(tAmount, taxFee);
        uint256 tLiquidity = calculateLiquidityFee(tAmount, liqFee);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);

        return tTransferAmount;
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 amount, uint256 taxFee) private pure returns (uint256) {
        if (taxFee == 0) return 0;
        return amount.mul(taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 amount, uint256 liqFee) private pure returns (uint256) {
        if (liqFee == 0) return 0;
        return amount.mul(liqFee).div(10**2);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _getSellBnBAmount(uint256 tokenAmount)
        private
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint256[] memory amounts = uniswapV2Router.getAmountsOut(
            tokenAmount,
            path
        );

        return amounts[1];
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    // function getSwapMinutes() external view returns (uint256) {
    //     return _intervalMinutesForSwap.div(60);
    // }

    // function setSwapMinutes(uint256 newMinutes) external onlyOwner {
    //     _intervalMinutesForSwap = newMinutes * 1 minutes;
    // }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setBuyFee(uint256 buyTaxFee, uint256 buyMarketingFee, uint256 buyStakeFee, uint256 buyLiquidityFee)
        external
        onlyOwner
    {
        _buyTaxFee = buyTaxFee;
        _buyMarketingFee = buyMarketingFee;
        _buyStakeFee = buyStakeFee;
        _buyLiquidityFee = buyLiquidityFee;
    }

    function setSellFee(uint256 sellTaxFee, uint256 sellMarketingFee, uint256 sellStakeFee, uint256 sellLiquidityFee)
        external
        onlyOwner
    {
        _sellTaxFee = sellTaxFee;
        _sellMarketingFee = sellMarketingFee;
        _sellStakeFee = sellStakeFee;
        _sellLiquidityFee = sellLiquidityFee;
    }

    // function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap)
    //     external
    //     onlyOwner
    // {
    //     minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    // }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = payable(_marketingAddress);
        _isExcludedFromFee[marketingAddress] = true;
    }

    function setStakeAddress(address _stakeAddress) external onlyOwner {
        stakeAddress = payable(_stakeAddress);
        _isExcludedFromFee[stakeAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function getPairAddress() external view onlyOwner returns (address) {
        return uniswapV2Pair;
    }

    function changeRouterVersion(address _router)
        external
        onlyOwner
        returns (address _pair)
    {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        if (_pair == address(0)) {
            // Pair doesn't exist
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
                address(this),
                _uniswapV2Router.WETH()
            );
        }
        uniswapV2Pair = _pair;

        // Set the router of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function recoverTokens(address _token, uint256 amount)
        external
        onlyOwner
        returns (bool _sent)
    {
      uint256 tAmount;
      if (amount == 0) {
        tAmount = IERC20(_token).balanceOf(address(this));
      } else {
        tAmount = amount;
      }

      _sent = IERC20(_token).transfer(owner(), tAmount);
    }

    function recoverBNB(uint256 amount)
        external
        onlyOwner
    {
      uint256 tAmount;
      if (amount == 0) {
        tAmount = address(this).balance;
      } else {
        tAmount = amount;
      }
      transferToAddressETH(payable(owner()), tAmount);
    }
}