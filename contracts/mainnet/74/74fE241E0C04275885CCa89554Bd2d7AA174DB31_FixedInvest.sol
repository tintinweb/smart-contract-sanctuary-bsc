/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
// File: lib/Date.sol

// contracts/lib/Date.sol

pragma solidity ^0.8.0;

library Date {
    
    function date8(uint timestamp) public pure returns (uint){
        (uint y,uint m, uint d) = daysToDate(timestamp);
        return y * 10000 + m * 100 + d;
    }

    //timezone utc
    function daysToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        uint SECONDS_PER_DAY = 24 * 60 * 60;
        uint OFFSET19700101 = 2440588;

        uint _days = timestamp / SECONDS_PER_DAY;
        uint L = _days + 68569 + OFFSET19700101;
        uint N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * year / 4 + 31;
        month = 80 * L / 2447;
        day = L - 2447 * month / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;
    }
}
// File: InvestBusiness.sol

// contracts/InvestBusiness.sol

pragma solidity ^0.8.0;


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Router01 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract FixedInvest {

    using Date for uint;

    struct Invest {
        uint no;
        uint total;
        uint invested;
    }

    struct InvestArray {
        address account;
        mapping(uint => Invest) values;
        //[l, r)
        uint l;
        uint r;
    }

    event DepositEvent(address indexed account, uint no, uint value, uint timestamp);
    event InvestEvent(uint indexed no, uint value, uint timestamp);
    event InvestEvent(address indexed account, uint value, uint timestamp);

    mapping(address => InvestArray) private _data;
    uint256 public global_no;

    mapping(address => uint) private _lastInvest;

    // BSC-MainNet
    address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant MPC = 0x3E689F6c41d7d7A705A5fBF14b8E19af295452B5;

    constructor(){
        global_no = 1;
        IERC20(USDT).approve(ROUTER, 10 ** 30);
    }

    function deposit(uint value) public {
        uint UNIT = 10 ** 18;
        require(value == 1000 * UNIT || value == 3000 * UNIT || value == 8000 * UNIT, "Bad amount");
        IERC20(USDT).transferFrom(msg.sender, address(this), value);
        InvestArray storage arr = _data[msg.sender];
        if (arr.account == address(0)) {
            arr.account = msg.sender;
        }
        _push(arr, global_no++, value);
    }

    function invest(address[] calldata path) public {
        require(path.length == 3, "Bad path");
        require(path[0] == USDT && path[1] == WBNB && path[2] == MPC, "Bad path");
        uint lst = _lastInvest[msg.sender];
        uint cur = block.timestamp.date8();
        require(cur > lst, "Invalid");

        InvestArray storage arr = _data[msg.sender];
        uint sum = _release(arr);

        require(sum > 0, "Fail: 0");
        _lastInvest[msg.sender] = cur;
        IUniswapV2Router01(ROUTER).swapExactTokensForTokens(sum, 0, path, msg.sender, block.timestamp + 1200);
    }

    function info() view public returns (uint, uint){
        return info(msg.sender);
    }

    function info(address addr) view public returns (uint, uint){
        uint lst = _lastInvest[addr];
        uint cur = block.timestamp.date8();
        return (cur == lst ? 1 : 0, _getRelease(_data[addr]));
    }

    function _push(InvestArray storage arr, uint256 no, uint256 value) internal {
        Invest storage invest0 = arr.values[arr.r];
        invest0.total = value;
        invest0.no = no;
        arr.r += 1;
        emit DepositEvent(arr.account, no, value, block.timestamp);
    }

    function _release(InvestArray storage arr) internal returns (uint){
        uint l = arr.l;
        uint r = arr.r;
        if (l == r) {
            return 0;
        }
        uint time = block.timestamp;
        uint sum = 0;
        for (uint i = l; i < r; i++) {
            Invest storage invest0 = arr.values[i];
            uint256 unit = invest0.total / 100;
            invest0.invested += unit;
            sum += unit;
            emit InvestEvent(invest0.no, unit, time);
            if (invest0.total == invest0.invested) {
                l++;
            }
        }
        arr.l = l;
        emit InvestEvent(arr.account, sum, time);
        return sum;
    }

    function _getRelease(InvestArray storage arr) internal view returns (uint){
        uint l = arr.l;
        uint r = arr.r;
        if (l == r) {
            return 0;
        }
        uint sum = 0;
        for (uint i = l; i < r; i++) {
            Invest storage invest0 = arr.values[i];
            uint256 unit = invest0.total / 100;
            sum += unit;
        }
        return sum;
    }
}