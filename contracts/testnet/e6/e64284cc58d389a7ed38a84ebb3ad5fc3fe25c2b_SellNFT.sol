/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.14;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


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

interface nft{
    function mint(address spender) external returns (bool);
}

contract SellNFT is Ownable{
    
    uint256 private _price = 100*10**18;
    address private _testToken;
    address private _testNFT;

    function testNFT() public view virtual returns (address) {
        return _testNFT;
    }
    function setTestNFT(address newTestNFT) public virtual onlyOwner {
        _testNFT = newTestNFT;
    }

    function testToken() public view virtual returns (address) {
        return _testToken;
    }
    function setTestToken(address newTestToken) public virtual onlyOwner {
        _testToken = newTestToken;
    }

    function price() public view virtual returns (uint256) {
        return _price;
    }

    function setPrice(uint256 newPrice) public virtual onlyOwner {
        _price = newPrice;
    }


    function buy (uint256 amount) public {
        IERC20 _Token = IERC20(_testToken);
        require(_Token.balanceOf(_msgSender()) >= amount*_price, 'INSUFFICIENT_BALANCE');
        require(_Token.transferFrom(_msgSender(), address(this), amount*_price));
        for (uint i; i < amount; i++) { 
            nft(_testNFT).mint(_msgSender());
        }
    }

}