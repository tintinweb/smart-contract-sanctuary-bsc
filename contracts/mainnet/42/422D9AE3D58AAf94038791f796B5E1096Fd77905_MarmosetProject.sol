/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// File: contracts/LotteryFinal.sol

/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: contracts/lotteryFull.sol


pragma solidity ^0.8.7;




interface IPancakeRouter01 {
    function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}


contract MarmosetProject is Ownable {

    IPancakeRouter01 public router = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address mmtToken = 0x3B5328D38a795514E044081fcaa764013715C666;
    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address feeAddr = 0xd46F0bB2853eD7482Bd428ebdED666ad5A70aA3e;
    address store = 0xB697b8778675004b3293B20AF3E98476D79d3191;
    address admin;

    uint currentLotteryNumber = 1; 
    uint lotteryPrice = 10 ether; //10$

    uint commission = 100; //100 - 1%
    uint division = 10000;
    uint jackpotPerc = 6000;
    uint deliveryFee = 99 ether; //99$

    uint constant ONE_WEEK = 604800;

    constructor(address _admin) {
        admin = _admin;
        nextLockTime.push(1668583200); //lock
        nextLockTime.push(1668583800); //1 number
        nextLockTime.push(1668584700); //2 number
        nextLockTime.push(1668585600); //3 number
        nextLockTime.push(1668586500); //4 number
        nextLockTime.push(1668587400); //5 number
        nextLockTime.push(1668588300); //6 number
        nextLockTime.push(1668589200); //unlock
        _transferOwnership(0x7af6A35806432B8071835beA14C7b44C19C45BD1);
    }


    mapping(uint => address[]) private players; //number of lottery -> array of players

    mapping(uint => uint) private dateOfLottery; //number of lottery -> timestamp

    mapping(uint => uint) private pool; //number of lotter - Prize pool 

    mapping(address => mapping(uint => uint[6])) private pastChoosedNumber; //user address - number of lottery - choosed number by client; 

    mapping(uint => uint[6]) private pastLotteryWonNumber; //number of lottery - won number; 

    mapping(address => mapping(uint => uint)) private wonByUser; //address of user - number of lottery  - won amount;

    mapping(address => mapping(uint => bool)) private played; //Address of user -> number of lottery -> played or not

    mapping(address => bool) public hasPlayed; //has ever play in lottery or not

    mapping(address => uint) private top20Amount; //address -> total Amount

    address[] public allPlayers;
    
    address[] private match2;
    address[] private match3;
    address[] private match4;
    address[] private match5;
    address[] private match6;

    uint[] private nextLockTime; //timestamp of [lock_buy, 1 number .... 6 number, unlock_buy]

    function buyTicket(uint[6] memory numbers) external {

        if(block.timestamp > nextLockTime[7]) {
            do {
                _updateLock();
            } while (block.timestamp - ONE_WEEK > nextLockTime[7]);

        } else if(block.timestamp > nextLockTime[0] && block.timestamp < nextLockTime[7]) {
            revert("Lottery in progress");
        }

        require(!played[msg.sender][currentLotteryNumber], "Already in lottery");
        if(!hasPlayed[msg.sender]) {
            hasPlayed[msg.sender] = true;
            allPlayers.push(msg.sender);
        }

        uint _amount = getPrice(lotteryPrice);
        IERC20(mmtToken).transferFrom(msg.sender, address(this), _amount);
        played[msg.sender][currentLotteryNumber] = true;
        pastChoosedNumber[msg.sender][currentLotteryNumber] = numbers;
        pool[currentLotteryNumber] += _amount;
        players[currentLotteryNumber].push(msg.sender);

    }

    function addJackPot(uint amount) external {
        IERC20(mmtToken).transferFrom(msg.sender, address(this), amount);
        pool[currentLotteryNumber] += amount;
    }

    
    function getWinner(uint[6] memory winNumber) external {
        require(msg.sender == admin,"caller is not an admin");

        uint prizeMatch2;
        uint prizeMatch3;
        uint prizeMatch4;
        uint prizeMatch5;
        uint prizeMatch6;
        uint rest;

        for (uint i = 0; i < players[currentLotteryNumber].length; i++) {
            uint matchNumber = _calculateMatch(winNumber, players[currentLotteryNumber][i]);
            if (matchNumber == 2) {
                match2.push(players[currentLotteryNumber][i]);
            } else if (matchNumber == 3) {
                match3.push(players[currentLotteryNumber][i]);
            } else if (matchNumber == 4) {
                match4.push(players[currentLotteryNumber][i]);
            } else if (matchNumber == 5) {
                match5.push(players[currentLotteryNumber][i]);
            } else if (matchNumber == 6) {
                match6.push(players[currentLotteryNumber][i]);
            }
        }
        uint fee = pool[currentLotteryNumber] * commission / division;
        pool[currentLotteryNumber] -= fee;
        uint ten = pool[currentLotteryNumber] / 10;
        uint jackpot = pool[currentLotteryNumber] * jackpotPerc / division;

        if(match2.length>0) {
            prizeMatch2 = ten / match2.length;
        } else {
            rest += ten;
        }
        if(match3.length>0) {
            prizeMatch3 = ten / match3.length;
        } else {
            rest += ten;
        }
        if(match4.length>0) {
            prizeMatch4 = ten / match4.length;
        } else {
            rest += ten;
        }
        if(match5.length>0) {
            prizeMatch5 = ten / match5.length;
        } else {
            rest += ten;
        }
        if(match6.length>0) {
            prizeMatch6 = jackpot / match6.length;

        } else {
            rest += jackpot;
        }

        if (rest > 0) {
            pool[currentLotteryNumber+1] += rest;
        }
        
        for (uint i = 0; i < match2.length; i++) {
            wonByUser[match2[i]][currentLotteryNumber] = prizeMatch2;
            top20Amount[match2[i]] += prizeMatch2;
        }
        for (uint i = 0; i < match3.length; i++) {
            wonByUser[match3[i]][currentLotteryNumber] = prizeMatch3;
            top20Amount[match3[i]] += prizeMatch3;
        }
        for (uint i = 0; i < match4.length; i++) {
            wonByUser[match4[i]][currentLotteryNumber] = prizeMatch4;
            top20Amount[match4[i]] += prizeMatch4;
        }
        for (uint i = 0; i < match5.length; i++) {
            wonByUser[match5[i]][currentLotteryNumber] = prizeMatch5;
            top20Amount[match5[i]] += prizeMatch5;
        }
        for (uint i = 0; i < match6.length; i++) {
            wonByUser[match6[i]][currentLotteryNumber] = prizeMatch6;
            top20Amount[match6[i]] += prizeMatch6;
        }

        pastLotteryWonNumber[currentLotteryNumber] = winNumber;
        dateOfLottery[currentLotteryNumber] = block.timestamp;

        IERC20(mmtToken).transfer(feeAddr, fee);
        _transferPrize(match2, prizeMatch2);
        _transferPrize(match3, prizeMatch3);
        _transferPrize(match4, prizeMatch4);
        _transferPrize(match5, prizeMatch5);
        _transferPrize(match6, prizeMatch6);
        delete match2;
        delete match3;
        delete match4;
        delete match5;
        delete match6;
        currentLotteryNumber++;
    }

    function _updateLock() private {
        for (uint i; i < nextLockTime.length; i++){
            nextLockTime[i] += ONE_WEEK;
        }
    }

    function _transferPrize(address[] memory winner, uint prize) private {
        for (uint i; i < winner.length; i++){
            IERC20(mmtToken).transfer(winner[i], prize);
        }
    }

    function _calculateMatch(uint[6] memory winNumber, address playerAddr) private view returns(uint i){
        for (i; i < winNumber.length; i++) {
            if (winNumber[i] != pastChoosedNumber[playerAddr][currentLotteryNumber][i]){
                return i;
            }
        }
    }
    
    
    function getPrice(uint amount) public view returns(uint) {
        address[] memory path = new address[](3);
        path[0] = usdt;
        path[1] = wbnb;
        path[2] = mmtToken;
        uint[] memory response = router.getAmountsOut(amount, path);
        return response[2];
    }

    function getPriceInUSD(uint amount) public view returns(uint) {
        address[] memory path = new address[](3);
        path[0] = mmtToken;
        path[1] = wbnb;
        path[2] = usdt;
        uint[] memory response = router.getAmountsOut(amount, path);
        return response[2];
    }

    function getPriceInUSDBatch(uint[] memory amount) public view returns(uint[] memory amounts) {
        amounts = new uint[](amount.length);
        address[] memory path = new address[](3);
        path[0] = mmtToken;
        path[1] = wbnb;
        path[2] = usdt;
        for (uint i; i < amount.length; i++){
            uint[] memory response = router.getAmountsOut(amount[i], path);
            amounts[i] = response[2];
        }

    }

    function getPriceInUSDHistory(address user, uint lotteryNumber) public view returns(uint) {
        uint won = wonByUser[user][lotteryNumber];
        address[] memory path = new address[](3);
        path[0] = mmtToken;
        path[1] = wbnb;
        path[2] = usdt;
        uint[] memory response = router.getAmountsOut(won, path);
        return response[2];
    }

    function getJackpot() external view returns(uint) {
        address[] memory path = new address[](3);
        path[0] = mmtToken;
        path[1] = wbnb;
        path[2] = usdt;
        uint[] memory response = router.getAmountsOut(pool[currentLotteryNumber], path);
        return response[2];
    }

    //========================================Shop=============================================

    event boughtToy(address who, uint when, uint paidMMT);

    function buyToy(uint amount) external {
        uint toPay = getPrice(deliveryFee);
        IERC20(mmtToken).transferFrom(msg.sender, store , (toPay * amount));
        emit boughtToy(msg.sender, block.timestamp, (toPay * amount));
    }

    //========================================View's Functions=================================

    function showLotteryInfo(address _address, uint lotteryNumber) external view returns(uint[6] memory, uint[6] memory, uint, uint) {
        return (pastLotteryWonNumber[lotteryNumber], pastChoosedNumber[_address][lotteryNumber], dateOfLottery[lotteryNumber],wonByUser[msg.sender][lotteryNumber]);
    }

    function currentLotteryNumberInfo() external view returns(uint) {
        return currentLotteryNumber;
    }

    function showWonNumber(uint lotteryNumber) external view returns(uint[6] memory) {
        return pastLotteryWonNumber[lotteryNumber];
    }

    function showMyNumber(address _address, uint lotteryNumber) external view returns(uint[6] memory) {
        return pastChoosedNumber[_address][lotteryNumber];
    }

    function showPlayers(uint lotteryNumber) external view returns(address[] memory) {
        return players[lotteryNumber];
    }

    function showLotteryDate(uint lotteryNumber) external view returns(uint) {
        return dateOfLottery[lotteryNumber];
    }

    function showLotteryPool(uint lotteryNumber) external view returns(uint) {
        return pool[lotteryNumber];
    }

    function showMyWon(uint lotteryNumber) external view returns(uint) {
        return wonByUser[msg.sender][lotteryNumber];
    }

    function showPlayed(uint lotteryNumber) external view returns(bool) {
        return played[msg.sender][lotteryNumber];
    }

    function getTop20() external view returns(address[] memory, uint[] memory){
        address[] memory _allPlayers = new address[](allPlayers.length);
        uint[] memory _totalAmount = new uint[](allPlayers.length);
        for(uint i; i < allPlayers.length; i++) {
            _allPlayers[i] = allPlayers[i];
            _totalAmount[i] = top20Amount[_allPlayers[i]];
        }
        return (_allPlayers, _totalAmount);
    }

    function getBlock() external view returns(uint) {
        return block.timestamp;
    }

    function getNextNumberTimer() external view returns(uint[] memory){
        return nextLockTime;
    }
 
    //========================================Admin's Functions================================

    function changeLotteryPrice(uint _$) external onlyOwner {
        lotteryPrice = _$;
    }
    function changeLotteryComission(uint _newCommission) external onlyOwner {
        commission = _newCommission;
    }

    function changeDeliveryFee(uint _deliveryFee) external onlyOwner {
        deliveryFee = _deliveryFee;
    }

    function withdraw(address _to) external onlyOwner {
        IERC20(mmtToken).transfer(_to, IERC20(mmtToken).balanceOf(address(this)));
    }

    function changeAdmin(address _newAdmin) external onlyOwner {
        admin = _newAdmin;
    }

}