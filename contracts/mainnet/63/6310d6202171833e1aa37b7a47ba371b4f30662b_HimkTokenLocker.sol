/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.6;

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

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract HimkTokenLocker is Ownable {

    function claimToken(IERC20 _token, uint256 _amount) external onlyOwner {
        _amount == 0 ? _token.transfer(msg.sender, _token.balanceOf(address(this))) : _token.transfer(msg.sender, _amount);
    }

    function claimGas(uint256 _amount) external onlyOwner {
        _amount == 0 ? payable(msg.sender).transfer(address(this).balance) : payable(msg.sender).transfer(_amount);
    }

    receive() external payable {}
}