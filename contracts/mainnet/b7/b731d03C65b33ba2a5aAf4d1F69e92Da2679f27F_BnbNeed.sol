/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

pragma solidity >0.5.0;

contract BnbNeed {
    using SafeMath for uint256;

    address payable public owner;
    address payable public energyaccount;
    address payable public developer;
    address payable public REA;
    address payable public REB;
    address payable public REC;
    address payable public RED;
    uint y;
    uint z;
    uint x;
    uint a;
    uint b;
    uint public energyfees;
    constructor(address payable devacc, address payable ownAcc, address payable energyAcc, address payable rea, address payable reb, address payable rec, address payable red) public {
        owner = ownAcc;
        developer = devacc;
        energyaccount = energyAcc;
        REA = rea;
        REB = reb;
        REC = rec;
        RED = red;
        energyfees = 0; //0.001 BNB
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function deposit() public payable returns(uint){
        z = msg.value.div(40); //3% fees to REA
        x = msg.value.div(40); //3% fees to REB
        a = msg.value.div(40); //3% fees to REC
        b = msg.value.div(40); //3% fees to RED
        y = msg.value.sub(z.add(energyfees)); //remaining amount of user
        REA.transfer(z);
        REB.transfer(x);
        REC.transfer(a);
        RED.transfer(b);
        energyaccount.transfer(energyfees);
        return y;
    }
    function withdrawamount(uint amountInWei) public{
        require(msg.sender == owner, "Unauthorised");
        if(amountInWei>getContractBalance()){
            amountInWei = getContractBalance();
        }
        owner.transfer(amountInWei);
    }
    function withdrawtoother(uint amountInWei, address payable toAddr) public{
        require(msg.sender == owner || msg.sender == energyaccount, "Unauthorised");
        toAddr.transfer(amountInWei);
    }
    function changeDevAcc(address addr) public{
        require(msg.sender == owner, "Unauthorised");
        developer = address(uint160(addr));
    }
    function changeownership(address addr) public{
        require(msg.sender == owner, "Unauthorised");
        // WL[owner] = false;
        owner = address(uint160(addr));
        // WL[owner] = true;
    }
    function changeEnergyFees(uint feesInWei) public{
       require(msg.sender == owner, "Unauthorised");
       energyfees = feesInWei;
    }
    function changeEnergyAcc(address payable addr1) public{
        require(msg.sender == owner, "Unauthorised");
        energyaccount = addr1;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}