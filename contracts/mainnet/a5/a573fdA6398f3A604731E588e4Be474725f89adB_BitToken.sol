pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "./Stakeable.sol";
import "./Comissionable.sol";
import "./Ownable.sol";
import "./Vestingable.sol";

contract BitToken is Comissionable(address(this)), Stakeable, Ownable, Vestingable {


    /**
    * @notice Our Tokens required variables that are needed to operate everything
  */
    uint256 private _totalSupply;
    uint256 private _decimals;
    string private _symbol;
    string private _name;

    /**
    * @notice _balances is a mapping that contains a address as KEY
  * and the balance of the address as the value
  */

    mapping(address => uint256) private _balances;


    /**
    * @notice _allowances is used to manage and control allownace
  * An allowance is the right to use another accounts balance, or part of it
   */
    mapping(address => mapping(address => uint256)) private _allowances;

    struct Halving {
        uint since;
        uint taxPercentage;
        uint toBurnPercentage;
    }

    Halving[] private halvings;

    /**
    * @notice Events are created below.
  * Transfer event is a event that notify the blockchain that a transfer of assets has taken place
  *
  */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @notice Approval is emitted when a new Spender is approved to spend Tokens on
   * the Owners account
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
    * @notice constructor will be triggered when we create the Smart contract
  * _name = name of the token
  * _short_symbol = Short Symbol name for the token
  * token_decimals = The decimal precision of the Token, defaults 18
  * _totalSupply is how much Tokens there are totally
  */
    constructor(string memory token_name, string memory short_symbol, uint256 token_decimals, uint256 token_totalSupply){
        _name = token_name;
        _symbol = short_symbol;
        _decimals = token_decimals;
        _totalSupply = token_totalSupply;

        // Add all the tokens created to the creator of the token
        _balances[msg.sender] = _totalSupply;

        // Emit an Transfer event to notify the blockchain that an Transfer has occured
        emit Transfer(address(0), msg.sender, _totalSupply);


        halvings.push(Halving(90 days, 30, 80));
        halvings.push(Halving(180 days, 20, 82));
        halvings.push(Halving(270 days, 10, 84));
        halvings.push(Halving(360 days, 0, 86));
    }
    /**
    * @notice decimals will return the number of decimal precision the Token is deployed with
  */
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    /**
    * @notice symbol will return the Token's symbol
  */
    function symbol() external view returns (string memory){
        return _symbol;
    }
    /**
    * @notice name will return the Token's symbol
  */
    function name() external view returns (string memory){
        return _name;
    }
    /**
    * @notice totalSupply will return the tokens total supply of tokens
  */
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }
    /**
    * @notice balanceOf will return the account balance for the given account
  */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] - sumVesting(account) ;
    }

    /**
    * @notice _burn will destroy tokens from an address inputted and then decrease total supply
  * An Transfer event will emit with receiever set to zero address
  *
  * Requires
  * - Account cannot be zero
  * - Account balance has to be bigger or equal to amount
  */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BitToken: cannot burn from zero address");
        require(_balances[account] >= amount, "BitToken: Cannot burn more than the account owns");

        // Remove the amount from the account balance
        _balances[account] = _balances[account] - amount;
        // Decrease totalSupply
        _totalSupply = _totalSupply - amount;
        // Emit event, use zero address as reciever
        emit Transfer(account, address(0), amount);
    }
    /**
    * @notice burn is used to destroy tokens on an address
  *
  * See {_burn}
  * Requires
  *   - msg.sender must be the token owner
  *
   */
    function burn(address account, uint256 amount) public onlyOwner returns (bool) {
        _burn(account, amount);
        return true;
    }


    /**
    * @notice transfer is used to transfer funds from the sender to the recipient
  * This function is only callable from outside the contract. For internal usage see
  * _transfer
  *
  * Requires
  * - Caller cannot be zero
  * - Caller must have a balance = or bigger than amount
  *
   */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
    * @notice transfer is used to transfer funds from the sender to the recipient
  * This function is only callable from outside the contract. For internal usage see
  * _transfer
  *
  * Requires
  * - Caller cannot be zero
  * - Caller must have a balance = or bigger than amount
  *
   */
    function transferVesting(address recipient, uint256 amount, uint256 cliffDays) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        _vest(recipient, amount, _activeSince + (cliffDays * 1 days));
        return true;
    }
    /**
    * @notice _transfer is used for internal transfers
  *
  * Events
  * - Transfer
  *
  * Requires
  *  - Sender cannot be zero
  *  - recipient cannot be zero
  *  - sender balance most be = or bigger than amount
   */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BitToken: transfer from zero address");
        require(recipient != address(0), "BitToken: transfer to zero address");
        require(balanceOf(sender) >= amount, "BitToken: cant transfer more than your account holds");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }
    /**
    * @notice getOwner just calls Ownables owner function.
  * returns owner of the token
  *
   */
    function getOwner() external view returns (address) {
        return owner();
    }
    /**
    * @notice allowance is used view how much allowance an spender has
   */
    function allowance(address owner, address spender) external view returns (uint256){
        return _allowances[owner][spender];
    }
    /**
    * @notice approve will use the senders address and allow the spender to use X amount of tokens on his behalf
  */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
    * @notice _approve is used to add a new Spender to a Owners account
   *
   * Events
   *   - {Approval}
   *
   * Requires
   *   - owner and spender cannot be zero address
    */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BitToken: approve cannot be done from zero address");
        require(spender != address(0), "BitToken: approve cannot be to zero address");
        // Set the allowance of the spender address at the Owner mapping over accounts to the amount
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    /**
    * @notice transferFrom is uesd to transfer Tokens from a Accounts allowance
    * Spender address should be the token holder
    *
    * Requires
    *   - The caller must have a allowance = or bigger than the amount spending
     */
    function transferFrom(address spender, address recipient, uint256 amount) external returns (bool){
        // Make sure spender is allowed the amount
        require(_allowances[spender][msg.sender] >= amount, "BitToken: You cannot spend that much on this account");
        // Transfer first
        _transfer(spender, recipient, amount);
        // Reduce current allowance so a user cannot respend
        _approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
        return true;
    }
    /**
    * @notice increaseAllowance
    * Adds allowance to a account from the function caller address
    */
    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + amount);
        return true;
    }
    /**
    * @notice decreaseAllowance
  * Decrease the allowance on the account inputted from the caller address
   */
    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - amount);
        return true;
    }


    /**
    * Add functionality like burn to the _stake afunction
    *
     */
    function stake(uint256 _amount) public {
        // Make sure staker actually is good for it
        require(_amount <= balanceOf(msg.sender), "BitToken: Cannot stake more than you own");
        require(_amount >= 1000000000000000000000, "BitToken: Minimal stake amount is 1000");
        require(members[msg.sender].tree.exists == true, "BitToken: Users have to join affiliate system first.");
        _transfer(msg.sender, stakeholdersWallet.selfAddress(), _amount);
        _stake(_amount);
        if (members[msg.sender].tree.exists) {
            processPurchase(msg.sender, _amount);
        } else {
            Details memory details;
            _joinReferralSystem(msg.sender, msg.sender, details);
        }
    }

    function joinReferralSystem(address sponsorId, Details  memory details) public {
        if (members[msg.sender].tree.sponsor == msg.sender) {
            _setSponsor(msg.sender, sponsorId, details);
        } else {
            _joinReferralSystem(msg.sender, sponsorId, details);
        }
    }


    /**
    * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function cancelStake(uint256 stake_index) public {

        Stake memory amount_to_mint = _withdrawStake(stake_index);
        // Return staked tokens to user

        stakingWallet.sendFundsTo(address(this), amount_to_mint.claimable, msg.sender);

        bool hasNext = true;
        uint index = 0;
        while(hasNext) {
            if( index + 1 < halvings.length && halvings[index+1].since + amount_to_mint.since < block.timestamp) {
                index++;
            } else {
                hasNext = false;
            }
        }
        uint amountToTax = amount_to_mint.amount * halvings[index].taxPercentage/ 100;
        uint amountToWithdraw = amount_to_mint.amount  - amountToTax;
        _burn(stakeholdersWallet.selfAddress(), amountToTax * halvings[index].toBurnPercentage / 100);
        stakeholdersWallet.sendFundsTo(address(this), amountToTax * (100 - halvings[index].toBurnPercentage) / 100, stakingWallet.selfAddress());

        stakeholdersWallet.sendFundsTo(address(this), amountToWithdraw, msg.sender);



    }


    /**
    * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function claimStakeProfits(uint256 amount, uint256 stake_index) public {
        uint toClaim = _claimStake(amount, stake_index);
        stakingWallet.sendFundsTo(address(this), toClaim, msg.sender);

    }


    function sendFundsTo(address tracker, uint256 amount, address receiver) public onlyOwner returns (bool) {
        // Transfer tokens from this address to the receiver
        return IERC20(tracker).transfer(receiver, amount);
    }

    function sendStakingFundsTo(address tracker, uint256 amount, address receiver) public onlyOwner returns (bool) {
        // Transfer tokens from this address to the receiver
        return stakingWallet.sendFundsTo(tracker, amount, receiver);
    }

    function sendStakeholderFunsTo(address tracker, uint256 amount, address receiver) public onlyOwner returns (bool) {
        // Transfer tokens from this address to the receiver
        return stakeholdersWallet.sendFundsTo(tracker, amount, receiver);

    }

    function setProfile(Details memory details) public onlyOwner returns (bool) {
        // Transfer tokens from this address to the receiver
        return _setProfile(msg.sender, details);

    }


    function selfBalanceOf(address tracker) public onlyOwner returns (uint) {


        // Transfer tokens from this address to the receiver
        return IERC20(tracker).balanceOf(owner());
    }

    function selfAddress() public view returns (address) {
        return address(this);
    }

}