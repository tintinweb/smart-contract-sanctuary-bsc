pragma solidity ^0.4.24;


/*
    Carey Development Token
*/

import "./ERC20.sol";

contract CAREYDevelopment is ERC20 {

    string private _symbol;
    uint256 private _decimals;
    string private _name;
    address private _creator;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor (
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 decimals_,
        uint8 fee_,
        address charityWallet_
    ) ERC20(fee_,charityWallet_) public {
        _name = name_;
        _decimals = decimals_;
        _symbol = symbol_;
        _mint(msg.sender, totalSupply_ * (10**_decimals));
        _creator = msg.sender;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_creator, address(0));
        _creator = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == _creator, "This can only be done by the creator!");
        _;
    }

    /**
     * @return the owner of the token.
     */
    function Owner() public view returns (address) {
        return _creator;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint256) {
      return _decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
      return _name;
    }
    
}