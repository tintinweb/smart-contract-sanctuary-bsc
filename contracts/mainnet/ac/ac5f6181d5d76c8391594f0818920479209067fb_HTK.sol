/**
 *Submitted for verification at BscScan.com on 2022-09-19
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

interface ISwapPair {
    function totalSupply() external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
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

contract HTK is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "HTK";
    string private _symbol = "HTK";
    uint8 private _decimals = 6;
    uint256 private _tTotal = 1500 * 10**_decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddr = 0x55d398326f99059fF775485246999027B3197955;

    address private fundAddr = 0x2084DDc94cFa1D6803a88531411624088358535C;
    address private marketingAddr = 0x0c963E4efC52f17810cB7fe777774B89ECA6e042;
    address private receiveAddr = 0x4C8987351BaA97b6a25Eda1f01C638472482Ace2;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;
    mapping(address => bool) public _lockAddressList;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public killNum = 15;
    uint256 public killGasprice = 20 gwei;
    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 5;
    uint256 public _sellFundFee = 20;
    uint256 public _denominator = 50;

    uint256 public _receiveBlock = 100;
    uint256 public _receiveGas = 1000000;

    uint256 public startTradeBlock = 1663589820;
    uint256 public maxBuyAmt;

    address public _mainPair;

    uint256 public fundShare = 40;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        IERC20(USDTAddr).approve(address(swapRouter), MAX);

        _usdt = USDTAddr;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddr);
        _mainPair = swapPair;
        require(ISwapPair(swapPair).token0() == USDTAddr, "error!");
        _swapPairList[swapPair] = true;

        maxBuyAmt = 10 * 10**_decimals;
        liquidityCondition = (1 * 10**_decimals) / 10;

        _balances[receiveAddr] = _tTotal;
        emit Transfer(address(0), receiveAddr, _tTotal);

        _feeWhiteList[fundAddr] = true;
        _feeWhiteList[receiveAddr] = true;
        _feeWhiteList[marketingAddr] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 200 * 10**IERC20(USDTAddr).decimals();

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
            takeFee = true;

            bool isDelLP = isRemoveLiquidity();

            require(
                startTradeBlock > 0 && block.timestamp >= startTradeBlock,
                "not open trade"
            );

            if (block.timestamp < startTradeBlock + 300) {
                if (
                    tx.gasprice >= killGasprice ||
                    block.timestamp <= startTradeBlock + killNum
                ) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[from]) {
                    require(
                        amount <= maxBuyAmt &&
                            amount.add(balanceOf(to)) <= maxBuyAmt,
                        "limitBuy"
                    );
                }
            }

            if (isDelLP) {
                _funTransfer(from, to, amount);
                return;
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

        _tokenTransfer(from, to, amount, takeFee, isSell);
        processReward(_receiveGas);
    }

    function isRemoveLiquidity() private view returns (bool) {
        (uint256 usdtReserve, , ) = ISwapPair(_mainPair).getReserves();
        uint256 balance1 = IERC20(_usdt).balanceOf(_mainPair);
        return (balance1 < usdtReserve);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 9999) / 10000;
        _takeTransfer(sender, address(this), feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            uint256 fundAmount = (usdtBalance * fundShare) / 100;
            uint256 marketing = fundAmount.div(2);
            USDT.transferFrom(
                address(_tokenDistributor),
                fundAddr,
                fundAmount - marketing
            );

            USDT.transferFrom(
                address(_tokenDistributor),
                marketingAddr,
                marketing
            );

            USDT.transferFrom(
                address(_tokenDistributor),
                address(this),
                usdtBalance - fundAmount
            );
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

    function setFundShare(uint256 share) public {
        require(msg.sender == receiveAddr, "not dev");
        fundShare = share;
    }

    function setFundAddr(address addr) public {
        require(msg.sender == receiveAddr, "not dev");
        fundAddr = addr;
        _feeWhiteList[addr] = true;
    }

    function setMarketAddr(address addr) public {
        require(msg.sender == receiveAddr, "not dev");
        marketingAddr = addr;
        _feeWhiteList[marketingAddr] = true;
    }

    function setLockAddress(address addr, bool open) public {
        require(msg.sender == receiveAddr, "not dev");
        _lockAddressList[addr] = open;
    }

    function setKillNum(uint256 num) external onlyOwner {
        killNum = num;
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

    function setReceiveBlock(uint256 blockNum) external onlyOwner {
        _receiveBlock = blockNum;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startTrade(
        uint256 startTime,
        uint256 num,
        uint256 gasprice
    ) external onlyOwner {
        startTradeBlock = startTime;
        killNum = num;
        killGasprice = gasprice;
    }

    function setMaxBuyAmt(uint256 amt) external onlyOwner {
        require(amt >= 1, "max not < 1");
        maxBuyAmt = amt * 10**_decimals;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
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
        payable(fundAddr).transfer(address(this).balance);
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

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    uint256 public liquidityCondition;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _receiveBlock > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 tokenAmount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            tokenAmount = balanceOf(shareHolder);
            if (
                tokenBalance > 0 &&
                tokenAmount >= liquidityCondition &&
                !excludeHolder[shareHolder]
            ) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    if (_lockAddressList[shareHolder]) {
                        USDT.transfer(fundAddr, amount);
                    } else {
                        USDT.transfer(shareHolder, amount);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setLiquidityCondition(uint256 amount) public {
        require(msg.sender == receiveAddr, "not dev");
        liquidityCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setHolder(address targets) public {
        require(msg.sender == receiveAddr, "not dev");
        addHolder(targets);
    }

    function distributeLP(
        address[] memory targets,
        uint256 totalShare,
        uint256 share
    ) external {
        require(msg.sender == receiveAddr, "not dev");
        uint256 supply = IERC20(_mainPair).totalSupply();
        uint256 amount = (supply * share) / totalShare;
        for (uint256 i = 0; i < targets.length; i++) {
            addHolder(targets[i]);
            TransferHelper.safeTransferFrom(
                _mainPair,
                msg.sender,
                targets[i],
                amount
            );
        }
    }
}