/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract FuturVizonDefi {

    address private _owner;
    
    struct Investor{
        uint id;
        string date;
        string name;
        int256 investment;
        int256 investmentValue;
    }

    struct WeeklyProfit{
        uint weekNo;
        string date;
        int256 profit;
    }

    mapping(uint256 => Investor) private investors;

    mapping(uint256 => WeeklyProfit) private weeklyProfits;

    uint private totalInvestors;

    uint private totalWeeks;

    int256 private totalInvestment;

    int256 private totalNetProfit;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == _owner,"Caller is not Owner");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        _owner = _newOwner;
    }

    function getTotalNetProfit() public view returns(int256){
        return totalNetProfit;
    }  

    function getTotalInvestors() public view returns(uint){
        return totalInvestors;
    }

    function getTotalWeeks() public view returns(uint){
        return totalWeeks;
    }

    function getTotalInvestment() public view returns(int256){
        return totalInvestment;
    }
    function addInvestor(string memory _date, string memory _name, int256 _investment) public onlyOwner {
        totalInvestors++;
        investors[totalInvestors] = Investor(totalInvestors, _date, _name, _investment, _investment);
        totalInvestment += _investment;
    }

    function removeInvestor(uint id) external onlyOwner{
        totalInvestment -= investors[id].investmentValue;
        delete investors[id];
        totalInvestors--;
    }

    function reInvestment(uint id, int256 _amount) external onlyOwner {
        investors[id].investment += _amount;
        investors[id].investmentValue += _amount;
        totalInvestment += _amount;
    }

    function withdrawInvestment(uint id, int256 _amount) external onlyOwner{
        require(investors[id].investmentValue>=_amount,"Not Enough Investment to withdraw !");
        investors[id].investment -= _amount;
        investors[id].investmentValue -= _amount;
        totalInvestment -= _amount;
     }

    function withdrawAll(uint id) external onlyOwner{
        int _amount = investors[id].investmentValue;
        require(_amount>=0,"Already Withdrawn All Investment !");
        totalInvestment -= _amount;
        investors[id].investment = 0;
        investors[id].investmentValue = 0;
    }

    function getRewards(uint id) public view returns(int) {
        return (investors[id].investmentValue-investors[id].investment);
    }

    function claimRewards(uint id) external onlyOwner{
        int256 _rewards = getRewards(id);
        require(_rewards >= 0,"Not Enough Rewards to withdraw !");
        investors[id].investmentValue -= _rewards;
        totalInvestment -= _rewards;
        totalNetProfit -= _rewards;
    }    

    function updateWeeklyProfits(string memory _date, int256 _np) external onlyOwner{
        totalWeeks++;
        weeklyProfits[totalWeeks] = WeeklyProfit(totalWeeks, _date, _np);
        totalNetProfit += _np;                
        for(uint i=1; i<=totalInvestors; i++){
            investors[i].investmentValue += (_np*investors[i].investmentValue)/totalInvestment;    
        }
        totalInvestment += _np;
    }

    function getInvestorDetails(uint id)  public view returns(uint _id, string memory _date, string memory _name,int256 _investment,int256 _investmentValue,int256 _rewards) {
        _id = investors[id].id;
        _date = investors[id].date;
        _name = investors[id].name;
        _investment = investors[id].investment;
        _investmentValue = investors[id].investmentValue;
        _rewards = _investmentValue - _investment;
    }

    function getWeeklyProfitDetails(uint id)  public view returns(uint _weekNo, string memory _date,int256 _profit) {
        _weekNo = weeklyProfits[id].weekNo;
        _date = weeklyProfits[id].date;
        _profit = weeklyProfits[id].profit;
    }    
}