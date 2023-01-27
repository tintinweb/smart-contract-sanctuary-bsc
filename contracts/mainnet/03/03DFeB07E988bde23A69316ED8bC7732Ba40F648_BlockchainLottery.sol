/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

//SPDX-License-Identifier: MIT

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

pragma solidity ^0.8.0;

contract BlockchainLottery {
    address public Owner;
    address public Manager;

    bool public isOn = true;

    address[] public participants;

    address[] public tokens;
    mapping(address => uint256) public totalTokenPrize;

    address public lastWinner;

    uint256 public fee = 489765310000000;
    uint256 public amount = 1000000000000000000;
    uint256 randNonce = 2;

    mapping(address => uint256) public primeUserTickets;
    address[] public primeUser;
    mapping(address => address) public primeUserToken;

    event Winner(address Winner);
    event DepositeAmountEvent(address);

    constructor() {
        Manager = msg.sender;
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "You are not the Owner");
        _;
    }
    modifier onlyManager() {
        require(msg.sender == Manager, "You are not the Manager");
        _;
    }

    // USER FUNCTIONS

    // Prime User Can Buy Ticket from here
    function buyTickets(uint256 _amount, uint256 _noOfTicket, address _tokenAddress) public payable {
        require(isOn, "All Tickets Sold Out"); // Check if the contract is still selling tickets
        require(_amount == amount, "Please Provider Actual price of tickets"); // Check if the User paying complete Ticket Price
        require(msg.value==fee*_noOfTicket,"Please provide the fees");
        require(!isParticipant(msg.sender), "You are Already a participant"); // Check if User has already participated in the lottery or not

        if (!isToken(_tokenAddress)) {
            // Check if the Token user using is already in the record or not
            tokens.push(_tokenAddress); // add token to record if token is not present in records
        }
        // transfer the fee amount from the user's deposit to the Fee Account
        // transfer the Amount of lottery to the contract
        IERC20(_tokenAddress).transferFrom(msg.sender,address(this),
            (_amount) * _noOfTicket
        );
        // add user to the Participants list
        participants.push(msg.sender);
        // add uset to the list of Prime User
        if(_noOfTicket>1){
            primeUser.push(msg.sender);
            // initialize the users ticket balance
            primeUserTickets[msg.sender] = _noOfTicket - 1;
            // incrementing the prize of lottery buy token address
            // add the user balance
            primeUserToken[msg.sender] = _tokenAddress;
        }
        totalTokenPrize[_tokenAddress] += _amount;
    }

    // opens the lottery for the user
    function getLottery() public {
        require(msg.sender == Owner || msg.sender == Manager,"You are neither Owner nor the Manager");

        require(isOn == false, "isOn should ne false");
        
        require(participants.length != 0, "No Participants");
        //shuffling tickets
        // address[] memory shuffledParticipants = shuffleParticipants(participants);
        // geting the lottery winner
        uint256 WinnerId = LotteryWinner();
        // sending lottery price to winner

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transfer(participants[WinnerId],totalTokenPrize[tokens[i]]);
        }

        //getting winner for the event
        lastWinner = participants[WinnerId];
        emit Winner(participants[WinnerId]);
        // cleaning the participants and ticket from the array

        delete participants;

        uint256 tokensLen = tokens.length;
        for (uint256 i = 0; i < tokensLen; i++) {
            totalTokenPrize[tokens[i]] = 0;
        }

        delete tokens;

        randNonce=WinnerId;
        // setting lottery status to ON
        isOn = true;
        
        if (primeUser.length > 0) {
            for (uint256 i = (primeUser.length - 1); i >= 0; i--) {
                if (primeUserTickets[primeUser[i]] > 0) {
                    participants.push(primeUser[i]);
                    primeUserTickets[primeUser[i]]--;
                    if (!isToken(primeUserToken[primeUser[i]])) {
                        tokens.push(primeUserToken[primeUser[i]]);
                    }
                    totalTokenPrize[primeUserToken[primeUser[i]]] += (amount);
                    if(primeUserTickets[primeUser[i]] == 0){
                        remove(i);
                    }
                } else {
                    remove(i);
                }
                if (i == 0) {
                    break;
                }
            }
        }
    }

    // UTILITIES FUNCTION
    function remove(uint256 i) private {
        while (i < primeUser.length - 1) {
            primeUser[i] = primeUser[i + 1];
            i++;
        }
        primeUser.pop();
    }

    // Check if the participant is already bought the token or not
    function isParticipant(address _participant) public view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                return true;
            }
        }
        return false;
    }

    // Check if token is already present in the Record or not
    function isToken(address _token) public view returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == _token) {
                return true;
            }
        }
        return false;
    }


    // Declare the winner
    function LotteryWinner() public view returns (uint256) {
        uint256 _modulus = participants.length;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce, _modulus))) % _modulus;
    }

    // OWNER Functions

    function updateOwner(address _address) public onlyOwner {
        Owner = _address;
    }

    function setManager(address _account) public onlyOwner {
        Manager = _account;
    }

    function setDepositeAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
    }

    function setRandNounce(uint256 _num) public onlyOwner {
        randNonce = _num;
    }

    function setIsOn(bool _isOn) public {
        require(
            msg.sender == Owner || msg.sender == Manager,
            "You are neither Owner nor the Manager"
        );
        isOn = _isOn;
    }

    function getAllParticipants() public view returns (address[] memory) {
        return participants;
    }

    function getAllTokens() public view returns (address[] memory) {
        return tokens;
    }

    function getAllPrimeUsers() public view returns (address[] memory) {
        return primeUser;
    }
    
    function getTotalPrize() public view returns (uint256) {
        uint256 totalPrize;
        for (uint256 i = 0; i < tokens.length; i++) {
            totalPrize += totalTokenPrize[tokens[i]];
        }
        return totalPrize;
    }

    function withdrawBNB() public onlyOwner {
        payable(Owner).transfer(address(this).balance);
    }
}