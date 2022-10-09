/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IUniswapV2Factory {function createPair(address tokenA, address tokenB) external returns (address pair);}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

interface IDKToken {
    function inviter(address account) external view returns(address);
}


contract DKToken is IDKToken, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint8 private _decimal = 18;

    string private _name = "LuLu TOKEN";
    string private _symbol = "LuLu";
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    uint256 public _burnMinLimit;

    // tx fee params
    uint256 public _tLocalRate;
    uint256 public _tBlackRate;
    uint256 public _tLPRate;

    uint256 private _tLocalPreRate;
    uint256 private _tBlackPreRate;
    uint256 private _tLPPreRate;

    // swap fee params
    uint256 public _sLocalRate;
    uint256 public _sBlackRate;
    uint256 public _sLPRate;

    uint256 private _sLocalPreRate;
    uint256 private _sBlackPreRate;
    uint256 private _sLPPreRate;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcluded;

    IERC20 public uniswapV2Pair;

    address[] private _excluded;

    address public buyFeeAddress;
    address public sellFeeAddress;

    address public constant _burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public constant busdtToken = 0x55d398326f99059fF775485246999027B3197955;

    // inviter state
    mapping(address => address) public override inviter;
    bool isTransferSetInviter = true;

    bool isSend2Fund = true;

    uint256 public dkBalanceLimit = 100 * 1e18;

    struct TaxFee {
        uint256 tLocalRate;
        uint256 tBlackRate;
        uint256 tLPRate;
        uint256 sLocalRate;
        uint256 sBlackRate;
        uint256 sLPRate;
    }

    struct TaxFeeReflection {
        uint256 rtLocalRate;
        uint256 rtBlackRate;
        uint256 rtLPRate;
        uint256 rsLocalRate;
        uint256 rsBlackRate;
        uint256 rsLPRate;
    }
    
    constructor(
        address _buyFeeAddress, 
        address _sellFeeAddress,
        address _minePoolAddress,
        address _airdropAddress,
        address _initLpProviderAddress
    ){

        _tTotal = 1_0000_0000_0000_0000 * 10**_decimal;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[_burnAddress] = _rTotal / 100 * 50;
        emit Transfer(address(0), _burnAddress, _tTotal / 100 * 50);

        _rOwned[_minePoolAddress] = _rTotal / 100 * 25;
        emit Transfer(address(0), _minePoolAddress, _tTotal / 100 * 25);

        _rOwned[_airdropAddress] = _rTotal / 100 * 15;
        emit Transfer(address(0), _airdropAddress, _tTotal / 100 * 15);

        _rOwned[_initLpProviderAddress] = _rTotal / 100 * 10;
        emit Transfer(address(0), _initLpProviderAddress, _tTotal / 100 * 10);

        _burnMinLimit = 2100_0000 * 10**_decimal;

        // tx fee rate
        _tLocalRate = 2;
        _tBlackRate = 1;
        _tLPRate = 2;

        // swap fee rate
        _sLocalRate = 2;
        _sBlackRate = 5;
        _sLPRate = 3;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2PairAddr = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), busdtToken);
        uniswapV2Pair = IERC20(_uniswapV2PairAddr);

        excludeFromReward(address(0));
        excludeFromReward(_burnAddress);
        excludeFromReward(address(this));
        
        excludeFromReward(address(uniswapV2Pair));

        excludeFromReward(address(owner()));
        excludeFromReward(address(_minePoolAddress));
        excludeFromReward(address(_airdropAddress));
        excludeFromReward(address(_initLpProviderAddress));
        
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[_burnAddress] = true;
        excludeLpProvider[address(this)] = true;

        buyFeeAddress = _buyFeeAddress;
        sellFeeAddress = _sellFeeAddress;
    }


    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual  returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }

    function totalSupplyReflection() public view virtual returns (uint256) {
        return _rTotal;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setBurnMinLimit(uint256 minLimit) external onlyOwner {
        _burnMinLimit = minLimit * 10**_decimal;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (sender == address(uniswapV2Pair) || recipient == address(uniswapV2Pair)){
            address _feeReceiver;
            if (sender == address(uniswapV2Pair)){//buy token
                _feeReceiver = buyFeeAddress;
            }else {
                 _feeReceiver = sellFeeAddress;
            }
            _tokenTransfer(sender, recipient, amount, 2, _feeReceiver);

            if (recipient == address(uniswapV2Pair)){// add LP and sell DK
                addLpProvider(sender);
            }
            
        } else {
            _tokenTransfer(sender, recipient, amount, 1,address(0));
        }

        // set invite   
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0)
        && !isContract(sender) && !isContract(recipient);

        if (isTransferSetInviter && shouldSetInviter) {
            inviter[recipient] = sender;
        }
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function setTaxFeePercent(
        uint256 tLocalRate_, 
        uint256 tBlackRate_, 
        uint256 tLPRate_, 
        uint256 sLocalRate_, 
        uint256 sBlackRate_, 
        uint256 sLPRate_) external onlyOwner {
        _tLocalRate = tLocalRate_;
        _tBlackRate = tBlackRate_;
        _tLPRate = tLPRate_;
        _sLocalRate = sLocalRate_;
        _sBlackRate = sBlackRate_;
        _sLPRate = sLPRate_;
    }
    
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function calculateTaxFee(uint256 _amount, uint256 ty) private view returns (TaxFee memory taxFee) {
        if ((_tTotal - _tOwned[_burnAddress]) > _burnMinLimit){
            if (ty == 1){
                taxFee.tLocalRate = _amount.mul(_tLocalRate).div(100);
                taxFee.tLPRate = _amount.mul(_tLPRate).div(100);
                taxFee.tBlackRate = _amount.mul(_tBlackRate).div(100);
            } else {
                taxFee.sLocalRate = _amount.mul(_sLocalRate).div(100);
                taxFee.sLPRate = _amount.mul(_sLPRate).div(100);
                taxFee.sBlackRate = _amount.mul(_sBlackRate).div(100);
            }
        }
    }

    function calculateTaxFeeReflection(uint256 _amount, uint256 currentRate, uint256 ty) private view returns (TaxFeeReflection memory feeRelection) {
        TaxFee memory taxFee = calculateTaxFee(_amount, ty);
        if (taxFee.tLocalRate > 0 || taxFee.sLocalRate > 0){
            if (ty == 1){
                feeRelection.rtLocalRate = taxFee.tLocalRate.mul(currentRate);
                feeRelection.rtBlackRate = taxFee.tBlackRate.mul(currentRate);
                feeRelection.rtLPRate = taxFee.tLPRate.mul(currentRate);
            } else {
                feeRelection.rsLocalRate = taxFee.sLocalRate.mul(currentRate);
                feeRelection.rsBlackRate = taxFee.sBlackRate.mul(currentRate);
                feeRelection.rsLPRate = taxFee.sLPRate.mul(currentRate);
            }
        }   
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal); // rTotal - m * (rTotal/tTotal) >= rTotal/tTotal ==> m <= tTotal
        return (rSupply, tSupply);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, uint256 ty, address feeReceiver) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, ty,feeReceiver);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, ty,feeReceiver);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, ty,feeReceiver);
        } else {
            _transferStandard(sender, recipient, amount, ty,feeReceiver);
        }
    }

    function _reflectFee(uint256 rShareFree, uint256 tShareFree) private {
        if (rShareFree > 0){
            _rTotal = _rTotal.sub(rShareFree);
            _tFeeTotal = _tFeeTotal.add(tShareFree);
        }
    }

    function _getTValues(uint256 tAmount, uint256 ty) private view returns (uint256) {
        TaxFee memory taxFee = calculateTaxFee(tAmount, ty);
        uint256 tTransferAmount;
        if (ty == 1){
            tTransferAmount = tAmount.sub(taxFee.tLocalRate).sub(taxFee.tBlackRate).sub(taxFee.tLPRate);
        } else {
            tTransferAmount = tAmount.sub(taxFee.sLocalRate).sub(taxFee.sBlackRate).sub(taxFee.sLPRate);
        }
        return tTransferAmount;
    }

    function _getRValues(uint256 tAmount, uint256 currentRate, uint256 ty) private view returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        TaxFeeReflection memory feeRelection = calculateTaxFeeReflection(tAmount, currentRate, ty);
        uint256 rTransferAmount;
        if (ty == 1){
            rTransferAmount = rAmount.sub(feeRelection.rtLocalRate).sub(feeRelection.rtBlackRate).sub(feeRelection.rtLPRate);
        } else {
            rTransferAmount = rAmount.sub(feeRelection.rsLocalRate).sub(feeRelection.rsBlackRate).sub(feeRelection.rsLPRate);
        }
        return (rAmount, rTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, uint256 ty, address feeReceiver) private {
        uint256 tTransferAmount = _getTValues(tAmount, ty);
        TaxFee memory taxFee = calculateTaxFee(tAmount, ty);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, _getRate(), ty);
        TaxFeeReflection memory feeRelection = calculateTaxFeeReflection(tAmount,  _getRate(), ty);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _relationShare(sender, taxFee, feeRelection, ty);
    
        if (feeRelection.rtLocalRate > 0 || feeRelection.rsLocalRate > 0){
            if (ty == 1){// is tx
                _reflectFee(feeRelection.rtLocalRate, taxFee.tLocalRate);
            } else {// is swap
                if(isSend2Fund) {
                    _takeFund(sender, taxFee.sLocalRate, feeReceiver);
                } else {
                    _reflectFee(feeRelection.rsLocalRate, taxFee.sLocalRate);
                }
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeFund(address sender, uint256 tDev, address feeReceiver) private {
        if(feeReceiver != address(0)) {
            uint256 currentRate =  _getRate();
            uint256 rDev = tDev.mul(currentRate);
            _rOwned[feeReceiver] = _rOwned[feeReceiver].add(rDev);
            emit Transfer(sender, feeReceiver, tDev);
        }
        
    }
    

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, uint256 ty, address feeReceiver) private {
        uint256 tTransferAmount = _getTValues(tAmount, ty);
        TaxFee memory taxFee = calculateTaxFee(tAmount, ty);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, _getRate(), ty);
        TaxFeeReflection memory feeRelection = calculateTaxFeeReflection(tAmount,  _getRate(), ty);
        
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _relationShare(sender, taxFee, feeRelection, ty);

        if (feeRelection.rtLocalRate > 0 || feeRelection.rsLocalRate > 0){
            if (ty == 1){
                _reflectFee(feeRelection.rtLocalRate, taxFee.tLocalRate);
            } else {
                if(isSend2Fund) {
                    _takeFund(sender, taxFee.sLocalRate, feeReceiver);
                } else {
                    _reflectFee(feeRelection.rsLocalRate, taxFee.sLocalRate);
                }
            }
        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, uint256 ty, address feeReceiver) private {
        uint256 tTransferAmount = _getTValues(tAmount, ty);
        TaxFee memory taxFee = calculateTaxFee(tAmount, ty);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, _getRate(), ty);
        TaxFeeReflection memory feeRelection = calculateTaxFeeReflection(tAmount,  _getRate(), ty);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _relationShare(sender, taxFee, feeRelection, ty);

        if (feeRelection.rtLocalRate > 0 || feeRelection.rsLocalRate > 0){
            if (ty == 1){
                _reflectFee(feeRelection.rtLocalRate, taxFee.tLocalRate);
            } else {
                if(isSend2Fund) {
                    _takeFund(sender, taxFee.sLocalRate, feeReceiver);
                } else {
                    _reflectFee(feeRelection.rsLocalRate, taxFee.sLocalRate);
                }
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, uint256 ty, address feeReceiver) private {
        uint256 tTransferAmount = _getTValues(tAmount, ty);
        TaxFee memory taxFee = calculateTaxFee(tAmount, ty);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, _getRate(), ty);
        TaxFeeReflection memory feeRelection = calculateTaxFeeReflection(tAmount,  _getRate(), ty);
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _relationShare(sender, taxFee, feeRelection, ty);

        if (feeRelection.rtLocalRate > 0 || feeRelection.rsLocalRate > 0){
            if (ty == 1){
                _reflectFee(feeRelection.rtLocalRate, taxFee.tLocalRate);
            } else {
                if(isSend2Fund) {
                    _takeFund(sender, taxFee.sLocalRate, feeReceiver);
                } else {
                    _reflectFee(feeRelection.rsLocalRate, taxFee.sLocalRate);
                }
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _relationShare(address sender, TaxFee memory taxFee, TaxFeeReflection memory feeRelection, uint ty) private {
        if (taxFee.tLPRate > 0 || taxFee.sLPRate > 0){
            if (ty == 1){
                _tOwned[address(this)] = _tOwned[address(this)].add(taxFee.tLPRate);
                _rOwned[address(this)] = _rOwned[address(this)].add(feeRelection.rtLPRate);
                _tOwned[_burnAddress] = _tOwned[_burnAddress].add(taxFee.tBlackRate);
                _rOwned[_burnAddress] = _rOwned[_burnAddress].add(feeRelection.rtBlackRate);
                emit Transfer(sender, address(this), taxFee.tLPRate);
                emit Transfer(sender, _burnAddress, taxFee.tBlackRate);
            } else {
                _tOwned[address(this)] = _tOwned[address(this)].add(taxFee.sLPRate);
                _rOwned[address(this)] = _rOwned[address(this)].add(feeRelection.rsLPRate);
                _tOwned[_burnAddress] = _tOwned[_burnAddress].add(taxFee.sBlackRate);
                _rOwned[_burnAddress] = _rOwned[_burnAddress].add(feeRelection.rsBlackRate);
                emit Transfer(sender, address(this), taxFee.sLPRate);
                emit Transfer(sender, _burnAddress, taxFee.sBlackRate);
            }
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;


    function addLpProvider(address adr) private {
        if (lpProviderIndex[adr] == 0) {
            lpProviders.push(adr);
            lpProviderIndex[adr] = lpProviders.length;
        }
    }

    uint256 public currentIndex;
    uint256 public lpRewardCondition = 10;
    uint256 public progressLPBlock=block.number;


    function processLP(uint256 gas) public {

        if (progressLPBlock + 200 > block.number) {
            return;
        }
  
        uint totalPair = uniswapV2Pair.totalSupply();
        if (totalPair == 0) {
            return;
        }

        uint256 balance = balanceOf(address(this));

        if (balance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;
        uint256 dkBalance;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        uint256 gasLeft = gasleft();


        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];

            pairBalance = uniswapV2Pair.balanceOf(shareHolder);
            dkBalance = balanceOf(shareHolder);

            if (
                pairBalance > 0 && 
                !excludeLpProvider[shareHolder] &&
                dkBalance >= dkBalanceLimit
            ) {
                amount = balance * pairBalance / totalPair;

                if (amount > 0) {
                    // 66% to shareHolder,total 34% distribute to 5 levels
                    _tokenTransfer(address(this), shareHolder, amount * 66 / 100, 1, address(0));

                    // distribute 5 levels
                    _takeInviterFee(shareHolder,amount);
                    
                }
            }
            uint256 newGasLeft = gasleft();
            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
            //gasUsed = gasUsed + (gasLeft - gasleft());
            //gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function _takeInviterFee(address _shareHolder,uint256 _amount) internal {
        address curInviter = _shareHolder;
        if (curInviter == address(0)) {
            return;
        }
        uint256 _dkBalance;
        // distribute 5 levels
        for (int256 i = 0; i < 5; i++) {// total 34%
            uint256 rate;
            if (i == 0) {
                rate = 15;
            } else if (i == 1) {
                rate = 10;
            } else if (i == 2){
                rate = 5;
            }else if (i == 3){
                rate = 3;
            }else if (i == 4){
                rate = 1;
            }
            curInviter = inviter[curInviter];
            if (curInviter == address(0)) {
                curInviter = _burnAddress;
            }

            uint256 curAmount = _amount * rate / 100;
            
            _dkBalance = balanceOf(curInviter);
            if(_dkBalance >= dkBalanceLimit) {
                _tokenTransfer(address(this), curInviter, curAmount, 1, address(0));
            }
        }
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function register(address _inviter) public {
        require(!isTransferSetInviter,"Cannot register");
        require(msg.sender != _inviter,"inviter cannot be msgSender");
        require(inviter[msg.sender] == address(0),"Already register");
        require(!isContract(msg.sender) && !isContract(_inviter),"Not Contract");
        inviter[msg.sender] = _inviter;
    }

    function setIsTransferSetInviter(bool _set) public onlyOwner {
        isTransferSetInviter = _set;
    }

    function setIsSend2Fund() public onlyOwner {
        isSend2Fund = !isSend2Fund;
    }

    function setDkBalanceLimit(uint256 _newLimit) public onlyOwner {
        dkBalanceLimit = _newLimit;
    }

    function getRemianLpProviders() public view returns(bool isRight, uint256 _curIndex,uint256 remianLpProviders){
        if(currentIndex == 0) {
            return(true,0,0);
        }else {
            if(lpProviders.length >= currentIndex) {
                return(true, currentIndex,lpProviders.length - currentIndex);
            } else {
                return(false,0,0);
            }
        } 
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}