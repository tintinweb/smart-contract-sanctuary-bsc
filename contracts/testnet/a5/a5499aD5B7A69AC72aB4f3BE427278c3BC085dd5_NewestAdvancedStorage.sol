/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity ^0.5.0;

contract NewestAdvancedStorage {
           uint[] public ids;
           
           function add(uint id) public {
               ids.push(id);
           }

        

           function get(uint position) view public returns(uint) {
                            return ids[position];


           }

           function getall() view public returns(uint[] memory) {
               return ids;
           }

           function length() view public returns(uint) {
                       return ids.length;                    
           }
}