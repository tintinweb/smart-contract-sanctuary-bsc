/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Betgame is Ownable {
    //set all teams, ticket cost & fees before initiating
    bool isInitiated=false;
    //disable user interaction
    bool isPaused=false;
    //set after winner is set
    bool gameEnded=false;
    //set after fees are withdrawn
    bool feesWithdrawn=false;
    //Token used for purchase
    IERC20 purchaseToken;
    //Price for 1 ticket
    uint256 ticketPrice=10;
    //Percentage of ticket going to protocol
    uint256 protocolFeesPercent=0;
    //Accumulated total
    uint256 totalPool=0;
    //Maximum number of purchaseable tickets
    uint256 maxTickets=10;
    //Id of the winning team
    uint256 winnerId=10000;
    //Storage for user selection
    mapping(address => UserSelection) userData;
    //Storage for team tickets
    mapping(uint256 => uint256) teamTickets;
    //Storage for team list
    string[] teamList;
    //Struct used to store user selection
    struct UserSelection {
        uint256 teamId;
        uint256 numTickets;
        bool withdrawn;
    }
    /*
    constructor(address _purchaseToken){
        purchaseToken = IERC20(address(_purchaseToken));
    }*/

    //Add new team
    function addTeam(string memory _teamName) external onlyOwner{
        require(isInitiated == false, "Already Initiated!");
        bool foundTeam=false;
        for (uint256 i = 0; i < teamList.length; i++) {
            if (keccak256(abi.encodePacked((teamList[i]))) == keccak256(abi.encodePacked((_teamName)))) {
                foundTeam=true;
            break;
            }
        }
        require(foundTeam == false, "Already Added!");
        teamList.push(_teamName);
        //console.log(teamList.length);
    }

    //set the purchase token
    function setPurchaseToken(address _purchaseToken) external onlyOwner {
        require(isInitiated == false, "Already Initiated!");
        purchaseToken = IERC20(address(_purchaseToken));
        //purchaseToken.approve(address(this),115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    //set the ticket price in wei
    function setTicketPrice(uint256 _ticketPrice) external onlyOwner {
        require(isInitiated == false, "Already Initiated!");
        require(_ticketPrice>0,"Ticket price needs to be greater than 0!");
        ticketPrice = _ticketPrice;
    }
    //set the fees percentage of the ticket price, 10 means 10%
    function setFees(uint256 _protocolFees) external onlyOwner {
        require(isInitiated == false, "Already Initiated!");
        require(_protocolFees < 20, "Cannot set fees more than 20%!");
        protocolFeesPercent = _protocolFees;
    }
    //Call once teams, ticket price & fees are set
    function initialise() external onlyOwner {
        require(isInitiated == false, "Already Initiated!");
        require(teamList.length>1,"Need to add atleast two teams!");
        isInitiated=true;
    }
    //Call once the real game starts to disable new buyers
    function sleep() external onlyOwner {
        require(isInitiated == true, "Need to initiate!");
        require(isPaused == false, "Already paused!");
        require(gameEnded == false, "Game ended already!");
        isPaused=true;
    }
    //set winner
    function setWinner(uint256 _winnerId) external onlyOwner {
        require(isInitiated == true, "Need to initiate!");
        require(isPaused == true, "Need to be paused!");
        require(gameEnded == false, "Game ended already!");
        require(_winnerId<teamList.length,"Team ID out of bounds!");
        gameEnded=true;
        isPaused=false;
        winnerId=_winnerId;
    }
    //Get balance of purchase token in the contract
    function getBalance() public view returns (uint256) {
        //return address(this).balance;
        return purchaseToken.balanceOf(address(this));
    }
    //withdraw protocol fees to address
    function withdrawFees(address _walletAddress) external onlyOwner{
        require(gameEnded == true, "Game needs to end!");
        require(feesWithdrawn == false, "Withdrawn already!");
        require(_walletAddress != address(0), "Cannot withdraw to zero address!");
        uint256 totalProtocolFee=totalPool*protocolFeesPercent/100;
        require(totalProtocolFee >0, "Nothing to withdraw!");
        //console.log("Withdrawing ",totalProtocolFee);
        /*//pay with ether
        (bool success, ) = payable(_walletAddress).call{value: totalProtocolFee}("");
        require(success, "Failed to Withdraw");
        */
        //payable(_walletAddress).transfer(totalProtocolFee);
        bool success =purchaseToken.transfer(_walletAddress, totalProtocolFee);
        require(success, "Failed to Withdraw");
        feesWithdrawn=true;
    }
    //Buy tickets
    function buyTickets(uint256 _teamId,uint256 _numTickets) external {//payable{//for paying in eth
        require(isInitiated == true, "Need to initiate!");
        require(isPaused == false, "Game is paused!");
        require(gameEnded == false, "Game ended already!");
        require(_numTickets >0, "Need atleast 1 ticket!");
        require(_numTickets <=maxTickets, "Cannot purchase so many tickets!");
        require(_teamId <teamList.length, "Team id is out of bounds!");
        address userAddress=msg.sender;
        require(userData[userAddress].numTickets==0,"Wallet already registered!");
        /*//for paying eth
        console.log("Receiving ",msg.value,ticketPrice*_numTickets);
        require(msg.value>=ticketPrice*_numTickets ,"Not enough money");
        */
        bool success=purchaseToken.transferFrom(msg.sender,address(this), ticketPrice*_numTickets);
        require(success, "Failed to Purchase");
        totalPool+=ticketPrice*_numTickets;
        UserSelection memory userSelection=UserSelection({teamId:_teamId,numTickets:_numTickets,withdrawn:false});
        userData[userAddress]=userSelection;
        teamTickets[_teamId]=teamTickets[_teamId]+_numTickets;
        //payable(address(this)).transfer(ticketPrice*_numTickets);
        //purchaseToken.transfer(payable(address(this)), ticketPrice*_numTickets);
    }
    //Collect user winning
    function collectWinnings() external{
        require(gameEnded == true, "Game needs to end!");
        require(userData[msg.sender].numTickets>0,"Wallet not registered!");
        require(userData[msg.sender].teamId==winnerId,"Your team didnt win!");
        require(userData[msg.sender].withdrawn==false,"Already withdrawn");
        userData[msg.sender].withdrawn=true;
        //console.log("Collecting ",getWinningsForWallet());
        //payable(msg.sender).transfer(getWinningsForWallet());
        //purchaseToken.transfer(payable(msg.sender), getWinningsForWallet());
        /*//for paying in eth
        (bool success, ) = payable(msg.sender).call{value: getWinningsForWallet()}("");
        require(success, "Failed to Collect!");
        */
        //bool success=purchaseToken.transferFrom(address(this),msg.sender, getWinningsForWallet());
        bool success =purchaseToken.transfer(msg.sender, getWinningsForWallet(msg.sender));
        require(success, "Failed to Collect!");
    }

    //Get the protocol fees
    function getFees() public view returns (uint256) {
        return protocolFeesPercent;
    }
    //Get the ticket cost
    function getTicketPrice() public view returns (uint256) {
        return ticketPrice;
    }
    //Get the total pool
    function getTotalPool() public view returns (uint256) {
        return totalPool;
    }
    //Get the max number of tickets purchasable
    function getMaxTickets() public view returns (uint256) {
        return maxTickets;
    }
    //Get purchase token address
    function getPurchaseToken() public view returns (address) {
        return address(purchaseToken);
    }
    //Get winning team id
    function getWinnerId() public view returns (uint256) {
        return winnerId;
    }
    //Get all teams
    function getAllTeams() public view returns (string memory) {
        string memory teamStr="";
        for (uint256 i = 0; i < teamList.length; i++) {
            //teamStr=string.concat(teamStr,teamList[i]);
            if(i!=teamList.length-1){
                teamStr=string(abi.encodePacked(teamStr,teamList[i],","));
            }else{
                teamStr=string(abi.encodePacked(teamStr,teamList[i]));
            }
        }
        return teamStr;
    }
    //Get all tickets for a specific team
    function getAllTicketsForTeam(uint256 _teamId) public view returns (uint256) {
        require(_teamId<teamList.length,"Team ID out of bounds!");
        return teamTickets[_teamId];
    }
    //Get number of tickets for user wallet
    function getTicketsForWallet(address _walletAddress) public view returns (uint256) {
        require(userData[_walletAddress].numTickets>0,"Wallet not registered!");
        return userData[_walletAddress].numTickets;
    }
    //Get selected team for user wallet
    function getTeamForWallet(address _walletAddress) public view returns (string memory) {
        require(userData[_walletAddress].numTickets>0,"Wallet not registered!");
        return teamList[userData[_walletAddress].teamId];
    }
    //Get selected team's id for user wallet
    function getTeamIdForWallet(address _walletAddress) public view returns (uint256) {
        require(userData[_walletAddress].numTickets>0,"Wallet not registered!");
        return userData[_walletAddress].teamId;
    }
    //Get winnings for user wallet
    function getWinningsForWallet(address _walletAddress) public view returns (uint256){
        require(gameEnded == true, "Game needs to end!");
        require(userData[_walletAddress].numTickets>0,"Wallet not registered!");
        require(userData[_walletAddress].teamId==winnerId,"Your team didnt win!");
        uint256 shareablePool=totalPool-(totalPool*protocolFeesPercent/100);
        uint256 totalWinners=getAllTicketsForTeam(winnerId);
        uint256 ticketShare=shareablePool/totalWinners;
        return ticketShare*userData[_walletAddress].numTickets;
    }
    //check if game has ended
    function hasGameEnded() public view returns (bool){
        return gameEnded;
    }
    //check if wallet has a bet
    function hasBet(address _walletAddress) public view returns (bool){
        return userData[_walletAddress].numTickets>0;
    }
    //check if game in sleep mode
    function isSleeping() public view returns (bool){
        return isPaused;
    }
    //check if wallet has withdrawn
    function hasWalletWithdrawn(address _walletAddress) public view returns (bool){
        return userData[_walletAddress].withdrawn;
    }
    //check if wallet has withdrawn
    function isFeesWithdrawn() public view returns (bool){
        return feesWithdrawn;
    }
}