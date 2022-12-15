/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBEP20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event TransferOwnerShip(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, 'Not owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit TransferOwnerShip(newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),
            'Owner can not be 0');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PrivateSale is Ownable {

    IBEP20 token;
    uint256 public rateNum;
    uint256 public rateDen;
    uint256 public minAmount;

    constructor() {
        token = IBEP20(0x8196BCf3b5642c4dDc9B8D11780d005a9FD18Bc4);
        rateNum = 10**7;
        rateDen = 1;
        minAmount = 0.05 ether;
    }

    receive () external payable {
        bool success;
        (success,) = address(owner()).call{value: msg.value}("");
        require(success, "Transfer failed.");

        uint256 amount = (msg.value * rateNum) / rateDen;
        require(amount >= minAmount, "Amount is too small.");
        token.transferFrom(owner(), msg.sender, amount);
        
    }


    // Only owner functions here

    function setToken(address _token) public onlyOwner {
        token = IBEP20(_token);
    }

    function setRate(uint256 _rateNum, uint256 _rateDen) public onlyOwner {
        rateNum = _rateNum;
        rateDen = _rateDen;
    }

    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

}