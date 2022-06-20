//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Capped.sol";
import "./Ownable.sol";
import "./AccessControl.sol";

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

contract MinterAccess is AccessControl, Ownable {

    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        address owner = _msgSender();
        super._setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        super._setupRole(MINTER_ROLE, owner);
        super._setupRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function hasMinterRole(address account) public view returns(bool) {
        return super.hasRole(MINTER_ROLE, account);
    }

    function setupMinterRole(address account) public onlyOwner {
        super._setupRole(MINTER_ROLE, account);
    }

    function revokeMinterRole(address account) public onlyOwner {
        super.revokeRole(MINTER_ROLE, account);
    }

    modifier onlyMinter() {
        require(hasMinterRole(_msgSender()), "MinterAccess: sender do not have the minter role");
        _;
    }
}

contract Seed is ERC20Capped, MinterAccess {

    constructor() ERC20("Seed","SeedDao") ERC20Capped(200000000*1e18) {}

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function mint(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function withdrawToken(address token, address to) external onlyOwner {
        uint256 balance = ERC20Interface(token).balanceOf(address(this));
        _safeTransfer(token,to,balance);
    }

    function _safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }
}