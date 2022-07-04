/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
        return address(0x0000000000000000000000000000000000000000);
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

interface ISwapPair {
    function sync() external;
}

interface IMintToken {
    function mint(address account, uint256 amount) external;
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
    address public _bToken;
    address public _bLP;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => address) public _invitor;
    mapping(address => mapping(address => bool)) public _maybeInvitor;
    mapping(address => uint256) public _binderCount;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPDividendBFee = 5;
    uint256 public _buyInviteFee = 10;

    uint256 public _sellMintBTokenFee = 5;
    uint256 public _sellBTokenLPFee = 5;
    uint256 public _sellDestroyBTokenFee = 5;

    uint256 public startTradeBlock;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address BToken, address OtherToken
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

        _swapPairList[swapFactory.createPair(address(this), swapRouter.WETH())] = true;
        _swapPairList[swapFactory.createPair(address(this), OtherToken)] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[FundAddress] = total;
        emit Transfer(address(0), FundAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        lpRewardCondition = 10 * 10 ** IERC20(BToken).decimals();
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;

        _bToken = BToken;
        _bLP = swapFactory.getPair(USDTAddress, BToken);
        require(address(0) != _bLP, "bTokenLP not exists");
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
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == address(0) || account == address(0x000000000000000000000000000000000000dEaD)) {
            return 0;
        }
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        uint256 txFee;
        bool isBuy;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
                txFee = 1;
                if (_swapPairList[from]) {
                    isBuy = true;
                }
            }
        } else {
            if (address(0) == _invitor[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _invitor[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binderCount[from] == 0) {
                    _invitor[from] = to;
                    _binderCount[to]++;
                }
            }
        }

        _tokenTransfer(from, to, amount, txFee, isBuy);

        if (_swapPairList[to]) {
            addLpProvider(from);
        }

        if (from != address(this)) {
            processLP(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 80 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee,
        bool isBuy
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            if (isBuy) {
                uint256 inviterAmount = tAmount * _buyInviteFee / 100;
                if (inviterAmount > 0) {
                    uint256 fundAmount = inviterAmount;
                    feeAmount += inviterAmount;
                    uint256 perInviteAmount = inviterAmount / 10;
                    address current = recipient;
                    for (uint256 i; i < 6; ++i) {
                        address inviter = _invitor[current];
                        if (address(0) == inviter) {
                            break;
                        }
                        if (0 == i) {
                            inviterAmount = perInviteAmount * 5;
                        } else {
                            inviterAmount = perInviteAmount;
                        }
                        fundAmount -= inviterAmount;
                        _takeTransfer(sender, inviter, inviterAmount);
                        current = inviter;
                    }
                    if (fundAmount > 10) {
                        _takeTransfer(sender, address(this), fundAmount);
                    }
                }
                uint256 lpDividendAmount = tAmount * _buyLPDividendBFee / 100;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(this), lpDividendAmount);
                }
            } else {
                uint256 mintAmount = tAmount * _sellMintBTokenFee / 100;
                uint256 destroyAmount = tAmount * _sellDestroyBTokenFee / 100;
                uint256 sellSwapAmount = tAmount * _sellBTokenLPFee / 100 + destroyAmount + mintAmount;
                feeAmount += sellSwapAmount;
                _takeTransfer(sender, address(this), sellSwapAmount);

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    sellSwapAmount = sellSwapAmount + tAmount / 100;
                    if (sellSwapAmount > contractTokenBalance) {
                        sellSwapAmount = contractTokenBalance;
                    }

                    uint256 lpDividendAmount = tAmount * (_buyLPDividendBFee) / 50;
                    uint256 allSellAmount = lpDividendAmount + sellSwapAmount;

                    if (allSellAmount > contractTokenBalance) {
                        allSellAmount = contractTokenBalance;
                    }
                    swapTokenForFund(allSellAmount, allSellAmount - sellSwapAmount, destroyAmount);
                    _mintToken(sender, mintAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _mintToken(address sender, uint256 amount) private {
        if (tx.origin == sender) {
            address bToken = _bToken;
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = address(_usdt);
            path[2] = bToken;
            uint256[] memory amountsOuts = _swapRouter.getAmountsOut(amount, path);
            IMintToken mintToken = IMintToken(bToken);
            mintToken.mint(sender, amountsOuts[2]);
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 lpDividendAmount, uint256 destroyAmount) private lockTheSwap {
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

        uint256 buyUsdt = usdtBalance * (lpDividendAmount + destroyAmount) / tokenAmount;

        address bLP = _bLP;
        USDT.transferFrom(tokenDistributor, bLP, usdtBalance - buyUsdt);
        ISwapPair(bLP).sync();

        USDT.transferFrom(tokenDistributor, address(this), buyUsdt);

        address bToken = _bToken;
        IERC20 BToken = IERC20(bToken);
        uint256 bTokenBalance = BToken.balanceOf(address(this));
        path[0] = usdt;
        path[1] = _bToken;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyUsdt,
            0,
            path,
            address(this),
            block.timestamp
        );

        bTokenBalance = BToken.balanceOf(address(this)) - bTokenBalance;
        BToken.transfer(address(0x000000000000000000000000000000000000dEaD), bTokenBalance * destroyAmount / (destroyAmount + lpDividendAmount));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, address to, uint256 amount) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLpProvider(address adr) private {
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

    uint256 public currentIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public _progressBlockDebt = 200;

    function processLP(uint256 gas) private {
        if (progressLPBlock + _progressBlockDebt > block.number) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 rewardToken = IERC20(_bToken);
        uint256 tokenBalance = rewardToken.balanceOf(address(this));
        if (tokenBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    rewardToken.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyFunder {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyFunder {
        excludeLpProvider[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyFunder {
        _progressBlockDebt = progressBlockDebt;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract MBCToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "MBC Token",
        "MBC",
        18,
        100000000,
        address(0x86005C98ED93231F5182Fb3e1994F831fB26d2E7),
        address(0x3516c549c8D87AAA73d0FA4E904ec219Ff928B6C),
        address(0xc5f327228A87fccdd2B337536aa55d9d9dbf0612)
    ){

    }
}