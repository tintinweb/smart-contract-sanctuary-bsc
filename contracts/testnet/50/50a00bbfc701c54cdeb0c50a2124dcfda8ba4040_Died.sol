/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
contract Died {
    event NEWPERSON(uint ID,string new_NAME);
    string public Name;
    uint public Age;
    uint age_amount=2;
    uint age_new_amount=10**age_amount;
    
    struct  People{
       string  Name;
        uint   Age ;
    }
    constructor(){
        Name="noune";
        Age=0;
    }

    People[] public _people;

    function Data(uint age)private view returns(uint){
        uint new_age=uint(keccak256(abi.encodePacked(age)));
        return new_age % age_new_amount;
    }
    function set_Data (string memory name_db,uint age_db)private{
        _people.push(People(name_db,age_db));
    }
    function Input(string memory new_Name,uint new_Age)public  returns(People[] memory){
        Name = new_Name;
        Age  = Data(new_Age);
        set_Data(Name,Age);
        uint ID=_people.length -1;
        emit NEWPERSON(ID,Name);
        return _people;
    }
}