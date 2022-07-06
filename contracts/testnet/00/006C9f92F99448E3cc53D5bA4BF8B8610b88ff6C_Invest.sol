// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Ownable.sol";
import "./Context.sol";
import "./IBEP20.sol";

// min busd:        10000000000000000000000 (10 000$)
// max busd:        10000000000000000000000000 (10 000 000$)
// buy rate:        10000000000000000 (0.001$)
// buyback rate:    20000000000000000 (0.002$)

// dlp deposit amount: 1000000000000000000000000000 (1 000 000 000 DLP)

struct SaleEvent {
    bool paused;
    uint256 minBusd;
    uint256 maxBusd;
    uint256 buyRate;
    uint256 buybackRate;
}

contract Invest is Ownable {
    IBEP20 private _dlpContract = IBEP20(0xE94df0295ACcF337b1f4c06BA962F35Db621d663);
    IBEP20 private _busdContract = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    SaleEvent private _event;
    uint private _totalInvestors = 0;
    mapping (uint => address) private _shares;
    mapping(address => uint256) private _invests;
    uint256 private _frozenDlp = 0;

    function _withdraw() private {
        uint256 busdBalance = _busdContract.balanceOf(address(this));
        require(busdBalance > 0, "Insufficient busd");

        _busdContract.transfer(_msgSender(), busdBalance);
    }

    function _withdrawDlp(address recipient) private {
        _dlpContract.transfer(recipient, _freeDlpAmount());
    }

    function _createEvent(SaleEvent memory ev) private returns (SaleEvent storage) {
        require(_event.minBusd == 0, "Event already started");
        require(ev.buybackRate > 0, "Buyback rate cannot be zero");
        require(ev.buyRate > 0, "Buy rate cannot be zero");
        require(ev.maxBusd > ev.minBusd, "Invalid limits");

        _event = ev;

        return _event;
    }

    function _freeDlpAmount() private view returns (uint256) {
        return _dlpContract.balanceOf(address(this)) - _frozenDlp;
    }

    function _invest(address investor, uint256 busdAmount) private {
        require(_event.paused == false, "Event is paused");
        require(_event.buyRate > 0, "Rate not specified");

        uint256 allowedBalance = _busdContract.allowance(investor, address(this));
        uint256 wantDlpAmount = busdAmount / _event.buyRate;

        require(allowedBalance >= busdAmount, "Insufficient allowed balance");
        require(_freeDlpAmount() >= wantDlpAmount, "No free DLP amount");

        _busdContract.transferFrom(investor, address(this), busdAmount);
        _invests[investor] += wantDlpAmount;
        _shares[_totalInvestors] = investor;
        _frozenDlp += wantDlpAmount;
        _totalInvestors += 1;
    }

    function _investBalance(address investor) private view returns (uint256 dlp, uint256 busd) {
        dlp = _invests[investor];
        busd = _invests[investor] * _event.buybackRate;

        return (dlp, busd);
    }

    function _buyback(uint256 busdAmount) private {
        uint256 busdBalance = _busdContract.balanceOf(address(this));

        require(busdBalance >= busdAmount, "Insufficient funds");
        require(busdAmount >= 1e18, "Cannot distibute less than 1 BUSD");
        require(_frozenDlp > 0, "No invests");

        uint256 distibuted = 0;

        for(uint256 i = 0; i < _totalInvestors; i++) {
            address investor = _shares[i];
            uint256 toDistibute = _invests[investor] * _event.buybackRate;

            if(distibuted >= busdAmount || toDistibute <= 0) {
                continue;
            }
            
            if(investor == address(0)) {
                continue;
            }

            if(_invests[investor] <= 0) {
                continue;
            }

            uint256 percentOfShare = _invests[investor] * 1e4 / _frozenDlp;
            uint256 profitAmountBusd = busdAmount * percentOfShare / 1e4;
            uint256 repaidDebtDlp = profitAmountBusd / _event.buybackRate;

            if(percentOfShare == 0) {
                continue;
            }

            if(profitAmountBusd == 0) {
                continue;
            }

            if(repaidDebtDlp == 0) {
                continue;
            }

            _busdContract.transfer(investor, profitAmountBusd);
            _invests[investor] -= repaidDebtDlp;
            _frozenDlp -= repaidDebtDlp;
        }
    }

    function createEvent(
        uint256 minBusd,
        uint256 maxBusd,
        uint256 buyRate,
        uint256 buybackRate
    ) public onlyOwner returns (SaleEvent memory) {
        return _createEvent(SaleEvent({
            paused: false,
            minBusd: minBusd,
            maxBusd: maxBusd,
            buyRate: buyRate,
            buybackRate: buybackRate
        }));
    }

    function invest(uint256 busdAmount) public {
        _invest(_msgSender(), busdAmount);
    }

    function withdraw() public onlyOwner {
        _withdraw();
    }

    function withdrawDlp() public onlyOwner {
        _withdrawDlp(_msgSender());
    }

    function currentEvent() public view returns  (SaleEvent memory) {
        return _event;
    }

    function contracts() public view returns (address dlp, address busd) {
        return (address(_busdContract), address(_dlpContract));
    }

    function balance() public view returns (uint256 dlp, uint256 busd, uint256 frozen, uint256 free) {
        dlp = _dlpContract.balanceOf(address(this));
        busd = _busdContract.balanceOf(address(this));
        frozen = _frozenDlp;
        free = dlp - frozen;

        return (dlp, busd, frozen, free);
    }

    function investBalanceOf(address investor) public view returns (uint256 dlp) {
        return (_invests[investor]);
    }

    function totalInvestors() public view returns (uint256) {
        return _totalInvestors;
    }

    function shareBy(uint256 index) public view returns (address) {
        return _shares[index];
    }

    function buyback(uint256 busdAmount) public onlyOwner {
        _buyback(busdAmount);
    }
}