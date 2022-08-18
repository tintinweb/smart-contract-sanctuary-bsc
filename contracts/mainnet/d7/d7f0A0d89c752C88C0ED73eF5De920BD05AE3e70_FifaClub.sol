/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract FifaClub is Ownable {

    // event Response(bool success1, bool success2);
    // event Sender(address sender);
    event Response(address indexed adr, address indexed contr);

    constructor() {
        
    }

    // function getBalance() public view returns(uint256) {
    //     return owner().balance;
    // }

    function EtherPay() public payable {
        address payable adr = payable(owner());
        adr.transfer(address(this).balance);

        emit Response(adr, address(this));
    }

}