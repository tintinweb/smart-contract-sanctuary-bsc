/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// Solidity program 
// to store 
// Employee Details
pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
  
// Creating a Smart Contract
contract StructDemo{
  
   // Structure of employee
   struct PaymentGo{
       
       // State variables
       address accID;
       uint amount;
   }

   struct TotalPayment{
       address accID;
       uint totalAmount;
   }
   
   PaymentGo []emps;
   TotalPayment []balanceAll;
  
   // Function to add 
   // employee details
   function addEmployee(
     address accID, 
     uint amount
   ) public{
       PaymentGo memory d
         =PaymentGo(accID,
                   amount);
        if(emps.length > 0)
        {
            uint i;
            for(i=0;i<emps.length;i++)
            {
            PaymentGo memory e
             =emps[i];
           
           // Looks for a matching 
           // employee id
           if(e.accID==accID)
           {
                emps[i].amount += d.amount;
           } else {
                emps.push(d);
           }
            }
        } else {
            emps.push(d);
        }
       
   }

//    function addBalance(
//        address accID,
//        uint totalAmount
//    ) private {
//        for(i=0;i<emps.length;i++)
//        {
//            PaymentGo memory e
//              =emps[i];
           
//            // Looks for a matching 
//            // employee id
//            if(e.accID==accID)
//            {
//                 TotalPayment memory e
//                     =
//            }
//        }
//    }
  
  // Function to get
  // details of employee
   function getPayment(
     address accID
   ) public view returns(
     uint){
       uint i;
       for(i=0;i<emps.length;i++)
       {
           PaymentGo memory e
             =emps[i];
           
           // Looks for a matching 
           // employee id
           if(e.accID==accID)
           {
                  return(e.amount);
           }
       }
       
     // If provided employee 
     // id is not present
     // it returns Not 
     // Found
     return(0);
   }
}