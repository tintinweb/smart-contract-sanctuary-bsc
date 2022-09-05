/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

/**
 *Submitted for verification at polygonscan.com on 2022-08-16
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: BlockchainLottery.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract BlockchainLottery{
    address public owner;
    bool public isOn = true;
    address[] participants;
    uint public lastWinner;
    uint public fee = 500000;
    uint randNonce=2;
    uint public amount = 1500000;
    uint lotteryNumberCounter=0;
    address feeAccount;
    mapping(uint=>address) public ticketsAndAddress;
    mapping(address=>uint) public addressAndTickets;
    uint[] public tickets;
    mapping(address=>uint) amountOfParticipants;
    address public USDTAddress = 0x55d398326f99059fF775485246999027B3197955; //USDT Address on BSC
    event Winner(address,uint);
    event DepositeAmountEvent(address);
    constructor(){
        feeAccount=msg.sender;
        owner=msg.sender;
    }

    modifier onlyFeeAcccount{
        require(msg.sender==feeAccount,"You are not the Fee Receiver");
        _;
    }
    modifier onlyOwner{
        require(msg.sender==feeAccount,"You are not the Owner");
        _;
    }
    function updateOwner(address _address) public {
        require(msg.sender==feeAccount,"You are not the Fee Account");
        owner=_address;
    }
    function setFeeAccount(address _account) public onlyFeeAcccount {
        feeAccount = _account;
    }
    function updateFee(uint _fee) public onlyFeeAcccount{
        require(_fee<amount,"Fee should be less then amount");
        fee = _fee;
    }
    function updateUSDTAddress(address _newAddress) public onlyFeeAcccount{
        require(_newAddress!=USDTAddress,"NEW ADDRESS CAN NOT BE OLD ONE");
        USDTAddress = _newAddress;
    }
    function getParticipants(uint _id) view public returns(address){
        return participants[_id];
    }
    function setDepositeAmount(uint _amount) public onlyOwner{
        amount = _amount;
    }
    function setRandNounce(uint _num) public onlyFeeAcccount {
        randNonce=_num;
    }

    function getAllParticipants() view public returns(address[] memory){
        return participants;
    }
    function getAllTickets() public view returns(uint[] memory){
        return tickets;
    }
    function getTicket(address _address) public view returns(uint){
        return addressAndTickets[_address];
    }
    
    function setIsOn(bool _isOn) public onlyOwner{
        isOn=_isOn;
    }


    //participants can deposite the amount of USDT
    function depositeUSDT(uint _amount) public {
        require(isOn,"Deposites are now closed");
        require(_amount==amount,"Please enter the specified amount of USDT");
        IERC20(USDTAddress).transferFrom(msg.sender, feeAccount, fee);
        IERC20(USDTAddress).transferFrom(msg.sender, address(this), _amount-fee);
        participants.push(msg.sender);
        amountOfParticipants[msg.sender]+=_amount;
        emit DepositeAmountEvent(msg.sender);
    }



    //assign all the participants a random ticket number
    function assignTicket() public {
        // require(msg.sender==feeAccount||msg.sender==owner,"You are not the Owner nor the Fee Account");
        require(isOn, "isOn require to True");
        require(participants.length!=0,"No participants");
        for(uint i=0;i<participants.length;i++){
            uint ticket = ticketGenerator();
            ticketsAndAddress[ticket] = participants[i];
            addressAndTickets[participants[i]] = ticket;
            tickets.push(ticket);
            randNonce++;
        }
        isOn=false;
    }

    // generates the lottery tickets
    function ticketGenerator() internal view returns(uint){
        uint _modulus = 100000;
        uint ticket = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
        return ticket;
    }

    // opens the lottery for the user 
    function getLottery() public {
        // require(msg.sender==feeAccount||msg.sender==owner,"You are not the Owner nor the Fee Account");
        require(isOn==false,"isOs should ne false");
        require(tickets.length!=0,"No tickets");
        uint[] memory shuffledTickets = shuffleTickets(tickets);
        uint WinnerId = LotteryWinner();
        uint balance = IERC20(USDTAddress).balanceOf(address(this));
        IERC20(USDTAddress).transfer(ticketsAndAddress[shuffledTickets[WinnerId]],balance);
        lastWinner = shuffledTickets[WinnerId];
        emit Winner(ticketsAndAddress[shuffledTickets[WinnerId]],shuffledTickets[WinnerId]);
        uint participantsLen = participants.length;
        for(uint i=0;i<participantsLen;i++){
            participants.pop();
        }
        uint ticketsLen = tickets.length;
        for(uint i=0;i<ticketsLen;i++){
            tickets.pop();
        }
        isOn=true;
    }

    // Declares the winner index of the lottery from shuffled array of the ticket numbers
    function LotteryWinner() internal view returns(uint){
        uint _modulus = tickets.length;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }
 
    //shuffles the array of the ticket numbers 
    function shuffleTickets(uint[] memory _myArray) internal view returns(uint[] memory){
        uint a = _myArray.length; 
        uint b = _myArray.length;
        for(uint i = 0; i< b ; i++){
            uint randNumber =(uint(keccak256      
            (abi.encodePacked(block.timestamp,_myArray[i]))) % a)+1;
            uint interim = _myArray[randNumber - 1];
            _myArray[randNumber-1]= _myArray[a-1];
            _myArray[a-1] = interim;
            a = a-1;
        }
        uint256[] memory result;
        result = _myArray;       
        return result;        
    }
}