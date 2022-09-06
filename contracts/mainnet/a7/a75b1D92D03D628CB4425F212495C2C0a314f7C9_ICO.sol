/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract ICO {      

    IERC20 stakingToken;
    IERC20 stakingFromToken;
    uint256 public ratePerToken;
    uint40 public startTime;
    uint40 public endTime;    
    bool ICO_status;
    uint256 public total_users=0;
    uint256[1] public levelIncome = [5];
    uint256 rateDiv = 1000000;
    uint256 public totalSupply = 100000;
    uint256 public saled = 0;
    uint256 randNonce = 0;
    address stakingaddress;
    struct User {
        uint256 id;        
        address sponsor;
        uint40 directs;        
        uint256 total_balance;       
        uint256 direct_commision;       
        uint256 claimed;               
        uint256 total_deposit;               
        uint40 timestamp;       
    }

    struct user_investment{
        uint256 total_invest;
        uint256 investment_count;
        uint256[] investments;
    }

    struct investment{
        uint256 id;
        address myaddress;
        uint256 amount;
        uint256 invest;      
        uint40 timestamp;
    }

    uint32 public stakingTime = 1671062400;   

    uint256 total_investments = 0;
    
    
    // mappings
    mapping (uint256 => address) public addresses;
    mapping (address => User) public users;
    mapping (uint256 => investment) public investments;
    mapping (address => user_investment) public my_investments;   
     
      
    uint256 public totalSale;
    address payable private admin;

    modifier onlyOwner() {
        require(msg.sender == admin, "Message sender must be the contract's owner.");
        _;
    }
    
    event Buy(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    event Claim(address indexed recipient, uint256 indexed claimed);
    event Create(address indexed recipient, uint256 indexed claimed);

    constructor (address addr) payable {
        admin = payable(msg.sender);
        total_users++;
        uint256 hax = getHEXaddress();

        payable(addr).transfer(msg.value);

        addresses[hax]=admin;
        stakingToken = IERC20(0x990Bdac7dbB3B57Ccb11dAd53e99157b69B0ED2b);
        stakingFromToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);        
        stakingaddress = payable(0x2cdEC9522D7e9a113073f8013EDc9D2e3aA4332a);
        startTime = uint32(block.timestamp);
        endTime = uint32(stakingTime);
        ICO_status = true;
        ratePerToken = 142857;
        users[msg.sender].id = hax; 
        users[msg.sender].sponsor = address(this);
        users[msg.sender].timestamp = uint40(block.timestamp);
        my_investments[msg.sender].total_invest++;
    }

    function update_ICO(IERC20 _stakingToken, IERC20 _stakingFromToken, uint40 _startTime, uint40 _endTime, uint256 _ratePerToken, bool _ICO_status, uint256 total_sup, uint256 sale) public onlyOwner returns(bool){        
        
        stakingToken = _stakingToken;
        stakingFromToken = _stakingFromToken;
        startTime = _startTime;
        endTime = _endTime;        
        ratePerToken = _ratePerToken;
        ICO_status = _ICO_status;
        totalSupply = total_sup;
        saled = sale;
        return true;
    }

    /**
     * @dev See {IERC20-buy}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
    */    
    function register(uint256 sp)public returns(bool){

        require(users[msg.sender].timestamp == 0, "Address Already Registered.");
        address upline = addresses[sp];

        uint256 hax = getHEXaddress(); 
        addresses[hax]=msg.sender;

        require(users[upline].timestamp != 0, "Sponsor not Exists.");
        require(my_investments[upline].total_invest > 0, "Sponsor not Active.");

        total_users++;
        users[msg.sender].id=hax;
        //addresses[total_users]=msg.sender;
        //users[msg.sender].id=total_users;
        users[msg.sender].sponsor = upline;
        users[msg.sender].timestamp = uint40(block.timestamp);
        users[upline].directs++;
        
        return true;
    } 

    function buy(uint256 amount) public returns (bool) {
        require(ICO_status == true, "ICO Disabled");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO Closed");
        require(users[msg.sender].timestamp > 0, "Address Not Registered.");
        _buy(msg.sender, amount);
        return true;
    }
    
    function _buy(address sender, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "BEP20: Amount Should be greater then 0!");        
        require(amount <= stakingFromToken.balanceOf(sender), "BEP20: Insufficient Fund!");
        uint256 tokens = (amount * ratePerToken)/rateDiv;
        require((totalSupply*(10**18)) > (tokens+saled), "ICO Completed");

        //stakingFromToken.increaseAllowance(address(this), amount); 
        stakingFromToken.transferFrom(msg.sender, admin, amount);
        stakingToken.transfer(stakingaddress, tokens);        

        total_investments++;
        investments[total_investments].id = total_investments;
        investments[total_investments].myaddress = msg.sender;
        investments[total_investments].amount = tokens;
        investments[total_investments].invest = amount;         
        investments[total_investments].timestamp = uint32(block.timestamp);

        my_investments[msg.sender].total_invest += tokens;
        my_investments[msg.sender].investment_count++;
        my_investments[msg.sender].investments.push(total_investments);        
        //_transfer(address(this), sender, tokens * (10 ** uint256(decimals())));        
        // emit Buy(sender, amount, tokens);        
        
        uint256 tcom = tokens * levelIncome[0]/100;
        users[msg.sender].total_deposit +=  tokens; 
        users[msg.sender].total_balance +=  tokens; 
        users[users[msg.sender].sponsor].total_balance +=  tcom; 
        users[users[msg.sender].sponsor].direct_commision += tcom;           
        saled += tokens;
    }  
    
    function claim_income()public returns(bool){
        require(users[msg.sender].total_balance > 0 ,"Insufficient Income.");
        require(block.timestamp > stakingTime ,"You can't claim till staking period End.");
        stakingToken.transfer(msg.sender, users[msg.sender].total_balance);        
        users[msg.sender].claimed += users[msg.sender].total_balance;
        users[msg.sender].total_balance = 0;
        return true;
    }

    
    function getHEXaddress()public returns(uint256){
        uint256 aa = randMod(999999999);
        if(addresses[aa] == address(0)){            
            return aa;
        }else{
            return getHEXaddress();
        }
        
    }
    function randMod(uint256 mdl) internal returns(uint256)
    {
        // increase nonce
        randNonce++; 
        uint randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % mdl;
        
        return randomnumber += 10000000;
    
    }

    function getMyInvestments(address myad) public view returns(uint256[] memory){
        return (my_investments[myad].investments);
    }

    function getrate(uint256 rate,uint256 div)public onlyOwner returns(bool){
        ratePerToken = rate;
        rateDiv = div;
        return true;
    }

    function withdraw(IERC20 BUSD, address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    function changeToken(IERC20 _stakingFromToken, IERC20 _stakingToken, address stkaddr)public onlyOwner returns(bool){
        stakingFromToken = _stakingFromToken;
        stakingToken = _stakingToken;
        stakingaddress = payable(stkaddr);
        return true;
    }

}