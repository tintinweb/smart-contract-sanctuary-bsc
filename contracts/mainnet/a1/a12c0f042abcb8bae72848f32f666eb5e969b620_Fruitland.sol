/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

// lotto360.io - fruitland game

contract Fruitland {
    address private owner;
    uint256 private ctFee = 5;
    bool private status = false;
    uint256 private currentSpinId = 0;
    uint8 public prizeMultiplier = 100;
    uint256 public minSpinAmount = 10000000000000000; // 0.01 bnb
    uint256 public maxSpinAmount = 10000000000000000; // 0.01 bnb

    constructor() {
        owner = msg.sender;
    }

    enum SpinStatus {
        Ready,
        Closed
    }

    struct Spin {
        uint256 id;
        uint256 amount;
        uint256 purchaseTime;
        uint256 spinTime;
        uint256 ctFee;
        uint8 multiplier;
        uint256 result;
        uint256 guess;
        address user;
        SpinStatus status;
    }

    mapping(uint256 => Spin) private Spins;
    mapping(address => uint256[]) private UserSpins;

    /**************************************************************************************************
     * @dev modifiers
     **************************************************************************************************/
    modifier nonContract() {
        require(tx.origin == msg.sender, "Contract not allowed");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**************************************************************************************************
     * @dev events
     **************************************************************************************************/
    event SpinPurchased(uint256 id, address user, uint256 amount, uint256 time, uint256 multiplier);

    event SlotSpined(
        uint256 id,
        address user,
        uint256 amount,
        uint256 guess,
        uint256 result,
        uint256 time,
        uint256 multiplier
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinSpinAmountUpdated(uint256 minSpinAmount);
    event MaxSpinAmountUpdated(uint256 maxSpinAmount);
    event TokenTransferred(address to, uint256 amount);
    event MultiplierUpdated(uint8 multiplier);
    event InjectFunds(address indexed sender);

    /**************************************************************************************************
     * @dev Contspiner Functions
     **************************************************************************************************/
    function FundsInject() public payable {
        emit InjectFunds(msg.sender);
    }

    function SetContractFee(uint8 _ctFee) external onlyOwner nonContract {
        ctFee = _ctFee;
    }

    function SetPrizeMultiplier(uint8 _prizeMultiplier) external onlyOwner nonContract {
        prizeMultiplier = _prizeMultiplier;
        emit MultiplierUpdated(prizeMultiplier);
    }

    function SetMinSpinAmount(uint256 _minSpinAmount) external onlyOwner nonContract {
        minSpinAmount = _minSpinAmount;
        emit MinSpinAmountUpdated(minSpinAmount);
    }

    function SetMaxSpinAmount(uint256 _maxSpinAmount) external onlyOwner nonContract {
        maxSpinAmount = _maxSpinAmount;
        emit MaxSpinAmountUpdated(maxSpinAmount);
    }

    function transferOwnership(address newOwner) external onlyOwner nonContract {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**************************************************************************************************
     * @dev MainGame Functions
     **************************************************************************************************/
    function PurchaseSpin() public payable nonContract {
        require(msg.value >= minSpinAmount, "Spin amount must be greater than minimum amount");
        require(msg.value <= maxSpinAmount, "Spin amount must be less than maximum amount");

        require(!_anyReadySpins(msg.sender), "You already purchase a spin");

        uint256 toPay = ((msg.value - ((msg.value / 100) * ctFee)) * prizeMultiplier);
        require(address(this).balance > toPay, "Spin prize is bigger than contract balance, try small amount");

        currentSpinId++;

        Spins[currentSpinId - 1] = Spin({
            id: currentSpinId,
            amount: msg.value,
            purchaseTime: block.timestamp,
            spinTime: 0,
            ctFee: ctFee,
            multiplier: prizeMultiplier,
            guess: 0,
            result: 0,
            user: msg.sender,
            status: SpinStatus.Ready
        });

        UserSpins[msg.sender].push(currentSpinId);

        emit SpinPurchased(currentSpinId, msg.sender, msg.value, block.timestamp, prizeMultiplier);
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function SpinSlot(
        uint256 seed,
        uint256 guess,
        uint256 spinId,
        address user
    ) public onlyOwner nonContract returns (uint256) {
        Spin memory spin = Spins[spinId - 1];
        require(spin.status == SpinStatus.Ready, "Spin is spinned before");
        require(user == spin.user, "Spin belongs to other user");
        require(guess > 999999, "Guessed number is too low");
        require(guess < 2000000, "Guessed number is too high");

        uint256 result = uint256(_generateRandomNumber(seed));

        Spins[spinId - 1].spinTime = block.timestamp;
        Spins[spinId - 1].result = result;
        Spins[spinId - 1].guess = guess;
        Spins[spinId - 1].status = SpinStatus.Closed;

        if (guess == result) {
            uint256 toPay = (spin.amount - ((spin.amount / 100) * ctFee)) * prizeMultiplier;
            _transferTokens(spin.user, toPay);
        }

        emit SlotSpined(spin.id, spin.user, spin.amount, guess, result, block.timestamp, spin.multiplier);
        return result;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function _generateRandomNumber(uint256 _seed) private view onlyOwner nonContract returns (uint256) {
        uint256 number = uint256(
            keccak256(
                abi.encodePacked(
                    _seed,
                    block.number,
                    block.coinbase,
                    block.gaslimit,
                    block.timestamp,
                    blockhash(block.number - 1),
                    status
                )
            )
        );

        return (number % 1000000) + 1000000;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function _anyReadySpins(address user) private view returns (bool) {
        uint256[] memory userSpins = UserSpins[user];
        for (uint256 i = 0; i < userSpins.length; i++) {
            uint256 spinId = userSpins[i];
            if (Spins[spinId - 1].status == SpinStatus.Ready) {
                return true;
            }
        }
        return false;
    }

    /**************************************************************************************************
     * @dev Payment Functions
     **************************************************************************************************/
    function _transferTokens(address _to, uint256 _amount) private onlyOwner nonContract {
        uint256 currentBalance = address(this).balance;
        require(currentBalance >= _amount, "insufficient contract balance");
        payable(_to).transfer(_amount);

        emit TokenTransferred(_to, _amount);
    }

    function WithdrawToken(address to, uint256 amount) public onlyOwner nonContract {
        _transferTokens(to, amount);
    }

    /**************************************************************************************************
     * @dev Getter Functions
     **************************************************************************************************/
    function GetSpins() public view onlyOwner nonContract returns (Spin[] memory) {
        Spin[] memory spins = new Spin[](currentSpinId);
        for (uint256 i = 0; i < currentSpinId; i++) {
            spins[i] = Spins[i];
        }
        return spins;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetSpinById(uint256 spinId) public view onlyOwner returns (Spin memory) {
        return Spins[spinId - 1];
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetUserSpins(address userAddress) public view onlyOwner nonContract returns (Spin[] memory) {
        uint256[] memory userSpins = UserSpins[userAddress];
        uint256 size = userSpins.length;
        Spin[] memory spins = new Spin[](size);

        for (uint256 i = 0; i < size; i++) {
            uint256 spinId = userSpins[i];
            spins[i] = Spins[spinId - 1];
        }
        return spins;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function UserGetSpinById(uint256 spinId) public view returns (Spin memory) {
        Spin memory spin;
        if (Spins[spinId - 1].user == msg.sender) {
            spin = Spins[spinId - 1];
        }
        return spin;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetReadySpin() public view returns (Spin memory) {
        uint256[] memory userSpins = UserSpins[msg.sender];
        Spin memory spin;
        for (uint256 i = 0; i < userSpins.length; i++) {
            uint256 spinId = userSpins[i];
            if (Spins[spinId - 1].status == SpinStatus.Ready) {
                spin = Spins[spinId - 1];
            }
        }
        return spin;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetMyHistory() public view returns (Spin[] memory) {
        uint256[] memory userSpins = UserSpins[msg.sender];
        uint256 size = userSpins.length;
        Spin[] memory spins = new Spin[](size);

        for (uint256 i = 0; i < size; i++) {
            uint256 spinId = userSpins[i];
            spins[i] = Spins[spinId - 1];
        }
        return spins;
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetSettingForUser()
        public
        view
        returns (
            uint8,
            uint256,
            uint256
        )
    {
        return (prizeMultiplier, minSpinAmount, maxSpinAmount);
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function GetSettingForAdmin()
        public
        view
        onlyOwner
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        return (prizeMultiplier, minSpinAmount, maxSpinAmount, ctFee, currentSpinId, owner);
    }

    function SetStatus(bool newStatus) public {
        status = newStatus;
    }
}