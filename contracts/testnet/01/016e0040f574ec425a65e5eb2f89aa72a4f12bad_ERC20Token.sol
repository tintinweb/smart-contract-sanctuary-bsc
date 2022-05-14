// contracts/ERC20Token.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IPancakePair.sol";

contract ERC20Token is ERC20 {

    address public lpAddress;
    address public usdtAddress;
    address public lowbAddress;

    event Mint(address indexed user, uint amount);
    event Burn(address indexed user, uint amount);

    constructor(address lpAddress_) ERC20("LUSD Token", "LUSD") {
        lpAddress = lpAddress_;
        IPancakePair pair = IPancakePair(lpAddress_);
        usdtAddress = pair.token0();
        lowbAddress = pair.token1();
        
    }

    function getLowbAmount(uint lusdAmount) public view returns (uint) {
        IPancakePair pair = IPancakePair(lpAddress);
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = pair.getReserves();
        return reserve1 * lusdAmount / reserve0;
    }

    function mint(uint amount) public {
        IERC20 token = IERC20(lowbAddress);
        uint lowbAmount = getLowbAmount(amount);
        require(token.transferFrom(msg.sender, address(this), lowbAmount), "Lowb transfer failed");
        _mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }

    function burn(uint amount) public {
        _burn(msg.sender, amount);
        IERC20 token = IERC20(lowbAddress);
        uint lowbAmount = getLowbAmount(amount);
        token.transfer(msg.sender, lowbAmount);
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }
}