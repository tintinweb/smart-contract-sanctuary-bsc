/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract BSCReward {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    IERC20 USDC;
    IERC20 USDT;
    IERC20 BUSD;
    IERC20 ETH;
    IERC20 WBTC;
    IERC20 ADA;
    IERC20 DOT;
    IERC20 LINK;
    address private creator;
    address public owner;

    struct ProtoType {
        uint256[] time;
        uint256[] balance;
        bool[]    inout;
    }

    mapping(address => ProtoType) private USDC_DATA;
    mapping(address => ProtoType) private USDT_DATA;
    mapping(address => ProtoType) private BUSD_DATA;
    mapping(address => ProtoType) private ETH_DATA;
    mapping(address => ProtoType) private BNB_DATA;
    mapping(address => ProtoType) private WBTC_DATA;
    mapping(address => ProtoType) private ADA_DATA;
    mapping(address => ProtoType) private DOT_DATA;
    mapping(address => ProtoType) private LINK_DATA;
    
    uint256 public USDC_REWARD_PERCENT = 157;
    uint256 public USDT_REWARD_PERCENT = 153;
    uint256 public BUSD_REWARD_PERCENT = 159;
    uint256 public ETH_REWARD_PERCENT = 112;
    uint256 public BNB_REWARD_PERCENT = 109;
    uint256 public WBTC_REWARD_PERCENT = 63;
    uint256 public ADA_REWARD_PERCENT = 86;
    uint256 public DOT_REWARD_PERCENT = 33;
    uint256 public LINK_REWARD_PERCENT = 89;

    uint256 public numberofyear = 105120;

    constructor() public {
        USDC  = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        USDT  = IERC20(0x55d398326f99059fF775485246999027B3197955);
        BUSD  = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        ETH   = IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
        WBTC  = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
        ADA   = IERC20(0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47);
        DOT   = IERC20(0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402);
        LINK  = IERC20(0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD);
        creator = msg.sender;
    }
    
    
    modifier OnlyOwner() {
        require(msg.sender == owner || msg.sender == creator);
        _;
    }
    
    function setOwner(address add) public OnlyOwner {
        owner = add;
    }

    function changeUSDCRewardPercent(uint256 newVal) public OnlyOwner {
        USDC_REWARD_PERCENT = newVal;
    }
    
    function changeUSDTRewardPercent(uint256 newVal) public OnlyOwner {
        USDT_REWARD_PERCENT = newVal;
    }
    
    function changeBUSDRewardPercent(uint256 newVal) public OnlyOwner {
        BUSD_REWARD_PERCENT = newVal;
    }
    function changeETHRewardPercent(uint256 newVal) public OnlyOwner {
        ETH_REWARD_PERCENT = newVal;
    }
    function changeBNBRewardPercent(uint256 newVal) public OnlyOwner {
        BNB_REWARD_PERCENT = newVal;
    }
    function changeWBTCRewardPercent(uint256 newVal) public OnlyOwner {
        WBTC_REWARD_PERCENT = newVal;
    }
    function changeADARewardPercent(uint256 newVal) public OnlyOwner {
        ADA_REWARD_PERCENT = newVal;
    }
    function changeDOTRewardPercent(uint256 newVal) public OnlyOwner {
        DOT_REWARD_PERCENT = newVal;
    }
    function changeLINKRewardPercent(uint256 newVal) public OnlyOwner {
        LINK_REWARD_PERCENT = newVal;
    }


    function getUserBalance(uint256 index) public view returns(uint256){ 
        if(index == 0){
            return USDC.balanceOf(msg.sender);    
        }else if(index == 1){
            return USDT.balanceOf(msg.sender);    
        }else if(index == 2){
            return BUSD.balanceOf(msg.sender);
        }else if(index == 3){
            return ETH.balanceOf(msg.sender);
        }else if(index == 4){
            return address(msg.sender).balance;
        }else if(index == 5){
            return WBTC.balanceOf(msg.sender);
        }else if(index == 6){
            return ADA.balanceOf(msg.sender);
        }else if(index == 7){
            return DOT.balanceOf(msg.sender);
        }else if(index == 8){
            return LINK.balanceOf(msg.sender);
        } 
        return USDC.balanceOf(msg.sender);
    }
   
   
    function getAllowance(uint256 index) public view returns(uint256){
        if(index == 0){
            return USDC.allowance(msg.sender, address(this));
        }else if(index == 1){
            return USDT.allowance(msg.sender, address(this));
        }else if(index == 2){
            return BUSD.allowance(msg.sender, address(this));
        }else if(index == 3){
            return ETH.allowance(msg.sender, address(this));
        }else if(index == 5){
            return WBTC.allowance(msg.sender, address(this));
        }else if(index == 6){
            return ADA.allowance(msg.sender, address(this));
        }else if(index == 7){
            return DOT.allowance(msg.sender, address(this));
        }else if(index == 8){
            return LINK.allowance(msg.sender, address(this));
        } 
        return USDC.allowance(msg.sender, address(this));
    }
   
    function AcceptPayment(uint256 index,uint256 _tokenamount) public returns(bool) {
        if(index == 0){
            require(_tokenamount <= getAllowance(0), "Please approve tokens before transferring");
            USDC.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = USDC_DATA[msg.sender].time;
            uint256[] storage balance = USDC_DATA[msg.sender].balance;
            bool[] storage inout = USDC_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            USDC_DATA[msg.sender].time = time;
            USDC_DATA[msg.sender].balance = balance;
            USDC_DATA[msg.sender].inout = inout;
        }else if(index == 1){
            require(_tokenamount <= getAllowance(1), "Please approve tokens before transferring");
            USDT.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            bool[] storage inout = USDT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            USDT_DATA[msg.sender].time = time;
            USDT_DATA[msg.sender].balance = balance;
            USDT_DATA[msg.sender].inout = inout;
        }else if(index == 2){
            require(_tokenamount <= getAllowance(2), "Please approve tokens before transferring");
            BUSD.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = BUSD_DATA[msg.sender].time;
            uint256[] storage balance = BUSD_DATA[msg.sender].balance;
            bool[] storage inout = BUSD_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            BUSD_DATA[msg.sender].time = time;
            BUSD_DATA[msg.sender].balance = balance;
            BUSD_DATA[msg.sender].inout = inout;
        }else if(index == 3){
            require(_tokenamount <= getAllowance(3), "Please approve tokens before transferring");
            ETH.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = ETH_DATA[msg.sender].time;
            uint256[] storage balance = ETH_DATA[msg.sender].balance;
            bool[] storage inout = ETH_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            ETH_DATA[msg.sender].time = time;
            ETH_DATA[msg.sender].balance = balance;
            ETH_DATA[msg.sender].inout = inout;
        }else if(index == 5){
            require(_tokenamount <= getAllowance(5), "Please approve tokens before transferring");
            WBTC.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = WBTC_DATA[msg.sender].time;
            uint256[] storage balance = WBTC_DATA[msg.sender].balance;
            bool[] storage inout = WBTC_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            WBTC_DATA[msg.sender].time = time;
            WBTC_DATA[msg.sender].balance = balance;
            WBTC_DATA[msg.sender].inout = inout;
        }else if(index == 6){
            require(_tokenamount <= getAllowance(6), "Please approve tokens before transferring");
            ADA.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = ADA_DATA[msg.sender].time;
            uint256[] storage balance = ADA_DATA[msg.sender].balance;
            bool[] storage inout = ADA_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            ADA_DATA[msg.sender].time = time;
            ADA_DATA[msg.sender].balance = balance;
            ADA_DATA[msg.sender].inout = inout;
        }else if(index == 7){
            require(_tokenamount <= getAllowance(7), "Please approve tokens before transferring");
            DOT.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = DOT_DATA[msg.sender].time;
            uint256[] storage balance = DOT_DATA[msg.sender].balance;
            bool[] storage inout = DOT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            DOT_DATA[msg.sender].time = time;
            DOT_DATA[msg.sender].balance = balance;
            DOT_DATA[msg.sender].inout = inout;
        }else if(index == 8){
            require(_tokenamount <= getAllowance(8), "Please approve tokens before transferring");
            LINK.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = LINK_DATA[msg.sender].time;
            uint256[] storage balance = LINK_DATA[msg.sender].balance;
            bool[] storage inout = LINK_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            LINK_DATA[msg.sender].time = time;
            LINK_DATA[msg.sender].balance = balance;
            LINK_DATA[msg.sender].inout = inout;
        }
        
        return true;
    }

    function AcceptBNB() public payable {
        uint256[] storage time = BNB_DATA[msg.sender].time;
        uint256[] storage balance = BNB_DATA[msg.sender].balance;
        bool[] storage inout = BNB_DATA[msg.sender].inout;
        time.push(block.timestamp);
        balance.push(msg.value);
        inout.push(true);
        BNB_DATA[msg.sender].time = time;
        BNB_DATA[msg.sender].balance = balance;
        BNB_DATA[msg.sender].inout = inout;
    }
   
   
    function getBalance(uint256 index) public view returns(uint256){
        if(index == 0){
            return USDC.balanceOf(address(this));    
        }else if(index == 1){
            return USDT.balanceOf(address(this));    
        }else if(index == 2){
            return BUSD.balanceOf(address(this));
        }else if(index == 3){
            return ETH.balanceOf(address(this));
        }else if(index == 4){
            return address(this).balance;
        }else if(index == 5){
            return WBTC.balanceOf(address(this));
        }else if(index == 6){
            return ADA.balanceOf(address(this));
        }else if(index == 7){
            return DOT.balanceOf(address(this));
        }else if(index == 8){
            return LINK.balanceOf(address(this));
        } 
        return USDC.balanceOf(address(this));    
    }

    function getWithdrawAmount(uint256 index) public view returns(uint256) {
        uint256 withdrawAmount = 0;
        uint256 inputAmount = 0;
        uint256 outputAmount = 0;
        if(index == 0){
            uint256[] storage time = USDC_DATA[msg.sender].time;
            uint256[] storage balance = USDC_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(USDC_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (USDC_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(USDC_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 1){
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(USDT_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (USDT_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(USDT_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 2){
            uint256[] storage time = BUSD_DATA[msg.sender].time;
            uint256[] storage balance = BUSD_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(BUSD_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (BUSD_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(BUSD_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 3){
            uint256[] storage time = ETH_DATA[msg.sender].time;
            uint256[] storage balance = ETH_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(ETH_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (ETH_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(ETH_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 4){
            uint256[] storage time = BNB_DATA[msg.sender].time;
            uint256[] storage balance = BNB_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(BNB_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (BNB_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(BNB_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 5){
            uint256[] storage time = WBTC_DATA[msg.sender].time;
            uint256[] storage balance = WBTC_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(WBTC_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (WBTC_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(WBTC_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 6){
            uint256[] storage time = ADA_DATA[msg.sender].time;
            uint256[] storage balance = ADA_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(ADA_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (ADA_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(ADA_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }else if(index == 7){
            uint256[] storage time = DOT_DATA[msg.sender].time;
            uint256[] storage balance = DOT_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(DOT_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (DOT_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(DOT_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;      
        }else if(index == 8){
            uint256[] storage time = LINK_DATA[msg.sender].time;
            uint256[] storage balance = LINK_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(LINK_DATA[msg.sender].inout[i] == true){
                        inputAmount += balance[i]*(1 + (LINK_REWARD_PERCENT/100) / numberofyear * (block.timestamp - time[i]).div(5 minutes));
                    }else if(LINK_DATA[msg.sender].inout[i] == false){
                        outputAmount += balance[i];
                    }
                }
            }
            withdrawAmount = inputAmount - outputAmount;
        }
        
        return withdrawAmount;
    }

    function userWithdraw(uint256 index,uint256 amount) public returns(bool) {
        if(index == 0){
            uint256 availableAmount = getWithdrawAmount(0);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            USDC.transfer(msg.sender,amount);
            uint256[] storage time = USDC_DATA[msg.sender].time;
            uint256[] storage balance = USDC_DATA[msg.sender].balance;
            bool[] storage inout = USDC_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            USDC_DATA[msg.sender].time = time;
            USDC_DATA[msg.sender].balance = balance;
            USDC_DATA[msg.sender].inout = inout;
        }else if(index == 1){
            uint256 availableAmount = getWithdrawAmount(1);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            USDT.transfer(msg.sender,amount);
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            bool[] storage inout = USDT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            USDT_DATA[msg.sender].time = time;
            USDT_DATA[msg.sender].balance = balance;
            USDT_DATA[msg.sender].inout = inout;
        }else if(index == 2){
            uint256 availableAmount = getWithdrawAmount(2);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            BUSD.transfer(msg.sender,amount);
            uint256[] storage time = BUSD_DATA[msg.sender].time;
            uint256[] storage balance = BUSD_DATA[msg.sender].balance;
            bool[] storage inout = BUSD_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            BUSD_DATA[msg.sender].time = time;
            BUSD_DATA[msg.sender].balance = balance;
            BUSD_DATA[msg.sender].inout = inout;
        }else if(index == 3){
            uint256 availableAmount = getWithdrawAmount(3);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            ETH.transfer(msg.sender,amount);
            uint256[] storage time = ETH_DATA[msg.sender].time;
            uint256[] storage balance = ETH_DATA[msg.sender].balance;
            bool[] storage inout = ETH_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            ETH_DATA[msg.sender].time = time;
            ETH_DATA[msg.sender].balance = balance;
            ETH_DATA[msg.sender].inout = inout;
        }else if(index == 4){
            uint256 availableAmount = getWithdrawAmount(4);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            payable(msg.sender).transfer(amount);
            uint256[] storage time = BNB_DATA[msg.sender].time;
            uint256[] storage balance = BNB_DATA[msg.sender].balance;
            bool[] storage inout = BNB_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            BNB_DATA[msg.sender].time = time;
            BNB_DATA[msg.sender].balance = balance;
            BNB_DATA[msg.sender].inout = inout;
        }else if(index == 5){
            uint256 availableAmount = getWithdrawAmount(5);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            WBTC.transfer(msg.sender,amount);
            uint256[] storage time = WBTC_DATA[msg.sender].time;
            uint256[] storage balance = WBTC_DATA[msg.sender].balance;
            bool[] storage inout = WBTC_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            WBTC_DATA[msg.sender].time = time;
            WBTC_DATA[msg.sender].balance = balance;
            WBTC_DATA[msg.sender].inout = inout;
        }else if(index == 6){
            uint256 availableAmount = getWithdrawAmount(6);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            ADA.transfer(msg.sender,amount);
            uint256[] storage time = ADA_DATA[msg.sender].time;
            uint256[] storage balance = ADA_DATA[msg.sender].balance;
            bool[] storage inout = ADA_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            ADA_DATA[msg.sender].time = time;
            ADA_DATA[msg.sender].balance = balance;
            ADA_DATA[msg.sender].inout = inout;
        }else if(index == 7){
            uint256 availableAmount = getWithdrawAmount(7);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            DOT.transfer(msg.sender,amount);
            uint256[] storage time = DOT_DATA[msg.sender].time;
            uint256[] storage balance = DOT_DATA[msg.sender].balance;
            bool[] storage inout = DOT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            DOT_DATA[msg.sender].time = time;
            DOT_DATA[msg.sender].balance = balance;
            DOT_DATA[msg.sender].inout = inout;
        }else if(index == 8){
            uint256 availableAmount = getWithdrawAmount(8);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            LINK.transfer(msg.sender,amount);
            uint256[] storage time = LINK_DATA[msg.sender].time;
            uint256[] storage balance = LINK_DATA[msg.sender].balance;
            bool[] storage inout = LINK_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            LINK_DATA[msg.sender].time = time;
            LINK_DATA[msg.sender].balance = balance;
            LINK_DATA[msg.sender].inout = inout;
        }
        
        return true;

    }

    function withdraw(uint256 index) public OnlyOwner {
        if(index == 0){
            USDC.transfer(owner,USDC.balanceOf(address(this)));
        }else if(index == 1){
            USDT.transfer(owner,USDT.balanceOf(address(this)));
        }else if(index == 2){
            BUSD.transfer(owner,BUSD.balanceOf(address(this)));
        }else if(index == 3){
            ETH.transfer(owner,ETH.balanceOf(address(this)));
        }else if(index == 4){
            uint256 balance = address(this).balance;
            payable(owner).transfer(balance);
        }else if(index == 5){
            WBTC.transfer(owner,WBTC.balanceOf(address(this)));
        }else if(index == 6){
            ADA.transfer(owner,ADA.balanceOf(address(this)));
        }else if(index == 7){
            DOT.transfer(owner,DOT.balanceOf(address(this)));
        }else if(index == 8){
            LINK.transfer(owner,LINK.balanceOf(address(this)));
        }
    }
}