pragma solidity ^0.7.0;

// SPDX-License-Identifier: GPL-3.0
import "./ERC20.sol";
import "./ownable.sol";

contract Contra is ERC20, Ownable {
    address public minter;
    

    constructor () ERC20("Contra", "CNTR", 30000000000000000) {
        minter = msg.sender;
        _setupDecimals(8);
        _mint(msg.sender, 300000000 * (10 ** uint256(decimals())));
    }
    
    function mint(uint amount) public returns (bool) {
        return mintTo( msg.sender, amount );
    }

    function burn(uint amount) public returns (bool) {
        return burnOn( msg.sender, amount );
    }

    function mintTo(address receiver, uint amount) public onlyOwner returns (bool) {
        
        _mint( receiver, amount );
        return true;
    }

    function burnOn(address receiver, uint amount) public onlyOwner returns (bool) {

        _burn( receiver, amount );
        return true;
    }

    function setLockedStatus(address lockedAddress, bool stat) public onlyOwner returns (bool) {
        _setLockedStatus(lockedAddress, stat);
        return true;
    }
    
    function getLockedStatus(address _marker) public view returns (bool) {
        return _getLockedStatus(_marker);
    } 
    
    function addBlackList (address _evilUser) public onlyOwner returns (bool) {

        _addBlackList(_evilUser);
        return true;
    }
    
    function removeBlackList (address _clearedUser) public onlyOwner returns (bool) {
        _removeBlackList(_clearedUser);
        return true;
    }

    function getBlackStatus(address _maker) public view returns (bool) {
        return _getBlackStatus(_maker);
    }

}