/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

pragma solidity ^0.5.17;
 
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

interface Token {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract Airdropper is Owned{

    constructor(address _owner) public Owned(_owner) {

    }
    
    function AirTransfer(address recipients, uint _values, address _tokenAddress,bytes6 financialCode)  external returns (bool) {
        Token token = Token(_tokenAddress);
        token.transfer(recipients, _values);
        emit InviteAccount(financialCode);
        return true;
    }
 
     function withdrawalToken(address _tokenAddress) external onlyOwner { 
        Token token = Token(_tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }


    /* ========== EVENTS ========== */

    event InviteAccount(bytes6 financialCode);


}