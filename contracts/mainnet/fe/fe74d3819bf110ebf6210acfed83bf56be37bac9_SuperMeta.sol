/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract SuperMeta is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "SuperMeta";
    string private _symbol = "SMeta";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 50000000 * 10**_decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr;
    address private USDTAddr;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;
    mapping(address => bool) public _vipWhiteList;
    mapping(address => bool) public _boughtList;

    address private receiveAddr = 0x778CaFc5BC33D7aB271De518f29E9269034f257a;
    address private fund1Addr = 0x6DcDBD7285a747AF5c395190Eb764521Fc8c86C8;
    address private fund2Addr = 0x2b7F1C650f11712df513F8bd06294f8213B39F19;
    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 3;
    uint256 public _sellFundFee = 20;
    uint256 public _denominator = 115;

    uint256 public startTradeBlock = 0;

    address public _mainPair;
    uint256 public vipTimes;
    uint256 public tokenLimit;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        if (chainId == 56) {
            RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            USDTAddr = 0x55d398326f99059fF775485246999027B3197955;
        } else {
            RouterAddr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
            USDTAddr = 0x1d1FfD1870aF4702738f4d0cdb9c6265789C43d7;
        }

        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        IERC20(USDTAddr).approve(address(swapRouter), MAX);
        receiveAddr = msg.sender;
        _usdt = USDTAddr;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddr);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[receiveAddr] = _tTotal;
        emit Transfer(address(0), receiveAddr, _tTotal);

        _feeWhiteList[receiveAddr] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(USDTAddr);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
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
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_botWhiteList[from] && !_botWhiteList[to], "bot address");

        bool takeFee;
        bool isSell;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_swapPairList[from] || _swapPairList[to]) {
                takeFee = true;
                require(startTradeBlock > 0, "not open trade");

                if (
                    _swapPairList[from] &&
                    block.number <= startTradeBlock + vipTimes
                ) {
                    require(_vipWhiteList[to], "not vip");
                    require(!_boughtList[to], "Already purchased");

                    address[] memory path = new address[](2);
                    path[0] = _usdt;
                    path[1] = address(this);
                    uint256[] memory amountsIn = _swapRouter.getAmountsIn(
                        amount,
                        path
                    );
                    require(amountsIn[0] <= tokenLimit, "exceeds limit");
                    _boughtList[to] = true;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _sellFundFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
                                _denominator;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund);
                        }
                    }
                    isSell = true;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee = isSell ? _sellFundFee : _buyFundFee;
            uint256 swapAmount = (tAmount * swapFee) / 100;
            feeAmount += swapAmount;
            _takeTransfer(sender, address(this), swapAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        if (usdtBalance > 0) {
            uint256 amount = usdtBalance / 2;
            USDT.transferFrom(
                address(_tokenDistributor),
                fund2Addr,
                usdtBalance - amount
            );
            USDT.transferFrom(address(_tokenDistributor), fund1Addr, amount);
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function startTrade(uint256 _vipTimes, uint256 _tokenLimit)
        external
        onlyOwner
    {
        startTradeBlock = block.number;
        vipTimes = _vipTimes;
        tokenLimit = _tokenLimit;
    }

    function setFees(
        uint256 buyFee,
        uint256 sellFee,
        uint256 denominator
    ) external onlyOwner {
        _buyFundFee = buyFee;
        _sellFundFee = sellFee;
        _denominator = denominator;
    }

    function setVipWhiteList(address[] calldata addList, bool enable)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addList.length; i++) {
            _vipWhiteList[addList[i]] = enable;
        }
    }

    function setBotWhiteList(address[] calldata addList, bool enable)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addList.length; i++) {
            _botWhiteList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) public {
        require(msg.sender == receiveAddr, "not dev");
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}
}