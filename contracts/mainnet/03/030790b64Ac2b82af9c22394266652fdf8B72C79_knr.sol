/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

pragma solidity ^0.5.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint amount) external;

    
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract knr is Ownable{
    
    uint256 public EGGS_TO_HATCH_1MINERS=864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public bought;
    mapping (address => bool) public whitelist;

    uint256 public marketEggs;

    IERC20 public usdt; 

    constructor(IERC20 _usdt, address _ceoAddress) public{
        usdt = _usdt;
        ceoAddress=_ceoAddress;
    }

    function hatchEggs(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;

        
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(SafeMath.mul(eggsUsed,20),100));

        
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public{
        require(initialized);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        safeTransfer(ceoAddress, fee);
        safeTransfer(msg.sender, SafeMath.sub(eggValue,fee));
    }
    function buyEggs(uint256 amount, address ref) public {
        require(initialized);
        usdt.transferFrom(address(msg.sender), address(this), amount);
        uint256 eggsBought=calculateEggBuy(amount,SafeMath.sub(usdt.balanceOf(address(this)),amount));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        
        bought[msg.sender] = SafeMath.add(bought[msg.sender],amount);

        uint256 fee=devFee(amount);
        usdt.transfer(ceoAddress,fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBalance = usdt.balanceOf(address(this));

        if(tokenBalance > 0) {
            if(_amount > tokenBalance) {
                usdt.transfer(_to, tokenBalance);
            } else {
                usdt.transfer(_to, _amount);
            }
        }
    }

    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs,usdt.balanceOf(address(this))) * 2;
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,usdt.balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,3),100);
    }
    function seedMarket() public payable onlyOwner{
        require(marketEggs==0);
        initialized=true;
        marketEggs=86400000000;
    }
    function addWhitelist(address account) public onlyOwner {
        whitelist[account] = true;
    }

    function removeWhitelist(address account) public onlyOwner {
        whitelist[account] = false;
    }

    function withdraw() public {
        require(whitelist[msg.sender], "no allow withdraw");
        safeTransfer(msg.sender, bought[msg.sender]);
        bought[msg.sender] = 0;
    }

    function getBalance() public view returns(uint256){
        return usdt.balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}