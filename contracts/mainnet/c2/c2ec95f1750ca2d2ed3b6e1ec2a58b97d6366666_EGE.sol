/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

interface IBtcNFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
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
    address public _owner;
    constructor (address token, address token2) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
        IERC20(token2).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

contract RewardPool {

}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor public _nftDistributor;

    uint256 public _buyFundFee = 100;
    uint256 public _buyDestroyFee = 200;

    uint256 public _sellLPFee = 100;
    uint256 public _sellNFTDividendFee = 100;
    uint256 public _sellNodeDividendFee = 100;
    uint256 public _sellLPDividendFee = 200;
    uint256 public _sellDestroyOtherFee = 100;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;
    uint256 public _numToSell;

    uint256 public _startTradeTime;
    address public _addLPToken;

    address public _btcNFTAddress;
    address public _airdropSender;
    mapping(address => uint256) public _lockAmounts;

    address public _admAddress;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address AddLPToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address BTCNFTAddress, address AirdropSender
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(AddLPToken).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), AddLPToken);
        _swapPairList[mainPair] = true;
        _addLPToken = AddLPToken;
        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;
        _airdropSender = AirdropSender;
        _admAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[AirdropSender] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _usdt = USDTAddress;

        _tokenDistributor = new TokenDistributor(USDTAddress, AddLPToken);
        _nftDistributor = new TokenDistributor(USDTAddress, AddLPToken);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        lpRewardCondition = 100 * usdtDecimals;
        _numToSell = 1 * tokenDecimals;

        _addLpProvider(FundAddress);

        _btcNFTAddress = BTCNFTAddress;
        _btcNftHolderCondition = 10 * tokenDecimals;
        btcNftRewardCondition = 100 * usdtDecimals;

        partnerRewardCondition = 100 * usdtDecimals;

        _maxReward = 210000 * tokenDecimals - total;
        _rewardPool = address(new RewardPool());
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
        if (_swapPairList[account]) {
            return balance;
        }
        address mainPair = _mainPair;
        uint256 reward = calUserTotalReward(account, currentSnapshotId(), IERC20(mainPair).totalSupply(), _balances[mainPair]);
        return balance + reward;
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 currentId = currentSnapshotId();

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
                    _addLpProvider(lastMaybeAddLPAddress);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    }
                }
                if (lpBalance != lpAmount) {
                    _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                    if (0 == _userLastRewardSnapshots[lastMaybeAddLPAddress]) {
                        _userLastRewardSnapshots[lastMaybeAddLPAddress] = currentId;
                    }
                }
            }
        }

        IERC20 pairToken = IERC20(mainPair);
        if (currentId > 1) {
            _calTotalReward(currentId, pairToken.totalSupply(), balanceOf(mainPair));
            _calUserReward(from, currentId);
        }

        uint256 balance = _balances[from];
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 999999 / 1000000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        bool takeFee;
        bool isAdd;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (_swapPairList[to]) {
                isAdd = _isAddLiquidity();
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (isAdd) {
                    takeFee = false;
                }
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAdd, "!Trade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (from == _airdropSender) {
                _lockAmounts[to] += amount;
            } else {
                uint256 lockedAmount = _lockAmounts[from];
                if (lockedAmount > amount) {
                    lockedAmount = amount;
                }
                _lockAmounts[from] -= lockedAmount;
                _lockAmounts[to] += lockedAmount;
            }
        }

        if (isAdd) {
            uint256 lockedAmount = _lockAmounts[from];
            if (lockedAmount > amount) {
                lockedAmount = amount;
            }
            _lockAmounts[from] -= lockedAmount;
        }

        if (!_swapPairList[from]) {
            uint256 lockedAmount = _lockAmounts[from];
            require(balance >= amount + lockedAmount, "locked");
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            } else if (from == mainPair) {
                uint256 lpBalance = IERC20(mainPair).balanceOf(to);
                uint256 lpAmount = _userLPAmount[to];
                if (lpAmount > lpBalance) {
                    _userLPAmount[to] = lpBalance;
                }
            }

            processPartnerDividend();
            uint256 blockNum = block.number;
            if (processPartnerBlock != blockNum) {
                uint256 rewardGas = _rewardGas;
                processBtcNFT(rewardGas);
                if (progressBtcNFTBlock != blockNum) {
                    processLP(rewardGas);
                }
            }
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = 5;
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

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _addLPToken;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
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

    function _standTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
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
            if (_swapPairList[sender]) {//buy
                uint256 fundFeeAmount = tAmount * _buyFundFee / 10000;
                if (fundFeeAmount > 0) {
                    feeAmount += fundFeeAmount;
                    _takeTransfer(sender, address(this), fundFeeAmount);
                }

                uint256 destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                if (destroyFeeAmount > 0) {
                    feeAmount += destroyFeeAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
                }
            } else {//sell
                uint256 lpFee = _sellLPFee;
                uint256 swapFee = lpFee + _sellLPDividendFee + _sellDestroyOtherFee + _sellNFTDividendFee + _sellNodeDividendFee;
                uint256 swapAmount = tAmount * swapFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numToSell = _numToSell;
                    if (contractTokenBalance >= numToSell) {
                        swapTokenForFund(numToSell, swapFee, lpFee);
                    }
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee, uint256 lpFee) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 fundFee = _buyFundFee;
        swapFee += fundFee;

        swapFee += swapFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        swapFee -= lpFee;

        address addLPToken = _addLPToken;
        address tokenDistributor = address(_tokenDistributor);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = addLPToken;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 AddLPToken = IERC20(addLPToken);
        uint256 addLPTokenBalance = AddLPToken.balanceOf(tokenDistributor);
        addLPTokenBalance = addLPTokenBalance * 9999 / 10000;
        AddLPToken.transferFrom(tokenDistributor, address(this), addLPTokenBalance);

        uint256 lpTokenAmount = addLPTokenBalance * lpFee / swapFee;
        if (lpTokenAmount > 0) {
            address fundAdr = fundAddress;
            _swapRouter.addLiquidity(
                address(this), addLPToken, lpAmount, lpTokenAmount, 0, 0, fundAdr, block.timestamp
            );
            _userLPAmount[fundAdr] = IERC20(_mainPair).balanceOf(fundAdr);
        }

        uint256 destroyAmount = addLPTokenBalance * 2 * _sellDestroyOtherFee / swapFee;
        if (destroyAmount > 0) {
            AddLPToken.transfer(address(0x000000000000000000000000000000000000dEaD), destroyAmount);
        }

        _distributeUsdt(addLPTokenBalance - destroyAmount - lpTokenAmount, fundFee);
    }

    function _distributeUsdt(uint256 tokenAmount, uint256 fundFee) private {
        if (0 == tokenAmount) {
            return;
        }
        address usdt = _usdt;
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = _addLPToken;
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(address(this)) - usdtBalance;
        uint256 nodeFee = _sellNodeDividendFee;
        uint256 nftFee = _sellNFTDividendFee;
        uint256 totalFee = fundFee + nodeFee + nftFee + _sellLPDividendFee;

        uint256 nodeUsdt = usdtBalance * nodeFee / totalFee;
        if (nodeUsdt > 0) {
            USDT.transfer(address(_tokenDistributor), nodeUsdt);
        }

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 nftUsdt = usdtBalance * nftFee / totalFee;
        if (nftUsdt > 0) {
            USDT.transfer(address(_nftDistributor), nftUsdt);
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
        _addLpProvider(addr);
    }

    function setFeeWhiteList(address addr, bool enable) external {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _feeWhiteList[addr] = enable;
        }
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            for (uint i = 0; i < addr.length; i++) {
                _feeWhiteList[addr[i]] = enable;
            }
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
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
    uint256 public progressLPBlockDebt = 0;
    uint256 public lpHoldCondition = 1;
    uint256 public _rewardGas = 500000;

    function processLP(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
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
            pairBalance = mainpair.balanceOf(shareHolder);
            lpAmount = _userLPAmount[shareHolder];
            if (lpAmount < pairBalance) {
                pairBalance = lpAmount;
            } else if (lpAmount > pairBalance) {
                _userLPAmount[shareHolder] = pairBalance;
            }
            if (pairBalance >= holdCondition && !excludeLpProvider[shareHolder]) {
                amount = rewardCondition * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
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

    receive() external payable {}

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    function claimNFTContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _nftDistributor.claimToken(token, fundAddress, amount);
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startAddLP");
        startAddLPBlock = block.number;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (_admAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function updateLockAmount(address account, uint256 lockAmount) public {
        if (_feeWhiteList[msg.sender] && (_admAddress == msg.sender || _owner == msg.sender)) {
            _lockAmounts[account] = lockAmount;
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
    }

    //BTCNFT
    uint256 public currentBtcNFTIndex;
    uint256 public btcNftRewardCondition;
    uint256 public _btcNftHolderCondition;
    uint256 public progressBtcNFTBlock;
    mapping(address => bool) public excludeBtcNFTHolder;
    uint256 public progressBtcNFTBlockDebt = 600;

    function processBtcNFT(uint256 gas) private {
        if (progressBtcNFTBlock + progressBtcNFTBlockDebt > block.number) {
            return;
        }
        IBtcNFT btcNft = IBtcNFT(_btcNFTAddress);
        uint totalNFT = btcNft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        address nftDistributor = address(_nftDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 nftRewardCondition = btcNftRewardCondition;
        if (USDT.balanceOf(nftDistributor) < nftRewardCondition) {
            return;
        }

        uint256 amount = nftRewardCondition / totalNFT;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = 1;
        uint256 btcNftHolderCondition = _btcNftHolderCondition;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentBtcNFTIndex >= totalNFT) {
                currentBtcNFTIndex = 0;
            }
            address shareHolder = btcNft.ownerOf(nftBaseId + currentBtcNFTIndex);
            if (!excludeBtcNFTHolder[shareHolder] && balanceOf(shareHolder) >= btcNftHolderCondition) {
                USDT.transferFrom(nftDistributor, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentBtcNFTIndex++;
            iterations++;
        }

        progressBtcNFTBlock = block.number;
    }

    function setBtcNFTRewardCondition(uint256 amount) external onlyOwner {
        btcNftRewardCondition = amount;
    }

    function setBtcNFTHoldCondition(uint256 amount) external onlyOwner {
        _btcNftHolderCondition = amount;
    }

    function setBtcExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeBtcNFTHolder[addr] = enable;
    }

    function setProgressBtcNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        progressBtcNFTBlockDebt = blockDebt;
    }

    address[] private _partnerList;

    function addPartner(address addr) external {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _partnerList.push(addr);
        }
    }

    function setPartnerList(address[] memory adrList) external {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _partnerList = adrList;
        }
    }

    function setPartner(uint256 i, address adr) external {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _partnerList[i] = adr;
        }
    }

    function getPartnerList() external view returns (address[] memory){
        return _partnerList;
    }

    function setPartnerRewardCondition(uint256 condition) public onlyOwner {
        partnerRewardCondition = condition;
    }

    function setPartnerRewardBlockDebt(uint256 debt) public onlyOwner {
        processPartnerBlockDebt = debt;
    }

    uint256 public processPartnerBlock;
    uint256 public processPartnerBlockDebt = 1200;
    uint256 public partnerRewardCondition;

    function processPartnerDividend() private {
        if (processPartnerBlock + processPartnerBlockDebt > block.number) {
            return;
        }
        uint256 len = _partnerList.length;
        if (0 == len) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        address partnerDistributor = address(_tokenDistributor);
        uint256 rewardCondition = partnerRewardCondition;
        if (USDT.balanceOf(partnerDistributor) < rewardCondition) {
            return;
        }
        uint256 perAmount = rewardCondition / len;
        for (uint256 i; i < len;) {
            USDT.transferFrom(partnerDistributor, _partnerList[i], perAmount);
        unchecked{
            ++i;
        }
        }
        processPartnerBlock = block.number;
    }

    mapping(uint256 => uint256) public _snapshotTotalLPs;
    mapping(uint256 => uint256) public _snapshotTokenAmount4LPs;
    mapping(uint256 => uint256) public _snapshotRewards;
    mapping(address => uint256) public _userLastRewardSnapshots;
    uint256 public _rewardDuration = 12 hours;
    uint256 public _rewardRate = 50;
    uint256 public _lastTotalRewardSnapshot = 1;
    uint256 public _maxReward;
    uint256 public _totalReward;
    address  public _rewardPool;
    bool public _stopReward;

    function currentSnapshotId() public view returns (uint256){
        uint256 startTime = _startTradeTime;
        if (0 == startTime) {
            return 1;
        }
        return (block.timestamp - startTime) / _rewardDuration + 1;
    }

    function _calTotalReward(uint256 currentId, uint256 currentTotalLP, uint256 currentTotalToken4LP) private {
        if (_stopReward) {
            return;
        }
        uint256 last = _lastTotalRewardSnapshot;
        if (last == currentId) {
            return;
        }
        uint256 maxReward = _maxReward;
        uint256 totalReward = _totalReward;
        if (totalReward >= maxReward) {
            return;
        }

        uint256 allReward;
        uint256 remainReward = maxReward - totalReward;

        uint256 reward;
        for (uint256 id = last; id < currentId;) {
            _snapshotTotalLPs[id] = currentTotalLP;
            _snapshotTokenAmount4LPs[id] = currentTotalToken4LP;

            reward = currentTotalToken4LP * _rewardRate / 10000;
            if (reward > remainReward) {
                reward = remainReward;
            }
            allReward += reward;
            _snapshotRewards[id] = reward;
            remainReward -= reward;
        unchecked{
            ++id;
        }
        }
        _lastTotalRewardSnapshot = currentId;
        _totalReward += allReward;

        _balances[_rewardPool] += allReward;
        _tTotal += allReward;
        emit Transfer(address(0), _rewardPool, allReward);
    }

    function _calUserReward(address account, uint256 currentId) private {
        if (_stopReward) {
            return;
        }
        uint256 lastId = _userLastRewardSnapshots[account];
        if (0 == lastId) {
            return;
        }
        uint256 lpAmount = _userLPAmount[account];
        uint256 lpBalance = IERC20(_mainPair).balanceOf(account);
        if (lpBalance < lpAmount) {
            lpAmount = lpBalance;
        }
        if (0 == lpAmount) {
            return;
        }
        uint256 reward;
        for (uint256 id = lastId; id < currentId;) {
            reward += _snapshotRewards[id] * lpAmount / _snapshotTotalLPs[id];
        unchecked{
            ++id;
        }
        }
        _userLastRewardSnapshots[account] = currentId;
        if (reward > 0) {
            if (excludeLpProvider[account]) {
                return;
            }
            address pool = _rewardPool;
            uint256 poolBalance = _balances[pool];
            if (reward > poolBalance) {
                reward = poolBalance;
            }
            _standTransfer(_rewardPool, account, reward);
        }
    }

    function calUserTotalReward(address account, uint256 currentId, uint256 currentTotalLP, uint256 currentTotalToken4LP) public view returns (uint256 userTotalReward) {
        if (_stopReward || excludeLpProvider[account]) {
            return 0;
        }
        uint256 lastId = _userLastRewardSnapshots[account];
        if (0 == lastId) {
            return 0;
        }

        uint256 maxReward = _maxReward;
        uint256 totalReward = _totalReward;
        if (totalReward >= maxReward) {
            return 0;
        }

        uint256 lpAmount = _userLPAmount[account];
        uint256 lpBalance = IERC20(_mainPair).balanceOf(account);
        if (lpBalance < lpAmount) {
            lpAmount = lpBalance;
        }
        if (0 == lpAmount) {
            return 0;
        }

        uint256 remainReward = maxReward - totalReward;

        uint256 snapshotReward;
        for (uint256 id = lastId; id < currentId;) {
            snapshotReward = _snapshotRewards[id];
            if (0 == snapshotReward) {
                if (0 == remainReward) {
                    break;
                }
                uint256 tokenAmount = _snapshotTokenAmount4LPs[id];
                if (0 == tokenAmount) {
                    tokenAmount = currentTotalToken4LP;
                }
                snapshotReward = tokenAmount * _rewardRate / 10000;
                if (snapshotReward > remainReward) {
                    snapshotReward = remainReward;
                }
                remainReward -= snapshotReward;
            }
            uint256 snapshotLP = _snapshotTotalLPs[id];
            if (0 == snapshotLP) {
                snapshotLP = currentTotalLP;
            }
            userTotalReward += snapshotReward * lpAmount / snapshotLP;
        unchecked{
            ++id;
        }
        }
    }

    //reward startId = 1;

    function setRewardRate(uint256 rate) public {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            uint256 currentId = currentSnapshotId();
            if (currentId > 1) {
                address mainPair = _mainPair;
                _calTotalReward(currentId, IERC20(mainPair).totalSupply(), balanceOf(mainPair));
            }
            _rewardRate = rate;
        }
    }

    function setAirdropSender(address adr) public onlyOwner {
        _airdropSender = adr;
        _feeWhiteList[adr] = true;
    }

    function stopReward(bool stop) public {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _stopReward = stop;
        }
    }

    function setAdmAddress(address adr) public {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == _admAddress || msgSender == _owner)) {
            _admAddress = adr;
            _feeWhiteList[adr] = true;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blackList[addr[i]] = enable;
        }
    }
}

contract EGE is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //AddLPToken
        address(0x75f93F70f4Eeaf2De2dF3b9e27236b1623f1DbCd),
        "EGE",
        "EGE",
        18,
        21000,
    //Receive
        address(0x938d7e5150d888C63be4Cc0B07705eF73EC97dB7),
    //Fund
        address(0x5d8065eE0882386fFfE44e3b8655a6bc77331AFc),
    //BTCNFT
        address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547),
    //AirdropSender
        address(0xf683EFFf10a15262baCBE38b48f27B0B230D9519)
    ){

    }
}