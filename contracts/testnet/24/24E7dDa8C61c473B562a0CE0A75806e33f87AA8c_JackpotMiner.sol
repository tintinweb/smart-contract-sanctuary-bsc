/*
    SPDX-License-Identifier: MIT
    Website: www.JackpotMiner.finance
*/
pragma solidity ^0.8.17;

import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUPG.sol";

contract JackpotMiner is Ownable {
    uint256 constant EGGS_TO_HATCH_1MINERS = 2592000; //for final version should be seconds in a day
    uint256 constant PSN = 10000;
    uint256 constant PSNH = 5000;
    uint256 public constant TAX = 45;
    uint256 public constant TAX_DENOM = 1000;
    uint256 public maxChestTime;
    uint256 public minBuy;
    uint256 public maxBuy;
    uint256 public toGameAmount;
    bool public initialized = false;
    address public ceoAddress1;
    address public ceoAddress2;
    address public ceoAddress3;
    address public upgSource;
    IUPG upg = IUPG(address(0));
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => address) public referrals;
    uint256 public marketEggs;

    event GiftMiner(address indexed to, uint256 amount);

    constructor() {
        ceoAddress1 = msg.sender;
        ceoAddress2 = 0xA791EA12F7c38CBBE2171C06A6A37472a4470bf6;
        ceoAddress3 = msg.sender;
        maxChestTime = 86400; 
        minBuy = 20000000000000000; 
        maxBuy = 200000000000000000; 
        toGameAmount = 10000000000000000;
        upg = IUPG(address(0x0Ba41A12d44FD881549Fc8141321194DE451028E));
        upgSource = address(0x3Ea1B87eFBc8c469376Cc5634630d514Ca20b79F);
    }

    function hatchEggs(uint256 _gameId) public {
        require(initialized, "not initialized");
        uint256 eggsUsed = getMyEggs();
        uint256 eggsValue = calculateEggSell(eggsUsed);
        if (eggsValue >= minBuy) {
            claimedEggs[msg.sender] = 0;
            lastHatch[msg.sender] = block.timestamp;
            uint256 newEggs = calculateEggBuy(
                SafeMath.sub(eggsValue, toGameAmount),
                address(this).balance
            );
            uint256 newMiner = SafeMath.div(newEggs, EGGS_TO_HATCH_1MINERS);
            hatcheryMiners[msg.sender] = SafeMath.add(
                hatcheryMiners[msg.sender],
                newMiner
            );
            upg.Payment{value: toGameAmount}(msg.sender, upgSource, _gameId);

            claimedEggs[referrals[msg.sender]] = SafeMath.add(
                claimedEggs[referrals[msg.sender]],
                SafeMath.div(newEggs, 10)
            );
        } else {
            uint256 newMiners = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1MINERS);
            claimedEggs[msg.sender] = 0;
            lastHatch[msg.sender] = block.timestamp;
            hatcheryMiners[msg.sender] = SafeMath.add(
                hatcheryMiners[msg.sender],
                newMiners
            );

            claimedEggs[referrals[msg.sender]] = SafeMath.add(
                claimedEggs[referrals[msg.sender]],
                SafeMath.div(eggsUsed, 10)
            );
        }
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(eggsUsed, 4));
    }

    function sellEggs() external {
        require(initialized, "not initialized");
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee1 = SafeMath.div(SafeMath.mul(devFee(eggValue), 20), TAX);
        uint256 fee2 = SafeMath.div(SafeMath.mul(devFee(eggValue), 5), TAX);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = SafeMath.add(marketEggs, hasEggs);
        payable(ceoAddress1).transfer(fee1);
        payable(ceoAddress2).transfer(fee1);
        payable(ceoAddress3).transfer(fee2);
        payable(msg.sender).transfer(SafeMath.sub(eggValue, devFee(eggValue)));
    }

    function buyEggs(address _ref, uint256 _gameId) external payable {
        require(initialized, "not initialized");
        require(msg.value >= minBuy && msg.value <= maxBuy, "Invalid amount");
        if (_ref == msg.sender) {
            _ref = address(0);
        }
        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = _ref;
        }

        uint256 fee1 = SafeMath.div(SafeMath.mul(devFee(msg.value), 20), TAX);
        uint256 fee2 = SafeMath.div(SafeMath.mul(devFee(msg.value), 5), TAX);
        payable(ceoAddress1).transfer(fee1);
        payable(ceoAddress2).transfer(fee1);
        payable(ceoAddress3).transfer(fee2);

        lastHatch[msg.sender] = block.timestamp;
        uint256 newEggs = calculateEggBuy(
            SafeMath.sub(
                SafeMath.sub(msg.value, devFee(msg.value)),
                toGameAmount
            ),
            address(this).balance
        );
        uint256 newMiner = SafeMath.div(newEggs, EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiner
        );
        upg.Payment{value: toGameAmount}(msg.sender, upgSource, _gameId);

        claimedEggs[referrals[msg.sender]] = SafeMath.add(
            claimedEggs[referrals[msg.sender]],
            SafeMath.div(newEggs, 10)
        );
    }

    function giftMiner(address _adr, uint256 _gameId) external payable {
        require(initialized, "not initialized");
        require(msg.value >= minBuy && msg.value <= maxBuy, "Invalid amount");
        uint256 value = SafeMath.sub(msg.value, toGameAmount);
        uint256 eggsBought = calculateEggBuy(
            value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        hatcheryMiners[_adr] = SafeMath.add(hatcheryMiners[_adr], eggsBought);
        upg.Payment{value: toGameAmount}(_adr, upgSource, _gameId);
        emit GiftMiner(_adr, msg.value);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) internal pure returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateEggSell(uint256 _eggs) public view returns (uint256) {
        return calculateTrade(_eggs, marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 _eth, uint256 _contractBalance)
        internal
        view
        returns (uint256)
    {
        return calculateTrade(_eth, _contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 _eth)
        external
        view
        returns (uint256)
    {
        return calculateEggBuy(_eth, address(this).balance);
    }

    function devFee(uint256 _amount) internal pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, TAX), TAX_DENOM);
    }

    function seedMarket() public payable onlyOwner {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 259200000000;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint256) {
        return hatcheryMiners[msg.sender];
    }

    function getMyEggs() public view returns (uint256) {
        return
            SafeMath.add(
                claimedEggs[msg.sender],
                getEggsSinceLastHatch(msg.sender)
            );
    }

    function getEggsSinceLastHatch(address _adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            maxChestTime,
            SafeMath.sub(block.timestamp, lastHatch[_adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[_adr]);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function setMinBuy(uint256 _minBuy) public onlyOwner {
        require(_minBuy > toGameAmount, "should be higher than toGameAmount");
        minBuy = _minBuy;
    }

    function setMaxBuy(uint256 _maxBuy) public onlyOwner {
        require(_maxBuy > minBuy, "should be higher than minBuy");
        maxBuy = _maxBuy;
    }

    function setToGameAmount(uint256 _toGameAmount) public onlyOwner {
        require(_toGameAmount < minBuy, "should be lower than minBuy");
        toGameAmount = _toGameAmount;
    }

    function setCEOAddress1(address _ceoAddress1) public onlyOwner {
        require(_ceoAddress1 != address(0), "is zero address");
        ceoAddress1 = _ceoAddress1;
    }

    function setCEOAddress2(address _ceoAddress2) public onlyOwner {
        require(_ceoAddress2 != address(0), "is zero address");
        ceoAddress2 = _ceoAddress2;
    }

    function setCEOaddress3(address _ceoAddress3) public onlyOwner {
        require(_ceoAddress3 != address(0), "is zero address");
        ceoAddress3 = _ceoAddress3;
    }

    function setUPG(address _upg) public onlyOwner {
        require(_upg != address(0), "is zero address");
        upg = IUPG(_upg);
    }

    function setUPGSource(address _upgSource) public onlyOwner {
        require(_upgSource != address(0), "is zero address");
        upgSource = _upgSource;
    }

    function setMaxChestTime(uint256 _maxChestTime) public onlyOwner {
        require(_maxChestTime >= 86400, "should be higher than 86400");
        maxChestTime = _maxChestTime;
    }

    // playGame function will be deleted for mainnet launch
    function playGame(uint256 _gameId) public payable {
        upg.Payment{value: msg.value}(msg.sender, upgSource, _gameId);
    }

    // withdraw function will be deleted for mainnet launch
    function withdraw() public onlyOwner { 
        payable(msg.sender).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUPG {
    function Payment(
        address wallet,
        address source,
        uint256 id
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}