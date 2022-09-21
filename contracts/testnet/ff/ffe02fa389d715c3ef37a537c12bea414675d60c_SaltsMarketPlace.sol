/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "no whitelist");
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param addr address
     */
    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     */
    function addAddressesToWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     */
    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     */
    function removeAddressesFromWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }
}

interface IToken {
    function calculateTransferTaxes(address _from, uint256 _value)
        external
        view
        returns (uint256 adjustedValue, uint256 taxAmount);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function burn(uint256 _value) external;

    function burnFrom(address account, uint256 amount) external;

    function currentSupply() external returns (uint256);

    function updateRewards(uint256 _amount) external;
}

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract SaltsMarketPlace is Ownable {
    IToken public SALTS;
    IERC20 public BUSD;
    
    bool public isPaused;
    address public devWallet;
    
    uint256 a = 1;
    uint256 b = 2;
    uint256 c = a / b;
    mapping(uint256 => uint256) public commision; // for referals
    
    mapping(address => bool) internal isRegistered;
    
    struct User {
        address user;
        address parent;
        uint256 withdrawableRefAmount;
    }
    
    mapping(address => User) public users;
    
    function registerUser(address _user, address _referer) external {
        require(isRegistered[_user] == false);
        // the default value for a user regestering without ref is 0x00
        if (_referer == address(0)) {
            _register(_user);
        } else {
            _register(_user);
            User storage user = users[msg.sender];
            user.parent = _referer;
        }
        emit UserRegistered(_user, _referer, block.timestamp);
    }
    
    function _register(address _user) internal {
        users[_user].user = _user;
        isRegistered[_user] = true;
    }
    
    constructor(
        address BUSD_addr,
        address SALTS_addr,
        address _devWallet
    ) {
        SALTS = IToken(SALTS_addr);
        BUSD = IERC20(BUSD_addr);
        devWallet = _devWallet;
        commision[0] = 5;
        commision[1] = 3;
        commision[2] = 2;
        commision[3] = 1;
        commision[4] = c;
    }
    
    event UserRegistered(
        address indexed user,
        address indexed referer,
        uint256 timestamp
    );
    event TokensBought(
        address user,
        uint256 busdAmount,
        uint256 tax,
        uint256 saltsRecieved,
        uint256 timestamp
    );
    event TokensSold(
        address user,
        uint256 saltsAmount,
        uint256 taxAmount,
        uint256 busdGot,
        uint256 timestamp
    );
    
    event RefTx(uint refIndex, address user, uint amount, uint timestamp);
    
    function unpause() public onlyOwner {
        isPaused = false;
    }

    function pause() public onlyOwner {
        isPaused = true;
    }

    modifier isNotPaused() {
        require(!isPaused, "Swaps currently paused");
        _;
    }

    // reverts fallback. can not deposit ether to this contract
    receive() external payable {
        revert();
    }

    function salts_balance() public view returns (uint256) {
        return SALTS.balanceOf(address(this));
    }

    function busd_balance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    // calculates whale tax depending on the amount
    function taxWhale(uint256 _amount) internal returns (uint8) {
        uint256 token_current_supply = SALTS.currentSupply();
        uint256 i = ((_amount / token_current_supply) * 100);

        uint8 whaleTax;

        if (i < 1) {
            whaleTax = 0;
        } else if (i > 1 && i < 2) {
            whaleTax = 5;
        } else if (i > 2 && i < 3) {
            whaleTax = 10;
        } else if (i > 3 && i < 4) {
            whaleTax = 15;
        } else if (i > 4 && i < 5) {
            whaleTax = 20;
        } else if (i > 5 && i < 6) {
            whaleTax = 25;
        } else if (i > 6 && i < 7) {
            whaleTax = 30;
        } else if (i > 7 && i < 8) {
            whaleTax = 35;
        } else if (i > 8 && i < 9) {
            whaleTax = 40;
        } else if (i > 9 && i < 10) {
            whaleTax = 45;
        } else if (i >= 10) {
            whaleTax = 50;
        }
        return whaleTax;
    }

    mapping(address => uint256) public token_balances;
    address public rewards_pool;

    // checks amount for whale tax eligibility
    function WhaleTax(uint256 amount) internal returns (bool) {
        uint8 i = taxWhale(amount);
        if (i == 0) {
            return true;
        } else {
            return false;
        }
    }

    // busd to salts
    function BUY(uint256 busdAmount) public {
        // calculate CMP
        uint256 amount = busdAmount * CMP_Busd_to_Salts();
        uint256 taxAmount;
        uint256 amount_to_transfer;
        uint256 whaleTaxAmount;

        if (WhaleTax(amount) == true) {
            // calculates whale tax
            uint8 tax = taxWhale(amount);
            // calculates amount
            whaleTaxAmount = (amount * tax) / 100;
            // distributes amount
            amount = amount - whaleTaxAmount;
        }

        taxAmount = (amount * 10) / 100;
        amount_to_transfer = amount - taxAmount;
        distributeFee(msg.sender, taxAmount + whaleTaxAmount);

        // perform Swap
        BUSD.transferFrom(msg.sender, address(this), busdAmount);

        SALTS.transfer(msg.sender, amount_to_transfer);

        emit TokensBought(
            msg.sender,
            busdAmount,
            taxAmount,
            amount_to_transfer,
            block.timestamp
        );
    }

    // salts to busd
    function SELL(uint256 saltsAmount) public {
        // user transfers slats tokens to this smart contract
        SALTS.transfer(address(this), saltsAmount);

        uint256 taxAmount;
        uint256 amount_to_busd;
        uint256 whaleTaxAmount;

        if (WhaleTax(saltsAmount) == true) {
            // calculates whale tax
            uint8 tax = taxWhale(saltsAmount);
            // calculates amount
            whaleTaxAmount = (saltsAmount * tax) / 100;
            // calculates regular fees on remaining amount
            saltsAmount = saltsAmount - whaleTaxAmount;
        }

        taxAmount = (saltsAmount * 10) / 100;
        amount_to_busd = saltsAmount - taxAmount;
        distributeFee(msg.sender, taxAmount + whaleTaxAmount);

        // calculate CMP
        uint256 amount = amount_to_busd * CMP_Salts_to_Busd();

        // transfers BUSD amount to user
        BUSD.transfer(msg.sender, amount);

        emit TokensSold(
            msg.sender,
            saltsAmount,
            taxAmount,
            amount,
            block.timestamp
        );
    }

    function distributeFee(address _user, uint256 amount) internal {
        uint256 DevTax;
        uint256 Rewards;
        uint256 BurnTax;
        uint8 i = 0;
        User storage tempUser = users[_user];
        while (tempUser.parent != address(0) && i <= 4) {
            tempUser = users[tempUser.parent];
            tempUser.withdrawableRefAmount += (amount * commision[i]) / 100;
            amount -= (amount * commision[i]) / 100;
            i++;
            //TODO: emit an event for referral index and amount and temp user address.
            emit RefTx(i, tempUser.parent, (amount * commision[i]) / 100, block.timestamp);
        }

        DevTax = (amount * 25) / 100;
        Rewards = (amount * 35) / 100;
        BurnTax = (amount * 40) / 100;

        token_balances[devWallet] += DevTax;
        token_balances[rewards_pool] += Rewards;
        SALTS.transfer(rewards_pool, Rewards);
        SALTS.updateRewards(Rewards); //TODO : pass in this address.
        // BurnTokens
        SALTS.burnFrom(address(this), BurnTax);
    }
    // current market price per 1 SALTS to BUSD
    function CMP_Salts_to_Busd() public view returns (uint256) {
        uint256 CMP = busd_balance() / salts_balance();
        return CMP;
    }

    // current market price per 1 BUSD to SALTS
    function CMP_Busd_to_Salts() public view returns (uint256) {
        uint256 CMP = salts_balance() / busd_balance();
        return CMP;
    }

    function rewards_pool_address(address _stakingContract) public onlyOwner {
        rewards_pool = _stakingContract;
    }
}