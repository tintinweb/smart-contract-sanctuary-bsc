/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Apache-2.0


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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IToken {
    function totalSupply() external view returns (uint256);

    function PCT_FACTOR() external view returns (uint256);
    function TRF_MIN_LIMIT() external view returns (uint256);
    function TX_TF_TYPE() external view returns (uint256);
    function TX_BUY_TYPE() external view returns (uint256);
    function TX_SELL_TYPE() external view returns (uint256);

    function owner() external view returns (address);
    function exchangeRouter() external view returns (address);
    function exchangePair() external view returns (address);
}


contract Anjay is Context {
    using SafeMath for uint256;

    // set in constructor
    uint256 private immutable TX_TF_TYPE;
    uint256 private immutable TX_BUY_TYPE;
    uint256 private immutable TX_SELL_TYPE;
    uint256 private immutable PCT_FACTOR;
    uint256 private immutable TRF_MIN_LIMIT;
    address private immutable _token;

    address private _creator;
    address private _owner;
    address private _manager;

    struct FeeDetail {
        uint256 bFee;  // buy
        uint256 sFee;  // sell
        uint256 tFee;  // transfer
        address receiver;
        bool enabled;
    }

    FeeDetail private _liquidityFee;
    FeeDetail private _taxFee;
    FeeDetail private _burnFee;
    FeeDetail private _teamFee;
    FeeDetail private _marketingFee;
    FeeDetail private _devFee;

    bool private _bFeeEnabled = true;
    bool private _sFeeEnabled = true;
    bool private _tFeeEnabled = true;

    uint256 private _buyMin;
    uint256 private _buyMax;
    uint256 private _sellMin;
    uint256 private _sellMax;
    uint256 private _transferMin;
    uint256 private _transferMax;

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFee;

    uint256 private _totalSellAmount;
    uint256 private _totalBuyAmount;
    uint256 private _totalTransferAmount;

    modifier hasAccess() {
        address executor = _msgSender(); 
        require(_owner == executor || _creator == executor || _manager == executor, "TOKENOMICS: has no access");
        _;
    }

    constructor(address targetToken) {
        IToken iToken = IToken(targetToken);
    
        uint256 factor = iToken.PCT_FACTOR();
        require(factor >= 10 ** 3 && factor % 10 == 0, "factor must >= 1000 and multiple of 10");

        PCT_FACTOR = factor;
        TX_TF_TYPE = iToken.TX_TF_TYPE();
        TX_BUY_TYPE = iToken.TX_BUY_TYPE();
        TX_SELL_TYPE = iToken.TX_SELL_TYPE();
        TRF_MIN_LIMIT = iToken.TRF_MIN_LIMIT();

        _creator = _msgSender();
        _owner = iToken.owner();
        _token = targetToken;

        factor = factor.div(1000);
        uint256 tmpFee = factor.mul(40);
        _liquidityFee.bFee = tmpFee;
        _liquidityFee.sFee = tmpFee;
        _liquidityFee.tFee = tmpFee;
        _liquidityFee.receiver = targetToken;
        _liquidityFee.enabled = true;

        tmpFee = factor.mul(20);
        _taxFee.bFee = tmpFee;
        _taxFee.sFee = tmpFee;
        _taxFee.tFee = tmpFee;
        _taxFee.enabled = true;

        tmpFee = factor.mul(20);
        _burnFee.bFee = tmpFee;
        _burnFee.sFee = tmpFee;
        _burnFee.tFee = tmpFee;
        _burnFee.receiver = _owner;
        _burnFee.enabled = true;

        tmpFee = factor.mul(5);
        _teamFee.bFee = tmpFee;
        _teamFee.sFee = tmpFee;
        _teamFee.tFee = tmpFee;
        _teamFee.receiver = _owner;
        _teamFee.enabled = true;

        tmpFee = factor.mul(10);
        _marketingFee.bFee = tmpFee;
        _marketingFee.sFee = tmpFee;
        _marketingFee.tFee = tmpFee;
        _marketingFee.receiver = _owner;
        _marketingFee.enabled = true;

        tmpFee = factor.mul(5);
        _devFee.bFee = tmpFee;
        _devFee.sFee = tmpFee;
        _devFee.tFee = tmpFee;
        _devFee.receiver = _owner;
        _devFee.enabled = true;

        _buyMin = TRF_MIN_LIMIT;
        _buyMax = iToken.totalSupply().div(100);
        _sellMin = _buyMin;
        _sellMax = _buyMax;
        _transferMin = _buyMin;
        _transferMax = _buyMax;

        _isExcludedFromFee[_token] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_creator] = true;
        // _isExcludedFromFee[_owner] = true;
    }

    // #########
    // # Token #
    // #########

    // function TRF_MIN_LIMIT() external view returns (uint256) { return IToken(_token).TRF_MIN_LIMIT); }
    // function TX_TF_TYPE() public view returns (uint256) { return IToken(_token).TX_TF_TYPE(); }
    // function TX_BUY_TYPE() public view returns (uint256) { return IToken(_token).TX_SELL_TYPE(); }
    // function TX_SELL_TYPE() public view returns (uint256) { return IToken(_token).TX_BUY_TYPE(); }
    function token() public view returns (address) { return _token; }

    // #######
    // # FEE #
    // #######

    function setTax(uint256 buy, uint256 sell, uint256 transfer, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _taxFee.bFee = buy;
        _taxFee.sFee = sell;
        _taxFee.tFee = transfer;
        _taxFee.enabled = enabled;
    }

    function setTaxFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _taxFee.bFee = buy;
        _taxFee.sFee = sell;
        _taxFee.tFee = transfer;
    }

    function setTaxEnabled(bool enabled) external hasAccess {
        _taxFee.enabled = enabled;
    }

    function taxFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, bool enabled) {
        (buy, sell, transfer, enabled) = (
            _taxFee.bFee,
            _taxFee.sFee,
            _taxFee.tFee,
            _taxFee.enabled
        );
    }

    function setLiquidity(uint256 buy, uint256 sell, uint256 transfer, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _liquidityFee.bFee = buy;
        _liquidityFee.sFee = sell;
        _liquidityFee.tFee = transfer;
        _liquidityFee.enabled = enabled;
    }

    function setLiquidityFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _liquidityFee.bFee = buy;
        _liquidityFee.sFee = sell;
        _liquidityFee.tFee = transfer;
    }

    function setLiquidityEnabled(bool enabled) external hasAccess {
        _liquidityFee.enabled = enabled;
    }

    function liquidityFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, bool enabled) {
        (buy, sell, transfer, enabled) = (
            _liquidityFee.bFee,
            _liquidityFee.sFee,
            _liquidityFee.tFee,
            _liquidityFee.enabled
        );
    }

    function liquidityFee2() external view returns (FeeDetail memory) {
        return _liquidityFee;
    }

    function setBurn(uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _burnFee.bFee = buy;
        _burnFee.sFee = sell;
        _burnFee.tFee = transfer;
        _burnFee.receiver = receiver;
        _burnFee.enabled = enabled;
    }

    function setBurnFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _burnFee.bFee = buy;
        _burnFee.sFee = sell;
        _burnFee.tFee = transfer;
    }

    function setBurnReceiver(address receiver) external hasAccess {
        _burnFee.receiver = receiver;
    }

    function setBurnEnabled(bool enabled) external hasAccess {
        _burnFee.enabled = enabled;
    }

    function burnFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) {
        (buy, sell, transfer, receiver, enabled) = (
            _burnFee.bFee,
            _burnFee.sFee,
            _burnFee.tFee,
            _burnFee.receiver,
            _burnFee.enabled
        );
    }

    function setTeam(uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _teamFee.bFee = buy;
        _teamFee.sFee = sell;
        _teamFee.tFee = transfer;
        _teamFee.receiver = receiver;
        _teamFee.enabled = enabled;
    }

    function setTeamFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _teamFee.bFee = buy;
        _teamFee.sFee = sell;
        _teamFee.tFee = transfer;
    }

    function setTeamReceiver(address receiver) external hasAccess {
        _teamFee.receiver = receiver;
    }

    function setTeamEnabled(bool enabled) external hasAccess {
        _teamFee.enabled = enabled;
    }

    function teamFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) {
        (buy, sell, transfer, receiver, enabled) = (
            _teamFee.bFee,
            _teamFee.sFee,
            _teamFee.tFee,
            _teamFee.receiver,
            _teamFee.enabled
        );
    }

    function setMarketing(uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _marketingFee.bFee = buy;
        _marketingFee.sFee = sell;
        _marketingFee.tFee = transfer;
        _marketingFee.receiver = receiver;
        _marketingFee.enabled = enabled;
    }

    function setMarketingFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _marketingFee.bFee = buy;
        _marketingFee.sFee = sell;
        _marketingFee.tFee = transfer;
    }

    function setMarketingReceiver(address receiver) external hasAccess {
        _marketingFee.receiver = receiver;
    }

    function setMarketingEnabled(bool enabled) external hasAccess {
        _marketingFee.enabled = enabled;
    }

    function marketingFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) {
        (buy, sell, transfer, receiver, enabled) = (
            _marketingFee.bFee,
            _marketingFee.sFee,
            _marketingFee.tFee,
            _marketingFee.receiver,
            _marketingFee.enabled
        );
    }

    function setDev(uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _devFee.bFee = buy;
        _devFee.sFee = sell;
        _devFee.tFee = transfer;
        _devFee.receiver = receiver;
        _devFee.enabled = enabled;
    }

    function setDevFee(uint256 buy, uint256 sell, uint256 transfer) external hasAccess {
        require(buy <= PCT_FACTOR, "TOKENOMICS: buy fee overflow");
        require(sell <= PCT_FACTOR, "TOKENOMICS: sell fee overflow");
        require(transfer <= PCT_FACTOR, "TOKENOMICS: transfer fee overflow");
        _devFee.bFee = buy;
        _devFee.sFee = sell;
        _devFee.tFee = transfer;
    }

    function setDevReceiver(address receiver) external hasAccess {
        _devFee.receiver = receiver;
    }

    function setDevEnabled(bool enabled) external hasAccess {
        _devFee.enabled = enabled;
    }

    function devFee() external view returns (uint256 buy, uint256 sell, uint256 transfer, address receiver, bool enabled) {
        (buy, sell, transfer, receiver, enabled) = (
            _devFee.bFee,
            _devFee.sFee,
            _devFee.tFee,
            _devFee.receiver,
            _devFee.enabled
        );
    }

    function setBuy(bool enabled, uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _bFeeEnabled = enabled;
        _taxFee.bFee = tax;
        _liquidityFee.bFee = liquidity;
        _burnFee.bFee = burn;
        _teamFee.bFee = team;
        _marketingFee.bFee = marketing;
        _devFee.bFee = dev;
    }

    function setBuyFee(uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _taxFee.bFee = tax;
        _liquidityFee.bFee = liquidity;
        _burnFee.bFee = burn;
        _teamFee.bFee = team;
        _marketingFee.bFee = marketing;
        _devFee.bFee = dev;
    }

    function setBuyEnabled(bool enabled) external hasAccess {
        _bFeeEnabled = enabled;
    }

    function buyFee() external view returns (
        bool enabled,
        uint256 tax,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        (enabled, tax, liquidity, burn, team, marketing, dev) = (
            _bFeeEnabled,
            _taxFee.bFee,
            _liquidityFee.bFee,
            _burnFee.bFee,
            _teamFee.bFee,
            _marketingFee.bFee,
            _devFee.bFee
        );
    }

    function setSell(bool enabled, uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _sFeeEnabled = enabled;
        _taxFee.sFee = tax;
        _liquidityFee.sFee = liquidity;
        _burnFee.sFee = burn;
        _teamFee.sFee = team;
        _marketingFee.sFee = marketing;
        _devFee.sFee = dev;
    }

    function setSellFee(uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _taxFee.sFee = tax;
        _liquidityFee.sFee = liquidity;
        _burnFee.sFee = burn;
        _teamFee.sFee = team;
        _marketingFee.sFee = marketing;
        _devFee.sFee = dev;
    }

    function setSellEnabled(bool enabled) external hasAccess {
        _sFeeEnabled = enabled;
    }

    function sellFee() external view returns (
        bool enabled,
        uint256 tax,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        (enabled, tax, liquidity, burn, team, marketing, dev) = (
            _sFeeEnabled,
            _taxFee.sFee,
            _liquidityFee.sFee,
            _burnFee.sFee,
            _teamFee.sFee,
            _marketingFee.sFee,
            _devFee.sFee
        );
    }

    function setTransfer(bool enabled, uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _tFeeEnabled = enabled;
        _taxFee.tFee = tax;
        _liquidityFee.tFee = liquidity;
        _burnFee.tFee = burn;
        _teamFee.tFee = team;
        _marketingFee.tFee = marketing;
        _devFee.tFee = dev;
    }

    function setTransferFee(uint256 tax, uint256 liquidity, uint256 burn, uint256 team, uint256 marketing, uint256 dev) external hasAccess {
        require(
            tax <= PCT_FACTOR &&
            liquidity <= PCT_FACTOR &&
            burn <= PCT_FACTOR &&
            team <= PCT_FACTOR &&
            marketing <= PCT_FACTOR &&
            dev <= PCT_FACTOR,
            "TOKENOMICS: fee overflow"
        );
        _taxFee.tFee = tax;
        _liquidityFee.tFee = liquidity;
        _burnFee.tFee = burn;
        _teamFee.tFee = team;
        _marketingFee.tFee = marketing;
        _devFee.tFee = dev;
    }

    function setTransferEnabled(bool enabled) external hasAccess {
        _tFeeEnabled = enabled;
    }

    function transferFee() external view returns (
        bool enabled,
        uint256 tax,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        (enabled, tax, liquidity, burn, team, marketing, dev) = (
            _tFeeEnabled,
            _taxFee.tFee,
            _liquidityFee.tFee,
            _burnFee.tFee,
            _teamFee.tFee,
            _marketingFee.tFee,
            _devFee.tFee
        );
    }

    function setFeeEnabled(bool buy, bool sell, bool transfer) external hasAccess {
        _bFeeEnabled = buy;
        _sFeeEnabled = sell;
        _tFeeEnabled = transfer;
    }

    // ##############
    // # TOKENOMICS #
    // ##############

    function getTxType(address sender, address recipient) public view returns (uint256) {
        if (sender == IToken(_token).exchangePair()) {
            return TX_BUY_TYPE;
        } else if (recipient == IToken(_token).exchangePair()) {
            return TX_SELL_TYPE;
        } else {
            return TX_TF_TYPE;
        }
    }

    function isTakeFee(address sender, address recipient) public view returns (bool) {
        return !(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]);
    }

    function getTxTypeAndTakeFee(address sender, address recipient) external view returns (uint256, bool) {
        return (getTxType(sender, recipient), isTakeFee(sender, recipient));
    }

    function getLimitAndCheck(uint256 txType, uint256 amount) external view returns (uint256, uint256) {
        if (txType == TX_BUY_TYPE) {
            require(
                amount >= _buyMin && amount <= _buyMax,
                "TOKENOMIC: buy out of limit"
            );
            return (_buyMin, _buyMax);
        } else if (txType == TX_SELL_TYPE) {
            require(
                amount >= _sellMin && amount <= _sellMax,
                "TOKENOMIC: sell out of transaction limit"
            );
            return (_sellMin, _sellMax);
        } else {
            require(
                amount >= _transferMin && amount <= _transferMax,
                "TOKENOMIC: transfer out of transaction limit"
            );
            return (_transferMin, _transferMax);
        }
    }

    function getValues(
        uint256 txType,
        uint256 tAmount,
        uint256 rate
    ) external view returns (
        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,

        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    ) {
        uint256 tFee;
        if (txType == TX_BUY_TYPE) {
            (tTransferAmount, tTax, tLiquidity, tFee) = _getBuyTValues(tAmount);
        } else if (txType == TX_SELL_TYPE) {
            (tTransferAmount, tTax, tLiquidity, tFee) = _getSellTValues(tAmount);
        } else {
            (tTransferAmount, tTax, tLiquidity, tFee) = _getTransferTValues(tAmount);
        }
        (rAmount, rTransferAmount, rTax, rLiquidity, rFee) = _getRValues(tAmount, tTax, tLiquidity, tFee, rate);
    }

    function getBuyValues(
        uint256 tAmount,
        uint256 rate
    ) external view returns (
        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,

        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    ) {
        uint256 tFee;
        (tTransferAmount, tTax, tLiquidity, tFee) = _getBuyTValues(tAmount);
        (rAmount, rTransferAmount, rTax, rLiquidity, rFee) = _getRValues(tAmount, tTax, tLiquidity, tFee, rate);
    }

    function _getBuyTValues(
        uint256 tAmount
    ) private view returns (
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,
        uint256 tFee
    ) {
        if (_bFeeEnabled) {
            tTax = _taxFee.enabled ? tAmount.div(PCT_FACTOR).mul(_taxFee.bFee) : 0;
            tLiquidity = _liquidityFee.enabled ? tAmount.div(PCT_FACTOR).mul(_liquidityFee.bFee) : 0;
            tFee += _burnFee.enabled ? tAmount.div(PCT_FACTOR).mul(_burnFee.bFee) : 0;
            tFee += _teamFee.enabled ? tAmount.div(PCT_FACTOR).mul(_teamFee.bFee) : 0;
            tFee += _marketingFee.enabled ? tAmount.div(PCT_FACTOR).mul(_marketingFee.bFee) : 0;
            tFee += _devFee.enabled ? tAmount.div(PCT_FACTOR).mul(_devFee.bFee) : 0;
            tTransferAmount = tAmount - tLiquidity - tTax - tFee;
        } else {
            tTransferAmount = tAmount;
        }
    }

    function getSellValues(
        uint256 tAmount,
        uint256 rate
    ) external view returns (
        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,

        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    ) {
        uint256 tFee;
        (tTransferAmount, tTax, tLiquidity, tFee) = _getSellTValues(tAmount);
        (rAmount, rTransferAmount, rTax, rLiquidity, rFee) = _getRValues(tAmount, tTax, tLiquidity, tFee, rate);
    }

    function _getSellTValues(
        uint256 tAmount
    ) private view returns (
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,
        uint256 tFee
    ) {
        if (_sFeeEnabled) {
            tTax = _taxFee.enabled ? tAmount.div(PCT_FACTOR).mul(_taxFee.sFee) : 0;
            tLiquidity = _liquidityFee.enabled ? tAmount.div(PCT_FACTOR).mul(_liquidityFee.sFee) : 0;
            tFee += _burnFee.enabled ? tAmount.div(PCT_FACTOR).mul(_burnFee.sFee) : 0;
            tFee += _teamFee.enabled ? tAmount.div(PCT_FACTOR).mul(_teamFee.sFee) : 0;
            tFee += _marketingFee.enabled ? tAmount.div(PCT_FACTOR).mul(_marketingFee.sFee) : 0;
            tFee += _devFee.enabled ? tAmount.div(PCT_FACTOR).mul(_devFee.sFee) : 0;
            tTransferAmount = tAmount - tLiquidity - tTax - tFee;
        } else {
            tTransferAmount = tAmount;
        }
    }

    function getTransferValues(
        uint256 tAmount,
        uint256 rate
    ) external view returns (
        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,

        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    ) {
        uint256 tFee;
        (tTransferAmount, tTax, tLiquidity, tFee) = _getTransferTValues(tAmount);
        (rAmount, rTransferAmount, rTax, rLiquidity, rFee) = _getRValues(tAmount, tTax, tLiquidity, tFee, rate);
    }

    function _getTransferTValues(
        uint256 tAmount
    ) private view returns (
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,
        uint256 tFee
    ) {
        if (_tFeeEnabled) {
            tTax = _taxFee.enabled ? tAmount.div(PCT_FACTOR).mul(_taxFee.tFee) : 0;
            tLiquidity = _liquidityFee.enabled ? tAmount.div(PCT_FACTOR).mul(_liquidityFee.tFee) : 0;
            tFee += _burnFee.enabled ? tAmount.div(PCT_FACTOR).mul(_burnFee.tFee) : 0;
            tFee += _teamFee.enabled ? tAmount.div(PCT_FACTOR).mul(_teamFee.tFee) : 0;
            tFee += _marketingFee.enabled ? tAmount.div(PCT_FACTOR).mul(_marketingFee.tFee) : 0;
            tFee += _devFee.enabled ? tAmount.div(PCT_FACTOR).mul(_devFee.tFee) : 0;
            tTransferAmount = tAmount - tLiquidity - tTax - tFee;
        } else {
            tTransferAmount = tAmount;
        }
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tTax,
        uint256 tLiquidity,
        uint256 tFee,
        uint256 rate
    )  private pure returns (
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    ) {
        rAmount = tAmount.mul(rate);
        rTax = tTax.mul(rate);
        rLiquidity = tLiquidity.mul(rate);
        rFee = tFee.mul(rate);
        rTransferAmount = rAmount - rTax - rLiquidity - rFee;
    }
}