/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
    address public lpReceiveAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _usdtPair;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor public _advancedPartnerRewardDistributor;

    uint256 public _buyFundFee = 5;
    uint256 public _buyInviteFee = 5;
    uint256 public _buyLPFee = 5;

    uint256 public _sellIDOPartnerFee = 5;
    uint256 public _sellFundFee = 5;
    uint256 public _sellLPFee = 5;

    uint256 public startTradeBlock;

    uint256 public numTokensSellToFund;

    uint256 public invitorHoldCondition;

    mapping(address => bool) public _partnerAdmin;

    uint256 public _sellAmountRate = 500;
    bool public _sellAllDestroy = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address LPReceiveAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        lpReceiveAddress = LPReceiveAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[LPReceiveAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[RouterAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;

        invitorHoldCondition = 100 * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _advancedPartnerRewardDistributor = new TokenDistributor(USDTAddress);

        numTokensSellToFund = 100 * 10 ** Decimals;
        partnerHoldCondition = 100 * 10 ** Decimals;
        partnerRewardCondition = 100 * 10 ** Decimals;
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

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "!trading");
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount, 90);
                    return;
                }
                if (_swapPairList[to]) {
                    if (_sellAllDestroy) {
                        uint256 lpPoolAmount = balanceOf(to);
                        uint256 maxSellAmount = lpPoolAmount * _sellAmountRate / 10000;
                        if (amount > maxSellAmount) {
                            amount = maxSellAmount;
                        }
                    }
                }
            }
        } else {
            if (amount > 0) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            processPartnerReward(500000);
            if (progressPartnerRewardBlock != block.number) {
                processAdvancedPartnerReward(500000);
            }
        }
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
        if (!takeFee) {
            _funTransfer(sender, recipient, tAmount, 0);
            return;
        }
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (_swapPairList[sender]) {//Buy
            uint256 inviteAmount = tAmount * _buyInviteFee / 100;
            feeAmount += inviteAmount;
            uint256 fundAmount = inviteAmount;
            uint256 invitePerAmount = inviteAmount / 10;
            address current = recipient;
            for (uint256 i; i < 5;) {
                address invitor = _inviter[current];
                if (address(0) == invitor) {
                    break;
                }
                if (balanceOf(invitor) >= invitorHoldCondition) {
                    if (0 == i || 4 == i) {
                        inviteAmount = 3 * invitePerAmount;
                    } else if (1 == i || 3 == i) {
                        inviteAmount = invitePerAmount;
                    } else {
                        inviteAmount = 2 * invitePerAmount;
                    }
                    fundAmount -= inviteAmount;
                    _takeTransfer(sender, invitor, inviteAmount);
                }
                current = invitor;
            unchecked{
                ++i;
            }
            }
            if (fundAmount > 100) {
                _takeTransfer(sender, lpReceiveAddress, fundAmount);
            }

            uint256 buySwapAmount = tAmount * (_buyLPFee + _buyFundFee) / 100;
            feeAmount += buySwapAmount;
            _takeTransfer(sender, address(this), buySwapAmount);
        } else if (_swapPairList[recipient]) {//Sell
            uint256 idoPartnerAmount = tAmount * _sellIDOPartnerFee / 100;
            feeAmount += idoPartnerAmount;
            uint256 idoNormalAmount = idoPartnerAmount / 5;
            _takeTransfer(sender, address(_tokenDistributor), idoNormalAmount);
            _takeTransfer(sender, address(_advancedPartnerRewardDistributor), idoPartnerAmount - idoNormalAmount);

            uint256 sellSwapAmount = tAmount * (_sellLPFee + _sellFundFee) / 100;
            feeAmount += sellSwapAmount;
            _takeTransfer(sender, address(this), sellSwapAmount);

            if (!inSwap) {
                if (_sellAllDestroy) {
                    _tokenTransfer(recipient, address(0x000000000000000000000000000000000000dEaD), tAmount * 180 / 100, false);
                    ISwapPair(recipient).sync();
                }
                swapTokenForFund();
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function swapTokenForFund() private lockTheSwap {
        uint256 tokenAmount = numTokensSellToFund;
        address tokenDistributor = address(_tokenDistributor);
        address usdt = _usdt;
        IERC20 USDT = IERC20(usdt);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        if (balanceOf(address(this)) >= tokenAmount) {
            uint256 lpRate = _buyLPFee + _sellLPFee;
            uint256 fundRate = _buyFundFee + _sellFundFee;
            uint256 allRate = lpRate + fundRate;
            allRate += allRate;

            uint256 lpAmount = tokenAmount * lpRate / allRate;

            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount,
                0,
                path,
                tokenDistributor,
                block.timestamp
            );
            uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
            USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

            allRate -= lpRate;
            uint256 lpUSDT = usdtBalance * lpRate / allRate;
            if (lpUSDT > 0) {
                _swapRouter.addLiquidity(
                    address(this),
                    usdt,
                    lpAmount,
                    lpUSDT,
                    0,
                    0,
                    lpReceiveAddress,
                    block.timestamp
                );
            }

            uint256 fundUSDT = usdtBalance * fundRate * 2 / allRate;
            if (fundUSDT > 0) {
                USDT.transfer(fundAddress, fundUSDT);
            }
        }
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLPReceiveAddress(address addr) external onlyOwner {
        lpReceiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function setFundSellAmount(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyFunder {
        invitorHoldCondition = amount * 10 ** _decimals;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    modifier onlyPartnerAdmin() {
        require(_owner == msg.sender || _partnerAdmin[msg.sender], "!PartnerAdmin");
        _;
    }

    //设置是否合伙人管理员
    function setPartnerAdmin(address adr, bool enable) external onlyOwner {
        _partnerAdmin[adr] = enable;
    }

    receive() external payable {}

    address[] public partners;
    mapping(address => bool) public _isPartner;

    function getPartnerLength() external view returns (uint256){
        return partners.length;
    }

    function addPartner(address adr) external onlyPartnerAdmin {
        if (_isPartner[adr]) {
            return;
        }
        _isPartner[adr] = true;
        partners.push(adr);
    }

    uint256 public currentPartnerRewardIndex;
    uint256 public partnerRewardCondition;
    uint256 public partnerHoldCondition;
    uint256 public progressPartnerRewardBlock;
    uint256 public progressPartnerRewardBlockDebt = 200;

    function processPartnerReward(uint256 gas) private {
        if (progressPartnerRewardBlock + progressPartnerRewardBlockDebt > block.number) {
            return;
        }
        address partnerRewardDistributor = address(_tokenDistributor);
        uint256 balance = balanceOf(partnerRewardDistributor);
        if (balance < partnerRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;

        uint256 shareholderCount = partners.length;
        if (0 == shareholderCount) {
            return;
        }
        uint perRewardAmount = balance / shareholderCount;
        if (0 == perRewardAmount) {
            return;
        }
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentPartnerRewardIndex >= shareholderCount) {
                currentPartnerRewardIndex = 0;
            }
            shareHolder = partners[currentPartnerRewardIndex];
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance >= partnerHoldCondition) {
                _tokenTransfer(partnerRewardDistributor, shareHolder, perRewardAmount, false);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentPartnerRewardIndex++;
            iterations++;
        }

        progressPartnerRewardBlock = block.number;
    }

    address[] public advancedPartners;
    mapping(address => bool) public _isAdvancedPartner;

    function getAdvancedPartnerLength() external view returns (uint256){
        return advancedPartners.length;
    }

    function addAdvancedPartner(address adr) external onlyPartnerAdmin {
        if (_isAdvancedPartner[adr]) {
            return;
        }
        _isAdvancedPartner[adr] = true;
        advancedPartners.push(adr);
    }

    uint256 public currentAdvancedPartnerRewardIndex;
    uint256 public progressAdvancedPartnerRewardBlock;

    function processAdvancedPartnerReward(uint256 gas) private {
        if (progressAdvancedPartnerRewardBlock + progressPartnerRewardBlockDebt > block.number) {
            return;
        }
        address partnerRewardDistributor = address(_advancedPartnerRewardDistributor);
        uint256 balance = balanceOf(partnerRewardDistributor);
        if (balance < partnerRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;

        uint256 shareholderCount = advancedPartners.length;
        if (0 == shareholderCount) {
            return;
        }
        uint perRewardAmount = balance / shareholderCount;
        if (0 == perRewardAmount) {
            return;
        }
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentAdvancedPartnerRewardIndex >= shareholderCount) {
                currentAdvancedPartnerRewardIndex = 0;
            }
            shareHolder = advancedPartners[currentAdvancedPartnerRewardIndex];
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance >= partnerHoldCondition) {
                _tokenTransfer(partnerRewardDistributor, shareHolder, perRewardAmount, false);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentAdvancedPartnerRewardIndex++;
            iterations++;
        }

        progressAdvancedPartnerRewardBlock = block.number;
    }

    function setPartnerRewardCondition(uint256 amount) external onlyFunder {
        partnerRewardCondition = amount * 10 ** _decimals;
    }

    function setPartnerHoldCondition(uint256 amount) external onlyFunder {
        partnerHoldCondition = amount * 10 ** _decimals;
    }

    function setProgressPartnerRewardBlockDebt(uint256 blockDebt) external onlyFunder {
        progressPartnerRewardBlockDebt = blockDebt;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (0 == balanceOf(account) && _binders[account].length == 0) {
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

    function setInProject(address adr, bool enable) external onlyFunder {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setSellAllDestroy(bool enable) external onlyFunder {
        _sellAllDestroy = enable;
    }

    function setSellAmountRate(uint256 rate) external onlyFunder {
        _sellAmountRate = rate;
    }
}

contract SRSCToken is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "SRSC",
        "SRSC",
        18,
        10000000,
    //Fund
        address(0x32D51A03659271c71393c7A3ac70ab9d2918e5A4),
    //LPReceive
        address(0xE91Ef99c48378e75D529A3Da2e9d4f89d00a433F),
    //Receive
        address(0xB801Fe1F896610765B8d31c683F2d45472bDA87C)
    ){

    }
}