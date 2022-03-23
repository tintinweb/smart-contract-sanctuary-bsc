/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

//IERC20 INTERFACE

interface IERC20 {
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
}

contract Ownable is Context {
    address private  _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KITYTIX is Context, Ownable{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    //EDIT FIELD TO EDIT NUMBER OF TICKETS
    uint public totalSupply = 10000; // MODIFY SUPPLY
    uint public decimals = 0;


    string public name = "KITY Lottery Tix";
    string public symbol = "KITYTIX";

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[address(this)] = totalSupply;
    }

    	function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
  
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }

    function sell(address to, uint value) internal returns(bool) {
        require(balanceOf(address(this)) >= value, 'balance too low');
        balances[to] += value;
        balances[address(this)] -= value;
        emit Transfer(address(this), to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function burn(uint256 _amount) external onlyOwner(){
        require(balanceOf(msg.sender) >= _amount, 'balance too low');
        totalSupply -= _amount;
        balances[msg.sender] -= _amount;
    }

    function mint(uint256 _amount) external onlyOwner(){
        totalSupply += _amount;
        balances[msg.sender] += _amount;
    }

    function selfDestruct() public {
        selfdestruct(payable(owner()));
    }


}

contract BuyTicket is Context, Ownable, KITYTIX{

    mapping(address => uint) public rewardsTickets;
    uint public kityThresholdMultiple = 50000 * 10 ** 18;

    //Kity Token Contract Change This Address to KITY CA
    IERC20 kityContract = IERC20(0x300361303dCa0256f93b6008eD8CFEf0C2f9A5cB); 


    address payable public feeAddress = payable(0x9039D7B2BDb14298eb10BEBc20667869d2d64484); 
    address payable public jackpotAddress = payable(0x12dbC4A7596c35076f6A393244DD3aEaB749fC41); 
    address payable public kityStaking = payable(0x0266CFfeD9a384b92CFbB4B3F66345AcB52cFBe0); 

    uint public devFee = 20;
    uint public stakingFee = 20;
    uint public jackpotFee = 60;

    //ETHER is the Solidity denomination for the unit base currency of the blockchain
    //this would transalte to BNB on the Binance Chain
    uint ticketPrice = 0.033 ether;
    function noOfTicketsAvailable() public view returns(uint) {
        return balanceOf(address(this));
    }


    function buyTickets(uint numberOfTickets) external payable {
        require (numberOfTickets <= noOfTicketsAvailable(), "not enough tokens to buy");
        uint _amount = ticketPrice*numberOfTickets;
        address callerWallet = msg.sender;
        require (msg.value == _amount, "msg value is not correct");
        splitEther(_amount);
        transferTickets(numberOfTickets, callerWallet);
    }


//ADD BREAKDOWN TO DIFFERENT WALLETS
//ADD SWAP TO KITY

    function splitEther (uint amount) internal {
        feeAddress.transfer(amount*devFee/100);
        kityStaking.transfer(amount*stakingFee/100);
        jackpotAddress.transfer(amount*jackpotFee/100);

    }


	function transferTickets(uint _numberOfTickets, address _callerWallet) internal {
        uint ticketsToAddAsReward = rewardTickets(_callerWallet, _numberOfTickets);

        if (noOfTicketsAvailable() < _numberOfTickets+ticketsToAddAsReward){
            sell(_callerWallet, _numberOfTickets);
        }
        else {
            sell(_callerWallet, _numberOfTickets+ticketsToAddAsReward);
        }

        
    }
    function rewardTickets(address _callerWallet, uint ticketsBought) internal returns(uint){
        uint kityBalance = kityContract.balanceOf(_callerWallet);
        uint numberOfRewards = 0;

        //CONDITION O: HAVE CLAIMED ALL REWARDS?
        if (rewardsTickets[_callerWallet] >= 5){
            numberOfRewards = 0;
        }
        
        else {
             //CONDITION 1: HAS ENOUGH KITY
            if (kityBalance >= kityThresholdMultiple && kityBalance < kityThresholdMultiple*2) {
                numberOfRewards = 1; //50k
            }
            else if (kityBalance >= kityThresholdMultiple*2 && kityBalance < kityThresholdMultiple*3) {
                numberOfRewards = 2; //100k
            }
            else if (kityBalance >= kityThresholdMultiple*3 && kityBalance < kityThresholdMultiple*4) {
                numberOfRewards = 3;  //150k
            }
            else if (kityBalance >= kityThresholdMultiple*4 && kityBalance < kityThresholdMultiple*5) {
                numberOfRewards = 4;  //200k
            }
            else if (kityBalance >= kityThresholdMultiple*5) {
                numberOfRewards = 5; //250k
            }

            //CONDITION 2: Has not recieved rewards before

            if(rewardsTickets[_callerWallet] >= numberOfRewards){
                numberOfRewards = 0;
            }

            //CONDITION 3: TOKENS BOUGHT <= TO REWARDS
            if (numberOfRewards > ticketsBought){
                numberOfRewards = ticketsBought;
            }
            else {
                //do nothing, keep value from above
            }


        }

        rewardsTickets[_callerWallet] += numberOfRewards;
        return numberOfRewards;
    }

    function rewardTicketsToGive(address _callerWallet) public view returns(uint){
        uint kityBalance = kityContract.balanceOf(_callerWallet);
        uint numberOfRewards = 0;

        if (kityBalance >= kityThresholdMultiple && kityBalance < kityThresholdMultiple*2) {
            numberOfRewards = 1; //50k
        }
        else if (kityBalance >= kityThresholdMultiple*2 && kityBalance < kityThresholdMultiple*3) {
            numberOfRewards = 2; //100k
        }
        else if (kityBalance >= kityThresholdMultiple*3 && kityBalance < kityThresholdMultiple*4) {
            numberOfRewards = 3;  //150k
        }
        else if (kityBalance >= kityThresholdMultiple*4 && kityBalance < kityThresholdMultiple*5) {
            numberOfRewards = 4;  //200k
        }
        else if (kityBalance >= kityThresholdMultiple*5) {
            numberOfRewards = 5; //250k
        }
        
        return numberOfRewards;

    }



}