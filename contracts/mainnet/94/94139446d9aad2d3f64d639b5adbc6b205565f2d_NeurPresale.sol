/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-21
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner
     */
    function transferOwnership(address payable adr) external onlyOwner {
        require(adr !=  address(0),  "adr is a zero address");
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXRouter {
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract NeurPresale is Auth {

    using SafeMath for uint256;
    address constant DEAD = address(0);
    address constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955; 
    address public PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private NeurContract = 0x80E7107250bF2E31eB35131E24Cc9502aE5F05d0;

    address private reciever;
    uint256 public referReward = 30;
    bool public presaleStarted = false;
    bool public shouldCheckWinner = true;

    // presale
    //
    uint256[2] public raisedAmount = [0 , 0];
    uint256[2] public minimumBuy = [0 , 0];
    uint256[] public buyAmount;
    uint256[] public bonusAmount;
    IDEXRouter public router;

    // rewards
    //
    address[3] public referralsWinners = [DEAD , DEAD , DEAD];
    address[3] public buyingWinners = [DEAD , DEAD , DEAD];
    mapping (address => uint256) referralsAmount;
    mapping (address => uint256) buyingAmount;

    constructor () Auth(msg.sender) {
        router = IDEXRouter(PANCAKE_ROUTER);
        reciever = owner;        
        bonusAmount = [50 , 55 , 60 , 65 , 75];
        buyAmount = [200 , 1000 , 2500 ,5000];
    }

    function setPreasleStatus(bool status) external onlyOwner{
        presaleStarted = status;
    }

    function checkBonus(uint256 _amount) public view returns (uint256) {
        uint256 reward = 0;
        if(_amount <= (buyAmount[0] * (10 ** 18))){
            reward = _amount * bonusAmount[0];
        }else if (_amount <= (buyAmount[1] * (10 ** 18))){
            reward = _amount * bonusAmount[1];
        }else if (_amount <= (buyAmount[2] * (10 ** 18))){
            reward = _amount * bonusAmount[2];
        }else if (_amount <= (buyAmount[3] * (10 ** 18))){
            reward = _amount * bonusAmount[3];
        }else if (_amount > (buyAmount[3] * (10 ** 18))){
            reward = _amount * bonusAmount[4];
        }
        return reward;
        
    }

    function buyWithBnb(address _refer) public payable returns(bool){
        require(presaleStarted == true , "presale not started!");
        require(msg.value  >= minimumBuy[0]);
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = BNB;
        uint256[] memory amounts = router.getAmountsIn(msg.value , path);
        uint256 _amount = amounts[0]; 
        uint256 _token = checkBonus(_amount);
        payable(reciever).transfer(address(this).balance);
        IBEP20(NeurContract).transfer(msg.sender, _token);
        checkRefAndRaise(_amount , _token , _refer);
        return true;
    }

    function buyWithUsd(uint256 _amount, address _refer) public returns(bool){
        require(presaleStarted == true , "presale not started!");
        require(_amount  >= minimumBuy[1]);
        uint256 _token = checkBonus(_amount);
        IBEP20(USDT).transferFrom(msg.sender , reciever, _amount);
        IBEP20(NeurContract).transfer(msg.sender, _token);
        checkRefAndRaise(_amount , _token , _refer);
        return true;
    }

    function checkRefAndRaise(uint256 _amount , uint256 _token ,address _refer) internal {
        if(_refer != address(0) && _refer != DEAD && _refer != msg.sender && _refer != address(this)){
            uint256 referTokens = _token.mul(referReward).div(1000);
            IBEP20(NeurContract).transfer(_refer, referTokens);
            raisedAmount[1] = raisedAmount[1] + referTokens;
        }
        raisedAmount[0] = raisedAmount[0] + _amount;
        raisedAmount[1] = raisedAmount[1] + _token;
        if(shouldCheckWinner){
            checkWinner(msg.sender , _amount , _refer);
        }
    }

    function checkWinner(address _buyer , uint256 _USDT , address _referrer ) internal {
        if(_referrer != address(0) && _referrer != DEAD && _referrer != _buyer && _referrer != address(this)){
            uint256 newRefAmount = referralsAmount[_referrer] + _USDT;
            referralsAmount[_referrer] = newRefAmount;

            if(referralsAmount[referralsWinners[2]] <= newRefAmount && newRefAmount < referralsAmount[referralsWinners[1]]){
                referralsWinners[2] = _referrer;
            }else if(referralsAmount[referralsWinners[1]] <= newRefAmount && newRefAmount < referralsAmount[referralsWinners[0]]){
                referralsWinners[2] = referralsWinners[1];
                referralsWinners[1] = _referrer;
            }else if(newRefAmount >= referralsAmount[referralsWinners[0]]){
                referralsWinners = [_referrer , referralsWinners[0] , referralsWinners[1]];
            }
        }
        uint256 newBuyAmount = buyingAmount[_buyer] + _USDT;
        buyingAmount[_buyer] = newBuyAmount;

        if(buyingAmount[buyingWinners[2]] <= newBuyAmount && newBuyAmount < buyingAmount[buyingWinners[1]]){
            buyingWinners[2] = _buyer;
        }else if(buyingAmount[buyingWinners[1]] <= newBuyAmount && newBuyAmount < buyingAmount[buyingWinners[0]]){
            buyingWinners = [buyingWinners[0] , _buyer , buyingWinners[1]];
        }else if(newBuyAmount >= buyingAmount[buyingWinners[0]]){
            buyingWinners = [_buyer , buyingWinners[0] , buyingWinners[1]];
        }
    }

    function getBonusAmount() public view returns(uint256[] memory){
        return bonusAmount;
    }

    function getBuyAmount() public view returns(uint256[] memory){
        return buyAmount;
    }

    function getRaisedAmount() public view returns(uint256[2] memory){
        return raisedAmount;
    }

    function getBuyerWinners() public view returns(address[3] memory){
        return buyingWinners;
    }

    function getBuyerWinners(address[3] memory _buyers) public view returns(uint256[3] memory){
        return [buyingAmount[_buyers[0]] ,referralsAmount[_buyers[1]] ,referralsAmount[_buyers[2]] ];
    }

    function getRefferWinners() public view returns(address[3] memory){
        return referralsWinners;
    }

    function getRefferByAddress(address _address) public view returns(uint256){
        return referralsAmount[_address];
    }

    function getBoughtByAddress(address _address) public view returns(uint256){
        return buyingAmount[_address];
    }

    function getRefferWinners(address[3] memory _winners) public view returns(uint256[3] memory){
        return [referralsAmount[_winners[0]] ,referralsAmount[_winners[1]] ,referralsAmount[_winners[2]] ];
    }

    function updateAmounts(bool _flag , uint256[] memory _value) external onlyOwner returns(bool){
        if(_flag == true){
            bonusAmount = _value;
        }else{
            buyAmount = _value;
        }
        return true;
    }

    function changeReceiver(address _address) external onlyOwner {
        require(_address != DEAD && _address != address(0));
        reciever = _address;
    }

    function claimBNB() public onlyOwner {
        require(address(this).balance > 0 , "no BNB balance in contract");
        payable(owner).transfer(address(this).balance);
    }
    
    function claimToken(address _token , uint256 _amount) public onlyOwner {
        uint256 _tokenBalance = IBEP20(_token).balanceOf(address(this));
        _amount = _amount * (10 ** IBEP20(_token).decimals());
        require(_tokenBalance > _amount , "no token balance in contract");
        IBEP20(_token).transfer(owner , _amount);
    }
    
    function setReferPercent(uint256 _percent) public onlyOwner {
        referReward = _percent;
    }

    function setShouldCheckWinner(bool _status) public onlyOwner {
        shouldCheckWinner = _status;
    }
 
   function setMinimumBuy(uint256[2] memory _minimum) public onlyOwner {
        minimumBuy = _minimum;
    }

}