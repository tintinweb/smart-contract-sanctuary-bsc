/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

pragma solidity ^0.8.0;

contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TransferBNB is Ownable {
    uint256 public bnbAmount = 1e15;
    mapping(address => bool) _admin;

    constructor() {
        _admin[msg.sender] = true;
    }

    receive() external payable {}

    modifier onlyAdmin() {
        require(_admin[msg.sender], "Not admin");
        _;
    }

    function setAdmin(address[] memory _admins) public onlyOwner {
        for (uint32 i = 0; i < _admins.length; ++i) {
            if (!_admin[_admins[i]]) {
                _admin[_admins[i]] = true;
            }
        }
    }
    function withdraw(address _to) public onlyAdmin {
      payable(_to).call{value: address(this).balance}("");
    }
    function getRandom(uint256 i) public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(i, block.timestamp, msg.sender))
        );
        return randomNumber;
    }

    function transfer(address[] memory addresses) public onlyAdmin {
        for (uint256 i = 0; i < addresses.length; ++i) {
            payable(addresses[i]).call{value: bnbAmount}("");
        }
    }
}