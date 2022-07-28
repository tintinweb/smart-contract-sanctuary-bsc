/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IBscPrice {
    function getTokenUsdtPrice(address _token) external view returns (uint256);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

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


contract MccToken is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public startTime = 1658880000;
    uint256 public startMineTime = 1658880000;

    uint256 public maxRate = 1000;

    uint256 public tradeFee = 120;

    uint256 public tradeDestroy = 10;

    uint256 public angelRate = 10;

    uint256 public  lpRate = 10;

    uint256 public  daoRate = 10;

    uint256 public  defiRate = 80;

    uint256 public extraDestroyFee = 120;

    uint256 public dropRate = 15;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public angelAddress;

    address public lpAddress;

    address public daoAddress;

    address public defiContractAddress;

    address public receiveAddress1 = 0x17A5CeFbACd72884aacCcB98de31B204F77F2Fdd;

    address public receiveAddress2 = 0x2DcfA523002f25c9B37EbC457428eAb4d9Bb8Dd3;

    address public daoWalletAddress = 0xa2342c4a7E9C2B6AD6C1D6416C39895C29991633;

    uint256 public initialAmount = 660 * 1e18;
    uint256 public totalDefiAmount = 33000 * (10 ** 18);
    uint256 public transferDefiAmount;
    bool public transferDefiFlag = true;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(uint256 => bool) public mineDays;
    mapping(uint256 => uint256) public priceMap;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    constructor(
        string memory name_,
        string memory symbol_
    ) payable ERC20(name_, symbol_) {
        _totalSupply = 297000 * (10 ** 18);

        _balances[receiveAddress1] = 115500 * (10 ** 18);
        emit Transfer(address(0), receiveAddress1, 115500 * (10 ** 18));

        _balances[receiveAddress2] = 181500 * (10 ** 18);
        emit Transfer(address(0), receiveAddress2, 181500 * (10 ** 18));

        angelAddress = 0xcEf624D153E3cB8C75dFF049b98d3A29CEAC3364;
        lpAddress = 0x302fe026897B324CeF543a45cED7d72CbaA3FD63;
        daoAddress = 0x674479945E6BB1579E79ED5306eF260E9Ce9fD3D;
        defiContractAddress = 0xf923A6e550C8aA1511E668bf14fCF9863dE32876;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(angelAddress, true);
        excludeFromFees(lpAddress, true);
        excludeFromFees(daoAddress, true);
        excludeFromFees(defiContractAddress, true);
        excludeFromFees(receiveAddress1, true);
        excludeFromFees(receiveAddress2, true);
        excludeFromFees(daoWalletAddress, true);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
    }


    function setLpAdderss(address addr) public onlyOwner {
        uniswapV2Pair = addr;
    }

    function setDefiContractAdderss(address addr) public onlyOwner {
        defiContractAddress = addr;
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    function setFeeRate(uint256 _tradeDestroy, uint256 _angelRate,
        uint256 _lpRate, uint256 _daoRate, uint256 _defiRate) public onlyOwner {
        tradeDestroy = _tradeDestroy;
        angelRate = _angelRate;
        lpRate = _lpRate;
        daoRate = _daoRate;
        defiRate = _defiRate;
        tradeFee = tradeDestroy.add(angelRate).add(lpRate).add(daoRate).add(defiRate);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if (_isExcludedFromFees[account] != excluded) {
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function setStartMineTime(uint256 _startMineTime) public onlyOwner {
        startMineTime = _startMineTime;
    }

    function getMineDays() public view returns (uint256) {
        uint256 intervalDay = block.timestamp.sub(startMineTime).div(1 days);
        return intervalDay;
    }

    function mint() internal {
        if (transferDefiFlag) {

            uint256 mineDay = getMineDays();
            if (!mineDays[mineDay] && mineDay > 0) {

                transferDefiAmount = transferDefiAmount.add(initialAmount);
                super._mint(daoWalletAddress, initialAmount);

                mineDays[mineDay] = true;

                if (transferDefiAmount >= totalDefiAmount) {
                    transferDefiFlag = false;
                }
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        mint();

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 finalAmount = takeAllFee(from, to, amount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(finalAmount);
        emit Transfer(from, to, finalAmount);

        setPrice();
    }


    function takeAllFee(address from, address to, uint256 amount) internal returns (uint256 amountAfter) {
        uint256 destroyAmount;
        uint256 extraDestroyAmount;
        uint256 tradeFeeAmount;
        if (from == uniswapV2Pair || to == uniswapV2Pair) {
            tradeFeeAmount = amount.mul(tradeFee).div(maxRate);

            destroyAmount = amount.mul(tradeDestroy).div(maxRate);

            uint256 angelAmount = amount.mul(angelRate).div(maxRate);
            _balances[angelAddress] = _balances[angelAddress].add(angelAmount);
            emit Transfer(from, angelAddress, angelAmount);

            uint256 lpAmount = amount.mul(lpRate).div(maxRate);
            _balances[lpAddress] = _balances[lpAddress].add(lpAmount);
            emit Transfer(from, lpAddress, lpAmount);

            uint256 daoAmount = amount.mul(daoRate).div(maxRate);
            _balances[daoAddress] = _balances[daoAddress].add(daoAmount);
            emit Transfer(from, daoAddress, daoAmount);

            uint256 defiAmount = amount.mul(defiRate).div(maxRate);
            _balances[defiContractAddress] = _balances[defiContractAddress].add(defiAmount);
            emit Transfer(from, defiContractAddress, defiAmount);

            if (to == uniswapV2Pair) {
                uint256 currentDownRate = getPriceDownRate();
                if (currentDownRate >= dropRate) {
                    extraDestroyAmount = amount.mul(extraDestroyFee).div(maxRate);
                    tradeFeeAmount = extraDestroyAmount.add(tradeFeeAmount);
                    destroyAmount = extraDestroyAmount.add(destroyAmount);
                }
            }

        } else {

            destroyAmount = amount.mul(tradeFee).div(maxRate);
            tradeFeeAmount = destroyAmount;
        }

        _balances[deadAddress] = _balances[deadAddress].add(destroyAmount);
        emit Transfer(from, deadAddress, destroyAmount);

        _totalSupply = _totalSupply.sub(destroyAmount);
        amountAfter = amount.sub(tradeFeeAmount);
        return amountAfter;
    }


    function getCurrentPrice() view public returns (uint256 currentPrice){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0x55d398326f99059fF775485246999027B3197955;
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(1e18, path);
        return amounts[1];
    }

    function getIntervalDays() public view returns (uint256) {
        return block.timestamp.sub(startTime).div(1 days);
    }

    function setPrice() internal {
        uint256 intervalDay = getIntervalDays();
        if (priceMap[intervalDay] == 0) {
            priceMap[intervalDay] = getCurrentPrice();
        }
    }

    function getStartPrice() view public returns (uint256){
        uint256 intervalDay = getIntervalDays();
        uint256 _startPrice = priceMap[intervalDay];
        if (priceMap[intervalDay] == 0) {
            _startPrice = getCurrentPrice();
        }
        return _startPrice;
    }

    function getPriceDownRate() view public returns (uint256){
        uint256 currentPrice = getCurrentPrice();
        uint256 _startPrice = getStartPrice();
        uint256 ze = 0;
        if (currentPrice >= _startPrice) {
            return ze;
        }
        uint256 downRate = _startPrice.sub(currentPrice).mul(100).div(_startPrice);
        return downRate;
    }

    function burn(uint256 amount) public {
        require(msg.sender != address(0), "burn from the zero address");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[deadAddress] = _balances[deadAddress].add(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, deadAddress, amount);
    }


}