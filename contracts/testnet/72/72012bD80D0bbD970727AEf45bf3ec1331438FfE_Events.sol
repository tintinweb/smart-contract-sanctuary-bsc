/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier:MIT

contract Events{

    address public owner;
    uint256 public value ;


    constructor (){
        owner = msg.sender;
    }
    event changeOwner(address _owner,address _from);
    event Increment(address owner,uint256 value);
    event Log(address indexed sender, string _message);
    event Deposit(address indexed _from,address indexed _to, uint _value);
    event transfer(address indexed _from, address indexed _to, uint amount);
    event NewTrade(uint256 indexed date,address from,address indexed to,uint256 indexed amount);
    
    

    function deposit() public payable {      
      emit Deposit(msg.sender, address(this), msg.value);
    }
 
    function getValue(uint _a, uint _b) public {
        value = _a + _b;
        emit Increment(msg.sender,value);
    }

    function trade(address to, uint256 amount) public  {
        emit NewTrade(block.timestamp, msg.sender, to,amount);
    }

    function test(string memory _message) public {
        emit Log(msg.sender, _message);
    } 

    function transferTo(address _from, address  _to, uint amount) public {
        emit transfer(_from, _to, amount);
    }

    function updateOwner(address _owner) public {
        emit changeOwner(_owner,msg.sender);
    }
}