/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-05
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

    function feeTo() external view returns (address);
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

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IDividendPool {
    function addTokenReward(uint256 rewardAmount) external;

    function addLPTokenReward(uint256 rewardAmount) external;
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lockLPAmount;
        uint256 lpAmount;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;

    uint256 public _buyLargeNFTFee = 50;
    uint256 public _buyLittleNFTFee = 50;
    uint256 public _buyLPDividendFee = 100;

    uint256 public _sellLPDividendFee = 200;

    uint256 public startTradeBlock;
    address public immutable _usdt;
    address public immutable _mainPair;

    TokenDistributor public immutable _littleNFTRewardDistributor;

    address public _largeNFTAddress;
    address public _littleNFTAddress;

    uint256 public _releaseLPStartTime;
    uint256 public _releaseLPDailyDuration = 1 days;
    uint256 public _releaseLPDailyRate = 100;

    address public _lpDividendPool;
    uint256 public _limitAmount;

    mapping(address => uint256) private _nftReward;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address UsdtAddress,
        address LargeNFTAddress, address LittleNFTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, uint256 LimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _largeNFTAddress = LargeNFTAddress;
        _littleNFTAddress = LittleNFTAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = UsdtAddress;
        IERC20(UsdtAddress).approve(address(swapRouter), MAX);
        address pair = swapFactory.createPair(address(this), UsdtAddress);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;

        _tokenDistributor = new  TokenDistributor(UsdtAddress);
        _littleNFTRewardDistributor = new  TokenDistributor(UsdtAddress);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(_tokenDistributor)] = true;
        _feeWhiteList[address(_littleNFTRewardDistributor)] = true;

        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeNFTHolder[_mainPair] = true;
        nftRewardCondition = 10 * tokenUnit;

        _limitAmount = LimitAmount * tokenUnit;
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = _balances[from];
        require(balance >= amount, "BNE");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 6);
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        uint256 addLPLiquidity;
        if (to == _mainPair) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                UserInfo storage userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                (uint256 lpAmount, uint256 lpLockAmount, uint256 releaseAmount, uint256 lpBalance) = getUserInfo(to);
                if (lpLockAmount > 0) {
                    require(lpBalance + releaseAmount >= lpLockAmount, "rq Lock");
                }
                require(lpAmount >= removeLPLiquidity, ">userLP");
                _userInfo[to].lpAmount -= removeLPLiquidity;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!T");
                takeFee = true;
                if (addLPLiquidity > 0) {
                    takeFee = false;
                }
                if (removeLPLiquidity > 0) {
                    takeFee = false;
                }
            }
        }

        if (takeFee && block.number < startTradeBlock + 3) {
            _killTransfer(from, to, amount);
            return;
        }

        _tokenTransfer(from, to, amount, takeFee);

        uint256 limitAmount = _limitAmount;
        if (limitAmount > 0) {
            //Hold Limit
            if (!_feeWhiteList[to] && !_swapPairList[to]) {
                require(limitAmount >= balanceOf(to), "Limit");
            }
        }

        if (takeFee) {
            uint256 rewardGas = _rewardGas;
            uint256 blockNum = block.number;
            processLargeNFTReward(rewardGas);
            if (processLargeNFTBlock != blockNum) {
                processLittleNFTReward(rewardGas);
            }
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
        address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(_mainPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) /
            (balanceOf(_mainPair) - amount - 1);
        }
    }

    function _killTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            address(0x000000000000000000000000000000000000dEaD),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] -= tAmount;

        uint256 feeAmount;
        if (takeFee) {
            if (_swapPairList[sender]) {//Buy
                uint256 largeNFTFeeAmount = tAmount * _buyLargeNFTFee / 10000;
                if (largeNFTFeeAmount > 0) {
                    feeAmount += largeNFTFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), largeNFTFeeAmount);
                }
                uint256 littleNFTFeeAmount = tAmount * _buyLittleNFTFee / 10000;
                if (littleNFTFeeAmount > 0) {
                    feeAmount += littleNFTFeeAmount;
                    _takeTransfer(sender, address(_littleNFTRewardDistributor), littleNFTFeeAmount);
                }
                uint256 lpDividendFeeAmount = tAmount * _buyLPDividendFee / 10000;
                if (lpDividendFeeAmount > 0) {
                    feeAmount += lpDividendFeeAmount;
                    address lpDividendPool = _lpDividendPool;
                    _takeTransfer(sender, lpDividendPool, lpDividendFeeAmount);
                    IDividendPool(lpDividendPool).addTokenReward(lpDividendFeeAmount);
                }
            } else if (_swapPairList[recipient]) {//Sell
                uint256 lpFeeAmount = tAmount * _sellLPDividendFee / 10000;
                if (lpFeeAmount > 0) {
                    feeAmount += lpFeeAmount;
                    _takeTransfer(sender, address(this), lpFeeAmount);
                    if (!inSwap) {
                        swapTokenForFund(lpFeeAmount);
                    }
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 lpAmount = tokenAmount / 2;

        address distributor = address(_tokenDistributor);
        address usdt = _usdt;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(distributor);
        USDT.transferFrom(distributor, address(this), usdtBalance);
        if (usdtBalance > 0 && lpAmount > 0) {
            address lpDividendPool = _lpDividendPool;
            (, , uint liquidity) = _swapRouter.addLiquidity(
                usdt,
                address(this),
                usdtBalance,
                lpAmount,
                0,
                0,
                lpDividendPool,
                block.timestamp
            );
            IDividendPool(lpDividendPool).addLPTokenReward(liquidity);
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

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimContractToken(address contractAddr, address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            TokenDistributor(contractAddr).claimToken(token, fundAddress, amount);
        }
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _releaseLPStartTime = block.timestamp;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userInfo[account].lpAmount = lpAmount;
        }
    }

    function updateLPLockAmount(address account, uint256 lockAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userInfo[account].lockLPAmount = lockAmount;
        }
    }

    function initLPLockAmounts(address[] memory accounts, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            uint256 len = accounts.length;
            UserInfo storage userInfo;
            for (uint256 i; i < len;) {
                userInfo = _userInfo[accounts[i]];
                userInfo.lpAmount = lpAmount;
                userInfo.lockLPAmount = lpAmount;
            unchecked{
                ++i;
            }
            }
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpLockAmount, uint256 releaseAmount, uint256 lpBalance
    ) {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;

        lpLockAmount = userInfo.lockLPAmount;
        if (_releaseLPStartTime > 0) {
            uint256 times = (block.timestamp - _releaseLPStartTime) / _releaseLPDailyDuration;
            releaseAmount = lpLockAmount * (1 + times) * _releaseLPDailyRate / 10000;
            if (releaseAmount > lpLockAmount) {
                releaseAmount = lpLockAmount;
            }
        }
        lpBalance = IERC20(_mainPair).balanceOf(account);
    }

    function setLargeNFTAddress(address adr) external onlyOwner {
        _largeNFTAddress = adr;
    }

    function setLittleNFTAddress(address adr) external onlyOwner {
        _littleNFTAddress = adr;
    }

    uint256 public nftRewardCondition;
    mapping(address => bool) public excludeNFTHolder;

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    //LargeNFT
    uint256 public currentLargeNFTIndex;
    uint256 public processLargeNFTBlock;
    uint256 public processLargeNFTBlockDebt = 100;

    function processLargeNFTReward(uint256 gas) private {
        if (processLargeNFTBlock + processLargeNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_largeNFTAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_tokenDistributor);
        if (balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        address shareHolder;
        uint256 limitAmount = _limitAmount;
        uint256 shareHolderBalance;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentLargeNFTIndex >= totalNFT) {
                currentLargeNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(1 + currentLargeNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                if (0 == limitAmount || _feeWhiteList[shareHolder]) {
                    _tokenTransfer(sender, shareHolder, amount, false);
                    _nftReward[shareHolder] += amount;
                } else {
                    shareHolderBalance = balanceOf(shareHolder);
                    if (shareHolderBalance + amount <= limitAmount) {
                        _tokenTransfer(sender, shareHolder, amount, false);
                        _nftReward[shareHolder] += amount;
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLargeNFTIndex++;
            iterations++;
        }

        processLargeNFTBlock = block.number;
    }

    function setProcessLargeNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processLargeNFTBlockDebt = blockDebt;
    }

    //LittleNFT
    uint256 public currentLittleNFTIndex;
    uint256 public processLittleNFTBlock;
    uint256 public processLittleNFTBlockDebt = 0;

    function processLittleNFTReward(uint256 gas) private {
        if (processLittleNFTBlock + processLittleNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_littleNFTAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_littleNFTRewardDistributor);
        if (balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        address shareHolder;
        uint256 limitAmount = _limitAmount;
        uint256 shareHolderBalance;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentLittleNFTIndex >= totalNFT) {
                currentLittleNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(1 + currentLittleNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                if (0 == limitAmount || _feeWhiteList[shareHolder]) {
                    _tokenTransfer(sender, shareHolder, amount, false);
                    _nftReward[shareHolder] += amount;
                } else {
                    shareHolderBalance = balanceOf(shareHolder);
                    if (shareHolderBalance + amount <= limitAmount) {
                        _tokenTransfer(sender, shareHolder, amount, false);
                        _nftReward[shareHolder] += amount;
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLittleNFTIndex++;
            iterations++;
        }

        processLittleNFTBlock = block.number;
    }

    function setProcessLittleNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processLittleNFTBlockDebt = blockDebt;
    }

    function setDailyDuration(uint256 d) external onlyOwner {
        _releaseLPDailyDuration = d;
    }

    function setReleaseLPDailyRate(uint256 rate) external onlyOwner {
        _releaseLPDailyRate = rate;
    }

    function setLPDividendPool(address pool) external onlyOwner {
        _lpDividendPool = pool;
        _feeWhiteList[pool] = true;
    }

    function minusLPAmount(address account, uint256 amount) public {
        require(_lpDividendPool == msg.sender, "rq DividendPool");
        (uint256 lpAmount, uint256 lpLockAmount, uint256 releaseAmount, uint256 lpBalance) = getUserInfo(account);
        if (lpLockAmount > 0) {
            require(lpBalance + releaseAmount >= lpLockAmount, "rq Lock");
        }
        require(lpAmount >= amount, ">userLP");
        _userInfo[account].lpAmount -= amount;
    }

    function addLPAmount(address account, uint256 amount) public {
        require(_lpDividendPool == msg.sender, "rq DividendPool");
        _userInfo[account].lpAmount += amount;
    }

    function getUserNFTInfo(address account) public view returns (
        uint256 tokenBalance, uint256 nftReward,
        uint256 LargeNFTBalance, uint256 littleNFTBalance
    ){
        tokenBalance = balanceOf(account);
        nftReward = _nftReward[account];
        LargeNFTBalance = INFT(_largeNFTAddress).balanceOf(account);
        littleNFTBalance = INFT(_littleNFTAddress).balanceOf(account);
    }

    function getLPInfo() public view returns (
        uint256 totalLP, uint256 lpUAmount
    ){
        totalLP = IERC20(_mainPair).totalSupply();
        lpUAmount = IERC20(_usdt).balanceOf(_mainPair) * 2;
    }
}

contract ZM is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //ShareHolder NFT
        address(0x956e830F3a038C2D550fEd30345f53B11eeB0333),
    //Studio NFT
        address(0x0b32466471E897488e451E60f040727d61Bbee56),
        "ZM",
        "ZM",
        18,
        7999,
    //Receive
        address(0x687e21CF240c2C2B91F160620f69673a92938358),
    //Fund
        address(0x687e21CF240c2C2B91F160620f69673a92938358),
    //Limit
        10
    ){

    }
}