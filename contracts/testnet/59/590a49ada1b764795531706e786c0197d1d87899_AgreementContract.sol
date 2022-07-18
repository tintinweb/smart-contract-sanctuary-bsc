/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**To set up a new project, go to the projects directory that you created in Chapter 1 and make a new project using Cargo, like so:

￼                                                 

     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
 // if (employeeid == agreements[agreementID].employeesID[i]) {
                // employees[agreements[agreementID].employeesID[i]]
                //     .allocationToken = employees[
                //     agreements[agreementID].employeesID[i]
                // ].allocationToken.sub(amount);
                // }
                // token.transfer
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner,"Ownable: caller is not the owner");
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
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


contract AgreementContract is Ownable {
    
    using SafeMath for uint256;
    
    AggregatorV3Interface internal priceFeed;
    
    uint256 public milestonefee=500;  //5%
    uint256 public maxMilestoneFee=1000; //10%
    
    uint256 public escrowAmount;

    constructor() {
        // token = IERC20(Token);
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);  // Aggregator: BNB/USD
        owner = msg.sender;

    }
    function getLatestPrice() private view returns (int) {
        (
            , // uint80 roundID
            int price, 
            , // uint startedAt
            , // uint timeStamp
              // uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price / 10**8;
    }
    function bnbToUsd()public view returns(uint256){
        uint256 usdPrice = uint256(getLatestPrice());
        return usdPrice;
    }

    struct Agreement {
        string details;
        uint256 start_time;
        uint256 duration;
        uint256 price;
        uint256[] validatersID;
        uint256[] employeesID;
        uint256 employers;
        uint256[] milstones;
        bool validate;
        bool delivered;
        uint256 closed_time;
    }

    struct milestone {
        uint256 id;
        string description;
        uint256 Mile_Price;
        uint256 duration;
        uint256 submission_date;
        uint256 submission_time;
        bool delivered;
        uint256 empid;
        bool validate;
        bool Approve;
    }

    struct employer {
        uint256 id;
        string name;
        string email;
        uint256 phoneNo;
        uint256 allocationToken;
    }

    struct employee {
        uint256 id;
        string name;
        string email;
        uint256 phoneNo;
        bool approve;
        uint256 allocationToken;
    }

    struct validator {
        uint256 id;
        string name;
        string email;
        uint256 phoneNo;
        uint256 allocationToken;
    }

    enum Role {
        employee,
        employer,
        validator
    }

    mapping(uint256 => milestone) public milestones;
    mapping(uint256 => employer) public employers;
    mapping(uint256 => employee) public employees;
    mapping(uint256 => validator) public validators;
    mapping(uint256 => Agreement) public agreements;
    mapping(uint256 => bool)public transferToken;
    mapping(uint256 => bool)public cancelContract;
    mapping(uint256 => mapping(Role => bool)) public claim;
    // mapping(uint256=>bool)public claim;

    // event check(string);
    event registration(
        uint256 indexed id,
        string indexed name,
        string email,
        uint256 indexed phoneNo,
        Role role
    );

    event ContractCreation(
        uint256 indexed id,
        string details,
        uint256 employee,
        uint256 start_date,
        uint256 validater,
        uint256 empid
    );

    //** this function for Registration of different participants according //
    // ** to have Role like Validators,employee,employer //
    function Registration(
        uint256 id,
        string memory name,
        string memory email,
        uint256 phoneNo,
        Role role
    ) public onlyOwner {
        require(
            employers[id].id != id &&
                employees[id].id != id &&
                validators[id].id != id,
            "this id is aiready exist in participants"
        );
        if (role == Role.employee) {
            employee storage emp = employees[id];
            emp.id = id;
            emp.name = name;
            emp.email = email;
            emp.phoneNo = phoneNo;
            emit registration(id, name, email, phoneNo, role);
        } else if (role == Role.employer) {
            employer storage emplyr = employers[id];
            emplyr.id = id;
            emplyr.name = name;
            emplyr.email = email;
            emplyr.phoneNo = phoneNo;
            emit registration(id, name, email, phoneNo, role);
        } else if (role == Role.validator) {
            validator storage validtr = validators[id];
            validtr.id = id;
            validtr.name = name;
            validtr.email = email;
            validtr.phoneNo = phoneNo;
            emit registration(id, name, email, phoneNo, role);
        }
    }

    //** allocate token/Amount to participants
    function allocation(uint256 allocationtoken, uint256 empid)
        public
        onlyOwner
    {
        if (empid == employers[empid].id) {
            employers[empid].allocationToken = allocationtoken.div(bnbToUsd());
        } else if (empid == employees[empid].id) {
            employees[empid].allocationToken = allocationtoken.div(bnbToUsd());
        } else if (empid == validators[empid].id) {
            validators[empid].allocationToken = allocationtoken.div(bnbToUsd());
        }
    }

    //** this function is used to create agreement between employeee and employer **//

    function CreateContract(
        uint256 id,
        string memory details,
        uint256 _employee,
        uint256 start_date,
        uint256 validater,
        uint256 employerid,
        uint256 price
    ) public onlyOwner {
        escrowAmount=price.div(bnbToUsd());
        Agreement storage agreemnt = agreements[id];
        agreemnt.details = details;
        agreemnt.employeesID.push(_employee);
        agreemnt.start_time = start_date;
        agreemnt.price = price;
        agreemnt.validatersID.push(validater);
        agreemnt.employers = employerid;
        emit ContractCreation(
            id,
            details,
            _employee,
            start_date,
            validater,
            employerid
        );
        
    }

    // creation of milestones through Admin:-
    // contract Id:- no of milestones [description,Amount,milestoneduration,assigneto]
    // one to many()
    // validation :- no of count of milestone is equal to description,.....all fields
    // amount of price of aggreement == count of milestone of amount
    // total duration agreement == duration of milestone
    // id is exist in array of employees

    function CreateMilestone(
        string[] memory description,
        uint256[] calldata Mile_Price,
        uint256[] calldata duration,
        uint256[] calldata emp,
        uint256 agreementID
    ) public onlyOwner {
        // uint256 totalMile_duration;
        uint256 totalMile_Price;
        require(cancelContract[agreementID]!=true,"Agrement cancelled");
        for (uint256 i = 1; i < description.length; i++) {
            // require(milestones[i].id!=mileid[i],"milestone must be unique");
            milestones[i].id = i;
            milestones[i].Mile_Price = Mile_Price[i];
            milestones[i].description = description[i];
            milestones[i].duration = duration[i];
            milestones[i].empid = emp[i];
            agreements[agreementID].milstones.push(i);
            totalMile_Price = totalMile_Price.add(Mile_Price[i]);

            // totalMile_duration=totalMile_duration.add(duration[i]);
        }
        require(
            agreements[agreementID].price == totalMile_Price,
            "milestone price is same as aggrement price"
        );
    }

    function Approve(
        uint256 empid,
        bool status,
        uint256 agreementID
    ) public payable {
        // escrowAmount=agreements[agreementID].price.div(bnbToUsd());
        require(msg.value==escrowAmount,"Amount not correct");
        for (
            uint256 i = 0;
            i < agreements[agreementID].employeesID.length;
            i++
        ) {
            if (agreements[agreementID].employeesID[i] == empid) {
                employees[agreements[agreementID].employeesID[i]]
                    .approve = status;
            }
        }
        payable(address(this)).transfer(msg.value);
    }

    // Used to delivered to milestone and track it with use this parameters:-
    // employee-id,contract-id ,milestone-index,submission date,submission-time,filehash}

    function milestoneDelevered(
        uint256 milesid,
        uint256 agreementID,
        uint256 submissionTime,
        // uint256 submissionDate,
        uint256 employeeId
    ) public {
        // milestone storage mile= milestones[milesid];
        // require(mile.id==milesid,"MilesID not exist");
        require(cancelContract[agreementID]!=true,"Agreement cancelled");
        require(milestones[milesid].Approve != true,"Milestone already accepted");

        for (uint256 i = 0; i < agreements[agreementID].milstones.length; i++) {
            if (milesid == agreements[agreementID].milstones[i]) {
                milestones[milesid].delivered = true;
                milestones[milesid].submission_time = submissionTime;
                // milestones[milesid].submission_date = submissionDate;
                milestones[milesid].empid = employeeId;
            }
        }
    }

    // Used to delivered to milestone and track it with use this parameters:-
    // employee-id,contract-id ,milestone-index,submission date,submission-time,filehash}

    function milestoneApproved(
        uint256 milesid,
        bool status,
        uint256 agreementID,
        address receiver
    ) public onlyOwner {
        require(cancelContract[agreementID]!=true,"Agreement cancelled");
        require(milestones[milesid].Approve != true,"Milestone already accepted");
        require(milestones[milesid].delivered == true, "it must be delivered");
        require(milestones[milesid].validate == true, "it must be validate");

        for (uint256 i = 0; i < agreements[agreementID].milstones.length; i++) {
            if (milesid == agreements[agreementID].milstones[i]) {
                milestones[milesid].Approve = status;
                uint fee = milestones[i].Mile_Price.mul(milestonefee).div(10000);
                payable(owner).transfer(fee);
                payable(receiver).transfer(milestones[i].Mile_Price.sub(fee));
            }
        }

        // require(milestones[milesid].Approve == true,"Check your Approval status");              
    }

    function allocationtoEmployee(uint256 milesid,uint256 agreementID)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < agreements[agreementID].milstones.length; i++) {
            if (
                milesid == agreements[agreementID].milstones[i] &&
                milestones[milesid].Approve == true
            ) {
                if (
                    milestones[i].Mile_Price <=
                    employers[agreements[agreementID].employers].allocationToken
                ) {
                    employees[milestones[milesid].empid]
                        .allocationToken = milestones[i].Mile_Price;
                    employers[agreements[agreementID].employers]
                        .allocationToken = employers[
                        agreements[agreementID].employers
                    ].allocationToken.sub(milestones[i].Mile_Price);
                }
            }
        }
    }
    // Used to validate contact(with respect to contract id) by validator(validator id).
    // function ValidateContract(uint256 validaterid,uint256 agreementID) public {
    //     for (
    //         uint256 i = 0;
    //         i < agreements[agreementID].validatersID.length;
    //         i++
    //     ) {
    //         if (validaterid == agreements[agreementID].validatersID[i]) {
    //             agreements[agreementID].validate = true;
    //         }
    //     }
    // }

    //Validate-milestone:- Used to validate milestone(with respect to milestone id) by validator(validator id).
    function ValidateMilestone(
        uint256 validaterid,
        uint256 agreementID,
        uint256 milestoneID
    ) public {
        require(cancelContract[agreementID] !=true,"Agreement cancelled");
        require(milestones[milestoneID].delivered == true, "it must be delivered");
        require(milestones[milestoneID].Approve != true,"Milestone already accepted");

        for (
            uint256 i = 0;
            i < agreements[agreementID].validatersID.length;
            i++
        ) {
            if (validaterid == agreements[agreementID].validatersID[i]) {
                milestones[milestoneID].validate = true;
            }
        }
    }

    // End contract id:-
    // Used to end contract-id with this parameter{time stamp,employer id , contract id].
    function endOfcontract(uint256 agreementID) public onlyOwner {
        agreements[agreementID].delivered = true;
        agreements[agreementID].closed_time = block.timestamp;
    }

    function cancelcontract(uint256 agreementID) public onlyOwner {
        cancelContract[agreementID] = true;
    }

     function redeem(
        uint256 amount,
        uint256 milesid,
        uint256 employeeid,
        uint256 agreementID,
        address receiver
    ) public onlyOwner {
        //  Agreement storage agreemnt = agreements[agreementID];
        require(amount==escrowAmount,"Amount is same as escrowAmount");
        require(milestones[milesid].delivered ==true,"Milestone is not delivered");
        require(milestones[milesid].validate == true,"it must be validate");
        // uint256 _amount=amount.div(usdPrice);

        for (
            uint256 i = 0;
            i < agreements[agreementID].employeesID.length;
            i++
        ) {
            if (employeeid == agreements[agreementID].employeesID[i]) {
                employees[agreements[agreementID].employeesID[i]]
                    .allocationToken = employees[
                    agreements[agreementID].employeesID[i]
                ].allocationToken.sub(amount);
            }
        }
        uint fee=amount.mul(milestonefee).div(10000);
        payable(owner).transfer(fee);
        payable(receiver).transfer(amount.sub(fee));
        transferToken[agreementID]=true;
    }

    function raiseDispute(uint256 milesid,uint256 agreementID,Role role) public {
        require(transferToken[agreementID] != true,"Payment already transfered"); 
        require(milestones[milesid].validate == true,"it must be validate");
        if (role == Role.employee) {
            require(milestones[milesid].delivered == true,"Milestone is not delivered");
            require(milestones[milesid].Approve == true,"Check your Approval status");
            claim[agreementID][role]=true;

           
        } else if (role == Role.employer) {
            require(milestones[milesid].Approve == true,"Check your Approval status");
            claim[agreementID][role]=true;

            
        } else {
            revert("Invalid Role");
            
            
        }

        
    }

    function disputeResolve(uint256 agreementID,uint256 employeeid,Role role,address receiver) public onlyOwner{
        require(claim[agreementID][role] == true,"No dispute raised");
        for (
             uint256 i = 0;
            i < agreements[agreementID].employeesID.length;
            i++
        ) {
            if (employeeid == agreements[agreementID].employeesID[i]) {
                employees[agreements[agreementID].employeesID[i]]
                    .allocationToken = employees[
                    agreements[agreementID].employeesID[i]
                ].allocationToken.sub(escrowAmount);
            }
        }
        uint fee= escrowAmount.mul(milestonefee).div(10000);
        payable(owner).transfer(fee);
        payable(receiver).transfer(escrowAmount.sub(fee));
    }

    function setMilestoneFee(uint fee) public onlyOwner {
        require(fee <= maxMilestoneFee,"Fee is greater than Maxmilestone Fee");
        milestonefee=fee;
    }

    function contractEthbalance()public view returns(uint256){
        return address(this).balance;
    }
    
    function withdraw()public onlyOwner{
        payable(owner).transfer(address(this).balance);  
    } 
    
                                                            
}