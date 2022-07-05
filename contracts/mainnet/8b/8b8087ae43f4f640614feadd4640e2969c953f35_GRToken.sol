/**
 *Submitted for verification at BscScan.com on 2022-07-05
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

    mapping(address => bool) public _swapPairList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address public _osk;
    TokenDistributor public _tokenDistributor;

    uint256 public _buyInviteFee = 200;
    uint256 public _buyLPDividendFee = 200;

    uint256 public _sellLPFee = 200;
    uint256 public _sellFundFee = 100;
    uint256 public _sellDestroyFee = 100;

    uint256 public _transferFee = 400;

    address public _oskPair;

    uint256 public _invitorHoldCondition;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouteAddress, address OSKAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);

        _swapRouter = swapRouter;
        _osk = OSKAddress;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address oskPair = swapFactory.createPair(address(this), OSKAddress);
        _oskPair = oskPair;

        _swapPairList[oskPair] = true;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(OSKAddress).approve(address(swapRouter), MAX);

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

        numTokensSellToFund = 100 * 10 ** Decimals;
        _tokenDistributor = new TokenDistributor(OSKAddress);

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;

        rewardCondition = 100 * 10 ** IERC20(OSKAddress).decimals();
        _holdCondition = 10 * 10 ** Decimals;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");
                if (block.number < startTradeBlock + 3) {
                    _fundTransfer(from, to, amount, 9000);
                    return;
                }
            }

            if (_swapPairList[from]) {
                addHolder(to);
            } else {
                addHolder(from);
            }
        } else {
            if (0 == balanceOf(to) && amount > 0) {
                _bindInvitor(to, from);
            }
        }
        _tokenTransfer(from, to, amount);

        if (
            from != address(this)
            && startTradeBlock > 0) {
            processHoldReward(500000);
        }
    }

    function _fundTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 10000;
        if (feeAmount > 0) {
            _takeTransfer(
                sender,
                fundAddress,
                feeAmount
            );
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_feeWhiteList[sender] || _feeWhiteList[recipient]) {
            _fundTransfer(sender, recipient, tAmount, 0);
            return;
        }

        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (_swapPairList[sender]) {//Buy
            uint256 inviteAmount = tAmount * _buyInviteFee / 10000;
            if (inviteAmount > 0) {
                feeAmount += inviteAmount;
                address invitor = _inviter[recipient];
                if (address(0) != invitor && (0 == _invitorHoldCondition || balanceOf(invitor) >= _invitorHoldCondition)) {
                    _takeTransfer(sender, invitor, inviteAmount);
                } else {
                    _takeTransfer(sender, fundAddress, inviteAmount);
                }
            }

            uint256 lpDividendAmount = tAmount * _buyLPDividendFee / 10000;
            if (lpDividendAmount > 0) {
                feeAmount += lpDividendAmount;
                _takeTransfer(sender, address(this), lpDividendAmount);
            }
        } else if (_swapPairList[recipient]) {//Sell
            uint256 sellLPAmount = tAmount * _sellLPFee / 10000;
            if (sellLPAmount > 0) {
                feeAmount += sellLPAmount;
                _takeTransfer(sender, address(this), sellLPAmount);
            }

            uint256 fundAmount = tAmount * _sellFundFee / 10000;
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount);
            }

            uint256 destroyAmount = tAmount * _sellDestroyFee / 10000;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }

            if (!inSwap) {
                uint256 thisBalance = balanceOf(address(this));
                if (thisBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        } else {//Transfer
            uint256 transferFeeAmount = tAmount * _transferFee / 10000;
            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, fundAddress, transferFeeAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpDividendFee = _buyLPDividendFee;
        uint256 lpFee = _sellLPFee;
        address osk = _osk;

        uint256 txFee = lpDividendFee + lpFee;
        txFee += txFee;
        uint256 lpAmount = tokenAmount * lpFee / txFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = osk;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 OSK = IERC20(osk);
        uint256 oskBalance = OSK.balanceOf(tokenDistributor);
        OSK.transferFrom(tokenDistributor, address(this), oskBalance);
        txFee -= lpFee;
        if (lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this),
                osk,
                lpAmount,
                oskBalance * lpFee / txFee,
                0, 0,
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

    function setSellFee(uint256 lpFee, uint256 fundFee, uint256 destroyFee) external onlyOwner {
        _sellLPFee = lpFee;
        _sellFundFee = fundFee;
        _sellDestroyFee = destroyFee;
    }

    function setTransferFee(uint256 transferFee) external onlyOwner {
        _transferFee = transferFee;
    }

    function setBuyFee(uint256 inviteFee, uint256 lpDividendFee) external onlyOwner {
        _buyInviteFee = inviteFee;
        _buyLPDividendFee = lpDividendFee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    receive() external payable {}

    function claimBalance(uint256 amount, address to) external onlyFunder {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
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
    uint256 public _holdCondition;
    uint256 public rewardCondition;
    uint256 public progressBlock;
    uint256 public _progressBlockDebt = 200;

    function processHoldReward(uint256 gas) private {
        if (progressBlock + _progressBlockDebt > block.number) {
            return;
        }

        uint totalBalance = totalSupply();

        IERC20 OSK = IERC20(_osk);
        uint256 oskBalance = OSK.balanceOf(address(this));
        if (oskBalance < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 holdBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = _holdCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            holdBalance = balanceOf(shareHolder);
            if (holdBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = oskBalance * holdBalance / totalBalance;
                if (amount > 0) {
                    OSK.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressBlock = block.number;
    }

    function setRewardCondition(uint256 amount) external onlyFunder {
        rewardCondition = amount;
    }

    function setHoldCondition(uint256 amount) external onlyFunder {
        _holdCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyFunder {
        _progressBlockDebt = progressBlockDebt;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyFunder {
        _invitorHoldCondition = amount;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    function bindInvitor(address invitor) public {
        address account = msg.sender;
        _bindInvitor(account, invitor);
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

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }
}

contract GRToken is AbsToken {
    constructor() AbsToken(
        address(0xFfBe36E6edd8422351b22AFf5ac8121dB556fb3F),
        address(0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da),
    //名称
        "GR",
    //符号
        "GR",
    //精度
        8,
    //总量
        299900,
    //营销钱包
        address(0x9FdC5Aae5F76f0055728eD38B3508a1417A84533),
    //代币接收地址
        address(0xCbB3FfC4edDD524D996daaeFfeaeA2d6E4bB8d00)
    ){

    }
}