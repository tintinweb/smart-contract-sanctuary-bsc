/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Payroll {
    address public companyAcc;
    uint256 public companyBal;
    uint256 public totalWorkers = 0;
    uint256 public totalSalary = 0;
    uint256 public totalPayment = 0;

    mapping(address => bool) isWorker;

    event Paid(
        uint256 id,
        address from,
        uint256 totalSalary,
        uint256 timestamp
    );

    struct PaymentStruct {
        uint256 id;
        address worker;
        uint256 salary;
        uint256 timestamp;
    }

    PaymentStruct[] employees;

    modifier ownerOnly(){
        require(msg.sender == companyAcc, "Owner reserved only");
        _;
    }

    constructor() {
        companyAcc = msg.sender;
    }

    function addWorker(
        address worker,
        uint256 salary
    ) external ownerOnly returns (bool) {
        require(salary > 0 ether, "Salary cannot be zero!");
        require(!isWorker[worker], "Record already existing!");

        totalWorkers++;
        totalSalary += salary;
        isWorker[worker] = true;

        employees.push(
            PaymentStruct(
                totalWorkers,
                worker,
                salary,
                block.timestamp
            )
        );
        
        return true;
    }

    function payWorkers() payable external ownerOnly returns (bool) {
        require(msg.value >= totalSalary, "Ethers too small");
        require(totalSalary <= companyBal, "Insufficient balance");

        for(uint i = 0; i < employees.length; i++) {
            payTo(employees[i].worker, employees[i].salary);
        }

        totalPayment++;
        companyBal -= msg.value;

        emit Paid(
            totalPayment,
            companyAcc,
            totalSalary,
            block.timestamp
        );

        return true;
    }

    function fundCompanyAcc() payable external returns (bool) {
        require(companyAcc != msg.sender, "You can't fund yourself!");
        payTo(companyAcc, msg.value);
        companyBal += msg.value;
        return true;
    }

    function getWorkers() external view returns (PaymentStruct[] memory) {
        return employees;
    }

    function payTo(
        address to, 
        uint256 amount
    ) internal returns (bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }
}