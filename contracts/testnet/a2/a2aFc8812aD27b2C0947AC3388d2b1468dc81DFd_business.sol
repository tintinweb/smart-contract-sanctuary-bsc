/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);
}


contract digital{
    address public _owner; 
    address public tokenContractAddr;
    address public UsdtTokenContract;
    uint public proportion;
    bool public subscribeSwitch; 

    mapping(address => uint256) public invitees; 
    mapping(address => address) public recommender;

    mapping(address => uint) public accountToken;

    mapping(address => uint) public subscriptionQuota;

    mapping(address => uint) public notes;


    event Operate(address userAddr, uint amount, uint amountTokens,address recommender);
    event Withdraw(address userAddr, address tokenContractAddr, uint amount);
    event TransferOwnership(address newOwner);
    event TransferEth(address userAddr, uint value);
    event TransferToken(address tokenAddr, address sender, address accept, uint amount);


    constructor() public {
        _owner = msg.sender;
        tokenContractAddr = 0x74ADe0DA17a4cA7FcdA6c8d9229bFE8D6BA70924;
        UsdtTokenContract = 0xA624499102B76Fb99c5Bb6C7337A985fEeeCF520;
        subscribeSwitch = true;
        proportion = 100; // 1:100
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function destoryContract() public onlyOwner{ 
        selfdestruct(msg.sender);
    }
    
}


contract business is digital {

    
    receive() external payable {}

    function operate(address userAddr, uint amount, address recommender) internal returns(bool){
        IERC20 erc20 = IERC20(UsdtTokenContract);
        //require(erc20.allowance(userAddr,address(this)) >= amount, "BEP20: Insufficient authorized amount");
        //require(erc20.balanceOf(userAddr) >= amount, "BEP20: Your account has insufficient usdt balance");

        require(erc20.transferFrom(userAddr,address(this),amount) == true, "BEP20: Deduction failed");
        accountToken[userAddr] += amount * proportion;
        invitees[recommender] += 1;
        subscriptionQuota[recommender] += 10;
        subscriptionQuota[userAddr] -= amount;
        notes[userAddr] += amount;
        emit Operate(userAddr,amount,amount * proportion,recommender);
        return true;

    }

    function subscribe(uint amount, address recommender) public returns(bool) {
        require(subscribeSwitch == true,"Subscription has ended");
        require(amount > 1,"Subscription amount does not meet the rules");

        if (notes[msg.sender] == 0){ 
            subscriptionQuota[msg.sender] += 100 * 10 ** 18; 
            require(subscriptionQuota[msg.sender] >= amount, "Insufficient quota");
            return operate(msg.sender,amount,recommender);
        }
        require(subscriptionQuota[msg.sender] >= amount, "Insufficient quota");
        return operate(msg.sender,amount,recommender);

    }

    

    
    function withdraw() external {
        uint amount = accountToken[msg.sender];
        require(subscribeSwitch == false, "Subscription is not over, withdrawal is prohibited");
        require(amount > 0, "ERC20: Your token balance is insufficient");
        accountToken[msg.sender] = 0;
        IERC20 erc20 = IERC20(tokenContractAddr);
        erc20.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, tokenContractAddr, amount);
    }

    function changeUsdtContract(address tokens) external onlyOwner {
        UsdtTokenContract = tokens;
    }



    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner !=  address ( 0 ), "new is 0" );
        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }

    
    function transferEth(uint _value) external onlyOwner {
        msg.sender.transfer(_value);
        emit TransferEth(msg.sender, _value);
    }

    
    function transferToken(address tokenAddr, address accept, uint amount) external onlyOwner returns(bool) {
        IERC20 erc20 = IERC20(tokenAddr);
        if (erc20.balanceOf(address(this)) >= amount) {
            erc20.transfer(accept, amount);
            emit TransferToken(tokenAddr, msg.sender, accept, amount);
            return true;
        } 
        return false;
    }

    
    function SubscriptionRatioChanges(uint value) external onlyOwner {
        proportion = value;
    }

    
    function tokenContractChanges(address tolenAddr) external onlyOwner {
        tokenContractAddr = tolenAddr;
    }

    function subscriptionSwitch() external onlyOwner {
        if (subscribeSwitch == true) {
            subscribeSwitch = false;
        }
        subscribeSwitch == true;
    }


    
    function getProportion() public view returns(uint) {
        return proportion;
    }

    
    function getTokenContract() public view returns(address) {
        return tokenContractAddr;
    }

    
    function getSubscriptionSwitch() public view returns(bool) {
        return subscribeSwitch;
    }
    

    
    function getBalance(address addr) public view returns(uint) {
        require(addr != address(0), "wrong address");
        return accountToken[addr];
    }


   
    function getInvitees(address addr) public view returns(uint) {
        return invitees[addr];
    }

    
    function getSubscriptionRecord(address to) public view returns(uint) {
        return notes[to];
    }

    
    function getSubscriptionQuota(address to) public view returns(uint) {
        return subscriptionQuota[to];
    }

    // getUsdtTokenContract
    function getUsdtTokenContract() public view returns(address) {
        return UsdtTokenContract;
    }


}