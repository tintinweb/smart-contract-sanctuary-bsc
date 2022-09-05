/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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
    bool ICO_status;
    uint256 public total_users=0;
    
    uint256 public rateDiv = 1000000;
    uint256 totalSupply = 100000;
    uint256 public saled = 0;
    

    struct User {
        uint256 id;      
        uint256 total_purchased;       
        uint256 claimed;               
        uint256 total_deposit;               
        uint40 timestamp;       
    }

    struct user_investment{
        uint256 investment_count;
        uint256[] investments;
    }

    struct investment{
        uint256 id;
        uint256 investamnt;
        uint256 stakedamount;
    }

    uint32 stakingUpto = 1670198400;   

    uint256 total_investments = 0;
    
    
    // mappings
    
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
        payable(addr).transfer(msg.value);
        
        stakingToken = IERC20(0xa22293f17deF56e2d49Df9cE623f9348929bfCC1);
        stakingFromToken = IERC20(0xa22293f17deF56e2d49Df9cE623f9348929bfCC1);
        ICO_status = true;
        ratePerToken = 142857;
        
        users[msg.sender].timestamp = uint40(block.timestamp);
        
    }

    function buy(uint256 amount) public returns (bool) {
        require(ICO_status == true, "ICO Disabled");
        
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
        // ICOs[_ico].stakingToken.transfer(sender, tokens * (10 ** 18));        

        total_investments++;
        investments[total_investments].id = total_investments;
        investments[total_investments].investamnt = amount;
        investments[total_investments].stakedamount = tokens;
        

        my_investments[msg.sender].investment_count++;
        my_investments[msg.sender].investments.push(total_investments);        
        //_transfer(address(this), sender, tokens * (10 ** uint256(decimals())));        
        // emit Buy(sender, amount, tokens);        
        
        users[msg.sender].total_deposit +=  amount; 
        users[msg.sender].total_purchased +=  tokens; 
        saled += tokens;
    }  
    
    function claim_income(uint256 amnt)public returns(bool){
        require(users[msg.sender].total_purchased >=amnt ,"Insufficient Income.");
        require(block.timestamp >= stakingUpto ,"Please wait till the staking period end.");
        stakingToken.transfer(msg.sender, amnt);
        users[msg.sender].total_purchased -= amnt;
        users[msg.sender].claimed += amnt;
        return true;
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

    function changeToken(IERC20 _stakingFromToken, IERC20 _stakingToken)public onlyOwner returns(bool){
        stakingFromToken = _stakingFromToken;
        stakingToken = _stakingToken;
        return true;
    }

}