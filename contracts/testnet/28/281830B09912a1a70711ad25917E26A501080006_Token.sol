/**
 *Submitted for verification at BscScan.com on 2021-12-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /*function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owner) external view returns (uint);
    function DOMAIN_SEPARATOR() external view returns (bytes32);*/
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Token is IERC20{

    struct Stake{
        address account;
        uint256 amount;
    }

    uint256 [3] public privateSaleTotalTokens;//total private sale tokens for each
    uint256 [3] public privateSaleEnd;//dstribution time and distribution flag != 0
    Stake [] [3] public privateSaleList;//editable to determine distribution
    mapping(address=>uint256) [3] public privateSaleBalance;//amount of private sale current lockup balance after distribution
    uint256 [3] public privateSaleToDistribute;//tokens undistrbuted
    uint8 public completedSales;

    uint256 public totalTeamTokens = 2800000000;//max team tokens
    Stake [] public teamList;//editable to determine distribution
    uint256 public teamVestingStart;//furthest private sale end date
    mapping(address=>uint256) public teamTokenBalance;//amount from distribution
    uint256 public teamToDistribute;//tokens undistrbuted
    bool public canWithdraw;//withdraw extra tokens not sold or sent to team


    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public override immutable totalSupply;
    mapping(address=>uint256) public override balanceOf;
    mapping(address=>mapping(address=>uint256)) public override allowance;
    address private owner;

    modifier unFinalized(uint8 saleIndex){
        require(privateSaleEnd[saleIndex]==0,"already distributed");
        _;
    }
    modifier finalized(uint8 saleIndex){
        require(privateSaleEnd[saleIndex]!=0,"not distributed");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"not owner");
        _;
    }

    constructor(){
        uint8 _decimals = 9;
        owner = msg.sender;
        uint256 _totalSupply = 10000000000*10**_decimals;
        (name,symbol,decimals,totalSupply) = ("MyToken","MT",_decimals,_totalSupply);
        balanceOf[address(0)] = 3800000000 *10**_decimals;
        balanceOf[msg.sender]= 6200000000*10**_decimals;
        privateSaleTotalTokens[0] = 250000000*10**_decimals;
        privateSaleTotalTokens[1] = 350000000*10**_decimals;
        privateSaleTotalTokens[2] = 400000000*10**_decimals;
    }
    function _transfer(address sender, address recipient, uint256 amount) private{
        require(spendableBalance(sender)>=amount,"insuffficient unlocked balance");
        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender,recipient,amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(allowance[sender][msg.sender]>=amount,"Not Approved");
        allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function clearPrivateSale(uint8 saleIndex)unFinalized(saleIndex) onlyOwner external{
        delete privateSaleList[saleIndex];
        privateSaleToDistribute[saleIndex]=0;
    }
    function addToPrivateSale(uint8 saleIndex, address buyer,uint256 amount)unFinalized(saleIndex) onlyOwner external{
        amount = amount *10**decimals;
        require(privateSaleToDistribute[saleIndex]+amount<=privateSaleTotalTokens[saleIndex]);
        privateSaleList[saleIndex].push(Stake(buyer,amount));
        privateSaleToDistribute[saleIndex] = privateSaleToDistribute[saleIndex].add(amount);
    }
    function addMultipleToPrivateSale(uint8 saleIndex, address[] memory buyers,uint256 [] memory amounts)unFinalized(saleIndex) onlyOwner external{
        for(uint256 i=0;i<buyers.length;i++){
            amounts[i] = amounts[i] *10**decimals;
            require(privateSaleToDistribute[saleIndex]+amounts[i]<=privateSaleTotalTokens[saleIndex]);
            privateSaleList[saleIndex].push(Stake(buyers[i],amounts[i]));
            privateSaleToDistribute[saleIndex] = privateSaleToDistribute[saleIndex].add(amounts[i]);
        }
    }
    function clearTeam()unFinalized(2) onlyOwner external{
        delete teamList;
        teamToDistribute = 0;
    }
    function addToTeam(address member,uint256 amount)unFinalized(2) onlyOwner external{
        amount = amount *10**decimals;
        require(teamToDistribute+amount<=totalTeamTokens);
        teamList.push(Stake(member,amount));
        teamToDistribute = teamToDistribute.add(amount);
    }

    function addMultipleToTeam(address[] memory members,uint256[] memory amounts)unFinalized(2) onlyOwner external{
        for(uint256 i=0;i<members.length;i++){
            amounts[i] = amounts[i] *10**decimals;
            require(teamToDistribute+amounts[i]<=totalTeamTokens);
            teamList.push(Stake(members[i],amounts[i]));
            teamToDistribute = teamToDistribute.add(amounts[i]);
        }
    }
    function distributePrivateSale(uint8 saleIndex)unFinalized(saleIndex) onlyOwner external{
        require(block.timestamp!=0);//unlikely edge case
        for(uint256 i=0;i<privateSaleList[saleIndex].length;i++){
            _transfer(address(0),privateSaleList[saleIndex][i].account,privateSaleList[saleIndex][i].amount);
            privateSaleBalance[saleIndex][privateSaleList[saleIndex][i].account] = privateSaleBalance[saleIndex][privateSaleList[saleIndex][i].account].add(privateSaleList[saleIndex][i].amount);
        }
        completedSales++;
        privateSaleEnd[saleIndex] = block.timestamp;
        if(completedSales==3){
            for(uint256 i=0;i<teamList.length;i++){
                _transfer(address(0),teamList[i].account,teamList[i].amount);
                teamTokenBalance[teamList[i].account] = teamTokenBalance[teamList[i].account].add(teamList[i].amount);
            }
            teamVestingStart = block.timestamp;
            canWithdraw=true;
        }
    }
    function spendableBalance(address account) public view returns(uint256) {
        uint256 lockedTokens;
        for(uint8 i=0;i<privateSaleEnd.length;i++){
            lockedTokens = lockedTokens.add(lockedBalanceFromSale(account,i));
        }
        if(teamVestingStart > 0 && teamTokenBalance[account] > 0 &&  block.timestamp < teamVestingStart + 31557600){
            if(block.timestamp > teamVestingStart){
                lockedTokens = lockedTokens.add((teamVestingStart + 31557600 - block.timestamp).mul(teamTokenBalance[account]).div(31557600));
            }
            else{
                lockedTokens = lockedTokens.add(teamTokenBalance[account]);
            }
        }
        return balanceOf[account].sub(lockedTokens);
    }
    function lockedBalanceFromSale(address account, uint8 saleIndex) public view returns(uint256){
        //private sale balance and not past maturity
        if(privateSaleBalance[saleIndex][account] > 0 && block.timestamp < privateSaleEnd[saleIndex] + 39447000){
            //before 3 month lockup ends entire balance is locked
            if(block.timestamp < privateSaleEnd[saleIndex] + 7889400){
                return privateSaleBalance[saleIndex][account];
            }
            //immature portion = (maturity - currentTime / maturity) * balance
            else{
                return (privateSaleEnd[saleIndex] + 39447000 - block.timestamp).mul(privateSaleBalance[saleIndex][account]).div(31557600);
            }
        }
        return 0;
    }
    function withdrawLeftoverPrivateSale(uint8 saleIndex) finalized(saleIndex) onlyOwner external{
        require(teamVestingStart!=0 && canWithdraw==true);
        //all "ToDistribute" balances are already distributed
        _transfer(address(0),owner,totalTeamTokens - teamToDistribute + privateSaleTotalTokens[0] - privateSaleToDistribute[0]+ privateSaleTotalTokens[1] - privateSaleToDistribute[1]+ privateSaleTotalTokens[2] - privateSaleToDistribute[2]);
        canWithdraw = false;
    }

    //function privateSaleSend for token lockup multisend
}