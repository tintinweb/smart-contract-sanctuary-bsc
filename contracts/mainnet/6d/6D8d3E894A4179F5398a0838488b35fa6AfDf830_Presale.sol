/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

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

/**
 * BEP20 standard interface.
 */
interface ERC20 {
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

contract Presale {
    using SafeMath for uint256;
    address public _owner;
    address payable _collection;
    ERC20 public _claimToken;
    ERC20 public _payToken;

    uint public _pay = 100 ether;

    uint public _saleStartTime = 0;
    uint public _saleEndTime = 0;
    uint public _claimStartTime = 0;

    uint public _A = 10;
    uint public _B = 5;

    uint public _creation = 100;
    uint public _plain = 10;
    uint public _creationCount = 0;
    uint public _plainCount = 0;

    struct IdentityConfig{
        uint price;
        uint preSaleCount;
        uint preSaleAddress;
    }

    struct RewardRecord{
        address inviter;
        uint classA;
        uint classB;
        uint count;
        uint claim;
        uint creation;
        uint plain;
    }

    struct PresaleRecord{
        uint256 payAmount;
        uint256 claimCountTokens;
        uint256 claim;
    }
    IdentityConfig public _identity;
    mapping(address=>PresaleRecord) public _record;
    mapping(address=>RewardRecord) public _reward;
    mapping(address=>bool) public _admin;

    constructor()  {
        _owner = msg.sender;
        _claimToken = ERC20(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D);
        _payToken = ERC20(0x55d398326f99059fF775485246999027B3197955);
        _collection = payable(0xc8E3b56eaf9C798b15ac6FAa5971Bf81b6378f21);
        //
        _identity = IdentityConfig(
            10,
            0,
            0
        );
        //
        _admin[_owner] = true;
        _admin[_collection] = true;
    }

    modifier onlyOwner() {
        require(_admin[msg.sender], "Ownable: caller is not the owner");
        _;
    }
    function setTokenAddr(address newtoken) public onlyOwner {
        _claimToken = ERC20(newtoken);
    }
    function setCollectionAddr(address payable newAddress) public onlyOwner {
        _collection = newAddress;
    }
    function setSaleTime(uint stime, uint etime) public onlyOwner{
        _saleStartTime = stime;
        _saleEndTime = etime;
    }
    function setClaimStartTime(uint time) public onlyOwner{
        _claimStartTime = time;
    }
    function setAB(uint A, uint B) public onlyOwner{
        _A = A;
        _B = B;
    }
    function setNFT(uint creation, uint plain) public onlyOwner{
        _creation = creation;
        _plain = plain;
    }

    function setPay(uint pay) public onlyOwner{
        _pay = pay;
    }

    function transferForeignToken(address token, address to) public onlyOwner{
        require(token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = ERC20(token).balanceOf(address(this));
        require(ERC20(token).approve(address(this),_contractBalance));
        require(ERC20(token).transfer(to, _contractBalance));
    }
    function transferForeignBNB(address to) public onlyOwner{
        uint256 amountBNB = address(this).balance;
        payable(to).transfer(amountBNB);
    }

    function mint(address invitee) public payable {

        require(_saleEndTime > 0 && _saleStartTime > 0,"There is no start or end time set");
        require(block.timestamp > _saleStartTime,"Not started");
        require(block.timestamp < _saleEndTime,"It's end");
        require(_payToken.balanceOf(msg.sender) >= _pay,"Insufficient wallet balance");

        uint256 total = _record[msg.sender].payAmount.add(_pay);

        PresaleRecord memory pRecord = _record[msg.sender];


        _identity.preSaleCount = _identity.preSaleCount.add(_pay);
        if(pRecord.payAmount == 0){
            _identity.preSaleAddress += 1;
        }

        _record[msg.sender] = PresaleRecord(
            total,
            pRecord.claimCountTokens.add(_pay.mul(_identity.price)),
            0
        );

        if(invitee != address(0) && invitee != msg.sender){
            if(_reward[msg.sender].inviter == address(0) && _reward[invitee].inviter != msg.sender){
                _reward[msg.sender].inviter = invitee;
            }else{
                invitee = address(0);
            }
        } else if(_reward[msg.sender].inviter != address(0)){
            invitee = _reward[msg.sender].inviter;
        }
        uint256 toReward = 0;
        if(invitee != address(0) && invitee != msg.sender){
            //class a
            toReward = _pay.mul(_A).div(100);
            _reward[invitee].count = _reward[invitee].count.add(toReward);
            _reward[invitee].classA += 1;
            //class b
            if(_reward[invitee].inviter != address(0)){
                uint256 toRewardNode = _pay.mul(_B).div(100);
                address inviter = _reward[invitee].inviter;
                _reward[inviter].count = _reward[inviter].count.add(toRewardNode);
                _reward[inviter].classB += 1;
                toReward = toReward.add(toRewardNode);
            }
            //NFT
            if (_creationCount <= 50){
                _reward[invitee].creation = _reward[invitee].classA.div(_creation);
                _creationCount += _reward[invitee].creation;
            }
            if (_plainCount <= 8888){
                _reward[invitee].plain = _reward[invitee].classA.div(_plain);
                _plainCount += _reward[invitee].plain;
            }
        }
        if (toReward > 0){
            require(_payToken.transferFrom(msg.sender,address(this), toReward),"Not Enough tokens Transfered");
            require(_payToken.transferFrom(msg.sender,_collection, _pay.sub(toReward)),"Transfered error");
        } else{
            require(_payToken.transferFrom(msg.sender,_collection, _pay),"Transfered error");
        }
    }
    function getClaimTokens(address addr) view public returns (uint256){
        PresaleRecord memory record = _record[addr];

        //require(block.timestamp > _saleEndTime,"The presale is not over");
        require(_claimStartTime > 0 && block.timestamp > _claimStartTime,"Not started");
        require(record.claim < record.claimCountTokens,"finished claim");

        return record.claimCountTokens.sub(record.claim);
    }
    function claim() public returns (bool) {
        PresaleRecord memory record = _record[msg.sender];
        uint256 claimAmount = getClaimTokens(msg.sender);
        require(claimAmount > 0,"claim is zero");
        require(_claimToken.balanceOf(address(this)) >= claimAmount,"Not enough balance");

        require(_claimToken.approve(address(this),claimAmount));
        require(_claimToken.transferFrom(address(this),msg.sender, claimAmount),"Not Enough tokens Transfered");

        _record[msg.sender].claim = record.claim.add(claimAmount);
        return true;
    }
    function reward() public {
        uint256 myReward = _reward[msg.sender].count.sub(_reward[msg.sender].claim);
        require(myReward > 0,"reward is zero");

        _reward[msg.sender].claim = _reward[msg.sender].claim.add(myReward);
        require(_payToken.transfer(msg.sender, myReward),"Not Enough tokens Transfered");
    }
}