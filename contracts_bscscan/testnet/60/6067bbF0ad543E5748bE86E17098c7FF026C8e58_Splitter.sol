// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

contract Splitter {

    address[] private wallet ;
    uint16[] private sharePercentage ;

    bool private _reentrant = false;
    modifier nonReentrant() {
        require(!_reentrant, "No reentrancy");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    constructor(
    address[] memory _wallet,
    uint16[] memory _sharePercentage
    ) {
        require(_wallet.length == _sharePercentage.length, "Not the same number of wallet and sharePercentage");
        wallet = _wallet;
        sharePercentage = _sharePercentage;
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawFund() external nonReentrant {
        uint256 startingBalance = address(this).balance;
        uint256 share;
        for (uint256 i = 0; i < wallet.length; i++) {
            share = startingBalance * sharePercentage[i] /100;
            payable(wallet[i]).transfer(share);
        }
    }
}