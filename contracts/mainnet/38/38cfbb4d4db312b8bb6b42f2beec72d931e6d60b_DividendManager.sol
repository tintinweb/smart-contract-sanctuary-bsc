// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";
import "SafeMath.sol";
import "ICallbackContract.sol";
import "ITBC10Token.sol";
import "ABDKMathQuad.sol";
import "RecoverableFunds.sol";

contract DividendManager is ICallbackContract, Ownable, RecoverableFunds {

    ITBC10Token public token;
    IERC20 public busd;

    uint256 internal _excludedSupply;
    bytes16 internal _dividendPerShare;
    mapping(address => bytes16) internal _dividendCorrections;
    mapping(address => uint256) internal _withdrawnDividends;
    mapping(address => bool) internal _excluded;

    event DividendsDistributed(address indexed from, uint256 amount);
    event DividendWithdrawn(address indexed to, uint256 amount);

    modifier onlyToken() {
        require(address(token) == _msgSender(), "DividendManager: caller is not the token");
        _;
    }

    function setToken(address _token) public onlyOwner {
        token = ITBC10Token(_token);
    }

    function setBUSD(address _busd) public onlyOwner {
        busd = IERC20(_busd);
    }

    function dividendCorrectionOf(address account) public view returns(uint256)  {
        return ABDKMathQuad.toUInt(_dividendCorrections[account]);
    }

    function dividendPerShare() public view returns(uint256)  {
        return ABDKMathQuad.toUInt(_dividendPerShare);
    }

    function distributeDividends(uint256 amount) public {
        uint256 correctedSupply = token.getRTotal() - _excludedSupply;
        require(correctedSupply > 0, "DividendManager: totalSupply should be greater than 0");
        require(amount > 0, "DividendManager: distributed amount should be greater than 0");
        busd.transferFrom(_msgSender(), address(this), amount);
        _dividendPerShare = ABDKMathQuad.add(
            _dividendPerShare,
            ABDKMathQuad.div(
                ABDKMathQuad.fromUInt(amount),
                ABDKMathQuad.fromUInt(correctedSupply)
            )
        );
        emit DividendsDistributed(msg.sender, amount);
    }

    function withdrawDividend() public {
        _withdrawDividend(_msgSender());
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        if (_excluded[account]) return 0;
        return accumulativeDividendOf(account) - _withdrawnDividends[account];
    }

    function withdrawnDividendOf(address account) public view returns(uint256) {
        return _withdrawnDividends[account];
    }

    function accumulativeDividendOf(address account) public view returns(uint256) {
        return ABDKMathQuad.toUInt(
            ABDKMathQuad.add(
                ABDKMathQuad.mul(_dividendPerShare, ABDKMathQuad.fromUInt(token.getROwned(account))),
                _dividendCorrections[account]
            )
        );
    }

    function includeInDividends(address account) public onlyOwner {
        _dividendCorrections[account] = ABDKMathQuad.neg(
            ABDKMathQuad.mul(
                _dividendPerShare,
                ABDKMathQuad.fromUInt(token.getROwned(account))
            )
        );
        _excluded[account] = false;
        _excludedSupply = _excludedSupply - token.getROwned(account);
    }

    function excludeFromDividends(address account) public onlyOwner {
        _withdrawDividend(account);
        _excluded[account] = true;
        _excludedSupply = _excludedSupply + token.getROwned(account);
    }

      function reflectCallback(uint256 tAmount, uint256 rAmount) override external onlyToken {}

    function reflectCallback(address account, uint256 tAmount, uint256 rAmount) override external onlyToken {}

    function increaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) override external onlyToken {
        if (_excluded[account]) {
            _excludedSupply = _excludedSupply + rAmount;
        } else {
            _decreaseDividendCorrection(account, _calculateDividendCorrection(ABDKMathQuad.fromUInt(rAmount)));
        }
    }

    function decreaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) override external onlyToken {
        if (_excluded[account]) {
            _excludedSupply = _excludedSupply - rAmount;
        } else {
            _increaseDividendCorrection(account, _calculateDividendCorrection(ABDKMathQuad.fromUInt(rAmount)));
        }
    }
    
    function decreaseTotalSupplyCallback(uint256 tAmount, uint256 rAmount) override external onlyToken {}

    function transferCallback(address from, address to, uint256 tFromAmount, uint256 rFromAmount, uint256 tToAmount, uint256 rToAmount) override external onlyToken {}

    function burnCallback(address account, uint256 tAmount, uint256 rAmount) override external onlyToken {}

    function _withdrawDividend(address account) internal {
        uint256 withdrawableDividend = withdrawableDividendOf(account);
        if (withdrawableDividend > 0) {
            _withdrawnDividends[account] = _withdrawnDividends[account] + withdrawableDividend;
            busd.transfer(account, withdrawableDividend);
            emit DividendWithdrawn(account, withdrawableDividend);
        }
    }

    function _calculateDividendCorrection(bytes16 value) internal view returns (bytes16) {
        return ABDKMathQuad.mul(_dividendPerShare, value);
    }

    function _increaseDividendCorrection(address account, bytes16 value) internal {
        _dividendCorrections[account] = ABDKMathQuad.add(_dividendCorrections[account], value);
    }

    function _decreaseDividendCorrection(address account, bytes16 value) internal {
        _dividendCorrections[account] = ABDKMathQuad.sub(_dividendCorrections[account], value);
    }

}