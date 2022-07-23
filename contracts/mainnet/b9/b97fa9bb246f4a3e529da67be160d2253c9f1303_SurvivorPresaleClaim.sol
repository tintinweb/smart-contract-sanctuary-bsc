/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface Presale {
    function getUserDeposits(address user) external view returns (uint256);
}

contract SurvivorPresaleClaim {
    IERC20 public constant HP =
        IERC20(0x79EEe7769c731bCF5f215B0C1E14f4a52be00D52);

    Presale public constant SurvivorPresale =
        Presale(0xAf43BC1CF205D6d50c0C8491f2a624E518562813);

    address public owner;

    mapping(address => uint256) public user_promo_tokens;
    mapping(address => uint256) public claimed_tokens;

    bool public claims_enabled = false;

    // CUSTOM ERRORS

    error NotLaunchedYet();
    error NothingToSend();
    error ZeroAddress();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the Owner!");
        _;
    }

    function totalClaim(address _address) public view returns (uint256) {
        uint256 deposits = SurvivorPresale.getUserDeposits(_address);

        return
            user_promo_tokens[_address] +
            ((deposits * 327500) / 20000000000000000000);
    }

    function withdrawHP() external {
        if (!claims_enabled) revert NotLaunchedYet();

        uint256 total_to_send = totalClaim(msg.sender) -
            claimed_tokens[msg.sender];

        if (total_to_send == 0) revert NothingToSend();

        claimed_tokens[msg.sender] += total_to_send;

        HP.transfer(msg.sender, total_to_send);
    }

    function setClaimsEnabled(bool _enabled) external onlyOwner {
        claims_enabled = _enabled;
    }

    function changeOwner(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        owner = _address;
    }

    function addPromoTokens(
        address[] memory addresses,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == address(0)) revert ZeroAddress();
            user_promo_tokens[addresses[i]] += amounts[i];
        }
    }
}