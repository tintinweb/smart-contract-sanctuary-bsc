// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract RatesController is Ownable {
    using SafeMath for uint256;
    
    IERC20 public xSHEEP; // xSH33P
    IERC20 public SHEEP; // SH33P

    uint256[6] public xsheepBalances; // More xSH33P == faster payout rate
    uint256[5] public sheepBalances;  // More SH33P == bigger max payout rate

    uint256[7] public rates;
    uint16[6] public maxPayOutRates;
    uint256[15] public refBonuses;

    constructor(address _sheep, address _xsheep) {
        xSHEEP = IERC20(_xsheep); // Rates Token
        SHEEP = IERC20(_sheep); // SH33P Token (for levels + rewards)

        //set xSH33P balances
        xsheepBalances[0] = 35e18;   //   35 xSH33P
        xsheepBalances[1] = 65e18;   //   65 xSH33P
        xsheepBalances[2] = 110e18;  //  110 xSH33P
        xsheepBalances[3] = 250e18;  //  250 xSH33P
        xsheepBalances[4] = 600e18;  //  600 xSH33P
        xsheepBalances[5] = 1000e18; // 1000 xSH33P

        //assign rates values -- from 0.5% to 1.1% -- rates for holding xSH33P
        rates[0] = 50e16;  // 0.5% per day
        rates[1] = 60e16;  // 0.6% per day
        rates[2] = 70e16;  // 0.7% per day
        rates[3] = 80e16;  // 0.8% per day
        rates[4] = 90e16;  // 0.9% per day
        rates[5] = 100e16; // 1.0% per day
        rates[6] = 110e16; // 1.1% per day

        //set SH33P balances
        sheepBalances[0] = 50e18;  //  50 SH33P
        sheepBalances[1] = 100e18; // 100 SH33P
        sheepBalances[2] = 150e18; // 150 SH33P
        sheepBalances[3] = 200e18; // 200 SH33P
        sheepBalances[4] = 250e18; // 250 SH33P

        //assign maxPayOutRates values -- from 255 to 365 -- rates for holding SH33P
        maxPayOutRates[0] = 255; // 255% per year
        maxPayOutRates[1] = 277; // 277% per year
        maxPayOutRates[2] = 300; // 300% per year
        maxPayOutRates[3] = 321; // 321% per year
        maxPayOutRates[4] = 343; // 343% per year
        maxPayOutRates[5] = 365; // 365% per year

        refBonuses[0] = 5;  // 5%
        refBonuses[1] = 5;  // 5%
        refBonuses[2] = 5;  // 5%
        refBonuses[3] = 5;  // 5%
        refBonuses[4] = 5;  // 5%
        refBonuses[5] = 5;  // 5%
        refBonuses[6] = 5;  // 5%
        refBonuses[7] = 5;  // 5%
        refBonuses[8] = 5;  // 5%
        refBonuses[9] = 5;  // 5%
        refBonuses[10] = 5; // 5%
        refBonuses[11] = 5; // 5%
        refBonuses[12] = 5; // 5%
        refBonuses[13] = 5; // 5%
        refBonuses[14] = 5; // 5%
    }

    function setToken1(address tokenAddress) public onlyOwner {
        xSHEEP = IERC20(tokenAddress);
    }

    function setToken2(address tokenAddress) public onlyOwner {
        SHEEP = IERC20(tokenAddress);
    }

    function setToken1Balances(uint256[5] memory _balances) public onlyOwner {
        xsheepBalances = _balances;
    }

    function setToken2Balances(uint256[5] memory _balances) public onlyOwner {
        sheepBalances = _balances;
    }

    //set new rates function
    function setRates(uint256[6] memory _rates) public onlyOwner {
        rates = _rates;
    }

    //set new maxPayOutRates function
    function setMaxPayOutRates(uint16[6] memory _maxPayOutRates) public onlyOwner {
        maxPayOutRates = _maxPayOutRates;
    }

    function setRefBonuses(uint256[15] memory _refBonuses) public onlyOwner {
        refBonuses = _refBonuses;
    }

    function payOutRateOf(address _addr) public view returns (uint256) {
        uint256 balance = xSHEEP.balanceOf(_addr);
        uint256 rate;

        if (balance < xsheepBalances[0]) {
            rate = rates[0];
        }
        if (balance >= xsheepBalances[0] && balance < xsheepBalances[1]) {
            rate = rates[1];
        }
        if (balance >= xsheepBalances[1] && balance < xsheepBalances[2]) {
            rate = rates[2];
        }
        if (balance >= xsheepBalances[2] && balance < xsheepBalances[3]) {
            rate = rates[3];
        }
        if (balance >= xsheepBalances[3] && balance < xsheepBalances[4]) {
            rate = rates[4];
        }
        if (balance >= xsheepBalances[4] && balance < xsheepBalances[5]) {
            rate = rates[5];
        }
        if (balance >= xsheepBalances[5]) {
            rate = rates[6];
        }

        return rate;
    }

    function getMaxPayoutOf(address _user, uint256 amount) public view returns (uint256) {
        uint256 balance = SHEEP.balanceOf(_user);
        uint256 maxPayOut;

        if (balance < sheepBalances[0]) {
            maxPayOut = (amount * maxPayOutRates[0]) / 100;
        }
        if (balance >= sheepBalances[0] && balance < sheepBalances[1]) {
            maxPayOut = (amount * maxPayOutRates[1]) / 100;
        }

        if (balance >= sheepBalances[1] && balance < sheepBalances[2]) {
            maxPayOut = (amount * maxPayOutRates[2]) / 100;
        }

        if (balance >= sheepBalances[2] && balance < sheepBalances[3]) {
            maxPayOut = (amount * maxPayOutRates[3]) / 100;
        }

        if (balance >= sheepBalances[3] && balance < sheepBalances[4]) {
            maxPayOut = (amount * maxPayOutRates[4]) / 100;
        }

        if (balance >= sheepBalances[4]) {
            maxPayOut = (amount * maxPayOutRates[5]) / 100;
        }

        return maxPayOut;
    }

    function getRefBonus(uint8 level) public view returns (uint256) {
        return refBonuses[level];
    }
}