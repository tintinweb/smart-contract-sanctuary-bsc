/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

pragma solidity ^0.4.20;





contract BEP20 {

    

    string public name;

    string public symbol;

    uint8 public decimals = 8;

    

    uint256 public totalSupply;

	uint256 public totalMintSupply;

    

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);    

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);    

    event Burn(address indexed from, uint256 value);

    event Mint(address indexed from, uint256 _value);



    address owner;

    uint256 initialSupply = 100000000;

    uint256 initialMintSupply = 100000;

    string tokenName = 'BugSwap';

    string tokenSymbol = 'BGSWP';

    constructor() public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  

		totalMintSupply = initialMintSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;                

        name = tokenName;                                  

        symbol = tokenSymbol;                             

        owner = msg.sender;

    }

    

    function _transfer(address _from, address _to, uint _value) internal {        

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

		

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

		

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

		

        return true;

    }

    

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

		

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



    function mint(uint256 _value) public returns (bool success) {

        require(totalMintSupply > 0);

        require(_value <= totalMintSupply);		

		

        uint previousBalances = balanceOf[msg.sender] + balanceOf[owner];

		

        balanceOf[msg.sender] += _value;

        balanceOf[owner] -= _value;



        totalMintSupply -= _value;

		assert(balanceOf[msg.sender] + balanceOf[owner] == previousBalances);

        emit Transfer(owner, msg.sender, _value);



        return true;

    }

}