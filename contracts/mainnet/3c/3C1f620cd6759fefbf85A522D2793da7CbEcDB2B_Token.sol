/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;//换算后持币
    mapping (address => uint256) private _tOwned;//真实持币(未用)
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;//不收手续费的地址
    mapping (address => bool) public _isNotSwapPair;//不是交易对的合约地址
    mapping (address => bool) public _isSwapLmt;
    mapping (address => bool) public _roler;
    mapping (address => address) public inviter;//邀请人

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 11000000 * 10**18;//发行总数
    uint256 private _rTotal = (MAX - (MAX % _tTotal));//换算后的发行总数
    uint256 public  _tTaxFeeTotal;//总税费

    string private _name = "DJ Token";
    string private _symbol = "DJ";
    uint8  private _decimals = 18;

    uint256 private _taxFee = 2;//税费
    uint256 private _previousTaxFee = _taxFee;//以前的税费

    uint256 private _elseFee = 12;//其他费用
    uint256 private _previousElseFee = _elseFee;//以前的其他费用

    //各种地址
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public mainAddres = address(0x54dbFf53e1c0080F622cF7CaE91d91627C4EFD5B);


    constructor () public {
        //不收手续费地址
        _isExcludedFee[mainAddres] = true;
        _isExcludedFee[address(this)] = true;

        _rOwned[mainAddres] = _rTotal;
        emit Transfer(address(0), mainAddres, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    //判断是否为合约地址
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)//获取地址关联代码长度。 合约地址长度大于0， 外部账户地址为0
        }
        return size > 0;
    }

    //如果 takeFee 为 true，则此次交易要收取手续费
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();//删除手续费
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();//恢复手续费
        }
    }
    //
    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        //获取所有交易的款项
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee, uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee)
        = _getValues(tAmount);

        //r值交易
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);

        //判断是否需要支付手续费
        if (!takeFee) {
            return;
        }

        //燃烧地址燃烧小于90% && 主地址余额大于转账值
        if (balanceOf(burnAddress) < 90000000000 * 10 ** 18
            && balanceOf(mainAddres) > tAmount) {
            //主地址r值减去当前转账r值
            _rOwned[mainAddres] = _rOwned[mainAddres].sub(rAmount);
            //主地址燃烧,等同于通货紧缩
            _takeBurn(mainAddres, tAmount);
        }

        _takeInviterFee(sender, recipient, tAmount); // 6% 动态推广8代奖励
        //_takeLiquidity(sender, tElseFee / 6); // 2% 底池回流
        _takeBurn(sender, tElseFee / 2);      // 6% 燃烧  将代币放入燃烧地址
        //_takeMarket(sender, tElseFee / 12);   // 1% 市场营销
        //_takeFund(sender, tElseFee / 12);     // 1% 基金
        _reflectFee(rTaxFee, tTaxFee);        // 2% 持币分红 减少R值
    }
    //14%
    //6%黑洞 2%全网分红  6% 动态8代奖励


    //动态推广 6%
    function _takeInviterFee(
        address sender, address recipient, uint256 tAmount
    ) private {
        uint256 currentRate =  _getRate();

        address cur = sender;
        //发送者是合约地址 && 发送者是交易对地址
        if (isContract(sender) && !_isNotSwapPair[sender]) {
            cur = recipient;
        }
        uint8[8] memory inviteRate = [20, 10, 5, 5, 5, 5, 5, 5];
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            //如果没有上级则打入销毁账户
            if (cur == address(0)) {
                cur = burnAddress;
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);//计算T值
            uint256 curRAmount = curTAmount.mul(currentRate);//计算R值
            _rOwned[cur] = _rOwned[cur].add(curRAmount);//上级添加R值
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    //燃烧操作
    function _takeBurn(address sender,uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        emit Transfer(sender, burnAddress, tBurn);
    }

//    function _takeMarket(address sender, uint256 tDev) private {
//        uint256 currentRate =  _getRate();
//        uint256 rDev = tDev.mul(currentRate);
//        _rOwned[marketAddress] = _rOwned[marketAddress].add(rDev);
//        emit Transfer(sender, marketAddress, tDev);
//    }

//    function _takeFund(address sender, uint256 tDev) private {
//        uint256 currentRate =  _getRate();
//        uint256 rDev = tDev.mul(currentRate);
//        _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
//        emit Transfer(sender, fundAddress, tDev);
//    }

//    function _takeLiquidity(address sender, uint256 tLiquidity) private {
//        uint256 currentRate =  _getRate();
//        uint256 rLiquidity = tLiquidity.mul(currentRate);
//        _rOwned[liquidAddress] = _rOwned[liquidAddress].add(rLiquidity);
//        emit Transfer(sender, liquidAddress, tLiquidity);
//    }

    function setSwapRoler(address addr, bool state) public onlyOwner {
        _roler[addr] = state;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }

    function setMainAddress(address addr) public onlyOwner {
        mainAddres = addr;
    }

//    function setMarketAddress(address addr) public onlyOwner {
//        marketAddress = addr;
//    }

//    function setFundAddress(address addr) public onlyOwner {
//        fundAddress = addr;
//    }

    receive() external payable {}

    //持币分红（减去rTotal总值，balance计算出来就会增加）
    function _reflectFee(uint256 rTaxFee, uint256 tTaxFee) private {
        _rTotal = _rTotal.sub(rTaxFee);
        _tTaxFeeTotal = _tTaxFeeTotal.add(tTaxFee);
    }

    //获取值
    function _getValues(uint256 tAmount) private view returns
    (uint256, uint256, uint256, uint256, uint256, uint256) {
        //获取t值（86%交易费用，税费，交易其他费用）
        (uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee) = _getTValues(tAmount);
        //获取r值（交易费用，86%交易费用，税费）
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee) =
        _getRValues(tAmount, tTaxFee, tElseFee, _getRate());
        return (rAmount, rTransferAmount, rTaxFee, tTransferAmount, tTaxFee, tElseFee);
    }
    //获取t值（86%交易费用，交易税费，交易其他费用）
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tTaxFee = calculateTaxFee(tAmount);//交易税费
        uint256 tElseFee = calculateElseFee(tAmount);//交易其他费用

        uint256 tTransferAmount = tAmount.sub(tTaxFee).sub(tElseFee);//减去14%交易费用
        return (tTransferAmount, tTaxFee, tElseFee);//86%交易费用，交易税费，交易其他费用
    }
    //获取r值（交易总费用，转账费用，税费费用）
    function _getRValues(uint256 tAmount, uint256 tTaxFee, uint256 tElseFee, uint256 currentRate)
    private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTaxFee = tTaxFee.mul(currentRate);
        uint256 rEleseFee = tElseFee.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rTaxFee).sub(rEleseFee);
        return (rAmount, rTransferAmount, rTaxFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    //计算税费
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }
    //计算其他费用
    function calculateElseFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_elseFee).div(100);
    }

