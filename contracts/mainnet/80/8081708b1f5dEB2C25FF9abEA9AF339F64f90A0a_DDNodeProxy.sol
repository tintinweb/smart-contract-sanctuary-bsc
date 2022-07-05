pragma solidity ^0.8.12;
import './DDNode2.sol';
import './DDNode.sol';

contract DDNodeProxy is DDNodeStorage, UpgradeableProxy {
    address _logicer;
    constructor()  public{
        _logicer = msg.sender;
    }
    function setLogic(address _add)public {
        require(msg.sender == _logicer);
        _upgradeTo(_add);
    }
}