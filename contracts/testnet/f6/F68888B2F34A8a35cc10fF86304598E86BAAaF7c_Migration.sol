// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IGymFarming {
    function withdraw(uint256 _pid, uint256 _amount) external;

    function safeRewardTransfer(address _to, uint256 _amount) external;

    function _getBnbPrice() external view returns (uint256);
}

interface IGymNetwork {
    function mintFor(address account, uint96 amount) external;

    function burn(uint256 rawAmount) external;
}

interface IGymVaultBank {
    function deposit(
        uint256 _pid,
        uint256 _wantAmt,
        uint256 _referrerId
    ) external payable;
}

contract Migration {
    address public routerAddress;
    address public oldLPAddress;
    address public newLPAddress;
    address public oldGymFarming;
    address public newGymFarming;

    // constructor(
    //     address _routerAddress,
    //     address _oldLPAddress,
    //     address _newLPAddress,
    //     address _oldGymFarming,
    //     address _newGymFarming
    // ) {
    //     routerAddress = _routerAddress;
    //     oldLPAddress = _oldLPAddress;
    //     newLPAddress = _newLPAddress;
    //     oldGymFarming = _oldGymFarming;
    //     newGymFarming = _newGymFarming;
    // }
    function deposit(
        uint256 _pid,
        uint256 _wantAmt,
        uint256 _referrerId
    ) public {
        IGymVaultBank(0xa614bB5903f0a3Fa4a8d9CA9765b739DB340955e).deposit(
            _pid,
            _wantAmt,
            _referrerId
        );
    }
}