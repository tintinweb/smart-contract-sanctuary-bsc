/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

interface IRelationShip {
    function _inviter(address account) external view returns (address);
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

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFee = 3;
    uint256 public _sellFee = 5;
    uint256 public _fundFee = 2;

    uint256 public startTradeBlock;
    address public _mainPair;

    mapping(address => address) public _invitor;

    uint256 public _limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;

        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;

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

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 10 * 10 ** IERC20(USDTAddress).decimals();

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
        if (!_swapPairList[from] && !_swapPairList[to]) {
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to] && amount > 0) {
                _invitor[to] = from;
            }
        }

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if (_feeWhiteList[from] || _feeWhiteList[to]) {
            _tokenTransfer(from, to, amount);
            if (_swapPairList[to]) {
                addLpProvider(from);
            }
            return;
        }

        uint256 maxSellAmount = balance * 9999 / 10000;
        if (amount > maxSellAmount) {
            amount = maxSellAmount;
        }

        if (_swapPairList[from]) {
            require(0 < startTradeBlock, "!Trading");
            _buyToken(to, from, amount);
        } else if (_swapPairList[to]) {
            if (inSwap) {
                _tokenTransfer(from, to, amount);
                return;
            }
            require(0 < startTradeBlock, "!Trading");
            _sellToken(from, to, amount);
            addLpProvider(from);
        } else {
            _tokenTransfer(from, to, amount);
        }
        processLP(500000);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function _buyToken(address account, address pair, uint256 amount) private {
        _balances[pair] = _balances[pair] - amount;
        uint256 feeAmount = amount * _buyFee / 100;
        uint256 fundAmount = feeAmount;
        if (feeAmount > 0) {
            address invitor = _invitor[account];
            if (address(0) != invitor) {
                uint256 inviteAmount = feeAmount * 2 / 3;
                fundAmount -= inviteAmount;
                _takeTransfer(pair, invitor, inviteAmount);

                invitor = _invitor[invitor];
                if (address(0) != invitor) {
                    inviteAmount = feeAmount - inviteAmount;
                    fundAmount = 0;
                    _takeTransfer(pair, invitor, inviteAmount);
                }
            }
            if (fundAmount > 0) {
                _takeTransfer(pair, fundAddress, fundAmount);
            }
        }
        _takeTransfer(pair, account, amount - feeAmount);
    }

    function _sellToken(address account, address pair, uint256 amount) private lockTheSwap {
        _balances[account] = _balances[account] - amount;

        uint256 sellFee = _sellFee;
        uint256 feeAmount = amount * sellFee / 100;
        if (feeAmount > 0) {
            _takeTransfer(account, address(this), feeAmount);

            address usdt = _usdt;
            address tokenDistributor = address(_tokenDistributor);
            IERC20 USDT = IERC20(usdt);
            uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdt;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                feeAmount,
                0,
                path,
                tokenDistributor,
                block.timestamp
            );
            usdtBalance = USDT.balanceOf(tokenDistributor) - usdtBalance;
            uint256 fundAmount = usdtBalance * _fundFee / sellFee;
            USDT.transferFrom(tokenDistributor, fundAddress, fundAmount);
        }

        _takeTransfer(account, pair, amount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        _buyFee = buyFee;
        _sellFee = sellFee;
    }

    function setLimitAmount(uint256 amount) external onlyFunder {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setFundFee(uint256 fundFee) external onlyFunder {
        _fundFee = fundFee;
    }

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
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

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    mapping(address => bool) excludeLpProvider;

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

    uint256 private currentIndex;
    uint256 public lpRewardCondition;
    uint256 private progressLPTime;

    function processLP(uint256 gas) private {
        uint256 timestamp = block.timestamp;
        if (progressLPTime + 300 > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        address tokenDistributor = address(_tokenDistributor);

        IERC20 token = IERC20(_usdt);
        uint256 tokenBalance = token.balanceOf(tokenDistributor);
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
                    token.transferFrom(tokenDistributor, shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPTime = timestamp;
    }

    function setMainPair(address pair) external onlyFunder {
        _mainPair = pair;
    }

    function setLPRewardCondition(uint256 amount) external onlyFunder {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyFunder {
        excludeLpProvider[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract A6 is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "A6 Token",
        "A6",
        9,
        6868,
        address(0x4ecb196c6BF588F20330eB6FbE1D8e15e5f383aD),
        address(0x4ecb196c6BF588F20330eB6FbE1D8e15e5f383aD)
    ){

    }
}