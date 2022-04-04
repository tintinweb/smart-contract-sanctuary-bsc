/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// File: Selendra.sol

//SPDX-License-Identifier: NONE
pragma solidity ^0.8.0;

// Imported OZ helper contracts
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/proxy/Initializable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";



// Projecting to run 1 year
// 100 Daily x 365 = 36500
// Project will start with 36500 SEL Token in Treasury
// During the first 2 weeks, we will increase the reward price to 500 SEL per day for 2 weeks = 7000 SEL
contract Selottery is Ownable {

    address public recentWinner;

    // TODO: change price to 10 SEL
    uint256 private ticketPriceInSel = 1; // 100
    uint256 private rewardSize = 1; // 2000

    // Treasury will collect 20% from all the tickets' sales
    // Substainable Flow, number of tickets to fill the reward
    // rewardSize / (ticketPriceInSel X treasuryFee/100) = 50 ickets to break even
    uint256 private treasuryFee = 20; 
    uint256 public allTimeCollectedFee;

    uint256 public currentLotteryId;
    
    // Represents the status of the lottery
    enum Status {
        Open,
        Close,
        Drawing
    }

    // All the needed info around a lottery
    struct Lottery {
        Status status;        // Status for lotto
        uint256 lotteryID;    // ID for lotto
        uint256 startTime;
        uint256 endTime;
        address winner;
        uint256 winnerTicketNumber;
        uint256 numTickets;
        uint256 prizePool;
        uint256 addOnPrize;
        uint256 collectedFee;
    }

    // lotteryID, Lottery
    mapping(uint256 => Lottery) private _lotteries;
    // lotteryID, array of players
    mapping(uint256 => address[]) private _players;

    event startTicket(uint256 lotteryId, uint256 startTime, uint256 endTime, uint256 prizePool);
    event closeTicket(uint256 lotteryId, uint256 startTime, uint256 endTime);
    event generateRandomNumber(uint randomNumber, address winnerAddress, uint256 prize);

    constructor() {}

    function startLottery(uint256 _startTime, uint256 _endTime) public onlyOwner {
        currentLotteryId++;
        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            lotteryID: currentLotteryId,
            startTime: _startTime,
            endTime: _endTime,
            winner: 0x0000000000000000000000000000000000000000,
            winnerTicketNumber: 9999999999,
            numTickets: 0,
            prizePool: rewardSize * 10**18,
            addOnPrize: 0,
            collectedFee: 0
        });

        emit startTicket(currentLotteryId, _lotteries[currentLotteryId].startTime, _lotteries[currentLotteryId].endTime, _lotteries[currentLotteryId].prizePool);
    }

    function closeLottery() public onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > _lotteries[currentLotteryId].endTime, "Lottery not over");
        
        _lotteries[currentLotteryId].status = Status.Close;
        emit closeTicket(currentLotteryId, _lotteries[currentLotteryId].startTime, _lotteries[currentLotteryId].endTime);
    }

    function drawWinner() public onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
        require(_players[currentLotteryId].length > 0, "No tickets were purchased");
        
        uint winnerIndex = randomness();
        recentWinner = _players[currentLotteryId][winnerIndex];
        _lotteries[currentLotteryId].status = Status.Drawing;
        _lotteries[currentLotteryId].winner = recentWinner;
        _lotteries[currentLotteryId].winnerTicketNumber = winnerIndex + 1; // index needs to add one for number

        // safe transfer token
        uint256 prize = _lotteries[currentLotteryId].prizePool + _lotteries[currentLotteryId].addOnPrize;
        // payable(recentWinner).transfer(prize);

        emit generateRandomNumber(winnerIndex, recentWinner, prize);
    }

    function randomness() private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encode(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encode(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encode(msg.sender)))) / (block.timestamp)) +
            block.number,
            _players[currentLotteryId]
        )));
        return seed % _players[currentLotteryId].length;
    }

    function enter() public payable {
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp <= _lotteries[currentLotteryId].endTime, "Lottery already close");
        require(msg.value >= ticketPriceInSel * 10**18, "Not enough Sel!");
        
        _players[currentLotteryId].push(msg.sender);
        _lotteries[currentLotteryId].numTickets++;
        uint256 fee = msg.value * (treasuryFee) / 100;
        _lotteries[currentLotteryId].collectedFee += fee; 
        _lotteries[currentLotteryId].addOnPrize += msg.value - fee;
        allTimeCollectedFee += fee;
    }

    function enter(uint256 _count) public payable {
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(msg.value >= _count * ticketPriceInSel * 10**18, "Not enough Sel!");
        
        for (uint256 i = 0; i < _count; i++) {
             _players[currentLotteryId].push(msg.sender);
        }

        _lotteries[currentLotteryId].numTickets += _count;
        uint256 fee = msg.value * (treasuryFee) / 100;
        _lotteries[currentLotteryId].collectedFee += fee; 
        _lotteries[currentLotteryId].addOnPrize += msg.value - fee;
        allTimeCollectedFee += fee;
    }

    function getLottery(uint256 _lotteryId) public view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

    function getPlayers(uint256 _lotteryId) public view returns (address[] memory) {
        return _players[_lotteryId];
    }

    function getPlayersSize(uint256 _lotteryId) public view returns (uint256) {
        return _players[_lotteryId].length;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    // This is a backdoor, hopefully we do not have to use this method ever.
    // in drawWinner(), we send tokens to winner but the transaction can fail.
    // This method is to be used by admin to recollectable back the fund to the winner
    function sendTokenToWinner(uint256 _lotteryId) public onlyOwner {
        payable(_lotteries[_lotteryId].winner).transfer(_lotteries[_lotteryId].prizePool + _lotteries[_lotteryId].addOnPrize);
    }

    function geTicketPriceInSel() public view returns (uint256) {
        return ticketPriceInSel;
    }

    function setTicketPriceInSel(uint256 _ticketPriceInSel) public onlyOwner {
        ticketPriceInSel = _ticketPriceInSel;
    }

    function getRewardSize() public view returns (uint256) {
        return rewardSize;
    }

    function setRewardSize(uint256 _rewardSize) public onlyOwner {
        rewardSize = _rewardSize;
    }

    function getTreasuryFee() public view returns (uint256) {
        return treasuryFee;
    }

    function setTreasuryFee(uint256 _treasuryFee) public onlyOwner {
        treasuryFee = _treasuryFee;
    }

    function getPrize(uint256 _lotteryId) public view returns (uint256) {
        return _lotteries[_lotteryId].addOnPrize + _lotteries[_lotteryId].prizePool;
    }

    function getCurrentLotteryId() public view returns (uint256) {
        return currentLotteryId;
    }

    function getCurrentLotteryDetails() public view returns (Lottery memory) {
        return _lotteries[currentLotteryId];
    }
}