/**
 *Submitted for verification at BscScan.com on 2022-05-27
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

    address private fundAddress;
    address private gameAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    mapping(address => address) private _invitor;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 private _buyFee = 10;
    uint256 private _buyHoldLPDividendFee = 5;

    uint256 private _sellGameFee = 6;
    uint256 private _sellDeadFee = 1;
    uint256 private _sellLPFee = 3;

    uint256 public startTradeBlock;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address GameAddress, address RouterAddress, address USDTAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(usdt).approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[FundAddress] = total;
        emit Transfer(address(0), FundAddress, total);

        fundAddress = FundAddress;
        gameAddress = GameAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[GameAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(usdt);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
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

    function totalSupply() external view override returns (uint256) {
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
        uint256 txFee;
        bool isBuy;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    require(_feeWhiteList[from], "!Trading");
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock || block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (!inSwap && _swapPairList[to]) {
                    uint256 contractTokenBalance = balanceOf(address(_tokenDistributor));
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = amount * _sellLPFee / 100;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }

                txFee = 1;
                if (_swapPairList[from]) {
                    isBuy = true;
                }
            }
        } else {
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to]) {
                _invitor[to] = from;
            }
        }

        if (txFee > 0 && !isBuy) {
            uint256 maxSellAmount = balanceOf(from) * 90 / 100;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
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
        uint256 feeAmount = tAmount * 75 / 100;
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
                feeAmount = tAmount * _buyFee / 100;
                uint256 taxAmount = feeAmount;
                address current = recipient;

                uint256 inviterAmount;
                uint256 perInviteAmount = tAmount / 200;
                for (uint256 i; i < 5; ++i) {
                    address inviter = _invitor[current];
                    if (address(0) == inviter) {
                        break;
                    }
                    if (0 == i) {
                        inviterAmount = perInviteAmount * 4;
                    } else if (3 > i) {
                        inviterAmount = perInviteAmount * 2;
                    } else {
                        inviterAmount = perInviteAmount;
                    }
                    taxAmount -= inviterAmount;
                    _takeTransfer(sender, inviter, inviterAmount);
                    current = inviter;
                }

                uint256 buyHoldLPDividendAmount = tAmount * _buyHoldLPDividendFee / 100;
                taxAmount -= buyHoldLPDividendAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    buyHoldLPDividendAmount
                );

                if (taxAmount > 0) {
                    _takeTransfer(
                        sender,
                        address(_tokenDistributor),
                        taxAmount
                    );
                }
            } else {
                uint256 sellLPAmount = tAmount * _sellLPFee / 100;
                if (sellLPAmount > 0) {
                    feeAmount += sellLPAmount;
                    _takeTransfer(
                        sender,
                        address(_tokenDistributor),
                        sellLPAmount
                    );
                }

                uint256 sellDeadAmount = tAmount * _sellDeadFee / 100;
                if (sellDeadAmount > 0) {
                    feeAmount += sellDeadAmount;
                    _takeTransfer(
                        sender,
                        address(0x000000000000000000000000000000000000dEaD),
                        sellDeadAmount
                    );
                }

                uint256 sellGameAmount = tAmount * _sellGameFee / 100;
                if (sellGameAmount > 0) {
                    feeAmount += sellGameAmount;
                    _takeTransfer(
                        sender,
                        gameAddress,
                        sellGameAmount
                    );
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        _tokenTransfer(address(_tokenDistributor), address(this), tokenAmount, 0, false);

        uint256 lpAmount = tokenAmount / 2;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_usdt);
        uint256 lpUsdt = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);

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

    function setBuyFee(uint256 buyFee, uint256 buyLPFee) external onlyOwner {
        _buyFee = buyFee;
        _buyHoldLPDividendFee = buyLPFee;
    }

    function setSellFee(uint256 sellGameFee, uint256 sellDeadFee, uint256 sellLPFee) external onlyOwner {
        _sellGameFee = sellGameFee;
        _sellDeadFee = sellDeadFee;
        _sellLPFee = sellLPFee;
    }

    function startTrade() external onlyOwner {
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

    function getInviter(address account) external view returns (address){
        return _invitor[account];
    }

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    mapping(address => bool) excludeLpProvider;

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    function processLP(uint256 gas) private {
        if (progressLPBlock + 28800 > block.number) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 tokenBalance = balanceOf(address(this));
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
                    _tokenTransfer(address(this), shareHolder, amount, 0, false);
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
        lpRewardCondition = amount * 10 ** _decimals;
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

contract DotaToken is AbsToken {
    constructor() AbsToken(
        "Defense of the Ancients",
        "DoTA",
        18,
        9900000000,
        address(0xd49d0Ff5498b3b9D2A564D368bDCe31b9893173F),
        address(0xca5C1D3D475922DAFeeB91F5159449C598DC0aD7),
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955)
    ){

    }
}