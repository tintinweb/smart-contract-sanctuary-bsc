/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// File: openzeppelin-solidity/contracts/utils/Context.sol


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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol


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

// File: openzeppelin-solidity/contracts/token/ERC20/extensions/IERC20Metadata.sol


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

// File: contracts/RevRev.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;





contract RRR22 is Context, IERC20, IERC20Metadata {
        mapping(address => uint256) private _balances;
        mapping(address => uint256) private _stake_holders;
        mapping(address => uint256) private _token_holders;
        mapping(address => uint256) private _stake_reward_snap;
        mapping(address => uint256) private _metamask_reward_snap;
        
        

    mapping(address => mapping(address => uint256)) private _allowances;
   

    uint256 private _bronze_count = 0;
    uint256 private _silver_count = 0;
    uint256 private _gold_count = 0;
    uint256 private _platinum_count = 0;
    uint256 private _diamond_count = 0;

    uint256  private _pool_weight_bronze  = 15;
    uint256  private _pool_weight_silver  = 35 ;
    uint256  private _pool_weight_gold  = 60;
    uint256  private _pool_weight_platinum  = 190;
    uint256  private _pool_weight_diamond  = 390;

    uint256  private _tier_amount_bronze  = 15000;
    uint256  private _tier_amount_silver  = 25000 ;
    uint256  private _tier_amount_gold  = 50000;
    uint256  private _tier_amount_platinum  = 150000;
    uint256  private _tier_amount_diamond  = 300000;
    

    uint256 private _totalSupply= 1000000000000000000;
    uint256 private _max_allocation = 1000000;
    address private _owner; 
    address private _myowner;
    string private _name ;
    string private _symbol;

    address private  _dev_wallet = 0x92Acac2777A7187Ed3AE685E6adAd34eDcFED9B9;
    address private _stake_reward_wallet = 0xFc69C5737dfB31D773e3213F0028f96F1621569C;
    address private _metamask_reward_wallet = 0x11d29f21Db0401d826B7ee19fD565Ad8603041cD;

    address private _stake_wallet = 0x02730033a1626Eb292E74Bcb7234F175BB30c4C6;
    address private _liquidity_wallet = 0x5B6d6EeF49FB770CC128272ef0A3E002284bE8cb ;

    uint256 private _stake_reward_bowl;
    uint256 private _metamask_reward_bowl;

    uint256 private _slipage = 10;
    uint256 private _developer_percent = 2;
    uint256 private _stake_reward_percent = 5;
    uint256 private _metamask_reward_percent = 10;
    uint256 private _marketing_reward_percent = 10;
    uint256 private _liquidity_percent = 5;

    address private _marketing_wallet = 0x4eD52868B6562173506B1226C5f72B752f774f38;
    address private _landing_address;

    address [] private _stake_holders_arr;
    address[] private _token_holders_arr;

    uint256 private _dev_reward_bowl;
    uint256 private _marketing_reward_bowl;
    uint256 private _liquidity_reward_bowl;


   
    constructor() {
        _name = "RRR22";
        _symbol = "RRR22";
               _myowner = msg.sender;


       // _mint(msg.sender,_totalSupply);
       _balances[msg.sender] = _totalSupply;
    }

    /**
     * @dev Returns the name of the token.
     */

    

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function max_allocation() public view returns (uint256){
        return _max_allocation;
    }

    function stake_reward_bowl() public view returns (uint256){
        return _stake_reward_bowl;
    }

    function metamask_reward_bowl() public view returns (uint256){
        return _metamask_reward_bowl;
    }

    function dev_reward_bowl() public view returns (uint256){
        return _dev_reward_bowl;
    }

    function marketing_reward_bowl() public view returns (uint256){
        return _marketing_reward_bowl;
    }

    function liquidity_reward_bowl() public view returns (uint256){
        return _liquidity_reward_bowl;
    }

    function stake_wallet() public view returns (address){
        return _stake_wallet;
    }

     function metamask_reward_wallet() public view returns (address){
        return _metamask_reward_wallet;
    }

    function liquidity_wallet() public view returns (address){
        return _liquidity_wallet;
    }

    function my_stake_reward(address ad) public view returns (uint256){
        return _stake_reward_snap[ad];
    }

    function my_metamask_reward(address ad) public view returns (uint256){
        return _metamask_reward_snap[ad];
    }

    function landin_address() public view returns (address){
        return _landing_address;
    }

    function stake_reward_wallet() public view returns (address){
        return _stake_reward_wallet;
    }

    function bronze_members() public view returns (uint256){
        return _bronze_count;
    }
    function silver_members() public view returns (uint256){
        return _silver_count;
    }
    function gold_members() public view returns (uint256){
        return _gold_count;
    }
    function platinum_members() public view returns (uint256){
        return _platinum_count;
    }
    function diamond_members() public view returns (uint256){
        return _diamond_count;
    }



    function get_tok_val(address adr) public view returns (uint256){
        return balanceOf(adr);
    }


    function tier_amount_bronze() public view  returns (uint256) {
        return _tier_amount_bronze;
    }
    function tier_amount_silver() public view  returns (uint256) {
        return _tier_amount_silver;
    }
    function tier_amount_gold() public view  returns (uint256) {
        return _tier_amount_gold;
    }
    function tier_amount_platinum() public view  returns (uint256) {
        return _tier_amount_platinum;
    }
     function tier_amount_diamond() public view  returns (uint256) {
        return _tier_amount_diamond;
    }

    function pool_weight_bronze() public view  returns (uint256) {
        return _pool_weight_bronze;
    }
    function pool_weight_silver() public view  returns (uint256) {
        return _pool_weight_silver;
    }
    function pool_weight_gold() public view  returns (uint256) {
        return _pool_weight_gold;
    }
    function pool_weight_platinum() public view  returns (uint256) {
        return _pool_weight_platinum;
    }
     function pool_weight_diamond() public view  returns (uint256) {
        return _pool_weight_diamond;
    }

    function developer_percent() public view  returns (uint256) {
        return _developer_percent;
    }
    
    function stake_reward_percent() public view  returns (uint256) {
        return _stake_reward_percent;
    }

    function liquidity_percent() public view  returns (uint256) {
        return _liquidity_percent;
    }

     function metamask_reward_percent() public view  returns (uint256) {
        return _metamask_reward_percent;
    }

     function marketing_reward_percent() public view  returns (uint256) {
        return _marketing_reward_percent;
    }

    /* set tier amount */

     function set_tier_amount_bronze(uint256 amt) public   returns (uint256) {
         if(_myowner == msg.sender){
         _tier_amount_bronze = amt;
         return _tier_amount_bronze;
         }
         else 
         {
             return 0;
         }
    }

    function set_stake_reward_percent(uint256 amt) public    {
        if(_myowner == msg.sender){
        _stake_reward_percent = amt;
        }
    }

    function set_liquidity_percent(uint256 amt) public    {
        if(_myowner == msg.sender){
       _liquidity_percent = amt;
        }
    }

    function set_metamask_reward_percent(uint256 amt) public    {
        if(_myowner == msg.sender){
       _metamask_reward_percent = amt;
        }
    }

    function set_marketing_reward_percent(uint256 amt) public    {
        if(_myowner == msg.sender){
        _marketing_reward_percent = amt;
        }
    }

    function set_developer_percent(uint256 amt) public    {
        if(_myowner == msg.sender){
       _developer_percent = amt;
        }
    }

    function set_stake_reward_wallet(address ad) public    {
        if(_myowner == msg.sender){
        _stake_reward_wallet = ad;
        }
    }

    function set_metamask_reward_wallet(address ad) public    {
        if(_myowner == msg.sender){
        _metamask_reward_wallet = ad;
        }
    }

    function set_liquidity_wallet(address ad) public    {
        if(_myowner == msg.sender){
        _liquidity_wallet = ad;
        }
    }

     function set_stake_wallet(address ad) public    {
         if(_myowner == msg.sender){
        _stake_wallet = ad;
         }
    }

   
     function set_landing_address(address ad) public    {
         if(_myowner == msg.sender){
        _landing_address = ad;
         }
    }
    function set_tier_amount_silver(uint256 amt) public  returns (uint256) {
        if(_myowner == msg.sender){
        _tier_amount_silver = amt;
        return _tier_amount_silver;
        }
        else{
            return 0;
        }
    }
    function set_tier_amount_gold(uint256 amt) public   returns (uint256) {
        if(_myowner == msg.sender){
        _tier_amount_gold = amt;
        return  _tier_amount_gold;
        }
        else{
        return 0;
        }
    
    }
    function set_tier_amount_platinum(uint256 amt) public   returns (uint256) {
        if(_myowner == msg.sender){
         _tier_amount_platinum = amt;
         return  _tier_amount_platinum;
        }
        else {
            return 0;
        }
    }
     function set_tier_amount_diamond(uint256 amt) public   returns (uint256) {
         if(_myowner == msg.sender){
         _tier_amount_diamond = amt;
         return _tier_amount_diamond;
         }
         else {
             return 0;
         }
    }

   /* set weight */

    function set_pool_weight_bronze(uint256 amt) public   {
        if(_myowner == msg.sender){
         _pool_weight_bronze= amt;
        }
    }
    function set_pool_weight_silver(uint256 amt) public   {
        if(_myowner == msg.sender){
        _pool_weight_silver = amt;
        }
    }
    function set_pool_weight_gold(uint256 amt) public    {
        if(_myowner == msg.sender){
        _pool_weight_gold = amt;
        }
    }
    function set_pool_weight_platinum(uint256 amt) public   {
        if(_myowner == msg.sender){
         _pool_weight_platinum = amt;
        }
    }
     function set_pool_weight_diamond(uint256 amt) public   {
         if(_myowner == msg.sender){
         _pool_weight_diamond =  amt;
         }
    }

    //  ==============================================================>

     function get_stake_tier(address adr) public view returns (string memory ){
         uint256 staked_amount =  get_stake_amount(adr);
         if(staked_amount >= 150000000 && staked_amount <300000000 ){
             return "Bronze";
         }
         else if(staked_amount >= 300000000 && staked_amount <500000000){
             return "Silver";
         }
         else if(staked_amount >= 500000000 && staked_amount <1500000000){
             return "Gold";
         }
         else if(staked_amount >= 1500000000 && staked_amount <3000000000){
             return "Platinum";
         }
         else if(staked_amount >= 3000000000){
             return "Diamond";
         }
         else{
             return "No Tier";
         }
     }


     function get_pool_weight(address adr) public view returns (uint256 ){
         uint256 staked_amount =  get_stake_amount(adr);
         if(staked_amount >= 150000000 && staked_amount <300000000 ){
             return 15;
         }
         else if(staked_amount >= 300000000 && staked_amount <500000000){
             return 35;
         }
         else if(staked_amount >= 500000000 && staked_amount <1500000000){
             return 60;
         }
         else if(staked_amount >= 1500000000 && staked_amount <3000000000){
             return 190;
         }
         else if(staked_amount >= 3000000000){
             return 390;
         }
         else{
             return 0;
         }
     }



    function marketing_wallet() public view  returns (address) {
        return _marketing_wallet;
    }

    function dev_wallet() public view  returns (address) {
        return _dev_wallet;
    }

    function get_stake_amount(address wallet) public view returns(uint256){
        return _stake_holders[wallet];
    }

    function show_stake_holders() public view returns( address[] memory ){
        
        return _stake_holders_arr;
    }

     function show_token_holders() public view returns( address[] memory ){
        
        return _token_holders_arr;
    }



    function slipage() public view  returns (uint256) {
        return _slipage;
    }

   function set_dev_wallet(address wallet) public  {
       if(_myowner == msg.sender){
        _dev_wallet = wallet;
       }
    }

    function set_max_allocation(uint256 amt) public  {
        if(_myowner == msg.sender){
        _max_allocation = amt;
        }
    }

    function un_stake( address uad, uint256 amount ) public returns (bool){
       
       
       _stake_holders[uad] -= amount ;
       
       _balances[uad] += amount ; 
       _balances[_stake_wallet] -= amount;

       emit Transfer(_stake_wallet, uad, amount);
       return true;

    }

    function distribute_stake_reward() public returns (uint256) {
if(_myowner == msg.sender){
         //loop through stake array l

         //unit total_stakers = _stake_holders_arr.length;
         uint256 stake_value_sum = 0;
         uint256 stake_reward_bal = _stake_reward_bowl;
         
         for(uint256 i = 0; i< _stake_holders_arr.length; i++ ){
            uint256 s_val = _stake_holders[_stake_holders_arr[i]];
              stake_value_sum += s_val;

         }
                //  return stake_value_sum;

         

         uint256 disburse_amount =   10000*stake_reward_bal/stake_value_sum;

         for(uint256 z =0; z< _stake_holders_arr.length; z++){
            address add = _stake_holders_arr[z];

            // get privious amt 
            
             uint256 privious_stake_val =  _stake_reward_snap[add];
             uint256 final_val =  privious_stake_val + _stake_holders[add]*disburse_amount;
           _stake_reward_snap[add] = final_val;
        
          // _balances[_stake_reward_wallet] -= 0;
          _stake_reward_bowl = 0;

          }
          
         return disburse_amount;
}
else{
    return 0;
}
    }


     function distribute_metamask_reward() public returns(uint256)  {
            if(_myowner == msg.sender){
                 //loop through stake array l

         //unit total_stakers = _stake_holders_arr.length;
         uint256 stake_value_sum = 0;
         uint256 stake_reward_bal = _metamask_reward_bowl;
         
         for(uint256 i = 0; i< _token_holders_arr.length; i++ ){
            uint256 s_val = _token_holders[_token_holders_arr[i]];
              stake_value_sum += s_val;

         }
                //  return stake_value_sum;

         

         uint256 disburse_amount =   10000*stake_reward_bal/stake_value_sum;

         for(uint256 z =0; z< _token_holders_arr.length; z++){
            address add = _token_holders_arr[z];

            // get privious amt 
            
          uint256 privious_stake_val =  _metamask_reward_snap[add];
            uint256 final_val =  privious_stake_val + _token_holders[add]*disburse_amount;
             _metamask_reward_snap[add] = final_val;
        
          // _balances[_metamask_reward_wallet] = 0;//final_val/1000;
          _metamask_reward_bowl = 0;
           

          }
          
         return disburse_amount;
    }
     else{
            return 0;
    }
       
    }


    function reedim_reward_stake(address uad) public returns(uint256){

       //uint256 my_reward_amount  =  _stake_reward_snap[uad];      
       _stake_reward_snap[uad] = 0; 
       //_balances[uad] += my_reward_amount;
       //_balances[_stake_reward_wallet] -= my_reward_amount;
       
       
       return balanceOf(uad);
    }

    function reedim_reward_metamask(address uad)  public  returns(uint256){
       // uint256 my_reward_amount  =  _metamask_reward_snap[uad];
       //_balances[uad] += my_reward_amount;
       _metamask_reward_snap[uad] = 0; 
        //_balances[uad] += my_reward_amount;
        //_balances[_metamask_reward_wallet] -= my_reward_amount;
      // emit Transfer(_metamask_reward_wallet, uad, my_reward_amount);
       return balanceOf(uad);
    }

    function set_stake(address uad , uint256 amt) public {
        
        _stake_holders[uad] += amt;
        bool push = true ;
        uint256 arrlength =  _stake_holders_arr.length;
        for(uint256 i=0; i<arrlength; i++){

            if(_stake_holders_arr[i] == uad){
                push = false;
            }
            
        }

        if(push == true){
         _stake_holders_arr.push(uad);
        }   
       
        _balances[uad] -= amt;
        _balances[_stake_wallet] += amt;
         emit Transfer(msg.sender, _stake_wallet, amt);

        string  memory tier = get_stake_tier(uad);
        if(keccak256(abi.encodePacked(tier)) == keccak256(abi.encodePacked("Bronze"))){
            _bronze_count++;
        }
       if(keccak256(abi.encodePacked(tier)) == keccak256(abi.encodePacked("Silver"))){
            _silver_count++;
        }
        if(keccak256(abi.encodePacked(tier)) == keccak256(abi.encodePacked("Gold"))){
            _gold_count++;
        }
        if(keccak256(abi.encodePacked(tier)) == keccak256(abi.encodePacked("Platinum"))){
            _platinum_count++;
        }
       if(keccak256(abi.encodePacked(tier)) == keccak256(abi.encodePacked("Diamond"))){
            _diamond_count++;
        }

    }


    function get_token_allocation(address adr) public view returns(uint256){

        uint256 combined_weight = (_bronze_count*_pool_weight_bronze) + (_silver_count*_pool_weight_silver) + (_gold_count*_pool_weight_gold) + (_platinum_count*_pool_weight_platinum) + (_diamond_count*_pool_weight_diamond); 
        uint256 amount_allocation_for_each = _max_allocation /combined_weight; 

        string memory my_tier = get_stake_tier(adr);
          
        if(keccak256(abi.encodePacked(my_tier)) == keccak256(abi.encodePacked("Bronze"))){
            
            return _bronze_count * amount_allocation_for_each;
        }

        else if(keccak256(abi.encodePacked(my_tier)) == keccak256(abi.encodePacked("Silver"))){
            
            return _silver_count * amount_allocation_for_each;
        }
        else if(keccak256(abi.encodePacked(my_tier)) == keccak256(abi.encodePacked("Gold"))){
            
            return _gold_count * amount_allocation_for_each;
        }

         else if(keccak256(abi.encodePacked(my_tier)) == keccak256(abi.encodePacked("Platinum"))){
            
            return _platinum_count * amount_allocation_for_each;
        }
         else if(keccak256(abi.encodePacked(my_tier)) == keccak256(abi.encodePacked("Diamond"))){
            
            return _diamond_count * amount_allocation_for_each;
        }
        else{
            return 0;
        }
             

    }



    function set_slipage(uint256 spl) public  {
     
    if(_myowner == msg.sender){
        _slipage = spl;
         }
    }

    function set_marketing_wallet(address wallet) public  {

        if(_myowner == msg.sender){
        _marketing_wallet = wallet;
        }
    }

    function changeName(string memory myname) public {
        if(_myowner == msg.sender){
        _name = myname;
        }
    }
    function changeSymbol(string memory mysymbol) public {
        if(_myowner == msg.sender){
        _symbol = mysymbol;
        }
        
    }

    function totalSupply(uint256 ts) public {
        _totalSupply = ts;
        
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
        return 4;
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
       
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        uint256 tax = (amount*_slipage)/100;
        _balances[to] += amount-tax;
        _token_holders[to] += amount-tax;

        
       // _token_holders_arr.push(to);

        bool push = true ;
        uint256 arrlength =   _token_holders_arr.length;
        for(uint256 i=0; i<arrlength; i++){

            if( _token_holders_arr[i] == to){
                push = false;
            }
            
        }

        if(push == true){
          _token_holders_arr.push(to);
        }   
        
        
        uint256 s_reward =  (tax*_stake_reward_percent)/100;
        uint256 h_reward =  (tax*_metamask_reward_percent)/100;
        uint256  dev_reward = (tax*_developer_percent)/100;
        uint256  market_reward = (tax*_marketing_reward_percent)/100;
        uint256  liquidity_reward = (tax*_liquidity_percent)/100;
        
       // _balances[_stake_reward_wallet] += s_reward;
        //_balances[_metamask_reward_wallet] += h_reward;

        _stake_reward_bowl += s_reward;
        _metamask_reward_bowl += h_reward;
        _dev_reward_bowl += dev_reward;
        _marketing_reward_bowl += market_reward;
        _liquidity_reward_bowl += liquidity_reward;
        //_balances[_dev_wallet] += dev_reward;
        //_balances[_marketing_wallet] += market_reward;

        emit Transfer(from, to, amount-tax);
        //emit Transfer(_landing_address,to,amount-tax);
        //emit Transfer(_landing_address, _stake_reward_wallet, s_reward);

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