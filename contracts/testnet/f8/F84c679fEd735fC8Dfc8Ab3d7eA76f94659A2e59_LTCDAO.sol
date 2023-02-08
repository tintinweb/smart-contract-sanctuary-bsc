/**
 *Submitted for verification at BscScan.com on 2023-02-07
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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress2;
    address public fundAddress3;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _ltc;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;


    uint256 public _buyLPDividendFee = 500;

    uint256 public _sellFundFee2 = 200;
    uint256 public _sellFundFee3 = 300;

    uint256 public _transferFee = 300;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _limitAmount;

    uint256 public _airdropNum = 1;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address LTCAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address FundAddress2, address FundAddress3,
        uint256 LimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
        _ltc = LTCAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;
        fundAddress3 = FundAddress3;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[FundAddress3] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = LimitAmount * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(usdt);

        excludeLPHolder[address(0)] = true;
        excludeLPHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        lpRewardCondition = 10 ** IERC20(LTCAddress).decimals();
        lpCondition = 1000;
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

    address private _lastMaybeLPAddress;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        address lastMaybeLPAddress = _lastMaybeLPAddress;
        address mainPair = _mainPair;
        if (lastMaybeLPAddress != address(0)) {
            _lastMaybeLPAddress = address(0);
            if (IERC20(mainPair).balanceOf(lastMaybeLPAddress) > 0) {
                _addLpProvider(lastMaybeLPAddress);
            }
        }

        require(!_blackList[from] || _feeWhiteList[from], "BL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] ) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    bool isAddLP;
                    if (to == mainPair) {
                        isAddLP = _isAddLiquidity(amount);
                        if (isAddLP) {
                            takeFee = false;
                        }
                    }
                    require(0 < startAddLPBlock && isAddLP, "!T");
                }

                _airdrop(from, to, amount);

                if (takeFee && block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        uint256 limitAmount = _limitAmount;
        if (limitAmount > 0 && !_swapPairList[to]) {
            require(limitAmount >= balanceOf(to), "LA");
        }

        if (from != address(this)) {
            if (_swapPairList[to]) {
                _lastMaybeLPAddress = from;
            }

            processLPReward(_rewardGas);
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = 1;
        address airdropAddress;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = airdropAmount;
            emit Transfer(airdropAddress, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * _buyLPDividendFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellFundFee2 + _sellFundFee3) / 10000;
            } else {//Transfer
                address tokenDistributor = address(_tokenDistributor);
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, tokenDistributor, feeAmount);
                    if (startTradeBlock > 0 && !inSwap) {
                        uint256 swapAmount = 2 * feeAmount;
                        uint256 contractTokenBalance = balanceOf(tokenDistributor);
                        if (swapAmount > contractTokenBalance) {
                            swapAmount = contractTokenBalance;
                        }
                        _tokenTransfer(tokenDistributor, address(this), swapAmount, false);
                        swapTokenForFund2(swapAmount);
                    }
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
                if (isSell && !inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = swapFeeAmount * 230 / 100;
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundFee2 = _sellFundFee2;
        uint256 liDividendFee = _buyLPDividendFee;
        uint256 totalFee = fundFee2 + _sellFundFee3 + _buyLPDividendFee;
        uint256 lpDividendUsdt = liDividendFee * usdtBalance / totalFee;

        uint256 fundUsdt = fundFee2 * usdtBalance / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress2, fundUsdt);
        }

        fundUsdt = usdtBalance - lpDividendUsdt - fundUsdt;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress3, fundUsdt);
        }

        if (lpDividendUsdt > 0) {
            path[0] = usdt;
            path[1] = _ltc;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                lpDividendUsdt,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function swapTokenForFund2(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
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

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress3(address addr) external onlyOwner {
        fundAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(
        uint256 lpDividendFee
    ) external onlyOwner {
        _buyLPDividendFee = lpDividendFee;
    }

    function setSellFee(
        uint256 sellFundFee2, uint256 sellFundFee3
    ) external onlyOwner {
        _sellFundFee2 = sellFundFee2;
        _sellFundFee3 = sellFundFee3;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
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

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimContractToken(address contractAddress, address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(contractAddress).claimToken(token, fundAddress, amount);
        }
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    receive() external payable {}

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public _rewardGas = 500000;

    mapping(address => bool)  public excludeLPHolder;
    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public lpCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt;

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 RewardToken = IERC20(_ltc);
        uint256 rewardCondition = lpRewardCondition;
        if (RewardToken.balanceOf(address(this)) < rewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLPHolder[shareHolder]) {
                tokenBalance = holdToken.balanceOf(shareHolder);
                if (tokenBalance >= holdCondition) {
                    amount = rewardCondition * tokenBalance / holdTokenTotal;
                    if (amount > 0) {
                        RewardToken.transfer(shareHolder, amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setLPCondition(uint256 amount) external onlyOwner {
        lpCondition = amount;
    }

    function setExcludeLPHolder(address addr, bool enable) external onlyOwner {
        excludeLPHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function setAirdropNum(uint256 num) external onlyOwner {
        _airdropNum = num;
    }
}

contract LTCDAO is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
    //USDT
        address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd),
    //LTC
        address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd),
        "LTCDAO",
        "LTCDAO",
        18,
        88000,
    
        address(0xd6b0C60C1579f57E1Daa54093CdF7Fb00d76dbEB),
 
        address(0xd6b0C60C1579f57E1Daa54093CdF7Fb00d76dbEB),
 
        address(0x0ba04577514a3810cbe047b2A1cdbB622A7A8Adb),

        address(0x9BA1212334a744FB571377A0114b4a98B8564310),

        0
    ){

    }
}