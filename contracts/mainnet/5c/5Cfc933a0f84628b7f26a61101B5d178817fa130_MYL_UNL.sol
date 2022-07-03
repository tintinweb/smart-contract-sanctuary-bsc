/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Invalid values");
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0,"Invalid values");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"Invalid values");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"Invalid values");
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"Invalid values");
        return a % b;
    }
}


interface MYL_LottoInterface{

     struct Draw{
        uint externalId; 
        uint endTimestamp;
        uint numberOfTickets;
        uint numberOfPurchases;
        uint charity;
        uint rewardProgram;
        uint winningNumbers;
        bool winnersDeclared;
    }

     struct Ticket{
        address buyer;
        uint purchaseId;
        uint ticketNumbers;
    }

    function getPriceOfOneTicket() external view returns(uint);
    
    function getPrizePool() external view returns(uint);

    function getCurrentDraw() external view returns(uint256,uint256,uint256,uint256,uint256);

    function getDraw(uint drawId) external view returns(Draw memory);

    event TicketPurchase(uint indexed drawId, address indexed buyer, uint[] ticketNumbers);

    event Donation(uint amount);

    event DeclareWinners(uint indexed drawId);

}



contract MYL_UNL is MYL_LottoInterface {

    using SafeMath for uint256;
    
    //============================================================================
    // Constants
    //============================================================================

    uint constant private GOVERMENT_PERCENT=35;
    uint constant private REWARD_PROGRAM_PERCENT=10;
    uint constant private OPEX_PERCENT=5;

    //============================================================================
    // State Variables
    //============================================================================

    mapping(uint=>Draw) private _draws;

    // MYL token contract
    IERC20 mylToken;

    //owner of the contract
    address private _owner;

    //admin of the contract
    address private _admin;

    // price of one ticket
    uint256 private _ticketPrice;

    // cut off time
    uint256 _cutOffTime=2 hours;                           

    //id of the current draw 
    uint256 private currentDrawId = 0;                                                                  

    // Number of tokens as reward-program 
    uint256 private _tokenReward=10 * (10**18);          

    address payable private _charityWallet;
    address payable private _rewardProgramWallet;
    address payable private _opexWallet;

 
    //user ticket number for a drawId
    mapping (uint256 => mapping (address => uint256[])) private _drawIdToParticipantAddressToTicketNumbers;          
    
    //user ticket number for a drawId
    mapping (uint256 => mapping (uint => Ticket)) private _drawIdToTicketIdToTicket;            

    //list of all winner addresses in a draw
    mapping (uint256 => address[]) private _drawIdToWinnerAddresses;  

    //list of all winning amounts in a draw
    mapping (uint256 => uint[]) private _drawIdToWinningAmounts;  


    //======================================================================================
    // CONSTRUCTOR
    //======================================================================================

    constructor (address owner,address _mylToken)  {
        _owner = owner;
        _admin = 0x533FF563AAB147D5254A01B0DA18Fce8a748F59c;

        mylToken = IERC20(_mylToken);

        _charityWallet=payable(0xBe0ca0a23838Cae9e3362aE6d25FbBd43E7CFbBe);
        _rewardProgramWallet=payable(0x7B401FEef43876A0eBdc464d12970088053Ab18c);
        _opexWallet=payable(0xE186A4Dcd2ADBf56edAD352a448c6EfE17D35D0f);

    }


    //======================================================================================
    // Access Control
    //======================================================================================


    /**
    * @dev get address of smart contract owner
    * @return address of owner
    */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
    * @dev modifier to check if the message sender is owner
    */
    modifier onlyOwner() {
        require(isOwner(),"caller is not the owner");
        _;
    }
    
    /**
     * @dev Internal function for modifier
     */
    function isOwner() internal view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfer ownership of the smart contract. For owner only
     * @return request status
      */
    function transferOwnership(address newOwner) public onlyOwner returns (bool){
        _owner = newOwner;
        return true;
    }


    /**
    * @dev get address of smart contract admin
    * @return address of owner
    */
    function getAdmin() public view returns (address) {
        return _admin;
    }

    /**
    * @dev modifier to check if the message sender is admin
    */
    modifier onlyAdmin() {
        require(isAdmin() || isOwner(),"caller is not the admin");
        _;
    }

    
    /**
     * @dev Internal function for modifier
     */
    function isAdmin() internal view returns (bool) {
        return msg.sender == _admin;
    }


    /**
     * @dev Set new admin for the contract
     * @return request status
      */
    function setAdmin(address newAdmin) public onlyOwner returns (bool){
        _admin = newAdmin;
        return true;
    }
 
    //======================================================================================
    // Main Funcions
    //======================================================================================

    
    /**
     * @dev close current draw and goto next draw 
    */
    function closeCurrentDrawAndGotoNextDraw(uint256 _nextDrawEndTimestamp, uint _externalId) public onlyAdmin returns(bool){

        //draw-date should be after current timestamp 
        require(_nextDrawEndTimestamp > block.timestamp,"Invalid endtime");
        
        //draw-date should be after current draw 
        require(_nextDrawEndTimestamp>_draws[currentDrawId].endTimestamp,"Invalid endtime");

        if(_draws[currentDrawId].endTimestamp==0){
            _draws[currentDrawId].endTimestamp = _nextDrawEndTimestamp;
            _draws[currentDrawId].externalId = _externalId;
            return true;
        }


        _charityWallet.transfer(_draws[currentDrawId].charity);
        _rewardProgramWallet.transfer(_draws[currentDrawId].rewardProgram);
   

        uint _prizePool=address(this).balance;
        uint _opex =  _prizePool.mul(OPEX_PERCENT).div(100);
        _opexWallet.transfer(_opex);

        currentDrawId = currentDrawId +1;

        _draws[currentDrawId]=Draw(
            _externalId,                                        //externalId
            _nextDrawEndTimestamp,                              //endDatetime
            _draws[currentDrawId].numberOfTickets,              //numberOfTickets
            _draws[currentDrawId].numberOfPurchases,            //numberOfPurchases
            0,                                                  //charity
            0,                                                  //rewardProgram
            0,                                                  //winningNumbers
            false                                               //winnersDeclared
        );
        return true;  
    }

    /**
     * @dev declare winner for the current draw
    */
    function declareWinners(
        uint256 _winningNumbers,
        address payable[] calldata _winnerAddresses, 
        uint256[]  calldata _winningAmountsInWei
    ) external payable onlyAdmin returns(bool){

        require(currentDrawId>0,"Not allowd before closing the draw");

        require(!_draws[currentDrawId-1].winnersDeclared,"winners already declared");
        
        require(_winnerAddresses.length == _winningAmountsInWei.length, "Invalid winner declaration data");
        bool _allAddressesAreValid=true;

        //check all winning addresses to make sure that they have tickets in the current draw
        for(uint256 i=0;i<_winnerAddresses.length;i++){
            _allAddressesAreValid=_allAddressesAreValid && _drawIdToParticipantAddressToTicketNumbers[currentDrawId-1][_winnerAddresses[i]].length>0;
        }
        require(_allAddressesAreValid, "Invalid winner addresses");

        
        for(uint256 i=0;i<_winnerAddresses.length;i++){
            _winnerAddresses[i].transfer(_winningAmountsInWei[i]);
        }


        for(uint256 i=0;i<_winnerAddresses.length;i++){
            _drawIdToWinnerAddresses[currentDrawId-1].push(_winnerAddresses[i]);
            _drawIdToWinningAmounts[currentDrawId-1].push(_winningAmountsInWei[i]);
        }

         _draws[currentDrawId-1].winningNumbers=_winningNumbers;

        _draws[currentDrawId-1].winnersDeclared=true;
        emit DeclareWinners(currentDrawId-1);
        return true;
    }

    
    /**
     * @dev perform purchase
     * @param _ticketNumbers ticket number from the list in application
    */
    function purchaseTicket(uint256[] calldata _ticketNumbers) external payable returns(bool)
    {
        uint256 ticketCount=_ticketNumbers.length;

        require(_ticketPrice>0, "Ticket-price is not set yet!");
        require(_draws[currentDrawId].endTimestamp >0, "Sales not beginned yet!");
        require(ticketCount>0 && ticketCount<6, "Invalid number of tickets");

        require(msg.value >= ticketCount.mul(_ticketPrice), "Insufficient value");

        for(uint256 i=0;i<_ticketNumbers.length;i++){
            require(_ticketNumbers[i].div(10**12) ==0 && _ticketNumbers[i].div(10**10) >0, "Invalid ticket value/count" );
        }
    
        uint256 _drawId;
        if((_draws[currentDrawId].endTimestamp - _cutOffTime) > block.timestamp){
            _drawId = currentDrawId;
        } else {
            _drawId = currentDrawId.add(1);
        }
      
        for(uint256 i=0;i<_ticketNumbers.length;i++){
            _drawIdToTicketIdToTicket[_drawId][_draws[_drawId].numberOfTickets + i]=Ticket(msg.sender,_draws[_drawId].numberOfPurchases,_ticketNumbers[i]);
            _drawIdToParticipantAddressToTicketNumbers[_drawId][msg.sender].push(_ticketNumbers[i]);
        }

        //reward program
        if(ticketCount == 5) {
            mylToken.transfer(msg.sender,_tokenReward);
        }

        _draws[_drawId].numberOfTickets=_draws[_drawId].numberOfTickets.add(ticketCount);
        _draws[_drawId].numberOfPurchases=_draws[_drawId].numberOfPurchases.add(1);
        
        _draws[_drawId].charity +=  msg.value.mul(GOVERMENT_PERCENT).div(100);
        _draws[_drawId].rewardProgram +=  msg.value.mul(REWARD_PROGRAM_PERCENT).div(100);
       
       emit TicketPurchase(currentDrawId,msg.sender,_ticketNumbers);

        return true;
    }


    /**
     * @dev perform donate
    */
    function donate() external payable returns(bool)
    {
        _draws[currentDrawId].charity +=  msg.value.mul(GOVERMENT_PERCENT).div(100);
        emit Donation(msg.value);
        return true;
    }


    //======================================================================================
    // Getters and Setters
    //======================================================================================


    /**
     * @dev set wallet address of Ukraine Goverment
    */
    function setUkraineWallet(address _wallet) public onlyOwner returns(bool){
        require(_wallet!=address(0),"Invalid wallet address");
        _charityWallet = payable(_wallet);
        return true;
    }

    /**
     * @dev get wallet address of Ukraine Goverment
    */
    function GetUkraineWallet() public view returns(address){
        return _charityWallet;
    }

    /**
     * @dev set the opex wallet
    */
    function setOpexWallet(address _wallet) public onlyOwner returns(bool){
        require(_wallet!=address(0),"Invalid wallet address");
        _opexWallet = payable(_wallet);
        return true;
    }

    /**
     * @dev get the opex wallet
    */
    function getOpexWallet() public view returns(address){
        return _opexWallet;
    }


    /**
     * @dev set the reward program wallet
    */
    function setRewardProgramWallet(address _wallet) public onlyOwner returns(bool){
        require(_wallet!=address(0),"Invalid wallet address");
        _rewardProgramWallet = payable(_wallet);
        return true;
    }

    /**
     * @dev get the reward program wallet
    */
    function getRewardProgramWallet() public view returns(address){
        return _rewardProgramWallet;
    }

    /**
     * @dev set cut off time for the lotto
    */
    function setCutOffTime(uint256 time) public onlyOwner returns(bool){
        require(time > 0,"Invalid time provided, Please try Again!!");
        _cutOffTime = time;
        return true;
    }
    
    /**
     * @dev get cut off time for the lotto
    */
    function getCutOffTime() external view returns(uint256){
        return _cutOffTime;
    }


    /**
     * @dev get price of one ticket
    */
    function getPriceOfOneTicket() external view override returns(uint256){
        return _ticketPrice;
    }

    /**
     * @dev set price of one ticket by owner only
     * @param _newPrice New price of each token
    */
    function setPriceOfOneTicket(uint256 _newPrice) external onlyAdmin returns(bool){
        require(_newPrice>0,"Invalid price");
        _ticketPrice = _newPrice;
        return true;
    }


    /**
     * @dev get number of myl-tokens as reward in 5-ticket purchase
    */
    function getTokenReward() external view returns(uint256){
        return _tokenReward;
    }

    /**
     * @dev set number of myl-tokens as reward in 5-ticket purchase
    */
    function setTokenReward(uint256 _num) external onlyOwner returns(bool){
        _tokenReward = _num;
        return true;
    }    


    //======================================================================================
    // get sales data
    //======================================================================================
  

   
    /**
     * @dev get current jackpot for this session
    */
    function getPrizePool() external view override returns(uint256){
        return address(this).balance.sub(_draws[currentDrawId].charity).sub(_draws[currentDrawId].rewardProgram).sub(_draws[currentDrawId+1].charity).sub(_draws[currentDrawId+1].rewardProgram);
    }


    /**
     * @dev get ticket number for the given address
     * @param _drawId id of a draw id
     * @param _address buyer's addrerss
    */
    function getTicketNumbersByAddress(uint256 _drawId, address _address) external view returns(uint256[] memory){
        return _drawIdToParticipantAddressToTicketNumbers[_drawId][_address];
    }

    /**
     * @dev get ticket data for the given id
     * @param _drawId id of a draw id
     * @param _ticketId id of the ticket
    */
    function getTicketDataById(uint256 _drawId, uint _ticketId) external view returns(Ticket memory){
        return _drawIdToTicketIdToTicket[_drawId][_ticketId];
    }

    /**
     * @dev get data of draw
     * @param _drawId id of a draw id
    */
    function getDraw(uint256 _drawId) external view override returns(Draw memory){
        return _draws[_drawId];
    }

    /**
     * @dev get data of current draw
    */
    function getCurrentDraw() external view override returns(uint256,uint256,uint256,uint256,uint256){
        return (
            currentDrawId,
            _draws[currentDrawId].endTimestamp,
            _draws[currentDrawId].numberOfTickets,
            _draws[currentDrawId].numberOfPurchases,
            _draws[currentDrawId].externalId
        );
    }


    /**
     * @dev get winner addresses for a draw
     * @param _drawId id of a draw id
    */
    function getWinnerAddresses(uint _drawId) public view returns (address[] memory){
        return _drawIdToWinnerAddresses[_drawId];
    }

    /**
     * @dev get winning amounts for a draw
     * @param _drawId id of a draw id
    */
    function getWinningAmounts(uint _drawId) public view returns (uint[] memory){
        return _drawIdToWinningAmounts[_drawId];
    }


    //======================================================================================
    // Withdraw
    //======================================================================================

    /**
     * @dev withdraw from contract
    */
     function withdraw(uint256 _amount,address payable _receiver) external onlyOwner returns(bool){
        require(_amount>0 && (address(this).balance - _draws[currentDrawId].charity - _draws[currentDrawId].rewardProgram) >= _amount,"More than available amount"); 
        _receiver.transfer(_amount);
        return true;
    }
    
    
    /**
     * @dev withdraw token from contract
    */
    function withdrawToken(address tokenAddress, uint256 amount, address receiver) external onlyOwner returns(bool){
        require(IERC20(tokenAddress).balanceOf(address(this))>= amount, "Insufficient amount to transfer");
        IERC20(tokenAddress).transfer(receiver,amount);
        return true;
    }   
   
}