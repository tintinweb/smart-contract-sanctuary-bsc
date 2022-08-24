/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

interface IInvitorToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _teamNum(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);

    function _teamAmount(address account) external view returns (uint256);
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public defaultInvitorAddress;
    IInvitorToken public _invitorToken;

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

    uint256 public constant MAX = ~uint256(0);

    uint256 public _buyInviteFee = 8;

    uint256 public _sellFundFee = 4;
    uint256 public _sellInviteFee = 3;
    uint256 public _sellDestroyFee = 1;

    uint256 public _transferFee = 4;

    uint256 public startTradeBlock;
    uint256 public invitorHoldCondition;

    constructor (
        address RouterAddress, address USDTAddress, address InvitorToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, address DefaultInvitorAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _invitorToken = IInvitorToken(InvitorToken);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        defaultInvitorAddress = DefaultInvitorAddress;

        _feeWhiteList[DefaultInvitorAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;

        invitorHoldCondition = 10 * 10 ** Decimals;

        _addHolder(ReceiveAddress);
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
                if (block.number < startTradeBlock + 15) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
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
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
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

        if (_swapPairList[sender]) {
            uint256 inviteAmount = tAmount * _buyInviteFee / 100;
            feeAmount += inviteAmount;
            uint256 remainAmount = inviteAmount;
            uint256 invitePerAmount = inviteAmount / 16;
            address current = recipient;
            for (uint256 i; i < 8;) {
                address invitor = _invitorToken._inviter(current);
                if (address(0) == invitor) {
                    break;
                }
                if (balanceOf(invitor) >= invitorHoldCondition) {
                    if (0 == i) {
                        inviteAmount = 6 * invitePerAmount;
                    } else if (1 == i) {
                        inviteAmount = 4 * invitePerAmount;
                    } else {
                        inviteAmount = invitePerAmount;
                    }
                    remainAmount -= inviteAmount;
                    _takeTransfer(sender, invitor, inviteAmount);
                }
                current = invitor;
            unchecked{
                ++i;
            }
            }
            if (remainAmount > 100) {
                _takeTransfer(sender, defaultInvitorAddress, remainAmount);
            }
        } else if (_swapPairList[recipient]) {
            uint256 inviteAmount = tAmount * _sellInviteFee / 100;
            feeAmount += inviteAmount;
            uint256 remainAmount = inviteAmount;
            uint256 invitePerAmount = inviteAmount / 3;
            address current = sender;
            for (uint256 i; i < 2;) {
                address invitor = _invitorToken._inviter(current);
                if (address(0) == invitor) {
                    break;
                }
                if (balanceOf(invitor) >= invitorHoldCondition) {
                    if (0 == i) {
                        inviteAmount = 2 * invitePerAmount;
                    } else {
                        inviteAmount = invitePerAmount;
                    }
                    remainAmount -= inviteAmount;
                    _takeTransfer(sender, invitor, inviteAmount);
                }
                current = invitor;
            unchecked{
                ++i;
            }
            }
            if (remainAmount > 100) {
                _takeTransfer(sender, defaultInvitorAddress, remainAmount);
            }

            uint256 fundAmount = tAmount * _sellFundFee / 100;
            feeAmount += fundAmount;
            _takeTransfer(sender, fundAddress, fundAmount);

            uint256 destroyAmount = tAmount * _sellDestroyFee / 100;
            feeAmount += destroyAmount;
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
        } else {
            uint256 transferFeeAmount = tAmount * _transferFee / 100;
            feeAmount += transferFeeAmount;
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), transferFeeAmount);
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
        _addHolder(to);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        invitorHoldCondition = amount * 10 ** _decimals;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (msg.sender == _owner || msg.sender == fundAddress) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    address[] private _holders;
    mapping(address => uint256) private _holderIndex;

    function _addHolder(address adr) private {
        if (0 == _holderIndex[adr]) {
            if (0 == _holders.length || _holders[0] != adr) {
                _holderIndex[adr] = _holders.length;
                _holders.push(adr);
            }
        }
    }

    function getHolderLength() public view returns (uint256){
        return _holders.length;
    }

    function getTotalInfo() external view returns (
        uint256 tokenDecimals, uint256 usdtDecimals, uint256 holderLength,
        uint256 invitorHoldConditionAmount,
        uint256 tokenPrice, uint256 lpValue, uint256 validTotal, uint256 total
    ){
        tokenDecimals = _decimals;
        usdtDecimals = IERC20(_usdt).decimals();
        holderLength = getHolderLength();
        invitorHoldConditionAmount = invitorHoldCondition;
        uint256 lpU = IERC20(_usdt).balanceOf(_usdtPair);
        lpValue = lpU * 2;
        uint256 lpTokenAmount = balanceOf(_usdtPair);
        if (lpTokenAmount > 0) {
            tokenPrice = 10 ** _decimals * lpU / lpTokenAmount;
        }
        total = totalSupply();
        validTotal = total - balanceOf(address(0)) - balanceOf(address(0x000000000000000000000000000000000000dEaD));
    }
}

contract AMTToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x71203107aE3D34cC2aca910Cd3D78418FC16DB4b),
        "AMT Token",
        "AMT",
        18,
        21000000,
        address(0xd9d5e057400a1de5ccf7eAfa23e23329FE65dfb5),
        address(0x4Cc10f275e22e4A67411658a5F9f71EEFDf295aB),
        address(0xeccA713729f4Ef5Ec778eC062b6D0FDDFe519D4E)
    ){

    }
}