/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// VOPY SPACE A Distributed Blockchain -Based Video Sharing System With Copyright, Integrity, And Immutability
//                          &(`)&&  & &&
//                      && &\/&\|& (`)|/&&&&
//                     &\/(/&/&||/&  /_/&/_&
//                   &(`)&\/&|(,)/& \/&&& & (`)
//                  &&_\_&&_\ |& |&&&/&&_/_& &&
//                  (`) &&&& &| &| /& & (`)& /&&
//                   &&&&& &&--& &&|&&-&&-&&&&&
//                              |||}
//                           Y  {||{
//                           {}_}|||}
//                              ||}
//                          -=-~'{`.-^-
//                          8b  `}    d8 
//                          `8b     d8' 
//                           `8b   d8' 
//                            `8b,d8'  
//                              "8"     
// https://vopy.space

// Telegram https://t.me/vopyspace

// https://www.linkedin.com/in/isaac-e-anderson-313bb922a/

// https://medium.com/@VopySpace

// https://discord.com/invite/dZrw5dzS

// https://www.reddit.com/user/Vopy_Space

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

abstract contract VopySpaceContext {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

interface VopyBinanceSmartChainEvolutionProposal {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function tokenCrucifixion(uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library VopyOperations {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 result = a + b;
        require(result >= a, "VopyOperations: add did not work");
        return result;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VopyOperations: sub did not work");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 result = a - b;
        return result;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = a * b;
        require(result / a == b, "VopyOperations: multiplication did not work");
        return result;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VopyOperations: division did not work");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 result = a / b;
        return result;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "VopyOperations: mod did not work");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library VopyAddress {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "VopyAddress: not enough balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "VopyAddress: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "VopyAddress: low_level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "VopyAddress: low_level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "VopyAddress: not enough balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "VopyAddress: call to non_contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract VopyOwnable is VopySpaceContext {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(_owner == _msgSender(), "VopyOwnable: you are not the Owner... BROOO!");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "VopyOwnable: new owner is the zero position array address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract VopyCrypt is VopySpaceContext, VopyBinanceSmartChainEvolutionProposal, VopyOwnable {
    using VopyOperations for uint256;
    using VopyAddress for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    address internal burnAddress = 0x000000000000000000000000000000000000dEaD;
    string  private _NAME = "Vopy Space";
    string  private _SYMBOL = "VPS";
    uint256   private _DECIMALS;
    uint256 private _MAX = ~uint256(0);
    uint256 private _DECIMAL_FACTOR;
    uint256 private _ONE_HUNDRED = 100;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private _tBurnTotal;
    uint256 private _tCharityTotal;
    uint256 private _tMarketingTotal;
    uint256 private _tLiquidityTotal;

    Fee public fee;
    OriginalFee originalFee;

    struct OriginalFee {
        uint256  ORIG_TAX_FEE;
        uint256  ORIG_BURN_FEE;
        uint256  ORIG_CHARITY_FEE;
        uint256  ORIG_MARKETING_FEE;
        uint256  ORIG_LIQUIDITY_FEE;
    }

    struct TotalFee {
        uint256 tFee;
        uint256 tBurn;
        uint256 tCharity;
        uint256 tMarketing;
        uint256 tLiquidity;
    }

    struct Fee {
        address marketingAddress;
        uint256 _MARKETING_FEE;
        address liquidityAddress;
        uint256 _LIQUIDITY_FEE;
        address charityAddress;
        uint256 _CHARITY_FEE;
        address burnAddress;
        uint256 _BURN_FEE;
        address txAddress;
        uint256 _TAX_FEE;
    }

    constructor (uint256 _decimals, uint256 _supply, address ownerAddress,
        address marketingAddress,
        uint256 marketingFee,
        address liquidityAddress,
        uint256 liquidityFee,
        address charityAddress,
        uint256 charityFee,
        uint256 burnFee,
        address txAddress,
        uint256 txFee
    ) payable {
        _DECIMALS = _decimals;
        _DECIMAL_FACTOR = 10 ** _DECIMALS;
        _tTotal =_supply * _DECIMAL_FACTOR;
        _rTotal = (_MAX - (_MAX % _tTotal));
        fee = Fee(marketingAddress, marketingFee, liquidityAddress, liquidityFee, charityAddress, charityFee, burnAddress, burnFee, txAddress,txFee);
        originalFee.ORIG_TAX_FEE = fee._TAX_FEE;
        originalFee.ORIG_BURN_FEE = fee._BURN_FEE;
        originalFee.ORIG_CHARITY_FEE = fee._CHARITY_FEE;
        originalFee.ORIG_MARKETING_FEE = fee._MARKETING_FEE;
        originalFee.ORIG_LIQUIDITY_FEE = fee._LIQUIDITY_FEE;

        _owner = ownerAddress;
        _rOwned[ownerAddress] = _rTotal;
        payable(ownerAddress).transfer(msg.value);
        emit Transfer(address(0),ownerAddress, _tTotal);
    }
    function name() public view returns (string memory) {
        return _NAME;
    }
    function symbol() public view returns (string memory) {
        return _SYMBOL;
    }
    function decimals() public view returns (uint8) {
        return uint8(_DECIMALS);
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "VopyCrypt: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "VopyCrypt: decreased allowance below zero"));
        return true;
    }
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    function totalFeesRewardsDeliveredToHolderBelievers() public view returns (uint256) {
        return _tFeeTotal;
    }
    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }
    function totalCharity() public view returns (uint256) {
        return _tCharityTotal;
    }
    function totalMarketing() public view returns (uint256) {
        return _tMarketingTotal;
    }
    function totalLiquidity() public view returns (uint256) {
        return _tLiquidityTotal;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    function deliverRewardTokensToHolderBelievers(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "VopyCrypt: Excluded addresses cannot call this function");
        require(sender != fee.liquidityAddress, "VopyCrypt: Liquidity address has no power here");
        require(sender != fee.marketingAddress, "VopyCrypt: Marketing address has no power here");
        require(sender != _owner, "VopyCrypt: Owner address has no power here");
        require(sender != fee.txAddress, "VopyCrypt: Tx address has no power here");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "VopyCrypt: Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "VopyCrypt: Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "VopyCrypt: Account address is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "VopyCrypt: Account address is already included");
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

    function setAsCharityAccount(address account) external onlyOwner() {
        fee.charityAddress = account;
    }

    function setAsMarketingAccount(address account) external onlyOwner() {
        fee.marketingAddress = account;
    }

    function setAsLiquidityAccount(address account) external onlyOwner() {
        fee.liquidityAddress = account;
    }

    function updateFee(uint256 _txFee,uint256 _burnFee,uint256 _charityFee, uint256 _marketingFee, uint256 _liquidityFee) onlyOwner() public{
        require(_txFee < 100 && _burnFee < 100 && _charityFee < 100 && _marketingFee < 100 && _liquidityFee < 100);
        fee._TAX_FEE = _txFee;
        fee._BURN_FEE = _burnFee;
        fee._CHARITY_FEE = _charityFee;
        fee._MARKETING_FEE = _marketingFee;
        fee._LIQUIDITY_FEE = _liquidityFee;
        originalFee.ORIG_TAX_FEE = fee._TAX_FEE;
        originalFee.ORIG_BURN_FEE = fee._BURN_FEE;
        originalFee.ORIG_CHARITY_FEE = fee._CHARITY_FEE;
        originalFee.ORIG_MARKETING_FEE = fee._MARKETING_FEE;
        originalFee.ORIG_LIQUIDITY_FEE = fee._LIQUIDITY_FEE;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "VopyCrypt: approve from the zero address");
        require(spender != address(0), "VopyCrypt: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "VopyCrypt: transfer from the zero address");
        require(recipient != address(0), "VopyCrypt: transfer to the zero address");
        require(amount > 0, "VopyCrypt: You are transferring ZERO tokens... BROO!");
        bool takeFee = true;
        if (sender == _owner
        || fee.marketingAddress == sender
        || fee.marketingAddress == recipient
        || fee.liquidityAddress == sender
        || fee.liquidityAddress == recipient
        || fee.charityAddress == sender
        || fee.charityAddress == recipient
        || fee.txAddress == sender
        || fee.txAddress == recipient
            || _isExcluded[recipient]) {
            takeFee = false;
        }
        if (!takeFee) removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        if (!takeFee) restoreAllFee();
    }
    function _tokenCrucifixion(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "VopyCrypt: transfer from the zero address");
        require(amount > 0, "VopyCrypt: to Crucify Tokens you first need to have some.. BROO!");
        removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        _tBurnTotal = _tBurnTotal.add(amount);
        _tTotal = _tTotal.sub(amount);
        restoreAllFee();
    }
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, TotalFee memory totalFee) = _getValues(tAmount);
        uint256 rBurn =  totalFee.tBurn.mul(currentRate);
        _standardTransferContent(sender, recipient, rAmount, rTransferAmount);
        _sendToCharity(totalFee.tCharity, sender);
        _sendToMarketing(totalFee.tMarketing, sender);
        _sendToLiquidity(totalFee.tLiquidity, sender);
        _reflectFee(rFee, rBurn, totalFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _standardTransferContent(address sender, address recipient, uint256 rAmount, uint256 rTransferAmount) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, TotalFee memory totalFee) = _getValues(tAmount);
        uint256 rBurn =  totalFee.tBurn.mul(currentRate);
        _excludedFromTransferContent(sender, recipient, tTransferAmount, rAmount, rTransferAmount);
        _sendToCharity(totalFee.tCharity, sender);
        _sendToMarketing(totalFee.tMarketing, sender);
        _sendToLiquidity(totalFee.tLiquidity, sender);
        _reflectFee(rFee, rBurn, totalFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _excludedFromTransferContent(address sender, address recipient, uint256 tTransferAmount, uint256 rAmount, uint256 rTransferAmount) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, TotalFee memory totalFee) = _getValues(tAmount);
        uint256 rBurn =  totalFee.tBurn.mul(currentRate);
        _excludedToTransferContent(sender, recipient, tAmount, rAmount, rTransferAmount);
        _sendToCharity(totalFee.tCharity, sender);
        _sendToMarketing(totalFee.tMarketing, sender);
        _sendToLiquidity(totalFee.tLiquidity, sender);
        _reflectFee(rFee, rBurn, totalFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _excludedToTransferContent(address sender, address recipient, uint256 tAmount, uint256 rAmount, uint256 rTransferAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, TotalFee memory totalFee) = _getValues(tAmount);
        uint256 rBurn =  totalFee.tBurn.mul(currentRate);
        _bothTransferContent(sender, recipient, tAmount, rAmount, tTransferAmount, rTransferAmount);
        _sendToCharity(totalFee.tCharity, sender);
        _sendToMarketing(totalFee.tMarketing, sender);
        _sendToLiquidity(totalFee.tLiquidity, sender);
        _reflectFee(rFee, rBurn, totalFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _bothTransferContent(address sender, address recipient, uint256 tAmount, uint256 rAmount, uint256 tTransferAmount, uint256 rTransferAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }
    function _reflectFee(uint256 rFee, uint256 rBurn, TotalFee memory totalFee) private {
        _rTotal = _rTotal.sub(rFee).sub(rBurn);
        _tFeeTotal = _tFeeTotal.add(totalFee.tFee);
        _tBurnTotal = _tBurnTotal.add(totalFee.tBurn);
        _tCharityTotal = _tCharityTotal.add(totalFee.tCharity);
        _tMarketingTotal = _tMarketingTotal.add(totalFee.tMarketing);
        _tLiquidityTotal = _tLiquidityTotal.add(totalFee.tLiquidity);
        _tTotal = _tTotal.sub(totalFee.tBurn);
        emit Transfer(address(this), address(0), totalFee.tBurn);
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, TotalFee memory) {
        TotalFee memory totalFee = _getTBasics(tAmount);
        uint256 tTransferAmount = getTTransferAmount(tAmount, totalFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rFee) = _getRBasics(tAmount, totalFee.tFee, currentRate);
        uint256 rTransferAmount = _getRTransferAmount(rAmount, rFee, totalFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, totalFee);
    }
    function _getTBasics(uint256 tAmount) private view returns (TotalFee memory) {
        TotalFee memory totalFee;
        totalFee.tFee = ((tAmount.mul(fee._TAX_FEE)).div(_ONE_HUNDRED));
        totalFee.tBurn = ((tAmount.mul(fee._BURN_FEE)).div(_ONE_HUNDRED));
        totalFee.tCharity = ((tAmount.mul(fee._CHARITY_FEE)).div(_ONE_HUNDRED));
        totalFee.tMarketing = ((tAmount.mul(fee._MARKETING_FEE)).div(_ONE_HUNDRED));
        totalFee.tLiquidity = ((tAmount.mul(fee._LIQUIDITY_FEE)).div(_ONE_HUNDRED));
        return totalFee;
    }
    function getTTransferAmount(uint256 tAmount, TotalFee memory totalFee) private pure returns (uint256) {
        return tAmount.sub(totalFee.tFee).sub(totalFee.tBurn).sub(totalFee.tCharity).sub(totalFee.tMarketing).sub(totalFee.tLiquidity);
    }
    function _getRBasics(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        return (rAmount, rFee);
    }
    function _getRTransferAmount(uint256 rAmount, uint256 rFee, TotalFee memory totalFee, uint256 currentRate) private pure returns (uint256) {
        uint256 rBurn = totalFee.tBurn.mul(currentRate);
        uint256 rCharity = totalFee.tCharity.mul(currentRate);
        uint256 rMarketing = totalFee.tMarketing.mul(currentRate);
        uint256 rLiquidity = totalFee.tLiquidity.mul(currentRate);
        uint256 rTransferAmount = _subR(rAmount, rFee, rBurn, rCharity, rMarketing, rLiquidity);
        return rTransferAmount;
    }

    function _subR(uint256 rAmount, uint256 rFee, uint256 rBurn, uint256 rCharity, uint256 rMarketing, uint256 rLiquidity) private pure returns (uint256){
        uint256 rTransferAmount1 = rAmount.sub(rFee).sub(rBurn);
        uint256 rTransferAmount2 = rTransferAmount1.sub(rCharity).sub(rMarketing);
        uint256 rTransferAmount3 = rTransferAmount2.sub(rLiquidity);
        return rTransferAmount3;
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
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _sendToCharity(uint256 tCharity, address sender) private {
        uint256 currentRate = _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[fee.charityAddress] = _rOwned[fee.charityAddress].add(rCharity);
        _tOwned[fee.charityAddress] = _tOwned[fee.charityAddress].add(tCharity);
        emit Transfer(sender, fee.charityAddress, tCharity);
    }

    function _sendToMarketing(uint256 tMarketing, address sender) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[fee.marketingAddress] = _rOwned[fee.marketingAddress].add(rMarketing);
        _tOwned[fee.marketingAddress] = _tOwned[fee.marketingAddress].add(tMarketing);
        emit Transfer(sender, fee.marketingAddress, tMarketing);
    }

    function _sendToLiquidity(uint256 tLiquidity, address sender) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[fee.liquidityAddress] = _rOwned[fee.liquidityAddress].add(rLiquidity);
        _tOwned[fee.liquidityAddress] = _tOwned[fee.liquidityAddress].add(tLiquidity);
        emit Transfer(sender, fee.liquidityAddress, tLiquidity);
    }

    function removeAllFee() private {
        if(fee._TAX_FEE == 0 && fee._BURN_FEE == 0 && fee._CHARITY_FEE == 0 && fee._MARKETING_FEE == 0 && fee._LIQUIDITY_FEE == 0) return;
        originalFee.ORIG_TAX_FEE = fee._TAX_FEE;
        originalFee.ORIG_BURN_FEE = fee._BURN_FEE;
        originalFee.ORIG_CHARITY_FEE = fee._CHARITY_FEE;
        originalFee.ORIG_MARKETING_FEE = fee._MARKETING_FEE;
        originalFee.ORIG_LIQUIDITY_FEE = fee._LIQUIDITY_FEE;
        fee._TAX_FEE = 0;
        fee._BURN_FEE = 0;
        fee._CHARITY_FEE = 0;
        fee._MARKETING_FEE = 0;
        fee._LIQUIDITY_FEE = 0;
    }
    function restoreAllFee() private {
        fee._TAX_FEE = originalFee.ORIG_TAX_FEE;
        fee._BURN_FEE = originalFee.ORIG_BURN_FEE;
        fee._CHARITY_FEE = originalFee.ORIG_CHARITY_FEE;
        fee._MARKETING_FEE = originalFee.ORIG_MARKETING_FEE;
        fee._LIQUIDITY_FEE = originalFee.ORIG_LIQUIDITY_FEE;
    }

    function tokenCrucifixion(uint256 amount) public override returns (bool) {
        _tokenCrucifixion(_msgSender(), burnAddress, amount);
        return true;
    }
}