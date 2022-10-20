/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/*

                      ..                 -=+-         .-=++++=
                    =++++++=-:.      -==+++*====+. .=+++++++++=
                   -+++++++++++++=-.=+++++++++*+--++++++++++++*
                   =++++**+++++++++++++++++++++++*+++++++***+++:
                   =+++*=--=++++++++++++++++++++++++++++=--+*++-
                   -++++....:=*++++++++++++++++++++++++:. .-+++-
                   .+++*:...=*+++++++++++++++++++++*###*-..=+++-
                    +++++:-*+++++++*%@@@%#+++++++%@+---*%*+*+++:
                    -+++***+++++++%%=:..:[email protected]#++++#*....   ##++++.
                     ++++*+++++++##   .:..:##+++%-*#.-+.  %++++
                     [email protected]  :+%+*@=%+++#[email protected]@@@@-  +.:+:
       .              =+:   .:=++%   -#@@@@**+-=*=*@@@@-  -  :.
   .:.....:.::        .-        :+:  :[email protected]@@@=+:  .--=-+-  .    .
  :-..       ..-:                 -.  .-.+-:.      .           .
 .=-:.           ::                ..          -+##*+           .
 =--:.     .      -.                           .=*#+:           .
 =--:..::=:-:.... .-                        ..       ..      ..
 =-::==+++++++-.-.-:    ....                  ..    .      ..
 :=++**++++++++--.         .::::...                    ..:.
  -******+++++++++-:.:-==+++=+=-::::::::.......    ..::.
   :+********+++++++++++=++++++**++==--------::::::-=
     :+*********+++++========+++********+==----::::::.
          :-=+*****++++==========++++**=-::::............
                ++++++++=========++++::....
               :++++++++++=======++++=..
               -++++++++++*=====+++++=.                 .
               +++++++++++*+++++*++++==                 ..
            .-+++++++++++++*+++#**++++=-               ..
            ***+++++++++++++::-***++++++             :- .
            ****++++++++++*+-:-***+++++*.        .:-++
            +*****++++++++#***+#**++++++=----===++++++-
            :******+*==-. =****#***+++++*.   ++++++++++.
             ==--::..-     **+++#+++++==+=    +*+++++++=
              :.     -     .+...:=::..  ..:    ==--::..:
               .:   .-      .-    --.    .-     .:     :
                 ....         ::::. ::::::        ......
*/


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _grantToSecondOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
  *  main game contract
  */
