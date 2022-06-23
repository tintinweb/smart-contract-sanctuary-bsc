/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

pragma solidity >= 0.6.6;


contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
   
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBlackSetter{
    function addBlackList(address[] memory owners)external ;
    function remBlackList(address[] memory owners)external;
    function isBlack(address owner)external view returns(bool);
}

contract BlackSetter is Ownable{

    IBlackSetter public setter;

    constructor(
        address _setter,
        address _ownerAddress
    ) public {
        _owner = _ownerAddress;
        setter = IBlackSetter(_setter);
    }

    function addBlackList(address[] memory owners)external onlyOwner{
        setter.addBlackList(owners);
    }

    function remBlackList(address[] memory owners)external onlyOwner{
        setter.remBlackList(owners);
    }

    function isBlack(address owner)external view returns(bool){
        return setter.isBlack(owner);
    }
}