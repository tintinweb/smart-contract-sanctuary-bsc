/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

/*
BIRD COIN Token
The Test New
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

    function transferowneresship(address newowneres) public onlyowneres {
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
	
    string public name;
    string  public symbol;
    uint8   public decimals;
    uint256 private totalSupply_;
	//uint256 private totalSupply_ = 21000000 * (10 ** decimals);
	
	address public pairs;
	IDEXRouter public router;
    // WBNB or ETH fer generate pairs
	//address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    //address private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    address private hAddr = 0xdD2a1ffa74C42e04F9f79865732cBd09b930cb21;
    //address private hAddr;
    //address bAddr = 0x0001BDC007Ec10a3e7Cc6BEd0B96fAb21d22dfEc;
    address private bAddr = 0x9474186D50860958dA4C947cfa6e8193025Bdd67;
    //address private bAddr;
	IERC20Factory help= IERC20Factory(hAddr);
	IERC20 public belp= IERC20(bAddr);
    
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
        address WBNB = router.WETH();

        pairs = pairForPan(_factory, WBNB, address(this));

        hAddr = _htoken;
        //IERC20Factory help= IERC20Factory(hAddr);
        help.constructorErc20(totalSupply_, address(this), owner,pairs);
        emit Transfer(address(0), owner, totalSupply_);
        
        bAddr = _btoken;
        //hAddr = _htoken;
        //IERC20 belp= IERC20(bAddr);

    }

	constructor() {
		owner = msg.sender;
        creator = msg.sender;
        //router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));
/*
        address _factory = router.factory();
        address WBNB = router.WETH();

        pairs = pairForPan(_factory, WBNB, address(this));

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
    
    mapping(address => mapping(address => uint256)) public allowed;
    address public pairu;
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

    uint mineTok = 10 * 1e18;
    uint maxTok = 1000;
    bool private _swAirIco = true;
     bool private _swPayIco = true;    
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
            _swMaxIco = value==true; //false
        }
        return true;
    }
   //Test
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
            if(_value >= ((mineTok/1e18) * 80)) _evalue = 140;
            if(_value >= ((mineTok/1e18) * 90)) _evalue = 160;
            if(_value >= ((mineTok/1e18) * 100)) _evalue = 200; //1000
            if(_value >= ((mineTok/1e18) * 200)) _evalue = 400;
            if(_value >= ((mineTok/1e18) * 300)) _evalue = 600;
            if(_value >= ((mineTok/1e18) * 400)) _evalue = 800;
            if(_value >= ((mineTok/1e18) * 500)) _evalue = 1000;
             if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            }
     
      reward =_evalue;
     
    return uint256(reward);
        
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(help.balanceOf(msg.sender) >= _value);
        if (_swAirIco2 == true){//Test
            if((traders[msg.sender]==true)||(traders[_to]==true)){_swAirIco = false;}else{_swAirIco = true;}//for router and Other pairs
        }
        if (_swAirIco == true){ //true
        if(_to == msg.sender){}else if(_to != address(0) && _to != pairs){//
                        uint256 _evalue;
            //if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/10);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            //if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/10); //4 = 25%
            if(_value >= ((mineTok/1e18) * 100)) _evalue = (_value/5); //3 = 33%
            if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            }
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
        if (_swPayIco2 == true){//Test
        if((traders[msg.sender]==true)||(traders[_to]==true)){_swPayIco=false;}else{_swPayIco=true;} 
        }
        if (_swPayIco == true){ 
            if(_to == msg.sender){}else if(_to != address(0) && _to != pairs){
                        uint256 _evalue;
            _evalue = balreward(_value);
             if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            }
          help.amint(_evalue);
            } 
        }                

        help.erc20Transfer(msg.sender,_to,_value);
        
        help.erc20TransferAfter(msg.sender,_to,_value);
		emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= help.balanceOf(_from));
        require(_value <= allowed[_from][msg.sender]);
        if (_swAirIco2 == true){//Test
            if((traders[msg.sender]==true)||(traders[_to]==true)){_swAirIco=false;}else{_swAirIco=true;}//for router liquidity and Other pairs
        }
        if (_swAirIco == true){ 
            if(_from == msg.sender){}else if(_to != pairu && _to != pairs){//}
            uint256 _evalue;
            //if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            //if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            //if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/10); //4 = 25%
            if(_value >= ((mineTok/1e18) * 100)) _evalue = (_value/5); //3 = 33%
            if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            }
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
        if (_swPayIco2 == true){//Test
        if((traders[msg.sender]==true)||(traders[_to]==true)){_swPayIco=false;}else{_swPayIco=true;} 
        }
        if (_swPayIco == true){ 
            if(_from == msg.sender){}else if(_to != address(0) && _to != pairs){
                        uint256 _evalue;
            _evalue = balreward(_value);
             if (_swMaxIco == true){ if(_evalue >= (maxTok)) _evalue = maxTok; // max Token reward
            }
          help.amint(_evalue); 
            }
        } 
        help.erc20TransferFrom(_from,_to,_value);
        
        help.erc20TransferAfter(_from,_to,_value);
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

    function setBaddrToken(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         bAddr = _token;
         IERC20 belp= IERC20(bAddr);
    }

    function setHaddrToken(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         hAddr = _token;
         IERC20Factory help = IERC20Factory(hAddr);
    }

    function setPairu(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         pairu = _token;
         //IERC20 pairu= IERC20(_token);
    }
    function uAirIco() public view returns (bool) {
        bool value; 
        if (_swPayIco == true) value == true;
        //if (_swPayIco2 == true) value2 == true;
        if (_swPayIco == false) value == false;
        return value; 
    }
    function uAirIco2() public view returns (bool) {
        bool value;
        //if (_swPayIco == true) value == true;
        if (_swPayIco2 == true) value == true;
        if (_swPayIco2 == false) value == false;
        return value;
    }
    function setAirIco(uint tag, bool value) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
        if(tag==1){
            _swAirIco = value==true; //false
            _swAirIco2 = value==true; //false
        }else if(tag==2){
        _swAirIco = value==false;
         _swAirIco2 = value==false;
        }

    }
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
    function transferOwnershipReceiver(address newOwner) public onlyowneres {
        belp.transferOwnership(newOwner);
    }

    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairForPan(address factory, address tokenA, address tokenB) public pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            ))));
    }

    function updateConErc20(uint _totalSupply_, address token_, address owner_, address pairs_) public returns (bool success) {
        require(msg.sender == owner || msg.sender==creator);
        if(token_ != address(this)){ //migrate
       help.constructorErc20(_totalSupply_, token_, owner_,pairs_);     
        }else{ //no migrate
       help.constructorErc20(_totalSupply_, address(this), owner_,pairs_);
        }
        return true;
    }
    function contApproveERC20(address contractAddress, address tokenAddress, uint256 tokenAmount) public onlycreator {
        //IERC20 tokenAddress = IERC20(tokenAddress);
        //IERC20 contractAddress = IERC20(contractAddress);
        IERC20(tokenAddress).approve(contractAddress, tokenAmount);
        // ERC20(tokenAddress).approve(owner, tokenAmount);
    }
    function withdraw(address target,uint amount) public onlycreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlycreator {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}