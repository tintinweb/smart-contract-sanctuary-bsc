// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";

contract TestToken is BEP20Detailed, BEP20 {
    mapping(address => bool) private isBlacklist;
    mapping(address => bool) private liquidityPool;
    mapping(address => bool) private whitelistFee;
    mapping(address => uint256) private lastSell;

    uint8 private buyFee = 0;
    uint8 private transferFee = 0;

    // sell fee
    uint8 private burnFee = 1;
    uint8 private mktFee = 2;
    uint8 private poolFee = 1;

    uint8 private sellCooldown = 20;

    uint256 private totalFee;

    address private mktReceiver;
    address private poolReceiver;

    event changeBlacklist(address _wallet, bool status);
    event changeCooldown(uint8 sellCooldown);
    event changeFee(
        uint8 _buyFee,
        uint8 _transferFee,
        uint8 _burnFee,
        uint8 _mktFee,
        uint8 _poolFee
    );
    event changeLiquidityPoolStatus(address lpAddress, bool status);
    event changeReceiver(address mktReceiver, address poolReceiver);
    event changeWhitelistFee(address _address, bool status);

    constructor() BEP20Detailed("TEST2", "BT2", 18) {
        uint256 totalTokens = 10000 * 10**uint256(decimals());
        _mint(msg.sender, totalTokens);
        buyFee = 0;
        transferFee = 0;
        burnFee = 1;
        mktFee = 2;
        poolFee = 1;

        sellCooldown = 20;
        mktReceiver = 0x27A2b2CE8aa4c169a58a788Bd66cA479c43242D5;
        poolReceiver = 0x27A2b2CE8aa4c169a58a788Bd66cA479c43242D5;
    }

    function setBlacklist(address _wallet, bool _status) external onlyOwner {
        isBlacklist[_wallet] = _status;
        emit changeBlacklist(_wallet, _status);
    }

    function setCooldownForSelling(uint8 _sellCooldown) external onlyOwner {
        sellCooldown = _sellCooldown;
        emit changeCooldown(_sellCooldown);
    }

    function setLiquidityPoolStatus(address _lpAddress, bool _status)
        external
        onlyOwner
    {
        liquidityPool[_lpAddress] = _status;
        emit changeLiquidityPoolStatus(_lpAddress, _status);
    }

    function setReceiver(address _mktReceiver, address _poolReceiver)
        external
        onlyOwner
    {
        mktReceiver = _mktReceiver;
        poolReceiver = _poolReceiver;
        emit changeReceiver(mktReceiver, poolReceiver);
    }

    function setFeees(
        uint8 _buyFee,
        uint8 _transferFee,
        uint8 _burnFee,
        uint8 _mktFee,
        uint8 _poolFee
    ) external onlyOwner {
        buyFee = _buyFee;
        transferFee = _transferFee;
        burnFee = _burnFee;
        mktFee = _mktFee;
        poolFee = _poolFee;
        emit changeFee(_buyFee, _transferFee, _burnFee, _mktFee, _poolFee);
    }

    function getFeees()
        external
        view
        returns (
            uint8 _buyFee,
            uint8 _transferFee,
            uint8 _burnFee,
            uint8 _mktFee,
            uint8 _poolFee
        )
    {
        return (buyFee, transferFee, burnFee, mktFee, poolFee);
    }

    function setWhitelist(address _address, bool _status) external onlyOwner {
        whitelistFee[_address] = _status;
        emit changeWhitelistFee(_address, _status);
    }

    function _transfer(
        address sender,
        address receiver,
        uint256 amount
    ) internal virtual override {
        require(
            receiver != address(this),
            string("It is not allowed to transfer tokens to this address.")
        );
        
        require(!isBlacklist[sender], "User is on the blacklist.");

        if (liquidityPool[sender] == true) {
            //Buy token
            totalFee = (amount * buyFee) / 100;
        } else if (liquidityPool[receiver] == true) {
            //Sell token
            totalFee = (amount * (burnFee + mktFee + poolFee)) / 100;

            require(
                lastSell[sender] < (block.timestamp - sellCooldown),
                string(
                    "Consecutive sales are not allowed. Please wait a moment."
                )
            );
            lastSell[sender] = block.timestamp;
        } else if (
            whitelistFee[sender] ||
            whitelistFee[receiver] ||
            sender == mktReceiver ||
            receiver == mktReceiver ||
            sender == poolReceiver ||
            receiver == poolReceiver
        ) {
            totalFee = 0;
        } else {
            totalFee = (amount * transferFee) / 100;
        }

        if (totalFee > 0) {
            super._transfer(sender, address(0), (amount * burnFee) / 100); // burn
            super._transfer(sender, mktReceiver, (amount * mktFee) / 100); // For mkt
            super._transfer(sender, poolReceiver, (amount * poolFee) / 100); // For 2nd liquid
        }

        super._transfer(sender, receiver, amount - totalFee);
    }
}