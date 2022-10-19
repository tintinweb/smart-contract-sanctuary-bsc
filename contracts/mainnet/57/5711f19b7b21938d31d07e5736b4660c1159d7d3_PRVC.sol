/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.15;

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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)


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
contract PRVC is Context , IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint256 private  initialSupply = 4500000000000*(10**decimals());

    mapping (address => bool) public  _isExcludedFromFee;

    string private constant _name = "PrivaCoin";
    string private  constant _symbol = "PRVC";

    address public _devTeamWallet;

    uint  public  constant _devTeamTaxFee = 2; // 0.002 %
    uint  public constant _burnTaxFee = 3; // 0.003 %


    uint public  teamWalletUnlockPeriod;
    uint public  marketingWalletUnlockPeriod;
    uint public  roadMapWalletUnlockPeriod;
    uint public  reserveWalletUnlockPeriod;

    uint public maxBurnFee = 4499910000000*(10**decimals()); // 99,998 % will burn after that burn will stop.
    uint public _totalBurnFee;

    address public  constant teamWallet = 0x511578f92F8Efa632B2C1B5408dA4fc330A1655C; // 15 % of totalSupply
    address public  constant tokenSaleWallet = 0x3B72777854a2d0654FcaB46e70FFb6232742e9c4; // 40% of tokenSupply
    address public  constant marketingWallet = 0xA0a41f2Ddb51D43D5DF3550AbB2e65AF3e0ff2C1; // 9% of tokenSupply
    address public  constant roadMapWallet = 0xda4AFbEe5EA08BfA9BD4190110872D72F26803db; // 20% of tokenSupply
    address public  constant reserveWallet = 0xAce593162994DcF01316758348697314501Ec06f;// 16% of tokenSupply


 
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(address devTeam) {

        require (devTeam!=address(0),"invalid address");
        _devTeamWallet= devTeam;
         
         _isExcludedFromFee[msg.sender] = true;
         _isExcludedFromFee[_devTeamWallet] = true;

 
        // initiate multiSign Wallets

        for(uint i=0;i<owners.length;i++){

            address owner = owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner is already there!");
            isOwner[owner]=true;
          
        }

        // tokenomics tokens allocations

        teamWalletUnlockPeriod=block.timestamp+1095 days; // 3 year
        marketingWalletUnlockPeriod= block.timestamp+365 days; // 1 year
        roadMapWalletUnlockPeriod=block.timestamp+730 days;  // 2 year
        reserveWalletUnlockPeriod=block.timestamp+1460 days; // 4 year

        _mint(tokenSaleWallet, (initialSupply*40/100)); // 40% of tokenSupply
      

    }


    function claimTeamTokens(uint _trnxId) external onlyMultiOwner {

        require(block.timestamp>teamWalletUnlockPeriod,"can't unlock now");

        executeTransaction(_trnxId, 4); 
        _mint(teamWallet, (initialSupply*15/100)); //  15 % of totalSupply

    }

    function claimMarketingTokens(uint _trnxId) external onlyMultiOwner {

        require(block.timestamp>marketingWalletUnlockPeriod,"can't unlock now");
        executeTransaction(_trnxId, 5); 
          _mint(marketingWallet, (initialSupply*9/100)); // 9% of tokenSupply

    }

    function claimRoadMapTokens(uint _trnxId) external onlyMultiOwner {

        require(block.timestamp>roadMapWalletUnlockPeriod,"can't unlock now");
        executeTransaction(_trnxId, 6); 
          _mint(roadMapWallet, (initialSupply*20/100)); // 20% of tokenSupply
    }

    function claimReserveTokens(uint _trnxId) external onlyMultiOwner{

         require(block.timestamp>reserveWalletUnlockPeriod,"can't unlock now");
         executeTransaction(_trnxId, 7); 
        _mint(reserveWallet, (initialSupply*16/100)); // 16% of tokenSupply
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
    function totalSupply() external  view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external  view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) external  virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public   view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function calculateDevTaxFee(uint _amount) internal pure  returns (uint256) {
        return (_amount*(_devTeamTaxFee)/(100000));
    }

    function calculateBurnTaxFee(uint _amount) internal view  returns (uint256) {
    

        if (_totalBurnFee>maxBurnFee){

            return 0; // no more tax is needed
        }

        return (_amount*(_burnTaxFee)/(100000));
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
    function approve(address spender, uint256 amount) external  virtual override returns (bool) {
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
    ) external  virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) external  virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) external  virtual returns (bool) {
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

        // Tax Deduction ------------

        uint taxFee;
        uint _burnFee;
        uint _devFee;
    
        if (_isExcludedFromFee[from] ||  _isExcludedFromFee[to]){


        }else{

            _burnFee = calculateBurnTaxFee(amount);
            _devFee = calculateDevTaxFee(amount);

            if (_burnFee>0){
                // call burn                
                _totalSupply -= _burnFee;
                _totalBurnFee += _burnFee;

                emit Transfer(from, address(0), _burnFee);
                
            }

            if (_devFee>0){

                _balances[_devTeamWallet] += _devFee;
                emit Transfer(from, _devTeamWallet, _devFee);
            }

            taxFee=(_burnFee+_devFee);    

        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += (amount-taxFee);
        }

        emit Transfer(from, to, (amount-taxFee));

       
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

     

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        
    }


    function setDevTeamWallet(uint _trnxId) external onlyMultiOwner {

    
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.data != address(0),"invalid address");
      _devTeamWallet=_transactions.data;

      executeTransaction(_trnxId,1); // 1 for devTeamWallet

    }

    function ExculdeUserFromFee(uint _trnxId) external onlyMultiOwner {

        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.data != address(0),"invalid address");
        _isExcludedFromFee[_transactions.data] = true;
          executeTransaction(_trnxId,2); // 2 for ExcludeRewardOnly
    }

    function IncludeUserFromFee(uint _trnxId) external onlyMultiOwner {

        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.data != address(0),"invalid address");

      _isExcludedFromFee[_transactions.data] = false;

       executeTransaction(_trnxId,3); //3 for IncludeReward Only

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


    //-------------------MULTISiGn-------------------------

 
    address[] public owners=[0x5b3b60Eb668df2B9B48dDeA3c7FDd0B0264b33aE,0x8356b06a332DBe073a5908D1ebd2fdCAf8190bcA,
    0x6629ba9aA656dA61a5CaBDe98E04D4F2911A16A3,0x2a7CcA5c8babd8dDB7e592c40487BF2786DC8E1a,0xec826CcceCE1D3AD70f9Ee1B021790A1F6a669C3];


   


    mapping(address=>bool) public isOwner;

    uint public walletPermission =3; 
    Transaction[] public transactions;
    mapping(uint=> mapping(address=>bool)) public approved;

    struct Transaction{
      
        bool  isExecuted;
        uint methodID;
        address data;

        // 1 for Set Devteam
        // 2 for Set excludeReward
        // 3 for Set includeReward
        // 4 for teamTokensUnlock
        // 5 for marketingTokensUnlock
        // 6 for roadMapTokensUnlock
        // 7 for reserveTokensUnlock
    }


    //-----------------------EVENTS-------------------

    event assignTrnx(uint trnx);
    event Approve(address owner, uint trnxId);
    event Revoke(address owner, uint trnxId);
    event Execute(uint trnxId);


    //----------------------Modifier-------------------

    // YOU CAN REMOVE THIS OWNER MODIFIER IF YOU ALREADY USING OWNED LIB

    modifier onlyMultiOwner(){
        require(isOwner[msg.sender],"not an owner");
        _;
    }

    modifier trnxExists(uint _trnxId){
        require(_trnxId<transactions.length,"trnx does not exist");
        _;
    }

    modifier notApproved(uint _trnxId){

        require(!approved[_trnxId][msg.sender],"trnx has already done");
        _;
    }

    modifier notExecuted(uint _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"trnx has already executed");
        _;
    }



 // ADD NEW TRANSACTION 

    function newTransaction(uint _methodID, address _data) external onlyMultiOwner returns(uint){
        // check last transaction
        uint lastIndex;

        require(_methodID<=7 && _methodID>0,"invalid method id");
        if(transactions.length>0){

            lastIndex = transactions.length-1;
            require(transactions[lastIndex].isExecuted==true,"Please Execute Queue Transaction First");
        }
        transactions.push(Transaction({
            isExecuted:false,
            methodID:_methodID,
            data:_data
        }));

        approved[transactions.length-1][msg.sender]=true;
        emit Approve(msg.sender,transactions.length-1);

        emit assignTrnx(transactions.length-1);
        return transactions.length-1;
    }

    function getCurrentRunningTransactionId() external view returns(uint){

        if ( transactions.length>0){

            return transactions.length-1;
        }

        revert();
    }

    // APPROVE TRANSACTION BY ALL OWNER WALLET FOR EXECUTE CALL
    function approveTransaction(uint _trnxId)
     external onlyMultiOwner
     trnxExists(_trnxId)
     notApproved(_trnxId)
     notExecuted(_trnxId)

    {

        approved[_trnxId][msg.sender]=true;
        emit Approve(msg.sender,_trnxId);

    }

    // GET APPROVAL COUNT OF TRANSACTION
    function _getAprrovalCount(uint _trnxId) public view returns(uint ){

        uint count;
        for(uint i=0; i<owners.length;i++){

            if (approved[_trnxId][owners[i]]){

                count+=1;
            }
        }

        return count;
     
    }

    // EXECUTE TRANSACTION 
    function executeTransaction(uint _trnxId,uint _mID) internal trnxExists(_trnxId) notExecuted(_trnxId){

        require(_getAprrovalCount(_trnxId)>=walletPermission,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.methodID==_mID,"invalid Function call");
        _transactions.isExecuted = true;
        emit Execute(_trnxId);

    }



    // USE THIS FUNCTION WITHDRAW/REJECT TRANSACTION
    function revoke(uint _trnxId) external
    onlyMultiOwner
    trnxExists(_trnxId)
    notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"trnx has not been approve");
        approved[_trnxId][msg.sender]=false;

       emit Revoke(msg.sender,_trnxId);
    }



}