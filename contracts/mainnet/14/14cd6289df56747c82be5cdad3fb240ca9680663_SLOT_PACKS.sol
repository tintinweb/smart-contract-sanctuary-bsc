/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
                               
pragma solidity ^0.8.7;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract SLOT_PACKS is Context {
    using SafeMath for uint256;
    mapping (uint256 => uint256) packPrice;

    mapping (uint256  => uint256) public credits;

    mapping (address  => uint256) public packPlayer;
    mapping (address  => uint256) public packPlayerCredits;

    mapping (address  => uint256) public playerWithdrawn;

    mapping (address  => uint256) public playerRewards;

    address [] slotGamers;

    mapping (address => bool) public ADMIN;
    mapping (address => bool) public cashierWallet;
    address payable public slotWallet;
    uint256 public slotFee;
    uint256 private withdrawnSlotAdmin;  
    uint256 public totalSupply;
    bool contractIsLive = true;
    bool autoClaim = true;

    uint256  creditPrice = 0.002 ether;


    constructor () {
        
        slotWallet  = payable(msg.sender);
        cashierWallet[msg.sender] = true;
        ADMIN[msg.sender] = true;

        packPrice[1] = 0.002 ether;
        packPrice[2] = 0.02 ether;
        packPrice[3] = 0.1 ether;
        packPrice[4] = 0.2 ether;
        
        credits[1] = 1;
        credits[2] = 10;
        credits[3] = 50;
        credits[4] = 100;

        slotFee = 0; //0%

    }
   
    //add user enabled to manage contract
    function addAdmin(address _address, bool isOn) public returns (bool)  {
        require(ADMIN[msg.sender], "Only Admin can act with this");
        ADMIN[_address] = isOn;
        return isOn;
    }
    function addCashierWallet(address _address, bool isOn) public returns (bool)  {
        require(slotWallet == msg.sender, "Only Admin can act with this");
        cashierWallet[_address] = isOn;
        return isOn;
    }
    function setContractLive (bool isOn) public  returns (bool ){
        require(ADMIN[msg.sender] , "Only Admin can act here");
        contractIsLive = isOn;
        return isOn;
    }
    function setCreditPrice (uint256 _price) public  returns (bool ){
        require(ADMIN[msg.sender] , "Only Admin can act here");
        creditPrice = _price;
        return true;
    }
    function setSlotFee (uint256 _fee) public  returns (bool ){
        require(ADMIN[msg.sender] , "Only Admin can act here");
        slotFee = _fee;
        return true;
    }
    function setAutoClaim( bool isOn) public returns (bool)  {
        require(ADMIN[msg.sender], "Only Admin can act with this");
        autoClaim = isOn;
        return isOn;
    }
    
    function setPackPrice(uint256 _pack, uint256 _price) public {
        require(ADMIN[msg.sender], "Only Admin can act with this");
        packPrice[_pack] = _price;
    }

    function setPackCredits(uint256 _pack, uint256 _credits) public {
        require(ADMIN[msg.sender], "Only Admin can act with this");
        credits[_pack] = _credits;
    }

    function buyPack (uint256 _pack)  external payable returns (bool success){
        uint256 amount = msg.value;
        require(contractIsLive == true ,"Updated Pack Contract is live");
        require(amount >= packPrice[_pack],"Not enought amount to buy this Pack");
        totalSupply++;
        packPlayer[msg.sender] = _pack;
        packPlayerCredits[msg.sender] = packPlayerCredits[msg.sender].add(credits[_pack]);// 
        
        payable(slotWallet).transfer(amount * slotFee / 100);
         
        return true;
    }
    function getSlotGamers() public view returns (address[] memory){
        require(ADMIN[msg.sender], "Only Admin can act with this");
        return slotGamers;
    }
    
    function getPackPrice(uint256 _pack) public view returns (uint256){
        return packPrice[_pack];
    }

// @dev this return only the purchased credits
    function getPlayerCredits(address _player) public view returns (uint256){
        return packPlayerCredits[_player];
    }

    function getPlayerWithdrawn(address _player) public view returns (uint256){
        return playerWithdrawn[_player];
    }
    
    function allowWithdrawWinner(address _winner, uint256 _credits) public{
        require(cashierWallet[msg.sender], "Only cashier can act with this");
        uint256 amount = _credits.mul(creditPrice);
        if(autoClaim){
                payable(_winner).transfer(amount);
                    } else{
                playerRewards[_winner] = amount;
            }
        playerWithdrawn[_winner] = playerWithdrawn[_winner].add(amount);
    }
    function allowWithdrawWinnerArray(address[] memory _winner, uint256[] memory _weiAmount) public{
        require(cashierWallet[msg.sender], "Only cashier  can act with this");
        for (uint a=0; a < _winner.length; a++) {
            if(autoClaim){
                payable(_winner[a]).transfer(_weiAmount[a]);
                } else{
                playerRewards[_winner[a]] = _weiAmount[a];
            }
        }
    }

    function withdrawWinner() public{
        require(playerRewards[msg.sender] > 0, "Only user can claim Prizes");
        payable(msg.sender).transfer(playerRewards[msg.sender]);
        playerRewards[msg.sender] = 0;
    }
    function getAllowanceRewards(address _winner) public view returns (uint256){
        return playerRewards[_winner];
    }

    function withdrawSlotAdmin(uint256 _weiAmount) public{
        payable(slotWallet).transfer(_weiAmount);
        withdrawnSlotAdmin = withdrawnSlotAdmin.add(_weiAmount);
    }
    function getWithdrawnSlotAdmin() public view returns (uint256){
        require(ADMIN[msg.sender], "Only Admin can act with this");
        return withdrawnSlotAdmin;
    }

function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}
function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }

receive() external payable {}

}