// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";

contract SquadTable is Ownable {

    uint256 private maxSupply;
    bytes private weights;

    constructor(uint256 _maxSupply) {
        maxSupply = _maxSupply;
    }

    function addWeights(bytes memory _weights) external onlyOwner {
        weights = _weights;
    }
    
    function getRank(uint256 _tokenId) external view returns (uint8) {
        require(_tokenId < maxSupply, "Invalid tokenId");
        return uint8(weights[_tokenId]);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}