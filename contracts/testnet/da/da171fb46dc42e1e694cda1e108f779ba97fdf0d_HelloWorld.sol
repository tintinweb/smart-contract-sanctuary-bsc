/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** @title Documents. */ 
contract HelloWorld {
     string public nametoken;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalairdrop;
    mapping(address=>uint256) public balances;

    uint256 public tokenPrice;
    address public minter;
    address public burner;

string defaultName;
mapping (address => string) public accounts; 
 

   event Transfer(address indexed From_address, address indexed To_address, uint256 indexed amount);
   event Buy(address indexed Buyer_address, uint256 indexed amount);
   event Airdrop(address indexed Buyer_airdrop_address, uint256 indexed amount);

constructor(uint256 initialSupply) {
    defaultName = 'World';

        totalSupply = initialSupply;
        totalairdrop=200000000;
        minter = msg.sender;
        burner = msg.sender;
        balances[minter] = initialSupply;
        nametoken = "SportX";
        symbol = "SPTX";
        decimals = 18;
        tokenPrice = 10**15 wei;        // 0.001 Eth = 10^15 wei
}


   function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter, "Only Minter can Mint!");
        balances[receiver] += amount;
        totalSupply += amount;
    }

/** @dev Retrieve Message to Print
      * @return The Message to Print, Hello, Concatenated with the User Name
      */ 
function getMessage() public view returns(string memory){
    string memory name = bytes(accounts[msg.sender]).length > 0 ? accounts[msg.sender] : defaultName;
    return concat("Hello, " , name);
}
 
/** @dev Set the Name to Greet 
      * @param  _name  user name
      * @return success Returns bool value (True or False) to indicate if save was successful or not
      */
function setName(string memory _name) public returns(bool success){
    require(bytes(_name).length > 0);
    accounts[msg.sender] = _name;
    return true;
}

/** @dev Set the Name to Greet 
      * @param  _base  contains the base value " Hello, "
      * @param  _value contains the name to append to message to display
      * @return the concatenated string of _base+_value i.e. Hello, Name
      */ 
 function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);
 
        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);
 
        uint i;
        uint j;
 
        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }
 
        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }
        
        return string(_newValue);
    }
}