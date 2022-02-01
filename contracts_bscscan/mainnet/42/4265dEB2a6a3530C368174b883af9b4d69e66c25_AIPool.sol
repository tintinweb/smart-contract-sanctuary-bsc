/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
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

interface DateTime {
        function getYear(uint timestamp) external pure returns (uint16);
        function getMonth(uint timestamp) external pure returns (uint8);
        function getDay(uint timestamp) external pure returns (uint8);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) external pure returns (uint);
}
interface ITradeBNB
{
   function totalAIPool(address user) external view returns(uint256);
   function userjointime(address user) external view returns(uint40);

}
interface IEACAggregatorProxy
{
    function latestAnswer() external view returns (uint256);
}
contract AIPool {
    using SafeMath for uint256;
    string public name     = "AI Pool";
    address public TradeBNB ;
    bool public safeguard;  //putting safeguard on will halt all non-owner functions
    mapping (address => bool) public frozenAccount;
    event FrozenAccounts(address target, bool frozen);
    event  Withdrawal(address indexed src, uint256 wad, uint256 bnbval);
    event UserClaim(address indexed _user, uint256 amount, uint claimtime);
    mapping(address => bool) internal administrators;
    mapping(address => mapping(uint => bool)) public isClaimed;
    uint public adminfeeperc = 3;
    struct user
    {
      uint256 withdrawble;
      uint256 totalwithdrawn;
      uint256 totalwithdrawnBNB;
    }
    uint16[] public poolperc=[180,250,770,960,510,620,390,630,540,630,250,230,850,630,870,280,640,460,750,640,690,510,210,150,660,890,360,830,620,230,360];

    mapping(address => user) public userInfo;
    address public terminal;
    address public EACAggregatorProxyAddress;
    DateTime public dateTime ;
    receive() external payable {
   }
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress],"Caller must be admin");
        _;
    }
    constructor(address _EACAggregatorProxyAddress,address dateTimeAddr)
    {
      administrators[msg.sender] = true;
      terminal = msg.sender;
      administrators[terminal] = true;
      //main -- 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
      EACAggregatorProxyAddress = _EACAggregatorProxyAddress;
      //0x4eDdEeE8E95aD2b29b8032B79359e9bF25E98150 -- main
      dateTime = DateTime(dateTimeAddr);
    }
    function isContract(address _address) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    function sendToOnlyExchangeContract(uint256 _amount) public onlyAdministrator returns(bool)
    {
        require(!isContract(msg.sender),  'No contract address allowed');
        require(address(this).balance >= _amount,'Insufficient Balance');
        payable(terminal).transfer(_amount);
        return true;
    }
    function changPoolPerc(uint16[] memory _setpoolperc) public onlyAdministrator returns(bool)
    {
        require(_setpoolperc.length == 31,'Values must be for 31 days');
        poolperc = _setpoolperc;
        return true;
    }
    function changTradeBNB(address _TradeBNB) public onlyAdministrator returns(bool)
    {
        TradeBNB = _TradeBNB;
        return true;
    }
    function setAdminFeeForWithdraw(uint _adminfeeperc) public onlyAdministrator returns(bool)
    {
        adminfeeperc = _adminfeeperc;
        return true;
    }

    function getYear(uint bdate) view public returns (uint16){
      return dateTime.getYear(bdate);
    }
    function getMonth(uint bdate) view public returns (uint8){
        return dateTime.getMonth(bdate);
    }
    function getDay(uint bdate) view public returns (uint8){
        return dateTime.getDay(bdate);
    }

    function claim(uint vdate) public returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(TradeBNB!=address(0),"Stake contract has not been set");
      require(ITradeBNB(TradeBNB).userjointime(msg.sender) < vdate,'Invalid date for claim');
      uint vcurdat = block.timestamp;
      uint8 vmonth=getMonth(vdate);
      uint16 vyear=getYear(vdate);
      uint8 vday=getDay(vdate);
      require((vmonth==getMonth(vcurdat) && vyear==getYear(vcurdat) && vday<= getDay(vcurdat)),'Claim available only for current month');
      uint vnewdate = dateTime.toTimestamp(vyear,vmonth,vday,1);
      require(!isClaimed[msg.sender][vnewdate],'Already claimed');
      uint256 userAITotal = ITradeBNB(TradeBNB).totalAIPool(msg.sender);
      require(userAITotal>0, "Invalid AI Pool trading");
      uint256 amount = userAITotal * poolperc[vday - 1] / 100000;
      isClaimed[msg.sender][vnewdate] = true;
      userInfo[msg.sender].withdrawble += amount;
      emit UserClaim(msg.sender, amount, vdate);
      return true;
    }

    function withdraw() public returns (bool) {
        require(!safeguard);
        require(!frozenAccount[msg.sender], "caller has been frozen");
        require(userInfo[msg.sender].withdrawble > 0,'Not good to withdraw');
        uint256 amount= userInfo[msg.sender].withdrawble;
        uint256 adminfee = amount * adminfeeperc / 100;
        uint256 userbalance = USDToBNB(amount - adminfee);
        adminfee =USDToBNB(adminfee);
        userInfo[msg.sender].withdrawble -= amount;
        userInfo[msg.sender].totalwithdrawn += amount;
        userInfo[msg.sender].totalwithdrawnBNB += userbalance + adminfee;
        payable(msg.sender).transfer(userbalance);
        payable(terminal).transfer(adminfee);
        emit Withdrawal(msg.sender, amount , userbalance + adminfee) ;
        return true;
    }
    function destruct() onlyAdministrator() public{
        selfdestruct(payable(terminal));
    }
    function BNBToUSD(uint bnbAmount) public view returns(uint)
    {
        uint256  bnbpreice = IEACAggregatorProxy(EACAggregatorProxyAddress).latestAnswer();
        return bnbAmount * bnbpreice * (10 ** 10) / (10 ** 18);
    }
    function USDToBNB(uint busdAmount) public view returns(uint)
    {
        uint256  bnbpreice = IEACAggregatorProxy(EACAggregatorProxyAddress).latestAnswer();
        return busdAmount  / bnbpreice * (10 ** 8);
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
    function freezeAccount(address target, bool freeze) onlyAdministrator public {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    function setterminal(address _terminal) public  onlyAdministrator returns(bool)
    {
        administrators[terminal] = false;
        terminal = _terminal;
        administrators[terminal] = true;
        return true;
    }
}