/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// SPDX-License-Identifier: MITS

pragma solidity 0.8.7;


contract CacaDragon {

    /// @notice EIP-20 token name for this token
    string public constant name = "Caca Dragon";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "CDR";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint256 public totalSupply = 1000000000000000 * 10 ** 18; 

    /// @dev Allowance amounts on behalf of others
    mapping(address => mapping(address => uint256)) internal allowances;

    /// @dev Official record of token balances for each account
    mapping(address => uint256) internal balances;

    /// @dev maximium buy => 0.5
    uint256 private _maxBuy = 500000000000000000; 

    address[] internal stakeholders;

    /**
    * @notice The stakes for each stakeholder.
    */
   mapping(address => uint256) internal stakes;

   /**
    * @notice The accumulated rewards for each stakeholder.
    */
   mapping(address => uint256) internal rewards;

   
    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @notice set token sales price
    uint256 public constant tokenPrice = 5; // 1 token for 5 wei

    // /// @notice total amount of tax collected
    // uint totalTaxedAmount = 0;

    /// @notice set token sales price
    uint256 tax = 15;

    /// @notice dex adrress check
    mapping(address => bool) public is_dex;

    /// @notice address can hold more than 3% of total supply
    mapping(address => bool) public unlimitedhold;

    /// @notice blacklist address
    mapping(address=>bool) isBlacklisted;

    /// @notice admin address
    address admin;

    /// @notice admin role
    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function.");
    _;
    }

    /**
     * @notice Construct a new Gym token
     * @param account The initial account to grant all the tokens
     */

    constructor(address account) {
        admin = msg.sender;
        balances[account] = uint256(totalSupply);
        emit Transfer(address(0), account, totalSupply);
    }


     /**
     * @notice Add/update dex address
     * @param _dex The dex farm account
     */
    function AddDexaddr(address _dex) onlyAdmin external returns(bool) {
        // payable(_dex);
        is_dex[_dex] = true;
        return true;
    }

    /**
     * @notice allow address to hold more than 3% of totalSupply
     * @param _who account
     */
    function AddUnlimitedHold(address _who) onlyAdmin external returns(bool) {
        unlimitedhold[_who] = true;
        return true;
    }

     /**
     * @notice allow address to hold more than 3% of totalSupply
     * @param _who account
     */
    function allowUnlimitedHold(address _who) onlyAdmin external returns(bool) {
        unlimitedhold[_who] = false;
        return true;
    }

     /**
     * @notice blacklist address
     * @param _addr address to blackist
     */
    function blackList(address _addr) public onlyAdmin {
        require(!isBlacklisted[_addr], "address already blacklisted");
        isBlacklisted[_addr] = true;
    }

    /**
     * @notice bulk blacklist address
     * @param _addresses addresses to blackist
     */
    function bulkBlacklist(address[] memory _addresses) public onlyAdmin {
        for (uint i = 0; i < _addresses.length; i++) {
                isBlacklisted[_addresses[i]] = true;
            }
    }

     /**
     * @notice remove address from blacklist 
     * @param _addr address to remove
     */
    function removeFromBlacklist(address _addr) public onlyAdmin {
        require(isBlacklisted[_addr], "address already whitelisted");
        isBlacklisted[_addr] = false;
        
    }

    /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */

    function isStakeholder(address _address) public view returns(bool, uint256) {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder) public onlyAdmin{
    //    (bool _isStakeholder, ) = isStakeholder(_stakeholder);
    //    if(!_isStakeholder) stakeholders.push(_stakeholder);
    stakeholders.push(_stakeholder);

    }



    /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }

 

   /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake, address stakeholder)
       public onlyAdmin
   {
    //    if(stakes[stakeholder] == 0) addStakeholder(stakeholder);
       stakes[stakeholder] = _stake;
   }

   
   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeholder The stakeholder to check rewards for.
    */
   function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }


   /**
    * @notice A simple method that calculates the rewards for each stakeholder.
    * @param _stakeholder The stakeholder to calculate rewards for.
    */
