/*
    SPDX-License-Identifier: MIT
    Website: www.JackpotMiner.finance
*/

pragma solidity ^0.8.17;

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IGames {
    function Payment(
        address wallet,
        address source,
        uint256 id
    ) external payable;
}

contract JackpotMiner is Ownable {
    uint256 constant EGGS_TO_HATCH_1MINERS = 2592000; //for final version should be seconds in a day
    uint256 constant PSN = 10000;
    uint256 constant PSNH = 5000;
    uint256 public minBuy;
    uint256 public maxBuy;
    uint256 public toGameAmount;
    bool public initialized = false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => address) public referrals;
    uint256 public marketEggs;

    IGames Games = IGames(address(0));

    constructor() {
        ceoAddress = msg.sender;
        ceoAddress2 = msg.sender;
        Games = IGames(address(0x91a51253c9A295e2771B187343fe733480c73036));
        minBuy = 20000000000000000; //0.02 ether
        maxBuy = 200000000000000000; //0.2 ether
        toGameAmount = 10000000000000000; //0.01 ether
    }

    function hatchEggs(address ref, uint256 gameId) public {
        require(initialized, "not initialized");
        if (ref == msg.sender) {
            ref = address(0);
        }
        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed = getMyEggs();
        uint256 eggsValue = calculateEggSell(eggsUsed);
        if (eggsValue > minBuy) {
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
            Games.Payment{value: toGameAmount}(msg.sender, address(0), gameId);

            //send referral eggs
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

            //send referral eggs
            claimedEggs[referrals[msg.sender]] = SafeMath.add(
                claimedEggs[referrals[msg.sender]],
                SafeMath.div(eggsUsed, 10)
            );
        }

        //boost market to nerf miners hoarding
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(eggsUsed, 5));
    }

    function sellEggs() public {
        require(initialized, "not initialized");
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        uint256 fee2 = fee / 2;
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = SafeMath.add(marketEggs, hasEggs);
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        payable(msg.sender).transfer(SafeMath.sub(eggValue, fee));
    }

    function buyEggs(address ref, uint256 gameId) public payable {
        require(initialized, "not initialized");
        require(
            msg.value >= minBuy && msg.value <= maxBuy,
            "Invalid amount"
        );

        uint256 eggsBought = calculateEggBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        eggsBought = SafeMath.sub(eggsBought, devFee(eggsBought));
        uint256 fee = devFee(msg.value);
        uint256 fee2 = fee / 2;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref, gameId);
    }

    function giftMiner(address adr, uint256 gameId) payable public onlyOwner {
        require(initialized, "not initialized");
        require(msg.value >= minBuy && msg.value <= maxBuy, "Invalid amount");
        // calculate eggs
        uint256 value = SafeMath.sub(msg.value, toGameAmount);
        uint256 eggsBought = calculateEggBuy(
            value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        eggsBought = SafeMath.sub(eggsBought, devFee(eggsBought));
        uint256 fee = devFee(value);
        uint256 fee2 = fee / 2;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        hatcheryMiners[adr] = SafeMath.add(hatcheryMiners[adr], eggsBought);
        Games.Payment{value: toGameAmount}(adr, address(0), gameId);
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public pure returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
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

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 45), 1000);
    }

    function seedMarket() public payable onlyOwner {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 259200000000;
    }

    function getBalance() public view returns (uint256) {
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

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            EGGS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setMinBuy(uint256 _minBuy) public onlyOwner {
        require(_minBuy > toGameAmount, "is lower than toGameAmount");
        minBuy = _minBuy;
    }

    function setMaxBuy(uint256 _maxBuy) public onlyOwner {
        require(_maxBuy > minBuy, "is lower than minBuy");
        maxBuy = _maxBuy;
    }

    function setToGameAmount(uint256 _toGameAmount) public onlyOwner {
        require(_toGameAmount < minBuy, "is higher than minBuy");
        toGameAmount = _toGameAmount;
    }

    function setGamesAddress(address _gamesAddress) public onlyOwner {
        require(_gamesAddress != address(0), "is zero address");
        Games = IGames(_gamesAddress);
    }

    function setCEOAddress(address _ceoAddress) public onlyOwner {
        require(_ceoAddress != address(0), "is zero address");
        ceoAddress = _ceoAddress;
    }

    function setCEOAddress2(address _ceoAddress2) public onlyOwner {
        require(_ceoAddress2 != address(0), "is zero address");
        ceoAddress2 = _ceoAddress2;
    }

    function withdraw() public onlyOwner { // will be deleted after testing
        payable(msg.sender).transfer(address(this).balance);
    }
}

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