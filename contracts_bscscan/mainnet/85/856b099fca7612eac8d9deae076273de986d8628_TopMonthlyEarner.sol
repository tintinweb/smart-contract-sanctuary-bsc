/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
interface IEACAggregatorProxy
{
    function latestAnswer() external view returns (uint256);
}
interface ITradeBNB
{
   function settopEarners(address _user,uint256 _amt) external returns(bool);
   function top5Earners(address user) external view returns(uint256);
}
contract TopMonthlyEarner {

    using SafeMath for uint256;
    bool public safeguard;  //putting safeguard on will halt all non-owner functions
    mapping (address => bool) public frozenAccount;
    uint public adminfeeperc = 3;
    uint public PoolDistperc = 5;
    address public terminal;
    address public tradeBNB;
    address public EACAggregatorProxyAddress;
    mapping(address => bool) internal administrators;
    event FrozenAccounts(address target, bool frozen);
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress],"Caller must be admin");
        _;
    }
    string public name = "Top Monthly Earner";
    uint256 private decimals = 18;
    event ClaimEv(address indexed _user, uint256 amount, uint256 bnbamt);
    constructor(address _TradeBNB, address _EACAggregatorProxyAddress)
    {
        terminal = msg.sender;
        administrators[terminal] = true;
        tradeBNB = _TradeBNB;
        //main -- 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        EACAggregatorProxyAddress = _EACAggregatorProxyAddress;
    }

    function USDToBNB(uint busdAmount) public view returns(uint)
    {
        uint256  bnbpreice = IEACAggregatorProxy(EACAggregatorProxyAddress).latestAnswer();
        return busdAmount  / bnbpreice * (10 ** (decimals-10));
    }

    function Claim() external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      uint256 topEarn = ITradeBNB(tradeBNB).top5Earners(msg.sender);
      require(topEarn>0,'Invalid amount to claim');
      uint256 bnbtosend =USDToBNB(topEarn);
      require(address(this).balance >= bnbtosend,'Insufficient BNB');
      ITradeBNB(tradeBNB).settopEarners(msg.sender,topEarn);
      uint256 adminfee = topEarn * adminfeeperc/100;
      uint256 userbalance = USDToBNB(topEarn - adminfee);
      adminfee = USDToBNB(adminfee);
      payable(msg.sender).transfer(userbalance);
      payable(terminal).transfer(adminfee);
      emit ClaimEv(msg.sender, topEarn, bnbtosend);
      return true;
    }
      receive() external payable {
    }

    function setAdminFeeForWithdraw(uint _adminfeeperc) public onlyAdministrator returns(bool)
    {
        adminfeeperc = _adminfeeperc;
        return true;
    }

    function sendToStakingContract() public onlyAdministrator returns(bool)
    {
        require(!isContract(msg.sender),  'No contract address allowed');
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }
    function destruct() onlyAdministrator() public{
        selfdestruct(payable(terminal));
    }
    /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() onlyAdministrator public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;
        }
    }
    function changTradeBNB(address _TradeBNB) public onlyAdministrator returns(bool)
    {
        tradeBNB = _TradeBNB;
        return true;
    }
    function freezeAccount(address target, bool freeze) onlyAdministrator public {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }

    function isContract(address _address) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    function setterminal(address _terminal) public  onlyAdministrator returns(bool)
    {
        administrators[terminal] = false;
        terminal = _terminal;
        administrators[terminal] = true;
        return true;
    }
}