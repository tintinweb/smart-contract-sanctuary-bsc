/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT

/*
                                                 ____
                                               /      \
                                         ___  |        |  ___
                                        /   |  \ ____ /  |   \
                                       /     \ ________ /     \
                                      /       __________       \
                                     /      /            \      \
                                    /     /                \     \
                                   /     |      ______      |     \
                                   \    |     /        \     |    /
                                    \   |    |          |    |   /
                                     \   |   |          |   |   /
                                      \   \   \ ______ /   /   /
                                       \    \ __________ /    /
                                        \____________________/


  _______________________________________________________________________________________________
//                                                                                               \\ 
||  ###    ##   ###   ###   #  #   #    #  #   ##   ###   #      #####   ###   #  #  ####  #   #  ||
||  #  #  #  #  #  #  #  #  #   # #     #  #  #  #  #  #  #        #    #   #  # #   #     ##  #  ||
||  ###   ####  #  #  #  #  #    #      ####  #  #  #  #  #        #    #   #  ##    ###   # # #  ||
||  #  #  #  #  #  #  #  #  #   # #     #  #  #  #  #  #  #        #    #   #  # #   #     #  ##  ||
||  #  #  #  #  ###   ###   #  #   #    #  #   ##   ###   ####     #     ###   #  #  ####  #   #  ||
 \\______________________________________________________________________________________________//

This code has Copyright ©




Description of the contract:

The Raddix Hodl token is an ERC20 token with the special feature that it always has an intrinsic value. 
For each individual token, the intrinsic value must be deposited, then a token is minted. 
In this case, it is BUSD that each token is backed with. 
Another special feature is that the value of a token cannot decrease, but it can increase. 
If you bought the token for 0.01 BUSD, you can be sure that this value will always be deposited for this token. 
Because 1% of the amount of token is burned with every transaction, 
the value of a single token will always increase. 
If the number of tokens sent is higher than 100000 RHT, the fee is 0.1%. 
For everything above 1000000 RHT tokens, 0.05% is burned.
The contract is written so that nothing can remove the value of your token except your token itself.
When you mint tokens, you are credited with 95.5% of the value of the tokens, 
the other 4.5% of the value is credited to the owner of the contract, 
to create LP tokens that can be traded on exchanges. Since the token has a direct value attached to it, 
this minting fee is necessary to start the whole system, as only active trading brings an increase in value.
In addition, a mechanism is launched that creates the deposited value of Imaginary Tokens, 
and burns them within 9 weeks. After these 9 weeks, you can redeem your token in the Contract for the full amount.
As long as the totalSupply is below 5000000 tokens (which corresponds to 500000 BUSD at the beginning), 
there is still no "imaginary burn" everything minted above that has the 9 weeks runtime until the full value. 
If it is paid out before then, the remaining value goes into the pool and to the owner of the contract.
The burn mechanism is the reason why the token is a Hodl token. 
The value of a token is calculated based on the total amount of tokens and the BNB deposited in the contract. 
This is then also always the purchase value, so logically the purchase value of a token also increases.
This ensures that the value of a token is maintained and can therefore only increase, 
which happens when someone trades in their tokens before the imagine burn expires, 
through normal trading because the 1% burned, or when someone burns their tokens themselves.
In summary, the risk of loss is minimal (unless BUSD crashes), 
if you wait you will lose a maximum of 4.5% (if you minted. You can also buy also on Exchanges), 
should you be the only one invested in this token. On the other hand, 
if you buy the token below its intrinsic value on the exchange, or sell it above its intrinsic value, 
you can be sure of making a profit.
So if you plan to just leave your BUSD on your wallet anyway, you can invest in this token as well. 
I have made this contract as open and transparent as I could and wish us all success with the system I have devised. 


How to mint RHT:

1. Go to "Read Contract" and copy the RHT Contract, next click on Contract BUSD.

2. In the BUSD Contract go to Contract -> Write Contract -> approve -> paste the RHT Contract in _spender,
   now insert your amount you want to mint in BUSD. For example:  25 BUSD = 25000000000000000000.
   Click on Connect to Web3 (Red Dot) choose your Wallet and enter. -> Click on "Write" by "approve".

3. Now go back to the RHT Contract and go to Write. Connect to Web3 as same as before.
   Insert the same amount of BUSD in BuyRHT and click on "Write". Done



tokenBurns              	        - Array with the tokens in the Burning mechanism. timeLeft is seconds.
                                      enter 0 to see which is the oldest burn order and when it expires. 

buyRHT                              - buy RHT for your value RHT, you do not need a BurnTokenTrigger beforehand, 
                                       the token value is always calculated live. please put a dot, 
                                       otherwise the transaction will fail. e.g. 0.01 (BNB).

showRHTvalueForBuy                  - Value for a token if you want to buy some.

showRHTvalueForSell                 - Value for a token if you want to sell some.

TriggerForShowAllUpdated            - costs the transaction fee once, but should ensure that all data is updated.

Burn                                - You can burn your own token if you like.

sellRHT                             - Burn your amount of tokens, the contract sends them the corresponding value: 
                                      = (showRHTvalueForSell) * TokenAmount. Only whole Number(s) for selling.

sellRHTforOwnerOfRHTcontract        - is the same as described above, except that I sell directly, 
                                      without waiting (simplifies administration).

showAllRHTinBurningMechanism        - Shows the total amount of tokens that are currently being burned.

showRHTvalueForSellwithoutTrigger   - Show you the Sell Price. As this worked rather unreliably, 
                                      I added the trigger function.

showRHTvalueForBuywithoutTrigger    - Show you the Buy Price. As this worked rather unreliably, 
                                      I added the trigger function.
                                    
totalSupplyWholeNumber              - Shows the number of tokens as a whole number. 
                                      (otherwise you have to subtract 18 digits. this is just for clarity).

tokenBurnsLenght                    - How many TokenBurn processes are running? 
                                      So that you know how long the array is.

AmountYouGetForOneBUSDwhenMinting   - Amount you get for one BUSD when minting. So that you can calculate better.


If you have any questions, need help or are looking for like-minded people, please feel free to drop by on discord.
https://discord.gg/euGkmvuabz


*/







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

    /** 
     * Transfers _value amount of token to address _to and MUST emit the Transfer event. 
     * The balance of msg.sender will be deducted by _value + _fee. Add _value amount to the balance of the receiver.
     * If zero fees should be applied due to whitelisting, assume the above _fee to be zero.
     */
    function transferExactDest(address _to, uint _value) external returns (bool success);

    /**
     * Transfers _value amount of token to address _to and MUST fire the Transfer event. The balance of _from will be deducted by _value + _fee. 
     * If zero fees should be applied due to whitelisting, assume the above _fee value to be zero.
     */
    function transferExactDestFrom(address _from, address _to, uint _value) external returns (bool success);

    /**
     * A query function that returns the amount of tokens a receiver will get if a sender sends _sentAmount tokens.
     */
    function getReceivedAmount(uint _sentAmount) external view returns (uint receivedAmount, uint feeAmount);

    /**
     * Returns the amount of tokens the sender has to send if he wants the receiver to receive exactly _receivedAmount tokens.
     */
    function getSendAmount(uint _receivedAmount) external view returns (uint sendAmount, uint feeAmount);

    /**
     * Returns the amount of tokens that are in the account as a balance, minus the fee if you want to send the total amount.
     */
    function balanceOfWithoutFee(address account) external view returns (uint256);
}



// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

// Was edited manually by me, is no longer a standard.

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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

     function _symbolcheck() internal view returns (string memory) {
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
        if(amount < 500000 * 1000000000000000000) {
            uint fee = amount/100; // for 1% fee
        address owner = _msgSender();
        _transfer(owner, to, amount-fee);
        _burn(owner, fee);
        } else if(amount < 10000000 * 1000000000000000000) {
            uint fee = amount/1000; // for 0,1% fee
        address owner = _msgSender();
        _transfer(owner, to, amount-fee);
        _burn(owner, fee);
        } else {
            uint fee = amount/2000; // for 0,05% fee
        address owner = _msgSender();
        _transfer(owner, to, amount-fee);
        _burn(owner, fee);
        }
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
        if(amount < 100000 * 1000000000000000000) {
            uint fee = amount/100; // for 1% fee
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount-fee);
        _burn(from, fee);
        } else if(amount < 1000000 * 1000000000000000000) {
            uint fee = amount/1000; // for 0,1% fee
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount-fee);
        _burn(from, fee);
        } else {
            uint fee = amount/2000; // for 0,05% fee
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount-fee);
        _burn(from, fee);
        }
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
    

    // Transfers _value amount of token to address _to and MUST emit the Transfer event. 
    // The balance of msg.sender will be deducted by _value + _fee. Add _value amount to the balance of the receiver.
    // If zero fees should be applied due to whitelisting, assume the above _fee to be zero.
    function transferExactDest(address _to, uint _value) public virtual override returns (bool success) {
        if(_value < 500000 * 1000000000000000000) {
            uint fee = _value/100; // for 1% fee
        address owner = _msgSender();
        _transfer(owner, _to, _value);
        _burn(owner, fee);
        } else if(_value < 10000000 * 1000000000000000000) {
            uint fee = _value/1000; // for 0,1% fee
        address owner = _msgSender();
        _transfer(owner, _to, _value);
        _burn(owner, fee);
        } else {
            uint fee = _value/2000; // for 0,05% fee
        address owner = _msgSender();
        _transfer(owner, _to, _value);
        _burn(owner, fee);
        }
        return true;
    }

    // Transfers _value amount of token to address _to and MUST fire the Transfer event. The balance of _from will be deducted by _value + _fee. 
    // If zero fees should be applied due to whitelisting, assume the above _fee value to be zero.
    function transferExactDestFrom(address _from, address _to, uint _value) public virtual override returns (bool success) {
        address spender = _msgSender();
        if(_value < 100000 * 1000000000000000000) {
            uint fee = _value/100; // for 1% fee
        _spendAllowance(_from, spender, _value);
        _transfer(_from, _to, _value);
        _burn(_from, fee);
        } else if(_value < 1000000 * 1000000000000000000) {
            uint fee = _value/1000; // for 0,1% fee
        _spendAllowance(_from, spender, _value);
        _transfer(_from, _to, _value);
        _burn(_from, fee);
        } else {
            uint fee = _value/2000; // for 0,05% fee
        _spendAllowance(_from, spender, _value);
        _transfer(_from, _to, _value);
        _burn(_from, fee);
        }
        return true;
    }

    // A query function that returns the amount of tokens a receiver will get if a sender sends _sentAmount tokens. 
    function getReceivedAmount(uint _sentAmount) public virtual override view returns (uint receivedAmount, uint feeAmount) {
        uint i = _sentAmount;
        uint fee;
        if(i < 100000 * 1000000000000000000) {
            fee = i/100; // for 1% fee
        } else if(i < 1000000 * 1000000000000000000) {
            fee = i/1000; // for 0,1% fee
        } else {
            fee = i/2000; // for 0,05% fee
        }

        return (i-fee, fee);
    }

    // Returns the amount of tokens the sender has to send if he wants the receiver to receive exactly _receivedAmount tokens.
    function getSendAmount(uint _receivedAmount) public virtual override view returns (uint sendAmount, uint feeAmount) {
        uint i = _receivedAmount;
        uint fee;
        if(i < 100000 * 1000000000000000000) {
            fee = i/100; // for 1% fee
        } else if(i < 1000000 * 1000000000000000000) {
            fee = i/1000; // for 0,1% fee
        } else {
            fee = i/2000; // for 0,05% fee
        }

        return (i+fee, fee);
    }

    // Returns the amount of tokens that are in the account as a balance, minus the fee if you want to send the total amount.
    function balanceOfWithoutFee(address account) public view virtual override returns (uint256) {
        uint i = _balances[account];
        uint fee;
        if(i < 100000 * 1000000000000000000) {
            fee = i/100; // for 1% fee
        } else if(i < 1000000 * 1000000000000000000) {
            fee = i/1000; // for 0,1% fee
        } else {
            fee = i/2000; // for 0,05% fee
        }
        return i - fee;
    }

    

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
    ) internal virtual{
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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


// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: contracts/RaddixHodlToken.sol


pragma solidity ^0.8.13;


contract RaddixHodlToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("RaddixHodlToken", "RHT") {
        RHTvalue = 100000000000000000; // This is the start value.
        valueForSell = RHTvalue;
        valueForBuy = RHTvalue;
        RHT = ERC20(address(this));
        BUSDaddress = 0x8Dee6b6AFa2953F7b4a1C26aD0185956fF9388ef;
        BUSD = ERC20(address(BUSDaddress));
    }

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    uint RHTvalue;
    uint private balanceContract;
    uint burningTimeInSeconds = 5443200; // = 9 weeks
    uint multiplikator = 1000000000000000000;

    uint public valueForSell;
    uint public valueForBuy;

    IERC20 public RHT;
    address BUSDaddress;
    IERC20 public BUSD;

    struct TokenBurnData {
        uint timestamp;
        uint amount;
        uint timeLeft;
    }

    uint regulator;

    TokenBurnData[] public tokenBurns;

    function buyRHT(uint BUSDamount) external {
        setRegulator();
        _BurnTokenTrigger();
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= BUSDamount, "Check the token allowance");
        BUSD.transferFrom(msg.sender, address(this), BUSDamount);
        uint i = BUSDamount/_showRHTvalueForBuy();
        _mint(msg.sender, i*955*multiplikator/1000);
        _mint(owner(), i*45*multiplikator/1000);
        RHTvalue = _showRHTvalueForSell();
        tokenBurns.push(TokenBurnData(block.timestamp+burningTimeInSeconds, uint(i*regulator*multiplikator), burningTimeInSeconds));
        balanceContract = BUSD.balanceOf(address(this));
        _BurnTokenTrigger();
        emit Bought(i*955*multiplikator/1000);
    }

    function _safeTransfer(
        IERC20 token,
        address to,
        uint amount
    ) private {
        bool sent = token.transfer(to, amount);
        require(sent, "Token transfer failed");
    }

    function setRegulator() private {
        if(totalSupply() < 5000000*multiplikator) regulator = 0;
        else if(totalSupply() < 10000000*multiplikator) regulator = 1;
        else if(totalSupply() < 50000000*multiplikator) regulator = 5;
        else if(totalSupply() < 100000000*multiplikator) regulator = 10;
        else if(totalSupply() < 500000000*multiplikator) regulator = 50;
        else if(totalSupply() < 1000000000*multiplikator) regulator = 100;
        else if(totalSupply() < 5000000000*multiplikator) regulator = 500;
        else regulator = 1000;
    }

    function secondsRemaining(uint x) private view returns (uint) {
    if (x <= block.timestamp) {
        return 0;  // already there
    } else {
        return x - block.timestamp;
    }
    }

    function showRHTvalueForBuy() private {
        valueForBuy = _showRHTvalueForBuy();
    }

    function _showRHTvalueForBuy() private view returns (uint x) {
        if(totalSupply() != 0){
            x = (balanceContract*multiplikator)/totalSupply();
        } else x = 100000000000000000;
        
        return x;
    }


    function _showAllRHTinBurningMechanism() private view returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < tokenBurns.length; i++) {
            sum += tokenBurns[i].amount;
        }
        return sum;
    }

    function BurnTokenInStruct(uint tokenBurnsId) private {
        TokenBurnData storage tokenToBurn = tokenBurns[tokenBurnsId];
        if(secondsRemaining(tokenToBurn.amount) != 0) {
            uint i = tokenToBurn.timeLeft - secondsRemaining(tokenToBurn.timestamp);
            uint x = (tokenToBurn.amount*100)/tokenToBurn.timeLeft;
            uint amountToBurn = (x*i)/100;
            tokenToBurn.amount = tokenToBurn.amount - amountToBurn;
            tokenToBurn.timeLeft = tokenToBurn.timeLeft - i;
        }
        else {
            remove(tokenBurnsId);
        }
        
    }

    function _TokenImagineBurnedTrigger() private view returns(uint) {
        uint amount = 0;
        uint sum = 0;
        for (uint i = 0; i < tokenBurns.length; i++) {
            sum+= TokenInStructIsImagineBurned(i);
            amount+= tokenBurns[i].amount;
        }
        sum = amount - sum;
        return sum;
    }

    function TokenInStructIsImagineBurned(uint tokenBurnsId) private view returns (uint) {
        TokenBurnData storage tokenToBurn = tokenBurns[tokenBurnsId];
        uint y;
        if(secondsRemaining(tokenToBurn.timestamp) != 0) {
            uint i = tokenToBurn.timeLeft - secondsRemaining(tokenToBurn.timestamp);
            uint x = (tokenToBurn.amount*100)/tokenToBurn.timeLeft;
            uint amountToBurn = (x*i)/100; 
            y = amountToBurn;
        } else y = tokenToBurn.amount; 
        return y;
    }

    function _BurnTokenTrigger() private {
        for (uint i = 0; i < tokenBurns.length; i++) {
            BurnTokenInStruct(i);
        }
        RHTvalue = _showRHTvalueForSell();
        showRHTvalueForSell();
        showRHTvalueForBuy();
    }

    function TriggerForShowAllUpdated() public {
        _BurnTokenTrigger();
    }

    function sellRHT(uint RHTamountToSell) public {
        _BurnTokenTrigger();
        uint i = RHTvalue;
        require(balanceOf(msg.sender) >= RHTamountToSell*multiplikator, "Check the token allowance");
        if(RHTvalue != _showRHTvalueForBuy()) {
            uint x = (_showRHTvalueForBuy() - RHTvalue)/2;
            _cashOut(owner(), RHTamountToSell * x);
        }
        _burn(msg.sender, RHTamountToSell*multiplikator);
        _cashOut(msg.sender, i * RHTamountToSell);
        balanceContract = BUSD.balanceOf(address(this));
        _BurnTokenTrigger();
        emit Sold(i * RHTamountToSell);
    }

    function sellRHTforOwnerOfRHTcontract(uint RHTamountToSell) public onlyOwner {
        _BurnTokenTrigger();
        uint i = _showRHTvalueForBuy();
        require(balanceOf(msg.sender) >= RHTamountToSell*multiplikator, "Check the token allowance");
        _burn(msg.sender, RHTamountToSell*multiplikator);
        _cashOut(msg.sender, i * RHTamountToSell);
        balanceContract = BUSD.balanceOf(address(this));
        _BurnTokenTrigger();
        emit Sold(i * RHTamountToSell);
    }

    function balanceInPool() public view returns (uint) {
        return BUSD.balanceOf(address(this));
    }

    function showRHTvalueForSellwithoutTrigger() public view returns (uint) {
        return _showRHTvalueForSell();
    }

    function showRHTvalueForBuywithoutTrigger() public view returns (uint) {
        return _showRHTvalueForBuy();
    }

    function showRHTvalueForSell() private {
        valueForSell = _showRHTvalueForSell();
    }

    function _showRHTvalueForSell() private view returns (uint i) {
        if(totalSupply() != 0){
            i = (balanceContract*multiplikator) / (totalSupply()+_TokenImagineBurnedTrigger());
        } else i = 100000000000000000;
        return i;
    }

    function _cashOut(address to, uint amount) private {
        _safeTransfer(BUSD, to, amount);
    }

    function remove(uint index) private{
        tokenBurns[index] = tokenBurns[tokenBurns.length - 1];
        tokenBurns.pop();
    }

    function totalSupplyWholeNumber()public view returns (uint){
        return totalSupply()/multiplikator;
    }

    function tokenBurnsLenght() public view returns (uint) {
        return tokenBurns.length;
    }

    function AmountYouGetForBUSDwhenMinting(uint BUSDamount) public view returns (uint) {
        uint i = (BUSDamount/_showRHTvalueForBuy())*955*multiplikator/1000;
        return i;
    }
}