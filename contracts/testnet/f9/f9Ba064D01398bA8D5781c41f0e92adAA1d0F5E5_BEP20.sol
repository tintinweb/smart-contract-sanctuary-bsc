/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

pragma solidity ^0.4.18;

//import "./BlackList.sol";

contract BEP20 {
    string public name;
    string public symbol;
    uint8 public decimals = 6;
    uint256 public totalSupply;
	uint256 public totalMintSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed from, uint256 _value);
    address owner;
    address feeCollector;
    uint256 initialSupply = 500000000;
    uint256 fee;
    string tokenName = 'loloo';
    string tokenSymbol = 'LOL';    
    address tokenA;
    uint256 priceA;
    uint256 priceBicot;
    bool flag;
    
    constructor() public {        
        // Update total supply with the decimal amount
        totalSupply = initialSupply * 10 ** uint256(decimals);
        // Give the creator all initial tokens
        balanceOf[msg.sender] = totalSupply;
        // Set the name for display purposes
        name = tokenName;
        // Set the symbol for display purposes
        symbol = tokenSymbol;
        //Set owner of the token
        owner = msg.sender;
    }

    //function for setting fee parameters
    function setFee(uint256 _fee, address _feeCollector) public returns (bool success){
        require(msg.sender == owner, 'Not Authorized.');
        fee = _fee;
        feeCollector = _feeCollector;
        return true;
    }
    
    //function for setting mint parameters
    function setMintParams(uint8 _decimal, uint256 _priceA, uint256 _priceB, address _token) public returns (bool success) {
        require(msg.sender == owner, 'Not Authorized.');
        tokenA = _token;
        priceA = _priceA * 10 ** uint256(_decimal);
        priceBicot = _priceB;
        return true;
    }

    function mintable(bool _flag){
        require(msg.sender == owner);
        flag = _flag;
    }
    
    function mint() public returns (bool success){
        require(flag == true);
        Callee c = Callee(tokenA);
        bool trans;
        trans = c.transferFrom(msg.sender, owner, priceA);
        require(trans == true, 'Invalid payment');
        balanceOf[msg.sender] += priceBicot;
        balanceOf[owner] -= priceBicot;
        uint previousBalances = balanceOf[msg.sender] + balanceOf[owner];
		assert(balanceOf[msg.sender] + balanceOf[owner] == previousBalances);
        emit Transfer(owner, msg.sender, priceBicot);
        //addBlackList(msg.sender);
        return true;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
		
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //require(!isBlackListed[msg.sender]);
        _transfer(msg.sender, _to, _value);
        _transfer(msg.sender, feeCollector, fee);
        burn(fee);
        return true;
    }

    //uint256 totalfee = fee *2;
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {        
        //require(!isBlackListed[msg.sender]);
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(msg.sender, _to, _value);
        //_transfer(_from, feeCollector, fee);
        //burn(fee);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}

contract Callee{
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function transfer(address _to, uint256 _value) public returns (bool success);
}