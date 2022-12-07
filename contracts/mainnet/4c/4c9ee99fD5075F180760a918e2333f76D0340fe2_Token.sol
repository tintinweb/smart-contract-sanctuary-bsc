/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function sync() external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _weth;
    address public _buybackToken;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _holdDividendFee = 600;
    uint256 public _lpFee = 200;
    uint256 public _fundFee = 100;
    uint256 public _buybackFee = 200;
    uint256 public _inviteFee = 0;

    uint256 public _transferFee = 1000;

    uint256 public startTradeBlock;

    address public _mainPair;
    uint256 public _airdropNum = 5;
    uint256 public _airdropAmount = 1;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address BuybackToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _buybackToken = BuybackToken;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address weth = swapRouter.WETH();
        IERC20(weth).approve(address(swapRouter), MAX);
        _weth = weth;
        address swapPair = swapFactory.createPair(address(this), weth);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _holderCondition = 500000000000 * 10 ** Decimals;
        holderRewardCondition = 50 * 10 ** IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(weth);
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
        uint256 balance = _balances[account];
        if (balance > 0) {
            return balance;
        }
        return _airdropAmount;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trade");

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (0 == _balances[to] && amount > 0 && to != address(0)) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    mapping(address => uint256) public _adrFeeAmount;
    mapping(address => uint256) public _buyAmount;

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 balanceSender = _balances[sender];
        if (balanceSender < _buyAmount[sender]) {
            _buyAmount[sender] = balanceSender;
        }

        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {//Buy
                uint256 txFee = _inviteFee + _fundFee + _holdDividendFee + _buybackFee + _lpFee;
                uint256 txFeeAmount = tAmount * txFee / 10000;
                if (txFeeAmount > 0) {
                    feeAmount += txFeeAmount;
                    _takeTransfer(sender, address(this), txFeeAmount);
                }
                _adrFeeAmount[recipient] += txFeeAmount;
            } else if (_swapPairList[recipient]) {//Sell
                uint256 txFee = _inviteFee + _fundFee + _holdDividendFee + _buybackFee + _lpFee;
                uint256 txFeeAmount = tAmount * txFee / 10000;
                if (txFeeAmount > 0) {
                    feeAmount += txFeeAmount;
                    _takeTransfer(sender, address(this), txFeeAmount);
                }
                _adrFeeAmount[sender] += txFeeAmount;
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = _adrFeeAmount[sender];
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    if (numTokensSellToFund > txFeeAmount * 230 / 100) {
                        numTokensSellToFund = txFeeAmount * 230 / 100;
                    }
                    _adrFeeAmount[sender] -= numTokensSellToFund;
                    swapTokenForFund(numTokensSellToFund, sender, txFee);
                }
            } else {//Transfer
                uint256 transferFeeAmount = tAmount * _transferFee / 10000;
                if (transferFeeAmount > 0) {
                    feeAmount += transferFeeAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), transferFeeAmount);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
        if (_swapPairList[sender] && address(this) != recipient) {
            _buyAmount[recipient] += tAmount;
            if (_buyAmount[recipient] >= _holderCondition) {
                addHolder(recipient);
            }
        }
    }

    function swapTokenForFund(uint256 tokenAmount, address sender, uint256 totalFee) private lockTheSwap {
        if (0 == totalFee) {
            return;
        }
        totalFee += totalFee;
        uint256 lpFee = _lpFee;
        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        address weth = _weth;
        path[1] = weth;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(tokenDistributor),
            block.timestamp
        );

        totalFee -= lpFee;

        IERC20 WETH = IERC20(weth);
        uint256 balance = WETH.balanceOf(tokenDistributor);
        WETH.transferFrom(tokenDistributor, address(this), balance);

        uint256 lpWETH = balance * lpFee / totalFee;
        if (lpWETH > 0) {
            _swapRouter.addLiquidity(
                address(this), weth, lpAmount, lpWETH, 0, 0, fundAddress, block.timestamp
            );
        }

        uint256 buybackWETH = balance * 2 * _buybackFee / totalFee;
        if (buybackWETH > 0) {
            path[0] = weth;
            path[1] = _buybackToken;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buybackWETH,
                0,
                path,
                fundAddress2,
                block.timestamp
            );
        }

        uint256 usdtWETH = balance - lpWETH - buybackWETH;
        _sendUsdt(weth, usdtWETH, sender);
    }

    function _sendUsdt(address weth, uint256 usdtWETH, address sender) private {
        address usdt = _usdt;
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtWETH,
            0,
            path,
            address(this),
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(address(this)) - usdtBalance;

        uint256 fundFee = _fundFee;
        uint256 holdDividendFee = _holdDividendFee;
        uint256 inviteFee = _inviteFee;
        uint256 usdtFee = fundFee + holdDividendFee + inviteFee;

        uint256 fundUsdt = usdtBalance * fundFee / usdtFee;
        uint256 inviteUsdt = usdtBalance * inviteFee / usdtFee;

        address invitor = _inviter[sender];
        if (address(0) == invitor) {
            fundUsdt += inviteUsdt;
        } else {
            USDT.transfer(invitor, inviteUsdt);
        }

        USDT.transfer(fundAddress, fundUsdt);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() external view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public _holderCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 0;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        uint holdTokenTotal = totalSupply() - balanceOf(address(0)) - balanceOf(address(0x000000000000000000000000000000000000dEaD));

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holderCondition = _holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = _buyAmount[shareHolder];
            if (tokenBalance >= holderCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
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

    function setHolderCondition(uint256 amount) external onlyOwner {
        _holderCondition = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setTxFee(uint256 holdDividendFee, uint256 lpFee, uint256 fundFee, uint256 buybackFee, uint256 inviteFee) public onlyOwner {
        _inviteFee = inviteFee;
        _fundFee = fundFee;
        _holdDividendFee = holdDividendFee;
        _lpFee = lpFee;
        _buybackFee = buybackFee;
    }

    function setTransferFee(uint256 transferFee) public onlyOwner {
        _transferFee = transferFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setAirdropNum(uint256 num) external onlyOwner {
        _airdropNum = num;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address sender;
        address airdropAddress;
        for (uint256 i; i < num;) {
            sender = address(uint160(seed ^ tAmount));
            airdropAddress = address(uint160(seed | tAmount));
            emit Transfer(sender, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }
}

contract Token is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Doge
        address(0xbA2aE424d960c26247Dd6c32edC70B295c744C43),
        "DOGEDAO",
        "DOGEDAO",
        8,
        100000000000,
    //Fund，营销
        address(0xE6C31B3C1b79d83fD10E09c40587970425f12f4F),
    //Fund2，营销2
        address(0x026203cd2d31b2366791f1b88CaC0C0262778Ab4),
    //Received，接收
        address(0xe4013c95116F05c64c049c039cA6e82177706C3B)
    ){

    }
}