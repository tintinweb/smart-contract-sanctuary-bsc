/**
 *Submitted for verification at BscScan.com on 2022-07-13
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
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    mapping(address => bool) public _swapPairList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address public _fist;
    TokenDistributor public _tokenDistributor;

    uint256 public _lpFee = 100;
    uint256 public _lpDividendFee = 200;
    uint256 public _destroyFee = 0;

    IERC20 public _fistPair;

    uint256 public _minTotal;

    uint256 public startAddLPBlock;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouteAddress, address FistAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        address fist = FistAddress;

        _swapRouter = swapRouter;
        _fist = fist;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address fistPair = swapFactory.createPair(address(this), fist);
        _fistPair = IERC20(fistPair);

        _swapPairList[fistPair] = true;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(fist).approve(address(swapRouter), MAX);

        uint256 tTotal = Supply * 10 ** Decimals;
        _tTotal = tTotal;

        _balances[ReceiveAddress] = tTotal;
        emit Transfer(address(0), ReceiveAddress, tTotal);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        numTokensSellToFund = tTotal / 5800;
        _tokenDistributor = new TokenDistributor(fist);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;

        lpRewardCondition = 1 * 10 ** IERC20(fist).decimals();

        _minTotal = 580 * 10 ** Decimals;
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
        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 5) {
                    _funTransfer(from, to, amount);
                    return;
                }

                takeFee = true;

                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }

            if (_swapPairList[from]) {
                addLpProvider(to);
            } else {
                addLpProvider(from);
            }
        }
        _tokenTransfer(from, to, amount, takeFee);

        if (
            from != address(this)
            && startTradeBlock > 0) {
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 taxAmount = tAmount * (_lpFee + _lpDividendFee) / 10000;
            feeAmount += taxAmount;
            _takeTransfer(
                sender,
                address(this),
                taxAmount
            );
            uint256 destroyAmount = tAmount * _destroyFee / 10000;
            uint256 total = totalSupply();
            uint256 maxDestroyAmount;
            if (total > _minTotal) {
                maxDestroyAmount = total - _minTotal;
            }
            if (destroyAmount > maxDestroyAmount) {
                destroyAmount = maxDestroyAmount;
            }
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(
                    sender,
                    address(0x000000000000000000000000000000000000dEaD),
                    destroyAmount
                );
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpDividendFee = _lpDividendFee;
        uint256 lpFee = _lpFee;
        address fist = _fist;

        uint256 txFee = lpDividendFee + lpFee;
        txFee += txFee;
        uint256 lpAmount = tokenAmount * lpFee / txFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = fist;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 FIST = IERC20(fist);
        uint256 fistBalance = FIST.balanceOf(tokenDistributor);
        FIST.transferFrom(tokenDistributor, address(this), fistBalance);
        txFee -= lpFee;
        if (lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this),
                fist,
                lpAmount,
                fistBalance * lpFee / txFee,
                0,0,
                fundAddress,
                block.timestamp
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

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount;
    }

    function setFee(uint256 lpDividendFee, uint256 lpFee, uint256 destroyFee) external onlyOwner {
        _lpDividendFee = lpDividendFee;
        _lpFee = lpFee;
        _destroyFee = destroyFee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyFunder {
        IERC20(token).transfer(fundAddress, amount);
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
    uint256 public _progressBlockDebt = 20;

    function processLP(uint256 gas) private {
        if (progressLPBlock + _progressBlockDebt > block.number) {
            return;
        }
        IERC20 fistPair = _fistPair;
        uint totalPair = fistPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(this));
        if (fistBalance < lpRewardCondition) {
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
            pairBalance = fistPair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = fistBalance * pairBalance / totalPair;
                if (amount > 0) {
                    FIST.transfer(shareHolder, amount);
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

    function setMinTotal(uint256 total) external onlyFunder {
        _minTotal = total * 10 ** _decimals;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }
}

contract Token is AbsToken {
    constructor() AbsToken(
        //路由地址
        address(0x1B6C9c20693afDE803B27F8782156c0f892ABC2d),
    //FIST
        address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A),
    //名称
        "QL Token",
    //符号
        "QL",
    //精度
        8,
    //总量
        5800,
    //营销钱包
        address(0x0F7c397075455d8F583a9D42Aaa45D7520504413),
    //代币接收地址
        address(0x16FE4e30CEA0786C0602B10B9466955B6F4d377f)
    ){

    }
}