// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import  "./IERC20.sol";
import "./IOwnable.sol";
import "./Test.sol";

interface TokenCreator{
    function createToken(
        uint256 _initialAmount, 
        string memory _tokenName, 
        uint8 _decimalUnits, 
        string  memory _tokenSymbol, 
        address creator
        ) external returns(address);
}

contract MintFactory is Ownable_Link, Test{
    constructor(address _ownable) {
        ownable = IOwnable(_ownable);
    }

    address[] public minters;
    mapping(address => string) public templatesName;
    event NewToken(address token);
    event AddSupport(address template, string name);
    event DeleteSupport(address template, string name);

    modifier CheckSupport(address template){
        require(bytes(templatesName[template]).length != 0, "Unsopported smart-contract");
        _;
    }

    ///
    /// admin's functional 
    ///

    function addSupport(address template, string memory name) public CheckOwner{
        require(bytes(templatesName[template]).length == 0, "This smart-contract is already has support");
        require(bytes(name).length != 0, "Error: Empty name");
        templatesName[template] = name;
        minters.push(template);
    }
    
    function deleteSupport(address template) public CheckOwner CheckSupport(template){
        delete templatesName[template];
        uint c = 0;
        for (uint i = 0; i< minters.length; i++){
            if (minters[i] != template){
                minters[c] = minters[i];
                c++;
            }
        }
        minters.pop();
    }

    function createToken(
        uint248 template,
        address _owner,
        uint _initialAmount, 
        string memory _tokenName, 
        uint8 _decimalUnits, 
        string  memory _tokenSymbol
        )
        public CheckPerms CheckSupport(minters[template]) returns(address){
            TokenCreator minter = TokenCreator(minters[template]);
            address token = minter.createToken(_initialAmount, _tokenName, _decimalUnits, _tokenSymbol, _owner);
            emit NewToken(token);
            return token;
    }
    
    /// read

    function getSupports() public view returns(string[] memory){
        string[] memory names = new string[](minters.length);
        for (uint i = 0; i < minters.length; i++) {
            names[i] = templatesName[minters[i]];
        }
        return names;
    }

}