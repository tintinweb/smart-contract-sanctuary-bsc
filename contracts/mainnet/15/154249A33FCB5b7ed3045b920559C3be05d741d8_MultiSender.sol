/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

pragma solidity 0.4.23;

/** WenLambo Migration Aidrop smart contract
*/
/**
 * @title BEP20Basic
 * @dev Simpler version of BEP20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract BEP20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BEP20 is BEP20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MultiSender {
    mapping(address => uint256) public txCount;
    address public owner;
    address public pendingOwner;
    uint16 public arrayLimit = 500;
    uint256 public discountStep = 0.00000 ether;
    uint256 public fee = 0.00 ether;
    
    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
    modifier hasFee() {
        require(msg.value >= fee - discountRate(msg.sender));
        _;
    }

    function MultiSender(address _owner, address _pendingOwner) public {
        owner = _owner;
        pendingOwner = _pendingOwner;
    }

    function() public payable {}
    
    function discountRate(address _customer) public view returns(uint256) {
        uint256 count = txCount[_customer];
        return count * discountStep;
    }
    
    function currentFee(address _customer) public view returns(uint256) {
        return fee - discountRate(_customer);
    }
    
    function claimOwner(address _newPendingOwner) public {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
        pendingOwner = _newPendingOwner;
    }
    
    function changeTreshold(uint16 _newLimit) public onlyOwner {
        arrayLimit = _newLimit;
    }
    
    function changeFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
    }
    
    function changeDiscountStep(uint256 _newStep) public onlyOwner {
        discountStep = _newStep;
    } 
    
    function multisendToken(address token, address[] _contributors, uint256[] _balances) public hasFee payable {
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        BEP20 bep20token = BEP20(token);
        uint8 i = 0;
        require(bep20token.allowance(msg.sender, this) > 0);
        for (i; i < _contributors.length; i++) {
            bep20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
        Multisended(total, token);
    }
    
    function multisendEther(address[] _contributors, uint256[] _balances) public hasFee payable {
        // this function is always free, however if there is anything left over, I will keep it.
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _contributors[i].transfer(_balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
        Multisended(total, address(0));
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        BEP20 bep20token = BEP20(_token);
        uint256 balance = bep20token.balanceOf(this);
        bep20token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }
}