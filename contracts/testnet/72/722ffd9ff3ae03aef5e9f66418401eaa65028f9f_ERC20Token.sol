// contracts/ERC20Token.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IPancakePair.sol";

contract ERC20Token is ERC20 {

    address public lpAddress;
    address public usdtAddress;
    address public lowbAddress;
    address public owner;

    mapping (uint => uint) public lusdMinted;
    mapping (uint => uint) public lusdBurned;

    event Mint(address indexed user, uint amount);
    event Burn(address indexed user, uint amount);

    constructor(address lpAddress_) ERC20("LUSD Token", "LUSD") {
        lpAddress = lpAddress_;
        IPancakePair pair = IPancakePair(lpAddress_);
        usdtAddress = pair.token0();
        lowbAddress = pair.token1();
        owner = msg.sender;
    }

    function getLowbNeedToMint(uint lusdAmount) public view returns (uint) {
        uint factor;
        if (getLowbAmountRef(lusdAmount) < getLowbAmountImm(lusdAmount)) {
            factor = 0;
        }
        else if (lusdMinted[block.number/100]*100 < totalSupply()) {
            factor = lusdMinted[block.number/100]*100 * 10000 / totalSupply();
        }
        else {
            factor = 10000;
        }
        return (factor * getLowbAmountRef(lusdAmount) + (10000 - factor) * getLowbAmountImm(lusdAmount)) / 10000;
    }

    function getLowbReturnAmount(uint lusdAmount) public view returns (uint) {
        uint factor;
        if (getLowbAmountRef(lusdAmount) > getLowbAmountImm(lusdAmount)) {
            factor = 0;
        }
        else if (lusdBurned[block.number/100]*100 < totalSupply()) {
            factor = lusdBurned[block.number/100]*100 * 10000 / totalSupply();
        }
        else {
            factor = 10000;
        }
        return (factor * getLowbAmountRef(lusdAmount) + (10000 - factor) * getLowbAmountImm(lusdAmount)) / 10000;
    }

    function getLowbAmountImm(uint lusdAmount) public view returns (uint) {
        IPancakePair pair = IPancakePair(lpAddress);
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = pair.getReserves();
        return reserve1 * lusdAmount / reserve0;
    }

    function getLowbAmountRef(uint lusdAmount) public view returns (uint) {
        IERC20 lowb = IERC20(lowbAddress);
        uint lowAmount = lowb.balanceOf(address(this));
        return lowAmount * lusdAmount / totalSupply();
    }

    function mint(uint amount) public {
        lusdMinted[block.number/100] = lusdMinted[block.number/100] + amount;
        IERC20 token = IERC20(lowbAddress);
        uint lowbAmount;
        if (msg.sender == owner) {
            lowbAmount = getLowbAmountImm(amount);
        }
        else {
            lowbAmount = getLowbNeedToMint(amount) * 10030 / 10000;
        }
        require(token.transferFrom(msg.sender, address(this), lowbAmount), "Lowb transfer failed");
        _mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }

    function burn(uint amount) public {
        lusdBurned[block.number/100] = lusdBurned[block.number/100] + amount;
        _burn(msg.sender, amount);
        IERC20 token = IERC20(lowbAddress);
        uint lowbAmount;
        if (msg.sender == owner) {
            lowbAmount = getLowbAmountImm(amount);
        }
        else {
            lowbAmount = getLowbReturnAmount(amount) * 9970 / 10000;
        }
        token.transfer(msg.sender, lowbAmount);
        emit Burn(msg.sender, amount);
    }
}