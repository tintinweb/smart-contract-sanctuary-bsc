// SPDX-License-Identifier: MIT

//SAV#8
pragma solidity >=0.8.4 <=0.8.15;

import "./Ownable.sol";
import "./Pausable.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./ReentrancyGuard.sol";

interface Burnable {
    function burn(uint256 amount) external returns (bool);

    function burnFrom(address account, uint256 amount) external returns (bool);
}

contract WOCPAD is Ownable, Pausable, ReentrancyGuard {
    // initial constants
    address private _coinFromAddress;
    address private _coinToAddress; //PLC usually
    uint256 private _p0; //initial price in coinFrom to buy 1 coinTo
    uint256 private _pmax;
    uint256 private _dmax;

    uint8 private _coinFromDecimals; //IERC20(_coinFromAddress).decimals()
    uint8 private _coinToDecimals;

    //state variables
    uint256 private _ps;
    uint256 private _ds;
    uint64 private _countSales;

    bool private _soldout;
    uint256 private _withdrawed;

    constructor(
        address aFrom,
        address aTo,
        uint256 p0,
        uint256 pmax,
        uint256 dmax
    ) Ownable() Pausable() {
        require(
            aFrom != address(0) &&
                aTo != address(0) &&
                dmax > 0 &&
                pmax > p0 &&
                p0 > 0,
            "Could not create contract, some init constants are wrong"
        );
        _coinFromAddress = aFrom;
        _coinToAddress = aTo; //PLC usually
        _p0 = p0; //in Wei
        _pmax = pmax; //in Wei
        _dmax = dmax; //in Wei

        _coinFromDecimals = IERC20Metadata(_coinFromAddress).decimals();
        _coinToDecimals = IERC20Metadata(_coinToAddress).decimals();
        _ds = 0; //nothing sold yet
        _withdrawed = 0;
        _countSales = 0;

        _soldout = false; //not soldout

        if (!paused()) {
            //initially paused!
            setPause(true);
        }
    }

    /**
     * deposit supposed to be called only once
     * this function will invoke coinTo.transferFrom
     * deposit will move contract from paused to unpased
     */

    //SAV#9
    function deposit() external onlyOwner {
        uint256 balance = IERC20(_coinToAddress).balanceOf(address(this));
        require(
            !isSoldout() && _ds == 0 && balance == 0,
            "Contract is already depositet earlier"
        );

        // SAV#1
        require(
            IERC20(_coinToAddress).transferFrom(
                msg.sender,
                address(this),
                _dmax
            ),
            "the owner does not have enough PTC to deposit the contract"
        );
        //SAV#6
        require(
            IERC20(_coinToAddress).approve(msg.sender, _dmax),
            "the contract cannot approve the owner to burn PTC if necessary"
        );

        setPause(false);
    }

    /**
     * buy some amount of PTC for calculated amound of USDC depending on price change
     */

    //SAV#9
    function sell(uint256 ptcAmount) external whenNotPaused nonReentrant {
        //buy specific amount of PTC
        require(
            !isSoldout(),
            "Sell impossible: Contract shouldn't be in a soldout state"
        );
        require(
            IERC20(_coinToAddress).balanceOf(address(this)) >= ptcAmount,
            "Sell immpossible: not enough PTC balance"
        );
        require(
            _ds + ptcAmount <= _dmax,
            "Sell immpossible: PTC limit reached (ds+amount>=dmax)"
        );

        uint256 oldFromBalance = IERC20(_coinFromAddress).balanceOf(
            address(this)
        );
        uint256 oldToBalance = IERC20(_coinToAddress).balanceOf(address(this));

        uint256 samount = _getS(ptcAmount);

        require(
            IERC20(_coinFromAddress).balanceOf(msg.sender) >= samount,
            "Sell imposible, because buyer balance < needed amount"
        );

        require(
            IERC20(_coinFromAddress).allowance(msg.sender, address(this)) >=
                samount,
            "Sell imposible, because allowance < needed amount"
        );

        // SAV#4
        _ds += ptcAmount;
        _countSales += 1;

        bool success = IERC20(_coinFromAddress).transferFrom(
            msg.sender,
            address(this),
            samount
        );

        require(success, "Sell went wrong, transferFrom finished with error");
        // SAV#4
        if (_ds == _dmax) {
            _soldout = true;
        }
        //SAV#1
        require(
            IERC20(_coinToAddress).transfer(msg.sender, ptcAmount),
            "transfer to the buyer was not completed, the sale occurred with an error"
        );

        /* 
checking invariance
first: our newBalance in FROM coin should increase by payed amount sharp
second: our newBalance in TO coin should decrease for sold amount sharp
*/
        assert(
            IERC20(_coinFromAddress).balanceOf(address(this)) ==
                oldFromBalance + samount
        );
        assert(
            IERC20(_coinToAddress).balanceOf(address(this)) ==
                oldToBalance - ptcAmount
        );
    }

    /**
     * Calculating price for specific dx
     * multiply dx by tg(a)
     */
    function _getpx(uint256 dx) private view returns (uint256) {
        //SAV#5
        require(
            // removed _ds + dx >= 0 &&
            _ds + dx <= _dmax,
            "getpx couldn't calculate price for d more than dmax"
        );
        return _p0 + (dx * (_pmax - _p0)) / _dmax;
    }

    /**
     * simple approach, mult average price for this range by length of range
     */
    function _getS(uint256 dx) private view returns (uint256) {
        //SAV#5
        require(
            //removed _ds + dx >= 0 &&
            _ds + dx <= _dmax,
            "getS: dx should be in 0 .. dmax-ds range"
        );
        uint256 avgPrice = (_getpx(_ds) + _getpx(_ds + dx)) / 2;

        return (dx * avgPrice) / 10**_coinToDecimals;
    }

    /**
     * withdraw whole amount of the secont coin
     */
    function withdraw() external onlyOwner {
        uint256 balance = IERC20(_coinFromAddress).balanceOf(address(this));
        require(balance > 0, "Nothing to withdraw");
        //SAV#1
        require(
            IERC20(_coinFromAddress).transfer(msg.sender, balance),
            "withdrawal did not take place"
        );
        _withdrawed += balance;
    }

    /**
     * burn coins belonged to contract
     * and if you burn all the coins - change the state to soldout
     */
    //SAV#9
    function burn(uint256 amount) external onlyOwner {
        require(
            IERC20(_coinToAddress).balanceOf(address(this)) >= amount,
            "Burn immpossible: not enough PTC balance"
        );
        require(
            _ds + amount <= _dmax,
            "Burn immpossible: PTC limit reached (ds+amount>=dmax)"
        );

        // SAV#4
        _ds += amount;

        //SAV#6
        require(
            Burnable(_coinToAddress).burn(amount),
            "wocpad ptc burn failed"
        );

        if (_ds == _dmax) {
            _soldout = true;
        }
    }

    function setPause(bool pause_flag) public onlyOwner {
        if (pause_flag) {
            _pause();
        } else {
            _unpause();
        }
    }

    function isSoldout() public view returns (bool) {
        return _soldout;
    }

    //SAV#9
    function withdrawed() external view onlyOwner returns (uint256) {
        return _withdrawed;
    }

    //SAV#9
    function getp0() external view returns (uint256) {
        return (_p0);
    }

    //SAV#9
    function getpmax() external view returns (uint256) {
        return (_pmax);
    }

    //SAV#9
    function getdmax() external view returns (uint256) {
        return (_dmax);
    }

    //SAV#9
    function getCoinFromAddress() external view returns (address) {
        return _coinFromAddress;
    }

    //SAV#9
    function getCoinToAddress() external view returns (address) {
        return _coinToAddress;
    }

    //SAV#9
    function getds() external view returns (uint256) {
        return _ds;
    }

    //SAV#9
    function getpx(uint256 dx) external view returns (uint256) {
        return _getpx(dx);
    }

    //SAV#9
    function getS(uint256 dx) external view returns (uint256) {
        return _getS(dx);
    }
}