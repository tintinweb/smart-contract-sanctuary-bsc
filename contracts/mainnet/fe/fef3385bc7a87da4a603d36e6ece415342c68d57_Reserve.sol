// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

contract Reserve {
    uint256 public povertyLine; // wallets below this balance are eligible for top up
    uint256 public topUpAmount; // top up is always a fixed amount

    address[] public wallets;
    mapping(address => bool) public managers;

    address public immutable admin; // multisig

    constructor(
        uint256 _povertyLine,
        uint256 _topUpAmount,
        address[] memory _wallets,
        address[] memory _managers,
        address _admin
    ) {
        povertyLine = _povertyLine;
        topUpAmount = _topUpAmount;
        wallets = _wallets;

        for (uint256 i = 0; i < _managers.length; i++) {
            managers[_managers[i]] = true;
        }

        admin = _admin;
    }

    // ensure Reserve can receive gas from any source
    receive() external payable {}

    // === ADMIN FUNCTIONS ===

    function updatePovertyLine(uint256 _povertyLine) external onlyAdmin {
        povertyLine = _povertyLine;
    }

    function updateTopUpAmount(uint256 _topUpAmount) external onlyAdmin {
        topUpAmount = _topUpAmount;
    }

    function addWallet(address _wallet) external onlyAdmin {
        wallets.push(_wallet);
    }

    function removeWallet(address _wallet) external onlyAdmin {
        uint256 foundIndex = type(uint256).max;
        uint256 numWallets = wallets.length;

        for (uint256 i = 0; i < numWallets; i++) {
            if (wallets[i] == _wallet) {
                foundIndex = i;
                break;
            }
        }

        require(foundIndex < type(uint256).max, "Wallet not registered");
        wallets[foundIndex] = wallets[numWallets - 1];
        wallets.pop();
    }

    function addManager(address _manager) external onlyAdmin {
        managers[_manager] = true;
    }

    function removeManager(address _manager) external onlyAdmin {
        managers[_manager] = false;
    }

    // === END ADMIN FUNCTIONS ===

    function walletsSnapshot() external view returns (uint256 totalNum, uint256 needFunding) {
        totalNum = wallets.length;
        for (uint256 i = 0; i < totalNum; i++) {
            if (wallets[i].balance < povertyLine) {
                needFunding++;
            }
        }
    }

    // only managers may disperse funds
    function disperse() external {
        require(managers[msg.sender], "Only manager may disperse");
        require(address(this).balance >= topUpAmount, "Insufficient reserve size");

        uint256 numWallets = wallets.length;
        for (uint256 i = 0; i < numWallets; i++) {
            address wallet = wallets[i];
            if (wallet.balance < povertyLine) {
                (bool success,) = wallet.call{value: topUpAmount}("");
                require(success, "Failed to disperse to wallet");

                // break if not enough remaining
                if (address(this).balance < topUpAmount) {
                    break;
                }
            }
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Admin access required");
        _;
    }
}