//    function calculateReward(address _stakeholder)
//        public
//        view
//        returns(uint256)
//    {
//        uint256 revenue = address(this).balance;
//        uint256 reward = (stakes[_stakeholder] * revenue) / 100;
//        return reward;
//    }

   /**
    * @notice A method to distribute rewards to all stakeholders.
    */
   function distributeRewards(uint256 _revenue)
       private
       
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           address stakeholder = stakeholders[s];
        //    uint256 reward = calculateReward(stakeholder);
        uint256 reward = (stakes[stakeholder] * _revenue) / 100;
           rewards[stakeholder] = reward;
       }
   }

   /**
    * @notice A method to allow a stakeholder to withdraw rewards.
    */
   function withdrawReward()
       public
   {
       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;
        mint(reward);
        
        
   }

     /**
     * @notice remove dex address
     * @param _dex The dex farm account
     */
    function RemoveDexaddr(address _dex) onlyAdmin external returns(bool) {
        is_dex[_dex] = false;
        return true;
    }

    // calculate percentage and round off to preci. if you feed it 101,450, 3  get 224, i.e. 22.4%.
    function percentage(uint numerator, uint denominator, uint precision) public pure returns(uint quotient) {

         // caution, check safe-to-multiply here
        uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
  }

    /**
    * @notice anti whale check
    * @param _who account holder
    */
    function canHold(address _who) public view returns(bool) {
        // check if address is allowed to hold more than 3% totalSupply
        if(unlimitedhold[_who]){
            return true;
        }

        // get account balance
        uint256 Userbal = balances[_who];

    
        // calculate 2% of total supply
        uint256 percentTotal = (2 * totalSupply)/100;
    
        // check if account is less than 2% of totalSupply
        if(Userbal < percentTotal){
            return true;
        }
        return false;
    }
   
      /**
     * @notice update tax fee
     * @param _newfee The dex farm account
     */
    function UpdateTax(uint256 _newfee) onlyAdmin external returns(bool) {
        tax = _newfee;
        return true;
    }



     /**
     * @notice calculate maxium buy amount (0.5% of totalsupply)
     * @param _buyrate buyrate amount
     */
    function Buypercent(uint256 _buyrate )public view returns (uint256) {
        
        // calculate buyrate percentage of totalsupply (0.5% of totalsupply)
        uint256 totalBuyperct = (_buyrate * totalSupply)/100;

        return totalBuyperct;
       
    }

    function mint(uint256 rawAmount) private {
        _mint(msg.sender, rawAmount);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 rawAmount) external returns (bool) {
        uint256 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint256).max;
        } else {
            amount = safe96(rawAmount, "Token::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    
    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint256 rawAmount) public returns (bool) {
        
        // @notice antiwhale check, check if address can hold more than 2% of totalsupply
        // require(canHold(dst) == true, "You cannot hold more than 2% of totalsupply");

        // @notice antiwhale check, check if address is blacklisted
        require(!isBlacklisted[dst], "address is backlisted");

        
        /// @notice if reciever address is dex then there its a sell order, apply tax
        if(is_dex[dst] == true){

            // check for sell amount and apply tax accordinly

            //   if(rawAmount > 2 * 10 ** 18){
            //     tax = 17;
            // }

            // else if(rawAmount > 4 * 10 ** 18){
            //     tax = 19;
            // }
            // else if(rawAmount > 6 * 10 ** 18){
            //     tax = 21;
            // }
            // else if(rawAmount > 8 * 10 ** 18){
            //     tax = 23;
            // }
            // else if(rawAmount > 10 * 10 ** 18){
            //     tax = 24;
            // }
            // else if(rawAmount > 12 * 10 ** 18){
            //     tax = 25;
            // }
            // update sender balance
            balances[msg.sender] =  balances[msg.sender] - rawAmount;

             // get tax percent in ether
            uint256 taxPerct = (tax * rawAmount) /100;

            
            // update receiver balance
            balances[dst] = balances[dst]  + rawAmount - taxPerct;
            
            // initiate transfer
            uint256 trnsfAmount = rawAmount - taxPerct;

            _transferTokens(msg.sender, dst, trnsfAmount);

            distributeRewards(taxPerct);
        
            return true;
        }
         
         /// @notice if sender address is dex then its a buy order, apply buy tax
        else if(is_dex[msg.sender] == true){
            // get 0.5% of totalsupply in ether
            // uint256 perctofTotalsupply = Buypercent(_maxBuy);


            // require(rawAmount <= perctofTotalsupply, "exceeds maximum buy rate");

            // update sender balance
            balances[msg.sender] =  balances[msg.sender] - rawAmount;

             // get tax percent in ether
            uint256 taxPerct = (tax * rawAmount) /100;

            
            // update receiver balance
            balances[dst] = balances[dst]  + rawAmount - taxPerct;
            
            // initiate transfer
            uint256 trnsfAmount = rawAmount - taxPerct;

            _transferTokens(msg.sender, dst, trnsfAmount);
            return true;
         }

         // update sender balance
        balances[msg.sender] =  balances[msg.sender] - rawAmount;

        // update receiver balance
        balances[dst] = balances[dst]  + rawAmount;
        
        _transferTokens(msg.sender, dst, rawAmount);

        return true; 


    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) public returns (bool) {
        // address spender = msg.sender;
        // uint256 spenderAllowance = allowances[src][spender];
        // uint256 amount = safe96(rawAmount, "Token::approve: amount exceeds 96 bits");

        // if (spender != src && spenderAllowance != type(uint256).max) {
        //     uint256 newAllowance = sub96(
        //         spenderAllowance,
        //         amount,
        //         "Token::transferFrom: transfer amount exceeds spender allowance"
        //     );
        //     allowances[src][spender] = newAllowance;

        //     emit Approval(src, spender, newAllowance);
        // }

         // @notice antiwhale check, check if address can hold more than 2% of totalsupply
        // require(canHold(dst) == true, "You cannot hold more than 2% of totalsupply");

        // @notice anti-sniper check, check if address is blacklisted
        require(!isBlacklisted[dst], "address is backlisted");
        
       /// @notice if reciever address is dex then its a sell order apply tax
        if(is_dex[dst] == true){

            // if(rawAmount > 2 * 10 ** 18){
            //     tax = 17;
            // }

            // else if(rawAmount > 4 * 10 ** 18){
            //     tax = 19;
            // }
            // else if(rawAmount > 6 * 10 ** 18){
            //     tax = 21;
            // }
            // else if(rawAmount > 8 * 10 ** 18){
            //     tax = 23;
            // }
            // else if(rawAmount > 10 * 10 ** 18){
            //     tax = 24;
            // }
            // else if(rawAmount > 12 * 10 ** 18){
            //     tax = 25;
            // }

            // update sender balance
            balances[src] =  balances[src] - rawAmount;

            // get tax percent in ether
            uint256 taxPerct = (tax * rawAmount) /100;
   
            // update receiver balance
            balances[dst] = balances[dst]  + rawAmount - taxPerct;
            
            // initiate transfer
            uint256 trnsfAmount = rawAmount - taxPerct;

            _transferTokens(src, dst, trnsfAmount);
            return true;
        }
         
         /// @notice if sender address is dex then its buy order apply tax
        else if(is_dex[src] == true){

             // get 0.5% of totalsupply in ether
            // uint256 perctofTotalsupply = Buypercent(_maxBuy);

            // require(rawAmount <= perctofTotalsupply, "exceeds maximum buy rate");

            // update sender balance
            balances[src] =  balances[src] - rawAmount;

            // get tax percent in ether
            uint256 taxPerct = (tax * rawAmount) /100;
 
            // update receiver balance
            balances[dst] = balances[dst]  + rawAmount - taxPerct;
            
            // initiate transfer
            uint256 trnsfAmount = rawAmount - taxPerct;

            _transferTokens(src, dst, trnsfAmount);
            return true;
         }
         
           // update sender balance
        balances[msg.sender] =  balances[msg.sender] - rawAmount;

        // update receiver balance
        balances[dst] = balances[dst]  + rawAmount;

         _transferTokens(src, dst, rawAmount);
        return true;
    }

   

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function burn(uint256 rawAmount) public {
        uint256 amount = safe96(rawAmount, "Token::approve: amount exceeds 96 bits");
        _burn(msg.sender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     */
    function burnFrom(address account, uint256 rawAmount) public {
        uint256 amount = safe96(rawAmount, "Token::approve: amount exceeds 96 bits");
        uint256 currentAllowance = allowances[account][msg.sender];
        require(currentAllowance >= amount, "Token: burn amount exceeds allowance");
        allowances[account][msg.sender] = currentAllowance - amount;
        _burn(account, amount);
    }

  



    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Token: burn from the zero address");
        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {
        require(src != address(0), "Token::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Token::_transferTokens: cannot transfer to the zero address");

        // balances[src] = sub96(balances[src], amount, "Token::_transferTokens: transfer amount exceeds balance");
        // balances[dst] = add96(balances[dst], amount, "Token::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

    }

    

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint256) {
        require(n < 2**96, errorMessage);
        return uint256(n);
    }

      function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}