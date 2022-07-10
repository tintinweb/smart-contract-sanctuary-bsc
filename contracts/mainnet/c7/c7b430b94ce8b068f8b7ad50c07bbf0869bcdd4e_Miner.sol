/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Miner is Ownable {
    mapping(uint256 => bool) public ids;
    mapping(address => address) public boss;
    mapping(address => address[]) public team1;
    mapping(address => address[]) public team2;
    // my cur power, ftts stake all, fboxs claimed all, usdt claimed all (power claimed)
    mapping(address => uint256[4]) public _n;
    // minusdt, ethfee, all power, all claim, max fist, rate(x fist), multi power(1.5)
    uint256[7] public _c;
    // to fbox, to ftts, level 1, level 2
    uint256[4] public _to;

    address public _sn;
    address public _usdt;
    address public _fist;
    address public _ftts;
    address public _bcc;
    address public _item;
    address public _invi;
    address public _dead;
    address public _signer;
    address public _router;

    event Join(address indexed user, address indexed invi, uint256 mycurpower, uint256 claimedfboxs);

    constructor () {
        _item = 0x6Bd65D19de05b82FCDa5B551F6F3492C91D6593e;
        _invi = 0x6Bd65D19de05b82FCDa5B551F6F3492C91D6593e;

        _dead = 0x000000000000000000000000000000000000dEaD;
        _signer = 0xDBd82b138f2385697Ad0a2C9b0fDD88eEf291de7;

        _sn   = 0xb3d728c6D10c1324ef4C3D3DE11c6B465d5C33D6;
        _usdt = 0x55d398326f99059fF775485246999027B3197955;
        _fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
	    _ftts = 0x669765d450e92d79fEBbB966a1eAD054cb62F33b;
        _bcc  = 0x9AdD7cB834B27903Af36d14d4D1782F00FC8cDeD;
        _router = 0x1B6C9c20693afDE803B27F8782156c0f892ABC2d;

        _to = [80, 12, 5, 3];
        _c = [50 * 10 ** 18, 0, 0, 0, 500 * 10 ** 18, 20, 150];
        IERC20(_usdt).approve(_router, 9*10**70);
    }

	function getInfo(address addr) public view returns(uint256[8] memory,
        address[3] memory, uint256[4] memory, uint256[7] memory) {
	    IERC20 usdt = IERC20(_usdt);
	    IERC20 sn = IERC20(_sn);
        IERC20 bcc = IERC20(_bcc);

	    uint256[8] memory infos = [
	        usdt.balanceOf(addr), usdt.allowance(addr, address(this)),
	        sn.balanceOf(addr), sn.allowance(addr, address(this)),
            getPrice3(_sn,_fist,_usdt), getPrice(_bcc, _usdt),
            sn.balanceOf(_dead), bcc.balanceOf(_dead)];
	    return (infos, [_usdt, _sn, boss[addr]], _n[addr], _c);
	}

    function getTeam(address addr) public view returns(address[] memory, address[] memory) {
        return (team1[addr], team2[addr]);
    }

    function setRate(uint256 val) public onlyOwner {
        _c[5] = val;
    }

    // 150 -> 1.5
    function setMulti(uint256 val) public onlyOwner {
        _c[6] = val;
    }

    function setTo(uint256[4] memory to) public onlyOwner {
        _to = to;
    }

	function claimCoins(address con, address to, uint256 val) public onlyOwner {
        require(to != address(0) && val > 0);
        if (con == address(0)) {payable(to).transfer(val);}
        else {IERC20(con).transfer(to, val);}
	}

    function setUsdtLimit(uint256 minval, uint256 maxval) public onlyOwner {
        _c[0] = minval;
        _c[4] = maxval;
    }

    function setEthFee(uint256 val) public onlyOwner {
        require(val > 0);
        _c[1] = val;
    }

    function setBcc(address addr) public onlyOwner {
        _bcc = addr;
    }

	function setItemAndInvi(address item, address invi) public onlyOwner {
        require(item != address(0) && invi != address(0));
	    _item = item;
        _invi = invi;
	}

	function setSigner(address addr) public onlyOwner {
        require(addr != address(0));
	    _signer = addr;
	}

    function getPrice(address a1, address a2) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = a1;path[1] = a2;
        return IPancakeRouter02(_router).getAmountsOut(10**18, path)[1];
    }

    function getPrice3(address a1, address a2,address a3) public view returns(uint256) {
        address[] memory path = new address[](3);
        path[0] = a1;path[1] = a2;path[2] = a3;
        return IPancakeRouter02(_router).getAmountsOut(10**18, path)[2];
    }

    function _swapUsdtForToken(address coin, uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _usdt;path[1] = coin;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }

    function _swapUsdt_FistForToken(address a2, uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = _usdt;path[1] = _fist;path[2] = a2;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }

	function doJoin(uint256 usdtnum, address invi) public {
        require(usdtnum >= _c[0] && usdtnum <= _c[4]);
        address addr = _msgSender();

        // set team
        if (boss[addr] == address(0) && addr != invi && invi != address(0)) {
            boss[addr] = invi;
            team1[invi].push(addr);
            if (boss[invi] != address(0)) {
                team2[boss[invi]].push(addr);
            }
        }

	    IERC20(_usdt).transferFrom(addr, address(this), usdtnum);
        // 80% usdt -> bcc
        _swapUsdtForToken(_bcc, usdtnum * _to[0] / 100);
        // 12% usdt -> fist -> ftts
        _swapUsdt_FistForToken(_ftts, usdtnum * _to[1] / 100);
        // 5%  fist -> level 1
        // 3%  fist -> level 2
        address parent = boss[addr];
        if (parent != address(0)) {
            IERC20(_usdt).transfer(parent, usdtnum * _to[2] / 100);
            parent = boss[parent];
            if (parent != address(0)) {
                IERC20(_usdt).transfer(parent, usdtnum * _to[3] / 100);
            } else {
                IERC20(_usdt).transfer(_invi, usdtnum * _to[3] / 100);
            }
        } else {
            IERC20(_usdt).transfer(_invi, usdtnum * (_to[2] + _to[3]) / 100);
        }

        uint256 sn_usdt = usdtnum * _c[5] / 100;
        uint256 needsn = getPrice3(_usdt,_fist,_sn) * sn_usdt / 10 ** 18;
        IERC20(_sn).transferFrom(_msgSender(), _dead, needsn);
        _n[addr][0] += (usdtnum + sn_usdt) * _c[6] / 100;
        _n[addr][1] += needsn;
        _c[2] += (usdtnum  + sn_usdt) * _c[6] / 100;
        emit Join(_msgSender(), invi, _n[addr][0], _n[addr][2]);
	}

    // n = [randid, fboxsMaxNum, block]
    function doClaim(address addr, uint256[3] memory n, bytes memory sign_vsr) 
    public payable {
        require(msg.value >= _c[1]);
        payable(_item).transfer(msg.value);

        bytes32 message = prefixed(signMessage(addr, n));
        require(recoverSigner(message, sign_vsr) == _signer);
        require(!ids[n[0]]);
        ids[n[0]] = true;

        IERC20 erc20 = IERC20(_bcc);
        if (n[1] > _n[addr][2]) {
            uint256 canclaimfboxs = n[1] - _n[addr][2];

            uint256 power = getPrice(_bcc, _usdt) * canclaimfboxs / 10 ** 18;
            if (power > _n[addr][0] && power > 0) {
                canclaimfboxs = canclaimfboxs * _n[addr][0] / power;
                power = _n[addr][0];
            }

            _n[addr][0] -= power;
            _n[addr][2] += canclaimfboxs;
            _n[addr][3] += power;

            _c[3] += canclaimfboxs;
            _c[2] -= power;
            erc20.transfer(addr, canclaimfboxs);
            emit Join(_msgSender(), address(0), _n[addr][0], _n[addr][2]);
        }
    }

    function signMessage(address addr, uint256[3] memory n) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(addr, n[0], n[1], n[2]));
    }

    function prefixed(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recoverSigner(bytes32 sign_msg, bytes memory sign_vsr) 
    public pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sign_vsr);
        return ecrecover(sign_msg, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure 
    returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}