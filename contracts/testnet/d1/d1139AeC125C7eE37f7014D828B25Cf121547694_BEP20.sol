/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity ^0.4.18;

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
    uint256 burnAmount;
    string tokenName = 'VoavToken';
    string tokenSymbol = 'VOAV'; 
    address tokenA;
    uint256 priceA;
    uint256 priceBicot;
    uint8 phasenum;
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
    address[] internal phase1;
    address[] internal phase2;
    address[] internal phase3;
    address[] internal phase4;
    address[] internal phase5;

    function isPhase1(address _address)
       internal
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < phase1.length; s += 1){
           if (_address == phase1[s]) return (true, s);
       }
       return (false, 0);
   }
   function isPhase2(address _address)
       internal
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < phase2.length; s += 1){
           if (_address == phase2[s]) return (true, s);
       }
       return (false, 0);
   }
   function isPhase3(address _address)
       internal
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < phase3.length; s += 1){
           if (_address == phase3[s]) return (true, s);
       }
       return (false, 0);
   }
   function isPhase4(address _address)
       internal
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < phase4.length; s += 1){
           if (_address == phase4[s]) return (true, s);
       }
       return (false, 0);
   }
   function isPhase5(address _address)
       internal
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < phase5.length; s += 1){
           if (_address == phase5[s]) return (true, s);
       }
       return (false, 0);
   }
   function isLocked(address _address) public view returns(bool) {
       (bool _isPhase1, ) = isPhase1(_address);
       (bool _isPhase2, ) = isPhase2(_address);
       (bool _isPhase3, ) = isPhase3(_address);
       (bool _isPhase4, ) = isPhase4(_address);
       (bool _isPhase5, ) = isPhase5(_address);
       if (_isPhase1){
           return true;
       }
       else if(_isPhase2){
           return true;
       }
       else if(_isPhase3){
           return true;
       }
       else if(_isPhase4){
           return true;
       }
       else if(_isPhase5){
           return true;
       }
       else {
           return false;
       }
   }
   function addLocked(address user) internal {
       if(phasenum == 1){
           phase1.push(user);           
       }
       else if (phasenum == 2){
           phase2.push(user);
       }
       else if (phasenum == 3){
           phase3.push(user);
       }
       else if (phasenum == 4){
           phase4.push(user);
       }
       else if (phasenum == 5){
           phase5.push(user);
       }
   }
   function removeLock(uint8 num) public{
       require(msg.sender == owner , 'Not Authorized!');
       if(num == 1){
           delete phase1;           
       }
       else if (num == 2){
           delete phase2;
       }
       else if (num == 3){
           delete phase3;
       }
       else if (num == 4){
           delete phase4;
       }
       else if (num == 5){
           delete phase5;
       }       
   }

    //function for setting fee parameters
    function setFee(uint256 _fee, uint256 _burnAmount, address _feeCollector) public returns (bool success){
        require(msg.sender == owner, 'Not Authorized.');
        fee = _fee;
        burnAmount = _burnAmount;
        feeCollector = _feeCollector;
        return true;
    }
    
    //function for setting mint parameters
    function setMintParams(uint256 _amountIn, uint256 _amountOut, address _token) public returns (bool success) {
        require(msg.sender == owner, 'Not Authorized.');
        tokenA = _token;
        priceA = _amountIn;
        priceBicot = _amountOut;
        return true;
    }

    //function for setting minting phase
    function setPhase(uint8 _phasenum) public{
        require(msg.sender == owner, 'Not Authorized.');
        phasenum = _phasenum;
    }

    //function for setting mintable status
    function mintable(bool _flag) public{
        require(msg.sender == owner, 'Not Authorized.');
        flag = _flag;
    }
    
    function mint() public returns (bool success){
        require(flag == true, 'Minting is not available.');
        Callee c = Callee(tokenA);
        bool trans;
        trans = c.transferFrom(msg.sender, owner, priceA);
        require(trans == true, 'Invalid payment');
        balanceOf[msg.sender] += priceBicot;
        balanceOf[owner] -= priceBicot;
        uint previousBalances = balanceOf[msg.sender] + balanceOf[owner];
		assert(balanceOf[msg.sender] + balanceOf[owner] == previousBalances);
        emit Transfer(owner, msg.sender, priceBicot);
        addLocked(msg.sender);
        return true;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0), 'To cannot be empty.');
        require(isLocked(_from) == false, 'Your assets are locked.');
        require(balanceOf[_from] >= _value, 'Insufficient balance.');
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
		
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        _transfer(msg.sender, feeCollector, fee);
        burn(burnAmount);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(msg.sender, _to, _value);
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