/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// File: Game.sol


pragma solidity ^0.8.4;


contract Game {
    
    address[14][5] public tables;
   // address[14] table_2;
   // address[14] table_3;
   // address[14] table_4;
   // address[14] table_5;

   
    mapping (address => uint256 ) public my_table;
    mapping (address => bool ) public check_inGame;

    //mapping (uint256 => uint256) public count_users;

    function Check_Status() public view returns(string memory){
       if (M_Set_Number(tables) <= 8)
       return "Legion";
       else if (M_Set_Number(tables) > 8 && M_Set_Number(tables) < 12)
        return "Adviser";
       else if (M_Set_Number(tables) >= 12 && M_Set_Number(tables) < 14)
        return "Chancellor";
       else if (M_Set_Number(tables) == 14)
        return "Emperor";
        else
        return "error";
    }

    function Check_Number() public view returns(uint256){
        return M_Set_Number(tables);
    }

    function Check_Table() public view returns(uint256){
        return my_table[msg.sender];
    }

    function Check_Players(uint256 number_table) public view returns(uint256){
       return M_Free_Place(tables, number_table);
       
    }

    function TestPay() public payable{

    }

    function Rat() public view returns(address){
        return tables[0][1];
    }

    function Add_Player() public Set_InGame(){

        check_inGame[msg.sender] = true;
        
        if(tables[0][tables[0].length] != address(0) && tables[0][tables[0].length] != address(this)){
            my_table[tables[0][tables[0].length]]++;
            check_inGame[tables[0][tables[0].length]] = false;
        }
       

        for (uint i = 0; i < tables[0].length-1; i++){
            tables[0][i+1] = tables[0][i];
            
        }

        tables[0][0] = msg.sender;
        

       // tables[0][0] = address(0);


    }

    function Remove_Player() public {

    }

////////////////////////////ищет свободное место////////////////////////////////////////////
    function M_Free_Place(address[14][5] memory arr, uint256 num) public view returns (uint256){

        uint256 count;

        for (uint i = 0; i < arr[num].length; i++){
            if (arr[num][i] == address(0))
            count++;
        }

        return count;
    }
////////////////////////////ищет свободное место////////////////////////////////////////////


////////////////////////////присваивает порядковый номер////////////////////////////////////////////
    function M_Set_Number(address[14][5] memory arr) public view returns (uint256){

        for (uint i = 0; i < arr[my_table[msg.sender]].length; i++){
            if (arr[my_table[msg.sender]][i] == msg.sender){
                return i;
            }

        }
        revert("you are not in the game");

    }
////////////////////////////присваивает порядковый номер////////////////////////////////////////////

////////////////////////////проверка в игре игрок или нет////////////////////////////////////////////
     modifier Set_InGame(){
        require(check_inGame[msg.sender] == false, "You not in game");
        _;
    }
////////////////////////////проверка в игре игрок или нет////////////////////////////////////////////

}