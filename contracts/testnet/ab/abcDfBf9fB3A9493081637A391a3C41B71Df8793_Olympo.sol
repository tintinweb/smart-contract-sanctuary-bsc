/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.8.13;

contract Olympo{
    
    event PegasusMinted(address);

    address payable public founder;
    address payable public safe_founder;

    uint256 public new_pegasus_value;
    uint256 public pegasus_minted;
    constructor(){ founder = payable (msg.sender); pegasus_minted = 0;}
    modifier onlyFounder{ require(msg.sender == founder, "Only Founder");_; }
    receive() external payable {}

    function setFounder(address _newFounder) external onlyFounder{ founder = payable (_newFounder); }
    function getFounder()               view external returns(address){ return founder; }

    function setSafeFounder(address _safe)   external onlyFounder{ safe_founder = payable(_safe);}
    function getSafeFounder()           view external returns(address){ return safe_founder; }
    
    function setPegasusValue(uint256 _value) external onlyFounder{ new_pegasus_value = _value; }
    function getPegasusValue()          view external returns(uint256){ return new_pegasus_value; }
    function getPegasusMinted()         view external returns(uint256){ return pegasus_minted; }

    function mintPegasus() external payable {
        require(msg.value == new_pegasus_value, "not enough beans");
        safe_founder.transfer(msg.value);
        pegasus_minted++;
        emit PegasusMinted(msg.sender);
    }

    function claimGold() external payable onlyFounder{
        safe_founder.transfer( address(this).balance );
    }
}