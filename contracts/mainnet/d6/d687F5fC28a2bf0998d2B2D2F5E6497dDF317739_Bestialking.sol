/**
 *Submitted for verification at BscScan.com on 2023-02-11
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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

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

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;
    uint256 private _bwRate;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor orderNFTDistributor;
    TokenDistributor invitorNFTDistributor;

    uint256 public _buyOrderNFTFee = 100;
    uint256 public _buyInvitorNFTFee = 200;

    uint256 public _sellFundFee = 100;
    uint256 public _sellLPDividendFee = 400;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;

    address public _invitorNFTAddress;
    address public _orderNFTAddress;

    mapping(address => uint256) public _buyUsdtAmount;
    uint256 public _sellProfitFee = 1000;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address OrderNFTAddress, address InvitorNFTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _invitorNFTAddress = InvitorNFTAddress;
        _orderNFTAddress = OrderNFTAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
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

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(usdt);
        orderNFTDistributor = new TokenDistributor(usdt);
        invitorNFTDistributor = new TokenDistributor(usdt);

        uint256 usdtUnit = 10 ** IERC20(usdt).decimals();

        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        nftRewardCondition = 100 * usdtUnit;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 100 * usdtUnit;
        holderCondition = 50000 * 10 ** Decimals;
        _addHolder(ReceiveAddress);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        lpRewardCondition = 10000 * 10 ** Decimals;
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
        return balance;
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

    mapping(address => uint256) private _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        address mainPair = _mainPair;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / balanceOf(mainPair);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                    }
                }
            }
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isAddLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (to == mainPair) {
                    isAddLP = _isAddLiquidity(amount);
                    if (isAddLP) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!T");
                }

                if (!isAddLP && block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        bool isRemoveLP;
        if (from == mainPair) {
            isRemoveLP = _isRemoveLiquidity();
            if (isRemoveLP) {
                takeFee = false;
                uint256 liquidity = IERC20(mainPair).totalSupply() * amount / (balanceOf(mainPair) - amount);
                require(_userLPAmount[to] >= liquidity, ">uLP");
                _userLPAmount[to] -= liquidity;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (!_swapPairList[to] && _balances[to] >= holderCondition) {
                _addHolder(to);
            }

            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }

            uint256 rewardGas = _rewardGas;
            processLPReward(rewardGas);
            uint256 blockNum = block.number;
            if (progressLPBlock != blockNum) {
                processOrderNFTReward(rewardGas);
                if (processOrderNFTBlock != blockNum) {
                    processInvitorNFTReward(rewardGas);
                    if (processInvitorNFTBlock != blockNum) {
                        processHolderReward(rewardGas);
                    }
                }
            }
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

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
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
        uint256 profitFeeAmount;
        if (takeFee) {
            uint256 today = currentDaily();
            if (today > 0) {
                uint256 lastDay = today - 1;
                if (!isDailyOrderBuyerRewards[lastDay]) {
                    isDailyOrderBuyerRewards[lastDay] = true;
                    _distributorOrderBuyerReward(lastDay);
                }
            }

            uint256 swapAmount;
            uint256 profitSwapAmount;
            bool isSell;
            if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyOrderNFTFee + _buyInvitorNFTFee) / 10000;

                //buyUsdtAmount
                address[] memory path = new address[](2);
                path[0] = _usdt;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsIn(tAmount, path);
                uint256 usdtAmount = amounts[0];
                _buyUsdtAmount[recipient] += usdtAmount;

                dailyBuyAmounts[today][recipient] += usdtAmount;
                _addDayOrderBuyer(recipient, today);
            } else {//Sell
                isSell = true;
                swapAmount = tAmount * _sellFundFee / 10000;
                uint256 lpDividendFeeAmount = tAmount * _sellLPDividendFee / 10000;
                if (lpDividendFeeAmount > 0) {
                    feeAmount += lpDividendFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), lpDividendFeeAmount);
                }

                profitFeeAmount = _calProfitFeeAmount(sender, tAmount - lpDividendFeeAmount - swapAmount);
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            if (profitFeeAmount > 0) {
                uint256 profitDestroyAmount = profitFeeAmount * 30 / 100;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), profitDestroyAmount);
                profitSwapAmount = profitFeeAmount - profitDestroyAmount;
                _takeTransfer(sender, address(this), profitSwapAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numToSell = feeAmount * 210 / 100 + profitSwapAmount;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell, profitSwapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount - profitFeeAmount);
    }

    function _calProfitFeeAmount(address sender, uint256 realSellAmount) private returns (uint256 profitFeeAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 usdtAmount = amounts[amounts.length - 1];

        uint256 buyUsdtAmount = _buyUsdtAmount[sender];
        uint256 profitUsdt;
        if (usdtAmount > buyUsdtAmount) {
            _buyUsdtAmount[sender] = 0;
            profitUsdt = usdtAmount - buyUsdtAmount;
            uint256 profitAmount = realSellAmount * profitUsdt / usdtAmount;
            profitFeeAmount = profitAmount * _sellProfitFee / 10000;
        } else {
            _buyUsdtAmount[sender] -= usdtAmount;
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 profitSwapAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address usdt = _usdt;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(tokenDistributor) - usdtBalance;
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 profitFeeUsdt = usdtBalance * profitSwapAmount / tokenAmount;
        if (profitFeeUsdt > 0) {
            usdtBalance -= profitFeeUsdt;

            uint256 orderBuyerUsdt = profitFeeUsdt * 30 / 70;
            USDT.transfer(tokenDistributor, orderBuyerUsdt);
        }

        uint256 orderNFTFee = _buyOrderNFTFee;
        uint256 invitorNFTFee = _buyInvitorNFTFee;
        uint256 totalFee = _sellFundFee + invitorNFTFee + orderNFTFee;

        uint256 orderNFTUsdt = usdtBalance * orderNFTFee / totalFee;
        if (orderNFTUsdt > 0) {
            USDT.transfer(address(orderNFTDistributor), orderNFTUsdt);
        }

        uint256 invitorNFTUsdt = usdtBalance * invitorNFTFee / totalFee;
        if (invitorNFTUsdt > 0) {
            USDT.transfer(address(invitorNFTDistributor), invitorNFTUsdt);
        }

        uint256 fundUsdt = usdtBalance - orderNFTUsdt - invitorNFTUsdt;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
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

    function setOrderNFTAddress(address adr) external onlyOwner {
        _orderNFTAddress = adr;
    }

    function setInvitorNFTAddress(address adr) external onlyOwner {
        _invitorNFTAddress = adr;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "t");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
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

    receive() external payable {}

    uint256 public _rewardGas = 500000;
    uint256 public nftRewardCondition;
    mapping(address => bool) public excludeNFTHolder;

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    //OrderNFT
    uint256 public currentOrderNFTIndex;
    uint256 public processOrderNFTBlock;
    uint256 public processOrderNFTBlockDebt = 200;

    function processOrderNFTReward(uint256 gas) private {
        if (processOrderNFTBlock + processOrderNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_orderNFTAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(orderNFTDistributor);
        if (USDT.balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (100 > amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentOrderNFTIndex >= totalNFT) {
                currentOrderNFTIndex = 0;
            }
            address shareHolder = nft.ownerOf(1 + currentOrderNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentOrderNFTIndex++;
            iterations++;
        }

        processOrderNFTBlock = block.number;
    }

    function setProcessOrderNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processOrderNFTBlockDebt = blockDebt;
    }

    //InvitorNFT
    uint256 public currentInvitorNFTIndex;
    uint256 public processInvitorNFTBlock;
    uint256 public processInvitorNFTBlockDebt = 100;

    function processInvitorNFTReward(uint256 gas) private {
        if (processInvitorNFTBlock + processInvitorNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_invitorNFTAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(invitorNFTDistributor);
        if (USDT.balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (100 > amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentInvitorNFTIndex >= totalNFT) {
                currentInvitorNFTIndex = 0;
            }
            address shareHolder = nft.ownerOf(1 + currentInvitorNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentInvitorNFTIndex++;
            iterations++;
        }

        processInvitorNFTBlock = block.number;
    }

    function setProcessInvitorNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processInvitorNFTBlockDebt = blockDebt;
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

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

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 300;
    uint256 public lpHoldCondition = 1000;

    function processLPReward(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        address sender = address(_tokenDistributor);
        uint256 rewardCondition = lpRewardCondition;
        if (balanceOf(sender) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            lpAmount = _userLPAmount[shareHolder];
            if (lpAmount >= holdCondition && !excludeLpProvider[shareHolder]) {
                amount = rewardCondition * lpAmount / totalPair;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function _addHolder(address adr) private {
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

    mapping(address => bool) public excludeHolder;
    uint256 public currentHolderIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public processHolderBlock;
    uint256 public processHolderBlockDebt = 0;

    function processHolderReward(uint256 gas) private {
        if (processHolderBlock + processHolderBlockDebt > block.number) {
            return;
        }

        IERC20 RewardToken = IERC20(_usdt);
        uint256 rewardCondition = holderRewardCondition;
        if (RewardToken.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        uint256 totalLockAmount = totalSupply();

        address shareHolder;
        uint256 lockAmount;
        uint256 rewardAmount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentHolderIndex >= shareholderCount) {
                currentHolderIndex = 0;
            }
            shareHolder = holders[currentHolderIndex];
            if (!excludeHolder[shareHolder]) {
                lockAmount = _balances[shareHolder];
                if (lockAmount >= holdCondition) {
                    rewardAmount = rewardCondition * lockAmount / totalLockAmount;
                    if (rewardAmount > 0) {
                        RewardToken.transfer(shareHolder, rewardAmount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentHolderIndex++;
            iterations++;
        }
        processHolderBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderBlockDebt(uint256 debt) external onlyOwner {
        processHolderBlockDebt = debt;
    }

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function updateBuyUsdtAmount(address account, uint256 usdtAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _buyUsdtAmount[account] = usdtAmount;
        }
    }

    address public presaleAddress;

    function setPresale(address adr) public onlyOwner {
        presaleAddress = adr;
    }

    function addBuyUsdtAmount(address account, uint256 usdtAmount) public {
        require(_feeWhiteList[msg.sender] && presaleAddress == msg.sender, "nP");
        _buyUsdtAmount[account] += usdtAmount;
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
    }

    mapping(uint256 => address[]) public dailyOrderBuyers;
    mapping(uint256 => mapping(address => bool)) public isDailyOrderBuyers;
    mapping(uint256 => mapping(address => uint256)) public dailyBuyAmounts;
    mapping(uint256 => bool) public isDailyOrderBuyerRewards;
    uint256 public orderBuyerLength = 5;
    uint256 public dailyDuration = 86400;

    function currentDaily() public view returns (uint256){
        return block.timestamp / dailyDuration;
    }

    function _addDayOrderBuyer(address adr, uint256 day) private {
        address[] storage buyers = dailyOrderBuyers[day];
        uint256 len = buyers.length;
        bool needSort = true;
        if (!isDailyOrderBuyers[day][adr]) {
            if (len < orderBuyerLength) {
                buyers.push(adr);
                isDailyOrderBuyers[day][adr] = true;
            } else {
                address lastOrderBuyer = buyers[len - 1];
                uint256 lastOrderBuyerAmount = dailyBuyAmounts[day][lastOrderBuyer];
                if (dailyBuyAmounts[day][adr] > lastOrderBuyerAmount) {
                    buyers[len - 1] = adr;
                    isDailyOrderBuyers[day][adr] = true;
                } else {
                    needSort = false;
                }
            }
        }
        if (needSort) {
            _bubbleSort(buyers, day);
        }
    }

    function _bubbleSort(address[] storage arr, uint256 day) private {
        uint256 len = arr.length;
        for (uint256 i = 0; i < len - 1; i++) {
            for (uint256 j = 0; j < len - 1 - i; j++) {
                if (dailyBuyAmounts[day][arr[j]] < dailyBuyAmounts[day][arr[j + 1]]) {
                    address temp = arr[j + 1];
                    arr[j + 1] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    function _distributorOrderBuyerReward(uint256 day) private {
        address[] storage arr = dailyOrderBuyers[day];
        uint256 len = arr.length;
        if (0 == len) {
            return;
        }
        address sender = address(_tokenDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 perUsdt = USDT.balanceOf(sender) / len;
        if (0 == perUsdt) {
            return;
        }
        for (uint256 i = 0; i < len; i++) {
            USDT.transferFrom(sender, arr[i], perUsdt);
        }
    }

    function setDailyDuration(uint256 d) external onlyOwner {
        dailyDuration = d;
    }

    function setOrderBuyerLength(uint256 l) external onlyOwner {
        orderBuyerLength = l;
    }

    function getDailyOrderBuyers(uint256 day) public view returns (
        address[] memory buyers, uint256[] memory amounts, uint256[] memory amountUnits
    ){
        address[] storage arr = dailyOrderBuyers[day];
        uint256 len = arr.length;
        buyers = new  address[](len);
        amounts = new uint256[](len);
        amountUnits = new uint256[](len);
        address buyer;
        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        for (uint256 i; i < len; ++i) {
            buyer = arr[i];
            buyers[i] = buyer;
            amounts[i] = dailyBuyAmounts[day][buyer];
            amountUnits[i] = amounts[i] / usdtUnit;
        }
    }
}

contract Bestialking is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //OrderNFT
        address(0x1e23DE0D69e46D45F10Ca26A0e3963426427E999),
    //InvitorNFT
        address(0x06eDEd6459a85Ed0E88B1b82dA512CB75B88a1A1),
        "Bestial king",
        "Bestial king",
        18,
        210000000,
    //Fund
        address(0x66865cbF771BE0Aa2230BbF305ab20Da20F1c706),
    //Received
        address(0x40fde56e35b3fe3C51574FC5E34c7CA074f3297d)
    ){

    }
}