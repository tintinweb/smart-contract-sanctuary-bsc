// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC20.sol";

contract NavixTestToken is ERC20 {

    uint256 private immutable _cap = 21000000 * 10**18;
    uint256 private immutable _endtime = block.timestamp + 604800;

    uint256 private _lastMintTime = block.timestamp;

    constructor() ERC20("Navix Test Token", "LUZ")  {
        _mint( address(0x9641F44C48221a8a1451F4650621f7f9c6e694c7), 1 * 10**18);
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function endtime() public view virtual returns (uint256) {
        return _endtime;
    }

    function _mintAmount() internal {
        uint256 amount = (block.timestamp - _lastMintTime) * cap() / 604800;
        
        _lastMintTime = block.timestamp;

        _mint( address(0xC842d8d75809E32525B26c6d75e8Abec738475c2), amount * 100 / 50); // Navix Test
        _mint( address(0x9641F44C48221a8a1451F4650621f7f9c6e694c7), amount * 100 / 50); // Toy Story

        require(_lastMintTime == block.timestamp);
    }


    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }


    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override {
        require(_to != address(this), string("No transfers to contract allowed."));

        if (_from != address(0)) {
            _mintAmount();
        }

        super._beforeTokenTransfer(_from, _to, _amount);       
    }

}