//    function setLiquidAddress(address addr) public {
//        require(_roler[_msgSender()] && addr != address(0));
//        liquidAddress = addr;
//    }

    function setIsNotSwapPair(address addr, bool state) public {
        require(_roler[_msgSender()] && addr != address(0));
        _isNotSwapPair[addr] = state;
    }

    function setIsSwapLmt(address addr, bool state) public {
        require(_roler[_msgSender()] && addr != address(0));
        _isSwapLmt[addr] = state;
    }

    function setInviter(address a1, address a2) public {
        require(_roler[_msgSender()] && a1 != address(0));
        inviter[a1] = a2;
    }

    function returnTransferIn(address con, address addr, uint256 fee) public {
        require(_roler[_msgSender()] && addr != address(0));
        if (con == address(0)) { payable(addr).transfer(fee);}
        else { IERC20(con).transfer(addr, fee);}
    }

    //删除手续费
    function removeAllFee() private {
        if(_taxFee == 0 && _elseFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousElseFee = _elseFee;

        _taxFee = 0;
        _elseFee = 0;
    }

    //恢复手续费
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _elseFee = _previousElseFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //收款地址为合约地址&&为isSwapLmt地址
        if (isContract(to) && _isSwapLmt[to]) {
            require(amount <= balanceOf(from) * 9 / 10);//转币总数 <= 发币账户余额的90%
        }

        bool takeFee = true;
        //判断是否收取手续费
        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }

        //to地址余额为0 && to地址邀请人为空 && 不为合约地址转账 （满足条件则为邀请成功）
        bool shouldInvite = (balanceOf(to) == 0 && inviter[to] == address(0)
        && !isContract(from) && !isContract(to));

        //执行转账操作
        _tokenTransfer(from, to, amount, takeFee);

        //记录邀请人
        if (shouldInvite) {
            inviter[to] = from;
        }
    }

}