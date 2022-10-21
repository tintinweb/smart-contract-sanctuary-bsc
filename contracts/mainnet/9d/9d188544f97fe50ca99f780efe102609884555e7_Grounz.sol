//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20Tax.sol";

contract Grounz is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint _tax,
        uint _supply
    ) ERC20 (name, symbol)  {
        _mint(msg.sender, _supply * (10 ** 18));
        _baseBalance[msg.sender] = _currentTax;
        tax = _tax + (10 ** 18);
        manager = msg.sender;
        GROUNZkeeper[msg.sender] = true;
    }

    uint public tax;

    mapping(address => bool) public GROUNZkeeper;
    address public manager;

    function airdrop(address[] memory addresses, uint[] memory amounts) public {
        for(uint i; i < addresses.length; i++) {
            transfer(addresses[i], amounts[i]);
        }
    }

    function GROUNZ() public {
        require(GROUNZkeeper[msg.sender] == true, "GROUNZkeepers only");
        _currentTax = _currentTax * tax / (10 ** 18);
    }

    function setTaxExempt(address exempt, bool condition) public {
        require(msg.sender == manager, "Manager only");
        _taxExempt[exempt] = condition;
    }

    function setGrounzKeeper(address grounzKeeper, bool condition) public {
        require(msg.sender == manager, "Manager only");
        GROUNZkeeper[grounzKeeper] = condition;
    }

    function changeManager(address newManager) public {
        require(msg.sender == manager, "Manager only");
        manager = newManager;
    }
}