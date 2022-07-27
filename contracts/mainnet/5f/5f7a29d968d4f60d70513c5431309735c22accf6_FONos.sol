// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import './IERC20.sol';
import './SafeMath.sol';
import './Address.sol';
import './ERC20.sol';

contract FONos is ERC20 {
    address public owner;
    mapping(address => bool) miner;
    constructor() ERC20("FONos", "FONos", 18, 0)
    {
        owner = msg.sender;
    }

    function setMiner(address account, bool isMiner) external {
        require(msg.sender == owner, "only owner");
        miner[account] = isMiner;
    }
    function transferOwner(address newOwner) external {
        require(msg.sender == owner, "only owner");
        owner = newOwner;
    }

    function mint(address to, uint256 amount) external {
        require(miner[msg.sender], "only miner");
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        require(miner[msg.sender], "only miner");
        _burn(to, amount);
    }

}