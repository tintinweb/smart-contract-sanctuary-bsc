/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol
pragma solidity ^0.8.1;

contract AirDrop_LOE{
    
    IERC20 private token___;
    address private owner;     
    uint public buy_ratio_Token=10000;                      // 1 BNB = 10.000 T
    uint public sell_ratio_Token=12000;                     // 1 BNB = 12.000 T
    uint public minimum_buy_Token=10**17;                   // 0.001 BNB = 10 T
    uint public minimum_sell_Token=100*10**18;              // 100 T
    bool public buy_active = false;                         // false
    bool public sell_active = false;                        // false
    uint public timeStart;

    bool public claimStatus = true;
    uint public token_quantity_per_claim=600*10**18;
    uint public bnb_per_claim=2700000000000000;
    uint public commission_ref=4;
    uint public commission_ref_2=2;


    address[] public users_Claimed;

    constructor(address token_address){
        owner = msg.sender;
        token___ = IERC20(token_address);
        timeStart = block.timestamp;
    }

    function checkUserClaimed() public view returns(bool){
        bool check = false;
        for(uint i=0; i<users_Claimed.length; i++){
            if(users_Claimed[i]==msg.sender){
                check = true;
                break;
            }
        }
        return check;
    }

    function claim_token_no_ref() public payable{
        require(checkUserClaimed()==false, "Sorry, you have claimed already");
        require(claimStatus==true, "Sorry, you can not claim at this time");
        require(token___.balanceOf(address(this))>token_quantity_per_claim, "Sorry, we dont have token enough");
        require(msg.value>= bnb_per_claim, "Sorry, not enough BNB" );
        token___.transfer(msg.sender, token_quantity_per_claim);
        users_Claimed.push(msg.sender);
    }

    function claim_token_with_ref(address _ref) public payable{
        require(checkUserClaimed()==false, "Sorry, you have claimed already");
        require(claimStatus==true, "Sorry, you can not claim at this time");
        require(token___.balanceOf(address(this))>token_quantity_per_claim, "Sorry, we dont have token enough");
        require(msg.value>= bnb_per_claim, "Sorry, not enough BNB" );
        payable(_ref).transfer(msg.value/100*commission_ref);
        token___.transfer(msg.sender, token_quantity_per_claim);
        users_Claimed.push(msg.sender);
    }
    
    modifier checkMaster(){
        require(msg.sender == owner, "You are not allowed to process.");
        _;
    }

    function updateToken(address _newTokenAddress) public checkMaster{
        token___ = IERC20(_newTokenAddress);
    }

    function updateClaimRatio(bool _newStatus, uint _new_token_quantity_per_claim, uint _new_bnb_per_claim, uint _new_commission_ref, uint _new_commission_ref_2) public checkMaster{
        claimStatus = _newStatus;
        token_quantity_per_claim = _new_token_quantity_per_claim;
        bnb_per_claim = _new_bnb_per_claim;
        commission_ref = _new_commission_ref;
        commission_ref_2 = _new_commission_ref_2;
    }
    
    function buy_Token() public payable{
        require(buy_active==true, "[001] Token is not for buy right this time.");
        require(msg.value>=minimum_buy_Token, "[002] You can not buy less 10 T (0.001 BNB)"); 
        require(msg.value*buy_ratio_Token<= token___.balanceOf(address(this)), "[003] We dont have enought Token to sell right");
        token___.transfer(msg.sender, msg.value*buy_ratio_Token);
    }

    function buy_Token_ref_1(address ref1) public payable{
        require(buy_active==true, "[001] Token is not for buy right this time.");
        require(msg.value>=minimum_buy_Token, "[002] You can not buy less 10 T (0.001 BNB)"); 
        require(msg.value*buy_ratio_Token<= token___.balanceOf(address(this)), "[003] We dont have enought Token to sell right");
        payable(ref1).transfer(msg.value/100*commission_ref);
        token___.transfer(msg.sender, msg.value*buy_ratio_Token);
    }

    function buy_Token_ref_2(address ref1, address ref2) public payable{
        require(buy_active==true, "[001] Token is not for buy right this time.");
        require(msg.value>=minimum_buy_Token, "[002] You can not buy less 10 T (0.001 BNB)"); 
        require(msg.value*buy_ratio_Token<= token___.balanceOf(address(this)), "[003] We dont have enought Token to sell right");
        payable(ref1).transfer(msg.value/100*commission_ref);
        payable(ref2).transfer(msg.value/100*commission_ref_2);
        token___.transfer(msg.sender, msg.value*buy_ratio_Token);
    }
    
    function sell_Token(uint amount) public{
        require(sell_active==true, "[001] Token is not for sell right this time.");
        require(amount>=minimum_sell_Token, "[006]Minimum token is invalid");
        require(token___.allowance(msg.sender, address(this))>= amount, "[007] Please approve before sell token");
        require(token___.balanceOf(msg.sender)>=amount, "[008] You dont have Token enought to sell.");
        require(address(this).balance>amount/sell_ratio_Token, "[009] Sorry, we dont have enought BNB to sell right this time");
        token___.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount/sell_ratio_Token);
    }
    
    function update_Buy_Ratio_Token(uint newRatio) public checkMaster{
        require(newRatio>0, "[004] Token buy ratio must bigger than 0");
        buy_ratio_Token = newRatio;
    }
    
    function update_Sell_Ratio_Token(uint newRatio) public checkMaster{
        require(newRatio>0, "[005] Token sell ratio must bigger than 0");
        sell_ratio_Token = newRatio;
    }

    function update_Minimum_buy_Token(uint newRatio) public checkMaster{
        require(newRatio>0, "[004] New ratio must bigger than 0");
        minimum_buy_Token = newRatio;
    }

    function update_Minimum_sell_Token(uint newRatio) public checkMaster{
        require(newRatio>0, "[004] New ratio must bigger than 0");
        minimum_sell_Token = newRatio;
    }

    function updateSwapStatus(bool buyStatus, bool sellStatus) public checkMaster{
        buy_active = buyStatus;
        sell_active = sellStatus;
    }
    
    function withdraw_All() public checkMaster{
        payable(owner).transfer(address(this).balance);
        token___.transfer(owner, token___.balanceOf(address(this)));
    }
    
    function withdraw_BNB(uint amount) public checkMaster{
        require(amount<=address(this).balance);
        payable(owner).transfer(amount);
    }

    function withdraw_all_BNB() public checkMaster{
        require(address(this).balance>0, "[011] Sorry, no BNB to withdraw");
        payable(owner).transfer(address(this).balance);
    }

    function withdraw_Token(uint amount) public checkMaster{
        require(amount<=token___.balanceOf(address(this)));
        token___.transfer(owner, amount);
    }

    function withdraw_all_Token() public checkMaster{
        require(token___.balanceOf(address(this))>0);
        token___.transfer(owner, token___.balanceOf(address(this)));
    }

    // LockToken
    struct TokenOwner{
        address _Address;
        uint _tokenAmount;
        uint _timelock_from;
        uint _timelock;
        bool _status;    // false: unclaim
        uint _dateClaim;
    }

    TokenOwner[] public tokenOwners;

    function distributeToken(address Address, uint TokenAmount, uint From, uint Timelock) public checkMaster{
        tokenOwners.push(TokenOwner(Address, TokenAmount, From, Timelock, false, 0));
    }

    function getTokenOwnerDistributeQuantity() public view returns(uint) {
        return tokenOwners.length;
    }

    function getTokenOwnerDistributeDetail(uint ordering) public view returns(address, uint, uint, uint, bool, uint){
        require(ordering<tokenOwners.length);
        return( tokenOwners[ordering]._Address, tokenOwners[ordering]._tokenAmount, tokenOwners[ordering]._timelock_from, tokenOwners[ordering]._timelock, tokenOwners[ordering]._status, tokenOwners[ordering]._dateClaim );
    }

    function ownerClaimToken(uint ordering) public {
        require(ordering<tokenOwners.length, "[019] No token owners at this moment.");
        require(msg.sender==tokenOwners[ordering]._Address, "[020] Sorry, you do not have permission to claim tokens.");
        require(tokenOwners[ordering]._status==false, "[023] Sorry, tokens have been claimed already.");
        require(block.timestamp >= timeStart + tokenOwners[ordering]._timelock * 1 days, "[021] Sorry, you can not claim token at this time");
        require(token___.balanceOf(address(this))>tokenOwners[ordering]._tokenAmount, "[022] Sorry, do not have token enought to claim.");
        token___.transfer(tokenOwners[ordering]._Address, tokenOwners[ordering]._tokenAmount);
        tokenOwners[ordering]._status = true;
        tokenOwners[ordering]._dateClaim = block.timestamp;
    }

}