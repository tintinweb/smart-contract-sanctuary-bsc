/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDhanu {
    function decimals() external pure returns(uint8);
    function mint(address _to, uint256 _value) external returns (bool success); 
    function transfer(address _to, uint256 _value)external returns(bool); 
}

contract DhanuVesting{
    address public constant dhanuAddress = 0x2971BE951341304E225D285518533131Ba28CC89;
    IDhanu dhanu = IDhanu(dhanuAddress);
    uint256 decimalFactor = 10**uint256(dhanu.decimals());
    address public owner;
    uint256 public contractDeployedTime;
    string[] public vestingTypes = ["Team", "Community", "Eco_System", "Liquidity", "Investor", "Infrastructure", "Airdrop", "Reserved"];
    struct VestingDetails{
        string vestingType;
        uint256 startTime;
        uint256 lockTime;
        uint256 endTime;
        uint256 totalAllocationAmount;
        uint256 mintedAmount;
        uint256 withdrawableAmountInContract;
        uint256 transferedAmount;
        address[] assignedAddresses;
    }
    mapping(string=>VestingDetails) internal vestingtTypesToDetails;
    uint256 public totalBalanceOfContract;
    bool public initialMintingForInvestorAndAirdropExecuted = false;

    event mintToken(string indexed vestingType, uint256 mintAmount, uint256 mintTime);
    event transferToken(string indexed vestingType, address indexed assignedAddress, uint256 transferAmount, uint256 transferTime);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Of The Contract Can Call this Function!");
        _;
    }
    modifier validAddress(address inputAddress){
        require(inputAddress != address(0), "Input address is not a valid address!");
        _;
    }
    modifier validIndex(uint256 index){
        require(index >=0 && index <=7, "Invalid Index!");
        _;
    }

    constructor(){
        owner = msg.sender;
        contractDeployedTime = block.timestamp;

        vestingtTypesToDetails[vestingTypes[0]] = VestingDetails(vestingTypes[0], block.timestamp, block.timestamp + 365 days, block.timestamp + 1460 days, 77_000_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[0]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[1]] = VestingDetails(vestingTypes[1], block.timestamp, block.timestamp, block.timestamp, 148_500_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[1]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[2]] = VestingDetails(vestingTypes[2], block.timestamp, block.timestamp + 180 days, block.timestamp + 180 days, 50_000_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[2]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[3]] = VestingDetails(vestingTypes[3], block.timestamp, block.timestamp + 90 days, block.timestamp + 360 days, 41_000_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[3]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[4]] = VestingDetails(vestingTypes[4], block.timestamp, block.timestamp, block.timestamp, 54_400_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[4]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[5]] = VestingDetails(vestingTypes[5], block.timestamp, block.timestamp, block.timestamp, 23_000_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[5]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[6]] = VestingDetails(vestingTypes[6], block.timestamp, block.timestamp + 365 days, block.timestamp + 365 days, 7_350_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[6]].assignedAddresses);
        vestingtTypesToDetails[vestingTypes[7]] = VestingDetails(vestingTypes[7], block.timestamp, block.timestamp, block.timestamp, 23_000_000 * decimalFactor, 0, 0, 0, vestingtTypesToDetails[vestingTypes[7]].assignedAddresses);  
    }

    function addVestingAddress(uint256 indexOfVestingType, address assignedAddress) public onlyOwner validAddress(assignedAddress) validIndex(indexOfVestingType){
        bool isValidAddress = true;
        for(uint i=0; i<vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.length; i++){
            if(assignedAddress==vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[i]){
                isValidAddress = false;
                break;
            }
        }

        require(isValidAddress==true, "Can't add address! address already exist.");

        vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.push(assignedAddress);
    }
    function removeTeamAddress(uint256 indexOfVestingType, address assignedAddress) public onlyOwner validAddress(assignedAddress) validIndex(indexOfVestingType){
        uint index;
        bool isValidAddress = false;
        for(uint i=0; i<vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.length; i++){
            if(assignedAddress==vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[i]){
                index = i;
                isValidAddress = true;
                break;
            }
        }

        require(isValidAddress==true, "Can't remove address! address dons't exist.");

        delete(vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[index]);
        vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[index] = vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.length-1];
        vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.pop();
    }
    function mintForInvestorAndAirDrop() public onlyOwner{
        require(initialMintingForInvestorAndAirdropExecuted == false, "Can't Mint! Already Minted.");
        //mint 20 % out of 68M for Investors
        uint256 mintAmount_investor = 13_600_000 * decimalFactor;
        dhanu.mint(address(this), mintAmount_investor);
        vestingtTypesToDetails[vestingTypes[4]].mintedAmount = vestingtTypesToDetails[vestingTypes[4]].mintedAmount + mintAmount_investor;
        vestingtTypesToDetails[vestingTypes[4]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[4]].withdrawableAmountInContract + mintAmount_investor;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount_investor;
        
        emit mintToken(vestingTypes[4], mintAmount_investor, block.timestamp);

        // //mint 30% out of 10.5M for Airdrop
        uint256 mintAmount_airdrop = 3_150_000 * decimalFactor;
        dhanu.mint(address(this), mintAmount_airdrop);
        vestingtTypesToDetails[vestingTypes[6]].mintedAmount = vestingtTypesToDetails[vestingTypes[6]].mintedAmount + mintAmount_airdrop;
        vestingtTypesToDetails[vestingTypes[6]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[6]].withdrawableAmountInContract + mintAmount_airdrop;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount_airdrop;
        
        emit mintToken(vestingTypes[6], mintAmount_airdrop, block.timestamp);

        initialMintingForInvestorAndAirdropExecuted = true;
    }
    function viewVestingTypes(uint256 index) public view  returns(VestingDetails memory){
        return vestingtTypesToDetails[vestingTypes[index]];
    }
    function viewAssignedAddressesOfVestingType(uint256 index) public view returns(address[] memory){
        return vestingtTypesToDetails[vestingTypes[index]].assignedAddresses;
    }
    function viewBalanceOfVestingType(uint256 index) public view returns(uint256){
        return vestingtTypesToDetails[vestingTypes[index]].withdrawableAmountInContract;
    }
    function checkMintableTeamFund() public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 startTime = vestingtTypesToDetails[vestingTypes[0]].startTime;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[0]].lockTime;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[0]].endTime;

        if(currentTime < lockTime){
            return 0;
        }else if(currentTime >= endTime){
            return (vestingtTypesToDetails[vestingTypes[0]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[0]].mintedAmount);
        }else{
            uint256 percentageAllowed = ((currentTime - startTime) / 365 days) * 25;
            uint256 amountAllowed = (percentageAllowed * vestingtTypesToDetails[vestingTypes[0]].totalAllocationAmount) / 100;
            return (amountAllowed - vestingtTypesToDetails[vestingTypes[0]].mintedAmount);
        }
    }
     function checkMintableCommunityFund() public view returns(uint256){
        return (vestingtTypesToDetails[vestingTypes[1]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[1]].mintedAmount);
    }
    function checkMintableEcoSystemFund() public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[2]].endTime;

        if(currentTime >= endTime){
            return (vestingtTypesToDetails[vestingTypes[2]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[2]].mintedAmount);
        }else{
            return 0;
        }
    }
    function checkMintableLiquidityFund() public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 startTime = vestingtTypesToDetails[vestingTypes[3]].startTime;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[3]].lockTime;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[3]].endTime;

        if(currentTime < lockTime){
            return 0;
        }else if(currentTime >= endTime){
            return (vestingtTypesToDetails[vestingTypes[3]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[3]].mintedAmount);
        }else{
            uint256 percentageAllowed = ((currentTime - startTime) / 90 days) * 25;
            uint256 amountAllowed = (percentageAllowed * vestingtTypesToDetails[vestingTypes[3]].totalAllocationAmount) / 100;
            return (amountAllowed - vestingtTypesToDetails[vestingTypes[3]].mintedAmount);
        }
    }
    function checkMintableInvestorFund() public view returns(uint256){
        return (vestingtTypesToDetails[vestingTypes[4]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[4]].mintedAmount);
    }
    function checkMintableInfrastructureFund() public view returns(uint256){
        return (vestingtTypesToDetails[vestingTypes[5]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[5]].mintedAmount);   
    }
    function checkMintableAirdropFund() public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[6]].endTime;
         if(currentTime >= endTime){
            return (vestingtTypesToDetails[vestingTypes[6]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[6]].mintedAmount);
        }else{
            return 0;
        }
    }
    function checkMintableReservedFund() public view returns(uint256){
        return (vestingtTypesToDetails[vestingTypes[7]].totalAllocationAmount - vestingtTypesToDetails[vestingTypes[7]].mintedAmount);
    }
    function mintTeamFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[0]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[0]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");
        
        uint256 currentTime = block.timestamp;
        uint256 startTime = vestingtTypesToDetails[vestingTypes[0]].startTime;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[0]].lockTime;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[0]].endTime;

        require(currentTime > lockTime, "Can't withdraw! funds are still locked, please wait for lock time to finish.");
        
        if(currentTime >= endTime){
            dhanu.mint(address(this), mintAmount);
            vestingtTypesToDetails[vestingTypes[0]].mintedAmount = vestingtTypesToDetails[vestingTypes[0]].mintedAmount + mintAmount;
            vestingtTypesToDetails[vestingTypes[0]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[0]].withdrawableAmountInContract + mintAmount;
            totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
            emit mintToken(vestingTypes[0], mintAmount, block.timestamp);

        }else{
            //(current - start) / time_gap
            uint256 percentageAllowed = ((currentTime - startTime) / 365 days) * 25;
            uint256 amountAllowed = (percentageAllowed * vestingtTypesToDetails[vestingTypes[0]].totalAllocationAmount) / 100;
           
            require(mintAmount <= amountAllowed, "Can't withdraw! withdrawl amount exceeds the allocated amount according to time.");
           
            dhanu.mint(address(this), mintAmount);
            vestingtTypesToDetails[vestingTypes[0]].mintedAmount = vestingtTypesToDetails[vestingTypes[0]].mintedAmount + mintAmount;
            vestingtTypesToDetails[vestingTypes[0]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[0]].withdrawableAmountInContract + mintAmount;
            totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
            emit mintToken(vestingTypes[0], mintAmount, block.timestamp);
        }
        return true;
    }
    function mintCommunityFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[1]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[1]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");

        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[1]].mintedAmount = vestingtTypesToDetails[vestingTypes[1]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[1]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[1]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[1], mintAmount, block.timestamp);

        return true;
    }
    function mintEcoSystemFund(uint256 mintAmount) public onlyOwner returns(bool){       
        require(vestingtTypesToDetails[vestingTypes[2]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[2]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");

        uint256 currentTime = block.timestamp;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[2]].lockTime;

        require(currentTime > lockTime, "Can't withdraw! funds are still locked, please wait for lock time to finish.");

        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[2]].mintedAmount = vestingtTypesToDetails[vestingTypes[2]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[2]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[2]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[2], mintAmount, block.timestamp);

        return true;
    }
    function mintLiquidityFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[3]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[3]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");
        
        uint256 currentTime = block.timestamp;
        uint256 startTime = vestingtTypesToDetails[vestingTypes[3]].startTime;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[3]].lockTime;
        uint256 endTime = vestingtTypesToDetails[vestingTypes[3]].endTime;

        require(currentTime > lockTime, "Can't withdraw! funds are still locked, please wait for lock time to finish.");
        
        if(currentTime >= endTime){
            dhanu.mint(address(this), mintAmount);
            vestingtTypesToDetails[vestingTypes[3]].mintedAmount = vestingtTypesToDetails[vestingTypes[3]].mintedAmount + mintAmount;
            vestingtTypesToDetails[vestingTypes[3]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[3]].withdrawableAmountInContract + mintAmount;
            totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
            emit mintToken(vestingTypes[3], mintAmount, block.timestamp);
        }else{
            uint256 percentageAllowed = ((currentTime - startTime) / 90 days) * 25;
            uint256 amountAllowed = (percentageAllowed * vestingtTypesToDetails[vestingTypes[3]].totalAllocationAmount) / 100;
            
            require(mintAmount <= amountAllowed, "Can't withdraw ! withdrawl amount exceeds the allocated amount according to time.");
            
            dhanu.mint(address(this), mintAmount);
            vestingtTypesToDetails[vestingTypes[3]].mintedAmount = vestingtTypesToDetails[vestingTypes[3]].mintedAmount + mintAmount;
            vestingtTypesToDetails[vestingTypes[3]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[3]].withdrawableAmountInContract + mintAmount;
            totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
            emit mintToken(vestingTypes[3], mintAmount, block.timestamp);
        }
        return true;
    }
    function mintInvestorFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[4]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[4]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");
        
        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[4]].mintedAmount = vestingtTypesToDetails[vestingTypes[4]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[4]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[4]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[4], mintAmount, block.timestamp);

        return true;
    }
    function mintInfrastructureFund() public onlyOwner returns(bool){
        uint256 mintAmount = 2_300_000 * decimalFactor;
        
        require(vestingtTypesToDetails[vestingTypes[5]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[5]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");

        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[5]].mintedAmount = vestingtTypesToDetails[vestingTypes[5]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[5]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[5]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[5], mintAmount, block.timestamp);

        return true;
    }
    function mintAirdropFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[6]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[6]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");

        uint256 currentTime = block.timestamp;
        uint256 lockTime = vestingtTypesToDetails[vestingTypes[6]].lockTime;

        require(currentTime > lockTime, "Can't withdraw! funds are still locked, please wait for lock time to finish.");

        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[6]].mintedAmount = vestingtTypesToDetails[vestingTypes[6]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[6]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[6]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[6], mintAmount, block.timestamp);

        return true;
    }
    function mintReservedFund(uint256 mintAmount) public onlyOwner returns(bool){
        require(vestingtTypesToDetails[vestingTypes[7]].totalAllocationAmount >= (vestingtTypesToDetails[vestingTypes[7]].mintedAmount + mintAmount), "Can't Withdraw! withdrawl amount exceeds the allocated amount.");

        dhanu.mint(address(this), mintAmount);
        vestingtTypesToDetails[vestingTypes[7]].mintedAmount = vestingtTypesToDetails[vestingTypes[7]].mintedAmount + mintAmount;
        vestingtTypesToDetails[vestingTypes[7]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[7]].withdrawableAmountInContract + mintAmount;
        totalBalanceOfContract = totalBalanceOfContract + mintAmount;
        
        emit mintToken(vestingTypes[7], mintAmount, block.timestamp);

        return true;
    }

    function transferFundsToAddress(uint256 indexOfVestingType, address assignedAddress, uint256 amount) public onlyOwner validAddress(assignedAddress) validIndex(indexOfVestingType) returns(bool){
        require(amount <= vestingtTypesToDetails[vestingTypes[indexOfVestingType]].withdrawableAmountInContract, "Can't Transfer! transfer amount is greater than team's current total fund.");

        bool isValidAddress = false;
        for(uint i=0; i<vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses.length; i++){
            if(assignedAddress==vestingtTypesToDetails[vestingTypes[indexOfVestingType]].assignedAddresses[i]){ 
                isValidAddress = true;
                break;
            }
        }

        require(isValidAddress==true, "Can't Transfer! address dons't exist.");

        dhanu.transfer(assignedAddress, amount);
        vestingtTypesToDetails[vestingTypes[indexOfVestingType]].withdrawableAmountInContract = vestingtTypesToDetails[vestingTypes[indexOfVestingType]].withdrawableAmountInContract - amount;
        vestingtTypesToDetails[vestingTypes[indexOfVestingType]].transferedAmount = vestingtTypesToDetails[vestingTypes[indexOfVestingType]].transferedAmount + amount;
        totalBalanceOfContract = totalBalanceOfContract - amount;

        emit transferToken(vestingTypes[indexOfVestingType], assignedAddress, amount, block.timestamp);
        return true;
    }
}