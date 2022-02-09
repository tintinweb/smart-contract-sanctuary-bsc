// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./interface/IERC20.sol";

interface IGAMERUPEE is IERC20 {
    function harvest(address account, uint releaseIndex) external returns(uint);
}

contract RollingReserveWallet {

    
    IGAMERUPEE public gameRupee;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address _gameRupee) {
        gameRupee = IGAMERUPEE(_gameRupee);
    }

    function harvest(uint releaseIndex) external {
        uint pendingAmount = gameRupee.harvest(msg.sender, releaseIndex);
        require(pendingAmount > 0, "Nothing to harvest");
        gameRupee.transfer(msg.sender, pendingAmount);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}