contract DogeDashGame is Ownable{
    // HELLO token instance
    IERC20 public HELLO;

    // Player Info
    struct PlayerInfo {
        // depositted amount
        uint256 depositted_amount;
        // timestamp when withdraw
        uint256 last_withdraw_ts;
    }

    // check if game is paused
    bool public isGamePaused;
    // useWhitelist
    bool public useWhitelist = false;

    // game version
    uint256 private game_version = 1;

    // HELLO amount whenever play game
    // e.g. 1 HELLO
    uint256 public deposit_amount = 1 * 10 ** 18;

    // Limit token amount per deposit
    uint256 public MAX_DEPOSIT_AMOUNT;
    // Limit token amount per withdraw
    uint256 public MAX_WITHDRAW_AMOUNT;
    // Limit token amount per withdraw
    uint256 public MIN_WITHDRAW_AMOUNT;

    uint256 public WITHDRAW_EXPIRATION_SECONDS = 60; // 1 Minute

    // a rate limit so that the game cannot withdraw to a user repeatedly
    uint256 public PLAYER_WITHDRAW_RATE;

    // Admin wallet address (game wallet)
    // Only this wallet will call withdrawToPlayer function
    address public admin_wallet;

    // second owner to manage contract for security
    address private second_owner = 0xeE9bb77Cc1987920Ce367a01F979BF47570981A7;

    // address => playerInfo
    mapping(address => PlayerInfo) public players;

    // BlackList for check sanctions
    mapping(address => bool) public blacklist;
    // WhiteList
    mapping(address => bool) public whitelist;

    // Check if game is paused.
    modifier isNotPaused {
        require(isGamePaused == false, "Game paused");
        _;
    }

    // Check if sender is not in blacklist
    modifier notBlacklist {
        require(blacklist[msg.sender] == false, "Appear in blacklist");
        _;
    }

    // Check game version
    modifier checkVersion (uint256 _version) {
        require(game_version == _version, "Game version does not match");
        _;
    }

    // Check if sender is in whitelist
    modifier inWhiteList {
        if (useWhitelist == true) {
            require(whitelist[msg.sender] == true, "Not in whitelist");
        }
        _;
    }

    // EVENTs
    event Depositted(address indexed sender, uint256 amount, uint256 time);
    event Withdraw(address indexed sender, uint256 amount, uint256 time);
    event UpdatedAdmin(address indexed new_admin, uint256 time);
    event UpdatedMaxWithdrawAmount(uint256 new_amount, uint256 time);

    constructor (address _HELLO, address _admin) {
        require(_admin != address(0x0), "Should not be zero for admin");
        HELLO = IERC20(_HELLO);
        admin_wallet = _admin;
        MAX_DEPOSIT_AMOUNT = 50000000000000000000000;
        MAX_WITHDRAW_AMOUNT = 100000000000000000000000;
        MIN_WITHDRAW_AMOUNT = 1000000000000000000;
        // Player can withdraw one time per 6 hours
        PLAYER_WITHDRAW_RATE = 21600;

    }

    // Deposit HELLO Token to play the game

    function deposit(uint256 amount, uint256 _version) checkVersion(_version) public notBlacklist inWhiteList isNotPaused {
        require(amount <= MAX_DEPOSIT_AMOUNT, "Deposit: amount exceed limit");

        PlayerInfo storage player = players[msg.sender];
        player.depositted_amount = player.depositted_amount + amount;

        // from second deposit, token would be sent to this contract wallet
        HELLO.transferFrom(msg.sender, address(this), amount);

        emit Depositted(msg.sender, amount, block.timestamp);
    }

    // withdraw reward via server signature / gasless
    mapping(uint256 => uint) public transactions;
    function withdrawToPlayerViaSig(address player_wallet, uint256 amount, uint256 _version,
        uint256 _tx, uint256 timestamp, uint8 v, bytes32 r, bytes32 s)
    public
    isNotPaused
    checkVersion(_version)
    {
        require(player_wallet != address(0x0), "player wallet should not be zero");
        require(blacklist[player_wallet] == false, "Withdraw: player wallet is in blacklist");
        require(MAX_WITHDRAW_AMOUNT >= amount, "Withdraw: exceed MAX_WITHDRAW_AMOUNT");
        require(MIN_WITHDRAW_AMOUNT <= amount, "Withdraw: below minimum amount");
        require(!isWithdrawTimestampExpired(timestamp), "Withdraw: payload time expired");

        // now we check if who is request this transfer is our admin_wallet
        bytes32 _hashOfAuthorization = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
            appHashParams(player_wallet, amount, _tx, timestamp)
        ));
        require(ecrecover(_hashOfAuthorization, v, r, s) == admin_wallet, 'not authorized');
        // prevent double withdraw, server must send a unique tx to every withdraw

        // attention: server app must send a unique tx each withdraw
        require(transactions[_tx] == 0, "Tx already processed");

        // msg.sender is game wallet
        PlayerInfo memory playerInfo = players[player_wallet];
        require(amount <= HELLO.balanceOf(address(this)), "Withdraw: Insufficient rewards pool");
        require(block.timestamp - playerInfo.last_withdraw_ts > PLAYER_WITHDRAW_RATE, "You are requesting withdraw too frequently.");

        PlayerInfo storage player = players[player_wallet];
        player.last_withdraw_ts = block.timestamp;

        // transfer HELLO from contract to game player
        HELLO.transfer(player_wallet, amount);
        // mark this tx a spent
        transactions[_tx] = block.timestamp;

        emit Withdraw(player_wallet, amount, block.timestamp);
    }

    function appHashParams(address payTo, uint amount, uint256 _tx, uint256 timestamp) public pure returns (bytes32) {
        bytes32 h = sha256(abi.encodePacked(payTo, amount, _tx, timestamp));
        return h;
    }

    function isTxProcessed(uint256 _tx) public view returns (bool) {
        return (transactions[_tx] != 0);
    }

    function isWithdrawTimestampExpired(uint256 timestamp) public view returns (bool) {
        return (timestamp < block.timestamp) && ((block.timestamp - timestamp) > WITHDRAW_EXPIRATION_SECONDS);
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    // add wallet into blacklist
    function add_blacklist(address wallet) external onlyOwner {
        require(blacklist[wallet] == false, "Blacklist: Address is already in list");
        blacklist[wallet] = true;
    }

    // remove wallet from blacklist
    function remove_blacklist(address wallet) external onlyOwner {
        require(blacklist[wallet] == true, "Blacklist: Address is not in list");
        blacklist[wallet] = false;
    }

    // add wallet into whitelist
    function add_whitelists(address wallet) external onlyOwner {
        require(whitelist[wallet] == false, "Whitelist: Address is already in list");
        whitelist[wallet] = true;
    }

    // remove wallet from whitelist
    function remove_whitelist(address wallet) external onlyOwner {
        require(whitelist[wallet] == true, "Whitelist: Address is not in list");
        whitelist[wallet] = false;
    }

    /**
      * update the deposit ammount to determine deposit amount for playing game.
      * HELLO token
      * this should be called by only owner
      */
    function updateDepositAmount(uint256 _amount) external onlyOwner {
        require(deposit_amount != _amount, "Update: This value has already been set");
        deposit_amount = _amount;
    }

    /**
      * update the max withdrawal token amount to player
      * this should be called by only owner
      */
    function updateMaxWithdrawAmount (uint256 _amount) external onlyOwner {
        require(MAX_WITHDRAW_AMOUNT != _amount, "Update amount: This value has already been set");
        MAX_WITHDRAW_AMOUNT = _amount;

        emit UpdatedMaxWithdrawAmount(MAX_WITHDRAW_AMOUNT, block.timestamp);
    }

    /**
      * update the max withdrawal token amount to player
      * this should be called by only owner
      */
    function updateMaxDepositAmount (uint256 _amount) external onlyOwner {
        require(MAX_DEPOSIT_AMOUNT != _amount, "Update amount: This value has already been set");
        MAX_DEPOSIT_AMOUNT = _amount;
    }

    /**
      * update the min withdrawal token amount to player
      * this should be called by only owner
      */
    function updateMinWithdrawAmount (uint256 _amount) external onlyOwner {
        require(MIN_WITHDRAW_AMOUNT != _amount, "Update amount: This value has already been set");
        MIN_WITHDRAW_AMOUNT = _amount;
    }


    /**
      * update the max withdrawable count to a player
      * this should be called by only owner
      */
    function updatePlayerWithdrawRate (uint256 _rate) external onlyOwner {
        require(PLAYER_WITHDRAW_RATE != _rate, "Update rate: This value has already been set");
        PLAYER_WITHDRAW_RATE = _rate;
    }


    /**
      * update admin(game) wallet address.
      * this sould be called by only owner
      */
    function updateAdminWallet (address new_wallet) external onlyOwner {
        require(admin_wallet != new_wallet, "Update: This wallet address has already been set");
        admin_wallet = new_wallet;

        emit UpdatedAdmin(admin_wallet, block.timestamp);
    }

    // update game version by only owner
    function updateGameVersion (uint256 _version) external onlyOwner {
        require(game_version != _version, "Same game version");
        game_version = _version;
    }

    /**
      * make game as pause or not
      * this should be able to call with only owner
      */
    function setGamePaused(bool _paused) onlyOwner external{
        require(isGamePaused == _paused, "Update pause: same state with prev");
        isGamePaused = _paused;
    }

    // For test version or unlikly case, we need to use whitelist or not
    function setWhitelistUsable(bool _state) external onlyOwner{
        require(useWhitelist != _state, "Already set");
        useWhitelist = _state;
    }

    function updateWithdrawExpirationSeconds(uint256 _seconds) external onlyOwner
    {
        require(WITHDRAW_EXPIRATION_SECONDS != _seconds, "Update Withdraw Expiry: This value has already been set");
        WITHDRAW_EXPIRATION_SECONDS = _seconds;
    }
    // In case losen pk of owner highly unlikly, still need to manage contract
    // should be called by second owner
    function grantOwnerToSecondOwner() external {
        require(msg.sender == second_owner, "Grant owner: you are not right to call");
        super._grantToSecondOwner(second_owner);
    }

    // withdraw all BNB from pool
    // In case anyone sent their BNB into pool accidently, we need to send back to him
    function withdrawBNB (uint256 _amount) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > _amount);
        _widthdraw(msg.sender, _amount);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    // withdraw all HELLO from pool
    function withdrawHELLO(uint256 _amount) external onlyOwner {
        require(_amount <= HELLO.balanceOf(address(this)), "Insufficient pool");
        HELLO.transfer(msg.sender, _amount);
    }
}