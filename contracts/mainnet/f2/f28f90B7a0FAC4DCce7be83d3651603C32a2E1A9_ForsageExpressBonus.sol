/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IForsage {
    function registrationFor(address userAddress, address referrerAddress) external;
    function buyNewLevelFor(address userAddress, uint8 matrix, uint8 level) external;
    function BASIC_PRICE() external view returns(uint);
    function levelPrice(uint8 level) external view returns(uint);

    function users(address userAddress) external view returns(uint id, address referrer, uint partnersCount);
}

interface IForsageExpress {
    function buyNewLevelFor(address userAddress, uint8 level) external payable;
    function levelPrice(uint8 level) external view returns(uint);
    function isLevelActive(address _userAddress, uint _level) external view returns(bool);
}

contract ForsageExpressBonus {

    address public owner;
    mapping(address => bool) bonusUsed;

    IForsage public forsage;
    IForsageExpress public forsageExpress;

    uint public totalUses;

    constructor(IForsage _forsage, IForsageExpress _forsageExpress) public {
        owner = msg.sender;
        forsage = _forsage;
        forsageExpress = _forsageExpress;
    }

    receive() external payable {
        require(msg.sender == owner, "onlyOwner");
    }

    function canUseBonus(address _userAddress) public view returns(bool) {
        (uint id, , ) = forsage.users(_userAddress);
        
        return (id != 0 && id <= 289780 && block.timestamp < 1651341600);  
    }

    function useBonus() public {
        require(canUseBonus(msg.sender), "bonus is inactive");
        require(!forsageExpress.isLevelActive(msg.sender, 1), "levelAlreadyActivated");
        require(!bonusUsed[msg.sender], "bonus already used");
        forsageExpress.buyNewLevelFor{value: forsageExpress.levelPrice(1)}(msg.sender, 1);

        bonusUsed[msg.sender] = true;
        totalUses++;
    }

    function endDrop() public {
        require(msg.sender == owner, "onlyOwner");
        require(block.timestamp >= 1651341600, "not yet");
        msg.sender.transfer(address(this).balance);
    }

    function withdrawToken(address tokenAddress) public {
        require(msg.sender == owner, "onlyOwner");
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, balance);
    }
}