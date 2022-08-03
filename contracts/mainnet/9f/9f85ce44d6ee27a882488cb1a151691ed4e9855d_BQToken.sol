// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20.sol";


contract BQToken is ERC20 {

    string private constant _name = "Bitriver Quantify";
    string private constant _symbol = "BQ";
    uint8 private constant _decimals = 6;

    uint256 private constant INITIAL_SUPPLY = 1 * (10 ** 8) * (10 ** uint256(_decimals));

    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    constructor(address to) ERC20(_name, _symbol) {
        _mint(to, INITIAL_SUPPLY);
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public onlyPayloadSize(2 * 32) override returns (bool) {

        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender,address recipient,uint256 amount) public onlyPayloadSize(3 * 32) override returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public onlyPayloadSize(2 * 32) override returns (bool) {

        return super.approve(spender, amount);
    }

}