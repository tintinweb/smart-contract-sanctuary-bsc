/**
 *Submitted for verification at BscScan.com on 2022-09-04
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

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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

// File: contracts/SPS.sol


pragma solidity ^0.8.9;




contract StonePaperScissors is Ownable {

    using Counters for Counters.Counter;

    enum Choice { NONE, STONE, PAPER, SCISSORS }

    struct PlayerInfo {
        address player;
        Choice choice;
        bool checked;
    }

    struct RoomInfo {
        address creator;
        uint256 size;
        uint256 createDate;
        uint256 endDate;
        Choice winResult;
        uint256 price;
        address token;
        uint256 usdPrice;
    }

    // player address => room id => PlayerInfo
    mapping(address => mapping(uint256 => PlayerInfo)) private playerInfoList;

    // room id => RoomInfo
    mapping(uint256 => RoomInfo) public roomList;

    mapping (uint256 => address[]) public playersList;

    // room id => PlayerInfo[]
    mapping(uint256 => PlayerInfo[]) private choiceList;

    struct BetInfo {
        bool status;        // status
        uint256 price;      // bet price
        uint256 period;     // period
    }

    // room size => BetInfo
    mapping(uint256 => BetInfo) public betInfoList;

    // room_id => choice => counter
    mapping(uint256 => mapping(Choice => uint256)) private roomChoiceCounter;

    // 25 / 1000 = 0.025 = 2.5(%)
    uint256 feePercent;

    Counters.Counter public roomCounter;

    event AddBetInfo(uint256 size, uint256 price, uint256 period);
    event RemoveBetInfo(uint256 size);
    event CreateRoom(uint256 roomId, uint256 size, Choice choice, address indexed token, uint256 tokenAmount);
    event BetGame(address indexed player, uint256 roomId, Choice choice, address indexed token, uint256 tokenAmount);
    event Harvest(uint256 roomId, address indexed player, address indexed token, uint256 amount);
    event Unstake(uint256 roomId, address indexed player, address indexed token, uint256 tokenAmount);
    event WithDraw(address indexed token, uint256 amount, address indexed to);

    constructor() {
        
        feePercent = 25;

        BetInfo memory _betInfo1 = BetInfo({
            status: true,
            price: 25000000000000000, // 0.025 eth
            period: 60*60*24*4 // 4 days
        });
        // 2 players game info
        betInfoList[2] = _betInfo1;

        BetInfo memory _betInfo2 = BetInfo({
            status: true,
            price: 20000000000000000, // 0.02 eth
            period: 60*60*24*4 // 4 days
        });
        // 4 players game info
        betInfoList[4] = _betInfo2;

    }

    /**
    * @param size room size
    * @param price bet price
    */
    function addBetInfo(uint256 size, uint256 price, uint256 period) external onlyOwner {

        require(size > 0, "SPS: Size should be a positive number");
        require(price > 0, "SPS: Price should be a positive number");
        require(period > 0, "SPS: Period should be a positive number");
        require(!betInfoList[size].status, "SPS: Size is already added");        

        BetInfo memory _betInfo = BetInfo({
            status: true,
            price: price,
            period: period
        });
        
        betInfoList[size] = _betInfo;

        emit AddBetInfo(size, price, period);

    }

    /**
    * @param size room size
    **/
    function removeBetInfo(uint256 size) external onlyOwner {

        require(size > 0, "SPS: Size should be a positive number");
        require(betInfoList[size].status, "SPS: Size is not added");

        delete betInfoList[size];

        emit RemoveBetInfo(size);

    }

    /**
    * @param size room size
    * @param choice creator choice for a game
    **/
    function createRoom(uint256 size, Choice choice, address token, uint256 tokenAmount, uint256 usdPrice) external payable {
        require(size > 0, "SPS: Size should be a positive number");
        require(choice != Choice.NONE, "SPS: You have to choose your choice");
        require(betInfoList[size].status, "SPS: Size is not added in room info list");
        require(usdPrice > 0, "SPS: UsdPrice should be a positive number");

        if(token == address(this)){

            require(msg.value == tokenAmount, " SPS: Please transfer native token as tokenAmount");

        }else{

            require(IERC20(token).allowance(msg.sender, address(this)) >= tokenAmount,
                "SPS: There is not enough token allownce amount to create room");
            require(IERC20(token).transferFrom(msg.sender, address(this), tokenAmount), 
                "SPS: There is an error to transfer some tokens in create room");

        }

        RoomInfo memory _roomInfo = RoomInfo({
            creator: msg.sender,
            size: size,
            createDate: block.timestamp,
            endDate: block.timestamp + betInfoList[size].period,
            winResult: Choice.NONE,
            price: tokenAmount,
            token: token,
            usdPrice: usdPrice
        });

        roomChoiceCounter[roomCounter.current()][choice]++;

        roomList[roomCounter.current()] = _roomInfo;
        
        PlayerInfo memory _playerInfo = PlayerInfo({
            player: msg.sender,
            choice: choice,
            checked: false
        });

        playerInfoList[msg.sender][roomCounter.current()] = _playerInfo;

        choiceList[roomCounter.current()].push(_playerInfo);

        playersList[roomCounter.current()] = [msg.sender];

        roomCounter.increment();

        emit CreateRoom(roomCounter.current() - 1, size, choice, token, tokenAmount);

    }

    function betGame(uint256 roomId, Choice choice, uint256 tokenAmount) external payable {
        
        require(roomId < roomCounter.current(), "SPS: Rooom id exceeds room number");
        require(choice != Choice.NONE, "SPS: You have to choose your choice");

        RoomInfo storage _roomInfo = roomList[roomId];

        require(_roomInfo.creator != address(0), "SPS: Room is not created");
        require(block.timestamp < _roomInfo.endDate, "SPS: Room has been already ended");
        require(choiceList[roomId].length < _roomInfo.size, "SPS: Room has been already fulled");
        require(_roomInfo.price == tokenAmount, "SPS: Token amount is not fit");
        
        if(address(this) == _roomInfo.token){

            require(tokenAmount == msg.value, "SPS: There is not enough price");

        }else{
            
            require(IERC20(_roomInfo.token).allowance(msg.sender, address(this)) >= tokenAmount, 
                "SPS: There is not enough allownce amount to bet in game");
            require(IERC20(_roomInfo.token).transferFrom(msg.sender, address(this), tokenAmount), 
                "SPS: There is an error to bet token in game");

        }

        require(playerInfoList[msg.sender][roomId].player == address(0), "SPS: You've already took part in this game");

        PlayerInfo memory _playerInfo = PlayerInfo({
            player: msg.sender,
            choice: choice,
            checked: false
        });

        choiceList[roomId].push(_playerInfo);

        playerInfoList[msg.sender][roomId] = _playerInfo;

        roomChoiceCounter[roomId][choice]++;

        playersList[roomId].push(msg.sender);

        if(choiceList[roomId].length == _roomInfo.size){

             if(roomChoiceCounter[roomId][Choice.STONE] > 0){

                if(roomChoiceCounter[roomId][Choice.PAPER] > 0){
                    
                    _roomInfo.winResult = Choice.PAPER;

                }else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0) {
                    
                    _roomInfo.winResult = Choice.STONE;

                }

            }else if(roomChoiceCounter[roomId][Choice.PAPER] > 0) {
                
                if(roomChoiceCounter[roomId][Choice.STONE] > 0){

                    _roomInfo.winResult = Choice.PAPER;

                } else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0){

                    _roomInfo.winResult = Choice.SCISSORS;

                }

            }else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0) {

                if(roomChoiceCounter[roomId][Choice.STONE] > 0){

                    _roomInfo.winResult = Choice.STONE;

                }else if(roomChoiceCounter[roomId][Choice.PAPER] > 0) {

                    _roomInfo.winResult = Choice.SCISSORS;

                }

            }

        }

        emit BetGame(msg.sender, roomId, choice, _roomInfo.token, tokenAmount);

    }

    function harvest(uint256 roomId) external {
        
        require(roomId < roomCounter.current(), "SPS: Rooom id exceeds room number");

        RoomInfo storage _roomInfo = roomList[roomId];
        PlayerInfo storage _playerInfo = playerInfoList[msg.sender][roomId];
        PlayerInfo[] storage _choiceList = choiceList[roomId];

        require(_roomInfo.creator != address(0), "SPS: Room is not created");
        require(!_playerInfo.checked, "SPS: You've already harvested");
        require(_roomInfo.size == choiceList[roomId].length, "SPS: There is not enough players to finish the game");

        uint256 _flagCounter = (roomChoiceCounter[roomId][Choice.STONE] == 0 ? 0 : 1) + 
                    (roomChoiceCounter[roomId][Choice.PAPER] == 0 ? 0 : 1) + 
                    (roomChoiceCounter[roomId][Choice.SCISSORS] == 0 ? 0 : 1);

        require(_flagCounter == 2, 
                "SPS: There is not winner");

        if(_roomInfo.winResult == Choice.NONE){

            if(roomChoiceCounter[roomId][Choice.STONE] > 0){
                if(roomChoiceCounter[roomId][Choice.PAPER] > 0){
                    _roomInfo.winResult = Choice.PAPER;
                }else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0) {
                    _roomInfo.winResult = Choice.STONE;
                }
            }else if(roomChoiceCounter[roomId][Choice.PAPER] > 0) {

                if(roomChoiceCounter[roomId][Choice.STONE] > 0){

                    _roomInfo.winResult = Choice.PAPER;

                } else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0){
                
                    _roomInfo.winResult = Choice.SCISSORS;
                }

            }else if(roomChoiceCounter[roomId][Choice.SCISSORS] > 0) {

                if(roomChoiceCounter[roomId][Choice.STONE] > 0){

                    _roomInfo.winResult = Choice.STONE;

                }else if(roomChoiceCounter[roomId][Choice.PAPER] > 0) {

                    _roomInfo.winResult = Choice.SCISSORS;

                }

            }

        }

        require(_roomInfo.winResult == _playerInfo.choice, "SPS: You are not winner");
        
        uint256 _winTotalPlayer = roomChoiceCounter[roomId][_playerInfo.choice];
        uint256 _totalMoney = 0;

        _totalMoney = _roomInfo.size * _roomInfo.price;

        uint256 _amount = _totalMoney * (1000 - feePercent) / 1000 / _winTotalPlayer;

        for(uint256 i = 0; i < _choiceList.length; i++){
            
            if(_choiceList[i].player == msg.sender){
                _choiceList[i].checked = true;
            }

        }

        if(_roomInfo.token == address(this)){
            
            require(address(this).balance >= _amount, "SPS: Balance error");
            (bool success, ) = (msg.sender).call{ value: _amount}("");
            require(success, "SPS: Get win price error");

        }else{
        
            require(IERC20(_roomInfo.token).balanceOf(address(this)) >= _amount, 
                "SPS: There is not enough token to harvest in contract");
            require(IERC20(_roomInfo.token).transfer(msg.sender, _amount), 
                "SPS: There is an error to harvest token");

        }

        _playerInfo.checked = true;

        emit Harvest(roomId, msg.sender, _roomInfo.token, _amount);

    }

    function unstake(uint256 roomId) external {
        
        require(roomId < roomCounter.current(), "SPS: Rooom id exceeds room number");
        
        RoomInfo storage _roomInfo = roomList[roomId];
        PlayerInfo storage _playerInfo = playerInfoList[msg.sender][roomId];
        PlayerInfo[] storage _choiceList = choiceList[roomId];

        require(_roomInfo.creator != address(0), "SPS: Room is not created");
        require(!_playerInfo.checked, "SPS: You've already harvested");
        
        if(_roomInfo.size == choiceList[roomId].length){
            require(((roomChoiceCounter[roomId][Choice.STONE] == 0 ? 0 : 1) + 
                    (roomChoiceCounter[roomId][Choice.PAPER] == 0 ? 0 : 1) + 
                    (roomChoiceCounter[roomId][Choice.SCISSORS] == 0 ? 0 : 1)) != 2, 
                "SPS: You cannot unstake. There is winner");
        } else {
            require(block.timestamp > _roomInfo.endDate, "SPS: Room is not finished yet");
        }

        if(_roomInfo.token == address(this)){
            require(address(this).balance >= _roomInfo.price, "SPS: Balance error");
            (bool success, ) = (msg.sender).call{ value: _roomInfo.price}("");
            require(success, "SPS: Withdraw unstake error");
        }else{
            require(IERC20(_roomInfo.token).balanceOf(address(this)) > _roomInfo.price,
                "SPS: There is not enough token to unstake in game");
            require(IERC20(_roomInfo.token).transfer(msg.sender, _roomInfo.price),
                "SPS: There is an error to unstake token in game");  
        }

        for(uint256 i = 0; i < _choiceList.length; i++){
            if(_choiceList[i].player == msg.sender){
                _choiceList[i].checked = true;
            }
        }

        _playerInfo.checked = true;

        emit Unstake(roomId, msg.sender, _roomInfo.token, _roomInfo.price);

    }

    function getChoiceList(uint256 roomId) public view returns(PlayerInfo[] memory) {
        
        require(roomList[roomId].size == choiceList[roomId].length || roomList[roomId].endDate < block.timestamp, "SPS: Game is not finished");

        return choiceList[roomId];

    }

    function withdraw(address token, uint256 amount, address payable to) external onlyOwner {
        
        require(amount > 0, "SPS: Amount should be a postive number.");

        if(address(this) == token){
            
            require(address(this).balance >= amount, "SPS: Out of native token balance.");

            (bool success, ) = (to).call{value: amount}("");

            require(success, "SPS: Withdraw failed");

        }else{
            
            require(IERC20(token).balanceOf(address(this)) >= amount,
                "SPS: There is not enough token to withraw");
            
            require(IERC20(token).transfer(to, amount),
                "SPS: There is an error to withraw token");

        }

        emit WithDraw(token, amount, to);

    }
    
}